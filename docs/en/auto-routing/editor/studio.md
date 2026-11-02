# Studio

The behaviour (profile) editor: form and YAML, a live preview on a group, warnings, merging and earlier versions.

## Opening

Hub → **Library** → **Behaviours**: a card of the user's own opens in place; any other opens as a copy. **New behaviour** starts from a template with one tier `Working` (`not dead`), `rank.tolerance` 50 and `feel: calm`. Save is disabled while there are errors or no changes. The format is in [Profiles](../profiles.md).

## Form

| Section | Rows | Key |
| --- | --- | --- |
| Header | **Name**, description | `title`, `description` |
| **What it would pick now** | **Against group**: the verdict and the leading candidates; **All candidates** opens the full ranking | — |
| **Server order** | Steps, as in the [route editor](routes.md#server-order) | `prefer` |
| **Servers** | **Use only servers**, **Leave out servers** | `pool` |
| **Character** | **Switching**, **Checks**, **When no server fits** (**Keep current**, **Go direct**) | `switch.feel`, `energy`, `stranded` |
| **More** | **Based on**, **Level**, **Tags**, **Advanced** | `extends`, `level`, `tags` |
| **Sites contacted** | Each host with its use (check, network diagnostic, exit-country check) and **third party** | — |
| **Warnings** | Non-blocking issues | — |

**Advanced** lists the parts the form does not edit, each opening YAML: **Availability checks**, **Network kinds**, **Per-network changes**, **Direct sites through this group**, **Exit-country check**, **Translations**.

The preview verdict is **Would keep {pick}**, **Would pick {pick} instead of {now}** or **Would find no server**. It applies nothing.

> [!NOTE]
> **Screenshot `studio-form`** — Name, preview, Server order, Servers and Character

> [!NOTE]
> **Screenshot `studio-check`** — Would pick «🇳🇴 Oslo 1» instead of «🇸🇪 Stockholm 1»

## YAML

**YAML** in the menu opens the whole document as text; saving it replaces the form. Form edits rewrite the text from the parsed document, so comments are lost. The menu also has **Export** and, for a saved behaviour, **Delete**.

> [!NOTE]
> **Screenshot `studio-yaml`** — the YAML editor of a behaviour

## Warnings

The first error shows in a banner and blocks saving; an issue tied to text is prefixed "Line {line}:".

| Warning | Meaning |
| --- | --- |
| Tag {tag} is never used | No condition references the tag. |
| Check {check} is never used, so it never runs | No condition references the check. |
| “{tier}” repeats the condition of “{after}”, so nothing lands in it | The later tier is unreachable. |
| No server of {group} passes the filter | The pool removes every server of the preview group. |
| No server of {group} is in “{tier}” right now | The tier is empty on the preview group. |
| This config has no group {group} | A scenario names a missing group. |
| Contacts third-party sites: {hosts} | A provider entry needs consent; see [Consent](../sharing.md#consent). |

> [!NOTE]
> **Screenshot `studio-warnings`** — a repeated tier and an unused tag

## Merging

A copy remembers its original. When the original changes, **The original changed** offers **Bring changes over** (merges them and keeps the user's own edits) and **What changed** (a line diff). Results: "Changes brought over", "Brought over; you changed these too, so yours were kept: {keys}" or "Couldn't bring the changes over".

> [!NOTE]
> **Screenshot `studio-merge`** — The original changed, with Bring changes over and What changed

## Versions

Each save keeps the replaced text; the last 10 versions per behaviour are kept. **Earlier versions** in the menu loads one into the editor; it is saved on the next save. Scenarios keep versions too, but the editor does not offer them.

> [!NOTE]
> **Screenshot `studio-restore`** — Earlier versions with timestamps
