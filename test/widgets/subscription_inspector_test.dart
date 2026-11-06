import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, SubscriptionSnapshot snapshot) =>
      tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          child: SubscriptionInspectorSheet(snapshot: snapshot),
        ),
      );

  testWidgets('shows each field under its header with trust and staleness', (
    tester,
  ) async {
    await pump(
      tester,
      SubscriptionSnapshot(
        metadata: const SubscriptionMetadata({
          'subscription.type': 'dev',
          'update.intervalMinutes': 60,
          'settings.flags': ['autorun', 'minimize'],
        }),
        receivedAt: DateTime(2026),
        staleFields: const ['update.intervalMinutes'],
        warnings: const ['hide-url: not a boolean'],
      ),
    );

    expect(find.text('provider.type'), findsOneWidget);
    expect(find.text('dev'), findsOneWidget);
    expect(find.text('profile-update-interval'), findsOneWidget);
    expect(find.text('hint · stale'), findsOneWidget);
    expect(find.text('autorun, minimize'), findsOneWidget);
    expect(find.text('hide-url: not a boolean'), findsOneWidget);
  });

  testWidgets('a field outside the registry shows its path untagged', (
    tester,
  ) async {
    await pump(
      tester,
      SubscriptionSnapshot(
        metadata: const SubscriptionMetadata({'custom.path': 'x'}),
        receivedAt: DateTime(2026),
      ),
    );

    expect(find.text('custom.path'), findsOneWidget);
    expect(find.text('x'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
