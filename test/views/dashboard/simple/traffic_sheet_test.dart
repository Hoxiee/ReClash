import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/features/traffic_forecast/forecast.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/views/dashboard/simple/traffic_sheet.dart';

import '../../../helpers/test_app.dart';

const _gb = 1024 * 1024 * 1024;

int get _today => usageDayOf(DateTime.now());

int _expiresInDays(int days) {
  final now = DateTime.now();
  return DateTime(
        now.year,
        now.month,
        now.day + days,
        12,
      ).millisecondsSinceEpoch ~/
      1000;
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required SubscriptionInfo info,
  List<UsageDay> days = const [],
}) async {
  tester.view
    ..physicalSize = const Size(412, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final profile =
      Profile.normal(
        label: 'Plan',
        url: 'https://subs.example.test/feed',
      ).copyWith(
        id: 7,
        subscriptionInfo: info,
        subscriptionSnapshot: SubscriptionSnapshot(
          metadata: const SubscriptionMetadata(),
          receivedAt: DateTime.utc(2026),
        ),
      );
  await tester.pumpWidget(
    TestApp(
      locale: const Locale('en'),
      overrides: [
        currentProfileProvider.overrideWithValue(profile),
        trafficUsageProvider(7).overrideWith((ref) => Stream.value(days)),
      ],
      child: const Scaffold(body: TrafficUsageSheet()),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _chart(WidgetTester tester) => tester.getRect(
  find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString() == '_DayChart',
  ),
);

void main() {
  testWidgets('shows what is left of the quota and when the plan ends', (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      info: SubscriptionInfo(
        upload: 10 * _gb,
        download: 30 * _gb,
        total: 100 * _gb,
        expire: _expiresInDays(10),
      ),
    );

    expect(find.text('Left'), findsOneWidget);
    expect(find.textContaining('of 100'), findsOneWidget);
    expect(find.text('Used 40 GB'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.textContaining('10 days left'), findsOneWidget);
  });

  testWidgets('an unlimited plan shows what was used without a quota', (
    tester,
  ) async {
    await _pumpSheet(tester, info: const SubscriptionInfo(download: 12 * _gb));

    expect(find.text('Left'), findsNothing);
    expect(find.text('Used'), findsOneWidget);
    expect(find.text('No traffic limit'), findsOneWidget);
  });

  testWidgets('a tapped bar shows its day, and a second tap the total', (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      info: const SubscriptionInfo(download: 20 * _gb, total: 100 * _gb),
      days: [
        for (var day = _today - 6; day <= _today; day++) UsageDay(day, _gb, 0),
      ],
    );
    expect(find.text('Total'), findsOneWidget);

    final chart = _chart(tester);
    final firstBar = Offset(chart.left + 4, chart.top + 40);
    await tester.tapAt(firstBar);
    await tester.pumpAndSettle();
    expect(find.text('Total'), findsNothing);
    final day = usageDateOf(_today - 6);
    final context = tester.element(find.byType(TrafficUsageSheet));
    expect(
      find.text(MaterialLocalizations.of(context).formatMediumDate(day)),
      findsOneWidget,
    );

    await tester.tapAt(firstBar);
    await tester.pumpAndSettle();
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('compares the daily average with the previous period', (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      info: const SubscriptionInfo(download: 20 * _gb, total: 100 * _gb),
      days: [
        for (var day = _today - 13; day <= _today; day++)
          UsageDay(day, day > _today - 7 ? 2 * _gb : _gb, 0),
      ],
    );

    expect(find.text('+100% vs previous period'), findsOneWidget);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.textContaining('vs previous period'), findsNothing);
  });
}
