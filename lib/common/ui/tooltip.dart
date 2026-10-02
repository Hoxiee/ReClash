import 'package:material_ui/material_ui.dart';

import 'shape.dart';
import 'spacing.dart';

abstract final class AppTooltipTiming {
  static const wait = Duration(milliseconds: 600);
  static const adjacent = Duration(milliseconds: 200);
  static const warm = Duration(seconds: 1);
  static const exit = Duration(milliseconds: 120);
  static const enterAnimation = Duration(milliseconds: 150);
  static const exitAnimation = Duration(milliseconds: 90);
  static const touch = Duration(seconds: 4);
}

TooltipThemeData appTooltipTheme(ThemeData theme) {
  final colors = theme.colorScheme;
  return TooltipThemeData(
    waitDuration: AppTooltipTiming.wait,
    exitDuration: AppTooltipTiming.exit,
    showDuration: AppTooltipTiming.touch,
    preferBelow: false,
    constraints: const BoxConstraints(minHeight: 32, maxWidth: 300),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    margin: AppInsets.sm,
    textStyle: theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurface,
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w500,
    ),
    decoration: ShapeDecoration(
      color: colors.surfaceContainerHigh,
      shape: _TooltipShape(
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      shadows: [
        BoxShadow(
          color: colors.shadow.withValues(
            alpha: colors.brightness == Brightness.dark ? 0.24 : 0.1,
          ),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ],
    ),
  );
}

extension AppTooltipThemeExt on ThemeData {
  ThemeData get withAppTooltips =>
      copyWith(tooltipTheme: appTooltipTheme(this));
}

class _TooltipShape extends OutlinedBorder {
  const _TooltipShape({super.side});

  OutlinedBorder _shape(Rect rect) =>
      AppShape.all(AppCorner.fit(rect.shortestSide)).copyWith(side: side);

  @override
  _TooltipShape copyWith({BorderSide? side}) =>
      _TooltipShape(side: side ?? this.side);

  @override
  ShapeBorder scale(double t) => _TooltipShape(side: side.scale(t));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _shape(rect).getInnerPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _shape(rect).getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) =>
      _shape(rect).paint(canvas, rect, textDirection: textDirection);
}
