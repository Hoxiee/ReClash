# The group sheet

The group sheet is where you watch and control one group. It lives in **Proxies**: select a group (only select groups have it) and tap the **Auto routing** button in the app bar, or use the same action on the group's row. It is also opened from rows in the hub. The sheet title is the group name.

Sections, top to bottom (some appear only when they have something to show):

1. Problems, as red lines (for example a missing profile).
2. **Permission needed**, when the profile waits for your consent.
3. The status card and **Change server**.
4. **Control**.
5. **Change to**.
6. **Behaviour**.
7. **Why this server**.
8. **History**.
9. **Auto routing settings**.
10. **Made by a route**, or **Turn off auto routing for this group**.

> [!NOTE]
> **Screenshot `group-sheet-auto`** — group sheet of the main group in Auto control: status card, Control, Change to chips, Behaviour section.

## A group that is not yet smart

A group without auto routing shows a short explanation, a section **With auto routing on** (the default profile with its description, and the server count) and a filled button.

1. Open the group sheet.
2. Read the hint: "ReClash keeps a working server selected in this group and switches when it fails. Checks run only while you use the network."
3. Tap **Turn on auto routing**.

What happens: the group gets its own binding with the default profile. To undo, see [turn auto routing off for one group](#turn-auto-routing-off-for-one-group).

> [!NOTE]
> **Screenshot `group-intro`** — the sheet of a group without auto routing, with the Turn on auto routing button.

## Status card

The top card shows:

| Part | Meaning |
| --- | --- |
| Server name | The current server, with its flag in front if the name lacks one. |
| Reason line | Why this server is selected, for example "Working; kept until it fails". Codes are in [troubleshooting.md](troubleshooting.md#reasons-on-the-status-card). |
| Forecast line | What may happen next, such as "May switch to {node} in {minutes} min", "Will switch to {node} once a check confirms it" or "Will switch to {node} if it stays {gain} ms faster". |
| Details | Country name, step name, and "Network: {kind}", joined with "·". |
| Latency | Right side, in ms, when known. |
| **Change server** | Button under the card. Switches to the best other server and skips the current one for 15 minutes. Disabled in Manual. |

## Control: Auto, Pinned, Manual

**Control** is a three-way segmented control. The footer under it explains the chosen option.

| Option | Footer hint | What happens |
| --- | --- | --- |
| **Auto** | Picks the best working server in the server order and switches when it fails. | The behaviour decides. |
| **Pinned** | Stays on {node}; leaves it only when it fails and comes back when it recovers. | Pins the server in use now (it needs a current server). If it fails, auto routing leaves it, and returns when it works again. |
| **Manual** | You pick the server in the proxies list; auto routing never switches it. | You select servers in the group list. Auto routing keeps watching only. |

To return to Auto, tap **Auto**. Picking a pool in **Change to** while pinned also returns to Auto.

> [!NOTE]
> **Screenshot `group-sheet-pinned`** — Control set to Pinned with "Holding the pinned server" on the status card.

## Change to

Hidden when the group is fixed on one member (the behaviour row then reads "Through {member}"). One tap narrows the group to a pool of servers and switches to its best server. The chips and the plus button are disabled in Manual.

| Control | What it does |
| --- | --- |
| **Any** chip | No narrowing. |
| Chips | Pools offered by the provider, pools of yours, and flags found in server names. Flag chips appear only when servers come from two or more countries; the most common flags come first, at most 8. |
| **Add a pattern** (plus button) | Asks for a **Name pattern** (a regular expression, matched case-insensitively against server names). The dialog warns "{count} of {total} match" and does not accept a pattern that matches nothing or is not valid. The new chip is selected at once. |
| Long-press (or right-click) a chip of yours | **Delete**. Provider and flag chips have no menu. |

> [!NOTE]
> **Screenshot `group-change-to`** — Change to with chips Any, 🇳🇴, 🇸🇪, 🇷🇺 and one custom pattern.

## Behaviour section

| Row | Opens |
| --- | --- |
| Profile row (title, then its description or its level, **Simple** or **Advanced**) | The **Profile** chooser, with sections **Built-in**, **From provider** and **Mine**. Each profile shows its description and, if it waits on consent, "Needs your permission". A provider group lists only what the provider offers. A footer says profiles are made in Advanced configuration → Auto routing. |
| **Server order** | The group's own server order page (hidden when the group is fixed on one member). The subtitle is a summary such as "1 ⚡ RU → 2 Any working server". See [the server order page](#server-order-page). |
| **Group settings** | The [settings page](#settings-page), subtitle "Switching: … · Checks: …". |

The section footer carries the problem of the profile, if it has one, and, while a scenario drives the group: "The scenario «{scenario}» drives this group now." The profile row then also names the scenario's program for the group (for example the main group or every group) when it differs from the group's own name.

Server-order precedence, strongest first: the scenario's order for the group, the order you set on the group, the profile's order. A last-resort step yields to every other step, even one below it.

> [!NOTE]
> **Screenshot `group-behaviour`** — Behaviour section with the Fastest profile, Server order summary and the settings row.

## Server order page

The page is titled **Server order**; its header is the group name. It edits the group's own order with the same [step editor](routes.md#the-server-order-editor) as routes.

- With no steps of your own, the page shows the profile's steps greyed out, with "From the behaviour — edit a step to make the order your own". Editing or adding a step starts from a copy of them. Delete all steps to follow the profile again.
- Each row has a number badge, the step label or condition, "Last resort" when set, and how many servers it takes ("{count} servers"; red at 0). The badge of the step the current server falls in is highlighted.
- A caption "if none of them works" links step 1 to step 2.
- The plus button (**Add a step**) adds a step. With two or more steps a sort button lets you drag to reorder. Long-press (or right-click) a step for **Delete**.
- Footer: "This order is for this group only. Leave it empty to follow the profile’s order." While a scenario drives the group it reads instead: "A scenario drives this group now: a server order the scenario gives it comes before this one."

## Settings page

> [!NOTE]
> **Screenshot `group-settings`** — settings page with Name pattern "4 of 5 match", Switching Balanced, Checks Economical, and the direct-sites switch.

| Section | Control | Notes |
| --- | --- | --- |
| **Servers** | **Name pattern** | A regular expression (hint "Any"), applied on Enter and only when valid. Empty means any server. The footer shows "{count} of {total} match" or "The pattern is not a valid regular expression". |
| **Behaviour** | **Switching** | **Rarely**, **Balanced**, **Often**. How eager the group is to leave a working server for a better one. |
| | **Checks** | **Economical**, **Balanced**, **Precise**. How many probe requests it may spend. |
| **Network** | **Direct sites through this group** | "When sites your rules send direct stop opening, they go through this group. Local addresses always stay direct." Shown only when the group supports it. After switching it on, a row shows **On now** or **Ready: direct sites still open**. |

## Why this server and History

**Why this server** is a fold row, shown when the engine has a ranking. Collapsed, it reads "{count} servers compared"; open it to see up to 8 servers. Each row shows the server and its latency; the current server is highlighted. The line under the name joins:

- either the reason the server is out, or its step and health;
- "may reach “{tier}” after a check", when a check could lift it;
- "exit {flag} {code}", the verified exit country;
- check results, each with a mark: ✓ passed, × failed, ~ soft;
- how long ago it was checked.

A server that is out has one of these reasons: Not in the pool, Excluded by the profile, Not a server, Skipped after “Change server”, Matches no preference, Not checked yet. Health shows as **Working**, **Worked before**, **Not checked** or **Not working**.

> [!NOTE]
> **Screenshot `group-why`** — Why this server expanded with five rows including a "Skipped after Change server" row.

**History** is a fold row shown once there is at least one event. Collapsed, it shows the newest event; open it for the last 20, newest first, each with its age. Entries:

- switches: "{from} → {to}: reason";
- failures: "{node} stopped working";
- pins: "Pinned: {node}";
- mode changes: "Mode {from} → {to}".

> [!NOTE]
> **Screenshot `group-history`** — History expanded with a failover and a pin entry.

## Auto routing settings

The row **Auto routing settings** ("Profiles, scenarios and routes") closes the sheet and opens the [hub](hub.md). Opened from the hub, it only closes the sheet.

## Consent

Some profiles want to contact sites to run checks. Until you allow it, the group runs Simple.

1. Open the group sheet. At the top, a section **Permission needed** reads "“{profile}” wants to check these sites" and lists the hosts under it.
2. Tap **Allow**.

Footer: "Until you allow it, the group runs the Simple profile. The sites are contacted only through your servers or to test the network."

The hub shows the same section for a scenario; see [hub.md](hub.md#consent).

> [!NOTE]
> **Screenshot `group-consent`** — Permission needed section with hosts and the Allow row.

## Route groups

A group created by a route shows a section **Made by a route** instead of the turn-off row. Its row **Edit the route** reads "A route in the scenario «{scenario}» created this group. Edit or remove it there." and has a disclosure chevron. Tapping it closes the sheet and opens the hub's Routes tab (Advanced configuration → Auto routing) at that route, where you edit it.

> [!NOTE]
> **Screenshot `group-route`** — sheet of the group "▶️ YouTube" with the Made by a route section.

## Turn auto routing off for one group

1. Open the group sheet.
2. Scroll to the bottom and tap **Turn off auto routing for this group** (red).

It removes the group's own binding. The footer says: "The group keeps its current server and stops switching on its own." The row is shown only for a group that has a binding of its own, and never for a route group. If a scenario still drives the group, change the scenario instead ([hub.md#turn-auto-routing-off](hub.md#turn-auto-routing-off)).
