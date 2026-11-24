import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:yaml/yaml.dart';

import 'routing.dart';

const _hold = 'version: 1\nlevels:\n  - pick: hold\n';

/// Whether [group]'s header opens its behaviour page rather than the legacy
/// auto-routing sheet. A strategy or a selector the user can script owns the
/// entry; a group the engine already drives keeps its sheet.
bool watchGroupBehaviour(WidgetRef ref, Group group) {
  final report = ref.watch(
    rcxStatusStateProvider.select((status) => status?.strategies[group.name]),
  );
  if (report != null) return true;
  if (ref.watch(rcxGroupProvider(group.name)) != null) return false;
  return group.type == GroupType.Selector && ref.watch(canScriptGroupsProvider);
}

Future<void> showGroupBehaviour(BuildContext context, String group) {
  return BaseNavigator.push<void>(context, _GroupBehaviourView(group: group));
}

Future<void> showNewStrategyGroup(BuildContext context) {
  return BaseNavigator.push<void>(context, const ScriptedGroupEditor());
}

class _GroupBehaviourView extends ConsumerWidget {
  const _GroupBehaviourView({required this.group});

  final String group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final status = ref.watch(rcxStatusStateProvider);
    final report = status?.strategies[group];
    final layer = ref.watch(currentRoutingLayerProvider);
    final local = layer.localGroups[group];
    final supported = ref.watch(canScriptGroupsProvider);
    final proxy = ref.watch(
      groupsProvider.select((state) => state.getGroup(group)),
    );
    final legacy = ref.watch(rcxGroupProvider(group));
    final action = ref.read(rcxRoutingActionProvider.notifier);
    final saved = layer.strategies[group];
    final active = report?.source ?? '';
    final automatic = active == 'user' && saved?.trim() == _hold.trim();
    Future<void> select(String? source) async {
      if (!await action.setStrategy(group, source) && context.mounted) {
        dialogs.showNotifier(l.rcxStrategyNotApplied);
      }
    }

    final issue = switch (report) {
      final report? when report.issue.isNotEmpty => l.rcxProblemProfileInvalid(
        report.issue,
      ),
      final report? when report.empty => l.rcxProblemGroupEmpty,
      _ when !supported => l.rcxStrategyCoreUnavailable,
      _ => null,
    };
    Future<void> delete() async {
      final confirmed = await dialogs.showMessage(
        title: l.delete,
        destructive: true,
        message: TextSpan(text: l.rcxDeleteProfile(group)),
      );
      if (confirmed != true || !context.mounted) return;
      final removed = await action.setLocalStrategyGroup(group, null, null);
      if (!context.mounted) return;
      if (removed) {
        Navigator.of(context).pop();
      } else {
        dialogs.showNotifier(l.rcxStrategyNotApplied);
      }
    }

    return CommonScaffold(
      title: group,
      menuItems: [
        if (local != null)
          CommonPopupMenuItem(
            glyph: AppGlyphs.delete,
            label: l.delete,
            danger: true,
            onPressed: () => unawaited(delete()),
          ),
      ],
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, context.contentTopPadding, 16, 24),
        children: [
          if (supported)
            generateSection(
              title: l.rcxBehaviour,
              items: [
                _choice(
                  proxy?.type == GroupType.Selector
                      ? l.rcxModeManual
                      : l.rcxWouldDo,
                  active.isEmpty,
                  () => unawaited(select('')),
                ),
                if (proxy?.type == GroupType.Selector)
                  _choice(
                    l.rcxStrategyAuto,
                    automatic,
                    () => unawaited(select(_hold)),
                  ),
                if (report?.offered == true)
                  _choice(
                    l.rcxSourceProvider,
                    active == 'provider',
                    () => unawaited(select(null)),
                  ),
              ],
            ),
          generateSection(
            items: [
              if (supported && proxy != null)
                ListItem(
                  title: Text(l.rcxStrategyEdit),
                  subtitle: active == 'user' && !automatic
                      ? Text(l.rcxFromYours)
                      : null,
                  trailing: const DisclosureIndicator(),
                  onTap: () async {
                    final source = saved == null || saved.isEmpty
                        ? await action.studio({
                            'op': 'source',
                            'kind': 'strategy',
                            'group': group,
                          })
                        : null;
                    if (!context.mounted) return;
                    await BaseNavigator.push<void>(
                      context,
                      ScriptedGroupEditor(
                        group: group,
                        local: local,
                        source: saved?.isNotEmpty == true
                            ? saved
                            : source?.text,
                      ),
                    );
                  },
                ),
              if (legacy != null)
                ListItem(
                  title: Text(l.rcxGroupProfiles),
                  trailing: const DisclosureIndicator(),
                  onTap: () => unawaited(showRoutingSheet(context, group)),
                ),
            ],
          ),
          if (issue != null) ListFooter(text: issue),
        ],
      ),
    );
  }

  Widget _choice(String label, bool selected, VoidCallback select) {
    return DecorationListItem(
      isSelected: selected,
      title: Text(label),
      trailing: selected ? const SelectionCheck() : null,
      onPressed: selected ? null : select,
    );
  }
}

class ScriptedGroupEditor extends ConsumerStatefulWidget {
  const ScriptedGroupEditor({super.key, this.group, this.local, this.source});

  final String? group;
  final RcxLocalStrategyGroup? local;
  final String? source;

  @override
  ConsumerState<ScriptedGroupEditor> createState() => _StrategyEditorState();
}

class _StrategyEditorState extends ConsumerState<ScriptedGroupEditor> {
  late final _name = TextEditingController(text: widget.group);
  late final _members = TextEditingController(
    text: widget.local?.members.join('\n'),
  );
  late final _providers = TextEditingController(
    text: widget.local?.providers.join('\n'),
  );
  late final _source = TextEditingController(
    text: widget.source?.isNotEmpty == true ? widget.source : _hold,
  );

  late final int? _profileId;
  late bool _includeAll;
  late bool _asText;
  late bool _showFilters;
  final _preferredName = TextEditingController();
  final _excludedCountries = TextEditingController();
  bool _lowestLatency = false;
  RcxStudioResult? _preview;
  bool _pending = false;
  String? _error;

  bool get _isLocal => widget.group == null || widget.local != null;

  @override
  void initState() {
    super.initState();
    _profileId = ref.read(currentProfileProvider)?.id;
    _asText = !_readSimpleSource();
    _includeAll = widget.local?.includeAll ?? widget.group == null;
    _showFilters =
        _preferredName.text.isNotEmpty || _excludedCountries.text.isNotEmpty;
  }

  @override
  void dispose() {
    _name.dispose();
    _members.dispose();
    _providers.dispose();
    _source.dispose();
    _preferredName.dispose();
    _excludedCountries.dispose();
    super.dispose();
  }

  List<String> _lines(TextEditingController controller) => controller.text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toSet()
      .toList();

  Future<void> _apply({required bool save}) async {
    if (_pending) return;
    final group = _name.text.trim();
    final source = _asText ? _source.text : _simpleSource();
    FocusScope.of(context).unfocus();
    final spec = !_isLocal
        ? null
        : RcxLocalStrategyGroup(
            includeAll: _includeAll,
            members: _includeAll ? const [] : _lines(_members),
            providers: _includeAll ? const [] : _lines(_providers),
          );
    final action = ref.read(rcxRoutingActionProvider.notifier);
    final l = context.appLocalizations;
    setState(() {
      _pending = true;
      _error = null;
      _preview = null;
    });
    try {
      final preview = await action.studio({
        'kind': 'strategy',
        'op': 'lint',
        'group': group,
        'text': source,
        if (spec != null) 'localGroup': spec.toJson(),
        if (widget.group == null) 'create': true,
      });
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _error = preview == null ? l.rcxStrategyCoreUnavailable : null;
      });
      if (!save || preview == null || preview.errors.isNotEmpty) return;
      if (ref.read(currentProfileProvider)?.id != _profileId) {
        setState(() => _error = l.rcxStrategyProfileChanged);
        return;
      }
      final applied = spec == null
          ? await action.setStrategy(group, source)
          : await action.setLocalStrategyGroup(group, spec, source);
      if (!mounted) return;
      if (applied) {
        Navigator.of(context).pop();
      } else {
        setState(() => _error = l.rcxStrategyNotApplied);
      }
    } catch (error) {
      if (mounted) setState(() => _error = l.rcxStrategyNotApplied);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  bool _readSimpleSource() {
    final input = widget.source;
    if (input == null || input.isEmpty || input == _hold) return true;
    try {
      final root = loadYaml(input);
      if (root is! Map || root['levels'] is! List) return false;
      final levels = root['levels'] as List;
      if (levels.isEmpty || levels.first is! Map) return false;
      final level = levels.first as Map;
      final filter = level['match'];
      final exclude = root['exclude'];
      final countries = exclude is Map ? exclude['countries'] : null;
      _excludedCountries.text = countries is List ? countries.join(' ') : '';
      _preferredName.text = filter is Map
          ? filter['name-contains']?.toString() ?? ''
          : '';
      _lowestLatency = level['pick'] == 'latency';
      return _simpleSource().trim() == input.trim();
    } on YamlException {
      return false;
    }
  }

  String _simpleSource() {
    final preferred = _preferredName.text;
    final excluded = _excludedCountries.text
        .split(RegExp(r'[,\s]+'))
        .where((country) => country.isNotEmpty)
        .map((country) => country.toUpperCase())
        .toList();
    final pick = _lowestLatency ? 'latency' : 'hold';
    return [
      'version: 1',
      if (excluded.isNotEmpty) 'exclude: {countries: ${jsonEncode(excluded)}}',
      'levels:',
      if (preferred.isNotEmpty) ...[
        '  - match: {name-contains: ${jsonEncode(preferred)}}',
        '    pick: $pick',
      ],
      '  - pick: $pick',
      '',
    ].join('\n');
  }

  void _clearPreview(String _) => setState(() {
    _preview = null;
    _error = null;
  });

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: !_pending,
      onChanged: _clearPreview,
      minLines: lines,
      maxLines: lines == 1 ? 1 : null,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _input(
    String title,
    TextEditingController controller, {
    String? hint,
  }) {
    return FormRow(
      title: title,
      trailing: IgnorePointer(
        ignoring: _pending,
        child: FormRowTextField(
          controller: controller,
          hintText: hint,
          onChanged: _clearPreview,
        ),
      ),
    );
  }

  Widget _pick(String label, bool latency) {
    final selected = latency == _lowestLatency;
    return DecorationListItem(
      isSelected: selected,
      title: Text(label),
      trailing: selected ? const SelectionCheck() : null,
      onPressed: selected || _pending
          ? null
          : () {
              _lowestLatency = latency;
              _clearPreview('');
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final preview = _preview;
    final filters = [
      if (_preferredName.text.isNotEmpty)
        l.rcxLadderNameHas(_preferredName.text),
      if (_excludedCountries.text.isNotEmpty)
        _excludedCountries.text.toUpperCase(),
    ];
    return CommonScaffold(
      title: widget.group ?? l.rcxAddGroup,
      menuItems: [
        if (!_asText)
          CommonPopupMenuItem(
            label: l.rcxStrategyYaml,
            onPressed: _pending
                ? null
                : () {
                    _source.text = _simpleSource();
                    setState(() => _asText = true);
                  },
          ),
      ],
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: widget.group == null ? l.rcxAddGroup : l.save,
        isLoading: _pending,
        onPressed: _pending || _name.text.trim().isEmpty
            ? null
            : () => unawaited(_apply(save: true)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, context.contentTopPadding, 16, 24),
            children: [
              if (widget.group == null)
                generateSection(
                  items: [_input(l.name, _name, hint: l.rcxCheckGroup)],
                ),
              if (_isLocal)
                generateSection(
                  title: l.rcxServers,
                  footer: _includeAll ? null : l.rcxStrategyLines,
                  items: [
                    DecorationListItem(
                      title: Text(l.rcxStrategyAllServers),
                      trailing: Switch(
                        value: _includeAll,
                        onChanged: _pending
                            ? null
                            : (value) {
                                _includeAll = value;
                                _clearPreview('');
                              },
                      ),
                    ),
                    if (!_includeAll) ...[
                      _field(_members, l.rcxServers, lines: 2),
                      _field(_providers, l.proxyProviders, lines: 2),
                    ],
                  ],
                ),
              if (_asText)
                _field(_source, 'YAML', lines: 6)
              else
                generateSection(
                  title: l.rcxBehaviour,
                  items: [
                    _pick(l.rcxStrategyHold, false),
                    _pick(l.rcxStrategyLowestLatency, true),
                  ],
                ),
              if (!_asText)
                generateSection(
                  items: [
                    DecorationListItem(
                      title: Text(l.filter),
                      subtitle: filters.isNotEmpty && !_showFilters
                          ? Text(filters.join(' · '), maxLines: 2)
                          : null,
                      trailing: GlyphIcon(
                        _showFilters
                            ? AppGlyphs.chevronUp
                            : AppGlyphs.chevronDown,
                      ),
                      onPressed: _pending
                          ? null
                          : () {
                              setState(() => _showFilters = !_showFilters);
                            },
                    ),
                    if (_showFilters) ...[
                      _input(
                        l.rcxStrategyPreferNames,
                        _preferredName,
                        hint: '*',
                      ),
                      _input(
                        l.rcxLadderExceptCountries,
                        _excludedCountries,
                        hint: 'RU',
                      ),
                    ],
                  ],
                ),
              if (_error case final error?) ListFooter(text: error),
              if (preview != null) ...[
                for (final issue in preview.errors)
                  ListFooter(text: issue.message),
                for (final (index, members) in preview.strategyLevels.indexed)
                  generateSection(
                    title: l.rcxLadderStep(index + 1),
                    footer: l.rcxLadderFits(members.length),
                    items: [
                      if (members.isNotEmpty)
                        ListItem(
                          title: Text(members.take(3).join(', '), maxLines: 2),
                          trailing: const DisclosureIndicator(),
                          onTap: () => unawaited(
                            BaseNavigator.push<void>(
                              context,
                              _StrategyMembers(
                                title: l.rcxLadderStep(index + 1),
                                names: members,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
              if (_showFilters ||
                  filters.isNotEmpty ||
                  _asText ||
                  !_includeAll && _isLocal)
                TextButton(
                  onPressed: _pending
                      ? null
                      : () => unawaited(_apply(save: false)),
                  child: Text(l.preview),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrategyMembers extends StatelessWidget {
  const _StrategyMembers({required this.title, required this.names});

  final String title;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, context.contentTopPadding, 16, 24),
        itemCount: names.length,
        itemBuilder: (_, index) => ListItem(title: EmojiText(names[index])),
      ),
    );
  }
}
