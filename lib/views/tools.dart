import 'dart:async';

import 'package:collection/collection.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/tool_commands.dart';
import 'package:reclash/views/tools/catalog.dart';
import 'package:reclash/views/tools/navigation.dart';
import 'package:reclash/views/tools/search.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxBodyWidth = 840.0;

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => ToolsViewState();
}

class ToolsViewState extends ConsumerState<ToolsView> {
  final _navigator = GlobalKey<NavigatorState>();
  final _searchFocus = FocusNode();
  final _observer = _ToolsRouteObserver();
  var _split = false;
  var _navigating = false;
  final _recentIds = <String>[];

  static const _recentLimit = 6;

  @override
  void initState() {
    super.initState();
    ref.listenManual(toolsSessionProvider.select((s) => s.pendingCommand), (
      _,
      command,
    ) {
      if (command != null) _scheduleCommand();
    }, fireImmediately: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PageActivityScope.isActiveOf(context)) _scheduleCommand();
  }

  void _scheduleCommand() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !PageActivityScope.isActiveOf(context)) return;
      final command = ref.read(toolsSessionProvider.notifier).takeCommand();
      if (command != null) unawaited(_execute(command));
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<bool> handleBack() async {
    final navigator = _navigator.currentState;
    if (_observer.top?.settings is Page && _searchFocus.hasFocus) {
      if (ref.read(toolsSessionProvider).query.isNotEmpty) {
        ref.read(toolsSessionProvider.notifier).search('');
      } else {
        _searchFocus.unfocus();
      }
      return true;
    }
    if (navigator != null && navigator.canPop()) {
      await navigator.maybePop();
      return true;
    }
    final session = ref.read(toolsSessionProvider);
    if (session.query.isNotEmpty) {
      ref.read(toolsSessionProvider.notifier).search('');
      return true;
    }
    return false;
  }

  Future<bool> _dismissEditors({Route<dynamic>? until}) async {
    final navigator = _navigator.currentState;
    while (navigator != null &&
        _observer.top?.settings is! Page &&
        !identical(_observer.top, until) &&
        navigator.canPop()) {
      final previous = _observer.top;
      if (previous == null || !await canLeaveRoute(previous) || !mounted) {
        return false;
      }
      if (previous.isActive) navigator.pop();
      if (identical(previous, _observer.top)) return false;
    }
    return mounted;
  }

  Future<void> openEntry(ToolEntry entry, {bool push = false}) async {
    if (_navigating) return;
    _navigating = true;
    try {
      if (!await _dismissEditors()) return;
      if (!mounted) return;
      if (entry.command case final command?) {
        await _execute(command);
        return;
      }
      final route = entry.unavailableReason == null
          ? entry.route
          : entry.fallback;
      if (route == null) return;
      final current = ref.read(toolsSessionProvider).path;
      if (!push && current.isNotEmpty && current.last.page != route.page) {
        for (final previous in _observer.pages.toList().reversed) {
          if (!await canLeaveRoute(previous) || !mounted) return;
        }
      }
      if (entry.unavailableReason case final reason?) {
        context.showNotifier(reason);
      } else {
        _recordRecent(entry.id);
      }
      ref.read(toolsSessionProvider.notifier).open(route, push: push);
    } finally {
      _navigating = false;
    }
  }

  Future<void> _execute(ToolCommand command) async {
    final l = context.appLocalizations;
    final confirmation = switch (command) {
      ToolCommand.restartCore => l.restartCoreTip,
      ToolCommand.closeConnections => l.toolsCloseConnectionsConfirm,
      ToolCommand.updateResources => l.toolsUpdateResourcesConfirm,
      ToolCommand.checkUpdates => '',
    };
    try {
      final completed = await ref
          .read(toolCommandsProvider.notifier)
          .execute(
            command,
            context: context,
            confirm: () async =>
                mounted &&
                await dialogs.showMessage(
                      context: sheetNavigatorOf(context).context,
                      message: TextSpan(text: confirmation),
                    ) ==
                    true &&
                mounted,
          );
      if (mounted && completed && command != ToolCommand.checkUpdates) {
        context.showNotifier(l.toolsCompleted);
      }
    } catch (error) {
      if (mounted) {
        context.showNotifier(
          userFacingErrorMessage(error, l),
          level: MessageLevel.error,
        );
      }
    }
  }

  Future<void> openSearch() async {
    if (_split || ref.read(toolsSessionProvider).path.isEmpty) {
      ref.read(toolsSessionProvider.notifier).focusSearch();
      return;
    }
    final context = _observer.top?.navigator?.context ?? this.context;
    final entry = await showSheet<ToolEntry>(
      context: context,
      builder: (sheetContext) => ToolsCatalogPanel(
        autofocus: true,
        onDismiss: () => Navigator.of(sheetContext).pop(),
        onSelect: (entry) async => Navigator.of(sheetContext).pop(entry),
      ),
    );
    if (mounted && entry != null) await openEntry(entry);
  }

  Future<void> _popTo(int depth) async {
    if (_navigating) return;
    _navigating = true;
    try {
      if (!await _dismissEditors()) return;
      for (final previous
          in _observer.pages.toList().skip(depth).toList().reversed) {
        if (!await canLeaveRoute(previous) || !mounted) return;
      }
      ref.read(toolsSessionProvider.notifier).popTo(depth);
    } finally {
      _navigating = false;
    }
  }

  Future<void> _popToDetail(Route<dynamic> target) async {
    if (_navigating) return;
    _navigating = true;
    try {
      await _dismissEditors(until: target);
    } finally {
      _navigating = false;
    }
  }

  void _selectPathSegment(int index) {
    if (index < _observer.pages.length) {
      unawaited(_popTo(index + 1));
      return;
    }
    final target = _observer._routes
        .whereType<_ToolsDetailRoute<dynamic>>()
        .where((route) => route.depth == index)
        .lastOrNull;
    if (target != null) unawaited(_popToDetail(target));
  }

  /// The path header of [route], ending in its own title where it has one.
  String? _pathOf(Route<dynamic> route) {
    if (route is _ToolsDetailRoute) {
      final segments = [?route.parent, ?_scaffoldTitleIn(route.subtreeContext)];
      return segments.isEmpty ? null : segments.join(' › ');
    }
    final page = route.settings;
    return page is _ToolsPage && !_ToolsRouteObserver._isPlaceholder(route)
        ? page.headerTitle
        : null;
  }

  /// Pushes a page a Tools page opens on its own, such as an editor, as a
  /// page of the workspace beneath that page's path.
  Future<T?>? _pushDetail<T>(BuildContext context, Widget page) {
    final navigator = _navigator.currentState;
    final below = ModalRoute.of(context);
    if (navigator == null ||
        below == null ||
        !identical(Navigator.of(context), navigator)) {
      return null;
    }
    final parent = _pathOf(below);
    return navigator.push<T>(
      _ToolsDetailRoute<T>(
        host: this,
        parent: parent,
        parentHasBack:
            below is _ToolsDetailRoute ||
            _observer.pages.toList().indexOf(below) > 0,
        page: page,
      ),
    );
  }

  Widget _catalog(NavigationDockScope? navigation) {
    final catalog = ToolsCatalogPanel(
      searchFocus: _searchFocus,
      onSelect: openEntry,
    );
    if (navigation == null) return catalog;
    final bar = navigation.held
        ? navigation.navigation
        : const SizedBox.shrink();
    return navigation.floating
        ? Stack(
            fit: StackFit.expand,
            children: [
              catalog,
              PositionedDirectional(start: 0, end: 0, bottom: 0, child: bar),
            ],
          )
        : Column(
            children: [
              Expanded(child: catalog),
              bar,
            ],
          );
  }

  void _recordRecent(String id) {
    setState(() {
      _recentIds
        ..remove(id)
        ..insert(0, id);
      if (_recentIds.length > _recentLimit) {
        _recentIds.removeRange(_recentLimit, _recentIds.length);
      }
    });
  }

  void _openWidget(Widget widget) {
    final page = toolPageOf(widget);
    if (page == null) return;
    _recordRecent('page.${page.name}');
    ref.read(toolsSessionProvider.notifier).open(ToolRoute(page), push: true);
  }

  Widget _landing(List<ToolEntry> entries) {
    final l = context.appLocalizations;
    return PagePresentationScope(
      child: CappedBodyScope(
        maxWidth: _maxBodyWidth,
        child: CommonScaffold(
          title: l.toolsLastUsed,
          body: entries.isEmpty
              ? AppBarClearance(
                  child: NullStatus(
                    label: l.toolsChoose,
                    illustration: NullStatusIllustration.data,
                  ),
                )
              : Builder(
                  builder: (context) => ListView(
                    padding:
                        EdgeInsets.only(
                          left: 16,
                          top: context.sectionsTopPadding,
                          right: 16,
                          bottom: 20 + context.bottomInset,
                        ) +
                        context.bodyInsets,
                    children: [
                      generateSection(
                        items: [
                          for (final entry in entries)
                            ListItem(
                              key: ValueKey('tools-recent-${entry.id}'),
                              leading: GlyphIcon(entry.glyph),
                              title: Text(entry.title),
                              subtitle: entry.path.isEmpty
                                  ? null
                                  : Text(entry.path),
                              onTap: () => unawaited(openEntry(entry)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(toolsSessionProvider);
    final l = context.appLocalizations;
    final environment = watchToolEnvironment(ref);
    final available = buildToolCatalog(l, environment);
    final entriesById = {for (final entry in available) entry.id: entry};
    final recentEntries = _recentIds
        .map((id) => entriesById[id])
        .whereType<ToolEntry>()
        .toList();
    final pages = {
      for (final entry in available)
        if (entry.route?.settingId == null && entry.route != null)
          entry.route!.page: entry,
    };
    final path = session.path
        .where((route) => pages.containsKey(route.page))
        .toList();
    final active = PageActivityScope.isActiveOf(context);
    final navigation = NavigationDockScope.maybeOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final split =
            constraints.maxWidth >= 960 &&
            constraints.maxWidth / textScale >= 800 &&
            constraints.maxHeight >= 480;
        _split = split;
        final catalogWidth = split ? 360.0 : constraints.maxWidth;
        final detailStart = split ? catalogWidth + 1 : 0.0;
        final rtl = Directionality.of(context) == TextDirection.rtl;
        final workspace = PageBackground(
          baseColor: SurfaceLevel.page.colorOf(context.colorScheme),
          child: Stack(
            children: [
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: catalogWidth,
                child: split
                    ? PageViewport(
                        routeHeader: true,
                        bounds: Rect.fromLTWH(
                          rtl ? constraints.maxWidth - catalogWidth : 0,
                          0,
                          catalogWidth,
                          constraints.maxHeight,
                        ),
                        child: ToolsCatalogPanel(
                          searchFocus: _searchFocus,
                          onSelect: openEntry,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (split)
                PositionedDirectional(
                  start: catalogWidth,
                  top: 0,
                  bottom: 0,
                  width: 1,
                  child: TabContentMotion.wrap(
                    context,
                    ColoredBox(
                      key: const ValueKey('tools-pane-divider'),
                      color: context.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              PositionedDirectional(
                start: detailStart,
                end: 0,
                top: 0,
                bottom: 0,
                child: PageViewport(
                  routeHeader: split,
                  inlineHeaders: !split,
                  bounds: Rect.fromLTWH(
                    rtl ? 0 : detailStart,
                    0,
                    constraints.maxWidth - detailStart,
                    constraints.maxHeight,
                  ),
                  child: Navigator(
                    key: _navigator,
                    observers: [_observer],
                    onDidRemovePage: (page) {
                      if (!_navigator.currentState!.widget.pages.contains(
                        page,
                      )) {
                        return;
                      }
                      final state = ref.read(toolsSessionProvider);
                      final index = state.path.indexWhere(
                        (route) => page.key == ValueKey(route.page),
                      );
                      if (index >= 0) {
                        ref.read(toolsSessionProvider.notifier).popTo(index);
                      }
                    },
                    pages: [
                      _ToolsPage(
                        key: const ValueKey('tools.placeholder'),
                        headerTitle: split ? l.toolsLastUsed : l.tools,
                        child: split
                            ? _RetainedLanding(
                                child: path.isEmpty
                                    ? _landing(recentEntries)
                                    : null,
                              )
                            : _catalog(navigation),
                      ),
                      for (final route in path)
                        _ToolsPage(
                          key: ValueKey(route.page),
                          headerTitle: path
                              .take(path.indexOf(route) + 1)
                              .map((item) => pages[item.page]!.title)
                              .join(' › '),
                          child: PagePresentationScope(
                            previousTitle: !split
                                ? null
                                : path.indexOf(route) == 0
                                ? l.toolsLastUsed
                                : path
                                      .take(path.indexOf(route))
                                      .map((item) => pages[item.page]!.title)
                                      .join(' › '),
                            previousHasBack: path.indexOf(route) > 0,
                            transitionTitle: path
                                .take(path.indexOf(route) + 1)
                                .map((item) => pages[item.page]!.title)
                                .join(' › '),
                            onTitleSelect: split
                                ? (index) => unawaited(_popTo(index + 1))
                                : null,
                            child: CappedBodyScope(
                              maxWidth:
                                  split &&
                                      route.page != ToolPage.coreRuntimeConfig
                                  ? _maxBodyWidth
                                  : double.infinity,
                              child: PageNavigationScope(
                                canOpen: (widget) => toolPageOf(widget) != null,
                                open: _openWidget,
                                push: _pushDetail,
                                child: SettingsRevealScope(
                                  targetId: route.settingId,
                                  nonce: session.focusNonce,
                                  active: active && route == path.last,
                                  child: buildToolPage(route.page, context),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        final bar = navigation?.held == true
            ? navigation!.navigation
            : const SizedBox.shrink();
        return ViewScope(
          size: ViewScope.sizeOf(context),
          isMobile: !split,
          windowControls: ViewScope.windowControlsOf(context),
          child: !split || navigation == null
              ? workspace
              : navigation.floating
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    workspace,
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      bottom: 0,
                      child: bar,
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: workspace),
                    bar,
                  ],
                ),
        );
      },
    );
  }
}

/// Keeps the landing under the first page while that page fades in, then
/// empties, so a later replacement never uncovers it.
class _RetainedLanding extends StatefulWidget {
  const _RetainedLanding({required this.child});

  final Widget? child;

  @override
  State<_RetainedLanding> createState() => _RetainedLandingState();
}

class _RetainedLandingState extends State<_RetainedLanding> {
  Widget? _shown;
  Animation<double>? _cover;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_RetainedLanding oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    _cover?.removeStatusListener(_onCover);
    _cover = null;
    if (widget.child case final child?) {
      _shown = child;
      return;
    }
    final cover = ModalRoute.of(context)?.secondaryAnimation;
    if (cover == null || cover.isCompleted) {
      _shown = null;
    } else {
      _cover = cover..addStatusListener(_onCover);
    }
  }

  void _onCover(AnimationStatus status) {
    if (status.isCompleted) setState(_sync);
  }

  @override
  void dispose() {
    _cover?.removeStatusListener(_onCover);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _shown ?? const SizedBox.expand();
}

class _ToolsPage extends Page<void> {
  const _ToolsPage({super.key, required this.headerTitle, required this.child});

  final String headerTitle;

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    final previous = context
        .findAncestorStateOfType<ToolsViewState>()
        ?._observer
        .top
        ?.settings;
    return _ToolsPageRoute(
      settings: this,
      previousTitle: previous is _ToolsPage ? previous.headerTitle : null,
      previousHasBack:
          previous is _ToolsPage &&
          previous.key != const ValueKey('tools.placeholder'),
    );
  }
}

abstract class _ToolsRoute<T> extends PageRoute<T>
    with DragBackRouteMixin<T>, DeferredPushRouteMixin<T> {
  _ToolsRoute({super.settings});

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => SlideOverPageTransition.duration;

  @override
  Duration get reverseTransitionDuration =>
      SlideOverPageTransition.reverseDuration;

  // A desktop pan in the split layout selects text and resizes panes.
  @override
  bool get popGestureEnabled =>
      (!system.isDesktop ||
          navigator?.context
                  .findAncestorStateOfType<ToolsViewState>()
                  ?._split ==
              false) &&
      super.popGestureEnabled;

  bool get coversBelow => true;

  Widget buildContent(BuildContext context, Animation<double> animation);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => dragBackDetector(
    SlideOverPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      dragged: isDragBackActive,
      uncoveredByGesture: navigator!.userGestureInProgress,
      child: child,
    ),
  );

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final content = Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: KeyboardInsetHold(
        child: PageViewport.inherit(
          context,
          child: coversBelow
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    const _ToolsBackdrop(),
                    buildContent(context, animation),
                  ],
                )
              : buildContent(context, animation),
        ),
      ),
    );
    if (!coversBelow || !ViewScope.isMobileOf(context)) return content;
    final padding = MediaQuery.paddingOf(context);
    final navigation = NavigationDockScope.maybeOf(context);
    return BottomInsetScope(
      inset: 0,
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: padding.copyWith(
              bottom: navigation?.bottomPadding ?? padding.bottom,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _ToolsPageRoute extends _ToolsRoute<void> {
  _ToolsPageRoute({
    required super.settings,
    required this.previousTitle,
    required this.previousHasBack,
  });

  final String? previousTitle;
  final bool previousHasBack;

  @override
  bool get coversBelow => !_ToolsRouteObserver._isPlaceholder(this);

  @override
  Widget buildContent(BuildContext context, Animation<double> animation) {
    final child = (settings as _ToolsPage).child;
    if (!coversBelow ||
        child is! PagePresentationScope ||
        child.previousTitle == null) {
      return child;
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final returning = animation.status == AnimationStatus.reverse;
        return PagePresentationScope(
          title: child.title,
          onTitleSelect: child.onTitleSelect,
          transitionTitle: child.transitionTitle,
          previousTitle: returning
              ? child.previousTitle
              : previousTitle ?? child.previousTitle,
          previousHasBack: returning ? child.previousHasBack : previousHasBack,
          child: child.child,
        );
      },
    );
  }
}

/// A page a Tools page pushes itself, presented as one more step of its path.
class _ToolsDetailRoute<T> extends _ToolsRoute<T> {
  _ToolsDetailRoute({
    required this.host,
    required this.parent,
    required this.parentHasBack,
    required this.page,
  });

  final ToolsViewState host;
  final String? parent;
  final bool parentHasBack;
  final Widget page;

  /// The index of this page's own title in its path header.
  int get depth => parent?.split(' › ').length ?? 0;

  @override
  Widget buildContent(BuildContext context, Animation<double> animation) {
    final split = !ViewScope.isMobileOf(context);
    return PagePresentationScope(
      previousTitle: split ? parent : null,
      previousHasBack: parentHasBack,
      onTitleSelect: split ? host._selectPathSegment : null,
      child: CappedBodyScope(
        maxWidth: split ? _maxBodyWidth : double.infinity,
        child: PageNavigationScope(
          canOpen: (_) => false,
          open: (_) {},
          push: host._pushDetail,
          child: page,
        ),
      ),
    );
  }
}

String? _scaffoldTitleIn(BuildContext? context) {
  CommonScaffold? scaffold;
  void visit(Element element) {
    if (element.widget case final CommonScaffold found) {
      scaffold = found;
    } else if (scaffold == null) {
      element.visitChildren(visit);
    }
  }

  context?.visitChildElements(visit);
  return scaffold?.title;
}

/// Covers the pages beneath with the workspace wallpaper, which holds still as
/// the page slides in or back, or changes tabs.
class _ToolsBackdrop extends StatelessWidget {
  const _ToolsBackdrop();

  @override
  Widget build(BuildContext context) =>
      TabContentMotion.wrap(context, const PageBackdrop());
}

class _ToolsRouteObserver extends NavigatorObserver {
  static const placeholder = ValueKey('tools.placeholder');

  final _routes = <Route<dynamic>>[];
  Route<dynamic>? get top => _routes.lastOrNull;
  Iterable<Route<dynamic>> get pages => _routes.where(
    (route) => route.settings is Page && !_isPlaceholder(route),
  );

  static bool _isPlaceholder(Route<dynamic>? route) =>
      route?.settings is Page && (route!.settings as Page).key == placeholder;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) _routes[index] = newRoute;
  }
}
