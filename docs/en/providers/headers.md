# Response headers

Parsing rules, value formats and the account, panel, message and reminder fields a subscription response can carry.

Every field, alias and limit is in the [Standard registry](standard.md). App-setting fields are in [App settings](app-settings.md), `reclash-routing` in [Routing delivery](routing.md), device headers in [Request headers](request.md#device-status).

## Parsing

- Header names are case-insensitive.
- A field is read from its canonical header. An alias is read only when the canonical header is absent, so an invalid canonical value never falls back to the alias.
- A field sent more than once is ignored: `Duplicate singleton`.
- An invalid value is dropped: `Invalid provider field`. The rest of the response applies.
- An unknown `reclash-*` or `flclashx-*` header warns: `Unsupported provider field`.
- A header value over 8 KiB, or over 64 KiB of headers in total, fails the fetch.
- A field missing from the response is withdrawn, except usage fields, which go stale ([Metadata lifetime](README.md#metadata-lifetime)).
- An empty value is valid for `text`, `tokens`, `pairs`, `numbers`, `hosts` and `packages` and replaces the stored value. `url`, `integer` and `boolean` fields cannot be cleared.

### Body comments

If the host cannot set headers, put the metadata first in the body as comments.

```yaml
#reclash-servicename: Example VPN
#reclash-supporturl: https://t.me/example_support
#reclash-announce: base64:0J/RgNC40LzQtdGAIFZQTg==
proxies:
  - name: Germany
```

- Only lines before the first line that is neither a comment nor empty are read, within the first 64 KiB.
- Names are any field header or alias, plus `flclashx-*` names under the FlClashX preset.
- An HTTP header wins over a comment for the same field.
- `Subscription-Userinfo` and device headers are read from HTTP only.

## Value formats

| Type | Syntax | Rules |
| --- | --- | --- |
| `text` | UTF-8, or `base64:` / `base64,` followed by Base64 of UTF-8 | Max 1024 bytes after decoding, unless the field says otherwise. No control characters; LF allowed in `reclash-announce` and `reclash-notice`. |
| `url` | Absolute `http` or `https` URL | Host required. No userinfo, whitespace or control characters. Max 1024 characters. |
| `integer` | Decimal | Multiplied by the alias scale, then range-checked. |
| `boolean` | `1`, `true`, `yes` / `0`, `false`, `no` | Case-insensitive. |
| `tokens` | Comma-separated | Lowercased, deduplicated. Each token matches `^[a-z0-9._:#-]{1,64}$`; one bad token invalidates the field. |
| `pairs` | `key:value;key:value` | Lowercased. Items without a colon are skipped. Keys and values follow the token rule. |
| `numbers` | Comma-separated integers | Sorted, deduplicated, max 8. One invalid or out-of-range number invalidates the field. |
| `hosts` | Comma-separated `host[:port]` | Lowercased; a leading `https://` and trailing `/` are dropped. One invalid entry invalidates the field. |
| `packages` | Android package names, separated by commas or whitespace | An invalid name is dropped alone, with a warning. Max 255 characters per name; over 512 names invalidates the field. |

`reclash-buyplan`, `reclash-buytraffic` and `reclash-background` take an optional integer after the last comma. An out-of-range integer is dropped with a warning; the main value still applies.

## Subscription-Userinfo

```http
Subscription-Userinfo: upload=455727941; download=6174315083; total=107374182400; expire=1798761600
```

| Key | Meaning |
| --- | --- |
| `upload`, `download` | Bytes used. |
| `total` | Byte quota. `0` means unlimited. |
| `expire` | Unix time in seconds. `0` means no expiry. |

Keys are case-insensitive and separated by `;`. Values are non-negative, truncated to integers; `expire` is at most `8640000000000`. A repeated key is discarded.

## Profile name

A profile the user has not named takes the first available of:

1. `Content-Disposition` filename (`filename*`, then `filename`);
2. `profile-title` (text, 160 B);
3. `reclash-servicename`;
4. the subscription host.

A name the user set is never replaced.

## Provider panel

| Header | Type | Shown as |
| --- | --- | --- |
| `reclash-servicename` | text, 160 B | Service name on the dashboard card and in the import dialog. |
| `reclash-servicelogo` | url | Logo on the simple dashboard. |
| `reclash-supporturl` | url | Support action. Also accepts `https://t.me/…`, `https://telegram.me/…` and `tg://` links, such as `tg://resolve?domain=…`. |
| `reclash-webpageurl` | url | Website action. |
| `reclash-subscriptiontype` | text, 32 B | Badge in the import dialog and profile list: `test`, `promo` or `dev`. Other values show none. |
| `reclash-hideurl` | boolean | Masks the URL in the profile editor and import dialog. It does not make the URL secret. |
| `reclash-serverinfo` | text, 256 B | Proxy group whose selected node the simple dashboard shows. Matched case-insensitively. |

## Messages

| Header | Type | Behavior |
| --- | --- | --- |
| `reclash-announce` | text, multiline, 1024 B | Description. Shown in the import dialog and in a dashboard card the user can move but not remove. |
| `reclash-announceurl` | url | Link on the description card. |
| `reclash-notice` | text, multiline, 1024 B | Dismissible dashboard notice. A dismissal is remembered for that exact text and link; a change shows it again. |
| `reclash-noticeurl` | url | Link on the notice. |

To remove a message, send its header with an empty value.

```http
reclash-notice: base64:TWFpbnRlbmFuY2Ugb24gMSBOb3ZlbWJlciwgMDI6MDDigJMwMzowMCBVVEMuCkNvbm5lY3Rpb25zIG1heSBkcm9wLg==
reclash-noticeurl: https://status.example.net
```

## Renewal and reminders

| Header | Value | Effect |
| --- | --- | --- |
| `reclash-buyplan` | `url[,days]`, days 1–3650 | Renew action, offered from `days` left. |
| `reclash-buytraffic` | `url[,percent]`, percent 1–100 | Top-up action, offered from `percent` of quota used. |
| `reclash-expiredays` | numbers 0–365 | Days before expiry that trigger a notification. Default `3,2,1`. |
| `reclash-trafficpercent` | numbers 1–100 | Percent of quota used that triggers a notification. Default `90`. |

- Reminders need `Subscription-Userinfo`. Expiry reminders are skipped for `expire=0`; traffic reminders for `total=0`.
- Each threshold notifies once per expiry date. A traffic threshold re-arms when usage drops below it.
- No reminder fires while a usage field is stale.
- The notification action is top-up for a traffic reminder (when `percent` is unset or reached), otherwise renew (when `days` is unset or reached), otherwise support.
- On the dashboard, renew appears from `days` left, or from the largest expiry threshold if `days` is unset. Top-up appears from `percent` used, or from the lowest traffic threshold if unset.

## Update interval

`reclash-autoupdateinterval` sets the update interval in minutes, 5–43200. The alias `profile-update-interval` is in hours. It applies only while "Use provider update interval" is on in the profile editor, which is off by default.

## Other fields

| Header | Page |
| --- | --- |
| `reclash-view`, `reclash-powerbutton`, `reclash-widgets`, `reclash-background` | [Appearance](app-settings.md#appearance) |
| `reclash-settings` | [Settings flags](app-settings.md#settings-flags) |
| `reclash-restrictions` | [Restrictions](app-settings.md#restrictions) |
| `reclash-excludeapps`, `reclash-includeapps`, `reclash-approuting` | [Android apps](app-settings.md#android-apps) |
| `reclash-fallbackhosts`, `reclash-newdomain` | [Fallback hosts](request.md#fallback-hosts) |
| `reclash-routing` | [Routing bundle](routing.md#routing-bundle) |
| `x-hwid-max-devices-reached`, `x-hwid-not-supported` | [Device status](request.md#device-status) |

## FlClashX names

With the FlClashX client preset, `flclashx-*` headers and comments map onto ReClash fields; other presets ignore them. A canonical `reclash-*` header wins over its FlClashX counterpart.

| FlClashX | ReClash |
| --- | --- |
| `flclashx-servicename`, `-servicelogo`, `-supporturl`, `-webpageurl`, `-buyplan`, `-buytraffic`, `-autoupdateinterval`, `-hideurl`, `-serverinfo`, `-widgets`, `-background`, `-view`, `-settings` | `reclash-` with the same suffix |
| `flclashx-special` | `reclash-restrictions` |
| `flclashx-newdomain` | `reclash-fallbackhosts` |
