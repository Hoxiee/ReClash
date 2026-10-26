# ReClash 订阅服务商标准

版本：1

## 限制

| 限制项 | 字节数 |
| --- | ---: |
| 单个请求头字段 | 8192 |
| 所有响应头 | 65536 |
| 传输数据 | 16777216 |
| 解码后数据 | 33554432 |

## 元数据字段

| 路径 | 请求头 | 类型 | 信任级别 | 使用方 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `provider.name` | `reclash-servicename` | text | display | panel |  |
| `provider.logo` | `reclash-servicelogo` | url | display | panel |  |
| `provider.supportUrl` | `reclash-supporturl` | url | display | panel | 别名 `support-url` |
| `provider.webUrl` | `reclash-webpageurl` | url | display | panel | 别名 `profile-web-page-url` |
| `provider.buyPlanUrl` | `reclash-buyplan` | url | display | panel | 后缀 `provider.buyPlanDays`，范围 1–3650 |
| `provider.buyTrafficUrl` | `reclash-buytraffic` | url | display | panel | 后缀 `provider.buyTrafficPercent`，范围 1–100 |
| `provider.announce` | `reclash-announce` | text | display | panel | 别名 `announce` |
| `provider.announceUrl` | `reclash-announceurl` | url | display | panel |  |
| `provider.notice` | `reclash-notice` | text | display | panel |  |
| `provider.noticeUrl` | `reclash-noticeurl` | url | display | panel |  |
| `subscription.type` | `reclash-subscriptiontype` | text | display | panel |  |
| `account.title` | `profile-title` | text | display | panel |  |
| `update.intervalMinutes` | `reclash-autoupdateinterval` | integer | hint | scheduler | 别名 `profile-update-interval`，乘以 60 |
| `routing.bundleUrl` | `reclash-routing` | url | hint | routing |  |
| `presentation.hideUrl` | `reclash-hideurl` | boolean | display | panel | 别名 `hide-url` |
| `presentation.serverGroup` | `reclash-serverinfo` | text | display | panel |  |
| `presentation.widgets` | `reclash-widgets` | tokens | hint | appearance |  |
| `presentation.background` | `reclash-background` | url | hint | appearance | 后缀 `presentation.backgroundOpacity`，范围 1–100 |
| `presentation.view` | `reclash-view` | pairs | hint | appearance |  |
| `presentation.powerButton` | `reclash-powerbutton` | pairs | hint | appearance |  |
| `reminder.expireDays` | `reclash-expiredays` | numbers | hint | reminder |  |
| `reminder.trafficPercent` | `reclash-trafficpercent` | numbers | hint | reminder |  |
| `settings.flags` | `reclash-settings` | tokens | hint | settings |  |
| `settings.restrictions` | `reclash-restrictions` | tokens | hint | settings |  |
| `transport.fallbackHosts` | `reclash-fallbackhosts` | hosts | hint | transport |  |
| `transport.newDomain` | `reclash-newdomain` | hosts | hint | transport |  |
| `apps.exclude` | `reclash-excludeapps` | packages | hint | apps |  |
| `apps.include` | `reclash-includeapps` | packages | hint | apps |  |
| `apps.routing` | `reclash-approuting` | tokens | hint | apps |  |

## HTTP 请求头

| 请求头 | 方向 | 编码 | 敏感 |
| --- | --- | --- | --- |
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
