import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/tool_commands.dart';
import 'package:reclash/views/tools/catalog.dart';
import 'package:reclash/views/tools/navigation.dart';
import 'package:reclash/views/tools/search.dart';
import 'package:reclash/ui/deferred_push.dart';
import 'package:reclash/ui/drag_back.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/page_transition.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<bool> _dismissEditors() async {
    final navigator = _navigator.currentState;
    while (navigator != null &&
        _observer.top?.settings is! Page &&
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
            confirm: () async =>
                mounted &&
                await dialogs.showMessage(
                      context: context,
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

  Widget _breadcrumbs(List<ToolRoute> path, Map<ToolPage, ToolEntry> pages) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, route) in path.indexed) ...[
              if (index > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('›'),
                ),
              if (index == path.length - 1)
                Text(pages[route.page]!.title)
              else
                TextButton(
                  onPressed: () => unawaited(_popTo(index + 1)),
                  child: Text(pages[route.page]!.title),
                ),
            ],
          ],
        ),
      );

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
      maxBodyWidth: 840,
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
                  padding: EdgeInsets.only(
                    left: 16,
                    top: context.contentTopPadding,
                    right: 16,
                    bottom: 20 + BottomInsetScope.of(context),
                  ),
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
        return ViewScope(
          size: ViewScope.sizeOf(context),
          isMobile: !split,
          windowControls: ViewScope.windowControlsOf(context),
          child: PageBackground(
            baseColor: SurfaceLevel.page.colorOf(context.colorScheme),
            child: Stack(
              children: [
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: catalogWidth,
                  child: Offstage(
                    offstage: !split && path.isNotEmpty,
                    child: ExcludeFocus(
                      excluding: !split && path.isNotEmpty,
                      child: TickerMode(
                        enabled: active && (split || path.isEmpty),
                        child: PageActivityScope(
                          isActive: active && (split || path.isEmpty),
                          child: PageViewport(
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (split)
                  PositionedDirectional(
                    start: catalogWidth,
                    top: 0,
                    bottom: 0,
                    width: 1,
                    child: ColoredBox(
                      key: const ValueKey('tools-pane-divider'),
                      color: context.colorScheme.outlineVariant,
                    ),
                  ),
                PositionedDirectional(
                  start: detailStart,
                  end: 0,
                  top: 0,
                  bottom: 0,
                  child: Offstage(
                    offstage: !split && path.isEmpty,
                    child: PageViewport(
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
                            ref
                                .read(toolsSessionProvider.notifier)
                                .popTo(index);
                          }
                        },
                        pages: [
                          _ToolsPage(
                            key: const ValueKey('tools.placeholder'),
                            child: split && path.isEmpty
                                ? _landing(recentEntries)
                                : const SizedBox.expand(),
                          ),
                          for (final route in path)
                            _ToolsPage(
                              key: ValueKey(route.page),
                              child: PagePresentationScope(
                                title: split
                                    ? _breadcrumbs(
                                        path
                                            .take(path.indexOf(route) + 1)
                                            .toList(),
                                        pages,
                                      )
                                    : null,
                                maxBodyWidth:
                                    split &&
                                        route.page != ToolPage.coreRuntimeConfig
                                    ? 840
                                    : double.infinity,
                                child: PageNavigationScope(
                                  canOpen: (widget) =>
                                      toolPageOf(widget) != null,
                                  open: _openWidget,
                                  child: SettingsRevealScope(
                                    targetId: route.settingId,
                                    nonce: session.focusNonce,
                                    active: active && route == path.last,
                                    child: buildToolPage(route.page, context),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolsPage extends Page<void> {
  const _ToolsPage({super.key, required this.child});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) =>
      _ToolsPageRoute(settings: this);
}

class _ToolsPageRoute extends PageRoute<void>
    with
        DragBackRouteMixin<void>,
        DeferredPushRouteMixin<void>,
        SharedXPageRouteMixin<void> {
  _ToolsPageRoute({required super.settings});

  static const _enterCurve = Interval(0.5, 1, curve: Cubic(0.16, 1, 0.3, 1));
  static const _leaveCurve = Interval(0, 0.5, curve: Cubic(0.4, 0, 1, 1));

  @override
  Duration get transitionDuration => const Duration(milliseconds: 260);

  @override
  bool sharesMotionWith(Route<dynamic>? route) => route is _ToolsPageRoute;

  @override
  Color backdropOf(Color surface, {required bool dragging}) =>
      Colors.transparent;

  @override
  Color transitionColorOf(Color surface) => Colors.transparent;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (isDragBackActive) {
      return super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    return dragBackDetector(
      AnimatedBuilder(
        animation: Listenable.merge([animation, secondaryAnimation]),
        builder: (context, child) {
          final entering = _enterCurve.transform(animation.value);
          final covered = secondaryAnimation.status == AnimationStatus.reverse
              ? _enterCurve.transform(1 - secondaryAnimation.value)
              : 1 - _leaveCurve.transform(secondaryAnimation.value);
          return Opacity(opacity: entering * covered, child: child);
        },
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Semantics(
    scopesRoute: true,
    explicitChildNodes: true,
    child: KeyboardInsetHold(
      child: PageViewport.inherit(
        context,
        child: (settings as _ToolsPage).child,
      ),
    ),
  );
}

class _ToolsRouteObserver extends NavigatorObserver {
  final _routes = <Route<dynamic>>[];
  Route<dynamic>? get top => _routes.lastOrNull;
  Iterable<Route<dynamic>> get pages => _routes.where(
    (route) =>
        route.settings is Page &&
        (route.settings as Page).key != const ValueKey('tools.placeholder'),
  );

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) _routes[index] = newRoute;
  }
}
