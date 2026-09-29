import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';

void main() {
  test('an English locale still yields Russia from a Moscow time zone', () {
    expect(
      detectRegion(
        const RegionSignals(timeZoneId: 'Europe/Moscow'),
        const Locale('en'),
      ),
      'RU',
    );
  });

  test('the SIM country wins over a conflicting locale', () {
    expect(
      detectRegion(
        const RegionSignals(simCountry: 'ru'),
        const Locale('en', 'US'),
      ),
      'RU',
    );
  });

  test('the serving network settles a region when the SIM is absent', () {
    expect(
      detectRegion(const RegionSignals(networkCountry: 'ir'), null),
      'IR',
    );
  });

  test(
    'the locale is the last resort when no native signal names a region',
    () {
      expect(
        detectRegion(const RegionSignals(), const Locale('zh')),
        'CN',
      );
      expect(
        detectRegion(const RegionSignals(), const Locale('fa')),
        'IR',
      );
    },
  );

  test('a data-only country resolves from SIM and time zone alike', () {
    expect(
      detectRegion(const RegionSignals(simCountry: 'eg'), const Locale('en')),
      'EG',
    );
    expect(
      detectRegion(const RegionSignals(timeZoneId: 'Africa/Cairo'), null),
      'EG',
    );
  });

  test('Arabic names too many countries to detect Egypt by language', () {
    expect(detectRegion(const RegionSignals(), const Locale('ar')), isNull);
  });

  test('nothing recognizable leaves the region unset', () {
    expect(
      detectRegion(
        const RegionSignals(simCountry: 'de', timeZoneId: 'Europe/Berlin'),
        const Locale('de'),
      ),
      isNull,
    );
    expect(detectRegion(const RegionSignals(), null), isNull);
  });

  test('signal casing and whitespace do not defeat detection', () {
    expect(
      detectRegion(const RegionSignals(simCountry: ' Ru '), null),
      'RU',
    );
  });
}
