# Standard registry

Limits, manifest fields and HTTP headers of provider standard version 1, generated from the registry the app decodes with.

Machine-readable copy: [`provider_standard.g.json`](../../../provider_standard.g.json). Value formats and behavior: [Response headers](headers.md) and [Request headers](request.md).

## Limits

| Limit | Bytes |
| --- | ---: |
| One header field | 8192 |
| All response headers | 65536 |
| Wire payload | 16777216 |
| Decoded payload | 33554432 |

## Manifest fields

| Path | Type | Limit | Trust | Consumer | Notes |
| --- | --- | ---: | --- | --- | --- |
| `provider.name` | text | 160 | display | panel |  |
| `provider.logo` | url | 1024 | display | panel |  |
| `provider.logo-dark` | url | 1024 | display | panel |  |
| `provider.support-url` | url | 1024 | display | panel | fallback header `support-url` |
| `provider.web-url` | url | 1024 | display | panel | fallback header `profile-web-page-url` |
| `provider.renew.url` | url | 1024 | display | panel | `provider.renew.days` 1-3650 |
| `provider.top-up.url` | url | 1024 | display | panel | `provider.top-up.percent` 1-100 |
| `provider.announce.text` | text | 1024 | display | panel | fallback header `announce` |
| `provider.announce.url` | url | 1024 | display | panel |  |
| `provider.notice.text` | text | 1024 | display | panel |  |
| `provider.notice.url` | url | 1024 | display | panel |  |
| `provider.type` | text | 32 | display | panel |  |
| `provider.hide-url` | boolean | 1024 | display | panel | fallback header `hide-url` |
| `provider.server-group` | text | 256 | display | panel |  |
| `reminders.expire-days` | numbers | 8 | hint | reminder |  |
| `reminders.traffic-percent` | numbers | 8 | hint | reminder |  |
| `settings` | flags | 16 | hint | settings |  |
| `policy` | policy | 16 | hint | settings |  |
| `transport.fallback-hosts` | hosts | 5 | hint | transport |  |
| `transport.new-domain` | hosts | 1 | hint | transport |  |
| `apps.exclude` | packages | 512 | hint | apps |  |
| `apps.include` | packages | 512 | hint | apps |  |
| `apps.routing` | tokens | 1 | hint | apps |  |
| `support.keys` | keys | 2 | consent | support |  |
| `support.upload-url` | url | 1024 | consent | support | https only |

## HTTP headers

| Header | Direction | Encoding | Sensitive |
| --- | --- | --- | --- |
| `x-hwid` | request | lowercase-hex-32 | yes |
| `x-device-os` | request | ascii | yes |
| `x-ver-os` | request | ascii | yes |
| `x-device-model` | request | ascii | yes |
| `x-hwid-not-supported` | response | boolean | no |
| `x-hwid-max-devices-reached` | response | boolean | no |
| `Subscription-Userinfo` | response | semicolon-counts | no |
| `Content-Disposition` | response | rfc6266 | no |
| `User-Agent` | request | ascii | no |
| `Accept-Language` | request | ascii | no |
| `x-client` | request | ascii | no |
| `x-app-version` | request | ascii | no |
| `x-device-locale` | request | ascii | yes |
| `support-url` | response | url | no |
| `profile-web-page-url` | response | url | no |
| `announce` | response | text-or-base64-prefixed | no |
| `profile-title` | response | text-or-base64-prefixed | no |
| `profile-update-interval` | response | decimal | no |
| `hide-url` | response | boolean | no |
| `reclash-config` | response | url | no |
