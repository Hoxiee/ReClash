# 请求头

ReClash 获取订阅时发送的内容、如何选择客户端身份，以及如何处理重定向、状态码和备用主机。

## 客户端请求头

| 请求头 | 值 |
| --- | --- |
| `User-Agent` | 由[客户端预设](#client-presets)设定。 |
| `Accept-Encoding` | `gzip, deflate` |
| `Authorization` | `Basic`，由订阅 URL 的 userinfo 生成。 |
| `x-hwid` | 设备 ID，仅在[启用](#device-id)时发送。 |
| `x-client`、`x-app-version`、`x-device-locale`、`Accept-Language` | 仅在 Happ 和 INCY 预设下发送。 |

## 客户端预设

配置的“请求客户端”设置决定使用哪个预设。新配置使用“自动”；在该设置出现之前创建的配置使用 ReClash。

| 预设 | `User-Agent` | 额外请求头 |
| --- | --- | --- |
| ReClash | `ReClash/v<version> clash-verge Platform/<os>` | — |
| FlClashX | `FlClash X/v0.4.2 core/v1.19.28 Platform/<os>` | — |
| Clash Meta | `ClashMetaForAndroid/2.11.36.Meta` | — |
| Clash | `ClashForAndroid/2.5.12` | — |
| Happ | `Happ/4.7.1/<Platform>/17912103176801703650` | `x-device-locale: <language>` |
| INCY | `INCY/3.3.1` | `x-client: INCY`、`x-app-version: 3.3.1`、`x-device-locale: <locale>`、`Accept-Language: <locale>` |
| sing-box / Karing | `Karing/1.2.25.2802` | — |
| v2rayNG | `v2rayNG/2.3.11` | — |
| 自定义 User-Agent | 用户输入的文本，最多 512 个字符，不含控制字符 | — |

`<os>` 为 `android`、`windows`、`macos` 或 `linux`。应用级的 User-Agent 设置可以替换 ReClash 的值。

### 自动协商

“自动”首先尝试上次成功的预设，然后按表中从 ReClash 到 v2rayNG 的顺序尝试。会发送相同请求头的预设会被跳过。20 秒内最多尝试 8 次。

只有在返回 `406`、`415` 或无法识别正文格式时，才会尝试下一个预设。其他任何失败都会终止协商。

预设只改变请求头，绝不改变设备 ID。

## 重定向与传输

- 最多 5 次重定向。每个响应必须恰好带有一个 `Location`。循环以及从 `https` 到 `http` 的重定向会失败。
- 重定向到其他源时，只保留 `User-Agent`、`Accept` 和 `Accept-Language`。设备 ID 和授权信息会被丢弃。
- `Content-Encoding` 必须是 `gzip`、`deflate` 或 `identity`，且只发送一次。Gzip 和 zlib 正文也会通过魔数字节检测。
- 正文传输时最大 16 MiB，解码后最大 32 MiB。正文为空则失败。
- 不检查 `Content-Type`。

## 响应格式

ReClash 在本地检测正文格式。原生 Clash YAML 保持原样；分享链接列表、Xray JSON（单个配置或数组）、sing-box JSON、WireGuard 以及受支持的 Amnezia 容器会在 Core 校验之前转换为 Clash YAML。

分享链接列表接受纯文本、Base64 和 Base64url。支持的协议方案包括 `mierus`、`tt`（TrustTunnel）、`socks5h`、`hysteria2+realm` 和 `hy2+realm`；Mieru 链接可以定义多组端口/协议。设置了 anti-DPI、客户端随机前缀或多个地址的 TrustTunnel 链接导入时会带有丢失警告，因为 Core 无法表达这些字段。在可识别的列表中，无法识别或格式错误的节点链接会被报告为已跳过。

VLESS XHTTP 转换会保留受支持的 `extra` 选项，包括请求头、填充、连接复用和独立的下载连接。不受支持或格式错误的 extra 选项会被报告为转换损失。外来的 DNS、入站及其他未转换的配置部分同样会被报告，Xray 数组中的每个配置也是如此。在 VLESS 上，Xray `mux` 会转换为 `mux.cool`。Xray 会把小于 128 的 TCP `concurrency` 提高到 128，导入器保留这一生效值；负值会禁用 mux。Vision 节点仅在关闭 TCP 多路复用（`concurrency: 0` 或缺失）并启用 XUDP（`xudpConcurrency > 0`）时保留 mux：导入器写入 Core 的 `concurrency: 0`（不建立 TCP 池），因此 TCP 保持普通 Vision，只有 UDP 被多路复用；其他 Vision mux 记为转换损失，非 VLESS mux 同样记为转换损失。既没有 TCP 池也没有 XUDP 的块会被丢弃。存在损失时需要批准，或该来源已接受导入策略；未经批准的更新会让已保存的配置保持不变。

## 响应状态

| 响应 | 结果 |
| --- | --- |
| 任意状态码下的 `x-hwid-max-devices-reached: 1` | 设备数量上限失败。若同一响应中的 `support-url` 是 `http(s)` 链接，错误提示会提供该链接。 |
| `401`、`403` | 未授权。 |
| `429` | 被限流。 |
| `406`、`415` | 失败；“自动”会尝试下一个预设。 |
| 其他非 `2xx` | 失败。 |
| `2xx` 但正文为空，或没有节点、组或远程 provider | 失败。 |
| `2xx` 但格式未知 | 失败；“自动”会尝试下一个预设。 |

更新失败时，已保存的配置、其元数据和清单都保持不变。

## 备用主机

这两个字段仅适用于 `https` 订阅。路径和查询参数保持不变，只替换 `host[:port]`。

| 清单键 | 值 | 行为 |
| --- | --- | --- |
| `transport.fallback-hosts` | 最多 5 个 `host[:port]` | 主主机出现传输、TLS、超时、限流或无效响应错误后，按顺序尝试。绝不会替换已保存的 URL。 |
| `transport.new-domain` | 一个 `host[:port]` | 优先尝试。更新成功后，会获取并校验新主机；只有成功时配置才会迁移到它。失败则忽略。 |

备用主机来自已保存的[清单](manifest.md#transport)，因此必须先有一次成功的更新来交付它。发往备用主机的请求携带与主主机相同的请求头，包括设备 ID。

```yaml
transport:
  fallback-hosts: [sub2.example.net, sub3.example.org:8443]
  new-domain: sub.example.com
```

## 设备 ID

### 取值

| 请求头 | 值 |
| --- | --- |
| `x-hwid` | 对 `ReClash/HWID/v1\0` 与平台 ID 做 SHA-256 后，取前 32 个小写十六进制字符。 |
| `x-device-os`、`x-ver-os`、`x-device-model` | 操作系统名称、操作系统版本和设备型号。这三个请求头与 `x-hwid` 一同发送；平台未报告的值为空。 |

平台 ID 在 Android 上是 `ANDROID_ID`，在 Windows 上是 `MachineGuid`，在 macOS 上是系统 GUID，在 Linux 上是 `/etc/machine-id`。若不存在则使用随机值。该 ID 按设备保存，对所有配置相同，并且不包含在备份中。它是一个假名标识符，不是硬件证明。

### 同意

- “发送 HWID”有全局值和按配置的覆盖；“使用全局设置”则跟随全局值。
- 开启时会显示说明。
- 该 ID 只会发送到订阅 URL 的源及其备用主机。跨源重定向会丢弃它，位于其他源的清单永远不会收到它。
- [预览 API](preview-api.md)和图标请求从不携带它。

## 设备状态

| 请求头 | 值 | 效果 |
| --- | --- | --- |
| `x-hwid-max-devices-reached` | `1`、`true` 或 `yes` | 更新失败并提示设备数量上限错误（[响应状态](#response-status)）。 |
| `x-hwid-not-supported` | `1`、`true` 或 `yes` | 在订阅检查器中显示为“设备状态”。 |

仅当请求头只发送一次时，标志才有效。两者同时设置时，设备数量上限优先。
