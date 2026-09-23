import 'dart:ui';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an English locale still yields Russia from a Moscow time zone', () {
    expect(
      detectRegion(
        const RegionSignals(timeZoneId: 'Europe/Moscow'),
        const Locale('en'),
      ),
      AppRegion.russia,
    );
  });

  test('the SIM country wins over a conflicting locale', () {
    expect(
      detectRegion(
        const RegionSignals(simCountry: 'ru'),
        const Locale('en', 'US'),
      ),
      AppRegion.russia,
    );
  });

  test('the serving network settles a region when the SIM is absent', () {
    expect(
      detectRegion(const RegionSignals(networkCountry: 'ir'), null),
      AppRegion.iran,
    );
  });

  test('the locale is the last resort when no native signal names a region', () {
    expect(detectRegion(const RegionSignals(), const Locale('zh')),
        AppRegion.china);
    expect(detectRegion(const RegionSignals(), const Locale('fa')),
        AppRegion.iran);
  });

  test('nothing recognizable falls through to other', () {
    expect(
      detectRegion(
        const RegionSignals(simCountry: 'de', timeZoneId: 'Europe/Berlin'),
        const Locale('de'),
      ),
      AppRegion.other,
    );
    expect(detectRegion(const RegionSignals(), null), AppRegion.other);
  });

  test('signal casing and whitespace do not defeat detection', () {
    expect(
      detectRegion(const RegionSignals(simCountry: ' Ru '), null),
      AppRegion.russia,
    );
  });
}
