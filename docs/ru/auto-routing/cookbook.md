# Рецепты

Готовые профили и сценарии для частых задач. Каждый проходит rcxlint в том виде, как написан.

## Основной трафик через одну страну, сервисы — через другие

Всё через Норвегию; YouTube через самый быстрый сервер; российские сайты напрямую.

```yaml title="norway-split.rcx.yaml"
rcx: 1
title: Norway split
mode: rule
groups:
  $main: { profile: builtin/simple, prefer: [{ label: Norway, when: 'country = NO' }, { label: Any, when: 'not dead', last-resort: true }] }
routes:
  - name: YouTube
    match: [GEOSITE,youtube]
    profile: builtin/fastest
  - name: Local
    match: ['GEOSITE,category-ru', 'GEOIP,RU,no-resolve']
    to: DIRECT
```

## Лестница предпочтений

Сначала серверы со звёздочкой, затем Финляндия, затем всё, что работает.

```yaml title="starred-ladder.rcx.yaml"
rcx: 1
title: Starred, then Finland
prefer:
  - { label: Starred, when: 'name ~ /\*/ and not dead' }
  - { label: Finland, when: 'country = FI' }
  - { label: Anything, when: 'not dead', last-resort: true }
rank: { by: latency, tolerance: 30 }
```

Порядок переходит к Финляндии, только когда все серверы со звёздочкой мертвы или исключены.

## Экономный профиль

Мало проверок и редкие переключения для слабого устройства или лимитного канала.

```yaml title="frugal.rcx.yaml"
rcx: 1
title: Frugal
extends: builtin/stable
energy: eco
switch: { feel: calm, max-per-hour: 1 }
```

Мёртвый сервер по-прежнему заменяется сразу; лимит касается только переключений ради улучшения.

## Исключить тестовые серверы

Никогда не выбирать серверы с тестовыми или пробными именами, даже как запасной вариант.

```yaml title="no-test.rcx.yaml"
rcx: 1
title: No test servers
tags:
  trial: 'name ~ /^trial/i'
pool: { exclude: 'name ~ /test|demo|expired/i or tag(trial)' }
```

`pool.exclude` убирает элементы до рассмотрения уровней. Привязка или сценарий могут сузить пул дальше, но никогда не
расширить его.

## Проверенная страна выхода

Только серверы, чей выход подтверждён за пределами России, а запасной вариант — любой рабочий сервер.

```yaml title="verified-exit.rcx.yaml"
rcx: 1
title: Verified exit
prefer:
  - { label: Verified abroad, when: 'exit.country != RU' }
  - { label: Any, when: 'not dead', last-resort: true }
```

Пока выход не проверен, сервер считается `Any`. Планировщик проверяет его, когда это может поднять группу на уровень.

## Мобильные данные и Wi-Fi

Самый быстрый сервер в Wi-Fi, стабильный — в мобильной сети.

```yaml title="mobile-wifi.rcx.yaml"
rcx: 1
title: Mobile and Wi-Fi
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

`network.transport` сообщается на Android. На других платформах он остаётся неизвестным, и тип не распознаётся.

## Напрямую, когда ничего не работает

Переходить на `DIRECT` вместо того, чтобы держать мёртвый сервер.

```yaml title="direct-fallback.rcx.yaml"
rcx: 1
title: Direct fallback
extends: builtin/simple
stranded: direct
```

`stranded` действует, только когда ни один элемент не пригоден. С `group:<name>` выбирается элемент `<name>`.

## Держать группу на одном элементе

Держать основную группу на фиксированном элементе, например балансировщике, без всякого поиска.

```yaml title="hold-main.rcx.yaml"
rcx: 1
title: Hold main
groups:
  $main: { to: Balancer }
```

Закрепление всё равно важнее `to`. Если в конфиге нет `Balancer`, группа сообщает `fixed.missing` и сохраняет свой элемент.

## Пакет маршрутизации провайдера

Провайдер раздаёт профиль и сценарий по умолчанию через поле `reclash-routing`.

```yaml title="routing.yaml"
profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - { label: Germany, when: 'country = DE' }
      - { label: Any, when: 'not dead', last-resort: true }
groups:
  Proxy: { profiles: [provider/fast-de, builtin/stable], default: provider/fast-de }
scenarios:
  work:
    rcx: 1
    title: Work
    groups:
      $main: { profile: provider/fast-de }
    routes:
      - name: Intranet
        match: [DOMAIN-SUFFIX,corp.example]
        to: DIRECT
scenario: provider/work
```

Здесь ничто не обращается к узлам, поэтому согласие не нужно; см.
[Доставка от провайдера](sharing.md#provider-delivery).
