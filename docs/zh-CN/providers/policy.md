# 安全策略

服务商可以在 ReClash 中强制执行哪些限制，使用户无法撤销。

一条策略最多由两部分组成。**规则**位于订阅正文中，是普通的 mihomo 配置，因此所有客户端都会遵守。**开关**位于清单的 `policy` 部分，让 ReClash 强制执行该规则。

| 你想要 | 订阅正文 | 清单 |
| --- | --- | --- |
| [全局模式只能经由指定节点](#only-listed-nodes-in-global) | 列出这些节点的 `GLOBAL` 组 | `global: listed` |
| [完全没有全局模式](#no-global) | 无 | `global: off` |
| [Android 应用始终在 VPN 之外](#apps-that-must-stay-outside-the-vpn) | `tun.exclude-package` | `apps: required` |
| [Android 上没有本地代理端口](#no-local-proxy-ports) | 无 | `local-ports: closed` |
| [禁止编辑仪表盘](#locked-dashboard) | 无 | `dashboard: locked` |

所有键都是可选的。省略的键不会施加任何限制。

```yaml
policy:
  global: listed       # any (default) | listed | off
  apps: required       # recommended (default) | required
  local-ports: closed  # open (default) | closed
  dashboard: locked    # editable (default) | locked
```

## Global 模式只允许列出的节点

规则模式保持自由：由你的 `rules` 决定。在全局模式下，流量只能经由 `GLOBAL` 组可达的节点离开。

最简单的写法是 mihomo 原生的 `filter`。假设节点池中有名为 `Germany`、`Poland LTE`、`Russia LTE` 和 `Streaming` 的节点，而全局模式只允许使用带 LTE 的节点。

订阅正文：

```yaml
proxy-groups:
  - name: GLOBAL
    type: select
    include-all-proxies: true
    filter: '\bLTE\b'
    remnawave: { include-proxies: false }
```

清单：

```yaml
policy:
  global: listed
```

结果：

| 模式与节点 | 结果 |
| --- | --- |
| 规则模式，任意节点，包括 `Streaming` | 可用。 |
| 全局模式，`Poland LTE` | 可用。 |
| 全局模式，`Russia LTE` | 可用。 |
| 全局模式，`Germany` | 被阻止。应用会提示用户选择允许的节点或改用规则模式。 |
| 全局模式，`DIRECT` | 被阻止。被拒绝的路由绝不会回退为直连。 |

写法：

| 你想要 | `GLOBAL` 组 |
| --- | --- |
| 名称中带有某个标记的节点 | `include-all-proxies: true` 加 `filter: '\bLTE\b'`。 |
| 除某些节点之外的全部节点 | `include-all-proxies: true` 加 `exclude-filter: Streaming`。 |
| 精确的短列表 | 手工列出的 `proxies`。用户没有的主机会导致配置失败，见下文。 |

- `filter` 只匹配节点名称。它只缩小 `include-all-proxies`（或 `include-all`）带来的成员，不影响显式的 `proxies`。
- 反引号用于分隔多个备选项。`(?i)` 表示忽略大小写。
- 用 `\bLTE\b` 而不是 `lte`：不加边界的 `lte` 也会匹配 `Malte`。
- `exclude-filter` 和 `exclude-type` 会从所有组中移除成员，包括显式的 `proxies`。
- 标记必须出现在节点名称中。Remnawave 主机的 `tags` 不会进入 mihomo 配置。
- 新增的匹配节点会自动加入，资费套餐中缺少部分匹配主机的用户仍能得到可加载的配置。这适合大型节点池。
- 手工列出的 `proxies` 如果包含用户没有的主机，mihomo 会报错 `GLOBAL: 'Poland LTE' not found`。配置更新本身仍会成功，失败只在应用配置时出现。启用 `global: listed` 时，该配置会被阻止并拒绝所有流量。

什么算作已列出：

| 情形 | 结果 |
| --- | --- |
| 正文 `proxies` 中的节点，且可经 `GLOBAL` 到达 | 允许。 |
| `GLOBAL` 通过 `filter` 解析到的节点 | 允许。 |
| 节点被重命名 | 仍然允许：许可跟随服务器、端口和凭据，而不是名称。 |
| 另一台服务器占用了某个允许节点的名称 | 拒绝。 |
| 来自 `proxy-providers` 来源的节点 | 拒绝，除非其定义与某个允许的内联节点完全一致。 |
| `GLOBAL` 中列出的 `DIRECT` 或 `REJECT` | 不产生任何效果。 |
| `filter` 没有匹配到任何节点 | 该组解析为 `COMPATIBLE`（或其 `empty-fallback`），全局模式被移除。 |
| 没有 `GLOBAL` 组，或其无法到达任何内联节点 | 全局模式被移除，与 `global: off` 相同。 |

> [!WARNING]
> 面板在生成正文时可能向你的组中添加节点。Remnawave 会把所有主机追加到缺少 `remnawave: { include-proxies: false }` 的组的 `proxies` 中（[做法](rollout.md#policy-in-the-mihomo-template)），这会绕过 `filter`。此时所有节点都被允许，订阅检查器会显示 `policy.global is listed, but GLOBAL reaches every inline node of the body, so the lock restricts nothing`。当正文包含远程 provider 或只有单一路由时，该警告不会出现。请检查客户端实际收到的正文。

仅适用于全局模式。在规则模式下，由普通的组和规则决定。

## 禁用 Global

```yaml
policy:
  global: off
```

应用会隐藏全局模式，Core 也会拒绝它。处于全局模式的配置会切换为规则模式。正文无需任何内容。

## 必须留在 VPN 之外的应用

订阅正文：

```yaml
tun:
  exclude-package: [com.example.bank, com.example.gov]
```

清单：

```yaml
policy:
  apps: required
```

| 行为 | `recommended`（默认） | `required` |
| --- | --- | --- |
| 列表来源 | `tun.exclude-package` 和 `apps.exclude` | 仅 `tun.exclude-package` |
| 用户能否取回应用 | 能 | 不能：已锁定，标记为“服务商强制要求” |
| 白名单模式，或访问控制关闭 | 由用户的模式决定 | 仍被排除 |
| Android 上的本地代理端口 | 开放 | 关闭 |
| 桌面端 | 忽略 | 忽略 |
| 未使用 VPN 模式的 Android | 忽略 | 忽略：配置会在没有排除项的情况下连接 |

`apps: required` 仅在 Android 的 VPN 模式下生效；桌面端和 Android 代理模式会忽略它并直接连接。

被排除的应用使用直连和真实 IP。排除不等于阻止：如需阻止它们，请使用 Android 的锁定模式。VPN 应用本身无法被排除。

用户可见的错误：

| 消息 | 原因 | 处理 |
| --- | --- | --- |
| `provider app exclusions are not applied; restart the VPN` | 正在运行的 VPN 启动时使用的是不同的列表 | 重启 VPN。 |
| `provider policy could not identify this application` | 无法识别连接所属的应用 | 该连接保持被阻止。 |
| `provider policy requires this application to remain outside the VPN` | 列出的应用仍被旧的 VPN 会话捕获 | 重启 VPN。 |

## 禁用本地代理端口

```yaml
policy:
  local-ports: closed
```

仅适用于 Android。关闭 mixed、HTTP、SOCKS、redir 和 TProxy 端口，使 Web 仪表盘不可用，并让应用自身的请求直接发出。`apps: required` 也会启用此项。

## 锁定仪表盘

```yaml
policy:
  dashboard: locked
```

移除两个仪表盘上的编辑功能。你在 [`widgets`](manifest.md#widgets) 中设置的布局保持不变。

## 锁定何时生效

| 事件 | 结果 |
| --- | --- |
| 新的有效清单省略了某个键 | 该锁定会在下次更新时撤销。 |
| `policy` 的某个值无效 | 整个部分被撤销；[检查器](rollout.md#subscription-inspector)会显示警告。 |
| 获取清单失败 | 最后一份有效副本保持其锁定。 |
| 订阅更新失败 | 不发生任何变化。 |
| 响应中不再有 `reclash-config`，或从未获取过清单 | 没有锁定。正文中的规则作为普通 mihomo 配置生效。 |
| 用户切换配置 | 应用新配置的策略。 |
| 模式或锁定发生变化 | 已有连接会被关闭。 |

脚本、覆写和控制器重载都无法移除锁定：Core 从原始配置文件推导锁定，并将其保存在 `config.yaml` 之外。

## 限制

- 这保护的是配合的客户端，而不是你的网络。不读取清单的客户端只会遵守正文中的规则，被修改过的客户端可能两者都无视。必须杜绝的行为请在服务器端强制执行。
- 排除某个包并不涵盖在浏览器中打开的同一服务。
