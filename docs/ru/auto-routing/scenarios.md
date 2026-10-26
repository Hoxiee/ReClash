# Сценарии

**Сценарий** — автоматическая маршрутизация всего подключения. В отличие от [профиля](profiles.md), который управляет одной группой, сценарий может задавать режим туннеля, назначать программы сразу нескольким группам, менять поведение в зависимости от сети и направлять выбранный трафик в отдельные группы с помощью **маршрутов**.

Примеры с пометкой `# fragment` являются фрагментами. Остальные — полные сценарии, проходящие проверку [`rcxlint`](sharing.md#инструмент-rcxlint). Учтите: `rcxlint` распознаёт документ как сценарий по верхнеуровневому ключу `groups` или `mode`; поэтому в сценарии только с маршрутами для проверки нужен `groups` (допустимо даже `groups: { $main: {} }`).

Содержание: [структура](#структура-сценария) · [ключи](#ключи) · [группы и программы](#группы-и-программы) · [приоритет порядка серверов](#приоритет-порядка-серверов) · [режим](#режим) · [типы сетей](#типы-сетей-и-on) · [маршруты](#маршруты) · [типы совпадений](#типы-совпадений) · [ограничения](#ограничения) · [зарезервированные имена](#зарезервированные-имена) · [ошибки](#ошибки-проверки) · [метки и l10n](#метки-и-l10n)

## Структура сценария

```yaml
rcx: 1
title: Evening streaming
description: Fastest servers for the main group and a Dutch pool for video.
mode: rule
groups:
  $main:
    profile: builtin/fastest
routes:
  - name: Video
    match: [GEOSITE,youtube]
    prefer:
      - label: Netherlands
        when: country = NL
      - label: Anything
        when: not dead
```

Сценарий выбирает пользователь или провайдер задаёт как вариант по умолчанию. Группы, не указанные в нём, сохраняют собственный профиль (гарантия `scenario`).

## Ключи

| Ключ | Тип | По умолчанию | Значение |
| --- | --- | --- | --- |
| `rcx` | целое число | 1 | Версия формата. |
| `title`, `description` | строка | отсутствует | Показываются в списке; переводятся через `l10n`. |
| `tags` | карта «имя → условие» | отсутствует | Именованные условия для пулов программ (не более 32). Метки сценария не могут использовать `tag()`. |
| `network` | `{diagnose, kinds}` | отсутствует | Проверки и типы сетей для собственного поведения сценария. Формат такой же, как в профиле. |
| `mode` | `rule`, `global`, `direct` | пусто | Желаемый сценарий для режима туннеля. Пустое значение не меняет режим пользователя. |
| `groups` | карта «цель → программа» | отсутствует | Программы для групп (не более 32 записей). |
| `routes` | список маршрутов | отсутствует | Совпадения трафика с отдельными группами (не более 32). |
| `on` | карта «тип → `{mode, groups}`» | отсутствует | Переопределения для активного типа сети. Не более 8 типов. |
| `l10n` | карта «язык → строки» | отсутствует | Переводы заголовка, описания и меток. |

Размер файла сценария — не более 64 КиБ.

## Группы и программы

`groups` связывает **цель** с **программой**.

```yaml
rcx: 1
title: Targets
groups:
  $main: { profile: builtin/fastest }
  '*': { profile: builtin/stable }
  GLOBAL: { to: DIRECT }
  Netflix: { pool: { include: 'country in [NL, DE]' } }
```

### Цели

| Цель | Значение |
| --- | --- |
| имя группы | Точная группа, например `Netflix`. Имеет приоритет над `$main` и `*`. |
| `$main` | Группа `select`, на которую направлено итоговое правило `MATCH` конфигурации. |
| `*` | Все остальные группы `select`, но не `GLOBAL`. |
| `GLOBAL` | Встроенная группа mihomo `GLOBAL`, используемая в режиме global. |

Приоритет: точное имя, затем `$main`, затем `*`. Имя группы маршрута само по себе является допустимой целью (если группа с таким именем ещё не существует в конфигурации); программа маршрута выполняет ту же роль.

### Ключи программы

| Ключ | Значение |
| --- | --- |
| `profile` | ID профиля (`builtin/fastest`, `provider/x`, `user/x`). Заменяет собственный профиль группы. |
| `pool` | `{include, exclude}`. Только сужает пул группы. |
| `prefer` | Порядок серверов (список шагов `{label, when}`), заменяющий порядок профиля. |
| `to` | Закрепляет группу за одним элементом: сервером или вложенной группой, например балансировщиком. Поиск не выполняется. |

`to` несовместим с `profile`, `pool` и `prefer` («to закрепляет один элемент, поэтому profile, pool и prefer неприменимы»). `{}` управляет группой с её собственным профилем. Программа с `pool` или `prefer`, но без `profile`, проверяется при запуске группы, поскольку профиль становится известен только тогда.

```yaml
rcx: 1
title: Hold and narrow
groups:
  $main:
    pool:
      exclude: name ~ /(?i)test/
    prefer:
      - label: Norway
        when: country = NO
      - label: Anything
        when: not dead
  Backup: { to: DIRECT }
```

## Приоритет порядка серверов

Для порядка серверов группы приоритет у источников следующий (сверху — выше):

1. `prefer` программы сценария (включая программу `on.<kind>`);
2. `prefer` привязки пользователя;
3. собственный `prefer` профиля.

```mermaid
flowchart LR
    S[Scenario program prefer] -->|beats| U[User binding prefer]
    U -->|beats| P[Profile prefer]
```

Пользователь может выбирать порядок для групп, не указанных в сценарии; сценарий или сценарий от провайдера также может задавать группе отдельный порядок на время своего действия.

## Режим

`mode` задаёт режим туннеля. Сценарий **удерживает** режим, только пока пользователь не выбрал режим вручную.

- Эффективный режим — желаемый режим сценария, если он задан; иначе режим пользователя; иначе `rule`.
- После ручной смены режима сценарий перестаёт его удерживать. Выбор **Auto** снова передаёт управление сценарию.
- Группа, через которую ничего не направляется в текущем режиме, простаивает (причина `hold.idle`): `GLOBAL` вне режима global и все группы в режиме direct.

Маршруты управляют трафиком только в режиме rule. Если задан другой режим, а сценарий содержит маршруты, в статусе отображается `route.not-rule-mode`.

## Типы сетей и `on`

Сценарий может определять сеть через `network.kinds` (и `network.diagnose`) так же, как профиль, а затем задавать переопределения для каждого типа через `on.<kind>`. Каждый `on.<kind>` может содержать `mode` и `groups`. Запись группы внутри `on.<kind>` **целиком заменяет** базовую запись с тем же ключом; остальные базовые записи продолжают действовать. Использование `on.x` без объявления типа `x` — ошибка.

```yaml
rcx: 1
title: Calm on mobile
description: Fastest on Wi-Fi, stable on mobile data.
network:
  kinds:
    - { kind: cell, when: 'network.transport = cellular' }
groups:
  $main: { profile: builtin/fastest }
on:
  cell:
    groups:
      $main: { profile: builtin/stable }
```

Сценарий запоминает свой тип для каждой сети (`scenario:<id>`). При смене типа привязки перестраиваются. Как и для профилей, новый тип должен быть подтверждён двумя последовательными циклами.

## Маршруты

`routes` — упорядоченный список. У маршрута есть `name`, необязательное `description` (не более 240 байт), список `match` и встроенная программа: `profile` (по умолчанию `builtin/simple`), `pool`, `prefer` либо `to`.

```yaml
rcx: 1
title: Work and play
groups:
  $main: {}
routes:
  - name: Chat
    description: Messengers through a nearby server.
    match: [GEOSITE,telegram]
    prefer:
      - label: Finland
        when: country = FI
      - label: Anything
        when: not dead
  - name: Government
    match: [GEOSITE,category-gov-ru]
    to: DIRECT
```

- Маршрут **без `to`** создаёт группу `select` с именем маршрута и `include-all: true`. Это умная группа, которой управляет собственная программа маршрута.
- Маршрут **с `to`** не создаёт группу. Правила направляются к цели: `DIRECT`, `REJECT`, существующей группе или серверу.
- Правила добавляются **перед** правилами конфигурации в порядке маршрутов. Побеждает первый совпавший маршрут.
- Маршруты применяются при **применении конфигурации** и только в режиме **rule**. Схема процесса, флаг `reload` и однократное повторное применение описаны в [разделе о движке](engine.md#маршруты).
- Поскольку программа маршрута не входит в ключ применения, изменения `profile`, `pool` или `prefer` применяются сразу. Изменения `name`, `match` или `to` вызывают однократное повторное применение.

### Запись `match`

Элементы — заголовки правил mihomo **без** цели. Обычная форма — строка вида `"TYPE,value"` для каждого элемента списка. Поддерживается и YAML-список в flow-формате: `[GEOSITE,youtube]` читается как два элемента (`GEOSITE` и `youtube`); движок объединяет тип со следующим значением и присоединяет следующий `no-resolve`.

```yaml
rcx: 1
title: Match forms
groups:
  $main: {}
routes:
  - name: Block style
    match:
      - GEOSITE,youtube
      - DOMAIN-SUFFIX,anthropic.com
    to: DIRECT
  - name: Flow style
    match: [GEOSITE,telegram, GEOIP,RU,no-resolve]
    to: DIRECT
```

Элементы с символами синтаксиса YAML заключайте в кавычки.

### Типы совпадений

| Тип | Значение | Пример | `no-resolve` |
| --- | --- | --- | --- |
| `DOMAIN` | Точный узел | `DOMAIN,www.example.com` | нет |
| `DOMAIN-SUFFIX` | Домен и поддомены | `DOMAIN-SUFFIX,example.com` | нет |
| `DOMAIN-KEYWORD` | Подстрока узла | `DOMAIN-KEYWORD,video` | нет |
| `DOMAIN-WILDCARD` | Узел с `*` и `?` | `DOMAIN-WILDCARD,*.cdn.example.com` | нет |
| `DOMAIN-REGEX` | Регулярное выражение (вся оставшаяся часть записи, запятые разрешены) | `DOMAIN-REGEX,^api[0-9]+\.example\.com$` | нет |
| `GEOSITE` | Категория из `GEOSITE.dat` | `GEOSITE,youtube` | нет |
| `GEOIP` | Код страны ISO | `GEOIP,RU` | да |
| `IP-CIDR` | Диапазон IPv4 | `IP-CIDR,10.0.0.0/8` | да |
| `IP-CIDR6` | Диапазон IPv6 | `IP-CIDR6,fd00::/8` | да |
| `IP-ASN` | Номер автономной системы | `IP-ASN,13335` | да |
| `SRC-IP-CIDR` | Диапазон адресов клиента | `SRC-IP-CIDR,192.168.1.50/32` | нет |
| `DST-PORT` | Порт или диапазон; несколько значений разделяются `/` | `DST-PORT,443` или `DST-PORT,8000-8100` | нет |
| `PROCESS-NAME` | Имя исполняемого файла | `PROCESS-NAME,firefox` | нет |
| `PROCESS-PATH` | Полный путь к исполняемому файлу | `PROCESS-PATH,/usr/bin/curl` | нет |
| `RULE-SET` | Имя уже существующего в конфигурации провайдера правил | `RULE-SET,my-ads` | да |

`no-resolve` запрещает mihomo выполнять DNS-запрос для правила; используйте его для правил по адресу, когда назначение обычно задаётся именем. Для других типов параметр запрещён («не принимает параметров»).

Для `RULE-SET` провайдер правил должен существовать в конфигурации. Если его нет, маршрут пропускается с проблемой `route.invalid`: «rule set X is not in the config». Для `GEOSITE` категория должна присутствовать в поставляемой приложением базе geosite (`assets/data/GEOSITE.dat`). Редактор этого не проверяет, поэтому после добавления проверьте маршрут.

```yaml
rcx: 1
title: Every match type
groups:
  $main: {}
routes:
  - name: Domains
    match:
      - DOMAIN,www.example.com
      - DOMAIN-SUFFIX,example.org
      - DOMAIN-KEYWORD,videocdn
      - DOMAIN-WILDCARD,*.static.example.net
      - DOMAIN-REGEX,^api[0-9]+\.example\.com$
    to: DIRECT
  - name: Lists
    match:
      - GEOSITE,youtube
      - GEOIP,RU,no-resolve
    to: DIRECT
  - name: Addresses
    match:
      - IP-CIDR,10.0.0.0/8,no-resolve
      - IP-CIDR6,fd00::/8,no-resolve
      - IP-ASN,13335,no-resolve
      - SRC-IP-CIDR,192.168.1.50/32
    to: DIRECT
  - name: Ports and apps
    match:
      - DST-PORT,8000-8100
      - DST-PORT,22/2222
      - PROCESS-NAME,firefox
      - PROCESS-PATH,/usr/bin/curl
    to: DIRECT
```

## Ограничения

| Ограничение | Значение |
| --- | --- |
| Размер сценария | 64 КиБ |
| Программы в `groups` | 32 |
| Имя цели | 64 символа |
| Маршруты | 32 |
| Записи `match` на маршрут | 128 |
| Имя маршрута | 64 байта |
| Описание маршрута | 240 байт |
| Шаги в `prefer` программы | 16 |
| Метки | 32 |
| Типы сети / записи `on` | 8 |

## Зарезервированные имена

Имя маршрута не может быть `$main`, `*`, `GLOBAL`, `DIRECT`, `REJECT`, `REJECT-DROP`, `PASS` или `COMPATIBLE`. Оно также должно быть непустым и уникальным среди маршрутов, не содержать запятых и управляющих символов и не использоваться в `groups` (программа маршрута указывается в самом маршруте).

При применении конфигурации маршрут с именем существующего proxy или группы пропускается (`route.name-taken`). Маршрут, цель `to` которого не существует, пропускается (`route.to-missing`).

## Ошибки проверки

Ошибки содержат путь к проблемному элементу. Типичные сообщения:

| Путь | Сообщение |
| --- | --- |
| `routes.2.match.0` | `GEOSITE needs a value`, `"X" is not a match type a route can use`, `IP-CIDR "x" is not an address range like 10.0.0.0/8` |
| `routes.1.name` | `two routes are named X`, `route name "X" is reserved`, `route X takes its program on the route, not under groups` |
| `groups.$main` | `to holds one member, so profile, pool and prefer do not apply` |
| `on.cell` | `the scenario declares no network kind cell` |
| `mode` | `mode "x" is not rule, global or direct` |

Проблемы, обнаруженные только при применении конфигурации, отображаются в статусе сценария: `route.name-taken`, `route.to-missing`, `route.invalid` и `route.not-rule-mode`.

## Метки и l10n

`tags` определяют именованные условия для `pool` и `prefer` в программах:

```yaml
rcx: 1
title: Starred only
tags:
  star: 'name ~ /\*/'
groups:
  $main:
    pool:
      include: tag(star)
```

`l10n` переводит `title`, `description` и метки шагов так же, как для профиля:

```yaml
rcx: 1
title: Work
groups:
  $main: {}
l10n:
  ru:
    Work: Работа
```
