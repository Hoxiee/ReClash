# 提供商清单

提供商清单是一个静态 YAML 文件，由提供商为所有用户统一托管一份，并通过 `reclash-config` 响应头指向它。它承载 ReClash 在标准响应头之外展示或应用的全部内容：提供商面板、提醒、设置、策略、Android 应用、传输、支持、外观、卡片和路由。订阅正文仍是纯 mihomo 配置。

## 快速开始

**1. 编写 `reclash.yaml`。**

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

**2. 托管并指向它。** 把文件放到任意静态 HTTPS 主机上，并在订阅响应中添加一个响应头：

```http
reclash-config: https://example.net/reclash.yaml
```

**3. 检查。** 在 ReClash 中更新配置，然后打开 配置 → 配置菜单 → 订阅检查器（[订阅检查器](rollout.md#subscription-inspector)）。检查器没有警告时，清单即已生效。

所有部分都是可选的。按需添加；下面的完整示例用到了全部部分。

## 完整示例

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
seasonal:
  calendar: default
  effects:
    - { effect: confetti, from: "12-31", to: "01-01", colors: ["#336699"] }
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
chains:
  - name: Via Frankfurt
    hops: [DE entry, NL exit]
    fingerprints:
      - { type: vless, server: de1.example.net, port: 443 }
      - { type: vless, server: nl1.example.net, port: 443 }
```

## 在编辑器中校验

该 schema 随文档一同发布。在第一行加入下面的注释，带有 YAML 语言服务器的编辑器就会校验并补全该文件：

```yaml
# yaml-language-server: $schema=https://reclash.pages.dev/schemas/provider-config.schema.json
version: 1
```

在 CI 中：

```sh
uvx check-jsonschema --schemafile https://reclash.pages.dev/schemas/provider-config.schema.json reclash.yaml
```

schema 比应用更严格：应用遇到未知键会给出警告并忽略，schema 则直接拒绝。源文件为 [`provider-config.schema.json`](../../../provider-config.schema.json)。

## 分发

- `reclash-config: <https url>` 仅在 `https` 响应中有效。重定向必须落在 `https` URL 上。
- 文件最大 512 KiB。其中的单个配置或场景最大 64 KiB。支持 `ETag` 和 `304 Not Modified`。
- 它随订阅更新一同拉取，限时 8 秒（更新剩余时间不足时更短）。
- 位于订阅同源的清单会收到订阅请求头。其他来源只收到 `User-Agent`、`Accept` 和 `Accept-Language`；设备 ID 绝不会离开订阅来源。
- 已存储的副本在完整校验后整体替换。拉取失败或内容无效时保留上一份有效副本，且绝不会导致更新失败。
- 省略 `reclash-config` 会删除已存储的副本。新的有效副本中缺失的部分会被撤回（[归属](#ownership)）。
- 副本与配置存放在一起，Core 从中读取 `routing`。备份不包含它：恢复后，这些部分在下次更新前都不存在。
- 拉取和校验警告会显示在[订阅检查器](rollout.md#subscription-inspector)中。

## 格式

- `version: 1` 为必填。任何其他值都会使文件被拒绝。
- 键使用 kebab-case。锚点、别名、重复键、非字符串键以及超过 32 层的嵌套都会使文件被拒绝。
- 类型严格，不做强制转换：`"12"` 不是数字，`"true"` 不是布尔值，字符串不是列表，列表也不是字符串。
- 未知键会给出警告并被忽略。`view` 或 `power-button` 中的未知枚举值会被忽略。
- 除非字段另有说明，所有 URL 均为 `https`。
- 无效的卡片会被单独跳过并给出警告。无效的部分会整体忽略并给出警告，其值也会被撤回。只有 `provider` 中带别名的四个字段会回退到响应头（[提供商](#provider)）。

> [!WARNING]
> 颜色要加引号：`color: #336699` 是 YAML 注释。值会变为空，该键会被忽略并给出警告。

> [!TIP]
> 在 `power-labels` 中给键 `on` 和 `off` 加引号。YAML 1.1 工具会把它们读作布尔值。

### 本地化文本

每个 `name`、`text`、`title`、`label` 和 `hint` 都是纯字符串或语言映射。客户端依次选取精确标签（`pt-br`）、语言（`pt`）、`en`，最后是第一个条目。标签不区分大小写。含有空条目或非字符串条目的映射无效。

```yaml
cards:
  - id: welcome
    type: note
    text:
      en: Welcome back.
      pt-BR: Bem-vindo de volta.
      ru: С возвращением.
```

## 归属

- 提供的值在其配置为当前配置期间无需确认即可生效，并带有“来自服务商”标记。
- 用户修改过的设置不再跟随提供商；其标记会提供“交还给服务商”。
- 应用设置中的“将设置交还给服务商”会重置所有设置、用户对常规、DNS 和 TUN 选项的覆盖，以及对提供商应用的更改。
- 当前配置不再提供某个值时（例如切换配置之后），仍跟随提供商的设置会回到用户之前的值。
- 省略某个部分或其中的某个键，会撤回其值（[元数据生命周期](README.md#metadata-lifetime)）。
- 只有 [`policy`](#policy) 会设置用户无法解除的限制。

## 各部分

### Provider

`provider` 描述服务。文本字段接受纯字符串或语言映射；限制以字符计。

| 键 | 类型 | 显示为 |
| --- | --- | --- |
| `name` | 文本，160 | 仪表盘卡片和导入对话框中的服务名称。 |
| `logo` | url | 简易仪表盘和配置卡片上的徽标。 |
| `logo-dark` | url | 深色主题下的徽标。回退到 `logo`。 |
| `support-url` | url | 支持操作。也接受 `https://t.me/…`、`https://telegram.me/…` 和 `tg://` 链接，例如 `tg://resolve?domain=…`。 |
| `web-url` | url | 网站操作。 |
| `type` | 文本，32 | 导入对话框和配置列表中的徽章：`test`、`promo` 或 `dev`。其他值不显示徽章。 |
| `hide-url` | 布尔值 | 在配置编辑器和导入对话框中遮盖 URL。它不会让 URL 变成机密。 |
| `server-group` | 文本，256 | 简易仪表盘显示其所选节点的代理组；用户的代理链也会在其中提供。匹配时不区分大小写。 |
| `announce` | `{text, url}` | 说明。`text` 可多行，1024。显示在导入对话框中，以及位于小组件上方、用户既不能移动也不能移除的仪表盘卡片中。`url` 是卡片上的链接。 |
| `notice` | `{text, url}` | 可关闭的仪表盘通知。`text` 可多行，1024。关闭操作按该确切文本和链接记忆；任一变化都会让它再次显示。 |
| `renew` | `{url, days}` | 续费操作，从剩余 `days` 天起提供（1–3650）。 |
| `top-up` | `{url, percent}` | 充值操作，从配额已用 `percent` 起提供（1–100）。 |

超出范围的 `days` 或 `percent` 会被丢弃并给出警告；`url` 仍然生效。要移除某条消息，删除其键即可。

当清单未设置时，有四个字段会回退到标准响应头：`support-url`、`web-url`（`profile-web-page-url`）、`announce` 和 `hide-url`（[别名](headers.md#aliases)）。清单设置了该字段时以清单为准。即使整个 `provider` 部分无效，这四个字段仍会回退。

```yaml
provider:
  notice:
    text: |
      Maintenance on 1 November, 02:00–03:00 UTC.
      Connections may drop.
    url: https://status.example.net
```

### Reminders

`reminders` 设置 ReClash 何时通知到期和流量情况。

| 键 | 值 | 效果 |
| --- | --- | --- |
| `expire-days` | 0–365 的整数，最多 8 个 | 到期前触发通知的天数。默认 `[3, 2, 1]`。 |
| `traffic-percent` | 1–100 的整数，最多 8 个 | 触发通知的配额已用百分比。默认 `[90]`。 |

- 提醒需要 `Subscription-Userinfo`。`expire=0` 时跳过到期提醒，`total=0` 时跳过流量提醒，用量字段过期时也不会触发任何提醒。
- 每个阈值在每个到期日期只通知一次。流量用量降到阈值以下时，该流量阈值会重新生效。
- 通知的操作：流量提醒为充值（当 `top-up.percent` 未设置或已达到时），否则为续费（当 `renew.days` 未设置或已达到时），否则为支持。
- 在仪表盘上，续费从剩余 `renew.days` 天起出现；若未设置 `days`，则从最大的到期阈值起出现。充值从已用 `top-up.percent` 起出现；若未设置，则从最低的流量阈值起出现。

```yaml
reminders:
  expire-days: [7, 3, 1]
  traffic-percent: [80, 95]
```

### Settings

`settings` 设置应用设置。只会改动列出的键：`true` 打开设置，`false` 明确关闭，未列出的键保留用户的值。

| 键 | 设置 | 效果 |
| --- | --- | --- |
| `minimize-on-exit` | 退出时最小化 | 关闭窗口时将应用最小化。 |
| `launch-at-login` | 开机自启 | 登录时启动应用。 |
| `start-hidden` | 静默启动 | 启动时不显示窗口。 |
| `connect-on-launch` | 自动运行 | 应用打开时启动代理。 |
| `check-app-updates` | 更新偏好 › 自动检查 | 检查应用更新。 |
| `capture-logs` | Logcat | 捕获日志。关闭时隐藏日志入口。 |
| `close-connections` | 关闭连接 | 代理变化时断开已打开的连接。 |

```yaml
settings:
  connect-on-launch: true
  close-connections: true
```

### Policy

`policy` 设置用户无法解除的限制。每个键都是可选的；默认让用户自由选择。详情及各限制在正文一侧的写法见[安全策略](policy.md)。

| 键 | 值 | 效果 |
| --- | --- | --- |
| `global` | `any`（默认）、`listed`、`off` | `listed` 将 GLOBAL 流量限制在正文 `GLOBAL` 组的节点内（[详情](policy.md#only-listed-nodes-in-global)）。`off` 在应用和 Core 中移除全局模式；全局配置会切换为规则模式（[详情](policy.md#no-global)）。 |
| `apps` | `recommended`（默认）、`required` | `required` 使 Android 上的 `tun.exclude-package` 成为强制项（[详情](policy.md#apps-that-must-stay-outside-the-vpn)）。 |
| `local-ports` | `open`（默认）、`closed` | 仅限 Android。`closed` 会关闭所有本地代理端口（mixed、HTTP、SOCKS、redir、TProxy），使 Web 仪表盘不可用，并让应用自身的请求直连。在 `apps: required` 下同样生效（[详情](policy.md#no-local-proxy-ports)）。 |
| `dashboard` | `editable`（默认）、`locked` | `locked` 会移除两种仪表盘上的编辑功能（[详情](policy.md#locked-dashboard)）。 |

无效的值会连同警告一起撤回整个 `policy` 部分。

```yaml
policy:
  global: off
  dashboard: locked
```

### Apps

`apps` 提供 Android 应用列表。它们只是建议：用户可以收回。若要使排除成为强制项，请设置 [`policy.apps: required`](policy.md#apps-that-must-stay-outside-the-vpn)。

| 键 | 效果 |
| --- | --- |
| `exclude` | 建议从隧道中排除的应用，与配置中的 `tun.exclude-package` 合并生效。 |
| `include` | 建议纳入的应用，与配置中的 `tun.include-package` 合并生效。 |
| `routing` | `domestic` 或 `domestic:<cc>`。添加已安装的、在应用所在地区（或 `<cc>`）已知为国内的应用。该地区没有列表时忽略。 |

`exclude` 和 `include` 是 Android 包名列表：每个名称最多 255 个字符，超过 512 个名称则整个字段无效。无效的名称会被单独丢弃并给出警告。

它们与用户访问控制的组合方式：

| 访问控制 | 应用的提供商应用 |
| --- | --- |
| 关闭 | 如有建议排除和强制排除，会开启黑名单模式，仅包含这些应用。 |
| 黑名单 | 用户未收回的建议排除以及强制排除，会加入用户的列表。 |
| 白名单 | 用户未收回的建议纳入会加入用户的列表。强制排除会从中移除。 |

模式不会混用：黑名单模式下忽略建议纳入，白名单模式下忽略建议排除。提供商应用在访问控制中带有“来自服务商”标记。取消勾选即为收回；“将应用交还给服务商”会重置它。有效列表变化时，Android 会请求重启 VPN。

```yaml
apps:
  exclude: [com.example.bank, ru.example.gov]
  routing: domestic
```

### Transport

`transport` 为订阅指定其他主机。它仅适用于 `https` 订阅（[备用主机](request.md#fallback-hosts)）。

| 键 | 值 |
| --- | --- |
| `fallback-hosts` | 最多 5 个 `host[:port]` 的列表。转为小写；开头的 `https://` 和结尾的 `/` 会被去掉。一个无效条目会使整个字段无效。 |
| `new-domain` | 一个 `host[:port]` 字符串，不是列表。 |

```yaml
transport:
  fallback-hosts: [sub2.example.net, sub3.example.org:8443]
  new-domain: sub.example.com
```

### Support

`support` 启用已签名的修复链接和直接上传报告（[支持报告](support.md)）。

| 键 | 值 |
| --- | --- |
| `keys` | 最多两个 `ed25519:…` 公钥，用于[已签名的修复链接](support.md#key)。 |
| `upload-url` | 接收[支持报告](support.md#receiving-reports)的 `https` URL。 |

两者在每次更新时都会被替换。它们需要用户同意：首次上传前，应用会指明上传域名。

```yaml
support:
  keys: ["ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik"]
  upload-url: https://support.example.net/reclash/reports
```

### View

`view` 设置代理列表和应用的外观。它包含 `proxies` 和 `app` 两组；未知的键和值会被忽略。

| 键 | 值 |
| --- | --- |
| `proxies.type` | `tab`、`list` |
| `proxies.sort` | `none`、`delay`、`name` |
| `proxies.layout` | `loose`、`standard`、`tight` |
| `proxies.icon` | `filled`、`plain`、`hidden` |
| `proxies.card` | `loose`、`standard`、`compact`、`oneline` |
| `app.navbar` | `floating`、`docked` |
| `app.glass` | `none`、`standard`、`ultra` |
| `app.color` | 加引号的 `RRGGBB` 或 `AARRGGBB`，`#` 可选 |
| `app.color-dark` | 与 `app.color` 相同。在深色主题中替代它；没有 `app.color` 时忽略。 |
| `app.style` | `vivid`、`tinted`、`soft`、`monochrome` |
| `app.black` | 布尔值 |
| `app.seasonal` | 布尔值。打开或关闭“季节特效”主题设置。 |

`app.glass` 是请求的质量。持续的渲染过载可能在当前会话中降低实际质量，但不会改变已保存的设置及其提供商归属；通知中会提供恢复选项。

`view`、`power-button`、`wallpaper`、`seasonal` 和 `widgets` 是外观的唯一来源；没有任何响应头可以设置外观。这些值带有“来自服务商”标记，并让位于用户（[归属](#ownership)）。

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

`power-button` 设置简易仪表盘上运行中电源按钮的样式。用户没有对应的设置。

| 键 | 值 | 默认 |
| --- | --- | --- |
| `shape` | 一个形状名称、名称列表，或 `random` | `cookie` |
| `type` | `solid`、`tonal`、`outline` | `solid` |

形状：`cookie`、`circle`、`scallop`、`sunny`、`flower`、`clover`、`burst`、`puffy`、`puffyDiamond`、`clover8Leaf`、`cookie4Sided`、`cookie6Sided`、`verySunny`、`square`、`diamond`、`pentagon`、`gem`、`pixelCircle`、`softBoom`、`boom`、`sharpBurst`。

- 名称不区分大小写。未知形状会被忽略，重复项不会增加概率。没有任何已知形状时，按钮为 `cookie`。
- `random` 表示所有形状，且只能作为整个值使用。
- 列表是一个池：均匀随机选取一个形状，并在应用会话期间保持，直到配置或有效形状发生变化。

```yaml
power-button:
  shape: [puffy, clover8Leaf]
  type: outline
```

### Wallpaper

`wallpaper` 设置应用的背景图片。

| 键 | 值 | 默认 |
| --- | --- | --- |
| `url` | `https` 图片 URL。必填：缺少时该部分无效。 | — |
| `opacity` | 1–100 的整数 | 8 |

每个 URL 的图片只下载一次并缓存。用户可以用自己的图片替换它，但不能将其关闭：提供商设置了背景期间，它是图库中的第一个图块，移除用户当前使用的图片后会恢复提供商的图片。

```yaml
wallpaper:
  url: https://cdn.example.net/wallpaper.webp
  opacity: 12
```

### Seasonal effects

`seasonal` 会在选定日期于应用内容后方添加粒子特效，例如雪花、彩纸或爱心。客户端还内置了日历，用户可以通过“季节特效”主题设置关闭整个功能；`view.app.seasonal` 设置的就是这个开关。

| 键 | 值 | 默认 |
| --- | --- | --- |
| `calendar` | `default`、`none`。`none` 会为此订阅关闭客户端内置的日历。 | `default` |
| `effects` | 最多 16 个特效的列表；多余的条目会被忽略并给出警告 | — |

每个特效接受以下键：

| 键 | 值 | 默认 |
| --- | --- | --- |
| `effect` | `snow`、`lights`、`stars`、`leaves`、`petals`、`confetti`、`hearts`。必填。 | — |
| `from` | `MM-DD` 或 `YYYY-MM-DD`，包含该日。必填。 | — |
| `to` | 形式与 `from` 相同，包含该日。必填。 | — |
| `density` | `low`、`medium`、`high` | `medium` |
| `colors` | 1–8 个加引号的 `RRGGBB` 颜色，`#` 可选；它们会替代特效自带的调色板 | — |

- 日期为设备的本地日期。在 YAML 中给 `MM-DD` 值加引号，使其保持为字符串。
- `MM-DD` 范围每年重复，且可以跨过新年，例如 `12-31` 到 `01-01`。带年份的范围只生效一次，`from` 和 `to` 必须使用相同形式，且不得倒序。
- 内置日历在 12 月 1 日至 2 月 29 日显示轻雪，在 12 月 20 日至 1 月 14 日显示更密的雪和节日彩灯，在 10 月 1 日至 11 月 10 日显示落叶，在 4 月 1 日至 5 月 10 日显示花瓣。
- 在其覆盖的日子里，提供商的特效会替代日历中同类的特效。
- 同时最多显示三层特效；优先保留提供商的特效。
- 开启“减少动态效果”时，特效会停止并静止，用户关闭该设置时则绝不显示。
- 无效的特效会被跳过并给出警告。无效的部分（例如形状错误或 `calendar` 值未知）会整体忽略。

```yaml
seasonal:
  calendar: default
  effects:
    - effect: confetti
      from: "12-31"
      to: "01-01"
      density: high
      colors: ["#336699", "#FFCC00"]
```

### Widgets

`widgets` 是仪表盘卡片的列表，按显示顺序排列。

标记：`currentOutbound`、`health`、`networkSpeed`、`outboundMode`、`vpnButton`（Android）、`networkTakeover`（桌面）、`serviceStatus`、`profiles`、`proxyGroups`、`connectionStats`、`intranetIp`、`memoryInfo`。

- 标记不区分大小写。未知标记会被忽略；没有任何已知标记时，仪表盘保持不变。
- 缺少 `currentOutbound` 时会首先添加它。
- 简易仪表盘使用列出的 `outboundMode`、`serviceStatus` 和 `health`；一个都没列出时保持不变。
- `provider.announce` 不是小组件：只要设置了它，其卡片就显示在小组件上方，且不能被列出、移动或移除。

```yaml
widgets: [outboundMode, serviceStatus, health]
```

### Cards

`cards` 是最多 8 张卡片的列表，按文件顺序显示在小组件上方。第八张之后的卡片会被丢弃并给出警告。每张卡片都有以下通用键：

| 键 | 值 |
| --- | --- |
| `id` | 必填。唯一，匹配 `[a-z0-9._:#-]{1,64}`。 |
| `type` | 必填：`banner`、`note`、`actions`。 |
| `when` | 可选的[条件](#conditions)。 |
| `dismissible` | 布尔值，默认 `false`。关闭操作按卡片的确切内容记忆；修改卡片后会再次显示。 |

卡片类型不具备的键会给出警告并被忽略。限制：`title` 80 个字符，`text` 280，`label` 32；`copy` 值最多 256 字节，`share` 值最多 1024 字节。

#### Actions

卡片、按钮和 `actions` 条目最多带有一个操作键。出现多个键或值无效，都会使该卡片无效。

| 键 | 效果 |
| --- | --- |
| `url` | 打开 `http`、`https` 或 Telegram 链接，最多 2048 个字符。 |
| `copy` | 复制文本。 |
| `share` | 在 Android 上打开系统分享面板；在其他平台复制文本。 |
| `app` | 执行固定的应用内操作。 |

`app` 的值：

| 值 | 效果 | 隐藏条件 |
| --- | --- | --- |
| `support` | 打开提供商的支持链接。 | 没有有效的 `provider.support-url`。 |
| `website` | 打开提供商的网页。 | 没有有效的 `provider.web-url`。 |
| `renew` | 打开套餐购买链接。 | 没有有效的 `provider.renew`。 |
| `topUp` | 打开流量购买链接。 | 没有有效的 `provider.top-up`。 |
| `updateProfile` | 更新当前配置。 | — |
| `speedTest` | 打开测速。 | — |
| `doctor` | 打开 Doctor。 | — |
| `updateApp` | 打开更新面板。 | — |

被隐藏的操作会移除其 `actions` 条目，卡片级操作则不再可点击。没有任何操作会更改设置、导入订阅，或启动、停止连接。

#### Banner

| 键 | 值 |
| --- | --- |
| `layout` | `hero`（默认）、`split`、`strip`、`image` |
| `title`、`text` | 本地化文本 |
| `image`、`image-dark` | `https` 图片 URL。深色主题使用 `image-dark`。 |
| `side` | `start`、`end`（默认）。`split` 中图片所在的一侧。 |
| `tone` | `surface`（默认）、`primary`、`secondary`、`tertiary` |
| `countdown` | Unix 秒数。显示距该时间的剩余时间。 |
| `button` | `{label, <action>}`。带按钮的卡片本身不可点击。 |
| `url`、`copy`、`share`、`app` | 整张卡片的操作。 |

`image` 横幅只有图片，且必须提供图片。

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

| 键 | 值 |
| --- | --- |
| `text` | 必填，本地化文本 |
| `level` | `info`（默认）、`warning`、`critical` |
| `url`、`copy`、`share`、`app` | 整张卡片的操作 |

```yaml
cards:
  - id: low-traffic
    type: note
    level: warning
    text: Traffic is almost used up.
    app: topUp
```

#### Actions card

`items` 是 2–6 个条目的列表。

| 键 | 值 |
| --- | --- |
| `icon` | 必填名称。 |
| `label` | 必填，本地化文本 |
| `url`、`copy`、`share`、`app` | 恰好一个 |

图标：`support`、`help`、`chat`、`speed`、`link`、`open`、`copy`、`share`、`refresh`、`update`、`sync`、`info`、`warning`、`star`、`bolt`、`key`、`lock`、`gift`、`sparkle`、`web`、`website`、`globe`、`send`、`telegram`、`download`、`doctor`、`tools`、`clock`、`renew`、`account`。未知名称显示中性图标。

```yaml
cards:
  - id: help
    type: actions
    items:
      - { icon: support, label: Support, app: support }
      - { icon: telegram, label: Channel, url: "https://t.me/example" }
```

### Conditions

`when` 仅在列出的每个键都成立时才显示卡片。没有 `when` 时，卡片始终显示。

| 键 | 成立条件 |
| --- | --- |
| `from` | 当前时间不早于此 Unix 时间。 |
| `until` | 当前时间早于此 Unix 时间。 |
| `days-left-below` | 订阅有到期时间，且剩余整天数少于此值。 |
| `traffic-above` | 在总量非零时，已用比例不低于此百分比。 |
| `platforms` | 当前平台在列表中：`android`、`windows`、`macos`、`linux`。 |
| `client-below` | 应用版本低于此版本。 |

- 用量数据过期时，用量条件绝不成立。
- `client-below` 只会触达具备此功能的客户端：更旧的客户端不会读取该文件。
- 应用打开期间，时间条件会自动切换。

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

`power-labels` 替换电源按钮下方的标题。状态有 `off`、`connecting`、`on`、`paused`，以及与套餐相关的：`expired`（套餐已结束，无论是否已连接）、`exhausted`（流量已用尽）、`ending`（按 `reminder` 阈值，套餐临近结束）、`grace`（在已结束的套餐上保持连接）。应用自己发现的问题（例如无网络或连接中断）始终保留应用自带的标题。每个状态接受以下之一：

- 字符串或语言映射，
- `{title, hint}`，其中每个部分都可以是语言映射，
- 上述形式的列表：每个应用会话选取其中一个条目。

| 部分 | 限制 |
| --- | --- |
| `title` | 64 个字符 |
| `hint` | 96 个字符 |

超出限制的条目会被丢弃；若某个状态一个条目都不剩，则使用本地化标签。

占位符：`{daysLeft}`、`{trafficLeft}`、`{server}`。占位符没有值时，整个条目回退到本地化标签。`hint` 仅在按钮没有在标题下方提供操作的位置显示：不在 `on` 上显示（那里保留实时连接行），也不显示在续费或充值按钮旁。标签绝不会改变语义、颜色或形状。

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

`routing` 提供自动路由配置和场景。其语法见[配置](../auto-routing/profiles.md)和[场景](../auto-routing/scenarios.md)。订阅正文不含路由键，因此对其他 Clash 客户端仍然有效。

| 键 | 值 |
| --- | --- |
| `profiles` | 配置名称到配置的映射。 |
| `scenarios` | 场景名称到场景的映射。 |
| `scenario` | 默认场景的名称。 |
| `bindings` | 代理组名称到下文绑定的映射。 |

配置以 `provider/<name>` 寻址。`extends` 可以指定 `builtin/<name>` 或另一个提供商配置。

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

| 键 | 值 |
| --- | --- |
| `profiles` | 为该组提供的配置名称。 |
| `default` | 用户做出选择之前使用的配置。 |
| `chips` | 最多 12 个一键池：`{label, include}`，其中 `include` 是[条件](../auto-routing/conditions.md)。 |
| `pool` | 用于收窄该组服务器的 `{include, exclude}` 条件。 |
| `prefer` | 替代配置自身的、针对该组的服务器顺序。场景程序的 `prefer` 优先于它。 |
| `feel` | 切换性格：`calm`、`balanced` 或 `eager`（[引擎如何工作](../auto-routing/engine.md)）。 |
| `energy` | 检测预算：`eco`、`balanced` 或 `precise`。 |

绑定按名称寻址其组。绑定到配置中不存在的组，会在订阅检查器中给出警告；而正文中被重命名的组会悄悄失去其绑定，直到清单更新。

#### Provider limits

| 限制 | 规则 |
| --- | --- |
| 池 | 提供商的绑定只能收窄组的池。 |
| `direct-split` | 来自提供商时被忽略；只有用户可以打开它。 |
| 大小 | 配置或场景最大 64 KiB。 |
| 第三方主机 | 若配置或场景的检测、诊断或回显服务会联系提供商站点之外的主机，则需要用户同意。提供商站点指订阅主机的可注册域名；内置配置的端点始终允许。在同意之前，该组运行 `builtin/simple`。 |
| 选择 | 配置和场景只是提议：用户为每个组选择配置并选择场景，或关闭自动控制。 |

#### Validation

```sh
dart run tool/rcx.dart lint reclash.yaml
```

该 linter 接受配置、场景、含有 `profiles` 或 `scenarios` 的文档，或含有 `routing` 的清单。在应用中，Core 会在组或场景状态中报告无效或缺失的提供商配置。

### Chains

`chains` 提供将流量依次经过订阅自身两到三个节点或组的路由，入口在前。用户可在 代理 → 链 中的“服务商提供”下看到它们，可以打开或关闭，也可以将其复制为自己的链来编辑。

```yaml
chains:
  - name: Via Frankfurt
    hops: [DE entry, NL exit]
    target-group: Proxy
    fingerprints:
      - { type: vless, server: de1.example.net, port: 443 }
      - null
```

| 键 | 值 |
| --- | --- |
| `name` | 文本，64。该链在运行配置中的组名；在该部分内唯一。 |
| `hops` | 订阅中节点或组的两到三个名称，入口在前。 |
| `target-group` | 提供该链的组。缺省时为主组（[`server-group`](#provider)）。 |
| `offered` | `false` 使该链不在任何组中提供，仅用于路由规则。默认 `true`。 |
| `fingerprints` | 每一跳一个条目：`{type, server, port}`，没有指纹的跳用 `null`。 |

指纹指明一跳所代表的节点。订阅重命名该节点时，链会跟随到 `type`、`server` 和 `port` 都相同的那个唯一节点；找不到或有多个时，链保持损坏，直到清单被修复。没有 `fingerprints` 时，被重命名的跳会使链损坏。

- 最多 16 条链。无效的链会被单独跳过并给出警告，重复的名称同样如此。
- 链只能使用订阅所包含的内容，因此不会增加自己的目的地。
- 用户自己的同名链优先；此时提供商的链会被报告为名称冲突。

## 图片

- `image` 和 `image-dark` 仅限 `https`：PNG、JPEG 或 WebP，最大 2 MiB。不支持 SVG。
- 图片缓存一天。刷新失败时保留缓存副本。
- 图片加载失败的横幅会显示其文本。没有可用图片的 `image` 横幅什么也不显示。

> [!NOTE]
> 图片请求会向图片主机暴露用户的 IP 地址，每用户专属的 URL 会识别出查看者。客户端自身不发送任何遥测。

### 配置徽标

客户端在添加配置时一次性选定配置卡片上的徽标，并取第一个可用的：

1. `logo` 和 `logo-dark`。
2. 订阅页面在浏览器中打开时自行声明的徽标：其 `og:image`、图标链接，或面板的品牌徽标。
3. 来自 `web-url` 页面的图标；未设置 `web-url` 时，来自订阅主机 `https` 根路径的图标：该站点上的 `apple-touch-icon` 和 `icon` 链接，然后是 `/apple-touch-icon.png`。
4. `support-url` 所指向 Telegram 页面的 `og:image`。
5. 配置名称的字母组合图标。

- 徽标仅限 `https`，最大 512 KiB，格式为平台可解码的格式或 SVG。小于 48 px 的站点和 Telegram 图标会被跳过。
- 站点图标只来自页面自己的站点，因此不会询问任何第三方图标服务。Telegram 图片只来自 Telegram 的主机。
- 徽标及其主色会随配置一起存储。之后的更新不会再次打开提供商的页面；只有当 `logo` 和 `logo-dark` 的链接变化时才会重新拉取它们，因此提供商通过清单更换徽标。主色用于为卡片背景着色；文字保持中性。本地配置和自定义配置保持中性。
- 这些请求不携带设备 ID 和 `Authorization`。唯一的 Cookie 是面板自己的会话 Cookie，它被送回该面板以读取其品牌信息。

## 边界

- 提供商只能设置本页列出的设置、[更新间隔](headers.md#update-interval)、[Routing](#routing) 中的路由提议，以及 [Chains](#chains) 中的路由。
- 清单中的任何内容都不会自行触发报告、遥测或上传。
- `provider.hide-url` 会遮盖 URL；它不保护 URL。
- 包排除不涵盖在浏览器中打开的同一服务。
