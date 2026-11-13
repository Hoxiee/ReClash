import 'package:flutter/widgets.dart';

const _swipeDistance = 48.0;
const _swipeVelocity = 400.0;

/// A swipe an inner pager could not take because it sat on its last page: it
/// bubbles up to the [PageSwipe] that owns the next level.
class PageSwipeNotification extends Notification {
  const PageSwipeNotification({required this.forward});

  final bool forward;
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

  int get _sign => Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void _endDrag(DragEndDetails details) {
    final distance = _drag * _sign;
    final velocity = (details.primaryVelocity ?? 0) * _sign;
    _drag = 0;
    final forward = velocity < -_swipeVelocity || distance <= -_swipeDistance;
    final back = velocity > _swipeVelocity || distance >= _swipeDistance;
    if (forward != back) widget.onSwipe(forward);
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
      if (overscroll.abs() >= _swipeDistance) widget.onSwipe(overscroll > 0);
    }
    return false;
  }

  bool _onPageSwipe(PageSwipeNotification notification) {
    widget.onSwipe(notification.forward);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return NotificationListener<PageSwipeNotification>(
      onNotification: _onPageSwipe,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
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
    );
  }
}
