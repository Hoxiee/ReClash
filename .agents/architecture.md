# Architecture

## Core Integration

The Go proxy core in `core/` operates in two modes.

Android lib mode:

- Go core is compiled as a C shared library, `libclash.so`, through `go build -buildmode=c-shared` with CGO.
- The Android `:core` module owns JNI access to the in-process library. Flutter crosses the `${packageName}/service`
  MethodChannel through `lib/plugins/service.dart` and Android's `ServicePlugin` rather than talking to JNI directly.
- `lib/core/lib.dart` (`CoreLib`) implements the shared Core interface, gates method calls on its connection completer,
  initializes and synchronizes Android shared state, and closes the native service path exactly once.
- Because Core is in the application process on Android, application RSS already includes Core memory.

Desktop core mode:

- Go core runs as a separate process with `CGO_ENABLED=0`.
- `rust_api`'s `ipc` module provides the native local-IPC primitives: a Unix domain socket on macOS/Linux and a named pipe
  on Windows.
  Dart now owns the transport state, RPC correlation, process ownership, and lifecycle convergence above those primitives.
- `lib/core/service.dart` (`CoreService`) is the composition root. It wires the IPC transport, launcher selection,
  lifecycle controller, RPC client, and crash-event bridge; it is no longer the whole desktop implementation by itself.
- `lib/core/desktop/transport.dart` converts native IPC frames into ready, connected, disconnected, failed, and data
  events. A replaceable binding keeps RPC subscriptions stable when a failed or stale transport must be rebuilt.
- `lib/core/desktop/rpc_client.dart` owns request IDs and pending completers, waits up to 10 seconds for a connection,
  applies a three-minute default method timeout, unwraps `CoreMethodResponse`, and fails all pending calls when transport
  disconnects or closes.
- `lib/core/desktop/lifecycle.dart` serializes process intents and owns the authoritative desktop state machine.
- `lib/core/desktop/launcher.dart` abstracts direct child-process and Helper ownership through idempotent process leases.
  `lib/core/desktop/windows_launcher.dart` adds cancellable, UAC-managed Windows launches; Linux uses the capability-backed
  Helper through `lib/core/desktop/helper_client.dart`.

`lib/core/controller.dart` (`CoreController`) selects the implementation based on platform. `lib/core/interface.dart` defines the shared `CoreHandlerInterface`.

Key Go core files:

- `core/hub.go`: handler functions.
- `core/method.go`: MethodChannel-style method-call dispatch and response envelopes.
- `core/message.go`: non-blocking priority/bulk event queues and bounded message batching.
- `core/lib.go`: CGO exports.
- `core/server.go`: desktop socket/named-pipe client and framed message forwarding.

## Listener Exposure

`_makeRealProfileTask` in `lib/common/task.dart` writes `mixed-port`, `allow-lan`, and `external-controller` into every
generated profile. With `allow-lan` off, mihomo's `genAddr` binds each listener to `127.0.0.1`; the external controller is
`ExternalControllerStatus.close` by default and never binds anywhere but loopback.

The loopback listener takes local connections without authentication on every platform, Android included. That is the
design, not an oversight: the app reaches the network through its own mixed port, and credentials on that port would lock
out both ReClash and every other local consumer, which is the reason a local proxy client exists. The boundary the binding
does enforce is that traffic must originate on the device; it does not isolate programs already running there, so on
Android any app holding `INTERNET` can use the proxy and learn the outbound IP. Reports treating that as a vulnerability
(#1934) are answered by this paragraph. Do not add authentication, per-UID filtering, or a random local credential to this
path without an explicit decision from the maintainer.

### Interface Name Modes

The same task also writes `interface-name` per `PatchClashConfig.interfaceNameMode`: `clear` (default) forces it empty so a
subscription's value cannot survive into the generated profile, `follow` leaves whatever the profile YAML already has, and
`custom` writes the user's `interfaceName`. mihomo ignores `interface-name` on Android whenever `dialer.DefaultSocketHook`
is installed (`core/lib.go` `installHooks`, vendored `dialer.go`), so `NetworkListView` in `lib/views/config/network.dart`
shows the mode picker and text field only on desktop.

## Lifecycle Ownership And Convergence

### Shared Flutter Layer

`CoreController.start()`, `restart()`, `stop()`, and `close()` are the only shared lifecycle facade. `close()` is terminal;
callers must not try to reuse a closed platform implementation.

`CoreAction` in `lib/providers/actions/core.dart` owns the user-facing Core status and setup sequence:

- `startCore()` publishes `connecting`, starts the platform Core, publishes `connected`, then initializes Core state. A
  startup error publishes `disconnected` and displays the error.
- `restartCore()` coalesces overlapping callers behind one worker. `_requestedRestartRevision` records newer requests,
  while `_latestExplicitStart` retains the newest requested post-restart running intent. After the lifecycle restart and
  `initCore()`, the worker reapplies profile/running state until it has consumed the latest revision.
- The provider is an orchestration and presentation layer, not a process owner. Platform lifecycle code remains responsible
  for determining whether a Core process/service is actually running.

Application exit is centralized in `SystemAction` and `SystemExitCoordinator`:

1. Optionally save config and clean up DNS, system proxy, and tray resources in parallel.
2. Close the desktop window.
3. Call terminal `CoreController.close()`.
4. Exit the application exactly once.

The coordinator is idempotent, continues later cleanup steps after an earlier error, preserves the first error for the
caller, and uses a three-second watchdog as an emergency application-exit path. `Application.dispose()` and
`CoreManager.onCrash()` do not independently destroy Core; this avoids competing shutdown owners.

### Desktop Lifecycle

`DesktopCoreLifecycle` is a latest-desired-intent reconciler, not a queue that blindly executes every request:

- Public intents receive monotonically increasing revisions and target running, restarted, stopped, or closed.
- Observable phases are `idle`, `starting`, `running`, `stopping`, `failed`, and `closed`.
- A completed command reports `applied`, `coalesced`, or `superseded`, allowing callers and tests to distinguish a command
  that won from one satisfied or replaced by a newer compatible intent.
- Startup opens or replaces the IPC transport, resolves a launcher, generates a 128-bit lowercase hexadecimal session ID,
  launches Core, and waits for the matching connection. Windows additionally verifies that the named-pipe peer PID equals
  the process PID in the launch lease; the native managed bootstrap authenticates both processes before admitting RPC.
- Each running session retains its process owner, lease, PID, session ID, and transport connection generation. Stop waits
  for both process-exit confirmation and the matching disconnect generation; a missing disconnect replaces the transport
  before later starts.
- An unconfirmed process exit is retained as an unconfirmed lease. New start/restart intents fail until ownership can be
  cleaned up, preventing two Core instances from being treated as the active session. Terminal close may continue on a
  best-effort basis because the application is exiting.
- An unexpected disconnect or transport failure while running is converted to `DesktopCoreFailure`, the owned process is
  cleaned up, and `CoreService` emits a Core crash event for the normal UI recovery path.

macOS uses direct launch. Linux selects its capability-backed Helper when ready and otherwise uses direct launch for
local proxy operation. Windows uses direct launch for an ordinary GUI's proxy-only session and `windowsElevated` ownership
when TUN requires privileges or the GUI is already elevated. A requested TUN without a privileged session or working
listener is a startup failure, never a successful proxy-only fallback.

### Windows Managed Launch

`CoreService.requireTunElevation` changes the next session's requirements; providers do not spawn Core. Explicit consent
permits one UAC attempt and is not proof of authorization. Only an active managed Core authorizes TUN. Silent startup and
automatic recovery do not reuse consent to open another UAC prompt.

- `windows_launcher.dart` prepares a native ticket synchronously before asynchronous launch. `CoreLaunchAttempt` exposes
  actual spawn, lease readiness and cleanup completion. The lifecycle subscribes to IPC before launch, allows 120 seconds
  for UAC, and starts the ten-second bootstrap/connection budget at actual spawn. Stop revokes a pending attempt without
  waiting for the user to dismiss UAC; another launch is blocked until native ownership is settled.
- `plugins/rust_api/rust/src/windows/` owns the ticket, exact process handle and unnamed kill-on-close Job Object. It
  locks and hashes the fixed sibling `ReClashCore.exe` before `ShellExecuteExW/runas`. Neither a general command nor an
  arbitrary executable path is accepted. The manifest hash detects mismatch, not a fully replaced bundle's authenticity.
- The bootstrap pipe has an explicit DACL at creation, first-instance protection and remote-client rejection. Windows
  supplies peer PID/session; the handshake also checks process creation identity. Core verifies the original GUI's SID
  and executable. GUI verifies an elevated identification-only token, allowing a different administrator account's SID.
- Temporary process/token DACL grants let that administrator query the original GUI and duplicate its job handle. They
  are restored after handoff or cancellation. Core joins the job and immediately closes its duplicate; the GUI retains
  the final handle. `JOINED` followed by `COMMIT` gates ordinary RPC and TUN. Cancel revokes the ticket before job shutdown;
  terminating an empty job is not proof that a delayed UAC launch cannot appear.
- `core/managed_windows.go` installs a ten-second watchdog before bootstrap, rejects unmanaged elevated startup and checks
  the GUI again on the RPC pipe. Unconfirmed exit keeps the attempt/lease owned and blocks replacement. A dead GUI ends
  the managed Core through the job or bootstrap watchdog, without requiring the GUI to hold `PROCESS_TERMINATE`.
- Core uses the original GUI's supplied data directory, with the root and ancestors held against replacement. This is not
  a filesystem sandbox for descendant paths or profile/controller operations: Core still executes those with its elevated
  token. Cross-account handoff and actual UAC/TUN behavior require real Windows validation.

### Android Service Lifecycle

Android deliberately keeps Flutter requests optimistic and the native layer authoritative:

- `ServicePlugin.start()` and `stop()` acknowledge immediately after submitting intent. They do not wait for service
  creation, VPN permission, binding, TUN establishment, or teardown.
- `ServiceState` owns the latest `RunRequest`, shared configuration, run time, and `STOPPED`/`STARTING`/`STARTED`/`STOPPING`
  state. Identity checks discard obsolete work. `startPreparationLock` serializes permission/setup preparation and
  `transitionLock` serializes actual service transitions.
- `ServiceController` owns exactly one `ManagedServiceBinding`, selects `VpnService` or `ProxyService` from `VpnOptions`,
  binds with a five-second connection timeout, invokes `ManagedService.start()`/`stop()` off the main thread, and clears
  binding/run-time state on failure or disconnection.
- Generic service creation/destruction is lifecycle evidence, not user intent. New commands must flow through
  `ServiceState.requestStart()`/`requestStop()` or the explicit system-action handlers instead of inferring intent from a
  callback.

Quick Settings, notification, revoke, and Always-on VPN paths converge on the same owner:

- With a Flutter engine attached, `ServiceState.handleStartAction()`/`handleStopAction()` forward through `TilePlugin` to
  `TileManager`, which updates normal Flutter setup state. Without Flutter, native code restores `SharedState` from
  preferences, runs `quickSetup`, checks VPN permission, and submits the native request directly.
- Android may create an Always-on `VpnService` through `onStartCommand()` without FlClash's bound-service path. The service
  sends the explicit, permission-protected `VPN_START_REQUESTED` broadcast to `ServiceBroadcastReceiver`, which routes it to
  `ServiceState.handleStartAction()` so Core/configuration and the normal binding are restored before TUN is treated as
  ready.
- `VpnService.onRevoke()` stops TUN/modules first, then sends `VPN_REVOKED`; the receiver only requests a stop when
  `ServiceController` still owns an active VPN binding.
- `ServiceBroadcastReceiver` uses `goAsync()` and an atomic one-shot completion. Normal completion or a nine-second
  watchdog calls `PendingResult.finish()` exactly once; the watchdog releases Android's broadcast lease and does not
  cancel or redefine the underlying lifecycle intent.

## Core Protocol And Event Delivery

The shared protocol uses `CoreMethodCall(id, method, arguments)` and `CoreMethodResponse(id, result, error)` in both
directions. The envelope is the only JSON serialization layer: keep arguments, results, and event data as structured JSON
values rather than embedding pre-encoded JSON strings. Plain domain strings, such as country codes or provider contents,
remain strings.

Go event delivery is intentionally non-blocking:

- State-bearing events such as delay, loaded-provider, and geo-update use a 256-entry priority queue. Desktop process
  crashes are generated locally by `CoreService` from lifecycle failures rather than sent through the Go queue.
- High-volume log and request/connection events use a separate 256-entry bulk queue, so bulk floods cannot evict state.
- A full queue evicts only its own oldest event and retries the newest event; Core work never blocks on event delivery.
- The batcher flushes at 32 messages or every 16 milliseconds. Priority events are preferred, but one bulk opportunity is
  guaranteed after eight priority messages to prevent starvation.

Desktop RPC accepts both a single event object and batched event lists. Android and desktop listener dispatch isolate
listener exceptions so one faulty observer does not prevent the remaining events/listeners from running.

## User-Facing Core And Delay Feedback

`CoreStatusButton` in `lib/views/dashboard/widgets/core_status_button.dart` is the desktop dashboard's status/restart
surface. It is shown only outside dashboard edit mode and only when `coreLib == null`:

- Provider state remains authoritative. The widget keeps a separate display-only status so a fast
  `connecting -> connected` transition still shows at least 600 milliseconds of progress instead of flashing.
- The hold arms only after an observed transition to `connecting`; mounting while already connecting does not invent a new
  delay. A real `disconnected` transition cancels the hold immediately so failure is never hidden, while a long-running
  connecting state remains visible after the timer expires.
- Taps during the display hold or while the provider is genuinely connecting are inert. Connected/disconnected taps show
  the appropriate confirmation and delegate restart to `CoreAction`; the widget never starts Core directly.

Proxy delay testing follows the same failure-safe UI rule. `proxyDelayTest()` records an in-progress zero delay, writes the
real result on success, and logs plus records `-1` on exceptions. `DelayTestButton` reverses its animation in `finally`, so
an RPC failure cannot leave the control permanently spinning.

## Settings Rows

`lib/widgets/config_item.dart` holds the shared settings-row vocabulary: `ConfigToggleItem`, `ConfigOptionsItem`,
`ConfigTextItem`, and `ConfigListInputItem`. Each takes a `selector` (a `ProviderListenable`, normally
`someProvider.select(...)`) and an `onChanged(ref, value)` writer, and watches its own selector so changing one setting
rebuilds one row instead of the whole section. Titles and subtitles are `ConfigLabel` callbacks that receive
`AppLocalizations`, which keeps literal labels such as `IPv6` and localized labels in the same shape.

Build settings screens from these directly, or from a file-local helper that binds one provider once — see `_dnsToggle`
in `lib/views/config/dns.dart` and `_appSettingToggle` in `lib/views/application_setting.dart`. Declare a named
`ConsumerWidget` only when a row is genuinely reused across screens, as `lib/views/config/network.dart` rows are by
`lib/views/dashboard/widgets/quick_options.dart`. Rows with bespoke behaviour — a custom dialog, a derived value, or a
second provider write — stay hand-written rather than growing extra parameters on the shared items.

## State Management

Provider files in `lib/providers/`:

- `app.dart`: runtime/UI state, logs, traffic, delays, loading, navigation.
- `config.dart`: persistent config providers, app settings, theme, VPN, proxy style.
- `state.dart`: derived/computed providers, navigation, proxy, tray, color scheme.
  Like `action.dart`, this is an entry point only: the providers live under
  `lib/providers/state/` and are joined with `part` directives, so importing
  `state.dart` still reaches all of them.
  - `state/proxies.dart`: group and proxy lists, filter/sort, delay, selection.
  - `state/navigation.dart`: navigation items, current page, dashboard, more tools.
  - `state/system.dart`: tray, VPN params, access control, hot keys, shared state.
  - `state/theme.dart`: dynamic color, color scheme, brightness.
  - `state/profile.dart`: profiles, current profile, clash config, setup state.
  - `state/overwrite.dart`: custom overwrite validity and the staged group/rule notifiers.
- `action.dart`: business logic notifiers, setup, backup, core lifecycle, proxy selection.
- `core.dart`: `coreHandlerProvider`, the container-scoped handle on `CoreController`.
- `database.dart`: Drift database provider wrappers.

### Reaching Singletons

`lib/common/` and `lib/core/` publish process-wide singletons (`coreController`,
`system`, `preferences`, `appPath`, `request`, and others). Code that already has a
`Ref` or a `WidgetRef` reads them through a provider instead, so a test can scope a
fake to one `ProviderContainer` rather than swapping a global and relying on a
tearDown to put it back.

`coreHandlerProvider` is the established case. Every call site under
`lib/providers/`, `lib/manager/` and `lib/views/` goes through it; notifiers and
`ConsumerState` classes that touch Core repeatedly hold it as
`CoreController get _core => ref.read(coreHandlerProvider)`.

Tests override it with `coreHandlerProvider.overrideWithValue(CoreController.scoped(fake))`,
which does not claim the singleton. `CoreController.test` does claim it, and is
only for tests that have not moved yet. Prefer the scoped override even when a
test passes either way: a test that claims the singleton makes the global and the
provider resolve to the same fake, so it cannot tell a provider read from a
leftover global read, and a half-migrated call site stays green.

One deliberate exception: `globalState` owns the `ProviderContainer`, so it cannot
itself live in one. Code without a `Ref` reaches providers through
`globalState.container.read(...)`. The remaining call sites are `lib/core/lib.dart`,
`lib/common/print.dart`, and the tray `read` callback in
`lib/providers/actions/system.dart` — all singletons or platform callbacks with no
`Ref` in scope.

`lib/models/profile.dart` no longer reaches Core. `Profile.saveFile` and
`Profile.update` take a `ValidateConfig` callback, and every caller passes
`(path) => _core.validateConfig(path)`, keeping the Core handle lazy so a profile
path that never validates never resolves the controller.

The UI layer must not reach a process-wide singleton directly.
`test/lint/ui_layer_singleton_test.dart` scans `lib/views`, `lib/widgets`,
`lib/pages` and `lib/features` for `globalState.container` and the bare
`coreController` global and fails the run on either. Widgets that need Core hold
`CoreController get _core => ref.read(coreHandlerProvider)`.

`globalState.measure` and `globalState.theme` stay global on purpose. Both are
context-derived caches assigned by `ThemeManager`, and tests already scope them by
assigning in the app builder (see `test/helpers/test_app.dart`); moving them into
providers would touch every layout call site without changing behaviour.

`globalState` in `lib/state.dart` is a singleton holding ambient app state — the
package info, the measure and theme, the container, and the start/stop flags —
plus `safeRun`/`loadingRun`. Startup orchestration is **not** on it: `init` and
`attach` live in `lib/bootstrap.dart`, above `lib/common`, because they drive the
window, the autostart entry, the tray and the permission prompts. Providers are
generated into `lib/providers/generated/`.

The root navigator key lives in `lib/common/navigator.dart` as `rootNavigatorKey`;
`globalState.navigatorKey` is a getter onto it. `lib/common/dialog.dart` reaches
the key directly, so the dialog helpers no longer import `lib/state.dart`.

### Platform Layering

`lib/common/common.dart` deliberately does not export `tray.dart`, `window.dart`,
`launch.dart`, `system_dns.dart`, or `permission.dart`. Those five modules import
`tray_manager`, `window_manager`, `launch_at_startup`, and `screen_retriever`;
exporting them put those packages in the compile graph of all 132 files that
import the barrel for a string helper. Import the specific module instead.

`test/lint/platform_layering_test.dart` enforces four rules. Three are local: the
barrel never re-exports one of those five modules, nothing under `lib/common`,
`lib/enum` or `lib/models` other than those five imports a desktop platform
package, and `lib/common` never imports the `lib/manager/manager.dart` barrel
(import the single manager needed, as `common/context.dart` does with
`manager/status_manager.dart`). The fourth walks the barrel's whole transitive
closure and fails if *any* file in it imports one of those packages. That one is
the real invariant — the local rules only stop the shortest path, and every leak
found so far arrived through a longer one.

Four consequences are already in the tree:

- `System.back` and `System.exit` no longer touch `window`; the window half of
  both lives in `SystemAction`.
- `KeyboardModifier.toHotKeyModifier()` moved from `lib/enum/enum.dart` to
  `lib/manager/hotkey_manager.dart`, its only consumer.
- Startup orchestration moved off `GlobalState` into `lib/bootstrap.dart`.
  `common/num.dart`, `common/print.dart` and `common/request.dart` import
  `state.dart` for `theme`, `container` and `packageInfo`/`ua`, so anything
  `GlobalState` reaches lands in the barrel's closure; the ambient state it now
  holds reaches nothing platform-specific.
- `SystemAction` talks to `WindowPort` and `TrayPort` from
  `lib/common/app_ports.dart` instead of importing `common/window.dart` and
  `common/tray.dart`. `lib/bootstrap.dart` binds `windowPort` and `trayPort` to
  the real implementations; both stay null in tests, where every call through
  them is a no-op. A test that needs the real tray assigns `trayPort` itself, as
  `test/common/tray_menu_test.dart` does.

Narrow the barrel imports too: `lib/providers/providers.dart` re-exports
`action.dart`, so importing the providers barrel from `lib/common` or from
`providers/app.dart` reaches the whole action layer. Those three now import
`providers/state.dart` and `providers/config.dart` directly.

The same shape appeared twice more, without a platform package involved: a data
type in a lower layer holding the widget that renders it, which drags the whole
view tree into the barrel's closure.

- `lib/common/navigation.dart` was a route table building view widgets. It is
  now `lib/views/navigation.dart` implementing `NavigationPort`, which
  `providers/state/navigation.dart` reads through and `bootstrap.init` binds.
  Unbound it yields no items, so a test that renders navigation assigns
  `navigationPort` itself, as `test/pages/home_test.dart` does.
- `DashboardWidget` carried a `GridItem` per value, so `lib/enum/enum.dart`
  imported the dashboard cards — and `lib/widgets/widgets.dart` with them. The
  enum is persisted in the app settings, so it is back to plain data; the
  mapping lives in `lib/views/dashboard/widget_registry.dart`, the reverse
  lookup relying on the branches returning canonical consts.

Together those took the closure from 258 files to 187, with nothing under
`lib/views` left in it. `test/lint/platform_layering_test.dart` pins that
directly: the barrel's closure must contain no `lib/views` file. Data the
provider layer needs from the UI layer goes through a port in
`lib/common/app_ports.dart` rather than an import in the other direction.

### High-Frequency Buffers

`logsProvider`, `requestsProvider` and `trafficsProvider` hold a `FixedList`
(`lib/common/fixed.dart`), which trades a normal copy-on-write for a shared
buffer tagged with a generation counter:

- `append` mutates the buffer in place and returns a new wrapper one generation
  ahead. That is what providers publish, so `updateShouldNotify` still fires.
- `list` returns an immutable copy, cached until the next mutation. It must stay
  eager: an older wrapper shares the buffer, so its contents move on. Anything
  that needs a stable view has to read `list` at the moment it is notified, not
  hold the wrapper and read later.
- Consumers that only need to know *that* the buffer changed watch `revision`,
  not `list` — selecting on the list snapshots and deep-compares the whole
  buffer on every arrival, which is what this design exists to avoid. See
  `lib/views/logs.dart` for the pattern: watch the generation, snapshot inside
  the throttled callback.

`add`/`clear` mutate in place without advancing the generation; use them only on
a buffer you own outright (seeding, resets, tests), never on published state.

## Database

The app uses Drift/SQLite in `lib/database/`. Current schema version is 2.

Tables:

- `Profiles`
- `Scripts`
- `Rules`
- `ProfileRuleLinks` (`profile_rule_mapping`)
- `ProxyGroups`
- `IconRecords` (`icon_records`)

Rule scenes distinguish global added rules, profile added rules, profile custom rules, and disabled links. Rule and proxy-group ordering use fractional indexing.

Generated Drift output lives in `lib/database/generated/database.g.dart`. After schema changes, run code generation and add or update focused database tests under `test/database/` when converter or migration behavior changes.

## Manager Stack

Managers are nested `InheritedWidget`/`StatefulWidget` components built by `buildManagerStack()` in `lib/application.dart`:

```text
AppEnvManager > StatusManager > ThemeManager
  > [Desktop: WindowManager > TrayManager > HotKeyManager > ProxyManager]
    [Mobile:  AndroidManager > TileManager]
  > AppStateManager > CoreManager > ConnectivityManager
  > [Desktop: WindowHeaderContainer] [Mobile: VpnManager]
  > app content
```

Each manager in `lib/manager/` handles a specific platform concern. The
platform slots are exclusive: no desktop manager appears on mobile and no mobile
manager appears on desktop.

The order is an ownership contract, not a layout detail. `ConnectivityManager`
sits below `CoreManager` because its `onConnectivityChanged` callback reads
Core-backed state, so Core must already be mounted when it fires. `StatusManager`
and `ThemeManager` sit above the platform managers so a platform manager can
surface a message or read the theme.

`buildManagerStack()` is a pure function of `isDesktop`, the connectivity
callback, and the app content, so `test/application_test.dart` asserts the whole
order by constructing the stack without mounting it. Changing the nesting means
updating both this diagram and that test.

## Core Controller and Actions

`lib/core/controller.dart` (`CoreController`) is a singleton facade over `CoreHandlerInterface`. Public methods delegate to the platform-specific interface, either Android FFI or desktop socket. It has an `@visibleForTesting` constructor and `resetInstance()` for test injection.

`lib/providers/action.dart` is the public library entry point for action
providers. The Riverpod notifier implementations are split by responsibility
under `lib/providers/actions/` and joined to the entry point with `part`
directives, so consumers continue to import the same public API:

- `CommonAction`: update check and common UI operations.
- `SetupAction`: config setup and TUN management.
- `BackupAction`: backup/restore with WebDAV sync.
- `CoreAction`: core lifecycle, initialization, coalesced restart, and post-restart profile/running-state application.
- `SystemAction`: system integration, tray, coordinated resource cleanup, terminal Core close, exit, and brightness.
- `StoreAction`: profile storage operations.
- `ThemeAction`: theme state updates.
- `ProxiesAction`: group management and proxy selection.
- `ProfilesAction`: profile CRUD, auto-update, import.
- `GeoResourceAction`: geo resource updates and URL configuration.
- `UpdatingAction`: stale sweep over `UpdatingKeys`.

`UpdatingKeys` in `lib/providers/app.dart` owns every per-entity updating flag; `isUpdatingProvider(key)` is the
read-only view widgets watch. Callers pair `start(key, scope: ...)` with `stop(key, operation)` using the returned
token, so overlapping operations on one key are reference counted and a late `stop` from a superseded operation
cannot clear a newer one. Keys started with `UpdatingScope.core` depend on the Core to make progress, so
`UpdatingKeys` discards them itself when `coreStatusProvider` leaves `connected` — that is the state's own
invariant, not a policy, and it must stay inside the notifier where no warm-up ordering can miss it.
`UpdatingScope.local` keys (profile updates run entirely in Dart) survive a Core restart. `UpdatingAction` holds
only the policy half: the periodic sweep that discards a key stuck past `updatingStaleTimeout`. Do not move the
timeout back into `UpdatingKeys`, and do not widen the disconnect reset to every scope.

## Platform Managers

Desktop:

- `WindowManager`
- `TrayManager`
- `HotKeyManager`
- `ProxyManager`

Mobile:

- `AndroidManager`
- `TileManager`
- `VpnManager`

Shared:

- `ConnectivityManager`
- `CoreManager`
- `AppStateManager`
- `StatusManager`
- `ThemeManager`

## Build System

`setup.dart` is the release build orchestrator:

1. Writes `env.json` (`APP_ENV`).
2. Activates `flutter_distributor` for packaging.
3. Relies on the platform build hook to build the required Core artifacts before
   the native application is linked.

Go core building is handled by `build_tool`, a standalone Dart CLI in `plugins/setup/buildkit/build_tool/`.

Platform build hooks inside `flutter build` trigger `build_tool` automatically:

- macOS: podspec script phase, `build_pod.sh`, `build_tool macos`.
- Linux: CMake include, `buildkit/cmake/buildkit.cmake`, `build_tool linux`.
- Windows: CMake include, `buildkit/cmake/buildkit.cmake`, `build_tool windows`. CMake forwards the active configuration through `BUILDKIT_CONFIGURATION`.
- Android: Gradle include, `buildkit/gradle/plugin.gradle`, `build_tool android`.

### Setup Build Harness Plugin

`plugins/setup/` is a build-time Flutter plugin, not a runtime Dart or FFI API. Its plugin shape exists so Flutter's native
build graphs can run the Go/Rust build harness before platform consumers need the generated artifacts. Application code
must not import or call it.

Responsibilities are deliberately split:

- CocoaPods, Gradle, and CMake hooks schedule a lightweight check on every native build. They do not decide which Go or
  Rust files are stale.
- `buildkit/build_tool/` owns target resolution, input fingerprinting, compilation, output copying, and cache validation.
- `core/` and `services/helper/` remain source owners; `libclash/` and Android `jniLibs`/header directories are generated
  output locations.
- `setup.dart` remains the release/package orchestrator and does not pre-build
  platform artifacts or use `dart-define` for Core integrity data. The Windows
  build tool writes the runtime `manifest.json` beside the Core output, and the
  Windows bundle copies it beside the application executable.

Platform outputs remain explicit:

- Android builds the Go core as `c-shared`, then copies `libclash.so` and generated headers into the `:core` Android module.
- macOS and Linux build a standalone `ReClashCore` process used by the desktop socket integration.
- Windows builds `ReClashCore.exe` and a `manifest.json` containing `coreSha256`. The build tool also compiles the legacy
  Rust Helper, but `plugins/setup/windows/CMakeLists.txt` excludes it from the application bundle and package checks reject
  it. Managed elevation is supplied by `rust_api.dll`, not a Windows service.

The hooks follow rust_api/Cargokit's phony-output scheduling pattern, but setup uses its own cache because it builds both a
Go core and, on Windows, a separate Rust helper. Per-target records live under `.dart_tool/setup_build_cache/v1/`:

- Go fingerprints cover the target-specific `go list -deps` inputs inside `core/mihomo`, module files, effective
  build configuration, build-tool sources, target flags, Go environment/toolchain, and Android NDK compiler details.
- Windows helper fingerprints cover its Rust sources and manifests, Cargo/Rust
  toolchains and flags, and the expected Core SHA256.
- A cache hit requires the fingerprint and every recorded output's path, size, and modification state to match. It exits
  silently without Go/Cargo compilation, output copying, or Windows `taskkill`.
- Cache records are written only after a successful build and protected by per-target process/file locks. Missing outputs,
  changed inputs, cache-schema changes, or `--force` rebuild only the affected target.
- `flutter clean` removes `.dart_tool`, so the next native build performs one full core rebuild. Manual builds can bypass
  the cache with `make core-<platform> FORCE=1`.

This differs from `rust_api`: rust_api is a runtime Flutter Rust Bridge integration whose Cargokit hooks produce its native
FFI library, while setup is only the build and packaging bridge for FlClash's external core artifacts.

### Windows Package Validation

Windows CMake requires app-local MSVC runtime files and fails if none are found. The Inno template requires Windows 10,
uses `publisher_name`, and launches post-install with `runasoriginaluser`; it cannot undo elevation if Setup itself was
started elevated. Silent setup skips that first launch.

`setup.dart` runs `tool/windows_package.dart` on staging through the distributor's pre-package hook and again on the
finished ZIP. `tool/src/` validates reachable PE imports/delay imports/exports, architecture, required assets, safe ZIP
paths, absence of the legacy Helper and the Core manifest hash. It resolves app-local runtime dependencies from the bundle,
not the build host's PATH. An unreachable auxiliary DLL or the standalone x86 `EnableLoopback.exe` is not treated as a
startup dependency.

`tool/check_windows_package.ps1` verifies Authenticode status, installs into an isolated directory, compares installed
payload hashes with the ZIP and waits for a GUI window plus successful Core init RPC. Killing only the GUI then requires
Core exit; failed cleanup retains the installation. CI preserves installer/application logs. Hosted-runner smoke does not
prove a clean OS, standard-user UAC, cross-account credentials or TUN operation.

Unsigned builds are accepted only when signing is not required; an invalid existing signature always fails the Windows
check. `WINDOWS_SIGNING_REQUIRED=true` makes release validation reject unsigned binaries. Signing order is payload first,
then `--finalize-manifest` after signing Core, packaging, setup signature, final signature checks and `SHA256SUMS` last.
`--finalize-manifest` only updates the hash; neither it nor the PE certificate-directory check establishes trust.

Build configuration defaults live in `build_tool/lib/src/options.dart` and can be overridden via a root `build_config.yaml`.

Architecture detection is automatic. The `--description` flag passed to `flutter_distributor` adds arch suffixes to artifact names, such as `ReClash-0.8.93-macos-arm64.dmg`.

## Local Plugins

- `setup`: build-time harness for Go core and Helper artifacts; no runtime Dart API.
- `proxy`: system proxy configuration.
- `rust_api`: runtime Flutter Rust Bridge FFI plugin built through Cargokit. See below.
- `code_forge`: the FlClash config editor, vendored under `plugins/code_forge` (derived from the published `code_forge`
  package). Its SDK floor stays at upstream `>=3.13.2` for the `private-named-parameters` feature; it is a separate
  package with its own language version, so the repository's own `>=3.10.0` floor is unaffected. The editor's rope
  backend lives in `rust_api` (`src/editor/`); it replaced `re_editor`.
- `tray`: system tray for Linux, macOS and Windows. Written for FlClash; replaced the `tray_manager` fork.
- `wifi_ssid`: Wi-Fi SSID detection.
- `flutter_distributor`: app packaging/distribution.

## rust_api Crate Layout

`plugins/rust_api/rust/src/` separates the bridge boundary from the code behind it:

- `api/` is the only input flutter_rust_bridge parses (`rust_input: crate::api`). Every function there is a thin
  delegation, so the generated bindings stay identical on every platform.
- `ipc/` implements the desktop socket server: `frame` (length-prefixed framing and the write backoff), `queue` (the
  bounded send queue), `platform` (socket cleanup, Windows peer credentials and the non-blocking pipe reader), and
  `server` (lifecycle, accept loop, and the `RUNNING`/`STATE` globals).
- `script/` runs profile override scripts on QuickJS through `rquickjs`.
- `editor/` is the editor's rope backend for `code_forge`: a `ropey`-based buffer behind a `RopeBridge` opaque with
  `#[frb(sync)]` buffer methods, plus async fold/guide/word computation. Offsets cross the bridge as scalar
  (codepoint) indices and are converted to UTF-16 on the Dart side.
- `windows/` owns managed Core elevation, bootstrap authentication, temporary access grants and Job Object lifetime.

What a platform does not use, it does not compile. `interprocess` is declared under
`cfg(not(target_os = "android"))`, and `ipc/mod.rs` swaps in `ipc/unsupported.rs` there, because Android loads the Core
in-process and never opens a socket. Adding a capability follows the same shape: implement it in its own module, gate the
dependency by target, and keep the `api/` entry point unconditional so one set of bindings still serves every platform.

`RustLib.init()` runs on every platform now, not only desktop — the script engine is shared.

## Profile Script Engine

`lib/common/javascript.dart` sends the profile as JSON to `evaluate_script`, which runs `main(config)` on QuickJS and
returns the JSON the script produced. Nothing about the script runs in Dart.

- QuickJS is compiled from source for the target being built, which is what removed the prebuilt `quickjs-c-bridge`
  binaries: `flutter_js` shipped x64 Windows and desktop-only libraries, so Windows ARM64 could not start (#2361).
- `rquickjs` carries pre-generated bindings for every target this project builds except the Android ones, so Android
  builds enable its `bindgen` feature. That needs the NDK's own libclang and sysroot;
  `cargokit/build_tool/lib/src/android_environment.dart` exports `LIBCLANG_PATH` and `BINDGEN_EXTRA_CLANG_ARGS` for it,
  which is a local change to vendored Cargokit.
- Evaluation is bounded: a 10-second interrupt deadline and a memory ceiling, because a script that never returns would
  otherwise hold the profile forever. `console` is installed before the script runs, since scripts written for other
  clients log as they work.
- `rust/tests/fixtures/profile_script.js` is the compatibility regression: an overwrite written for the suite that
  performs the transform real ones perform, so it exercises `Map`/`Set`, spread, destructuring, optional chaining,
  nullish coalescing, `Object.fromEntries`, named capture groups and lookbehind in one pass. Keep it first-party and
  free of external URLs — vendoring somebody's published script here carries their attribution and their links.

## Legacy Windows Helper

`services/helper/` retains the legacy Windows service implementation and protocol tests. It is not shipped or selected on
Windows: its loopback HTTP endpoints lack caller authentication, and session IDs/hash checks do not fix that boundary.
Do not re-enable it as a fallback for failed UAC. The installer removes stale service registrations and the old executable;
this cleanup must not remove user data. Linux's separate capability-backed Helper is still used through systemd.
