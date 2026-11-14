import 'package:flutter/widgets.dart';

const _swipeDistance = 48.0;
const _swipeVelocity = 400.0;

/// A swipe an inner pager could not take because it sat on its last page: it
/// bubbles up to the [PageSwipe] that owns the next level.
class PageSwipeNotification extends Notification {
  const PageSwipeNotification({required this.forward});

  final bool forward;
}

/// Lets a subtree keep the sideways gestures that start inside it, such as the
/// swipe back of a pushed route, away from the enclosing [PageSwipe].
class PageSwipeScope extends InheritedWidget {
  const PageSwipeScope._({required this.claim, required super.child});

  final void Function(int pointer, VoidCallback? onBack) claim;

  /// [onBack] takes a swipe toward the previous page that still reaches the
  /// [PageSwipe]: one an inner pager passed up from its first page, or any
  /// swipe on a route whose drag back is off, as while it vetoes its pop,
  /// holds a back layer or is still sliding in.
  static void blockPointer(
    BuildContext context,
    int pointer, {
    VoidCallback? onBack,
  }) {
    context.getInheritedWidgetOfExactType<PageSwipeScope>()?.claim(
      pointer,
      onBack,
    );
  }

  @override
  bool updateShouldNotify(PageSwipeScope oldWidget) => false;
}

/// One step a [PageSwipe] took onto a page, from the side the swipe came.
class PageSwipeArrival {
  PageSwipeArrival({required this.forward});

  /// True when the page was entered from the one before it, so an inner
  /// pager starts on its first page; false starts it on its last.
  final bool forward;
}

/// Hands the page a [PageSwipe] stepped onto the [PageSwipeArrival] that
/// brought it in, so an inner pager continues the swipe from that side.
class PageSwipeEntry extends InheritedWidget {
  const PageSwipeEntry({super.key, this.arrival, required super.child});

  final PageSwipeArrival? arrival;

  static PageSwipeArrival? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageSwipeEntry>()?.arrival;

  @override
  bool updateShouldNotify(PageSwipeEntry oldWidget) =>
      !identical(arrival, oldWidget.arrival);
}

/// Turns a sideways swipe into a step to the next or previous page, one level
/// above whatever swipes inside it. A child takes the swipe first; it reaches
/// [onSwipe] only when the child had no page left in that direction, as a
/// [PageSwipeNotification] or a horizontal scrollable's overscroll, or when no
/// child swipes at all.
class PageSwipe extends StatefulWidget {
  const PageSwipe({
    super.key,
    required this.enabled,
    required this.onSwipe,
    required this.child,
  });

  final bool enabled;

  /// `forward` is toward the page after the current one, whatever the text
  /// direction.
  final ValueChanged<bool> onSwipe;
  final Widget child;

  @override
  State<PageSwipe> createState() => _PageSwipeState();
}

class _PageSwipeState extends State<PageSwipe> {
  var _drag = 0.0;
  var _overscroll = 0.0;
  final _claims = <int, VoidCallback?>{};
  var _pointer = -1;

  bool get _isBlocked => _claims.containsKey(_pointer);

  void _claim(int pointer, VoidCallback? onBack) => _claims[pointer] = onBack;

  void _onPointerDown(PointerDownEvent event) {
    _claims.removeWhere((pointer, _) => pointer != event.pointer);
    _pointer = event.pointer;
  }

  void _swipe(bool forward) {
    if (!_isBlocked) {
      widget.onSwipe(forward);
    } else if (!forward) {
      _claims[_pointer]?.call();
    }
    _claims.remove(_pointer);
  }

  int get _sign => Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void _endDrag(DragEndDetails details) {
    final distance = _drag * _sign;
    final velocity = (details.primaryVelocity ?? 0) * _sign;
    _drag = 0;
    final forward = velocity < -_swipeVelocity || distance <= -_swipeDistance;
    final back = velocity > _swipeVelocity || distance >= _swipeDistance;
    if (forward != back) _swipe(forward);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) return false;
    if (notification is ScrollStartNotification) {
      _overscroll = 0;
    } else if (notification is OverscrollNotification) {
      if (notification.dragDetails != null) {
        _overscroll += notification.overscroll;
      }
    } else if (notification is ScrollEndNotification) {
      final overscroll = _overscroll;
      _overscroll = 0;
      if (overscroll.abs() >= _swipeDistance) _swipe(overscroll > 0);
    }
    return false;
  }

  bool _onPageSwipe(PageSwipeNotification notification) {
    _swipe(notification.forward);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return PageSwipeScope._(
      claim: _claim,
      child: NotificationListener<PageSwipeNotification>(
        onNotification: _onPageSwipe,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _onPointerDown,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (_) => _drag = 0,
              onHorizontalDragUpdate: (details) =>
                  _drag += details.primaryDelta ?? 0,
              onHorizontalDragCancel: () => _drag = 0,
              onHorizontalDragEnd: _endDrag,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
