import 'package:reclash/models/models.dart';

enum MilestoneId {
  vigil,
  auscultation,
  fullLadder,
  silentAutopilot,
  odometer,
  meridian,
  porcelain,
  crown,
}

const _dayMillis = 24 * 60 * 60 * 1000;

Set<MilestoneId> unlockedMilestones(OdometerSnapshot snapshot) => {
  if (snapshot.streakMillis >= 90 * _dayMillis) MilestoneId.vigil,
  if (snapshot.exams >= 100 && snapshot.examsClean * 10 >= snapshot.exams * 9)
    MilestoneId.auscultation,
  if (snapshot.ladderCompleted) MilestoneId.fullLadder,
  if (snapshot.autoDecisions >= 1000 &&
      snapshot.quietManualMillis >= 14 * _dayMillis)
    MilestoneId.silentAutopilot,
  if (snapshot.upBytes + snapshot.downBytes >= 1000 * 1000 * 1000 * 1000)
    MilestoneId.odometer,
  if (snapshot.countries.length >= 5) MilestoneId.meridian,
  if (snapshot.cleanDayRun >= 7 || snapshot.bestCleanDayRun >= 7)
    MilestoneId.porcelain,
  if (snapshot.totalCoveredMillis >= 360 * _dayMillis) MilestoneId.crown,
};
