import 'dart:async';
import 'dart:convert';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/pages/editor.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'routing.dart';
import 'routing_condition.dart';
import 'routing_import.dart' show exportRoutingDocument;
import 'routing_match.dart';
import 'routing_route.dart';
import 'routing_studio.dart';

const _textDelay = Duration(milliseconds: 500);
const _modes = ['', 'rule', 'global', 'direct'];
const _defaultScenario = 'builtin/every-group';

/// A new scenario lets every select group pick its own best server; the
/// first edit is the user's own.
const _blankScenario =
    'rcx: 1\n'
    'title: My scenario\n'
    'groups:\n'
    "  '*': {}\n";

Future<void> openScenarioEditor(
  BuildContext context, {
  String? name,
  String? text,
  String from = '',
}) {
  return BaseNavigator.push<void>(
    context,
    ScenarioEditor(name: name, text: text, from: from),
  );
}

/// The scenario this subscription runs when auto routing is turned on
/// without a pick.
String rcxScenarioToTurnOn(WidgetRef ref) {
  final picked = ref.read(currentRoutingLayerProvider).scenario;
  return picked == null || picked.isEmpty ? _defaultScenario : picked;
}

/// The lint issues of one scenario by where they belong: a route, a group's
/// program, a field of either, or the page as a whole.
extension on List<RcxIssue> {
  Map<String, String> under(AppLocalizations l, String prefix) => {
    for (final issue in this)
      if (issue.path == prefix || issue.path.startsWith('$prefix.'))
        issue.path.length > prefix.length
            ? issue.path.substring(prefix.length + 1)
            : '': rcxIssueText(
          l,
          issue,
        ),
  };

  bool hits(String prefix) => where(
    (issue) => issue.path == prefix || issue.path.startsWith('$prefix.'),
  ).isNotEmpty;
}

void _clean(Map<String, Object?> scenario) {
  scenario.removeWhere((_, value) => rcxIsEmpty(value));
}

/// Text, lint and section edits of one scenario document, shared by the
/// editor page and the Routes tab of the hub.
mixin _ScenarioDocument<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String text = '';
  RcxStudioResult? lint;
  Map<String, Object?> scenario = const {};
  int _request = 0;
  (String, String)? _formatted;

  RcxRoutingAction get action => ref.read(rcxRoutingActionProvider.notifier);

  String get lintId;

  void onLinted(RcxStudioResult result) {}

  Future<RcxStudioResult?> _lintText(String text) => action.studio({
    'op': 'lint',
    'kind': 'scenario',
    'text': text,
    'id': lintId,
  });

  Future<void> check() async {
    final id = ++_request;
    final result = await _lintText(text);
    if (!mounted || id != _request || result == null) return;
    setState(() {
      lint = result;
      if (result.scenario case final parsed?) scenario = parsed;
    });
    onLinted(result);
  }

  void setText(String value) {
    setState(() => text = value);
    unawaited(check());
  }

  Future<String?> _format(void Function(Map<String, Object?>) update) async {
    final next = rcxDeepCopy(scenario);
    update(next);
    _clean(next);
    // A validated edit is kept right after with the same document.
    final key = jsonEncode(next);
    if (_formatted case (final done, final text) when done == key) return text;
    final result = await action.studio({
      'op': 'format',
      'kind': 'scenario',
      'scenario': next,
    });
    if (result?.text case final text?) _formatted = (key, text);
    return result?.text;
  }

  /// Section edits rewrite the document from its parsed form. An empty
  /// program stays: `'*': {}` means "every group, as it is".
  Future<void> edit(void Function(Map<String, Object?>) update) async {
    final formatted = await _format(update);
    if (formatted != null && mounted) setText(formatted);
  }

  /// The problems [update] would bring under [prefix], before it is kept.
  Future<Map<String, String>> validate(
    String prefix,
    void Function(Map<String, Object?>) update,
  ) async {
    final l = context.appLocalizations;
    final formatted = await _format(update);
    if (formatted == null) return const {};
    final result = await _lintText(formatted);
    return result?.errors.under(l, prefix) ?? const {};
  }
}

/// The connection-wide auto control as one page: what it is called and
/// does, then its routes, groups and networks.
class ScenarioEditor extends ConsumerStatefulWidget {
  const ScenarioEditor({super.key, this.name, this.text, this.from = ''});

  final String? name;
  final String? text;
  final String from;

  @override
  ConsumerState<ScenarioEditor> createState() => _ScenarioEditorState();
}

class _ScenarioEditorState extends ConsumerState<ScenarioEditor>
    with _ScenarioDocument {
  late RcxUserProfile _saved;
  final _title = TextEditingController();
  final _description = TextEditingController();
  Timer? _textDebounce;
  bool _saving = false;

  @override
  String get lintId => 'user/${widget.name ?? 'draft'}';

  @override
  void initState() {
    super.initState();
    final existing = widget.name == null
        ? null
        : ref.read(rcxProfilesProvider)[widget.name];
    _saved =
        existing ??
        RcxUserProfile(
          text: widget.text ?? _blankScenario,
          kind: 'scenario',
          from: widget.from,
          base: widget.from.isEmpty ? '' : widget.text ?? '',
        );
    text = _saved.text;
    unawaited(check());
  }

  @override
  void dispose() {
    _textDebounce?.cancel();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  void onLinted(RcxStudioResult result) {
    if (_textDebounce?.isActive ?? false) return;
    final title = scenario['title'] as String? ?? '';
    final description = scenario['description'] as String? ?? '';
    if (_title.text != title) _title.text = title;
    if (_description.text != description) _description.text = description;
  }

  bool get _dirty => widget.name == null || text != _saved.text;

  void _onTextChanged() {
    _textDebounce?.cancel();
    _textDebounce = Timer(_textDelay, () {
      unawaited(
        edit((s) {
          s['title'] = _title.text.trim();
          s['description'] = _description.text.trim();
        }),
      );
    });
  }

  Future<void> _editYaml() async {
    final edited = await BaseNavigator.push<String>(
      context,
      EditorPage(
        title: context.appLocalizations.rcxYaml,
        content: text,
        onSave: (context, _, content) => Navigator.of(context).pop(content),
      ),
    );
    if (edited != null && mounted) setText(edited);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final name =
          widget.name ??
          rcxFreeProfileName(
            ref.read(rcxProfilesProvider),
            scenario['title'] as String? ?? '',
          );
      await action.saveProfile(
        name,
        _saved.copyWith(text: text, kind: 'scenario'),
      );
      final active = ref.read(rcxStatusStateProvider)?.scenario?.id;
      if (widget.from.isNotEmpty && widget.from == active) {
        await action.setScenario('user/$name');
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final name = widget.name;
    if (name == null) return;
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: l.delete,
      destructive: true,
      message: TextSpan(text: l.rcxDeleteProfile(_titleOf(context))),
    );
    if (confirmed != true || !mounted) return;
    await action.saveProfile(name, null);
    if (mounted) Navigator.of(context).pop();
  }

  String _titleOf(BuildContext context) {
    final title = scenario['title'] as String? ?? '';
    return title.isEmpty ? context.appLocalizations.rcxNewScenario : title;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final lint = this.lint;
    final errors = lint?.errors ?? const <RcxIssue>[];
    final placed = ScenarioSections.placed(errors);
    return CommonScaffold(
      title: _titleOf(context),
      isLoading: lint == null,
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.code,
          label: l.rcxYaml,
          onPressed: _editYaml,
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.export,
          label: l.rcxExport,
          onPressed: () => unawaited(
            exportRoutingDocument(
              context,
              ref,
              id: widget.name != null && !_dirty ? lintId : null,
              kind: 'scenario',
              text: text,
              title: _titleOf(context),
            ),
          ),
        ),
        if (widget.name != null)
          CommonPopupMenuItem(
            glyph: AppGlyphs.delete,
            label: l.delete,
            danger: true,
            onPressed: _delete,
          ),
      ],
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: l.save,
        isLoading: _saving,
        onPressed: _saving || errors.isNotEmpty || !_dirty || lint == null
            ? null
            : _save,
      ),
      body: ListView(
        padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.contentTopPadding, bottom: 20) +
            context.bodyInsets,
        children: [
          ErrorBanner(
            message: placed.isEmpty ? null : rcxIssueText(l, placed.first),
          ),
          if (lint?.scenario != null) ...[
            generateSection(
              items: [
                FormRow(
                  title: l.rcxProfileName,
                  invalid: errors.hits('title'),
                  trailing: FormRowTextField(
                    controller: _title,
                    hintText: l.rcxNewScenario,
                    onChanged: (_) => _onTextChanged(),
                  ),
                ),
                DecorationListItem(
                  title: TextField(
                    controller: _description,
                    minLines: 2,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onChanged: (_) => _onTextChanged(),
                    decoration: InputDecoration.collapsed(
                      border: const NoInputBorder(),
                      hintText: l.rcxHubDescriptionHint,
                    ),
                  ),
                ),
              ],
            ),
            ScenarioSections(
              scenario: scenario,
              errors: errors,
              onEdit: edit,
              validate: validate,
            ),
          ],
          if (lint != null) ..._lintSections(l, lint),
        ],
      ),
    );
  }
}

List<Widget> _lintSections(AppLocalizations l, RcxStudioResult lint) => [
  if (lint.warnings.isNotEmpty)
    generateSection(
      title: l.rcxWarnings,
      items: [
        for (final warning in lint.warnings)
          DecorationListItem(title: Text(rcxIssueText(l, warning))),
      ],
    ),
  if (lint.endpoints.isNotEmpty)
    generateSection(
      title: l.rcxContacts,
      footer: l.rcxContactsHint,
      items: [
        for (final endpoint in lint.endpoints)
          DecorationListItem(
            title: Text(endpoint.host),
            subtitle: Text(rcxEndpointUse(l, endpoint.use)),
          ),
      ],
    ),
];

/// The active scenario of the subscription, edited in place: the first
/// change to a built-in or provider scenario makes the user's own copy and
/// runs it instead.
class RoutingRoutesTab extends ConsumerStatefulWidget {
  const RoutingRoutesTab({super.key, this.route, this.onRouteShown});

  final String? route;
  final VoidCallback? onRouteShown;

  @override
  ConsumerState<RoutingRoutesTab> createState() => _RoutingRoutesTabState();
}

class _RoutingRoutesTabState extends ConsumerState<RoutingRoutesTab>
    with _ScenarioDocument {
  late final ScrollController _controller = sheetScrollController(context);
  String? _id;
  bool _loaded = false;
  bool _copying = false;

  String? get _own =>
      _id != null && _id!.startsWith('user/') ? _id!.substring(5) : null;

  @override
  String get lintId => _id ?? 'user/draft';

  @override
  void initState() {
    super.initState();
    final id = ref.read(rcxStatusStateProvider)?.scenario?.id;
    if (id == null) {
      _loaded = true;
    } else {
      unawaited(_load(id));
    }
    ref.listenManual(
      rcxStatusStateProvider.select((status) => status?.scenario?.id),
      (_, id) => unawaited(_load(id)),
    );
    ref.listenManual(rcxProfilesProvider, (_, profiles) {
      final own = _own;
      final saved = own == null ? null : profiles[own]?.text;
      if (saved != null && saved != text) setText(saved);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load(String? id) async {
    if (id == _id && _loaded) return;
    _id = id;
    if (id == null) {
      setState(() {
        _loaded = true;
        text = '';
        lint = null;
        scenario = const {};
      });
      return;
    }
    final own = _own;
    final String? loaded;
    if (own != null) {
      loaded = ref.read(rcxProfilesProvider)[own]?.text;
    } else {
      final result = await action.studio({
        'op': 'source',
        'id': id,
        'kind': 'scenario',
      });
      loaded = result?.text;
    }
    if (!mounted || _id != id) return;
    _loaded = true;
    text = loaded ?? '';
    unawaited(check());
  }

  /// Makes the running scenario the user's own before its first change;
  /// false when the user keeps the original.
  Future<bool> _ensureOwn() async {
    if (_own != null) return true;
    if (_copying || _id == null) return false;
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final info = (ref.read(rcxLibraryProvider).value ?? const [])
        .where((p) => p.id == _id)
        .firstOrNull;
    final title = info?.displayTitle(locale) ?? _id!;
    final confirmed = await dialogs.showMessage(
      title: l.rcxHubCopyTitle,
      message: TextSpan(text: l.rcxHubCopyMessage(title)),
      confirmText: l.rcxHubCopyConfirm,
    );
    if (confirmed != true || !mounted) return false;
    _copying = true;
    try {
      final name = rcxFreeProfileName(ref.read(rcxProfilesProvider), title);
      await action.saveProfile(
        name,
        RcxUserProfile(text: text, kind: 'scenario', from: _id!, base: text),
      );
      _id = 'user/$name';
      await action.setScenario(_id);
      return mounted;
    } finally {
      _copying = false;
    }
  }

  Future<void> _edit(void Function(Map<String, Object?>) update) async {
    if (!await _ensureOwn()) return;
    await edit(update);
  }

  @override
  void onLinted(RcxStudioResult result) {
    final own = _own;
    if (own == null || result.errors.isNotEmpty) return;
    final saved = ref.read(rcxProfilesProvider)[own];
    if (saved == null || saved.text == text) return;
    unawaited(action.saveProfile(own, saved.copyWith(text: text)));
  }

  Future<void> _start() async {
    final name = rcxFreeProfileName(
      ref.read(rcxProfilesProvider),
      context.appLocalizations.rcxNewScenario,
    );
    await action.saveProfile(
      name,
      const RcxUserProfile(text: _blankScenario, kind: 'scenario'),
    );
    await action.setScenario('user/$name');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final status = ref.watch(rcxStatusStateProvider);
    final lint = this.lint;
    if (status == null) {
      return NullStatus(
        label: l.rcxHubNeedsCore,
        illustration: NullStatusIllustration.proxies,
      );
    }
    if (_loaded && _id == null) {
      return NullStatus(
        label: l.rcxHubRoutesOff,
        description: l.rcxHubRoutesOffHint,
        illustration: NullStatusIllustration.rules,
        action: FilledButton(
          onPressed: () => unawaited(_start()),
          child: Text(l.rcxHubStartScenario),
        ),
      );
    }
    final errors = lint?.errors ?? const <RcxIssue>[];
    final placed = ScenarioSections.placed(errors);
    return ListView(
      key: const PageStorageKey('routing-routes'),
      controller: _controller,
      padding:
          const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.appBarInset,
            bottom: context.bottomInset + 32,
          ) +
          context.bodyInsets,
      children: [
        ErrorBanner(
          message: placed.isEmpty ? null : rcxIssueText(l, placed.first),
        ),
        if (lint?.scenario != null)
          ScenarioSections(
            scenario: scenario,
            errors: errors,
            onEdit: _edit,
            validate: (prefix, update) async =>
                await _ensureOwn() ? validate(prefix, update) : const {},
            openRoute: widget.route,
            onRouteOpened: widget.onRouteShown,
            routes: status.scenario?.id == _id
                ? status.scenario?.routes ?? const []
                : const [],
            tunnelMode: status.tunnelMode,
          ),
        if (lint != null) ..._lintSections(l, lint),
      ],
    );
  }
}

typedef ScenarioEdit =
    Future<void> Function(void Function(Map<String, Object?> scenario) update);

typedef ScenarioValidate =
    Future<Map<String, String>> Function(
      String prefix,
      void Function(Map<String, Object?> scenario) update,
    );

/// The structure of one scenario: routes in priority order, everything
/// else, the other groups it names, and its networks.
class ScenarioSections extends ConsumerStatefulWidget {
  const ScenarioSections({
    super.key,
    required this.scenario,
    required this.errors,
    required this.onEdit,
    required this.validate,
    this.routes = const [],
    this.tunnelMode = '',
    this.openRoute,
    this.onRouteOpened,
  });

  final Map<String, Object?> scenario;
  final List<RcxIssue> errors;
  final ScenarioEdit onEdit;
  final ScenarioValidate validate;

  /// How the running scenario applied each route, when this is the one.
  final List<RcxRouteStatus> routes;
  final String tunnelMode;

  /// A route to open in its editor once, as the sections first show it.
  final String? openRoute;
  final VoidCallback? onRouteOpened;

  static const _placedRoots = ['routes', 'groups', 'title'];

  /// The errors no row of these sections shows.
  static List<RcxIssue> placed(List<RcxIssue> errors) => [
    for (final issue in errors)
      if (!_placedRoots.contains(issue.path.split('.').first)) issue,
  ];

  @override
  ConsumerState<ScenarioSections> createState() => _ScenarioSectionsState();
}

class _ScenarioSectionsState extends ConsumerState<ScenarioSections> {
  bool _sorting = false;
  bool _networks = false;

  Map<String, Object?> get _s => widget.scenario;

  @override
  void initState() {
    super.initState();
    _scheduleOpen();
  }

  @override
  void didUpdateWidget(ScenarioSections oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openRoute != oldWidget.openRoute) _scheduleOpen();
  }

  void _scheduleOpen() {
    final name = widget.openRoute;
    if (name == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.openRoute != name) return;
      widget.onRouteOpened?.call();
      final index = _routes.indexWhere((route) => route['name'] == name);
      if (index >= 0) unawaited(_openRoute(index, _routes[index]));
    });
  }

  List<Map<String, Object?>> get _routes => [
    for (final route in rcxList(_s['routes'])) rcxMap(route),
  ];

  String _profileTitle(String id) {
    final locale = Localizations.localeOf(context).toString();
    final library = ref.read(rcxLibraryProvider).value ?? const [];
    return library.where((p) => p.id == id).firstOrNull?.displayTitle(locale) ??
        id;
  }

  Set<String> _takenBy(int? index) {
    final routes = _routes;
    final routeNames = {for (final route in routes) route['name']};
    return {
      for (final (i, route) in routes.indexed)
        if (i != index) '${route['name']}',
      for (final group in ref.read(groupsProvider))
        if (!routeNames.contains(group.name)) group.name,
    };
  }

  Future<void> _addRoute() async {
    final match = await pickRouteTraffic(context);
    if (match == null || !mounted) return;
    final taken = _takenBy(null);
    var name = rcxTrafficName(match);
    if (taken.contains(name)) name = '';
    await _openRoute(null, {'name': name, 'match': match});
  }

  Future<void> _openRoute(int? index, Map<String, Object?> route) async {
    final at = index ?? _routes.length;
    void put(Map<String, Object?> s, Map<String, Object?> value) {
      final routes = [...rcxList(s['routes'])];
      if (index == null) {
        routes.add(value);
      } else {
        routes[index] = value;
      }
      s['routes'] = routes;
    }

    final result = await editRoute(
      context,
      value: route,
      scenario: _s,
      taken: _takenBy(index),
      validate: (value) => widget.validate('routes.$at', (s) => put(s, value)),
    );
    if (result != null) await widget.onEdit((s) => put(s, result));
  }

  Future<void> _openProgram(String target) async {
    void put(Map<String, Object?> s, Map<String, Object?> value) {
      s['groups'] = {...rcxMap(s['groups']), target: value};
    }

    final result = await editRoute(
      context,
      value: rcxMap(rcxMap(_s['groups'])[target]),
      scenario: _s,
      target: target,
      validate: (value) =>
          widget.validate('groups.$target', (s) => put(s, value)),
    );
    if (result != null) await widget.onEdit((s) => put(s, result));
  }

  void _removeRoute(int index) {
    unawaited(
      widget.onEdit(
        (s) => s['routes'] = [...rcxList(s['routes'])]..removeAt(index),
      ),
    );
  }

  void _reorder(int from, int to) {
    unawaited(
      widget.onEdit((s) {
        final routes = [...rcxList(s['routes'])];
        routes.insert(to, routes.removeAt(from));
        s['routes'] = routes;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _routesSection(l),
        _mainSection(l),
        _ProgramsSection(
          title: l.rcxHubOtherGroups,
          footer: l.rcxHubOtherGroupsHint,
          programs: rcxMap(_s['groups'])..remove(r'$main'),
          offerMain: false,
          errors: widget.errors,
          profileTitle: _profileTitle,
          onOpen: _openProgram,
          onRemove: (target) => unawaited(
            widget.onEdit(
              (s) => s['groups'] = {...rcxMap(s['groups'])}..remove(target),
            ),
          ),
        ),
        ..._networkSections(l),
      ],
    );
  }

  Widget _routesSection(AppLocalizations l) {
    final routes = _routes;
    final applied = {for (final route in widget.routes) route.name: route};
    final sorting = _sorting && routes.length > 1;
    Widget row(int index) {
      final route = routes[index];
      final name = '${route['name'] ?? ''}';
      final problem = applied[name]?.problem;
      final invalid = widget.errors.hits('routes.$index');
      final traffic = rcxTrafficSummary(l, [
        for (final head in rcxList(route['match'])) '$head',
      ]);
      return ContextMenuRegion(
        key: ValueKey('route:$name'),
        menuItems: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.edit,
            label: l.edit,
            onPressed: () => unawaited(_openRoute(index, route)),
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.delete,
            label: l.delete,
            danger: true,
            onPressed: () => _removeRoute(index),
          ),
        ],
        child: DecorationListItem(
          invalid: invalid || problem != null,
          title: EmojiText(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!name.toLowerCase().contains(traffic.toLowerCase()))
                EmojiText(
                  traffic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              EmojiText(
                problem != null
                    ? rcxReasonText(l, problem)
                    : rcxProgramSummary(l, route, profileTitle: _profileTitle),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          onPressed: () => unawaited(_openRoute(index, route)),
          trailing: const DisclosureIndicator(),
        ),
      );
    }

    final add = FormRow(
      key: const ValueKey('add-route'),
      title: l.rcxRouteAdd,
      leading: EntryButton.add(onPressed: _addRoute),
      onPressed: _addRoute,
    );
    final ruleOnly =
        routes.isNotEmpty &&
        widget.tunnelMode.isNotEmpty &&
        widget.tunnelMode != 'rule';
    return Column(
      children: [
        ListHeader(
          title: l.rcxHubRoutes,
          actions: [
            if (routes.length > 1)
              sortModeAction(
                context,
                sorting: sorting,
                onPressed: () => setState(() => _sorting = !_sorting),
              ),
          ],
        ),
        if (sorting)
          SortModeScope(
            sorting: true,
            child: ReorderableList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length,
              itemBuilder: (_, index) => SortableItem(
                key: ValueKey('route:${routes[index]['name']}'),
                index: index,
                child: ItemPositionProvider(
                  position: ItemPosition.get(index, routes.length),
                  child: row(index),
                ),
              ),
              proxyDecorator: (child, index, animation) => commonProxyDecorator(
                ItemPositionProvider(
                  position: ItemPosition.get(index, routes.length),
                  child: row(index),
                ),
                index,
                animation,
              ),
              onReorderItem: _reorder,
            ),
          )
        else
          AnimatedEntries(
            grouped: true,
            children: [for (var i = 0; i < routes.length; i++) row(i), add],
          ),
        ListFooter(
          text: ruleOnly
              ? l.rcxHubRoutesRuleOnly(rcxModeLabel(widget.tunnelMode))
              : l.rcxHubRoutesHint,
        ),
      ],
    );
  }

  Widget _mainSection(AppLocalizations l) {
    final program = rcxMap(rcxMap(_s['groups'])[r'$main']);
    final group = rcxTargetGroup(ref, r'$main');
    return generateSection(
      title: l.rcxHubEverythingElse,
      footer: l.rcxHubEverythingElseHint,
      items: [
        DecorationListItem(
          invalid: widget.errors.hits(r'groups.$main'),
          title: EmojiText(group ?? l.rcxMainGroup),
          subtitle: EmojiText(
            program.isEmpty
                ? l.rcxOwnProfile
                : rcxProgramSummary(l, program, profileTitle: _profileTitle),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: () => unawaited(_openProgram(r'$main')),
          trailing: const DisclosureIndicator(),
        ),
      ],
    );
  }

  List<Widget> _networkSections(AppLocalizations l) {
    final network = rcxMap(_s['network']);
    final kinds = [for (final kind in rcxList(network['kinds'])) rcxMap(kind)];
    final overrides = rcxMap(_s['on']);
    final tags = rcxMap(_s['tags']);
    final mode = _s['mode'] as String? ?? '';
    final summary = [
      mode.isEmpty ? l.rcxModeKeep : l.rcxModeIs(rcxModeLabel(mode)),
      for (final kind in kinds) rcxKindLabel(l, kind['kind'] as String? ?? ''),
    ].join(' · ');
    return [
      generateAnimatedSection(
        title: l.rcxHubNetworks,
        footer: _networks ? l.rcxScenarioKindsHint : null,
        items: [
          DecorationListItem(
            key: const ValueKey('networks'),
            title: Text(l.rcxHubNetworksTitle),
            subtitle: _networks ? null : Text(summary, maxLines: 2),
            onPressed: () => setState(() => _networks = !_networks),
            trailing: SizedBox.square(
              dimension: kMinInteractiveDimension,
              child: Center(
                child: GlyphIcon(
                  _networks ? AppGlyphs.chevronUp : AppGlyphs.chevronDown,
                ),
              ),
            ),
          ),
          if (_networks) ...[
            _modeRow(
              l,
              mode,
              (mode) => widget.onEdit((s) => s['mode'] = mode),
              key: const ValueKey('mode'),
            ),
            for (final (index, kind) in kinds.indexed)
              _kindRow(l, index, kind, rcxMap(overrides[kind['kind']])),
            FormRow(
              key: const ValueKey('add-kind'),
              title: l.rcxAddKind,
              leading: EntryButton.add(onPressed: _addKind),
              onPressed: _addKind,
            ),
          ],
        ],
      ),
      AnimatedEntries(
        children: [
          if (_networks)
            KeyedSubtree(
              key: const ValueKey('tags'),
              child: _tagsSection(l, tags),
            ),
          if (_networks &&
              (rcxMap(network['diagnose']).isNotEmpty ||
                  rcxMap(_s['l10n']).isNotEmpty))
            KeyedSubtree(
              key: const ValueKey('advanced'),
              child: _advancedSection(l, network),
            ),
        ],
      ),
    ];
  }

  Widget _tagsSection(AppLocalizations l, Map<String, Object?> tags) {
    return generateSection(
      title: l.rcxTags,
      footer: l.rcxTagsHint,
      items: [
        for (final MapEntry(:key, :value) in tags.entries)
          ContextMenuRegion(
            menuItems: [
              CommonPopupMenuItem(
                glyph: AppGlyphs.delete,
                label: l.delete,
                danger: true,
                onPressed: () => unawaited(
                  widget.onEdit(
                    (s) => s['tags'] = {...rcxMap(s['tags'])}..remove(key),
                  ),
                ),
              ),
            ],
            child: DecorationListItem(
              title: EmojiText(key),
              subtitle: Text('$value', maxLines: 2),
              onPressed: () async {
                final text = await editCondition(
                  context,
                  title: key,
                  text: '$value',
                  profile: const {},
                );
                if (text != null && text.isNotEmpty) {
                  await widget.onEdit(
                    (s) => s['tags'] = {...rcxMap(s['tags']), key: text},
                  );
                }
              },
              trailing: const DisclosureIndicator(),
            ),
          ),
        FormRow(
          title: l.rcxAddTag,
          leading: EntryButton.add(onPressed: _addTag),
          onPressed: _addTag,
        ),
      ],
    );
  }

  Widget _advancedSection(AppLocalizations l, Map<String, Object?> network) {
    return generateSection(
      title: l.rcxAdvanced,
      footer: l.rcxAdvancedHint,
      items: [
        if (rcxMap(network['diagnose']) case final diag when diag.isNotEmpty)
          DecorationListItem(
            title: Text(l.rcxDiagnostics),
            subtitle: Text(diag.keys.join(', ')),
          ),
        if (rcxMap(_s['l10n']) case final languages when languages.isNotEmpty)
          DecorationListItem(
            title: Text(l.rcxTranslations),
            subtitle: Text(languages.keys.join(', ')),
          ),
      ],
    );
  }

  Widget _kindRow(
    AppLocalizations l,
    int index,
    Map<String, Object?> kind,
    Map<String, Object?> layer,
  ) {
    final name = kind['kind'] as String? ?? '';
    final mode = layer['mode'] as String? ?? '';
    final groups = rcxMap(layer['groups']);
    return ContextMenuRegion(
      key: ValueKey('kind:$name'),
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.delete,
          label: l.delete,
          danger: true,
          onPressed: () => unawaited(
            widget.onEdit((s) {
              final network = rcxMap(s['network']);
              network['kinds'] = [...rcxList(network['kinds'])]
                ..removeAt(index);
              s['network'] = network;
              s['on'] = {...rcxMap(s['on'])}..remove(name);
            }),
          ),
        ),
      ],
      child: DecorationListItem(
        title: Text(rcxKindLabel(l, name)),
        subtitle: Text(
          [
            if ((kind['when'] as String? ?? '').isNotEmpty) kind['when'],
            if (mode.isNotEmpty) l.rcxModeIs(rcxModeLabel(mode)),
            if (groups.isNotEmpty)
              groups.keys.map((k) => rcxProgramLabel(l, k)).join(', '),
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () => unawaited(_editKind(index)),
        trailing: const DisclosureIndicator(),
      ),
    );
  }

  Future<void> _addKind() async {
    final l = context.appLocalizations;
    final taken = {
      for (final kind in rcxList(rcxMap(_s['network'])['kinds']))
        rcxMap(kind)['kind'],
    };
    final name = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: l.rcxAddKind,
        value: '',
        labelText: l.rcxKindName,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (!RegExp(r'^[a-z0-9-]{1,24}$').hasMatch(text)) {
            return l.rcxKindNameInvalid;
          }
          return taken.contains(text) ? l.existsTip(text) : null;
        },
      ),
    );
    final kind = name?.trim() ?? '';
    if (kind.isEmpty || !mounted) return;
    await widget.onEdit((s) {
      final network = rcxMap(s['network']);
      network['kinds'] = [
        ...rcxList(network['kinds']),
        {'kind': kind, 'when': ''},
      ];
      s['network'] = network;
    });
  }

  Future<void> _editKind(int index) async {
    final kinds = rcxList(rcxMap(_s['network'])['kinds']);
    if (index >= kinds.length) return;
    final kind = rcxMap(kinds[index]);
    final name = kind['kind'] as String? ?? '';
    final result = await BaseNavigator.push<_KindEdit>(
      context,
      _KindEditor(
        kind: kind,
        layer: rcxMap(rcxMap(_s['on'])[name]),
        scenario: _s,
        profileTitle: _profileTitle,
      ),
    );
    if (result == null) return;
    await widget.onEdit((s) {
      final network = rcxMap(s['network']);
      network['kinds'] = [...rcxList(network['kinds'])]..[index] = result.kind;
      s['network'] = network;
      final on = rcxMap(s['on']);
      if (result.layer.isEmpty) {
        on.remove(name);
      } else {
        on[name] = result.layer;
      }
      s['on'] = on;
    });
  }

  Future<void> _addTag() async {
    final l = context.appLocalizations;
    final name = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: l.rcxAddTag,
        value: '',
        labelText: l.rcxTagName,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (!RegExp(r'^[A-Za-z0-9_-]{1,24}$').hasMatch(text)) {
            return l.rcxTagNameInvalid;
          }
          return rcxMap(_s['tags']).containsKey(text)
              ? l.existsTip(text)
              : null;
        },
      ),
    );
    final tag = name?.trim() ?? '';
    if (tag.isEmpty || !mounted) return;
    final text = await editCondition(
      context,
      title: tag,
      text: '',
      profile: const {},
    );
    if (text == null || text.isEmpty) return;
    await widget.onEdit((s) => s['tags'] = {...rcxMap(s['tags']), tag: text});
  }
}

Widget _modeRow(
  AppLocalizations l,
  String mode,
  ValueChanged<String> onChanged, {
  Key? key,
}) {
  return ListItem<String>.options(
    key: key,
    title: Text(l.rcxScenarioMode),
    options: _modes,
    value: _modes.contains(mode) ? mode : '',
    textBuilder: (mode) => mode.isEmpty ? l.rcxModeKeep : rcxModeLabel(mode),
    onChanged: (value) {
      if (value != mode) onChanged(value);
    },
  );
}

typedef _KindEdit = ({Map<String, Object?> kind, Map<String, Object?> layer});

/// One network kind: how it is recognized, and the mode and groups the
/// scenario holds while on it.
class _KindEditor extends StatefulWidget {
  const _KindEditor({
    required this.kind,
    required this.layer,
    required this.scenario,
    required this.profileTitle,
  });

  final Map<String, Object?> kind;
  final Map<String, Object?> layer;
  final Map<String, Object?> scenario;
  final String Function(String id) profileTitle;

  @override
  State<_KindEditor> createState() => _KindEditorState();
}

class _KindEditorState extends State<_KindEditor> {
  late Map<String, Object?> _kind = {...widget.kind};
  late Map<String, Object?> _layer = {...widget.layer};

  Map<String, Object?> get _groups => rcxMap(_layer['groups']);

  Future<void> _editWhen() async {
    final l = context.appLocalizations;
    final text = await editCondition(
      context,
      title: rcxKindLabel(l, _kind['kind'] as String? ?? ''),
      text: _kind['when'] as String? ?? '',
      // Network conditions see the scenario's own diagnostics.
      profile: {'network': rcxMap(widget.scenario['network'])},
      network: true,
    );
    if (text != null && mounted) {
      setState(() => _kind = {..._kind, 'when': text});
    }
  }

  Future<void> _openProgram(String target) async {
    final result = await editRoute(
      context,
      value: rcxMap(_groups[target]),
      scenario: widget.scenario,
      target: target,
    );
    if (result != null && mounted) {
      setState(
        () => _layer = {
          ..._layer,
          'groups': {..._groups, target: result},
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final when = _kind['when'] as String? ?? '';
    return FormPage(
      title: rcxKindLabel(l, _kind['kind'] as String? ?? ''),
      onSave: () {
        final layer = {..._layer}..removeWhere((_, value) => rcxIsEmpty(value));
        Navigator.of(context).pop((kind: _kind, layer: layer));
      },
      children: [
        generateSection(
          footer: l.rcxKindWhenHint,
          items: [
            DecorationListItem(
              title: Text(l.rcxKindWhen),
              subtitle: Text(when.isEmpty ? l.rcxCondAlways : when),
              onPressed: _editWhen,
              trailing: const DisclosureIndicator(),
            ),
          ],
        ),
        generateSection(
          title: l.rcxOnThisNetwork,
          items: [
            _modeRow(
              l,
              _layer['mode'] as String? ?? '',
              (mode) => setState(() => _layer = {..._layer, 'mode': mode}),
            ),
          ],
        ),
        _ProgramsSection(
          title: l.rcxScenarioGroups,
          footer: l.rcxKindGroupsHint,
          programs: _groups,
          offerMain: true,
          profileTitle: widget.profileTitle,
          onOpen: (target) => unawaited(_openProgram(target)),
          onRemove: (target) => setState(
            () => _layer = {
              ..._layer,
              'groups': {..._groups}..remove(target),
            },
          ),
        ),
      ],
    );
  }
}

/// The groups a scenario names and what it does with each; a group is
/// added from the config's select groups, as every other group, or GLOBAL.
class _ProgramsSection extends ConsumerWidget {
  const _ProgramsSection({
    required this.title,
    required this.programs,
    required this.offerMain,
    required this.profileTitle,
    required this.onOpen,
    required this.onRemove,
    this.errors = const [],
    this.footer,
  });

  final String title;
  final String? footer;
  final Map<String, Object?> programs;
  final bool offerMain;
  final List<RcxIssue> errors;
  final String Function(String id) profileTitle;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final groups = ref.watch(
      groupsProvider.select(
        (groups) => [
          for (final group in groups)
            if (group.type == GroupType.Selector) group.name,
        ],
      ),
    );
    final targets = [
      for (final target in [if (offerMain) r'$main', '*', 'GLOBAL', ...groups])
        if (!programs.containsKey(target)) target,
    ];
    return generateAnimatedSection(
      title: title,
      footer: footer,
      items: [
        for (final MapEntry(:key, :value) in programs.entries)
          ContextMenuRegion(
            key: ValueKey('program:$key'),
            menuItems: [
              CommonPopupMenuItem(
                glyph: AppGlyphs.delete,
                label: l.delete,
                danger: true,
                onPressed: () => onRemove(key),
              ),
            ],
            child: DecorationListItem(
              invalid: errors.hits('groups.$key'),
              title: EmojiText(rcxProgramLabel(l, key)),
              subtitle: EmojiText(
                rcxMap(value).isEmpty
                    ? l.rcxOwnProfile
                    : rcxProgramSummary(
                        l,
                        rcxMap(value),
                        profileTitle: profileTitle,
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => onOpen(key),
              trailing: const DisclosureIndicator(),
            ),
          ),
        if (targets.isNotEmpty)
          CommonPopupBox(
            key: const ValueKey('add-group'),
            targetBuilder: (open) => FormRow(
              title: l.rcxAddGroup,
              leading: EntryButton.add(onPressed: open),
              onPressed: open,
            ),
            popupBuilder: (_) => CommonPopupMenu(
              items: [
                for (final target in targets)
                  CommonPopupMenuItem(
                    label: rcxProgramLabel(l, target),
                    onPressed: () => onOpen(target),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
