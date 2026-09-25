part of '../action.dart';

enum _SetupTaskResult { completed, handoffToCoreRestart, aborted, failed }

class _RunRequest {
  final bool running;
  final bool initialize;
  final DateTime? previousStartTime;

  const _RunRequest({
    required this.running,
    required this.initialize,
    required this.previousStartTime,
  });
}

@Riverpod(keepAlive: true)
class SetupAction extends _$SetupAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  Timer? _runtimeTimer;
  bool _runtimeUpdatesEnabled = true;
  final _setupScheduler = SerialTaskScheduler();
  final _listenerScheduler = SerialTaskScheduler();
  _RunRequest? _latestRunRequest;
  DateTime? _startTime;
  Future<bool?>? _authorizationAttempt;
  int? _authorizationAttemptRevision;
  Future<bool>? _authorizationRestart;
  int _authorizationRevision = 0;
  bool _authorizationPromptAllowed = false;
  bool _disposed = false;
  bool _notificationPermissionRequested = false;
  LinuxHelperInstallResult? _linuxInstallResult;
  String? _authorizationProblem;

  void beginTunAuthorization({bool allowPrompt = true}) {
    _authorizationRevision++;
    _authorizationPromptAllowed = allowPrompt;
  }

  bool _authorizationIsCurrent(int revision) =>
      !_disposed && revision == _authorizationRevision;

  bool get _isRunning => _startTime != null && _startTime!.isBeforeNow;

  @override
  void build() {
    ref.onDispose(() {
      _disposed = true;
      _authorizationRevision++;
      _runtimeTimer?.cancel();
      _runtimeTimer = null;
    });
  }

  SetupParams get _setupParams {
    final selectedMap = ref.read(selectedMapProvider);
    final testUrl = ref.read(
      appSettingProvider.select((state) => state.testUrl),
    );
    return SetupParams(selectedMap: selectedMap, testUrl: testUrl);
  }

  Future<bool> fullSetup() async {
    if (!ref.read(initProvider)) return true;
    ref.read(proxiesActionProvider.notifier).cancelDelayTests();
    ref.read(delayDataSourceProvider.notifier).value = {};
    final setupResult = applyProfile(force: true);
    ref.read(logsProvider.notifier).value = FixedList(maxLogsLength);
    ref.read(requestsProvider.notifier).value = FixedList(maxRequestsLength);
    ref.read(dnsQueriesProvider.notifier).value = FixedList(
      maxDnsQueriesLength,
    );
    ref.read(dnsQueryCountProvider.notifier).value = 0;
    ref.read(requestCountProvider.notifier).value = 0;
    try {
      return await setupResult;
    } catch (e, s) {
      commonPrint.log('fullSetup ===> ${compactError(e)}, $s');
      return false;
    }
  }

  void _setLocalRunning(bool running) {
    _runtimeTimer?.cancel();
    _runtimeTimer = null;
    if (!running) {
      _startTime = null;
      debouncer.cancel(FunctionTag.applyProfile);
      _updateRunTime();
      return;
    }

    _startTime ??= DateTime.now();
    _updateRunTime();
    _syncRuntimeTimer();
  }

  void updateRuntimeActivity({
    required AppLifecycleState? lifecycleState,
    required bool isAndroid,
  }) {
    final enabled =
        !isAndroid ||
        lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed ||
        lifecycleState == AppLifecycleState.inactive;
    if (_runtimeUpdatesEnabled == enabled) {
      return;
    }
    _runtimeUpdatesEnabled = enabled;
    _syncRuntimeTimer();
  }

  void _syncRuntimeTimer() {
    _runtimeTimer?.cancel();
    _runtimeTimer = null;
    if (_startTime == null || !_runtimeUpdatesEnabled) {
      return;
    }
    _refreshRunningState();
    _runtimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshRunningState(),
    );
  }

  void _refreshRunningState() {
    _updateRunTime();
    unawaited(ref.read(commonActionProvider.notifier).updateTraffic());
  }

  void _updateRunTime() {
    final startTime = _startTime;
    ref.read(runTimeProvider.notifier).value = startTime == null
        ? null
        : DateTime.now().millisecondsSinceEpoch -
              startTime.millisecondsSinceEpoch;
  }

  Future<void> _updateStartTime() async {
    _startTime = await service?.getRunTime();
  }

  Future<void> initStatus() async {
    if (!globalState.needInitStatus) {
      commonPrint.log('init status cancel');
      return;
    }
    commonPrint.log('init status');
    if (requiresHelperSession) {
      beginTunAuthorization(
        allowPrompt: !ref.read(appSettingProvider).silentLaunch,
      );
    }
    if (system.isAndroid) {
      await _updateStartTime();
    }
    final shouldRun = _isRunning || ref.read(appSettingProvider).autoRun;
    if (shouldRun) {
      await setRunning(true, initialize: true);
    } else {
      await globalState.safeRun(() => applyProfile(force: true));
    }
  }

  Future<bool> setRunning(bool running, {bool initialize = false}) {
    if (!running) beginTunAuthorization(allowPrompt: false);
    if (running && !initialize && !ref.read(initProvider)) {
      return Future.value(true);
    }

    final request = _RunRequest(
      running: running,
      initialize: running && initialize,
      previousStartTime: _startTime,
    );
    _latestRunRequest = request;
    final requestRevision = ref
        .read(runRequestStateProvider.notifier)
        .begin(running);
    if (running && !request.initialize) {
      ref.read(connectionDoctorProvider.notifier).resetForTunnelSession();
    }
    _setLocalRunning(running);
    if (request.initialize) {
      globalState.needInitStatus = false;
    }
    final operation = running ? _start(request) : _stop(request);
    return operation.whenComplete(
      () => ref.read(runRequestStateProvider.notifier).finish(requestRevision),
    );
  }

  // Android 14+ crashes the core service if its foreground notification cannot be
  // posted, so grant POST_NOTIFICATIONS a chance before the service starts. Asked
  // once per session and never blocking: a deliberate refusal still starts the tunnel.
  Future<void> _ensureNotificationPermission() async {
    if (!system.isAndroid || _notificationPermissionRequested) return;
    _notificationPermissionRequested = true;
    if (await app?.isNotificationsPermissionGranted() ?? true) return;
    await app?.requestNotificationsPermission();
  }

  Future<bool> _start(_RunRequest request) async {
    await _ensureNotificationPermission();
    if (request.initialize ||
        (requiresHelperSession &&
            ref.read(patchClashConfigProvider).tun.enable)) {
      var applied = false;
      try {
        applied = await applyProfile(
          force: true,
          preloadInvoke: () => _setCoreRunning(request),
        );
      } catch (_) {
        applied = false;
      }
      if (!applied && _isCurrent(request)) {
        await globalState.safeRun(() => setRunning(false));
      }
      return applied;
    }

    try {
      await _setCoreRunning(request);
    } catch (_) {
      _rollbackRunning(request);
      rethrow;
    }
    if (_isCurrent(request)) {
      applyProfileDebounce(force: true, silence: true);
    }
    return true;
  }

  Future<bool> _stop(_RunRequest request) async {
    try {
      await _setCoreRunning(request);
    } catch (_) {
      _rollbackRunning(request);
      rethrow;
    }
    if (!_isCurrent(request)) {
      return true;
    }
    resetCoreTraffic();
    ref.read(trafficsProvider.notifier).clear();
    ref.read(totalTrafficProvider.notifier).value = const Traffic();
    ref.read(checkIpNumProvider.notifier).add();
    return true;
  }

  Future<void> _setCoreRunning(_RunRequest request) {
    return _listenerScheduler.run(() async {
      if (!_isCurrent(request)) {
        return;
      }
      // A start request that lands on a paused Android service would resume
      // it, so the already-running service is left paused.
      if (request.running && system.isAndroid && ref.read(pausedProvider)) {
        return;
      }
      _signalOdometerIntent(request.running);
      final applied = await setCoreRunning(request.running);
      if (!applied && _isCurrent(request)) {
        if (request.running) {
          ref
              .read(runRequestStateProvider.notifier)
              .markFault(RunRequestFault.ingressBlocked);
        }
        throw MessageException(currentAppLocalizations.doctorIngressTitle);
      }
      if (request.running && _isCurrent(request)) {
        final profileId = ref.read(currentProfileIdProvider);
        if (profileId != null) {
          ref.read(profilesActionProvider.notifier).markProfileUsed(profileId);
        }
      }
    });
  }

  String? _odometerStartReason() {
    final reason = bootGuard.decision.exitReason;
    if (reason == AppExitReason.packageUpdated) return 'update';
    if (reason == AppExitReason.lowMemory) return 'lowMemory';
    if (reason?.isCrash == true) return 'crash';
    return null;
  }

  void _signalOdometerIntent(bool running) {
    final signal = OdometerSignal(
      running ? OdometerSignalKind.prepareUp : OdometerSignalKind.prepareDown,
      reason: running ? _odometerStartReason() : 'user',
    );
    unawaited(
      Future<bool>.sync(() => _core.signalOdometer(signal)).then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          commonPrint.log(
            'odometer signal skipped: $error',
            logLevel: LogLevel.warning,
          );
        },
      ),
    );
  }

  void _rollbackRunning(_RunRequest request) {
    if (!_isCurrent(request)) {
      return;
    }
    _startTime = request.previousStartTime;
    _setLocalRunning(!request.running);
  }

  bool _isCurrent(_RunRequest request) => identical(_latestRunRequest, request);

  Future<void> updateConfigDebounce() async {
    debouncer.call(FunctionTag.updateConfig, updateConfig);
  }

  @protected
  Future<bool> setCoreRunning(bool running) {
    return running ? _core.startListener() : _core.stopListener();
  }

  @protected
  void resetCoreTraffic() {
    _core.resetTraffic();
  }

  @visibleForTesting
  Future<void> updateConfig() async {
    await globalState.safeRun(() async {
      final revision = _authorizationRevision;
      final requested = ref.read(updateParamsProvider);
      final shouldContinueSetup = await requestAdmin(requested.tun.enable);
      if (!_authorizationIsCurrent(revision) || shouldContinueSetup == null) {
        return;
      }
      if (!shouldContinueSetup) {
        await _restartCoreAfterAuthorization();
        return;
      }
      final updateParams = ref.read(updateParamsProvider);
      final message = await _core.updateConfig(
        updateParams.copyWith.tun(
          enable: _getEffectiveTunEnable(updateParams.tun.enable),
        ),
      );
      ref.read(checkIpNumProvider.notifier).add();
      if (message.isNotEmpty) throw MessageException(message);
    });
  }

  void tryCheckIp() {
    final isTimeout = ref.read(
      networkDetectionProvider.select(
        (state) => state.ipInfo == null && state.isLoading == false,
      ),
    );
    if (!isTimeout) return;
    ref.read(checkIpNumProvider.notifier).add();
  }

  void applyProfileDebounce({bool silence = false, bool force = false}) {
    debouncer.call(FunctionTag.applyProfile, (silence, force) {
      applyProfile(silence: silence, force: force);
    }, args: [silence, force]);
  }

  void changeUiMode(UiOutboundMode mode) {
    ref
        .read(smartRoutingSettingProvider.notifier)
        .update((state) => state.withEnabled(mode.smartRouting));
    changeMode(mode.coreMode);
  }

  void changeMode(Mode mode) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: mode));
    if (mode == Mode.global) {
      ref
          .read(proxiesActionProvider.notifier)
          .updateCurrentGroupName(GroupName.GLOBAL.name);
    }
  }

  void autoApplyProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyProfile();
    });
  }

  // False means building the profile, the config write, or the Core setup
  // step failed; a profile that fails to build is still pushed to the Core
  // as the empty config so it never keeps serving the previous one.
  // authorizeCore failures still throw.
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    final result = await _runSetup(
      force: force,
      silence: silence,
      preloadInvoke: preloadInvoke,
    );
    return result == _SetupTaskResult.completed;
  }

  Future<_SetupTaskResult> _runSetup({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    final revision = _authorizationRevision;
    final result = await _setupScheduler.run(() {
      if (!_authorizationIsCurrent(revision)) {
        return Future.value(_SetupTaskResult.aborted);
      }
      return _setupConfig(
        force: force,
        silence: silence,
        preloadInvoke: preloadInvoke,
        onUpdated: () async {
          await ref.read(proxiesActionProvider.notifier).updateGroups();
          await ref.read(providersProvider.notifier).syncProviders();
        },
      );
    });
    if (result != _SetupTaskResult.handoffToCoreRestart) {
      return result;
    }
    if (!_authorizationIsCurrent(revision)) return _SetupTaskResult.aborted;
    // Release the current serial task before restartCore reapplies the profile.
    final restarted = await _restartCoreAfterAuthorization();
    return restarted ? _SetupTaskResult.completed : _SetupTaskResult.failed;
  }

  Future<bool> _restartCoreAfterAuthorization() {
    final active = _authorizationRestart;
    if (active != null) return active;
    final operation = _restartAuthorizedCore();
    _authorizationRestart = operation;
    return operation.whenComplete(() => _authorizationRestart = null);
  }

  Future<bool> _restartAuthorizedCore() async {
    try {
      return await ref.read(coreActionProvider.notifier).restartCore();
    } catch (_) {
      ref.read(authorizedTunEnableProvider.notifier).value =
          TunAuthorizationState.none;
      rethrow;
    }
  }

  Future<({String yaml, String md5})> getProfile({
    required SetupState setupState,
    required PatchClashConfig patchConfig,
  }) async {
    final profileId = setupState.profileId;
    final desync = ref.read(effectiveDesyncSettingProvider);
    // Only-dpi mode is the subscription-free use of the app: no profile to
    // fetch, the whole config is synthesized from the empty map.
    if (profileId == null && !(desync.enabled && desync.onlyDpi)) {
      return (yaml: '', md5: '');
    }
    final defaultUA = globalState.packageInfo.ua;
    final networkSetting = ref.read(
      networkSettingProvider.select(
        (state) => (
          appendSystemDns: state.appendSystemDns,
          routeMode: state.routeMode,
          overrideNetwork: state.overrideSubscriptionNetwork,
          authentication: state.authentication,
        ),
      ),
    );
    final smartRouting = ref.read(
      smartRoutingSettingProvider.select((state) => state.enabled),
    );
    final configMap = profileId == null
        ? <String, dynamic>{}
        : await _core.getConfig(profileId);
    final overrideDns = ref.read(overrideDnsProvider);
    final appendSystemDns = networkSetting.appendSystemDns;
    final routeMode = networkSetting.routeMode;
    final overrideNetwork = networkSetting.overrideNetwork;
    String? scriptContent;
    final List<Rule> addedRules = [];
    final List<ProxyGroup> proxyGroups = [];
    final List<Rule> rules = [];
    if (setupState.overwriteType == OverwriteType.script) {
      scriptContent = await setupState.script?.content;
    } else if (setupState.overwriteType == OverwriteType.standard) {
      addedRules.addAll(setupState.addedRules);
    } else {
      proxyGroups.addAll(setupState.proxyGroups);
      rules.addAll(setupState.rules);
    }
    final realPatchConfig = patchConfig.copyWith(
      tun: patchConfig.tun.getRealTun(routeMode),
    );
    Map<String, dynamic> rawConfig = configMap;
    if (scriptContent?.isNotEmpty == true) {
      rawConfig = await handleEvaluate(scriptContent!, rawConfig);
    }
    final directory = await appPath.profilesPath;
    final res = makeRealProfileTask(
      MakeRealProfileState(
        rules: rules,
        proxyGroups: proxyGroups,
        profilesPath: directory,
        profileId: profileId,
        rawConfig: rawConfig,
        realPatchConfig: realPatchConfig,
        overrideDns: overrideDns,
        appendSystemDns: appendSystemDns,
        overrideNetwork: overrideNetwork,
        addedRules: addedRules,
        defaultUA: defaultUA,
        smartRouting: smartRouting,
        serviceRoutePolicies: setupState.serviceRoutePolicies,
        serviceRules: setupState.serviceRules,
        authentication: networkSetting.authentication.credentials,
        matchTarget: setupState.matchTarget,
        desync: desync.enabled,
        desyncPort: desync.port,
        desyncCategories: desync.categories,
        desyncForceTcp: desync.forceTcp,
        desyncOnly: desync.enabled && desync.onlyDpi,
      ),
    );
    return res;
  }

  Future<String> getProfileWithId(int profileId) async {
    try {
      final setupState = await ref.read(setupStateProvider(profileId).future);
      final patchClashConfig = ref.read(patchClashConfigProvider);
      final res = await getProfile(
        setupState: setupState,
        patchConfig: patchClashConfig,
      );
      return res.yaml;
    } catch (e) {
      dialogs.showNotifier(e.toString(), level: MessageLevel.error);
    }
    return '';
  }

  @protected
  bool get supportsTunElevation => !system.isMacOS;

  @protected
  bool get requiresHelperSession => system.isLinux;

  @protected
  bool get helperSessionActive => _core.processOwner == CoreProcessOwner.helper;

  @protected
  bool get rechecksTunAuthorization => system.isLinux;

  bool _getEffectiveTunEnable(bool enableTun) {
    if (!supportsTunElevation ||
        (requiresHelperSession && !helperSessionActive)) {
      return false;
    }
    final authorizationState = ref.read(authorizedTunEnableProvider);
    return enableTun && authorizationState == TunAuthorizationState.authorized;
  }

  @protected
  Future<AuthorizeCode> authorizeCore() async {
    if (!requiresHelperSession) return system.authorizeCore();
    final result = await Linux().registerWithResult();
    _linuxInstallResult = result;
    return switch (result) {
      LinuxHelperInstallResult.ready => AuthorizeCode.none,
      LinuxHelperInstallResult.installed => AuthorizeCode.success,
      _ => AuthorizeCode.error,
    };
  }

  @protected
  Future<bool> confirmTunAuthorization() async {
    await windowPort?.show();
    await WidgetsBinding.instance.endOfFrame;
    final context = globalState.navigatorKey.currentContext;
    if (context == null || !context.mounted || _disposed) return false;
    return await dialogs.showMessage(
          context: context,
          title: currentAppLocalizations.helperAuthorizationTitle,
          message: TextSpan(
            text: currentAppLocalizations.helperAuthorizationMessage,
          ),
          confirmText: currentAppLocalizations.helperAuthorizationContinue,
          cancelText: currentAppLocalizations.helperAuthorizationLater,
        ) ==
        true;
  }

  @protected
  void showTunAuthorizationError(String message) {
    dialogs.showNotifier(message, level: MessageLevel.error);
  }

  @protected
  Future<bool> checkCoreAuthorization() async {
    if (!requiresHelperSession) return system.checkIsAdmin();
    if (!system.hasSystemd()) {
      _authorizationProblem = currentAppLocalizations.helperSystemdUnavailable;
      return false;
    }
    final readiness = await system.helperReadiness();
    if (readiness == HelperReadiness.manifestMissing) {
      _authorizationProblem = currentAppLocalizations.helperCorruptTip;
    }
    return readiness == HelperReadiness.ready;
  }

  @visibleForTesting
  Future<bool?> requestAdmin(bool enableTun) async {
    if (!requiresHelperSession) return _requestAdmin(enableTun, null);
    if (!enableTun) return true;
    final revision = _authorizationRevision;
    final active = _authorizationAttempt;
    if (active != null) {
      if (_authorizationAttemptRevision == revision) return active;
      await active;
      if (!_authorizationIsCurrent(revision)) return null;
      return requestAdmin(enableTun);
    }
    final operation = _requestAdmin(enableTun, revision);
    _authorizationAttemptRevision = revision;
    final attempt = operation.whenComplete(() {
      _authorizationAttempt = null;
      _authorizationAttemptRevision = null;
    });
    _authorizationAttempt = attempt;
    return attempt;
  }

  Future<bool?> _requestAdmin(bool enableTun, int? revision) async {
    if (!enableTun) {
      return true;
    }
    if (!supportsTunElevation) {
      ref.read(authorizedTunEnableProvider.notifier).value =
          TunAuthorizationState.unauthorized;
      return true;
    }
    final authorizationState = ref.read(authorizedTunEnableProvider);
    if (authorizationState != TunAuthorizationState.none &&
        !rechecksTunAuthorization) {
      return true;
    }
    _authorizationProblem = null;
    final authorized = await checkCoreAuthorization();
    if (revision != null && !_authorizationIsCurrent(revision)) return null;
    if (authorized) {
      if (requiresHelperSession && !helperSessionActive) {
        if (authorizationState == TunAuthorizationState.authorized) {
          throw MessageException(currentAppLocalizations.helperCorruptTip);
        }
        ref.read(authorizedTunEnableProvider.notifier).value =
            TunAuthorizationState.authorized;
        return false;
      }
      ref.read(authorizedTunEnableProvider.notifier).value =
          TunAuthorizationState.authorized;
      return true;
    }

    final authorizationNotifier = ref.read(
      authorizedTunEnableProvider.notifier,
    );
    authorizationNotifier.value = TunAuthorizationState.unauthorized;

    if (revision != null) {
      if (!_authorizationPromptAllowed) return null;
      _authorizationPromptAllowed = false;
      final problem = _authorizationProblem;
      if (problem != null) {
        showTunAuthorizationError(problem);
        return null;
      }
      final confirmed = await confirmTunAuthorization();
      if (!confirmed || !_authorizationIsCurrent(revision)) return null;
    }
    _linuxInstallResult = null;
    final code = await authorizeCore();
    if (revision != null && !_authorizationIsCurrent(revision)) return null;
    final installResult = _linuxInstallResult;
    if (installResult != null && code == AuthorizeCode.error) {
      final message = switch (installResult) {
        LinuxHelperInstallResult.cancelled => null,
        LinuxHelperInstallResult.systemdUnavailable =>
          currentAppLocalizations.helperSystemdUnavailable,
        LinuxHelperInstallResult.pkexecUnavailable =>
          currentAppLocalizations.helperPkexecUnavailable,
        LinuxHelperInstallResult.agentUnavailable =>
          currentAppLocalizations.helperAgentUnavailable,
        LinuxHelperInstallResult.bundleInvalid =>
          currentAppLocalizations.helperCorruptTip,
        LinuxHelperInstallResult.notReady =>
          currentAppLocalizations.helperInstallNotReady,
        _ => currentAppLocalizations.helperInstallFailed,
      };
      if (message != null) showTunAuthorizationError(message);
      return null;
    }

    switch (code) {
      case AuthorizeCode.success:
        authorizationNotifier.value = TunAuthorizationState.authorized;
        return false;
      case AuthorizeCode.none:
        authorizationNotifier.value = TunAuthorizationState.authorized;
        return !requiresHelperSession || helperSessionActive;
      case AuthorizeCode.error:
        if (requiresHelperSession) {
          throw MessageException(currentAppLocalizations.helperCorruptTip);
        }
        return true;
    }
  }

  /// An empty profile list is left alone: it is the first-run state, and it is
  /// what the profile stream holds before its first emission.
  @visibleForTesting
  Profile? recoverMissingProfile() {
    final profileId = ref.read(currentProfileIdProvider);
    if (profileId == null) return null;
    final profiles = ref.read(profilesProvider);
    if (profiles.isEmpty) return null;
    final fallback = profiles.first;
    commonPrint.log(
      'profile $profileId is missing, falling back to ${fallback.id}',
      logLevel: LogLevel.warning,
    );
    ref.read(currentProfileIdProvider.notifier).value = fallback.id;
    return fallback;
  }

  Future<_SetupTaskResult> _setupConfig({
    bool force = false,
    bool silence = false,
    Future<void> Function()? preloadInvoke,
    FutureOr Function()? onUpdated,
  }) async {
    final revision = _authorizationRevision;
    var profile = ref.read(currentProfileProvider) ?? recoverMissingProfile();
    // A refresh failure is surfaced by safeRun; setup keeps the old profile.
    final allowDeviceIdentity = ref.read(appSettingProvider).sendDeviceIdentity;
    final nextProfile = await globalState.safeRun(
      () async => profile?.checkAndUpdateAndCopy(
        validate: (path) => _core.validateConfig(path),
        inspect: (path) => _core.inspectConfig(path),
        requestHeaders: await deviceIdentity.subscriptionHeaders(
          includeDeviceIdentity: allowDeviceIdentity,
        ),
        allowDeviceIdentityRetry: allowDeviceIdentity,
      ),
    );
    if (nextProfile != null) {
      profile = nextProfile;
      ref.read(profilesProvider.notifier).put(nextProfile);
    }
    commonPrint.log('setup ===> ${profile?.realLabel}');
    if (!_authorizationIsCurrent(revision)) return _SetupTaskResult.aborted;
    final requestedTun = ref.read(patchClashConfigProvider).tun.enable;
    final shouldContinueSetup = preloadInvoke == null
        ? await requestAdmin(requestedTun)
        : await globalState.safeRun(() => requestAdmin(requestedTun));
    if (!_authorizationIsCurrent(revision) || shouldContinueSetup == null) {
      return _SetupTaskResult.aborted;
    }
    if (!shouldContinueSetup) {
      return _SetupTaskResult.handoffToCoreRestart;
    }
    final patchConfig = ref.read(patchClashConfigProvider);
    final effectiveTunEnable = _getEffectiveTunEnable(patchConfig.tun.enable);
    final realPatchConfig = patchConfig.copyWith.tun(
      enable: effectiveTunEnable,
    );
    final realProfile = await globalState.safeRun(() async {
      final setupState = await ref.read(setupStateProvider(profile?.id).future);
      return getProfile(setupState: setupState, patchConfig: realPatchConfig);
    }, title: 'build profile');
    if (!_authorizationIsCurrent(revision)) return _SetupTaskResult.aborted;
    final profileFailed = realProfile == null;
    final yamlString = realProfile?.yaml ?? '';
    final yamlMd5 = realProfile?.md5 ?? '';
    if (!profileFailed && yamlMd5 == globalState.lastConfigMd5 && !force) {
      return _SetupTaskResult.completed;
    }
    if (system.isAndroid) {
      globalState.lastVpnState = ref.read(vpnStateProvider);
      final sharedState = ref.read(sharedStateProvider);
      await preferences.saveShareState(sharedState);
    }
    // Recaptured so _start's catch can roll back after safeRun swallows it.
    (Object, StackTrace)? handoffFailure;
    var setupFailed = false;
    await globalState.loadingRun(
      () async {
        try {
          final configFilePath = await appPath.configFilePath;
          await File(configFilePath).safeWriteAsString(yamlString);
          final profileId = profile?.id;
          if (profileId != null) {
            await appPath.ensureProviderDirs(profileId);
          }
          if (!_authorizationIsCurrent(revision)) return;
          final message = await _core.setupConfig(
            params: _setupParams,
            preloadInvoke: preloadInvoke,
          );
          if (message.isNotEmpty) {
            throw MessageException(message);
          }
        } catch (e, s) {
          setupFailed = true;
          if (preloadInvoke != null) {
            handoffFailure = (e, s);
          }
          rethrow;
        }
        globalState.lastConfigMd5 = yamlMd5;
        ref.read(checkIpNumProvider.notifier).add();
        await onUpdated?.call();
      },
      silence: true,
      tag: !silence ? LoadingTag.proxies : null,
    );
    if (handoffFailure != null) {
      Error.throwWithStackTrace(handoffFailure!.$1, handoffFailure!.$2);
    }
    if (!_authorizationIsCurrent(revision)) return _SetupTaskResult.aborted;
    if (setupFailed || profileFailed) {
      return _SetupTaskResult.failed;
    }
    return _SetupTaskResult.completed;
  }
}
