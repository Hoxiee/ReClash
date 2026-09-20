import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/profiles/profiles.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows inactive months after 120 days', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: LastUsedTimeText(
          lastUsedAt: DateTime(2026, 1, 1),
          now: DateTime(2026, 5, 1),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Not used for 4 months'), findsOneWidget);
    expect(find.textContaining('Last used:'), findsNothing);
  });

  testWidgets('seasonal toggle restores normal relative time', (tester) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          milestoneSettingProvider.overrideWithBuild(
            (_, _) => const MilestoneProps(seasonalEnabled: false),
          ),
        ],
        child: LastUsedTimeText(
          lastUsedAt: DateTime.now().subtract(const Duration(days: 120)),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Unused for'), findsNothing);
  });
}
