import 'dart:async';

import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/profiles/subscription_report.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

class _StubAction extends ProfilesAction {
  _StubAction(this.report, {this.gate});

  final SubscriptionReport report;
  final Future<void>? gate;

  @override
  Future<SubscriptionReport> buildSubscriptionReport() async {
    if (gate != null) await gate;
    return report;
  }
}

SubscriptionReport _report(SubscriptionFault fault) => SubscriptionReport(
  verdict: SubscriptionVerdict(fault: fault),
  runtimeDial: const SubscriptionDialReport(
    attempts: 120,
    success: 57,
    failure: 63,
  ),
  nodes: const [SubscriptionNodeReport(alias: 'node-01', failures: 30)],
  subscriptionUpdate: const SubscriptionUpdateReport(
    attempted: true,
    attempts: 3,
    failures: 1,
  ),
);

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester,
    SubscriptionFault fault, {
    Future<void>? gate,
    String? reportUrl,
  }) async {
    const size = Size(900, 1600);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        profilesActionProvider.overrideWith(
          () => _StubAction(_report(fault), gate: gate),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: SubscriptionReportSheet(reportUrl: reportUrl)),
        ),
      ),
    );
    if (gate == null) await tester.pumpAndSettle();
    return container;
  }

  testWidgets('surfaces the server verdict headline and facts', (tester) async {
    await pump(tester, SubscriptionFault.server);
    expect(find.text('The problem looks like the provider'), findsOneWidget);
    expect(find.text('57/120'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('Copy report link'), findsOneWidget);
    // The extra export actions stay behind the inline export menu.
    expect(find.text('Save JSON'), findsNothing);
    expect(find.text('Copy R1 code'), findsNothing);
  });

  testWidgets('export menu reveals the extra export actions', (tester) async {
    await pump(tester, SubscriptionFault.server);
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text('Copy R1 code'), findsOneWidget);
    expect(find.text('Save JSON'), findsOneWidget);
  });

  testWidgets('offers send-to-provider when the panel sets a report URL', (
    tester,
  ) async {
    await pump(
      tester,
      SubscriptionFault.server,
      reportUrl: 'https://example.com/report',
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text('Send to provider'), findsOneWidget);
  });

  testWidgets('hides send-to-provider without a report URL', (tester) async {
    await pump(tester, SubscriptionFault.server);
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text('Send to provider'), findsNothing);
  });

  testWidgets('inconclusive reads as no single cause, not a blame', (
    tester,
  ) async {
    await pump(tester, SubscriptionFault.inconclusive);
    expect(find.text('No single cause stands out'), findsOneWidget);
    expect(find.text('The problem looks like the provider'), findsNothing);
  });

  testWidgets('lands focus on the primary action after a slow load', (
    tester,
  ) async {
    final gate = Completer<void>();
    await pump(tester, SubscriptionFault.server, gate: gate.future);
    // Plain pumps run the focus settle while only the never-settling spinner is up.
    await tester.pump();
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();

    final context = FocusManager.instance.primaryFocus?.context;
    final button = context?.findAncestorWidgetOfExactType<FilledButton>();
    expect(button?.onPressed, isNotNull);
  });
}
