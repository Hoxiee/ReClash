# Profiles

Reference for the RCX profile format: keys, defaults, inheritance, bindings and limits.

## Document

A profile is one YAML mapping; unknown keys are errors. The app calls a profile a behaviour.

```yaml title="bypass-de.rcx.yaml"
rcx: 1
title: Germany first
description: Prefers servers that exit in Germany and open the test page.
level: advanced
pool: { exclude: 'type = http' }
tags:
  premium: 'name ~ /premium|vip/i'
checks:
  page: { http: 'https://example.com/', expect: [200] }
prefer:
  - { label: German exit, when: 'exit.country = DE and passes(page)' }
  - { label: Premium, when: 'tag(premium) and not dead' }
  - { label: Any working, when: 'not dead', last-resort: true }
rank: { by: latency, tolerance: 40 }
switch: { improve: true, feel: calm, max-per-hour: 1 }
stranded: direct
energy: balanced
```

## Keys

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `rcx` | integer | 1 | Format version; above 1 is rejected. |
| `title` | string | the id | Display name. |
| `description` | string | — | One-line summary in choosers. |
| `level` | `simple` \| `advanced` | `simple` | How much the editor exposes. |
| `extends` | profile id | — | Base profile; see [Inheritance](#inheritance). |
| `pool` | `{include, exclude}` | all members | Server conditions that narrow the members. |
| `tags` | map name → server condition | — | Named server sets for `tag(name)`. |
| `checks` | map id → check | — | Requests for `passes(id)` and `fails(id)`. |
| `prefer` | list of tiers | one step `Working` (`not dead`) | Ordered server tiers. |
| `rank.by` | `latency` \| `stability` | `latency` | Score formula; see [Score](engine.md#score). |
| `rank.tolerance` | integer ms | 0 | Bonus for the current server. |
| `switch.feel` | `calm` \| `balanced` \| `eager` | `balanced` | Preset for the `switch` fields. |
| `switch.improve` | boolean | `false` | Switch to a faster server in the same tier. |
| `switch.dwell` | duration | preset | Minimum time between improvement switches. |
| `switch.min-gain-ms` | integer | preset | Minimum gain in milliseconds. |
| `switch.min-gain-pct` | integer | preset | Minimum gain as a percentage of the current score. |
| `switch.confirm` | integer | preset | Fresh samples the candidate must win in a row. |
| `switch.max-per-hour` | integer | preset | Improvement switches per hour. |
| `stranded` | `hold` \| `direct` \| `group:<name>` | `hold` | Action when no member is eligible. |
| `energy` | `eco` \| `balanced` \| `precise` | `balanced` | Probe budget; see [Budgets](engine.md#budgets). |
| `network.diagnose` | map name → diagnostic | — | Direct probes for network conditions. |
| `network.kinds` | list of kind rules | — | Network kinds; first match wins. |
| `on` | map kind → layer | — | Changes on one network kind. |
| `direct-split` | network condition | — | When direct split may activate. |
| `egress-verify.echo` | list of URLs | two built-in services | Exit-country echo services. |
| `egress-verify.agree` | 0–3 | 2 (0 means 2) | Distinct agreeing sources required. |
| `l10n` | map language → map source → text | — | Translations of the profile's own strings. |

Durations use Go syntax (`90s`, `1h30m`) and cannot be negative. See [Feel presets](engine.md#feel-presets).

## Pool

`include` and `exclude` are [server conditions](conditions.md). A member is kept unless `include` is false or `exclude`
is true, so an unknown fact neither admits nor removes it. Non-servers (`DIRECT`, `REJECT` and similar) are never eligible.

## Tiers

```yaml
# fragment
prefer:
  - { label: Fast home, when: 'country = NL and latency < 80ms' }
  - { label: Any, when: 'not dead' }
  - { label: Fallback, when: 'not dead', last-resort: true }
```

| Field | Type | Description |
| --- | --- | --- |
| `label` | string | Shown in the app; empty shows as `Tier N`, N being the position. |
| `when` | server condition | Members for which it is true join the tier. |
| `last-resort` | boolean | The tier yields to every other tier, wherever it is listed. |

A member joins the first tier whose condition is true. Selection moves to the next tier only when every server in a tier
is excluded or dead.

## Checks

```yaml
# fragment
checks:
  web: { http: 'https://example.com/generate_204', expect: [204] }
  port: { tcp: 'example.net:443', optional: true }
  hello: { tls: '203.0.113.7:443', sni: example.org }
```

| Field | Type | Description |
| --- | --- | --- |
| `http` | URL | `HEAD` request through the server; redirects are not followed. |
| `tcp` | `host:port` | TCP connect through the server. |
| `tls` | `host:port` | TLS handshake through the server; the certificate is not verified. |
| `sni` | string | Server name for `tls`; defaults to the host when it is a name. |
| `expect` | list of 100–599 | `http` only; without it any response passes. |
| `optional` | boolean | A failure is soft: `passes(id)` and `fails(id)` both stay false. |

Exactly one of `http`, `tcp` or `tls` is required. A check runs only when a condition uses it, as an extra on a successful
probe. A host outside the provider's domain and the built-in endpoints needs consent when the profile comes from a
provider; see [Consent](sharing.md#consent).

## Network

```yaml
# fragment
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443', '77.88.8.1:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: whitelist, when: 'home ok and foreign fail' }
```

A diagnostic is a named list of `http` URLs or `tcp`/`tls` `host:port` targets, probed directly through the `DIRECT`
outbound. `<name> ok` holds when any target answered; `<name> fail` holds when every target was tried and none answered.

| Kind field | Type | Description |
| --- | --- | --- |
| `kind` | name | `[a-z0-9-]`, 1–24 characters. |
| `when` | network condition | Recognizes the kind. |
| `pause` | boolean | Hold the current server and stop checks on this kind. |

Recognition rules are in [Network kinds](engine.md#network-kinds).

## Per-network changes

```yaml
# fragment
on:
  whitelist:
    prefer:
      - { label: Bypass node, when: 'tag(bypass) and not dead' }
    switch: { feel: eager }
```

`on.<kind>` may set `pool`, `prefer`, `rank`, `switch`, `stranded` and `energy`. The kind must be declared in
`network.kinds`, or compiling fails with `the profile declares no network kind <kind>`. The layer merges over the profile
like a child in [Inheritance](#inheritance); the user's binding applies after it.

## Direct split

`direct-split` is a network condition. While it is true and the user enabled **Direct sites through this group**,
connections matched by an explicit `DIRECT` rule go through the group. Exceptions and states:
[Direct split](engine.md#direct-split).

## Translations

```yaml
# fragment
l10n:
  ru: { Germany first: Сначала Германия, German exit: Выход в Германии }
```

Keys are the profile's own source strings: title, description and tier labels. The app shows the user's language, else the
source text. Language tags are 2–3 lowercase letters, optionally followed by a region of 2–8 letters or digits (`ru`,
`zh-CN`).

## Inheritance

`extends` names a base profile; chains go at most 4 levels deep and cannot loop.

| Key | Merge rule |
| --- | --- |
| Scalars (`title`, `level`, `rank.by`, `stranded`, `energy`, …) | The child wins when set; `rank.tolerance: 0` cannot override. |
| `pool` | Narrows: includes joined with `and`, excludes with `or`. |
| `tags`, `checks`, `network.diagnose`, `l10n` | Merged per key; `l10n` per language and string. |
| `prefer` | Replaced when the child has any tier. |
| `switch` | A child `feel` resets the other fields to that preset (`improve` is kept); explicit fields then override. |
| `on` | Merged per kind; a child's `on.<kind>` replaces the parent's. |
| `network.kinds`, `egress-verify.echo` | Replaced whole. |
| `egress-verify.agree` | The child wins when set. |

Errors: `extends itself`, `extends more than 4 levels deep`, `profile <id> not found`.

## Bindings

A binding attaches a profile to one select group. The subscription writes it as `rcx:` on the group; the app keeps the
user's binding per subscription.

```yaml
# fragment
proxy-groups:
  - name: Proxy
    type: select
    proxies: [NL 1, NL 2, DE 1]
    rcx:
      profiles: [fast, builtin/stable]
      default: fast
      pool: { exclude: 'name ~ /test/' }
      chips:
        - { label: Netherlands, include: 'country = NL' }
```

| Key | Type | Description |
| --- | --- | --- |
| `profiles` | list of ids | Profiles offered for the group. |
| `default` | id | Used when `profile` is empty or missing. |
| `profile` | id | The chosen profile. |
| `pool` | `{include, exclude}` | Narrows the profile's pool. |
| `prefer` | list of tiers | Replaces the profile's order for this group. |
| `feel` | feel | Resets the switch fields to that preset. |
| `energy` | energy | Overrides the profile's energy. |
| `chips` | list of `{label, include}`, at most 12 | One-tap pools under **Choose from**; invalid chips are dropped. |

The user's binding replaces `profile`, `pool`, `feel` and `energy`, replaces `prefer` when non-empty, and adds its chips to
the provider's. A subscription cannot turn on direct split. The profile id resolves in order: `profile`, `default`,
`builtin/simple`; a missing `profile` is reported as `profile.missing`. Scenario programs apply on top; see
[Programs](scenarios.md#programs). Where the profile's own `on.<kind>` sets `prefer` for the current network
kind, that order wins over both.

## Limits

| Item | Limit |
| --- | --- |
| Document | 64 KiB |
| Tiers | 16 |
| Tags | 32 |
| Checks | 8 |
| Diagnostics | 8, each with 1–4 targets |
| Network kinds, `on` entries | 8 each |
| Echo services | 4, `http(s)` URLs |
| `extends` depth | 4 |
| Chips | 12 |
| `l10n` | 16 languages, 64 strings each, 1–160 characters per string |
| Condition | 2048 characters; see [Limits](conditions.md#limits) |
