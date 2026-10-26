# The auto routing hub

The hub is the home of auto routing. Open **Advanced configuration**, then **Auto routing**. It has three tabs, **Overview**, **Routes** and **Library**. Switch tabs with the segmented control at the top or by swiping. The app remembers the last tab. On a wide window the title reads "Auto routing", a bullet, then the tab name.

The three-dot menu at the top right has **New scenario**, **New profile** and **Import**.

> [!NOTE]
> **Screenshot `hub-menu`** — the hub app bar with the three-dot menu open, showing New scenario, New profile and Import.

## Overview tab

The Overview tab answers "what is auto routing doing right now".

> [!NOTE]
> **Screenshot `hub-overview`** — Overview tab with auto routing on, scenario "My split" running, live line, a Routes section and a Smart groups section with the energy footer.

### Before you see anything

| You see | Why | What to do |
| --- | --- | --- |
| **No subscription** with "Add a subscription first; auto routing works with its groups." | No profile is selected. | Add a subscription. |
| **Start the connection to see auto routing** | The Core is not running, so no live data exists. | Start the connection. |

> [!NOTE]
> **Screenshot `hub-no-subscription`** — the Overview tab in the "No subscription" state.

### Turn auto routing on

1. Open **Auto routing**, tab **Overview**.
2. Switch **Auto routing** on.

What happens: the scenario you picked last starts. If you never picked one, the built-in scenario **Every group** starts, which makes every select group of the subscription smart. While the switch is off the footer reads "Turn on to let a scenario pick servers for your groups and routes."

> [!NOTE]
> **Screenshot `hub-overview-off`** — Overview with the master switch off and its hint.

If the scenario has a problem (for example it needs your permission), the footer of the switch shows the problem text instead.

### Choose a scenario

The scenario card shows the running scenario's title and description. Tap **Change**.

> [!NOTE]
> **Screenshot `scenario-chooser`** — the scenario sheet with sections Mine, From provider and Built-in, each with titles and descriptions, "My split" selected.

The sheet groups scenarios by source.

| Section | Contents |
| --- | --- |
| **Mine** | Scenarios you made or saved as copies. |
| **From provider** | Scenarios your subscription offers. |
| **Built-in** | Scenarios that ship with ReClash, such as Every group. |

Tap one to run it. Choosing a scenario never changes it; to change one see [Make your own copy](#make-your-own-copy).

### The live line

Under the card a line reads **Network: <kind> · Mode: <mode>**. The subtitle says who sets the mode now:

| Subtitle | Meaning |
| --- | --- |
| The scenario sets the mode on this network | The scenario picked the mode. |
| The mode is yours on this network | The scenario leaves the mode to you. |
| You chose the mode yourself; the scenario waits until you pick Auto | You overrode the mode by hand. |

When you overrode the mode, a row **Back to auto** ("Give the mode back to the scenario") appears. Tap it to let the scenario decide again. The live line is hidden when the scenario has a problem.

### Rows: Routes and Smart groups

**Routes** lists one row per route of the running scenario. The subtitle shows:

- the route's problem, if any (see [troubleshooting](troubleshooting.md));
- **Direct** for a direct route, or the target for a fixed route;
- otherwise the current server, its country (when the name has no flag), its latency and its step.

Tap a route row to open its [group sheet](groups.md) (not for direct or fixed routes, which have no group).

**Smart groups** lists the other groups auto routing drives, with the same subtitle. Its footer is the energy line, **Checks today: {requests} · {used} of {cap}**, once checks were made, otherwise "No group is driven by auto routing yet." The energy line shows how many probe requests auto routing spent today against its daily cap.

> [!NOTE]
> **Screenshot `hub-groups-energy`** — the Smart groups section with several rows and the "Checks today" footer.

### Consent

If the scenario or a profile wants to contact sites, a section **Needs your permission** appears at the top. See [groups.md#consent](groups.md#consent).

## Routes tab

The Routes tab edits the running scenario's routes.

> [!NOTE]
> **Screenshot `hub-routes`** — Routes tab for "My split": four routes, an Add route row, Everything else, Other groups, Networks.

### Empty states

| State | Shows | Action |
| --- | --- | --- |
| No scenario is running | **No scenario is running**: "Routes send chosen traffic, such as one service, through its own servers." | **Start a scenario** creates a new scenario of yours (titled "New scenario") and starts it. |
| Not in rule mode | Warning: "Routes apply in rule mode; the connection is in {mode} mode now." | Switch the connection to rule mode. |

> [!NOTE]
> **Screenshot `hub-routes-off`** — Routes tab with "No scenario is running" and the Start a scenario button.

> [!NOTE]
> **Screenshot `hub-routes-rule-only`** — Routes tab footer with the rule-mode warning while the connection is in global mode.

### Route cards

Under **Routes** each route shows its name, a short summary of its traffic (hidden when the name already says it), and its server setup (a summary such as "Direct", "Through X", or a server order). The footer says: "Traffic takes the first route it matches, top to bottom."

| Control | What it does |
| --- | --- |
| Tap a route | Opens the [route editor](routes.md#the-route-editor). |
| Long-press (right-click on desktop) | Menu with **Edit** and **Delete**. |
| **Add route** row | Starts the [add-a-route flow](routes.md#add-a-route-for-one-service). |
| Sort action in the header (shown with two or more routes) | Switches the list to reorder mode; drag rows, then leave reorder mode. |

Order matters: when a connection matches two routes, the higher one wins.

> [!NOTE]
> **Screenshot `hub-routes-reorder`** — Routes list in reorder mode with drag handles.

### Everything else

One row for traffic no route matched. The caption says: "Traffic no route matched goes through the subscription’s main group." The row names the main group (or "Main group") and shows either "Group's own profile" or a summary of the order you set. Tap it to give the main group its own behaviour and server order. In "My split" this is where "main traffic Norway" is set.

> [!NOTE]
> **Screenshot `hub-everything-else`** — Everything else row and its editor with a single step "Country Norway".

### Other groups

**Other groups** ("Groups of the subscription this scenario also drives.") holds rules for named groups and for **Every group** (the `*` rule). Use the **Add group** popup to add a rule for a group or for all remaining groups; long-press a row for **Delete**. In the editor it works exactly like the route editor's server order, but without traffic.

> [!NOTE]
> **Screenshot `hub-other-groups`** — Other groups section with one row for "Every group" and the Add group popup.

### Networks

The collapsible **Mode and networks** row ("What this scenario does" in the subtitle) contains:

| Item | Meaning |
| --- | --- |
| **Connection mode** | Whether the scenario changes the mode: leave as is, rule, global or direct. |
| Network kinds | Named kinds of network (for example "home"). Each has a **Recognized when** condition, a mode for that network and group rules. |
| **Add network kind** | Lowercase Latin letters, digits and dashes, up to 24 characters. |
| **Tags** | Names for sets of servers, used in steps as `tag(name)`. Letters, digits, `-` and `_`, up to 24. |
| **Advanced** | Network diagnostics and translations; read-only here: "These parts are edited as YAML." |

See [scenarios.md](../scenarios.md) for the text form.

> [!NOTE]
> **Screenshot `hub-networks`** — the Networks section expanded with Connection mode, one network kind, Tags and Advanced.

### Make your own copy

Built-in and provider scenarios cannot be changed. The first time you edit one (for example by adding a route), ReClash asks:

> **Make your own copy?** "“{title}” is not yours to change. Your edits go to a copy, and the copy becomes the running scenario."

Choose **Make a copy**. The copy goes to **Mine**, runs from now on, and keeps a link to its origin so you can later [bring changes over](studio.md#bring-changes-from-the-original).

> [!NOTE]
> **Screenshot `copy-dialog`** — the "Make your own copy?" dialog with the Make a copy button.

### Autosave and versions

Edits to your own scenario are saved as soon as they are valid. The app keeps the scenario's last 10 versions with it, but only the profile studio offers to restore one ([studio.md#history-and-restore](studio.md#history-and-restore)). A route change causes one profile re-apply a moment after your last edit.

## Library tab

> [!NOTE]
> **Screenshot `hub-library`** — Library tab, Scenarios filter, cards with Built-in, From provider and Mine badges, "My split" selected.

A segmented filter switches between **Scenarios** and **Group profiles**.

| Filter | Hint |
| --- | --- |
| Scenarios | "A scenario drives the whole connection. Tap one of yours to edit it, any other to edit a copy." |
| Group profiles | "How a smart group picks its server. Tap one of yours to edit it, any other to edit a copy." |

### Cards

Each card shows a title, a description (or its error if the file is broken) and chips:

| Chip | Where |
| --- | --- |
| **Built-in**, **From provider**, **Mine** | All cards: where the entry comes from. |
| **Simple**, **Advanced** | Group profiles: how many knobs the profile exposes. |
| **Needs your permission** | Entries that want to contact sites you have not allowed yet. |

The running scenario shows a check mark.

### Tapping and the context menu

Tap a card of yours to edit it in place. Tap any other card to open the editor on a copy; the copy is created when you save.

Long-press (right-click on desktop) for the menu:

| Item | Available for | What it does |
| --- | --- | --- |
| **Edit** | Mine | Opens the editor. |
| **Duplicate and edit** | All | Makes your own copy and opens it. |
| **Export** | All | Opens [export](sharing.md#export). |
| **Delete** | Mine | Asks "Delete “{profile}”?" and removes it. |

> [!NOTE]
> **Screenshot `library-menu`** — a Mine card with its context menu open (Edit, Duplicate and edit, Export, Delete).

### New scenario, new profile, import

Use the three-dot menu. **New scenario** opens the scenario editor with an empty setup; **New profile** opens the [studio](studio.md); **Import** opens [import](sharing.md#import).

## The scenario editor

A scenario opened from the Library shows a page with the same sections as the Routes tab, preceded by:

- a title field (hint "New scenario");
- a description field (hint "What this scenario does").

Below the sections: **Warnings** and **Sites it contacts**. The top bar has a save check (disabled while there are errors or nothing changed) and a menu with **YAML** (edit as text), **Export** and **Delete**.

> [!NOTE]
> **Screenshot `scenario-editor`** — scenario editor for "My split" with title, description, routes and the YAML menu.

## Turn auto routing off

### The whole subscription

1. Open **Auto routing**, tab **Overview**.
2. Switch **Auto routing** off.

The running scenario is cleared. Groups go back to being plain select groups; servers you had are kept as they are. Your scenarios stay in the Library.

### One group

1. Open Proxies and tap the group, then open its auto routing sheet.
2. Scroll to the bottom and tap **Turn off auto routing**.

This removes the group's own binding. It is shown only for groups you made smart yourself, not for groups the scenario drives. See [groups.md#turn-auto-routing-off-for-one-group](groups.md#turn-auto-routing-off-for-one-group).

### One route

1. Open the **Routes** tab.
2. Long-press the route, choose **Delete**.

The route and its group disappear; its traffic falls through to the next matching route or **Everything else**.

> [!NOTE]
> **Screenshot `route-delete-menu`** — the context menu of a route with Edit and Delete.

## Walkthrough: build "My split" from an empty state

The goal setup (see the [demo setup](../images/README.md#demo-setup)):

- main traffic: Norway;
- YouTube: ⚡ RU servers, any server if none;
- Claude: Sweden;
- Gemini: any server with `*` in its name;
- Local: direct for the `category-ru` site category and for `yandex`.

1. Open **Advanced configuration**, **Auto routing**, tab **Routes**. You see **No scenario is running**.
2. Tap **Start a scenario**. A scenario "New scenario" of yours starts.
3. Tap **Add route**. (You will rename the scenario to "My split" at the end.)
4. In the picker choose the chip **YouTube**, tap **Next**. The name field is pre-filled with "YouTube" and its emoji. Keep it, leave **Send through** on **Auto**.
5. Under **Server order** tap **Add a step**. Under **Servers in this step** tap **Name contains** and type `⚡ RU`. Tap the check. The footer shows how many servers fit now.
6. Tap **Add a step** again, leave every field empty: the step reads **Any working server**. Save the route.
7. Tap **Add route** and choose **Gemini**. Rename it "✨ Gemini". Add one step with **Name contains** `*`; the star is literal, not a wildcard.
8. Tap **Add route**. Pick no chip; instead tap **Add entry**, choose **Site category**, type `category-ru`. Add another entry, **Domain and subdomains**, `yandex.ru`. Tap **Next**, name it "🏠 Local", set **Send through** to **Direct**.
9. Add a route for Claude: chip **Claude** (rename to "🤖 Claude"), one step with **Country** set to Sweden.
10. Reorder with the sort action so the order is as you want it. Specific routes belong above broader ones.
11. Open **Everything else**, add a step with **Country** Norway.
12. Open **Library**, tap the scenario "New scenario", type the title `My split` and a description, and save.
13. Check **Overview**: the routes show their current servers.

> [!NOTE]
> **Screenshot `walk-1-empty`** — Routes tab with "No scenario is running".

> [!NOTE]
> **Screenshot `walk-2-youtube-step`** — the step editor with Name contains "⚡ RU" and the "N servers fit now" footer.

> [!NOTE]
> **Screenshot `walk-3-done`** — Routes tab with all four routes and Everything else showing Norway.

Text form of the same setup: [scenarios.md#routes](../scenarios.md#routes).
