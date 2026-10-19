import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/route_state.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/providers/state.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _TestCommonAction extends CommonAction {
  @override
  Future<void> updateTraffic() async {}
}

class _TestRunTime extends RunTime {
  _TestRunTime(this.initial);

  final int? initial;

  @override
  int? build() => initial;
}

class _TestSetupAction extends SetupAction {
  _TestSetupAction({this.startResult = true});

  final bool startResult;
  int starts = 0;
  int stops = 0;
  DateTime? nativeStartTime;
  Completer<DateTime?>? nativeRuntimeGate;
  final Completer<void> nativeRuntimeStarted = Completer<void>();

  @override
  Future<DateTime?> readNativeRunTime() {
    final gate = nativeRuntimeGate;
    if (gate != null) {
      if (!nativeRuntimeStarted.isCompleted) nativeRuntimeStarted.complete();
      return gate.future;
    }
    return Future.value(nativeStartTime);
  }

  @override
  Future<bool> setCoreRunning(bool running) async {
    if (running) {
      starts++;
      if (startResult) {
        ref.read(runTimeProvider.notifier).value = 0;
      }
    } else {
      stops++;
      ref.read(runTimeProvider.notifier).value = null;
    }
    return running ? startResult : true;
  }

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool suppressErrors = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    await preloadInvoke?.call();
    return true;
  }

  @override
  void resetCoreTraffic() {}
}

class _TestSetupSession extends SetupSession {
  _TestSetupSession({this.saveResult = true, this.probeGate, this.probeGates});

  bool saveResult;
  final Completer<ProbeResult?>? probeGate;
  final List<Completer<ProbeResult?>>? probeGates;
  final Completer<void> probeStarted = Completer<void>();
  final Completer<void> retryProbeStarted = Completer<void>();
  bool android = false;
  bool connectThroughAction = false;
  DateTime? nativeAcknowledgement;
  RouteSnapshot snapshot = const RouteSnapshot(coreEpoch: 2, picksVersion: 5);
  int saveCalls = 0;
  Completer<bool>? saveGate;
  final Completer<void> saveStarted = Completer<void>();
  int prepareCalls = 0;
  int startCalls = 0;
  int applyCalls = 0;
  int snapshotCalls = 0;
  int probeCalls = 0;
  int nativeRuntimeCalls = 0;
  final List<String> probedUrls = [];

  void setFinishReady() {
    state = state.copyWith(
      step: SetupStep.result,
      report: const SetupReport(verdict: SetupVerdict.saved),
    );
  }

  @override
  bool get isAndroid => android;

  @override
  Future<bool> saveConfig(Config config) async {
    saveCalls++;
    final gate = saveGate;
    if (gate != null) {
      if (!saveStarted.isCompleted) saveStarted.complete();
      return gate.future;
    }
    return saveResult;
  }

  @override
  Future<bool> prepareCore() async {
    prepareCalls++;
    return true;
  }

  @override
  Future<bool> startConnection() async {
    startCalls++;
    if (connectThroughAction) return super.startConnection();
    ref.read(runTimeProvider.notifier).value = 0;
    return true;
  }

  @override
  Future<bool> applyProfile() async {
    applyCalls++;
    return true;
  }

  @override
  Future<DateTime?> nativeRunTime() async {
    nativeRuntimeCalls++;
    return nativeRuntimeCalls == 1 ? null : nativeAcknowledgement;
  }

  @override
  Future<RouteSnapshot?> routeSnapshot() async {
    snapshotCalls++;
    return snapshot;
  }

  @override
  Future<ProbeResult?> probeRoute(String url) {
    probeCalls++;
    probedUrls.add(url);
    if (probeCalls == 1 && !probeStarted.isCompleted) {
      probeStarted.complete();
    }
    if (probeCalls == 2 && !retryProbeStarted.isCompleted) {
      retryProbeStarted.complete();
    }
    final gates = probeGates;
    if (gates != null) return gates[probeCalls - 1].future;
    return probeGate?.future ??
        Future.value(
          const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
        );
  }
}

const _vpnOptions = VpnOptions(
  enable: true,
  port: 7890,
  ipv6: false,
  dnsHijacking: false,
  accessControlProps: AccessControlProps(),
  allowBypass: false,
  systemProxy: false,
  bypassDomain: [],
  stack: 'system',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ({
    ProviderContainer container,
    Profile profile,
    _TestSetupSession session,
    _TestSetupAction action,
  })
  makeHarness({
    AppSettingProps settings = const AppSettingProps(
      setupCompleted: false,
      acceptedDisclaimerVersion: disclaimerVersion,
      setupStep: 3,
    ),
    bool running = false,
    bool safeMode = false,
    bool startResult = true,
    bool runningVpnOptions = false,
    VpnOptions? vpnOptions,
    _TestSetupSession? session,
  }) {
    final profile = Profile.normal(label: 'Wizard profile');
    final setupSession = session ?? _TestSetupSession();
    final setupAction = _TestSetupAction(startResult: startResult);
    final core = _MockCoreHandlerInterface();
    when(() => core.watchRoute(true)).thenAnswer(
      (_) async => const RouteSnapshot(coreEpoch: 2, picksVersion: 5),
    );
    when(() => core.watchRoute(false)).thenAnswer((_) async => null);
    final container = ProviderContainer(
      overrides: [
        appSettingProvider.overrideWithBuild((_, _) => settings),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        runTimeProvider.overrideWith(
          () => _TestRunTime(
            running ? DateTime.now().millisecondsSinceEpoch : null,
          ),
        ),
        appVisibleProvider.overrideWithValue(true),
        coreStatusProvider.overrideWithValue(CoreStatus.connected),
        if (runningVpnOptions)
          runningVpnOptionsProvider.overrideWithBuild(
            (_, _) => vpnOptions ?? _vpnOptions,
          ),
        vpnOptionsProvider.overrideWith((_) async => vpnOptions ?? _vpnOptions),
        safeModeProvider.overrideWithValue(safeMode),
        setupActionProvider.overrideWith(() => setupAction),
        setupSessionProvider.overrideWith(() => setupSession),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        commonActionProvider.overrideWith(_TestCommonAction.new),
      ],
    );
    return (
      container: container,
      profile: profile,
      session: setupSession,
      action: setupAction,
    );
  }

  test(
    'resumes persisted step and draft without changing live settings',
    () async {
      final harness = makeHarness(
        settings: const AppSettingProps(
          setupCompleted: false,
          setupStep: 3,
          acceptedDisclaimerVersion: disclaimerVersion,
          setupProfileId: 72,
          setupCoverage: 'system',
          regionCode: 'CN',
          setupRegionCode: 'RU',
          setupRegionChosen: true,
        ),
      );
      addTearDown(harness.container.dispose);

      final state = harness.container.read(setupSessionProvider);

      expect(state.active, isTrue);
      expect(state.step, SetupStep.coverage);
      expect(state.draft.profileId, 72);
      expect(state.draft.coverage, SetupCoverage.system);
      expect(state.draft.regionCode, 'RU');
      expect(state.draft.regionChosen, isTrue);
      expect(
        harness.container.read(currentProfileIdProvider),
        harness.profile.id,
      );
      expect(harness.container.read(appSettingProvider).regionCode, 'CN');
    },
  );

  test(
    'legacy nullable completion remains active until bootstrap normalization',
    () async {
      final harness = makeHarness(
        settings: const AppSettingProps(
          acceptedDisclaimerVersion: disclaimerVersion,
          setupStep: 0,
        ),
      );
      addTearDown(harness.container.dispose);

      expect(harness.container.read(setupSessionProvider).active, isTrue);
      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.language,
      );
      await harness.container.read(setupSessionProvider.notifier).check();
      expect(harness.session.prepareCalls, 0);
      expect(harness.session.startCalls, 0);
      expect(harness.session.probeCalls, 0);
    },
  );

  test('check is gated while the profile step is active', () async {
    final harness = makeHarness(
      settings: const AppSettingProps(
        setupCompleted: false,
        acceptedDisclaimerVersion: disclaimerVersion,
        setupStep: 2,
      ),
    );
    addTearDown(harness.container.dispose);

    expect(
      harness.container.read(setupSessionProvider).step,
      SetupStep.profile,
    );
    await harness.container.read(setupSessionProvider.notifier).check();

    expect(harness.session.prepareCalls, 0);
    expect(harness.session.startCalls, 0);
    expect(harness.session.probeCalls, 0);
  });

  test('check remains available on the result step', () async {
    final fake = _TestSetupSession();
    final harness = makeHarness(session: fake);
    addTearDown(harness.container.dispose);
    final sessionSubscription = harness.container.listen<SetupSessionState>(
      setupSessionProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(sessionSubscription.close);
    fake.setFinishReady();

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(fake.prepareCalls, 1);
    expect(fake.startCalls, 1);
    expect(fake.applyCalls, 0);
    expect(fake.probeCalls, 1);
  });

  test('completed setup cannot be checked again', () async {
    final harness = makeHarness(
      settings: const AppSettingProps(
        setupCompleted: true,
        acceptedDisclaimerVersion: disclaimerVersion,
        setupStep: 3,
      ),
    );
    addTearDown(harness.container.dispose);

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(harness.session.prepareCalls, 0);
    expect(harness.session.startCalls, 0);
    expect(harness.session.probeCalls, 0);
  });

  test(
    'reopen persists incomplete status and restores the saved draft',
    () async {
      final harness = makeHarness(
        settings: AppSettingProps(
          setupCompleted: true,
          acceptedDisclaimerVersion: disclaimerVersion,
          regionCode: 'CN',
          setupProfileId: 81,
          setupCoverage: SetupCoverage.system.name,
          setupRegionCode: null,
          setupRegionChosen: true,
        ),
      );
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      expect(harness.container.read(setupSessionProvider).active, isFalse);
      expect(await session.reopen(), isTrue);

      final settings = harness.container.read(appSettingProvider);
      final state = harness.container.read(setupSessionProvider);
      expect(settings.setupCompleted, isFalse);
      expect(settings.setupProfileId, 81);
      expect(settings.setupCoverage, SetupCoverage.system.name);
      expect(settings.setupRegionChosen, isTrue);
      expect(settings.setupRegionCode, isNull);
      expect(state.active, isTrue);
      expect(state.draft.profileId, 81);
      expect(state.draft.coverage, SetupCoverage.system);
      expect(state.draft.regionChosen, isTrue);
      expect(state.draft.regionCode, isNull);
      expect(settings.regionCode, 'CN');
    },
  );

  test(
    'draft selections persist separately from active configuration',
    () async {
      final harness = makeHarness(
        settings: const AppSettingProps(
          setupCompleted: false,
          acceptedDisclaimerVersion: disclaimerVersion,
          regionCode: 'CN',
        ),
      );
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      session.selectProfile(harness.profile.id + 1);
      session.selectCoverage(SetupCoverage.tun);
      session.selectRegion(null);
      await Future<void>.delayed(Duration.zero);

      final settings = harness.container.read(appSettingProvider);
      expect(
        harness.container.read(currentProfileIdProvider),
        harness.profile.id,
      );
      expect(settings.regionCode, 'CN');
      expect(settings.setupProfileId, harness.profile.id + 1);
      expect(settings.setupCoverage, SetupCoverage.tun.name);
      expect(settings.setupRegionChosen, isTrue);
      expect(settings.setupRegionCode, isNull);
    },
  );

  test('failed save leaves the session active and incomplete', () async {
    final fake = _TestSetupSession(saveResult: false);
    final harness = makeHarness(session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);
    fake.setFinishReady();

    final finished = await session.finish(autoRun: true);

    expect(finished, isFalse);
    expect(harness.container.read(setupSessionProvider).active, isTrue);
    expect(harness.container.read(setupSessionProvider).saveError, isTrue);
    expect(harness.container.read(appSettingProvider).setupCompleted, isFalse);
  });

  test('failed initial save prevents connection setup', () async {
    final fake = _TestSetupSession(saveResult: false);
    final harness = makeHarness(session: fake);
    addTearDown(harness.container.dispose);

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(harness.container.read(setupSessionProvider).report, isNull);
    expect(
      harness.container.read(setupSessionProvider).step,
      SetupStep.coverage,
    );
    expect(fake.prepareCalls, 0);
    expect(fake.startCalls, 0);
    expect(fake.probeCalls, 0);
  });

  test('waits for Android native runtime acknowledgment after start', () async {
    final fake = _TestSetupSession()
      ..android = true
      ..nativeAcknowledgement = DateTime.utc(2025);
    final harness = makeHarness(session: fake);
    addTearDown(harness.container.dispose);

    await harness.container.read(setupSessionProvider.notifier).check();

    final report = harness.container.read(setupSessionProvider).report!;
    expect(fake.nativeRuntimeCalls, 2);
    expect(
      report.phases
          .singleWhere((phase) => phase.phase == SetupPhase.connection)
          .status,
      SetupPhaseStatus.confirmed,
    );
    await harness.container
        .read(setupSessionProvider.notifier)
        .finish(autoRun: false);
  });

  test('finish tolerates disposal while saving', () async {
    final fake = _TestSetupSession()..saveGate = Completer<bool>();
    final harness = makeHarness(session: fake);
    harness.container.listen<SetupSessionState>(
      setupSessionProvider,
      (_, _) {},
      fireImmediately: true,
    );
    final session = harness.container.read(setupSessionProvider.notifier);
    fake.setFinishReady();

    final finishing = session.finish(autoRun: false);
    await fake.saveStarted.future;
    harness.container.dispose();
    fake.saveGate!.complete(true);

    expect(await finishing, isFalse);
  });

  test('save without connection tolerates disposal while saving', () async {
    final fake = _TestSetupSession()..saveGate = Completer<bool>();
    final harness = makeHarness(session: fake);
    harness.container.listen<SetupSessionState>(
      setupSessionProvider,
      (_, _) {},
      fireImmediately: true,
    );
    final saving = harness.container
        .read(setupSessionProvider.notifier)
        .saveWithoutConnection();
    await fake.saveStarted.future;
    harness.container.dispose();
    fake.saveGate!.complete(true);

    expect(await saving, isFalse);
  });

  test('safe mode reports without starting or probing', () async {
    final fake = _TestSetupSession();
    final harness = makeHarness(safeMode: true, session: fake);
    addTearDown(harness.container.dispose);

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      SetupVerdict.safeMode,
    );
    expect(fake.prepareCalls, 0);
    expect(fake.startCalls, 0);
    expect(fake.applyCalls, 0);
    expect(fake.probeCalls, 0);
    await harness.container
        .read(setupSessionProvider.notifier)
        .finish(autoRun: false);
  });

  test(
    'checks one route probe without stopping an existing connection',
    () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(running: true, session: fake);
      addTearDown(harness.container.dispose);

      await harness.container.read(setupSessionProvider.notifier).check();

      final session = harness.container.read(setupSessionProvider.notifier);
      final report = harness.container.read(setupSessionProvider).report!;
      expect(fake.applyCalls, 1);
      expect(fake.startCalls, 0);
      expect(harness.action.stops, 0);
      expect(fake.probeCalls, 1);
      expect(fake.probedUrls, [
        harness.container.read(appSettingProvider).testUrl,
      ]);
      expect(fake.snapshotCalls, 2);
      expect(report.verdict, SetupVerdict.connected);
      expect(
        report.phases.map((phase) => phase.phase).toList(),
        SetupPhase.values,
      );
      expect(
        harness.container.read(routeTrackerProvider).isFresh(report.stamp!),
        isTrue,
      );

      expect(await session.finish(autoRun: false), isTrue);
      expect(
        harness.container.read(routeTrackerProvider).isFresh(report.stamp!),
        isTrue,
      );
    },
  );

  test('repeating an owned start still lets save-without stop it', () async {
    final fake = _TestSetupSession()..connectThroughAction = true;
    final harness = makeHarness(session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    await session.check();
    expect(harness.container.read(isStartProvider), isTrue);
    expect(harness.action.starts, 1);

    await session.check();
    expect(fake.startCalls, 1);
    expect(fake.applyCalls, 1);
    expect(harness.action.starts, 1);

    expect(await session.saveWithoutConnection(), isTrue);
    expect(harness.action.stops, 1);
    expect(harness.container.read(isStartProvider), isFalse);
    expect(harness.container.read(initProvider), isFalse);
    expect(harness.container.read(appSettingProvider).autoRun, isFalse);
    expect(await session.finish(autoRun: false), isTrue);
  });

  test('restores an existing Android run before applying the draft', () async {
    final fake = _TestSetupSession()
      ..android = true
      ..nativeRuntimeCalls = 1
      ..nativeAcknowledgement = DateTime.now();
    final harness = makeHarness(
      session: fake,
      runningVpnOptions: true,
      vpnOptions: _vpnOptions,
      settings: const AppSettingProps(
        setupCompleted: false,
        setupStep: 3,
        acceptedDisclaimerVersion: disclaimerVersion,
        autoRun: true,
      ),
    );
    addTearDown(harness.container.dispose);
    harness.action.nativeStartTime = DateTime.now();

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(harness.container.read(isStartProvider), isTrue);
    expect(harness.action.starts, 0);
    expect(harness.action.stops, 0);
    expect(fake.applyCalls, 1);

    expect(
      await harness.container
          .read(setupSessionProvider.notifier)
          .saveWithoutConnection(),
      isTrue,
    );
    expect(harness.action.stops, 0);
    expect(harness.container.read(isStartProvider), isTrue);
    expect(harness.container.read(appSettingProvider).autoRun, isTrue);
  });

  test('late native restore does not replace a newer stop intent', () async {
    final harness = makeHarness();
    addTearDown(harness.container.dispose);
    harness.container.read(setupActionProvider.notifier);
    final action = harness.action;
    final gate = Completer<DateTime?>();
    action.nativeRuntimeGate = gate;

    final restore = action.restoreRunningState();
    await action.nativeRuntimeStarted.future;
    await action.setRunning(false);
    gate.complete(DateTime.now());

    expect(await restore, isFalse);
    expect(harness.container.read(runTimeProvider), isNull);
    expect(action.stops, 1);
  });

  test('late native restore does not replace a newer start intent', () async {
    final harness = makeHarness();
    addTearDown(harness.container.dispose);
    harness.container.read(initProvider.notifier).value = true;
    harness.container.read(setupActionProvider.notifier);
    final action = harness.action;
    final gate = Completer<DateTime?>();
    action.nativeRuntimeGate = gate;

    final restore = action.restoreRunningState();
    await action.nativeRuntimeStarted.future;
    await action.setRunning(true, initialize: true);
    gate.complete(DateTime.now());

    expect(await restore, isFalse);
    expect(harness.container.read(runTimeProvider), 0);
    expect(action.starts, 1);
  });

  test(
    'save-without leaves a connection that predates the setup alone',
    () async {
      final harness = makeHarness(
        running: true,
        settings: const AppSettingProps(
          setupCompleted: false,
          acceptedDisclaimerVersion: disclaimerVersion,
          setupStep: 3,
          autoRun: true,
        ),
      );
      addTearDown(harness.container.dispose);
      harness.container.read(initProvider.notifier).value = true;

      expect(
        await harness.container
            .read(setupSessionProvider.notifier)
            .saveWithoutConnection(),
        isTrue,
      );

      expect(harness.action.stops, 0);
      expect(harness.container.read(isStartProvider), isTrue);
      expect(harness.container.read(initProvider), isTrue);
      expect(harness.container.read(appSettingProvider).autoRun, isTrue);
      expect(
        await harness.container
            .read(setupSessionProvider.notifier)
            .finish(autoRun: false),
        isTrue,
      );
      expect(harness.container.read(appSettingProvider).autoRun, isTrue);
    },
  );

  test(
    'cancelling a pending probe clears busy and skips unfinished phases',
    () async {
      final gate = Completer<ProbeResult?>();
      final fake = _TestSetupSession(probeGate: gate);
      final harness = makeHarness(running: true, session: fake);
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      final operation = session.check();
      await fake.probeStarted.future;
      session.cancelCheck();

      final cancelled = harness.container.read(setupSessionProvider);
      expect(cancelled.busy, isFalse);
      expect(
        cancelled.report!.phases.map((phase) => phase.status),
        isNot(contains(SetupPhaseStatus.running)),
      );
      gate.complete(
        const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
      );
      await operation;

      expect(
        harness.container.read(setupSessionProvider).report?.verdict,
        SetupVerdict.stopped,
      );
      expect(harness.container.read(setupSessionProvider).busy, isFalse);
    },
  );

  test(
    'a cancelled probe cannot answer a retry with a different result',
    () async {
      final oldGate = Completer<ProbeResult?>();
      final currentGate = Completer<ProbeResult?>();
      final fake = _TestSetupSession(probeGates: [oldGate, currentGate]);
      final harness = makeHarness(running: true, session: fake);
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      final first = session.check();
      await fake.probeStarted.future;
      session.cancelCheck();
      await first;

      final retry = session.check();
      await fake.retryProbeStarted.future;
      oldGate.complete(
        const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
      );
      await Future<void>.delayed(Duration.zero);
      expect(harness.container.read(setupSessionProvider).checking, isTrue);

      currentGate.complete(
        const ProbeResult(
          statusCode: 503,
          error: 'current probe failed',
          coreEpoch: 2,
          picksVersion: 5,
        ),
      );
      await retry;

      final report = harness.container.read(setupSessionProvider).report!;
      expect(report.verdict, SetupVerdict.unconfirmed);
      expect(report.error, 'current probe failed');
    },
  );

  test('coverage changes invalidate a pending route probe', () async {
    final gate = Completer<ProbeResult?>();
    final fake = _TestSetupSession(probeGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.probeStarted.future;
    session.selectCoverage(SetupCoverage.tun);
    gate.complete(
      const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
    );
    await operation;

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('region changes invalidate a pending route probe', () async {
    final gate = Completer<ProbeResult?>();
    final fake = _TestSetupSession(probeGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.probeStarted.future;
    session.selectRegion('RU');
    gate.complete(
      const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
    );
    await operation;

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('selected profile changes invalidate a pending route probe', () async {
    final gate = Completer<ProbeResult?>();
    final fake = _TestSetupSession(probeGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final operation = harness.container
        .read(setupSessionProvider.notifier)
        .check();
    await fake.probeStarted.future;

    harness.container
        .read(profilesProvider.notifier)
        .put(harness.profile.copyWith(label: 'Changed profile'));
    gate.complete(
      const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
    );
    await operation;

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('a Core epoch change invalidates a pending route probe', () async {
    final gate = Completer<ProbeResult?>();
    final fake = _TestSetupSession(probeGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.probeStarted.future;
    fake.snapshot = const RouteSnapshot(coreEpoch: 3, picksVersion: 5);
    gate.complete(
      const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
    );
    await operation;

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('changing the test URL invalidates a pending route probe', () async {
    final gate = Completer<ProbeResult?>();
    final fake = _TestSetupSession(probeGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final subscription = harness.container.listen<SetupSessionState>(
      setupSessionProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.probeStarted.future;
    final settings = harness.container.read(appSettingProvider);
    harness.container.read(appSettingProvider.notifier).value = settings
        .copyWith(testUrl: 'https://example.org/');
    gate.complete(
      const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
    );
    await operation;

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('stopping the Core invalidates a connected result in flight', () async {
    final gate = Completer<ProbeResult?>();
    final fake = _TestSetupSession(probeGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.probeStarted.future;
    harness.container.read(runTimeProvider.notifier).value = null;
    gate.complete(
      const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
    );
    await operation;

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      isNot(SetupVerdict.connected),
    );
    expect(await session.finish(autoRun: true), isTrue);
    expect(harness.container.read(appSettingProvider).autoRun, isFalse);
  });

  test('a refused Core start is not reported as connected', () async {
    final fake = _TestSetupSession()..connectThroughAction = true;
    final harness = makeHarness(session: fake, startResult: false);
    addTearDown(harness.container.dispose);

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(
      harness.container.read(setupSessionProvider).report?.verdict,
      isNot(SetupVerdict.connected),
    );
    expect(harness.container.read(initProvider), isFalse);
    expect(fake.probeCalls, 0);
  });

  test('disposing during a pending probe tolerates its late result', () async {
    final gate = Completer<ProbeResult?>();
    final fake = _TestSetupSession(probeGate: gate);
    final harness = makeHarness(running: true, session: fake);

    final operation = harness.container
        .read(setupSessionProvider.notifier)
        .check();
    await fake.probeStarted.future;
    harness.container.dispose();
    gate.complete(
      const ProbeResult(statusCode: 204, coreEpoch: 2, picksVersion: 5),
    );
    await operation;
  });
}
