import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' show dirname, join;
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/config.dart';
import 'package:reclash/views/settings/about.dart';
import 'package:reclash/views/settings/access.dart';
import 'package:reclash/views/settings/application_setting.dart';
import 'package:reclash/views/settings/backup_and_restore.dart';
import 'package:reclash/views/settings/hotkey.dart';
import 'package:reclash/views/settings/locale.dart';
import 'package:reclash/widgets/widgets.dart';

import '../appearance/appearance.dart';
import '../config/advanced.dart';
import '../config/desync.dart';
import '../config/dns.dart';
import '../config/network.dart';
import '../config/ntp.dart';
import '../config/smart_pause.dart';
import '../config/smart_routing.dart';
import '../devices/devices.dart';
import '../settings/developer.dart';
import '../settings/url_scheme.dart';
import 'connection_doctor.dart';
import 'core.dart';
import 'findings.dart';
import 'tools_search_index.g.dart';

const toolsDoctorPaneId = 'doctor';

const _toolsListPaneWidth = 360.0;

/// Caps a tool body so settings rows read as a column instead of stretching
/// edge to edge on a wide monitor; the detail pane centres it in the surplus.
const _toolsDetailMaxWidth = 840.0;

const _toolsPaneSwapDuration = Duration(milliseconds: 320);

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

/// One level of the desktop detail column. Picking a tool from the left pane
/// seeds the stack; opening a screen inside a tool pushes another level, so the
/// column drills in place with a back affordance instead of floating a sheet.
class _PaneEntry {
  const _PaneEntry({
    required this.id,
    required this.detail,
    this.title,
    this.focusTarget,
    this.focusNonce = 0,
  });

  final String id;
  final Widget detail;
  final Widget? title;
  final String? focusTarget;
  final int focusNonce;
}

/// One tool's recency-and-frequency record, the input to the "last used" order.
class _RecentStat {
  const _RecentStat({required this.count, required this.lastAt});

  final int count;
  final int lastAt;
}

class _ToolViewState extends ConsumerState<ToolsView> {
  final List<_PaneEntry> _paneStack = [];
  int _focusSeq = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  // The token-independent index is stable between keystrokes; only its inputs
  // (locale, visible tools) move it, so it is rebuilt on that signature alone.
  List<_ToolSearchEntry>? _indexCache;
  Object? _indexSignature;

  // Actions the open tool would have drawn in its own app bar; the shared pane
  // bar renders them since the tool's chrome is suppressed inside the pane.
  final ValueNotifier<Widget?> _detailActions = ValueNotifier(null);

  static const _recentToolLimit = 6;

  // Keep more history than we show so a tool that scrolls off the visible list
  // still carries its visit count when it is opened again.
  static const _recentStatCap = 40;

  // Frecency store: per tool, how many times it was opened and when last. The
  // shown order blends both, so a daily driver outranks a one-off from earlier.
  final Map<String, _RecentStat> _recentStats = {};
  List<String> _recentIds = const [];

  // The matches currently on screen, so Enter can open the top one without the
  // build's local list.
  List<_ToolSearchEntry> _matches = const [];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onSearchFocusChanged);
    _loadRecents();
    // Crossing a layout breakpoint swaps the two-pane shell for the list and
    // changes how rows open; drop the drilled pane and any stale overlay.
    ref.listenManual(viewModeProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        // Clear only this page's nested side sheet; the root navigator (the
        // mobile full-screen route) is the home shell's to reset.
        if (next != ViewMode.mobile) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (_paneStack.isEmpty && _detailActions.value == null) {
          return;
        }
        setState(() {
          _paneStack.clear();
          _detailActions.value = null;
        });
      });
    });
  }

  @override
  void dispose() {
    _searchFocus.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _detailActions.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (!mounted) {
      return;
    }
    // A live query already arms the back layer, so a focus change mid-search
    // need not rebuild — which would interrupt an in-flight result tap.
    if (_query.trim().isNotEmpty) {
      return;
    }
    setState(() {});
  }

  Future<void> _loadRecents() async {
    var stats = _statsFromRaw(await preferences.getRecentToolStats());
    if (stats.isEmpty) {
      // Migrate the recency-only list: newest first, one seed visit each so
      // frequency starts fair rather than pretending old opens never happened.
      final legacy = await preferences.getRecentToolIds();
      final now = DateTime.now().millisecondsSinceEpoch;
      stats = {
        for (final (index, id) in legacy.indexed)
          id: _RecentStat(count: 1, lastAt: now - index),
      };
    }
    if (!mounted || stats.isEmpty) {
      return;
    }
    setState(() {
      _recentStats
        ..clear()
        ..addAll(stats);
      _recentIds = _rankRecents();
    });
  }

  /// Remembers the tool just opened so the empty detail pane can offer a way
  /// straight back to recent work, ranked by how often and how lately it was
  /// used, and persisted so the list survives a restart.
  void _recordRecent(String id) {
    final existing = _recentStats[id];
    _recentStats[id] = _RecentStat(
      count: (existing?.count ?? 0) + 1,
      lastAt: DateTime.now().millisecondsSinceEpoch,
    );
    _pruneRecents();
    setState(() => _recentIds = _rankRecents());
    preferences.saveRecentToolStats(_statsToRaw());
  }

  // A visit is worth more while it is fresh and repeated visits stack, so a
  // frequently opened tool ranks above one touched once long ago.
  double _recentScore(_RecentStat stat) {
    final ageMs = DateTime.now().millisecondsSinceEpoch - stat.lastAt;
    final recency = switch (ageMs) {
      < Duration.millisecondsPerHour => 4.0,
      < Duration.millisecondsPerDay => 3.0,
      < Duration.millisecondsPerDay * 7 => 2.0,
      < Duration.millisecondsPerDay * 30 => 1.0,
      _ => 0.5,
    };
    return stat.count * recency;
  }

  List<String> _rankRecents() {
    final entries = _recentStats.entries.toList()
      ..sort((a, b) {
        final byScore = _recentScore(b.value).compareTo(_recentScore(a.value));
        if (byScore != 0) {
          return byScore;
        }
        return b.value.lastAt.compareTo(a.value.lastAt);
      });
    return [for (final entry in entries.take(_recentToolLimit)) entry.key];
  }

  void _pruneRecents() {
    if (_recentStats.length <= _recentStatCap) {
      return;
    }
    final ranked = _recentStats.entries.toList()
      ..sort((a, b) => _recentScore(b.value).compareTo(_recentScore(a.value)));
    for (final entry in ranked.skip(_recentStatCap)) {
      _recentStats.remove(entry.key);
    }
  }

  Map<String, _RecentStat> _statsFromRaw(List<Map<String, dynamic>> raw) {
    final result = <String, _RecentStat>{};
    for (final entry in raw) {
      final id = entry['id'];
      if (id is! String) {
        continue;
      }
      final count = entry['count'];
      final at = entry['at'];
      result[id] = _RecentStat(
        count: count is int && count > 0 ? count : 1,
        lastAt: at is int ? at : 0,
      );
    }
    return result;
  }

  List<Map<String, dynamic>> _statsToRaw() {
    return [
      for (final entry in _recentStats.entries)
        {'id': entry.key, 'count': entry.value.count, 'at': entry.value.lastAt},
    ];
  }

  void _onSearch(String value) {
    if (value == _query) {
      return;
    }
    setState(() => _query = value);
  }

  /// Ctrl/Cmd+F and "/" pull focus to the field and select any current text so
  /// the next keystroke replaces it, the reflex of a browser find bar.
  void _focusSearch() {
    _searchFocus.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  /// Escape first empties a live query, then releases focus, so one key backs
  /// out of search in the order a reader expects.
  void _dismissSearch() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      _onSearch('');
      return;
    }
    _searchFocus.unfocus();
  }

  void _handleSearchBack() {
    _searchController.clear();
    _onSearch('');
    _searchFocus.unfocus();
  }

  void _focusResults() {
    FocusScope.of(context).focusInDirection(TraversalDirection.down);
  }

  void _focusPrevious() {
    FocusScope.of(context).focusInDirection(TraversalDirection.up);
  }

  /// Enter from the field opens the top result, the reflex of a command
  /// palette. It moves focus into the results first, then activates whatever
  /// landed under focus; with nothing matched it just parks focus in the list.
  void _openFirstResult() {
    _focusResults();
    if (_matches.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final focused = FocusManager.instance.primaryFocus?.context;
      if (focused != null) {
        Actions.maybeInvoke(focused, const ActivateIntent());
      }
    });
  }

  void _selectRootPane(SettingsPaneSelection selection) {
    _recordRecent(selection.id);
    final sameRoot =
        _paneStack.length == 1 && _paneStack.first.id == selection.id;
    if (sameRoot && selection.focusTarget == null) {
      return;
    }
    // Re-selecting the same pane keeps the detail element, which never
    // republishes its relayed actions; only a real pane change resets them.
    if (!sameRoot) {
      _detailActions.value = null;
    }
    setState(() {
      _paneStack
        ..clear()
        ..add(
          _PaneEntry(
            id: selection.id,
            detail: selection.detail,
            title: selection.title,
            focusTarget: selection.focusTarget,
            focusNonce: selection.focusTarget == null ? 0 : ++_focusSeq,
          ),
        );
    });
  }

  void _pushPane(SettingsPaneSelection selection) {
    final sameTop = _paneStack.isNotEmpty && _paneStack.last.id == selection.id;
    if (sameTop && selection.focusTarget == null) {
      return;
    }
    if (!sameTop) {
      _detailActions.value = null;
    }
    setState(() {
      final entry = _PaneEntry(
        id: selection.id,
        detail: selection.detail,
        title: selection.title,
        focusTarget: selection.focusTarget,
        focusNonce: selection.focusTarget == null ? 0 : ++_focusSeq,
      );
      // Re-targeting the current pane replaces it in place so the detail
      // element survives with its relayed actions; a new pane is pushed.
      if (sameTop) {
        _paneStack[_paneStack.length - 1] = entry;
      } else {
        _paneStack.add(entry);
      }
    });
  }

  void _popPane() {
    if (_paneStack.length <= 1) {
      return;
    }
    _detailActions.value = null;
    setState(_paneStack.removeLast);
  }

  void _popToDepth(int depth) {
    if (depth < 1 || depth >= _paneStack.length) {
      return;
    }
    _detailActions.value = null;
    setState(() => _paneStack.removeRange(depth, _paneStack.length));
  }

  Widget _buildMobileNavigationMenu(List<NavigationItem> navigationItems) {
    return SettingSection(
      top: 16,
      title: context.appLocalizations.toolsCategoryDiagnostics,
      items: [
        const _ConnectionDoctorItem(),
        for (final navigationItem in _observabilityItems(navigationItems))
          _navigationItem(navigationItem),
      ],
    );
  }

  List<NavigationItem> _observabilityItems(List<NavigationItem> items) {
    return [
      for (final item in items)
        if (item.label != PageLabel.resources) item,
    ];
  }

  List<NavigationItem> _resourceItems(List<NavigationItem> items) {
    return [
      for (final item in items)
        if (item.label == PageLabel.resources) item,
    ];
  }

  DecorationListItem _navigationItem(NavigationItem navigationItem) {
    return DecorationListItem.open(
      leading: GlyphIcon(navigationItem.glyph),
      title: Text(navigationItem.label.label),
      subtitle: switch (navigationItem.label.description) {
        null => null,
        final description => Text(description),
      },
      widget: navigationItem.builder(context),
      maxWidth: 400,
      forceFull: false,
      paneId: 'nav_${navigationItem.label.name}',
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _dismissSearch,
          const SingleActivator(LogicalKeyboardKey.arrowDown): _focusResults,
        },
        child: SearchField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _onSearch,
          onSubmitted: (_) => _openFirstResult(),
        ),
      ),
    );
  }

  /// The token-independent search index, rebuilt only when its inputs move so
  /// each keystroke filters a cached list rather than reallocating it.
  List<_ToolSearchEntry> _index(
    List<NavigationItem> navigationItems,
    bool enableDeveloperMode,
    bool hasFindings,
    String? locale,
  ) {
    final signature = Object.hash(
      locale,
      enableDeveloperMode,
      hasFindings,
      Object.hashAll(navigationItems.map((item) => item.label.name)),
    );
    if (signature != _indexSignature) {
      _indexSignature = signature;
      _indexCache = _searchIndex(
        navigationItems,
        enableDeveloperMode,
        hasFindings,
      );
    }
    return _indexCache!;
  }

  /// A flat, cross-category index of every searchable row: the tool cards plus
  /// the individual settings one screen deeper, each tagged with its category
  /// so results regroup under the same headings the browsing view uses.
  List<_ToolSearchEntry> _searchIndex(
    List<NavigationItem> navigationItems,
    bool enableDeveloperMode,
    bool hasFindings,
  ) {
    final l = context.appLocalizations;
    return [
      _ToolSearchEntry(
        l.connectionDoctor,
        _ToolCategory.diagnostics,
        const _ConnectionDoctorItem(),
      ),
      if (hasFindings)
        _ToolSearchEntry(l.findings, _ToolCategory.info, const _FindingsItem()),
      for (final navigationItem in _observabilityItems(navigationItems))
        _ToolSearchEntry(
          '${navigationItem.label.label} '
          '${navigationItem.label.description ?? ''}',
          _ToolCategory.diagnostics,
          _navigationItem(navigationItem),
        ),
      for (final navigationItem in _resourceItems(navigationItems))
        _ToolSearchEntry(
          '${navigationItem.label.label} '
          '${navigationItem.label.description ?? ''}',
          _ToolCategory.configuration,
          _navigationItem(navigationItem),
        ),
      _ToolSearchEntry(
        '${l.appearance} ${l.appearanceDesc}',
        _ToolCategory.application,
        const _ThemeItem(),
      ),
      _ToolSearchEntry(
        l.language,
        _ToolCategory.application,
        const _LocaleItem(),
      ),
      _ToolSearchEntry(
        '${l.basicConfig} ${l.basicConfigDesc}',
        _ToolCategory.configuration,
        const _ConfigItem(),
      ),
      _ToolSearchEntry(
        '${l.advancedConfig} ${l.advancedConfigDesc}',
        _ToolCategory.configuration,
        const _AdvancedConfigItem(),
      ),
      _ToolSearchEntry(
        l.urlScheme,
        _ToolCategory.application,
        const _UrlSchemeItem(),
      ),
      if (system.isAndroid)
        _ToolSearchEntry(
          '${l.accessControl} ${l.accessControlDesc}',
          _ToolCategory.configuration,
          const _AccessItem(),
        ),
      _ToolSearchEntry(
        '${l.application} ${l.applicationDesc}',
        _ToolCategory.application,
        const _SettingItem(),
      ),
      _ToolSearchEntry(
        '${l.backupAndRestore} ${l.backupAndRestoreDesc}',
        _ToolCategory.configuration,
        const _BackupItem(),
      ),
      if (system.isAndroid && kEnableDeviceCompanion)
        _ToolSearchEntry(
          '${l.devices} ${l.devicesDescription}',
          _ToolCategory.application,
          const _DevicesItem(),
        ),
      if (system.isDesktop)
        _ToolSearchEntry(
          '${l.hotkeyManagement} ${l.hotkeyManagementDesc}',
          _ToolCategory.application,
          const _HotkeyItem(),
        ),
      if (system.isWindows)
        _ToolSearchEntry(
          '${l.loopback} ${l.loopbackDesc}',
          _ToolCategory.diagnostics,
          const _LoopbackItem(),
        ),
      if (enableDeveloperMode)
        _ToolSearchEntry(
          l.developerMode,
          _ToolCategory.info,
          const _DeveloperItem(),
        ),
      _ToolSearchEntry(
        l.disclaimer,
        _ToolCategory.info,
        const _DisclaimerItem(),
      ),
      _ToolSearchEntry(l.about, _ToolCategory.info, const _InfoItem()),
      ..._deepSettings(l, enableDeveloperMode),
    ];
  }

  /// The tool screens that own deep settings, defined once so both the search
  /// index and the recents registry name them the same way.
  List<_DeepOwner> _deepOwners(AppLocalizations l) {
    return [
      _DeepOwner(
        l.advancedConfig,
        'advanced',
        AppGlyphs.wrench,
        const AdvancedConfigView(),
      ),
      _DeepOwner(l.basicConfig, 'config', AppGlyphs.edit, const ConfigView()),
      _DeepOwner(
        l.application,
        'application',
        AppGlyphs.settings,
        const ApplicationSettingView(),
      ),
      _DeepOwner(
        l.appearance,
        'appearance',
        AppGlyphs.palette,
        const AppearanceView(),
      ),
      _DeepOwner(
        l.network,
        'network',
        AppGlyphs.key,
        BaseScaffold(title: l.network, body: const NetworkListView()),
      ),
      const _DeepOwner('DNS', 'dns', AppGlyphs.dns, DnsView()),
      const _DeepOwner('NTP', 'ntp', AppGlyphs.clock, NtpView()),
      _DeepOwner(
        l.smartRouting,
        'smartRouting',
        AppGlyphs.smartRoute,
        const RoutingStudioView(),
      ),
      _DeepOwner(
        l.smartPause,
        'smartPause',
        AppGlyphs.signalChart,
        const SmartPauseView(),
      ),
      if (system.isAndroid)
        _DeepOwner(l.desync, 'desync', AppGlyphs.bolt, const DesyncView()),
      _DeepOwner(
        l.backupAndRestore,
        'backup',
        AppGlyphs.cloudSync,
        const BackupAndRestore(),
      ),
      _DeepOwner(
        l.developerMode,
        'developer',
        AppGlyphs.cpu,
        const DeveloperView(),
      ),
    ];
  }

  /// Settings inside a tool screen, from the generated `deepSettingSpecs`.
  List<_ToolSearchEntry> _deepSettings(
    AppLocalizations l,
    bool enableDeveloperMode,
  ) {
    final owners = {for (final owner in _deepOwners(l)) owner.paneId: owner};
    const categories = {
      'diagnostics': _ToolCategory.diagnostics,
      'configuration': _ToolCategory.configuration,
      'application': _ToolCategory.application,
      'info': _ToolCategory.info,
    };
    final entries = <_ToolSearchEntry>[];
    for (final spec in deepSettingSpecs(l)) {
      if (!_gateOpen(spec.gate, enableDeveloperMode)) {
        continue;
      }
      final owner = owners[spec.paneId];
      if (owner == null) {
        continue;
      }
      final keywords = spec.keywords.isEmpty
          ? ''
          : ' ${spec.keywords.join(' ')}';
      entries.add(
        _ToolSearchEntry(
          '${spec.title} ${owner.label}$keywords',
          categories[spec.category] ?? _ToolCategory.configuration,
          _DeepSettingResult(
            glyph: owner.glyph,
            title: spec.title,
            owner: owner,
            focus: spec.title,
          ),
        ),
      );
    }
    return entries;
  }

  /// Whether a deep row's baked availability token holds in this environment.
  /// `byeDpi` tracks platform support (mirrors [byeDpiSupportedProvider]), not
  /// the user's feature toggle, so a desktop build never surfaces DPI rows.
  bool _gateOpen(String gate, bool enableDeveloperMode) {
    switch (gate) {
      case 'byeDpi':
      case 'android':
        return system.isAndroid;
      case 'developerMode':
        return enableDeveloperMode;
      case 'desktop':
        return system.isDesktop;
      case 'mobile':
        return !system.isDesktop;
      case 'windows':
        return system.isWindows;
      case 'macos':
        return system.isMacOS;
      case 'linux':
        return system.isLinux;
      case 'always':
      default:
        return true;
    }
  }

  /// Keeps entries every token matches, then orders them by how strongly they
  /// matched so an exact or prefix hit leads a fuzzy or transliterated one. The
  /// sort is stabilised on index order, so ties keep the index's own sequence.
  List<_ToolSearchEntry> _filterIndex(
    List<_ToolSearchEntry> index,
    List<String> tokens,
  ) {
    if (tokens.isEmpty) {
      return const [];
    }
    final scored = <({int order, int score, _ToolSearchEntry entry})>[];
    for (var i = 0; i < index.length; i++) {
      final haystack = _normalizeQuery(index[i].keywords);
      final words = _haystackWords(haystack);
      var total = 0;
      var matchedAll = true;
      for (final token in tokens) {
        final tier = _tokenTier(token, haystack, words);
        if (tier == 0) {
          matchedAll = false;
          break;
        }
        total += tier;
      }
      if (matchedAll) {
        scored.add((order: i, score: total, entry: index[i]));
      }
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.order.compareTo(b.order);
    });
    return [for (final entry in scored) entry.entry];
  }

  /// Groups matches back under their browsing categories so results read with
  /// the same structure as the index, headings and all.
  List<Widget> _resultSections(List<_ToolSearchEntry> matches) {
    final grouped = <_ToolCategory, List<Widget>>{};
    for (final match in matches) {
      (grouped[match.category] ??= <Widget>[]).add(match.item);
    }
    final l = context.appLocalizations;
    final sections = <Widget>[];
    var first = true;
    for (final category in _ToolCategory.values) {
      final items = grouped[category];
      if (items == null || items.isEmpty) {
        continue;
      }
      sections.add(
        SettingSection(
          top: first ? AppSpacing.lg : 0,
          title: category.label(l),
          items: items,
        ),
      );
      first = false;
    }
    return sections;
  }

  List<Widget> _getMobileCategories(
    List<NavigationItem> navigationItems,
    bool enableDeveloperMode,
    bool hasFindings,
  ) {
    return [
      _buildMobileNavigationMenu(navigationItems),
      SettingSection(
        title: context.appLocalizations.toolsCategoryConfiguration,
        items: [
          const _ConfigItem(),
          const _AdvancedConfigItem(),
          for (final navigationItem in _resourceItems(navigationItems))
            _navigationItem(navigationItem),
          const _BackupItem(),
          if (system.isAndroid) const _AccessItem(),
        ],
        enterDelay: const Duration(milliseconds: 50),
      ),
      SettingSection(
        title: context.appLocalizations.toolsCategoryApplication,
        items: [
          const _SettingItem(),
          const _ThemeItem(),
          const _LocaleItem(),
          if (system.isDesktop) const _HotkeyItem(),
          if (system.isAndroid && kEnableDeviceCompanion) const _DevicesItem(),
          const _UrlSchemeItem(),
        ],
        enterDelay: const Duration(milliseconds: 75),
      ),
      SettingSection(
        title: context.appLocalizations.toolsCategoryInfo,
        items: [
          if (hasFindings) const _FindingsItem(),
          if (enableDeveloperMode) const _DeveloperItem(),
          const _DisclaimerItem(),
          const _InfoItem(),
        ],
        enterDelay: const Duration(milliseconds: 100),
      ),
    ];
  }

  List<Widget> _getDesktopCategories(
    List<NavigationItem> navigationItems,
    bool enableDeveloperMode,
    bool hasFindings,
  ) {
    final appLocalizations = context.appLocalizations;
    return [
      SettingSection(
        top: 16,
        title: appLocalizations.toolsCategoryDiagnostics,
        items: [
          const _ConnectionDoctorItem(),
          for (final navigationItem in _observabilityItems(navigationItems))
            _navigationItem(navigationItem),
          if (system.isWindows) const _LoopbackItem(),
        ],
        enterDelay: const Duration(milliseconds: 50),
      ),
      SettingSection(
        title: appLocalizations.toolsCategoryConfiguration,
        items: [
          const _ConfigItem(),
          const _AdvancedConfigItem(),
          for (final navigationItem in _resourceItems(navigationItems))
            _navigationItem(navigationItem),
          const _BackupItem(),
          if (system.isAndroid) const _AccessItem(),
        ],
        enterDelay: const Duration(milliseconds: 75),
      ),
      SettingSection(
        title: appLocalizations.toolsCategoryApplication,
        items: [
          const _SettingItem(),
          const _ThemeItem(),
          const _LocaleItem(),
          if (system.isDesktop) const _HotkeyItem(),
          if (system.isAndroid && kEnableDeviceCompanion) const _DevicesItem(),
          const _UrlSchemeItem(),
        ],
        enterDelay: const Duration(milliseconds: 100),
      ),
      SettingSection(
        title: appLocalizations.toolsCategoryInfo,
        items: [
          if (hasFindings) const _FindingsItem(),
          if (enableDeveloperMode) const _DeveloperItem(),
          const _DisclaimerItem(),
          const _InfoItem(),
        ],
        enterDelay: const Duration(milliseconds: 125),
      ),
      const CoreSection(),
      const SettingBottomInset(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final hasFindings = ref.watch(
      visibleMilestonesProvider.select((state) => state.revealedAt.isNotEmpty),
    );
    final navigationItems = ref
        .watch(moreToolsSelectorStateProvider)
        .navigationItems;
    final viewMode = ref.watch(viewModeProvider);

    final query = _query.trim();
    final searching = query.isNotEmpty;
    final tokens = searching ? _queryTokens(query) : const <String>[];
    final matches = searching
        ? _filterIndex(
            _index(navigationItems, developerBuild, hasFindings, locale),
            tokens,
          )
        : const <_ToolSearchEntry>[];
    _matches = matches;

    if (viewMode == ViewMode.desktop) {
      final categories = _getDesktopCategories(
        navigationItems,
        developerBuild,
        hasFindings,
      );
      final rootId = _paneStack.isEmpty ? null : _paneStack.first.id;
      return _HighlightTokens(
        tokens: tokens,
        child: CallbackShortcuts(
          bindings: {
            controlSingleActivator(LogicalKeyboardKey.keyF): _focusSearch,
            const SingleActivator(LogicalKeyboardKey.slash): _focusSearch,
          },
          child: CommonScaffold(
            appBar: _buildDesktopBar(context),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: _toolsListPaneWidth,
                  child: Column(
                    children: [
                      _buildSearchField(),
                      Expanded(
                        // Arrow keys walk the result/list cards, but only in
                        // this column — the detail pane keeps its own key
                        // handling so sliders and lists inside a tool are not
                        // hijacked.
                        child: CallbackShortcuts(
                          bindings: {
                            const SingleActivator(LogicalKeyboardKey.arrowDown):
                                _focusResults,
                            const SingleActivator(LogicalKeyboardKey.arrowUp):
                                _focusPrevious,
                          },
                          child: SettingsPaneScope(
                            active: true,
                            selectedId: rootId,
                            onSelect: _selectRootPane,
                            child: searching
                                ? _buildSearchResults(matches)
                                : ListView(
                                    key: toolsDesktopIndexKey,
                                    padding: EdgeInsets.zero,
                                    children: categories,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _toolsPaneDivider(context),
                Expanded(
                  child: _buildDetailPane(
                    navigationItems,
                    developerBuild,
                    hasFindings,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = <Widget>[
      _buildSearchField(),
      if (searching) ...[
        _resultsAnnouncement(matches.length),
        if (matches.isEmpty)
          const _SearchEmpty()
        else
          ..._resultSections(matches),
      ] else ...[
        ..._getMobileCategories(navigationItems, developerBuild, hasFindings),
        const CoreSection(),
      ],
      const SettingBottomInset(),
    ];

    final mobile = _HighlightTokens(
      tokens: tokens,
      child: CallbackShortcuts(
        bindings: {
          controlSingleActivator(LogicalKeyboardKey.keyF): _focusSearch,
          const SingleActivator(LogicalKeyboardKey.slash): _focusSearch,
        },
        child: CommonScaffold(
          title: appLocalizations.tools,
          floatBody: true,
          body: SettingsPaneScope(
            active: false,
            selectedId: null,
            onSelect: _selectRootPane,
            child: ListView.builder(
              key: toolsStoreKey,
              padding: EdgeInsets.only(top: context.appBarInset),
              itemCount: items.length,
              itemBuilder: (_, index) => items[index],
            ),
          ),
        ),
      ),
    );
    // The scope stays mounted whether or not search is live; arming it through
    // [enabled] rather than by wrapping on demand keeps the search field (and
    // its keyboard) from being reparented and rebuilt the moment it gains focus.
    return BackLayerScope(
      enabled: searching || _searchFocus.hasFocus,
      onBack: _handleSearchBack,
      child: mobile,
    );
  }

  /// A visually-empty live region so a screen reader announces how many tools a
  /// search turned up (or that none did) as the query changes.
  Widget _resultsAnnouncement(int count) {
    return Semantics(
      liveRegion: true,
      label: context.appLocalizations.toolsSearchResultsCount(count),
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildSearchResults(List<_ToolSearchEntry> matches) {
    return ListView(
      key: const PageStorageKey('tools-desktop-search'),
      padding: EdgeInsets.zero,
      children: [
        _resultsAnnouncement(matches.length),
        if (matches.isEmpty)
          const _SearchEmpty()
        else
          ..._resultSections(matches),
        const SettingBottomInset(),
      ],
    );
  }

  /// The desktop shell's single top bar. Both column headings live here in the
  /// app-bar layer — "Инструменты" over the list and the open tool's title over
  /// the detail — so neither is washed out by a floating scrim, and the pane
  /// divider continues straight through the bar into the body beneath it.
  AppBar _buildDesktopBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      forceMaterialTransparency: true,
      backgroundColor: Colors.transparent,
      toolbarHeight: pageToolbarHeight,
      titleSpacing: 0,
      flexibleSpace: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _toolsListPaneWidth,
              child: Center(
                child: _ToolsBarHeader(
                  title: Text(context.appLocalizations.tools),
                ),
              ),
            ),
            _toolsPaneDivider(context),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: Center(child: _buildDetailHeader())),
                  ValueListenableBuilder<Widget?>(
                    valueListenable: _detailActions,
                    builder: (_, actions, _) =>
                        actions ?? const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The detail column's heading: a single title one level deep, or a clickable
  /// breadcrumb once a tool has been drilled into, so the path back through a
  /// nested screen is always visible and reversible in one tap.
  Widget _buildDetailHeader() {
    if (_paneStack.length <= 1) {
      final entry = _paneStack.isEmpty ? null : _paneStack.last;
      return _ToolsBarHeader(title: entry?.title);
    }
    return _ToolsBreadcrumb(
      entries: _paneStack,
      onBack: _popPane,
      onCrumb: _popToDepth,
    );
  }

  /// Maps a stored recent id back to the row that reopens it. Root tools keep
  /// their own rich rows; a deep-setting owner gets a synthesized row under the
  /// same pane id so both open in the pane through the shared scope.
  Map<String, Widget> _recentToolsById(
    List<NavigationItem> navigationItems,
    bool enableDeveloperMode,
    bool hasFindings,
    AppLocalizations l,
  ) {
    final map = <String, Widget>{
      toolsDoctorPaneId: const _ConnectionDoctorItem(),
      if (hasFindings) 'findings': const _FindingsItem(),
      for (final navigationItem in navigationItems)
        'nav_${navigationItem.label.name}': _navigationItem(navigationItem),
      'appearance': const _ThemeItem(),
      'locale': const _LocaleItem(),
      'config': const _ConfigItem(),
      'advanced': const _AdvancedConfigItem(),
      'application': const _SettingItem(),
      'backup': const _BackupItem(),
      'urlScheme': const _UrlSchemeItem(),
      'about': const _InfoItem(),
      if (system.isAndroid) 'access': const _AccessItem(),
      if (system.isDesktop) 'hotkey': const _HotkeyItem(),
      if (enableDeveloperMode) 'developer': const _DeveloperItem(),
    };
    for (final owner in _deepOwners(l)) {
      map.putIfAbsent(
        owner.paneId,
        () => DecorationListItem.open(
          leading: GlyphIcon(owner.glyph),
          title: Text(owner.label),
          widget: owner.detail,
          paneId: owner.paneId,
          blur: false,
        ),
      );
    }
    return map;
  }

  /// The empty detail pane: the "pick a tool" hero, and beneath it the tools
  /// last opened so getting back to recent work is one tap, not a re-hunt.
  Widget _buildRecents(
    List<NavigationItem> navigationItems,
    bool enableDeveloperMode,
    bool hasFindings,
  ) {
    final l = context.appLocalizations;
    final byId = _recentToolsById(
      navigationItems,
      enableDeveloperMode,
      hasFindings,
      l,
    );
    final items = [
      for (final id in _recentIds)
        if (byId[id] != null) byId[id]!,
    ];
    if (items.isEmpty) {
      return const _ToolsPanePlaceholder(key: ValueKey('tools-placeholder'));
    }
    return SettingsPaneScope(
      active: true,
      selectedId: null,
      onSelect: _selectRootPane,
      child: ListView(
        key: const ValueKey('tools-recents'),
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 320, child: _ToolsPanePlaceholder()),
          SettingSection(title: l.lastUsed, items: items),
          const SettingBottomInset(),
        ],
      ),
    );
  }

  Widget _buildDetailPane(
    List<NavigationItem> navigationItems,
    bool enableDeveloperMode,
    bool hasFindings,
  ) {
    final entry = _paneStack.isEmpty ? null : _paneStack.last;
    final Widget content;
    if (entry == null) {
      content = _buildRecents(
        navigationItems,
        enableDeveloperMode,
        hasFindings,
      );
    } else {
      content = KeyedSubtree(
        key: ValueKey('${_paneStack.length}:${entry.id}'),
        // Cap the tool body's width so rows and controls do not stretch across
        // a wide window; the list column is already fixed, this keeps the pair
        // balanced. Top-centered so a short tool sits under the bar, not
        // floating mid-pane.
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _toolsDetailMaxWidth),
            child: SettingsPaneScope(
              active: true,
              pushes: true,
              selectedId: null,
              onSelect: _pushPane,
              child: SheetProvider(
                type: SheetType.page,
                nestedNavigatorPop: ([_]) => _popPane(),
                child: ToolsPaneChrome(
                  suppressChrome: true,
                  actionsSink: _detailActions,
                  // Zero appBarInset for tools that read it in their own build
                  // (above their CommonScaffold); the shared bar already owns
                  // the top clearance, so the tool body sits flush beneath it.
                  child: FloatingBarScope(
                    inset: 0,
                    child: SettingFocusScope(
                      target: entry.focusTarget,
                      nonce: entry.focusNonce,
                      child: entry.detail,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return PageTransitionSwitcher(
      duration: context.motionDuration(_toolsPaneSwapDuration),
      transitionBuilder: (child, animation, secondaryAnimation) =>
          FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            fillColor: Colors.transparent,
            child: child,
          ),
      child: content,
    );
  }
}

/// Full-height hairline between the list and detail columns, drawn identically
/// in the bar and the body so the two segments read as one continuous line.
Widget _toolsPaneDivider(BuildContext context) {
  return VerticalDivider(
    width: 1,
    thickness: 1,
    color: context.colorScheme.outlineVariant,
  );
}

class _ToolsBarHeader extends StatelessWidget {
  const _ToolsBarHeader({this.title});

  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Row(
      children: [
        const SizedBox(width: AppSpacing.xxl),
        if (title == null)
          const Spacer()
        else
          Expanded(
            child: DefaultTextStyle.merge(
              style:
                  context.textTheme.titleLarge ??
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: title,
            ),
          ),
        const SizedBox(width: AppSpacing.lg),
      ],
    );
  }
}

/// The detail bar's path once a tool has been drilled into: a back button, then
/// one crumb per level on a single line. When the path outgrows the pane the
/// trail scrolls horizontally and stays pinned to the current level, so a
/// narrow window never wraps or squeezes the crumbs unevenly. Every crumb but
/// the last pops straight back to its level; the last is the current heading.
class _ToolsBreadcrumb extends StatefulWidget {
  const _ToolsBreadcrumb({
    required this.entries,
    required this.onBack,
    required this.onCrumb,
  });

  final List<_PaneEntry> entries;
  final VoidCallback onBack;
  final ValueChanged<int> onCrumb;

  @override
  State<_ToolsBreadcrumb> createState() => _ToolsBreadcrumbState();
}

class _ToolsBreadcrumbState extends State<_ToolsBreadcrumb> {
  final ScrollController _controller = ScrollController();

  @override
  void didUpdateWidget(_ToolsBreadcrumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries.length != oldWidget.entries.length) {
      _pinToCurrent();
    }
  }

  /// Keep the deepest crumb — the screen actually open — in view; ancestors
  /// scroll off to the left where a tap on the back arrow or a revealed crumb
  /// still reaches them.
  void _pinToCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) {
        return;
      }
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final crumbs = <Widget>[];
    for (var i = 0; i < widget.entries.length; i++) {
      final title = widget.entries[i].title;
      if (title == null) {
        continue;
      }
      final isLast = i == widget.entries.length - 1;
      if (isLast) {
        crumbs.add(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: DefaultTextStyle.merge(
              style: textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: title,
            ),
          ),
        );
        break;
      }
      final depth = i + 1;
      crumbs.add(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              textStyle: textTheme.titleMedium,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => widget.onCrumb(depth),
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: title,
            ),
          ),
        ),
      );
      crumbs.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: GlyphIcon(
            AppGlyphs.chevronForward,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Row(
      children: [
        IconButton(
          tooltip: context.appLocalizations.back,
          onPressed: widget.onBack,
          icon: const GlyphIcon(AppGlyphs.arrowBack),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: Row(children: crumbs),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}

class _ToolsPanePlaceholder extends StatelessWidget {
  const _ToolsPanePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return NullStatus(
      label: l.toolsSelectPanePlaceholder,
      description: l.toolsSearchHint,
      illustration: NullStatusIllustration.data,
    );
  }
}

class _ConnectionDoctorItem extends ConsumerWidget {
  const _ConnectionDoctorItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final snapshot = ref.watch(connectionDoctorProvider);
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.healthMonitor),
      title: Text(appLocalizations.connectionDoctor),
      subtitle: Text(connectionDoctorTitle(appLocalizations, snapshot)),
      widget: const ConnectionDoctorView(),
      paneId: toolsDoctorPaneId,
    );
  }
}

class _FindingsItem extends StatelessWidget {
  const _FindingsItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.sparkle),
      title: Text(context.appLocalizations.findings),
      widget: const FindingsView(),
      paneId: 'findings',
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final currentLocale = getLocaleForString(
      ref.watch(appSettingProvider.select((state) => state.locale)),
    );
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.language),
      title: Text(appLocalizations.language),
      subtitle: Text(
        currentLocale?.nativeLabel ?? appLocalizations.defaultText,
      ),
      widget: const LocaleView(),
      paneId: 'locale',
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.palette),
      title: Text(context.appLocalizations.appearance),
      subtitle: Text(context.appLocalizations.appearanceDesc),
      widget: const AppearanceView(),
      paneId: 'appearance',
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.cloudSync),
      title: Text(context.appLocalizations.backupAndRestore),
      subtitle: Text(context.appLocalizations.backupAndRestoreDesc),
      widget: const BackupAndRestore(),
      paneId: 'backup',
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.keyboard),
      title: Text(context.appLocalizations.hotkeyManagement),
      subtitle: Text(context.appLocalizations.hotkeyManagementDesc),
      widget: const HotKeyView(),
      paneId: 'hotkey',
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.lock),
      title: Text(context.appLocalizations.loopback),
      subtitle: Text(context.appLocalizations.loopbackDesc),
      onPressed: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          '',
        );
      },
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.list),
      title: Text(context.appLocalizations.accessControl),
      subtitle: Text(context.appLocalizations.accessControlDesc),
      widget: const AccessView(),
      paneId: 'access',
    );
  }
}

class _DevicesItem extends StatelessWidget {
  const _DevicesItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.devices_other),
      title: Text(context.appLocalizations.devices),
      subtitle: Text(context.appLocalizations.devicesDescription),
      widget: const DevicesView(),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.edit),
      title: Text(context.appLocalizations.basicConfig),
      subtitle: Text(context.appLocalizations.basicConfigDesc),
      widget: const ConfigView(),
      paneId: 'config',
    );
  }
}

class _AdvancedConfigItem extends StatelessWidget {
  const _AdvancedConfigItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.wrench),
      title: Text(context.appLocalizations.advancedConfig),
      subtitle: Text(context.appLocalizations.advancedConfigDesc),
      widget: const AdvancedConfigView(),
      paneId: 'advanced',
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.settings),
      title: Text(context.appLocalizations.application),
      subtitle: Text(context.appLocalizations.applicationDesc),
      widget: const ApplicationSettingView(),
      paneId: 'application',
    );
  }
}

class _DisclaimerItem extends ConsumerWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context, ref) {
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.gavel),
      title: Text(context.appLocalizations.disclaimer),
      onPressed: () async {
        final isDisclaimerAccepted = await dialogs.showDisclaimer();
        if (!isDisclaimerAccepted) {
          await ref.read(systemActionProvider.notifier).handleExit();
        }
      },
    );
  }
}

class _UrlSchemeItem extends StatelessWidget {
  const _UrlSchemeItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.link),
      title: Text(context.appLocalizations.urlScheme),
      widget: const UrlSchemeView(),
      paneId: 'urlScheme',
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.info),
      title: Text(context.appLocalizations.about),
      widget: const AboutView(),
      paneId: 'about',
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.cpu),
      title: Text(context.appLocalizations.developerMode),
      widget: const DeveloperView(),
      paneId: 'developer',
    );
  }
}

class _ToolSearchEntry {
  const _ToolSearchEntry(this.keywords, this.category, this.item);

  final String keywords;
  final _ToolCategory category;
  final Widget item;
}

/// The browsing categories, in the order the desktop index lists them, so
/// grouped search results read top-to-bottom the same way.
enum _ToolCategory {
  diagnostics,
  configuration,
  application,
  info;

  String label(AppLocalizations l) {
    return switch (this) {
      _ToolCategory.diagnostics => l.toolsCategoryDiagnostics,
      _ToolCategory.configuration => l.toolsCategoryConfiguration,
      _ToolCategory.application => l.toolsCategoryApplication,
      _ToolCategory.info => l.toolsCategoryInfo,
    };
  }
}

/// A tool screen that owns one or more deep settings: the label shown as the
/// result's breadcrumb, the pane id it opens under, the glyph it carries, and
/// the screen itself.
class _DeepOwner {
  const _DeepOwner(this.label, this.paneId, this.glyph, this.detail);

  final String label;
  final String paneId;
  final Glyph glyph;
  final Widget detail;
}

/// A single setting surfaced as a search result: the row shows the setting's
/// own name with the match highlighted plus a breadcrumb, but opening it drives
/// the owning screen, so the pane header reads the screen name not the setting.
class _DeepSettingResult extends StatelessWidget {
  const _DeepSettingResult({
    required this.glyph,
    required this.title,
    required this.owner,
    required this.focus,
  });

  final Glyph glyph;
  final String title;
  final _DeepOwner owner;
  final String focus;

  @override
  Widget build(BuildContext context) {
    final paneScope = SettingsPaneScope.of(context);
    void open() {
      if (paneScope != null && paneScope.active) {
        paneScope.onSelect(
          SettingsPaneSelection(
            id: owner.paneId,
            detail: owner.detail,
            title: Text(owner.label),
            focusTarget: focus,
          ),
        );
        return;
      }
      showExtend(
        context,
        builder: (_) => SettingFocusScope(target: focus, child: owner.detail),
      );
    }

    return DecorationListItem(
      leading: GlyphIcon(glyph),
      title: _HighlightText(title, _HighlightTokens.of(context)),
      subtitle: Text(owner.label),
      onPressed: open,
    );
  }
}

/// Renders [text] with every run that matches a search token drawn bold in the
/// primary colour, so a result shows at a glance why it matched.
class _HighlightText extends StatelessWidget {
  const _HighlightText(this.text, this.tokens);

  final String text;
  final List<String> tokens;

  @override
  Widget build(BuildContext context) {
    final spans = _highlightSpans(context);
    if (spans == null) {
      return Text(text);
    }
    return Text.rich(TextSpan(children: spans));
  }

  /// The matched ranges as spans, or null when nothing matches so the caller
  /// can fall back to a plain [Text] and skip the rich-text machinery.
  List<InlineSpan>? _highlightSpans(BuildContext context) {
    final haystack = _normalizeQuery(text);
    final hits = <bool>[for (var i = 0; i < text.length; i++) false];
    var matched = false;
    for (final token in tokens) {
      for (final candidate in _tokenCandidates(token)) {
        var from = 0;
        while (true) {
          final at = haystack.indexOf(candidate, from);
          if (at < 0) {
            break;
          }
          for (var i = at; i < at + candidate.length; i++) {
            hits[i] = true;
          }
          matched = true;
          from = at + candidate.length;
        }
      }
    }
    if (!matched) {
      return null;
    }
    final highlight = TextStyle(
      fontWeight: FontWeight.w700,
      color: context.colorScheme.primary,
    );
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();
    var runHit = hits.first;
    void flush() {
      if (buffer.isEmpty) {
        return;
      }
      spans.add(
        TextSpan(text: buffer.toString(), style: runHit ? highlight : null),
      );
      buffer.clear();
    }

    for (var i = 0; i < text.length; i++) {
      if (hits[i] != runHit) {
        flush();
        runHit = hits[i];
      }
      buffer.write(text[i]);
    }
    flush();
    return spans;
  }
}

/// Lowercases and folds ё→е so a query matches regardless of case or that one
/// interchangeable Cyrillic letter, the only fold Russian search needs here.
String _normalizeQuery(String value) {
  return value.toLowerCase().replaceAll('ё', 'е');
}

List<String> _queryTokens(String query) {
  return _normalizeQuery(
    query,
  ).split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
}

/// Splits a normalized haystack into whole words (length ≥ 3), the unit that
/// fuzzy and transliterated candidates are compared against — a bounded edit
/// against a whole label would let almost anything through, so matching that
/// tolerates a typo does so per word.
final _wordBoundary = RegExp(r'[^0-9a-zа-я]+');

List<String> _haystackWords(String haystack) {
  return haystack
      .split(_wordBoundary)
      .where((word) => word.length >= 3)
      .toList();
}

/// How strongly [token] matches, higher being more relevant: an exact whole
/// word (4) beats a word prefix (3), a bare substring (2), and a fuzzy or
/// transliterated hit (1); 0 means no match. Candidates cover the raw token,
/// both keyboard-layout remaps, and curated synonyms, so a query typed on the
/// wrong layout or in the other language still lands — and ranks by the same
/// scale, so filtering and ordering never disagree on what counts as a hit.
int _tokenTier(String token, String haystack, List<String> words) {
  var best = 0;
  for (final candidate in _tokenCandidates(token)) {
    if (words.contains(candidate)) {
      return 4;
    }
    if (words.any((word) => word.startsWith(candidate))) {
      best = best < 3 ? 3 : best;
      continue;
    }
    if (haystack.contains(candidate)) {
      best = best < 2 ? 2 : best;
      continue;
    }
    if (candidate.length >= 4) {
      final stem = _stemPlural(candidate);
      if (words.any(
        (word) =>
            _within1(candidate, word) ||
            (word.length >= 4 && _stemPlural(word) == stem),
      )) {
        best = best < 1 ? 1 : best;
      }
    }
  }
  return best;
}

/// A crude singular of an English word so a query in one number still matches a
/// label in the other ('canary' ↔ 'canaries'). Only the endings these labels
/// use, not a full stemmer.
String _stemPlural(String word) {
  if (word.length > 4 && word.endsWith('ies')) {
    return '${word.substring(0, word.length - 3)}y';
  }
  if (word.length > 3 && word.endsWith('s') && !word.endsWith('ss')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}

/// The spellings a single token is allowed to match under: itself, its two
/// keyboard-layout remaps (a Russian user left on QWERTY, or the reverse), and
/// any curated synonyms. Duplicates and the untranslated identity are dropped.
Iterable<String> _tokenCandidates(String token) {
  final seen = <String>{token};
  final cyrToLat = _translate(token, _cyrToLat);
  if (cyrToLat != token) {
    seen.add(cyrToLat);
  }
  final latToCyr = _translate(token, _latToCyr);
  if (latToCyr != token) {
    seen.add(latToCyr);
  }
  for (final base in seen.toList()) {
    final synonyms = _synonyms[base];
    if (synonyms != null) {
      seen.addAll(synonyms);
    }
  }
  return seen;
}

/// True when [a] and [b] are equal or differ by a single insertion, deletion,
/// or substitution — the one-typo tolerance, kept cheap by bailing as soon as a
/// second difference shows up rather than filling a full edit-distance matrix.
bool _within1(String a, String b) {
  final lengthGap = a.length - b.length;
  if (lengthGap < -1 || lengthGap > 1) {
    return false;
  }
  if (a.length == b.length) {
    var diffs = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i] && ++diffs > 1) {
        return false;
      }
    }
    return true;
  }
  final longer = a.length > b.length ? a : b;
  final shorter = a.length > b.length ? b : a;
  var i = 0;
  var j = 0;
  var skipped = false;
  while (i < longer.length && j < shorter.length) {
    if (longer[i] == shorter[j]) {
      i++;
      j++;
      continue;
    }
    if (skipped) {
      return false;
    }
    skipped = true;
    i++;
  }
  return true;
}

/// Maps a token character by character through [table], leaving anything absent
/// from the table untouched.
String _translate(String value, Map<String, String> table) {
  final buffer = StringBuffer();
  for (final char in value.split('')) {
    buffer.write(table[char] ?? char);
  }
  return buffer.toString();
}

/// The physical-key pairing between the Russian ЙЦУКЕН layout and US QWERTY, so
/// text typed with the wrong layout active can be remapped to what was meant.
const _layoutPairs = <String, String>{
  'й': 'q',
  'ц': 'w',
  'у': 'e',
  'к': 'r',
  'е': 't',
  'н': 'y',
  'г': 'u',
  'ш': 'i',
  'щ': 'o',
  'з': 'p',
  'х': '[',
  'ъ': ']',
  'ф': 'a',
  'ы': 's',
  'в': 'd',
  'а': 'f',
  'п': 'g',
  'р': 'h',
  'о': 'j',
  'л': 'k',
  'д': 'l',
  'ж': ';',
  'э': "'",
  'я': 'z',
  'ч': 'x',
  'с': 'c',
  'м': 'v',
  'и': 'b',
  'т': 'n',
  'ь': 'm',
  'б': ',',
  'ю': '.',
};

const _cyrToLat = _layoutPairs;
final _latToCyr = {
  for (final entry in _layoutPairs.entries) entry.value: entry.key,
};

/// Curated bilingual synonyms, keyed by a normalized token. Bridges the words a
/// person reaches for and the words a label actually uses — a search for the
/// colour of the app should find its appearance screen, in either language.
const _synonyms = <String, List<String>>{
  'цвет': ['оформлен', 'appearance', 'тема', 'вид', 'theme', 'color'],
  'тема': ['оформлен', 'appearance', 'theme', 'цвет'],
  'оформление': ['appearance', 'тема', 'цвет', 'theme'],
  'appearance': ['оформлен', 'тема', 'цвет', 'theme'],
  'theme': ['оформлен', 'appearance', 'тема', 'цвет'],
  'вид': ['оформлен', 'appearance', 'тема'],
  'язык': ['language', 'локал', 'locale'],
  'language': ['язык', 'локал'],
  'сеть': ['network', 'соединен'],
  'network': ['сеть', 'соединен'],
  'порт': ['port', 'proxy', 'прокси'],
  'port': ['порт'],
  'прокси': ['proxy', 'порт', 'port'],
  'proxy': ['прокси', 'порт'],
  'обновление': ['update', 'версия', 'version'],
  'update': ['обновлен', 'версия', 'version'],
  'версия': ['version', 'обновлен', 'about', 'приложении'],
  'version': ['версия', 'обновлен', 'about'],
};

/// Carries the active search tokens down to deep-setting results so each row
/// can highlight its own match without the search index depending on the query
/// — that keeps the index cacheable across keystrokes.
class _HighlightTokens extends InheritedWidget {
  const _HighlightTokens({required this.tokens, required super.child});

  final List<String> tokens;

  static List<String> of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_HighlightTokens>();
    return scope?.tokens ?? const [];
  }

  @override
  bool updateShouldNotify(_HighlightTokens oldWidget) {
    return !listEquals(tokens, oldWidget.tokens);
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: NullStatus(
        label: context.appLocalizations.noSearchResults,
        illustration: NullStatusIllustration.search,
      ),
    );
  }
}
