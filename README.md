<p align="center">
  <img src="assets/images/icon.png" width="104" alt="ReClash icon">
</p>

<h1 align="center">ReClash</h1>

<p align="center">Manage proxy profiles, subscriptions, and connections in one application.</p>

<p align="center">
  <a href="README_RU.md">Русский</a> ·
  <a href="README_zh_CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/Hoxiee/ReClash/actions/workflows/build.yaml"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/Hoxiee/ReClash/build.yaml?branch=main&style=flat-square&label=CI"></a>
  <a href="https://github.com/Hoxiee/ReClash/releases"><img alt="Latest release" src="https://img.shields.io/github/v/release/Hoxiee/ReClash?include_prereleases&style=flat-square"></a>
  <a href="LICENSE"><img alt="GPL-3.0 license" src="https://img.shields.io/github/license/Hoxiee/ReClash?style=flat-square"></a>
  <a href="https://t.me/ReClashNews"><img alt="Telegram news" src="https://img.shields.io/badge/Telegram-ReClashNews-2AABEE?style=flat-square&logo=telegram&logoColor=white"></a>
</p>

ReClash is a cross-platform application for Android, Windows, macOS, and Linux. Add and update subscriptions, switch proxies, monitor connections and traffic, and connect through system proxy or TUN/VPN. Settings, backups, and diagnostic tools are available in one interface.

The project is based on [FlClash](https://github.com/chen08209/FlClash).

## Features

- TUN/VPN and system proxy.
- Profile import and automatic subscription updates.
- Profile overrides, custom HTTP headers, and scripts.
- Proxy, connection, and routing-rule management.
- Traffic monitoring, logs, and delay tests.
- Local backups and optional WebDAV synchronization.
- System tray, startup, hotkeys, and deep links on desktop.
- Quick Settings, widgets, Always-on VPN, TV navigation, and broadcast actions on Android.
- Optional ByeDPI mode.

> ReClash does not provide proxy access or subscriptions. Import profiles only from sources you trust.

## Screenshots

<table>
  <tr>
    <td><img src="snapshots/desktop.gif" alt="ReClash on desktop"></td>
    <td><img src="snapshots/mobile.gif" alt="ReClash on mobile"></td>
  </tr>
  <tr>
    <td align="center">Desktop</td>
    <td align="center">Mobile</td>
  </tr>
</table>

## Install

Download the package for your platform from [Releases](https://github.com/Hoxiee/ReClash/releases):

| Platform | Packages |
| --- | --- |
| Android | APK: `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| Windows | installer or portable ZIP: x64, ARM64 |
| macOS | DMG: Apple silicon, Intel |
| Linux | AppImage: x64; DEB and RPM: x64, ARM64 |

Each release includes `SHA256SUMS`. On Linux or macOS, place it beside the downloaded package and run:

```bash
sha256sum -c SHA256SUMS --ignore-missing
```

On Windows, calculate the package hash with `Get-FileHash <file> -Algorithm SHA256` and compare it with the matching line in `SHA256SUMS`. Pre-release builds may be unstable and are not maintained as a separate support line.

## Getting started

1. Add a subscription URL or import a local profile. Automatic compatibility mode can try alternative subscription formats when a server varies its response by `User-Agent`.
2. Select a proxy or group, then connect through TUN/VPN or enable the system proxy. The system proxy covers applications that follow operating-system proxy settings; TUN/VPN handles traffic at the network layer.
3. Use profile overrides when local DNS, routing rules, request headers, or scripts must differ from the provider configuration.
4. Check **Connections**, **Traffic**, **Logs**, and delay tests when diagnosing a route. Back up the local configuration before larger changes; WebDAV synchronization is optional.

ReClash does not sell proxy access, provide subscriptions, or recommend providers. Subscription URLs commonly contain credentials, so do not publish them in logs or issue reports.

## Platform integration

Desktop builds provide a system tray, launch-at-startup support, global hotkeys, system-proxy control, and the `reclash://` URL scheme. Android provides a Quick Settings tile, home-screen widgets, Always-on VPN support, TV navigation, and launch/connect shortcuts.

The URL scheme can be used by local launchers and automation tools:

```text
reclash://connect
reclash://disconnect
reclash://toggle
reclash://open
reclash://close
reclash://add/<encoded subscription URL>
reclash://import/<base64 configuration>
reclash://install-config?url=<encoded URL>&name=<encoded name>
```

Import and add links carry sensitive configuration data. Create them only for trusted local automation and inspect links received from other sources before opening them.

## Build from source

Release builds use Flutter 3.47.1 and Go 1.26.4. Android also requires JDK 17 and NDK r28c. Native helper components require stable Rust. Clone the submodules and run the common validation first:

```bash
git clone --recurse-submodules https://github.com/Hoxiee/ReClash.git
cd ReClash
flutter pub get
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

Package on the target operating system:

```bash
dart setup.dart android
dart setup.dart windows
dart setup.dart macos
dart setup.dart linux
```

The setup tool writes packages to `dist/`. Linux packaging may request administrator access to install native build dependencies; Windows packaging requires GCC and Inno Setup; macOS packaging requires Node.js for `appdmg`. Detailed commands, code-generation rules, and native checks are in [CONTRIBUTING.md](CONTRIBUTING.md) and [`.agents/commands.md`](.agents/commands.md).

## Subscription providers

Providers can attach usage, expiration, update policy, support links, branding, dashboard layout, and migration metadata to subscription HTTP responses. The complete wire contract, supported aliases, examples, widget names, HWID behavior, and security notes are documented in [Subscription response headers](PROVIDER_HEADERS.md).

The `reclash-*` namespace takes priority over compatibility headers. These values are suggestions around the subscription body: user-owned settings stay under user control, and initial application defaults are applied only when a profile is added.

## Localization

ReClash speaks eight languages so people from different countries can use it. Uzbek, Kazakh, Turkmen, and Korean were added; Russian was re-proofread.

| Stage | What was done |
|---|---|
| Dictionary | Terms like "proxy", "subscription", "traffic" collected before translation from real localizations native speakers use: Android settings, Firefox, Windows, Wikipedia in that language. Uzbek — 40 terms from 35 sources, Kazakh — 43 from 40, Turkmen — 43 from 43, Korean — 38 from 38 |
| Honesty | 33 spots where sources diverged are marked as unconfirmed, not masked |
| Review | Chunked translation, each chunk blind-checked by a second pass: `{name}` placeholders, plurals, spelling, consistent voice. Each chunk had 5–20 defects |
| Natural phrasing | Edits against live corpora plus correct native orthography: `oʻ/gʻ`, Kazakh Cyrillic `ә ғ қ ң ө ұ ү һ і`, Turkmen Latin `ý ň ä ş ç ž` |

Localizations are alive. If a phrase sounds off to a native ear, please [open a translation issue](https://github.com/Hoxiee/ReClash/issues/new) and it will be fixed.

## Support and contributing

Read [SUPPORT.md](SUPPORT.md) before reporting a problem, especially before sharing logs or profiles. Security issues must be reported privately according to [SECURITY.md](SECURITY.md). Contributions are welcome under [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md).

Project announcements are published in the [ReClash Telegram channel](https://t.me/ReClashNews). It is a news channel, not a private provider-support service.

## Acknowledgements

ReClash exists because of the work of these projects and maintainers:

- [FlClash](https://github.com/chen08209/FlClash) by [chen08209](https://github.com/chen08209), the application ReClash is based on.
- [FlClashX](https://github.com/pluralplay/FlClashX) by [pluralplay](https://github.com/pluralplay), whose provider-oriented work and ideas informed parts of ReClash.
- [mihomo](https://github.com/MetaCubeX/mihomo) by [MetaCubeX](https://github.com/MetaCubeX), the proxy core used by the application.

ReClash is maintained independently. References to other projects describe technical lineage, compatibility, and dependencies; they do not imply endorsement.

The full dependency list and corresponding licenses are included with the application and in the repository.

## License

ReClash is distributed under the [GNU General Public License v3.0](LICENSE).
