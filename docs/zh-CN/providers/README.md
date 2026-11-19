# 服务商集成

订阅服务商如何向 ReClash 交付配置、元数据、路由和策略。请先阅读[快速开始](manifest.md#quick-start)，再打开对应领域的页面。

## 模型

一次订阅就是一次 HTTP GET。正文是纯 mihomo；请求头携带每个用户的数据，以及一个指向清单的指针，其余所有内容都由清单承载。

| 通道 | 承载内容 | 参考 |
| --- | --- | --- |
| 正文 | mihomo（Clash）YAML，只包含 mihomo 能理解的键。分享链接、Xray、sing-box、WireGuard 和 Amnezia 会在导入时转换，可能丢失数据。经 AGE 加密的正文会先解密。原生的 `GLOBAL` 组和 `tun.exclude-package` 承载[安全策略](policy.md)。 | — |
| 标准请求头 | `Subscription-Userinfo`、`Content-Disposition`、`profile-title`、`profile-update-interval`，以及别名 `support-url`、`profile-web-page-url`、`announce`、`hide-url`。 | [响应头](headers.md) |
| `reclash-config` 请求头 | 指向清单的指针，也是唯一的 `reclash-*` 请求头。其他任何 `reclash-*` 请求头都会被忽略并给出警告。 | [清单指针](headers.md#manifest-pointer) |
| 清单 | 所有用户共享的一份静态 YAML 文件：服务商面板、提醒、设置、策略、Android 应用、传输、支持、外观、卡片、电量标签、路由。 | [服务商清单](manifest.md) |
| 设备请求头 | `x-hwid`、`x-hwid-max-devices-reached` 及相关请求头。 | [请求头](request.md) |
| 预览端点 | 在确认浏览器导入之前显示的 JSON。它在任何订阅存在之前运行，因此无法使用清单。 | [预览 API](preview-api.md) |

## 获取流程

1. 使用配置的客户端预设以及设备 ID（若已启用）发送请求（[请求头](request.md)）。
2. 跟随最多 5 次重定向并解码正文（[重定向与传输](request.md#redirects-and-transport)）。
3. 对照[注册表](standard.md)解码请求头。无效的值会被丢弃并给出警告。
4. 将结果合并到已保存的元数据中（[元数据生命周期](#metadata-lifetime)）。
5. 获取 `reclash-config` 指定的清单（如有）（[交付](manifest.md#delivery)）。
6. 应用配置、清单和策略。

当正文为空、格式未知，或没有节点、组或远程 provider 时，更新会被拒绝，已保存的配置保持不变。

## 信任级别

| 级别 | 效果 | 示例 |
| --- | --- | --- |
| `display` | 向用户显示。不改变行为。 | `provider.name`、`provider.announce`、`provider.hide-url` |
| `hint` | 在固定范围内改变行为。 | `settings`、`apps.exclude`、`reminders` |
| `consent` | 需要用户同意后才生效。 | `support.keys`、`support.upload-url` |

大多数提示会让位于用户的修改（[所有权](manifest.md#ownership)）。只有 [`policy`](manifest.md#policy) 设置的限制是用户无法解除的。

## 元数据生命周期

用量和清单的老化方式不同。

| 数据 | 生命周期 |
| --- | --- |
| 标准请求头 | 每次成功更新都会把它们合并到已保存的数据之上。响应中的字段会替换已保存的值。缺失的用量字段（`Subscription-Userinfo`）保留其最后的值并标记为过期；过期期间，到期和流量提醒会被抑制。其他任何缺失的请求头都会被撤销，跟随它的设置会恢复为用户的值。 |
| 清单 | 完整校验后整体替换。获取失败或无效时保留最后一份有效副本。没有 `reclash-config` 的响应会删除已保存的副本。新的有效副本中缺失的部分会被撤销。 |

更新失败不会改变任何内容。[订阅检查器](rollout.md#subscription-inspector)会列出过期字段和警告。

## 标准版本

注册表为标准版本 1。[标准注册表](standard.md)由代码生成：请求头、清单字段、类型、信任级别和大小限制。机器可读的副本是 [`provider_standard.g.json`](../../../provider_standard.g.json)。

## 最小响应

```http
HTTP/1.1 200 OK
Content-Type: text/yaml; charset=utf-8
Content-Disposition: attachment; filename*=UTF-8''Example%20VPN
Subscription-Userinfo: upload=0; download=2147483648; total=107374182400; expire=1798761600
profile-update-interval: 12
reclash-config: https://example.net/reclash.yaml

proxies:
  - name: Germany
    type: socks5
    server: de.example.net
    port: 1080
proxy-groups:
  - name: Proxy
    type: select
    proxies: [Germany]
rules:
  - MATCH,Proxy
```

```yaml
version: 1
provider:
  name: Example VPN
  support-url: https://t.me/example_support
```

## 节点字段

可用于 `proxies:` 中的节点或 proxy provider 载荷中的节点的两个可选键：

```text
proxies:
  - name: Frankfurt 1
    type: vless
    desc: Streaming, 1 Gbit/s
    favorite: true
```

- `desc` 会替换节点卡片上的协议显示，并且可被搜索。`description`、`serverDescription` 和 `server-description` 可作为别名使用。
- `favorite: true` 会给节点加星标。用户自己点击星标会翻转服务商的标记，因此带星标的节点可以被取消星标，并保持该状态。

## 兼容性

- 其他客户端的请求头会被当作标准请求头读取：`Subscription-Userinfo`、`Content-Disposition`、`profile-title`、`profile-update-interval`、`profile-web-page-url`、`support-url`、`announce`、`hide-url`。
- 已经提供这些请求头的服务商只需再添加一个 `reclash-config` 请求头。其他客户端会忽略它。Remnawave 面板需要一条响应规则（[Remnawave](rollout.md#remnawave)）。
- 预设可以让 ReClash 表现为另一个客户端（[客户端预设](request.md#client-presets)）。它绝不会启用设备 ID。

## 页面

| 页面 | 内容 |
| --- | --- |
| [响应头](headers.md) | 标准请求头、值格式、别名、清单指针。 |
| [服务商清单](manifest.md) | 快速开始、完整示例、编辑器校验；服务商面板、提醒、设置、策略、应用、传输、支持、外观、卡片、电量标签、路由。 |
| [请求头](request.md) | 客户端请求头、预设、重定向、状态码、备用主机、设备 ID。 |
| [安全策略](policy.md) | `policy` 部分：GLOBAL 白名单、禁用全局模式、必需的 Android 排除项。 |
| [预览 API](preview-api.md) | 浏览器导入前的展示。 |
| [支持报告与修复链接](support.md) | 一键报告、上传端点、签名的修复链接。 |
| [交付与调试](rollout.md) | 部署、Remnawave、验证、故障、检查清单。 |
| [标准注册表](standard.md) | 生成的请求头与清单字段表。 |
