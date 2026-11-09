# Provider manifest

The provider manifest is one static YAML file that a provider hosts once for all users and points to with the `reclash-config` response header. It carries everything ReClash shows or applies beyond the standard headers: provider panel, reminders, settings, policy, Android apps, transport, support, appearance, cards and routing. The subscription body stays plain mihomo.

## Quick start

**1. Write `reclash.yaml`.**

```yaml
version: 1
provider:
  name: Example VPN
  support-url: https://t.me/example_support
  web-url: https://example.net
  renew: { url: https://example.net/buy, days: 7 }
reminders:
  expire-days: [3, 1]
```

**2. Host it and point to it.** Put the file on any static HTTPS host and add one response header to the subscription:

```http
reclash-config: https://example.net/reclash.yaml
```

**3. Check it.** Update the profile in ReClash and open Profiles → profile menu → Subscription inspector ([Subscription inspector](rollout.md#subscription-inspector)). The manifest is applied when the inspector shows no warnings.

Every section is optional. Add sections as you need them; the full example below uses all of them.

## Full example

```yaml
version: 1
provider:
  name: { en: Example VPN, ru: Пример VPN }
  logo: https://cdn.example.net/logo.png
  logo-dark: https://cdn.example.net/logo-dark.png
  support-url: https://t.me/example_support
  web-url: https://example.net
  type: test
  hide-url: true
  server-group: Proxy
  announce: { text: Welcome to Example VPN., url: https://example.net/news }
  notice: { text: Maintenance tonight., url: https://status.example.net }
  renew: { url: https://example.net/buy, days: 7 }
  top-up: { url: https://example.net/topup, percent: 80 }
reminders:
  expire-days: [3, 2, 1]
  traffic-percent: [90]
settings:
  connect-on-launch: true
  close-connections: true
policy:
  global: listed
  apps: required
  local-ports: closed
  dashboard: locked
apps:
  exclude: [com.example.bank]
  routing: domestic
transport:
  fallback-hosts: [backup.example.net:8443]
  new-domain: new.example.net
support:
  keys: ["ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik"]
  upload-url: https://support.example.net/reclash/reports
view:
  app:
    color: "#336699"
    color-dark: "#99BBEE"
    style: tinted
  proxies:
    type: list
    sort: delay
power-button:
  shape: [puffy, clover8Leaf]
  type: outline
wallpaper:
  url: https://cdn.example.net/wallpaper.webp
  opacity: 12
widgets: [outboundMode, serviceStatus, health]
cards:
  - id: spring-sale
    type: banner
    layout: hero
    tone: primary
    title:
      en: Spring sale
      ru: Весенняя распродажа
    text:
      en: 30% off every plan.
      ru: Скидка 30% на все тарифы.
    image: https://cdn.example.net/sale.webp
    image-dark: https://cdn.example.net/sale-dark.webp
    countdown: 1798675200
    button:
      label:
        en: Renew
        ru: Продлить
      app: renew
    dismissible: true
    when:
      from: 1767225600
      until: 1798675200
      platforms: [android, windows]
  - id: low-traffic
    type: note
    level: warning
    text: Traffic is almost used up.
    app: topUp
    when:
      traffic-above: 90
  - id: help
    type: actions
    items:
      - icon: support
        label: Support
        app: support
      - icon: telegram
        label: Channel
        url: https://t.me/example
      - icon: share
        label: Invite
        share: "Try ReClash: https://example.net/invite"
power-labels:
  "off": Tap to connect
  connecting: Connecting
  "on":
    - title: "{daysLeft} days left"
    - Protected
  paused: Paused
routing:
  profiles:
    fast-de:
      rcx: 1
      title: Fast Germany
      prefer:
        - { label: Germany, when: 'country = DE' }
        - { label: Anything, when: 'not dead' }
  scenarios:
    work:
      rcx: 1
      title: Work
      groups:
        $main: { profile: provider/fast-de }
  scenario: work
  bindings:
    Proxy: { profiles: [fast-de], default: fast-de }
```

## Validate in your editor

The schema is published with the documentation. Put this comment on the first line and editors with the YAML language server validate and complete the file:

```yaml
# yaml-language-server: $schema=https://reclash.pages.dev/schemas/provider-config.schema.json
version: 1
```

In CI:

```sh
uvx check-jsonschema --schemafile https://reclash.pages.dev/schemas/provider-config.schema.json reclash.yaml
```

The schema is stricter than the app: the app ignores an unknown key with a warning, the schema rejects it. The source is [`provider-config.schema.json`](../../../provider-config.schema.json).

## Delivery

- `reclash-config: <https url>` counts only in an `https` response. A redirect must end on an `https` URL.
- The file is at most 512 KiB. A profile or scenario inside it is at most 64 KiB. `ETag` and `304 Not Modified` are honored.
- It is fetched with the subscription update, within 8 seconds (less when the update has less time left).
- A manifest on the subscription's origin gets the subscription request headers. Another origin gets only `User-Agent`, `Accept` and `Accept-Language`; the device ID never leaves the subscription origin.
- The stored copy is replaced as a whole, after full validation. A failed or invalid fetch keeps the last valid copy and never fails the update.
- Omitting `reclash-config` deletes the stored copy. A section missing from a new valid copy is withdrawn ([Ownership](#ownership)).
- The copy is stored beside the profile, and the Core reads `routing` from it. Backups do not include it: after a restore the sections are absent until the next update.
- Fetch and validation warnings appear in the [Subscription inspector](rollout.md#subscription-inspector).

## Format

- `version: 1` is required. Any other value rejects the file.
- Keys are kebab-case. Anchors, aliases, duplicate keys, non-string keys and nesting deeper than 32 levels reject the file.
- Types are strict, with no coercion: `"12"` is not a number, `"true"` is not a boolean, a string is not a list and a list is not a string.
- An unknown key warns and is ignored. An unknown enum value in `view` or `power-button` is ignored.
- All URLs are `https`, except where a field says otherwise.
- An invalid card is skipped alone with a warning. An invalid section is ignored whole with a warning, and its values are withdrawn. Only the four aliased `provider` fields fall back to a header ([Provider](#provider)).

> [!WARNING]
> Quote colors: `color: #336699` is a YAML comment. The value becomes empty and the key is ignored with a warning.

> [!TIP]
> Quote the keys `on` and `off` in `power-labels`. YAML 1.1 tools read them as booleans.

### Localized text

Every `name`, `text`, `title`, `label` and `hint` is a plain string or a locale map. The client takes the exact tag (`pt-br`), then the language (`pt`), then `en`, then the first entry. Tags are case-insensitive. A map with an empty or non-string entry is invalid.

```yaml
cards:
  - id: welcome
    type: note
    text:
      en: Welcome back.
      pt-BR: Bem-vindo de volta.
      ru: С возвращением.
```

## Ownership

- Provided values apply without confirmation while their profile is current, tagged "From provider".
- A setting the user changes stops following the provider; its tag offers "Return to provider".
- "Return settings to provider" in application settings resets every setting, the user's overrides of general, DNS and TUN options, and changes to provider apps.
- When the current profile stops providing a value, for example after switching profiles, a setting that still follows the provider returns to the user's previous value.
- Omitting a section, or a key in it, withdraws its value ([Metadata lifetime](README.md#metadata-lifetime)).
- Only [`policy`](#policy) sets limits the user cannot lift.

## Sections

### Provider

`provider` describes the service. Text fields take a plain string or a locale map; limits are in characters.

| Key | Type | Shown as |
| --- | --- | --- |
| `name` | text, 160 | Service name on the dashboard card and in the import dialog. |
| `logo` | url | Logo on the simple dashboard. |
| `logo-dark` | url | Logo in the dark theme. Falls back to `logo`. |
| `support-url` | url | Support action. Also accepts `https://t.me/…`, `https://telegram.me/…` and `tg://` links, such as `tg://resolve?domain=…`. |
| `web-url` | url | Website action. |
| `type` | text, 32 | Badge in the import dialog and profile list: `test`, `promo` or `dev`. Other values show none. |
| `hide-url` | boolean | Masks the URL in the profile editor and import dialog. It does not make the URL secret. |
| `server-group` | text, 256 | Proxy group whose selected node the simple dashboard shows. Matched case-insensitively. |
| `announce` | `{text, url}` | Description. `text` is multiline, 1024. Shown in the import dialog and in a dashboard card above the widgets that the user can neither move nor remove. `url` is the link on the card. |
| `notice` | `{text, url}` | Dismissible dashboard notice. `text` is multiline, 1024. A dismissal is remembered for that exact text and link; a change shows it again. |
| `renew` | `{url, days}` | Renew action, offered from `days` left (1–3650). |
| `top-up` | `{url, percent}` | Top-up action, offered from `percent` of quota used (1–100). |

An out-of-range `days` or `percent` is dropped with a warning; the `url` still applies. To remove a message, remove its key.

Four fields fall back to a standard header when the manifest does not set them: `support-url`, `web-url` (`profile-web-page-url`), `announce` and `hide-url` ([Aliases](headers.md#aliases)). The manifest wins when it sets the field. If the whole `provider` section is invalid, these four still fall back.

```yaml
provider:
  notice:
    text: |
      Maintenance on 1 November, 02:00–03:00 UTC.
      Connections may drop.
    url: https://status.example.net
```

### Reminders

`reminders` sets when ReClash notifies about expiry and traffic.

| Key | Value | Effect |
| --- | --- | --- |
| `expire-days` | Integers 0–365, at most 8 | Days before expiry that trigger a notification. Default `[3, 2, 1]`. |
| `traffic-percent` | Integers 1–100, at most 8 | Percent of quota used that triggers a notification. Default `[90]`. |

- Reminders need `Subscription-Userinfo`. Expiry reminders are skipped for `expire=0`, traffic reminders for `total=0`, and none fires while a usage field is stale.
- Each threshold notifies once per expiry date. A traffic threshold re-arms when usage drops below it.
- The notification action is top-up for a traffic reminder (when `top-up.percent` is unset or reached), otherwise renew (when `renew.days` is unset or reached), otherwise support.
- On the dashboard, renew appears from `renew.days` left, or from the largest expiry threshold if `days` is unset. Top-up appears from `top-up.percent` used, or from the lowest traffic threshold if unset.

```yaml
reminders:
  expire-days: [7, 3, 1]
  traffic-percent: [80, 95]
```

### Settings

`settings` sets app settings. Only listed keys are touched: `true` turns a setting on, `false` is an explicit off, and an unlisted key keeps the user's value.

| Key | Setting | Effect |
| --- | --- | --- |
| `minimize-on-exit` | Minimize on exit | Closing the window minimizes the app. |
| `launch-at-login` | Auto launch | Starts the app at login. |
| `start-hidden` | Silent launch | Starts without showing the window. |
| `connect-on-launch` | Auto run | Starts the proxy when the app opens. |
| `check-app-updates` | Auto check for updates | Checks for app updates. |
| `capture-logs` | Logcat | Captures logs. Off hides the logs entry. |
| `close-connections` | Close connections | Drops open connections when the proxy changes. |

```yaml
settings:
  connect-on-launch: true
  close-connections: true
```

### Policy

`policy` sets limits the user cannot lift. Every key is optional; the default leaves the user free. Details and the body side of each limit are in [Safety policy](policy.md).

| Key | Values | Effect |
| --- | --- | --- |
| `global` | `any` (default), `listed`, `off` | `listed` limits GLOBAL traffic to the nodes of the body's `GLOBAL` group ([details](policy.md#only-listed-nodes-in-global)). `off` removes Global mode in the app and the Core; a Global profile switches to Rule ([details](policy.md#no-global)). |
| `apps` | `recommended` (default), `required` | `required` makes `tun.exclude-package` mandatory on Android ([details](policy.md#apps-that-must-stay-outside-the-vpn)). |
| `local-ports` | `open` (default), `closed` | Android only. `closed` closes every local proxy port (mixed, HTTP, SOCKS, redir, TProxy), makes the web dashboard unavailable, and sends the app's own requests directly. It also applies under `apps: required` ([details](policy.md#no-local-proxy-ports)). |
| `dashboard` | `editable` (default), `locked` | `locked` removes editing on both dashboards ([details](policy.md#locked-dashboard)). |

An invalid value withdraws the whole `policy` section with a warning.

```yaml
policy:
  global: off
  dashboard: locked
```

### Apps

`apps` offers Android app lists. They are recommendations: the user can take them back. To make exclusions mandatory, set [`policy.apps: required`](policy.md#apps-that-must-stay-outside-the-vpn).

| Key | Effect |
| --- | --- |
| `exclude` | Recommended exclusions from the tunnel, together with `tun.exclude-package` in the config. |
| `include` | Recommended inclusions, together with `tun.include-package` in the config. |
| `routing` | `domestic` or `domestic:<cc>`. Adds installed apps known as domestic for the app's region, or for `<cc>`. Ignored when the region has no list. |

`exclude` and `include` are lists of Android package names: at most 255 characters per name, and over 512 names invalidates the field. An invalid name is dropped alone, with a warning.

How they combine with the user's access control:

| Access control | Provider apps applied |
| --- | --- |
| Off | Recommended and required exclusions, if any, turn on blacklist mode with just those apps. |
| Blacklist | Recommended exclusions the user did not take back, and required exclusions, are added to the user's list. |
| Whitelist | Recommended inclusions the user did not take back are added to the user's list. Required exclusions are removed from it. |

Modes never mix: recommended inclusions are ignored in blacklist mode, and recommended exclusions in whitelist mode. Provider apps carry the "From provider" tag in Access control. Unticking one takes it back; "Return apps to provider" resets that. When the effective list changes, Android asks for a VPN restart.

```yaml
apps:
  exclude: [com.example.bank, ru.example.gov]
  routing: domestic
```

### Transport

`transport` names other hosts for the subscription. It works only for `https` subscriptions ([Fallback hosts](request.md#fallback-hosts)).

| Key | Value |
| --- | --- |
| `fallback-hosts` | List of up to 5 `host[:port]`. Lowercased; a leading `https://` and trailing `/` are dropped. One invalid entry invalidates the field. |
| `new-domain` | One `host[:port]` string, not a list. |

```yaml
transport:
  fallback-hosts: [sub2.example.net, sub3.example.org:8443]
  new-domain: sub.example.com
```

### Support

`support` enables signed fix links and direct report upload ([Support reports](support.md)).

| Key | Value |
| --- | --- |
| `keys` | At most two `ed25519:…` public keys, for [signed fix links](support.md#key). |
| `upload-url` | `https` URL that receives [support reports](support.md#receiving-reports). |

Both are replaced on every update. They need consent: the app names the upload domain before the first upload.

```yaml
support:
  keys: ["ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik"]
  upload-url: https://support.example.net/reclash/reports
```

### View

`view` sets how the proxy list and the app look. It takes the groups `proxies` and `app`; unknown keys and values are ignored.

| Key | Values |
| --- | --- |
| `proxies.type` | `tab`, `list` |
| `proxies.sort` | `none`, `delay`, `name` |
| `proxies.layout` | `loose`, `standard`, `tight` |
| `proxies.icon` | `filled`, `plain`, `hidden` |
| `proxies.card` | `loose`, `standard`, `compact`, `oneline` |
| `app.navbar` | `floating`, `docked` |
| `app.tabs` | `slide`, `fade` |
| `app.glass` | `none`, `standard`, `ultra` |
| `app.color` | Quoted `RRGGBB` or `AARRGGBB`, optional `#` |
| `app.color-dark` | Same as `app.color`. Replaces it in the dark theme; ignored without `app.color`. |
| `app.style` | `vivid`, `tinted`, `soft`, `monochrome` |
| `app.black` | Boolean |

`app.glass` is the requested quality. Sustained rendering overload can lower the effective quality for the current session without changing the saved setting or its provider ownership; the notification offers to restore it.

`view`, `power-button`, `wallpaper` and `widgets` are the only source of appearance; no header sets it. Values are tagged "From provider" and yield to the user ([Ownership](#ownership)).

```yaml
view:
  app:
    color: "#336699"
    style: tinted
  proxies:
    type: list
    sort: delay
```

### Power button

`power-button` styles the running power button of the simple dashboard. Users have no setting for it.

| Key | Values | Default |
| --- | --- | --- |
| `shape` | One shape name, a list of names, or `random` | `cookie` |
| `type` | `solid`, `tonal`, `outline` | `solid` |

Shapes: `cookie`, `circle`, `scallop`, `sunny`, `flower`, `clover`, `burst`, `puffy`, `puffyDiamond`, `clover8Leaf`, `cookie4Sided`, `cookie6Sided`, `verySunny`, `square`, `diamond`, `pentagon`, `gem`, `pixelCircle`, `softBoom`, `boom`, `sharpBurst`.

- Names are case-insensitive. Unknown shapes are ignored and duplicates add no chance. With no known shape, the button is `cookie`.
- `random` means every shape, and only as the whole value.
- A list is a pool: one shape is picked uniformly and holds for the app session, until the profile or the valid shapes change.

```yaml
power-button:
  shape: [puffy, clover8Leaf]
  type: outline
```

### Wallpaper

`wallpaper` sets the app background image.

| Key | Values | Default |
| --- | --- | --- |
| `url` | `https` image URL. Required: without it the section is invalid. | — |
| `opacity` | Integer 1–100 | 8 |

The image is downloaded once per URL and cached.

```yaml
wallpaper:
  url: https://cdn.example.net/wallpaper.webp
  opacity: 12
```

### Widgets

`widgets` is the list of dashboard cards in display order.

Tokens: `currentOutbound`, `health`, `networkSpeed`, `outboundMode`, `vpnButton` (Android), `networkTakeover` (desktop), `serviceStatus`, `profiles`, `proxyGroups`, `connectionStats`, `intranetIp`, `memoryInfo`.

- Tokens are case-insensitive. Unknown tokens are ignored; with no known token, the dashboard is unchanged.
- `currentOutbound` is added first when missing.
- The simple dashboard uses the listed `outboundMode`, `serviceStatus` and `health`; with none listed, it is unchanged.
- `provider.announce` is not a widget: its card shows above the widgets whenever it is set, and cannot be listed, moved or removed.

```yaml
widgets: [outboundMode, serviceStatus, health]
```

### Cards

`cards` is a list of at most 8 cards, shown above the widgets in file order. Cards past the eighth are dropped with a warning. Every card has the common keys:

| Key | Values |
| --- | --- |
| `id` | Required. Unique, matching `[a-z0-9._:#-]{1,64}`. |
| `type` | Required: `banner`, `note`, `actions`. |
| `when` | Optional [condition](#conditions). |
| `dismissible` | Boolean, default `false`. The dismissal is remembered for the exact content of the card; changing the card shows it again. |

A key the card type does not have warns and is ignored. Limits: `title` 80 characters, `text` 280, `label` 32; a `copy` value is at most 256 bytes and a `share` value 1024 bytes.

#### Actions

A card, a button and an `actions` item carry at most one action key. Several keys, or an invalid value, invalidate the card.

| Key | Effect |
| --- | --- |
| `url` | Opens an `http`, `https` or Telegram link, at most 2048 characters. |
| `copy` | Copies the text. |
| `share` | Opens the system share sheet on Android; copies the text elsewhere. |
| `app` | Runs a fixed in-app action. |

`app` values:

| Value | Effect | Hidden when |
| --- | --- | --- |
| `support` | Opens the provider's support link. | No valid `provider.support-url`. |
| `website` | Opens the provider's web page. | No valid `provider.web-url`. |
| `renew` | Opens the plan purchase link. | No valid `provider.renew`. |
| `topUp` | Opens the traffic purchase link. | No valid `provider.top-up`. |
| `updateProfile` | Updates the current profile. | — |
| `speedTest` | Opens the speed test. | — |
| `doctor` | Opens the Doctor. | — |
| `updateApp` | Opens the update sheet. | — |

A hidden action removes its `actions` item, and a card-level action stops being tappable. No action changes a setting, imports a subscription, or starts or stops the connection.

#### Banner

| Key | Values |
| --- | --- |
| `layout` | `hero` (default), `split`, `strip`, `image` |
| `title`, `text` | Localized text |
| `image`, `image-dark` | `https` image URL. `image-dark` is used in the dark theme. |
| `side` | `start`, `end` (default). The image side in `split`. |
| `tone` | `surface` (default), `primary`, `secondary`, `tertiary` |
| `countdown` | Unix seconds. Shows the time left until then. |
| `button` | `{label, <action>}`. A card with a button is not tappable itself. |
| `url`, `copy`, `share`, `app` | The action of the whole card. |

An `image` banner is the image alone and needs one.

```yaml
cards:
  - id: strip
    type: banner
    layout: strip
    tone: tertiary
    text: Maintenance tonight at 02:00 UTC.
    url: https://status.example.net
```

#### Note

| Key | Values |
| --- | --- |
| `text` | Required, localized |
| `level` | `info` (default), `warning`, `critical` |
| `url`, `copy`, `share`, `app` | The action of the whole card |

```yaml
cards:
  - id: low-traffic
    type: note
    level: warning
    text: Traffic is almost used up.
    app: topUp
```

#### Actions card

`items` is a list of 2–6 entries.

| Key | Values |
| --- | --- |
| `icon` | Required name. |
| `label` | Required, localized |
| `url`, `copy`, `share`, `app` | Exactly one |

Icons: `support`, `help`, `chat`, `speed`, `link`, `open`, `copy`, `share`, `refresh`, `update`, `sync`, `info`, `warning`, `star`, `bolt`, `key`, `lock`, `gift`, `sparkle`, `web`, `website`, `globe`, `send`, `telegram`, `download`, `doctor`, `tools`, `clock`, `renew`, `account`. An unknown name shows a neutral icon.

```yaml
cards:
  - id: help
    type: actions
    items:
      - { icon: support, label: Support, app: support }
      - { icon: telegram, label: Channel, url: "https://t.me/example" }
```

### Conditions

`when` shows a card only while every listed key holds. Without `when`, the card is always shown.

| Key | Holds when |
| --- | --- |
| `from` | Now is at or after this Unix time. |
| `until` | Now is before this Unix time. |
| `days-left-below` | The subscription has an expiry and fewer whole days remain. |
| `traffic-above` | The used share of a non-zero total is at least this percent. |
| `platforms` | The platform is in the list: `android`, `windows`, `macos`, `linux`. |
| `client-below` | The app version is lower than this version. |

- Usage conditions never hold on stale usage data.
- `client-below` only reaches clients that have this feature: older clients do not read the file.
- Times switch on their own while the app is open.

```yaml
cards:
  - id: update-hint
    type: note
    text: A new app version is out.
    app: updateApp
    when:
      client-below: 1.5.0
      platforms: [android]
```

### Power labels

`power-labels` replaces the title under the power button. States: `off`, `connecting`, `on`, `paused`, and for the plan: `expired` (the plan ended, connected or not), `exhausted` (the traffic ran out), `ending` (the plan nears its end by the `reminder` thresholds), `grace` (connected on a plan that ended). Problems the app found itself, such as no network or a broken connection, always keep the app's own title. Each state takes one of:

- a string or a locale map,
- `{title, hint}`, where each part may be a locale map,
- a list of these: one entry is picked per app session.

| Part | Limit |
| --- | --- |
| `title` | 64 characters |
| `hint` | 96 characters |

Entries outside the limits are dropped; a state with none left uses the localized label.

Placeholders: `{daysLeft}`, `{trafficLeft}`, `{server}`. A placeholder without a value makes the whole entry fall back to the localized label. A `hint` is shown only where the button offers no action under the title: not on `on`, where the live connection line stays, and not beside a Renew or Top up button. Labels never change semantics, color or shape.

```yaml
power-labels:
  connecting:
    en: Connecting to {server}
    ru: Подключение к {server}
  paused:
    title: Paused
    hint: Tap to resume
```

### Routing

`routing` offers auto-routing profiles and scenarios. Their syntax is in [Profiles](../auto-routing/profiles.md) and [Scenarios](../auto-routing/scenarios.md). The subscription body carries no routing keys, so it stays valid for other Clash clients.

| Key | Value |
| --- | --- |
| `profiles` | Map of profile name to profile. |
| `scenarios` | Map of scenario name to scenario. |
| `scenario` | Name of the default scenario. |
| `bindings` | Map of proxy-group name to binding, below. |

A profile is addressed as `provider/<name>`. `extends` may name `builtin/<name>` or another provider profile.

```yaml
routing:
  profiles:
    fast-de:
      rcx: 1
      title: Fast Germany
      prefer:
        - { label: Germany, when: 'country = DE' }
        - { label: Anything, when: 'not dead' }
  bindings:
    Proxy: { profiles: [fast-de], default: fast-de }
```

#### Group binding

| Key | Value |
| --- | --- |
| `profiles` | Profile names offered for the group. |
| `default` | Profile used until the user chooses. |
| `chips` | Up to 12 one-tap pools: `{label, include}`, where `include` is a [condition](../auto-routing/conditions.md). |
| `pool` | `{include, exclude}` conditions that narrow the group's servers. |
| `prefer` | Server order replacing the profile's own for this group. A scenario program's `prefer` beats it. |
| `feel` | Switching temper: `calm`, `balanced` or `eager` ([How the engine works](../auto-routing/engine.md)). |
| `energy` | Check budget: `eco`, `balanced` or `precise`. |

A binding addresses its group by name. A binding to a group the config lacks is a warning in the Subscription inspector, and a group renamed in the body silently loses its binding until the manifest is updated.

#### Provider limits

| Limit | Rule |
| --- | --- |
| Pool | A provider binding can only narrow a group's pool. |
| `direct-split` | Ignored from a provider; only the user can turn it on. |
| Size | A profile or scenario is at most 64 KiB. |
| Third-party hosts | A profile or scenario whose checks, diagnostics or echo services contact a host outside the provider's site needs user consent. The provider's site is the registrable domain of the subscription host; built-in profile endpoints are always allowed. Until consent, the group runs `builtin/simple`. |
| Choice | Profiles and scenarios are offers: the user picks a profile per group and a scenario, or turns auto control off. |

#### Validation

```sh
dart run tool/rcx.dart lint reclash.yaml
```

The linter accepts a profile, a scenario, a document with `profiles` or `scenarios`, or a manifest with `routing`. In the app, the Core reports an invalid or missing provider profile in the group or scenario status.

## Images

- `image` and `image-dark` are `https` only: PNG, JPEG or WebP, at most 2 MiB. SVG is not supported.
- Images are cached for a day. A failed refresh keeps the cached copy.
- A banner whose image fails shows its text. An `image` banner without a working image shows nothing.

> [!NOTE]
> An image request exposes the user's IP address to the image host, and a per-user URL identifies the viewer. The client sends no telemetry of its own.

## Boundaries

- A provider can set only the settings on this page, the [update interval](headers.md#update-interval), and the routing offers in [Routing](#routing).
- Nothing in the manifest triggers reports, telemetry or uploads on its own.
- `provider.hide-url` masks the URL; it does not protect it.
- Package exclusions do not cover the same service opened in a browser.
