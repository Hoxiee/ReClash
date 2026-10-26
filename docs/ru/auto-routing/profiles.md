# Профили

**Профиль** — политика одной умной группы: какие серверы разрешены, в каком порядке их предпочитать, как ранжировать и насколько охотно движок переключается. Это один YAML-документ размером не более 64 КиБ.

Примеры с `# fragment` намеренно неполные; все остальные — полные профили, проходящие [`rcxlint`](sharing.md#инструмент-rcxlint).

Содержание: [минимальный профиль](#минимальный-профиль) · [справочник ключей](#справочник-ключей) · [подробное описание](#подробное-описание-ключей) · [значения по умолчанию](#значения-по-умолчанию) · [ограничения](#ограничения) · [наследование](#extends) · [встроенные профили](#встроенные-профили)

## Минимальный профиль

```yaml
rcx: 1
title: Anything that works
```

Если `prefer` не задан, используется один шаг «Working» (`not dead`), и группа сохраняет любой работающий сервер. Остальные ключи уточняют это поведение.

## Справочник ключей

Неизвестные ключи считаются ошибками, поэтому опечатка обнаруживается при импорте, а не игнорируется.

| Ключ | Тип | По умолчанию | Назначение |
| --- | --- | --- | --- |
| `rcx` | целое число | обязательно для внешних документов | Версия формата. Сейчас `1`; более высокая версия отклоняется как новая для приложения. |
| `title` | строка | нет | Имя в списках. |
| `description` | строка | нет | Одно-два предложения: назначение и когда выбирать профиль. |
| `level` | `simple` | `advanced` | `simple` | Метка сложности и класс бюджета запросов (30 или 80 в час). |
| `extends` | ID профиля | нет | Наследование профиля; цепочка не глубже 4 уровней. |
| `pool` | `{include, exclude}` | все серверы | Серверы, доступные группе. |
| `tags` | карта «имя → условие» | нет | Именованные условия для `tag(name)` в `pool` и `prefer`. Не более 32. |
| `prefer` | список шагов | один шаг `not dead` | Порядок серверов (лестница), не более 16 шагов. |
| `rank` | `{by, tolerance}` | `latency`, 0 | Порядок серверов внутри шага. |
| `switch` | объект | пресет `balanced` | Когда переключаться с работающего сервера. |
| `stranded` | строка | `hold` | Действие, если ни один сервер не подходит. |
| `energy` | `eco` | `balanced` | `precise` | `balanced` | Допустимое число проверок. |
| `checks` | карта «ID → проверка» | нет | Именованные тесты для `passes(id)` / `fails(id)`, не более 8. |
| `network` | `{diagnose, kinds}` | нет | Проверки и типы сети. |
| `on` | карта «тип → переопределение» | нет | Переопределения для типов сети, не более 8. |
| `direct-split` | условие | выключено | Когда отправлять внутренний трафик напрямую. Только пользовательский уровень. |
| `egress-verify` | `{echo, agree}` | Cloudflare и ipinfo, 2 | Способ проверки страны выхода. |
| `l10n` | карта «язык → строки» | нет | Переводы заголовка, описания и меток. |

## Подробное описание ключей

### `rcx`

Версия формата.

```yaml
rcx: 1
title: Versioned
```

Значение выше `1` вызывает ошибку «profile format N is newer than this app understands».

### `title` и `description`

Обычный текст в списке поведений. Заголовки и описания переводятся с помощью `l10n`.

```yaml
rcx: 1
title: Quiet Europe
description: Keeps one European server and rarely changes it. Good for a laptop on battery.
pool:
  include: country in [DE, NL, FI]
```

### `level`

`simple` (значение по умолчанию) или `advanced`. Простые профили не превышают 30 запросов в час, расширенные — 80 (см. [энергопотребление](engine.md#когда-выполняются-проверки-и-лимиты-ресурсов)). Встроенные профили с проверками и диагностикой имеют уровень `advanced`.

```yaml
rcx: 1
title: Checked
level: advanced
checks:
  chat: { http: 'https://api.telegram.org/', expect: [200, 301, 302, 404] }
prefer:
  - label: Opens chat
    when: passes(chat)
  - label: Anything
    when: not dead
```

### `extends`

Наследует профиль по ID: `builtin/x`, `provider/x` или `user/x`. Имя без префикса означает `provider/x`. Цепочка не должна превышать 4 уровня.

```yaml
rcx: 1
title: Stable, Norway first
extends: builtin/stable
prefer:
  - label: Norway
    when: country = NO
  - label: Anything
    when: not dead
```

Правила объединения описаны ниже в разделе [Extends](#extends).

### `pool`

Чтобы сервер был доступен, `include` должен быть истинным, а `exclude` — ложным. Оба поля используют [условия](conditions.md). Неизвестные факты разрешают сервер. Уровни могут только сужать пул: `include` дочернего профиля объединяется с родительским через `and`, а `exclude` — через `or`.

```yaml
rcx: 1
title: Europe, no test servers
pool:
  include: country in [DE, NL, SE, FI, NO]
  exclude: name ~ /(?i)test|demo/
```

### `tags`

Именованные условия для повторного использования. Метку вызывают как `tag(name)`. Условие метки не может вызывать `tag()`, поэтому метки не зависят друг от друга.

```yaml
rcx: 1
title: Prefer mobile-friendly
tags:
  lte: 'name ~ /(?i)lte|mobile/'
prefer:
  - label: LTE nodes
    when: tag(lte) and not dead
  - label: Anything
    when: not dead
```

### `prefer`

Порядок серверов. Каждый шаг содержит `label` (показывается в приложении; без метки выводится «Tier N»), условие `when` и необязательный флаг `last-resort`. Выбирается первый шаг с работающим сервером; если все его серверы не работают, используется следующий.

```yaml
rcx: 1
title: Starred, then Finland, then any
prefer:
  - label: Starred
    when: name ~ /\*/ and not dead
  - label: Finland
    when: country = FI
  - label: Anything
    when: not dead
    last-resort: true
```

`last-resort: true` помечает шаг как окончательный резерв. Он используется, только если в остальных шагах нет работающих серверов, даже если те записаны ниже: при компиляции движок перемещает резервные шаги в конец, сохраняя их порядок. Студия также не предупреждает, если такой шаг пуст.

`prefer` пользователя или сценария заменяет этот список для группы (см. [приоритет порядка серверов](scenarios.md#приоритет-порядка-серверов)).

### `rank`

Порядок серверов внутри выбранного шага.

| Поле | Значения | По умолчанию | Значение |
| --- | --- | --- | --- |
| `by` | `latency`, `stability` | `latency` | `latency` предпочитает скорость; `stability` сильнее учитывает разброс и прежние сбои (см. [оценки](engine.md#шаг-4-рейтинг)). |
| `tolerance` | целое число, мс | `0` | Текущий сервер получает такую прибавку, поэтому претендент должен быть заметно лучше. |

```yaml
rcx: 1
title: Steady
rank:
  by: stability
  tolerance: 100
```

### `switch`

Когда движок может переключиться с *работающего* сервера. Неисправный сервер заменяется всегда.

| Поле | Тип | Значение |
| --- | --- | --- |
| `improve` | логическое, по умолчанию `false` | Можно ли менять работающий сервер на более удачный в том же шаге. Если нет, переключение происходит только при отказе. |
| `feel` | `calm`, `balanced`, `eager` | Пресет для следующих пяти параметров. По умолчанию `balanced`. |
| `dwell` | длительность (`10m`, `1h30m`) | Минимальный интервал между добровольными переключениями. |
| `min-gain-ms` | целое число | Претендент должен быть быстрее как минимум на указанное число мс. |
| `min-gain-pct` | целое число | …и как минимум на указанный процент текущей оценки. |
| `confirm` | целое число | Число свежих измерений выше порога перед переключением. |
| `max-per-hour` | целое число | Ограничение добровольных переключений в час. |

| Режим | dwell | min-gain-ms | min-gain-pct | confirm | max-per-hour |
| --- | --- | --- | --- | --- | --- |
| `calm` | 30 мин | 60 | 30 | 3 | 2 |
| `balanced` | 10 мин | 30 | 20 | 2 | 4 |
| `eager` | 2 мин | 15 | 10 | 2 | 8 |

Явное значение переопределяет пресет.

```yaml
rcx: 1
title: Eager but not twitchy
switch:
  improve: true
  feel: eager
  max-per-hour: 3
```

### `stranded`

Действие, если ни один сервер не подходит: `hold` (оставить текущий, по умолчанию), `direct` (использовать `DIRECT`) или `group:<name>` (использовать другую группу).

```yaml
rcx: 1
title: Fall back to direct
stranded: direct
```

### `energy`

`eco`, `balanced` (по умолчанию) или `precise`. Настраивает почасовые лимиты проверок (см. [бюджеты](engine.md#бюджеты)).

```yaml
rcx: 1
title: Frugal
energy: eco
```

### `checks`

Именованные тесты. Каждый содержит ровно одно поле из `http`, `tcp`, `tls`, а также дополнительные необязательные поля.

| Поле | Применимо к | Значение |
| --- | --- | --- |
| `http` | HTTP | URL `http://` или `https://`. |
| `tcp` | TCP | `host:port` для подключения. |
| `tls` | TLS | `host:port` для рукопожатия TLS. |
| `sni` | TLS | Имя сервера для отправки. |
| `expect` | только HTTP | Список допустимых кодов состояния от 100 до 599. |
| `optional` | все | Ошибка считается «мягкой»: проверка не считается ни успешной, ни неуспешной. |

Используйте проверки через `passes(id)` и `fails(id)`. Максимум 8 проверок.

```yaml
rcx: 1
title: Must open the video site
level: advanced
checks:
  video: { http: 'https://www.youtube.com/generate_204', expect: [204] }
  chat: { tcp: 'api.telegram.org:443', optional: true }
prefer:
  - label: Opens video and chat
    when: passes(video) and passes(chat)
  - label: Opens video
    when: passes(video)
  - label: Anything
    when: not dead
```

Каждая проверка расходует один запрос на участника, поэтому используйте их экономно, а дополнительные помечайте `optional`.

### `network`

Объявляет проверки и типы сети для сред с разным поведением (captive portal, мобильные белые списки).

`diagnose` сопоставляет имя со списком целей одного типа (`http`, `tcp` или `tls`). Диагностика считается успешной, если отвечает любая цель. Допускается до 8 диагностик, в каждой — до 4 целей. Имя диагностики должно быть в нижнем регистре и соответствовать `[a-z0-9-]`, длина — от 1 до 24 символов.

`kinds` — список, проверяемый сверху вниз: первый истинный `when` задаёт текущий тип. Тип с `pause: true` приостанавливает группу. Максимум 8 типов.

```yaml
rcx: 1
title: Knows about whitelists
level: advanced
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443', '77.88.8.1:443'] }
    foreign: { tls: ['1.1.1.1:443', '9.9.9.9:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: whitelist, when: 'home ok and foreign fail' }
    - { kind: open, when: 'foreign ok' }
```

### `on`

Переопределения для каждого типа сети. Разрешены `pool`, `prefer`, `rank`, `switch`, `stranded`, `energy`. Тип должен быть объявлен в `network.kinds`, иначе профиль отклоняется.

```yaml
rcx: 1
title: Different on a whitelist network
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: whitelist, when: 'home ok and foreign fail' }
prefer:
  - label: Anything
    when: not dead
on:
  whitelist:
    prefer:
      - label: Bypass node
        when: name ~ /(?i)bypass|whitelist/ and not dead
      - label: Anything
        when: not dead
```

### `direct-split`

Условие сети. Пока оно истинно, первая умная группа, где пользователь включил разделение прямого трафика, отправляет внутренний трафик напрямую. Включить параметр может только пользователь; профиль провайдера не может этого сделать. См. [разделение прямого трафика](engine.md#разделение-прямого-трафика).

```yaml
rcx: 1
title: Split when only home works
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
direct-split: 'home fail and foreign ok'
```

### `egress-verify`

Настройки проверки страны выхода для `exit.country`.

| Поле | По умолчанию | Значение |
| --- | --- | --- |
| `echo` | `https://www.cloudflare.com/cdn-cgi/trace`, `https://ipinfo.io/json` | HTTP(S) echo-сервисы, максимум 4. |
| `agree` | `2` | Число источников, которые должны назвать одну страну: от 1 до 3. |

```yaml
rcx: 1
title: Verified exit
level: advanced
egress-verify:
  echo:
    - https://www.cloudflare.com/cdn-cgi/trace
    - https://ipinfo.io/json
  agree: 2
prefer:
  - label: Really abroad
    when: exit.country != RU and not dead
  - label: Anything
    when: not dead
```

Если пользовательский echo-узел указан провайдером, требуется согласие (см. [согласие](engine.md#согласие-для-профилей-провайдера)).

### `l10n`

Переводы по языковым тегам (`ru`, `zh-CN`). Каждая запись сопоставляет *исходный текст* (английский заголовок, описание или метку шага) с переводом. До 16 языков, по 64 строки на язык, длина строки до 160 символов. Приложение показывает язык пользователя и при необходимости исходный текст.

```yaml
rcx: 1
title: Fast Germany
prefer:
  - label: Germany
    when: country = DE
  - label: Anything
    when: not dead
l10n:
  ru:
    Fast Germany: Быстрая Германия
    Germany: Германия
    Anything: Любой
```

## Значения по умолчанию

| Настройка | Значение |
| --- | --- |
| `level` | `simple` |
| `prefer` | один шаг «Working» с `not dead` |
| `rank.by` | `latency`, допуск `0` |
| `switch.feel` | `balanced`, `improve` выключен |
| `stranded` | `hold` |
| `energy` | `balanced` |
| `egress-verify.agree` | `2` |
| профиль группы, если ничего не выбрано | `builtin/simple` |

## Ограничения

| Ограничение | Значение |
| --- | --- |
| Размер профиля | 64 КиБ |
| Длина условия | 2048 символов, вложенность до 16 уровней |
| Регулярное выражение | 512 символов |
| Шаги `prefer` | 16 |
| Метки | 32 |
| Проверки | 8 |
| Диагностики сети / целей в каждой | 8 / 4 |
| Типы сети, типы `on` | 8 |
| Echo-сервисы | 4 |
| Языки / строк на язык / длина строки | 16 / 64 / 160 |
| Глубина `extends` | 4 |
| Чипы в привязке группы | 12 |

## Extends

Дочерний профиль наследует родительский и изменяет только явно указанные параметры.

| Ключ | Правило объединения |
| --- | --- |
| `pool` | `include` объединяются через `and`, `exclude` — через `or`: дочерний профиль только сужает пул. |
| `tags` | Объединяются по имени; при совпадении используется дочерний вариант. |
| `prefer` | Список дочернего профиля целиком заменяет родительский. |
| `switch` | Дочерний `feel` сбрасывает остальные параметры переключения к значениям пресета. |
| `checks`, `network.diagnose`, `on`, `l10n` | Объединяются по ключам. |
| `network.kinds` | Заменяются целиком. |
| остальные | Если дочернее значение задано, используется оно. |

## Уровни и привязки

Профиль принадлежит уровню, заданному ID: `builtin/x`, `provider/x`, `user/x`. **Привязка** группы (задаётся провайдером или пользователем) выбирает профиль и может содержать дополнительные параметры:

| Ключ привязки | Значение |
| --- | --- |
| `profiles` | Список ID профилей, предлагаемых для группы. |
| `default` | Профиль до выбора пользователя. |
| `profile` | Выбор пользователя. |
| `pool`, `feel`, `energy` | Переопределения; настройка пользователя заменяет настройку провайдера. |
| `prefer` | Порядок серверов, заменяющий порядок профиля. |
| `chips` | До 12 быстрых фильтров `{label, include}`, отображаемых в приложении. |

См. [Обмен](sharing.md), чтобы узнать, как провайдер публикует такие профили.

## Встроенные профили

Встроенные профили поставляются с приложением, содержат переводы на все поддерживаемые языки и всегда доступны как `builtin/<name>`.

| ID | Назначение |
| --- | --- |
| `builtin/simple` | Оставаться на работающем сервере; переключаться при его отказе. |
| `builtin/fastest` | Искать минимальную задержку и охотно переключаться. |
| `builtin/stable` | Предпочитать стабильный сервер, редко переключаться. |
| `builtin/from-list` | Как simple; используется для группы с ручным порядком провайдера. |
| `builtin/bypass-ru` | Россия: предпочитать зарубежные серверы, открывающие заблокированные сайты. |
| `builtin/bypass-ir` | Иран: аналогично, с проверкой YouTube. |
| `builtin/bypass-cn` | Китай: аналогично, с проверкой Google. |
| `builtin/whitelist-ru` | Россия, мобильные белые списки: наследует `bypass-ru` и добавляет шаг узлов обхода. |

### `builtin/simple`

```yaml
rcx: 1
title: Simple
level: simple
prefer:
  - label: Working
    when: not dead
rank:
  by: latency
  tolerance: 50
switch:
  improve: false
  feel: calm
stranded: hold
energy: balanced
```

(В поставляемом файле также есть `description` и `l10n`.) Работающий сервер сохраняется. Среди работающих предпочитается минимальная задержка, но при `improve: false` движок переключается, только если текущий сервер отказал.

### `builtin/fastest`

```yaml
rcx: 1
title: Fastest
rank:
  by: latency
  tolerance: 20
switch:
  improve: true
  feel: balanced
```

Переключается на явно более быстрый сервер (минимум на 30 мс и 20 %), если преимущество подтверждено дважды, не чаще четырёх раз в час и не ранее чем через 10 минут после прошлого переключения.

### `builtin/stable`

```yaml
rcx: 1
title: Stable
rank:
  by: stability
  tolerance: 100
switch:
  improve: true
  feel: calm
```

Оценка стабильности сильно штрафует за разброс и прошлые сбои, а режим `calm` обеспечивает редкие переключения.

### `builtin/from-list`

```yaml
rcx: 1
title: From the list
extends: builtin/simple
```

### `builtin/bypass-ru`, с пояснениями

```yaml
rcx: 1
title: Russia · bypass blocks
description: "For use in Russia: prefers servers abroad that open sites blocked at home, and uses a local exit only as a last resort."
level: advanced
checks:
  open: { http: 'https://api.telegram.org/', expect: [200, 301, 302, 404] }
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443', '77.88.8.1:443'] }
    foreign: { tls: ['1.1.1.1:443', '9.9.9.9:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: open, when: 'foreign ok' }
prefer:
  - { label: Opens blocked, when: 'passes(open) and exit.country != RU' }
  - { label: Abroad, when: 'not dead and exit.country != RU' }
  - { label: Home exit, when: 'not dead', last-resort: true }
rank: { by: latency, tolerance: 40 }
switch: { improve: true, feel: calm }
stranded: hold
direct-split: 'home fail and foreign ok'
energy: balanced
```

- `checks.open` обращается к API Telegram через каждый сервер. Коды 200, 301, 302 или 404 означают, что сервер открывает сайт, заблокированный в России.
- `network.diagnose` проверяет без туннеля, отвечает ли DNS Яндекса (`home`) и доступны ли Cloudflare и Quad9 по TLS (`foreign`).
- Тип `portal` приостанавливает группу при активном captive portal. Тип `open` обозначает сеть с доступным зарубежным интернетом.
- Лестница: сначала серверы с открытым заблокированным сайтом и подтверждённым выходом за пределами России; затем любой работающий зарубежный сервер; в крайнем случае — любой работающий сервер.
- `exit.country` неизвестен до проверки, поэтому ещё не проверенные серверы ожидают, а планировщик запускает запросы.
- `direct-split` — условие, при котором пользователь, включивший функцию, получает разделение для прямого выхода внутреннего трафика: домашний интернет работает, а зарубежный — нет.

`builtin/bypass-ir` и `builtin/bypass-cn` имеют ту же структуру. Отличаются URL проверки (`open`: `https://www.youtube.com/generate_204` с ожидаемым 204 для Ирана и `https://www.google.com/generate_204` с 204 для Китая), исключаемой страной (`IR`, `CN`), наличием только типа `portal`, а также отсутствием диагностики и `direct-split`.

### `builtin/whitelist-ru`, с пояснениями

```yaml
rcx: 1
title: Russia · mobile whitelists
level: advanced
extends: builtin/bypass-ru
tags:
  bypass: 'name ~ /(?i)lte|bypass|whitelist|обход|белы[ей]/'
network:
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: whitelist, when: 'home ok and foreign fail' }
    - { kind: open, when: 'foreign ok' }
on:
  whitelist:
    prefer:
      - { label: Bypass node, when: 'tag(bypass) and not dead' }
      - { label: Opens blocked, when: 'passes(open)' }
      - { label: Any working, when: 'not dead', last-resort: true }
```

- Наследует всё из `bypass-ru` и добавляет метку `bypass` для имён, похожих на названия серверов обхода.
- В сети типа *whitelist* (домашние ресурсы доступны, зарубежный интернет — нет) применяется другая лестница: сначала узлы обхода, затем серверы, прошедшие проверку, затем любой работающий.
- `network.kinds` целиком заменяет родительский список, поэтому типы `portal` и `open` нужно объявить повторно.
