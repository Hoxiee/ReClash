import 'dart:async';

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
import 'package:prism_ui/split_workspace.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxBodyWidth = 840.0;

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => ToolsViewState();
}

class ToolsViewState extends ConsumerState<ToolsView> {
  final _searchFocus = FocusNode();
  late final _controller = SplitWorkspaceController(
    detailTitle: _scaffoldTitleIn,
  );
  late final _catalogPanel = ToolsCatalogPanel(
    searchFocus: _searchFocus,
    onSelect: openEntry,
  );
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
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<bool> handleBack() async {
    if (_controller.topRoute?.settings is Page && _searchFocus.hasFocus) {
      if (ref.read(toolsSessionProvider).query.isNotEmpty) {
        ref.read(toolsSessionProvider.notifier).search('');
      } else {
        _searchFocus.unfocus();
      }
      return true;
    }
    if (await _controller.maybePop()) return true;
    final session = ref.read(toolsSessionProvider);
    if (session.query.isNotEmpty) {
      ref.read(toolsSessionProvider.notifier).search('');
      return true;
    }
    return false;
  }

  Future<void> openEntry(ToolEntry entry, {bool push = false}) async {
    if (_navigating) return;
    _navigating = true;
    try {
      if (!await _controller.dismissEditors()) return;
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
        for (final previous in _controller.pageRoutes.toList().reversed) {
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
    if (_controller.isSplit || ref.read(toolsSessionProvider).path.isEmpty) {
      ref.read(toolsSessionProvider.notifier).focusSearch();
      return;
    }
    final context = _controller.topRoute?.navigator?.context ?? this.context;
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
    return SplitWorkspace(
      controller: _controller,
      catalog: _catalogPanel,
      landing: _landing(recentEntries),
      catalogTitle: l.tools,
      landingTitle: l.toolsLastUsed,
      onPopTo: (depth) async =>
          ref.read(toolsSessionProvider.notifier).popTo(depth),
      onRemoved: (id) {
        final state = ref.read(toolsSessionProvider);
        final index = state.path.indexWhere((route) => route.page == id);
        if (index >= 0) {
          ref.read(toolsSessionProvider.notifier).popTo(index);
        }
      },
      pages: [
        for (final route in path)
          SplitWorkspacePage(
            id: route.page,
            title: pages[route.page]!.title,
            child: PageNavigationScope(
              canOpen: (widget) => toolPageOf(widget) != null,
              open: _openWidget,
              push: _controller.pushDetail,
              child: SettingsRevealScope(
                targetId: route.settingId,
                nonce: session.focusNonce,
                active: active && route == path.last,
                child: _pageBody(route.page, context),
              ),
            ),
          ),
      ],
    );
  }

  /// The runtime config editor needs the whole detail pane; every other tool
  /// reads inside the capped column.
  Widget _pageBody(ToolPage page, BuildContext context) {
    final body = buildToolPage(page, context);
    if (page != ToolPage.coreRuntimeConfig) return body;
    return CappedBodyScope(maxWidth: double.infinity, child: body);
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
