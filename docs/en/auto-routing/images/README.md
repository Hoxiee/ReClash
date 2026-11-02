# Screenshots

The screenshot slots of the in-app editor pages and the setup for capturing them.

## Demo setup

- Subscription "Demo" with servers 🇳🇴 Oslo 1, 🇳🇴 Oslo 2, 🇳🇴 Oslo 3, 🇸🇪 Stockholm 1, 🇸🇪 Stockholm 2, 🇷🇺 Moscow ⚡ 1,
  🇷🇺 Moscow ⚡ 2, *Premium NL, 🇩🇪 Frankfurt.
- User scenario "My split", running:
  - Everything else: step Country Norway;
  - ▶️ YouTube: steps Name contains «⚡ RU», then Any working server;
  - 🤖 Claude: step Country Sweden;
  - ✨ Gemini: step Name contains `*`;
  - 🏠 Local: Direct; Site category `category-ru` and Domain and subdomains `yandex.ru`.
- Rule mode, light theme, 412x915 unless a row says otherwise.
- The library holds the built-in behaviours and one of the user's own.

## Slots

Each slot is stored as `images/<id>.png`.

| id | file | page | what it must show | how to reach it |
| --- | --- | --- | --- | --- |
| editor-map | images/editor-map.png | editor/hub.md | the hub (Overview), the group sheet and the route editor side by side, with arrows between them; light theme, 412x915 | Composite of hub-overview, group-sheet-auto and route-editor. |
| hub-no-subscription | images/hub-no-subscription.png | editor/hub.md | Overview in the No subscription state; light theme, 412x915 | Remove the selected subscription, open Auto routing. |
| hub-overview | images/hub-overview.png | editor/hub.md | Overview with Auto routing on, «My split» running, the Mode row, Routes and Groups; light theme, 412x915 | Advanced configuration > Auto routing > Overview. |
| scenario-chooser | images/scenario-chooser.png | editor/hub.md | the scenario chooser with Mine, From provider and Built-in, «My split» selected; light theme, 412x915 | Overview > Change. |
| hub-groups-energy | images/hub-groups-energy.png | editor/hub.md | the Groups section with several rows and the Checks today footer; light theme, 412x915 | Overview after some checks ran. |
| hub-routes-off | images/hub-routes-off.png | editor/hub.md | Routes with No scenario is running and Start a scenario; light theme, 412x915 | Turn auto routing off, open Routes. |
| hub-routes | images/hub-routes.png | editor/hub.md | Routes of «My split»: four routes, Add route, Everything else and More; light theme, 412x915 | Auto routing > Routes. |
| hub-routes-rule-only | images/hub-routes-rule-only.png | editor/hub.md | the Routes footer with the rule-mode warning; light theme, 412x915 | Set the connection to global mode, open Routes. |
| hub-routes-reorder | images/hub-routes-reorder.png | editor/hub.md | the route list in reorder mode with drag handles; light theme, 412x915 | Routes > sort action. |
| hub-everything-else | images/hub-everything-else.png | editor/hub.md | the Everything else editor with one step Country Norway; light theme, 412x915 | Routes > Everything else. |
| hub-other-groups | images/hub-other-groups.png | editor/hub.md | Subscription groups with an Every group row and the Add group popup; light theme, 412x915 | Routes > More > Subscription groups > Add group. |
| hub-networks | images/hub-networks.png | editor/hub.md | Special networks with one network kind, its mode and groups; light theme, 412x915 | Routes > More > Special networks. |
| copy-dialog | images/copy-dialog.png | editor/hub.md | the Make your own copy? dialog; light theme, 412x915 | Run a built-in scenario, then Add route. |
| hub-library | images/hub-library.png | editor/hub.md | Library with the Scenarios filter and cards of every source, «My split» selected; light theme, 412x915 | Auto routing > Library. |
| library-menu | images/library-menu.png | editor/hub.md | a Mine card with Edit, Duplicate and edit, Export and Delete; light theme, 412x915 | Library > long-press a Mine card. |
| scenario-editor | images/scenario-editor.png | editor/hub.md | the scenario editor of «My split» with name, description, routes and the menu; light theme, 412x915 | Library > pencil on «My split». |
| export-sheet | images/export-sheet.png | editor/hub.md | the Export sheet with its three actions; light theme, 412x915 | Library > long-press a card > Export. |
| import-page | images/import-page.png | editor/hub.md | the import review of one scenario; light theme, 412x915 | Library > Import > Import from clipboard, with a scenario copied. |
| import-bundle | images/import-bundle.png | editor/hub.md | the import review of a bundle with a scenario and two behaviours; light theme, 412x915 | Import an exported bundle. |
| import-problems | images/import-problems.png | editor/hub.md | the import review with an error and Add to my library disabled; light theme, 412x915 | Import a broken file. |
| route-traffic-picker | images/route-traffic-picker.png | editor/routes.md | New route with YouTube and Gemini selected and the Custom section; light theme, 412x915 | Routes > Add route. |
| route-entry-form | images/route-entry-form.png | editor/routes.md | the entry form with Site category and an Invalid value error; light theme, 412x915 | Add route > Add entry. |
| route-editor | images/route-editor.png | editor/routes.md | the editor of «▶️ YouTube» with name, traffic, Best server, behaviour and server order; light theme, 412x915 | Routes > YouTube. |
| route-editor-fixed | images/route-editor-fixed.png | editor/routes.md | One server selected, choosing «🇳🇴 Oslo 1»; light theme, 412x915 | Route editor > One server. |
| route-behaviour | images/route-behaviour.png | editor/routes.md | the behaviour chooser with Built-in, From provider and Mine; light theme, 412x915 | Route editor > Behaviour. |
| route-pool | images/route-pool.png | editor/routes.md | Leave out servers with a name condition; light theme, 412x915 | Route editor > Leave out servers. |
| route-editor-ladder | images/route-editor-ladder.png | editor/routes.md | Server order with steps «⚡ RU» and Any working server and the connector; light theme, 412x915 | Route editor, scroll to Server order. |
| ladder-step-editor | images/ladder-step-editor.png | editor/routes.md | a step with Name contains «⚡ RU», Country and «2 servers fit now»; light theme, 412x915 | Server order > a step. |
| country-picker | images/country-picker.png | editor/routes.md | Choose countries with Norway verified, Sweden and Russia, then All countries; light theme, 412x915 | Step > Country. |
| condition-builder | images/condition-builder.png | editor/routes.md | All conditions: Country is one of Norway, Sweden; Latency is under 300; light theme, 412x915 | Route editor > Leave out servers. |
| condition-text | images/condition-text.png | editor/routes.md | the As text section with a parse error; light theme, 412x915 | Condition builder > As text, with a syntax error. |
| group-sheet-auto | images/group-sheet-auto.png | editor/groups.md | the main group in Auto: status, Control, Choose from and Behaviour; light theme, 412x915 | Proxies > main group > auto routing. |
| group-intro | images/group-intro.png | editor/groups.md | a group without auto routing with Turn on auto routing; light theme, 412x915 | The sheet of a group without a binding. |
| group-consent | images/group-consent.png | editor/groups.md | Permission needed with hosts and Allow; light theme, 412x915 | A group whose provider behaviour needs consent. |
| group-route | images/group-route.png | editor/groups.md | the sheet of «▶️ YouTube» with Made by a route; light theme, 412x915 | Proxies > the YouTube route group > auto routing. |
| group-sheet-pinned | images/group-sheet-pinned.png | editor/groups.md | Control set to Pinned with Holding the pinned server; light theme, 412x915 | Group sheet > Control > Pinned. |
| group-change-to | images/group-change-to.png | editor/groups.md | Choose from with Any, 🇳🇴, 🇸🇪, 🇷🇺 and one pattern; light theme, 412x915 | Group sheet > Choose from. |
| group-behaviour | images/group-behaviour.png | editor/groups.md | the Behaviour section with Fastest, Server order and Group settings; light theme, 412x915 | Group sheet > Behaviour. |
| group-settings | images/group-settings.png | editor/groups.md | Group settings with a name pattern, Switching, Checks and Direct sites through this group; light theme, 412x915 | Group sheet > Group settings. |
| group-why | images/group-why.png | editor/groups.md | Why this server expanded, with a Skipped after «Change server» row; light theme, 412x915 | Group sheet > Why this server. |
| group-history | images/group-history.png | editor/groups.md | History expanded with a failover and a pin; light theme, 412x915 | Group sheet > History. |
| studio-form | images/studio-form.png | editor/studio.md | the studio form with Name, preview, Server order, Servers and Character; light theme, 412x915 | Library > Behaviours > a Mine card. |
| studio-check | images/studio-check.png | editor/studio.md | What it would pick now against «Proxy»: Would pick «🇳🇴 Oslo 1» instead of «🇸🇪 Stockholm 1»; light theme, 412x915 | Studio > Against group > Proxy. |
| studio-yaml | images/studio-yaml.png | editor/studio.md | the YAML editor of a behaviour; light theme, 412x915 | Studio > menu > YAML. |
| studio-warnings | images/studio-warnings.png | editor/studio.md | Warnings with a repeated tier and an unused tag; light theme, 412x915 | Studio with a repeated tier and an unused tag. |
| studio-merge | images/studio-merge.png | editor/studio.md | The original changed with Bring changes over and What changed; light theme, 412x915 | Studio of a copy whose original changed. |
| studio-restore | images/studio-restore.png | editor/studio.md | Earlier versions with timestamps; light theme, 412x915 | Studio > menu > Earlier versions. |
