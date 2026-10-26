# 条件

**条件**是一个小型表达式，用于回答关于某台服务器的问题：“它是否符合要求？”条件可写在 `pool.include`、`pool.exclude`、`tags` 以及每个 `prefer` 步骤的 `when` 中。在网络设置（`network.kinds`、`direct-split`）中，条件描述的是网络本身。

标有 `# fragment` 的示例是不完整片段。其他示例均为完整配置，并可通过 [`rcxlint`](sharing.md#rcxlint-工具) 检查。条件展示在配置上下文中，可直接复制使用。

目录：[快速了解](#快速了解) · [语法](#语法) · [字段](#字段) · [运算符](#运算符) · [正则表达式](#正则表达式) · [函数](#函数) · [未知与待处理](#三值逻辑未知与待处理) · [网络条件](#网络条件) · [示例](#由简到繁的示例) · [限制](#限制)

## 快速了解

```yaml
rcx: 1
title: Quick tour
pool:
  exclude: name ~ /(?i)test/
prefer:
  - label: Norway, fast
    when: country = NO and latency < 120
  - label: Nordics
    when: country in [NO, SE, FI, DK]
  - label: Anything
    when: not dead
```

- `country = NO` 将字段与值进行比较。
- `latency < 120` 比较数值（毫秒）。
- `country in [NO, SE, FI, DK]` 检查值是否属于集合。
- `name ~ /(?i)test/` 使用正则表达式匹配，且不区分大小写。
- `not dead` 对独立的真假字段应用 `not`。
- 可使用 `and`、`or`、`not` 和括号组合条件。

## 语法

```text
condition   = or
or          = and { "or" and }
and         = not { "and" not }
not         = "not" not | primary
primary     = "(" condition ")" | test
test        = bool-field
            | string-field ( "=" | "!=" ) value
            | string-field "in" "[" value { "," value } "]"
            | string-field "~" regex
            | number-field ( "=" | "!=" | "<" | "<=" | ">" | ">=" ) number [ "ms" ]
            | "tag" "(" word ")"
            | "passes" "(" word ")" | "fails" "(" word ")"
value       = word | 'quoted' | "quoted"
regex       = /pattern/flags | 'quoted' | "quoted"
```

基本规则：

- **优先级**：`not` 最高，其次是 `and`，最后是 `or`。不确定时使用括号。
- 不支持 `!`，应写 `not`（错误提示会说明“use 'not'”）。
- *单词*可以包含字母、数字和 `_ - . :`。其他字符（空格、`*`、国旗）必须放在引号中。
- 字符串比较不区分大小写（`country = no` 等同于 `country = NO`）。
- 在 YAML 中，如果条件包含 `: `，或以 `[`、`{`、`*`、`&`、`!`、`#` 开头，应将整个条件加引号。以字段名开头通常安全；如有疑问，请用单引号，例如 `when: 'name ~ /a|b/'`。

## 字段

字段针对当前网络中的单台服务器进行计算。

### 服务器字段

| 字段 | 类型 | 运算符 | 含义 |
| --- | --- | --- | --- |
| `name` | 字符串 | `= != in ~` | 订阅中的服务器显示名称。 |
| `provider` | 字符串 | `= != in ~` | 提供该服务器的服务商（订阅）。 |
| `type` | 字符串 | `= != in ~` | 协议类型，例如 `vless`、`trojan`、`ss`。 |
| `server` | 字符串 | `= != in ~` | 节点连接的服务器地址。 |
| `country` | 字符串 | `= != in ~` | 已验证的出口国家，否则从名称解析。始终有确定值。 |
| `exit.country` | 字符串 | `= != in ~` | 仅指已验证的出口国家。验证前为未知。 |
| `entry.country` | 字符串 | `= != in ~` | 服务器自身地址所在国家。未确定前为未知。 |
| `udp` | 布尔值 | 无 | 节点支持 UDP。 |
| `alive` | 布尔值 | 无 | 最近确认可用。 |
| `dead` | 布尔值 | 无 | 已确认不可用。 |
| `measured` | 布尔值 | 无 | 此网络下至少有一条延迟测量值。 |
| `current` | 布尔值 | 无 | 当前选中的组服务器。 |
| `latency` | 数值 | `= != < <= > >=` | 延迟中位数，单位为毫秒。未测量服务器的结果为假。 |

### 国家字段

国家值使用 **ISO 3166-1 alpha-2 代码**，例如 `NO`、`SE`、`DE`、`RU`。应使用代码而不是国家名：写 `country = SE`，不要写 `country = Sweden`。

三个国家字段的数据来源不同：

| 字段 | 来源 | 何时为未知 |
| --- | --- | --- |
| `country` | 引擎已验证的出口国家；若无，则从服务器**名称**解析。 | 不会未知。未找到时为空（已知“无”），因此不会触发检测。 |
| `exit.country` | 仅使用已验证的出口国家。 | 引擎通过足够的数据源完成验证前。 |
| `entry.country` | 服务器地址所在国家。 | 地址解析完成前。 |

名称解析顺序：国旗 emoji；作为独立词出现的大写两位代码（`DE`、`[NO]`）；英文国家名或别名（`Germany`、`USA`、`UK`、`Korea`、`Russian Federation`）。如存在多个提示，按上述顺序采用第一个匹配项。

日常按地区选择时使用 `country`。如果必须确认流量实际从哪里出口（例如排除本国出口），则使用 `exit.country`；引擎只会为决策所需的服务器获取验证信息（参见[未知与待处理](#三值逻辑未知与待处理)）。

### 检查结果与标签

| 形式 | 含义 |
| --- | --- |
| `passes(id)` | 配置中的检查 `id` 已通过。 |
| `fails(id)` | 检查 `id` 已确认失败。 |
| `tag(name)` | `tags` 中名为 `name` 的条件成立。 |

v2 草案曾提到 `group` 字段，但实际上不存在。网络字段和诊断见[网络条件](#网络条件)。

## 运算符

### 字符串

| 运算符 | 示例 | 含义 |
| --- | --- | --- |
| `=` | `country = NO` | 相等，不区分大小写。 |
| `!=` | `type != ss` | 不相等。 |
| `in [ ]` | `country in [NO, SE]` | 等于列表中的任意值。 |
| `~` | `name ~ /gold|silver/` | 正则匹配（在字符串任意位置搜索）。 |

### 数值

运算符为 `= != < <= > >=`，并可选添加 `ms` 后缀：`latency <= 150ms` 和 `latency <= 150` 等价。

### 布尔字段

布尔字段单独使用：`udp`、`not dead`、`alive and udp`。不要写成 `dead = true`。

### 逻辑运算

支持 `and`、`or`、`not` 和括号。`not` 放在测试前表示取反，例如 `not name ~ /test/`。

## 正则表达式

`~` 使用 Go 的 **RE2** 正则语法。不支持前瞻、后顾和反向引用；匹配时间为线性复杂度。

有两种写法：

- `/pattern/`，可选 `i` 标志表示忽略大小写：`name ~ /gold/i`（等价于 `/(?i)gold/`）。其他标志会报错。
- 加引号的字符串：`name ~ 'gold|silver'`。

在 `/ /` 中使用 `\/` 表示字面斜杠。正则最多 512 个字符。

### YAML 转义

条件会先由 YAML 解析，因此需要遵循 YAML 转义规则。

| 目标 | 写法 |
| --- | --- |
| 名称中的字面 `*` | `name ~ /\*/`（反斜杠是正则转义；普通标量即可） |
| 字面 `|` 或 `.` | 在正则中写 `\|` 或 `\.` |
| 正则中包含 `: ` 或 `#` | 将整个条件放入单引号 |
| 单引号字符串中的单引号 | 写成两个：`'it''s'` |
| 双引号 YAML 中的反斜杠 | 写成两个：`"name ~ /\\*/"` |

YAML 单引号标量会保留反斜杠，因此最稳妥：`when: 'name ~ /\*/ and not dead'`。

```yaml
rcx: 1
title: Starred and flagged
prefer:
  - label: Starred
    when: 'name ~ /\*/ and not dead'
  - label: Flag emoji
    when: 'name ~ /🇩🇪|🇳🇱/'
  - label: Anything
    when: not dead
```

## 函数

| 函数 | 结果 |
| --- | --- |
| `tag(name)` | 当该服务器满足标签条件时为真。结果始终已知。标签内不能调用 `tag()`。 |
| `passes(id)` | 检查 `id` 通过时为真；尚未测量时为未知。 |
| `fails(id)` | 检查 `id` 失败时为真；尚未测量时为未知。 |

失败的**可选**检查属于*软失败*：对该检查而言，`passes` 和 `fails` 都为假。

## 三值逻辑：未知与待处理

引擎尚未测量的事实并非假，而是**未知**。因此条件有三种结果：真、假、未知，并按 Kleene 三值逻辑组合。

| `and` | 真 | 假 | 未知 |
| --- | --- | --- | --- |
| **真** | 真 | 假 | 未知 |
| **假** | 假 | 假 | 假 |
| **未知** | 未知 | 假 | 未知 |

| `or` | 真 | 假 | 未知 |
| --- | --- | --- | --- |
| **真** | 真 | 真 | 真 |
| **假** | 真 | 假 | 未知 |
| **未知** | 真 | 未知 | 未知 |

`not unknown` 仍为未知。

实际含义如下：

- **只有结果已知时，步骤才会确定。** 如果服务器在步骤 1 的条件为未知，该服务器处于**待处理**状态：它可能符合步骤 1，但引擎尚不确定。
- **待处理状态会触发检查。** 规划器会在资源预算内获取缺失的测量（查询出口国家或运行命名检查）。事实确定后，服务器便会归入对应步骤。
- **短路求值可以节省资源。** `no and unknown` 为*假*，因此已不符合 `country = NO` 的服务器不会在 `country = NO and exit.country = NO` 中触发出口国家查询。请将低成本、始终已知的测试写在前面。
- **节点池条件遇到未知时允许服务器通过。** 不会仅因为缺少信息就隐藏服务器。
- **只有特定字段会产生未知值**：`exit.country`、`entry.country`，以及测量前的 `passes()`/`fails()`。`country`、`name`、`type`、`provider`、`server`、`udp` 和 `tag()` 始终已知。未测量服务器的 `latency` 条件为*假*而非未知，因此不会单独触发检查。
- 若没有步骤匹配，但有步骤处于待处理状态，服务器会显示为“待处理”，而不是“无匹配步骤”。

## 网络条件

`network.kinds` 和 `direct-split` 中的条件描述的是**网络**，不是服务器。支持以下字段：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `network.kind` | 字符串 | 当前为该组识别出的网络类型。 |
| `network.transport` | 字符串 | 平台报告的链路类型；测试使用 `wifi`、`cellular` 和 `ethernet`。 |
| `network.portal` | 布尔值 | 是否检测到强制门户。 |
| `metered` | 布尔值 | 网络是否标记为按流量计费。 |
| `<name> ok`、`<name> fail` | 诊断结果 | `network.diagnose` 中同名诊断的结果。 |

诊断只能用于网络条件，不能在那里使用服务器字段。未测量的诊断结果为未知，因此探测完成前无法确定网络类型。

```yaml
rcx: 1
title: Network kinds
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: cell, when: network.transport = cellular and metered }
    - { kind: whitelist, when: 'home ok and foreign fail' }
prefer:
  - label: Anything
    when: not dead
```

## 由简到繁的示例

每一项均可用作 `when` 或 `pool` 条件。

| 目标 | 条件 |
| --- | --- |
| 任意可用服务器 | `not dead` |
| 仅挪威 | `country = NO` |
| 排除俄罗斯 | `country != RU` |
| 若干国家之一 | `country in [NO, SE, FI]` |
| 名称包含“Premium”（忽略大小写） | `name ~ /premium/i` |
| 名称中带星号 | `name ~ /\*/` |
| 名称中带闪电符号 | `name ~ /⚡/` |
| 排除演示服务器 | `not name ~ /(?i)demo|test/` |
| 支持 UDP 且速度快 | `udp and latency < 100` |
| 仅 Hysteria 或 TUIC | `type in [hysteria, hysteria2, tuic]` |
| 指定服务商 | `provider = MyProvider` |
| 不是当前服务器 | `not current` |
| 优先挪威快速节点，否则任意北欧节点 | 两个步骤：先 `country = NO and latency < 80`，再 `country in [NO, SE, FI, DK]` |
| 已验证的出口不在本国 | `exit.country != RU` |
| 通过指定检查且出口不在俄罗斯 | `passes(open) and exit.country != RU` |
| 标签或名称匹配 | `tag(bypass) or name ~ /(?i)lte/` |
| 名称有星号且国家为 NO 或 SE | `name ~ /\*/ and (country = NO or country = SE)` |

完整示例：

```yaml
rcx: 1
title: Careful ladder
level: advanced
tags:
  star: 'name ~ /\*/'
checks:
  open: { http: 'https://www.youtube.com/generate_204', expect: [204] }
pool:
  exclude: name ~ /(?i)test|demo/
prefer:
  - label: Starred, opens video, fast
    when: 'tag(star) and passes(open) and latency < 150'
  - label: Starred
    when: 'tag(star) and not dead'
  - label: Nordic, opens video
    when: 'country in [NO, SE, FI] and passes(open)'
  - label: Anything
    when: not dead
```

解读：第一步需要名称带星号、能访问视频且延迟较低的服务器。尚未执行 `open` 检查的服务器会在步骤 1 中保持待处理，因此规划器会对它们执行检查。若没有服务器符合条件，则第二步会选择任意带星号的服务器，以此类推。

## 限制

| 限制项 | 数值 |
| --- | --- |
| 条件文本长度 | 2048 个字符 |
| 嵌套深度 | 16 |
| 正则表达式长度 | 512 个字符 |

发布的 JSON Schema 使用相同的 2048 字符限制。

错误信息会指出出错部分及其位置，例如 `unknown field "bogus"`。在工作台中，错误会显示在对应行下方。
