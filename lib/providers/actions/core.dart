part of '../action.dart';

@Riverpod(keepAlive: true)
class CoreAction extends _$CoreAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  int _requestedRestartRevision = 0;
  Future<bool>? _restartOperation;
  bool _restartSilence = false;
  int _launchRevision = 0;

  @override
  void build() {
    ref.listen(coreStatusProvider, (_, status) {
      if (status != CoreStatus.connected) {
        ref.read(authorizedTunEnableProvider.notifier).value =
            TunAuthorizationState.none;
        ref.read(tunAppliedProvider.notifier).value = false;
      }
    });
  }

  void _configureLaunch({bool allowPrompt = false}) {
    _core.configurePrivilege(
      tunEnabled:
          ref.read(patchClashConfigProvider).tun.enable &&
          !ref.read(safeModeProvider),
      allowPrompt: allowPrompt,
    );
  }

  Future<void> cancelCoreStart() async {
    _launchRevision++;
    _core.revokePrivilegePrompt();
    final result = await _core.stop();
    if (!ref.mounted || result.outcome == CoreLifecycleOutcome.superseded) {
      return;
    }
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
  }

  Future<void> initCore() async {
    final isInit = await _core.isInit;

    final version = ref.read(versionProvider);
    if (!isInit) {
      final res = await _core.init(version);
      commonPrint.log('init result: $res');
    } else {
      await ref.read(proxiesActionProvider.notifier).updateGroups();
      await ref.read(providersProvider.notifier).syncProviders();
    }
  }

  Future<bool> startCore({
    bool silence = false,
    bool allowPrompt = false,
  }) async {
    final revision = ++_launchRevision;
    _configureLaunch(allowPrompt: allowPrompt);
    ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    try {
      final result = await startLifecycle();
      if (revision != _launchRevision || !ref.mounted) return false;
      return await _applyLifecycleResult(result, launchRevision: revision);
    } catch (error) {
      _core.revokePrivilegePrompt();
      if (revision != _launchRevision || !ref.mounted) return false;
      ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      if (!silence) {
        dialogs.showNotifier(
          userFacingErrorMessage(error, currentAppLocalizations),
          level: MessageLevel.error,
        );
      }
      if (silence) rethrow;
      return false;
    }
  }

  @protected
  Future<CoreLifecycleResult> startLifecycle() {
    return _core.start();
  }

  @protected
  Future<CoreLifecycleResult> restartLifecycle() {
    return _core.restart();
  }

  Future<bool> _applyLifecycleResult(
    CoreLifecycleResult result, {
    bool statusFirst = false,
    required int launchRevision,
  }) async {
    if (!ref.mounted ||
        launchRevision != _launchRevision ||
        result.outcome == CoreLifecycleOutcome.superseded) {
      return false;
    }
    if (statusFirst) {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await initCore();
    } else {
      await initCore();
      if (!ref.mounted || launchRevision != _launchRevision) return false;
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    }
    if (!ref.mounted || launchRevision != _launchRevision) return false;
    ref
        .read(authorizedTunEnableProvider.notifier)
        .value = system.isAndroid || isPrivilegedCoreOwner(_core.processOwner)
        ? TunAuthorizationState.authorized
        : TunAuthorizationState.none;
    return true;
  }

  Future<void> closeConnection(String id) async {
    await _core.closeConnection(id);
  }

  Future<void> closeConnections() async {
    await _core.closeConnections();
  }

  Future<void> clearDnsCacheOnNetworkChange() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    try {
      await _core.clearDnsCache();
    } catch (error) {
      commonPrint.log(
        'clearDnsCache error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  Future<void> requestGc() async {
    await _core.requestGc();
  }

  Future<void> crash() async {
    await _core.crash();
  }

  Future<bool> restartCore({bool silence = false, bool allowPrompt = false}) {
    _configureLaunch(allowPrompt: allowPrompt);
    _restartSilence |= silence;
    _requestedRestartRevision++;
    final activeOperation = _restartOperation;
    if (activeOperation != null) {
      return activeOperation;
    }

    final operation = _runRestartWorker();
    _restartOperation = operation;
    return operation;
  }

  Future<bool> _runRestartWorker() async {
    final launchRevision = ++_launchRevision;
    try {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      final result = await restartLifecycle();
      if (!ref.mounted || launchRevision != _launchRevision) return false;
      if (!await _applyLifecycleResult(
        result,
        statusFirst: true,
        launchRevision: launchRevision,
      )) {
        return false;
      }

      var appliedRevision = 0;
      var applied = true;
      while (appliedRevision < _requestedRestartRevision) {
        if (!ref.mounted || launchRevision != _launchRevision) return false;
        final revision = _requestedRestartRevision;
        final setupAction = ref.read(setupActionProvider.notifier);
        if (ref.read(isStartProvider)) {
          applied = await setupAction.setRunning(
            true,
            initialize: true,
            silence: _restartSilence,
            owner: setupAction.runIntentOwner,
          );
        } else {
          applied = await setupAction.applyProfile(
            force: true,
            silence: _restartSilence,
            suppressErrors: _restartSilence,
          );
        }
        appliedRevision = revision;
      }
      return applied;
    } catch (_) {
      _core.revokePrivilegePrompt();
      if (!ref.mounted || launchRevision != _launchRevision) return false;
      ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      rethrow;
    } finally {
      _restartOperation = null;
      _restartSilence = false;
    }
  }
}
