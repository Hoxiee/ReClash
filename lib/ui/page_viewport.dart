import 'package:flutter/widgets.dart';

import 'inherited.dart';
import 'page_background.dart';

class PageViewport extends StatefulWidget {
  const PageViewport({super.key, this.bounds, required this.child});

  final Rect? bounds;
  final Widget child;

  static Widget inherit(BuildContext context, {required Widget child}) {
    final viewport = context
        .dependOnInheritedWidgetOfExactType<_PageViewportScope>();
    if (viewport == null) return child;
    return PageBackground.inherit(
      context,
      child: _PageViewportScope(
        viewport: viewport.viewport,
        bounds: viewport.bounds,
        route: ModalRoute.of(context),
        child: child,
      ),
    );
  }

  static bool contains(BuildContext context) {
    final viewport = context
        .dependOnInheritedWidgetOfExactType<_PageViewportScope>();
    return viewport != null && viewport.route == ModalRoute.of(context);
  }

  @override
  State<PageViewport> createState() => _PageViewportState();
}

class _PageViewportState extends State<PageViewport> {
  final _viewport = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_PageViewportScope>();
    final anchored = inherited != null && widget.bounds != null;
    return SizedBox.expand(
      key: _viewport,
      child: _PageViewportScope(
        viewport: anchored ? inherited.viewport : _viewport,
        bounds: anchored
            ? widget.bounds!.shift(inherited.bounds?.topLeft ?? Offset.zero)
            : null,
        route: ModalRoute.of(context),
        child: widget.child,
      ),
    );
  }
}

class _PageViewportScope extends InheritedWidget {
  const _PageViewportScope({
    required this.viewport,
    required this.bounds,
    required this.route,
    required super.child,
  });

  final GlobalKey viewport;
  final Rect? bounds;
  final ModalRoute<dynamic>? route;

  @override
  bool updateShouldNotify(_PageViewportScope oldWidget) =>
      viewport != oldWidget.viewport ||
      bounds != oldWidget.bounds ||
      route != oldWidget.route;
}

/// A page growing over the one beneath: the beneath page's bar shows only
/// above [top], the growing page's top edge, so the page covers it.
class PageBarCover extends InheritedWidget {
  const PageBarCover({
    super.key,
    required this.listenable,
    required this.top,
    required super.child,
  });

  final Listenable listenable;
  final double? Function() top;

  @override
  bool updateShouldNotify(PageBarCover oldWidget) =>
      listenable != oldWidget.listenable;
}

class _CoverClipper extends CustomClipper<Rect> {
  const _CoverClipper(this.top);

  final double top;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, 0, size.width, top.clamp(0, size.height));

  @override
  bool shouldReclip(_CoverClipper oldClipper) => top != oldClipper.top;
}

class ViewportAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ViewportAppBar({super.key, required this.appBar});

  final PreferredSizeWidget appBar;

  @override
  Size get preferredSize => appBar.preferredSize;

  @override
  State<ViewportAppBar> createState() => _ViewportAppBarState();
}

class _ViewportAppBarState extends State<ViewportAppBar> {
  final _portal = OverlayPortalController()..show();

  @override
  Widget build(BuildContext context) {
    final viewport = context
        .dependOnInheritedWidgetOfExactType<_PageViewportScope>()!;
    final route = ModalRoute.of(context);
    final active = PageActivityScope.isActiveOf(context);
    final cover = context.dependOnInheritedWidgetOfExactType<PageBarCover>();
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => LayoutBuilder(
        builder: (_, constraints) {
          final box = viewport.viewport.currentContext?.findRenderObject();
          final overlay = Overlay.of(context).context.findRenderObject();
          if (box is! RenderBox || overlay is! RenderBox) {
            return const SizedBox.shrink();
          }
          final rect = MatrixUtils.transformRect(
            box.getTransformTo(overlay),
            viewport.bounds ?? Offset.zero & box.size,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: rect.left,
                top: rect.top,
                width: rect.width,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    route?.animation,
                    route?.secondaryAnimation,
                    cover?.listenable,
                  ]),
                  builder: (_, child) {
                    final secondary = route?.secondaryAnimation;
                    final covered =
                        secondary?.status != AnimationStatus.reverse &&
                        (secondary?.value ?? 0) > 0;
                    final leaving =
                        route?.animation?.status == AnimationStatus.reverse;
                    final top = cover?.top();
                    return Offstage(
                      offstage:
                          !active ||
                          covered ||
                          leaving ||
                          route?.offstage == true,
                      child: top == null
                          ? child
                          : ClipRect(clipper: _CoverClipper(top), child: child),
                    );
                  },
                  child: widget.appBar,
                ),
              ),
            ],
          );
        },
      ),
      child: SizedBox(
        height: widget.preferredSize.height + MediaQuery.paddingOf(context).top,
      ),
    );
  }
}
