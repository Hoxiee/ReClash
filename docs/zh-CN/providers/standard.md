# 标准注册表

提供商标准第 1 版的限制、清单字段和 HTTP 响应头，由应用解码时所用的注册表生成。

机器可读副本：[`provider_standard.g.json`](../../../provider_standard.g.json)。值格式和行为见[响应头](headers.md)和[请求头](request.md)。

## 限制

| 限制 | 字节 |
| --- | ---: |
| 单个响应头字段 | 8192 |
| 所有响应头 | 65536 |
| 传输负载 | 16777216 |
| 解码后负载 | 33554432 |

## 清单字段

| 路径 | 类型 | 限制 | 信任 | 使用方 | 说明 |
| --- | --- | ---: | --- | --- | --- |
| `provider.name` | text | 160 | display | panel | 别名响应头 `flclashx-servicename` (FlClashX), `isp-name` (Karing) |
| `provider.logo` | url | 1024 | display | panel | 别名响应头 `flclashx-servicelogo` (FlClashX), `profile-logo` (Koala Clash) |
| `provider.logo-dark` | url | 1024 | display | panel |  |
| `provider.support-url` | url | 1024 | display | panel | 后备响应头 `support-url` |
| `provider.web-url` | url | 1024 | display | panel | 后备响应头 `profile-web-page-url`; 别名响应头 `homepage` (Incy), `isp-url` (Karing) |
| `provider.renew.url` | url | 1024 | display | panel | 别名响应头 `flclashx-buyplan` (FlClashX), `sub-expire-button-link` (Happ); `provider.renew.days` 1-3650 |
| `provider.top-up.url` | url | 1024 | display | panel | 别名响应头 `flclashx-buytraffic` (FlClashX); `provider.top-up.percent` 1-100 |
| `provider.announce.text` | text | 1024 | display | panel | 后备响应头 `announce` |
| `provider.announce.url` | url | 1024 | display | panel | 别名响应头 `announce-url` (Incy, v2RayTun) |
| `provider.notice.text` | text | 1024 | display | panel |  |
| `provider.notice.url` | url | 1024 | display | panel |  |
| `provider.type` | text | 32 | display | panel |  |
| `provider.hide-url` | boolean | 1024 | display | panel | 后备响应头 `hide-url` |
| `provider.server-group` | text | 256 | display | panel |  |
| `reminders.expire-days` | numbers | 8 | hint | reminder |  |
| `reminders.traffic-percent` | numbers | 8 | hint | reminder |  |
| `settings` | flags | 16 | hint | settings |  |
| `policy` | policy | 16 | hint | settings |  |
| `transport.fallback-hosts` | hosts | 5 | hint | transport | 别名响应头 `flclashx-newdomain` (FlClashX) |
| `transport.new-domain` | hosts | 1 | hint | transport | 别名响应头 `new-domain` (Happ) |
| `apps.exclude` | packages | 512 | hint | apps |  |
| `apps.include` | packages | 512 | hint | apps |  |
| `apps.routing` | tokens | 1 | hint | apps |  |
| `support.keys` | keys | 2 | consent | support |  |
| `support.upload-url` | url | 1024 | consent | support | 仅限 https |

## HTTP 响应头

| 响应头 | 方向 | 编码 | 敏感 |
| --- | --- | --- | --- |
| `reclash-aliases` | 响应 | boolean | 否 |
| `x-hwid` | 请求 | lowercase-hex-32 | 是 |
| `x-device-os` | 请求 | ascii | 是 |
| `x-ver-os` | 请求 | ascii | 是 |
| `x-device-model` | 请求 | ascii | 是 |
| `x-hwid-not-supported` | 响应 | boolean | 否 |
| `x-hwid-max-devices-reached` | 响应 | boolean | 否 |
| `Subscription-Userinfo` | 响应 | semicolon-counts | 否 |
| `Content-Disposition` | 响应 | rfc6266 | 否 |
| `User-Agent` | 请求 | ascii | 否 |
| `Accept-Language` | 请求 | ascii | 否 |
| `x-client` | 请求 | ascii | 否 |
| `x-app-version` | 请求 | ascii | 否 |
| `x-device-locale` | 请求 | ascii | 是 |
| `flclashx-servicename` | 响应 | text-or-base64-prefixed | 否 |
| `isp-name` | 响应 | percent-encoded-text | 否 |
| `flclashx-servicelogo` | 响应 | url | 否 |
| `profile-logo` | 响应 | url | 否 |
| `support-url` | 响应 | url | 否 |
| `profile-web-page-url` | 响应 | url | 否 |
| `homepage` | 响应 | url | 否 |
| `isp-url` | 响应 | url | 否 |
| `flclashx-buyplan` | 响应 | url-with-optional-number | 否 |
| `sub-expire-button-link` | 响应 | url | 否 |
| `flclashx-buytraffic` | 响应 | url-with-optional-number | 否 |
| `announce` | 响应 | text-or-base64-prefixed | 否 |
| `announce-url` | 响应 | url | 否 |
| `profile-title` | 响应 | text-or-base64-prefixed | 否 |
| `subscription-name` | 响应 | text-or-base64-prefixed | 否 |
| `profile-update-interval` | 响应 | decimal | 否 |
| `hide-url` | 响应 | boolean | 否 |
| `reclash-config` | 响应 | url | 否 |
| `reclash-update` | 响应 | url | 否 |
| `flclashx-newdomain` | 响应 | host-list | 否 |
| `new-domain` | 响应 | host-list | 否 |
