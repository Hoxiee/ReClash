import 'package:flutter/widgets.dart';

import 'motion.dart';

typedef TabFrame = ({double offset, double opacity});

/// A switch that interrupts another starts each page from where it is drawn.
/// Sliding pages all travel the same distance, so pages that touch keep
/// touching and none ever crosses another.
class TabMotionPlan<K> {
  Map<K, TabFrame> _starts = const {};
  Map<K, TabFrame> _ends = const {};
  bool _fade = false;
  bool _linear = false;

  bool get isActive => _starts.isNotEmpty;

  Iterable<K> get keys => _starts.keys;

  bool contains(K key) => _starts.containsKey(key);

  Duration get duration => _fade ? fadeTabDuration : slideTabDuration;

  TabFrame frameOf(K key, {required K current, required double value}) {
    final start = _starts[key];
    if (start == null) return (offset: 0, opacity: key == current ? 1 : 0);
    final end = _ends[key]!;
    final t = _linear
        ? value
        : (_fade ? fadeTabCurve : slideTabCurve).transform(value);
    return (
      offset: start.offset + (end.offset - start.offset) * t,
      opacity: start.opacity + (end.opacity - start.opacity) * t,
    );
  }

  void beginDrag(K target, {required K current, required bool forward}) {
    final direction = forward ? 1.0 : -1.0;
    _fade = false;
    _linear = true;
    _starts = {
      current: (offset: 0, opacity: 1),
      target: (offset: direction, opacity: 1),
    };
    _ends = {
      current: (offset: -direction, opacity: 1),
      target: (offset: 0, opacity: 1),
    };
  }

  void retarget(
    K target, {
    required K current,
    required double value,
    required bool forward,
    required bool fade,
  }) {
    final starts = <K, TabFrame>{
      for (final key in {..._starts.keys, current})
        key: frameOf(key, current: current, value: value),
    };
    final offsets = starts.values.map((frame) => frame.offset);
    final entry = starts[target];
    starts[target] =
        entry ??
        (fade
            ? (offset: 0, opacity: 0)
            : (
                offset: forward
                    ? offsets.reduce((a, b) => a > b ? a : b) + 1
                    : offsets.reduce((a, b) => a < b ? a : b) - 1,
                opacity: 1,
              ));
    final shift = -starts[target]!.offset;
    _fade = fade;
    _linear = false;
    _starts = starts;
    _ends = {
      for (final MapEntry(:key, value: start) in starts.entries)
        key: fade
            ? (offset: 0, opacity: key == target ? 1 : 0)
            : (offset: start.offset + shift, opacity: 1),
    };
  }

  void clear() {
    _starts = const {};
    _ends = const {};
  }
}

class TabContentMotion extends InheritedWidget {
  const TabContentMotion({
    super.key,
    required this.animation,
    required this.frame,
    required this.axis,
    required super.child,
  });

  final Listenable animation;
  final TabFrame Function() frame;
  final Axis axis;

  static Widget wrap(BuildContext context, Widget child) {
    final motion = context
        .dependOnInheritedWidgetOfExactType<TabContentMotion>();
    return motion == null
        ? child
        : TabMotionTransition(
            animation: motion.animation,
            frame: motion.frame,
            axis: motion.axis,
            child: child,
          );
  }

  @override
  bool updateShouldNotify(TabContentMotion oldWidget) =>
      animation != oldWidget.animation ||
      frame != oldWidget.frame ||
      axis != oldWidget.axis;
}

class TabMotionTransition extends StatelessWidget {
  const TabMotionTransition({
    super.key,
    required this.animation,
    required this.frame,
    required this.axis,
    required this.child,
  });

  final Listenable animation;
  final TabFrame Function() frame;
  final Axis axis;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sign =
        axis == Axis.horizontal &&
            Directionality.of(context) == TextDirection.rtl
        ? -1.0
        : 1.0;
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final current = frame();
        final offset = current.offset * sign;
        return FractionalTranslation(
          translation: axis == Axis.horizontal
              ? Offset(offset, 0)
              : Offset(0, offset),
          child: Opacity(opacity: current.opacity, child: child),
        );
      },
      child: RepaintBoundary(child: child),
    );
  }
}
