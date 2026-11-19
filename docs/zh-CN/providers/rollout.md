# 交付与调试

提供商上线检查清单、如何提供响应头和清单文件、如何核实 ReClash 收到了什么，以及如何诊断故障。

## 上线检查清单

### 订阅

- [ ] 正文是有效的 mihomo 配置，至少包含一个节点、组或远程 provider，且不含 `reclash-*` 或 `rcx-*` 键。
- [ ] 存在 `Subscription-Userinfo` 且内容正确。
- [ ] 非 ASCII 的响应头文本使用 `base64:`。
- [ ] 每个响应头只发送一次，并能穿过每一层代理，包括 CDN。
- [ ] `reclash-config` 在 `https` 响应中发送，并指向 `https` URL。
- [ ] 仅在拒绝设备时才发送 `x-hwid-max-devices-reached`（[设备 ID](request.md#device-id)）。

### 清单

- [ ] 文件通过 `provider-config.schema.json` 校验（[在编辑器中校验](manifest.md#validate-in-your-editor)），其路由通过 `dart run tool/rcx.dart lint`。
- [ ] 每个会更改设置的部分都是有意为之（[所有权](manifest.md#ownership)）。
- [ ] 文件通过 `https` 在稳定的 URL 上提供，不超过 512 KiB。
- [ ] 备用主机提供相同的路径和查询。

### 策略

- [ ] `policy.global: listed` 要求正文中有一个 `GLOBAL` 组，使用 `filter` 或 `proxies`，且恰好产出你允许的节点。请检查客户端实际收到的正文。
- [ ] `policy.apps: required` 要求正文中有 `tun.exclude-package`（[安全策略](policy.md)）。
- [ ] 任何[预览 API](preview-api.md)端点都不会改变账号状态。

### 在应用中

- [ ] 更新一个真实的配置文件，打开[订阅检查器](#subscription-inspector)，确认没有警告，也没有过期字段。
- [ ] 仪表板显示提供商名称、卡片，以及标记为“来自服务商”的设置。
- [ ] 再次更新配置文件：各部分和设置保持已应用状态。

## 提供

- 在订阅 URL 上发送标准响应头，外加一个指向清单的 `reclash-config` 响应头。代理和 CDN 必须原样透传响应头。
- 把清单托管在任意静态 HTTPS 主机上（[交付](manifest.md#delivery)）。通常使用一个共享 URL；按用户区分的内容需要带令牌的 URL。
- `reclash-config` 响应头只在 `https` 响应中生效，重定向也必须以 `https` 结束。
- 将非 ASCII 的响应头文本编码为 `base64:`（[值格式](headers.md#value-formats)）。原始 UTF-8 经常被破坏。清单文本是纯 UTF-8 YAML。
- 限制：每个响应头值 8 KiB，所有响应头共 64 KiB，清单 512 KiB。超过响应头限制会导致获取失败。
- 每个响应头只发送一次。重复的会被忽略。
- 省略 `reclash-config` 会删除已存储的清单。`x-hwid-max-devices-reached` 无论状态码如何都会使更新失败。
- 没有自定义响应头时，提供商除标准响应头外无法获得任何 ReClash 功能。

## Remnawave

在 Subscription → Response Rules 中，于默认的 `Fallback Base64` 规则之上添加一条[响应规则](https://docs.rw/docs/learn-en/routing-rules)。规则自上而下执行，并在第一个匹配处停止。

```json
{
  "name": "ReClash",
  "description": "Mihomo config and manifest for ReClash",
  "enabled": true,
  "operator": "AND",
  "conditions": [
    { "headerName": "user-agent", "operator": "STARTS_WITH", "value": "reclash", "caseSensitive": false }
  ],
  "responseType": "MIHOMO",
  "responseModifications": {
    "applyHeadersToEnd": true,
    "headers": [
      { "key": "reclash-config", "value": "https://example.net/reclash.yaml" }
    ]
  }
}
```

这条规则有两个作用：

- 它提供 mihomo YAML。`ReClash/…` 不匹配任何默认的客户端规则，因此没有这条规则时，默认面板会以 `Fallback Base64` 应答。Base64 列表没有 `GLOBAL` 组，也没有 `tun.exclude-package`，所以 `policy` 没有可强制执行的内容。
- 它只向 ReClash 发送清单。其他客户端永远看不到该响应头。

如需以不同方式提供清单：

| 谁获得清单 | 响应头放在哪里 |
| --- | --- |
| 仅 ReClash | 上面的规则。 |
| ReClash，每个套餐一个清单 | 从规则中删除 `headers`，并把响应头添加到每个 external squad（Users → External Squads → squad → Headers）。不在任何 squad 中的用户得不到清单。该 squad 中的其他客户端也会收到该响应头并将其忽略。 |
| 所有客户端 | Subscription → Settings → Response headers。其他客户端会忽略它。 |

规则中保留的、带 `applyHeadersToEnd: true` 的响应头会覆盖 squad 的响应头。

### mihomo 模板中的策略

把 `GLOBAL` 和 `tun.exclude-package` 放进 mihomo 模板，并用 `policy` 启用它们（[安全策略](policy.md)）。如果不想让其他客户端也拿到它们，请在规则的 `responseModifications` 中用 `subscriptionTemplate` 为 ReClash 指定专用模板。

> [!WARNING]
> Remnawave 会把每个主机追加到所有没有 `remnawave: { include-proxies: false }` 的组，即使该组带有 `filter`。没有它时，`global: listed` 会放行所有主机，[检查器](#subscription-inspector)会警告 `policy.global is listed, but GLOBAL reaches every inline node of the body, so the lock restricts nothing`。请在 `GLOBAL` 以及 `GLOBAL` 能到达的每个组上设置它。主机名称必须带有过滤标记，因为主机的 `tags` 不会进入配置。

```text
proxy-groups:
  - name: GLOBAL
    type: select
    include-all-proxies: true
    filter: '\bLTE\b'
    remnawave: { include-proxies: false }
```

### 需要了解的事项

- 向用户提供基础订阅 URL。形如 `/<short>/mihomo` 的特定类型 URL 会跳过响应规则，因此不携带清单。
- 该规则依赖 User-Agent，而用户可以更改它。选择了其他[客户端预设](request.md#client-presets)的用户得不到清单，也没有锁定。如果这很重要，请向所有客户端发送该响应头，并让规则仅用于 mihomo YAML。
- `Subscription-Userinfo` 和 `Content-Disposition` 随每个配置响应一起提供。`profile-title`、`profile-update-interval`、`support-url` 和 `profile-web-page-url` 来自 Response headers，新面板默认会填写它们。`announce` 需要 HWID 的 `maxDevicesAnnounce` 设置。ReClash 把它们都当作标准响应头来读取。
- 把清单托管在任意静态主机上（[快速开始](manifest.md#quick-start)）。

已在 Remnawave 3.4.7 上验证。其他版本的面板标签可能不同。

## 验证

使用 ReClash 预设重复该请求：

```sh
curl -sS -D - -o /dev/null \
  -H 'User-Agent: ReClash/v1.0.0 clash-verge Platform/android' \
  -H 'Accept-Encoding: gzip, deflate' \
  'https://sub.example.net/s/TOKEN'
```

获取响应头所指向的清单，并确认它是通过 `https` 提供的纯 YAML：

```sh
curl -sS -D - 'https://example.net/reclash.yaml'
```

在应用中：

| 位置 | 显示内容 |
| --- | --- |
| 配置文件编辑器 → 兼容性 → 检查 | 成功的预设、检测到的格式、节点数量。不保存任何内容。 |
| 配置文件 → 配置文件菜单 → 订阅检查器 | 解码并保留了什么（[订阅检查器](#subscription-inspector)）。 |
| 仪表板和应用设置 | 已应用的提示，标记为“来自服务商”。 |

## 订阅检查器

| 项目 | 含义 |
| --- | --- |
| 来源 | 如果有任何字段来自响应头则为 `http`，否则为 `body`。 |
| 接收时间 | 最近一次成功更新的时间。 |
| 设备状态 | 已发送时为 `limitReached` 或 `unsupported`。 |
| 警告 | 解码器和清单的警告，例如绑定到不存在的组、`Invalid provider field`、`Duplicate singleton`、`Unsupported provider field`。 |
| 字段 | 按响应头名称列出的已存储字段，含信任级别，以及用量字段缺失时的 `stale` 标记。 |

## 常见故障

| 症状 | 原因 |
| --- | --- |
| 响应头字段缺失，并出现 `Invalid provider field` | 值违反其类型：带 userinfo 的 URL、控制字符、数字超出范围。 |
| 清单未应用 | `reclash-config` 不在 `https` 响应中、URL 或重定向不是 `https`、超过 512 KiB、YAML 无效，或 `version` 不是 `1`。最后一份有效副本会保留；警告见检查器。 |
| 清单的某个部分不起作用 | 该部分无效并已带警告被忽略，或未知键被忽略。请查看检查器。 |
| 旧的清单值消失 | 新的有效副本缺少该部分，或响应缺少 `reclash-config`。两者都会撤回这些值。 |
| `reclash-*` 响应头出现 `Unsupported provider field` | 只读取 `reclash-config`。请把该值移入清单。 |
| 提醒停止 | 用量字段过期、缺少 `Subscription-Userinfo`、`expire=0` 或 `total=0`。 |
| 更新间隔被忽略 | 配置文件编辑器中的“使用服务提供方的更新间隔”已关闭。它默认开启；用户已保存的选择会被保留。 |
| 间隔被拒绝 | 从小时换算后低于 5 或高于 43200 分钟。 |
| 设置不再跟随提供商 | 用户已更改它。“交还给服务商”可还原。 |
| 备用主机未被尝试 | 订阅为 `http`、这些主机尚未进入已存储的清单，或失败原因是 `401`、`403` 或设备数量上限。 |
| `transport` 部分被忽略 | `new-domain` 是列表，或 `fallback-hosts` 是字符串。 |
| 路由绑定未应用 | 绑定指向正文中不存在的组，例如重命名之后。请更新清单。 |
| 全局模式消失 | `policy.global: off`，或 `policy.global: listed` 但 `GLOBAL` 组解析不到任何节点。 |
| 带策略时提示“重启 VPN” | VPN 运行期间所需的排除项发生了变化。 |
| 自动协商在第一个错误处停止 | 只有 `406`、`415` 和未知的正文格式才会尝试下一个预设。 |
| 非 ASCII 文本乱码 | 响应头中使用了原始 UTF-8。请使用 `base64:`。 |
