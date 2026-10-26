# 场景

**场景**是面向整个连接的自动路由。与管理单个组的[配置](profiles.md)不同，场景可以设置隧道模式、同时为多个组指定程序、按网络类型更改行为，并通过**路由**将选定流量发送到专属组。

标有 `# fragment` 的示例是不完整片段。其他示例均为完整场景，可通过 [`rcxlint`](sharing.md#rcxlint-工具) 校验。注意：`rcxlint` 根据顶层 `groups` 或 `mode` 键识别场景，因此仅包含路由的场景也需要提供 `groups`（例如 `groups: { $main: {} }`）才能被识别和检查。

目录：[结构](#场景结构) · [键](#键) · [组与程序](#组与程序) · [服务器顺序优先级](#服务器顺序优先级) · [模式](#模式) · [网络类型](#网络类型与-on) · [路由](#路由) · [匹配类型](#匹配类型) · [限制](#限制) · [保留名称](#保留名称) · [错误](#验证错误) · [标签与 l10n](#标签与-l10n)

## 场景结构

```yaml
rcx: 1
title: Evening streaming
description: Fastest servers for the main group and a Dutch pool for video.
mode: rule
groups:
  $main:
    profile: builtin/fastest
routes:
  - name: Video
    match: [GEOSITE,youtube]
    prefer:
      - label: Netherlands
        when: country = NL
      - label: Anything
        when: not dead
```

场景由用户选择，也可由服务商作为默认场景提供。未指定的组会保留自身配置（这是 `scenario` 保证）。

## 键

| 键 | 类型 | 默认值 | 含义 |
| --- | --- | --- | --- |
| `rcx` | 整数 | 1 | 格式版本。 |
| `title`、`description` | 字符串 | 无 | 显示在列表中；可通过 `l10n` 翻译。 |
| `tags` | 名称 → 条件映射 | 无 | 程序节点池的命名条件（最多 32 个）。场景标签不能使用 `tag()`。 |
| `network` | `{diagnose, kinds}` | 无 | 用于场景网络行为的探测和网络类型。格式与配置相同。 |
| `mode` | `rule`、`global`、`direct` | 空 | 场景期望的隧道模式。留空则保留用户设置。 |
| `groups` | 目标 → 程序映射 | 无 | 各组的程序（最多 32 项）。 |
| `routes` | 路由列表 | 无 | 具有专属组的流量匹配项（最多 32 条）。 |
| `on` | 网络类型 → `{mode, groups}` 映射 | 无 | 网络类型激活期间的覆盖设置。最多 8 种类型。 |
| `l10n` | 语言 → 字符串映射 | 无 | 标题、描述和标签的翻译。 |

场景文件最大为 64 KiB。

## 组与程序

`groups` 将一个**目标**映射到一个**程序**。

```yaml
rcx: 1
title: Targets
groups:
  $main: { profile: builtin/fastest }
  '*': { profile: builtin/stable }
  GLOBAL: { to: DIRECT }
  Netflix: { pool: { include: 'country in [NL, DE]' } }
```

### 目标

| 目标 | 含义 |
| --- | --- |
| 组名 | 指定的组，例如 `Netflix`。优先级高于 `$main` 和 `*`。 |
| `$main` | 配置最终 `MATCH` 规则指向的 `select` 组。 |
| `*` | 其他所有 `select` 组，但不包括 `GLOBAL`。 |
| `GLOBAL` | mihomo 内置的 `GLOBAL` 组，在 global 模式中使用。 |

优先级依次为精确组名、`$main`、`*`。路由组的名称本身也是有效目标（除非配置中已存在同名组）；路由自身的程序可实现相同效果。

### 程序键

| 键 | 含义 |
| --- | --- |
| `profile` | 配置 ID（`builtin/fastest`、`provider/x`、`user/x`），替换组自身配置。 |
| `pool` | `{include, exclude}`，仅缩小组的节点池。 |
| `prefer` | 服务器顺序（由 `{label, when}` 步骤组成的列表），替换配置自身顺序。 |
| `to` | 将组固定到一个成员：服务器或嵌套组（例如负载均衡组）；不执行搜索。 |

`to` 不能与 `profile`、`pool` 或 `prefer` 同时使用（“to 固定单个成员，因此 profile、pool 和 prefer 不适用”）。`{}` 表示由组自身的配置控制该组。程序若包含 `pool` 或 `prefer` 但没有 `profile`，则会在组运行时验证，因为组配置届时才确定。

```yaml
rcx: 1
title: Hold and narrow
groups:
  $main:
    pool:
      exclude: name ~ /(?i)test/
    prefer:
      - label: Norway
        when: country = NO
      - label: Anything
        when: not dead
  Backup: { to: DIRECT }
```

## 服务器顺序优先级

组的服务器顺序按以下优先级决定，从高到低：

1. 场景程序的 `prefer`（包括 `on.<kind>` 程序）；
2. 用户绑定中的 `prefer`；
3. 配置自身的 `prefer`。

```mermaid
flowchart LR
    S[Scenario program prefer] -->|beats| U[User binding prefer]
    U -->|beats| P[Profile prefer]
```

因此，用户可以随时为场景未指定的组选择不同顺序；场景或服务商提供的场景也可以在生效期间为某组设定特定顺序。

## 模式

`mode` 设置隧道模式。只有在用户未手动选择模式之前，场景才会**保持**其模式。

- 有效模式依次为：场景指定的模式、用户模式，否则为 `rule`。
- 用户手动更改模式后，场景不再保持该模式。选择 **Auto** 可将控制权交还场景。
- 在当前有效模式下不承载流量的组会处于空闲状态（原因 `hold.idle`）：非 global 模式下的 `GLOBAL`，以及 direct 模式下的所有组。

路由仅会在 rule 模式下分流。如果场景含有路由，而有效模式不是 `rule`，状态会显示 `route.not-rule-mode`。

## 网络类型与 `on`

场景可以像配置一样，通过 `network.kinds`（及 `network.diagnose`）识别网络，并通过 `on.<kind>` 设置覆盖项。每个 `on.<kind>` 可指定 `mode` 和 `groups`。其中某组的条目会**整体替换**基础设置中同键的条目；其他基础条目仍生效。若使用未声明的类型（例如声明 `on.x` 却没有定义类型 `x`），会报错。

```yaml
rcx: 1
title: Calm on mobile
description: Fastest on Wi-Fi, stable on mobile data.
network:
  kinds:
    - { kind: cell, when: 'network.transport = cellular' }
groups:
  $main: { profile: builtin/fastest }
on:
  cell:
    groups:
      $main: { profile: builtin/stable }
```

场景会按网络记住当前类型（`scenario:<id>`）。类型改变时会重新构建绑定。与配置相同，新网络类型需要连续两轮判断一致才生效。

## 路由

`routes` 是有序列表。每条路由包含 `name`、可选的 `description`（最多 240 字节）、`match` 列表和内联程序：`profile`（默认 `builtin/simple`）、`pool`、`prefer` 或 `to`。

```yaml
rcx: 1
title: Work and play
groups:
  $main: {}
routes:
  - name: Chat
    description: Messengers through a nearby server.
    match: [GEOSITE,telegram]
    prefer:
      - label: Finland
        when: country = FI
      - label: Anything
        when: not dead
  - name: Government
    match: [GEOSITE,category-gov-ru]
    to: DIRECT
```

- **不带 `to` 的路由**会创建一个以路由命名、包含 `include-all: true` 的 `select` 组。该组是由路由自身程序控制的智能组。
- **带 `to` 的路由**不会创建组。其规则会发送到目标：`DIRECT`、`REJECT`、现有组或服务器。
- 路由规则按顺序**置于**配置规则之前。第一条匹配的路由获胜。
- 路由仅在应用配置时生效，且只适用于 **rule 模式**。应用流程、`reload` 标志和一次重新应用见[引擎路由说明](engine.md#路由)。
- 路由程序不属于应用配置键，因此修改 `profile`、`pool` 或 `prefer` 会立即生效。修改 `name`、`match` 或 `to` 会触发一次重新应用。

### 编写 `match`

条目是**不含目标**的 mihomo 规则头部。常见形式是每个列表项写成字符串 `"TYPE,value"`。也支持 YAML flow 列表，因为 `[GEOSITE,youtube]` 会读作 `GEOSITE` 和 `youtube` 两项；引擎会将类型与后续载荷合并，并吸收后续的 `no-resolve`。

```yaml
rcx: 1
title: Match forms
groups:
  $main: {}
routes:
  - name: Block style
    match:
      - GEOSITE,youtube
      - DOMAIN-SUFFIX,anthropic.com
    to: DIRECT
  - name: Flow style
    match: [GEOSITE,telegram, GEOIP,RU,no-resolve]
    to: DIRECT
```

包含 YAML 语法特殊字符的条目应加引号。

### 匹配类型

| 类型 | 载荷 | 示例 | 支持 `no-resolve` |
| --- | --- | --- | --- |
| `DOMAIN` | 完整主机名 | `DOMAIN,www.example.com` | 否 |
| `DOMAIN-SUFFIX` | 域及其子域 | `DOMAIN-SUFFIX,example.com` | 否 |
| `DOMAIN-KEYWORD` | 主机名子串 | `DOMAIN-KEYWORD,video` | 否 |
| `DOMAIN-WILDCARD` | 含 `*` 和 `?` 的主机名模式 | `DOMAIN-WILDCARD,*.cdn.example.com` | 否 |
| `DOMAIN-REGEX` | 正则表达式（条目剩余全部内容，允许逗号） | `DOMAIN-REGEX,^api[0-9]+\.example\.com$` | 否 |
| `GEOSITE` | `GEOSITE.dat` 中的类别 | `GEOSITE,youtube` | 否 |
| `GEOIP` | ISO 国家代码 | `GEOIP,RU` | 是 |
| `IP-CIDR` | IPv4 地址范围 | `IP-CIDR,10.0.0.0/8` | 是 |
| `IP-CIDR6` | IPv6 地址范围 | `IP-CIDR6,fd00::/8` | 是 |
| `IP-ASN` | 自治系统编号 | `IP-ASN,13335` | 是 |
| `SRC-IP-CIDR` | 客户端地址范围 | `SRC-IP-CIDR,192.168.1.50/32` | 否 |
| `DST-PORT` | 端口或范围；多个值用 `/` 分隔 | `DST-PORT,443` 或 `DST-PORT,8000-8100` | 否 |
| `PROCESS-NAME` | 可执行文件名 | `PROCESS-NAME,firefox` | 否 |
| `PROCESS-PATH` | 可执行文件完整路径 | `PROCESS-PATH,/usr/bin/curl` | 否 |
| `RULE-SET` | 配置中已有的规则提供者名称 | `RULE-SET,my-ads` | 是 |

`no-resolve` 会让 mihomo 跳过此规则的 DNS 解析；当目标通常是域名时，可用于地址规则。其他类型不允许该参数（会报“不接受选项”）。

`RULE-SET` 要求配置中存在对应的规则提供者；否则该路由会被跳过，并显示问题 `route.invalid`（“rule set X is not in the config”）。`GEOSITE` 类别必须存在于应用自带的 geosite 数据库（`assets/data/GEOSITE.dat`）。编辑器不会检查这一点，因此添加后请测试路由。

```yaml
rcx: 1
title: Every match type
groups:
  $main: {}
routes:
  - name: Domains
    match:
      - DOMAIN,www.example.com
      - DOMAIN-SUFFIX,example.org
      - DOMAIN-KEYWORD,videocdn
      - DOMAIN-WILDCARD,*.static.example.net
      - DOMAIN-REGEX,^api[0-9]+\.example\.com$
    to: DIRECT
  - name: Lists
    match:
      - GEOSITE,youtube
      - GEOIP,RU,no-resolve
    to: DIRECT
  - name: Addresses
    match:
      - IP-CIDR,10.0.0.0/8,no-resolve
      - IP-CIDR6,fd00::/8,no-resolve
      - IP-ASN,13335,no-resolve
      - SRC-IP-CIDR,192.168.1.50/32
    to: DIRECT
  - name: Ports and apps
    match:
      - DST-PORT,8000-8100
      - DST-PORT,22/2222
      - PROCESS-NAME,firefox
      - PROCESS-PATH,/usr/bin/curl
    to: DIRECT
```

## 限制

| 限制项 | 数值 |
| --- | --- |
| 场景大小 | 64 KiB |
| `groups` 中的程序数 | 32 |
| 目标名称长度 | 64 个字符 |
| 路由数 | 32 |
| 每条路由的匹配项数 | 128 |
| 路由名称长度 | 64 字节 |
| 路由说明长度 | 240 字节 |
| 程序 `prefer` 中的步骤数 | 16 |
| 标签数 | 32 |
| 网络类型 / `on` 条目数 | 8 |

## 保留名称

路由名不能是 `$main`、`*`、`GLOBAL`、`DIRECT`、`REJECT`、`REJECT-DROP`、`PASS` 或 `COMPATIBLE`。名称还必须非空、在路由中唯一、不含逗号或控制字符，也不能同时出现在 `groups` 中（路由程序应写在路由本身下）。

应用配置时，如果路由名已是配置中的代理或组，则会跳过该路由（`route.name-taken`）。若 `to` 指向不存在的目标，则跳过该路由（`route.to-missing`）。

## 验证错误

错误会标出问题条目的路径。常见消息如下：

| 路径 | 消息 |
| --- | --- |
| `routes.2.match.0` | `GEOSITE needs a value`、`"X" is not a match type a route can use`、`IP-CIDR "x" is not an address range like 10.0.0.0/8` |
| `routes.1.name` | `two routes are named X`、`route name "X" is reserved`、`route X takes its program on the route, not under groups` |
| `groups.$main` | `to holds one member, so profile, pool and prefer do not apply` |
| `on.cell` | `the scenario declares no network kind cell` |
| `mode` | `mode "x" is not rule, global or direct` |

仅在应用配置时发现的问题会显示在场景状态中：`route.name-taken`、`route.to-missing`、`route.invalid` 和 `route.not-rule-mode`。

## 标签与 l10n

`tags` 为程序中的 `pool` 和 `prefer` 定义命名条件：

```yaml
rcx: 1
title: Starred only
tags:
  star: 'name ~ /\*/'
groups:
  $main:
    pool:
      include: tag(star)
```

`l10n` 可像配置一样翻译 `title`、`description` 和步骤标签：

```yaml
rcx: 1
title: Work
groups:
  $main: {}
l10n:
  ru:
    Work: Работа
```
