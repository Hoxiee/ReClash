import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/network_detection.dart' as view;
import 'package:reclash/views/tools/tools.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/views/settings/url_scheme.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';

class _MockCoreHandler extends Mock implements CoreHandlerInterface {}

DoctorSnapshot _snapshot({
  int revision = 1,
  bool supported = true,
  DoctorExamState state = DoctorExamState.observing,
  DoctorHealth health = DoctorHealth.unknown,
  DoctorConfidence confidence = DoctorConfidence.insufficient,
  DoctorScope scope = DoctorScope.unknown,
  DoctorPathKind pathKind = DoctorPathKind.unknown,
  DoctorCaptureState captureState = DoctorCaptureState.unknown,
  List<DoctorStage> stages = const [],
  DoctorLayer layer = DoctorLayer.unknown,
  String causeCode = '',
  String examId = '',
  DoctorExamMode mode = DoctorExamMode.unknown,
  DoctorProgress progress = const DoctorProgress(),
  int? freshUntil,
  int evidenceDropped = 0,
  List<DoctorEvidence> evidence = const [],
  List<DoctorAction> actions = const [],
  List<DoctorIncident> incidents = const [],
}) {
  return DoctorSnapshot(
    revision: revision,
    supported: supported,
    state: state,
    health: health,
    confidence: confidence,
    scope: scope,
    pathKind: pathKind,
    captureState: captureState,
    stages: stages,
    layer: layer,
    causeCode: causeCode,
    examId: examId,
    mode: mode,
    progress: progress,
    freshUntil: freshUntil ?? DateTime.now().millisecondsSinceEpoch + 60000,
    evidenceDropped: evidenceDropped,
    evidence: evidence,
    actions: actions,
    incidents: incidents,
  );
}

Future<ProviderContainer> _pumpDoctor(
  WidgetTester tester,
  _MockCoreHandler core,
  DoctorSnapshot snapshot, {
  Size size = const Size(900, 900),
  double textScaleFactor = 1,
  Widget child = const ConnectionDoctorView(),
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  when(() => core.doctorSnapshot()).thenAnswer((_) async => snapshot);

  final container = ProviderContainer(
    overrides: [
      coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(child: child),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const DoctorStartParams(mode: DoctorExamMode.standard),
    );
    registerFallbackValue(const DoctorCancelParams(examId: 'exam'));
    registerFallbackValue(const DoctorHealParams(examId: 'exam', revision: 1));
  });

  for (final settings in [
    const MilestoneProps(),
    const MilestoneProps(unlocked: {'auscultation'}),
    const MilestoneProps(findingsEnabled: false),
  ]) {
    testWidgets('evidence timings are independent of findings: $settings', (
      tester,
    ) async {
      await _pumpDoctor(
        tester,
        _MockCoreHandler(),
        _snapshot(
          evidence: const [
            DoctorEvidence(layer: DoctorLayer.dns, durationBucketMs: 75),
            DoctorEvidence(layer: DoctorLayer.route),
          ],
        ),
        overrides: [
          milestoneSettingProvider.overrideWithBuild((_, _) => settings),
        ],
      );

      await tester.tap(find.text('Technical details'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('75 ms'), 200);

      expect(find.textContaining('75 ms'), findsOneWidget);
      expect(find.textContaining('0 ms'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('shows unsupported Core without diagnostic details', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(tester, core, const DoctorSnapshot());

    expect(find.text('Doctor unavailable'), findsOneWidget);
    expect(
      find.text('This Core version does not support connection diagnosis.'),
      findsOneWidget,
    );
    expect(
      find.text('Update Core to use connection diagnosis.'),
      findsOneWidget,
    );
    expect(find.text('Diagnosis'), findsNothing);
    expect(find.text('Run check'), findsNothing);
  });

  testWidgets('shows passive observing state and empty projections', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(tester, core, _snapshot());

    expect(find.text('Watching real traffic'), findsOneWidget);
    expect(find.text('Connection path'), findsOneWidget);
    expect(find.text('Not checked'), findsNothing);
    expect(find.text('Technical details'), findsOneWidget);
    expect(find.text('No usable evidence yet'), findsNothing);

    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();

    expect(find.text('No usable evidence yet'), findsOneWidget);
    final noIncidents = find.text('No completed checks yet');
    await tester.scrollUntilVisible(noIncidents, 200);
    expect(noIncidents, findsOneWidget);
    expect(find.text('Insufficient'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
  });

  testWidgets('shows a fully healthy path', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.complete,
        health: DoctorHealth.healthy,
        confidence: DoctorConfidence.confirmed,
        pathKind: DoctorPathKind.vpn,
        captureState: DoctorCaptureState.active,
        examId: 'healthy-exam',
        stages: const [
          DoctorStage(id: 'app', state: DoctorStageState.passed),
          DoctorStage(id: 'ingress', state: DoctorStageState.passed),
          DoctorStage(id: 'route', state: DoctorStageState.passed),
          DoctorStage(id: 'internet', state: DoctorStageState.passed),
          DoctorStage(id: 'response', state: DoctorStageState.passed),
        ],
      ),
    );

    for (final id in ['app', 'ingress', 'route', 'internet', 'response']) {
      expect(
        tester.getSemantics(find.byKey(ValueKey('doctor_path_$id'))).label,
        contains('Working'),
      );
    }

    final appLocalizations = await AppLocalizations.load(const Locale('en'));
    expect(
      connectionDoctorDescription(
        appLocalizations,
        _snapshot(
          state: DoctorExamState.complete,
          health: DoctorHealth.healthy,
          confidence: DoctorConfidence.confirmed,
          pathKind: DoctorPathKind.vpn,
          captureState: DoctorCaptureState.active,
          stages: const [
            DoctorStage(id: 'app', state: DoctorStageState.passed),
            DoctorStage(id: 'ingress', state: DoctorStageState.passed),
            DoctorStage(id: 'route', state: DoctorStageState.passed),
            DoctorStage(id: 'internet', state: DoctorStageState.passed),
            DoctorStage(id: 'response', state: DoctorStageState.passed),
          ],
        ),
        easterEggRoll: 0,
      ),
      'The patient is suspiciously healthy.',
    );
  });

  testWidgets('shows first fault and downstream consequences', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.complete,
        health: DoctorHealth.broken,
        confidence: DoctorConfidence.confirmed,
        layer: DoctorLayer.dns,
        stages: const [
          DoctorStage(id: 'app', state: DoctorStageState.unknown),
          DoctorStage(id: 'ingress', state: DoctorStageState.unknown),
          DoctorStage(
            id: 'route',
            state: DoctorStageState.failed,
            layer: DoctorLayer.dns,
          ),
          DoctorStage(id: 'internet', state: DoctorStageState.consequence),
          DoctorStage(id: 'response', state: DoctorStageState.consequence),
        ],
        evidence: const [
          DoctorEvidence(
            layer: DoctorLayer.dns,
            outcome: DoctorEvidenceOutcome.failed,
            confidence: DoctorConfidence.confirmed,
          ),
          DoctorEvidence(
            layer: DoctorLayer.transport,
            outcome: DoctorEvidenceOutcome.failed,
            confidence: DoctorConfidence.confirmed,
            consequence: true,
          ),
        ],
      ),
    );

    expect(
      tester.getSemantics(find.byKey(const ValueKey('doctor_path_app'))).label,
      contains('Not checked'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_ingress')))
          .label,
      contains('Not checked'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_route')))
          .label,
      contains('Problem here'),
    );
    for (final id in ['internet', 'response']) {
      expect(
        tester.getSemantics(find.byKey(ValueKey('doctor_path_$id'))).label,
        contains('Not checked after an earlier problem'),
      );
    }
  });

  testWidgets('blames the verdict stage when no stage was marked failed', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.complete,
        health: DoctorHealth.broken,
        confidence: DoctorConfidence.confirmed,
        layer: DoctorLayer.route,
        causeCode: 'routeOther',
      ),
    );

    // The core reported the fault only through the verdict layer, not a failed
    // stage, yet the map still marks the blamed stage and dims what follows.
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_route')))
          .label,
      contains('Problem here'),
    );
    for (final id in ['app', 'ingress']) {
      expect(
        tester.getSemantics(find.byKey(ValueKey('doctor_path_$id'))).label,
        contains('Not checked'),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows current examined stage without guessing later stages', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.examining,
        progress: const DoctorProgress(completed: 2, total: 5),
        stages: const [
          DoctorStage(id: 'ingress', state: DoctorStageState.passed),
          DoctorStage(id: 'route', state: DoctorStageState.checking),
        ],
        evidence: const [
          DoctorEvidence(
            layer: DoctorLayer.ingress,
            outcome: DoctorEvidenceOutcome.succeeded,
            confidence: DoctorConfidence.confirmed,
          ),
        ],
      ),
    );

    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_ingress')))
          .label,
      contains('Working'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_route')))
          .label,
      contains('Checking'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_response')))
          .label,
      contains('Not checked'),
    );
  });

  testWidgets('shows expected VPN as inactive without greening the path', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.complete,
        health: DoctorHealth.broken,
        confidence: DoctorConfidence.confirmed,
        pathKind: DoctorPathKind.vpn,
        captureState: DoctorCaptureState.inactive,
        layer: DoctorLayer.capture,
        causeCode: 'vpnNotActive',
        stages: const [DoctorStage(id: 'app', state: DoctorStageState.failed)],
      ),
    );

    expect(find.text('VPN is not active'), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('doctor_path_app'))).label,
      contains('Problem here'),
    );
    for (final id in ['ingress', 'route', 'internet', 'response']) {
      expect(
        tester.getSemantics(find.byKey(ValueKey('doctor_path_$id'))).label,
        contains('Not checked'),
      );
    }
  });

  testWidgets('marker-only reachability proves only the response stage', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.complete,
        health: DoctorHealth.healthy,
        confidence: DoctorConfidence.confirmed,
        pathKind: DoctorPathKind.localProxy,
        captureState: DoctorCaptureState.notApplicable,
        stages: const [
          DoctorStage(id: 'app', state: DoctorStageState.notApplicable),
          DoctorStage(id: 'ingress', state: DoctorStageState.notApplicable),
          DoctorStage(id: 'response', state: DoctorStageState.passed),
        ],
      ),
    );

    expect(find.text('Test address is reachable'), findsOneWidget);
    for (final id in ['route', 'internet']) {
      expect(
        tester.getSemantics(find.byKey(ValueKey('doctor_path_$id'))).label,
        contains('Not checked'),
      );
    }
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_response')))
          .label,
      contains('Working'),
    );
  });

  testWidgets('local proxy capture is not applicable', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        pathKind: DoctorPathKind.localProxy,
        captureState: DoctorCaptureState.notApplicable,
        stages: const [
          DoctorStage(id: 'app', state: DoctorStageState.notApplicable),
          DoctorStage(id: 'ingress', state: DoctorStageState.notApplicable),
        ],
      ),
    );

    expect(find.text('Local proxy'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_ingress')))
          .label,
      contains('Not required'),
    );
  });

  testWidgets('does not present stale fault as current', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.complete,
        health: DoctorHealth.broken,
        confidence: DoctorConfidence.confirmed,
        layer: DoctorLayer.dial,
        freshUntil: DateTime.now().millisecondsSinceEpoch - 1,
      ),
    );

    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_internet')))
          .label,
      contains('Not checked'),
    );
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('opening the screen answers with a check of its own', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    final idle = _snapshot(
      revision: 5,
      actions: const [DoctorAction(id: 'startStandard', eligible: true)],
    );
    when(() => core.startDoctor(any())).thenAnswer(
      (_) async => _snapshot(
        revision: 6,
        state: DoctorExamState.complete,
        health: DoctorHealth.healthy,
        confidence: DoctorConfidence.confirmed,
        stages: const [
          DoctorStage(id: 'ingress', state: DoctorStageState.passed),
        ],
      ),
    );
    await _pumpDoctor(tester, core, idle);

    final started = verify(
      () => core.startDoctor(captureAny()),
    ).captured.cast<DoctorStartParams>().toList();
    expect(started.map((value) => value.mode), [DoctorExamMode.standard]);
    expect(find.text('Connection looks healthy'), findsOneWidget);
    expect(find.text('Watching real traffic'), findsNothing);
  });

  testWidgets('opening the screen respects an ineligible check', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        actions: const [DoctorAction(id: 'startStandard', eligible: false)],
      ),
    );
    verifyNever(() => core.startDoctor(any()));
    expect(find.text('Watching real traffic'), findsOneWidget);
  });

  testWidgets('opening the screen never restarts a running check', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.examining,
        examId: 'exam-9',
        progress: const DoctorProgress(phase: 'dns', completed: 1, total: 8),
        actions: const [DoctorAction(id: 'startStandard', eligible: true)],
      ),
    );
    verifyNever(() => core.startDoctor(any()));
    expect(find.text('Checking the connection'), findsOneWidget);
  });

  testWidgets('shows bounded progress and forwards cancellation', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    final examining = _snapshot(
      revision: 3,
      state: DoctorExamState.examining,
      examId: 'exam-3',
      mode: DoctorExamMode.standard,
      progress: const DoctorProgress(phase: 'route', completed: 3, total: 8),
      actions: const [DoctorAction(id: 'cancel', eligible: true)],
    );
    final cancelled = _snapshot(
      revision: 4,
      state: DoctorExamState.cancelled,
      examId: 'exam-3',
    );
    when(() => core.cancelDoctor(any())).thenAnswer((_) async => cancelled);
    await _pumpDoctor(tester, core, examining);

    expect(find.text('Checking the connection'), findsOneWidget);
    expect(find.text('Step 3 of 8'), findsOneWidget);

    await tester.tap(find.text('Cancel check'));
    await tester.pumpAndSettle();

    final params =
        verify(() => core.cancelDoctor(captureAny())).captured.single
            as DoctorCancelParams;
    expect(params.examId, 'exam-3');
    expect(find.text('Check cancelled'), findsOneWidget);
  });

  testWidgets('renders terminal diagnosis states and causal evidence', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    final snapshot = _snapshot(
      state: DoctorExamState.complete,
      health: DoctorHealth.broken,
      confidence: DoctorConfidence.confirmed,
      scope: DoctorScope.app,
      layer: DoctorLayer.dns,
      stages: const [
        DoctorStage(
          id: 'route',
          state: DoctorStageState.failed,
          layer: DoctorLayer.dns,
        ),
        DoctorStage(id: 'internet', state: DoctorStageState.consequence),
        DoctorStage(id: 'response', state: DoctorStageState.consequence),
      ],
      evidence: const [
        DoctorEvidence(
          kind: DoctorEvidenceKind.probe,
          layer: DoctorLayer.dns,
          outcome: DoctorEvidenceOutcome.failed,
          confidence: DoctorConfidence.confirmed,
        ),
        DoctorEvidence(
          kind: DoctorEvidenceKind.firstProgress,
          layer: DoctorLayer.transport,
          outcome: DoctorEvidenceOutcome.failed,
          confidence: DoctorConfidence.confirmed,
          consequence: true,
        ),
      ],
      incidents: const [
        DoctorIncident(
          examId: 'old',
          mode: DoctorExamMode.deep,
          state: DoctorExamState.inconclusive,
          confidence: DoctorConfidence.insufficient,
          layer: DoctorLayer.route,
        ),
      ],
    );
    await _pumpDoctor(tester, core, snapshot, size: const Size(900, 1400));

    expect(find.text('DNS is not working'), findsOneWidget);
    expect(find.byKey(const ValueKey('doctor_path_route')), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('doctor_path_route')))
          .label,
      contains('Problem here'),
    );
    expect(find.text('DNS'), findsNothing);

    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();

    expect(find.text('DNS'), findsWidgets);
    expect(find.text('This app'), findsOneWidget);
    expect(find.text('Confirmed'), findsWidgets);
    expect(find.text('Failed · Confirmed'), findsNWidgets(2));
    expect(find.byIcon(Icons.subdirectory_arrow_right), findsOneWidget);
  });

  testWidgets('shows inconclusive, superseded, and cancelled titles', (
    tester,
  ) async {
    final cases = <DoctorExamState, String>{
      DoctorExamState.inconclusive: 'Not enough evidence',
      DoctorExamState.superseded: 'Environment changed',
      DoctorExamState.cancelled: 'Check cancelled',
    };
    for (final entry in cases.entries) {
      final core = _MockCoreHandler();
      await _pumpDoctor(tester, core, _snapshot(state: entry.key));
      expect(find.text(entry.value), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  testWidgets('shows stale and dropped-evidence limitations', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        freshUntil: DateTime.now().millisecondsSinceEpoch - 1,
        evidenceDropped: 7,
      ),
    );

    expect(find.text('Outdated'), findsNothing);
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    expect(find.text('Outdated'), findsOneWidget);
    final staleHint = find.text(
      'The environment may have changed. Refresh or run a new check before acting on this result.',
    );
    await tester.scrollUntilVisible(staleHint, 200);
    expect(staleHint, findsOneWidget);
    final dropped = find.text(
      '7 evidence events were dropped under load; confidence was not increased.',
    );
    await tester.scrollUntilVisible(dropped, 200);
    expect(dropped, findsOneWidget);
  });

  testWidgets('only exposes eligible actions and forwards their parameters', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    final initial = _snapshot(
      revision: 8,
      examId: 'exam-8',
      state: DoctorExamState.complete,
      health: DoctorHealth.broken,
      layer: DoctorLayer.dns,
      causeCode: 'dnsCacheStale',
      actions: const [
        DoctorAction(id: 'startStandard', eligible: true),
        DoctorAction(id: 'startDeep', eligible: true),
        DoctorAction(id: 'flushDns', eligible: true),
        DoctorAction(id: 'exportRedacted', eligible: false),
      ],
    );
    when(() => core.startDoctor(any())).thenAnswer((invocation) async {
      return initial.copyWith(revision: initial.revision + 1);
    });
    when(
      () => core.flushDoctorDns(any()),
    ).thenAnswer((_) async => initial.copyWith(revision: 10));
    await _pumpDoctor(tester, core, initial);

    expect(find.text('Export report'), findsNothing);
    expect(find.text('Cancel check'), findsNothing);

    await tester.tap(find.text('Run check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flush DNS cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    final deepCheck = find.text('Deep check');
    await tester.scrollUntilVisible(deepCheck, 200);
    await tester.tap(deepCheck);
    await tester.pumpAndSettle();

    final starts = verify(
      () => core.startDoctor(captureAny()),
    ).captured.cast<DoctorStartParams>().toList();
    expect(starts.map((value) => value.mode), [
      DoctorExamMode.standard,
      DoctorExamMode.deep,
    ]);
    final heal =
        verify(() => core.flushDoctorDns(captureAny())).captured.single
            as DoctorHealParams;
    expect(heal.examId, 'exam-8');
    expect(heal.revision, 9);
    expect(heal.actionId, 'flushDns');
  });

  testWidgets('cancelling export confirmation does not call Core', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    final snapshot = _snapshot(
      actions: const [DoctorAction(id: 'exportRedacted', eligible: true)],
    );
    await _pumpDoctor(tester, core, snapshot);

    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    final exportReport = find.text('Export report');
    await tester.scrollUntilVisible(exportReport, 200);
    await tester.tap(exportReport);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('The report contains diagnostic codes'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => core.exportDoctorReport());
  });

  testWidgets('Tools puts Doctor immediately before Requests', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      size: const Size(400, 900),
      child: const ToolsView(),
      overrides: [
        moreToolsSelectorStateProvider.overrideWithValue(
          MoreToolsSelectorState(
            navigationItems: [
              NavigationItem(
                icon: const Icon(Icons.view_timeline),
                label: PageLabel.requests,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    final doctorTop = tester.getTopLeft(find.text('Connection Doctor')).dy;
    final requestsTop = tester.getTopLeft(find.text('Requests')).dy;
    expect(doctorTop, lessThan(requestsTop));
  });

  testWidgets('Tools entry opens the shared Doctor screen', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const ToolsView(),
      size: const Size(360, 760),
    );

    await tester.tap(find.text('Connection Doctor'));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectionDoctorView), findsOneWidget);
    expect(find.text('Watching real traffic'), findsOneWidget);
  });

  testWidgets('Tools desktop shows a placeholder before any selection', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const ToolsView(),
      size: const Size(1200, 900),
    );

    expect(find.text('Select a setting to view it here.'), findsOneWidget);
    expect(find.byType(ConnectionDoctorView), findsNothing);
    expect(find.text('Connection Doctor'), findsWidgets);
  });

  testWidgets('Tools desktop opens the Doctor pane when picked', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const ToolsView(),
      size: const Size(1200, 900),
    );

    await tester.tap(find.text('Connection Doctor'));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectionDoctorView), findsOneWidget);
    expect(find.text('Watching real traffic'), findsWidgets);
  });

  testWidgets('Tools desktop selects a pane inline instead of a sheet', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const ToolsView(),
      size: const Size(1200, 900),
    );

    await tester.scrollUntilVisible(
      find.text('URL Scheme'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('URL Scheme'));
    await tester.pumpAndSettle();

    expect(find.byType(UrlSchemeView), findsOneWidget);
    expect(find.byType(ConnectionDoctorView), findsNothing);
  });

  testWidgets('Tools desktop drives pane selection from the keyboard', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const ToolsView(),
      size: const Size(1200, 900),
    );

    await tester.scrollUntilVisible(
      find.text('URL Scheme'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('URL Scheme'));
    await tester.pumpAndSettle();

    bool focusedOn(Finder ancestor) {
      final context = FocusManager.instance.primaryFocus?.context;
      if (context == null || ancestor.evaluate().isEmpty) {
        return false;
      }
      final target = tester.widget(ancestor.first);
      var inside = false;
      context.visitAncestorElements((element) {
        if (element.widget == target) {
          inside = true;
          return false;
        }
        return true;
      });
      return inside;
    }

    final urlSchemeCard = find.ancestor(
      of: find.text('URL Scheme'),
      matching: find.byType(CommonCard),
    );
    for (var i = 0; i < 60 && !focusedOn(urlSchemeCard); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(focusedOn(urlSchemeCard), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(UrlSchemeView), findsOneWidget);

    // Tab traversal reaches the detail pane, so its content is operable.
    for (var i = 0; i < 60 && !focusedOn(find.byType(UrlSchemeView)); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(focusedOn(find.byType(UrlSchemeView)), isTrue);

    // Escape at the pane root neither closes the app nor drops the pane.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(UrlSchemeView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard card opens the shared Doctor screen', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const Scaffold(body: view.NetworkDetection()),
      overrides: [
        networkDetectionProvider.overrideWithValue(
          const NetworkDetectionState(isLoading: false, ipInfo: null),
        ),
      ],
    );

    await tester.tap(find.text('Network detection'));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectionDoctorView), findsOneWidget);
    expect(find.text('Watching real traffic'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a narrow screen with large text without exceptions', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        actions: const [
          DoctorAction(id: 'startStandard', eligible: true),
          DoctorAction(id: 'startDeep', eligible: true),
          DoctorAction(id: 'exportRedacted', eligible: true),
        ],
      ),
      size: const Size(360, 760),
      textScaleFactor: 1.8,
    );

    expect(find.text('Watching real traffic'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
