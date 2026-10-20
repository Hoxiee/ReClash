import 'package:flutter/widgets.dart';

import 'inherited.dart';

class ShellScrimScope extends StatefulWidget {
  const ShellScrimScope({super.key, required this.child});

  final Widget child;

  @override
  State<ShellScrimScope> createState() => _ShellScrimScopeState();
}

class _ShellScrimScopeState extends State<ShellScrimScope> {
  final _bounds = GlobalKey();

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    key: _bounds,
    child: _ShellScrimBounds(bounds: _bounds, child: widget.child),
  );
}

class _ShellScrimBounds extends InheritedWidget {
  const _ShellScrimBounds({required this.bounds, required super.child});

  final GlobalKey bounds;

  @override
  bool updateShouldNotify(_ShellScrimBounds oldWidget) =>
      bounds != oldWidget.bounds;
}

/// Extends a nested route's scrim without moving its sheet or dismissal barrier.
class ShellModalScrim extends StatefulWidget {
  const ShellModalScrim({super.key, required this.color, required this.child});

  final Animation<Color?> color;
  final Widget child;

  @override
  State<ShellModalScrim> createState() => _ShellModalScrimState();
}

class _ShellModalScrimState extends State<ShellModalScrim> {
  final _portal = OverlayPortalController()..show();

  @override
  Widget build(BuildContext context) {
    final shell = context
        .dependOnInheritedWidgetOfExactType<_ShellScrimBounds>();
    final navigator = Navigator.of(context);
    final root = Navigator.of(context, rootNavigator: true);
    if (shell == null || identical(navigator, root)) return widget.child;
    final active = PageActivityScope.isActiveOf(context);
    return OverlayPortal(
      controller: _portal,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (context) => IgnorePointer(
        child: Offstage(
          offstage: !active,
          child: CustomPaint(
            painter: _ShellScrimPainter(
              bounds: shell.bounds,
              navigator: navigator,
              overlay: Overlay.of(context, rootOverlay: true),
              color: widget.color,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}

class _ShellScrimPainter extends CustomPainter {
  _ShellScrimPainter({
    required this.bounds,
    required this.navigator,
    required this.overlay,
    required this.color,
  }) : super(repaint: color);

  final GlobalKey bounds;
  final NavigatorState navigator;
  final OverlayState overlay;
  final Animation<Color?> color;

  @override
  void paint(Canvas canvas, Size size) {
    final shell = bounds.currentContext?.findRenderObject();
    final destination = navigator.context.findRenderObject();
    final target = overlay.context.findRenderObject();
    final tint = color.value;
    if (shell is! RenderBox ||
        destination is! RenderBox ||
        target is! RenderBox ||
        tint == null ||
        tint.a == 0) {
      return;
    }
    final shellRect = MatrixUtils.transformRect(
      shell.getTransformTo(target),
      Offset.zero & shell.size,
    );
    final destinationRect = MatrixUtils.transformRect(
      destination.getTransformTo(target),
      Offset.zero & destination.size,
    );
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(shellRect);
    final overlap = shellRect.intersect(destinationRect);
    if (!overlap.isEmpty) path.addRect(overlap);
    canvas.drawPath(path, Paint()..color = tint);
  }

  @override
  bool shouldRepaint(_ShellScrimPainter oldDelegate) =>
      bounds != oldDelegate.bounds ||
      navigator != oldDelegate.navigator ||
      overlay != oldDelegate.overlay ||
      color != oldDelegate.color;
}
