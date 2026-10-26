# Profiles

A **profile** is the policy of one smart group: which servers are allowed, in what order of preference, how they are
ranked and how eagerly the engine switches. It is one YAML document of at most 64 KiB.

Examples marked `# fragment` are deliberately partial; everything else is a complete profile that passes
[`rcxlint`](sharing.md#the-rcxlint-tool).

Contents: [minimal profile](#a-minimal-profile) · [key reference](#key-reference) · [each key](#keys-in-detail) ·
[defaults](#defaults-at-a-glance) · [limits](#limits) · [merging](#extends) · [built-in profiles](#built-in-profiles)

## A minimal profile

```yaml
rcx: 1
title: Anything that works
```

With no `prefer` the profile has one step, "Working" (`not dead`), and the group keeps whatever server works. Every
other key refines that.

## Key reference

Unknown keys are errors, so a typo is caught on import rather than ignored.

| Key | Type | Default | What it does |
| --- | --- | --- | --- |
| `rcx` | integer | required for outside documents | Format version. `1` today; a higher number is rejected as newer than the app understands. |
| `title` | string | none | Name shown in lists. |
| `description` | string | none | One or two sentences: what it does and when to pick it. |
| `level` | `simple` \| `advanced` | `simple` | Complexity label; also the request budget class (30 or 80 requests an hour). |
| `extends` | profile id | none | Inherit another profile. Chain of at most 4. |
| `pool` | `{include, exclude}` | all servers | Which servers the group may use. |
| `tags` | map name → condition | none | Named conditions, usable as `tag(name)` in `pool` and `prefer`. Max 32. |
| `prefer` | list of steps | one step `not dead` | The server order (ladder). Max 16 steps. |
| `rank` | `{by, tolerance}` | `latency`, 0 | How to order servers inside a step. |
| `switch` | object | preset `balanced` | When to move away from a working server. |
| `stranded` | string | `hold` | What to do when no server qualifies. |
| `energy` | `eco` \| `balanced` \| `precise` | `balanced` | How much checking is allowed. |
| `checks` | map id → check | none | Named tests used as `passes(id)` / `fails(id)`. Max 8. |
| `network` | `{diagnose, kinds}` | none | Network probes and network kinds. |
| `on` | map kind → override | none | Per-network-kind overrides. Max 8 kinds. |
| `direct-split` | condition | off | When to send domestic traffic direct. User-layer only. |
| `egress-verify` | `{echo, agree}` | Cloudflare and ipinfo, 2 | How the exit country is verified. |
| `l10n` | map language → strings | none | Translations of title, description and labels. |

## Keys in detail

### `rcx`

The format version.

```yaml
rcx: 1
title: Versioned
```

A value above `1` fails with "profile format N is newer than this app understands".

### `title` and `description`

Plain text shown in the list of behaviours. Titles and descriptions are translated through `l10n`.

```yaml
rcx: 1
title: Quiet Europe
description: Keeps one European server and rarely changes it. Good for a laptop on battery.
pool:
  include: country in [DE, NL, FI]
```

### `level`

`simple` (default) or `advanced`. Simple profiles stay within 30 requests an hour, advanced ones within 80 (see
[energy](engine.md#when-checks-run-and-the-energy-budgets)). Built-ins that use checks and diagnostics are
`advanced`.

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

Inherit another profile by id: `builtin/x`, `provider/x` or `user/x`. A bare name means `provider/x`. The chain may
be at most 4 deep.

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

The merge rules are in [Extends](#extends) below.

### `pool`

`include` must hold and `exclude` must not hold for a server to be usable. Both are
[conditions](conditions.md). A condition over unknown facts admits the server. Layers can only narrow the pool: a
child's `include` is joined with the parent's by `and`, its `exclude` by `or`.

```yaml
rcx: 1
title: Europe, no test servers
pool:
  include: country in [DE, NL, SE, FI, NO]
  exclude: name ~ /(?i)test|demo/
```

### `tags`

Names for conditions you reuse. A tag is read with `tag(name)`. Tag conditions cannot call `tag()` themselves, so
tags cannot depend on tags.

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

The server order. Each step has a `label` (shown in the app; an unlabelled step is shown as "Tier N"), a `when`
condition, and an optional `last-resort` flag. The first step with a live server wins; if all of its servers are
dead, the next step is used.

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

`last-resort: true` marks a step as the final fallback. It is used only when no other step has a live server, even a
step written below it: the engine moves last-resort steps after all the others, keeping their order among themselves.
The studio also does not warn when such a step is empty.

A user's or scenario's `prefer` replaces this list for the group (see
[server-order precedence](scenarios.md#server-order-precedence)).

### `rank`

How to order servers inside the winning step.

| Field | Values | Default | Meaning |
| --- | --- | --- | --- |
| `by` | `latency`, `stability` | `latency` | `latency` favours speed; `stability` punishes spread and past failures harder (see the [scores](engine.md#step-4-ranking)). |
| `tolerance` | integer, ms | `0` | The current server is credited this much, so a challenger must be clearly better. |

```yaml
rcx: 1
title: Steady
rank:
  by: stability
  tolerance: 100
```

### `switch`

When the engine may move away from a *working* server. A dead server is always replaced regardless.

| Field | Type | Meaning |
| --- | --- | --- |
| `improve` | bool, default `false` | Whether the engine may leave a working server for a better one in the same step. When false it only fails over. |
| `feel` | `calm`, `balanced`, `eager` | A preset for the next five fields. Default `balanced`. |
| `dwell` | duration (`10m`, `1h30m`) | Minimum time between voluntary switches. |
| `min-gain-ms` | integer | The challenger must be at least this many ms better. |
| `min-gain-pct` | integer | ...and at least this percent better than the current score. |
| `confirm` | integer | Fresh samples that must beat the bar before switching. |
| `max-per-hour` | integer | Cap on voluntary switches per hour. |

| Feel | dwell | min-gain-ms | min-gain-pct | confirm | max-per-hour |
| --- | --- | --- | --- | --- | --- |
| `calm` | 30m | 60 | 30 | 3 | 2 |
| `balanced` | 10m | 30 | 20 | 2 | 4 |
| `eager` | 2m | 15 | 10 | 2 | 8 |

An explicit value overrides the preset.

```yaml
rcx: 1
title: Eager but not twitchy
switch:
  improve: true
  feel: eager
  max-per-hour: 3
```

### `stranded`

What to do when no server qualifies: `hold` (keep the current server, default), `direct` (use `DIRECT`) or
`group:<name>` (use another group).

```yaml
rcx: 1
title: Fall back to direct
stranded: direct
```

### `energy`

`eco`, `balanced` (default) or `precise`. It sets the hourly check allowance (see
[budgets](engine.md#budgets)).

```yaml
rcx: 1
title: Frugal
energy: eco
```

### `checks`

Named tests. Each has exactly one of `http`, `tcp`, `tls`, plus optional fields.

| Field | Applies to | Meaning |
| --- | --- | --- |
| `http` | HTTP | An `http://` or `https://` URL. |
| `tcp` | TCP | `host:port` to connect to. |
| `tls` | TLS | `host:port` for a TLS handshake. |
| `sni` | TLS | Server name to send. |
| `expect` | HTTP only | List of accepted status codes, 100 to 599. |
| `optional` | all | A failure is "soft": the check neither passes nor fails. |

Use them with `passes(id)` and `fails(id)`. Max 8 checks.

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

A check costs a request per member, so use few and rely on `optional` for extras.

### `network`

Declares probes and network kinds, for networks that behave differently (captive portals, mobile whitelists).

`diagnose` maps a name to a list of targets of one type (`http`, `tcp` or `tls`). A diagnostic is *ok* if any target
answers. Up to 8 diagnostics, each with up to 4 targets. Diagnostic names are lowercase, `[a-z0-9-]`, 1 to 24 characters.

`kinds` is a list tried top to bottom: the first `when` that holds names the current kind. A kind with `pause: true`
holds the group. Up to 8 kinds.

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

Per-kind overrides. Allowed inside: `pool`, `prefer`, `rank`, `switch`, `stranded`, `energy`. The kind must be
declared in `network.kinds`; otherwise the profile is rejected.

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

A network condition. While it holds, the first smart group whose user turned direct split on lets domestic traffic go
out directly. Only the user layer can turn it on; a provider's profile cannot enable it. See [direct split](engine.md#direct-split).

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

How the exit country is checked, for `exit.country`.

| Field | Default | Meaning |
| --- | --- | --- |
| `echo` | `https://www.cloudflare.com/cdn-cgi/trace`, `https://ipinfo.io/json` | `http(s)` echo services. Max 4. |
| `agree` | `2` | Sources that must name the same country. 1 to 3. |

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

Custom echo hosts need user consent when they come from a provider (see [consent](engine.md#consent-for-provider-profiles)).

### `l10n`

Translations keyed by language tag (`ru`, `zh-CN`). Each entry maps the *source text* (the English title,
description or a step label) to its translation. Up to 16 languages, 64 strings each, 160 characters per string. The
app shows the user's language and falls back to the source text.

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

## Defaults at a glance

| Setting | Default |
| --- | --- |
| `level` | `simple` |
| `prefer` | one step "Working" with `not dead` |
| `rank.by` | `latency`, tolerance `0` |
| `switch.feel` | `balanced`, `improve` false |
| `stranded` | `hold` |
| `energy` | `balanced` |
| `egress-verify.agree` | `2` |
| group profile when nothing is chosen | `builtin/simple` |

## Limits

| Limit | Value |
| --- | --- |
| Profile size | 64 KiB |
| Condition length | 2048 characters, nesting depth 16 |
| Regular expression | 512 characters |
| Steps in `prefer` | 16 |
| Tags | 32 |
| Checks | 8 |
| Network diagnostics / targets each | 8 / 4 |
| Network kinds, `on` kinds | 8 |
| Echo services | 4 |
| Languages / strings each / string length | 16 / 64 / 160 |
| `extends` depth | 4 |
| Chips per group binding | 12 |

## Extends

A child profile starts from the parent and changes only what it states.

| Key | Merge rule |
| --- | --- |
| `pool` | Includes join with `and`, excludes with `or`: the child can only narrow. |
| `tags` | Merged by name; the child wins on a clash. |
| `prefer` | The child's list replaces the parent's whole. |
| `switch` | A child `feel` resets the other switch values to that preset. |
| `checks`, `network.diagnose`, `on`, `l10n` | Merged per key. |
| `network.kinds` | Replaced whole. |
| everything else | The child's value wins if set. |

## Layers and bindings

A profile belongs to a layer by id: `builtin/x`, `provider/x`, `user/x`. A group's **binding** (set by the provider or
user) picks the profile and may add more:

| Binding key | Meaning |
| --- | --- |
| `profiles` | The list of profile ids offered for this group. |
| `default` | The one used until the user chooses. |
| `profile` | The user's choice. |
| `pool`, `feel`, `energy` | Overrides; a user value replaces the provider's. |
| `prefer` | A server order that replaces the profile's. |
| `chips` | Up to 12 `{label, include}` quick filters shown in the app. |

See [Sharing](sharing.md) for how a provider ships these.

## Built-in profiles

Built-ins ship with the app, carry translations for every supported language and are always available as `builtin/<name>`.

| Id | Purpose |
| --- | --- |
| `builtin/simple` | Keep a working server; fail over when it dies. |
| `builtin/fastest` | Chase the lowest latency, switching readily. |
| `builtin/stable` | Prefer a steady server, switching rarely. |
| `builtin/from-list` | Same as simple; for a group the provider orders by hand. |
| `builtin/bypass-ru` | Russia: prefer servers abroad that open blocked sites. |
| `builtin/bypass-ir` | Iran: the same idea with a YouTube check. |
| `builtin/bypass-cn` | China: the same idea with a Google check. |
| `builtin/whitelist-ru` | Russia, mobile whitelists: extends `bypass-ru` and adds a bypass-node step. |

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

(The shipped file also carries `description` and `l10n`.) A working server is kept. Among working servers the
lowest latency is preferred, but `improve: false` means the engine moves only when the current server dies.

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

Switches to a clearly faster server (at least 30 ms and 20 % better, confirmed twice, no more than 4 times an hour,
no sooner than 10 minutes after the last switch).

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

The stability score punishes spread and past failures heavily, and `calm` switches rarely.

### `builtin/from-list`

```yaml
rcx: 1
title: From the list
extends: builtin/simple
```

### `builtin/bypass-ru`, annotated

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

- `checks.open` fetches the Telegram API through each server. A status of 200, 301, 302 or 404 means the server
  reaches a site blocked in Russia.
- `network.diagnose` asks, without the tunnel, whether Yandex DNS answers (`home`) and whether Cloudflare and Quad9
  answer over TLS (`foreign`).
- The `portal` kind pauses the group while a captive portal is up. The `open` kind marks a network where the
  foreign internet is reachable.
- The ladder: first servers that open blocked sites and whose verified exit is outside Russia; then any live server
  outside Russia; last any live server.
- `exit.country` is unknown until verified, so servers that have not been looked up yet are *pending* and the planner
  buys the lookups.
- `direct-split` is the condition under which the user, if they turned it on, gets a split that sends domestic
  traffic direct: the home internet works and the foreign one does not.

`builtin/bypass-ir` and `builtin/bypass-cn` have the same shape. They differ in the check URL (`open` is
`https://www.youtube.com/generate_204`, expect 204, for Iran, and `https://www.google.com/generate_204`, expect 204,
for China), in the country they avoid (`IR`, `CN`), and in having only the `portal` kind, and in having no diagnostics and no `direct-split`.

### `builtin/whitelist-ru`, annotated

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

- It reuses everything from `bypass-ru`, and adds a `bypass` tag for names that look like bypass servers.
- On a *whitelist* network (home works, the foreign internet does not), the ladder changes: first bypass nodes, then
  any server that passes the check, then anything.
- `network.kinds` replaces the parent's list, so it repeats `portal` and `open`.
