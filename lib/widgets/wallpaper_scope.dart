import 'package:material_ui/material_ui.dart';

class WallpaperSurfaceScope extends InheritedWidget {
  const WallpaperSurfaceScope({
    super.key,
    required this.opacity,
    required super.child,
  });

  final double opacity;

  static Color colorOf(BuildContext context, Color color) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<WallpaperSurfaceScope>();
    return scope == null
        ? color
        : color.withValues(alpha: color.a * scope.opacity);
  }

  @override
  bool updateShouldNotify(WallpaperSurfaceScope oldWidget) =>
      opacity != oldWidget.opacity;
}
