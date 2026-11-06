# Delivery and debugging

Serving headers, verifying what ReClash received, diagnosing failures, and rolling out changes.

## Serving headers

- Send metadata as response headers on the subscription URL. Proxies and CDNs must pass `reclash-*` headers through unchanged.
- Encode non-ASCII text as `base64:` ([Value formats](headers.md#value-formats)). Raw UTF-8 is often mangled.
- Limits: 8 KiB per value, 64 KiB for all headers. Exceeding either fails the fetch.
- Send each header once. Repeats are ignored.
- If headers cannot be set, use [body comments](headers.md#body-comments) at the top of the config.
- Send an empty value to clear a message. Omitting the header withdraws it.
- Send `x-hwid-max-devices-reached` only when refusing the device. It fails the update at any status.

## Verification

Repeat the request with the ReClash preset:

```sh
curl -sS -D - -o /dev/null \
  -H 'User-Agent: ReClash/v1.0.0 clash-verge Platform/android' \
  -H 'Accept-Encoding: gzip, deflate' \
  'https://sub.example.net/s/TOKEN'
```

In the app:

| Where | Shows |
| --- | --- |
| Profile editor → Compatibility → Check | Preset that succeeded, detected format, node count. Saves nothing. |
| Profiles → profile menu → Subscription inspector | What was decoded and kept ([Subscription inspector](#subscription-inspector)). |
| Dashboard and application settings | Applied hints, tagged "From provider". |

Validate routing with `dart run tool/rcx.dart lint` policy against [`provider-policy.schema.json`](../../../provider-policy.schema.json), and the hosted config against [`provider-config.schema.json`](../../../provider-config.schema.json).

## Subscription inspector

| Item | Meaning |
| --- | --- |
| Source | `http` if any field came from headers, otherwise `body`. |
| Received | Time of the last successful update. |
| Device status | `limitReached` or `unsupported`, when sent. |
| Warnings | Decoder warnings, such as `Invalid provider field`, `Duplicate singleton`, `Unsupported provider field`. |
| Fields | Stored fields by header name, with trust level and a `stale` tag where a usage field was missing. |

## Common failures

| Symptom | Cause |
| --- | --- |
| A field is missing, with `Invalid provider field` | Value breaks its type: bad token, number out of range, URL with userinfo, control characters. One bad token or host invalidates the field. |
| `Unsupported provider field` | Misspelled header, or `flclashx-*` under a non-FlClashX preset. |
| Old value gone after removing a header | Omitting withdraws it. Usage fields stay stale instead. |
| Reminders stopped | Usage field stale, `Subscription-Userinfo` missing, `expire=0` or `total=0`. |
| Update interval ignored | "Use provider update interval" is off in the profile editor (default). |
| Interval rejected | Below 5 or above 43200 minutes after scaling. |
| Setting no longer follows the provider | The user changed it. "Return to provider" restores it. |
| Fallback hosts not tried | Subscription is `http`, hosts came in the same failing response, or the failure was `401`, `403` or a device limit. |
| Routing bundle not applied | Not `https` for an `https` subscription, over 256 KiB, empty, or invalid YAML. Download errors go to the app log. |
| Global mode gone | `noglobal`, or a policy with `global.allow: []`. |
| Policy import fails | Unknown key or version; duplicate or unknown `reclash-id`. |
| "Restart the VPN" with a policy | Required exclusions changed while the VPN was running. |
| Automatic negotiation stops on the first error | Only `406`, `415` and an unknown body format try the next preset. |
| Non-ASCII text is garbled | Raw UTF-8 in a header. Use `base64:`. |

## Rollout checklist

- [ ] Body is a valid mihomo config with at least one node, group or remote provider.
- [ ] `Subscription-Userinfo` is present and correct.
- [ ] Non-ASCII text uses `base64:`.
- [ ] Each header is sent once and passes every proxy layer.
- [ ] The Subscription inspector shows no warnings or stale fields.
- [ ] Settings-changing hints are intended: [App settings](app-settings.md).
- [ ] Routing bundle and inline profiles pass `rcx.dart lint`.
- [ ] Any policy passes the schema, and every `reclash-id` is unique.
- [ ] Any [hosted config](config.md) passes `provider-config.schema.json`, and the Subscription inspector shows no config warnings.
- [ ] Fallback hosts serve the same path and query.
- [ ] Device ID matches [Device ID](request.md#device-id); `x-hwid-max-devices-reached` is sent only on refusal.
- [ ] Any [Preview API](preview-api.md) endpoint changes no account state.
