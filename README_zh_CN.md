<div align="center">

<img src="assets/images/icon.png" alt="ReClash" width="88">

# ReClash

基于 Clash Meta（mihomo）内核、能替你选择线路的多平台代理客户端。
简单易用，开源无广告。

[English](README.md) · **简体中文**

[![Release](https://img.shields.io/github/v/release/Hoxiee/ReClash?include_prereleases&style=flat-square&label=release)](https://github.com/Hoxiee/ReClash/releases)
[![Downloads](https://img.shields.io/github/downloads/Hoxiee/ReClash/total?style=flat-square&logo=github)](https://github.com/Hoxiee/ReClash/releases)
[![License](https://img.shields.io/github/license/Hoxiee/ReClash?style=flat-square)](LICENSE)
[![Telegram](https://img.shields.io/badge/Telegram-channel-26A5E4?style=flat-square&logo=telegram&logoColor=white)](https://t.me/ReClashApp)

[下载](#下载) · [截图](#截图) · [自动路由](docs/zh-CN/auto-routing/README.md) · [更新日志](CHANGELOG.md) ·
[从源码构建](#从源码构建)

</div>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="snapshots/preview-dark.png">
    <img alt="ReClash 仪表盘在桌面窗口与手机上的界面" src="snapshots/preview.png" width="92%">
  </picture>
</p>

> [!NOTE]
> ReClash 目前处于预览阶段。在 0.1 版本线稳定之前，版本以 `0.1.0-pre.N` 预发布的形式发布。

## 功能

- **自动路由。** 智能代理组按照一份可读的策略选择服务器：哪些服务器可用、优先顺序如何、切换要多积极。
  它会按网络分别衡量延迟、失败次数和出口国家，并说明当前服务器被选中的原因。场景可以按网络设置隧道模式，
  并把指定的网站交给专门的代理组。[阅读指南](docs/zh-CN/auto-routing/README.md)。
- **两种仪表盘。** 简洁版只有一个连接按钮，加上当前位置和订阅剩余用量；详细版由小组件组成：流量、出口 IP
  及其质量、服务检测、连接等。
- **读懂服务商的订阅。** 从 `Subscription-Userinfo` 读取流量与到期时间，支持配置标题、服务商公告，
  以及服务商提供、经你同意才生效的路由配置与设置。Clash、INCY、Happ 链接、普通代理 URI
  和多种配置格式都能直接导入。详见[服务商支持](docs/zh-CN/PROVIDER_FEATURES.md)。
- **服务检测。** 查看 Google、YouTube、ChatGPT、Netflix 等服务能否通过当前线路打开，以及各自的延迟。
- **按需连接。** 在信任的网络中暂停代理，在其他网络中自动恢复；暂停期间端口保持开放。
- **mihomo（Clash Meta）内核**，支持规则分流、代理组、延迟测试、系统代理与 TUN 模式。
- **配置**可通过链接或文件导入，内置编辑器、覆写脚本，以及自定义规则、代理和代理组。
- **实时查看**连接、请求、DNS 查询和日志。
- **Material You 设计，搭配 Apple 风格的交互**：动态取色、浅色与深色主题、连续曲率圆角、可在多个高度间吸附的面板，
  以及从手机到桌面自适应的布局。
- **备份与恢复**，支持 WebDAV 或本地文件。
- **平台细节**：Android 上有快捷设置磁贴、分应用代理、可选的启动器图标和 Android TV 支持；桌面端有托盘菜单和全局快捷键。

## 截图

<table>
  <tr>
    <td width="33%"><picture><source media="(prefers-color-scheme: dark)" srcset="snapshots/screens/mobile-dashboard-dark.webp"><img alt="手机上的简洁仪表盘" src="snapshots/screens/mobile-dashboard-light.webp"></picture></td>
    <td width="33%"><picture><source media="(prefers-color-scheme: dark)" srcset="snapshots/screens/mobile-proxies-dark.webp"><img alt="手机上带延迟的代理组" src="snapshots/screens/mobile-proxies-light.webp"></picture></td>
    <td width="33%"><picture><source media="(prefers-color-scheme: dark)" srcset="snapshots/screens/mobile-profiles-dark.webp"><img alt="手机上显示流量与到期时间的订阅" src="snapshots/screens/mobile-profiles-light.webp"></picture></td>
  </tr>
</table>

<table>
  <tr>
    <td width="50%"><picture><source media="(prefers-color-scheme: dark)" srcset="snapshots/screens/desktop-dashboard-dark.webp"><img alt="桌面端的详细仪表盘" src="snapshots/screens/desktop-dashboard-light.webp"></picture></td>
    <td width="50%"><picture><source media="(prefers-color-scheme: dark)" srcset="snapshots/screens/desktop-proxies-dark.webp"><img alt="桌面端的代理组" src="snapshots/screens/desktop-proxies-light.webp"></picture></td>
  </tr>
  <tr>
    <td width="50%"><picture><source media="(prefers-color-scheme: dark)" srcset="snapshots/screens/desktop-connections-dark.webp"><img alt="桌面端的实时连接" src="snapshots/screens/desktop-connections-light.webp"></picture></td>
    <td width="50%"><picture><source media="(prefers-color-scheme: dark)" srcset="snapshots/screens/desktop-profiles-dark.webp"><img alt="桌面端的配置列表" src="snapshots/screens/desktop-profiles-light.webp"></picture></td>
  </tr>
</table>

截图中的订阅、服务器和地址均为虚构。

## 下载

在 [GitHub Releases](https://github.com/Hoxiee/ReClash/releases) 获取最新版本。每个版本都附带 `SHA256SUMS`
文件，可用来校验下载的文件。

| 平台 | 安装包 | 说明 |
| --- | --- | --- |
| Android 7 及以上 | `arm64-v8a`、`armeabi-v7a`、`x86_64` 的 APK | 大多数手机选 `arm64-v8a`。 |
| Windows 10 及以上 | 安装程序（`-setup.exe`）或便携版 `.zip`，x64 与 ARM64 | 骁龙等 ARM 笔记本请选 ARM64。 |
| macOS 12 及以上 | Apple 芯片（`arm64`）与 Intel（`amd64`）的 DMG | |
| Linux | x64 与 ARM64 的 `.deb`、`.rpm`、Arch `.pkg.tar.xz`；x64 的 AppImage | 见下方托盘说明。 |

<p>
  <a href="https://github.com/Hoxiee/ReClash/releases"><img alt="Get it on GitHub" src="snapshots/get-it-on-github.svg" height="56"></a>
</p>

ReClash 使用独立的包名和数据目录，可以与 FlClash 并存安装，互不影响。

**Linux 托盘图标**

`.deb` 安装包会自动安装所需依赖。使用 AppImage 或 `.rpm` 时，需要先安装 AyatanaAppIndicator 库，托盘图标才能显示：

```bash
sudo apt-get install libayatana-appindicator3-1   # Debian 与 Ubuntu
sudo dnf install libayatana-appindicator-gtk3     # Fedora
```

**无人值守的桌面环境**

ReClash 要在免责声明被接受后才会启动核心。在容器等无人点击的环境里，可在应用的环境变量中设置
`FLCLASH_ACCEPT_DISCLAIMER=1`，首次启动时即视为接受。

## 使用

**通过链接导入配置。** 打开下面格式的链接，即可导入订阅。`clash://` 和 `clashmeta://` 开头的链接同样可用，
INCY、Happ 的导入链接以及 `vless://`、`hysteria2://` 等普通代理 URI 也都支持。

```text
reclash://install-config?url=<经过 URL 编码的订阅链接>
```

**用链接控制应用。** `reclash://connect`、`reclash://disconnect` 和 `reclash://toggle` 用于开关代理；
其余链接（包括分享自动路由配置的链接）可在「工具 › URL 方案」中查看。

**Android 自动化。** Tasker、MacroDroid 等应用可以用下面的 Action 启动 Activity，从而启动、停止或切换代理：

```text
com.reclash.action.START
com.reclash.action.STOP
com.reclash.action.TOGGLE
```

在电脑上也可以通过 adb 触发：

```bash
adb shell am start -a com.reclash.action.TOGGLE
```

## 文档

- [自动路由](docs/zh-CN/auto-routing/README.md)：基本概念、配置、场景、条件与实用示例。
- [服务商支持](docs/zh-CN/PROVIDER_FEATURES.md)与[服务商标准](docs/zh-CN/PROVIDER_HEADERS.md)：订阅服务商可以向应用传达的信息。

## 从源码构建

需要 [Flutter](https://docs.flutter.dev/get-started/install) 3.47（正式版构建使用 3.47.6）、[Go](https://go.dev/dl/) 1.27，
以及通过 rustup 安装的 [Rust](https://rustup.rs/)。桌面端需要在对应系统上构建，Android 在任意系统上都能构建。

```bash
git clone --recursive https://github.com/Hoxiee/ReClash.git
cd ReClash
flutter pub get
dart setup.dart android   # 或 windows、macos、linux
```

安装包输出到 `dist/`。Go 内核和 Rust 库会在 Flutter 构建过程中一并编译。

| 平台 | 额外依赖 |
| --- | --- |
| Android | 带 NDK 的 Android SDK。加上 `--arch arm64` 可以只构建单个 ABI。 |
| Windows | 编译内核用的 GCC（MinGW-w64），以及打包安装程序用的 [Inno Setup](https://jrsoftware.org/isinfo.php) 6。 |
| macOS | Xcode 与 Node.js。脚本会通过 npm 安装 `appdmg`。 |
| Linux | Debian 或 Ubuntu。脚本会用 apt 安装构建所需的软件包，并下载 `appimagetool`。 |

其余选项可以运行 `dart setup.dart --help` 查看，例如用 `--targets` 只构建部分安装包格式。
本文中的截图由 `tool/snapshots/render.sh` 根据模拟数据生成。

## 支持

给仓库点一个 Star 是支持项目最简单的方式。更新通知请关注 [Telegram 频道](https://t.me/ReClashApp)，
Bug 与功能建议请提交到 [GitHub Issues](https://github.com/Hoxiee/ReClash/issues)。

## 致谢

ReClash 是 chen08209 的 [FlClash](https://github.com/chen08209/FlClash) 的分支，并使用
[mihomo](https://github.com/MetaCubeX/mihomo) 内核。感谢这两个项目及其贡献者。

## 许可证

ReClash 以 [GPL-3.0 协议](LICENSE)发布。
