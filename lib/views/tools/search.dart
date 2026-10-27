import 'package:reclash/ui/icons/icons.dart';
import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/tools_search.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:reclash/providers/tool_commands.dart';
import 'catalog.dart';
import 'core.dart';

ToolEnvironment watchToolEnvironment(WidgetRef ref) {
  final settings = ref.watch(
    appSettingProvider.select((s) => (s.developerMode, s.openLogs)),
  );
  final more = ref.watch(moreToolsSelectorStateProvider);
  return ToolEnvironment(
    desktop: system.isDesktop,
    android: system.isAndroid,
    windows: system.isWindows,
    linux: system.isLinux,
    developer: settings.$1,
    logs: settings.$2,
    macos: system.isMacOS,
    webdav: ref.watch(davSettingProvider.select((dav) => dav != null)),
    sidebarBlur: system.isMacOS || system.isWindows,
    navigationLayout: ref.watch(
      appSettingProvider.select((state) => state.navigationLayout),
    ),
    themeMode: ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    ),
    customInterface: ref.watch(
      patchClashConfigProvider.select(
        (s) => s.interfaceNameMode == InterfaceNameMode.custom,
      ),
    ),
    mipsStack: ref.watch(
      patchClashConfigProvider.select((s) => s.tun.stack == TunStack.mips),
    ),
    dnsKeys: ref
        .watch(patchClashConfigProvider.select((s) => s.dnsOverrideKeys))
        .map((key) => key.name)
        .toSet(),
    authentication: ref.watch(
      networkSettingProvider.select((s) => s.authentication.enable),
    ),
    controller: ref.watch(
      patchClashConfigProvider.select(
        (s) => s.externalController == ExternalControllerStatus.open,
      ),
    ),
    coreReady: ref.watch(coreStatusProvider) == CoreStatus.connected,
    morePages: {
      for (final item in more.navigationItems)
        ?switch (item.label) {
          PageLabel.requests => ToolPage.requests,
          PageLabel.connections => ToolPage.connections,
          PageLabel.dns => ToolPage.dnsQueries,
          PageLabel.logs => ToolPage.logs,
          _ => null,
        },
    },
  );
}

class ToolsCatalogPanel extends ConsumerStatefulWidget {
  const ToolsCatalogPanel({
    super.key,
    required this.onSelect,
    this.autofocus = false,
    this.onDismiss,
    this.searchFocus,
  });

  final Future<void> Function(ToolEntry entry) onSelect;
  final bool autofocus;
  final VoidCallback? onDismiss;
  final FocusNode? searchFocus;

  @override
  ConsumerState<ToolsCatalogPanel> createState() => _ToolsCatalogPanelState();
}

class _ToolsCatalogPanelState extends ConsumerState<ToolsCatalogPanel> {
  final _controller = TextEditingController();
  late final _focus = widget.searchFocus ?? FocusNode();
  final _resultKeys = <String, GlobalKey>{};
  ScrollController? _scroll;
  Object? _catalogKey;
  List<ToolEntry> _entries = const [];
  ToolsSearch _engine = ToolsSearch(const []);
  var _selected = 0;
  var _opening = false;
  List<ToolEntry> _results = const [];

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(toolsSessionProvider).query;
    _focus.addListener(_focusChanged);
    ref.listenManual(toolsSessionProvider.select((s) => s.query), (_, query) {
      if (_controller.text != query) {
        _controller.text = query;
        _selected = 0;
      }
    });
    ref.listenManual(toolsSessionProvider.select((s) => s.searchNonce), (_, _) {
      if (mounted) _focus.requestFocus();
    });
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scroll ??= sheetScrollController(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.removeListener(_focusChanged);
    if (widget.searchFocus == null) _focus.dispose();
    _scroll?.dispose();
    super.dispose();
  }

  void _focusChanged() {
    if (mounted) setState(() {});
  }

  void _search(String value) {
    _selected = 0;
    ref.read(toolsSessionProvider.notifier).search(value);
    if (_scroll?.hasClients == true) _scroll!.jumpTo(0);
  }

  Future<void> _select(ToolEntry entry) async {
    if (_opening) return;
    _opening = true;
    try {
      await widget.onSelect(entry);
    } finally {
      _opening = false;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_controller.text.isNotEmpty) {
        _controller.clear();
        _search('');
      } else if (widget.onDismiss != null) {
        widget.onDismiss!();
      } else {
        _focus.unfocus();
      }
      return KeyEventResult.handled;
    }
    if (!_focus.hasFocus) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter && _results.isNotEmpty) {
      unawaited(_select(_results[_selected.clamp(0, _results.length - 1)]));
      return KeyEventResult.handled;
    }
    final offset = event.logicalKey == LogicalKeyboardKey.arrowDown
        ? 1
        : event.logicalKey == LogicalKeyboardKey.arrowUp
        ? -1
        : 0;
    if (offset == 0 || _results.isEmpty) return KeyEventResult.ignored;
    setState(
      () => _selected = (_selected + offset).clamp(0, _results.length - 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _results.isEmpty) return;
      final target = _resultKeys[_results[_selected].id]?.currentContext;
      if (target != null) Scrollable.ensureVisible(target, alignment: 0.5);
    });
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final env = watchToolEnvironment(ref);
    final key = (
      Localizations.localeOf(context).toLanguageTag(),
      env.desktop,
      env.android,
      env.windows,
      env.linux,
      env.developer,
      env.logs,
      env.authentication,
      env.controller,
      env.coreReady,
      env.macos,
      env.webdav,
      env.sidebarBlur,
      env.customInterface,
      env.mipsStack,
      env.dnsKeys.join(','),
      env.morePages.map((page) => page.name).join(','),
    );
    if (key != _catalogKey) {
      _catalogKey = key;
      _entries = buildToolCatalog(l, env);
      _engine = ToolsSearch(_entries.map((entry) => entry.document));
    }
    final session = ref.watch(toolsSessionProvider);
    final busy = ref.watch(toolCommandsProvider);
    final searching = session.query.trim().isNotEmpty;
    final byId = {for (final entry in _entries) entry.id: entry};
    final matches = _engine.search(session.query);
    _results = searching
        ? [for (final hit in matches) byId[hit.document.id]!]
        : _entries
              .where((entry) => entry.showInCatalog && entry.route != null)
              .toList();
    Widget row(ToolEntry entry, {int? index}) {
      final pinned = session.pinned.contains(entry.id);
      final selected = searching && _focus.hasFocus && index == _selected;
      final isActive =
          selected ||
          !context.isMobileView && session.path.lastOrNull?.id == entry.id;
      return ContextMenuRegion(
        key: searching
            ? _resultKeys.putIfAbsent(entry.id, GlobalKey.new)
            : null,
        menuItems: entry.route == null
            ? null
            : [
                CommonPopupMenuItem(
                  label: pinned ? l.toolsUnpin : l.toolsPin,
                  glyph: AppGlyphs.pin,
                  onPressed: () => ref
                      .read(toolsSessionProvider.notifier)
                      .togglePin(entry.id),
                ),
              ],
        child: Semantics(
          selected: isActive,
          child: ListItem(
            isSelected: isActive,
            holdsSelection: true,
            leading: GlyphIcon(entry.glyph),
            title: Text(entry.title),
            subtitle: searching || entry.route?.settingId != null
                ? Text(
                    [
                      entry.command != null
                          ? l.toolsAction
                          : entry.route?.settingId != null
                          ? l.toolsSetting
                          : l.toolsSection,
                      if (entry.path.isNotEmpty) entry.path,
                      if (entry.unavailableReason != null)
                        entry.unavailableReason!,
                    ].join(' · '),
                  )
                : null,
            trailing: busy.contains(entry.command)
                ? const CommonCircleLoading(size: 20)
                : entry.command != null
                ? Text(l.toolsRun)
                : null,
            onTap:
                busy.contains(entry.command) ||
                    entry.unavailableReason != null && entry.fallback == null
                ? null
                : () => unawaited(_select(entry)),
          ),
        ),
      );
    }

    return CommonScaffold(
      title: l.tools,
      backAction: widget.onDismiss,
      body: Builder(
        builder: (context) => Focus(
          onKeyEvent: _handleKey,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, context.appBarInset, 16, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: SearchField(
                    controller: _controller,
                    focusNode: _focus,
                    fill: context.raisedSurfaceLevel.colorOf(
                      context.colorScheme,
                    ),
                    onChanged: _search,
                  ),
                ),
                const SizedBox(height: 12),
                if (searching)
                  Semantics(
                    liveRegion: true,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l.toolsResults(_results.length),
                        style: AppTextStyle.caption1.of(context),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: EdgeInsetsDirectional.only(
                      end: 12,
                      bottom: 20 + context.bottomInset,
                    ),
                    children: searching
                        ? [
                            if (_results.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(l.toolsEmpty),
                              ),
                            if (_results.isNotEmpty)
                              generateSection(
                                items: [
                                  for (final (index, entry) in _results.indexed)
                                    row(entry, index: index),
                                ],
                              ),
                          ]
                        : [
                            if (session.pinned.any(byId.containsKey))
                              generateSection(
                                title: l.toolsPinned,
                                items: [
                                  for (final id in session.pinned)
                                    if (byId[id] case final entry?) row(entry),
                                ],
                              ),
                            for (final category in ToolCategory.values)
                              if (_results.any(
                                (entry) => entry.category == category,
                              ))
                                generateSection(
                                  title: toolCategoryLabel(category, l),
                                  items: [
                                    for (final entry in _results.where(
                                      (entry) => entry.category == category,
                                    ))
                                      row(entry),
                                  ],
                                ),
                            generateSection(
                              title: l.core,
                              items: [
                                CoreSection(
                                  onOpen: () => unawaited(
                                    _select(byId['page.coreDetails']!),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
