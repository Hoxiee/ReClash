import 'package:reclash/views/dashboard/widgets/seasonal_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new year window runs from December 28 through January 3', () {
    for (final date in [
      DateTime(2026, 12, 28),
      DateTime(2026, 12, 31),
      DateTime(2027, 1, 1),
      DateTime(2027, 1, 3),
    ]) {
      expect(seasonalMotifAt(date), SeasonalMotif.newYear);
    }
    expect(seasonalMotifAt(DateTime(2026, 12, 27)), SeasonalMotif.drift);
    expect(seasonalMotifAt(DateTime(2027, 1, 4)), SeasonalMotif.drift);
  });

  test('birthday takes precedence over first run anniversary', () {
    final firstRun = DateTime(2025, 9, 2);
    expect(
      seasonalMotifAt(DateTime(2026, 9, 2), firstRun: firstRun),
      SeasonalMotif.birthday,
    );
  });

  test('first run appears only on a later anniversary', () {
    final firstRun = DateTime(2025, 4, 12);
    expect(
      seasonalMotifAt(DateTime(2025, 4, 12), firstRun: firstRun),
      SeasonalMotif.drift,
    );
    expect(
      seasonalMotifAt(DateTime(2026, 4, 12), firstRun: firstRun),
      SeasonalMotif.firstRun,
    );
  });
}
