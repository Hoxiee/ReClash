import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/service.dart';

import 'providers.dart';
import 'routed_probe.dart';

final setupSessionProvider = NotifierProvider<SetupSession, SetupSessionState>(
  SetupSession.new,
);

@immutable
class SetupSessionState {
  const SetupSessionState({
    required this.active,
    required this.step,
    required this.draft,
    this.busy = false,
    this.checking = false,
    this.scanningApps = false,
    this.phases = const [],
    this.report,
    this.error,
    this.saveError = false,
    this.needsVpnRestart = false,
    this.pendingLink,
  });

  final bool active;
  final SetupStep step;
  final SetupDraft draft;
  final bool busy;
  final bool checking;
  final bool scanningApps;
  final List<SetupPhaseResult> phases;
  final SetupReport? report;
  final String? error;
  final bool saveError;
  final bool needsVpnRestart;
  final String? pendingLink;

  SetupSessionState copyWith({
    bool? active,
    SetupStep? step,
    SetupDraft? draft,
    bool? busy,
    bool? checking,
    bool? scanningApps,
    List<SetupPhaseResult>? phases,
    SetupReport? report,
    String? error,
    bool? saveError,
    bool? needsVpnRestart,
    String? pendingLink,
    bool clearReport = false,
    bool clearError = false,
    bool clearLink = false,
  }) => SetupSessionState(
    active: active ?? this.active,
    step: step ?? this.step,
    draft: draft ?? this.draft,
    busy: busy ?? this.busy,
    checking: checking ?? this.checking,
    scanningApps: scanningApps ?? this.scanningApps,
    phases: phases ?? this.phases,
    report: clearReport ? null : report ?? this.report,
    error: clearError ? null : error ?? this.error,
    saveError: saveError ?? this.saveError,
    needsVpnRestart: needsVpnRestart ?? this.needsVpnRestart,
    pendingLink: clearLink ? null : pendingLink ?? this.pendingLink,
  );
}

// The session rides in the family key so the probe never reads the session
// provider from inside its own run, which Riverpod reports as a cycle.
final _setupRouteProbeProvider = NotifierProvider.autoDispose
    .family<
      _SetupRouteProbe,
      RoutedProbeState<String, ProbeResult>,
      (int, SetupSession)
    >(_SetupRouteProbe.new);

class _SetupRouteProbe extends Notifier<RoutedProbeState<String, ProbeResult>>
    with RoutedProbe<String, ProbeResult> {
  _SetupRouteProbe((int, SetupSession) key)
    : generation = key.$1,
      _session = key.$2;

  final int generation;
  final SetupSession _session;

  @override
  RoutedProbeState<String, ProbeResult> build() => buildProbe();

  @override
  bool isFailure(ProbeResult result) =>
      result.error != null ||
      result.statusCode < 200 ||
      result.statusCode >= 400;

  @override
  Future<Map<String, ProbeAnswer<ProbeResult>>> probe(
    String target,
    RouteState route,
  ) async {
    final session = _session;
    final result = await session.probeRoute(target);
    if (!ref.mounted ||
        !session.ref.mounted ||
        session._generation != generation) {
      return const {};
    }
    final snapshot = await session.routeSnapshot();
    if (!ref.mounted ||
        !session.ref.mounted ||
        session._generation != generation) {
      return const {};
    }
    if (snapshot != null) {
      ref.read(routeTrackerProvider.notifier).applySnapshot(snapshot);
    }
    return {
      target: ProbeAnswer(
        value: result,
        coreEpoch: result?.coreEpoch,
        routeVersion: result?.routeVersion,
        hits: result?.hits ?? const [],
      ),
    };
  }
}

class _SetupCancelled implements Exception {}

AccessControlProps _bypassing(AccessControlProps props, List<String> apps) {
  if (props.enable && props.mode == AccessControlMode.acceptSelected) {
    final bypassed = apps.toSet();
    return props.copyWith(
      acceptList: [
        for (final app in props.acceptList)
          if (!bypassed.contains(app)) app,
      ],
    );
  }
  return props.copyWith(
    enable: true,
    mode: AccessControlMode.rejectSelected,
    rejectList: ({...props.rejectList, ...apps}.toList()..sort()),
  );
}

SetupDraft _draftOf(
  AppSettingProps settings, {
  required int? profileId,
  required SetupCoverage coverage,
}) => SetupDraft(
  profileId: settings.setupProfileId ?? profileId,
  coverage:
      SetupCoverage.values
          .where((value) => value.name == settings.setupCoverage)
          .firstOrNull ??
      coverage,
  regionCode: settings.setupRegionChosen
      ? sanitizeRegionCode(settings.setupRegionCode)
      : settings.regionCode,
  regionChosen: settings.setupRegionChosen || settings.regionCode != null,
  directRoutes: settings.setupDirectRoutes,
);

class SetupSession extends Notifier<SetupSessionState> {
  int _generation = 0;
  bool _committing = false;
  bool _probing = false;
  bool _hadConnection = false;
  CoreAction? _ownedCoreStart;
  RouteTracker? _routeWatcher;
  final Object _connectionOwner = Object();
  Future<void>? _operation;
  Future<void>? _scan;
  Completer<void>? _cancellation;
  Future<bool> _saveTail = Future.value(true);

  @override
  SetupSessionState build() {
    final settings = ref.read(appSettingProvider);
    _hadConnection = ref.read(isStartProvider);
    void invalidateInputs(Object? previous, Object? next) {
      if (_committing || previous == next || !state.active) return;
      _invalidate();
    }

    ref.listen<int?>(currentProfileIdProvider, invalidateInputs);
    ref.listen(patchClashConfigProvider, invalidateInputs);
    ref.listen(networkSettingProvider, invalidateInputs);
    ref.listen(vpnSettingProvider, invalidateInputs);
    ref.listen(
      appSettingProvider.select(
        (settings) => (settings.regionCode, settings.checkCertificate),
      ),
      invalidateInputs,
    );
    ref.listen(profilesProvider, (previous, next) {
      if (previous == null ||
          !state.active ||
          (!_probing && state.report == null)) {
        return;
      }
      final profileId = state.draft.profileId;
      if (profileId != null &&
          previous.getProfile(profileId) != next.getProfile(profileId)) {
        _invalidate();
      }
    });
    ref.listen(routeTrackerProvider, (previous, next) {
      if (previous == null || !state.active) return;
      final stamp = state.report?.stamp;
      if (stamp != null && !next.isFresh(stamp)) _invalidate();
      if (_probing &&
          (previous.coreEpoch != next.coreEpoch ||
              previous.hostEpoch != next.hostEpoch ||
              previous.proxied != next.proxied ||
              previous.resumes != next.resumes ||
              !next.synced)) {
        _invalidate();
      }
    });
    ref.onDispose(() {
      _cancelOperation();
      final watcher = _routeWatcher;
      scheduleMicrotask(() {
        if (watcher?.ref.mounted == true) watcher!.detach();
      });
    });
    return SetupSessionState(
      active: settings.setupCompleted != true,
      step: resumableSetupStep(
        settings.setupStep,
        accepted: settings.acceptedDisclaimerVersion >= disclaimerVersion,
      ),
      draft: _draftOf(
        settings,
        profileId: ref.read(currentProfileIdProvider),
        coverage: currentCoverage,
      ),
    );
  }

  SetupCoverage get currentCoverage => isAndroid
      ? ref.read(vpnSettingProvider).enable
            ? SetupCoverage.tun
            : SetupCoverage.local
      : ref.read(patchClashConfigProvider).tun.enable
      ? SetupCoverage.tun
      : ref.read(networkSettingProvider).systemProxy
      ? SetupCoverage.system
      : SetupCoverage.local;

  @protected
  bool get isAndroid => system.isAndroid;

  @protected
  Future<bool> saveConfig(Config config) => preferences.saveConfig(config);

  Future<bool> _save() {
    final save = _saveTail.then((_) async {
      if (!ref.mounted) return false;
      try {
        return await saveConfig(ref.read(configProvider));
      } catch (_) {
        return false;
      }
    });
    _saveTail = save;
    return save;
  }

  Future<bool> persist() async {
    final draft = state.draft;
    ref
        .read(appSettingProvider.notifier)
        .update(
          (settings) => settings.copyWith(
            setupStep: state.step.index,
            setupProfileId: draft.profileId,
            setupCoverage: draft.coverage.name,
            setupRegionCode: draft.regionCode,
            setupRegionChosen: draft.regionChosen,
            setupDirectRoutes: draft.directRoutes,
          ),
        );
    final saved = await _save();
    if (ref.mounted) state = state.copyWith(saveError: !saved);
    return saved;
  }

  Future<bool> next(SetupStep step) async {
    if (state.busy) return false;
    if (step != state.step && state.report != null) _invalidate();
    if (step.index > SetupStep.agreement.index &&
        ref.read(appSettingProvider).acceptedDisclaimerVersion <
            disclaimerVersion) {
      return false;
    }
    final previous = state.step;
    state = state.copyWith(step: step, clearError: true);
    if (step == SetupStep.region) unawaited(scanDirectApps());
    if (await persist()) return true;
    if (ref.mounted) state = state.copyWith(step: previous);
    return false;
  }

  Future<bool> selectLanguage(String? locale) async {
    ref
        .read(appSettingProvider.notifier)
        .update((settings) => settings.copyWith(locale: locale));
    return persist();
  }

  Future<bool> acceptAgreement() async {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (settings) =>
              settings.copyWith(acceptedDisclaimerVersion: disclaimerVersion),
        );
    return next(SetupStep.profile);
  }

  void selectProfile(int? id) {
    _invalidate();
    state = state.copyWith(
      draft: state.draft.withProfile(id),
      clearError: true,
    );
    unawaited(persist());
  }

  void selectCoverage(SetupCoverage value) {
    _invalidate();
    state = state.copyWith(
      draft: state.draft.withCoverage(value),
      clearError: true,
    );
    unawaited(persist());
  }

  void selectRegion(String? code) {
    _invalidate();
    state = state.copyWith(
      draft: state.draft.withRegion(sanitizeRegionCode(code)),
      clearError: true,
    );
    unawaited(persist());
    unawaited(scanDirectApps());
  }

  void selectDirectRoutes(bool value) {
    _invalidate();
    state = state.copyWith(
      draft: state.draft.withDirectRoutes(value),
      clearError: true,
    );
    unawaited(persist());
    unawaited(scanDirectApps());
  }

  bool get _wantsDirectApps {
    final draft = state.draft;
    return isAndroid &&
        draft.coverage == SetupCoverage.tun &&
        draft.regionChosen &&
        draft.directRoutes &&
        directRulesForCode(draft.regionCode).isNotEmpty;
  }

  @protected
  Future<List<String>> domesticPackages(String regionCode) async {
    final system = ref.read(systemActionProvider.notifier);
    if (!await system.isInstalledAppsPermissionGranted() &&
        !await system.requestInstalledAppsPermission()) {
      return const [];
    }
    return system.getDomesticPackageNames(regionCode);
  }

  /// Finds the region's apps once per chosen region; a region changed while
  /// the scan ran is scanned again before the future completes.
  Future<void> scanDirectApps() {
    if (!_wantsDirectApps || state.draft.directApps != null) {
      return Future.value();
    }
    return _scan ??= _scanDirectApps().whenComplete(() => _scan = null);
  }

  Future<void> _scanDirectApps() async {
    state = state.copyWith(scanningApps: true);
    try {
      while (ref.mounted &&
          _wantsDirectApps &&
          state.draft.directApps == null) {
        final regionCode = state.draft.regionCode!;
        List<String> packages;
        try {
          packages = await domesticPackages(regionCode);
        } catch (_) {
          packages = const [];
        }
        if (ref.mounted && state.draft.regionCode == regionCode) {
          state = state.copyWith(
            draft: state.draft.withDirectApps(List.unmodifiable(packages)),
          );
        }
      }
    } finally {
      if (ref.mounted) state = state.copyWith(scanningApps: false);
    }
  }

  /// Puts the region's direct rules above the global rules, skipping those
  /// already present so a repeated check does not stack copies.
  @protected
  Future<void> addDirectRules(List<String> rawRules) async {
    final existing = await database.rulesDao.queryGlobalRules().get();
    final present = {for (final rule in existing) rule.rawValue};
    final missing = [
      for (final raw in rawRules)
        if (Rule.parse(raw) case final rule
            when !present.contains(rule.rawValue))
          rule,
    ];
    if (missing.isEmpty) return;
    final orders = indexing.generateNKeysBetween(
      null,
      existing.firstOrNull?.order,
      missing.length,
    );
    await database.transaction(() async {
      for (final (index, rule) in missing.indexed) {
        await database.rulesDao.putRule(rule.copyWith(order: orders[index]));
      }
    });
  }

  void offerLink(String link) => state = state.copyWith(pendingLink: link);
  void consumeLink() => state = state.copyWith(clearLink: true);
  void showError(Object error) =>
      state = state.copyWith(error: compactError(error));

  void _cancelOperation() {
    _generation++;
    _probing = false;
    final coreStart = _ownedCoreStart;
    _ownedCoreStart = null;
    if (coreStart?.ref.mounted == true) unawaited(coreStart!.cancelCoreStart());
    final cancellation = _cancellation;
    if (cancellation != null && !cancellation.isCompleted) {
      cancellation.complete();
    }
  }

  List<SetupPhaseResult> _settledPhases() => List.unmodifiable([
    for (final phase in state.phases)
      if (phase.status == SetupPhaseStatus.running ||
          phase.status == SetupPhaseStatus.waiting)
        SetupPhaseResult(phase.phase, status: SetupPhaseStatus.skipped)
      else
        phase,
  ]);

  void _invalidate() {
    _cancelOperation();
    if (state.checking || state.report != null) {
      final phases = _settledPhases();
      state = state.copyWith(
        busy: state.checking ? false : state.busy,
        checking: false,
        phases: phases,
        report:
            state.report?.asStale() ??
            SetupReport(
              verdict: SetupVerdict.stale,
              phases: phases,
              connectionActive: ref.read(isStartProvider),
            ),
        step: state.checking ? SetupStep.result : state.step,
        needsVpnRestart: false,
      );
    }
  }

  void cancelCheck() {
    if (!state.checking) return;
    _cancelOperation();
    final phases = _settledPhases();
    state = state.copyWith(
      busy: false,
      checking: false,
      phases: phases,
      step: SetupStep.result,
      report: SetupReport(
        verdict: SetupVerdict.stopped,
        phases: phases,
        connectionActive: ref.read(isStartProvider),
      ),
    );
    unawaited(persist());
  }

  void _guard(int generation) {
    if (!ref.mounted || generation != _generation) throw _SetupCancelled();
  }

  Future<bool> prepareCore() async {
    if (ref.read(appSettingProvider).acceptedDisclaimerVersion <
        disclaimerVersion) {
      return false;
    }
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      final coreStart = ref.read(coreActionProvider.notifier);
      _ownedCoreStart = coreStart;
      try {
        final started = await coreStart.startCore(
          silence: true,
          allowPrompt: true,
        );
        if (!started) {
          throw MessageException(currentAppLocalizations.setupUnknownError);
        }
      } finally {
        if (identical(_ownedCoreStart, coreStart)) _ownedCoreStart = null;
      }
    }
    return true;
  }

  Future<bool> _commitDraft({required bool preserveRunning}) async {
    final draft = state.draft;
    if (draft.profileId != null &&
        ref.read(profilesProvider).getProfile(draft.profileId!) == null) {
      throw MessageException(currentAppLocalizations.nullProfileDesc);
    }
    if (preserveRunning && ref.read(isStartProvider)) return persist();
    final directRules = draft.regionChosen && draft.directRoutes
        ? directRulesForCode(draft.regionCode)
        : const <String>[];
    if (directRules.isNotEmpty) await addDirectRules(directRules);
    if (_wantsDirectApps && state.draft.directApps == null) {
      await scanDirectApps();
    }
    if (!ref.mounted) return false;
    final directApps = _wantsDirectApps
        ? state.draft.directApps ?? const <String>[]
        : const <String>[];
    _committing = true;
    try {
      ref.read(currentProfileIdProvider.notifier).value = draft.profileId;
      if (draft.regionChosen &&
          draft.regionCode != ref.read(appSettingProvider).regionCode) {
        ref.read(systemActionProvider.notifier).applyRegion(draft.regionCode);
      }
      if (isAndroid) {
        ref
            .read(vpnSettingProvider.notifier)
            .update(
              (settings) => settings.copyWith(
                enable: draft.coverage == SetupCoverage.tun,
                accessControlProps: directApps.isEmpty
                    ? settings.accessControlProps
                    : _bypassing(settings.accessControlProps, directApps),
              ),
            );
      } else {
        ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (config) => config.copyWith.tun(
                enable: draft.coverage == SetupCoverage.tun,
              ),
            );
        ref
            .read(networkSettingProvider.notifier)
            .update(
              (settings) => settings.copyWith(
                systemProxy: draft.coverage == SetupCoverage.system,
              ),
            );
      }
      ref.read(configProvider);
    } finally {
      _committing = false;
    }
    return persist();
  }

  void _phase(SetupPhase phase, SetupPhaseStatus status, {String? detail}) {
    state = state.copyWith(
      phases: [
        for (final item in state.phases)
          item.phase == phase
              ? SetupPhaseResult(phase, status: status, detail: detail)
              : item,
      ],
    );
  }

  @protected
  Future<bool> startConnection() => ref
      .read(setupActionProvider.notifier)
      .setRunning(
        true,
        initialize: true,
        silence: true,
        owner: _connectionOwner,
        allowPrompt: true,
      );

  @protected
  Future<bool> applyProfile() => ref
      .read(setupActionProvider.notifier)
      .applyProfile(force: true, silence: true, suppressErrors: true);

  @protected
  Future<DateTime?> nativeRunTime() async => service?.getRunTime();

  Future<bool> _confirmAndroid(int generation) async {
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    while (DateTime.now().isBefore(deadline)) {
      _guard(generation);
      if (await nativeRunTime() != null) return true;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  @protected
  Future<RouteSnapshot?> routeSnapshot() =>
      ref.read(coreHandlerProvider).watchRoute(true);

  Future<RouteState> _syncRoute(int generation) async {
    final tracker = ref.read(routeTrackerProvider.notifier);
    final snapshot = await routeSnapshot();
    _guard(generation);
    if (snapshot == null) {
      throw MessageException(currentAppLocalizations.setupRouteChanged);
    }
    tracker.applySnapshot(snapshot);
    await Future<void>.delayed(Duration.zero);
    _guard(generation);
    return ref.read(routeTrackerProvider);
  }

  @protected
  Future<ProbeResult?> probeRoute(String url) => ref
      .read(coreHandlerProvider)
      .probe(
        ProbeParams(
          url: url,
          timeout: const Duration(seconds: 8).inMilliseconds,
        ),
      );

  Future<ProbeEntry<ProbeResult>> _probeRoute(
    String url,
    int generation,
    Future<void> cancellation,
  ) async {
    final provider = _setupRouteProbeProvider((generation, this));
    final answer = Completer<ProbeEntry<ProbeResult>>();
    var launched = false;
    final subscription = ref.listen(
      provider.select((probe) => probe.entryOf(url)),
      (_, entry) {
        launched |= entry.isLoading;
        if (launched && !entry.isLoading && !answer.isCompleted) {
          answer.complete(entry);
        }
      },
    );
    ref.read(provider.notifier).refresh([url]);
    try {
      return await Future.any([
        answer.future,
        cancellation.then<ProbeEntry<ProbeResult>>(
          (_) => throw _SetupCancelled(),
        ),
      ]).timeout(const Duration(seconds: 28));
    } finally {
      subscription.close();
    }
  }

  Future<void> check({bool restartVpn = false}) {
    if (!state.active ||
        ref.read(appSettingProvider).setupCompleted != false ||
        (state.step != SetupStep.region &&
            state.step != SetupStep.result &&
            !state.checking) ||
        (state.busy && !state.checking) ||
        ref.read(appSettingProvider).acceptedDisclaimerVersion <
            disclaimerVersion) {
      return Future.value();
    }
    final previous = _operation;
    if (state.checking && previous != null) return previous;
    final generation = ++_generation;
    final cancellation = _cancellation = Completer<void>();
    state = state.copyWith(
      step: SetupStep.checking,
      busy: true,
      checking: true,
      clearReport: true,
      clearError: true,
      needsVpnRestart: false,
      phases: [for (final phase in SetupPhase.values) SetupPhaseResult(phase)],
    );
    late final Future<void> operation;
    operation =
        _check(
          generation,
          previous: previous,
          cancellation: cancellation.future,
          restartVpn: restartVpn,
        ).whenComplete(() {
          if (identical(_operation, operation)) _operation = null;
          if (ref.mounted && generation == _generation) {
            _probing = false;
            state = state.copyWith(busy: false, checking: false);
          }
        });
    _operation = operation;
    return operation;
  }

  Future<void> _check(
    int generation, {
    Future<void>? previous,
    required Future<void> cancellation,
    required bool restartVpn,
  }) async {
    try {
      await previous;
      _guard(generation);
      if (!await persist()) {
        _guard(generation);
        state = state.copyWith(step: SetupStep.region);
        return;
      }
      _guard(generation);
      if (ref.read(safeModeProvider)) {
        _finishReport(const SetupReport(verdict: SetupVerdict.safeMode));
        return;
      }
      if (state.draft.profileId == null) {
        throw MessageException(currentAppLocalizations.nullProfileDesc);
      }
      final setup = ref.read(setupActionProvider.notifier);
      final ownConnection = identical(setup.runIntentOwner, _connectionOwner);
      final nativeRunning = isAndroid && await setup.restoreRunningState();
      _guard(generation);
      _hadConnection |=
          !ownConnection && (ref.read(isStartProvider) || nativeRunning);
      _guard(generation);
      if (!await _commitDraft(preserveRunning: false)) {
        _guard(generation);
        state = state.copyWith(step: SetupStep.region);
        return;
      }
      _guard(generation);
      _phase(SetupPhase.core, SetupPhaseStatus.running);
      if (!await prepareCore()) {
        throw MessageException(currentAppLocalizations.setupUnknownError);
      }
      _guard(generation);
      _phase(SetupPhase.core, SetupPhaseStatus.confirmed);
      if (isAndroid && ref.read(isStartProvider)) {
        final running = ref.read(runningVpnOptionsProvider)?.effective;
        final requested = (await ref.read(vpnOptionsProvider.future)).effective;
        _guard(generation);
        if (running != null && running != requested) {
          if (!restartVpn) {
            state = state.copyWith(needsVpnRestart: true);
            _finishReport(
              SetupReport(
                verdict: SetupVerdict.permission,
                error: currentAppLocalizations.vpnConfigChangeDetected,
                connectionActive: true,
              ),
            );
            return;
          }
          await ref
              .read(setupActionProvider.notifier)
              .setRunning(false, silence: true, owner: _connectionOwner);
          _guard(generation);
        }
      }
      _phase(SetupPhase.profile, SetupPhaseStatus.running);
      final alreadyRunning = ref.read(isStartProvider);
      _phase(SetupPhase.connection, SetupPhaseStatus.running);
      final applied = alreadyRunning
          ? await applyProfile()
          : await startConnection();
      _guard(generation);
      if (!applied) {
        throw MessageException(currentAppLocalizations.setupUnknownError);
      }
      ref.read(initProvider.notifier).value = true;
      _phase(SetupPhase.profile, SetupPhaseStatus.confirmed);
      final connectionConfirmed =
          !isAndroid || await _confirmAndroid(generation);
      _guard(generation);
      if (!connectionConfirmed ||
          !ref.read(isStartProvider) ||
          ref.read(suspendProvider)) {
        _phase(SetupPhase.connection, SetupPhaseStatus.unconfirmed);
        _finishReport(
          SetupReport(
            verdict: SetupVerdict.unconfirmed,
            connectionActive: ref.read(isStartProvider),
          ),
        );
        return;
      }
      _phase(SetupPhase.connection, SetupPhaseStatus.confirmed);
      if (_routeWatcher == null) {
        final tracker = ref.read(routeTrackerProvider.notifier);
        _routeWatcher = tracker;
        tracker.attach();
      }
      await _syncRoute(generation);
      _probing = true;
      final testUrl = ref.read(patchClashConfigProvider).testUrl;
      _phase(SetupPhase.route, SetupPhaseStatus.running);
      ProbeEntry<ProbeResult>? answer;
      try {
        answer = await _probeRoute(testUrl, generation, cancellation);
      } on _SetupCancelled {
        rethrow;
      } catch (_) {}
      _guard(generation);
      final response = answer?.value;
      final stamp = answer?.stamp;
      final fresh =
          stamp != null && ref.read(routeTrackerProvider).isFresh(stamp);
      final routeConfirmed = answer?.phase == ProbePhase.fresh && fresh;
      final error = response?.message ?? response?.error;
      _phase(
        SetupPhase.route,
        routeConfirmed
            ? SetupPhaseStatus.confirmed
            : SetupPhaseStatus.unconfirmed,
        detail: error,
      );
      _probing = false;
      _finishReport(
        SetupReport(
          verdict:
              answer?.phase == ProbePhase.empty || (stamp != null && !fresh)
              ? SetupVerdict.stale
              : !routeConfirmed
              ? SetupVerdict.unconfirmed
              : state.draft.coverage == SetupCoverage.local
              ? SetupVerdict.local
              : SetupVerdict.connected,
          delay: response?.delay,
          chains: response?.chains ?? const [],
          error: error,
          stamp: stamp,
          checkedAt: DateTime.now(),
          connectionActive: ref.read(isStartProvider),
        ),
      );
    } on _SetupCancelled {
      return;
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      final running = state.phases
          .where((item) => item.status == SetupPhaseStatus.running)
          .firstOrNull;
      if (running != null) _phase(running.phase, SetupPhaseStatus.failed);
      _finishReport(
        SetupReport(
          verdict: running?.phase == SetupPhase.connection && isAndroid
              ? SetupVerdict.permission
              : SetupVerdict.failed,
          error: compactError(error),
          connectionActive: ref.read(isStartProvider),
        ),
      );
    }
  }

  void _finishReport(SetupReport report) {
    final phases = _settledPhases();
    state = state.copyWith(
      phases: phases,
      step: SetupStep.result,
      checking: false,
      report: SetupReport(
        verdict: report.verdict,
        phases: phases,
        delay: report.delay,
        chains: report.chains,
        error: report.error,
        stamp: report.stamp,
        checkedAt: report.checkedAt,
        connectionActive: report.connectionActive,
      ),
    );
    unawaited(persist());
  }

  Future<void> _stopOwnedConnection() async {
    final setup = ref.read(setupActionProvider.notifier);
    if (!_hadConnection && identical(setup.runIntentOwner, _connectionOwner)) {
      await setup.setRunning(false, silence: true, owner: _connectionOwner);
    }
  }

  Future<bool> saveWithoutConnection() async {
    if (state.busy) return false;
    _cancelOperation();
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _operation;
      if (!ref.mounted) return false;
      if (isAndroid && !ref.read(safeModeProvider)) {
        final setup = ref.read(setupActionProvider.notifier);
        final ownConnection = identical(setup.runIntentOwner, _connectionOwner);
        final nativeRunning = await setup.restoreRunningState();
        if (!ref.mounted) return false;
        _hadConnection |= nativeRunning && !ownConnection;
      }
      await _stopOwnedConnection();
      if (!ref.mounted || !await _commitDraft(preserveRunning: true)) {
        return false;
      }
      if (!ref.mounted) return false;
      final preserveConnection = ref.read(isStartProvider);
      if (!preserveConnection) {
        ref.read(initProvider.notifier).value = false;
        ref
            .read(appSettingProvider.notifier)
            .update((settings) => settings.copyWith(autoRun: false));
      }
      if (!await persist() || !ref.mounted) return false;
      _finishReport(
        SetupReport(
          verdict: SetupVerdict.saved,
          connectionActive: ref.read(isStartProvider),
        ),
      );
      return true;
    } catch (error) {
      if (ref.mounted) state = state.copyWith(error: compactError(error));
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<bool> finish({required bool autoRun}) async {
    if (state.busy || state.step != SetupStep.result || state.report == null) {
      return false;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _operation;
      if (!ref.mounted) return false;
      final previous = ref.read(appSettingProvider);
      final canAutoRun =
          state.report?.confirmed == true &&
          state.report?.connectionActive == true &&
          ref.read(isStartProvider);
      ref
          .read(appSettingProvider.notifier)
          .update(
            (settings) => settings.copyWith(
              setupCompleted: true,
              setupStep: SetupStep.result.index,
              autoRun:
                  state.report?.verdict == SetupVerdict.saved &&
                      ref.read(isStartProvider)
                  ? previous.autoRun
                  : canAutoRun && autoRun,
            ),
          );
      final saved = await _save();
      if (!ref.mounted) return false;
      if (!saved) {
        ref
            .read(appSettingProvider.notifier)
            .update(
              (settings) => settings.copyWith(
                setupCompleted: previous.setupCompleted,
                autoRun: previous.autoRun,
              ),
            );
        state = state.copyWith(saveError: true);
        return false;
      }
      _routeWatcher?.detach();
      _routeWatcher = null;
      state = state.copyWith(active: false, saveError: false);
      return true;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<bool> reopen() async {
    if (state.active || state.busy) return false;
    _generation++;
    _hadConnection = ref.read(isStartProvider);
    final settings = ref.read(appSettingProvider);
    ref
        .read(appSettingProvider.notifier)
        .update((value) => value.copyWith(setupCompleted: false));
    state = SetupSessionState(
      active: true,
      step: settings.acceptedDisclaimerVersion >= disclaimerVersion
          ? SetupStep.profile
          : SetupStep.language,
      draft: _draftOf(
        settings,
        profileId: ref.read(currentProfileIdProvider),
        coverage: currentCoverage,
      ),
    );
    return persist();
  }
}
