part of '../action.dart';

@Riverpod(keepAlive: true)
class SystemAction extends _$SystemAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  SystemExitCoordinator? _exitCoordinator;
  bool _resetPrepared = false;

  @override
  void build() {}

  Future<List<Package>> getPackages() async {
    ref.read(packagesProvider.notifier).value = await app?.getPackages() ?? [];
    return ref.read(packagesProvider);
  }

  void applyRegion(String? code) {
    final regionCode = sanitizeRegionCode(code);
    final next = withRegionDefaults(
      from: ref.read(appSettingProvider).regionCode,
      to: regionCode,
      patchConfig: ref.read(patchClashConfigProvider),
      bypassDomain: ref.read(networkSettingProvider).bypassDomain,
    );
    ref.read(patchClashConfigProvider.notifier).value = next.patchConfig;
    ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(bypassDomain: next.bypassDomain));
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(regionCode: regionCode));
  }

  Future<List<String>> getDomesticPackageNames(String regionCode) async {
    return await app?.getDomesticPackageNames(regionCode) ?? [];
  }

  Future<bool> isInstalledAppsPermissionGranted() async {
    return await app?.isInstalledAppsPermissionGranted() ?? true;
  }

  Future<bool> requestInstalledAppsPermission() async {
    return await app?.requestInstalledAppsPermission() ?? false;
  }

  Future<void> handleExit([bool needSave = true]) {
    ref.read(webDashboardActionProvider.notifier).cancel();
    ref.read(webDashboardAccessProvider.notifier).end();
    final coordinator = _exitCoordinator ??= SystemExitCoordinator(
      watchdogDuration: exitWatchdogDuration,
      closeWindow: closeWindow,
      closeCore: closeCore,
      exitApplication: exitApplication,
    );
    return coordinator.exit(cleanup: () => cleanupExitResources(needSave));
  }

  Future<void> resetAllDataAndExit() async {
    if (!_resetPrepared) {
      final stopped = await _core.stop();
      if (stopped.outcome == CoreLifecycleOutcome.superseded) {
        throw StateError('Core stop was superseded');
      }
      await cleanupExitResources(false);
      await closeCore();
      _resetPrepared = true;
    }
    await disableAutoLaunch();
    await deleteAllData();
    await handleExit(false);
  }

  @protected
  Future<void> disableAutoLaunch() async {
    await disableAutoLaunchPort?.call();
  }

  @protected
  Future<void> deleteAllData() => clearAppData(all: true);

  @protected
  Duration get exitWatchdogDuration => const Duration(seconds: 3);

  @protected
  Future<void> cleanupExitResources(bool needSave) async {
    final saveOperation = needSave ? _savePreferencesSafely() : null;
    final tray = trayPort;
    if (tray != null) {
      await tray.shutdown().onError<Object>((error, stackTrace) {
        commonPrint.log(
          'Tray shutdown failed: ${compactError(error)}',
          logLevel: LogLevel.error,
        );
      });
    }
    await Future.wait([
      ?saveOperation,
      bootGuard.markClosed(),
      if (systemDnsCoordinator != null) systemDnsCoordinator!.shutdown(),
      ?systemProxyQueue?.close(),
    ]);
  }

  Future<void> _savePreferencesSafely() async {
    try {
      await savePreferences();
    } catch (error) {
      commonPrint.log(
        'Preferences save failed: ${compactError(error)}',
        logLevel: LogLevel.error,
      );
    }
  }

  @protected
  Future<void> savePreferences() async {
    final port = windowPort;
    if (port != null) {
      try {
        final current = ref.read(windowSettingProvider);
        final geometry = await port.captureNormalGeometry(current);
        if (geometry != null) {
          ref.read(windowSettingProvider.notifier).value = geometry;
        }
      } catch (error) {
        commonPrint.log(
          'Window geometry capture failed: ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
      }
    }
    await preferences.saveConfig(ref.read(configProvider));
  }

  @protected
  Future<void> closeWindow() async {
    await windowPort?.close();
  }

  @protected
  Future<void> closeCore() async {
    await _core.close();
    commonPrint.log('exit');
  }

  @protected
  Future<void> exitApplication() async {
    await system.exit();
    windowPort?.forceExit();
  }

  Future<void> handleClose([bool exit = true]) async {
    if (ref.read(appSettingProvider).minimizeOnExit || !exit) {
      if (system.isDesktop) {
        await _savePreferencesSafely();
      }
      await system.back();
      await windowPort?.hide();
    } else {
      await handleExit();
    }
  }

  Future<void> updateVisible() async {
    await windowPort?.toggle();
  }

  Future<void> updateTun() => ref
      .read(setupActionProvider.notifier)
      .setTunEnabled(!ref.read(patchClashConfigProvider).tun.enable);

  void updateSystemProxy() {
    ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(systemProxy: !state.systemProxy));
  }

  Future<void> copyProxyEnv() async {
    final port = ref.read(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    await Clipboard.setData(
      ClipboardData(text: proxyEnvCommand(port, isWindows: system.isWindows)),
    );
  }

  void updateAutoLaunch() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(autoLaunch: !state.autoLaunch));
  }

  Future<void> updateTray() async {
    await trayPort?.update(
      trayState: ref.read(trayStateProvider),
      traffic: ref.read(
        trafficsProvider.select(
          (state) => state.list.safeLast(const Traffic()),
        ),
      ),
      read: globalState.container.read,
    );
  }

  Future<void> updateLocalIp() async {
    ref.read(localIpProvider.notifier).value = null;
    await Future.delayed(commonDuration);
    ref.read(localIpProvider.notifier).value = await getLocalIpAddress();
  }
}
