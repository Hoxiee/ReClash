<p align="center">
  <img src="assets/images/icon.png" width="104" alt="ReClash 图标">
</p>

<h1 align="center">ReClash</h1>

<p align="center">在一个应用中管理代理配置、订阅和连接。</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README_RU.md">Русский</a>
</p>

<p align="center">
  <a href="https://github.com/Hoxiee/ReClash/actions/workflows/build.yaml"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/Hoxiee/ReClash/build.yaml?branch=main&style=flat-square&label=CI"></a>
  <a href="https://github.com/Hoxiee/ReClash/releases"><img alt="最新版本" src="https://img.shields.io/github/v/release/Hoxiee/ReClash?include_prereleases&style=flat-square"></a>
  <a href="LICENSE"><img alt="GPL-3.0 许可证" src="https://img.shields.io/github/license/Hoxiee/ReClash?style=flat-square"></a>
  <a href="https://t.me/ReClashApp"><img alt="Telegram 频道" src="https://img.shields.io/badge/Telegram-ReClashApp-2AABEE?style=flat-square&logo=telegram&logoColor=white"></a>
</p>

ReClash 是面向 Android、Windows、macOS 和 Linux 的跨平台应用。添加和更新订阅、快速切换代理、监控连接与流量，并通过系统代理或 TUN/VPN 连接。设置、备份和诊断工具集中在同一个界面中。

项目基于 [FlClash](https://github.com/chen08209/FlClash)。

## 功能

- TUN/VPN 和系统代理。
- 配置导入和订阅自动更新。
- 配置覆写、自定义 HTTP 请求头和脚本。
- 代理、连接和路由规则管理。
- 流量监控、日志和延迟测试。
- 本地备份和可选 WebDAV 同步。
- 桌面端托盘、开机启动、快捷键和深层链接。
- Android 快捷设置、小组件、Always-on VPN、电视导航和自动化广播。
- 可选 ByeDPI 模式。

> ReClash 不提供代理或订阅。请仅导入可信来源的配置。

## 截图

<table>
  <tr>
    <td><img src="snapshots/desktop.gif" alt="ReClash 桌面端"></td>
    <td><img src="snapshots/mobile.gif" alt="ReClash 移动端"></td>
  </tr>
  <tr>
    <td align="center">桌面端</td>
    <td align="center">移动端</td>
  </tr>
</table>

## 安装

请从 [Releases](https://github.com/Hoxiee/ReClash/releases) 下载对应平台的软件包：

| 平台 | 软件包 |
| --- | --- |
| Android | APK：`arm64-v8a`、`armeabi-v7a`、`x86_64` |
| Windows | 安装程序或便携 ZIP：x64、ARM64 |
| macOS | DMG：Apple 芯片、Intel |
| Linux | AppImage：x64；DEB、RPM：x64、ARM64 |

每个版本都附带 `SHA256SUMS`。在 Linux 或 macOS 上，将它与下载的软件包放在同一目录并运行：

```bash
sha256sum -c SHA256SUMS --ignore-missing
```

在 Windows 上，使用 `Get-FileHash <文件> -Algorithm SHA256` 计算哈希，并与 `SHA256SUMS` 中对应的记录比较。预发布版本可能不稳定，也不会作为单独的维护分支获得支持。

## 开始使用

1. 添加订阅 URL 或导入本地配置。若服务器根据 `User-Agent` 返回不同格式，自动兼容模式可以依次尝试适用格式。
2. 选择代理或策略组，然后通过 TUN/VPN 连接，或者启用系统代理。系统代理仅影响遵循操作系统代理设置的应用；TUN/VPN 在网络层处理流量。
3. 如果本地 DNS、路由规则、HTTP 请求头或脚本需要与服务商配置不同，请使用配置覆写。
4. 排查线路问题时可查看**连接**、**流量**、**日志**和延迟测试。进行较大修改前建议创建本地备份；WebDAV 同步是可选功能。

ReClash 不出售代理服务、不提供订阅，也不推荐服务商。订阅 URL 通常包含访问凭据，请勿将其发布到日志或 issue 中。

## 系统集成

桌面版提供系统托盘、开机启动、全局快捷键、系统代理控制和 `reclash://` URL scheme。Android 版提供 Quick Settings 磁贴、桌面小组件、Always-on VPN、电视导航以及启动和连接快捷方式。

本地启动器和自动化工具可以使用以下 URL scheme：

```text
reclash://connect
reclash://disconnect
reclash://toggle
reclash://open
reclash://close
reclash://add/<编码后的订阅 URL>
reclash://import/<Base64 配置>
reclash://install-config?url=<编码后的 URL>&name=<编码后的名称>
```

导入和添加链接会携带敏感配置。请只为可信的本地自动化创建这些链接，并在打开外部来源的链接前检查其内容。

## 从源码构建

发布版本使用 Flutter 3.47.1 和 Go 1.26.4。Android 还需要 JDK 17 与 NDK r28c；原生 helper 组件需要稳定版 Rust。请克隆子模块并先运行通用检查：

```bash
git clone --recurse-submodules https://github.com/Hoxiee/ReClash.git
cd ReClash
flutter pub get
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

请在目标操作系统上打包：

```bash
dart setup.dart android
dart setup.dart windows
dart setup.dart macos
dart setup.dart linux
```

构建工具会将软件包写入 `dist/`。Linux 打包可能会请求管理员权限以安装原生依赖；Windows 打包需要 GCC 和 Inno Setup；macOS 打包需要 Node.js，以便使用 `appdmg`。详细命令、代码生成规则和原生检查见 [CONTRIBUTING.md](CONTRIBUTING.md) 与 [`.agents/commands.md`](.agents/commands.md)。

## 订阅服务商集成

服务商可以通过订阅 HTTP 响应头传递流量与到期时间、更新间隔、支持链接、品牌样式、dashboard 布局和域名迁移信息。完整协议、兼容别名、示例、可用小组件、HWID 行为及安全说明见 [Subscription response headers](PROVIDER_HEADERS.md)。

`reclash-*` 命名空间优先于兼容响应头。这些值用于补充订阅正文，但不会夺走用户控制权：用户保存的设置仍由用户管理，应用初始设置只会在添加配置时应用一次。

## 支持与贡献

提交问题前请阅读 [SUPPORT.md](SUPPORT.md)，尤其是安全分享日志与配置的说明。安全漏洞应按照 [SECURITY.md](SECURITY.md) 私下报告。贡献规则见 [CONTRIBUTING.md](CONTRIBUTING.md)，社区行为规范见 [Code of Conduct](CODE_OF_CONDUCT.md)。

项目动态发布在 [ReClash Telegram 频道](https://t.me/ReClashApp)。该频道用于发布新闻，不是服务商的私人客服渠道。

## 致谢

ReClash 的开发离不开以下项目及其维护者：

- [FlClash](https://github.com/chen08209/FlClash)，由 [chen08209](https://github.com/chen08209) 维护，是 ReClash 的项目基础。
- [FlClashX](https://github.com/pluralplay/FlClashX)，由 [pluralplay](https://github.com/pluralplay) 维护，其面向服务商的功能和设计思路为 ReClash 的部分实现提供了参考。
- [mihomo](https://github.com/MetaCubeX/mihomo)，由 [MetaCubeX](https://github.com/MetaCubeX) 维护，是本应用使用的代理核心。

ReClash 由独立维护者维护。文中提及其他项目仅用于说明技术来源、兼容性和依赖关系，并不表示这些项目或其维护者认可 ReClash。

完整的依赖列表及其许可证可在应用和仓库中查看。

## 许可证

ReClash 依据 [GNU General Public License v3.0](LICENSE) 发布。
