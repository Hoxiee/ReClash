import 'dart:async';

import 'package:reclash/ui/context.dart';
import 'package:reclash/ui/item_position.dart';
import 'package:reclash/ui/metrics.dart';
import 'package:reclash/ui/models.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';
import 'list.dart';

/// Each entry runs on a controller of its own, so a change made while another
/// entry still moves leaves that one running.
class EntryTransitions<K> {
  final TickerProvider vsync;

  /// Runs once [K] has collapsed, outside the frame that finished it, so the
  /// owner may drop the entry with setState even while being built.
  final ValueChanged<K> onLeft;

  final _controllers = <K, AnimationController>{};
  final _leaving = <K>{};
  final _positions = <K, ItemPosition>{};

  EntryTransitions({required this.vsync, required this.onLeft});

  Animation<double>? animationOf(K key) => _controllers[key];

  bool isLeaving(K key) => _leaving.contains(key);

  Iterable<K> get leaving => _leaving;

  /// Moves [entries] to [next], keeping the ones it drops while they leave.
  List<T> sync<T>(
    List<T> entries,
    List<T> next,
    K Function(T item) keyOf,
    Duration duration,
  ) {
    final keys = {for (final item in next) keyOf(item)};
    final shown = {
      for (final entry in entries)
        if (!isLeaving(keyOf(entry))) keyOf(entry),
    };
    for (final key in shown) {
      if (!keys.contains(key)) {
        leave(key, duration);
      }
    }
    for (final key in keys) {
      if (!shown.contains(key)) {
        enter(key, duration);
      }
    }
    return keepLeaving(entries, next, keyOf);
  }

  /// Places the staying [keys] in one run of rounded rows, ahead of
  /// [trailing] rows that close it; a leaving key keeps the place it had.
  void place(Iterable<K> keys, {int trailing = 0}) {
    final staying = keys.where((key) => !isLeaving(key)).toList();
    final count = staying.length + trailing;
    for (final (index, key) in staying.indexed) {
      _positions[key] = ItemPosition.get(index, count);
    }
  }

  ItemPosition positionOf(K key) => _positions[key] ?? ItemPosition.middle;

  void enter(K key, Duration duration) {
    _leaving.remove(key);
    (_controllers[key] ??= _create(key, 0))
      ..duration = duration
      ..forward();
  }

  void leave(K key, Duration duration) {
    if (!_leaving.add(key)) {
      return;
    }
    (_controllers[key] ??= _create(key, 1))
      ..duration = duration
      ..reverse();
  }

  AnimationController _create(K key, double value) {
    final controller = AnimationController(vsync: vsync, value: value);
    controller.addStatusListener((status) {
      if (!status.isDismissed || !_leaving.remove(key)) {
        return;
      }
      _controllers.remove(key);
      scheduleMicrotask(() {
        controller.dispose();
        _positions.remove(key);
        onLeft(key);
      });
    });
    return controller;
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

List<T> keepLeaving<T>(
  List<T> previous,
  List<T> next,
  Object? Function(T item) keyOf,
) {
  final keys = {for (final item in next) keyOf(item)};
  final before = <Object?, List<T>>{};
  var pending = <T>[];
  for (final item in previous) {
    final key = keyOf(item);
    if (!keys.contains(key)) {
      pending.add(item);
    } else if (pending.isNotEmpty) {
      before[key] = pending;
      pending = [];
    }
  }
  return [
    for (final item in next) ...[...?before[keyOf(item)], item],
    ...pending,
  ];
}

class EntryTransition extends StatelessWidget {
  static final _fade = CurveTween(curve: const Interval(0.5, 1));
  static final _size = CurveTween(curve: Curves.easeInOutCubic);

  final Animation<double>? animation;
  final bool leaving;
  final Widget child;

  const EntryTransition({
    super.key,
    required this.animation,
    this.leaving = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = this.animation ?? kAlwaysCompleteAnimation;
    return IgnorePointer(
      ignoring: leaving,
      child: SizeTransition(
        sizeFactor: animation.drive(_size),
        alignment: Alignment.topCenter,
        child: FadeTransition(opacity: animation.drive(_fade), child: child),
      ),
    );
  }
}

/// Unfolds [child] in place while [visible] and folds it away otherwise, with
/// the motion of [AnimatedEntries]; it leaves showing the last visible child.
class AnimatedReveal extends StatefulWidget {
  final bool visible;
  final Widget child;

  const AnimatedReveal({super.key, required this.visible, required this.child});

  @override
  State<AnimatedReveal> createState() => _AnimatedRevealState();
}

class _AnimatedRevealState extends State<AnimatedReveal>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    value: widget.visible ? 1 : 0,
  )..addStatusListener(_handleStatus);
  late var _child = widget.child;

  void _handleStatus(AnimationStatus status) {
    if (status.isDismissed && mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      _child = widget.child;
    }
    if (widget.visible == oldWidget.visible) {
      return;
    }
    _controller.duration = context.motionDuration(commonDuration);
    widget.visible ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }
    return EntryTransition(
      animation: _controller,
      leaving: !widget.visible,
      child: _child,
    );
  }
}

/// With [grouped], a child collapsing out keeps its place in the run of
/// rounded rows while the others close up around it. A child without a key is
/// told apart by its type, so two of one type need keys of their own.
class AnimatedEntries extends StatefulWidget {
  final List<Widget> children;
  final bool grouped;

  const AnimatedEntries({
    super.key,
    required this.children,
    this.grouped = false,
  });

  @override
  State<AnimatedEntries> createState() => _AnimatedEntriesState();
}

class _AnimatedEntriesState extends State<AnimatedEntries>
    with TickerProviderStateMixin {
  late final _transitions = EntryTransitions<Key>(
    vsync: this,
    onLeft: _handleLeft,
  );
  late var _entries = widget.children;

  @override
  void didUpdateWidget(covariant AnimatedEntries oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entries = _transitions.sync(
      _entries,
      widget.children,
      _keyOf,
      context.motionDuration(commonDuration),
    );
  }

  @override
  void dispose() {
    _transitions.dispose();
    super.dispose();
  }

  static Key _keyOf(Widget child) => child.key ?? ValueKey(child.runtimeType);

  void _handleLeft(Key key) {
    if (!mounted || widget.children.any((child) => _keyOf(child) == key)) {
      return;
    }
    setState(() {
      _entries = [
        for (final entry in _entries)
          if (_keyOf(entry) != key) entry,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.grouped) {
      _transitions.place(_entries.map(_keyOf));
    }
    return Column(
      children: [
        for (final entry in _entries)
          if (_keyOf(entry) case final key)
            EntryTransition(
              key: key,
              animation: _transitions.animationOf(key),
              leaving: _transitions.isLeaving(key),
              child: widget.grouped
                  ? ItemPositionProvider(
                      position: _transitions.positionOf(key),
                      child: entry,
                    )
                  : entry,
            ),
      ],
    );
  }
}

Widget generateAnimatedSection({
  String? title,
  required List<Widget> items,
  List<IconButtonData> actions = const [],
  String? footer,
}) {
  return Column(
    children: [
      AnimatedReveal(
        visible: items.isNotEmpty,
        child: title != null
            ? ListHeader(title: title, actions: actions)
            : const ListSectionGap(),
      ),
      AnimatedEntries(grouped: true, children: items),
      AnimatedReveal(
        visible: items.isNotEmpty && footer != null,
        child: _AnimatedFooter(text: footer ?? ''),
      ),
    ],
  );
}

/// Eases a footer whose text gains or loses a line along with its rows.
class _AnimatedFooter extends StatelessWidget {
  final String text;

  const _AnimatedFooter({required this.text});

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: context.motionDuration(commonDuration),
    curve: Curves.easeInOutCubic,
    alignment: Alignment.topCenter,
    child: ListFooter(text: text),
  );
}
