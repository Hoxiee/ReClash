# Setting Changes

A changed setting takes one of three paths. The path depends on who reads the setting and when it reads it, not on
which page edits it. Choose the path when you add a setting or move one.

| Path    | Who reads the setting                       | Watched provider                       | Acts                          | Effect                                     |
|---------|---------------------------------------------|----------------------------------------|-------------------------------|--------------------------------------------|
| Update  | Core, and Go can change it in place         | `updateParamsProvider`                 | `CoreManager`, automatically  | Patches the running config, no reload      |
| Apply   | Core, only when it parses a config          | `setupPatchProvider`                   | `CoreManager`, automatically  | Rebuilds the profile and reloads the Core  |
| Restart | Android service, when it starts             | `vpnOptionsProvider`                   | `VpnManager` asks the user    | Stop and start of the service              |

Update and apply run on their own, debounced. A restart never does: rebuilding the tunnel cuts every connection
through it, so `VpnManager` only shows a notifier and the user taps its restart action. A setting that only Flutter
reads takes no path.

## Update

`CoreManager` hands each change of `updateParamsProvider` to `SetupAction.updateConfigDebounce`. `updateConfig` then sends
`PatchClashConfig.toUpdateParams` to Go's `updateConfig` in `core/config.go`. That function writes the fields into the
running config and calls the runtime setter for each one, or `updateListeners` for the inbounds. Nothing is re-parsed.

When Core is disconnected or still connecting, `updateConfig` keeps settings local without RPC or authorization.
The next Core initialization applies the saved settings through the full profile path.

The update path carries these fields:

- From `PatchClashConfig`: `mode`, `log-level`, `mixed-port`, `allow-lan`, `ipv6`, `find-process-mode`,
  `tcp-concurrent`, `unified-delay`, `external-controller`, `secret`, `geo-auto-update`, `geo-update-interval`,
  `geox-url`, and the `tun` keys of `Tun.coreJson`: `enable`, `device`, `stack`, and `auto-route`, always on.
- From other settings: `NetworkProps.authentication`, and `AppSettingProps.checkCertificate`, sent as
  `skip-cert-verify`.

On desktop, `updateListeners` rebuilds the TUN from the patched `tun`. Enabling TUN may need authorization first. When
`requestAdmin` requires a privileged lease handoff, `updateConfig` restarts the Core instead of patching it.
Only the explicit TUN switch/start/restart grants a system prompt; a debounced setting update does not. Tray, hotkey
and compositor TUN commands use `SetupAction.setTunEnabled`, like the network switch, so enable grants are one-shot
and disable revokes a pending authorization.
Registration does not enable TUN until the managed lease is active, and system DNS follows confirmed `tunActive`. On Android,
`updateListeners` skips TUN, so a `tun` update reaches the VPN only through a restart.

To move a setting onto this path:

1. Add it to Dart `UpdateParams` and `toUpdateParams`.
2. Add it to Go `UpdateParams` in `core/protocol.go` and apply it in `updateConfig`.
3. Reset it in `PatchClashConfig.setupOnly`. If you skip this, every change also reloads the profile. The
   `PatchClashConfig.setupOnly` test in `test/models/config_test.dart` fails until its fixture changes the field and
   `setupOnly` resets it.
4. Keep writing it in `_makeRealProfileTask`, so a full apply hands the Core the same value.

Prefer update whenever Go has a setter for the setting, because an apply reloads the whole config.

## Apply

`CoreManager` answers each change of `setupPatchProvider` with `applyProfileDebounce(silence: true)`. That call
rebuilds the profile YAML and hands it to Go's `applyConfig` through `setupConfig`. The provider holds three values:

- `patchClashConfigProvider.setupOnly`: the config with every field that update carries reset to its default.
- `NetworkProps.appendSystemDns`.
- `NetworkProps.bypassPrivateRoute` on desktop, where the task adds the private ranges to the TUN's final
  `route-exclude-address`.

A change to anything else in `PatchClashConfig` therefore reaches it. Today that is the DNS and TUN overrides (`dns`,
`dnsOverrideKeys`, `tunOverride`, `tunOverrideKeys`), `hosts`, the extra inbound ports (`port`, `socks-port`,
`redir-port`, `tproxy-port`), the dialer options (`keep-alive-*`, `disable-keep-alive`, `interface-name`, its mode,
`routing-mark`), `geodata-loader` and `global-ua`. A new `PatchClashConfig` field written by `_makeRealProfileTask` lands here without further work. A value
the profile build reads from another settings object has to be added to `setupPatchProvider`.

An apply without `force` sends nothing when the md5 of the generated YAML has not changed. A value that only
`SetupParams` carries never changes the YAML, so this path does not deliver it. `testUrl` is that case: Go's default
health-check URL follows it only when some other change or a `force` apply reaches the Core.

Profile content does not go through `setupPatchProvider`. `setupStateProvider` reads rules, groups and scripts from the
database once instead of watching them. Content is applied explicitly by whatever changes it:

- Profile editors call `autoApplyProfile` when they close.
- Subscription updates, scripts and app-level providers call `applyProfileDebounce`.
- A profile switch runs `fullSetup`.
- A start applies again with `force` unless the last apply saw the same inputs (`_inputsApplied`), the `testUrl` and
  `skipCertVerify` that only `SetupParams` carries included.

## Restart

`VpnService.handleStart` builds the tunnel from the session’s `VpnOptions`; resume restores those same options.
`ServiceController.start` uses `enable` to choose between `VpnService` and `ProxyService`.

`vpnOptionsProvider` derives the options the service would start with now. `runningVpnOptionsProvider` records what
the last listener start handed it. The route list is subtracted in an isolate by `vpnRouteAddressProvider`, which
reruns only when the route lists or `bypassPrivateRoute` change, so `vpnOptionsProvider` is async: a start awaits it
before recording, the Android Core awaits it before its first `syncState`, and the shared state keeps the last options
while new routes compute rather than handing the service an empty list. `SetupAction` owns every start and stop: it
sets the record on a start and clears it on a stop. On-demand pause preserves the run and its recorded options.

`VpnManager` shows the notifier whenever a change leaves `VpnOptions.effective` different from the recorded options.
Repeated changes refresh the same notifier instead of stacking new ones. Changing a setting back to the running value
asks for nothing. The tap runs `SetupAction.restartVpn`: a stop, then a start, and only while a run is up.

| `VpnOptions` field     | Taken from                                                    | The service reads it                   |
|------------------------|---------------------------------------------------------------|----------------------------------------|
| `enable`               | `VpnProps.enable`, off in safe mode                           | always                                 |
| `stack`                | `Tun.stack`                                                   | with the VPN                           |
| `ipv6`, `dnsHijacking` | `VpnProps`                                                    | with the VPN                           |
| `allowBypass`          | `VpnProps`                                                    | with the VPN                           |
| `accessControlProps`   | `VpnProps.accessControlProps`                                 | `enable`, `mode` and that mode's list  |
| `systemProxy`          | `VpnProps.systemProxy`, off under local auth or safe mode     | with the VPN                           |
| `port`                 | `PatchClashConfig.mixedPort`                                  | with `systemProxy`                     |
| `bypassDomain`         | `NetworkProps.bypassDomain`                                   | with `systemProxy`                     |
| `routeAddress`         | `Tun.routeAddress` and `bypassPrivateRoute`                   | with the VPN                           |
| `mtu`                  | `Tun.mtu`                                                     | with the VPN                           |
| `congestionController` | `Tun`                                                         | with the VPN                           |

The service never reads the access list's sort and filter fields. `effective` resets them, along with every field
the table does not mark as read, so changing them does not ask for a restart.

To add a VPN option:

1. Add it to Dart and Kotlin `VpnOptions` and to `vpnOptionsProvider`.
2. If the service reads it only under a condition, put that condition in `VpnOptions.effective`, which mirrors
   `ServiceController.start` and `VpnService.handleStart`.

The notifier stays off while nothing runs, during on-demand suspension, in safe mode, and on desktop, where
`VpnManager` is not mounted. When Flutter reattaches to a service that is already running, it records the current
options, because the service does not report the options it was started with.

## One Setting, Several Paths

Each path watches its own provider, so a single setting can take more than one of them:

- `mixedPort`: update moves the Core's listener; under the VPN system proxy, the restart notice follows.
- TUN switch and stack: update rebuilds the desktop TUN. On Android the update reaches no TUN, and the restart notice
  carries the stack.
- MTU, congestion control and routes: Android's rows take the restart path; on desktop they are TUN overrides, applied
  with the profile.
- `bypassPrivateRoute`: apply on desktop, restart on Android.
- Local authentication: update applies it to the inbounds. It also switches the VPN system proxy, which needs a
  restart.

## Региональные значения по умолчанию

`SystemAction.applyRegion` записывает DNS, MTU и список обхода региона в обычные настройки (`PatchClashConfig`,
`NetworkProps.bypassDomain`), поэтому редакторы показывают реальные значения. При смене региона заменяются только
значения, совпадающие с умолчаниями прежнего региона; изменённые вручную остаются. «Восстановить по умолчанию» на
страницах «Сеть» и DNS возвращает значения текущего региона. Пользовательские профили получают DNS региона из
`regionCode` для ключей, которые они не задают. Проверки сервисов остаются Flutter-настройкой, а Android-подбор
приложений — отдельным действием с подтверждением. Автоопределение не применяет регион, VPN перезапускается только
через существующее подтверждение `VpnManager`.

## Web Dashboard

`AppSettingProps.webDashboardFlavor` is read only by Flutter and takes no update, apply or restart path. The two
installations share one managed `external-ui` root and select `/ui/<flavor>/` in the URL. Switching flavor neither
reinstalls a panel nor reloads the profile.

Dashboard access is runtime state in `webDashboardAccessProvider`, not an `AppSettingProps` or `PatchClashConfig`
mutation. Saved external-controller settings and their secret win; otherwise session ownership supplies a temporary
loopback controller and secret to both `SetupAction._effectivePatchConfig` and `updateParamsProvider`.
`syncWebDashboardAccess` sends a live update through the setup scheduler without restarting VPN. Closing embedded
access, ending browser access or exiting removes the overlay and restores the saved values. Explicit controller
setting changes revoke the overlay rather than reopening what the user closed. Safe Mode never enables it.

`prepareWebDashboard` applies the profile only when the installed managed root differs from the last successful apply.
Publishing an updated panel under that same root needs no apply; file-serving sees the replacement directly. The
profile task clears profile-owned `external-ui-url` and `external-ui-name` even when no dashboard is installed.

## Choosing The Path

For a new or moved setting, answer each question. More than one answer can be yes.

1. Does the Android service read it when it starts? Then it belongs in `VpnOptions` and takes the restart path.
2. Does the Core read it, and can Go change it in place? Then it belongs in `UpdateParams` and takes the update path.
3. Does the Core read it only when it parses a config? Then write it into the generated config, and it takes the
   apply path.
4. Does only Flutter read it? Then it takes no path.

Tests that hold these rules:

- `test/models/config_test.dart` (`PatchClashConfig.setupOnly`).
- `test/models/core_test.dart` (`VpnOptions.effective`).
- `test/providers/state_derived_test.dart` (the setup patch).
- `test/manager/core_manager_test.dart` (update against apply).
- `test/manager/vpn_manager_test.dart` (the restart notice).
- `test/providers/setup_action_test.dart` (running options, suspension, `restartVpn`).

## On-demand

`VpnProps.onDemandEnabled`, `onDemandFullStop`, `onDemandCloseConnections`, `onDemandStrict` and the existing
`excludeSSIDs` list form a live policy. `VpnOptions` carries it to Android, while `effective` excludes it from restart
comparison. `ServiceState` serializes native pause/resume against run transitions and keeps monitoring physical
networks when Flutter is detached. Ordinary pause removes TUN and retains Core and proxy ports; full stop also closes
proxy listeners. Resume restores the session’s tunnel options, leaving unrelated changed VPN settings on the restart path.

Desktop `SetupAction` sends pause changes through its listener scheduler. Go applies pause as runtime state without
mutating saved TUN configuration, so profile reloads and listener updates preserve it. SSID reads are opted in only
when the policy is enabled and includes SSID rules; subnet-only rules need no location access. Matching uses exact
SSID names and IPv4/IPv6 CIDRs, with strict AND semantics when both rule kinds exist. Manual intent clears when the
physical network changes or the run stops.
