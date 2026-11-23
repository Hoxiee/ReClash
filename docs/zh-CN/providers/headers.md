# 响应头

订阅响应可以携带的标准 HTTP 响应头、它们的值格式，以及指向提供商清单的 `reclash-config` 响应头。

所有响应头、别名和限制都在[标准注册表](standard.md)中。提供商告知 ReClash 的其他一切都在[提供商清单](manifest.md)中；设备响应头见[请求头](request.md#device-status)。

## 解析

- 响应头名称不区分大小写。
- 字段先从其标准响应头读取，再从其[来自其他客户端的别名](#headers-from-other-clients)读取。第一个有效值生效；清单会覆盖两者。
- 发送多次的字段会被忽略：`Duplicate singleton`。
- 无效值会被丢弃：`Invalid provider field`。响应的其余部分仍会应用。
- 单个响应头值超过 8 KiB，或所有响应头合计超过 64 KiB，会导致获取失败。
- 响应中缺失的字段会被撤回，用量字段除外，它们会变为过期（[元数据生命周期](README.md#metadata-lifetime)）。
- 空的 `text` 值是有效的，并会替换已存储的值。`url`、`integer` 和 `boolean` 字段无法清除。
- 元数据只从响应头读取。正文不携带元数据。除 `reclash-config`、`reclash-aliases` 和 `reclash-update` 之外的 `reclash-*` 响应头会被忽略，并在订阅检查器中给出 `Unsupported provider field` 警告。

## 值格式

| 类型 | 语法 | 规则 |
| --- | --- | --- |
| `text` | UTF-8，或 `base64:` / `base64,` 后接 UTF-8 的 Base64 | 解码后最多 1024 字节，除非字段另有说明。不含控制字符；`announce` 中允许 LF。 |
| `url` | 绝对 `http` 或 `https` URL | 必须有主机。不含 userinfo、空白或控制字符。最多 1024 个字符。 |
| `integer` | 十进制 | 乘以别名比例后再检查范围。 |
| `boolean` | `1`、`true`、`yes` / `0`、`false`、`no` | 不区分大小写。 |

## Subscription-Userinfo

```http
Subscription-Userinfo: upload=455727941; download=6174315083; total=107374182400; expire=1798761600
```

| 键 | 含义 |
| --- | --- |
| `upload`、`download` | 已使用的字节数。 |
| `total` | 字节配额。`0` 表示无限制。 |
| `expire` | 以秒为单位的 Unix 时间。`0` 表示永不过期。 |

键不区分大小写，以 `;` 分隔。值为非负数，截断为整数；`expire` 最大为 `8640000000000`。重复的键会被丢弃。

## 配置文件名称

用户尚未命名的配置文件会采用以下第一个可用的名称：

1. `Content-Disposition` 文件名（先 `filename*`，再 `filename`）；
2. `profile-title`（文本，160 B）；
3. [清单](manifest.md#provider)中的 `provider.name`；
4. 订阅主机。

用户设置的名称永远不会被替换。`profile-title` 命名的是账号，而不是服务。

## 更新间隔

`profile-update-interval` 以小时为单位设置更新间隔。换算为分钟后必须在 5–43200 之间。仅当配置文件编辑器中“使用服务提供方的更新间隔”开启时才会生效，该选项默认开启。用户已保存的选择会被保留。没有清单字段可以设置它。

## 别名

当清单未设置[清单 `provider`](manifest.md#provider) 的某个字段时，四个标准响应头会填充该字段。清单设置了该字段时以清单为准。

| 响应头 | 清单字段 | 类型 |
| --- | --- | --- |
| `support-url` | `provider.support-url` | url |
| `profile-web-page-url` | `provider.web-url` | url |
| `announce` | `provider.announce` | 文本，多行，1024 B |
| `hide-url` | `provider.hide-url` | boolean |

## 来自其他客户端的响应头

其他 VPN 客户端已经发送的响应头会被读作现有字段的别名，因此提供商无需添加 ReClash 专用的响应头。

- 字段先从其标准响应头读取，再按下面列出的顺序从其别名读取。第一个有效值生效；无效值会带警告被丢弃，然后尝试下一个。
- 托管的清单（[`reclash-config`](manifest.md)）会覆盖两者。
- 带清单指针的响应仅以清单为准：除非它同时发送 `reclash-aliases: 1`，否则别名处于关闭状态。客户端无法使用的指针（非 `https` 响应）不计入。
- 没有清单指针时别名处于开启状态；`reclash-aliases: 0` 将其关闭。`1`、`true`、`yes`、`0`、`false` 或 `no` 之外的值在任何情况下都会将其关闭，并给出 `Invalid provider field` 警告。
- 主机别名（`transport.*`）仅从 `https` 响应中读取。
- 别名只携带显示和传输提示。设置、应用、路由和策略永远不会从它们读取；`flclashx-view`、`flclashx-widgets`、`flclashx-settings`、`flclashx-special`、Happ 路由以及按应用的响应头等都会被忽略。
- `profile-update-interval` 无需换算：在所有已检查的客户端中它都以小时为单位，与 ReClash 相同。
- 迁移到清单的提供商可以继续为其他客户端发送这些响应头。

| 别名响应头 | 客户端 | ReClash 字段 | 说明 |
| --- | --- | --- | --- |
| `flclashx-servicename` | FlClashX | `provider.name` | 文本；允许 `base64:` 前缀。 |
| `isp-name` | Karing | `provider.name` | 百分号编码的文本。 |
| `flclashx-servicelogo` | FlClashX | `provider.logo` | 与标准响应头相同。 |
| `profile-logo` | Koala Clash | `provider.logo` | 与标准响应头相同。 |
| `homepage` | Incy | `provider.web-url` | 与标准响应头相同。 |
| `isp-url` | Karing | `provider.web-url` | 与标准响应头相同。 |
| `flclashx-buyplan` | FlClashX | `provider.renew.url` | `<url>[,<n>]`；`n` 进入 `provider.renew.days`。 |
| `sub-expire-button-link` | Happ | `provider.renew.url` | 与标准响应头相同。 |
| `flclashx-buytraffic` | FlClashX | `provider.top-up.url` | `<url>[,<n>]`；`n` 进入 `provider.top-up.percent`。 |
| `announce-url` | Incy, v2RayTun | `provider.announce.url` | 与标准响应头相同。 |
| `subscription-name` | Incy | 配置文件名称（无清单路径） | 与 `profile-title` 一样填充配置文件名称；文本，允许 `base64:` 前缀。 |
| `flclashx-newdomain` | FlClashX | `transport.fallback-hosts` | 主机列表，最多 5 个。 |
| `new-domain` | Happ | `transport.new-domain` | 主机列表，最多 1 个。 |

格式：`plain` 值遵循标准响应头的[值格式](#value-formats)；`urlWithNumber` 会带警告丢弃无效的 `n` 并保留 URL；`hostList` 接受以逗号分隔的 `host`、`host:port` 或 `scheme://host[:port]/...` 列表，并缩减为 `host[:port]`、去重并限制数量。

## 清单指针

```http
reclash-config: https://example.net/reclash.yaml
```

它是承载清单的 `reclash-*` 响应头。它是 `url`，只在 `https` 响应中生效。交付规则见[清单交付](manifest.md#delivery)。其他客户端会忽略它。

## 更新镜像

```http
reclash-update: https://updates.example.net/update-manifest.json
```

一个仅在 `https` 下生效的 `url`。它指向由提供商托管的、ReClash 已签名更新清单的副本，并从当前配置文件的订阅响应中读取。

- 默认情况下，ReClash 先检查官方签名发布目录，目录不可用时再检查 GitHub。如果官方来源均不可用，应用会尝试提供商镜像。
- 在托管配置中设置 [`updates.prefer-mirror: true`](manifest.md#updates) 可优先检查提供商镜像。在此顺序下，如果镜像正常返回且没有更新的版本，ReClash 会接受这个结果。镜像出现故障时会尝试官方来源。
- 应用自己从条目中选择其渠道（稳定版或预发布版）和平台资源。资源 URL 必须为 `https`。
- 对镜像的轮询开销很小：ReClash 会发送 `If-None-Match` 和 `If-Modified-Since`，因此返回 `304` 的静态主机几乎没有成本。请为该文件提供 `ETag` 或 `Last-Modified`。

### 清单格式

每个 ReClash 版本都会把 `update-manifest.json` 作为发布资源发布：

```json
{
  "releases": [
    {
      "tag": "v1.2.3",
      "prerelease": false,
      "notes": "…",
      "assets": [{"name": "…", "size": 0, "sha256": "…", "url": "https://…"}],
      "signature": "…"
    }
  ]
}
```

Ed25519 签名由 ReClash 持有的密钥生成，并用内置于应用的公钥校验，覆盖标签、渠道、说明以及每个资源的 `name`、`size` 和 `sha256`。镜像可以改写 `url` 字段，并把多个清单的条目（例如最新的稳定版和最新的预发布版）合并到同一个 `releases` 数组中。可选字段 `published_at` 用于显示发布日期。修改签名覆盖的字段会导致该条目被忽略。

```sh
# Point every asset at the mirror
jq --arg base https://cdn.example/reclash '.releases[].assets[] |= (.url = ($base + "/" + .name))' update-manifest.json

# Merge two manifests
jq -s '{releases: map(.releases[]) }' stable.json pre.json
```

拥有仓库的维护者可以验证文件：`dart run tool/update_manifest.dart verify <file> --key <public key>`。

### 检查时机

ReClash 在启动和回到前台时检查更新。上次检查成功后，启用内置发布目录的构建至少间隔 15 分钟，其他构建至少间隔一小时。检查失败后，再次回到前台时可按 2、5、15 或 30 分钟的间隔重试，连接 VPN 时可立即重试。启用内置发布目录时，每个渠道每小时最多通过 GitHub 进行一次备用检查。

如果 GitHub 和内置镜像均提供同一个安装包，ReClash 会测量各来源下载一小段数据所需的时间。应用优先从最快的来源下载，失败时切换来源，并在安装前校验 SHA-256。

## 设备状态

| 响应头 | 页面 |
| --- | --- |
| `x-hwid-max-devices-reached`、`x-hwid-not-supported` | [设备状态](request.md#device-status) |
