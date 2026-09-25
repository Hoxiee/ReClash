import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_diag.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

const _decision = RcxDiagEntry(
  seq: 1,
  at: 1,
  kind: 'decision',
  msg: 'cold start: ranked 2 candidates',
  ctx: RcxDiagContext(
    terrain: 'whitelist',
    env: 'ru',
    strategy: 'balanced',
    transport: 'wifi',
    reachF: 'fail',
    reachD: 'ok',
    probesLeft: 31,
    candidates: 2,
    eligible: 2,
  ),
  cands: [
    RcxCandidateReport(
      node: 'Amsterdam #3',
      country: 'NL',
      verdict: 'preferred',
      evidence: 'live',
      latencyMs: 112,
      order: 1,
      current: true,
      trust: 'trusted',
      confidence: 'high',
      origin: 'subscription',
    ),
    RcxCandidateReport(
      node: 'Frankfurt #1',
      verdict: 'viable',
      evidence: 'fresh',
      latencyMs: 240,
      order: 2,
    ),
  ],
);

const _switch = RcxDiagEntry(
  seq: 2,
  at: 2,
  kind: 'switch',
  msg: 'incumbent dead, failing over',
  from: 'Paris #7',
  to: 'Amsterdam #3',
);

const _probe = RcxDiagEntry(
  seq: 3,
  at: 3,
  kind: 'probe',
  msg: 'probe 77.88.8.8:443 ok 24ms',
);

const _batch = RcxDiagBatch(
  entries: [_decision, _switch, _probe],
  cursor: 3,
  enabled: true,
);

Future<void> _pump(
  WidgetTester tester, {
  bool diagnostics = true,
  Future<RcxDiagBatch?> Function(int since)? logReader,
}) async {
  final container = ProviderContainer(
    overrides: [
      appSettingProvider.overrideWithBuild(
        (_, _) => AppSettingProps(smartRoutingDiagnostics: diagnostics),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        includeNavigatorKey: false,
        setTheme: false,
        child: RoutingDiagView(logReader: logReader),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// Each entry is delivered once: a second poll asks past the cursor and gets
// nothing, so the fixed batch cannot stack duplicate rows during settle.
Future<RcxDiagBatch?> Function(int since) _feed(RcxDiagBatch batch) =>
    (since) async => since == 0 ? batch : null;

void main() {
  testWidgets('logging that is off explains itself and offers the switch', (
    tester,
  ) async {
    await _pump(tester, diagnostics: false, logReader: _feed(_batch));

    expect(find.text('Diagnostics logging is off'), findsOne);
    expect(find.text('Enable logging'), findsOne);
    expect(find.text('cold start: ranked 2 candidates'), findsNothing);
  });

  testWidgets('an engine that has said nothing yet reads as waiting', (
    tester,
  ) async {
    await _pump(tester, logReader: (_) async => null);

    expect(find.text('Waiting for the engine…'), findsOne);
  });

  testWidgets('every kind the engine emits lands as its own labelled row', (
    tester,
  ) async {
    await _pump(tester, logReader: _feed(_batch));

    expect(find.text('DECISION'), findsOne);
    expect(find.text('SWITCH'), findsOne);
    expect(find.text('PROBE'), findsOne);
    expect(find.text('cold start: ranked 2 candidates'), findsOne);
    expect(find.text('probe 77.88.8.8:443 ok 24ms'), findsOne);
    expect(find.text('Paris #7 → Amsterdam #3'), findsOne);
  });

  testWidgets('a decision keeps its state and candidates one tap away', (
    tester,
  ) async {
    await _pump(tester, logReader: _feed(_batch));

    expect(find.text('State'), findsNothing);
    expect(find.text('Candidates'), findsNothing);

    await tester.tap(find.text('DECISION'));
    await tester.pumpAndSettle();

    expect(find.text('State'), findsOne);
    expect(find.text('Candidates'), findsOne);
    expect(find.textContaining('trust=trusted'), findsOne);
  });

  testWidgets('a ring that overflowed states what it dropped', (tester) async {
    await _pump(
      tester,
      logReader: _feed(
        const RcxDiagBatch(entries: [_probe], cursor: 3, dropped: 5),
      ),
    );

    expect(find.text('5 entries dropped'), findsOne);
    expect(find.text('probe 77.88.8.8:443 ok 24ms'), findsOne);
  });

  testWidgets('scrolling up pauses the tail follow, returning re-pins it', (
    tester,
  ) async {
    RcxDiagBatch fill(int base, int count) => RcxDiagBatch(
      entries: [
        for (var i = 0; i < count; i++)
          RcxDiagEntry(
            seq: base + i,
            at: base + i,
            kind: 'event',
            msg: 'row ${base + i}',
          ),
      ],
      cursor: base + count - 1,
      enabled: true,
    );

    final first = fill(1, 60);
    final second = fill(1000, 20);
    final third = fill(2000, 20);
    Future<RcxDiagBatch?> reader(int since) async {
      if (since == 0) return first;
      if (since == first.cursor) return second;
      if (since == second.cursor) return third;
      return null;
    }

    await _pump(tester, logReader: reader);

    final controller = tester
        .widget<ListView>(find.byType(ListView))
        .controller!;
    expect(
      controller.position.pixels,
      controller.position.maxScrollExtent,
      reason: 'auto-scroll pins the fresh log to the tail',
    );

    final offsetAfterScrollUp = controller.position.maxScrollExtent - 300;
    controller.jumpTo(offsetAfterScrollUp);
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(
      controller.position.pixels,
      offsetAfterScrollUp,
      reason: 'new rows must not yank a reading user back to the bottom',
    );

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(
      controller.position.pixels,
      controller.position.maxScrollExtent,
      reason: 'returning to the bottom resumes following the tail',
    );
    expect(find.text('row 2019'), findsOne);
  });
}
