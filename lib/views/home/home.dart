import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/app_manager.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/start_button.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // The bar is only collapsed in desktop view, never unmounted: one tree
    // shape across view modes.
    return Material(
      color: context.colorScheme.surface,
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

class _HomePageViewState extends ConsumerState<_HomePageView>
    with SingleTickerProviderStateMixin {
  static const _switchDuration = Duration(milliseconds: 140);

  late PageController _pageController;
  late final AnimationController _switchController;
  late final CurvedAnimation _switchIn;

  double _incomingDirection = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    _switchController = AnimationController(
      vsync: this,
      duration: _switchDuration,
      value: 1,
    );
    _switchIn = CurvedAnimation(
      parent: _switchController,
      curve: Easing.standardDecelerate,
    );
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
  }

  int get _pageIndex {
    final pageLabel = ref.read(currentPageLabelProvider);
    return widget.navigationItems.indexWhere((item) => item.label == pageLabel);
  }

  Future<void> _toPage(PageLabel pageLabel) async {
    if (!mounted) {
      return;
    }
    final index = widget.navigationItems.indexWhere(
      (item) => item.label == pageLabel,
    );
    if (index == -1) {
      return;
    }
    final currentPage = _pageController.hasClients
        ? _pageController.page?.round()
        : null;
    if (currentPage == index) {
      return;
    }
    // A jump, never a scroll: scrolling would build every intermediate tab.
    final animate =
        ref.read(appSettingProvider).isAnimateToPage &&
        !context.disableAnimations;
    if (animate) {
      if (currentPage != null) {
        _incomingDirection = (index - currentPage).sign.toDouble();
      }
      _switchController.forward(from: 0);
    } else {
      _switchController.value = 1;
    }
    _pageController.jumpToPage(index);
  }

  void _reconcilePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
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
      _toPage(pageLabel);
    });
  }

  @override
  void dispose() {
    _switchIn.dispose();
    _switchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = ref.watch(
      currentNavigationItemsStateProvider.select((state) => state.value.length),
    );
    return AnimatedBuilder(
      animation: _switchIn,
      builder: (context, child) {
        final t = _switchIn.value;
        final slide = _incomingDirection * (1 - t) * 0.08;
        return Transform.translate(
          offset: Offset(slide * MediaQuery.sizeOf(context).width, 0),
          child: Opacity(opacity: 0.4 + 0.6 * t, child: child),
        );
      },
      child: PageView.builder(
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
          return index == -1 ? null : index;
        },
        itemBuilder: (context, index) {
          return widget.pageBuilder(context, index);
        },
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
