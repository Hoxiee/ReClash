# 示例集

适用于常见任务的完整配置与场景。每一个按原样写入都能通过 rcxlint。

## 主流量走一个国家，服务走别处

所有流量经由挪威；YouTube 经由最快的服务器；俄罗斯站点直连。

```yaml title="norway-split.rcx.yaml"
rcx: 1
title: Norway split
mode: rule
groups:
  $main: { profile: builtin/simple, prefer: [{ label: Norway, when: 'country = NO' }, { label: Any, when: 'not dead', last-resort: true }] }
routes:
  - name: YouTube
    match: [GEOSITE,youtube]
    profile: builtin/fastest
  - name: Local
    match: ['GEOSITE,category-ru', 'GEOIP,RU,no-resolve']
    to: DIRECT
```

## 服务器顺序

一种服务器顺序：先是加星标的服务器，然后是芬兰，最后是任何可用的服务器。

```yaml title="starred-ladder.rcx.yaml"
rcx: 1
title: Starred, then Finland
prefer:
  - { label: Starred, when: 'name ~ /\*/ and not dead' }
  - { label: Finland, when: 'country = FI' }
  - { label: Anything, when: 'not dead', last-resort: true }
rank: { by: latency, tolerance: 30 }
```

只有当所有加星标的服务器都已失效或被排除时，顺序才会转向芬兰。

## 节省型配置

适用于性能较弱的设备或按流量计费的链路：检查少、切换稀少。

```yaml title="frugal.rcx.yaml"
rcx: 1
title: Frugal
extends: builtin/stable
energy: eco
switch: { feel: calm, max-per-hour: 1 }
```

失效的服务器仍会被立即替换；该限制只适用于优化性切换。

## 排除测试服务器

绝不选择名称为测试或试用的服务器，即使作为最后手段也不选。

```yaml title="no-test.rcx.yaml"
rcx: 1
title: No test servers
tags:
  trial: 'name ~ /^trial/i'
pool: { exclude: 'name ~ /test|demo|expired/i or tag(trial)' }
```

`pool.exclude` 会在考虑任何层级之前移除成员。绑定或场景可以进一步缩小池，但绝不能扩大它。

## 已验证的出口国家

只使用已确认出口在俄罗斯以外的服务器，否则回退到任意可用服务器。

```yaml title="verified-exit.rcx.yaml"
rcx: 1
title: Verified exit
prefer:
  - { label: Verified abroad, when: 'exit.country != RU' }
  - { label: Any, when: 'not dead', last-resort: true }
```

在出口得到验证之前，服务器按 `Any` 计。当验证能让组提升一个层级时，规划器会对其进行检查。

## 移动数据与 Wi-Fi

Wi-Fi 下用最快的服务器，移动数据下用稳定的服务器。

```yaml title="mobile-wifi.rcx.yaml"
rcx: 1
title: Mobile and Wi-Fi
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

`network.transport` 在 Android 上会被报告。在其他平台上它保持未知，该类型也就永远不会被识别。

## 全部不可用时直连

回退到 `DIRECT`，而不是抱着一台失效的服务器不放。

```yaml title="direct-fallback.rcx.yaml"
rcx: 1
title: Direct fallback
extends: builtin/simple
stranded: direct
```

`stranded` 仅在没有符合条件的成员时生效。使用 `group:<name>` 时，它改为选择该成员。

## 让组固定在一个成员上

让主组固定在某个成员上（例如负载均衡器），不做任何搜索。

```yaml title="hold-main.rcx.yaml"
rcx: 1
title: Hold main
groups:
  $main: { to: Balancer }
```

固定（pin）仍然优先于 `to`。当配置中没有 `Balancer` 时，组会报告 `fixed.missing` 并保持其当前成员。

## 服务商路由

服务商在其清单的 `routing` 部分提供一个配置和一个默认场景。

```yaml title="reclash.yaml"
routing:
  profiles:
    fast-de:
      rcx: 1
      title: Fast Germany
      prefer:
        - { label: Germany, when: 'country = DE' }
        - { label: Any, when: 'not dead', last-resort: true }
  bindings:
    Proxy: { profiles: [provider/fast-de, builtin/stable], default: provider/fast-de }
  scenarios:
    work:
      rcx: 1
      title: Work
      groups:
        $main: { profile: provider/fast-de }
      routes:
        - name: Intranet
          match: [DOMAIN-SUFFIX,corp.example]
          to: DIRECT
  scenario: provider/work
```

这里没有任何内容会联系主机，因此无需同意；参见[服务商交付](sharing.md#provider-delivery)。
