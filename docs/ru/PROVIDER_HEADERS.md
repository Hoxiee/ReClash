# Стандарт провайдеров подписок ReClash

Версия: 1

## Ограничения

| Ограничение | Байты |
| --- | ---: |
| Одно поле заголовка | 8192 |
| Все заголовки ответа | 65536 |
| Передаваемые данные | 16777216 |
| Декодированные данные | 33554432 |

## Поля метаданных

| Путь | Заголовок | Тип | Доверие | Получатель | Примечания |
| --- | --- | --- | --- | --- | --- |
| `provider.name` | `reclash-servicename` | text | display | panel |  |
| `provider.logo` | `reclash-servicelogo` | url | display | panel |  |
| `provider.supportUrl` | `reclash-supporturl` | url | display | panel | псевдоним `support-url` |
| `provider.webUrl` | `reclash-webpageurl` | url | display | panel | псевдоним `profile-web-page-url` |
| `provider.buyPlanUrl` | `reclash-buyplan` | url | display | panel | суффикс `provider.buyPlanDays` от 1 до 3650 |
| `provider.buyTrafficUrl` | `reclash-buytraffic` | url | display | panel | суффикс `provider.buyTrafficPercent` от 1 до 100 |
| `provider.announce` | `reclash-announce` | text | display | panel | псевдоним `announce` |
| `provider.announceUrl` | `reclash-announceurl` | url | display | panel |  |
| `provider.notice` | `reclash-notice` | text | display | panel |  |
| `provider.noticeUrl` | `reclash-noticeurl` | url | display | panel |  |
| `subscription.type` | `reclash-subscriptiontype` | text | display | panel |  |
| `account.title` | `profile-title` | text | display | panel |  |
| `update.intervalMinutes` | `reclash-autoupdateinterval` | integer | hint | scheduler | псевдоним `profile-update-interval`, умножается на 60 |
| `routing.bundleUrl` | `reclash-routing` | url | hint | routing |  |
| `presentation.hideUrl` | `reclash-hideurl` | boolean | display | panel | псевдоним `hide-url` |
| `presentation.serverGroup` | `reclash-serverinfo` | text | display | panel |  |
| `presentation.widgets` | `reclash-widgets` | tokens | hint | appearance |  |
| `presentation.background` | `reclash-background` | url | hint | appearance | суффикс `presentation.backgroundOpacity` от 1 до 100 |
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

## HTTP-заголовки

| Заголовок | Направление | Кодирование | Конфиденциальный |
| --- | --- | --- | --- |
| `x-hwid` | запрос | lowercase-hex-32 | да |
| `x-device-os` | запрос | ascii | да |
| `x-ver-os` | запрос | ascii | да |
| `x-device-model` | запрос | ascii | да |
| `x-hwid-not-supported` | ответ | boolean | нет |
| `x-hwid-max-devices-reached` | ответ | boolean | нет |
| `Subscription-Userinfo` | ответ | semicolon-counts | нет |
| `Content-Disposition` | ответ | rfc6266 | нет |
| `User-Agent` | запрос | ascii | нет |
| `Accept-Language` | запрос | ascii | нет |
| `x-client` | запрос | ascii | нет |
| `x-app-version` | запрос | ascii | нет |
| `x-device-locale` | запрос | ascii | да |
