part of '../action.dart';

/// Throttles the startup update check so a frequently relaunched app does not
/// hit the releases API every cold start. A manual check bypasses this.
bool shouldRunAutoUpdateCheck(int lastCheckedAtMillis, DateTime now) {
  if (lastCheckedAtMillis <= 0) return true;
  return now.millisecondsSinceEpoch - lastCheckedAtMillis >=
      autoUpdateCheckInterval.inMilliseconds;
}

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  CoreHandlerInterface get _core => ref.read(coreHandlerProvider);
  bool _isUpdatingTraffic = false;

  @override
  void build() {}

  void toggleRunning() {
    final running = !ref.read(isStartProvider);
    final setup = ref.read(setupActionProvider.notifier);
    setup.beginTunAuthorization(allowPrompt: running);
    unawaited(
      globalState.safeRun(
        () => ref
            .read(setupActionProvider.notifier)
            .setRunning(
              running,
              initialize: running && !ref.read(initProvider),
            ),
      ),
    );
  }

  void togglePaused() {
    final paused = ref.read(pausedProvider);
    if (!paused && !ref.read(isStartProvider)) {
      return;
    }
    if (system.isAndroid) {
      final core = ref.read(coreHandlerProvider);
      unawaited(
        globalState.safeRun(
          () async => paused ? core.resumeTun() : core.pauseTun(),
        ),
      );
      return;
    }
    final anchor = ref.read(networkAnchorProvider);
    final notifier = ref.read(manualPauseProvider.notifier);
    paused ? notifier.resume(anchor) : notifier.pause(anchor);
  }

  void updateSpeedStatistics() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  void updateMode() {
    ref.read(patchClashConfigProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) return state;
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  Future<void> updateTraffic() async {
    if (_isUpdatingTraffic) {
      return;
    }
    _isUpdatingTraffic = true;
    try {
      final onlyStatisticsProxy = ref.read(
        appSettingProvider.select((state) => state.onlyStatisticsProxy),
      );
      final [traffic, totalTraffic] = await Future.wait([
        _readTraffic(() => _core.getTraffic(onlyStatisticsProxy)),
        _readTraffic(() => _core.getTotalTraffic(onlyStatisticsProxy)),
      ]);
      if (traffic != null) {
        ref.read(trafficsProvider.notifier).addTraffic(traffic);
      }
      if (totalTraffic != null) {
        ref.read(totalTrafficProvider.notifier).value = totalTraffic;
      }
    } finally {
      _isUpdatingTraffic = false;
    }
  }

  Future<Traffic?> _readTraffic(Future<Traffic> Function() request) async {
    try {
      return await request();
    } catch (error) {
      commonPrint.log(
        'updateTraffic error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  Future<bool> autoCheckUpdate() async {
    if (!ref.read(appSettingProvider).autoCheckUpdate) return false;
    // First-run update prompts belong to the setup gate; a dialog here would
    // land on top of the wizard and strand it.
    if (ref.read(needsSetupProvider)) return false;
    final now = DateTime.now();
    if (!shouldRunAutoUpdateCheck(
      await preferences.getLastUpdateCheckAt(),
      now,
    )) {
      return false;
    }
    final Map<String, dynamic>? res;
    try {
      res = await request.checkForUpdate(
        acceptPrereleases: ref.read(appSettingProvider).acceptPrereleaseUpdates,
      );
    } catch (error) {
      // A failed check must not stamp the throttle, or a transient outage hides
      // updates for a full interval.
      commonPrint.log(
        'autoCheckUpdate failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
    await preferences.saveLastUpdateCheckAt(now.millisecondsSinceEpoch);
    await checkUpdateResultHandle(data: res);
    return res != null;
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool isUser = false,
  }) async {
    if (data != null) {
      final context = globalState.navigatorKey.currentContext;
      if (context == null) {
        commonPrint.log(
          'skip update offer: no navigator context',
          logLevel: LogLevel.warning,
        );
        return;
      }
      final updater = ref.read(appUpdateActionProvider.notifier);
      final choice = await UpdateOfferScreen.show(
        context,
        release: data,
        primaryLabel: updater.isSupported
            ? currentAppLocalizations.installUpdate
            : currentAppLocalizations.goDownload,
        // A manual check offers only install plus back; an automatic one adds
        // the mute so a repeated prompt can be turned off.
        skipLabel: isUser ? null : currentAppLocalizations.noLongerRemind,
      );
      switch (choice) {
        case UpdateOfferChoice.install:
          unawaited(
            updater.isSupported
                ? updater.install(data)
                : launchUrl(
                    Uri.parse(
                      'https://github.com/$repository/releases/latest',
                    ),
                  ),
          );
        case UpdateOfferChoice.skip:
          if (!isUser) {
            ref
                .read(appSettingProvider.notifier)
                .update((state) => state.copyWith(autoCheckUpdate: false));
          }
        case UpdateOfferChoice.dismiss:
          break;
      }
    } else if (isUser) {
      unawaited(
        dialogs.showMessage(
          title: currentAppLocalizations.checkUpdate,
          message: TextSpan(text: currentAppLocalizations.checkUpdateError),
        ),
      );
    }
  }
}
