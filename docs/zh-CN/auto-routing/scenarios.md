# 场景

RCX 场景格式参考:面向组、路由、网络类型和隧道模式的程序。

## 文档

场景是一个不超过 64 KiB 的 YAML 映射;未知键会被拒绝。用户可以在 **场景** 中为每个订阅选择一个运行中的场景。关闭 **使用场景** 会保留上次选择。提供商可以通过[清单](../providers/manifest.md#routing)提供场景。

```yaml title="split.rcx.yaml"
rcx: 1
title: My split
mode: rule
tags:
  fast-ru: "name ~ '⚡ RU'"
groups:
  $main: { profile: builtin/fastest, prefer: [{ label: Norway, when: 'country = NO' }] }
  '*': {}
routes:
  - name: YouTube
    match: [GEOSITE,youtube]
    prefer:
      - { label: Fast RU, when: 'tag(fast-ru)' }
      - { label: Any, when: 'not dead' }
  - name: Claude
    match: [GEOSITE,anthropic]
    prefer: [{ label: Sweden, when: 'country = SE' }]
  - name: Local
    match: ['GEOSITE,category-ru', 'DOMAIN-SUFFIX,yandex.ru']
    to: DIRECT
```

| 键 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `rcx` | integer | 1 | 格式版本;大于 1 会被拒绝。 |
| `title`、`description` | string | — | 显示文本。 |
| `tags` | 名称 → 服务器条件的映射 | — | 对每个程序可见,与程序所用配置档自身的标签并存。 |
| `network` | `{diagnose, kinds}` | — | 与配置档相同;参见[网络](profiles.md#network)。 |
| `mode` | `rule` \| `global` \| `direct` | — | 场景所保持的隧道模式;为空则交给用户决定。 |
| `groups` | 目标 → 程序的映射 | — | 按组划分的程序;参见[目标](#targets)。最多 32 个。 |
| `routes` | 路由列表 | — | 置于配置自身规则之前的规则;参见[路由](#routes)。 |
| `on` | 类型 → `{mode, groups}` 的映射 | — | 在某一网络类型上的变更。 |
| `l10n` | 翻译 | — | 与配置档相同。 |

## 程序

| 键 | 类型 | 说明 |
| --- | --- | --- |
| `profile` | 配置档 id | 替换该组的配置档。否则该组沿用其绑定的配置档,再否则为 `builtin/simple`。 |
| `pool` | `{include, exclude}` | 进一步收窄绑定的池。 |
| `prefer` | 层级列表,最多 16 个 | 替换服务器顺序;优先于用户绑定的顺序。 |
| `to` | 成员名称 | 将该组保持在某一成员(服务器、负载均衡器、嵌套组)上,不做搜索。与其他键互斥。 |

`to` 与任何其他键同时出现会失败,并报 `to holds one member, so profile, pool and prefer do not apply`。有 `pool` 或 `prefer` 但没有 `profile` 的程序,会在运行时依据该组自身的配置档进行检查。

## 目标

| 键 | 适用于 |
| --- | --- |
| 组名 | 该组。1–64 个字符。 |
| 路由名 | 不允许:路由的程序写在路由本身上。 |
| `$main` | 最终 `MATCH` 规则将流量送往的组。 |
| `*` | 其他所有 select 组,但从不包括 `GLOBAL`。 |

单个组的优先顺序:其确切名称、其路由的程序、`$main`,然后是 `*`。场景没有提及的组保留其绑定,或仍是普通选择器。

## 路由

```yaml
# fragment
routes:
  - name: Work
    description: Office services through the Netherlands
    match:
      - DOMAIN-SUFFIX,corp.example
      - IP-CIDR,10.20.0.0/16,no-resolve
      - PROCESS-NAME,teams.exe
    pool: { include: 'country = NL' }
```

| 键 | 类型 | 说明 |
| --- | --- | --- |
| `name` | string | 1–64 字节,已去除首尾空白,不含逗号或控制字符,且唯一。成为组名。 |
| `description` | string | 最多 240 字节。 |
| `match` | `TYPE,value[,no-resolve]` 列表 | 1–128 条。 |
| `profile`、`pool`、`prefer` | 程序键 | 路由自己的组如何选择。 |
| `to` | 目标 | 将匹配的流量发往已有的代理、组、内置目标或另一路由的组,而不是创建组。 |

保留名称:`$main`、`*`、`GLOBAL`、`DIRECT`、`REJECT`、`REJECT-DROP`、`PASS`、`COMPATIBLE`。

### 匹配类型

| 类型 | 值 | `no-resolve` |
| --- | --- | --- |
| `DOMAIN`、`DOMAIN-SUFFIX`、`DOMAIN-KEYWORD`、`DOMAIN-WILDCARD` | 域名文本 | 否 |
| `DOMAIN-REGEX` | 正则;条目的其余全部内容 | 否 |
| `GEOSITE` | 站点类别 | 否 |
| `GEOIP` | 国家或类别代码 | 是 |
| `IP-CIDR`、`IP-CIDR6` | 地址范围 | 是 |
| `IP-ASN` | AS 号 | 是 |
| `SRC-IP-CIDR` | 源地址范围 | 否 |
| `DST-PORT` | 端口或范围,以 `/` 连接:`443/8000-8100` | 否 |
| `PROCESS-NAME`、`PROCESS-PATH` | 进程名称或路径 | 否 |
| `RULE-SET` | 配置中规则提供者的名称 | 是 |

类型不区分大小写。像 `[GEOSITE,youtube]` 这样的 YAML 流式列表会被读作一条条目:类型项会与下一项以及可选的 `no-resolve` 连接起来。

### 应用

路由只在应用配置时生效。每个不带 `to` 的路由会添加一个带 `include-all: true` 的 select 组,以及该路由的规则,按路由顺序置于所有配置规则之前。更改路由的名称、match 或 `to` 会请求一次重新应用,由应用执行;程序的更改则实时生效。

| 问题 | 代码 | 原因 |
| --- | --- | --- |
| 名称已被占用 | `route.name-taken` | 不带 `to` 的路由与已有的代理、组或内置目标同名。 |
| 目标缺失 | `route.to-missing` | `to` 指向的内容不在配置或路由中。 |
| 无效 | `route.invalid` | `RULE-SET` 不在配置中,或 mihomo 拒绝了该路由的规则或组。 |
| 非规则模式 | `route.not-rule-mode` | 存在路由,但隧道模式不是 `rule`。 |

被拒绝的路由会被丢弃,配置会在去掉它之后重新解析。无法追溯到某个路由的失败会将所有路由标记为无效,并在没有路由的情况下应用配置。

## 网络类型

```yaml
# fragment
network:
  diagnose:
    home: { tcp: ['77.88.8.8:443'] }
    foreign: { tls: ['1.1.1.1:443'] }
  kinds:
    - { kind: whitelist, when: 'home ok and foreign fail' }
on:
  whitelist:
    mode: global
    groups:
      GLOBAL: { profile: builtin/simple, pool: { include: tag(bypass) } }
```

`on.<kind>.groups` 按目标键替换基础程序;未提及的目标保留基础程序。`on.<kind>.mode` 回退到基础的 `mode`。`on` 下的类型必须已声明,否则加载会失败并报 `the scenario declares no network kind <kind>`。识别规则遵循[网络类型](engine.md#network-kinds)。

## 模式

生效的隧道模式是场景在当前类型上的模式,除非用户手动选择了模式;此时为用户的模式,再否则为 `rule`。选择场景会让模式回到场景的设定。在当前模式下不承载流量的组处于空闲(`hold.idle`):既不做决策,也不做检查。

| 模式 | 空闲的组 |
| --- | --- |
| `rule` | `GLOBAL` |
| `global` | 除 `GLOBAL` 之外的所有组 |
| `direct` | 所有组 |

## 限制

| 项目 | 限制 |
| --- | --- |
| 文档 | 64 KiB |
| 每个 `groups` 或 `on.<kind>.groups` 中的程序数 | 32 |
| 目标名称 | 1–64 个字符 |
| 标签 | 32;标签不能使用 `tag()` |
| 类型、`on` 条目 | 各 8 |
| 路由 | 32 |
| 路由名称、描述 | 64 字节、240 字节 |
| 每个路由的 match 条目 | 128 |
