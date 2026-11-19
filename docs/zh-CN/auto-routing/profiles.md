# 配置档

RCX 配置档格式参考:键、默认值、继承、绑定与限制。

## 文档

配置档是一个 YAML 映射;未知键会报错。应用将配置档称为行为。

```yaml title="bypass-de.rcx.yaml"
rcx: 1
title: Germany first
description: Prefers servers that exit in Germany and open the test page.
level: advanced
pool: { exclude: 'type = http' }
tags:
  premium: 'name ~ /premium|vip/i'
checks:
  page: { http: 'https://example.com/', expect: [200] }
prefer:
  - { label: German exit, when: 'exit.country = DE and passes(page)' }
  - { label: Premium, when: 'tag(premium) and not dead' }
  - { label: Any working, when: 'not dead', last-resort: true }
rank: { by: latency, tolerance: 40 }
switch: { improve: true, feel: calm, max-per-hour: 1 }
stranded: direct
energy: balanced
```

## 键

| 键 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `rcx` | integer | 1 | 格式版本;大于 1 会被拒绝。 |
| `title` | string | id | 显示名称。 |
| `description` | string | — | 选择器中的一行摘要。 |
| `level` | `simple` \| `advanced` | `simple` | 编辑器暴露多少内容。 |
| `extends` | 配置档 id | — | 基础配置档;参见[继承](#inheritance)。 |
| `pool` | `{include, exclude}` | 所有成员 | 收窄成员的服务器条件。 |
| `tags` | 名称 → 服务器条件的映射 | — | 供 `tag(name)` 使用的命名服务器集合。 |
| `checks` | id → 检查的映射 | — | 供 `passes(id)` 和 `fails(id)` 使用的请求。 |
| `prefer` | 层级列表 | 一个步骤 `Working`(`not dead`) | 有序的服务器层级。 |
| `rank.by` | `latency` \| `stability` | `latency` | 评分公式;参见[评分](engine.md#score)。 |
| `rank.tolerance` | 整数 ms | 0 | 给当前服务器的加成。 |
| `switch.feel` | `calm` \| `balanced` \| `eager` | `balanced` | `switch` 字段的预设。 |
| `switch.improve` | boolean | `false` | 切换到同一层级中更快的服务器。 |
| `switch.dwell` | 时长 | 预设 | 两次改进切换之间的最短时间。 |
| `switch.min-gain-ms` | integer | 预设 | 最小增益(毫秒)。 |
| `switch.min-gain-pct` | integer | 预设 | 最小增益,占当前评分的百分比。 |
| `switch.confirm` | integer | 预设 | 候选必须连续胜出的新鲜样本数。 |
| `switch.max-per-hour` | integer | 预设 | 每小时的改进切换次数。 |
| `stranded` | `hold` \| `direct` \| `group:<name>` | `hold` | 没有合格成员时的动作。 |
| `energy` | `eco` \| `balanced` \| `precise` | `balanced` | 探测预算;参见[预算](engine.md#budgets)。 |
| `network.diagnose` | 名称 → 诊断的映射 | — | 用于网络条件的直连探测。 |
| `network.kinds` | 类型规则列表 | — | 网络类型;第一个匹配者胜出。 |
| `on` | 类型 → 层的映射 | — | 在某一网络类型上的变更。 |
| `direct-split` | 网络条件 | — | 直连分流何时可以激活。 |
| `egress-verify.echo` | URL 列表 | 两个内置服务 | 出口国家回显服务。 |
| `egress-verify.agree` | 0–3 | 2(0 表示 2) | 所需的相互一致的不同来源数。 |
| `l10n` | 语言 → 来源 → 文本的映射 | — | 配置档自身字符串的翻译。 |

时长使用 Go 语法(`90s`、`1h30m`),不能为负。参见[手感预设](engine.md#feel-presets)。

## 池

`include` 和 `exclude` 是[服务器条件](conditions.md)。除非 `include` 为假或 `exclude` 为真,否则成员被保留,因此未知的事实既不放行也不移除成员。非服务器(`DIRECT`、`REJECT` 及类似项)永远不合格。

## 层级

应用将层级显示为**服务器顺序**;每个层级是一个步骤,`last-resort` 层级是**回退**。

```yaml
# fragment
prefer:
  - { label: Fast home, when: 'country = NL and latency < 80ms' }
  - { label: Any, when: 'not dead' }
  - { label: Fallback, when: 'not dead', last-resort: true }
```

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `label` | string | 在应用中显示;为空时显示为 `Tier N`,N 为位置。 |
| `when` | 服务器条件 | 条件为真的成员加入该层级。 |
| `last-resort` | boolean | 该层级让位于所有其他层级,无论其列在何处。 |

成员加入第一个条件为真的层级。只有当某层级中的每个服务器都被排除或死亡时,选择才会转移到下一层级。

## 检查

```yaml
# fragment
checks:
  web: { http: 'https://example.com/generate_204', expect: [204] }
  port: { tcp: 'example.net:443', optional: true }
  hello: { tls: '203.0.113.7:443', sni: example.org }
```

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `http` | URL | 通过服务器发出 `HEAD` 请求;不跟随重定向。 |
| `tcp` | `host:port` | 通过服务器建立 TCP 连接。 |
| `tls` | `host:port` | 通过服务器进行 TLS 握手;不验证证书。 |
| `sni` | string | `tls` 使用的服务器名称;若主机是名称则默认为该主机。 |
| `expect` | 100–599 的列表 | 仅限 `http`;未设置时任何响应都算通过。 |
| `optional` | boolean | 失败为软失败:`passes(id)` 和 `fails(id)` 都保持为假。 |

`http`、`tcp` 或 `tls` 必须恰好有一个。检查仅在有条件使用它时才运行,作为成功探测上的附加项。当配置档来自提供者时,位于提供者域名和内置端点之外的主机需要用户同意;参见[同意](sharing.md#consent)。

## 网络

```yaml
# fragment
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443', '77.88.8.1:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: portal, when: network.portal, pause: true }
    - { kind: whitelist, when: 'home ok and foreign fail' }
```

诊断是一个命名的 `http` URL 或 `tcp`/`tls` `host:port` 目标列表,通过 `DIRECT` 出站直接探测。任一目标应答时 `<name> ok` 成立;每个目标都已尝试且均未应答时 `<name> fail` 成立。

| 类型字段 | 类型 | 说明 |
| --- | --- | --- |
| `kind` | 名称 | `[a-z0-9-]`,1–24 个字符。 |
| `when` | 网络条件 | 识别该类型。 |
| `pause` | boolean | 在此类型上保持当前服务器并停止检查。 |

识别规则见[网络类型](engine.md#network-kinds)。

## 按网络变更

```yaml
# fragment
on:
  whitelist:
    prefer:
      - { label: Bypass node, when: 'tag(bypass) and not dead' }
    switch: { feel: eager }
```

`on.<kind>` 可以设置 `pool`、`prefer`、`rank`、`switch`、`stranded` 和 `energy`。该类型必须已在 `network.kinds` 中声明,否则编译会失败并报 `the profile declares no network kind <kind>`。该层像[继承](#inheritance)中的子配置档一样合并到配置档上;用户的绑定在其之后应用。

## 直连分流

`direct-split` 是网络条件。当它为真且用户启用了**直连网站经由此组**时,匹配了显式 `DIRECT` 规则的连接会改走该组。例外与状态:[直连分流](engine.md#direct-split)。

## 翻译

```yaml
# fragment
l10n:
  ru: { Germany first: Сначала Германия, German exit: Выход в Германии }
```

键是配置档自己的源字符串:标题、描述和层级标签。应用显示用户语言的文本,否则显示源文本。语言标签为 2–3 个小写字母,可选地后跟 2–8 个字母或数字的地区(`ru`、`zh-CN`)。

## 继承

`extends` 指定一个基础配置档;链最多 4 层深,且不能成环。

| 键 | 合并规则 |
| --- | --- |
| 标量(`title`、`level`、`rank.by`、`stranded`、`energy` 等) | 子配置档设置时以其为准;`rank.tolerance: 0` 无法覆盖。 |
| `pool` | 收窄:include 用 `and` 连接,exclude 用 `or` 连接。 |
| `tags`、`checks`、`network.diagnose`、`l10n` | 按键合并;`l10n` 按语言和字符串合并。 |
| `prefer` | 子配置档有任何层级时整体替换。 |
| `switch` | 子配置档的 `feel` 会将其他字段重置为该预设(`improve` 保留);显式字段随后覆盖。 |
| `on` | 按类型合并;子配置档的 `on.<kind>` 替换父配置档的。 |
| `network.kinds`、`egress-verify.echo` | 整体替换。 |
| `egress-verify.agree` | 设置时以子配置档为准。 |

错误:`extends itself`、`extends more than 4 levels deep`、`profile <id> not found`。

## 绑定

绑定将配置档附加到一个 select 组。订阅将其作为组上的 `rcx:` 写入;应用按订阅保存用户的绑定。

```yaml
# fragment
proxy-groups:
  - name: Proxy
    type: select
    proxies: [NL 1, NL 2, DE 1]
    rcx:
      profiles: [fast, builtin/stable]
      default: fast
      pool: { exclude: 'name ~ /test/' }
      chips:
        - { label: Netherlands, include: 'country = NL' }
```

| 键 | 类型 | 说明 |
| --- | --- | --- |
| `profiles` | id 列表 | 为该组提供的配置档。 |
| `default` | id | 当 `profile` 为空或缺失时使用。 |
| `profile` | id | 所选配置档。 |
| `pool` | `{include, exclude}` | 收窄配置档的池。 |
| `prefer` | 层级列表 | 替换该组使用的配置档顺序。 |
| `feel` | feel | 将 switch 字段重置为该预设。 |
| `energy` | energy | 覆盖配置档的 energy。 |
| `chips` | `{label, include}` 列表,最多 12 个 | **从中选择**下的一键池;无效的 chip 会被丢弃。 |

用户的绑定会替换 `profile`、`pool`、`feel` 和 `energy`,在非空时替换 `prefer`,并将其 chips 加到提供者的 chips 之上。订阅无法开启直连分流。配置档 id 按以下顺序解析:`profile`、`default`、`builtin/simple`;缺失的 `profile` 会报告为 `profile.missing`。场景程序叠加在其上;参见[程序](scenarios.md#programs)。当配置档自己的 `on.<kind>` 为当前网络类型设置了 `prefer` 时,该顺序优先于两者。

## 限制

| 项目 | 限制 |
| --- | --- |
| 文档 | 64 KiB |
| 层级 | 16 |
| 标签 | 32 |
| 检查 | 8 |
| 诊断 | 8,每个含 1–4 个目标 |
| 网络类型、`on` 条目 | 各 8 |
| 回显服务 | 4,`http(s)` URL |
| `extends` 深度 | 4 |
| Chips | 12 |
| `l10n` | 16 种语言,每种 64 个字符串,每个字符串 1–160 个字符 |
| 条件 | 2048 个字符;参见[限制](conditions.md#limits) |
