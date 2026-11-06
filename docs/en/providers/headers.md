# Response headers

The standard HTTP headers a subscription response can carry, their value formats, and the one `reclash-config` header that points to the provider manifest.

Every header, alias and limit is in the [Standard registry](standard.md). Everything else a provider tells ReClash is in the [Provider manifest](manifest.md); device headers are in [Request headers](request.md#device-status).

## Parsing

- Header names are case-insensitive.
- A field is read from its canonical header. An alias is read only when the canonical header is absent and the manifest does not set the field, so an invalid canonical value never falls back to the alias.
- A field sent more than once is ignored: `Duplicate singleton`.
- An invalid value is dropped: `Invalid provider field`. The rest of the response applies.
- A header value over 8 KiB, or over 64 KiB of headers in total, fails the fetch.
- A field missing from the response is withdrawn, except usage fields, which go stale ([Metadata lifetime](README.md#metadata-lifetime)).
- An empty `text` value is valid and replaces the stored value. `url`, `integer` and `boolean` fields cannot be cleared.
- Metadata is read from headers only. A body carries no metadata. A `reclash-*` header other than `reclash-config` is ignored with an `Unsupported provider field` warning in the Subscription inspector.

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

`profile-update-interval` sets the update interval in hours. After conversion to minutes it must be 5–43200. It applies only while "Use provider update interval" is on in the profile editor, which is off by default. No manifest field sets it.

## Aliases

Four standard headers fill a [manifest `provider`](manifest.md#provider) field when the manifest does not set it. The manifest wins when it sets the field.

| Header | Manifest field | Type |
| --- | --- | --- |
| `support-url` | `provider.support-url` | url |
| `profile-web-page-url` | `provider.web-url` | url |
| `announce` | `provider.announce` | text, multiline, 1024 B |
| `hide-url` | `provider.hide-url` | boolean |

## Manifest pointer

```http
reclash-config: https://example.net/reclash.yaml
```

It is the only `reclash-*` header ReClash reads. It is a `url` and counts only in an `https` response. Delivery rules are in [Manifest delivery](manifest.md#delivery). Other clients ignore it.

## Device status

| Header | Page |
| --- | --- |
| `x-hwid-max-devices-reached`, `x-hwid-not-supported` | [Device status](request.md#device-status) |
