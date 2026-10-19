import 'package:flutter/widgets.dart';

typedef PageBackgroundBuilder =
    Widget Function(BuildContext context, Color baseColor, Widget child);

class PageBackgroundScope extends InheritedWidget {
  const PageBackgroundScope({
    super.key,
    required this.cardOpacity,
    this.route,
    required super.child,
  });

  final double cardOpacity;
  final ModalRoute<dynamic>? route;

  static double opacityOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PageBackgroundScope>();
    if (scope == null ||
        scope.route != null && scope.route != ModalRoute.of(context)) {
      return 1;
    }
    return scope.cardOpacity;
  }

  static Color applyCardOpacity(BuildContext context, Color color) {
    final opacity = opacityOf(context).clamp(0.0, 1.0);
    return color.withValues(alpha: color.a * opacity);
  }

  @override
  bool updateShouldNotify(PageBackgroundScope oldWidget) =>
      cardOpacity != oldWidget.cardOpacity || route != oldWidget.route;
}

class PageBackgroundRegistration extends InheritedWidget {
  const PageBackgroundRegistration({
    super.key,
    required this.builder,
    required super.child,
  });

  final PageBackgroundBuilder builder;

  static PageBackgroundBuilder? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<PageBackgroundRegistration>()
      ?.builder;

  @override
  bool updateShouldNotify(PageBackgroundRegistration oldWidget) =>
      builder != oldWidget.builder;
}

class PageBackground extends StatelessWidget {
  const PageBackground({
    super.key,
    required this.child,
    required this.baseColor,
  });

  final Widget child;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final existing = context
        .dependOnInheritedWidgetOfExactType<_PageBackgroundRouteScope>();
    if (existing != null && existing.route == route) return child;
    final builder = PageBackgroundRegistration.maybeOf(context);
    final content = builder == null
        ? ColoredBox(color: baseColor, child: child)
        : builder(context, baseColor, child);
    return _PageBackgroundRouteScope(route: route, child: content);
  }
}

class _PageBackgroundRouteScope extends InheritedWidget {
  const _PageBackgroundRouteScope({required this.route, required super.child});

  final ModalRoute<dynamic>? route;

  @override
  bool updateShouldNotify(_PageBackgroundRouteScope oldWidget) =>
      route != oldWidget.route;
}
