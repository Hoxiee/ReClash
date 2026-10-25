# Sharing: export, import and links

You can send a scenario or profile to another device as a file, as text, or as a link.

Text format and bundle details: [../sharing.md](../sharing.md).

## Export

Open the Library, long-press a card, choose **Export**; or use **Export** in the menu of a scenario editor or studio.

> [!NOTE]
> **Screenshot `export-sheet`** — Export sheet with the three actions.

| Action | Result |
| --- | --- |
| **Export to clipboard** | Copies the YAML text. |
| **Copy link** | Copies a `reclash://routing?p=…` link that holds the compressed text. Notifier: "Copied successfully". Limit 64 KiB. |
| **Export file** | Saves `<name>.rcx.yaml`. |

### Plain document or bundle

- If the item references only built-in profiles, you get a plain document with just the item.
- If a scenario references profiles of yours or from a provider, you get a **bundle**: the scenario and every profile it needs in one file, so it works on the other device.

## Import

Open the hub three-dot menu, choose **Import**, then **Import from clipboard** or **Import from file**. A pasted `reclash://routing?p=…` link or an https link to a payload is accepted too.

> [!NOTE]
> **Screenshot `import-page`** — "Import routing profile" page for a single scenario with title, origin and description.

The page **Import routing profile** shows:

| Part | Meaning |
| --- | --- |
| Item list **In this file** | Appears with several items: each has a title and "Scenario" or "Profile"; the footer names the origin. |
| Single item | Title, level (profiles) or "Scenario", origin and description. |
| **Check on {group}** | A profile imported from a group's sheet is tested against that group. |
| **Sites it contacts** | Hosts, marked "third party" where needed. |
| **Warnings** | Non-blocking issues. |
| Banner | Errors; the first error disables saving. |

> [!NOTE]
> **Screenshot `import-bundle`** — import page of a bundle listing a scenario and two profiles.

Tap **Add to my profiles**. Notifier: "Added “{profile}”". Items go to **Mine**; a scenario does not start by itself.

### Renaming on a clash

If a title already exists the importer renames the new one with a number rather than overwrite yours.

### Problems

| Message | Meaning |
| --- | --- |
| "Start the app's core to check this profile." | The Core is not running, so the file cannot be checked. Start the connection and retry. |
| A banner with a parse error | The file is not valid; see [troubleshooting.md](troubleshooting.md). |
| Consent notice | The imported item contacts sites; you allow them after import. |

> [!NOTE]
> **Screenshot `import-problems`** — import page with an error banner and disabled save.

## Walkthrough: share a setup to another device

On the device that has "My split":

1. Open **Auto routing**, tab **Library**, filter **Scenarios**.
2. Long-press **My split**, choose **Export**.
3. Choose **Copy link**. You see "Copied successfully". (For a file use **Export file**.)
4. Send the link in a message to yourself.

On the other device:

1. Open the link in ReClash, or copy it and open **Auto routing**, three-dot menu, **Import**, **Import from clipboard**.
2. Check the page: title, items, **Sites it contacts**.
3. Tap **Add to my profiles**.
4. Go to the **Overview** tab, tap **Change**, choose **My split**.

Servers named in the setup (⚡ RU, Stockholm) must exist in the other device's subscription for steps to find servers; the setup itself is portable.
