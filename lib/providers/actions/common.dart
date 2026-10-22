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
    if (ref.read(isStartProvider) && ref.read(suspendProvider)) {
      unawaited(ref.read(onDemandOverrideProvider.notifier).setPaused(false));
      return;
    }
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
    final mode = ref.read(effectiveModeProvider);
    ref
        .read(setupActionProvider.notifier)
        .changeMode(Mode.values[(mode.index + 1) % Mode.values.length]);
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

  /// Opens the sheet on [context]'s navigator, the root's when the check
  /// starts with no page behind it, and completes with the check itself.
  Future<void> checkForUpdates([BuildContext? context]) async {
    final checking = ref.read(appUpdateActionProvider.notifier).check();
    final origin = context ?? globalState.navigatorKey.currentContext;
    if (origin != null && origin.mounted) {
      unawaited(UpdateSheet.show(origin));
    }
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
    if (context != null && context.mounted) await UpdateSheet.show(context);
  }
}
