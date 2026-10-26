# Cookbook

Worked recipes. Each one has a goal, the full YAML, a line-by-line explanation and what you see in the app. Every
YAML block passes [`rcxlint`](sharing.md#the-rcxlint-tool) unless it says otherwise. To use a scenario, import it
(see [Sharing](sharing.md)) and select it in the hub; to use a profile, bind it to a group.

Each recipe assumes server names carry a country flag or a code, as most subscriptions do. If yours do not, use
`name ~ /.../` conditions instead of `country`.

Contents: [1 main traffic and per-service servers](#1-main-traffic-via-norway-with-per-service-servers) ·
[2 a ladder](#2-a-ladder-stars-first-then-a-country-then-anything) · [3 weak phone](#3-a-cheap-and-stable-profile-for-a-weak-phone) ·
[4 mobile vs Wi-Fi](#4-different-behaviour-on-mobile-and-wi-fi) · [5 provider scenario](#5-a-provider-shipping-a-scenario) ·
[6 excluding test servers](#6-excluding-test-servers) · [7 pinning and manual control](#7-pinning-and-manual-control) ·
[8 bundle export](#8-a-bundle-export-of-a-scenario-with-its-own-profiles)

## 1. Main traffic via Norway, with per-service servers

**Goal.** Everything goes through Norway. YouTube prefers a Russian server with a lightning bolt in its name, then any
Russian server, then anything. Claude goes through Sweden. Gemini uses servers with `*` in the name. Sites in your own
country go direct.

```yaml
rcx: 1
title: Daily routes
description: Norway for everything, with special servers for YouTube, Claude and Gemini.
groups:
  $main:
    prefer:
      - label: Norway
        when: country = NO
      - label: Anything
        when: not dead
routes:
  - name: YouTube
    match: [GEOSITE,youtube]
    prefer:
      - label: Fast Russian
        when: country = RU and name ~ /⚡/
      - label: Russia
        when: country = RU
      - label: Anything
        when: not dead
  - name: Claude
    match: [GEOSITE,anthropic, DOMAIN-SUFFIX,claude.ai]
    prefer:
      - label: Sweden
        when: country = SE
      - label: Anything
        when: not dead
  - name: Gemini
    match: [GEOSITE,google-gemini]
    prefer:
      - label: Starred
        when: name ~ /\*/
      - label: Anything
        when: not dead
  - name: Local
    match: [GEOSITE,category-ru, GEOSITE,yandex, GEOIP,RU,no-resolve]
    to: DIRECT
```

**Line by line.**

- `groups.$main` drives the group your final `MATCH` rule uses. Its server order is Norway first, then anything alive.
- Each route (`YouTube`, `Claude`, `Gemini`) becomes its own `select` group with `include-all`, so it sees every
  server, and its own `prefer` gives it a server order. The route's rules go in front of your config's rules.
- `name ~ /⚡/` matches servers whose name contains the bolt; `country = RU` matches Russian servers (flag or code in
  the name). `country = RU and name ~ /⚡/` is "both".
- The Claude route lists a category and a domain: `GEOSITE,anthropic` and `DOMAIN-SUFFIX,claude.ai`. Either matches.
- Gemini uses `name ~ /\*/`: the backslash makes the star literal in the regular expression.
- The `Local` route has `to: DIRECT`, so it makes no group. It matches `category-ru`, `yandex` and `GEOIP,RU`
  (with `no-resolve`, so the rule does not trigger a DNS lookup) and sends them out directly.
- The route order matters: rules are prepended in this order, and the first match wins.

**What you see.** The hub lists the scenario with four routes. Each route shows its current server and the step that
chose it. The proxies screen has three extra groups named `YouTube`, `Claude` and `Gemini`. Routes apply in rule mode;
in global or direct mode the hub says so.

> [!NOTE]
> **Screenshot `cookbook-routes-hub`** — the scenario hub with the YouTube, Claude, Gemini and Local routes, each with its current server and the step that chose it.

## 2. A ladder: stars first, then a country, then anything

**Goal.** Servers with `*` in the name first, then Finland, then any working server.

```yaml
rcx: 1
title: Starred, then Finland, then any
prefer:
  - label: Starred
    when: name ~ /\*/ and not dead
  - label: Finland
    when: country = FI
  - label: Anything
    when: not dead
    last-resort: true
```

**Line by line.**

- Step 1 `Starred`: `name ~ /\*/ and not dead`. A star in the name, and not known to be down.
- Step 2 `Finland`: `country = FI`. Servers whose name says Finland.
- Step 3 `Anything`: `not dead`, marked `last-resort: true`.
- The engine uses the first step that has a live server. If every starred server is dead, step 2 is used, and so on.
  Inside a step, the fastest server wins.
- Replace `FI` with the code of your country. Codes are ISO two-letter codes, not names: `country = FI`, not
  `country = Finland`.

`last-resort: true` keeps `Anything` last even if someone later adds a step below it (see
[Profiles](profiles.md#prefer)).

**What you see.** In the group's explanation, the ranking is split by step. The current server shows its step label
(`Starred`, `Finland` or `Anything`) and the reason it was chosen.

> [!NOTE]
> **Screenshot `cookbook-ladder-ranking`** — the group ranking grouped by step: Starred, Finland, Anything, with the current server marked.

## 3. A cheap and stable profile for a weak phone

**Goal.** Few checks, rare switches, a steady server.

```yaml
rcx: 1
title: Cheap and steady
description: For weak phones. Few checks, rare switches.
extends: builtin/stable
energy: eco
switch:
  feel: calm
  max-per-hour: 1
```

**Line by line.**

- `extends: builtin/stable` starts from the stable behaviour: rank by stability, tolerance 100, calm.
- `energy: eco` allows 4 maintenance checks an hour, no discovery and 12 recovery checks (see
  [budgets](engine.md#budgets)).
- `switch.feel: calm` with `max-per-hour: 1` allows at most one voluntary switch an hour. A dead server is still
  replaced at once.
- Nothing else is needed: with the screen off, the engine does no checks anyway unless real traffic fails.

**What you see.** The hub shows "Eco" and the group changes server rarely. The journal lists few entries.

## 4. Different behaviour on mobile and Wi-Fi

**Goal.** The fastest server on Wi-Fi, a steady one on mobile data.

```yaml
rcx: 1
title: Mobile vs Wi-Fi
description: Stable and frugal on mobile data, fastest on Wi-Fi.
network:
  kinds:
    - kind: cell
      when: network.transport = cellular
    - kind: wifi
      when: network.transport = wifi
groups:
  $main: { profile: builtin/fastest }
on:
  cell:
    groups:
      $main: { profile: builtin/stable }
```

**Line by line.**

- `network.kinds` classifies the network. The first `when` that holds names the kind: `cell` on a cellular link,
  `wifi` on Wi-Fi.
- `groups.$main` gives the main group `builtin/fastest` by default.
- `on.cell.groups.$main` replaces that entry while the kind is `cell`: `builtin/stable`.
- Kind changes need two agreeing rounds, so passing through a tunnel does not flip behaviour.

**What you see.** The scenario status shows the network kind (`cell` or `wifi`), and the group's profile changes with
it.

## 5. A provider shipping a scenario

**Goal.** A provider ships a profile and a scenario that uses it, as a bundle the subscription points to.

```yaml
rcx: 1
profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - label: Germany
        when: country = DE
      - label: Anything
        when: not dead
scenarios:
  work:
    rcx: 1
    title: Work
    description: Everything via Germany, internal sites direct.
    groups:
      $main: { profile: provider/fast-de }
    routes:
      - name: Intranet
        match: [DOMAIN-SUFFIX,corp.example]
        to: DIRECT
scenario: work
```

**Line by line.**

- `profiles.fast-de` is a provider profile, referenced as `provider/fast-de`.
- `scenarios.work` sends the main group through that profile and sends corporate domains directly.
- `scenario: work` makes it the default. The user may choose another scenario or turn auto control off.
- Serve it from an `https` URL and announce it in the subscription: header `reclash-routing: https://example.com/routing.yaml`
  or a body line `#reclash-routing: https://example.com/routing.yaml`. Or put the same sections inline as `rcx-profiles`,
  `rcx-scenarios` and `rcx-scenario` (see [Sharing](sharing.md#provider-delivery)).
- Nothing here contacts a third-party host, so there is no consent prompt.

**What you see.** After the subscription updates, the hub offers "Work" as a provider scenario, marked as from the
provider. Selecting it applies the routes at the next config apply.

## 6. Excluding test servers

**Goal.** Never use servers named like tests or trials, even as a last resort.

```yaml
rcx: 1
title: No test servers
pool:
  exclude: name ~ /(?i)test|demo|expired/ or tag(junk)
tags:
  junk: 'name ~ /(?i)^trial/'
prefer:
  - label: Anything
    when: not dead
```

**Line by line.**

- `pool.exclude` removes servers from the pool entirely: they cannot be chosen at any step.
- The condition combines a regular expression on the name with a tag. `tag(junk)` reads the tag defined below.
- `tags.junk` matches names that start with "trial", case-insensitive (`^` anchors the start).
- Unknown facts admit a server, but name conditions are never unknown.

A provider or a scenario can narrow the pool the same way. They can never widen it.

**What you see.** Excluded servers still appear in the group's ranking, greyed out with the reason `Excluded by pool`.

## 7. Pinning and manual control

**Goal.** Keep a particular server, or stop the engine entirely.

This recipe is control, not YAML. Three controls exist for a group.

| You do | Control | Result |
| --- | --- | --- |
| Tap a server in a smart group | Pinned | The engine keeps that server. If it dies or leaves the pool, the group falls back to auto and tells you. |
| Choose "This network only" when pinning | Pinned, one network | The pin reverts to auto on other networks. |
| Choose Manual for the group | Manual | The engine never switches this group and spends no checks on it. |
| Choose Auto | Auto | Clears a pin and returns the group to the profile. |
| Press "Change server" | Auto, with the current server excluded for 15 minutes | Forces a switch. |

A pin also wins over a scenario's fixed target. A scenario can hold a group on a fixed target with a program:

```yaml
rcx: 1
title: Hold the main group on one server
groups:
  $main:
    to: DIRECT
```

**What you see.** A pinned group shows the pinned server as "chosen by you" and a hold reason
`hold.pinned` in the explanation. The journal records `pin` and `auto` events.

> [!NOTE]
> **Screenshot `cookbook-pin-control`** — a smart group sheet showing Auto, Pinned and Manual controls with the pinned server highlighted.

## 8. A bundle export of a scenario with its own profiles

**Goal.** Send a friend a scenario together with the profile it needs.

On your device the scenario is `streaming` and it uses your profile `streaming-fast`. Export the scenario. Because it
refers to a non-built-in profile, the export is a bundle:

```yaml
rcx: 1
kind: bundle
title: Streaming
scenarios:
  streaming:
    rcx: 1
    title: Streaming
    groups:
      $main: { profile: user/streaming-fast }
profiles:
  streaming-fast:
    rcx: 1
    title: Streaming fast
    extends: builtin/fastest
    prefer:
      - label: Germany
        when: country = DE
      - label: Anything
        when: not dead
```

**Line by line.**

- `kind: bundle` marks the file; without it, the receiver would read a single scenario.
- `scenarios.streaming` points to `user/streaming-fast`, the exported name of your profile.
- `profiles.streaming-fast` is the profile itself. `extends: builtin/fastest` stays a built-in reference, which every
  copy of the app has.
- The export names profiles after their titles and fixes the references. If you own several profiles called
  "Streaming fast", the names are `streaming-fast`, `streaming-fast-2`, and so on.

On import, the friend gets a scenario and a profile, each with a name that is free in their library. If they already
have `streaming-fast`, theirs is untouched, the imported one is `streaming-fast-2`, and the imported scenario is
rewritten to point at it.

`rcxlint` and the studio both check this file as it is.

**What you see.** The import review lists the scenario and the profile, with the final names, before anything is saved.

> [!NOTE]
> **Screenshot `cookbook-bundle-import`** — the import review listing one scenario and one profile with their final names.
