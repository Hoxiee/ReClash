# Subscription Provider Support

ReClash supports a native provider contract described in `provider_standard.g.json` and `PROVIDER_HEADERS.md`. The registry used by the application is `lib/subscriptions/protocol/registry.dart`.

## Supported

- Fetching subscriptions through the dedicated transport, with bounded redirects and managed request-header policy.
- Common subscription response headers, including `Subscription-Userinfo`, `Content-Disposition`, `profile-title`, and `announce`, the provider message shown when a subscription is added.
- Native metadata decoding through the versioned registry and codec.
- Device identity with global opt-in, per-profile overrides, and origin-scoped consent for device details.
- Client compatibility presets, automatic negotiation, and import adapters for supported configuration formats.
- `flclashx-*` metadata aliases are normalized only when the FlClashX preset is selected; all other presets accept native ReClash provider metadata names only.

## Routing profiles

A provider may offer routing profiles for its `select` proxy groups. The user chooses; the provider's default applies until then.

- Inline: top-level `rcx-profiles: {name: profile}` in the subscription YAML, and per `select` group `rcx: {profiles: [...], default: name, chips: [{label, include}]}`. Vanilla mihomo ignores both.
- Bundle: for providers serving universal YAML, `reclash-routing: <https url>` as a response header or a `#reclash-routing: <url>` comment line. The bundle is YAML `{rcx: 1, profiles: {name: profile}, groups: {"<group name>": binding}, scenarios: {name: scenario}, scenario: name}`, at most 256 KiB, and binds to groups by name. What the subscription declares inline wins over the bundle.
- A profile is at most 64 KiB. Provider profiles are addressed as `provider/<name>`; `extends` may name `builtin/<name>` or another provider profile.
- Providers can only narrow a group's pool and cannot enable `direct-split`; that stays with the user.
- A profile whose checks, diagnostics or echo services contact hosts other than the provider's own site (the registrable domain of the subscription URL) or endpoints used by built-in profiles needs the user's consent. Until then the group runs `builtin/simple`.
- A profile may ship an optional `l10n` map of translations of its title and labels per language; the app shows the user's language and falls back to the source text.
- Schema: `rcx-profile.schema.json` (profile at the root, bundle in `$defs.bundle`). Validate with `dart run tool/rcx.dart lint <file>...`; it accepts a profile, a scenario or a bundle.

### Scenarios

A scenario is a connection-wide auto control above smart groups: it sets the tunnel mode and gives groups a program. Groups it does not name keep their own binding.

- Inline: top-level `rcx-scenarios: {name: scenario}` plus `rcx-scenario: <name>` (the default) in the subscription YAML. Bundle: `scenarios: {name: scenario}` and `scenario: <name>`. Inline wins over the bundle.
- Scenario keys: `rcx`, `title`, `mode` (`rule`, `global` or `direct`; empty leaves the user's mode), `groups`, `tags` (named conditions for program pools), `network`, `on`, `l10n`.
- `groups` maps a target to a program. Targets: a group name, `$main` (the select group the final MATCH rule routes to), `*` (every other select group, not `GLOBAL`) or `GLOBAL`. Own name wins over `$main`, which wins over `*`.
- A program is `profile` (group profile id, replaces the group's own), `pool: {include, exclude}` (only narrows) or `to` (hold the group on one member, a server or a whole nested group such as a load balancer, with no search). `to` excludes `profile` and `pool`. `{}` drives the group with its own profile.
- `on.<kind>.mode` and `on.<kind>.groups` override per network kind; the kind must be declared in `network.kinds`. A group entry replaces the base entry of the same key whole.
- A scenario whose diagnostics contact third-party hosts needs the user's consent, as for profiles.
- The user picks the scenario or turns auto control off. A mode the user sets by hand wins until they choose Auto again.

## App settings from the subscription

A subscription may set app settings. They apply when the profile is current, without a confirmation, and each carries a "From provider" tag where the user edits it. A setting the user changes stops following the provider until "Return to provider" hands it back, per setting or for the whole profile.

- `reclash-view`: `key:value;...` over `proxies.type`, `proxies.sort`, `proxies.layout`, `proxies.icon`, `proxies.card`, `app.navbar`, `app.tabs`, `app.glass`, `app.color`, `app.style`, `app.black`. Unknown keys and values are ignored.
- `reclash-widgets`: dashboard cards, comma-separated. `reclash-background`: image URL, optionally `,<opacity percent>`.
- `reclash-settings`: `minimize`, `autorun`, `shadowstart`, `autostart`, `autoupdate`, `openlogs`, `closeconnections`.
- `reclash-restrictions`: `noglobal` removes the Global mode, `androidsecure` opens no local ports on Android, `denywidgets` removes dashboard editing.
- `announce` / `reclash-announce` shows the subscription description in a persistent dashboard card, with full selectable text and an optional `reclash-announceurl` link. It can be reordered with the other cards in the dashboard editor, but cannot be removed.
- `reclash-notice` shows a separate dismissible dashboard notification with an optional `reclash-noticeurl` link; changed text or a changed link shows again. Closing it never hides the subscription description.
- `reclash-expiredays`, `reclash-trafficpercent`: reminder thresholds. `reclash-buyplan` and `reclash-buytraffic` take a `,<n>` suffix: the action is offered from `<n>` days left or `<n>` percent used.
- `reclash-serverinfo`: a proxy group whose selected node is shown on the status card.

## Apps outside the tunnel (Android)

- Excludes come from `reclash-excludeapps`, a Clash config's `tun.exclude-package`, and `reclash-approuting: domestic` (the home region's apps, `domestic:<cc>` for a given region). They apply in the blacklist mode and while access control is off, and the user's own list adds to them.
- `reclash-includeapps` (or `tun.include-package`) adds to the whitelist in the whitelist mode only. Modes are never mixed.
- Provider apps carry the tag in Access control. Unticking one records that the user took it back into the tunnel; "Return apps to provider" resets that.

## Hosts

- `reclash-fallbackhosts` (up to 5 `host[:port]`): tried for the same path and query when the main host fails with a transport, TLS, timeout, rate-limit or invalid response. They never replace the stored URL.
- `reclash-newdomain` (one host): after the update succeeds, the new host is fetched and validated like the main one; only then the profile URL moves. A failing new host is ignored.
- Both are used only for `https` subscriptions.

## Boundaries

Provider responses cannot trigger reports or telemetry, and cannot change settings outside the lists above. Routing profiles are offers, not commands. The `flclashx-*` names map onto the same fields only under the FlClashX preset; `flclashx-newdomain` maps to `reclash-fallbackhosts`.

Client compatibility selection and import-format adaptation are separate layers. Neither implies permission to send device identity. `reclash-hideurl` only masks the URL in the editor; it does not prevent disclosure or modification.
