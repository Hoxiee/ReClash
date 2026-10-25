# The group profile studio

A group profile (a "behaviour") says how a smart group picks its server. The studio edits one. Open it from the hub: **Library** tab, filter **Group profiles**, tap a profile of yours (or any other to edit a copy); or choose **New profile** from the three-dot menu. The hub is at Advanced configuration → Auto routing.

Text form of profiles: [profiles.md](../profiles.md).

> [!NOTE]
> **Screenshot `studio-form`** — studio in form mode with General, Servers, Server order, Tags and Behaviour sections.

## Form and text

The top-right menu has **YAML**. It opens the profile as text in a full editor; saving there replaces the form's content. The form reflects the text. Edits in the form rewrite the text from its parsed form, so comments in hand-written YAML do not survive them. Name and description are written after a short pause in typing.

The check button in the app bar saves the profile. It stays disabled while the top banner shows an error and while nothing has changed.

> [!NOTE]
> **Screenshot `studio-yaml`** — the YAML text editor of a profile.

## Form sections

A new profile starts from a template: title "My profile", level Simple, one step "Working" (`not dead`), latency ranking and Switching set to Rarely.

Sections, top to bottom: the banner, **The original profile changed** (only when it applies), **General**, **Servers**, **Server order**, **Tags**, **Behaviour**, **Advanced** (only when used), **Check** (only when a smart group exists), **Warnings**, **Sites it contacts**.

| Section | Control | Notes |
| --- | --- | --- |
| **General** | **Name** | Title of the profile (hint "New profile"). |
| | Description box | Hint "What this profile does". |
| | **Level** | **Simple** or **Advanced**. |
| | **Based on** | The profile this one extends: **None** or any other profile in the library. |
| **Servers** | **Use** | Pool condition, default "Any server". |
| | **Leave out** | Exclusion, default "None". |
| **Server order** | Steps | See below. |
| **Tags** | **Add tag** | "A tag names a set of servers once, for use in tiers as tag(name)." |
| **Behaviour** | **Switching**, **Checks**, **When no server fits** | Switching and Checks work as in the group settings (**Rarely**, **Balanced**, **Often**; **Economical**, **Balanced**, **Precise**). **When no server fits**: **Keep the current server** or **Go direct**. |
| **Advanced** | read-only | "These parts are edited as YAML." One row per part the profile uses, among Availability checks, Network kinds, Per-network changes, Direct sites through this group, Exit-country check and Translations. Tapping a row opens the YAML editor. |

### Server order

The studio uses the same ladder as the group page, headed **Server order**. Steps are listed top to bottom; the first step that has a working server wins. A caption "if none of them works" links the first two steps. With no steps, a row "Any working server" reads "Add steps to prefer some servers over others".

- The plus button (**Add a step**) adds a step; tap a step to edit it in the [step editor](routes.md#the-step-builder) used by routes.
- With two or more steps, a sort button lets you drag to reorder. Long-press (or right-click) a step for **Delete**.
- Each step shows a label or its condition, "Last resort" when set, and, when the studio is checking against a group, how many of its servers the step takes.
- A line at the bottom, "If no step has a working server: {action}", repeats the **When no server fits** choice.
- A tag in a step is written `tag(name)`. The tag name takes Latin letters, digits, `-` and `_` only, up to 24 characters, and must be new.

### Tags

Each tag is a row with its condition; tap it to edit the condition, long-press (or right-click) for **Delete**. **Add tag** asks for a **Tag name**, then opens the condition builder for it.

## Conditions in the studio

**Use**, **Leave out**, tag rows and the advanced condition of a step open the [condition builder](routes.md#the-condition-builder). Countries come from the [country picker](routes.md#the-country-picker).

## Warnings and problems

A banner at the top shows the first error and disables saving. **Warnings** lists non-blocking issues, each prefixed "Line {line}:" when it points at text; it is absent when there are none. See [troubleshooting.md](troubleshooting.md#profile-and-scenario-checks) for the full list.

> [!NOTE]
> **Screenshot `studio-warnings`** — Warnings section with a tier that repeats an earlier condition and an unused tag.

**Sites it contacts** lists hosts the profile's checks contact, each with what it is used for (for example "check {name}") and "third party" where it applies. Footer: "Third-party sites belong neither to your provider nor to the built-in profiles."

## Check on a group

Section **Check** appears when at least one smart group exists. Its row **Against group** offers **None** and your smart groups. Choose a group to see what the profile would do right now, without applying it. Below the verdict, up to 6 servers are listed in the profile's ranking, with step, "may reach “{tier}” after a check" or the reason a server is out, and latency; the server it would pick is highlighted.

| Result | Meaning |
| --- | --- |
| **Would keep {pick}** | The group is already on the server the profile would pick. |
| **Would pick {pick} instead of {now}** | The profile would switch. |
| **Would find no server** | Nothing fits. |

> [!NOTE]
> **Screenshot `studio-check`** — Check section against "Proxy" with "Would pick 🇳🇴 Oslo 1 instead of 🇸🇪 Stockholm 1".

## Bring changes from the original

If you made your copy from a built-in or provider profile and that original later changed, the section **The original profile changed** appears.

| Row | What it does |
| --- | --- |
| **Bring changes over** ("Your own edits stay as they are") | Merges the new original into your copy. |
| **What changed** | Shows a line diff between the original you copied and its new version. |

Messages: **Changes brought over**; "Brought over; you changed these too, so yours were kept: {keys}"; or **Couldn't bring the changes over**.

> [!NOTE]
> **Screenshot `studio-merge`** — "The original profile changed" section with the two rows.

## History and restore

The top-right menu has **Earlier versions**. The item shows once the profile has older versions. Pick one to put it back in the editor; it is saved when you save. Saving keeps the replaced text, up to 10 versions of each profile. The menu also has **Export**, and for a saved profile **Delete** (confirmation "Delete “{profile}”?").

> [!NOTE]
> **Screenshot `studio-restore`** — Earlier versions sheet with timestamps.

## Scenario studio

The scenario editor ([hub.md#the-scenario-editor](hub.md#the-scenario-editor)) has the menu **YAML**, **Export** and (for a saved scenario) **Delete**, but no **Earlier versions**. Its form is the Routes tab.
