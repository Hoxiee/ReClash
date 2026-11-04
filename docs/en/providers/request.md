# Request headers

What ReClash sends when it fetches a subscription, how it picks a client identity, and how it handles redirects, statuses and fallback hosts.

## Client headers

| Header | Value |
| --- | --- |
| `User-Agent` | Set by the [client preset](#client-presets). |
| `Accept-Encoding` | `gzip, deflate` |
| `Authorization` | `Basic`, built from the subscription URL's userinfo. |
| `x-hwid` | Device ID, only when [enabled](#device-id). |
| `x-client`, `x-app-version`, `x-device-locale`, `Accept-Language` | Only under the Happ and INCY presets. |

## Client presets

The profile's "Request as" setting picks the preset. New profiles use Automatically; profiles created before the setting existed use ReClash.

| Preset | `User-Agent` | Extra headers |
| --- | --- | --- |
| ReClash | `ReClash/v<version> clash-verge Platform/<os>` | — |
| FlClashX | `FlClash X/v0.4.2 core/v1.19.28 Platform/<os>` | — |
| Clash Meta | `ClashMetaForAndroid/2.11.36.Meta` | — |
| Clash | `ClashForAndroid/2.5.12` | — |
| Happ | `Happ/4.7.1/<Platform>/17912103176801703650` | `x-device-locale: <language>` |
| INCY | `INCY/3.3.1` | `x-client: INCY`, `x-app-version: 3.3.1`, `x-device-locale: <locale>`, `Accept-Language: <locale>` |
| sing-box / Karing | `Karing/1.2.25.2802` | — |
| v2rayNG | `v2rayNG/2.3.11` | — |
| Custom User-Agent | User text, at most 512 characters, no control characters | — |

`<os>` is `android`, `windows`, `macos` or `linux`. The app-wide User-Agent setting can replace the ReClash value.

### Automatic negotiation

Automatically tries the last successful preset first, then the table order from ReClash to v2rayNG. Presets that would send identical headers are skipped. At most 8 attempts run within 20 seconds.

The next preset is tried only on `406`, `415` or an unknown body format. Any other failure stops negotiation. `flclashx-*` metadata applies only to the FlClashX preset ([FlClashX names](headers.md#flclashx-names)).

A preset changes only request headers, never the device ID.

## Redirects and transport

- Up to 5 redirects. Each response carries exactly one `Location`. Loops and `https` to `http` fail.
- A redirect to another origin keeps only `User-Agent`, `Accept` and `Accept-Language`. The device ID and authorization are dropped.
- `Content-Encoding` must be `gzip`, `deflate` or `identity`, sent once. Gzip and zlib bodies are also detected by magic bytes.
- The body may be 16 MiB on the wire and 32 MiB decoded. An empty body fails.
- `Content-Type` is not checked.

## Response formats

ReClash detects the body format locally. Native Clash YAML is kept as-is; share-link lists, Xray JSON (one configuration or an array), sing-box JSON, WireGuard and supported Amnezia containers are converted to Clash YAML before Core validation.

Share-link lists accept plain text, Base64 and Base64url. Supported schemes include `mierus`, `socks5h`, `hysteria2+realm` and `hy2+realm`; Mieru links can define several port/protocol pairs. Unrecognized or malformed node links in a recognized list are reported as skipped.

VLESS XHTTP conversion preserves supported `extra` options, including headers, padding, connection reuse and a separate download connection. Unsupported or malformed extra options are reported as conversion losses. Foreign DNS, inbound and other unconverted configuration sections are also reported, including for every configuration in an Xray array. Losses require approval or an already accepted import policy for that source; an unapproved update leaves the saved profile unchanged.

## Response status

| Response | Result |
| --- | --- |
| `x-hwid-max-devices-reached: 1` with any status | Device-limit failure. The error offers `reclash-supporturl` from the same response, if it is an `http(s)` link. |
| `401`, `403` | Unauthorized. |
| `429` | Rate-limited. |
| `406`, `415` | Fails; Automatically tries the next preset. |
| Other non-`2xx` | Fails. |
| `2xx` with an empty body, or no nodes, groups or remote providers | Fails. |
| `2xx` in an unknown format | Fails; Automatically tries the next preset. |

A failed update leaves the saved profile, its metadata and its policy unchanged.

## Fallback hosts

Both fields work only for `https` subscriptions. The path and query are kept; only `host[:port]` changes.

| Header | Value | Behavior |
| --- | --- | --- |
| `reclash-fallbackhosts` | Up to 5 `host[:port]` | Tried in order after a transport, TLS, timeout, rate-limit or invalid-response error on the main host. Never replaces the stored URL. |
| `reclash-newdomain` | One `host[:port]` | Tried first. After a successful update, the new host is fetched and validated; the profile moves to it only if that succeeds. Failure is ignored. |

Fallbacks come from stored metadata, so an earlier successful update must deliver them. Requests to them carry the same headers as to the main host, including the device ID.

```http
reclash-fallbackhosts: sub2.example.net, sub3.example.org:8443
reclash-newdomain: sub.example.com
```

## Device ID

### Values

| Header | Value |
| --- | --- |
| `x-hwid` | First 32 lowercase hex characters of SHA-256 over `ReClash/HWID/v1\0` and a platform ID. |
| `x-device-os`, `x-ver-os`, `x-device-model` | OS name, OS version and device model. All three headers are sent with `x-hwid`; values the platform does not report are empty. |

The platform ID is `ANDROID_ID` on Android, `MachineGuid` on Windows, the system GUID on macOS and `/etc/machine-id` on Linux. A random value is used when none exists. The ID is stored per device, is the same for every profile, and is excluded from backups. It is a pseudonymous identifier, not hardware attestation.

### Consent

- "Send HWID" has a global value and a per-profile override; "Use global" follows the global value.
- Turning it on shows a disclosure.
- The ID goes only to the subscription URL's origin and its fallback hosts. A cross-origin redirect drops it.
- [Preview API](preview-api.md) and logo requests never carry it.

## Device status

| Header | Value | Effect |
| --- | --- | --- |
| `x-hwid-max-devices-reached` | `1`, `true` or `yes` | The update fails with a device-limit error ([Response status](#response-status)). |
| `x-hwid-not-supported` | `1`, `true` or `yes` | Shown as "Device status" in the Subscription inspector. |

A flag counts only when its header is sent once. When both are set, the device limit wins.
