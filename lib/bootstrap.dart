import 'dart:async';
import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:reclash/common/app/boot_guard.dart';
import 'package:reclash/common/app/boot_record.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/desktop/launch.dart';
import 'package:reclash/common/app/migration.dart';
import 'package:reclash/common/app/permission.dart';
import 'package:reclash/common/subscription/subscription_reminder.dart';
import 'package:reclash/common/desktop/tray.dart';
import 'package:reclash/common/desktop/window.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/navigation.dart';
import 'package:reclash/views/views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum StartupOutcome { completed, exitRequested }

@visibleForTesting
class StartupCoordinator {
  const StartupCoordinator();

  Future<StartupOutcome> run({
    required Future<void> Function() startCore,
    required Future<bool> Function() handleFailedPreference,
    required Future<void> Function() handleSetupWizard,
    required Future<bool> Function() handleDisclaimer,
    required Future<void> Function() showCrashRecoveryTip,
    required Future<void> Function() showCrashlyticsTip,
    required Future<void> Function() initializeRuntime,
    required Future<void> Function() applyWindowVisibility,
    required void Function() startOptionalEffects,
    bool showWindowBeforeRuntime = false,
  }) async {
    if (!await handleFailedPreference()) return StartupOutcome.exitRequested;
    final coreStart = startCore();
    await handleSetupWizard();
    if (!await handleDisclaimer()) {
      await coreStart;
      return StartupOutcome.exitRequested;
    }
    await showCrashRecoveryTip();
    await showCrashlyticsTip();
    await coreStart;
    if (showWindowBeforeRuntime) await applyWindowVisibility();
    await initializeRuntime();
    if (!showWindowBeforeRuntime) await applyWindowVisibility();
    startOptionalEffects();
    return StartupOutcome.completed;
  }
}

class Bootstrap {
  static Bootstrap? _instance;

  Bootstrap._internal();

  factory Bootstrap() {
    _instance ??= Bootstrap._internal();
    return _instance!;
  }

  BootDecision _bootDecision = const BootDecision();

  Future<ProviderContainer> init(int version) async {
    globalState.appEnv = const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'pre',
    );
    windowPort = window;
    trayPort = appTray;
    navigationPort = navigation;
    final dynamicColor = await _initDynamicColor();
    unawaited(registerAppLicenses());
    // Before anything can spawn the core or trigger TUN authorization: on a
    // read-only install the sudo prompt must target the writable copy, and
    // the spawn must not race the copy either.
    await appPath.ensureWritableCore();
    return _initData(version, dynamicColor);
  }

  Future<DynamicColorSeeds> _initDynamicColor() async {
    TonalPalette? primaryPalette;
    Color? accentColor;
    try {
      primaryPalette = await _getSystemPrimaryPalette();
    } catch (error) {
      commonPrint.log(
        'Failed to get core palette: $error',
        logLevel: LogLevel.warning,
      );
    }
    try {
      accentColor = await DynamicColorPlugin.getAccentColor();
    } catch (error) {
      commonPrint.log(
        'Failed to get accent color: $error',
        logLevel: LogLevel.warning,
      );
    }
    return (
      lightSeed: primaryPalette != null ? Color(primaryPalette.get(40)) : null,
      darkSeed: primaryPalette != null ? Color(primaryPalette.get(80)) : null,
      accentColor: accentColor ?? const Color(defaultPrimaryColor),
    );
  }

  Future<TonalPalette?> _getSystemPrimaryPalette() async {
    final raw = await DynamicColorPlugin.channel.invokeMethod<List<dynamic>>(
      DynamicColorPlugin.methodName,
    );
    if (raw == null || raw.length < TonalPalette.commonSize) {
      return null;
    }
    return TonalPalette.fromList(
      raw.sublist(0, TonalPalette.commonSize).cast<int>(),
    );
  }

  Future<ProviderContainer> _initData(
    int version,
    DynamicColorSeeds dynamicColor,
  ) async {
    globalState.packageInfo = releasePackageInfo(
      await PackageInfo.fromPlatform(),
    );
    var config = await migration.run();
    _bootDecision = await bootGuard.evaluate(
      profileId: config.currentProfileId,
      crashlyticsEnabled: config.appSettingProps.crashlytics,
    );
    if (_bootDecision.recovery == BootRecovery.clearProfile) {
      config = config.copyWith(currentProfileId: null);
      await preferences.saveConfig(config);
    }
    final appState = AppState(
      brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      version: version,
      viewSize: Size.zero,
      requests: FixedList(maxRequestsLength),
      logs: FixedList(maxLogsLength),
      traffics: FixedList(trafficSampleLength),
      totalTraffic: const Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    final appStateOverrides = buildAppStateOverrides(appState);
    final configOverrides = buildConfigOverrides(config);
    final regionSignals = await app?.getRegionSignals() ?? const RegionSignals();
    final container = ProviderContainer(
      overrides: [
        ...appStateOverrides,
        ...configOverrides,
        regionSignalsProvider.overrideWithValue(regionSignals),
      ],
    );
    globalState.container = container;
    container
        .read(dynamicColorProvider.notifier)
        .seed(
          lightSeed: dynamicColor.lightSeed,
          darkSeed: dynamicColor.darkSeed,
          accentColor: dynamicColor.accentColor,
        );
    final profiles = await database.profilesDao.query().get();
    container.read(profilesProvider.notifier).setAndReorder(profiles);
    final effectiveLocale =
        getLocaleForString(config.appSettingProps.locale) ??
        WidgetsBinding.instance.platformDispatcher.locale;
    await AppLocalizations.load(effectiveLocale);
    seedRegionIfUnset(container.read, regionSignals, effectiveLocale);
    await window?.init(version, config.windowProps);
    if (system.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    return container;
  }

  Future<void> attach() async {
    if (globalState.isAttach == true) {
      return;
    }
    final outcome = await _initApp();
    if (outcome == StartupOutcome.completed) {
      globalState.isAttach = true;
    }
  }

  ProviderContainer get _container => globalState.container;

  Future<StartupOutcome> _initApp() {
    return const StartupCoordinator().run(
      startCore: () async {
        await _container.read(coreActionProvider.notifier).startCore();
      },
      handleFailedPreference: _handleFailedPreference,
      handleSetupWizard: _handleSetupWizard,
      handleDisclaimer: _handleDisclaimer,
      showCrashRecoveryTip: _showCrashRecoveryTip,
      showCrashlyticsTip: _showCrashlyticsTip,
      initializeRuntime: _initializeRuntime,
      applyWindowVisibility: _applyWindowVisibility,
      startOptionalEffects: _startOptionalEffects,
      showWindowBeforeRuntime: system.isLinux,
    );
  }

  Future<void> _initializeRuntime() async {
    if (!_bootDecision.isDegraded) {
      await _container.read(setupActionProvider.notifier).initStatus();
    }
    _container.read(initProvider.notifier).value = true;
    await bootGuard.markRunning();
  }

  Future<void> _applyWindowVisibility() async {
    if (_container.read(appSettingProvider).silentLaunch) {
      await windowPort?.hide();
    } else {
      await windowPort?.show();
    }
  }

  void _startOptionalEffects() {
    unawaited(_container.read(systemActionProvider.notifier).updateTray());
    unawaited(
      _container.read(profilesActionProvider.notifier).autoUpdateProfiles(),
    );
    unawaited(_container.read(commonActionProvider.notifier).autoCheckUpdate());
    unawaited(
      autoLaunch?.updateStatus(_container.read(appSettingProvider).autoLaunch),
    );
    if (system.isAndroid) {
      unawaited(
        app?.setIconVariant(_container.read(appSettingProvider).iconVariant),
      );
    }
    unawaited(
      runSubscriptionReminderSweep(
        profiles: _container.read(profilesProvider),
        enabled: _container
            .read(appSettingProvider)
            .notificationSettings
            .subscriptionReminders,
      ),
    );
    permissions.check(_container.read);
  }

  Future<void> _showMandatoryUi() async {
    await windowPort?.show();
  }

  /// A degraded launch already tells the user the previous run did not finish;
  /// a first-run wizard on top of that reads as lost data.
  Future<void> _handleSetupWizard() async {
    if (_bootDecision.isDegraded || !_container.read(needsSetupProvider)) {
      return;
    }
    final context = globalState.navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    await _showMandatoryUi();
    // The wizard can hold the screen for minutes and sends the user to system
    // settings, so a kill here is not a failed launch; the guard stays armed
    // for the runtime that follows.
    await bootGuard.markSetup();
    try {
      if (!context.mounted) return;
      await SetupWizard.show(context);
    } finally {
      await bootGuard.markStarting();
      await _container.read(storeActionProvider.notifier).savePreferences();
    }
  }

  Future<void> _showCrashRecoveryTip() async {
    switch (_bootDecision.recovery) {
      case BootRecovery.none:
        return;
      case BootRecovery.skipAutoSetup:
        await _showMandatoryUi();
        await dialogs.showMessage(
          title: currentAppLocalizations.launchInterrupted,
          cancelable: false,
          dismissible: false,
          message: TextSpan(text: currentAppLocalizations.launchInterruptedTip),
        );
      case BootRecovery.clearProfile:
        await _showMandatoryUi();
        await dialogs.showMessage(
          title: currentAppLocalizations.crashDetected,
          cancelable: false,
          dismissible: false,
          message: TextSpan(
            text: currentAppLocalizations.crashDetectedTip(_failedProfileLabel),
          ),
        );
    }
  }

  String get _failedProfileLabel {
    final profileId = _bootDecision.failedProfileId;
    if (profileId == null) {
      return '';
    }
    final profile = _container.read(profilesProvider).getProfile(profileId);
    return profile?.label.takeFirstValid(['$profileId']) ?? '$profileId';
  }

  Future<bool> _handleFailedPreference() async {
    if (await preferences.isInit) return true;
    await _showMandatoryUi();
    final res = await dialogs.showMessage(
      title: currentAppLocalizations.tip,
      message: TextSpan(text: currentAppLocalizations.cacheCorrupt),
    );
    if (res == true) {
      final file = File(await appPath.sharedPreferencesPath);
      await file.safeDelete();
    }
    // Saving here would rewrite the preferences file the user just chose to delete.
    await _container.read(systemActionProvider.notifier).handleExit(false);
    return false;
  }

  Future<void> _showCrashlyticsTip() async {
    if (!system.isAndroid) return;
    if (_container.read(
      appSettingProvider.select((state) => state.crashlyticsTip),
    )) {
      return;
    }
    await _showMandatoryUi();
    await dialogs.showMessage(
      title: currentAppLocalizations.dataCollectionTip,
      cancelable: false,
      message: TextSpan(text: currentAppLocalizations.dataCollectionContent),
    );
    _container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(crashlyticsTip: true));
  }

  Future<bool> _handleDisclaimer() async {
    if (_container.read(
      appSettingProvider.select((state) => state.disclaimerAccepted),
    )) {
      return true;
    }
    await _showMandatoryUi();
    final isDisclaimerAccepted = await dialogs.showDisclaimer();
    if (!isDisclaimerAccepted) {
      await _container.read(systemActionProvider.notifier).handleExit();
      return false;
    }
    _container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(disclaimerAccepted: true));
    return true;
  }
}

final bootstrap = Bootstrap();
