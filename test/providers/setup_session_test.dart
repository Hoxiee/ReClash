import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/path.dart';
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

PathResult _connectedPath() {
  final at = DateTime.now();
  return PathResult.start(PathScope.setup, at)
      .withStep(
        const PathStepResult(
          PathStep.internet,
          status: PathStepStatus.pass,
          duration: Duration(milliseconds: 84),
        ),
      )
      .finish(at);
}

PathResult _failedPath(FailureCause cause, String detail) {
  final at = DateTime.now();
  return PathResult.start(PathScope.setup, at)
      .withStep(
        PathStepResult(
          PathStep.internet,
          status: PathStepStatus.fail,
          cause: cause,
          detail: detail,
        ),
      )
      .finish(at);
}

class _TestSetupSession extends SetupSession {
  _TestSetupSession({this.saveResult = true, this.pathGate, this.pathGates});

  bool saveResult;
  final Completer<PathResult>? pathGate;
  final List<Completer<PathResult>>? pathGates;
  final Completer<void> pathStarted = Completer<void>();
  final Completer<void> retryPathStarted = Completer<void>();
  final _pathUpdates = StreamController<PathResult>.broadcast(sync: true);
  bool android = false;
  bool connectThroughAction = false;
  DateTime? nativeAcknowledgement;
  int saveCalls = 0;
  Completer<bool>? saveGate;
  final Completer<void> saveStarted = Completer<void>();
  int prepareCalls = 0;
  int startCalls = 0;
  int applyCalls = 0;
  int pathCalls = 0;
  int snapshotCalls = 0;
  RouteSnapshot? snapshot = const RouteSnapshot(coreEpoch: 2, routeVersion: 5);
  int nativeRuntimeCalls = 0;
  final List<List<String>> directRules = [];
  List<String> domesticApps = const [];
  final List<String> scannedRegions = [];

  void setFinishReady() {
    state = state.copyWith(
      step: SetupStep.result,
      outcome: const SetupOutcome(verdict: SetupVerdict.saved),
    );
  }

  void pushPath(PathResult path) => _pathUpdates.add(path);

  Future<void> closePathUpdates() => _pathUpdates.close();

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
  Future<void> addDirectRules(List<String> rawRules) async {
    directRules.add(rawRules);
  }

  @override
  Future<List<String>> domesticPackages(String regionCode) async {
    scannedRegions.add(regionCode);
    return domesticApps;
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
  Stream<PathResult> get pathUpdates => _pathUpdates.stream;

  @override
  Future<PathResult> runPath() {
    pathCalls++;
    if (pathCalls == 1 && !pathStarted.isCompleted) pathStarted.complete();
    if (pathCalls == 2 && !retryPathStarted.isCompleted) {
      retryPathStarted.complete();
    }
    final gates = pathGates;
    if (gates != null) return gates[pathCalls - 1].future;
    return pathGate?.future ?? Future.value(_connectedPath());
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
      setupStep: 4,
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
    addTearDown(setupSession.closePathUpdates);
    final setupAction = _TestSetupAction(startResult: startResult);
    final core = _MockCoreHandlerInterface();
    when(() => core.watchRoute(true)).thenAnswer(
      (_) async => const RouteSnapshot(coreEpoch: 2, routeVersion: 5),
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
      expect(harness.session.pathCalls, 0);
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
    expect(harness.session.pathCalls, 0);
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
    expect(fake.pathCalls, 1);
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
    expect(harness.session.pathCalls, 0);
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

    expect(harness.container.read(setupSessionProvider).outcome, isNull);
    expect(harness.container.read(setupSessionProvider).step, SetupStep.region);
    expect(fake.prepareCalls, 0);
    expect(fake.startCalls, 0);
    expect(fake.pathCalls, 0);
  });

  test('waits for Android native runtime acknowledgment after start', () async {
    final fake = _TestSetupSession()
      ..android = true
      ..nativeAcknowledgement = DateTime.utc(2025);
    final harness = makeHarness(session: fake);
    addTearDown(harness.container.dispose);

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(fake.nativeRuntimeCalls, 2);
    expect(fake.pathCalls, 1);
    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
      SetupVerdict.connected,
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

  test('safe mode reports without starting or running the path', () async {
    final fake = _TestSetupSession();
    final harness = makeHarness(safeMode: true, session: fake);
    addTearDown(harness.container.dispose);

    await harness.container.read(setupSessionProvider.notifier).check();

    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
      SetupVerdict.safeMode,
    );
    expect(fake.prepareCalls, 0);
    expect(fake.startCalls, 0);
    expect(fake.applyCalls, 0);
    expect(fake.pathCalls, 0);
    await harness.container
        .read(setupSessionProvider.notifier)
        .finish(autoRun: false);
  });

  test(
    'checks the setup path without stopping an existing connection',
    () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(running: true, session: fake);
      addTearDown(harness.container.dispose);

      await harness.container.read(setupSessionProvider.notifier).check();

      final session = harness.container.read(setupSessionProvider.notifier);
      final outcome = harness.container.read(setupSessionProvider).outcome!;
      expect(fake.applyCalls, 1);
      expect(fake.startCalls, 0);
      expect(harness.action.stops, 0);
      expect(fake.pathCalls, 1);
      expect(outcome.verdict, SetupVerdict.connected);
      expect(
        outcome.path?.steps.map((step) => step.step).toList(),
        PathScope.setup.steps,
      );
      expect(
        harness.container.read(routeTrackerProvider).isFresh(outcome.stamp!),
        isTrue,
      );

      expect(await session.finish(autoRun: false), isTrue);
      expect(
        harness.container.read(routeTrackerProvider).isFresh(outcome.stamp!),
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
        setupStep: 4,
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
          setupStep: 4,
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
    'cancelling a pending path clears busy and skips unfinished steps',
    () async {
      final gate = Completer<PathResult>();
      final fake = _TestSetupSession(pathGate: gate);
      final harness = makeHarness(running: true, session: fake);
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      final operation = session.check();
      await fake.pathStarted.future;
      fake.pushPath(
        PathResult.start(PathScope.setup, DateTime.now())
            .withStep(
              const PathStepResult(
                PathStep.network,
                status: PathStepStatus.pass,
              ),
            )
            .withStep(
              const PathStepResult(
                PathStep.core,
                status: PathStepStatus.running,
              ),
            ),
      );
      session.cancelCheck();

      final cancelled = harness.container.read(setupSessionProvider);
      expect(cancelled.busy, isFalse);
      expect(
        cancelled.path?.steps.map((step) => step.status),
        isNot(contains(PathStepStatus.running)),
      );
      expect(
        cancelled.path?.stepOf(PathStep.network)?.status,
        PathStepStatus.pass,
      );
      expect(
        cancelled.path?.stepOf(PathStep.core)?.status,
        PathStepStatus.skipped,
      );
      gate.complete(_connectedPath());
      await operation;

      expect(
        harness.container.read(setupSessionProvider).outcome?.verdict,
        SetupVerdict.stopped,
      );
      expect(harness.container.read(setupSessionProvider).busy, isFalse);
    },
  );

  test(
    'setup path updates reach the wizard only for the running check',
    () async {
      final gate = Completer<PathResult>();
      final fake = _TestSetupSession(pathGate: gate);
      final harness = makeHarness(running: true, session: fake);
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      final operation = session.check();
      await fake.pathStarted.future;
      final now = DateTime.now();
      fake.pushPath(
        PathResult.start(PathScope.full, now).withStep(
          const PathStepResult(
            PathStep.network,
            status: PathStepStatus.fail,
            cause: FailureCause.noNetwork,
          ),
        ),
      );
      fake.pushPath(
        PathResult.start(PathScope.setup, now).withStep(
          const PathStepResult(PathStep.network, status: PathStepStatus.pass),
        ),
      );

      final mirrored = harness.container.read(setupSessionProvider).path;
      expect(mirrored?.scope, PathScope.setup);
      expect(mirrored?.failed, isNull);
      expect(mirrored?.stepOf(PathStep.network)?.status, PathStepStatus.pass);
      gate.complete(_connectedPath());
      await operation;
    },
  );

  test(
    'a cancelled path cannot answer a retry with a different result',
    () async {
      final oldGate = Completer<PathResult>();
      final currentGate = Completer<PathResult>();
      final fake = _TestSetupSession(pathGates: [oldGate, currentGate]);
      final harness = makeHarness(running: true, session: fake);
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      final first = session.check();
      await fake.pathStarted.future;
      session.cancelCheck();
      await first;

      final retry = session.check();
      await fake.retryPathStarted.future;
      oldGate.complete(_connectedPath());
      await Future<void>.delayed(Duration.zero);
      expect(harness.container.read(setupSessionProvider).checking, isTrue);

      currentGate.complete(
        _failedPath(FailureCause.timeout, 'current probe failed'),
      );
      await retry;

      final outcome = harness.container.read(setupSessionProvider).outcome!;
      expect(outcome.verdict, SetupVerdict.failed);
      expect(outcome.error, 'current probe failed');
    },
  );

  test('coverage changes invalidate a pending path', () async {
    final gate = Completer<PathResult>();
    final fake = _TestSetupSession(pathGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.pathStarted.future;
    session.selectCoverage(SetupCoverage.tun);
    gate.complete(_connectedPath());
    await operation;

    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('region changes invalidate a pending path', () async {
    final gate = Completer<PathResult>();
    final fake = _TestSetupSession(pathGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.pathStarted.future;
    session.selectRegion('RU');
    gate.complete(_connectedPath());
    await operation;

    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('selected profile changes invalidate a pending path', () async {
    final gate = Completer<PathResult>();
    final fake = _TestSetupSession(pathGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final operation = harness.container
        .read(setupSessionProvider.notifier)
        .check();
    await fake.pathStarted.future;

    harness.container
        .read(profilesProvider.notifier)
        .put(harness.profile.copyWith(label: 'Changed profile'));
    gate.complete(_connectedPath());
    await operation;

    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('a Core epoch change invalidates a pending path', () async {
    final gate = Completer<PathResult>();
    final fake = _TestSetupSession(pathGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final operation = session.check();
    await fake.pathStarted.future;
    harness.container
        .read(routeTrackerProvider.notifier)
        .applySnapshot(const RouteSnapshot(coreEpoch: 3, routeVersion: 5));
    gate.complete(_connectedPath());
    await operation;

    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('changing the test URL invalidates a pending path', () async {
    final gate = Completer<PathResult>();
    final fake = _TestSetupSession(pathGate: gate);
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
    await fake.pathStarted.future;
    final settings = harness.container.read(patchClashConfigProvider);
    harness.container.read(patchClashConfigProvider.notifier).value = settings
        .copyWith(testUrl: 'https://example.org/');
    gate.complete(_connectedPath());
    await operation;

    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
      isNot(SetupVerdict.connected),
    );
  });

  test('stopping the Core invalidates a connected result in flight', () async {
    final gate = Completer<PathResult>();
    final fake = _TestSetupSession(pathGate: gate);
    final harness = makeHarness(running: true, session: fake);
    addTearDown(harness.container.dispose);
    final session = harness.container.read(setupSessionProvider.notifier);

    final stopped = Completer<void>();
    harness.container.listen(
      routeTrackerProvider.select((route) => route.proxied),
      (_, proxied) {
        if (!proxied) stopped.complete();
      },
    );

    final operation = session.check();
    await fake.pathStarted.future;
    harness.container.read(runTimeProvider.notifier).value = null;
    // The answer must land after the tracker has seen the stop.
    await stopped.future;
    gate.complete(_connectedPath());
    await operation;

    expect(
      harness.container.read(setupSessionProvider).outcome?.verdict,
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
      harness.container.read(setupSessionProvider).outcome?.verdict,
      isNot(SetupVerdict.connected),
    );
    expect(harness.container.read(initProvider), isFalse);
    expect(fake.pathCalls, 0);
  });

  test('disposing during a pending path tolerates its late result', () async {
    final gate = Completer<PathResult>();
    final fake = _TestSetupSession(pathGate: gate);
    final harness = makeHarness(running: true, session: fake);

    final operation = harness.container
        .read(setupSessionProvider.notifier)
        .check();
    await fake.pathStarted.future;
    harness.container.dispose();
    gate.complete(_connectedPath());
    await operation;
  });

  group('regional direct routes', () {
    const russia = AppSettingProps(
      setupCompleted: false,
      acceptedDisclaimerVersion: disclaimerVersion,
      setupStep: 4,
      setupCoverage: 'tun',
      setupRegionCode: 'RU',
      setupRegionChosen: true,
    );

    test('checking adds the region preset to the global rules', () async {
      final harness = makeHarness(settings: russia);
      addTearDown(harness.container.dispose);

      await harness.container.read(setupSessionProvider.notifier).check();

      expect(harness.session.directRules, [
        ['GEOSITE,category-ru,DIRECT', 'GEOIP,RU,DIRECT,no-resolve'],
      ]);
      expect(harness.container.read(appSettingProvider).regionCode, 'RU');
    });

    test('a declined preset adds no rules and stays declined', () async {
      final harness = makeHarness(settings: russia);
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      session.selectDirectRoutes(false);
      await session.check();

      expect(harness.session.directRules, isEmpty);
      expect(
        harness.container.read(appSettingProvider).setupDirectRoutes,
        isFalse,
      );
    });

    test('a neutral region adds no rules', () async {
      final harness = makeHarness(
        settings: russia.copyWith(setupRegionCode: null),
      );
      addTearDown(harness.container.dispose);

      await harness.container.read(setupSessionProvider.notifier).check();

      expect(harness.session.directRules, isEmpty);
    });

    test('Android VPN lets the found local apps bypass it', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..nativeAcknowledgement = DateTime.utc(2025)
        ..domesticApps = ['ru.bank', 'ru.gov'];
      final harness = makeHarness(session: fake, settings: russia);
      addTearDown(harness.container.dispose);
      harness.container
          .read(vpnSettingProvider.notifier)
          .update(
            (props) => props.copyWith(
              accessControlProps: const AccessControlProps(
                rejectList: ['org.game'],
              ),
            ),
          );

      await harness.container.read(setupSessionProvider.notifier).check();

      final access = harness.container
          .read(vpnSettingProvider)
          .accessControlProps;
      expect(fake.scannedRegions, ['RU']);
      expect(access.enable, isTrue);
      expect(access.mode, AccessControlMode.rejectSelected);
      expect(access.rejectList, ['org.game', 'ru.bank', 'ru.gov']);
    });

    test('an allow list drops the local apps instead', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..nativeAcknowledgement = DateTime.utc(2025)
        ..domesticApps = ['ru.bank'];
      final harness = makeHarness(session: fake, settings: russia);
      addTearDown(harness.container.dispose);
      harness.container
          .read(vpnSettingProvider.notifier)
          .update(
            (props) => props.copyWith(
              accessControlProps: const AccessControlProps(
                enable: true,
                mode: AccessControlMode.acceptSelected,
                acceptList: ['ru.bank', 'org.browser'],
              ),
            ),
          );

      await harness.container.read(setupSessionProvider.notifier).check();

      final access = harness.container
          .read(vpnSettingProvider)
          .accessControlProps;
      expect(access.mode, AccessControlMode.acceptSelected);
      expect(access.acceptList, ['org.browser']);
    });

    test('changing the region scans its apps again', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = ['ru.bank'];
      final harness = makeHarness(session: fake, settings: russia);
      addTearDown(harness.container.dispose);
      final session = harness.container.read(setupSessionProvider.notifier);

      await session.scanDirectApps();
      expect(harness.container.read(setupSessionProvider).draft.directApps, [
        'ru.bank',
      ]);
      fake.domesticApps = ['ir.bank'];
      session.selectRegion('IR');
      await session.scanDirectApps();

      expect(fake.scannedRegions, ['RU', 'IR']);
      expect(harness.container.read(setupSessionProvider).draft.directApps, [
        'ir.bank',
      ]);
    });

    test('local proxy coverage does not touch access control', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = ['ru.bank'];
      final harness = makeHarness(
        session: fake,
        settings: russia.copyWith(setupCoverage: 'local'),
      );
      addTearDown(harness.container.dispose);

      await harness.container.read(setupSessionProvider.notifier).check();

      expect(fake.scannedRegions, isEmpty);
      expect(
        harness.container.read(vpnSettingProvider).accessControlProps.enable,
        isFalse,
      );
    });
  });
}
