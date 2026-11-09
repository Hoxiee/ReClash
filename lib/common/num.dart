import 'package:reclash/common/number_text.dart';
import 'package:reclash/models/common.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

export 'package:reclash/common/number_text.dart';

extension NumExt on num {
  TrafficShow get traffic {
    final (:value, :unit) = trafficParts;
    return TrafficShow(value: value, unit: unit);
  }

  TrafficShow get shortTraffic {
    final (:size, :unit) = trafficScale;
    return TrafficShow(value: size.toStringAsFixed(0), unit: ' ${unit.name}');
  }
}

extension DoubleExt on double {
  bool moreOrEqual(double value) {
    return this > value || (value - this).abs() < precisionErrorTolerance;
  }
}

extension OffsetExt on Offset {
  double getCrossAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dx : dy;
  }

  double getMainAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dy : dx;
  }
}
