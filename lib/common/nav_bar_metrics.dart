import 'package:flutter/widgets.dart';

abstract final class NavBarMetrics {
  static const double pillHeight = 64;

  static const double gapTop = 8;
  static const double gapBottom = 16;
  static const double gapSide = 12;
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    gapSide,
    gapTop,
    gapSide,
    gapBottom,
  );

  /// The bar's SafeArea consumes the system inset on top of this height.
  static const double reservedHeight = pillHeight + gapTop + gapBottom;

  static const double highlightInset = 6;

  static const Duration motionDuration = Duration(milliseconds: 240);
  static const Curve motionCurve = Curves.easeOutCubic;
}
