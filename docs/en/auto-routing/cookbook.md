# Cookbook

Complete profiles and scenarios for common tasks. Each one passes rcxlint as written.

## Main traffic via one country, services elsewhere

Everything through Norway; YouTube through the fastest server; Russian sites direct.

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

## Ladder of preferences

Starred servers first, then Finland, then anything that works.

```yaml title="starred-ladder.rcx.yaml"
rcx: 1
title: Starred, then Finland
prefer:
  - { label: Starred, when: 'name ~ /\*/ and not dead' }
  - { label: Finland, when: 'country = FI' }
  - { label: Anything, when: 'not dead', last-resort: true }
rank: { by: latency, tolerance: 30 }
```

The order moves to Finland only once every starred server is dead or excluded.

## Frugal profile

Few checks and rare switches for a weak device or a metered link.

```yaml title="frugal.rcx.yaml"
rcx: 1
title: Frugal
extends: builtin/stable
energy: eco
switch: { feel: calm, max-per-hour: 1 }
```

A dead server is still replaced at once; the limit applies only to improvement switches.

## Exclude test servers

Never pick servers named as tests or trials, not even as a last resort.

```yaml title="no-test.rcx.yaml"
rcx: 1
title: No test servers
tags:
  trial: 'name ~ /^trial/i'
pool: { exclude: 'name ~ /test|demo|expired/i or tag(trial)' }
```

`pool.exclude` removes members before any tier is considered. A binding or a scenario can narrow the pool further but
never widen it.

## Verified exit country

Use only servers whose exit was confirmed outside Russia, falling back to any working server.

```yaml title="verified-exit.rcx.yaml"
rcx: 1
title: Verified exit
prefer:
  - { label: Verified abroad, when: 'exit.country != RU' }
  - { label: Any, when: 'not dead', last-resort: true }
```

Until its exit is verified a server counts as `Any`. The planner checks it when that could lift the group a tier.

## Mobile data versus Wi-Fi

The fastest server on Wi-Fi, a stable one on mobile data.

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

`network.transport` is reported on Android. Elsewhere it stays unknown, and the kind is never recognized.

## Go direct when nothing works

Fall back to `DIRECT` instead of holding a dead server.

```yaml title="direct-fallback.rcx.yaml"
rcx: 1
title: Direct fallback
extends: builtin/simple
stranded: direct
```

`stranded` applies only when no member is eligible. With `group:<name>` it selects that member instead.

## Hold a group on one member

Keep the main group on a fixed member, such as a load balancer, without any search.

```yaml title="hold-main.rcx.yaml"
rcx: 1
title: Hold main
groups:
  $main: { to: Balancer }
```

A pin still wins over `to`. When the config has no `Balancer`, the group reports `fixed.missing` and keeps its member.

## Provider routing bundle

A provider ships a profile and a default scenario through the `reclash-routing` field.

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

Nothing here contacts a host, so no consent is needed; see [Provider delivery](sharing.md#provider-delivery).
