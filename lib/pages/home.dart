import 'package:reclash/views/tools.dart';
import 'package:reclash/views/tools/global_search.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/app_manager.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasViewSize = ref.watch(
      viewSizeProvider.select((size) => !size.isEmpty),
    );
    if (!hasViewSize) {
      return const SizedBox.shrink();
    }
    return ToolsSearchLauncher(
      child: HomeBackScopeContainer(
        child: AppSidebarContainer(
          child: _HomeShell(
            child: Consumer(
              builder: (_, ref, _) {
                final navigationItems = ref
                    .watch(currentNavigationItemsStateProvider)
                    .value;
                final isMobile = ref.watch(isMobileViewProvider);
                return _HomePageView(
                  navigationItems: navigationItems,
                  pageBuilder: (_, index) {
                    final navigationItem = navigationItems[index];
                    return _NavigationPage(
                      key: ValueKey(navigationItem.label),
                      item: navigationItem,
                      isMobile: isMobile,
                      view: navigationItem.builder(context),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeShell extends ConsumerWidget {
  const _HomeShell({required this.child});

  final Widget child;

  void _handleToPage(PageLabel pageLabel, WidgetRef ref) {
    ref.read(currentPageLabelProvider.notifier).toPage(pageLabel);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(navigationStateProvider);
    final isMobile = state.viewMode == ViewMode.mobile;
    final navigationItems = state.navigationItems;
    final floating = ref.watch(
      appSettingProvider.select((state) => state.floatingNavigationBar),
    );
    return Material(
      color: SurfaceLevel.page.colorOf(context.colorScheme),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FocusTraversalGroup(
                    policy: PageTraversalPolicy(),
                    child: BottomInsetScope(
                      inset: isMobile && floating
                          ? NavigationDock.insetOf(context)
                          : 0,
                      child: _BodyPadding(isMobile: isMobile, child: child),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: AnimatedVisibility.bottomNavigation(
                    visible: isMobile && floating,
                    child: _NavigationPadding(
                      child: NavigationDock(
                        destinations: [
                          for (final item in navigationItems)
                            NavigationDockDestination(
                              id: item.label,
                              glyph: item.glyph,
                              label: item.label.label,
                            ),
                        ],
                        selectedIndex: state.currentIndex,
                        onSelected: (index) {
                          _handleToPage(navigationItems[index].label, ref);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedVisibility.bottomNavigation(
            visible: isMobile && !floating,
            child: _NavigationPadding(
              child: AnimatedNavigationBar(
                destinations: [
                  for (final (index, item) in navigationItems.indexed)
                    NavigationBarEntry(
                      id: item.label,
                      icon: AnimatedGlyph(
                        glyph: item.glyph,
                        filled: index == state.currentIndex,
                      ),
                      label: item.label.label,
                    ),
                ],
                selectedIndex: state.currentIndex,
                onSelected: (index) {
                  _handleToPage(navigationItems[index].label, ref);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyPadding extends StatelessWidget {
  const _BodyPadding({required this.isMobile, required this.child});

  final bool isMobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: false,
      removeBottom: isMobile,
      removeLeft: isMobile,
      removeRight: isMobile,
      context: context,
      child: child,
    );
  }
}

class _NavigationPadding extends StatelessWidget {
  const _NavigationPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: false,
      removeLeft: true,
      removeRight: true,
      context: context,
      child: child,
    );
  }
}

class _NavigationPage extends StatelessWidget {
  const _NavigationPage({
    super.key,
    required this.item,
    required this.isMobile,
    required this.view,
  });

  final NavigationItem item;
  final bool isMobile;
  final Widget view;

  @override
  Widget build(BuildContext context) {
    final scopedView = PageFocusScope(child: view);
    final keptView = KeepScope(
      key: ValueKey(item.label),
      keep: item.keep,
      child: isMobile || item.label == PageLabel.tools
          ? scopedView
          : Navigator(
              key: ValueKey('${item.label.name}_navigator'),
              pages: [MaterialPage(child: scopedView)],
              onDidRemovePage: (_) {},
            ),
    );
    return Consumer(
      builder: (_, ref, child) {
        final isActive = ref.watch(
          shownPageLabelProvider.select((label) => label == item.label),
        );
        // A kept-alive page off screen still ticks its animations, and
        // each tick asks for a frame.
        return PageActivityScope(
          isActive: isActive,
          child: TickerMode(
            enabled: isActive,
            child: ExcludeFocus(
              excluding: !isActive,
              child: KeyboardInsetHold(child: child!),
            ),
          ),
        );
      },
      child: keptView,
    );
  }
}

class _HomePageView extends ConsumerStatefulWidget {
  final IndexedWidgetBuilder pageBuilder;
  final List<NavigationItem> navigationItems;

  const _HomePageView({
    required this.pageBuilder,
    required this.navigationItems,
  });

  @override
  ConsumerState createState() => _HomePageViewState();
}

enum _TabRole { idle, outgoing, incoming }

class _HomePageViewState extends ConsumerState<_HomePageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition = AnimationController(
    vsync: this,
    value: 1,
    duration: fadeTabDuration,
  )..addStatusListener(_onTransitionStatus);

  final Set<PageLabel> _mounted = {};
  PageLabel? _active;
  PageLabel? _outgoing;
  double _direction = 1;

  @override
  void initState() {
    super.initState();
    _active = _shownCurrent;
    if (_active != null) _mounted.add(_active!);
    ref.listenManual(currentPageLabelProvider, (_, _) => _syncCurrent());
  }

  PageLabel? get _shownCurrent => widget.navigationItems.isEmpty
      ? null
      : shownPageLabelOf(
          ref.read(currentPageLabelProvider),
          widget.navigationItems,
        );

  int _indexOf(PageLabel? label) =>
      widget.navigationItems.indexWhere((item) => item.label == label);

  void _pruneMounted() {
    final items = {for (final item in widget.navigationItems) item.label: item};
    _mounted.removeWhere(
      (label) =>
          !items.containsKey(label) ||
          (label != _active && label != _outgoing && !items[label]!.keep),
    );
  }

  void _syncCurrent() {
    final target = _shownCurrent;
    if (target != _active) {
      _goTo(target);
    } else if (_outgoing != null && _indexOf(_outgoing) == -1) {
      _finishTransition();
    }
    _pruneMounted();
  }

  void _goTo(PageLabel? target) {
    final animation = ref.read(appSettingProvider).tabAnimation;
    final leaving = _transition.isAnimating && _outgoing != null
        ? _outgoing
        : _active;
    final from = _indexOf(leaving);
    final to = _indexOf(target);
    final instant =
        !ref.read(isMobileViewProvider) ||
        context.disableAnimations ||
        from == -1 ||
        to == -1 ||
        leaving == target;
    _transition.stop();
    setState(() {
      _active = target;
      _outgoing = instant ? null : leaving;
      if (target != null) _mounted.add(target);
      if (from != -1 && to != -1) _direction = to >= from ? 1 : -1;
      _pruneMounted();
    });
    if (instant) {
      _transition.value = 1;
    } else {
      _transition.duration = animation == TabAnimation.fade
          ? fadeTabDuration
          : kTabScrollDuration;
      _transition.forward(from: 0);
    }
  }

  void _onTransitionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _outgoing != null) {
      setState(() {
        _outgoing = null;
        _pruneMounted();
      });
    }
  }

  void _finishTransition() {
    _transition.stop();
    _outgoing = null;
    _pruneMounted();
    _transition.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations && _transition.isAnimating) {
      _finishTransition();
    }
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCurrent();
    if (!ref.read(isMobileViewProvider) && _transition.isAnimating) {
      _finishTransition();
    }
  }

  @override
  void dispose() {
    _transition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = ref.watch(
      appSettingProvider.select(
        (state) => state.tabAnimation == TabAnimation.fade,
      ),
    );
    final idle = <Widget>[];
    Widget? outgoing;
    Widget? incoming;
    for (var index = 0; index < widget.navigationItems.length; index++) {
      final label = widget.navigationItems[index].label;
      if (!_mounted.contains(label)) continue;
      final role = label == _active
          ? _TabRole.incoming
          : label == _outgoing
          ? _TabRole.outgoing
          : _TabRole.idle;
      final page = _TabTransition(
        key: ValueKey(label),
        animation: _transition,
        role: role,
        fade: fade,
        direction: _direction,
        child: widget.pageBuilder(context, index),
      );
      switch (role) {
        case _TabRole.idle:
          idle.add(page);
        case _TabRole.outgoing:
          outgoing = page;
        case _TabRole.incoming:
          incoming = page;
      }
    }
    return Stack(
      fit: StackFit.expand,
      children: [...idle, ?outgoing, ?incoming],
    );
  }
}

class _TabTransition extends StatelessWidget {
  const _TabTransition({
    super.key,
    required this.animation,
    required this.role,
    required this.fade,
    required this.direction,
    required this.child,
  });

  final Animation<double> animation;
  final _TabRole role;
  final bool fade;
  final double direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final active = role != _TabRole.idle;
    final incoming = role == _TabRole.incoming;
    return Offstage(
      offstage: !active,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, child) {
          final t = (fade ? fadeTabCurve : Curves.easeOut).transform(
            animation.value,
          );
          final offset = !active || fade
              ? 0.0
              : incoming
              ? direction * (1 - t)
              : -direction * t;
          final opacity = active && fade ? (incoming ? t : 1 - t) : 1.0;
          return FractionalTranslation(
            translation: Offset(offset, 0),
            child: Opacity(opacity: opacity, child: child),
          );
        },
        child: RepaintBoundary(child: child),
      ),
    );
  }
}

class HomeBackScopeContainer extends ConsumerWidget {
  final Widget child;

  const HomeBackScopeContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context, ref) {
    return CommonPopScope(
      onPop: (context) async {
        final pageLabel = ref.read(shownPageLabelProvider);
        final realContext =
            GlobalObjectKey(pageLabel).currentContext ?? context;
        if (pageLabel == PageLabel.tools) {
          final host = const GlobalObjectKey(PageLabel.tools).currentState;
          if (host is ToolsViewState && await host.handleBack()) return false;
          if (!context.mounted) return false;
        }
        final canPop = Navigator.canPop(realContext);
        if (canPop) {
          Navigator.of(realContext).pop();
        } else if (system.isTV && pageLabel != PageLabel.dashboard) {
          ref
              .read(currentPageLabelProvider.notifier)
              .toPage(PageLabel.dashboard);
        } else {
          await ref.read(systemActionProvider.notifier).handleClose();
        }
        return false;
      },
      child: child,
    );
  }
}
