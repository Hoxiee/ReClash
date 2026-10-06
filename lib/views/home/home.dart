import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/app_manager.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/start_button.dart';
import 'package:reclash/widgets/widgets.dart';

typedef OnSelected = void Function(int index);

const _exitConfirmWindow = Duration(seconds: 2);

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
                final isBar = ref.watch(isBarSurfaceProvider);
                return _HomePageView(
                  navigationItems: navigationItems,
                  // The rail stacks its destinations vertically, so a page swap
                  // slides along the same axis the user just moved on; the bar
                  // keeps the horizontal slide that matches its row.
                  vertical: !isBar,
                  pageBuilder: (_, index) {
                    final navigationItem = navigationItems[index];
                    return _NavigationPage(
                      key: ValueKey(navigationItem.label),
                      item: navigationItem,
                      isBar: isBar,
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
    final isBar = ref.watch(isBarSurfaceProvider);
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
    final showStart = isBar && onClassicDashboard && hasStartControl;
    // The hoisted wallpaper paints one backdrop for the whole content region;
    // a solid shell surface here would cover it, so go transparent when active.
    final wallpaperActive = ref.watch(effectiveWallpaperImageProvider) != null;
    // The bar is only collapsed in rail mode, never unmounted: one tree
    // shape across surfaces.
    return Material(
      color: wallpaperActive ? Colors.transparent : context.colorScheme.surface,
      child: Stack(
        children: [
          Positioned.fill(
            child: FocusTraversalGroup(
              policy: PageTraversalPolicy(),
              child: MediaQuery.removePadding(
                removeTop: false,
                removeBottom: isBar,
                removeLeft: isBar,
                removeRight: isBar,
                context: context,
                child: BottomInsetScope(
                  inset: isBar ? AppNavBar.insetOf(context) : 0,
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
              visible: isBar,
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
    required this.isBar,
    required this.view,
  });

  final NavigationItem item;
  final bool isBar;
  final Widget view;

  @override
  Widget build(BuildContext context) {
    final scopedView = PageFocusScope(
      child: DockedPageScope(docked: isBar, child: view),
    );
    final keptView = KeepScope(
      key: ValueKey(item.label),
      keep: item.keep,
      child: isBar
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
  final bool vertical;

  const _HomePageView({
    required this.pageBuilder,
    required this.navigationItems,
    required this.vertical,
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
    duration: slideTabDuration,
  );

  // The page set is addressed by label, never by a controller offset: a tab
  // appearing, leaving, or swapping places can no longer desync the view, since
  // there is no index to keep in step. Only ever-visited labels mount, and a
  // page that does not keep its state leaves the tree once it stops showing.
  final Set<PageLabel> _mounted = {};
  PageLabel? _active;
  PageLabel? _outgoing;
  double _direction = 1;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _active = ref.read(currentPageLabelProvider);
    if (_active != null) {
      _mounted.add(_active!);
    }
    ref.listenManual(currentPageLabelProvider, (prev, next) {
      if (next != _active) {
        _goTo(next);
      }
    });
  }

  int _indexOf(PageLabel? label) {
    return widget.navigationItems.indexWhere((item) => item.label == label);
  }

  bool _keeps(PageLabel label) {
    for (final item in widget.navigationItems) {
      if (item.label == label) {
        return item.keep;
      }
    }
    return false;
  }

  void _goTo(PageLabel next) {
    final animation = ref.read(appSettingProvider).tabAnimation;
    final instant =
        animation == TabAnimation.off ||
        context.disableAnimations ||
        _active == null;
    // Retargeting mid-flight keeps the page we were actually leaving as the
    // outgoing one, so a half-shown intermediate never flashes on the way.
    final leaving = _transition.isAnimating && _outgoing != null
        ? _outgoing
        : _active;
    final from = _indexOf(leaving);
    final to = _indexOf(next);
    final token = ++_seq;
    setState(() {
      _outgoing = instant ? null : leaving;
      _active = next;
      _mounted.add(next);
      if (from != -1 && to != -1) {
        _direction = to >= from ? 1 : -1;
      }
    });
    if (_outgoing == null) {
      _transition.value = 1;
      return;
    }
    _transition.duration = animation == TabAnimation.fade
        ? fadeTabDuration
        : slideTabDuration;
    _transition.forward(from: 0).whenComplete(() {
      if (token == _seq) {
        _settle();
      }
    });
  }

  void _settle() {
    if (!mounted) {
      return;
    }
    final gone = _outgoing;
    setState(() {
      _outgoing = null;
      if (gone != null && (!_keeps(gone) || _indexOf(gone) == -1)) {
        _mounted.remove(gone);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final labels = {for (final item in widget.navigationItems) item.label};
    _mounted.removeWhere((label) => !labels.contains(label));
    if (_outgoing != null && !labels.contains(_outgoing)) {
      _outgoing = null;
    }
    // The active tab left the set (e.g. proxies vanished while open): fall back
    // to the first tab, syncing the shared label after this frame.
    if (_active == null || !labels.contains(_active)) {
      final first = widget.navigationItems.isEmpty
          ? null
          : widget.navigationItems.first.label;
      _active = first;
      if (first != null) {
        _mounted.add(first);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(currentPageLabelProvider.notifier).toPage(first);
          }
        });
      }
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
      if (!_mounted.contains(label)) {
        continue;
      }
      final role = label == _active
          ? _TabRole.incoming
          : label == _outgoing
          ? _TabRole.outgoing
          : _TabRole.idle;
      final tile = _TabTransition(
        key: ValueKey(label),
        animation: _transition,
        role: role,
        fade: fade,
        direction: _direction,
        vertical: widget.vertical,
        child: widget.pageBuilder(context, index),
      );
      switch (role) {
        case _TabRole.idle:
          idle.add(tile);
        case _TabRole.outgoing:
          outgoing = tile;
        case _TabRole.incoming:
          incoming = tile;
      }
    }
    // Offstage pages first, the outgoing page under the incoming one so a
    // cross-fade or slide reads correctly.
    return Stack(
      fit: StackFit.expand,
      children: [...idle, ?outgoing, ?incoming],
    );
  }
}

/// Places a mounted tab for the frame: offstage when idle (state kept, nothing
/// painted), otherwise sliding or cross-fading as the active page changes.
class _TabTransition extends StatelessWidget {
  const _TabTransition({
    super.key,
    required this.animation,
    required this.role,
    required this.fade,
    required this.direction,
    required this.vertical,
    required this.child,
  });

  final Animation<double> animation;
  final _TabRole role;
  final bool fade;
  final double direction;
  final bool vertical;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final incoming = role == _TabRole.incoming;
    final active = role != _TabRole.idle;
    // The wrapper type never changes with the role: an idle page toggles only
    // Offstage, so its subtree (nested navigators, scroll state) is never torn
    // down and rebuilt when it stops or starts being the visible tab.
    return Offstage(
      offstage: !active,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, child) {
          final t = animation.value;
          final dx = !active || fade
              ? 0.0
              : incoming
              ? direction * (1 - t)
              : -direction * t;
          final opacity = active && fade ? (incoming ? t : 1 - t) : 1.0;
          return FractionalTranslation(
            translation: vertical ? Offset(0, dx) : Offset(dx, 0),
            child: Opacity(opacity: opacity, child: child),
          );
        },
        child: child,
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
        final notifier = ref.read(currentPageLabelProvider.notifier);
        // A drilled tab handles its own back via its own pop entry, which fires
        // alongside this root one; bail so the root does not also close the app.
        if (ref.read(navPathProvider(pageLabel)).isNotEmpty) {
          return false;
        }
        final realContext =
            GlobalObjectKey(pageLabel).currentContext ?? context;
        final canPop = Navigator.canPop(realContext);
        if (canPop) {
          Navigator.of(realContext).pop();
          return false;
        }
        final returnPage = notifier.takeReturnPage();
        if (returnPage != null) {
          notifier.toPage(returnPage);
          return false;
        }
        // Back walks home before it leaves: only the dashboard closes the app.
        if (pageLabel != PageLabel.dashboard) {
          notifier.toPage(PageLabel.dashboard);
          return false;
        }
        // Escape walks back through the app but never closes it: with nothing
        // left to go back to it simply stops, unlike the system back button.
        if (globalState.escapeBackDepth == 0) {
          // Confirm exit: the first back arms a window, the next one leaves.
          final now = DateTime.now();
          final armedAt = globalState.backExitArmedAt;
          if (armedAt == null || now.difference(armedAt) > _exitConfirmWindow) {
            globalState.backExitArmedAt = now;
            await app?.tip(context.appLocalizations.pressBackAgainToExit);
            return false;
          }
          globalState.backExitArmedAt = null;
          // On Android leaving means backgrounding the task: finishing the
          // activity while the VPN keeps the engine alive relaunches blank.
          if (app != null) {
            await app!.moveTaskToBack();
          } else {
            await ref.read(systemActionProvider.notifier).handleClose();
          }
        }
        return false;
      },
      child: child,
    );
  }
}
