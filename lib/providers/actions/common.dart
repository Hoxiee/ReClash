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

  Future<void> checkForUpdates() async {
    final context = globalState.navigatorKey.currentContext;
    if (context == null) return;
    final action = ref.read(appUpdateActionProvider.notifier);
    final checking = action.check();
    await UpdateSheet.show(context);
    await checking;
  }

  Future<bool> autoCheckUpdate() async {
    if (!ref.read(appSettingProvider).autoCheckUpdate) return false;
    await ref.read(appUpdateActionProvider.notifier).check(automatic: true);
    return ref.read(appUpdateActionProvider).hasUpdate;
  }

  Future<void> checkUpdateResultHandle({
    AppUpdateRelease? data,
    bool isUser = false,
  }) async {
    final action = ref.read(appUpdateActionProvider.notifier);
    if (data == null) {
      if (!isUser) return;
      action.noUpdates();
    } else {
      await action.offer(data, automatic: !isUser);
    }
    if (!isUser) return;
    final context = globalState.navigatorKey.currentContext;
    if (context != null) await UpdateSheet.show(context);
  }
}
