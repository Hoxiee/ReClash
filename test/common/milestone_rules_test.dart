import 'package:reclash/common/milestones/milestone_rules.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const day = 24 * 60 * 60 * 1000;

  test('unlocks each relic exactly at its boundary', () {
    final unlocked = unlockedMilestones(
      const OdometerSnapshot(
        streakMillis: 90 * day,
        exams: 100,
        examsClean: 90,
        ladderCompleted: true,
        autoDecisions: 1000,
        quietManualMillis: 14 * day,
        upBytes: 1000 * 1000 * 1000 * 1000,
        countries: ['a', 'b', 'c', 'd', 'e'],
        cleanDayRun: 7,
        totalCoveredMillis: 360 * day,
      ),
    );

    expect(unlocked, MilestoneId.values.toSet());
  });

  test('does not unlock just below boundaries', () {
    final unlocked = unlockedMilestones(
      const OdometerSnapshot(
        streakMillis: 90 * day - 1,
        exams: 100,
        examsClean: 89,
        ladderTop: 99,
        autoDecisions: 999,
        quietManualMillis: 14 * day - 1,
        upBytes: 1000 * 1000 * 1000 * 1000 - 1,
        countries: ['a', 'b', 'c', 'd'],
        cleanDayRun: 6,
        bestCleanDayRun: 6,
        totalCoveredMillis: 360 * day - 1,
      ),
    );

    expect(unlocked, isEmpty);
  });
}
