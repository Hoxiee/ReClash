# ReClash 服务商预览 API

版本 1 用于在导入订阅之前展示由服务商提供的信息。它与配置下载以及应用到已保存配置的服务商请求头相互独立。服务商实现此只读端点，ReClash 负责发现并读取它。

## 发现方式

返回一个普通的浏览器订阅页面，其中恰好包含一个链接：

```html
<link rel="reclash-preview" href="/reclash/preview/account-scoped-token">
```

相对 URL 以页面最终 URL 为基准解析。端点必须与该页面具有相同的 origin（协议、主机名和端口），不能就是该页面本身，也不能包含片段。ReClash 不会探测约定路径，也不会运行 JavaScript 来发现端点。如需个性化数据，可在 URL 中使用不透明的账户级令牌；不要要求提供 HWID 或通过浏览器登录。

## 请求与响应

ReClash 会发送 GET 请求，包含 `Accept: application/json` 和浏览器预览专用的 User-Agent。API 请求不会附带 HWID、设备信息、订阅客户端预设、cookies、授权头或 Referer。重定向使用现有的受限传输机制；只接受最终响应与页面同源的 JSON 数据。

返回 `Content-Type: application/json`，并提供不超过 64 KiB 的 UTF-8 JSON：

```json
{
  "version": 1,
  "provider": {
    "name": "Example VPN",
    "description": "Contact support if you need help installing your subscription.",
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

除整数 `version` 外，所有字段均为可选。未知字段会被忽略。名称最多 256 个字符，描述最多 4096 个字符。文本按纯文本显示，不会作为 HTML 或可执行 Markdown 处理。无效字段不会覆盖页面中已有的有效元数据。遇到不支持的版本、格式错误的 JSON、超大响应或请求失败时，会回退到面板页面，不会阻止导入。

- `provider.name`：确认对话框标题中的服务名称。
- `provider.description`：确认对话框正文中的服务商说明。
- `provider.logoUrl`：绝对 HTTP(S) 图片 URL，或相对于响应 URL 的地址。HTTPS 页面不能降级到 HTTP。支持的响应类型：PNG、JPEG、WebP、GIF、SVG 和 ICO（取决于解码器支持）。超过 512 KiB 的图片不会显示。图片加载失败时保留文字徽标；组件不会获取 SVG 引用的外部资源。
- `provider.supportUrl`：HTTP(S) 地址或经过验证的 Telegram 目标地址。相对链接以 API URL 为基准解析。顶部栏会显示支持入口，并使用现有的外部链接/Telegram 确认流程；不会自动打开链接。
- `account.name`：账户显示名称，与服务商名称和可编辑的本地配置名称分别显示。
- `subscription.type`：`test`、`promo` 或 `dev`，最多 32 个字符。确认对话框会在名称下方显示徽标；未知值不显示。若 `reclash-subscriptiontype` 请求头包含相同值，已保存的配置也会显示此徽标。

优先级为：有效 API 字段高于已识别的面板品牌信息，后者高于通用 HTML 元数据。API 字段缺失时保留较低优先级的值。获取图片时不会发送会话 cookies、授权信息、Referer 或设备身份，即使图片与页面同源也一样。不会执行或跟随 JSON 中的脚本、样式、应用列表、遥测端点或配置 URL。

## 服务商要求

页面、预览端点和徽标在用户同意之前必须可以安全读取。它们不得注册设备、占用设备名额、将订阅配置标记为已下载，也不得更改账户或订阅状态。不要在此响应中放入配置密钥或连接密钥。账户专属响应应使用 `Cache-Control: private, no-store`；不得将私有令牌写入日志或放入公共缓存。

ReClash 无法强制服务端保持只读。只有用户点击“添加”后，才会开始常规订阅下载以及任何已配置的设备识别。预览数据仅用于展示：不能更改应用设置、路由、传输身份、所选客户端或已保存的订阅 URL，也不会作为权威订阅元数据持久化。

## 现有面板

即使没有此 API，ReClash 仍可识别 Remnawave 内嵌账户数据和浏览器 `brandingSettings`、3x-ui 内嵌页面数据、Marzban 标准账户字段，以及通用 HTML 元数据/显式支持链接。对于 Remnawave，临时页面会话仅用于读取同源的浏览器品牌资源 `/assets/.app-config-v2.json`，不会用于此 API 或徽标。自定义主题可以添加发现链接来启用此契约，无需修改订阅交付方式。
