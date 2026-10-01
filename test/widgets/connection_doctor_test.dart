import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/ntp.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/views/dashboard/widgets/network_detection.dart' as view;
import 'package:reclash/views/settings/url_scheme.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/views/tools/tools.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/glyph_finders.dart';
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
  DoctorCapabilities capabilities = const DoctorCapabilities(),
  DoctorGenerations generations = const DoctorGenerations(),
  DoctorGenerations startGenerations = const DoctorGenerations(),
  List<DoctorHealAudit> healAudit = const [],
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
    capabilities: capabilities,
    generations: generations,
    startGenerations: startGenerations,
    healAudit: healAudit,
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
      await tester.scrollUntilVisible(find.textContaining('75 ms').first, 200);

      expect(find.textContaining('75 ms'), findsWidgets);
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
    // The path leads with five stations that read "Not checked" until an exam
    // runs, so an untested path is honest rather than a blank projection.
    expect(find.text('Not checked'), findsWidgets);
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
    expect(find.byGlyph(AppGlyphs.close), findsNothing);
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

    final rawEvidence = find.text('Raw evidence');
    await tester.scrollUntilVisible(rawEvidence, 200);
    await tester.tap(rawEvidence);
    await tester.pumpAndSettle();

    expect(find.text('Failed · Confirmed'), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byTooltip('Consequence of an earlier fault'),
        matching: find.byGlyph(AppGlyphs.subItem),
      ),
      findsOneWidget,
    );
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

  testWidgets('surfaces a stale diagnosis without presenting it as current', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        freshUntil: DateTime.now().millisecondsSinceEpoch - 1,
        evidenceDropped: 7,
      ),
      size: const Size(900, 1400),
    );

    // The stale caveat is the diagnosis meaning on the main screen; the exam is
    // never labelled as a current result.
    expect(find.text('Outdated'), findsNothing);
    expect(
      find.text(
        'The environment may have changed. Refresh or run a new check before acting on this result.',
      ),
      findsWidgets,
    );

    // The console carries the stale status inside its diagnosis rows.
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    final outdated = find.text('Outdated');
    await tester.scrollUntilVisible(outdated, 200);
    expect(outdated, findsOneWidget);
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
    // Deep is now a mode segment on the console, run by the shared button.
    await tester.tap(find.text('Deep'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Run a check'));
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

  testWidgets('console warns when evidence predates a change', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        generations: const DoctorGenerations(config: 3),
        startGenerations: const DoctorGenerations(config: 1),
      ),
    );

    // The drift caveat is an expert detail, kept off the verdict screen.
    expect(
      find.textContaining('Network or configuration changed since this check'),
      findsNothing,
    );
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Network or configuration changed since this check'),
      findsOneWidget,
    );
  });

  testWidgets('console records repair attempts and their outcome', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        healAudit: const [DoctorHealAudit(actionId: 'flushDns', outcome: 'ok')],
      ),
    );

    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    final attempts = find.text('Repair attempts');
    await tester.scrollUntilVisible(attempts, 200);
    expect(attempts, findsOneWidget);
    // The flush label also names the run panel's flush lever, so the audit row
    // shares it; its unique "ok" outcome proves the attempt was recorded.
    expect(find.text('Flush DNS cache'), findsWidgets);
    expect(find.text('ok'), findsOneWidget);
  });

  testWidgets('console shows the empty repair audit when none ran', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(tester, core, _snapshot());

    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    final empty = find.text('No repair attempts yet');
    await tester.scrollUntilVisible(empty, 200);
    expect(empty, findsOneWidget);
  });

  testWidgets('console run panel disables the check when ineligible', (
    tester,
  ) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(
        state: DoctorExamState.complete,
        actions: const [DoctorAction(id: 'startStandard', eligible: false)],
      ),
    );

    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    expect(find.text('Not available right now'), findsOneWidget);
    final runButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Run a check'),
    );
    expect(runButton.onPressed, isNull);
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
                glyph: AppGlyphs.requests,
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

  testWidgets('Tools desktop shows the placeholder before any selection', (
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
    await tester.ensureVisible(find.text('URL Scheme'));
    await tester.pumpAndSettle();
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

  testWidgets('Tools desktop drills into a sub-screen in place', (
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
      find.text('Advanced configuration'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Advanced configuration'));
    await tester.pumpAndSettle();

    expect(find.text('NTP'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.arrowBack), findsNothing);

    await tester.tap(find.text('NTP'));
    await tester.pumpAndSettle();

    // Opening a row pushes the sub-screen into the same column with a back
    // affordance instead of floating a blurred sheet over the whole page.
    expect(find.byType(NtpView), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.arrowBack), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(NtpView), findsNothing);
    expect(find.text('NTP'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.arrowBack), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools desktop breadcrumb jumps back to an outer level', (
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
      find.text('Advanced configuration'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Advanced configuration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NTP'));
    await tester.pumpAndSettle();

    // Two levels deep the detail bar shows the parent as a tappable crumb;
    // tapping it pops straight back to that level instead of one step at a time.
    final crumb = find.widgetWithText(TextButton, 'Advanced configuration');
    expect(crumb, findsOneWidget);
    expect(find.byType(NtpView), findsOneWidget);

    await tester.tap(crumb);
    await tester.pumpAndSettle();

    expect(find.byType(NtpView), findsNothing);
    expect(find.byGlyph(AppGlyphs.arrowBack), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools desktop search reaches a setting inside a screen', (
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

    await tester.enterText(find.byType(TextField), 'ntp');
    await tester.pumpAndSettle();

    // The result is grouped under the same heading its tool lives beneath, and
    // NTP is a setting one screen deep rather than a top-level tool row.
    expect(find.text('Configuration'), findsOneWidget);
    expect(find.textContaining('NTP'), findsWidgets);

    await tester.tap(find.textContaining('NTP').first);
    await tester.pumpAndSettle();

    // A deep hit opens the screen that owns the setting, not the setting alone.
    expect(find.byType(AdvancedConfigView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools desktop search highlights the exact row it lands on', (
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

    await tester.enterText(find.byType(TextField), 'ntp');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('NTP').first);
    await tester.pumpAndSettle();

    // Opening the owning screen wraps the matched row in its focus target, so
    // it scrolls into view and pulses instead of leaving the reader at the top.
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_SettingFocusTarget',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools search indexes settings buried two screens deep', (
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

    // Canaries live under Smart routing's region details, two screens in; they
    // still have to answer a search and open the screen that owns them.
    await tester.enterText(find.byType(TextField), 'canary');
    await tester.pumpAndSettle();
    expect(find.textContaining('canaries'), findsWidgets);

    await tester.tap(find.textContaining('Foreign canaries').first);
    await tester.pumpAndSettle();
    expect(find.byType(RoutingStudioView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools search remaps a query typed on the wrong layout', (
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

    // 'тез' is what 'ntp' becomes on the Russian ЙЦУКЕН layout; the search
    // remaps the keys back so a wrong-layout query still lands.
    await tester.enterText(find.byType(TextField), 'тез');
    await tester.pumpAndSettle();

    expect(find.textContaining('NTP'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools search bridges synonyms across languages', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const ToolsView(),
      size: const Size(1200, 900),
    );

    // 'цвет' (colour) is not a word in any English label; the synonym map ties
    // it to the appearance screen anyway.
    await tester.enterText(find.byType(TextField), 'цвет');
    await tester.pumpAndSettle();

    expect(find.textContaining('Appearance'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools search tolerates a single typo', (tester) async {
    final core = _MockCoreHandler();
    await _pumpDoctor(
      tester,
      core,
      _snapshot(),
      child: const ToolsView(),
      size: const Size(1200, 900),
    );

    // 'advenced' is one substitution from 'advanced' and matches no label as a
    // substring, so only the bounded fuzzy fallback can reach the screen.
    await tester.enterText(find.byType(TextField), 'advenced');
    await tester.pumpAndSettle();

    expect(find.textContaining('Advanced configuration'), findsWidgets);
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

    // The verdict now leads the hero, so its plain-language reading sits at the
    // top of the screen even at extreme text size; scrollUntilVisible is a
    // safety net that must not surface an overflow while reaching it.
    final headline = find.text('Watching real traffic');
    await tester.scrollUntilVisible(headline, 200);
    expect(headline, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
