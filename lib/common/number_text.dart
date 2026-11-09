import 'package:intl/intl.dart' show NumberFormat;
import 'package:reclash/enum/enum.dart';

/// Pinned to English so every locale reads K and M, never 万 or тыс.
final _compactFormat = NumberFormat.compact(locale: 'en');

extension NumTextExt on num {
  String get compact => _compactFormat.format(this);

  String fixed({int decimals = 2}) {
    String formatted = toStringAsFixed(decimals);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }
    return formatted;
  }

  ({double size, TrafficUnit unit}) get trafficScale {
    const units = TrafficUnit.values;
    var size = toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return (size: size, unit: units[unitIndex]);
  }

  ({String value, String unit}) get trafficParts {
    final (:size, :unit) = trafficScale;
    return (value: size.fixed(decimals: 1), unit: unit.name);
  }
}
