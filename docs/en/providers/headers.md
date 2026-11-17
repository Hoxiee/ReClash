# Response headers

The standard HTTP headers a subscription response can carry, their value formats, and the one `reclash-config` header that points to the provider manifest.

Every header, alias and limit is in the [Standard registry](standard.md). Everything else a provider tells ReClash is in the [Provider manifest](manifest.md); device headers are in [Request headers](request.md#device-status).

## Parsing

- Header names are case-insensitive.
- A field is read from its standard header, then from its [aliases from other clients](#headers-from-other-clients). The first valid value wins; the manifest overrides both.
- A field sent more than once is ignored: `Duplicate singleton`.
- An invalid value is dropped: `Invalid provider field`. The rest of the response applies.
- A header value over 8 KiB, or over 64 KiB of headers in total, fails the fetch.
- A field missing from the response is withdrawn, except usage fields, which go stale ([Metadata lifetime](README.md#metadata-lifetime)).
- An empty `text` value is valid and replaces the stored value. `url`, `integer` and `boolean` fields cannot be cleared.
- Metadata is read from headers only. A body carries no metadata. A `reclash-*` header other than `reclash-config` and `reclash-aliases` is ignored with an `Unsupported provider field` warning in the Subscription inspector.

## Value formats

| Type | Syntax | Rules |
| --- | --- | --- |
| `text` | UTF-8, or `base64:` / `base64,` followed by Base64 of UTF-8 | Max 1024 bytes after decoding, unless the field says otherwise. No control characters; LF allowed in `announce`. |
| `url` | Absolute `http` or `https` URL | Host required. No userinfo, whitespace or control characters. Max 1024 characters. |
| `integer` | Decimal | Multiplied by the alias scale, then range-checked. |
| `boolean` | `1`, `true`, `yes` / `0`, `false`, `no` | Case-insensitive. |

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
3. `provider.name` from the [manifest](manifest.md#provider);
4. the subscription host.

A name the user set is never replaced. `profile-title` names the account, not the service.

## Update interval

`profile-update-interval` sets the update interval in hours. After conversion to minutes it must be 5–43200. It applies only while "Use provider update interval" is on in the profile editor, which is on by default. A saved user choice is preserved. No manifest field sets it.

## Aliases

Four standard headers fill a [manifest `provider`](manifest.md#provider) field when the manifest does not set it. The manifest wins when it sets the field.

| Header | Manifest field | Type |
| --- | --- | --- |
| `support-url` | `provider.support-url` | url |
| `profile-web-page-url` | `provider.web-url` | url |
| `announce` | `provider.announce` | text, multiline, 1024 B |
| `hide-url` | `provider.hide-url` | boolean |

## Headers from other clients

Headers that other VPN clients already send are read as aliases of existing fields, so a provider need not add ReClash-specific headers.

- A field is read from its standard header first, then from its aliases in the order listed below. The first valid value wins; an invalid one is dropped with a warning and the next is tried.
- A hosted manifest ([`reclash-config`](manifest.md)) overrides both.
- A response with a manifest pointer is the manifest's alone: aliases are off unless it also sends `reclash-aliases: 1`. A pointer the client cannot use (a non-`https` response) does not count.
- Without a manifest pointer aliases are on; `reclash-aliases: 0` turns them off. A value other than `1`, `true`, `yes`, `0`, `false` or `no` turns them off in either case, with an `Invalid provider field` warning.
- Host aliases (`transport.*`) are read only from an `https` response.
- Aliases carry display and transport hints only. Settings, apps, routing and policy are never read from them; headers such as `flclashx-view`, `flclashx-widgets`, `flclashx-settings`, `flclashx-special`, Happ routing and per-app headers are ignored.
- `profile-update-interval` needs no conversion: it is in hours in every client checked, as in ReClash.
- A provider that moves to the manifest can keep sending these headers for other clients.

| Alias header | Client | ReClash field | Notes |
| --- | --- | --- | --- |
| `flclashx-servicename` | FlClashX | `provider.name` | Text; `base64:` prefix allowed. |
| `isp-name` | Karing | `provider.name` | Percent-encoded text. |
| `flclashx-servicelogo` | FlClashX | `provider.logo` | Same as the standard header. |
| `profile-logo` | Koala Clash | `provider.logo` | Same as the standard header. |
| `homepage` | Incy | `provider.web-url` | Same as the standard header. |
| `isp-url` | Karing | `provider.web-url` | Same as the standard header. |
| `flclashx-buyplan` | FlClashX | `provider.renew.url` | `<url>[,<n>]`; `n` goes to `provider.renew.days`. |
| `sub-expire-button-link` | Happ | `provider.renew.url` | Same as the standard header. |
| `flclashx-buytraffic` | FlClashX | `provider.top-up.url` | `<url>[,<n>]`; `n` goes to `provider.top-up.percent`. |
| `announce-url` | Incy, v2RayTun | `provider.announce.url` | Same as the standard header. |
| `subscription-name` | Incy | profile name (no manifest path) | Fills the profile name like `profile-title`; text, `base64:` prefix allowed. |
| `flclashx-newdomain` | FlClashX | `transport.fallback-hosts` | Host list, at most 5. |
| `new-domain` | Happ | `transport.new-domain` | Host list, at most 1. |

Formats: `plain` values follow the [value formats](#value-formats) of the standard header; `urlWithNumber` drops an invalid `n` with a warning and keeps the URL; `hostList` accepts a comma-separated list of `host`, `host:port` or `scheme://host[:port]/...`, reduced to `host[:port]`, deduplicated and limited.

## Manifest pointer

```http
reclash-config: https://example.net/reclash.yaml
```

It is the only `reclash-*` header ReClash reads. It is a `url` and counts only in an `https` response. Delivery rules are in [Manifest delivery](manifest.md#delivery). Other clients ignore it.

## Device status

| Header | Page |
| --- | --- |
| `x-hwid-max-devices-reached`, `x-hwid-not-supported` | [Device status](request.md#device-status) |
