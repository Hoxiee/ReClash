part of '../action.dart';

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  CoreController get _core => ref.read(coreHandlerProvider);
  bool _isUpdatingTraffic = false;
  int _toggleRequestRevision = 0;
  bool? _pendingToggleRunning;

  @override
  void build() {}

  void toggleRunning() {
    unawaited(
      setRunning(!(_pendingToggleRunning ?? ref.read(isStartProvider))),
    );
  }

  Future<void> setRunning(bool running) async {
    _pendingToggleRunning = running;
    final requestRevision = ++_toggleRequestRevision;
    if (!running &&
        system.isDesktop &&
        ref.read(coreStatusProvider) == CoreStatus.connecting) {
      unawaited(ref.read(coreActionProvider.notifier).cancelCoreStart());
    }
    final setupAction = ref.read(setupActionProvider.notifier);
    final runIntentRevision = setupAction.runIntentRevision;
    await globalState.safeRun(() async {
      try {
        if (running && ref.read(coreStatusProvider) != CoreStatus.connected) {
          final started = await ref
              .read(coreActionProvider.notifier)
              .startCore(allowPrompt: true);
          if (!started ||
              requestRevision != _toggleRequestRevision ||
              setupAction.runIntentRevision != runIntentRevision) {
            return;
          }
        }
        if (requestRevision != _toggleRequestRevision) return;
        final initialize = running && !ref.read(initProvider);
        final applied = await setupAction.setRunning(
          running,
          initialize: initialize,
          allowPrompt: running,
        );
        if (applied &&
            running &&
            initialize &&
            requestRevision == _toggleRequestRevision) {
          ref.read(initProvider.notifier).value = true;
        }
      } finally {
        if (requestRevision == _toggleRequestRevision) {
          _pendingToggleRunning = null;
        }
      }
    });
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

  UpdateChannel _updateChannel() {
    final setting = ref.read(appSettingProvider).updateChannel;
    return effectiveUpdateChannel(
      configured: setting,
      isPreBuild: globalState.isPre,
    );
  }

  Future<void> checkForUpdates() async {
    if (ref.read(loadingProvider(LoadingTag.checkUpdate))) return;
    final result = await globalState.loadingRun(
      () async {
        try {
          return (
            release: await request.checkForUpdate(channel: _updateChannel()),
            error: null,
          );
        } catch (error) {
          return (release: null, error: error);
        }
      },
      title: currentAppLocalizations.checkUpdate,
      tag: LoadingTag.checkUpdate,
    );
    if (result == null || !ref.mounted) return;
    if (result.error != null) {
      await _showUpdateCheckFailure();
      return;
    }
    await checkUpdateResultHandle(data: result.release, isUser: true);
  }

  Future<bool> autoCheckUpdate() async {
    if (!ref.read(appSettingProvider).autoCheckUpdate) return false;
    final AppUpdateRelease? release;
    try {
      release = await request.checkForUpdate(channel: _updateChannel());
    } catch (error) {
      commonPrint.log(
        'checkForUpdate failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
    await checkUpdateResultHandle(data: release);
    return release != null;
  }

  Future<void> _showUpdateCheckFailure() async {
    await dialogs.showMessage(
      title: currentAppLocalizations.checkUpdate,
      message: TextSpan(text: currentAppLocalizations.updateCheckFailed),
      cancelable: false,
    );
  }

  Future<void> checkUpdateResultHandle({
    AppUpdateRelease? data,
    bool isUser = false,
  }) async {
    if (data == null) {
      if (isUser) {
        await dialogs.showMessage(
          title: currentAppLocalizations.checkUpdate,
          message: TextSpan(text: currentAppLocalizations.updateNoUpdates),
          cancelable: false,
        );
      }
      return;
    }
    final context = globalState.navigatorKey.currentContext;
    if (context == null) {
      commonPrint.log(
        'skip update offer: no navigator context',
        logLevel: LogLevel.warning,
      );
      return;
    }
    final updater = ref.read(appUpdateActionProvider.notifier);
    final result = await UpdateOfferDialog.show(
      context,
      release: data,
      currentVersion: globalState.packageInfo.version,
      primaryLabel: updater.isSupported
          ? currentAppLocalizations.installUpdate
          : currentAppLocalizations.goDownload,
      skipLabel: isUser ? null : currentAppLocalizations.noLongerRemind,
    );
    if (result == true) {
      if (updater.isSupported) {
        unawaited(updater.install(data));
      } else {
        unawaited(
          dialogs.openUrl(data.source.releasePage(data.tag).toString()),
        );
      }
    } else if (!isUser && result == false) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(autoCheckUpdate: false));
    }
  }
}
