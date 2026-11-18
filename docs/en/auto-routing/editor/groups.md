# Group sheet

The per-group sheet in Proxies: status, control, how the group picks a server, details and messages.

## Sections

Open the sheet from the auto routing action of a select group in **Proxies**, from a group row in [Auto routing](hub.md), or from a group's row under **Groups in this scenario** of the running scenario.

| Section | Content |
| --- | --- |
| Problems | The group's problem; see [Messages](#messages). |
| **Permission needed** | "“{profile}” wants to check these sites", the hosts, **Allow**. Until then the group runs `builtin/simple`. |
| Status | Server, reason, forecast, exit country, tier, network kind, latency. **Change server** cools the current server for 15 minutes and switches; unavailable in Manual. |
| **Control** | **Auto**, **Pinned** or **Manual**; see [Control](#control). A driving scenario adds the footer "The scenario «{scenario}» drives this group now." |
| How the group picks | **Behaviour**, **Server order**, **Servers**, **Switching** and **Check frequency**; see [How the group picks](#how-the-group-picks). |
| **Network** | **Direct sites through this group**, when the behaviour has `direct-split`: **On now** or **Ready: direct sites still open**. |
| **Details** | "{count} servers compared"; opens **Why this server** (top 8 ranking rows) and **History** (last 20 journal entries); see [Explanation](#explanation). |
| **Auto routing settings** | Opens [Auto routing](hub.md). |
| **Made by a route** or **Turn off auto routing for this group** | A route group links to **Edit the route**, which opens the route editor. Otherwise, for a group with the user's own binding, removes it; the group keeps its server. |

Without a binding, the group shows **With auto routing on** (the behaviour it would get, server count) and **Turn on auto routing**, which adds a user binding with the default behaviour.

## Control

| Option | Engine control |
| --- | --- |
| **Auto** | `auto`: the decision runs; clears a pin. |
| **Pinned** | `pin` on the current server, on every network: kept while it works, returned to when it recovers. |
| **Manual** | `manual`: the user selects in the proxies list; the engine never switches and runs no checks. |

Selecting a server by hand in an Auto group pins it. See [Control](../engine.md#control).

## How the group picks

The one place to see and change how a group picks a server. Every row shows where its value comes from: **From scenario «{scenario}»**, **Yours for this group** or **From behaviour «{behaviour}»**. A group held on one member shows only **Through {member}**.

| Row | Edits |
| --- | --- |
| **Behaviour** | `profile`; choose from **Built-in**, **From provider** and **Mine**, or **As set on the group** in a scenario program. |
| **Server order** | `prefer`, via the [step editor](routes.md#server-order). Empty follows the behaviour. |
| **Servers** | The pool; see [Servers](#servers). |
| **Switching** | `feel`: **Rarely** (`calm`), **Balanced**, **Often** (`eager`). |
| **Check frequency** | `energy`: **Economical**, **Balanced**, **Precise**. |

### Where a change is saved

A change goes to the layer that already sets the field: the running scenario's program for this group (or its route), otherwise the user's binding. Under the scenario's **Every group** program (`*`) a changed field creates a program named after the group instead of changing every group. A built-in or provider scenario is copied to **Mine** before the first change. **Switching** and **Check frequency** always go to the binding.

### Servers

The **Servers** row opens **Choose from**; each choice sets `pool.include` and returns a pinned group to Auto.

| Part | Pool |
| --- | --- |
| **Any** | No narrowing. |
| Provider and user chips | The binding's `chips`. |
| Flags | Up to 8 flags found in server names, most common first, when there are at least two. |
| **Name pattern** | Saved as `name ~ /pattern/i`; refused while invalid or matching nothing ("{count} of {total} match"). |

A user chip's context menu deletes it. **Use only servers** and **Leave out servers** below it open the [condition builder](routes.md#conditions).

## Explanation

**Details** opens two sections. Each **Why this server** row shows the server and latency, then its exclusion or its tier and health (**Working**, **Worked before**, **Not checked**, **Not working**), "may reach “{tier}” after a check", "exit {country}", check results (✓ pass, × fail, ~ soft) and the last check time. **History** lists switches, failures, pins and mode changes. Fields: [Explanations and journal](../engine.md#explanations-and-journal).

## Messages

| Text | Code |
| --- | --- |
| Controlled manually | `manual.requested` |
| Holding the pinned server · Switched to the pinned server {node} | `hold.pinned` · `switch.pinned` |
| The scenario holds {node} · The scenario moves to {node} · {node} is not in this group | `hold.fixed` · `switch.fixed` · `fixed.missing` |
| Paused while the network is “{kind}”: nothing is checked or switched | `hold.paused` |
| Not in use: mode {mode} | `hold.idle` |
| No working server in the pool; holding the current one · No working server; fell back to {node} | `stranded.no-candidates` · `switch.stranded` |
| Selected the best available server | `switch.initial` |
| Changed server; {from} is skipped for 15 minutes | `switch.change-server` |
| {from} stopped working; switched to the best standby | `switch.failover` |
| {from} is no longer in the pool | `switch.out-of-pool` |
| No other working server to change to | `hold.no-alternative` |
| This is the best server | `hold.best` |
| Checking a better candidate | `hold.checking` |
| Working; kept until it fails | `hold.working` |
| Switched recently; holding before the next change | `hold.dwell` |
| Switch limit reached ({limit} per hour) | `hold.flap-limit` |
| A faster server needs another measurement | `hold.confirming` |
| Moved to a server in “{tier}” · Switched from {from}: {gain} ms faster | `switch.better-tier` · `switch.faster` |
| Could not select the server | `select.failed` |
| The network looks down; no server is blamed · Network changed | `network.suspect` · `network.changed` |
| Direct sites now go through this group · Direct sites go direct again | `split.on` · `split.off` |
| Not in the pool · Excluded by the behaviour · Not a server · Skipped after “Change server” · Matches no preference · Not checked yet | `pool.no-match` · `pool.excluded` · `pool.unroutable` · `cooldown` · `no-tier` · `pending` |
| Behaviour {profile} was not found; the default is used | `profile.missing` |
| Behaviour error: {error} | `profile.invalid` |
| This group is not a selector in the current config · The group has no servers | `group.unavailable` · `group.empty` |
| The route «{route}» was skipped: a group with its name already exists. | `route.name-taken` |
| The route «{route}» sends traffic to «{to}», which is not in the behaviour. | `route.to-missing` |
| The route «{route}» could not be applied: {error} | `route.invalid` |
| Routing state could not be saved: {error} | `store.failed` |

The forecast line names when the hold ends: "Will switch to {node} once a check confirms it", "May switch to {node} in {minutes} min" or "Will switch to {node} if it stays {gain} ms faster". Unknown codes show as is.
