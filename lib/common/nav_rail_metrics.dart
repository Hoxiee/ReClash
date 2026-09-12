import 'package:reclash/common/nav_bar_metrics.dart';
import 'package:flutter/widgets.dart';

abstract final class NavRailMetrics {
  static const double collapsedWidth = 72;
  static const double extendedWidth = 200;

  static const double extendedMinViewWidth = 1000;

  static const double iconSlotHeight = 52;
  static const double stackedSlotHeight = 64;
  static const double extendedSlotHeight = 52;

  static const double slotGap = 4;
  static const double pillInsetX = 8;
  static const double pillInsetY = 4;

  static const double groupGap = 8;
  static const double hairline = 1;

  static const double dividerExtent = groupGap * 2 + hairline;

  static const double markSize = 36;
  static const double markPadding = 6;

  static const EdgeInsets padding = EdgeInsets.symmetric(vertical: 8);

  static const Duration motionDuration = NavBarMetrics.motionDuration;
  static const Curve motionCurve = NavBarMetrics.motionCurve;
}
