# Реестр стандарта

Ограничения, поля манифеста и HTTP-заголовки стандарта провайдеров версии 1, сгенерированные из реестра, по которому декодирует приложение.

Машиночитаемая копия: [`provider_standard.g.json`](../../../provider_standard.g.json). Форматы значений и поведение: [«Заголовки ответа»](headers.md) и [«Заголовки запроса»](request.md).

## Ограничения

| Ограничение | Байты |
| --- | ---: |
| Одно поле заголовка | 8192 |
| Все заголовки ответа | 65536 |
| Передаваемые данные | 16777216 |
| Декодированные данные | 33554432 |

## Поля манифеста

| Путь | Тип | Лимит | Доверие | Получатель | Примечания |
| --- | --- | ---: | --- | --- | --- |
| `provider.name` | text | 160 | display | panel | заголовки-синонимы `flclashx-servicename` (FlClashX), `isp-name` (Karing) |
| `provider.logo` | url | 1024 | display | panel | заголовки-синонимы `flclashx-servicelogo` (FlClashX), `profile-logo` (Koala Clash) |
| `provider.logo-dark` | url | 1024 | display | panel |  |
| `provider.support-url` | url | 1024 | display | panel | резервный заголовок `support-url` |
| `provider.web-url` | url | 1024 | display | panel | резервный заголовок `profile-web-page-url`; заголовки-синонимы `homepage` (Incy), `isp-url` (Karing) |
| `provider.renew.url` | url | 1024 | display | panel | заголовки-синонимы `flclashx-buyplan` (FlClashX), `sub-expire-button-link` (Happ); `provider.renew.days` от 1 до 3650 |
| `provider.top-up.url` | url | 1024 | display | panel | заголовки-синонимы `flclashx-buytraffic` (FlClashX); `provider.top-up.percent` от 1 до 100 |
| `provider.announce.text` | text | 1024 | display | panel | резервный заголовок `announce` |
| `provider.announce.url` | url | 1024 | display | panel | заголовки-синонимы `announce-url` (Incy, v2RayTun) |
| `provider.notice.text` | text | 1024 | display | panel |  |
| `provider.notice.url` | url | 1024 | display | panel |  |
| `provider.type` | text | 32 | display | panel |  |
| `provider.hide-url` | boolean | 1024 | display | panel | резервный заголовок `hide-url` |
| `provider.server-group` | text | 256 | display | panel |  |
| `reminders.expire-days` | numbers | 8 | hint | reminder |  |
| `reminders.traffic-percent` | numbers | 8 | hint | reminder |  |
| `settings` | flags | 16 | hint | settings |  |
| `policy` | policy | 16 | hint | settings |  |
| `transport.fallback-hosts` | hosts | 5 | hint | transport | заголовки-синонимы `flclashx-newdomain` (FlClashX) |
| `transport.new-domain` | hosts | 1 | hint | transport | заголовки-синонимы `new-domain` (Happ) |
| `apps.exclude` | packages | 512 | hint | apps |  |
| `apps.include` | packages | 512 | hint | apps |  |
| `apps.routing` | tokens | 1 | hint | apps |  |
| `support.keys` | keys | 2 | consent | support |  |
| `support.upload-url` | url | 1024 | consent | support | только https |

## HTTP-заголовки

| Заголовок | Направление | Кодирование | Конфиденциальный |
| --- | --- | --- | --- |
| `reclash-aliases` | ответ | boolean | нет |
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
| `flclashx-servicename` | ответ | text-or-base64-prefixed | нет |
| `isp-name` | ответ | percent-encoded-text | нет |
| `flclashx-servicelogo` | ответ | url | нет |
| `profile-logo` | ответ | url | нет |
| `support-url` | ответ | url | нет |
| `profile-web-page-url` | ответ | url | нет |
| `homepage` | ответ | url | нет |
| `isp-url` | ответ | url | нет |
| `flclashx-buyplan` | ответ | url-with-optional-number | нет |
| `sub-expire-button-link` | ответ | url | нет |
| `flclashx-buytraffic` | ответ | url-with-optional-number | нет |
| `announce` | ответ | text-or-base64-prefixed | нет |
| `announce-url` | ответ | url | нет |
| `profile-title` | ответ | text-or-base64-prefixed | нет |
| `subscription-name` | ответ | text-or-base64-prefixed | нет |
| `profile-update-interval` | ответ | decimal | нет |
| `hide-url` | ответ | boolean | нет |
| `reclash-config` | ответ | url | нет |
| `flclashx-newdomain` | ответ | host-list | нет |
| `new-domain` | ответ | host-list | нет |
