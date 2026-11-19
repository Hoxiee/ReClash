# 预览 API

一个只读的 JSON 端点,版本 1,用于在用户从浏览器订阅页面确认导入之前提供提供者的展示信息。

它与订阅下载相互独立,也独立于应用于已保存配置档的[提供者清单](manifest.md)和[响应头](headers.md)。

## 发现

浏览器订阅页面恰好带有一个链接元素:

```text
<link rel="reclash-preview" href="/reclash/preview/account-scoped-token">
```

- 相对 URL 相对于最终页面 URL 解析。
- 端点必须与页面同源(协议、主机和端口),不能是页面本身,也不能包含片段。
- ReClash 不会探测常规路径,也不会运行 JavaScript 来寻找它。
- 通过 URL 中不透明的账户级令牌实现个性化。不要要求设备 ID 或浏览器登录。

## 请求

- `GET`,带 `Accept: application/json` 和浏览器预览用的 `User-Agent`。
- 不带设备 ID、客户端预设头、Cookie、`Authorization` 或 `Referer`。
- 重定向遵循订阅传输规则。只接受最终同源的 JSON 响应。

## 响应

`Content-Type: application/json`,UTF-8 JSON,最大 64 KiB。

```json
{
  "version": 1,
  "provider": {
    "name": "Example VPN",
    "description": "Contact support to install your subscription.",
    "logoUrl": "/assets/provider-logo.png",
    "supportUrl": "https://t.me/example_support"
  },
  "account": {
    "name": "Personal account"
  },
  "subscription": {
    "type": "test"
  }
}
```

| 字段 | 类型 | 规则 |
| --- | --- | --- |
| `version` | integer | 必填,为 `1`。 |
| `provider.name` | string,256 个字符 | 确认页头部中的服务名称。 |
| `provider.description` | string,4096 个字符 | 确认页正文中的描述。 |
| `provider.logoUrl` | URL | 绝对地址,或相对于 API URL;`http(s)`。`https` 页面不能指向 `http`。PNG、JPEG、WebP、GIF、SVG 或 ICO,最大 512 KiB。图片加载失败时保留字母图标;不会获取外部 SVG 资源。 |
| `provider.supportUrl` | URL | `http(s)` 或经过验证的 Telegram 链接,相对于 API URL。作为顶栏操作显示,并需经过常规的外部链接确认;从不自动打开。 |
| `account.name` | string,256 个字符 | 账户名称,与提供者及可编辑的配置档名称分开显示。 |
| `subscription.type` | string,32 个字符 | `test`、`promo` 或 `dev` 会在名称下显示徽章;其他值不显示。 |

- 除 `version` 外,所有字段均为可选。未知字段会被忽略。
- 文本为纯文本,绝不是 HTML 或 Markdown。
- 无效字段会被丢弃,且不会替换页面元数据。
- 版本不受支持、JSON 格式错误、响应过大或请求失败时,会回退到页面元数据,且从不阻止导入。
- Logo 请求即使在同源时也不带 Cookie、`Authorization`、`Referer` 或设备 ID。
- JSON 中的脚本、样式、应用列表、遥测端点和配置 URL 从不会被运行或跟随。

## 优先级

有效的 API 字段会覆盖识别出的面板品牌信息,后者又覆盖通用 HTML 元数据。缺失的 API 字段会保留较低优先级的值。

## 提供者要求

- 页面、端点和 logo 在用户同意之前读取必须是安全的。它们不得注册设备、占用设备名额、将配置标记为已下载,或更改账户状态。
- 不要在响应中放入配置或连接密钥。
- 对账户相关的响应发送 `Cache-Control: private, no-store`。让私有令牌远离日志和公共缓存。

ReClash 无法强制服务端保持只读行为。只有用户的“添加”操作才会开始订阅下载和任何设备标识。预览数据仅用于显示:它不会更改设置、路由、传输身份、客户端预设或已存储的 URL,也不会作为订阅元数据保留。以 [`provider.type`](manifest.md#provider) 形式发送的同一个 `subscription.type` 会标记已保存的配置档。

## 现有面板

没有此 API 时,ReClash 仍会读取:

| 来源 | 数据 |
| --- | --- |
| Remnawave | 内嵌的账户数据和浏览器 `brandingSettings`。临时页面会话仅用于同源的 `/assets/.app-config-v2.json`,从不用于此 API 或 logo。 |
| 3x-ui | 内嵌的页面数据。 |
| Marzban | 标准账户字段。 |
| 任意页面 | 通用 HTML 元数据和明确的支持链接。 |

自定义面板主题通过添加发现链接来选择加入;订阅分发保持不变。
