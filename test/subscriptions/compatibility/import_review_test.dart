import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/app_localizations.dart';
import 'package:reclash/subscriptions/compatibility/import_review.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import '../../helpers/test_app.dart';

void main() {
  testWidgets(
    'requires explicit consent for omitted sections and skipped nodes',
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          wrapInProviderScope: true,
          child: SubscriptionImportReviewPage(
            format: SubscriptionFormat.singbox,
            summary: SubscriptionImportSummary(
              nodes: 3,
              skipped: ['unsupported: sample'],
              ignoredSections: ['route', 'dns'],
              hasLosses: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final acceptButton = find.byTooltip(
        currentAppLocalizations.subscriptionImportAccept,
      );
      await tester.tap(acceptButton);
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionImportReviewPage), findsOneWidget);
      expect(
        find.text(currentAppLocalizations.subscriptionImportAcceptSections),
        findsOneWidget,
      );
      expect(
        find.text(currentAppLocalizations.subscriptionImportAcceptPartial),
        findsOneWidget,
      );

      await tester.tap(
        find.text(currentAppLocalizations.subscriptionImportAcceptSections),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionImportReviewPage), findsOneWidget);

      await tester.tap(
        find.text(currentAppLocalizations.subscriptionImportAcceptPartial),
      );
      await tester.pumpAndSettle();
      await tester.tap(acceptButton);
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionImportReviewPage), findsNothing);
    },
  );

  testWidgets('does not permit accepting a lossy import with no nodes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestApp(
        wrapInProviderScope: true,
        child: SubscriptionImportReviewPage(
          format: SubscriptionFormat.xray,
          summary: SubscriptionImportSummary(
            ignoredSections: ['routing'],
            hasLosses: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.subscriptionImportNoNodes),
      findsOneWidget,
    );
    await tester.tap(
      find.byTooltip(currentAppLocalizations.subscriptionImportAccept),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionImportReviewPage), findsOneWidget);
  });
}
