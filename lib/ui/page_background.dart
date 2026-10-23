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

class PageBackground extends StatefulWidget {
  const PageBackground({
    super.key,
    required this.child,
    required this.baseColor,
  });

  final Widget child;
  final Color baseColor;

  static Widget inherit(BuildContext context, {required Widget child}) {
    final background = context
        .dependOnInheritedWidgetOfExactType<_PageBackgroundRouteScope>();
    if (background == null) return child;
    final opacity = context
        .dependOnInheritedWidgetOfExactType<PageBackgroundScope>();
    return _PageBackgroundRouteScope(
      route: ModalRoute.of(context),
      anchor: background.anchor,
      child: PageBackgroundScope(
        cardOpacity: opacity?.cardOpacity ?? 1,
        route: ModalRoute.of(context),
        child: child,
      ),
    );
  }

  @override
  State<PageBackground> createState() => _PageBackgroundState();
}

class _PageBackgroundState extends State<PageBackground> {
  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final existing = context
        .dependOnInheritedWidgetOfExactType<_PageBackgroundRouteScope>();
    if (existing != null && existing.route == route) return widget.child;
    final builder = PageBackgroundRegistration.maybeOf(context);
    final content = builder == null
        ? ColoredBox(color: widget.baseColor, child: widget.child)
        : builder(context, widget.baseColor, widget.child);
    return LayoutBuilder(
      builder: (_, constraints) => CompositedTransformTarget(
        link: _link,
        child: _PageBackgroundRouteScope(
          route: route,
          anchor: _BackgroundAnchor(
            link: _link,
            size: constraints.biggest,
            baseColor: widget.baseColor,
            builder: builder,
          ),
          child: content,
        ),
      ),
    );
  }
}

class _BackgroundAnchor {
  const _BackgroundAnchor({
    required this.link,
    required this.size,
    required this.baseColor,
    required this.builder,
  });

  final LayerLink link;
  final Size size;
  final Color baseColor;
  final PageBackgroundBuilder? builder;

  @override
  bool operator ==(Object other) =>
      other is _BackgroundAnchor &&
      other.link == link &&
      other.size == size &&
      other.baseColor == baseColor &&
      other.builder == builder;

  @override
  int get hashCode => Object.hash(link, size, baseColor, builder);
}

/// The background a route shares with the page it sits in, painted where
/// that page paints it, so it holds still however the route moves and hides
/// what lies beneath the route without showing a seam.
class PageBackdrop extends StatelessWidget {
  const PageBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final anchor = context
        .dependOnInheritedWidgetOfExactType<_PageBackgroundRouteScope>()
        ?.anchor;
    if (anchor == null) return const SizedBox.expand();
    final builder = anchor.builder;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: anchor.size.width,
            maxWidth: anchor.size.width,
            minHeight: anchor.size.height,
            maxHeight: anchor.size.height,
            child: CompositedTransformFollower(
              link: anchor.link,
              showWhenUnlinked: false,
              child: builder == null
                  ? ColoredBox(color: anchor.baseColor)
                  : builder(context, anchor.baseColor, const SizedBox.expand()),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageBackgroundRouteScope extends InheritedWidget {
  const _PageBackgroundRouteScope({
    required this.route,
    required this.anchor,
    required super.child,
  });

  final ModalRoute<dynamic>? route;
  final _BackgroundAnchor? anchor;

  @override
  bool updateShouldNotify(_PageBackgroundRouteScope oldWidget) =>
      route != oldWidget.route || anchor != oldWidget.anchor;
}
