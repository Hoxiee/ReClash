import 'package:material_ui/material_ui.dart';

// A spacing scale distinct from AppCorner's radius scale: same names, different numbers.
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract final class AppInsets {
  static const EdgeInsets none = EdgeInsets.zero;
  static const EdgeInsets xxs = EdgeInsets.all(AppSpacing.xxs);
  static const EdgeInsets xs = EdgeInsets.all(AppSpacing.xs);
  static const EdgeInsets sm = EdgeInsets.all(AppSpacing.sm);
  static const EdgeInsets md = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets lg = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets xl = EdgeInsets.all(AppSpacing.xl);
  static const EdgeInsets xxl = EdgeInsets.all(AppSpacing.xxl);
  static const EdgeInsets xxxl = EdgeInsets.all(AppSpacing.xxxl);
}
