# Provider integration

How a subscription provider delivers configuration, metadata, routing and policy to ReClash. Start here, then open the page for your area.

## Model

A subscription is one HTTP GET. The body carries configuration; headers carry metadata.

| Channel | Carries | Reference |
| --- | --- | --- |
| Body | mihomo (Clash) YAML. Share links, Xray, sing-box, WireGuard and Amnezia are converted on import and may lose data. AGE-encrypted bodies are decrypted first. | — |
| Response headers | Account, panel, appearance, reminders, transport, app hints. | [Response headers](headers.md) |
| Body comments | Same metadata as leading `#name: value` lines, for hosts that cannot set headers. | [Body comments](headers.md#body-comments) |
| Body keys | `rcx-profiles`, `rcx-scenarios`, `rcx-scenario`, group key `rcx`, `reclash-policy`. Vanilla mihomo ignores them. | [Routing delivery](routing.md), [Required safety policy](policy.md) |
| Routing bundle | Separate YAML named by `reclash-routing`. | [Routing bundle](routing.md#routing-bundle) |
| Hosted config | Separate static YAML named by `reclash-config`: cards, power-button labels, appearance. | [Hosted config](config.md) |
| Preview endpoint | JSON shown before a browser import is confirmed. | [Preview API](preview-api.md) |

## Fetch cycle

1. Sends the request with the profile's client preset and the device ID, if enabled ([Request headers](request.md)).
2. Follows up to 5 redirects and decodes the body ([Redirects and transport](request.md#redirects-and-transport)).
3. Decodes headers and body comments against the [registry](standard.md). Invalid values are dropped with a warning.
4. Merges the result into stored metadata ([Metadata lifetime](#metadata-lifetime)).
5. Fetches the routing bundle, if named.
6. Fetches the hosted config, if named.
7. Applies configuration, hints and policy.

The update is rejected, and the saved profile stays unchanged, when the body is empty, its format is unknown, or it has no nodes, groups or remote providers.

## Trust levels

| Level | Effect | Examples |
| --- | --- | --- |
| `display` | Shown to the user. No behavior change. | `reclash-servicename`, `reclash-announce`, `reclash-hideurl` |
| `hint` | Changes behavior within fixed bounds. | `reclash-autoupdateinterval`, `reclash-settings`, `reclash-excludeapps` |

The registry also defines `consent`, which no field uses yet. Most hints yield to user changes ([Ownership](app-settings.md#ownership)). Only [`reclash-restrictions`](app-settings.md#restrictions) and the [required safety policy](policy.md) set limits the user cannot lift.

## Metadata lifetime

Each successful update merges new fields over the stored ones:

- A response field replaces the stored value.
- A missing usage field (`Subscription-Userinfo`, `subscription.*`) keeps its last value and is marked stale. Expiry and traffic reminders are suppressed while stale.
- Any other missing field is withdrawn. A setting that followed it returns to the user's value.
- A failed update changes nothing.

The [Subscription inspector](rollout.md#subscription-inspector) lists stale fields and warnings.

## Standard version

The registry is standard version 1. The [standard registry](standard.md) is generated from code: fields, headers, types, trust levels and size limits. The machine-readable copy is [`provider_standard.g.json`](../../../provider_standard.g.json).

## Minimal response

```http
HTTP/1.1 200 OK
Content-Type: text/yaml; charset=utf-8
Content-Disposition: attachment; filename*=UTF-8''Example%20VPN
Subscription-Userinfo: upload=0; download=2147483648; total=107374182400; expire=1798761600
reclash-servicename: Example VPN
reclash-supporturl: https://t.me/example_support
reclash-autoupdateinterval: 720

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

## Compatibility

- Other clients' headers are also read: `Subscription-Userinfo`, `Content-Disposition`, `profile-title`, `profile-update-interval`, `profile-web-page-url`, `support-url`, `announce`, `hide-url`.
- `flclashx-*` headers are read only under the FlClashX preset ([FlClashX names](headers.md#flclashx-names)).
- A preset can present ReClash as another client ([Client presets](request.md#client-presets)). It never enables the device ID.

## Pages

| Page | Content |
| --- | --- |
| [Response headers](headers.md) | Parsing, value formats, account, panel, message and reminder fields. |
| [Request headers](request.md) | Client headers, presets, redirects, statuses, fallback hosts, device ID. |
| [App settings](app-settings.md) | Appearance, dashboard, flags, restrictions, Android apps. |
| [Hosted config](config.md) | Cards, power-button labels and appearance in a static YAML file. |
| [Routing delivery](routing.md) | Routing profiles and scenarios, inline or in a bundle. |
| [Required safety policy](policy.md) | GLOBAL allowlist, mandatory Android exclusions. |
| [Preview API](preview-api.md) | Presentation before a browser import. |
| [Support reports and fix links](support.md) | One-button reports, upload endpoint, signed fix links. |
| [Delivery and debugging](rollout.md) | Serving headers, verification, failures, checklist. |
| [Standard registry](standard.md) | Generated field and header tables. |
