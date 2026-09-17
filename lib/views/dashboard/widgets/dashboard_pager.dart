import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero_layout.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_overlay.dart';
import 'package:reclash/views/dashboard/widgets/provider_summary_page.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pageTransitionDuration = Duration(milliseconds: 420);
const _swipeDistance = kTouchSlop * 2;
const _affordanceHeight = 40.0;

/// A wheel notch arrives as one discrete event, so the accumulator has to
/// forget an old gesture instead of adding the next flick to it.
const _wheelIdle = Duration(milliseconds: 220);

class DashboardPager extends ConsumerStatefulWidget {
  const DashboardPager({super.key});

  @override
  ConsumerState<DashboardPager> createState() => _DashboardPagerState();
}

class _DashboardPagerState extends ConsumerState<DashboardPager> {
  final _pageController = PageController();
  final _heroScrollController = ScrollController();
  final _providerScrollController = ScrollController();

  var _page = 0;
  var _animating = false;
  int? _pointer;
  Offset? _pointerPosition;
  var _pageDragDistance = 0.0;
  var _pageDragEligible = false;
  var _panZoomDistance = 0.0;
  ModalRoute<dynamic>? _route;
  LocalHistoryEntry? _backEntry;
  var _detachingBackEntry = false;
  var _pageActive = true;
  var _wheelDistance = 0.0;
  Duration _wheelStamp = Duration.zero;
  VelocityTracker? _velocityTracker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    _pageActive = PageActivityScope.isActiveOf(context);
    _syncBackEntry();
  }

  @override
  void dispose() {
    _detachBackEntry();
    _route = null;
    _pageController.dispose();
    _heroScrollController.dispose();
    _providerScrollController.dispose();
    super.dispose();
  }

  /// The second page is a layer over the dashboard, not a route of its own, so
  /// the system back button only reaches it through a local history entry.
  void _syncBackEntry() {
    final wanted = _page == 1 && _pageActive;
    if (wanted == (_backEntry != null)) return;
    if (!wanted) {
      _detachBackEntry();
      return;
    }
    final route = _route;
    if (route == null) return;
    final entry = LocalHistoryEntry(
      impliesAppBarDismissal: false,
      onRemove: _handleBackEntryRemoved,
    );
    _backEntry = entry;
    route.addLocalHistoryEntry(entry);
  }

  void _handleBackEntryRemoved() {
    _backEntry = null;
    if (_detachingBackEntry || !mounted) return;
    unawaited(_goToPage(0));
  }

  void _detachBackEntry() {
    final entry = _backEntry;
    if (entry == null) return;
    _backEntry = null;
    _detachingBackEntry = true;
    entry.remove();
    _detachingBackEntry = false;
  }

  void _setPage(int page) {
    setState(() => _page = page);
    _syncBackEntry();
  }

  bool _isAtBoundary(int direction) {
    final controller = _page == 0
        ? _heroScrollController
        : _providerScrollController;
    if (!controller.hasClients) return true;
    final position = controller.position;
    return direction < 0
        ? position.extentAfter <= kTouchSlop
        : position.extentBefore <= kTouchSlop;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_animating || _pointer != null) return;
    _pointer = event.pointer;
    _pointerPosition = event.position;
    _pageDragDistance = 0;
    _pageDragEligible = false;
    _velocityTracker = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _pointerPosition == null) return;
    _velocityTracker?.addPosition(event.timeStamp, event.position);
    final delta = event.position - _pointerPosition!;
    _pointerPosition = event.position;
    if (delta.dy.abs() <= delta.dx.abs()) return;
    final direction = delta.dy.sign.toInt();
    final canChangePage =
        (_page == 0 && direction < 0) || (_page == 1 && direction > 0);
    if (canChangePage && _isAtBoundary(direction)) {
      _pageDragDistance += delta.dy;
      _pageDragEligible = true;
    } else {
      _pageDragDistance = 0;
      _pageDragEligible = false;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    _velocityTracker?.addPosition(event.timeStamp, event.position);
    final velocity = _velocityTracker?.getVelocity().pixelsPerSecond.dy ?? 0;
    final upward =
        _pageDragEligible &&
        _page == 0 &&
        (_pageDragDistance <= -_swipeDistance ||
            velocity <= -kMinFlingVelocity);
    final downward =
        _pageDragEligible &&
        _page == 1 &&
        (_pageDragDistance >= _swipeDistance || velocity >= kMinFlingVelocity);
    _resetPointer();
    if (upward) {
      _goToPage(1);
    } else if (downward) {
      _goToPage(0);
    }
  }

  void _resetPointer() {
    _pointer = null;
    _pointerPosition = null;
    _pageDragDistance = 0;
    _pageDragEligible = false;
    _velocityTracker = null;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (_animating || event is! PointerScrollEvent) return;
    final delta = event.scrollDelta.dy;
    if (delta == 0 || delta.abs() <= event.scrollDelta.dx.abs()) return;
    if (event.timeStamp - _wheelStamp > _wheelIdle) _wheelDistance = 0;
    _wheelStamp = event.timeStamp;
    // A wheel scrolls the page it points at first; only its overscroll pages.
    final direction = -delta.sign.toInt();
    final canChangePage =
        (_page == 0 && direction < 0) || (_page == 1 && direction > 0);
    if (!canChangePage || !_isAtBoundary(direction)) {
      _wheelDistance = 0;
      return;
    }
    _wheelDistance -= delta;
    final page = switch ((_page, _wheelDistance)) {
      (0, <= -_swipeDistance) => 1,
      (1, >= _swipeDistance) => 0,
      _ => null,
    };
    if (page == null) return;
    _wheelDistance = 0;
    unawaited(_goToPage(page));
  }

  void _handlePanZoomStart(PointerPanZoomStartEvent event) {
    if (_animating) return;
    _panZoomDistance = 0;
  }

  void _handlePanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (_animating || event.panDelta.dy.abs() <= event.panDelta.dx.abs()) {
      return;
    }
    final direction = event.panDelta.dy.sign.toInt();
    final canChangePage =
        (_page == 0 && direction < 0) || (_page == 1 && direction > 0);
    if (canChangePage && _isAtBoundary(direction)) {
      _panZoomDistance += event.panDelta.dy;
    } else {
      _panZoomDistance = 0;
    }
  }

  void _handlePanZoomEnd(PointerPanZoomEndEvent event) {
    final page = switch ((_page, _panZoomDistance)) {
      (0, <= -_swipeDistance) => 1,
      (1, >= _swipeDistance) => 0,
      _ => null,
    };
    _panZoomDistance = 0;
    if (page != null) _goToPage(page);
  }

  Future<void> _goToPage(int page) async {
    if (_animating || page == _page || !_pageController.hasClients) return;
    setState(() => _animating = true);
    try {
      await _pageController.animateToPage(
        page,
        duration: context.motionDuration(_pageTransitionDuration),
        curve: Easing.standard,
      );
    } finally {
      if (mounted) setState(() => _animating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final byedpiMode = ref.watch(
      effectiveDesyncSettingProvider.select(
        (state) => state.enabled && state.onlyDpi,
      ),
    );
    final hasAnnounce = ref.watch(
      currentProfileProvider.select(
        (state) => state?.panelMeta?.announce?.trim().isNotEmpty ?? false,
      ),
    );
    return SeasonalDashboardOverlay(
      visible: _page == 0 && !_animating,
      child: LayoutBuilder(
        builder: (context, box) {
          final split = heroSplitFor(box);
          final hasProviderPage = !byedpiMode && !split;
          if (!hasProviderPage && _page != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (_pageController.hasClients) _pageController.jumpToPage(0);
              if (_page != 0) _setPage(0);
            });
          }
          if (split) {
            return _SplitBoard(
              heroScrollController: _heroScrollController,
              detailsScrollController: _providerScrollController,
            );
          }
          return CallbackShortcuts(
            bindings: hasProviderPage
                ? {
                    const SingleActivator(LogicalKeyboardKey.pageDown): () =>
                        unawaited(_goToPage(1)),
                    const SingleActivator(LogicalKeyboardKey.pageUp): () =>
                        unawaited(_goToPage(0)),
                  }
                : const {},
            // Key events only reach the bindings above through the focus chain,
            // and the hero page takes its autofocus with it when the pager leaves
            // it. This scope stays behind to catch the focus the page dropped.
            child: FocusScope(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: hasProviderPage ? _handlePointerDown : null,
                onPointerMove: hasProviderPage ? _handlePointerMove : null,
                onPointerUp: hasProviderPage ? _handlePointerUp : null,
                onPointerCancel: hasProviderPage
                    ? (_) => _resetPointer()
                    : null,
                onPointerSignal: hasProviderPage ? _handlePointerSignal : null,
                onPointerPanZoomStart: hasProviderPage
                    ? _handlePanZoomStart
                    : null,
                onPointerPanZoomUpdate: hasProviderPage
                    ? _handlePanZoomUpdate
                    : null,
                onPointerPanZoomEnd: hasProviderPage ? _handlePanZoomEnd : null,
                child: PageView(
                  key: const ValueKey('dashboard-pager'),
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _setPage,
                  children: [
                    _DashboardPage(
                      key: const ValueKey('dashboard-hero-page'),
                      affordance: byedpiMode
                          ? null
                          : _PageAffordance(
                              key: const ValueKey('dashboard-show-provider'),
                              icon: Icons.keyboard_arrow_down_rounded,
                              label: context
                                  .appLocalizations
                                  .dashboardShowProvider,
                              badge: hasAnnounce,
                              onPressed: () => _goToPage(1),
                            ),
                      child: PageActivityScope(
                        isActive: _pageActive && _page == 0 && !_animating,
                        child: HeroConnect(
                          scrollController: _heroScrollController,
                          onShowProvider: byedpiMode
                              ? null
                              : () => _goToPage(1),
                        ),
                      ),
                    ),
                    _DashboardPage(
                      key: const ValueKey('dashboard-provider-page'),
                      affordanceAtTop: true,
                      affordance: _PageAffordance(
                        key: const ValueKey('dashboard-show-connection'),
                        icon: Icons.keyboard_arrow_up_rounded,
                        label: context.appLocalizations.dashboardShowConnection,
                        onPressed: () => _goToPage(0),
                      ),
                      child: ProviderSummaryPage(
                        scrollController: _providerScrollController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Two columns instead of two pages: the orb keeps the left half, everything
/// the second page used to hide sits in one scroll on the right.
class _SplitBoard extends StatelessWidget {
  const _SplitBoard({
    required this.heroScrollController,
    required this.detailsScrollController,
  });

  final ScrollController heroScrollController;
  final ScrollController detailsScrollController;

  @override
  Widget build(BuildContext context) {
    final bottomInset = BottomInsetScope.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 8),
      child: BottomInsetScope(
        inset: 0,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth:
                  heroSplitLeftMaxWidth + heroSplitGap + heroSplitRightMaxWidth,
            ),
            child: Row(
              key: const ValueKey('dashboard-split-board'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: HeroConnect(
                    scrollController: heroScrollController,
                    mode: HeroLayoutMode.splitLeft,
                  ),
                ),
                const SizedBox(width: heroSplitGap),
                Expanded(
                  flex: 6,
                  child: HeroSplitDetails(
                    scrollController: detailsScrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    super.key,
    required this.child,
    this.affordance,
    this.affordanceAtTop = false,
  });

  final Widget child;
  final Widget? affordance;
  final bool affordanceAtTop;

  @override
  Widget build(BuildContext context) {
    final bottomInset = BottomInsetScope.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 4),
      child: Column(
        children: [
          if (affordanceAtTop && affordance != null)
            SizedBox(height: _affordanceHeight, child: affordance),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: heroBoardMaxWidth),
                child: BottomInsetScope(inset: 0, child: child),
              ),
            ),
          ),
          if (!affordanceAtTop)
            SizedBox(height: _affordanceHeight, child: affordance),
        ],
      ),
    );
  }
}

class _PageAffordance extends StatelessWidget {
  const _PageAffordance({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badge = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(this.icon, size: 22);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            visualDensity: VisualDensity.compact,
          ),
          onPressed: onPressed,
          icon: badge ? Badge(child: icon) : icon,
          label: Text(label),
        ),
      ),
    );
  }
}
