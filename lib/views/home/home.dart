import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/app_manager.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/start_button.dart';
import 'package:reclash/widgets/widgets.dart';

typedef OnSelected = void Function(int index);

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
    return HomeBackScopeContainer(
      child: PageFocusScope(
        directionalTraversalEdgeBehavior: TraversalEdgeBehavior.stop,
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
    // The dock owns the start control on a phone; the hero orb owns it on the
    // new dashboard, so the trailing button only rides the classic layout.
    final onClassicDashboard = !ref.watch(newDashboardEnabledProvider);
    final hasStartControl =
        ref.watch(profilesProvider.select((state) => state.isNotEmpty)) ||
        ref.watch(
          effectiveDesyncSettingProvider.select(
            (state) => state.enabled && state.onlyDpi,
          ),
        );
    final showStart = isMobile && onClassicDashboard && hasStartControl;
    // The hoisted wallpaper paints one backdrop for the whole content region;
    // a solid shell surface here would cover it, so go transparent when active.
    final wallpaperActive = ref.watch(effectiveWallpaperImageProvider) != null;
    // The bar is only collapsed in desktop view, never unmounted: one tree
    // shape across view modes.
    return Material(
      color: wallpaperActive ? Colors.transparent : context.colorScheme.surface,
      child: Stack(
        children: [
          Positioned.fill(
            child: FocusTraversalGroup(
              policy: PageTraversalPolicy(),
              child: MediaQuery.removePadding(
                removeTop: false,
                removeBottom: isMobile,
                removeLeft: isMobile,
                removeRight: isMobile,
                context: context,
                child: BottomInsetScope(
                  inset: isMobile ? AppNavBar.insetOf(context) : 0,
                  child: child,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedVisibility.bottomNavigation(
              visible: isMobile,
              child: MediaQuery.removePadding(
                removeTop: true,
                removeBottom: false,
                removeLeft: true,
                removeRight: true,
                context: context,
                child: AppNavBar(
                  onToPage: (label) => _handleToPage(label, ref),
                  trailing: showStart ? const StartButton() : null,
                ),
              ),
            ),
          ),
        ],
      ),
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
    final scopedView = PageFocusScope(
      child: DockedPageScope(docked: isMobile, child: view),
    );
    final keptView = KeepScope(
      key: ValueKey(item.label),
      keep: item.keep,
      child: isMobile
          ? scopedView
          : Navigator(
              key: ValueKey('${item.label.name}_navigator'),
              pages: [FocusTraversalPage<void>(child: scopedView)],
              onDidRemovePage: (_) {},
            ),
    );
    return Consumer(
      builder: (_, ref, child) {
        final isActive = ref.watch(
          currentPageLabelProvider.select((label) => label == item.label),
        );
        return PageActivityScope(
          isActive: isActive,
          child: ExcludeFocus(excluding: !isActive, child: child!),
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

class _HomePageViewState extends ConsumerState<_HomePageView> {
  late PageController _pageController;

  List<int>? _order;
  int _slide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    ref.listenManual(currentPageLabelProvider, (prev, next) {
      if (prev != next) {
        _toPage(next);
      }
    });
    ref.listenManual(currentNavigationItemsStateProvider, (prev, next) {
      if (prev?.value.length != next.value.length) {
        _reconcilePage();
      }
    });
    // A tool opened as a full-screen route or side sheet lives on a navigator
    // chosen by the view width, so a breakpoint crossing strands it over a
    // layout that no longer matches. Dismiss transient routes on the change.
    ref.listenManual(viewModeProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      });
    });
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A tab appearing or leaving shifts the indices of the pages after it. The
    // page view rebuilds this frame but the controller keeps its old pixel
    // offset, which now points at a neighbour, so the active page would flash
    // past to it until the post-frame reconcile lands. Re-pin the controller
    // to the active page's new index here, before this frame paints.
    if (oldWidget.navigationItems.length == widget.navigationItems.length) {
      return;
    }
    if (!_pageController.hasClients) {
      return;
    }
    final index = _pageIndex;
    if (index == -1) {
      return;
    }
    if (_order == null && _pageController.page?.round() != index) {
      _pageController.jumpToPage(index);
    }
  }

  int get _pageIndex {
    final pageLabel = ref.read(currentPageLabelProvider);
    return widget.navigationItems.indexWhere((item) => item.label == pageLabel);
  }

  Future<void> _toPage(
    PageLabel pageLabel, [
    bool ignoreAnimateTo = false,
  ]) async {
    if (!mounted) {
      return;
    }
    final index = widget.navigationItems.indexWhere(
      (item) => item.label == pageLabel,
    );
    if (index == -1) {
      return;
    }
    final tabAnimation = ref.read(appSettingProvider).tabAnimation;
    final slide = ++_slide;
    final page = _pageController.hasClients
        ? _pageController.page?.round() ?? index
        : index;
    final current = _order?[page] ?? page;
    if (_order != null) {
      setState(() => _order = null);
      _pageController.jumpToPage(current);
    }
    if (ignoreAnimateTo ||
        tabAnimation == TabAnimation.off ||
        context.disableAnimations) {
      _pageController.jumpToPage(index);
      return;
    }
    // As TabBarView does, so no page between is built and painted on the way.
    if ((index - current).abs() > 1) {
      final adjacent = index > current ? index - 1 : index + 1;
      setState(() {
        _order = List.generate(widget.navigationItems.length, (item) => item)
          ..[adjacent] = current
          ..[current] = adjacent;
      });
      _pageController.jumpToPage(adjacent);
    }
    final fade = tabAnimation == TabAnimation.fade;
    await _pageController.animateToPage(
      index,
      duration: fade ? fadeTabDuration : slideTabDuration,
      curve: fade ? fadeTabCurve : slideTabCurve,
    );
    if (mounted && slide == _slide && _order != null) {
      setState(() => _order = null);
    }
  }

  void _reconcilePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _order = null;
      final pageLabel = ref.read(currentPageLabelProvider);
      final index = widget.navigationItems.indexWhere(
        (item) => item.label == pageLabel,
      );
      if (index == -1) {
        ref
            .read(currentPageLabelProvider.notifier)
            .toPage(widget.navigationItems.first.label);
        return;
      }
      // A tab appearing or leaving elsewhere shifts indices but leaves the
      // active page where it sits; jumping the controller then only forces a
      // needless relayout flash, so sync it only when the active page moved.
      final current = _pageController.hasClients
          ? _pageController.page?.round()
          : null;
      if (current == index) {
        return;
      }
      _toPage(pageLabel, true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = ref.watch(
      currentNavigationItemsStateProvider.select((state) => state.value.length),
    );
    final fade = ref.watch(
      appSettingProvider.select(
        (state) => state.tabAnimation == TabAnimation.fade,
      ),
    );
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<PageLabel>) {
          return null;
        }
        final index = widget.navigationItems.indexWhere(
          (item) => item.label == key.value,
        );
        if (index == -1) {
          return null;
        }
        return _order?.indexOf(index) ?? index;
      },
      itemBuilder: (context, index) {
        final page = widget.pageBuilder(context, _order?[index] ?? index);
        return _FadeTabPage(
          key: page.key,
          controller: _pageController,
          position: index,
          enabled: fade,
          child: page,
        );
      },
    );
  }
}

/// Cancels the page view's slide so a tab switch cross-fades in place, and
/// wraps every page even when off so switching the setting keeps their state.
class _FadeTabPage extends StatelessWidget {
  const _FadeTabPage({
    super.key,
    required this.controller,
    required this.position,
    required this.enabled,
    required this.child,
  });

  final PageController controller;
  final int position;
  final bool enabled;
  final Widget child;

  double get _delta {
    if (!controller.hasClients || !controller.position.hasContentDimensions) {
      return 0;
    }
    final page = controller.page ?? position.toDouble();
    return (position - page).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final delta = enabled ? _delta : 0.0;
        return FractionalTranslation(
          translation: Offset(-delta, 0),
          child: Opacity(opacity: 1 - delta.abs(), child: child),
        );
      },
      child: child,
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
        final pageLabel = ref.read(currentPageLabelProvider);
        final realContext =
            GlobalObjectKey(pageLabel).currentContext ?? context;
        final canPop = Navigator.canPop(realContext);
        if (canPop) {
          Navigator.of(realContext).pop();
          return false;
        }
        final notifier = ref.read(currentPageLabelProvider.notifier);
        final returnPage = notifier.takeReturnPage();
        if (returnPage != null) {
          notifier.toPage(returnPage);
          return false;
        }
        // Escape walks back through the app but never closes it: with nothing
        // left to go back to it simply stops, unlike the system back button.
        if (globalState.escapeBackDepth == 0) {
          await ref.read(systemActionProvider.notifier).handleClose();
        }
        return false;
      },
      child: child,
    );
  }
}
