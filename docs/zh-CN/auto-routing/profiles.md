# 配置

**配置**是某个智能组的策略：允许使用哪些服务器、优先顺序、如何排序，以及引擎在多大程度上主动切换。它是一个不超过 64 KiB 的 YAML 文档。

标有 `# fragment` 的示例有意不完整；其他示例均为完整配置，并可通过 [`rcxlint`](sharing.md#rcxlint-工具) 检查。

目录：[最简配置](#最简配置) · [键参考](#键参考) · [键详解](#键详解) · [默认值](#默认值一览) · [限制](#限制) · [继承](#extends) · [内置配置](#内置配置)

## 最简配置

```yaml
rcx: 1
title: Anything that works
```

未设置 `prefer` 时，配置只有一个步骤“Working”（条件 `not dead`），组会保留任何可用服务器。其他键用于进一步调整行为。

## 键参考

未知键会报错，因此拼写错误会在导入时发现，而不会被忽略。

| 键 | 类型 | 默认值 | 作用 |
| --- | --- | --- | --- |
| `rcx` | 整数 | 外部文档必填 | 格式版本。当前为 `1`；更高版本会因应用不支持而拒绝。 |
| `title` | 字符串 | 无 | 列表中显示的名称。 |
| `description` | 字符串 | 无 | 一到两句话说明用途和适用场景。 |
| `level` | `simple` 或 `advanced` | `simple` | 复杂度标签及请求预算级别（每小时 30 或 80 次）。 |
| `extends` | 配置 ID | 无 | 继承其他配置，最多 4 层。 |
| `pool` | `{include, exclude}` | 所有服务器 | 组可以使用的服务器。 |
| `tags` | 名称 → 条件映射 | 无 | 可在 `pool` 和 `prefer` 中以 `tag(name)` 使用的命名条件，最多 32 个。 |
| `prefer` | 步骤列表 | 单步 `not dead` | 服务器顺序（阶梯），最多 16 步。 |
| `rank` | `{by, tolerance}` | `latency`、0 | 同一步骤内的服务器排序方式。 |
| `switch` | 对象 | `balanced` 预设 | 何时从可用服务器切换。 |
| `stranded` | 字符串 | `hold` | 没有服务器符合条件时的操作。 |
| `energy` | `eco`、`balanced`、`precise` | `balanced` | 允许执行多少检查。 |
| `checks` | ID → 检查映射 | 无 | `passes(id)` / `fails(id)` 使用的命名测试，最多 8 个。 |
| `network` | `{diagnose, kinds}` | 无 | 网络探测和网络类型。 |
| `on` | 类型 → 覆盖项映射 | 无 | 按网络类型覆盖设置，最多 8 种。 |
| `direct-split` | 条件 | 关闭 | 何时将本地流量直连。仅限用户层。 |
| `egress-verify` | `{echo, agree}` | Cloudflare 和 ipinfo，2 | 如何验证出口国家。 |
| `l10n` | 语言 → 字符串映射 | 无 | 标题、说明和标签的翻译。 |

## 键详解

### `rcx`

格式版本。

```yaml
rcx: 1
title: Versioned
```

值高于 `1` 时会报错：“profile format N is newer than this app understands”。

### `title` 和 `description`

显示在行为列表中的纯文本。标题和说明通过 `l10n` 翻译。

```yaml
rcx: 1
title: Quiet Europe
description: Keeps one European server and rarely changes it. Good for a laptop on battery.
pool:
  include: country in [DE, NL, FI]
```

### `level`

`simple`（默认）或 `advanced`。简单配置每小时最多 30 个请求，进阶配置最多 80 个（参见[能耗](engine.md#检查何时运行与能耗预算)）。包含检查和诊断的内置配置为 `advanced`。

```yaml
rcx: 1
title: Checked
level: advanced
checks:
  chat: { http: 'https://api.telegram.org/', expect: [200, 301, 302, 404] }
prefer:
  - label: Opens chat
    when: passes(chat)
  - label: Anything
    when: not dead
```

### `extends`

按 ID 继承其他配置：`builtin/x`、`provider/x` 或 `user/x`。不带前缀的名称表示 `provider/x`。继承链最多 4 层。

```yaml
rcx: 1
title: Stable, Norway first
extends: builtin/stable
prefer:
  - label: Norway
    when: country = NO
  - label: Anything
    when: not dead
```

合并规则见下文 [Extends](#extends)。

### `pool`

服务器要可用，`include` 必须成立且 `exclude` 不成立。两者都使用[条件](conditions.md)。若事实未知，条件会允许服务器通过。各层只能缩小节点池：子配置的 `include` 与父配置通过 `and` 组合，`exclude` 通过 `or` 组合。

```yaml
rcx: 1
title: Europe, no test servers
pool:
  include: country in [DE, NL, SE, FI, NO]
  exclude: name ~ /(?i)test|demo/
```

### `tags`

为可重复使用的条件命名。通过 `tag(name)` 引用标签。标签条件本身不能调用 `tag()`，因此标签之间不能相互依赖。

```yaml
rcx: 1
title: Prefer mobile-friendly
tags:
  lte: 'name ~ /(?i)lte|mobile/'
prefer:
  - label: LTE nodes
    when: tag(lte) and not dead
  - label: Anything
    when: not dead
```

### `prefer`

服务器顺序。每一步包含 `label`（在应用中显示；无标签时显示为“Tier N”）、`when` 条件和可选的 `last-resort` 标记。第一个包含可用服务器的步骤获胜；若其中服务器都不可用，则进入下一步。

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

`last-resort: true` 会将步骤标为最终回退项。只有其他所有步骤都没有可用服务器时才会采用它，即使其他步骤写在它之后也一样：引擎会在编译时将最后回退步骤移到其他步骤之后，并保持它们之间的顺序。此类步骤为空时，工作台也不会警告。

用户或场景的 `prefer` 会替换该组的此列表（参见[服务器顺序优先级](scenarios.md#服务器顺序优先级)）。

### `rank`

同一优先步骤内的服务器排序方式。

| 字段 | 值 | 默认值 | 含义 |
| --- | --- | --- | --- |
| `by` | `latency`、`stability` | `latency` | `latency` 优先速度；`stability` 会更重地惩罚波动和历史故障（参见[得分](engine.md#第四步排序)）。 |
| `tolerance` | 整数，单位 ms | `0` | 当前服务器获得此容差，因此挑战节点必须明显更好。 |

```yaml
rcx: 1
title: Steady
rank:
  by: stability
  tolerance: 100
```

### `switch`

引擎何时可以离开一个*可用*服务器。故障服务器始终会被替换。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `improve` | 布尔值，默认 `false` | 是否可从可用服务器切换到同一步骤内表现更好的服务器。为 false 时仅故障切换。 |
| `feel` | `calm`、`balanced`、`eager` | 下表其余五项的预设，默认 `balanced`。 |
| `dwell` | 时长（`10m`、`1h30m`） | 主动切换之间的最短间隔。 |
| `min-gain-ms` | 整数 | 挑战节点至少快这么多毫秒。 |
| `min-gain-pct` | 整数 | ……且至少比当前得分好这么多百分比。 |
| `confirm` | 整数 | 切换前必须有多少条新鲜测量超过门槛。 |
| `max-per-hour` | 整数 | 每小时主动切换次数上限。 |

| feel | dwell | min-gain-ms | min-gain-pct | confirm | max-per-hour |
| --- | --- | --- | --- | --- | --- |
| `calm` | 30 分钟 | 60 | 30 | 3 | 2 |
| `balanced` | 10 分钟 | 30 | 20 | 2 | 4 |
| `eager` | 2 分钟 | 15 | 10 | 2 | 8 |

显式指定的值会覆盖预设。

```yaml
rcx: 1
title: Eager but not twitchy
switch:
  improve: true
  feel: eager
  max-per-hour: 3
```

### `stranded`

没有服务器符合条件时的操作：`hold`（保留当前服务器，默认）、`direct`（使用 `DIRECT`）或 `group:<name>`（使用另一个组）。

```yaml
rcx: 1
title: Fall back to direct
stranded: direct
```

### `energy`

`eco`、`balanced`（默认）或 `precise`，设置每小时检查额度（参见[预算](engine.md#预算)）。

```yaml
rcx: 1
title: Frugal
energy: eco
```

### `checks`

命名测试。每项必须且只能指定 `http`、`tcp`、`tls` 之一，并可带其他字段。

| 字段 | 适用类型 | 含义 |
| --- | --- | --- |
| `http` | HTTP | `http://` 或 `https://` URL。 |
| `tcp` | TCP | 用于连接的 `host:port`。 |
| `tls` | TLS | 用于 TLS 握手的 `host:port`。 |
| `sni` | TLS | 要发送的服务器名称。 |
| `expect` | 仅 HTTP | 接受的状态码列表，范围为 100–599。 |
| `optional` | 全部 | 失败视为“软失败”：检查既不算通过，也不算失败。 |

使用 `passes(id)` 和 `fails(id)` 引用检查。最多 8 项。

```yaml
rcx: 1
title: Must open the video site
level: advanced
checks:
  video: { http: 'https://www.youtube.com/generate_204', expect: [204] }
  chat: { tcp: 'api.telegram.org:443', optional: true }
prefer:
  - label: Opens video and chat
    when: passes(video) and passes(chat)
  - label: Opens video
    when: passes(video)
  - label: Anything
    when: not dead
```

每项检查对每个成员都会消耗一次请求，应尽量少用，并将额外检查设为 `optional`。

### `network`

为行为不同的网络（如强制门户、移动网络白名单）声明探测和网络类型。

`diagnose` 将名称映射到一组同类型目标（`http`、`tcp` 或 `tls`）。任意目标响应即视为诊断成功。最多 8 项诊断，每项最多 4 个目标。诊断名称须为小写，符合 `[a-z0-9-]`，长度 1–24 个字符。

`kinds` 是自上而下检查的列表；第一个成立的 `when` 会确定当前网络类型。设置 `pause: true` 的类型会暂停组。最多 8 种类型。

```yaml
rcx: 1
title: Knows about whitelists
level: advanced
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443', '77.88.8.1:443'] }
    foreign: { tls: ['1.1.1.1:443', '9.9.9.9:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: whitelist, when: 'home ok and foreign fail' }
    - { kind: open, when: 'foreign ok' }
```

### `on`

按网络类型覆盖设置。允许项：`pool`、`prefer`、`rank`、`switch`、`stranded`、`energy`。类型必须在 `network.kinds` 中声明，否则配置会被拒绝。

```yaml
rcx: 1
title: Different on a whitelist network
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: whitelist, when: 'home ok and foreign fail' }
prefer:
  - label: Anything
    when: not dead
on:
  whitelist:
    prefer:
      - label: Bypass node
        when: name ~ /(?i)bypass|whitelist/ and not dead
      - label: Anything
        when: not dead
```

### `direct-split`

网络条件。条件成立时，第一个由用户启用直连分流的智能组会将本地流量直连。只有用户层可以启用；服务商配置不能开启。参见[直连分流](engine.md#直连分流)。

```yaml
rcx: 1
title: Split when only home works
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
direct-split: 'home fail and foreign ok'
```

### `egress-verify`

`exit.country` 出口国家验证方式。

| 字段 | 默认值 | 含义 |
| --- | --- | --- |
| `echo` | `https://www.cloudflare.com/cdn-cgi/trace`、`https://ipinfo.io/json` | HTTP(S) echo 服务，最多 4 个。 |
| `agree` | `2` | 必须报告相同国家的来源数：1–3。 |

```yaml
rcx: 1
title: Verified exit
level: advanced
egress-verify:
  echo:
    - https://www.cloudflare.com/cdn-cgi/trace
    - https://ipinfo.io/json
  agree: 2
prefer:
  - label: Really abroad
    when: exit.country != RU and not dead
  - label: Anything
    when: not dead
```

如果自定义 echo 主机由服务商提供，则需要用户授权（参见[授权](engine.md#服务商配置的授权)）。

### `l10n`

按语言标签（`ru`、`zh-CN`）指定翻译。每项将*源文本*（英文标题、说明或步骤标签）映射到翻译。最多 16 种语言，每种最多 64 个字符串，每个字符串最多 160 个字符。应用显示用户所用语言，没有翻译时使用源文本。

```yaml
rcx: 1
title: Fast Germany
prefer:
  - label: Germany
    when: country = DE
  - label: Anything
    when: not dead
l10n:
  ru:
    Fast Germany: Быстрая Германия
    Germany: Германия
    Anything: Любой
```

## 默认值一览

| 设置 | 默认值 |
| --- | --- |
| `level` | `simple` |
| `prefer` | 单步“Working”，条件 `not dead` |
| `rank.by` | `latency`，容差 `0` |
| `switch.feel` | `balanced`，`improve` 为 false |
| `stranded` | `hold` |
| `energy` | `balanced` |
| `egress-verify.agree` | `2` |
| 未选择其他配置时的组配置 | `builtin/simple` |

## 限制

| 限制项 | 数值 |
| --- | --- |
| 配置大小 | 64 KiB |
| 条件长度 | 2048 个字符，嵌套深度 16 |
| 正则表达式 | 512 个字符 |
| `prefer` 步骤 | 16 |
| 标签 | 32 |
| 检查 | 8 |
| 网络诊断数 / 每项目标数 | 8 / 4 |
| 网络类型、`on` 类型 | 8 |
| Echo 服务 | 4 |
| 语言 / 每种语言字符串数 / 字符串长度 | 16 / 64 / 160 |
| `extends` 深度 | 4 |
| 组绑定中的 chips | 12 |

## Extends

子配置从父配置开始，只更改它显式声明的内容。

| 键 | 合并规则 |
| --- | --- |
| `pool` | `include` 以 `and` 合并，`exclude` 以 `or` 合并：子配置只能缩小节点池。 |
| `tags` | 按名称合并；冲突时子配置优先。 |
| `prefer` | 子配置的列表整体替换父配置列表。 |
| `switch` | 子配置中的 `feel` 会将其他切换设置重置为该预设值。 |
| `checks`、`network.diagnose`、`on`、`l10n` | 按键合并。 |
| `network.kinds` | 整体替换。 |
| 其他所有键 | 若子配置设置了值，则采用子配置的值。 |

## 层与绑定

配置通过 ID 归属某个层级：`builtin/x`、`provider/x`、`user/x`。组的**绑定**（由服务商或用户设置）会选择配置，也可添加以下设置：

| 绑定键 | 含义 |
| --- | --- |
| `profiles` | 为该组提供的配置 ID 列表。 |
| `default` | 用户选择前使用的配置。 |
| `profile` | 用户的选择。 |
| `pool`、`feel`、`energy` | 覆盖项；用户设置会替换服务商设置。 |
| `prefer` | 替换配置服务器顺序的规则。 |
| `chips` | 最多 12 个 `{label, include}` 快速筛选器，在应用中显示。 |

服务商如何提供这些内容，参见[共享](sharing.md)。

## 内置配置

内置配置随应用发布，包含所有支持语言的翻译，并始终可通过 `builtin/<name>` 使用。

| ID | 用途 |
| --- | --- |
| `builtin/simple` | 保持使用可用服务器；故障时切换。 |
| `builtin/fastest` | 追求最低延迟，积极切换。 |
| `builtin/stable` | 优先稳定服务器，很少切换。 |
| `builtin/from-list` | 与 simple 相同；供服务商手动排序的组使用。 |
| `builtin/bypass-ru` | 俄罗斯：优先选择可访问被屏蔽网站的境外服务器。 |
| `builtin/bypass-ir` | 伊朗：相同思路，并检查 YouTube。 |
| `builtin/bypass-cn` | 中国：相同思路，并检查 Google。 |
| `builtin/whitelist-ru` | 俄罗斯移动网络白名单：继承 `bypass-ru` 并增加绕过节点步骤。 |

### `builtin/simple`

```yaml
rcx: 1
title: Simple
level: simple
prefer:
  - label: Working
    when: not dead
rank:
  by: latency
  tolerance: 50
switch:
  improve: false
  feel: calm
stranded: hold
energy: balanced
```

（实际文件还包含 `description` 和 `l10n`。）保持使用可用服务器。在可用服务器中优先选择延迟最低者，但 `improve: false` 表示只有当前服务器故障时才切换。

### `builtin/fastest`

```yaml
rcx: 1
title: Fastest
rank:
  by: latency
  tolerance: 20
switch:
  improve: true
  feel: balanced
```

切换到明显更快的服务器（至少快 30 ms 且提升 20%）；须连续确认两次，每小时最多切换 4 次，且距上次切换至少 10 分钟。

### `builtin/stable`

```yaml
rcx: 1
title: Stable
rank:
  by: stability
  tolerance: 100
switch:
  improve: true
  feel: calm
```

稳定性得分会大幅惩罚波动和历史故障，`calm` 使切换较少发生。

### `builtin/from-list`

```yaml
rcx: 1
title: From the list
extends: builtin/simple
```

### `builtin/bypass-ru` 注释示例

```yaml
rcx: 1
title: Russia · bypass blocks
description: "For use in Russia: prefers servers abroad that open sites blocked at home, and uses a local exit only as a last resort."
level: advanced
checks:
  open: { http: 'https://api.telegram.org/', expect: [200, 301, 302, 404] }
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443', '77.88.8.1:443'] }
    foreign: { tls: ['1.1.1.1:443', '9.9.9.9:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: open, when: 'foreign ok' }
prefer:
  - { label: Opens blocked, when: 'passes(open) and exit.country != RU' }
  - { label: Abroad, when: 'not dead and exit.country != RU' }
  - { label: Home exit, when: 'not dead', last-resort: true }
rank: { by: latency, tolerance: 40 }
switch: { improve: true, feel: calm }
stranded: hold
direct-split: 'home fail and foreign ok'
energy: balanced
```

- `checks.open` 通过每台服务器访问 Telegram API。状态码为 200、301、302 或 404 时，表示服务器可访问在俄罗斯被屏蔽的网站。
- `network.diagnose` 不经过隧道，检查 Yandex DNS（`home`）是否响应，以及能否通过 TLS 访问 Cloudflare 和 Quad9（`foreign`）。
- 网络类型 `portal` 在强制门户出现时暂停组；`open` 表示境外互联网可访问。
- 阶梯依次尝试：可访问受限网站且已验证出口不在俄罗斯的服务器；任意可用的境外服务器；最后任意可用服务器。
- `exit.country` 在验证前为未知，因此尚未查询的服务器会处于待处理状态，规划器会安排查询。
- 如果用户启用了直连分流，当 `home fail and foreign ok` 条件成立时，会将本地流量直连。

`builtin/bypass-ir` 和 `builtin/bypass-cn` 结构相同。不同点包括检查 URL（伊朗使用 `https://www.youtube.com/generate_204` 并期望 204；中国使用 `https://www.google.com/generate_204` 并期望 204）、排除的国家代码（`IR`、`CN`），以及仅保留 `portal` 类型、不包含诊断和 `direct-split`。

### `builtin/whitelist-ru` 注释示例

```yaml
rcx: 1
title: Russia · mobile whitelists
level: advanced
extends: builtin/bypass-ru
tags:
  bypass: 'name ~ /(?i)lte|bypass|whitelist|обход|белы[ей]/'
network:
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: whitelist, when: 'home ok and foreign fail' }
    - { kind: open, when: 'foreign ok' }
on:
  whitelist:
    prefer:
      - { label: Bypass node, when: 'tag(bypass) and not dead' }
      - { label: Opens blocked, when: 'passes(open)' }
      - { label: Any working, when: 'not dead', last-resort: true }
```

- 继承 `bypass-ru` 的所有设置，并为名称中看起来像绕过节点的服务器添加 `bypass` 标签。
- 在 *whitelist* 网络（本地可用、境外互联网不可用）中，服务器顺序会变为：先选绕过节点，再选通过检查的任意节点，最后选任何可用节点。
- `network.kinds` 会整体替换父配置列表，因此需重新声明 `portal` 和 `open`。
