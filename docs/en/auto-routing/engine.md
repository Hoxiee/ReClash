# Engine

How RCX gathers evidence, recognizes networks, decides, switches and spends probes, with the exact rules and defaults.

## Evidence

Evidence is kept per server and per network environment (Wi-Fi, carrier or gateway, hashed with an install salt). At
most 16 environments are kept; the least recently used is evicted.

| Fact | Rule |
| --- | --- |
| Latency samples | The last 8 within 6 hours. `p50` is the median; spread is `p90 − p50`. |
| Episodes | Failure episodes in the last 24 hours, at most 16. |
| Freshness | A success is fresh for 45 minutes, or 3 hours once the environment is 2 hours old. |
| Check results | Kept 6 hours. A pass is overturned only by a second consecutive failure; one failure after a pass makes the result unknown. |
| Exit country | Global per server, 24 hours. A disagreeing lookup is retried after 2 hours. |
| Dial failures | 3 failed dials within 20 seconds, with no success between them, make the server suspect. |

Sources: engine probes, mihomo URL tests and real traffic, which counts as a success.

### Health

| Health | Condition |
| --- | --- |
| `dead` | Marked dead and no success since. |
| `alive` | A fresh success and no failure after it. |
| `stale` | A success exists but is not fresh, or a failure followed it. |
| `unknown` | Never succeeded. |

### Score

| `rank.by` | Score |
| --- | --- |
| `latency` | `p50 + spread/2 + 50 × episodes` |
| `stability` | `p50 + spread + 300 × episodes` |

An unmeasured server scores 2²⁰. Lower is better.

### Exit country

Echo services are queried through the server one at a time until the answer settles; each service host is one vote. A
local GeoIP lookup of the reported address adds one vote. A country is accepted only when every valid vote names it and
at least `agree` distinct sources voted (default 2). `XX`, `T1` and `EU` are rejected; until then `exit.country` is
unknown. Default echo services: `https://www.cloudflare.com/cdn-cgi/trace` and `https://ipinfo.io/json`.

## Network kinds

A profile or scenario declares kinds as an ordered list of rules over network conditions and direct diagnostics.

- The first rule whose condition is true names the kind; an unknown rule leaves the kind undecided.
- Moving from no kind to a kind applies at once. Moving between kinds, or back to none, needs 2 agreeing rounds.
- The kind is remembered per environment, separately for each profile and for the scenario.
- A kind with `pause: true` holds the group (`hold.paused`) and stops its checks while it lasts.
- Diagnostics are shared by all groups and the scenario, deduplicated per target, and retried after 5, 10, then 30 minutes.

## Decision

The decision for a group runs on every change of policy, evidence or context. It is a pure function of them, its
explanation is the ranking it decided on, and it never performs I/O.

### Eligibility

Each member is tested in this order; the first match excludes it.

| Code | Excluded when |
| --- | --- |
| `pool.no-match` | `pool.include` is false (unknown admits). |
| `pool.excluded` | `pool.exclude` is true. |
| `pool.unroutable` | The member is `REJECT`, `REJECT-DROP`, `PASS`, `COMPATIBLE`, `DIRECT` or `DNS`. |
| `cooldown` | It was left by **Change server** less than 15 minutes ago. |
| `dead` | Its health is `dead`. |
| `pending` | No tier is true yet, but one is unknown; the first unknown tier is recorded. |
| `no-tier` | Every tier is false. |

An eligible member takes the first tier whose condition is true. Last-resort tiers sort after all other tiers, wherever
they are.

### Ranking

Members sort by: eligible first, tier, health (`alive`, `stale`, `unknown`, `dead`), effective score, name. The current
member's effective score is its score minus `rank.tolerance`, when measured. The first row is the best candidate. Up to
2 `pending` members whose unknown tier beats the best candidate's are queued for a check each decision.

### Order

1. Control `manual`: action `manual`; nothing else runs.
2. Scenario `to` member, unless pinned: `hold.fixed`, `switch.fixed` or `fixed.missing`, which keeps the current member.
3. Network kind with `pause`: `hold.paused`.
4. Pin, if the pinned member is present, not dead and not excluded: `hold.pinned` or `switch.pinned`. Otherwise the pin
   waits and the pinned member is queued for a check.
5. No best candidate: `hold.no-alternative` if the current member is on cooldown, else `stranded`.
6. Switching rules below.

### Switching

| Step | Condition | Result |
| --- | --- | --- |
| 1 | No current member | `switch.initial` |
| 2 | **Change server** was requested and the best is another member | `switch.change-server` |
| 3 | Current member is dead | `switch.failover`; its connections are closed |
| 4 | Current member is excluded for any reason but cooldown | `switch.out-of-pool` |
| 5 | Current member on cooldown and no alternative | `hold.no-alternative` |
| 6 | Best is the current member | `hold.best` |
| 7 | Best is in a better tier | `switch.better-tier` if it is alive and was checked within 5 minutes; otherwise `hold.checking` until a check |
| 8 | `improve: false` | `hold.working` |
| 9 | Either side unmeasured, or the score gain is below the need | `hold.best` |
| 10 | Last switch within `dwell` | `hold.dwell` |
| 11 | `max-per-hour` switches reached | `hold.flap-limit` |
| 12 | Fewer than `confirm` fresh samples beat the current member by the need | `hold.confirming` |
| 13 | Otherwise | `switch.faster` |

The need is `max(min-gain-ms, score × min-gain-pct / 100, tolerance)`, computed on the current member's score.
`confirm` counts the most recent consecutive fresh samples of the candidate at or below `current score − need`.

### Stranded

| `stranded` | Result |
| --- | --- |
| `hold` (default) | Keep the current member: `stranded.no-candidates`. |
| `direct` | Select `DIRECT`: `switch.stranded`. |
| `group:<name>` | Select the member `<name>` if the group has it: `switch.stranded`. |

### Feel presets

| `feel` | `dwell` | `min-gain-ms` | `min-gain-pct` | `confirm` | `max-per-hour` |
| --- | --- | --- | --- | --- | --- |
| `calm` | 30m | 60 | 30 | 3 | 2 |
| `balanced` (default) | 10m | 30 | 20 | 2 | 4 |
| `eager` | 2m | 15 | 10 | 2 | 8 |

Explicit `switch` fields override the preset.

## Probing

The planner buys only probes that can change a decision. At most 2 run at once, each with a 5-second timeout. A server is
not probed again within 1 minute, except to confirm a failure.

### Modes

The first matching mode applies.

| Mode | When | Allowed |
| --- | --- | --- |
| Stopped | The core is not running | Nothing |
| Sleep | Android Doze | Nothing |
| Background | Screen off | Recovery, only after real dial failures |
| Eco | Metered network, power saving, low battery or on battery | Recovery; needs and maintenance within a window; forced diagnostics |
| Active | Within 10 s of traffic or 30 s of a network change | Everything, including discovery |
| Idle | Otherwise | Recovery |

A window opens for 10 s on traffic and for 30 s on a network change. Needs, maintenance and discovery need an open window
and wait 10 seconds after wake. Diagnostics run in Active, or in Eco after a network change or while a kind awaits
confirmation.

### Budgets

Each group's `energy` sets hourly token buckets. The machine uses the highest level among its groups; any Eco condition
forces `eco`.

| `energy` | Maintain | Discover | Recover | Network | Standby check every |
| --- | --- | --- | --- | --- | --- |
| `eco` | 4 | 0 | 12 | 8 | 2 h |
| `balanced` (default) | 10 | 12 | 24 | 12 | 45 min |
| `precise` | 20 | 40 | 40 | 20 | 30 min |

Each request counts as 6 KiB against a daily cap of 20 MiB. Only user checks and recovery may exceed the cap; user checks
are never rationed.

### Probe kinds

| Kind | What |
| --- | --- |
| Recover | Dead or suspect servers, 4 per pass, with backoff 0, 5, 10, 20, 40 minutes. |
| Need | Pending members, the pinned member, or a better-tier candidate; paid from the discover bucket. |
| Maintain | Two standbys, plus the current member when the profile improves or uses checks or exit country, every standby interval. |
| Discover | Two unmeasured members per window with distinct server addresses; only with `improve: true` and in Active. |
| Extras | Checks and the exit lookup ride on a successful probe, one request each from the same bucket. |
| User | The `check` action: every routable member with all extras. |

## Failure handling

Failures seen while nothing gets through condemn no server.

- The link is proven when anything succeeded within the last minute. A resume or network change resets it.
- A failed probe marks a server dead only when the link is proven and the server failed at least twice in a row.
- A suspect current member is confirmed together with the best standby. If both fail, or there is no standby on an
  unproven link, the journal records `network.suspect` and the server backs off. Only the current member failing marks
  it dead (`failure.confirmed`), which triggers `switch.failover`.

## Direct split

While active, connections that matched an explicit `DIRECT` rule go through the group instead.

- It needs both the profile's `direct-split` condition and the user's toggle on the group; a subscription cannot turn
  it on.
- It never applies to the final `MATCH` rule or to local destinations: private, loopback, link-local, multicast,
  unspecified, `100.64.0.0/10`, and names that resolve only on the LAN. UDP is split only when the group's member
  supports UDP.
- Per-group state: off, standby (core stopped, no members, manual control, paused kind, or condition not true), or
  active. The first active group in order takes the traffic. Transitions are journaled as `split.on` and `split.off`.

## Control

| Action | Effect |
| --- | --- |
| Auto | The decision runs as above; clears a pin. |
| Pin | Holds the chosen member while it works and returns to it when it recovers. The core can limit a pin to the current network; the app pins on every network. |
| Manual | The engine never switches and runs no checks; provider health checks are not suppressed. |
| Change server | Puts the current member on a 15-minute cooldown, clears a pin and forces a switch. |
| Check | One user-bucket probe of every routable member. The core accepts it; the app does not offer it. |

Picking a server by hand in the proxies list pins it (`pin.manual` in the journal) unless the group is in Manual. While a
group is smart and not manual or idle, the engine replaces the automatic health check of every provider that serves its
members.

## Explanations and journal

**Why this server** returns the decision: action, target, reason, tier, the time a hold expires (`until`), and the full
ranking. Each row carries name, tier and label, health, latency, spread, score, episodes, last check, current flag,
exclusion reason, exit country, check results (pass, fail, soft) and the pending tier.

The journal keeps the last 200 entries of kinds `switch`, `stranded`, `change`, `pin`, `auto`, `manual`, `network`,
`mode`, `split` and `failure`. It is saved with the engine state, at most 1 MiB.

## Guarantees

| Guarantee | Statement |
| --- | --- |
| Layers | Provider and user layers only narrow a profile's pool; an invalid profile or unusable group is a visible problem. |
| Consent | A provider profile contacts third-party hosts only after the user allows them; until then the group runs `builtin/simple` and says why. |
| Ladder | An order falls through once every server on a step is down; a last-resort step yields to every other step; a scenario program's order beats the user's, which beats the profile's. |
| Scenario | A scenario sets the tunnel mode only until the user picks one, and drives only the groups it names. |
| Routes | Routes become groups and rules only at config apply, steer traffic only in rule mode, never take over an existing group, and a route that cannot apply is a visible problem. |
| Bundle | An export carries every non-built-in profile it references; an import never replaces a profile the user already has. |
| Thin fork | The mihomo fork carries provider health-check suppression, route fingerprints and direct-split hooks plus minimal safety hooks; policy interpretation stays in the ReClash core. |
