# Conditions

Reference for the RCX condition language: grammar, fields, functions, three-valued logic and limits.

## Where conditions appear

| Context | Kind | May use |
| --- | --- | --- |
| `pool.include`, `pool.exclude`, `prefer[].when`, chips, scenario programs | Server | Server and network fields, `tag()`, `passes()`, `fails()` |
| `tags` values | Server | Server and network fields, `passes()`, `fails()`; no `tag()` |
| `network.kinds[].when`, `direct-split` | Network | Network fields and `<diagnostic> ok` or `fail` only; a server field fails with `is about a server, not the network` |

An empty condition is always true.

## Grammar

```text
condition  = or
or         = and { "or" and }
and        = unary { "and" unary }
unary      = "not" unary | "(" or ")" | predicate
predicate  = boolfield
           | strfield ( "=" | "!=" ) value
           | strfield "in" "[" value { "," value } "]"
           | strfield "~" ( regex | string )
           | "latency" ( "=" | "!=" | "<" | "<=" | ">" | ">=" ) number
           | ( "tag" | "passes" | "fails" ) "(" name ")"
           | diagnostic ( "ok" | "fail" )
value      = word | string
word       = { letter | digit | "_" | "-" | "." | ":" }
string     = "'" { any but "'" } "'" | '"' { any but '"' } '"'
regex      = "/" { any, "\/" for a slash } "/" [ "i" ]
number     = digits [ "ms" ]
```

- Keywords (`and`, `or`, `not`, `in`, `ok`, `fail`) and field names are case-insensitive. `not` binds tightest, then
  `and`, then `or`.
- A lone `!` is an error: `use 'not' instead of '!'`.
- Strings have no escapes; quote any value with spaces, emoji or other characters outside `word`.
- A regex is RE2, unanchored; `i` is the only flag. A quoted string after `~` is also read as a pattern.
- String comparisons with `=`, `!=` and `in` ignore case.

## Fields

### Server fields

| Field | Type | Value | Unknown when |
| --- | --- | --- | --- |
| `name` | string | Member name | never |
| `provider` | string | Proxy provider that serves the member | never |
| `type` | string | mihomo adapter type, such as `Vless` or `Shadowsocks` | never |
| `server` | string | Server host or address | never |
| `country` | country | Verified exit country, else the country in the name (flag or English name) | never; empty counts as known |
| `exit.country` | country | Verified exit country | not verified yet |
| `entry.country` | country | GeoIP country of `server` when it is an IP address | `server` is a name or not in the database |
| `udp` | boolean | Member supports UDP | never |
| `alive` | boolean | Health `alive` | never |
| `dead` | boolean | Health `dead` | never |
| `measured` | boolean | Has latency samples from the last 6 hours | never |
| `current` | boolean | Is the selected member | never |
| `latency` | number, ms | Median latency | never; comparisons are false while not `measured` |

Country values are ISO 3166-1 alpha-2 codes (`NL`, `DE`).

### Network fields

| Field | Type | Value |
| --- | --- | --- |
| `network.kind` | string | The confirmed network kind |
| `network.transport` | string | `wifi`, `ethernet`, `cellular` or `other` on Android |
| `network.portal` | boolean | The system reports a captive portal |
| `metered` | boolean | The network is metered |

Network fields are unknown until the platform reports the network; `network.kind` is unknown until a kind is confirmed.

## Functions

| Form | True when | Errors |
| --- | --- | --- |
| `tag(name)` | The tag's condition is definitely true for the member; unknown counts as false. | `unknown tag`; `tag(…) is not allowed here` |
| `passes(id)` | The last result of check `id` is a pass. | `unknown check` |
| `fails(id)` | The last result of check `id` is a hard failure. | `unknown check` |
| `<diagnostic> ok` | Any target of the diagnostic answered. | `<name> needs ok or fail` |
| `<diagnostic> fail` | Every target was tried and none answered. | |

A check that was never run is unknown. A failed `optional` check makes both `passes()` and `fails()` false. A pass flips
only after two consecutive failures; see [Evidence](engine.md#evidence).

## Three-valued logic

Each predicate is true, false or unknown, combined by Kleene logic.

| A | B | A and B | A or B | not A |
| --- | --- | --- | --- | --- |
| true | unknown | unknown | true | false |
| false | unknown | false | unknown | true |
| unknown | unknown | unknown | unknown | unknown |

Consequences:

- A tier counts a member only when its condition is true. Unknown makes the member `pending`, which the planner may check.
- `pool.include` admits unknown; `pool.exclude` removes only true.
- An unknown network kind rule stops recognition until it resolves.

## Limits

| Item | Limit |
| --- | --- |
| Condition length | 2048 characters |
| Nesting | 16 levels; each `not` and each parenthesis adds one |
| Regex length | 512 characters |

## Examples

| Condition | Meaning |
| --- | --- |
| `not dead` | Any member not marked dead |
| `country in [NL, DE] and latency < 120ms` | Dutch or German, measured under 120 ms |
| `exit.country != RU and passes(open)` | Verified non-RU exit that opens the check |
| `name ~ /premium/i` | Name contains `premium` in any case |
| `name ~ '⚡ RU'` | Name contains the literal text `⚡ RU` |
| `udp and not type = Http` | Supports UDP and is not an HTTP proxy |
| `metered or network.transport = cellular` | Network condition: metered or mobile data |
| `home ok and foreign fail` | Network condition: only the `home` diagnostic answers |
