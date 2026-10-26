# ReClash 订阅服务商支持

ReClash 支持原生服务商契约，定义见 `provider_standard.g.json` 和 `PROVIDER_HEADERS.md`。应用使用的注册表位于 `lib/subscriptions/protocol/registry.dart`。

## 支持的功能

- 通过专用传输获取订阅，限制重定向，并统一管理请求头策略。
- 常见订阅响应头，包括 `Subscription-Userinfo`、`Content-Disposition`、`profile-title`，以及添加订阅时显示的服务商消息 `announce`。
- 通过版本化注册表和编解码器解码原生元数据。
- 设备身份支持全局启用、按配置覆盖，以及按 origin 授权设备详情。
- 客户端兼容预设、自动协商，以及受支持配置格式的导入适配器。
- 只有选中 FlClashX 预设时才会规范化 `flclashx-*` 元数据别名；其他预设仅接受 ReClash 原生服务商元数据名称。

## 路由配置

服务商可以为 `select` 代理组提供路由配置。由用户选择；用户选择前采用服务商默认项。

- 内联：订阅 YAML 顶层使用 `rcx-profiles: {name: profile}`，每个 `select` 组使用 `rcx: {profiles: [...], default: name, chips: [{label, include}]}`。标准 mihomo 会忽略这两个字段。
- 配置包：提供通用 YAML 的服务商可在响应头中返回 `reclash-routing: <https url>`，或在注释行中写 `#reclash-routing: <url>`。配置包格式为 YAML `{rcx: 1, profiles: {name: profile}, groups: {"<group name>": binding}, scenarios: {name: scenario}, scenario: name}`，最大 256 KiB，并按组名绑定。订阅内联声明优先于配置包。
- 配置大小最多 64 KiB。服务商配置 ID 格式为 `provider/<name>`；`extends` 可引用 `builtin/<name>` 或另一个服务商配置。
- 服务商只能缩小组的节点池，不能启用 `direct-split`；该选项由用户掌控。
- 如果配置中的检查、诊断或回显服务会连接到服务商站点（订阅 URL 的可注册域名）或内置配置所用端点之外的主机，则需要用户授权。在授权前，该组使用 `builtin/simple`。
- 配置和场景可在 `title` 后紧跟顶层 `description`（一到两句纯文本，说明用途及适用情形）。配置可选带有 `l10n` 翻译映射，为标题、描述和标签提供多语言版本；应用优先显示用户所用语言，缺少翻译时回退到源文本。
- Schema：`rcx-profile.schema.json`（配置位于根节点，配置包定义在 `$defs.bundle`）。使用 `dart run tool/rcx.dart lint <file>...` 验证；支持配置、场景或配置包。

### 场景

场景是作用于整个连接的自动控制层：设置隧道模式，并为各组指定程序。未指定的组保留自己的绑定。

- 内联：订阅 YAML 顶层的 `rcx-scenarios: {name: scenario}` 和 `rcx-scenario: <name>`（默认场景）。配置包使用 `scenarios: {name: scenario}` 和 `scenario: <name>`。内联声明优先于配置包。
- 场景键：`rcx`、`title`、`mode`（`rule`、`global` 或 `direct`；留空则保留用户模式）、`description`、`groups`、`routes`、`tags`（程序池的命名条件）、`network`、`on`、`l10n`（像配置一样翻译 `title` 和 `description`）。
- `groups` 将目标映射到程序。目标可以是组名、`$main`（最终 MATCH 规则所指向的 `select` 组）、`*`（除 `GLOBAL` 外的其他所有 `select` 组）或 `GLOBAL`。优先级依次为显式组名、`$main`、`*`。
- 程序可以是 `profile`（组配置 ID，替换组自身配置）、`pool: {include, exclude}`（仅缩小节点池），或 `to`（将组固定到某个成员：服务器，或整个嵌套组，如负载均衡组；不执行搜索）。`to` 不能与 `profile` 或 `pool` 同时使用。`prefer`（服务器顺序，即由 `{label, when}` 步骤组成的阶梯）会在程序生效期间替换配置自身顺序，并优先于用户组绑定中的 `prefer`。`{}` 表示使用组自己的配置驱动该组。
- `on.<kind>.mode` 和 `on.<kind>.groups` 可按网络类型覆盖设置；该类型必须在 `network.kinds` 中声明。组条目会整体替换同名基础条目。
- `on.<kind>.groups` 中的程序也可带 `prefer`，并可指定路由组。
- 若场景诊断会连接第三方主机，则需要用户授权，与配置相同。
- 用户可选择场景或关闭自动控制。手动设置的模式会持续生效，直到用户重新选择 Auto。

#### 路由

`routes` 是有序列表，将指定流量发送到专属组。每条包含 `name`、`match`、可选的 `description`，以及程序字段 `profile`（默认 `builtin/simple`）、`pool`、`prefer`，或者指向 `DIRECT` 等固定目标的 `to`。

```yaml
rcx-scenarios:
  daily:
    rcx: 1
    title: Daily
    routes:
      - name: ▶️ YouTube
        match: [GEOSITE,youtube]
        profile: builtin/fastest
        prefer: [{ label: Germany, when: 'country = DE' }]
      - name: 🤖 Claude
        match: [GEOSITE,anthropic, DOMAIN-SUFFIX,claude.ai]
      - name: 🏛️ Gov
        match: [GEOSITE,category-gov-ru]
        to: DIRECT
```

- `match` 是不带目标的 mihomo 规则头部扁平列表（如 `GEOSITE,youtube`、`DOMAIN-SUFFIX,claude.ai`）；IP 类型末尾可带 `no-resolve`。
- 未指定 `to` 的路由会变成名为该路由、启用 `include-all` 的 `select` 组；指定 `to` 的路由不创建组，规则直接发往该目标。路由规则按顺序插入配置规则列表前端，因此先匹配者优先。
- 若路由名称已是配置中的组名，或 `to` 指向不存在的目标，该路由会被跳过，并在场景状态中显示问题。路由仅在 `rule` 模式生效。
- 限制：最多 32 条路由，每条最多 128 个 `match` 项；名称最多 64 字节，必须唯一，且不能是 `$main`、`*`、`GLOBAL`、`DIRECT` 或 `REJECT`。
- `prefer`、`pool` 和 `tags` 的条件可使用 `country`：优先采用已验证的出口国家，否则从服务器名称读取（国旗 emoji、ISO alpha-2 代码或英文国家名）。无法识别时为空，不会让服务器一直处于等待状态。

## 订阅中的应用设置

订阅可设置应用选项。当前配置生效时，这些设置会直接应用，无需确认；用户编辑时，每项旁边会显示“来自服务商”标记。用户更改某项后，该项不再跟随服务商，直到用户对该项或整个配置选择“恢复服务商设置”。

- `reclash-view`：以 `key:value;...` 设置 `proxies.type`、`proxies.sort`、`proxies.layout`、`proxies.icon`、`proxies.card`、`app.navbar`、`app.tabs`、`app.glass`、`app.color`、`app.style`、`app.black`。未知键和值会被忽略。
- `reclash-powerbutton`：以 `key:value;...` 设置简洁仪表盘运行时电源按钮的形状（`shape`：`cookie`、`circle`、`scallop`、`sunny`、`flower`、`clover`、`burst`）和类型（`type`：`solid`、`tonal`、`outline`）。仅服务商可设置；未知键和值会被忽略。
- `reclash-widgets`：逗号分隔的仪表盘卡片。`reclash-background`：图片 URL，可选追加 `,<opacity percent>`。
- `reclash-settings`：`minimize`、`autorun`、`shadowstart`、`autostart`、`autoupdate`、`openlogs`、`closeconnections`。
- `reclash-restrictions`：`noglobal` 移除 Global 模式；`androidsecure` 禁止 Android 打开本地端口；`denywidgets` 禁用仪表盘编辑。
- `announce` / `reclash-announce` 在仪表盘固定卡片中显示订阅说明，支持完整文本选择，可选链接为 `reclash-announceurl`。此卡片可在编辑器中与其他卡片一起排序，但不能移除。
- `reclash-notice` 显示单独的可关闭仪表盘通知，可带 `reclash-noticeurl` 链接；文本或链接变化后会再次显示。关闭通知不会隐藏订阅说明。
- `reclash-subscriptiontype`：`test`、`promo` 或 `dev`。在导入对话框和配置列表中显示订阅徽标。仅供显示；未知值不显示徽标。
- `reclash-expiredays`、`reclash-trafficpercent`：提醒阈值。`reclash-buyplan` 和 `reclash-buytraffic` 接受 `,<n>` 后缀：分别在剩余 `<n>` 天或用量达到 `<n>` 百分比时提供操作入口。
- `reclash-serverinfo`：指定一个代理组，其当前选定节点显示在状态卡片中。

## 隧道外应用（Android）

- 排除项来自 `reclash-excludeapps`、Clash 配置中的 `tun.exclude-package`，以及 `reclash-approuting: domestic`（本地区域应用；指定地区可用 `domestic:<cc>`）。黑名单模式以及访问控制关闭时都会应用；用户自己的列表会在其基础上追加。
- `reclash-includeapps`（或 `tun.include-package`）仅在白名单模式下将应用加入白名单。两种模式不会混用。
- 服务商指定的应用会在访问控制中标记。取消勾选表示用户将该应用重新放入隧道；“将应用恢复为服务商设置”会重置此操作。

## 主机

- `reclash-fallbackhosts`（最多 5 个 `host[:port]`）：主机发生传输、TLS、超时、限流或无效响应故障时，使用相同路径和查询参数尝试备用主机。不会替换已保存的 URL。
- `reclash-newdomain`（一个主机）：更新成功后会像主机一样获取并验证新主机；只有验证成功，配置 URL 才会迁移。新主机失败时会忽略。
- 两者仅用于 `https` 订阅。

## 边界

服务商响应不能触发报告或遥测，也不能修改上述列表之外的设置。路由配置是建议，不是命令。只有在 FlClashX 预设下，`flclashx-*` 名称才会映射到相同字段；`flclashx-newdomain` 映射到 `reclash-fallbackhosts`。

客户端兼容性选择和导入格式适配属于不同层。它们都不意味着获准发送设备身份信息。`reclash-hideurl` 只会在编辑器中隐藏 URL，不会阻止披露或修改。
