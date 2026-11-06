# Hosted config

A static YAML file named by `reclash-config` that carries cards, power-button labels and appearance. It is presentation only.

## Purpose

- One file can serve every user: conditions and placeholders are evaluated in the client. A per-user file is a tokenized URL.
- It holds presentation only. Restrictions, policy, [settings flags](app-settings.md#settings-flags) and account fields stay in [headers](headers.md).
- The schema is [`provider-config.schema.json`](../../../provider-config.schema.json).

```yaml
version: 1
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
```

## Delivery

- The URL must be `https`, and the header counts only when it arrives in an `https` response. A redirect must end on an `https` URL.
- The file is at most 256 KiB. `ETag` and `304 Not Modified` are honored.
- It is fetched together with the subscription update, within 8 seconds (less when the update has less time left).
- A failed or invalid fetch keeps the last valid copy and never fails the update. A new copy replaces it only after full validation.
- Omitting `reclash-config` deletes the stored copy.
- Backups do not include the copy: after a restore the file's sections are absent until the next update.
- Fetch and validation warnings appear in the [Subscription inspector](rollout.md#subscription-inspector).

## Format

- `version: 1` is required. Any other value rejects the file.
- Anchors and aliases are rejected, and so are duplicate keys, non-string keys and nesting deeper than 32 levels.
- Types are strict, with no coercion: `"12"` is not a number, `"true"` is not a boolean.
- An unknown key warns and is ignored.
- An unknown enum value in `view` or `power-button` is ignored, as in the headers.
- An invalid card is skipped alone with a warning. An invalid section warns and the matching header stays in effect.

> [!WARNING]
> Quote colors: `color: #336699` is a YAML comment: the value becomes empty and the key is ignored with a warning.

> [!TIP]
> Quote the keys `on` and `off` in `power-labels`. YAML 1.1 tools read them as booleans.

### Precedence

The `view`, `power-button`, `wallpaper` and `widgets` sections are the only source of appearance; no header sets it. An invalid section is ignored with a warning. Ownership follows [Ownership](app-settings.md#ownership): values are tagged "From provider" and yield to the user.

### Localized text

Every `title`, `text`, `label` and `hint` is a plain string or a locale map. The client takes the exact tag (`pt-br`), then the language (`pt`), then `en`, then the first entry. Tags are case-insensitive. A map with an empty or non-string entry is invalid.

```yaml
cards:
  - id: welcome
    type: note
    text:
      en: Welcome back.
      pt-BR: Bem-vindo de volta.
      ru: С возвращением.
```

## Sections

### View

`view` takes the groups `proxies` and `app`. Unknown keys and values are ignored.

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

`app.glass` is the requested quality. Sustained rendering overload can lower the effective quality for the current session without changing the saved setting or its provider ownership. The notification offers to restore and keep the requested quality for the rest of the session.

### Power button

`power-button` styles the running power button of the simple dashboard. Users have no setting for it.

| Key | Values | Default |
| --- | --- | --- |
| `shape` | One shape name, a list of names, or `random` | `cookie` |
| `type` | `solid`, `tonal`, `outline` | `solid` |

Shapes: `cookie`, `circle`, `scallop`, `sunny`, `flower`, `clover`, `burst`, `puffy`, `puffyDiamond`, `clover8Leaf`, `cookie4Sided`, `cookie6Sided`, `verySunny`, `square`, `diamond`, `pentagon`, `gem`, `pixelCircle`, `softBoom`, `boom`, `sharpBurst`.

- Names are case-insensitive. Unknown shapes are ignored; duplicates add no chance. No known shape falls back to `cookie`.
- `random` means every shape, and only as the whole value.
- A list is a pool: one shape is picked uniformly and holds for the app session, until the profile or valid shapes change.

### Wallpaper

| Key | Values | Default |
| --- | --- | --- |
| `url` | `https` image URL. Required: without it the section is invalid. | — |
| `opacity` | Integer 1–100 | 8 |

The image is downloaded once per URL and cached.

### Widgets

`widgets` is a list of dashboard cards in display order.

Tokens: `currentOutbound`, `health`, `networkSpeed`, `outboundMode`, `vpnButton` (Android), `networkTakeover` (desktop), `serviceStatus`, `profiles`, `proxyGroups`, `connectionStats`, `intranetIp`, `memoryInfo`.

- Tokens are case-insensitive. Unknown tokens are ignored; with no known token, the dashboard is unchanged.
- `currentOutbound` is added first when missing.
- The simple dashboard uses the listed `outboundMode`, `serviceStatus` and `health`; with none listed, it is unchanged.
- `reclash-announce` is not a widget: its card shows above the widgets whenever the header is set, and cannot be listed, moved or removed.

### Cards

`cards` is a list of at most 8 cards, shown above the widgets in file order. Cards past the eighth are dropped with a warning. Every card has the common keys:

| Key | Values |
| --- | --- |
| `id` | Required. Unique, matching `[a-z0-9._:#-]{1,64}`. |
| `type` | Required: `banner`, `note`, `actions`. |
| `when` | Optional [condition](#conditions). |
| `dismissible` | Boolean, default `false`. The dismissal is remembered for the exact content of the card; changing the card shows it again. |

A key the card type does not have warns and is ignored.

Limits: `title` 80 characters, `text` 280, `label` 32. A `copy` value is at most 256 bytes and a `share` value 1024 bytes.

#### Actions

A card, a button, and an `actions` item carry at most one action key. Several keys, or an invalid value, invalidate the card.

| Key | Effect |
| --- | --- |
| `url` | Opens an `http`, `https` or Telegram link, at most 2048 characters. |
| `copy` | Copies the text. |
| `share` | Opens the system share sheet on Android; copies the text elsewhere. |
| `app` | Runs a fixed in-app action. |

`app` values:

| Value | Effect | Hidden when |
| --- | --- | --- |
| `support` | Opens the provider's support link. | No valid `reclash-supporturl`. |
| `website` | Opens the provider's web page. | No valid `reclash-webpageurl`. |
| `renew` | Opens the plan purchase link. | No valid `reclash-buyplan`. |
| `topUp` | Opens the traffic purchase link. | No valid `reclash-buytraffic`. |
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

#### Actions card

`items` is a list of 2–6 entries.

| Key | Values |
| --- | --- |
| `icon` | Required name. |
| `label` | Required, localized |
| `url`, `copy`, `share`, `app` | Exactly one |

Icons: `support`, `help`, `chat`, `speed`, `link`, `open`, `copy`, `share`, `refresh`, `update`, `sync`, `info`, `warning`, `star`, `bolt`, `key`, `lock`, `gift`, `sparkle`, `web`, `website`, `globe`, `send`, `telegram`, `download`, `doctor`, `tools`, `clock`, `renew`, `account`. An unknown name shows a neutral icon.

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

`power-labels` replaces the text under the power button. States: `off`, `connecting`, `on`, `paused`. Each state takes one of:

- a string or a locale map,
- `{title, hint}`, where each part may be a locale map,
- an array of these: one entry is picked per app session.

| Part | Limit |
| --- | --- |
| `title` | 64 characters |
| `hint` | 96 characters |

Entries outside the limits are dropped; a state with none left uses the localized label.

Placeholders: `{daysLeft}`, `{trafficLeft}`, `{server}`. A placeholder without a value makes the whole entry fall back to the localized label. A `hint` on `on` is not shown: the live connection line stays there. Labels never change semantics, color or shape.

```yaml
power-labels:
  connecting:
    en: Connecting to {server}
    ru: Подключение к {server}
  paused:
    title: Paused
    hint: Tap to resume
```

## Images

- `image` and `image-dark` are `https` only: PNG, JPEG or WebP, at most 2 MiB. SVG is not supported.
- Images are cached for a day. A failed refresh keeps the cached copy.
- A banner whose image fails shows its text. An `image` banner without a working image shows nothing.

> [!NOTE]
> An image request exposes the user's IP address to the image host, and a per-user URL identifies the viewer. The client sends no telemetry of its own.
