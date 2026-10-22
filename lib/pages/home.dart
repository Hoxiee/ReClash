import 'dart:async';

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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _pageKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
  ];

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handlePageShortcut);
  }

  bool _handlePageShortcut(KeyEvent event) {
    if (!system.isDesktop || event is! KeyDownEvent) return false;
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext?.findAncestorWidgetOfExactType<EditableText>() != null) {
      return false;
    }
    final keyboard = HardwareKeyboard.instance;
    final macOS = system.isMacOS;
    if (!(macOS ? keyboard.isMetaPressed : keyboard.isControlPressed) ||
        keyboard.isAltPressed ||
        keyboard.isShiftPressed ||
        (macOS ? keyboard.isControlPressed : keyboard.isMetaPressed)) {
      return false;
    }
    final index = _pageKeys.indexOf(event.logicalKey);
    final navigationItems = ref.read(currentNavigationItemsStateProvider).value;
    if (index < 0 || index >= navigationItems.length) return false;
    ref
        .read(currentPageLabelProvider.notifier)
        .toPage(navigationItems[index].label);
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handlePageShortcut);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasViewSize = ref.watch(
      viewSizeProvider.select((size) => !size.isEmpty),
    );
    if (!hasViewSize) {
      return const SizedBox.shrink();
    }
    return ToolsSearchLauncher(
      child: HomeBackScopeContainer(
        child: ShellScrimScope(
          child: AppSidebarContainer(
            child: PageViewport(
              child: _HomeShell(
                child: Consumer(
                  builder: (_, ref, _) {
                    final navigationItems = ref
                        .watch(currentNavigationItemsStateProvider)
                        .value;
                    final isMobile = ref.watch(isMobileViewProvider);
                    return _HomePageView(
                      navigationItems: navigationItems,
                      axis: isMobile ? Axis.horizontal : Axis.vertical,
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
    final toolsDetail =
        state.pageLabel == PageLabel.tools &&
        ref.watch(
          toolsSessionProvider.select((state) => state.path.isNotEmpty),
        );
    final showNavigation =
        isMobile &&
        !toolsDetail &&
        MediaQuery.viewInsetsOf(context).bottom == 0;
    return Material(
      color: PageBackgroundRegistration.maybeOf(context) == null
          ? SurfaceLevel.page.colorOf(context.colorScheme)
          : Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: PageBackground(
              baseColor: SurfaceLevel.page.colorOf(context.colorScheme),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FocusTraversalGroup(
                      policy: PageTraversalPolicy(),
                      child: _AnimatedBottomInset(
                        inset: showNavigation && floating
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
                      visible: showNavigation && floating,
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
          ),
          AnimatedVisibility.bottomNavigation(
            visible: showNavigation && !floating,
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

/// Lets the dock's room go only once a page opened over it has settled, so
/// nothing shifts under the opening transition; room is added at once.
class _AnimatedBottomInset extends StatefulWidget {
  const _AnimatedBottomInset({required this.inset, required this.child});

  final double inset;
  final Widget child;

  @override
  State<_AnimatedBottomInset> createState() => _AnimatedBottomInsetState();
}

class _AnimatedBottomInsetState extends State<_AnimatedBottomInset> {
  late double _inset = widget.inset;
  Timer? _release;

  @override
  void didUpdateWidget(_AnimatedBottomInset oldWidget) {
    super.didUpdateWidget(oldWidget);
    _release?.cancel();
    if (widget.inset >= _inset) {
      _inset = widget.inset;
      return;
    }
    _release = Timer(SharedXPageTransition.duration, () {
      if (mounted) setState(() => _inset = widget.inset);
    });
  }

  @override
  void dispose() {
    _release?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BottomInsetScope(inset: _inset, child: widget.child);
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
              pages: [
                MaterialPage(
                  child: Builder(
                    builder: (context) =>
                        PageViewport.inherit(context, child: scopedView),
                  ),
                ),
              ],
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

  final Axis axis;

  const _HomePageView({
    required this.pageBuilder,
    required this.navigationItems,
    required this.axis,
  });

  @override
  ConsumerState createState() => _HomePageViewState();
}

class _HomePageViewState extends ConsumerState<_HomePageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition = AnimationController(
    vsync: this,
    value: 1,
    duration: slideTabDuration,
  )..addStatusListener(_onTransitionStatus);

  final Set<PageLabel> _mounted = {};
  final _plan = TabMotionPlan<PageLabel>();
  PageLabel? _active;

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
          (label != _active && !_plan.contains(label) && !items[label]!.keep),
    );
  }

  void _syncCurrent() {
    final target = _shownCurrent;
    if (target != _active) {
      _goTo(target);
    } else if (_plan.keys.any((label) => _indexOf(label) == -1)) {
      _finishTransition();
    }
    _pruneMounted();
  }

  void _goTo(PageLabel? target) {
    final previous = _active;
    final from = _indexOf(previous);
    final to = _indexOf(target);
    final instant =
        context.disableAnimations ||
        from == -1 ||
        to == -1 ||
        _plan.keys.any((label) => _indexOf(label) == -1);
    if (instant) {
      _plan.clear();
    } else {
      _plan.retarget(
        target!,
        current: previous!,
        value: _transition.value,
        forward: to > from,
        fade: ref.read(appSettingProvider).tabAnimation == TabAnimation.fade,
      );
    }
    _transition.stop();
    setState(() {
      _active = target;
      if (target != null) _mounted.add(target);
      _pruneMounted();
    });
    if (instant) {
      _transition.value = 1;
    } else {
      _transition.duration = _plan.duration;
      _transition.forward(from: 0);
    }
  }

  void _onTransitionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _plan.isActive) {
      setState(() {
        _plan.clear();
        _pruneMounted();
      });
    }
  }

  void _finishTransition() {
    _transition.stop();
    _plan.clear();
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
    if (widget.axis != oldWidget.axis && _plan.isActive) _finishTransition();
    _syncCurrent();
  }

  @override
  void dispose() {
    _transition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    final idle = <Widget>[];
    final moving = <Widget>[];
    for (var index = 0; index < widget.navigationItems.length; index++) {
      final label = widget.navigationItems[index].label;
      if (!_mounted.contains(label)) continue;
      final shown = label == active || _plan.contains(label);
      final page = Offstage(
        key: ValueKey(label),
        offstage: !shown,
        child: TabMotionTransition(
          animation: _transition,
          frame: () =>
              _plan.frameOf(label, current: active!, value: _transition.value),
          axis: widget.axis,
          child: widget.pageBuilder(context, index),
        ),
      );
      (shown ? moving : idle).add(page);
    }
    // Keep vertically sliding pages below the window header.
    return ClipRect(
      clipBehavior: _plan.isActive && widget.axis == Axis.vertical
          ? Clip.hardEdge
          : Clip.none,
      child: Stack(fit: StackFit.expand, children: [...idle, ...moving]),
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
