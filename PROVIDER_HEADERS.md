# Subscription response headers

ReClash can read account data and provider-specific metadata from the HTTP response that returns a subscription. These headers are optional: the subscription body remains the source of the proxy configuration, while headers add usage data, update policy, provider links, dashboard content, and appearance.

Header names are case-insensitive. When a ReClash header and one of its compatibility aliases are both present, the `reclash-*` value wins. Empty and unknown headers are ignored. If a response repeats the same header, ReClash joins its values with commas before parsing it.

## Response example

```http
HTTP/1.1 200 OK
Content-Type: application/yaml; charset=utf-8
Subscription-Userinfo: upload=1048576; download=2097152; total=107374182400; expire=1798761600
Profile-Title: Example VPN
ReClash-AutoUpdateInterval: 60
ReClash-Announce: Maintenance is scheduled for Sunday.
ReClash-SupportURL: https://support.example.com
ReClash-ServiceName: Example VPN
ReClash-ServiceLogo: https://cdn.example.com/logo.svg
ReClash-ServerInfo: Proxy
ReClash-ActiveText: Protected by Example VPN
ReClash-BuyPlan: https://example.com/plans
ReClash-BuyTraffic: https://example.com/traffic
ReClash-View: type:list; sort:delay; layout:tight; icon:none; card:min
ReClash-Hex: FF5733:vibrant:pureblack
ReClash-Background: https://cdn.example.com/background.webp,18
ReClash-HeroRing: 2E5BFF;7A36F0;FF1744
ReClash-Widgets: networkSpeed,trafficUsage,serviceInfo,changeServerButton
ReClash-Custom: add
ReClash-Settings: autorun,autoupdate
ReClash-NewDomain: subscriptions.example.net
ReClash-FallbackHosts: spare-a.example.com,spare-b.example.com
```

`upload`, `download`, and `total` are byte counts. `expire` is a Unix timestamp in seconds.

## Common subscription headers

| Header | Value | ReClash behavior |
| --- | --- | --- |
| `subscription-userinfo` | `upload=<bytes>; download=<bytes>; total=<bytes>; expire=<unix-seconds>` | Shows traffic usage and expiration information. |
| `profile-title` | Profile name, plain UTF-8 or Base64 | Names the imported profile unless the user has renamed it. Use `base64:` for non-ASCII text. |
| `content-disposition` | A response filename | Used as a profile-name fallback. |
| `profile-update-interval` | Positive integer, in hours | Sets the profile update interval. |
| `support-url` | Provider support URL | Adds a support action. Use an absolute HTTPS URL. |
| `announce` | Plain text or Base64 | Shows a provider announcement. |

## ReClash headers

| Header | Value | Purpose |
| --- | --- | --- |
| `reclash-announce` | Plain text or Base64 | Provider announcement. Takes priority over `announce`. |
| `reclash-supporturl` | Provider support URL | Support page. Use an absolute HTTPS URL. |
| `reclash-autoupdateinterval` | Positive integer, in minutes | Profile update interval. |
| `reclash-servicename` | Plain text or Base64 | Provider name shown in the dashboard. |
| `reclash-servicelogo` | Absolute HTTPS image URL | Provider logo shown in the dashboard and connection control. |
| `reclash-serverinfo` | Proxy-group name, plain text or Base64 | Group used to resolve the active server shown in the dashboard. |
| `reclash-activetext` | Plain text or Base64 | Replaces the active protection caption under the hero orb and in the Android notification. |
| `reclash-buyplan` | Provider URL | Subscription renewal or plan purchase action. Use an absolute HTTPS URL. |
| `reclash-buytraffic` | Provider URL | Extra-traffic purchase action. Use an absolute HTTPS URL. |
| `reclash-view` | Proxy-page tokens | Suggests the proxy-page presentation for this profile. |
| `reclash-hex` | Theme tokens | Applies a theme while this profile is active. |
| `reclash-background` | Image URL and optional opacity | Applies a dashboard background while this profile is active. |
| `reclash-heroring` | Three colors | Sets the connected-state hero-ring gradient. |
| `reclash-widgets` | Comma-separated widget names | Suggests dashboard widgets and their order. |
| `reclash-custom` | `add` or `update` | Controls how `reclash-widgets` is merged. |
| `reclash-settings` | Comma-separated setting tokens | Supplies application defaults when the profile is first added. |
| `reclash-newdomain` | Hostname with optional port | Proposes a subscription-domain migration subject to fetch and configuration checks. |
| `reclash-fallbackhosts` | Up to four comma-separated hostnames | Supplies fallback hosts for transient fetch failures. |

## Text and Base64

`reclash-announce`, `reclash-servicename`, `reclash-serverinfo`, and `reclash-activetext` accept plain text and Base64. `profile-title` follows the same practical convention. Prefix encoded values with `base64:` or `base64,`:

```http
ReClash-ServiceName: base64:0J/RgNC40LzQtdGAIFZQTg==
```

The prefix is recommended even though ReClash can recognize some unprefixed Base64 values. Invalid payloads remain plain text instead of failing the subscription update. `reclash-activetext` is trimmed after decoding. If it is absent or empty, ReClash uses its localized protection caption; a later successful refresh without the header clears the previous override.

## Appearance

### Provider logo

`reclash-servicelogo` should be an absolute HTTPS URL to a PNG or SVG hosted by the provider. Use a square image with a transparent background rather than a wide wordmark. A 256–512 px source with important content inside the central 80% works well at the small sizes used by the interface. Keep brand color in `reclash-hex`; do not bake a large colored tile into the logo.

### Theme

`reclash-hex` accepts a 6-digit `RRGGBB` color or an 8-digit `AARRGGBB` color, optionally followed by a scheme variant and `pureblack`. Separate tokens with `:`, `;`, or `,`:

```http
ReClash-Hex: FF5733:vibrant:pureblack
```

Supported variants are `tonalspot`, `fidelity`, `monochrome`, `neutral`, `vibrant`, `expressive`, and `content`. Theme values dress the active profile without overwriting the user's saved theme.

### Background

`reclash-background` accepts an absolute HTTP or HTTPS image URL followed by an optional opacity from 1 to 100. The default is 10. URLs containing credentials and non-web schemes are rejected.

```http
ReClash-Background: https://cdn.example.com/background.webp,18
```

### Hero ring

`reclash-heroring` requires exactly three `RRGGBB` or `AARRGGBB` colors separated by semicolons or commas. A leading `#` is accepted.

```http
ReClash-HeroRing: 2E5BFF;7A36F0;FF1744
```

### Proxy page

`reclash-view` is a semicolon- or comma-separated set of `key:value` tokens:

```http
ReClash-View: type:list; sort:delay; layout:tight; icon:none; card:min
```

| Key | Values |
| --- | --- |
| `type` | `tab`, `list` |
| `sort` | `default`, `none`, `delay`, `name` |
| `layout` | `loose`, `standard`, `tight` |
| `icon` | `none`, `standard`, `icon` |
| `card` | `expand`, `shrink`, `min`, `oneline` |

`oneline` maps to the closest ReClash size, `min`. The suggestion follows the active profile and applies only to fields the user has not customized; users can stop following provider layout entirely.

## Dashboard widgets

`reclash-widgets` accepts the following names. Matching is case-insensitive; the canonical spellings below are recommended.

| Widget | Availability |
| --- | --- |
| `networkSpeed` | All platforms |
| `outboundModeV2` | All platforms |
| `outboundMode` | All platforms |
| `trafficUsage` | All platforms |
| `networkDetection` | All platforms |
| `tunButton` | Windows, macOS, Linux |
| `vpnButton` | Android |
| `systemProxyButton` | Windows, macOS, Linux |
| `intranetIp` | All platforms |
| `memoryInfo` | All platforms |
| `metaInfo` | All platforms |
| `announce` | All platforms |
| `serviceInfo` | All platforms |
| `changeServerButton` | All platforms |

Unsupported names and widgets unavailable on the current platform are ignored. Duplicates are removed.

`reclash-custom: update` replaces the current widget list with the supported provider list. The default mode is `add`: ReClash adopts the provider order while the user still has the default or previous provider layout; after a user customization, missing provider widgets are appended without removing the user's choices.

## Initial application settings

`reclash-settings` is offered only when a URL profile is first added. ReClash shows the requested app-wide changes and applies them only after the user confirms. Later subscription updates do not overwrite these user-owned settings.

| Token | Initial value enabled |
| --- | --- |
| `minimize` | Minimize instead of exiting |
| `autorun` | Start the connection when ReClash opens |
| `shadowstart` | Launch ReClash in the background |
| `autostart` | Launch ReClash at operating-system startup |
| `autoupdate` | Check for ReClash updates at startup |
| `openlogs` | Open logs with the connection |
| `closeconnections` | Close existing connections when the VPN pauses |

Only listed tokens are enabled; unlisted app settings keep their current values. Token matching is case-insensitive.

## Domain migration and fallback hosts

`reclash-newdomain` contains only a hostname and optional port, without a scheme, path, query, or credentials:

```http
ReClash-NewDomain: subscriptions.example.net
```

ReClash preserves the original URL scheme, path, query, and token, downloads the subscription from the proposed authority, validates the configuration, and checks that it contains a dialable node. The stored subscription URL changes only after those checks succeed.

`reclash-fallbackhosts` contains bare hostnames without ports. ReClash lowercases and deduplicates them, keeps at most four, and preserves the original URL path and query when trying one. Fallbacks are used for transport failures, timeouts, HTTP 408/429, and server errors; they are not used to bypass ordinary authentication or client errors.

```http
ReClash-FallbackHosts: spare-a.example.com,spare-b.example.com
```

## Device identity and provider verdicts

Sending device identity is disabled by default and controlled by the user in ReClash settings. When enabled for subscription refreshes, ReClash sends:

| Request header | Value |
| --- | --- |
| `x-hwid` | Stable 16-character device hash |
| `x-device-os` | Operating-system name |
| `x-ver-os` | Operating-system version |
| `x-device-model` | Device model or host name |

The initial profile import sends identity headers only when the user enabled the setting. A provider can return either verdict below with the value `true`:

| Response header | Effect |
| --- | --- |
| `x-hwid-max-devices-reached` | Shows the device-limit message and offers `reclash-supporturl` when available. |
| `x-hwid-not-supported` | Shows that the selected client/device mode is unsupported. |

Do not use these headers as an authentication boundary: they are client-supplied metadata.

## Compatibility aliases

ReClash accepts selected Clash and FlClashX spellings for interoperability. This compatibility does not imply affiliation with or endorsement by those projects. The first present header in each row wins, from left to right.

| ReClash field | Accepted headers in priority order |
| --- | --- |
| Announcement | `reclash-announce`, `announce` |
| Support URL | `reclash-supporturl`, `support-url`, `flclashx-supporturl` |
| Update interval | `reclash-autoupdateinterval` (minutes), `profile-update-interval` (hours), `flclashx-autoupdateinterval` (hours) |
| Service name | `reclash-servicename`, `flclashx-servicename` |
| Service logo | `reclash-servicelogo`, `flclashx-servicelogo` |
| Server-info group | `reclash-serverinfo`, `flclashx-serverinfo` |
| Active protection text | `reclash-activetext` |
| Plan URL | `reclash-buyplan`, `flclashx-buyplan` |
| Traffic URL | `reclash-buytraffic`, `flclashx-buytraffic` |
| Proxy view | `reclash-view`, `flclashx-view` |
| Theme | `reclash-hex`, `flclashx-hex` |
| Background | `reclash-background`, `flclashx-background` |
| New domain | `reclash-newdomain`, `flclashx-newdomain` |

There are no FlClashX aliases for the active protection text, hero ring, widget list, widget merge mode, initial settings, or fallback hosts.

## Security and privacy

Return provider metadata only over HTTPS and keep linked assets on infrastructure you control. Treat subscription URLs and their query parameters as credentials: never place them in logos, support links, logs, examples, or public bug reports. Keep announcements short and do not put executable markup in headers.

Users should import subscriptions only from providers they trust. A subscription response can change the profile update interval, add external links and remote images, suggest appearance and dashboard layout, or propose a new subscription host. ReClash validates formats where applicable, but that does not make an untrusted provider safe.
