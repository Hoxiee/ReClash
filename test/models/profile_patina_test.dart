import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 12, 12);
  final base = Profile.normal(label: 'Profile');

  test('patina boundaries follow profile inactivity', () {
    expect(base.copyWith(lastUsedAt: now).patinaLevelAt(now), 0);
    expect(
      base
          .copyWith(lastUsedAt: now.subtract(const Duration(days: 13)))
          .patinaLevelAt(now),
      0,
    );
    expect(
      base
          .copyWith(lastUsedAt: now.subtract(const Duration(days: 14)))
          .patinaLevelAt(now),
      1,
    );
    expect(
      base
          .copyWith(lastUsedAt: now.subtract(const Duration(days: 45)))
          .patinaLevelAt(now),
      2,
    );
    expect(
      base
          .copyWith(lastUsedAt: now.subtract(const Duration(days: 120)))
          .patinaLevelAt(now),
      3,
    );
  });

  test('legacy profiles fall back to their last update', () {
    final profile = base.copyWith(
      lastUpdateDate: now.subtract(const Duration(days: 50)),
    );
    expect(profile.patinaLevelAt(now), 2);
  });

  test('unknown and future timestamps stay clean', () {
    expect(base.patinaLevelAt(now), 0);
    expect(
      base
          .copyWith(lastUsedAt: now.add(const Duration(days: 1)))
          .patinaLevelAt(now),
      0,
    );
  });
}
