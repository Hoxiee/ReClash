part of '../action.dart';

enum _SetupTaskResult { completed, handoffToCoreRestart, failed }

typedef _SetupInputs = (
  SetupState,
  PatchClashConfig,
  NetworkProps,
  SetupParams,
);

typedef BuiltProfile = ({
  String yaml,
  String md5,
  ConfigCounts counts,
  SetupBase? base,
  String webDashboardDirectory,
});

class _RunRequest {
  final bool running;
  final bool initialize;

  /// Adopts a run the Android service has, config and groups alike.
  final bool resume;
  final DateTime? previousStartTime;
  final Object? owner;

  const _RunRequest({
    required this.running,
    required this.initialize,
    required this.resume,
    required this.previousStartTime,
    required this.owner,
  });
}

@Riverpod(keepAlive: true)
class SetupAction extends _$SetupAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  Timer? _runtimeTimer;
  final _setupScheduler = SerialTaskScheduler();
  final _listenerScheduler = SerialTaskScheduler();
  _RunRequest? _latestRunRequest;
  DateTime? _startTime;
  bool _sandboxedListener = false;
  _SetupInputs? _appliedInputs;
  var _lastPushDuration = Duration.zero;
  var _pendingForceApply = false;
  var _runIntentRevision = 0;
  bool _allowPrivilegePrompt = false;
  int _privilegeIntentRevision = 0;
  String _appliedWebDashboardDirectory = '';

  int get runIntentRevision => _runIntentRevision;

  Object? get runIntentOwner => _latestRunRequest?.owner;

  bool get _isRunning => _startTime != null && _startTime!.isBeforeNow;

  @override
  void build() {
    ref.onDispose(_stopRuntimeTicker);
    ref.listen(appVisibleProvider, (_, _) => _syncRuntimeTicker());
    ref.listen(
      appSettingProvider.select((state) => state.showTrayTitle),
      (_, _) => _syncRuntimeTicker(),
    );
  }

  bool get _isTrafficShown =>
      ref.read(appVisibleProvider) ||
      (system.isMacOS &&
          !ref.read(safeModeProvider) &&
          ref.read(appSettingProvider).showTrayTitle);

  SetupParams get _setupParams {
    final selectedMap = ref.read(selectedMapProvider);
    final appSetting = ref.read(appSettingProvider);
    return SetupParams(
      selectedMap: selectedMap,
      testUrl: ref.read(patchClashConfigProvider).testUrl,
      skipCertVerify: !appSetting.checkCertificate,
      rcx: ref.read(currentRoutingLayerProvider),
    );
  }

  // The selection reaches the Core through changeProxy, not through an apply.
  SetupParams get _appliedParams =>
      _setupParams.copyWith(selectedMap: const {});

  Future<bool> fullSetup() async {
    if (!ref.read(initProvider)) return true;
    ref.read(proxiesActionProvider.notifier).cancelDelayTests();
    ref.read(delayDataSourceProvider.notifier).value = {};
    final setupResult = _sandboxSwitched
        ? _restartRunning()
        : applyProfile(force: true);
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

  /// A test subscription runs without a listener, so crossing into or out of
  /// one restarts the session rather than only reapplying the profile.
  bool get _sandboxSwitched =>
      ref.read(isStartProvider) &&
      _sandboxedListener != ref.read(sandboxProvider);

  Future<bool> _restartRunning() async {
    await setRunning(false);
    return setRunning(true, initialize: true);
  }

  void _setLocalRunning(bool running) {
    _stopRuntimeTicker();
    if (!running) {
      _startTime = null;
      debouncer.cancel(FunctionTag.applyProfile);
      _pendingForceApply = false;
      _updateRunTime();
      return;
    }

    _startTime ??= DateTime.now();
    _updateRunTime();
    _syncRuntimeTicker();
  }

  void _syncRuntimeTicker() {
    if (_startTime == null || !_isTrafficShown) {
      _stopRuntimeTicker();
      return;
    }
    if (_runtimeTimer != null) {
      return;
    }
    _refreshRunningState();
    _runtimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshRunningState(),
    );
  }

  void _stopRuntimeTicker() {
    _runtimeTimer?.cancel();
    _runtimeTimer = null;
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

  @protected
  Future<DateTime?> serviceStartTime() async => readNativeRunTime();

  @protected
  Future<DateTime?> readNativeRunTime() async => service?.getRunTime();

  Future<bool> restoreRunningState() async {
    final revision = _runIntentRevision;
    final startedAt = await readNativeRunTime();
    if (!ref.mounted || revision != _runIntentRevision || startedAt == null) {
      return false;
    }
    final options =
        ref.read(runningVpnOptionsProvider) ??
        await ref.read(vpnOptionsProvider.future);
    if (!ref.mounted || revision != _runIntentRevision) return false;
    _startTime = startedAt;
    ref.read(runningVpnOptionsProvider.notifier).value = options;
    _setLocalRunning(true);
    return true;
  }

  Future<void> initStatus() async {
    if (!globalState.needInitStatus) {
      return;
    }
    final revision = _runIntentRevision;
    final startedAt = await serviceStartTime();
    if (!ref.mounted || revision != _runIntentRevision) return;
    _startTime = startedAt;
    if (_isRunning) {
      final md5 = await preferences.getAppliedConfigMd5();
      if (!ref.mounted || revision != _runIntentRevision) return;
      globalState.lastConfigMd5 = md5;
      await _run(true, initialize: true, resume: true);
    } else if (ref.read(appSettingProvider).autoRun) {
      await setRunning(true, initialize: true);
    } else {
      await globalState.safeRun(() => applyProfile(force: true));
    }
  }

  Future<bool> setRunning(
    bool running, {
    bool initialize = false,
    bool silence = false,
    Object? owner,
    bool allowPrompt = false,
  }) {
    if (running && !initialize && !ref.read(initProvider)) {
      return Future.value(true);
    }
    return _run(
      running,
      initialize: running && initialize,
      silence: silence,
      owner: owner,
      allowPrompt: allowPrompt,
    );
  }

  Future<bool> _run(
    bool running, {
    required bool initialize,
    bool resume = false,
    bool allowPrompt = false,
    bool silence = false,
    Object? owner,
  }) {
    _runIntentRevision++;
    if (running) {
      _allowPrivilegePrompt |= allowPrompt;
    } else {
      _privilegeIntentRevision++;
      _allowPrivilegePrompt = false;
      _core.revokePrivilegePrompt();
      if (system.isDesktop &&
          ref.read(coreStatusProvider) == CoreStatus.connecting) {
        unawaited(ref.read(coreActionProvider.notifier).cancelCoreStart());
      }
    }
    final request = _RunRequest(
      running: running,
      initialize: initialize,
      resume: resume,
      previousStartTime: _startTime,
      owner: owner,
    );
    _latestRunRequest = request;
    _setLocalRunning(running);
    if (request.initialize) {
      globalState.needInitStatus = false;
    }
    return running ? _start(request, silence: silence) : _stop(request);
  }

  Future<bool> _start(_RunRequest request, {required bool silence}) async {
    if (request.initialize) {
      var applied = false;
      try {
        applied = await applyProfile(
          force: !request.resume,
          silence: silence,
          suppressErrors: silence,
          preloadInvoke: () => _startCoreRunning(request),
        );
      } catch (_) {
        if (silence) {
          _rollbackRunning(request);
          if (request.previousStartTime == null && _isCurrent(request)) {
            await setRunning(false, silence: true, owner: request.owner);
          }
          rethrow;
        }
        applied = false;
      }
      if (!applied && _isCurrent(request)) {
        if (silence && request.previousStartTime != null) {
          _rollbackRunning(request);
        } else if (silence) {
          await setRunning(false, silence: true, owner: request.owner);
        } else {
          await globalState.safeRun(
            () => setRunning(false, owner: request.owner),
          );
        }
      }
      return applied;
    }

    try {
      await _startCoreRunning(request);
    } catch (_) {
      _rollbackRunning(request);
      rethrow;
    }
    final applied = await inputsApplied();
    if (_isCurrent(request) && !applied) {
      applyProfileDebounce(force: true, silence: true);
    }
    return true;
  }

  Future<void> _startCoreRunning(_RunRequest request) async {
    if (!await _setCoreRunning(request) && _isCurrent(request)) {
      throw _unanswered(CoreMethod.startListener);
    }
  }

  Future<bool> _stop(_RunRequest request) async {
    final bool answered;
    try {
      answered = await _setCoreRunning(request);
    } catch (_) {
      _rollbackRunning(request);
      rethrow;
    }
    if (!_isCurrent(request)) {
      return true;
    }
    ref.read(onDemandOverrideProvider.notifier).clear();
    resetCoreTraffic();
    ref.read(trafficsProvider.notifier).clear();
    ref.read(totalTrafficProvider.notifier).value = const Traffic();
    // A silent Core is gone or hung; running again would proxy traffic to it.
    if (!answered) {
      throw _unanswered(CoreMethod.stopListener);
    }
    return true;
  }

  Future<bool> _setCoreRunning(_RunRequest request) {
    return _listenerScheduler.run(() async {
      if (!_isCurrent(request)) {
        return true;
      }
      if (ref.read(safeModeProvider)) {
        return true;
      }
      if (request.resume) {
        final options = await ref.read(vpnOptionsProvider.future);
        if (ref.mounted && _isCurrent(request)) {
          ref.read(runningVpnOptionsProvider.notifier).value = options;
        }
        return true;
      }
      return _setListening(request);
    });
  }

  Future<bool> _setListening(_RunRequest request) async {
    final running = request.running;
    final vpnOptions = await ref.read(vpnOptionsProvider.future);
    if (!ref.mounted || !_isCurrent(request)) return true;
    final answered = await setCoreRunning(running);
    if (!ref.mounted || !_isCurrent(request)) return true;
    ref.read(runningVpnOptionsProvider.notifier).value = running && answered
        ? vpnOptions
        : null;
    if (!running && ref.mounted) {
      ref.read(tunAppliedProvider.notifier).value = false;
    }
    if (running && answered && !system.isAndroid && ref.read(suspendProvider)) {
      final vpn = ref.read(vpnSettingProvider);
      final paused = await setOnDemandPause(
        true,
        fullStop: vpn.onDemandFullStop,
      );
      if (!paused) throw _unanswered(CoreMethod.setOnDemandPaused);
      if (vpn.onDemandCloseConnections) await _core.closeConnections();
    }
    return answered;
  }

  Future<void> _syncTunApplied() async {
    if (!system.isDesktop || ref.read(safeModeProvider)) return;
    final info = await _core.getCoreInfo();
    if (!ref.mounted) return;
    ref.read(tunAppliedProvider.notifier).value = info?.tunActive ?? false;
    if (ref.read(isStartProvider) &&
        !ref.read(suspendProvider) &&
        _effectivePatchConfig(ref.read(patchClashConfigProvider)).tun.enable &&
        info?.tunActive != true) {
      throw const DesktopPrivilegeException('tun_not_ready');
    }
  }

  CoreMethodException _unanswered(CoreMethod method) => CoreMethodException(
    code: 'no_response',
    message: 'Core did not answer ${method.name}',
  );

  void syncSuspend() {
    debouncer.call(FunctionTag.suspend, () {
      return _listenerScheduler.run(() async {
        if (!ref.read(isStartProvider) || ref.read(safeModeProvider)) {
          return;
        }
        if (system.isAndroid) return;
        final paused = ref.read(suspendProvider);
        final vpn = ref.read(vpnSettingProvider);
        final answered = await setOnDemandPause(
          paused,
          fullStop: vpn.onDemandFullStop,
        );
        if (!answered) throw _unanswered(CoreMethod.setOnDemandPaused);
        if (paused && vpn.onDemandCloseConnections) {
          await _core.closeConnections();
        }
        await _syncTunApplied();
      });
    });
  }

  Future<void> restartVpn() async {
    if (!ref.read(isStartProvider)) {
      return;
    }
    await setRunning(false);
    await setRunning(true);
  }

  void _rollbackRunning(_RunRequest request) {
    if (!_isCurrent(request)) {
      return;
    }
    _startTime = request.previousStartTime;
    _setLocalRunning(_startTime != null);
  }

  bool _isCurrent(_RunRequest request) => identical(_latestRunRequest, request);

  Future<void> updateConfigDebounce() async {
    debouncer.call(FunctionTag.updateConfig, updateConfig);
  }

  @protected
  Future<bool> setCoreRunning(bool running) async {
    if (running && ref.read(sandboxProvider)) {
      return _sandboxedListener = true;
    }
    if (!running && _sandboxedListener) {
      _sandboxedListener = false;
      return true;
    }
    return running ? _core.startListener() : _core.stopListener();
  }

  @protected
  Future<bool> setOnDemandPause(bool paused, {required bool fullStop}) =>
      _core.setOnDemandPaused(paused, fullStop: fullStop);

  @protected
  void resetCoreTraffic() {
    _core.resetTraffic();
  }

  @visibleForTesting
  Future<void> updateConfig() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) return;
    await globalState.safeRun(() async {
      final patchConfig = ref.read(patchClashConfigProvider);
      final shouldContinueSetup = await requestAdmin(patchConfig.tun.enable);
      if (!shouldContinueSetup) {
        await _restartCoreAfterAuthorization();
        return;
      }
      final networkSetting = ref.read(networkSettingProvider);
      final message = await _core.updateConfig(
        _effectivePatchConfig(patchConfig).toUpdateParams(
          authentication: networkSetting.authentication.credentials,
          skipCertVerify: !ref.read(appSettingProvider).checkCertificate,
        ),
      );
      if (message.isNotEmpty) throw MessageException(message);
      await _syncTunApplied();
    });
  }

  @protected
  Duration get minApplyDebounce => const Duration(seconds: 2);

  /// A push held up by a rule-set download or a Core timeout says little
  /// about the load, yet would hold back every apply after it.
  @protected
  Duration get maxApplyDebounce => const Duration(seconds: 10);
  Future<bool> prepareWebDashboard() async {
    if (ref.read(safeModeProvider) ||
        ref.read(coreStatusProvider) != CoreStatus.connected ||
        ref.read(currentProfileIdProvider) == null) {
      return false;
    }
    final directory = await webDashboardServedDirectory(
      await appPath.homeDirPath,
    );
    if (directory.isEmpty) return false;
    if (_appliedInputs != null && _appliedWebDashboardDirectory == directory) {
      return true;
    }
    return applyProfile(silence: true);
  }

  Future<void> syncWebDashboardAccess() async {
    if (!ref.mounted || ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    final message = await _setupScheduler.run(() async {
      if (!ref.mounted ||
          ref.read(coreStatusProvider) != CoreStatus.connected) {
        return '';
      }
      return _core.updateConfig(
        _effectivePatchConfig(
          ref.read(patchClashConfigProvider),
        ).toUpdateParams(
          authentication: ref
              .read(networkSettingProvider)
              .authentication
              .credentials,
          skipCertVerify: !ref.read(appSettingProvider).checkCertificate,
        ),
      );
    });
    if (message.isNotEmpty) {
      throw const WebDashboardException(WebDashboardFailure.apply);
    }
  }

  void applyProfileDebounce({bool silence = false, bool force = false}) {
    _pendingForceApply |= force;
    debouncer.call(
      FunctionTag.applyProfile,
      (silence) {
        final force = _pendingForceApply;
        _pendingForceApply = false;
        applyProfile(silence: silence, force: force);
      },
      args: [silence],
      duration: Duration(
        microseconds: _lastPushDuration.inMicroseconds.clamp(
          minApplyDebounce.inMicroseconds,
          maxApplyDebounce.inMicroseconds,
        ),
      ),
    );
  }

  /// A mode the user picks wins over a scenario's until they pick Auto.
  void changeMode(Mode mode) {
    if (!ref.read(availableModesProvider).contains(mode)) return;
    if (ref.read(rcxStatusStateProvider)?.autoMode ?? false) {
      unawaited(
        ref.read(rcxRoutingActionProvider.notifier).setManualMode(true),
      );
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: mode));
    if (mode == Mode.global) {
      ref
          .read(proxiesActionProvider.notifier)
          .updateCurrentGroupName(GroupName.GLOBAL.name);
    }
  }

  /// For leaving an editor: a profile whose inputs match the config the Core
  /// already runs is not rebuilt, which on a large profile takes a while.
  void autoApplyProfile() {
    runAfterFrame(() async {
      if (!await inputsApplied()) {
        await applyProfile();
      }
    });
  }

  void applyIfGlobalRulesUsed() {
    final profile = ref.read(currentProfileProvider);
    if (profile == null ||
        profile.type == ProfileType.custom ||
        profile.extendType != ExtendType.standard) {
      return;
    }
    applyProfileDebounce(silence: true);
  }

  /// Whether the Core runs what the current profile and settings make now.
  Future<bool> inputsApplied() async {
    final applied = _appliedInputs;
    if (applied == null) {
      return false;
    }
    final profileId = ref.read(currentProfileIdProvider);
    final SetupState setupState;
    try {
      setupState = await ref.read(setupStateProvider(profileId).future);
    } catch (_) {
      return false;
    }
    return applied ==
        (
          setupState,
          _effectivePatchConfig(ref.read(patchClashConfigProvider)),
          ref.read(networkSettingProvider),
          _appliedParams,
        );
  }

  // False means building the profile, the config write, or the Core setup
  // step failed; a profile that fails to build is still pushed to the Core
  // as the empty config so it never keeps serving the previous one.
  // authorizeCore failures still throw.
  Future<bool> applyProfile({
    bool silence = false,
    bool suppressErrors = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    final result = await _runSetup(
      force: force,
      silence: silence,
      suppressErrors: suppressErrors,
      preloadInvoke: preloadInvoke,
    );
    return result != _SetupTaskResult.failed;
  }

  Future<_SetupTaskResult> _runSetup({
    bool silence = false,
    bool suppressErrors = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    final result = await _setupScheduler.run(() {
      return _setupConfig(
        force: force,
        silence: silence,
        suppressErrors: suppressErrors,
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
    // Release the current serial task before restartCore reapplies the profile.
    final restarted = await _restartCoreAfterAuthorization(
      silence: suppressErrors,
    );
    return restarted ? _SetupTaskResult.completed : _SetupTaskResult.failed;
  }

  Future<bool> _restartCoreAfterAuthorization({bool silence = false}) async {
    try {
      return await ref
          .read(coreActionProvider.notifier)
          .restartCore(silence: silence);
    } catch (_) {
      ref.read(authorizedTunEnableProvider.notifier).value =
          TunAuthorizationState.none;
      rethrow;
    }
  }

  /// With a base, [BuiltProfile.yaml] is only the overlay the Core applies.
  Future<BuiltProfile> getProfile({
    required SetupState setupState,
    required PatchClashConfig patchConfig,
  }) async {
    final profileId = setupState.profileId;
    if (profileId == null) {
      return (
        yaml: '',
        md5: '',
        counts: configCountsOf(const {}),
        base: null,
        webDashboardDirectory: '',
      );
    }
    final defaultUA = globalState.packageInfo.ua;
    final networkSetting = ref.read(
      networkSettingProvider.select(
        (state) => (
          appendSystemDns: state.appendSystemDns,
          bypassPrivateRoute: state.bypassPrivateRoute,
          authentication: state.authentication,
        ),
      ),
    );
    final appendSystemDns = networkSetting.appendSystemDns;
    final isCustom = setupState.profileType == ProfileType.custom;
    final scriptContent =
        !isCustom && setupState.extendType == ExtendType.script
        ? await setupState.script?.content
        : null;
    final hasScript = scriptContent?.isNotEmpty == true;
    final profileBase = !isCustom && !hasScript
        ? await _core.getProfileBase(profileId)
        : null;
    Map<String, dynamic> rawConfig = isCustom
        ? {
            'proxies': appProxiesPayload(
              setupState.appProxies,
              dialers: setupState.proxyDialers,
              groups: setupState.proxyGroups,
            ),
          }
        : profileBase?.base.config ?? await _core.getConfig(profileId);
    final proxyGroups = isCustom ? setupState.proxyGroups : <ProxyGroup>[];
    final rules = isCustom ? setupState.rules : <Rule>[];
    if (hasScript) {
      rawConfig = await handleEvaluate(scriptContent!, rawConfig);
    }
    if (ref.read(sandboxProvider)) {
      rawConfig = withSandboxNodes(rawConfig);
    }
    final directory = await appPath.profilesPath;
    final webDashboardDirectory = await webDashboardServedDirectory(
      await appPath.homeDirPath,
    );
    final injected = await _resolveInjectedProviders(
      setupState,
      proxyGroups: proxyGroups,
      rules: rules,
    );
    final res = await makeRealProfileTask(
      MakeRealProfileState(
        rules: rules,
        proxyGroups: proxyGroups,
        injectedProxyProviders: injected.proxies,
        injectedRuleProviders: injected.rules,
        profilesPath: directory,
        profileId: profileId,
        rawConfig: rawConfig,
        realPatchConfig: patchConfig,
        overrides: setupState.overrides,
        bypassPrivateRoute: networkSetting.bypassPrivateRoute,
        keepEmptyDnsOverrides: setupState.profileType != ProfileType.custom,
        appendSystemDns: appendSystemDns,
        addedRules: setupState.addedRules,
        defaultUA: defaultUA,
        authentication: networkSetting.authentication.credentials,
        matchTarget:
            profileBase == null ||
                setupState.matchTarget?.trim().isNotEmpty == true
            ? setupState.matchTarget
            : lastMatchTarget(profileBase.base.matchRules),
        safeMode: ref.read(safeModeProvider) || ref.read(sandboxProvider),
        webDashboardDirectory: webDashboardDirectory,
      ),
    );
    if (profileBase == null) {
      return (
        yaml: res.yaml,
        md5: res.md5,
        counts: res.counts,
        base: null,
        webDashboardDirectory: webDashboardDirectory,
      );
    }
    final (:base, :path) = profileBase;
    return (
      yaml: res.yaml,
      md5: '${res.md5}${base.digest}'.toMd5(),
      counts: (
        groups: res.counts.groups + base.proxyGroups,
        proxies: res.counts.proxies + base.proxies,
        rules: res.counts.rules + base.rules,
      ),
      base: SetupBase(path: path, overlay: res.yaml),
      webDashboardDirectory: webDashboardDirectory,
    );
  }

  /// Only what the custom profile actually references is injected, so an
  /// app-level provider costs nothing in the profiles that never name it.
  Future<({Map<String, dynamic> proxies, Map<String, dynamic> rules})>
  _resolveInjectedProviders(
    SetupState setupState, {
    required List<ProxyGroup> proxyGroups,
    required List<Rule> rules,
  }) async {
    final usedProxyProviders = <String>{
      for (final proxyGroup in proxyGroups) ...?proxyGroup.use,
    };
    final usedRuleProviders = <String>{
      for (final rule in rules) ...rule.ruleSets,
      if (setupState.profileType == ProfileType.custom)
        ...setupState.overrides.ruleSets,
    };
    if (usedProxyProviders.isEmpty && usedRuleProviders.isEmpty) {
      return (
        proxies: const <String, dynamic>{},
        rules: const <String, dynamic>{},
      );
    }
    final options = setupState.overrides.proxyProviders;
    final proxies = <String, dynamic>{};
    for (final entry in setupState.profileProviders.entries) {
      if (!usedProxyProviders.contains(entry.key)) {
        continue;
      }
      proxies[entry.key] = {
        'type': 'file',
        'path': await appPath.getProfilePath(entry.value.toString()),
        ...?options[entry.key]?.definition,
      };
    }
    final clashProvidersAction = ref.read(
      clashProvidersActionProvider.notifier,
    );
    final ruleProviders = <String, dynamic>{};
    for (final provider in setupState.clashProviders) {
      if (!usedRuleProviders.contains(provider.label)) {
        continue;
      }
      final prepared = await clashProvidersAction.prepare(provider);
      ruleProviders[prepared.label] = prepared.definition(
        await prepared.corePath,
      );
    }
    return (proxies: proxies, rules: ruleProviders);
  }

  Future<String> getProfileWithId(int profileId) async {
    try {
      final setupState = await ref.read(setupStateProvider(profileId).future);
      final patchClashConfig = ref.read(patchClashConfigProvider);
      final res = await getProfile(
        setupState: setupState,
        patchConfig: patchClashConfig,
      );
      return switch (res.base) {
        final base? => await _core.buildProfile(base),
        null => res.yaml,
      };
    } catch (e) {
      dialogs.showNotifier(e.toString(), level: MessageLevel.error);
    }
    return '';
  }

  PatchClashConfig _effectivePatchConfig(PatchClashConfig patchConfig) {
    if (ref.read(safeModeProvider)) {
      return patchConfig.copyWith(
        tun: patchConfig.tun.copyWith(enable: false),
        externalController: ExternalControllerStatus.close,
      );
    }
    patchConfig = webDashboardEffectiveConfig(
      patchConfig,
      temporarySecret: ref.read(webDashboardAccessProvider).temporarySecret,
      safeMode: false,
    );
    final authorized =
        system.isAndroid ||
        (isPrivilegedCoreOwner(_core.processOwner) &&
            ref.read(authorizedTunEnableProvider) ==
                TunAuthorizationState.authorized);
    return patchConfig.copyWith(
      tun: patchConfig.tun.copyWith(
        enable: patchConfig.tun.enable && authorized,
      ),
      externalController: patchConfig.secret.isEmpty
          ? ExternalControllerStatus.close
          : patchConfig.externalController,
    );
  }

  Future<void> setTunEnabled(bool enabled) async {
    _privilegeIntentRevision++;
    _allowPrivilegePrompt = enabled;
    if (!enabled) {
      _core.revokePrivilegePrompt();
      ref.read(tunPrivilegeSetupProvider.notifier).clear();
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith.tun(enable: enabled));
    await updateConfig();
  }

  @protected
  Future<DesktopPrivilegeDecision> preparePrivilege({
    required bool tunEnabled,
    required bool allowPrompt,
  }) =>
      _core.preparePrivilege(tunEnabled: tunEnabled, allowPrompt: allowPrompt);

  @visibleForTesting
  Future<bool> requestAdmin(bool enableTun, {bool silence = false}) async {
    if (ref.read(safeModeProvider)) return true;
    if (!enableTun) {
      _allowPrivilegePrompt = false;
      _core.configurePrivilege(tunEnabled: false);
      return true;
    }
    if (system.isAndroid) {
      ref.read(authorizedTunEnableProvider.notifier).value =
          TunAuthorizationState.authorized;
      return true;
    }
    final revision = _runIntentRevision;
    final privilegeRevision = _privilegeIntentRevision;
    final allowPrompt = _allowPrivilegePrompt;
    _allowPrivilegePrompt = false;
    final decision = await preparePrivilege(
      tunEnabled: enableTun,
      allowPrompt: allowPrompt,
    );
    if (decision == DesktopPrivilegeDecision.active && ref.mounted) {
      ref.read(tunPrivilegeSetupProvider.notifier).clear();
    }
    if (!ref.mounted ||
        revision != _runIntentRevision ||
        privilegeRevision != _privilegeIntentRevision) {
      _core.revokePrivilegePrompt();
      return true;
    }
    final notifier = ref.read(authorizedTunEnableProvider.notifier);
    switch (decision) {
      case DesktopPrivilegeDecision.notRequired:
        return true;
      case DesktopPrivilegeDecision.active:
        notifier.value = TunAuthorizationState.authorized;
        return true;
      case DesktopPrivilegeDecision.restartRequired:
        notifier.value = TunAuthorizationState.unauthorized;
        return false;
      case DesktopPrivilegeDecision.authorizationRequired:
        notifier.value = TunAuthorizationState.unauthorized;
        unawaited(_requestPrivilegeSetup(explicit: allowPrompt));
        return true;
    }
  }

  @protected
  Future<DesktopPrivilegeSetup> inspectPrivilege() =>
      _core.inspectPrivilege(tunEnabled: true);

  Future<void> _requestPrivilegeSetup({required bool explicit}) async {
    final DesktopPrivilegeSetup setup;
    try {
      setup = await inspectPrivilege();
    } catch (error) {
      commonPrint.log(
        'TUN setup inspection failed: $error',
        logLevel: LogLevel.warning,
      );
      return;
    }
    if (!ref.mounted || !ref.read(patchClashConfigProvider).tun.enable) return;
    switch (setup) {
      case DesktopPrivilegeSetup.install ||
          DesktopPrivilegeSetup.update ||
          DesktopPrivilegeSetup.approval ||
          DesktopPrivilegeSetup.unavailable:
        ref
            .read(tunPrivilegeSetupProvider.notifier)
            .request(setup, explicit: explicit);
      case DesktopPrivilegeSetup.notRequired ||
          DesktopPrivilegeSetup.active ||
          DesktopPrivilegeSetup.ready:
        break;
    }
  }

  /// Runs what the TUN setup prompt confirmed, installing or updating the
  /// Helper or service, and moves the Core onto it. Returns the failure that
  /// kept TUN off, or null once the privileged Core runs.
  Future<Object?> authorizeTun() async {
    ref.read(tunPrivilegeSetupProvider.notifier).clear();
    _core.allowPrivilegeInstall();
    final coreAction = ref.read(coreActionProvider.notifier);
    try {
      await coreAction.restartCore(silence: true, allowPrompt: true);
    } catch (error) {
      return error;
    }
    if (!ref.mounted) return null;
    final failure = coreAction.takePrivilegeFailure();
    if (failure != null) return failure;
    if (!isPrivilegedCoreOwner(_core.processOwner)) {
      return const DesktopPrivilegeException('authorization_required');
    }
    return null;
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
    bool suppressErrors = false,
    Future<void> Function()? preloadInvoke,
    FutureOr Function()? onUpdated,
  }) async {
    var profile = ref.read(currentProfileProvider) ?? recoverMissingProfile();
    Future<Profile?> refreshProfile() async =>
        await profile?.checkAndUpdateAndCopy(
          validate: (path, key) => _core.validateProfile(path, key),
          defaultUserAgent: globalState.ua,
          decrypt: _core.decryptProfilePayload,
        );
    final nextProfile = suppressErrors
        ? await refreshProfile()
        : await globalState.safeRun(refreshProfile);
    if (nextProfile != null) {
      profile = nextProfile;
      final profiles = ref.read(profilesProvider.notifier);
      if (suppressErrors) {
        await profiles.putAndWait(nextProfile);
      } else {
        profiles.put(nextProfile);
      }
    }
    commonPrint.log('setup ===> ${profile?.realLabel}');
    final patchConfig = ref.read(patchClashConfigProvider);
    final shouldContinueSetup = await requestAdmin(
      patchConfig.tun.enable,
      silence: suppressErrors,
    );
    if (!shouldContinueSetup) {
      return _SetupTaskResult.handoffToCoreRestart;
    }
    final pushWatch = Stopwatch();
    final realPatchConfig = _effectivePatchConfig(patchConfig);
    final networkSetting = ref.read(networkSettingProvider);
    SetupState? setupState;
    Future<BuiltProfile> buildProfile() async {
      final state = await ref.read(setupStateProvider(profile?.id).future);
      setupState = state;
      return getProfile(setupState: state, patchConfig: realPatchConfig);
    }

    final realProfile = suppressErrors
        ? await buildProfile()
        : await globalState.safeRun(buildProfile, title: 'build profile');
    final profileFailed = realProfile == null;
    final setupParams = _setupParams.copyWith(base: realProfile?.base);
    final inputs = switch (setupState) {
      final state? when !profileFailed => (
        state,
        realPatchConfig,
        networkSetting,
        _appliedParams,
      ),
      _ => null,
    };
    final yamlString = realProfile?.yaml ?? '';
    final yamlMd5 = realProfile?.md5 ?? '';
    if (!profileFailed && yamlMd5 == globalState.lastConfigMd5 && !force) {
      _appliedInputs = inputs;
      globalState.lastConfigCounts = realProfile.counts;
      await preloadInvoke?.call();
      _appliedWebDashboardDirectory = realProfile.webDashboardDirectory;
      return _SetupTaskResult.completed;
    }
    // Go answers a config it rejects by running its built-in default, which
    // has no proxies, so until this push succeeds no applied config is known.
    _appliedInputs = null;
    _appliedWebDashboardDirectory = '';
    globalState.lastConfigMd5 = null;
    globalState.lastConfigCounts = null;
    if (system.isAndroid) {
      await ref.read(vpnOptionsProvider.future);
      await preferences.saveShareState(ref.read(sharedStateProvider));
      await preferences.saveAppliedConfigMd5(null);
    }
    // Recaptured so _start's catch can roll back after safeRun swallows it.
    (Object, StackTrace)? handoffFailure;
    var setupFailed = false;
    Future<void> pushProfile() async {
      try {
        if (setupParams.base == null) {
          final configFilePath = await appPath.configFilePath;
          await File(configFilePath).writeAsStringAtomically(yamlString);
        }
        final profileId = profile?.id;
        if (profileId != null) {
          await appPath.ensureProviderDirs(profileId);
        }
        final String message;
        pushWatch.start();
        try {
          message = await _core.setupConfig(
            params: setupParams,
            preloadInvoke: preloadInvoke,
          );
        } finally {
          pushWatch.stop();
        }
        if (message.isNotEmpty) {
          globalState.lastConfigCounts = configCountsOf(const {});
          if (suppressErrors) {
            await onUpdated?.call();
          } else {
            await globalState.safeRun(() => onUpdated?.call());
          }
          throw MessageException(message);
        }
      } catch (e, s) {
        setupFailed = true;
        if (preloadInvoke != null) {
          handoffFailure = (e, s);
        }
        rethrow;
      }
      await _syncTunApplied();
      _appliedWebDashboardDirectory = realProfile?.webDashboardDirectory ?? '';
      globalState.lastConfigMd5 = yamlMd5;
      globalState.lastConfigCounts =
          realProfile?.counts ?? configCountsOf(const {});
      _appliedInputs = inputs;
      if (system.isAndroid) {
        await preferences.saveAppliedConfigMd5(yamlMd5);
      }
      await onUpdated?.call();
    }

    if (suppressErrors) {
      await pushProfile();
    } else {
      await globalState.loadingRun(
        pushProfile,
        silence: true,
        tag: !silence ? LoadingTag.proxies : null,
      );
    }
    _lastPushDuration = pushWatch.elapsed;
    if (handoffFailure != null) {
      Error.throwWithStackTrace(handoffFailure!.$1, handoffFailure!.$2);
    }
    if (setupFailed || profileFailed) {
      return _SetupTaskResult.failed;
    }
    return _SetupTaskResult.completed;
  }
}
