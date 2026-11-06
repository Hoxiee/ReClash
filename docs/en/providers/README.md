# Provider integration

How a subscription provider delivers configuration, metadata, routing and policy to ReClash. Start with the [Quick start](manifest.md#quick-start), then open the page for your area.

## Model

A subscription is one HTTP GET. The body is plain mihomo; headers carry per-user data and one pointer to a manifest that carries everything else.

| Channel | Carries | Reference |
| --- | --- | --- |
| Body | mihomo (Clash) YAML, only keys mihomo understands. Share links, Xray, sing-box, WireGuard and Amnezia are converted on import and may lose data. AGE-encrypted bodies are decrypted first. The native `GLOBAL` group and `tun.exclude-package` carry the [safety policy](policy.md). | — |
| Standard headers | `Subscription-Userinfo`, `Content-Disposition`, `profile-title`, `profile-update-interval`, and the aliases `support-url`, `profile-web-page-url`, `announce`, `hide-url`. | [Response headers](headers.md) |
| `reclash-config` header | The pointer to the manifest, and the only `reclash-*` header. Any other `reclash-*` header is ignored with a warning. | [Manifest pointer](headers.md#manifest-pointer) |
| Manifest | One static YAML file shared by all users: provider panel, reminders, settings, policy, Android apps, transport, support, appearance, cards, power labels, routing. | [Provider manifest](manifest.md) |
| Device headers | `x-hwid`, `x-hwid-max-devices-reached` and related headers. | [Request headers](request.md) |
| Preview endpoint | JSON shown before a browser import is confirmed. It runs before any subscription exists, so it cannot use the manifest. | [Preview API](preview-api.md) |

## Fetch cycle

1. Sends the request with the profile's client preset and the device ID, if enabled ([Request headers](request.md)).
2. Follows up to 5 redirects and decodes the body ([Redirects and transport](request.md#redirects-and-transport)).
3. Decodes headers against the [registry](standard.md). Invalid values are dropped with a warning.
4. Merges the result into stored metadata ([Metadata lifetime](#metadata-lifetime)).
5. Fetches the manifest named by `reclash-config`, if any ([Delivery](manifest.md#delivery)).
6. Applies configuration, manifest and policy.

The update is rejected, and the saved profile stays unchanged, when the body is empty, its format is unknown, or it has no nodes, groups or remote providers.

## Trust levels

| Level | Effect | Examples |
| --- | --- | --- |
| `display` | Shown to the user. No behavior change. | `provider.name`, `provider.announce`, `provider.hide-url` |
| `hint` | Changes behavior within fixed bounds. | `settings`, `apps.exclude`, `reminders` |
| `consent` | Needs the user's agreement before it acts. | `support.keys`, `support.upload-url` |

Most hints yield to user changes ([Ownership](manifest.md#ownership)). Only [`policy`](manifest.md#policy) sets limits the user cannot lift.

## Metadata lifetime

Usage and the manifest age differently.

| Data | Lifetime |
| --- | --- |
| Standard headers | Each successful update merges them over the stored ones. A response field replaces the stored value. A missing usage field (`Subscription-Userinfo`) keeps its last value and is marked stale; expiry and traffic reminders are suppressed while stale. Any other missing header is withdrawn, and a setting that followed it returns to the user's value. |
| Manifest | Replaced as a whole after full validation. A failed or invalid fetch keeps the last valid copy. A response without `reclash-config` deletes the stored copy. A section missing from a new valid copy is withdrawn. |

A failed update changes nothing. The [Subscription inspector](rollout.md#subscription-inspector) lists stale fields and warnings.

## Standard version

The registry is standard version 1. The [standard registry](standard.md) is generated from code: headers, manifest fields, types, trust levels and size limits. The machine-readable copy is [`provider_standard.g.json`](../../../provider_standard.g.json).

## Minimal response

```http
HTTP/1.1 200 OK
Content-Type: text/yaml; charset=utf-8
Content-Disposition: attachment; filename*=UTF-8''Example%20VPN
Subscription-Userinfo: upload=0; download=2147483648; total=107374182400; expire=1798761600
profile-update-interval: 12
reclash-config: https://example.net/reclash.yaml

proxies:
  - name: Germany
    type: socks5
    server: de.example.net
    port: 1080
proxy-groups:
  - name: Proxy
    type: select
    proxies: [Germany]
rules:
  - MATCH,Proxy
```

```yaml
version: 1
provider:
  name: Example VPN
  support-url: https://t.me/example_support
```

## Compatibility

- Other clients' headers are read as standard headers: `Subscription-Userinfo`, `Content-Disposition`, `profile-title`, `profile-update-interval`, `profile-web-page-url`, `support-url`, `announce`, `hide-url`.
- A provider that already serves them adds one `reclash-config` header. Other clients ignore it. A Remnawave panel needs one response rule ([Remnawave](rollout.md#remnawave)).
- A preset can present ReClash as another client ([Client presets](request.md#client-presets)). It never enables the device ID.

## Pages

| Page | Content |
| --- | --- |
| [Response headers](headers.md) | Standard headers, value formats, aliases, the manifest pointer. |
| [Provider manifest](manifest.md) | Quick start, full example, editor validation; provider panel, reminders, settings, policy, apps, transport, support, appearance, cards, power labels, routing. |
| [Request headers](request.md) | Client headers, presets, redirects, statuses, fallback hosts, device ID. |
| [Safety policy](policy.md) | The `policy` section: GLOBAL allowlist, no Global mode, required Android exclusions. |
| [Preview API](preview-api.md) | Presentation before a browser import. |
| [Support reports and fix links](support.md) | One-button reports, upload endpoint, signed fix links. |
| [Delivery and debugging](rollout.md) | Serving, Remnawave, verification, failures, checklist. |
| [Standard registry](standard.md) | Generated header and manifest field tables. |
