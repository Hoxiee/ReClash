# Auto routing screen

The Auto routing page: the switch, the running scenario with its routes, the smart groups, and the library with import and export.

## Entry points

| Place | Path | Edits |
| --- | --- | --- |
| Auto routing | **Tools** → **Auto routing** | The scenario, its routes, the groups, the library. |
| Group sheet | **Proxies** → a group → auto routing | One group's control, pool and behaviour; see [Group sheet](groups.md). Its **Auto routing settings** row and **Edit the route** open Auto routing. |
| Route editor | Auto routing → **Routes** → a route | One route; see [Route editor](routes.md). |
| Studio | Auto routing → **Library** → **Behaviours** → a card | One behaviour; see [Studio](studio.md). |

Auto routing is one screen without tabs. From top to bottom: the permission card, the switch and the running scenario, the mode, the running scenario's **Routes** and **More**, the **Groups**, and a **Library** row.

> [!NOTE]
> **Screenshot `editor-map`** — Auto routing, the group sheet and the route editor, linked by arrows

## States

| State | Shown |
| --- | --- |
| No subscription is selected | **No subscription** |
| The core is not running | **Start the connection to see auto routing** |
| Otherwise | The sections below |

> [!NOTE]
> **Screenshot `hub-no-subscription`** — Auto routing in the No subscription state

## Switch and scenario

| Row | Meaning |
| --- | --- |
| **Permission needed** | A card at the top, shown while a provider scenario waits for permission: it contacts hosts the user has not allowed; see [Consent](../sharing.md#consent). |
| **Auto routing** | On runs the last chosen scenario, or `builtin/every-group` if none was ever chosen. Off stops the scenario and keeps the choice. The footer shows the scenario's problem. |
| Scenario | Title and description of the running scenario. **Change** opens the quick switch sheet (**Mine**, **From provider**, **Built-in**); choosing one runs it unchanged. |
| **Mode: {mode}** | The tunnel mode, the network kind, and who holds it: the scenario, the user, or the user overriding the scenario. |
| **Give the mode back to the scenario** | Shown while the user's mode overrides the scenario's; returns the mode to the scenario. |

Without a running scenario the screen shows only the switch, the **Groups** and the **Library** row.

> [!NOTE]
> **Screenshot `hub-overview`** — auto routing on, «My split» running, mode row, Routes, Groups

> [!NOTE]
> **Screenshot `scenario-chooser`** — Mine, From provider, Built-in; «My split» selected

> [!NOTE]
> **Screenshot `hub-routes-off`** — auto routing off: the switch, Groups and the Library row

## Running scenario

The sections below edit the running scenario.

> [!NOTE]
> **Screenshot `hub-routes`** — «My split»: routes, Add route, Everything else, More

### Routes

| Row | Content |
| --- | --- |
| A route | Where the route's traffic goes now: its problem, `Direct` or the fixed target, or the current server, exit country, latency and step. A group route opens its group sheet; a direct or fixed route opens the route editor. Top to bottom; traffic takes the first match. The context menu has **Edit** and **Delete**. The sort action reorders. |
| **Add route** | Creates a route; see [Route editor](routes.md). |
| **Everything else** | The program of `$main`: the group the final rule sends traffic to. **As set on the group** means no program. |

While the tunnel mode is not `rule`, the footer reads "Routes apply in rule mode; the connection is in {mode} mode now."

### More

| Row | Content |
| --- | --- |
| **Connection mode** | The scenario's `mode`; **Don't change** leaves it to the user. |
| **Groups in this scenario** | Programs for named groups and **Every group** (`*`); **Add group** adds one. |
| **Network kinds** | **Name**, **Recognized when**, **On this network** (mode), **Groups**; **Add network kind**. **Advanced** shows diagnostics and translations, edited as YAML. |
| **Tags** | Scenario tags; **Add tag**. |

> [!NOTE]
> **Screenshot `hub-routes-rule-only`** — footer with the rule-mode warning in global mode

> [!NOTE]
> **Screenshot `hub-routes-reorder`** — reorder mode with drag handles

> [!NOTE]
> **Screenshot `hub-everything-else`** — one step, Country Norway

> [!NOTE]
> **Screenshot `hub-other-groups`** — Every group row and the Add group popup

> [!NOTE]
> **Screenshot `hub-networks`** — one network kind, its mode and groups

### Saving

Edits to the user's own scenario save once they have no errors. A route change re-applies the subscription once; other edits apply live. A built-in or provider scenario is read-only: the first edit asks **Edit a copy?**. **Edit a copy** saves a copy to **Mine**, linked to its original, and runs it.

> [!NOTE]
> **Screenshot `copy-dialog`** — the Edit a copy? dialog

## Groups

The smart groups the engine drives, each with the same status line as a route; each opens its group sheet. The footer reads **Checks today: {requests} · {used} of {cap}**: probe requests today and the data they used against the daily cap.

> [!NOTE]
> **Screenshot `hub-groups-energy`** — Groups with several rows and the Checks today footer

## Library

The last row, **Library** ("Scenarios, behaviours and import"), opens the library page. It starts with **New scenario**, **New behaviour** and **Import**, then a **Scenarios** | **Behaviours** switch and the list. Cards show the source chip (**Built-in**, **From provider**, **Mine**), **Simple** or **Advanced** for a behaviour, and **Needs your permission** when consent is missing.

| Action | Scenario | Behaviour |
| --- | --- | --- |
| Tap | Runs it | Opens the studio: the user's own in place, any other as a copy |
| Pencil | Edits the user's own, or opens a copy of any other | — |
| **Edit** | Mine only | Mine only |
| **Edit a copy** | Opens a copy | Opens a copy |
| **Export** | See [Import and export](#import-and-export) | Same |
| **Delete** | Mine only, after "Delete “{profile}”?" | Same |

A copy is saved when the editor saves it.

> [!NOTE]
> **Screenshot `hub-library`** — Scenarios filter and cards of every source

> [!NOTE]
> **Screenshot `library-menu`** — a Mine card with Edit, Edit a copy, Export and Delete

### Scenario editor

Holds **Name**, a description ("What this scenario does"), the **Routes** and **More** sections, **Warnings** and **Sites contacted**. The menu has **YAML**, **Export** and **Delete**; save is disabled while there are errors or no changes.

> [!NOTE]
> **Screenshot `scenario-editor`** — «My split» with name, description, routes and menu

## Import and export

**Export** offers **Export to clipboard**, **Copy link** and **Export file**. **Import** offers **Import from clipboard** and **Import from file**; a `reclash://routing` link opens the same review. Formats and naming are in [Sharing](../sharing.md).

> [!NOTE]
> **Screenshot `export-sheet`** — the three export actions

The review page **Import auto routing** shows the item (or **In this file** for a bundle), **What it picks in {group}** (what a single behaviour would pick in the current group), **Sites contacted** and **Warnings**. The check needs the core; without it the page reads "Start the app's core to check this file." and adds nothing. **Add to my library** is disabled while there are errors. It saves every item; nothing runs until the user chooses.

> [!NOTE]
> **Screenshot `import-page`** — the review of one scenario

> [!NOTE]
> **Screenshot `import-bundle`** — a bundle with a scenario and two behaviours

> [!NOTE]
> **Screenshot `import-problems`** — an error, with Add to my library disabled
