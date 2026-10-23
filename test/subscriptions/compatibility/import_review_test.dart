import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/app_localizations.dart';
import 'package:reclash/subscriptions/compatibility/import_policy.dart';
import 'package:reclash/subscriptions/compatibility/import_review.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/imports/routing/skipped_node.dart';
import 'package:material_ui/material_ui.dart';
import '../../helpers/test_app.dart';

Future<Future<SubscriptionImportApproval?>> _open(
  WidgetTester tester,
  SubscriptionImportSummary summary, {
  String sourceScope = '',
}) async {
  late BuildContext host;
  await tester.pumpWidget(
    TestApp(
      wrapInProviderScope: true,
      child: Builder(
        builder: (context) {
          host = context;
          return const SizedBox.expand();
        },
      ),
    ),
  );
  final result = Navigator.of(host).push(
    MaterialPageRoute<SubscriptionImportApproval>(
      builder: (_) => SubscriptionImportReviewPage(
        format: SubscriptionFormat.singbox,
        summary: summary,
        sourceScope: sourceScope,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('one tap on the counted add button accepts the losses', (
    tester,
  ) async {
    final result = await _open(
      tester,
      const SubscriptionImportSummary(
        nodes: 3,
        skippedNodes: [
          SkippedNode(
            name: 'Frankfurt',
            kind: 'wireguard',
            reason: SkippedNodeReason.protocol,
          ),
        ],
        ignoredSections: ['route', 'dns'],
        hasLosses: true,
      ),
    );
    final l10n = currentAppLocalizations;

    expect(find.text(l10n.subscriptionImportPartial(3, 4)), findsOneWidget);
    expect(find.text('Frankfurt'), findsOneWidget);
    expect(find.text(l10n.subscriptionImportReasonProtocol), findsOneWidget);
    expect(find.text('route'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);

    await tester.tap(find.text(l10n.subscriptionImportAdd(3)));
    await tester.pumpAndSettle();
    final approval = await result;
    expect(approval, isNotNull);
    expect(approval!.rememberedPolicy, isNull);
  });

  testWidgets('long skipped lists collapse behind show all', (tester) async {
    await _open(
      tester,
      SubscriptionImportSummary(
        nodes: 1,
        skippedNodes: [
          for (var i = 0; i < 8; i++)
            SkippedNode(
              name: 'node $i',
              kind: 'vless',
              reason: SkippedNodeReason.transport,
            ),
        ],
        hasLosses: true,
      ),
    );
    final l10n = currentAppLocalizations;

    expect(find.text('node 7'), findsNothing);
    await tester.ensureVisible(find.text(l10n.subscriptionImportShowAll(8)));
    await tester.tap(find.text(l10n.subscriptionImportShowAll(8)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('node 7'));
    expect(find.text('node 7'), findsOneWidget);
    expect(find.text(l10n.subscriptionImportShowAll(8)), findsNothing);
  });

  testWidgets('remembering consent returns a policy for the source', (
    tester,
  ) async {
    final result = await _open(
      tester,
      const SubscriptionImportSummary(
        nodes: 2,
        ignoredSections: ['route'],
        hasLosses: true,
      ),
      sourceScope: 'https://sub.example',
    );
    final l10n = currentAppLocalizations;

    expect(find.text(l10n.subscriptionImportAllAdded(2)), findsOneWidget);
    await tester.tap(find.text(l10n.subscriptionImportRememberConsent));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.subscriptionImportAdd(2)));
    await tester.pumpAndSettle();
    expect((await result)?.rememberedPolicy, isNotNull);
  });

  testWidgets('a lossy import with no nodes can only be closed', (
    tester,
  ) async {
    final result = await _open(
      tester,
      const SubscriptionImportSummary(
        ignoredSections: ['routing'],
        hasLosses: true,
      ),
    );
    final l10n = currentAppLocalizations;

    expect(find.text(l10n.subscriptionImportNoNodes), findsOneWidget);
    expect(find.text(l10n.subscriptionImportAdd(0)), findsNothing);
    await tester.tap(find.text(l10n.close));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
