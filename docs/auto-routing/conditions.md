# Conditions

A **condition** is a small expression that answers one question about a server: "is this one acceptable?" You write
conditions in `pool.include`, `pool.exclude`, `tags`, and in the `when` of every step of `prefer`. In network
settings (`network.kinds`, `direct-split`) they describe the network instead.

Examples marked `# fragment` are partial. All other examples are complete profiles that pass
[`rcxlint`](sharing.md#the-rcxlint-tool). A condition is shown inside a profile so that you can copy it as is.

Contents: [quick tour](#quick-tour) · [grammar](#grammar) · [fields](#fields) · [operators](#operators) ·
[regular expressions](#regular-expressions) · [functions](#functions) · [unknown and pending](#three-valued-logic-unknown-and-pending) ·
[network conditions](#network-conditions) · [examples](#examples-from-simple-to-advanced) · [limits](#limits)

## Quick tour

```yaml
rcx: 1
title: Quick tour
pool:
  exclude: name ~ /(?i)test/
prefer:
  - label: Norway, fast
    when: country = NO and latency < 120
  - label: Nordics
    when: country in [NO, SE, FI, DK]
  - label: Anything
    when: not dead
```

- `country = NO` compares a field with a value.
- `latency < 120` compares a number (milliseconds).
- `country in [NO, SE, FI, DK]` is a set test.
- `name ~ /(?i)test/` is a regular-expression match, case-insensitive.
- `not dead` is a bare yes/no field with `not`.
- Combine with `and`, `or`, `not` and parentheses.

## Grammar

```text
condition   = or
or          = and { "or" and }
and         = not { "and" not }
not         = "not" not | primary
primary     = "(" condition ")" | test
test        = bool-field
            | string-field ( "=" | "!=" ) value
            | string-field "in" "[" value { "," value } "]"
            | string-field "~" regex
            | number-field ( "=" | "!=" | "<" | "<=" | ">" | ">=" ) number [ "ms" ]
            | "tag" "(" word ")"
            | "passes" "(" word ")" | "fails" "(" word ")"
value       = word | 'quoted' | "quoted"
regex       = /pattern/flags | 'quoted' | "quoted"
```

Rules of thumb:

- **Precedence**: `not` binds tightest, then `and`, then `or`. Use parentheses when in doubt.
- `!` is not allowed. Write `not` (the error says "use 'not'").
- A *word* may contain letters, digits and `_ - . :`. Anything else (spaces, `*`, flags) goes in quotes.
- Case does not matter when comparing strings (`country = no` equals `country = NO`).
- In YAML, quote the whole condition if it contains `: `, a leading `[`, `{`, `*`, `&`, `!` or `#`. Starting with a
  field name is usually safe, but when in doubt, use single quotes: `when: 'name ~ /a|b/'`.

## Fields

Fields are evaluated against one server, on the network it is currently on.

### Server fields

| Field | Kind | Operators | Meaning |
| --- | --- | --- | --- |
| `name` | string | `= != in ~` | The server's display name in the subscription. |
| `provider` | string | `= != in ~` | The provider (subscription) that supplies the server. |
| `type` | string | `= != in ~` | Protocol type, for example `vless`, `trojan`, `ss`. |
| `server` | string | `= != in ~` | The server address the node connects to. |
| `country` | string | `= != in ~` | Verified exit country, else the country read from the name. Never unknown. |
| `exit.country` | string | `= != in ~` | Verified exit country only. Unknown until verified. |
| `entry.country` | string | `= != in ~` | Country of the server's own address. Unknown until known. |
| `udp` | bool | bare | The node supports UDP. |
| `alive` | bool | bare | Recently seen working. |
| `dead` | bool | bare | Known to be down (confirmed failure). |
| `measured` | bool | bare | Has at least one latency sample on this network. |
| `current` | bool | bare | Is the group's current server. |
| `latency` | number | `= != < <= > >=` | The median latency in ms. False for a server not yet measured. |

### Country fields

Country values are **ISO 3166-1 alpha-2 codes** such as `NO`, `SE`, `DE`, `RU`. Write codes, not names:
`country = SE`, not `country = Sweden`.

The three country fields differ in where the value comes from.

| Field | Source | When it is unknown |
| --- | --- | --- |
| `country` | The verified exit country if the engine has one; otherwise parsed from the server **name**. | Never. If nothing is found it is empty (a known "none"), so it never buys a check. |
| `exit.country` | Only the verified exit country. | Until the engine has verified it with enough sources. |
| `entry.country` | The country of the server's address. | Until it is resolved. |

The name is read in this order: a flag emoji; an upper-case two-letter code that is a whole word (`DE`, `[NO]`);
an English country name or alias (`Germany`, `USA`, `UK`, `Korea`, `Russian Federation`). If a name has several
hints, the first rule wins.

Use `country` for everyday choice by place. Use `exit.country` when it must be true where traffic really leaves, for
example to avoid exits in your own country; the engine buys the verification only for servers it needs to decide on
(see [unknown and pending](#three-valued-logic-unknown-and-pending)).

### Check results and tags

| Form | Meaning |
| --- | --- |
| `passes(id)` | Check `id` of the profile passed. |
| `fails(id)` | Check `id` failed (confirmed). |
| `tag(name)` | The named condition from `tags` holds. |

The v2 draft spec mentioned a `group` field; it does not exist. Network fields and diagnostics are described under
[network conditions](#network-conditions).

## Operators

### Strings

| Operator | Example | Meaning |
| --- | --- | --- |
| `=` | `country = NO` | Equal, case-insensitive. |
| `!=` | `type != ss` | Not equal. |
| `in [ ]` | `country in [NO, SE]` | Equal to any listed value. |
| `~` | `name ~ /gold|silver/` | Regular-expression match (searches anywhere in the string). |

### Numbers

`= != < <= > >=` with an optional `ms` suffix: `latency <= 150ms` and `latency <= 150` are the same.

### Bool fields

A bool field stands alone: `udp`, `not dead`, `alive and udp`. Do not write `dead = true`.

### Combinators

`and`, `or`, `not`, parentheses. `not` before a test negates it: `not name ~ /test/`.

## Regular expressions

`~` takes a pattern in the Go **RE2** syntax. No look-around and no back-references; matching time is linear.

Two forms:

- `/pattern/` with optional flag `i` for case-insensitive: `name ~ /gold/i` (same as `/(?i)gold/`). Any other flag
  is an error.
- A quoted string: `name ~ 'gold|silver'`.

Inside `/ /`, write `\/` for a literal slash. A pattern is at most 512 characters.

### YAML escaping

The condition is a YAML string, so YAML sees it first.

| You want | Write |
| --- | --- |
| A literal `*` in the name | `name ~ /\*/` (the backslash is a regex escape; plain scalar is fine) |
| A literal `|` or `.` | `\|` or `\.` inside the regex |
| A regex containing `: ` or `#` | Put the whole condition in single quotes |
| A single quote inside single quotes | Double it: `'it''s'` |
| Backslashes inside double-quoted YAML | Double them: `"name ~ /\\*/"` |

Single-quoted YAML scalars keep backslashes as written, so they are the safest choice: `when: 'name ~ /\*/ and not dead'`.

```yaml
rcx: 1
title: Starred and flagged
prefer:
  - label: Starred
    when: 'name ~ /\*/ and not dead'
  - label: Flag emoji
    when: 'name ~ /🇩🇪|🇳🇱/'
  - label: Anything
    when: not dead
```

## Functions

| Function | Result |
| --- | --- |
| `tag(name)` | True when the tag's condition is true for this server. Always known. Tags cannot use `tag()` inside themselves. |
| `passes(id)` | True when check `id` has passed. Unknown if not measured. |
| `fails(id)` | True when check `id` has failed. Unknown if not measured. |

An **optional** check that fails is *soft*: both `passes` and `fails` are false for it.

## Three-valued logic: unknown and pending

A fact the engine has not measured yet is not false; it is **unknown**. Conditions therefore have three results:
yes, no and unknown, combined by Kleene logic.

| `and` | yes | no | unknown |
| --- | --- | --- | --- |
| **yes** | yes | no | unknown |
| **no** | no | no | no |
| **unknown** | unknown | no | unknown |

| `or` | yes | no | unknown |
| --- | --- | --- | --- |
| **yes** | yes | yes | yes |
| **no** | yes | no | unknown |
| **unknown** | yes | unknown | unknown |

`not unknown` is unknown.

What this means in practice:

- **A step is decided only when it is known.** If a server's condition for step 1 is unknown, the server is
  **pending**: it might belong in step 1, but the engine does not know yet.
- **Pending buys a check.** The planner pays for the missing measurement (an exit-country lookup, a named check)
  within the energy budget. Once the fact is known, the server lands in its step.
- **Short-circuiting helps.** `no and unknown` is *no*, so a server that already fails `country = NO` does not
  cost an exit lookup in `country = NO and exit.country = NO`. Put the cheap, always-known tests first.
- **Pool conditions admit on unknown.** A server is not hidden because a fact is missing.
- **Unknowns come from specific fields only**: `exit.country`, `entry.country`, and `passes()`/`fails()` before a
  measurement. `country`, `name`, `type`, `provider`, `server`, `udp` and `tag()` are always known. `latency`
  conditions are *no* (not unknown) for an unmeasured server, so they never trigger a check by themselves.
- If no step matches and a step was pending, the server is shown as "pending" rather than "no step".

## Network conditions

Conditions in `network.kinds` and `direct-split` describe the **network**, not a server. They accept these fields:

| Field | Kind | Meaning |
| --- | --- | --- |
| `network.kind` | string | The kind currently detected for the group. |
| `network.transport` | string | Link type reported by the platform; the tests use `wifi`, `cellular` and `ethernet`. |
| `network.portal` | bool | A captive portal is detected. |
| `metered` | bool | The network is marked metered. |
| `<name> ok`, `<name> fail` | diagnostic | Result of the named diagnostic from `network.diagnose`. |

Diagnostics exist only in network conditions. Server fields are not valid there. An unmeasured diagnostic is
unknown, which leaves the kind undecided until the probe returns.

```yaml
rcx: 1
title: Network kinds
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: cell, when: network.transport = cellular and metered }
    - { kind: whitelist, when: 'home ok and foreign fail' }
prefer:
  - label: Anything
    when: not dead
```

## Examples from simple to advanced

Each line is a `when` or a `pool` condition.

| Goal | Condition |
| --- | --- |
| Any working server | `not dead` |
| Only Norway | `country = NO` |
| Not Russia | `country != RU` |
| One of several countries | `country in [NO, SE, FI]` |
| Name contains "Premium" (any case) | `name ~ /premium/i` |
| Name carries a star | `name ~ /\*/` |
| Name carries a lightning bolt | `name ~ /⚡/` |
| Excludes demo servers | `not name ~ /(?i)demo|test/` |
| UDP capable and fast | `udp and latency < 100` |
| Hysteria or TUIC only | `type in [hysteria, hysteria2, tuic]` |
| From one provider | `provider = MyProvider` |
| Not the current server | `not current` |
| Fast Norway, otherwise any Nordic | `country = NO and latency < 80` then `country in [NO, SE, FI, DK]` as two steps |
| Verified exit outside my country | `exit.country != RU` |
| Passes a named check abroad | `passes(open) and exit.country != RU` |
| Tag or name | `tag(bypass) or name ~ /(?i)lte/` |
| Starred and either NO or SE | `name ~ /\*/ and (country = NO or country = SE)` |

A longer one, in context:

```yaml
rcx: 1
title: Careful ladder
level: advanced
tags:
  star: 'name ~ /\*/'
checks:
  open: { http: 'https://www.youtube.com/generate_204', expect: [204] }
pool:
  exclude: name ~ /(?i)test|demo/
prefer:
  - label: Starred, opens video, fast
    when: 'tag(star) and passes(open) and latency < 150'
  - label: Starred
    when: 'tag(star) and not dead'
  - label: Nordic, opens video
    when: 'country in [NO, SE, FI] and passes(open)'
  - label: Anything
    when: not dead
```

Reading it: the first step needs a starred server that opens video and is quick. Servers whose `open` check is
unmeasured are pending in step 1, so the planner checks them. If none qualifies, step 2 takes any starred server,
and so on.

## Limits

| Limit | Value |
| --- | --- |
| Condition text | 2048 characters |
| Nesting depth | 16 |
| Regular expression | 512 characters |

The published JSON schema uses the same 2048-character limit.

Error messages name the offending part and its position, for example `unknown field "bogus"`. In the studio they are
shown under the line that caused them.
