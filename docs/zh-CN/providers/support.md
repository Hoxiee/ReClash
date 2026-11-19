# 支持报告与修复链接

用户如何用一个按钮把问题的全部信息发给你，以及你如何用一个链接来修复它。

## 报告

用户点击“报告问题”。应用会检查连接，测试配置中的每台服务器，并把结果打包成一个归档。在用户发送之前，任何内容都不会离开设备。

报告 ID（`RC-XXXX-XXXX`）出现在文件名、摘要和每个文件中。请先向用户索要它。

```text
reclash-report-2026-11-04-1530-RC-7K3F-92QD.zip
├── README.md            what this is and how to read it
├── report.html          open in a browser: everything below on one page
├── 01-summary.md        verdict, failed step, findings, the user's note
├── 02-findings.json     problems found, what auto-repair tried
├── 03-path.json         connection check, step by step, with timings
├── 04-servers.csv       every server: DNS, TCP, delay, error
├── 05-services.json     services through the tunnel and direct
├── 06-environment.json  hosts file, other VPNs and proxies, DNS, ports
├── 07-profile.json      your headers, update times, groups, selections
├── 08-history.json      the last 7 days: incidents, repairs, crashes
├── 09-config.yaml       the effective config
├── logs/                core.log, app.log, logcat.txt, capture.log
└── report.json          app, OS, device, locale, file list
```

每个 JSON 文件都有 `schema` 字段（`reclash.report.*@1`），因此面板可以解析报告。

- **先读：** `report.html` 或 `01-summary.md`。`04-servers.csv` 可以区分“服务器宕机”与“服务器在此网络上被封锁”。
- **脱敏：** 密码、UUID、密钥和 URL 令牌会被遮蔽。启用“公开”脱敏时，主机和 IP 也会被哈希。仍会包含机密信息的报告不会被创建。
- **大小：** 最大 10 MB；最旧的日志行最先被丢弃。

## 接收报告

默认情况下，用户会把归档发送到 `provider.support-url` 对应的聊天。在移动端通过分享面板发送；在桌面端，应用会保存文件、复制摘要并打开聊天。

若要直接接收报告，请在[清单](manifest.md#support)中设置上传 URL：

```yaml
support:
  upload-url: https://support.example.com/reclash/reports
```

应用会询问用户一次（会指明你的域名），随后发送：

```http
POST /reclash/reports HTTP/1.1
Content-Type: multipart/form-data; boundary=…

id=RC-7K3F-92QD
summary=<the text of 01-summary.md>
report=<the zip, application/zip>
```

`2xx` 响应表示成功。可选的 JSON 正文：`{"ticket": "4211", "message": "We'll answer within an hour"}`；应用会显示 `message`（最多 200 个字符）和 `ticket`。只接受 `https` URL。

## 修复链接

你用一个链接来回复；用户点击它，查看它将执行的操作并确认。

```text
reclash://fix?p=<payload>&s=<signature>
```

陌生人无法伪造这样的链接：它用你的密钥签名，应用会用你清单中的密钥进行校验。

### 密钥

只需生成一次密钥，并把私钥保存在你的服务器上：

```sh
go run ./core/cmd/reclash-fix keygen -out key.txt
go run ./core/cmd/reclash-fix header -key key.txt
```

`keygen` 会把私钥写入 `key.txt`（绝不会覆盖已有文件），并打印两行：

```text
support.keys value: ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik
kid: E545QOZLVJE
```

把 `ed25519:…` 值放入[清单](manifest.md#support)。`header` 会根据 `key.txt` 再次打印这个纯值；`kid` 是链接载荷中的密钥标识符。

```yaml
support:
  keys: ["ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik"]
```

- 仅接受来自 `https` 响应中所指定清单的密钥；每次更新时刷新。
- 最多两个密钥（一个列表），用于轮换。

### 为链接签名

```sh
go run ./core/cmd/reclash-fix sign -key key.txt -report RC-7K3F-92QD -ttl 48h \
  profile.update proxy.select:group=Auto,node=NL-1
```

标志必须放在操作之前。`-ttl` 最大为 `168h`。`verify -header 'ed25519:…' <link>` 用于检查链接。

### 操作

| 操作 | 效果 |
| --- | --- |
| `profile.update` | 更新订阅 |
| `profile.activate` | 将你的配置设为当前使用的配置 |
| `proxy.select:group=G,node=N` | 在你的某个组中选择一个节点 |
| `connections.reset` | 清空 DNS 和 fake-IP，关闭连接 |
| `core.restart` | 重启 Core |
| `overrides.reset` | 将用户的覆写重置为默认值（可撤销） |
| `config.ruleMode`、`config.freePort`、`dns.ignoreSystemHosts`、`proxy.clearOwn`、`tunnel.freeDeviceName`、`tunnel.restart` | 来自应用自带目录的修复 |

链接绝不会更改订阅 URL、添加配置、应用配置或打开 URL。它只作用于由其密钥签名的那个配置。

### 链接何时被拒绝

出现以下情况时，应用不会应用任何内容，并说明原因：

- 链接超过 2 KB 或格式错误；
- 密钥不在用户的任何订阅中；
- 签名不匹配；
- 已过期，或到期时间超过 7 天之后；
- 已被使用过；
- 报告 ID 不是来自此设备、不是针对你的配置，或已超过 30 天；
- 包含未知操作。

因此，一个链接只能使用一次，且只在生成报告的那台设备上有效。

### 传输格式

适用于不使用 CLI 的面板集成。`p` 是 UTF-8 JSON 载荷的 base64url，`s` 是对这些字节本身所做 Ed25519 签名的 base64url，所有地方都不带填充。

```json
{"v":1,"kid":"E545QOZLVJE","rid":"RC-7K3F-92QD","exp":1767225600,"nonce":"AAECAwQFBgcICQoL","fix":[{"id":"profile.update"},{"id":"proxy.select","group":"Auto","node":"NL-1"}]}
```

- `kid`：对 32 字节公钥做 SHA-256 后取前 8 个字节的 base64url。
- `exp`：Unix 秒。`nonce`：12 个随机字节的 base64url。
- 未知字段会被拒绝。

> [!TIP]
> 测试向量：由 32 个零字节生成的密钥得到上面的密钥，对此载荷签名得到 `s=XEdYg90ecSzT7cV1dRxH9cCVLpw01KXGiWC1Lz4iUD0kYga2zSoZwr1VQnkXVkVlyx5D3L3fGx_ursuvQvmBDQ`。
