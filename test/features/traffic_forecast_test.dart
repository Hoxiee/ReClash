import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/traffic_forecast/forecast.dart';

const _gb = 1 << 30;

List<UsageDay> _days(int from, List<int> bytes) => [
  for (final (index, value) in bytes.indexed)
    UsageDay(from + index, value, (index + 1) * _gb),
];

void main() {
  group('planUsageSample', () {
    test('the first sample is a baseline that spends nothing', () {
      expect(planUsageSample(last: null, used: 5 * _gb, today: 100), [
        const UsageDay(100, 0, 5 * _gb),
      ]);
    });

    test('growth on the same day adds to that day', () {
      expect(
        planUsageSample(
          last: const UsageDay(100, _gb, 5 * _gb),
          used: 7 * _gb,
          today: 100,
        ),
        [const UsageDay(100, 3 * _gb, 7 * _gb)],
      );
    });

    test('growth over days without a sample is spread to today', () {
      expect(
        planUsageSample(
          last: const UsageDay(100, _gb, 5 * _gb),
          used: 8 * _gb,
          today: 103,
        ),
        [
          const UsageDay(101, _gb, 8 * _gb),
          const UsageDay(102, _gb, 8 * _gb),
          const UsageDay(103, _gb, 8 * _gb),
        ],
      );
    });

    test('the remainder of an uneven split lands on today', () {
      final rows = planUsageSample(
        last: const UsageDay(100, 0, 0),
        used: 10,
        today: 103,
      );
      expect(rows.map((row) => row.bytes), [3, 3, 4]);
    });

    test('a counter that went down is a reset and spends nothing', () {
      expect(
        planUsageSample(
          last: const UsageDay(100, _gb, 9 * _gb),
          used: _gb ~/ 2,
          today: 101,
        ),
        [const UsageDay(101, 0, _gb ~/ 2)],
      );
    });

    test('a reset on the day keeps what the day already spent', () {
      expect(
        planUsageSample(
          last: const UsageDay(100, _gb, 9 * _gb),
          used: 1,
          today: 100,
        ),
        [const UsageDay(100, _gb, 1)],
      );
    });

    test('a gap past the retention starts over instead of smearing', () {
      expect(
        planUsageSample(
          last: const UsageDay(100, _gb, _gb),
          used: 2 * _gb,
          today: 100 + usageRetentionDays + 1,
        ),
        [const UsageDay(100 + usageRetentionDays + 1, 0, 2 * _gb)],
      );
    });
  });

  group('usagePace', () {
    test('needs a whole day after the first sample', () {
      expect(usagePace(const [], 100), isNull);
      expect(usagePace(const [UsageDay(100, 0, 1)], 100), isNull);
      expect(
        usagePace(const [UsageDay(99, 0, 1), UsageDay(100, 5, 2)], 100),
        isNull,
      );
    });

    test('averages the whole days between the first sample and today', () {
      final days = [
        const UsageDay(97, 0, 1),
        const UsageDay(98, 2 * _gb, 1),
        const UsageDay(99, 4 * _gb, 1),
        const UsageDay(100, 50 * _gb, 1),
      ];
      expect(usagePace(days, 100), 3 * _gb);
    });

    test('reads only the last week', () {
      final days = [
        const UsageDay(80, 0, 1),
        const UsageDay(85, 700 * _gb, 1),
        for (var day = 93; day < 100; day++) UsageDay(day, 7 * _gb, 1),
      ];
      expect(usagePace(days, 100), 7 * _gb);
    });

    test('counts a day without a row as nothing spent', () {
      final days = [const UsageDay(95, 0, 1), const UsageDay(99, 4 * _gb, 1)];
      expect(usagePace(days, 100), _gb);
    });
  });

  group('forecastTraffic', () {
    final now = DateTime(2026, 11, 3, 12);
    final today = usageDayOf(now);
    final history = _days(today - 3, [0, 2 * _gb, 2 * _gb, 2 * _gb]);

    TrafficForecast forecast({
      List<UsageDay>? days,
      int used = 10 * _gb,
      DateTime? expiry,
    }) => forecastTraffic(
      days: days ?? history,
      used: used,
      total: 100 * _gb,
      now: now,
      expiry: expiry,
    );

    test('gathers statistics while there is no whole day', () {
      expect(
        forecast(days: [UsageDay(today, 0, 1)]).kind,
        TrafficForecastKind.gathering,
      );
    });

    test('a spent quota is depleted whatever the pace', () {
      expect(forecast(used: 100 * _gb).kind, TrafficForecastKind.depleted);
    });

    test('no spending means plenty', () {
      final idle = _days(today - 3, [0, 0, 0, 0]);
      expect(forecast(days: idle).kind, TrafficForecastKind.plenty);
    });

    test('names the day it runs out when the plan has no end', () {
      final result = forecast();
      expect(result.kind, TrafficForecastKind.until);
      expect(result.perDay, 2 * _gb);
      expect(result.runsOut!.difference(now).inDays, 45);
    });

    test('a quota beyond a year is plenty', () {
      expect(
        forecast(used: 0, days: _days(today - 3, [0, 1, 1, 1])).kind,
        TrafficForecastKind.plenty,
      );
    });

    test('runs out early when the plan outlasts the quota', () {
      final result = forecast(expiry: now.add(const Duration(days: 60)));
      expect(result.kind, TrafficForecastKind.early);
      expect(result.daysEarly, 15);
    });

    test('lasts when the plan ends first', () {
      expect(
        forecast(expiry: now.add(const Duration(days: 30))).kind,
        TrafficForecastKind.lasts,
      );
    });

    test('runs out less than a day early still lasts', () {
      final result = forecast(
        expiry: now.add(const Duration(days: 45, hours: 5)),
      );
      expect(result.kind, TrafficForecastKind.lasts);
      expect(result.daysEarly, 0);
    });
  });
}
