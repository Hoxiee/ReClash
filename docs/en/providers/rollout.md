# Delivery and debugging

Go-live checklist for a provider, how to serve the headers and the manifest, how to verify what ReClash received, and how to diagnose failures.

## Go-live checklist

### Subscription

- [ ] The body is a valid mihomo config with at least one node, group or remote provider, and carries no `reclash-*` or `rcx-*` keys.
- [ ] `Subscription-Userinfo` is present and correct.
- [ ] Non-ASCII header text uses `base64:`.
- [ ] Each header is sent once and passes every proxy layer, CDN included.
- [ ] `reclash-config` is sent in an `https` response and names an `https` URL.
- [ ] `x-hwid-max-devices-reached` is sent only when refusing a device ([Device ID](request.md#device-id)).

### Manifest

- [ ] The file passes `provider-config.schema.json` ([Validate in your editor](manifest.md#validate-in-your-editor)), and its routing passes `dart run tool/rcx.dart lint`.
- [ ] Every section that changes settings is intended ([Ownership](manifest.md#ownership)).
- [ ] The file is served over `https` at a stable URL, at most 512 KiB.
- [ ] Fallback hosts serve the same path and query.

### Policy

- [ ] `policy.global: listed` has a `GLOBAL` group in the body, using `filter` or `proxies`, that yields exactly the nodes you allow. Check the body the client receives.
- [ ] `policy.apps: required` has `tun.exclude-package` in the body ([Safety policy](policy.md)).
- [ ] Any [Preview API](preview-api.md) endpoint changes no account state.

### In the app

- [ ] Update a real profile, open the [Subscription inspector](#subscription-inspector), and see no warnings and no stale fields.
- [ ] The dashboard shows the provider name, the cards and the settings tagged "From provider".
- [ ] Update the profile again: the sections and settings stay applied.

## Serving

- Send the standard headers on the subscription URL, plus one `reclash-config` header that names the manifest. Proxies and CDNs must pass headers through unchanged.
- Host the manifest on any static HTTPS host ([Delivery](manifest.md#delivery)). One shared URL is the normal case; per-user content needs a tokenized URL.
- The `reclash-config` header counts only in an `https` response, and a redirect must end on `https`.
- Encode non-ASCII header text as `base64:` ([Value formats](headers.md#value-formats)). Raw UTF-8 is often mangled. Manifest text is plain UTF-8 YAML.
- Limits: 8 KiB per header value, 64 KiB for all headers, 512 KiB for the manifest. Exceeding a header limit fails the fetch.
- Send each header once. Repeats are ignored.
- Omitting `reclash-config` deletes the stored manifest. `x-hwid-max-devices-reached` fails the update at any status.
- Without custom response headers a provider gets no ReClash features beyond the standard headers.

## Remnawave

Add one [response rule](https://docs.rw/docs/learn-en/routing-rules) in Subscription → Response Rules, above the default `Fallback Base64` rule. Rules run top to bottom and stop at the first match.

```json
{
  "name": "ReClash",
  "description": "Mihomo config and manifest for ReClash",
  "enabled": true,
  "operator": "AND",
  "conditions": [
    { "headerName": "user-agent", "operator": "STARTS_WITH", "value": "reclash", "caseSensitive": false }
  ],
  "responseType": "MIHOMO",
  "responseModifications": {
    "applyHeadersToEnd": true,
    "headers": [
      { "key": "reclash-config", "value": "https://example.net/reclash.yaml" }
    ]
  }
}
```

The rule does two jobs:

- It serves mihomo YAML. `ReClash/…` matches none of the default client rules, so without this rule a default panel answers with `Fallback Base64`. A Base64 list has no `GLOBAL` group and no `tun.exclude-package`, so `policy` has nothing to enforce.
- It sends the manifest to ReClash only. Other clients never see the header.

To serve the manifest differently:

| Who gets the manifest | Where the header goes |
| --- | --- |
| ReClash only | The rule above. |
| ReClash, one manifest per tariff | Delete `headers` from the rule and add the header to each external squad (Users → External Squads → squad → Headers). Users outside a squad get no manifest. Other clients in that squad also get the header and ignore it. |
| Every client | Subscription → Settings → Response headers. Other clients ignore it. |

A header left in the rule with `applyHeadersToEnd: true` overrides the squad's.

### Policy in the mihomo template

Put `GLOBAL` and `tun.exclude-package` into the mihomo template and switch them on with `policy` ([Safety policy](policy.md)). To keep them from other clients, give ReClash its own template with `subscriptionTemplate` in the rule's `responseModifications`.

> [!WARNING]
> Remnawave appends every host to each group that lacks `remnawave: { include-proxies: false }`, even a group with `filter`. Without it, `global: listed` allows every host and the [inspector](#subscription-inspector) warns `policy.global is listed, but GLOBAL reaches every inline node of the body, so the lock restricts nothing`. Set it on `GLOBAL` and on every group that `GLOBAL` reaches. The host name must carry the filter marker, because host `tags` do not reach the config.

```text
proxy-groups:
  - name: GLOBAL
    type: select
    include-all-proxies: true
    filter: '\bLTE\b'
    remnawave: { include-proxies: false }
```

### Things to know

- Give users the base subscription URL. A type-specific URL such as `/<short>/mihomo` skips response rules, so it carries no manifest.
- The rule depends on the User-Agent, which the user can change. A user who picks another [client preset](request.md#client-presets) gets no manifest and no locks. If that matters, send the header to every client and keep the rule only for mihomo YAML.
- `Subscription-Userinfo` and `Content-Disposition` come with every config response. `profile-title`, `profile-update-interval`, `support-url` and `profile-web-page-url` come from Response headers, which a new panel fills by default. `announce` needs the HWID `maxDevicesAnnounce` setting. ReClash reads all of them as standard headers.
- Host the manifest on any static host ([Quick start](manifest.md#quick-start)).

Checked on Remnawave 3.4.7. Panel labels may differ in other versions.

## Verification

Repeat the request with the ReClash preset:

```sh
curl -sS -D - -o /dev/null \
  -H 'User-Agent: ReClash/v1.0.0 clash-verge Platform/android' \
  -H 'Accept-Encoding: gzip, deflate' \
  'https://sub.example.net/s/TOKEN'
```

Fetch the manifest the header names, and check that it is plain YAML over `https`:

```sh
curl -sS -D - 'https://example.net/reclash.yaml'
```

In the app:

| Where | Shows |
| --- | --- |
| Profile editor → Compatibility → Check | Preset that succeeded, detected format, node count. Saves nothing. |
| Profiles → profile menu → Subscription inspector | What was decoded and kept ([Subscription inspector](#subscription-inspector)). |
| Dashboard and application settings | Applied hints, tagged "From provider". |

## Subscription inspector

| Item | Meaning |
| --- | --- |
| Source | `http` if any field came from headers, otherwise `body`. |
| Received | Time of the last successful update. |
| Device status | `limitReached` or `unsupported`, when sent. |
| Warnings | Decoder and manifest warnings, such as a binding to a missing group, `Invalid provider field`, `Duplicate singleton`, `Unsupported provider field`. |
| Fields | Stored fields by header name, with trust level and a `stale` tag where a usage field was missing. |

## Common failures

| Symptom | Cause |
| --- | --- |
| A header field is missing, with `Invalid provider field` | Value breaks its type: URL with userinfo, control characters, number out of range. |
| Manifest not applied | `reclash-config` not in an `https` response, URL or redirect not `https`, over 512 KiB, invalid YAML, or `version` is not `1`. The last valid copy stays; warnings are in the inspector. |
| A manifest section does nothing | The section is invalid and was ignored with a warning, or an unknown key was ignored. Check the inspector. |
| Old manifest values gone | The new valid copy lacks the section, or the response lacks `reclash-config`. Both withdraw the values. |
| `Unsupported provider field` for a `reclash-*` header | Only `reclash-config` is read. Move the value into the manifest. |
| Reminders stopped | Usage field stale, `Subscription-Userinfo` missing, `expire=0` or `total=0`. |
| Update interval ignored | "Use provider update interval" is off in the profile editor (default). |
| Interval rejected | Below 5 or above 43200 minutes after conversion from hours. |
| Setting no longer follows the provider | The user changed it. "Return to provider" restores it. |
| Fallback hosts not tried | Subscription is `http`, the hosts are not yet in a stored manifest, or the failure was `401`, `403` or a device limit. |
| `transport` section ignored | `new-domain` is a list or `fallback-hosts` is a string. |
| Routing binding not applied | The binding names a group the body does not have, for example after a rename. Update the manifest. |
| Global mode gone | `policy.global: off`, or `policy.global: listed` with a `GLOBAL` group that resolves to no node. |
| "Restart the VPN" with a policy | Required exclusions changed while the VPN was running. |
| Automatic negotiation stops on the first error | Only `406`, `415` and an unknown body format try the next preset. |
| Non-ASCII text is garbled | Raw UTF-8 in a header. Use `base64:`. |
