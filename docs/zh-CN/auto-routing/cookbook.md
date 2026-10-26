# 示例集

本节提供可直接使用的配置示例。每个示例包含目标、完整 YAML、逐行说明，以及在应用中的表现。除非特别说明，所有 YAML 代码块均可通过 [`rcxlint`](sharing.md#rcxlint-工具) 校验。要使用场景，请先导入（参见[共享](sharing.md)），再在路由中心中选择；要使用配置，请将其绑定到组。

示例假设服务器名称中带有国家旗帜或代码（大多数订阅如此）。如果没有，请使用 `name ~ /.../` 条件代替 `country`。

目录：[1 主流量与服务专用服务器](#1-主流量走挪威各服务使用不同服务器) · [2 阶梯选择](#2-阶梯先星标再国家最后任意可用节点) · [3 弱性能手机](#3-适用于低性能手机的省电稳定配置) · [4 移动网络与 Wi-Fi](#4-移动网络和-wi-fi-使用不同策略) · [5 服务商场景](#5-服务商分发场景) · [6 排除测试服务器](#6-排除测试服务器) · [7 固定和手动控制](#7-固定服务器和手动控制) · [8 导出含配置的场景包](#8-导出包含自有配置的场景包)

## 1. 主流量走挪威，各服务使用不同服务器

**目标。** 所有流量经挪威。YouTube 优先使用名称带闪电符号的俄罗斯服务器，其次任意俄罗斯服务器，最后任意可用服务器。Claude 走瑞典。Gemini 使用名称带 `*` 的服务器。所在国家的网站直连。

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

**逐项说明。**

- `groups.$main` 控制最终 `MATCH` 规则指向的主组；服务器顺序先选挪威，再选任何可用节点。
- 每条路由（`YouTube`、`Claude`、`Gemini`）都会创建一个带 `include-all` 的独立 `select` 组，因此能看到所有服务器；各自的 `prefer` 决定服务器顺序。路由规则会置于原配置规则之前。
- `name ~ /⚡/` 匹配名称中带闪电符号的服务器；`country = RU` 匹配俄罗斯服务器（名称中的国旗或代码）。`country = RU and name ~ /⚡/` 表示两项都要满足。
- Claude 路由同时匹配类别和域名：`GEOSITE,anthropic` 与 `DOMAIN-SUFFIX,claude.ai`。满足任意一项即可。
- Gemini 使用 `name ~ /\*/`：反斜杠让 `*` 在正则表达式中表示字面字符。
- `Local` 路由的目标为 `to: DIRECT`，因此不会创建组。它匹配 `category-ru`、`yandex` 和 `GEOIP,RU`（附带 `no-resolve`，避免规则触发 DNS 查询），并将流量直连。
- 路由顺序很重要：规则按此顺序添加到前面，第一条匹配规则生效。

**应用中的效果。** 路由中心会列出包含四条路由的场景。每条路由显示当前服务器和选中该服务器的步骤。“代理”页面会多出 `YouTube`、`Claude`、`Gemini` 三个组。路由仅在 rule 模式下生效；在 global 或 direct 模式下，路由中心会提示当前状态。

> [!NOTE]
> **截图 `cookbook-routes-hub`** —— 场景中心显示 YouTube、Claude、Gemini 和 Local 路由，并列出各自的当前服务器和选中步骤。

## 2. 阶梯：先星标，再国家，最后任意可用节点

**目标。** 优先使用名称带 `*` 的服务器，其次选择芬兰，最后选择任意可用服务器。

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

**逐项说明。**

- 步骤 1 `Starred`：`name ~ /\*/ and not dead`。名称带星号且未确认宕机。
- 步骤 2 `Finland`：`country = FI`。服务器名称表明位于芬兰。
- 步骤 3 `Anything`：`not dead`，并标记 `last-resort: true`。
- 引擎会采用第一个存在可用服务器的步骤。如果所有星标服务器都不可用，就采用步骤 2，以此类推。每个步骤内部选择速度最快的服务器。
- 将 `FI` 换成所需国家的代码。使用 ISO 两位代码，而不是国家名：写 `country = FI`，不要写 `country = Finland`。

`last-resort: true` 可确保 `Anything` 始终位于最后，即使以后在它后面添加步骤也是如此（参见[配置](profiles.md#prefer)）。

**应用中的效果。** 组的说明按步骤分组显示排序结果。当前服务器会显示步骤标签（`Starred`、`Finland` 或 `Anything`）及其被选中的原因。

> [!NOTE]
> **截图 `cookbook-ladder-ranking`** —— 组排序按 Starred、Finland、Anything 分组，并标出当前服务器。

## 3. 适用于低性能手机的省电稳定配置

**目标。** 少做检查、减少切换、保持服务器稳定。

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

**逐项说明。**

- `extends: builtin/stable` 继承稳定行为：按稳定性排序，容忍度为 100，切换策略为 calm。
- `energy: eco` 每小时允许 4 次维护检查，不进行发现，并允许 12 次恢复检查（参见[预算](engine.md#预算)）。
- `switch.feel: calm` 加上 `max-per-hour: 1`，每小时最多进行一次主动切换。服务器宕机时仍会立即替换。
- 无需额外设置：屏幕关闭时，引擎本来就不会检查服务器，除非实际流量发生故障。

**应用中的效果。** 路由中心显示“Eco”，组很少切换服务器。日志记录也很少。

## 4. 移动网络和 Wi-Fi 使用不同策略

**目标。** Wi-Fi 使用最快服务器；移动数据使用稳定服务器。

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

**逐项说明。**

- `network.kinds` 对网络分类。第一个成立的 `when` 决定类型：蜂窝网络为 `cell`，Wi-Fi 为 `wifi`。
- `groups.$main` 默认给主组使用 `builtin/fastest`。
- 当类型为 `cell` 时，`on.cell.groups.$main` 会替换该项，改用 `builtin/stable`。
- 网络类型需要连续两轮判断结果一致才会切换，因此短暂经过隧道不会改变策略。

**应用中的效果。** 场景状态会显示网络类型（`cell` 或 `wifi`），组配置也会随之切换。

## 5. 服务商分发场景

**目标。** 服务商通过订阅引用的配置包，分发一个配置及使用它的场景。

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

**逐项说明。**

- `profiles.fast-de` 是服务商配置，引用 ID 为 `provider/fast-de`。
- `scenarios.work` 让主组使用此配置，并将公司域名直接连接。
- `scenario: work` 将其设为默认场景。用户可以选择其他场景或关闭自动控制。
- 将配置包放在 `https` URL，并在订阅中声明：响应头 `reclash-routing: https://example.com/routing.yaml`，或正文行 `#reclash-routing: https://example.com/routing.yaml`。也可以直接将相同部分以内联形式写成 `rcx-profiles`、`rcx-scenarios` 和 `rcx-scenario`（参见[共享](sharing.md#服务商分发)）。
- 此配置不会访问第三方主机，因此不会显示授权提示。

**应用中的效果。** 订阅更新后，路由中心会提供标记为“来自服务商”的“Work”场景。选中后，路由会在下次应用配置时生效。

## 6. 排除测试服务器

**目标。** 即使作为最后手段，也绝不使用名称中带测试或试用字样的服务器。

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

**逐项说明。**

- `pool.exclude` 会将服务器彻底移出节点池，因此任何步骤都不会选中它。
- 条件将名称正则与标签组合起来。`tag(junk)` 读取下方定义的标签。
- `tags.junk` 匹配以“trial”开头的名称，忽略大小写（`^` 表示字符串开头）。
- 未知事实不会排除服务器，但名称条件始终是已知的。

服务商或场景也可以用相同方式缩小节点池，不能扩大节点池。

**应用中的效果。** 被排除的服务器仍显示在组排序中，但会变灰，并标注原因 `Excluded by pool`。

## 7. 固定服务器和手动控制

**目标。** 保持使用某个服务器，或完全停止引擎控制。

此示例使用界面控制，而非 YAML。组有三种控制方式。

| 操作 | 控制方式 | 结果 |
| --- | --- | --- |
| 点按智能组中的服务器 | 固定 | 引擎保持该服务器。如果它宕机或离开节点池，组会恢复 Auto 并提示你。 |
| 固定时选择“仅此网络” | 固定，仅限一个网络 | 在其他网络中会恢复 Auto。 |
| 为组选择 Manual | 手动 | 引擎不会切换该组的服务器，也不会为它执行检查。 |
| 选择 Auto | 自动 | 清除固定状态，交回配置控制。 |
| 点按“更换服务器” | 自动，当前服务器排除 15 分钟 | 强制切换服务器。 |

固定状态也优先于场景的固定目标。场景可通过程序将组固定到某个目标：

```yaml
rcx: 1
title: Hold the main group on one server
groups:
  $main:
    to: DIRECT
```

**应用中的效果。** 固定组会将该服务器标为“由你选择”，说明中显示原因 `hold.pinned`。日志会记录 `pin` 和 `auto` 事件。

> [!NOTE]
> **截图 `cookbook-pin-control`** —— 智能组面板显示 Auto、Pinned、Manual 控制方式，并突出固定的服务器。

## 8. 导出包含自有配置的场景包

**目标。** 将场景及其所需的配置一起发送给朋友。

你的设备上有一个名为 `streaming` 的场景，它使用配置 `streaming-fast`。导出场景时，由于它引用了非内置配置，导出结果为配置包：

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

**逐项说明。**

- `kind: bundle` 标记此文件；若无此字段，接收方会将它当作单个场景读取。
- `scenarios.streaming` 指向 `user/streaming-fast`，这是导出时配置使用的名称。
- `profiles.streaming-fast` 是配置本身。`extends: builtin/fastest` 保留为内置引用，每个应用副本都包含它。
- 导出时会按配置标题命名并修正引用。如果你有多个名为“Streaming fast”的配置，则会命名为 `streaming-fast`、`streaming-fast-2` 等。

导入后，朋友会得到场景和配置，并使用其库中尚未占用的名称。如果已有 `streaming-fast`，原配置不会改变；导入配置会命名为 `streaming-fast-2`，导入的场景也会更新为引用它。

`rcxlint` 和工作台均会按该文件当前形式检查它。

**应用中的效果。** 保存之前，导入审核页面会列出场景和配置，以及它们最终使用的名称。

> [!NOTE]
> **截图 `cookbook-bundle-import`** —— 导入审核页面列出一个场景和一个配置，并显示最终名称。
