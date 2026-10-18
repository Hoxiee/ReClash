import 'package:flutter_timezone/flutter_timezone.dart';

import 'region_detection.dart';

Future<RegionSignals> readDeviceRegionSignals() async {
  try {
    final timeZone = await FlutterTimezone.getLocalTimezone().timeout(
      const Duration(seconds: 2),
    );
    return RegionSignals(timeZoneId: timeZone.identifier);
  } catch (_) {
    return const RegionSignals();
  }
}
