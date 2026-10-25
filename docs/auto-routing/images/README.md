# Screenshot manifest

Images for the editor documentation live in this folder as `images/<id>.png`. Each stub in a page reads `Screenshot <id>`; the table below is the contract for taking it.

## Demo setup

Use the same setup for every screenshot.

- Subscription "Demo" with servers: 🇳🇴 Oslo 1, 🇳🇴 Oslo 2, 🇳🇴 Oslo 3, 🇸🇪 Stockholm 1, 🇸🇪 Stockholm 2, 🇷🇺 Moscow ⚡ 1, 🇷🇺 Moscow ⚡ 2, *Premium NL, 🇩🇪 Frankfurt.
- User scenario "My split", running, with routes:
  - main traffic (Everything else): country Norway;
  - ▶️ YouTube: steps "⚡ RU" then Any working server;
  - 🤖 Claude: country Sweden;
  - ✨ Gemini: step "Name contains `*`";
  - 🏠 Local: Direct, Site category `category-ru` and Domain and subdomains `yandex.ru`.
- Connection in rule mode, light theme, 412×915 unless a row says otherwise.
- Group profiles in the Library: the built-ins plus one of yours.

## Screenshots

| id | file | page | what it must show | how to reach it |
| --- | --- | --- | --- | --- |
| editor-map | images/editor-map.png | editor/README.md | the three entry points side by side: the hub (Overview tab), the group sheet opened from Proxies, and the route editor, each with a caption arrow showing how you get from one to the next; light theme, 412x915 | Composite of three screens; assemble from hub-overview, group-sheet-auto, route-editor. |
| group-sheet-auto | images/group-sheet-auto.png | editor/groups.md | group sheet of the main group in Auto control: status card, Control, Change to chips, Behaviour section; light theme, 412x915 | Proxies > main group > auto routing sheet. |
| group-intro | images/group-intro.png | editor/groups.md | the sheet of a group without auto routing, with the Turn on auto routing button; light theme, 412x915 | Group sheet of a group that is not smart. |
| group-sheet-pinned | images/group-sheet-pinned.png | editor/groups.md | Control set to Pinned with "Holding the pinned server" on the status card; light theme, 412x915 | Group sheet > Control > Pinned. |
| group-change-to | images/group-change-to.png | editor/groups.md | Change to with chips Any, 🇳🇴, 🇸🇪, 🇷🇺 and one custom pattern; light theme, 412x915 | Group sheet > Change to. |
| group-behaviour | images/group-behaviour.png | editor/groups.md | Behaviour section with the Fastest profile, Server order summary and the settings row; light theme, 412x915 | Group sheet > Behaviour. |
| group-settings | images/group-settings.png | editor/groups.md | settings page with Name pattern "4 of 5 match", Switching Balanced, Checks Economical, and the direct-sites switch; light theme, 412x915 | Group sheet > settings row. |
| group-why | images/group-why.png | editor/groups.md | Why this server expanded with five rows including a "Skipped after Change server" row; light theme, 412x915 | Group sheet > Why this server. |
| group-history | images/group-history.png | editor/groups.md | History expanded with a failover and a pin entry; light theme, 412x915 | Group sheet > History. |
| group-consent | images/group-consent.png | editor/groups.md | Permission needed section with hosts and the Allow row; light theme, 412x915 | Group sheet with a profile that needs consent. |
| group-route | images/group-route.png | editor/groups.md | sheet of the group "▶️ YouTube" with the Made by a route section; light theme, 412x915 | Proxies > the YouTube route group > auto routing sheet. |
| hub-menu | images/hub-menu.png | editor/hub.md | the hub app bar with the three-dot menu open, showing New scenario, New profile and Import; light theme, 412x915 | Advanced configuration > Auto routing > three-dot menu. |
| hub-overview | images/hub-overview.png | editor/hub.md | Overview tab with auto routing on, scenario "My split" running, live line, a Routes section and a Smart groups section with the energy footer; light theme, 412x915 | Auto routing > Overview, scenario My split running. |
| hub-no-subscription | images/hub-no-subscription.png | editor/hub.md | the Overview tab in the "No subscription" state; light theme, 412x915 | Remove the selected profile, open Auto routing. |
| hub-overview-off | images/hub-overview-off.png | editor/hub.md | Overview with the master switch off and its hint; light theme, 412x915 | Auto routing > Overview with the switch off. |
| scenario-chooser | images/scenario-chooser.png | editor/hub.md | the scenario sheet with sections Mine, From provider and Built-in, each with titles and descriptions, "My split" selected; light theme, 412x915 | Overview > Change. |
| hub-groups-energy | images/hub-groups-energy.png | editor/hub.md | the Smart groups section with several rows and the "Checks today" footer; light theme, 412x915 | Overview, scroll to Smart groups after some checks ran. |
| hub-routes | images/hub-routes.png | editor/hub.md | Routes tab for "My split": four routes, an Add route row, Everything else, Other groups, Networks; light theme, 412x915 | Auto routing > Routes. |
| hub-routes-off | images/hub-routes-off.png | editor/hub.md | Routes tab with "No scenario is running" and the Start a scenario button; light theme, 412x915 | Switch auto routing off, open Routes. |
| hub-routes-rule-only | images/hub-routes-rule-only.png | editor/hub.md | Routes tab footer with the rule-mode warning while the connection is in global mode; light theme, 412x915 | Set the connection to global mode, open Routes. |
| hub-routes-reorder | images/hub-routes-reorder.png | editor/hub.md | Routes list in reorder mode with drag handles; light theme, 412x915 | Routes > sort action in the Routes header. |
| hub-everything-else | images/hub-everything-else.png | editor/hub.md | Everything else row and its editor with a single step "Country Norway"; light theme, 412x915 | Routes > Everything else. |
| hub-other-groups | images/hub-other-groups.png | editor/hub.md | Other groups section with one row for "Every group" and the Add group popup; light theme, 412x915 | Routes > Other groups > Add group. |
| hub-networks | images/hub-networks.png | editor/hub.md | the Networks section expanded with Connection mode, one network kind, Tags and Advanced; light theme, 412x915 | Routes > Mode and networks, expanded. |
| copy-dialog | images/copy-dialog.png | editor/hub.md | the "Make your own copy?" dialog with the Make a copy button; light theme, 412x915 | Run a built-in scenario, then Add route. |
| hub-library | images/hub-library.png | editor/hub.md | Library tab, Scenarios filter, cards with Built-in, From provider and Mine badges, "My split" selected; light theme, 412x915 | Auto routing > Library. |
| library-menu | images/library-menu.png | editor/hub.md | a Mine card with its context menu open (Edit, Duplicate and edit, Export, Delete); light theme, 412x915 | Library > long-press a Mine card. |
| scenario-editor | images/scenario-editor.png | editor/hub.md | scenario editor for "My split" with title, description, routes and the YAML menu; light theme, 412x915 | Library > My split. |
| route-delete-menu | images/route-delete-menu.png | editor/hub.md | the context menu of a route with Edit and Delete; light theme, 412x915 | Routes > long-press a route. |
| walk-1-empty | images/walk-1-empty.png | editor/hub.md | Routes tab with "No scenario is running"; light theme, 412x915 | Routes with no scenario running. |
| walk-2-youtube-step | images/walk-2-youtube-step.png | editor/hub.md | the step editor with Name contains "⚡ RU" and the "N servers fit now" footer; light theme, 412x915 | Routes > Add route > YouTube > Next > Add a step. |
| walk-3-done | images/walk-3-done.png | editor/hub.md | Routes tab with all four routes and Everything else showing Norway; light theme, 412x915 | Routes after the walkthrough in hub.md. |
| route-traffic-picker | images/route-traffic-picker.png | editor/routes.md | the New route page with the service chips YouTube and Gemini selected and the Custom section below; light theme, 412x915 | Routes > Add route. |
| route-entry-form | images/route-entry-form.png | editor/routes.md | the entry form with Type "Site category" and an invalid value showing "Invalid value"; light theme, 412x915 | Add route > Add entry. |
| route-editor | images/route-editor.png | editor/routes.md | editor for "▶️ YouTube": name, traffic summary "YouTube · 2 more", Send through = Auto, server order, behaviour; light theme, 412x915 | Routes > tap YouTube. |
| route-editor-fixed | images/route-editor-fixed.png | editor/routes.md | route editor with One server selected and the Server row choosing "🇳🇴 Oslo 1"; light theme, 412x915 | Route editor > Send through > One server. |
| route-behaviour | images/route-behaviour.png | editor/routes.md | the Behaviour page with sections Built-in, From provider, User and the description footer; light theme, 412x915 | Route editor > Behaviour. |
| route-pool | images/route-pool.png | editor/routes.md | Leave out row showing "name contains …" and the Use row on a group rule; light theme, 412x915 | Route editor > Leave out. |
| route-editor-ladder | images/route-editor-ladder.png | editor/routes.md | Server order section with two steps ("⚡ RU" and "Any working server"), connectors, the caption "if none of them works" and the Add a step button; light theme, 412x915 | Route editor, scroll to Server order. |
| ladder-step-editor | images/ladder-step-editor.png | editor/routes.md | step editor with Name contains "⚡ RU", Country row, Add condition and the footer "2 servers fit now"; light theme, 412x915 | Server order > tap a step or Add a step. |
| country-picker | images/country-picker.png | editor/routes.md | Choose countries sheet with On your servers section (Norway 3 servers verified, Sweden 2 servers, Russia 2 servers) and All countries; light theme, 412x915 | Step editor > Country. |
| condition-builder | images/condition-builder.png | editor/routes.md | the builder with Match = All conditions and two conditions: Country is one of Norway, Sweden; Latency is under 300; light theme, 412x915 | Route editor > Leave out, or step editor > Advanced condition. |
| condition-text | images/condition-text.png | editor/routes.md | the As text section with a parse error banner; light theme, 412x915 | Condition builder > As text, with a deliberate syntax error. |
| export-sheet | images/export-sheet.png | editor/sharing.md | Export sheet with the three actions; light theme, 412x915 | Library > long-press a card > Export. |
| import-page | images/import-page.png | editor/sharing.md | "Import routing profile" page for a single scenario with title, origin and description; light theme, 412x915 | Hub menu > Import > paste a scenario link. |
| import-bundle | images/import-bundle.png | editor/sharing.md | import page of a bundle listing a scenario and two profiles; light theme, 412x915 | Import a bundle link. |
| import-problems | images/import-problems.png | editor/sharing.md | import page with an error banner and disabled save; light theme, 412x915 | Import a broken file. |
| studio-form | images/studio-form.png | editor/studio.md | studio in form mode with General, Servers, Server order, Tags and Behaviour sections; light theme, 412x915 | Library > Group profiles > a Mine profile. |
| studio-yaml | images/studio-yaml.png | editor/studio.md | the YAML text editor of a profile; light theme, 412x915 | Studio > menu > YAML. |
| studio-warnings | images/studio-warnings.png | editor/studio.md | Warnings section with a tier that repeats an earlier condition and an unused tag; light theme, 412x915 | Studio with a shadowed tier and an unused tag. |
| studio-check | images/studio-check.png | editor/studio.md | Check section against "Proxy" with "Would pick 🇳🇴 Oslo 1 instead of 🇸🇪 Stockholm 1"; light theme, 412x915 | Studio > Check > Against group. |
| studio-merge | images/studio-merge.png | editor/studio.md | "The original profile changed" section with the two rows; light theme, 412x915 | Studio of a copy whose original changed. |
| studio-restore | images/studio-restore.png | editor/studio.md | Earlier versions sheet with timestamps; light theme, 412x915 | Studio > menu > Earlier versions. |
| cookbook-routes-hub | images/cookbook-routes-hub.png | cookbook.md | Routes tab with the YouTube, Claude, Gemini and Local routes, each with its current server and step; light theme, 412x915 | Advanced configuration > Auto routing > Routes, with the split-traffic scenario running. |
| cookbook-ladder-ranking | images/cookbook-ladder-ranking.png | cookbook.md | group explanation with the ranking split by step (Starred, Finland, Anything) and the current server marked; light theme, 412x915 | Proxies > a group > auto routing button > Why this server. |
| cookbook-pin-control | images/cookbook-pin-control.png | cookbook.md | group sheet with Auto, Pinned and Manual, Pinned chosen and the pinned server highlighted; light theme, 412x915 | Proxies > a group > auto routing button, after picking a server by hand. |
| cookbook-bundle-import | images/cookbook-bundle-import.png | cookbook.md | import review listing one scenario and one profile with their final names; light theme, 412x915 | Hub menu > Import > the Streaming bundle. |
