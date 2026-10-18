# ReClash Subscription Provider Standard

Version: 1

## Limits

| Limit | Bytes |
| --- | ---: |
| One header field | 8192 |
| All response headers | 65536 |
| Wire payload | 16777216 |
| Decoded payload | 33554432 |

## Metadata fields

| Path | Header | Type | Trust | Consumer |
| --- | --- | --- | --- | --- |
| `provider.name` | `reclash-servicename` | text | display | panel |
| `provider.logo` | `reclash-servicelogo` | url | display | panel |
| `provider.supportUrl` | `reclash-supporturl` | url | display | panel |
| `provider.webUrl` | `reclash-webpageurl` | url | display | panel |
| `provider.buyPlanUrl` | `reclash-buyplan` | url | display | panel |
| `provider.buyTrafficUrl` | `reclash-buytraffic` | url | display | panel |
| `account.title` | `profile-title` | text | display | panel |
| `update.intervalMinutes` | `reclash-autoupdateinterval` | integer | hint | scheduler |
| `presentation.hideUrl` | `reclash-hideurl` | boolean | display | panel |

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
