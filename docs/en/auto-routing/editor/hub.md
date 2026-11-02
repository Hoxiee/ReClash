# Hub

The auto routing hub: the running scenario, its routes and groups, the library, and import and export.

## Entry points

| Place | Path | Edits |
| --- | --- | --- |
| Hub | **Advanced configuration** → **Auto routing** | The scenario, its routes, the library. |
| Group sheet | **Proxies** → a group → auto routing | One group's control, pool and behaviour; see [Group sheet](groups.md). |
| Route editor | Hub → **Routes** → a route | One route; see [Route editor](routes.md). |
| Studio | Hub → **Library** → **Behaviours** → a card | One behaviour (profile); see [Studio](studio.md). |

The hub has three tabs, **Overview**, **Routes** and **Library**, switched by the segmented control or a swipe.

> [!NOTE]
> **Screenshot `editor-map`** — the hub, group sheet and route editor, linked by arrows

## Overview

| State | Shown |
| --- | --- |
| No subscription is selected | **No subscription** |
| The core is not running | **Start the connection to see auto routing** |
| Otherwise | The rows below |

> [!NOTE]
> **Screenshot `hub-no-subscription`** — Overview in the No subscription state

| Row | Meaning |
| --- | --- |
| **Permission needed** | The running provider scenario contacts hosts the user has not allowed; see [Consent](../sharing.md#consent). |
| **Auto routing** | On runs the last chosen scenario, or `builtin/every-group` if none was ever chosen. Off stops the scenario and keeps the choice. The footer shows the scenario's problem. |
| Scenario | Title and description. **Change** opens the chooser (**Mine**, **From provider**, **Built-in**); choosing one runs it unchanged. |
| **Mode: {mode}** | The tunnel mode, the network kind, and who holds it: the scenario, the user, or the user overriding the scenario. |
| **Give the mode back to the scenario** | Shown while the user's mode overrides the scenario's; returns the mode to the scenario. |
| **Routes** | One row per route: its problem, `Direct` or the fixed target, or the current server, exit country, latency and tier. A group route opens its group sheet; a direct or fixed route opens the route editor. |
| **Groups** | Other groups the engine drives, same line; each opens its group sheet. |

The **Groups** footer reads **Checks today: {requests} · {used} of {cap}**: probe requests today and the data they used against the daily cap.

> [!NOTE]
> **Screenshot `hub-overview`** — auto routing on, «My split» running, mode row, Routes, Groups

> [!NOTE]
> **Screenshot `scenario-chooser`** — Mine, From provider, Built-in; «My split» selected

> [!NOTE]
> **Screenshot `hub-groups-energy`** — Groups with several rows and the Checks today footer

## Routes

The Routes tab edits the running scenario. Without one, it shows **No scenario is running** and **Start a scenario**, which saves and runs a blank scenario of the user's own.

> [!NOTE]
> **Screenshot `hub-routes-off`** — No scenario is running, Start a scenario

> [!NOTE]
> **Screenshot `hub-routes`** — «My split» Routes tab: routes, Add route, Everything else, More

| Section | Content |
| --- | --- |
| **Routes** | Top to bottom; traffic takes the first match. Tap opens the [route editor](routes.md); the context menu has **Edit** and **Delete**. The sort action reorders; **Add route** creates one. |
| **Everything else** | The program of `$main`: the group the final rule sends traffic to. **As set on the group** means no program. |
| **More** → **Connection mode** | The scenario's `mode`; **Don't change** leaves it to the user. |
| **More** → **Subscription groups** | Programs for named groups and **Every group** (`*`); **Add group** adds one. |
| **More** → **Special networks** | Network kinds: **Name**, **Recognized when**, **On this network** (mode), **Groups**; **Add network kind**. **Advanced** shows diagnostics and translations, edited as YAML. |
| **More** → **Tags** | Scenario tags; **Add tag**. |

While the tunnel mode is not `rule`, the footer reads "Routes apply in rule mode; the connection is in {mode} mode now."

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

Edits to the user's own scenario save once they have no errors. A route change re-applies the subscription once; other edits apply live. A built-in or provider scenario is read-only: the first edit asks **Make your own copy?**. **Make a copy** saves a copy to **Mine**, linked to its original, and runs it.

> [!NOTE]
> **Screenshot `copy-dialog`** — the Make your own copy? dialog

## Library

The Library tab starts with **New scenario**, **New behaviour** and **Import**, then lists **Scenarios** or **Behaviours**. Cards show the source chip (**Built-in**, **From provider**, **Mine**), **Simple** or **Advanced** for a behaviour, and **Needs your permission** when consent is missing.

| Action | Scenario | Behaviour |
| --- | --- | --- |
| Tap | Runs it | Opens the studio: the user's own in place, any other as a copy |
| Pencil | Edits the user's own, or opens a copy of any other | — |
| **Edit** | Mine only | Mine only |
| **Duplicate and edit** | Opens a copy | Opens a copy |
| **Export** | See [Import and export](#import-and-export) | Same |
| **Delete** | Mine only, after "Delete “{profile}”?" | Same |

A copy is saved when the editor saves it.

> [!NOTE]
> **Screenshot `hub-library`** — Scenarios filter and cards of every source

> [!NOTE]
> **Screenshot `library-menu`** — a Mine card with Edit, Duplicate and edit, Export and Delete

### Scenario editor

Holds **Name**, a description ("What this scenario does"), the Routes tab sections, **Warnings** and **Sites contacted**. The menu has **YAML**, **Export** and **Delete**; save is disabled while there are errors or no changes.

> [!NOTE]
> **Screenshot `scenario-editor`** — «My split» with name, description, routes and menu

## Import and export

**Export** offers **Export to clipboard**, **Copy link** and **Export file**. **Import** offers **Import from clipboard** and **Import from file**; a `reclash://routing` link opens the same review. Formats and naming are in [Sharing](../sharing.md).

> [!NOTE]
> **Screenshot `export-sheet`** — the three export actions

The review page **Import auto routing** shows the item (or **In this file** for a bundle), **Check on {group}** (what a single behaviour would pick in the current group), **Sites contacted** and **Warnings**. The check needs the core; without it the page reads "Start the app's core to check this file." and adds nothing. **Add to my library** is disabled while there are errors. It saves every item; nothing runs until the user chooses.

> [!NOTE]
> **Screenshot `import-page`** — the review of one scenario

> [!NOTE]
> **Screenshot `import-bundle`** — a bundle with a scenario and two behaviours

> [!NOTE]
> **Screenshot `import-problems`** — an error, with Add to my library disabled
