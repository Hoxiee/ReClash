import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

enum _VisibilityMotion {
  sidebar(
    axis: Axis.horizontal,
    alignment: AlignmentDirectional.topStart,
    hiddenOffset: Offset(-1, 0),
    softTopEdge: false,
  ),
  bottomNavigation(
    axis: Axis.vertical,
    alignment: AlignmentDirectional.bottomStart,
    hiddenOffset: Offset(0, 1),
    softTopEdge: true,
  );

  final Axis axis;
  final AlignmentGeometry alignment;
  final Offset hiddenOffset;

  /// Drops the clip once settled so a docked bar's lens and ring paint past it.
  final bool softTopEdge;

  const _VisibilityMotion({
    required this.axis,
    required this.alignment,
    required this.hiddenOffset,
    required this.softTopEdge,
  });
}

/// Animates navigation visibility together with the surrounding layout.
class AnimatedVisibility extends StatefulWidget {
  final bool visible;
  final _VisibilityMotion _motion;
  final Widget child;

  /// Creates a sidebar transition that moves to the left when hidden.
  const AnimatedVisibility.sidebar({
    super.key,
    required this.visible,
    required this.child,
  }) : _motion = _VisibilityMotion.sidebar;

  /// Creates a bottom-navigation transition that moves through the bottom.
  const AnimatedVisibility.bottomNavigation({
    super.key,
    required this.visible,
    required this.child,
  }) : _motion = _VisibilityMotion.bottomNavigation;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  late Widget _presentedChild;
  late bool _includeChild;

  @override
  void initState() {
    super.initState();
    _presentedChild = widget.child;
    _includeChild = widget.visible;
    _controller = AnimationController(
      value: widget.visible ? 1 : 0,
      duration: commonDuration,
      reverseDuration: commonDuration,
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Easing.standardDecelerate,
      reverseCurve: const FlippedCurve(Easing.standardAccelerate),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.disableAnimations) {
      return;
    }
    _controller.value = widget.visible ? 1 : 0;
  }

  @override
  void didUpdateWidget(covariant AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      if (widget.visible) {
        _presentedChild = widget.child;
      }
      return;
    }
    if (context.disableAnimations) {
      _presentedChild = widget.child;
      _includeChild = widget.visible;
      _controller.value = widget.visible ? 1 : 0;
      return;
    }
    if (widget.visible) {
      _presentedChild = widget.child;
      _includeChild = true;
      _controller.forward();
      return;
    }
    if (_controller.isDismissed) {
      _includeChild = false;
      return;
    }
    _controller.reverse();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed ||
        widget.visible ||
        !_includeChild) {
      return;
    }
    setState(() {
      _includeChild = false;
    });
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = widget._motion;
    final revealed = _includeChild
        ? FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: _animation.drive(
                Tween(begin: motion.hiddenOffset, end: Offset.zero),
              ),
              child: _presentedChild,
            ),
          )
        : const SizedBox.shrink();
    final content = motion.softTopEdge
        ? _DockReveal(
            sizeFactor: _animation,
            alignment: motion.alignment,
            child: revealed,
          )
        : ClipRect(
            child: SizeTransition(
              sizeFactor: _animation,
              axis: motion.axis,
              alignment: motion.alignment,
              child: revealed,
            ),
          );
    return ExcludeSemantics(
      excluding: !widget.visible,
      child: ExcludeFocus(
        excluding: !widget.visible,
        child: IgnorePointer(ignoring: !widget.visible, child: content),
      ),
    );
  }
}

/// Reveals like [SizeTransition] but unclips when open and fades the top edge.
class _DockReveal extends AnimatedWidget {
  const _DockReveal({
    required Animation<double> sizeFactor,
    required this.alignment,
    required this.child,
  }) : super(listenable: sizeFactor);

  final AlignmentGeometry alignment;
  final Widget child;

  Animation<double> get _sizeFactor => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final value = math.max(_sizeFactor.value, 0.0);
    final settled = value >= 1;
    final revealed = ClipRect(
      clipBehavior: settled ? Clip.none : Clip.hardEdge,
      child: Align(alignment: alignment, heightFactor: value, child: child),
    );
    if (settled) {
      return revealed;
    }
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
        stops: [0, 0.55],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: revealed,
    );
  }
}
