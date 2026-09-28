import 'package:flutter/widgets.dart';
import 'package:reclash/common/ui/nav_bar_metrics.dart';

abstract final class NavRailMetrics {
  /// Collapsed the rail is a column of square squircle buttons; expanded it
  /// widens and each slot grows taller to seat a label under the icon. Width
  /// and slot height both ride the bounce-free standard easing off one progress.
  static const double compactWidth = 48;
  static const double expandedWidth = 80;
  static const Duration expandDuration = Duration(milliseconds: 250);

  static const double compactSlotHeight = 44;
  static const double expandedSlotHeight = 58;

  static const double pillInsetX = 6;
  static const double pillInsetY = 4;

  static const double itemCorner = 10;
  static const double iconSize = 24;

  static const double indicatorWidth = 3;
  static const double indicatorHeight = 16;

  static const double groupGap = 8;
  static const double hairline = 1;

  static const double dividerExtent = groupGap * 2 + hairline;

  static const double markSize = 36;
  static const double markPadding = 6;

  static const EdgeInsets padding = EdgeInsets.symmetric(vertical: 8);

  static const Duration motionDuration = NavBarMetrics.motionDuration;
  static const Curve motionCurve = NavBarMetrics.motionCurve;

  static const Duration indicatorDuration = Duration(milliseconds: 320);
}
