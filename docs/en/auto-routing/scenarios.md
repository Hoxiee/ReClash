# Scenarios

Reference for the RCX scenario format: programs for groups, routes, network kinds and the tunnel mode.

## Document

A scenario is one YAML mapping of at most 64 KiB; unknown keys are rejected. One scenario runs per subscription: the
user's choice, else the subscription's `rcx-scenario`. Turning auto routing off keeps the choice but stops the scenario.

```yaml title="split.rcx.yaml"
rcx: 1
title: My split
mode: rule
tags:
  fast-ru: "name ~ '⚡ RU'"
groups:
  $main: { profile: builtin/fastest, prefer: [{ label: Norway, when: 'country = NO' }] }
  '*': {}
routes:
  - name: YouTube
    match: [GEOSITE,youtube]
    prefer:
      - { label: Fast RU, when: 'tag(fast-ru)' }
      - { label: Any, when: 'not dead' }
  - name: Claude
    match: [GEOSITE,anthropic]
    prefer: [{ label: Sweden, when: 'country = SE' }]
  - name: Local
    match: ['GEOSITE,category-ru', 'DOMAIN-SUFFIX,yandex.ru']
    to: DIRECT
```

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `rcx` | integer | 1 | Format version; above 1 is rejected. |
| `title`, `description` | string | — | Display text. |
| `tags` | map name → server condition | — | Visible to every program, beside the program profile's own tags. |
| `network` | `{diagnose, kinds}` | — | As in a profile; see [Network](profiles.md#network). |
| `mode` | `rule` \| `global` \| `direct` | — | Tunnel mode the scenario holds; empty leaves it to the user. |
| `groups` | map target → program | — | Programs by group; see [Targets](#targets). At most 32. |
| `routes` | list of routes | — | Rules placed before the config's rules; see [Routes](#routes). |
| `on` | map kind → `{mode, groups}` | — | Changes on one network kind. |
| `l10n` | translations | — | As in a profile. |

## Programs

| Key | Type | Description |
| --- | --- | --- |
| `profile` | profile id | Replaces the group's profile. Otherwise the group keeps its binding's profile, else `builtin/simple`. |
| `pool` | `{include, exclude}` | Narrows the binding's pool further. |
| `prefer` | list of tiers, at most 16 | Replaces the server order; beats the user's binding order. |
| `to` | member name | Holds the group on one member (server, load balancer, nested group) with no search. Excludes the other keys. |

`to` with any other key fails with `to holds one member, so profile, pool and prefer do not apply`. A program with `pool`
or `prefer` but no `profile` is checked when it runs, against the group's own profile.

## Targets

| Key | Applies to |
| --- | --- |
| Group name | That group. 1–64 characters. |
| Route name | Not allowed: a route carries its program on the route. |
| `$main` | The group the final `MATCH` rule sends traffic to. |
| `*` | Every other select group, never `GLOBAL`. |

Precedence for one group: its exact name, its route's program, `$main`, then `*`. A group the scenario does not name keeps
its binding or stays a plain selector.

## Routes

```yaml
# fragment
routes:
  - name: Work
    description: Office services through the Netherlands
    match:
      - DOMAIN-SUFFIX,corp.example
      - IP-CIDR,10.20.0.0/16,no-resolve
      - PROCESS-NAME,teams.exe
    pool: { include: 'country = NL' }
```

| Key | Type | Description |
| --- | --- | --- |
| `name` | string | 1–64 bytes, trimmed, no comma or control characters, unique. Becomes the group name. |
| `description` | string | At most 240 bytes. |
| `match` | list of `TYPE,value[,no-resolve]` | 1–128 entries. |
| `profile`, `pool`, `prefer` | program keys | How the route's own group chooses. |
| `to` | target | Send matches to an existing proxy, group, built-in target or another route's group instead of creating a group. |

Reserved names: `$main`, `*`, `GLOBAL`, `DIRECT`, `REJECT`, `REJECT-DROP`, `PASS`, `COMPATIBLE`.

### Match types

| Type | Value | `no-resolve` |
| --- | --- | --- |
| `DOMAIN`, `DOMAIN-SUFFIX`, `DOMAIN-KEYWORD`, `DOMAIN-WILDCARD` | Domain text | No |
| `DOMAIN-REGEX` | Regex; the whole rest of the entry | No |
| `GEOSITE` | Site category | No |
| `GEOIP` | Country or category code | Yes |
| `IP-CIDR`, `IP-CIDR6` | Address range | Yes |
| `IP-ASN` | AS number | Yes |
| `SRC-IP-CIDR` | Source address range | No |
| `DST-PORT` | Ports or ranges joined with `/`: `443/8000-8100` | No |
| `PROCESS-NAME`, `PROCESS-PATH` | Process name or path | No |
| `RULE-SET` | Name of a rule provider in the config | Yes |

Types are case-insensitive. A YAML flow list such as `[GEOSITE,youtube]` is read as one entry: a type item joins the next
item and an optional `no-resolve`.

### Apply

Routes take effect only when the config is applied. Each route without `to` adds a select group with `include-all: true`
and the route's rules, in route order, before all config rules. Changing a route's name, match or `to` requests one
re-apply, which the app performs; a program change applies live.

| Problem | Code | Cause |
| --- | --- | --- |
| Name taken | `route.name-taken` | A route without `to` is named like an existing proxy, group or built-in target. |
| Missing target | `route.to-missing` | `to` names nothing in the config or the routes. |
| Invalid | `route.invalid` | A `RULE-SET` is not in the config, or mihomo rejected the route's rule or group. |
| Not rule mode | `route.not-rule-mode` | Routes exist but the tunnel mode is not `rule`. |

A rejected route is dropped and the config is parsed again without it. A failure not traceable to one route marks every
route invalid and applies the config without routes.

## Network kinds

```yaml
# fragment
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: whitelist, when: 'home ok and foreign fail' }
on:
  whitelist:
    mode: global
    groups:
      GLOBAL: { profile: builtin/simple, pool: { include: tag(bypass) } }
```

`on.<kind>.groups` replaces the base program per target key; targets it does not name keep the base program.
`on.<kind>.mode` falls back to the base `mode`. A kind under `on` must be declared, or loading fails with
`the scenario declares no network kind <kind>`. Recognition follows [Network kinds](engine.md#network-kinds).

## Mode

The tunnel mode in force is the scenario's mode on the current kind, unless the user picked a mode by hand; then it is the
user's mode, else `rule`. Choosing a scenario returns the mode to it. Groups that carry no traffic in the current mode are
idle (`hold.idle`): they are neither decided nor checked.

| Mode | Idle groups |
| --- | --- |
| `rule` | `GLOBAL` |
| `global` | Every group except `GLOBAL` |
| `direct` | All groups |

## Limits

| Item | Limit |
| --- | --- |
| Document | 64 KiB |
| Programs per `groups` or `on.<kind>.groups` | 32 |
| Target name | 1–64 characters |
| Tags | 32; a tag cannot use `tag()` |
| Kinds, `on` entries | 8 each |
| Routes | 32 |
| Route name, description | 64 bytes, 240 bytes |
| Match entries per route | 128 |
