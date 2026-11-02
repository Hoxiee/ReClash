# Group sheet

The per-group sheet in Proxies: status, control, pool, behaviour, explanation, history and messages.

## Sections

Open the sheet from the auto routing action of a select group in **Proxies**, or from a group row in the hub.

| Section | Content |
| --- | --- |
| Problems | The group's problem; see [Messages](#messages). |
| **Permission needed** | "“{profile}” wants to check these sites", the hosts, **Allow**. Until then the group runs `builtin/simple`. |
| Status | Server, reason, forecast, exit country, tier, network kind, latency. **Change server** cools the current server for 15 minutes and switches; unavailable in Manual. |
| **Control** | **Auto**, **Pinned** or **Manual**; see [Control](#control). |
| **Choose from** | One-tap pools; see [Choose from](#choose-from). Hidden when held on one member. |
| **Behaviour** | Profile opens the chooser (**Built-in**, **From provider**, **Mine**); also **Server order** and **Group settings**. A driving scenario adds the footer "The scenario «{scenario}» drives this group now." |
| **Why this server** | "{count} servers compared"; expands to the top 8 ranking rows. |
| **History** | Newest journal entry; expands to the last 20. |
| **Auto routing settings** | Opens the hub. |
| **Made by a route** or **Turn off auto routing for this group** | A route group links to **Edit the route**. Otherwise, for a group with the user's own binding, removes it; the group keeps its server. |

Without a binding, the group shows **With auto routing on** (the profile it would get, server count) and **Turn on auto routing**, which adds a user binding with the default profile.

> [!NOTE]
> **Screenshot `group-sheet-auto`** — Auto group: status, Control, Choose from, Behaviour

> [!NOTE]
> **Screenshot `group-intro`** — no auto routing, with Turn on auto routing

> [!NOTE]
> **Screenshot `group-consent`** — Permission needed, hosts, Allow

> [!NOTE]
> **Screenshot `group-route`** — the «▶️ YouTube» sheet, Made by a route

## Control

| Option | Engine control |
| --- | --- |
| **Auto** | `auto`: the decision runs; clears a pin. |
| **Pinned** | `pin` on the current server, on every network: kept while it works, returned to when it recovers. |
| **Manual** | `manual`: the user selects in the proxies list; the engine never switches and runs no checks. |

Selecting a server by hand in an Auto group pins it. See [Control](../engine.md#control).

> [!NOTE]
> **Screenshot `group-sheet-pinned`** — Control Pinned, Holding the pinned server

## Choose from

Each chip sets `pool.include` of the user's binding and returns a pinned group to Auto.

| Chip | Pool |
| --- | --- |
| **Any** | No narrowing. |
| Provider and user chips | The binding's `chips`. |
| Flags | Up to 8 flags found in server names, most common first, when there are at least two. |
| **Add a pattern** | **Name pattern**, saved as `name ~ /pattern/i`; refused while invalid or matching nothing ("{count} of {total} match"). |

A user chip's context menu deletes it.

> [!NOTE]
> **Screenshot `group-change-to`** — Any, 🇳🇴, 🇸🇪, 🇷🇺 and one pattern

## Behaviour

| Row | Edits |
| --- | --- |
| Profile | The binding's `profile`. |
| **Server order** | The binding's `prefer`, via the [step editor](routes.md#server-order). Empty follows the profile; a scenario program's order comes first. |
| **Group settings** → **Servers** | **Name pattern**: `pool.include`, as above. |
| **Group settings** → **Behaviour** | **Switching**: `feel` **Rarely** (`calm`), **Balanced**, **Often** (`eager`). **Checks**: `energy` **Economical**, **Balanced**, **Precise**. |
| **Group settings** → **Network** | **Direct sites through this group** (when the profile has `direct-split`): **On now** or **Ready: direct sites still open**. |

> [!NOTE]
> **Screenshot `group-behaviour`** — Fastest, Server order, Group settings

> [!NOTE]
> **Screenshot `group-settings`** — pattern, Switching, Checks, Direct sites

## Explanation

Each **Why this server** row shows the server and latency, then its exclusion or its tier and health (**Working**, **Worked before**, **Not checked**, **Not working**), "may reach “{tier}” after a check", "exit {country}", check results (✓ pass, × fail, ~ soft) and the last check time. **History** lists switches, failures, pins and mode changes. Fields: [Explanations and journal](../engine.md#explanations-and-journal).

> [!NOTE]
> **Screenshot `group-why`** — Why this server, with a Skipped after «Change server» row

> [!NOTE]
> **Screenshot `group-history`** — History with a failover and a pin

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
| The route «{route}» sends traffic to «{to}», which is not in the profile. | `route.to-missing` |
| The route «{route}» could not be applied: {error} | `route.invalid` |
| Routing state could not be saved: {error} | `store.failed` |

The forecast line names when the hold ends: "Will switch to {node} once a check confirms it", "May switch to {node} in {minutes} min" or "Will switch to {node} if it stays {gain} ms faster". Unknown codes show as is.
