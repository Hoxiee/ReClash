# The auto routing editor

Auto routing (internal name RCX) lets ReClash pick servers for you and send chosen traffic, such as one service, through chosen servers. This section documents every screen you use to set it up. It covers the editor only. The text form of the same setups, the engine rules and the cookbook are in the pages linked at the bottom.

> [!NOTE]
> **Screenshot `editor-map`** — the three entry points side by side: the hub (Overview tab), the group sheet opened from Proxies, and the route editor, each with a caption arrow showing how you get from one to the next.

## Terms

| Term | Meaning |
| --- | --- |
| Scenario | The whole setup, kept as one file. It holds routes, rules for groups, and per-network changes. Only one scenario runs at a time. |
| Route | One rule inside a scenario: "this traffic goes through these servers". Routes are ordered; traffic takes the first route it matches. |
| Group | A select group of your subscription (for example the main proxy group). Each route also creates its own group, named like the route. |
| Behaviour | A group profile: the way a smart group picks its server (Simple, Fastest, Stable, Bypass and so on). |
| Server order | An ordered list of steps. The first step that has a working server wins. |
| Step | One line of a server order: a condition such as "Country Sweden" plus an optional label. |
| Control | Who decides the server of a group: Auto, Pinned or Manual. |

## Where each part lives

| Part | Where you open it |
| --- | --- |
| Auto routing hub (tabs Overview, Routes, Library) | Advanced configuration, then **Auto routing** |
| Group sheet (status, control, behaviour, history) | Proxies, tap a group, then the auto routing button on the group |
| Route editor | Hub, **Routes** tab, tap a route or **Add route** |
| Scenario editor | Hub, **Library** tab, tap a scenario |
| Group profile studio | Hub, **Library** tab, **Group profiles** filter, tap a profile; or the behaviour row of a group |
| Import | Hub, three-dot menu, **Import** |
| Export | Three-dot menu of a scenario or profile, or long-press a card in the Library |

> [!NOTE]
> The hub is reached from Advanced configuration → Auto routing, and from a group sheet in Proxies.

## Page map

| Page | What it covers |
| --- | --- |
| [hub.md](hub.md) | The hub: Overview, Routes and Library tabs |
| [routes.md](routes.md) | Adding and editing routes, the server order editor, country picker, condition builder |
| [groups.md](groups.md) | The group sheet in Proxies and its settings page |
| [studio.md](studio.md) | The group profile studio: form, YAML, simulation, merge, history |
| [sharing.md](sharing.md) | Export, import and links |
| [troubleshooting.md](troubleshooting.md) | Every message the editor shows and what to do about it |
| [../images/README.md](../images/README.md) | Screenshot manifest and demo setup |

## Typical flows

| I want to... | Go to |
| --- | --- |
| Turn auto routing on for everything | [hub.md#turn-auto-routing-on](hub.md#turn-auto-routing-on) |
| Send one service through chosen servers | [routes.md#add-a-route-for-one-service](routes.md#add-a-route-for-one-service) |
| Build a complete setup from nothing | [hub.md#walkthrough-build-my-split-from-an-empty-state](hub.md#walkthrough-build-my-split-from-an-empty-state) |
| Prefer servers from one country, with fallbacks | [routes.md#the-server-order-editor](routes.md#the-server-order-editor) |
| Pin or change the server of one group | [groups.md#control-auto-pinned-manual](groups.md#control-auto-pinned-manual) |
| Understand why a server was chosen | [groups.md#why-this-server-and-history](groups.md#why-this-server-and-history) |
| Turn auto routing off | [hub.md#turn-auto-routing-off](hub.md#turn-auto-routing-off) |
| Share my setup with another device | [sharing.md#walkthrough-share-a-setup-to-another-device](sharing.md#walkthrough-share-a-setup-to-another-device) |
| Fix a red message | [troubleshooting.md](troubleshooting.md) |

## How the pieces fit

1. A **scenario** is the running setup. You turn it on in the hub.
2. The scenario holds **routes**. Each route takes some traffic (services, domains, IP ranges, apps) and sends it through its own group, a fixed server, or direct.
3. A route's own group picks servers with a **behaviour** and a **server order**.
4. Groups the scenario does not name keep working as **smart groups** with their own behaviour, which you set on the group sheet.
5. Everything you change is saved at once. Route changes re-apply the profile once, a moment after the last edit.

Routes work only in rule mode. In global or direct mode the Routes tab says so and the routes wait.

## Other documentation

- [Overview of auto routing](../README.md)
- [How the engine decides](../engine.md)
- [Group profiles in text form](../profiles.md)
- [Conditions language](../conditions.md)
- [Scenarios in text form](../scenarios.md)
- [Sharing in text form](../sharing.md)
- [Cookbook](../cookbook.md)
