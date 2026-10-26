# 截图清单

编辑器文档所用图像放在此目录，文件名为 `images/<id>.png`。页面中的占位标记使用 `Screenshot <id>`；下表定义每张图应呈现的内容。

## 演示设置

所有截图使用相同设置。

- 订阅“Demo”，服务器包括：🇳🇴 Oslo 1、🇳🇴 Oslo 2、🇳🇴 Oslo 3、🇸🇪 Stockholm 1、🇸🇪 Stockholm 2、🇷🇺 Moscow ⚡ 1、🇷🇺 Moscow ⚡ 2、*Premium NL、🇩🇪 Frankfurt。
- 用户场景“My split”正在运行，包含路由：
  - 主流量（其他流量）：Country Norway；
  - ▶️ YouTube：步骤“⚡ RU”，然后任意可用服务器；
  - 🤖 Claude：Country Sweden；
  - ✨ Gemini：步骤“Name contains `*`”；
  - 🏠 Local：Direct，Site category `category-ru` 和 Domain and subdomains `yandex.ru`。
- 连接为 rule 模式，浅色主题；除非另有说明，分辨率为 412×915。
- 库中包含所有内置组配置和一个自定义配置。

## 截图

| id | 文件 | 页面 | 必须显示的内容 | 打开方式 |
| --- | --- | --- | --- | --- |
| editor-map | images/editor-map.png | editor/README.md | 并排展示三个入口：中心（Overview 选项卡）、从 Proxies 打开的组面板和路由编辑器；带箭头说明切换路径；浅色主题，412×915。 | 将 hub-overview、group-sheet-auto、route-editor 三屏合成。 |
| group-sheet-auto | images/group-sheet-auto.png | editor/groups.md | 主组处于 Auto，显示状态卡、Control、Change to 标签和 Behaviour；浅色主题，412×915。 | Proxies → 主组 → 自动路由面板。 |
| group-intro | images/group-intro.png | editor/groups.md | 未启用自动路由的组面板，显示 Turn on auto routing 按钮；浅色主题，412×915。 | 打开尚未成为智能组的组面板。 |
| group-sheet-pinned | images/group-sheet-pinned.png | editor/groups.md | Control 设为 Pinned，状态卡显示“保持固定服务器”；浅色主题，412×915。 | 组面板 → Control → Pinned。 |
| group-change-to | images/group-change-to.png | editor/groups.md | Change to 显示 Any、🇳🇴、🇸🇪、🇷🇺 和一个自定义模式；浅色主题，412×915。 | 组面板 → Change to。 |
| group-behaviour | images/group-behaviour.png | editor/groups.md | Behaviour 显示 Fastest 配置、Server order 摘要和设置行；浅色主题，412×915。 | 组面板 → Behaviour。 |
| group-settings | images/group-settings.png | editor/groups.md | 设置页显示 Name pattern“4 of 5 match”、Switching Balanced、Checks Economical 和直连网站开关；浅色主题，412×915。 | 组面板 → 设置行。 |
| group-why | images/group-why.png | editor/groups.md | 展开的 Why this server 有五行，其中包括“Skipped after Change server”；浅色主题，412×915。 | 组面板 → Why this server。 |
| group-history | images/group-history.png | editor/groups.md | 展开的 History 显示故障切换和固定事件；浅色主题，412×915。 | 组面板 → History。 |
| group-consent | images/group-consent.png | editor/groups.md | Permission needed 区域显示主机和 Allow 行；浅色主题，412×915。 | 打开使用需授权配置的组面板。 |
| group-route | images/group-route.png | editor/groups.md | “▶️ YouTube”组面板显示 Made by a route；浅色主题，412×915。 | Proxies → YouTube 路由组 → 自动路由面板。 |
| hub-menu | images/hub-menu.png | editor/hub.md | 路由中心顶部菜单打开，包含 New scenario、New profile、Import；浅色主题，412×915。 | Advanced configuration → Auto routing → 三点菜单。 |
| hub-overview | images/hub-overview.png | editor/hub.md | Overview 中自动路由开启，My split 运行，显示状态、Routes、Smart groups 和能耗页脚；浅色主题，412×915。 | Auto routing → Overview，运行 My split。 |
| hub-no-subscription | images/hub-no-subscription.png | editor/hub.md | Overview 处于 No subscription 状态；浅色主题，412×915。 | 移除当前配置并打开 Auto routing。 |
| hub-overview-off | images/hub-overview-off.png | editor/hub.md | Overview 主开关关闭并显示提示；浅色主题，412×915。 | Auto routing → Overview，关闭开关。 |
| scenario-chooser | images/scenario-chooser.png | editor/hub.md | 场景面板分为 Mine、From provider、Built-in，各自显示标题和说明，选中 My split；浅色主题，412×915。 | Overview → Change。 |
| hub-groups-energy | images/hub-groups-energy.png | editor/hub.md | Smart groups 多行项目及“Checks today”页脚；浅色主题，412×915。 | 检查运行后，在 Overview 向下滚动至 Smart groups。 |
| hub-routes | images/hub-routes.png | editor/hub.md | My split 的 Routes 选项卡：四条路由、Add route、Everything else、Other groups、Networks；浅色主题，412×915。 | Auto routing → Routes。 |
| hub-routes-off | images/hub-routes-off.png | editor/hub.md | Routes 显示 No scenario is running 和 Start a scenario；浅色主题，412×915。 | 关闭自动路由后打开 Routes。 |
| hub-routes-rule-only | images/hub-routes-rule-only.png | editor/hub.md | 连接为 global 模式时，Routes 页脚显示 rule 模式警告；浅色主题，412×915。 | 将连接设为 global，再打开 Routes。 |
| hub-routes-reorder | images/hub-routes-reorder.png | editor/hub.md | Routes 列表处于排序模式，显示拖动手柄；浅色主题，412×915。 | Routes → 标题栏排序按钮。 |
| hub-everything-else | images/hub-everything-else.png | editor/hub.md | Everything else 行和只含“Country Norway”一步的编辑器；浅色主题，412×915。 | Routes → Everything else。 |
| hub-other-groups | images/hub-other-groups.png | editor/hub.md | Other groups 显示一条 Every group 规则和 Add group 弹出菜单；浅色主题，412×915。 | Routes → Other groups → Add group。 |
| hub-networks | images/hub-networks.png | editor/hub.md | 展开的 Networks 区域显示 Connection mode、一个网络类型、Tags 和 Advanced；浅色主题，412×915。 | Routes → 展开 Mode and networks。 |
| copy-dialog | images/copy-dialog.png | editor/hub.md | “Make your own copy?”对话框及 Make a copy 按钮；浅色主题，412×915。 | 运行内置场景后添加路由。 |
| hub-library | images/hub-library.png | editor/hub.md | Library 选项卡、Scenarios 筛选、带 Built-in、From provider、Mine 标签的卡片，选中 My split；浅色主题，412×915。 | Auto routing → Library。 |
| library-menu | images/library-menu.png | editor/hub.md | Mine 卡片上下文菜单展开，含 Edit、Duplicate and edit、Export、Delete；浅色主题，412×915。 | Library → 长按 Mine 卡片。 |
| scenario-editor | images/scenario-editor.png | editor/hub.md | My split 场景编辑器显示标题、说明、路由和 YAML 菜单；浅色主题，412×915。 | Library → My split。 |
| route-delete-menu | images/route-delete-menu.png | editor/hub.md | 路由上下文菜单含 Edit 和 Delete；浅色主题，412×915。 | Routes → 长按路由。 |
| walk-1-empty | images/walk-1-empty.png | editor/hub.md | Routes 选项卡显示 No scenario is running；浅色主题，412×915。 | 打开未运行场景的 Routes。 |
| walk-2-youtube-step | images/walk-2-youtube-step.png | editor/hub.md | 步骤编辑器 Name contains“⚡ RU”，页脚显示“N servers fit now”；浅色主题，412×915。 | Routes → Add route → YouTube → Next → Add a step。 |
| walk-3-done | images/walk-3-done.png | editor/hub.md | Routes 显示四条路由，Everything else 显示 Norway；浅色主题，412×915。 | 按 hub.md 完成设置后查看 Routes。 |
| route-traffic-picker | images/route-traffic-picker.png | editor/routes.md | New route 页面选中 YouTube 和 Gemini 服务标签，下方有 Custom 区域；浅色主题，412×915。 | Routes → Add route。 |
| route-entry-form | images/route-entry-form.png | editor/routes.md | 条目表单 Type“Site category”，无效值显示“Invalid value”；浅色主题，412×915。 | Add route → Add entry。 |
| route-editor | images/route-editor.png | editor/routes.md | ▶️ YouTube 编辑器：名称、流量摘要“YouTube · 2 more”、Send through = Auto、服务器顺序、行为；浅色主题，412×915。 | Routes → 点按 YouTube。 |
| route-editor-fixed | images/route-editor-fixed.png | editor/routes.md | 路由编辑器选择 One server，Server 行选中“🇳🇴 Oslo 1”；浅色主题，412×915。 | Route editor → Send through → One server。 |
| route-behaviour | images/route-behaviour.png | editor/routes.md | Behaviour 页面含 Built-in、From provider、User 和说明页脚；浅色主题，412×915。 | Route editor → Behaviour。 |
| route-pool | images/route-pool.png | editor/routes.md | 组规则的 Leave out 行显示“name contains …”，下方为 Use 行；浅色主题，412×915。 | Route editor → Leave out。 |
| route-editor-ladder | images/route-editor-ladder.png | editor/routes.md | Server order 含“⚡ RU”和“Any working server”两步、连接线、“if none of them works”提示及 Add a step 按钮；浅色主题，412×915。 | Route editor 向下滚动至 Server order。 |
| ladder-step-editor | images/ladder-step-editor.png | editor/routes.md | 步骤编辑器显示 Name contains“⚡ RU”、Country、Add condition 和“2 servers fit now”；浅色主题，412×915。 | Server order → 点按步骤或 Add a step。 |
| country-picker | images/country-picker.png | editor/routes.md | Choose countries 面板显示 On your servers（Norway 3 servers verified、Sweden 2、Russia 2）和 All countries；浅色主题，412×915。 | Step editor → Country。 |
| condition-builder | images/condition-builder.png | editor/routes.md | 构建器 Match = All conditions，包含 Country is one of Norway, Sweden 和 Latency is under 300；浅色主题，412×915。 | Route editor → Leave out，或 step editor → Advanced condition。 |
| condition-text | images/condition-text.png | editor/routes.md | As text 区域显示解析错误横幅；浅色主题，412×915。 | Condition builder → As text，并输入故意写错的语法。 |
| export-sheet | images/export-sheet.png | editor/sharing.md | 导出面板显示三项操作；浅色主题，412×915。 | Library → 长按卡片 → Export。 |
| import-page | images/import-page.png | editor/sharing.md | 单个场景的“Import routing profile”页面，显示标题、来源和说明；浅色主题，412×915。 | 中心菜单 → Import → 粘贴场景链接。 |
| import-bundle | images/import-bundle.png | editor/sharing.md | 配置包导入页列出一个场景和两个配置；浅色主题，412×915。 | 导入配置包链接。 |
| import-problems | images/import-problems.png | editor/sharing.md | 导入页面显示错误横幅，保存按钮禁用；浅色主题，412×915。 | 导入损坏的文件。 |
| studio-form | images/studio-form.png | editor/studio.md | 工作台表单模式显示 General、Servers、Server order、Tags、Behaviour；浅色主题，412×915。 | Library → Group profiles → 自定义配置。 |
| studio-yaml | images/studio-yaml.png | editor/studio.md | 配置的 YAML 文本编辑器；浅色主题，412×915。 | Studio → 菜单 → YAML。 |
| studio-warnings | images/studio-warnings.png | editor/studio.md | Warnings 显示重复前置条件的步骤和未使用标签；浅色主题，412×915。 | 工作台中设置被覆盖的步骤和未使用标签。 |
| studio-check | images/studio-check.png | editor/studio.md | 针对“Proxy”组的 Check 显示“Would pick 🇳🇴 Oslo 1 instead of 🇸🇪 Stockholm 1”；浅色主题，412×915。 | Studio → Check → Against group。 |
| studio-merge | images/studio-merge.png | editor/studio.md | “The original profile changed”区域显示两项；浅色主题，412×915。 | 打开原配置已更新的副本。 |
| studio-restore | images/studio-restore.png | editor/studio.md | Earlier versions 面板显示时间戳；浅色主题，412×915。 | Studio → 菜单 → Earlier versions。 |
| cookbook-routes-hub | images/cookbook-routes-hub.png | cookbook.md | Routes 页面含 YouTube、Claude、Gemini、Local，各自显示当前服务器和步骤；浅色主题，412×915。 | Advanced configuration → Auto routing → Routes，运行分流场景。 |
| cookbook-ladder-ranking | images/cookbook-ladder-ranking.png | cookbook.md | 组说明中的排名按 Starred、Finland、Anything 分步显示，并标出当前服务器；浅色主题，412×915。 | Proxies → 组 → 自动路由按钮 → Why this server。 |
| cookbook-pin-control | images/cookbook-pin-control.png | cookbook.md | 组面板包含 Auto、Pinned、Manual，选择 Pinned 且固定服务器高亮；浅色主题，412×915。 | Proxies → 组 → 自动路由按钮，手动选择服务器后。 |
| cookbook-bundle-import | images/cookbook-bundle-import.png | cookbook.md | 导入审核列出一个场景和一个配置及最终名称；浅色主题，412×915。 | 中心菜单 → Import → Streaming 配置包。 |
