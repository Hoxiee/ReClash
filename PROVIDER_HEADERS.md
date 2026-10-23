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

| Path | Header | Type | Trust | Consumer | Notes |
| --- | --- | --- | --- | --- | --- |
| `provider.name` | `reclash-servicename` | text | display | panel |  |
| `provider.logo` | `reclash-servicelogo` | url | display | panel |  |
| `provider.supportUrl` | `reclash-supporturl` | url | display | panel | alias `support-url` |
| `provider.webUrl` | `reclash-webpageurl` | url | display | panel | alias `profile-web-page-url` |
| `provider.buyPlanUrl` | `reclash-buyplan` | url | display | panel | suffix `provider.buyPlanDays` 1-3650 |
| `provider.buyTrafficUrl` | `reclash-buytraffic` | url | display | panel | suffix `provider.buyTrafficPercent` 1-100 |
| `provider.announce` | `reclash-announce` | text | display | panel | alias `announce` |
| `provider.announceUrl` | `reclash-announceurl` | url | display | panel |  |
| `provider.notice` | `reclash-notice` | text | display | panel |  |
| `provider.noticeUrl` | `reclash-noticeurl` | url | display | panel |  |
| `account.title` | `profile-title` | text | display | panel |  |
| `update.intervalMinutes` | `reclash-autoupdateinterval` | integer | hint | scheduler | alias `profile-update-interval` x60 |
| `routing.bundleUrl` | `reclash-routing` | url | hint | routing |  |
| `presentation.hideUrl` | `reclash-hideurl` | boolean | display | panel | alias `hide-url` |
| `presentation.serverGroup` | `reclash-serverinfo` | text | display | panel |  |
| `presentation.widgets` | `reclash-widgets` | tokens | hint | appearance |  |
| `presentation.background` | `reclash-background` | url | hint | appearance | suffix `presentation.backgroundOpacity` 1-100 |
| `presentation.view` | `reclash-view` | pairs | hint | appearance |  |
| `reminder.expireDays` | `reclash-expiredays` | numbers | hint | reminder |  |
| `reminder.trafficPercent` | `reclash-trafficpercent` | numbers | hint | reminder |  |
| `settings.flags` | `reclash-settings` | tokens | hint | settings |  |
| `settings.restrictions` | `reclash-restrictions` | tokens | hint | settings |  |
| `transport.fallbackHosts` | `reclash-fallbackhosts` | hosts | hint | transport |  |
| `transport.newDomain` | `reclash-newdomain` | hosts | hint | transport |  |
| `apps.exclude` | `reclash-excludeapps` | packages | hint | apps |  |
| `apps.include` | `reclash-includeapps` | packages | hint | apps |  |
| `apps.routing` | `reclash-approuting` | tokens | hint | apps |  |

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
