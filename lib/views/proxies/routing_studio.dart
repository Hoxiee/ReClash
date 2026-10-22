import 'dart:async';

import 'package:reclash/common/common.dart';
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
import 'routing_import.dart';

const rcxFeels = ['calm', 'balanced', 'eager'];
const rcxEnergies = ['eco', 'balanced', 'precise'];
const _strandings = ['hold', 'direct'];
const _checkRows = 6;
const _titleDelay = Duration(milliseconds: 500);

/// A new profile starts from the simple built-in's behaviour with one tier,
/// so the first edit is the user's own.
const _blankProfile =
    'rcx: 1\n'
    'title: My profile\n'
    'level: simple\n'
    'prefer:\n'
    '  - { label: Working, when: not dead }\n'
    'rank: { by: latency, tolerance: 50 }\n'
    'switch: { feel: calm }\n';

/// Opens the editor for the user's profile [name]. Without a name it starts
/// a new one from [text]; [from] names the profile it copies, whose later
/// changes the editor then offers to bring over.
Future<void> openRoutingStudio(
  BuildContext context, {
  String? name,
  String? text,
  String from = '',
  String? groupName,
}) {
  return BaseNavigator.push<void>(
    context,
    RoutingStudio(name: name, text: text, from: from, groupName: groupName),
  );
}

class RoutingStudio extends ConsumerStatefulWidget {
  const RoutingStudio({
    super.key,
    this.name,
    this.text,
    this.from = '',
    this.groupName,
  });

  final String? name;
  final String? text;
  final String from;
  final String? groupName;

  @override
  ConsumerState<RoutingStudio> createState() => _RoutingStudioState();
}

class _RoutingStudioState extends ConsumerState<RoutingStudio> {
  late RcxUserProfile _saved;
  late String _text;
  final _title = TextEditingController();
  Timer? _titleDebounce;
  RcxStudioResult? _lint;
  Map<String, Object?> _profile = const {};
  String? _source;
  bool _saving = false;
  int _request = 0;
  // The smart group the draft is checked against.
  late String? _group = widget.groupName;

  RcxRoutingAction get _action => ref.read(rcxRoutingActionProvider.notifier);

  String get _id => 'user/${widget.name ?? 'draft'}';

  @override
  void initState() {
    super.initState();
    final existing = widget.name == null
        ? null
        : ref.read(rcxProfilesProvider)[widget.name];
    _saved =
        existing ??
        RcxUserProfile(
          text: widget.text ?? _blankProfile,
          from: widget.from,
          base: widget.from.isEmpty ? '' : widget.text ?? '',
        );
    _text = _saved.text;
    unawaited(_check());
    unawaited(_loadSource());
  }

  @override
  void dispose() {
    _titleDebounce?.cancel();
    _title.dispose();
    super.dispose();
  }

  bool get _dirty => widget.name == null || _text != _saved.text;

  Future<void> _loadSource() async {
    if (_saved.from.isEmpty) return;
    final result = await _action.studio({'op': 'source', 'id': _saved.from});
    if (mounted && result != null) setState(() => _source = result.text);
  }

  Future<void> _check() async {
    final id = ++_request;
    final result = await _action.studio({
      'op': 'lint',
      'text': _text,
      'id': _id,
      'group': ?_group,
    });
    if (!mounted || id != _request || result == null) return;
    setState(() {
      _lint = result;
      if (result.profile case final profile?) {
        _profile = profile;
        final title = profile['title'] as String? ?? '';
        if (_title.text != title && _titleDebounce?.isActive != true) {
          _title.text = title;
        }
      }
    });
  }

  void _setText(String text) {
    setState(() => _text = text);
    unawaited(_check());
  }

  /// Section edits rewrite the document from its parsed form, so the
  /// comments of hand-written YAML do not survive them.
  Future<void> _edit(void Function(Map<String, Object?> profile) update) async {
    final profile = rcxDeepCopy(_profile);
    update(profile);
    profile.removeWhere((_, value) => rcxIsEmpty(value));
    final result = await _action.studio({'op': 'format', 'profile': profile});
    if (!mounted || result == null) return;
    _setText(result.text);
  }

  void _onTitleChanged(String title) {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(_titleDelay, () {
      unawaited(_edit((p) => p['title'] = title.trim()));
    });
  }

  Future<void> _editYaml() async {
    final l = context.appLocalizations;
    final text = await BaseNavigator.push<String>(
      context,
      EditorPage(
        title: l.rcxYaml,
        content: _text,
        onSave: (context, _, content) => Navigator.of(context).pop(content),
      ),
    );
    if (text != null && mounted) _setText(text);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final name =
          widget.name ??
          rcxFreeProfileName(
            ref.read(rcxProfilesProvider),
            _profile['title'] as String? ?? '',
          );
      await _action.saveProfile(
        name,
        _saved.copyWith(text: _text, history: _saved.history),
      );
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
      message: TextSpan(text: l.rcxDeleteProfile(_titleOf(context))),
    );
    if (confirmed != true || !mounted) return;
    await _action.saveProfile(name, null);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _restore() async {
    final l = context.appLocalizations;
    final version = await showInSheet<RcxProfileVersion>(
      context,
      builder: (sheetContext) => SelectionSheet<RcxProfileVersion>(
        title: l.rcxHistoryVersions,
        sections: [SelectionSection(items: _saved.history)],
        labelBuilder: (v) => v.at.getLastUpdateTimeDesc(sheetContext),
        selectedOf: (_) => null,
        onSelected: (v) => Navigator.of(sheetContext).pop(v),
      ),
    );
    if (version != null && mounted) _setText(version.text);
  }

  Future<void> _bringOver() async {
    final source = _source;
    if (source == null) return;
    final result = await _action.studio({
      'op': 'merge',
      'base': _saved.base,
      'theirs': source,
      'text': _text,
    });
    if (!mounted || result == null) return;
    final l = context.appLocalizations;
    if (result.text.isEmpty) {
      context.showNotifier(l.rcxMergeFailed);
      return;
    }
    setState(() => _saved = _saved.copyWith(base: source));
    _setText(result.text);
    context.showNotifier(
      result.conflicts.isEmpty
          ? l.rcxMerged
          : l.rcxMergedConflicts(result.conflicts.join(', ')),
    );
  }

  void _showChanges() {
    final source = _source;
    if (source == null) return;
    unawaited(
      showInSheet<void>(
        context,
        builder: (_) => _DiffPage(
          title: context.appLocalizations.rcxSourceChanges,
          before: _saved.base,
          after: source,
        ),
      ),
    );
  }

  String _titleOf(BuildContext context) {
    final title = _profile['title'] as String? ?? '';
    return title.isEmpty ? context.appLocalizations.rcxNewProfile : title;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final lint = _lint;
    final errors = lint?.errors ?? const <RcxIssue>[];
    final sourceChanged =
        _source != null && _saved.base.isNotEmpty && _source != _saved.base;
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
            showRoutingExport(context, text: _text, title: _titleOf(context)),
          ),
        ),
        if (_saved.history.isNotEmpty)
          CommonPopupMenuItem(
            glyph: AppGlyphs.clock,
            label: l.rcxHistoryVersions,
            onPressed: _restore,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 20),
        children: [
          ErrorBanner(
            message: errors.isEmpty ? null : rcxIssueText(l, errors.first),
          ),
          if (sourceChanged)
            generateSection(
              title: l.rcxSourceChanged,
              items: [
                DecorationListItem(
                  title: Text(l.rcxBringChanges),
                  subtitle: Text(l.rcxBringChangesHint),
                  onPressed: _bringOver,
                  trailing: const GlyphIcon(AppGlyphs.sync),
                ),
                DecorationListItem(
                  title: Text(l.rcxSourceChanges),
                  onPressed: _showChanges,
                  trailing: const GlyphIcon(AppGlyphs.chevronForward),
                ),
              ],
            ),
          if (lint?.profile != null) ..._sections(context),
          if (lint?.profile != null) _checkSection(lint!),
          if (lint != null && lint.warnings.isNotEmpty)
            generateSection(
              title: l.rcxWarnings,
              items: [
                for (final warning in lint.warnings)
                  DecorationListItem(title: Text(rcxIssueText(l, warning))),
              ],
            ),
          if (lint != null && lint.endpoints.isNotEmpty)
            _endpointsSection(l, lint.endpoints),
        ],
      ),
    );
  }

  List<Widget> _sections(BuildContext context) {
    final l = context.appLocalizations;
    final p = _profile;
    final pool = rcxMap(p['pool']);
    final tags = rcxMap(p['tags']);
    final tiers = rcxList(p['prefer']);
    final switching = rcxMap(p['switch']);
    return [
      generateSection(
        title: l.rcxGeneral,
        items: [
          FormRow(
            title: l.rcxProfileName,
            trailing: FormRowTextField(
              controller: _title,
              hintText: l.rcxNewProfile,
              onChanged: _onTitleChanged,
            ),
          ),
          _options(
            title: l.rcxLevel,
            options: const ['simple', 'advanced'],
            value: p['level'] as String? ?? 'simple',
            label: (v) => rcxLevelLabel(l, v),
            onChanged: (v) => _edit((p) => p['level'] = v),
          ),
          _baseRow(l),
        ],
      ),
      generateSection(
        title: l.rcxServers,
        items: [
          _conditionRow(
            title: l.rcxPoolInclude,
            value: pool['include'] as String? ?? '',
            empty: l.rcxCondAnyServer,
            onChanged: (text) => _edit(
              (p) => p['pool'] = {...rcxMap(p['pool']), 'include': text},
            ),
          ),
          _conditionRow(
            title: l.rcxPoolExclude,
            value: pool['exclude'] as String? ?? '',
            empty: l.none,
            onChanged: (text) => _edit(
              (p) => p['pool'] = {...rcxMap(p['pool']), 'exclude': text},
            ),
          ),
        ],
      ),
      generateSection(
        title: l.rcxTiers,
        footer: l.rcxTiersHint,
        items: [
          for (final (index, tier) in tiers.indexed)
            _tierRow(index, rcxMap(tier), tiers.length),
          FormRow(
            title: l.rcxAddTier,
            leading: EntryButton.add(onPressed: () => _editTier(null)),
            onPressed: () => _editTier(null),
          ),
        ],
      ),
      generateSection(
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
                  onPressed: () => _edit(
                    (p) => p['tags'] = {...rcxMap(p['tags'])}..remove(key),
                  ),
                ),
              ],
              child: _conditionRow(
                title: key,
                value: '$value',
                empty: '',
                onChanged: (text) =>
                    _edit((p) => p['tags'] = {...rcxMap(p['tags']), key: text}),
              ),
            ),
          FormRow(
            title: l.rcxAddTag,
            leading: EntryButton.add(onPressed: _addTag),
            onPressed: _addTag,
          ),
        ],
      ),
      generateSection(
        title: l.rcxBehaviour,
        items: [
          _options(
            title: l.rcxSwitching,
            options: rcxFeels,
            value: switching['feel'] as String? ?? 'balanced',
            label: (v) => rcxFeelLabel(l, v),
            onChanged: (v) =>
                _edit((p) => p['switch'] = {...rcxMap(p['switch']), 'feel': v}),
          ),
          _options(
            title: l.rcxChecks,
            options: rcxEnergies,
            value: p['energy'] as String? ?? 'balanced',
            label: (v) => rcxEnergyLabel(l, v),
            onChanged: (v) => _edit((p) => p['energy'] = v),
          ),
          _options(
            title: l.rcxStranded,
            options: _strandings,
            value: p['stranded'] as String? ?? 'hold',
            label: (v) => _strandedLabel(l, v),
            onChanged: (v) => _edit((p) => p['stranded'] = v),
          ),
        ],
      ),
      if (_advancedRows(l) case final rows when rows.isNotEmpty)
        generateSection(
          title: l.rcxAdvanced,
          footer: l.rcxAdvancedHint,
          items: rows,
        ),
    ];
  }

  List<Widget> _advancedRows(AppLocalizations l) {
    final p = _profile;
    final checks = rcxMap(p['checks']);
    final network = rcxMap(p['network']);
    final kinds = [
      for (final kind in rcxList(network['kinds']))
        rcxMap(kind)['kind'] as String,
    ];
    final overrides = rcxMap(p['on']);
    final languages = rcxMap(p['l10n']);
    final rows = <(String, String)>[
      if (checks.isNotEmpty) (l.rcxChecksDeclared, checks.keys.join(', ')),
      if (kinds.isNotEmpty)
        (l.rcxNetworkKinds, kinds.map((k) => rcxKindLabel(l, k)).join(', ')),
      if (overrides.isNotEmpty)
        (
          l.rcxOverrides,
          overrides.keys.map((k) => rcxKindLabel(l, k)).join(', '),
        ),
      if ((p['direct-split'] as String? ?? '').isNotEmpty)
        (l.rcxDirectSplit, p['direct-split'] as String),
      if (rcxMap(p['egress-verify']).isNotEmpty)
        (
          l.rcxExitCheck,
          rcxList(rcxMap(p['egress-verify'])['echo']).join(', '),
        ),
      if (languages.isNotEmpty) (l.rcxTranslations, languages.keys.join(', ')),
    ];
    return [
      for (final (title, value) in rows)
        DecorationListItem(
          title: Text(title),
          subtitle: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
          onPressed: _editYaml,
          trailing: const GlyphIcon(AppGlyphs.code),
        ),
    ];
  }

  Widget _tierRow(int index, Map<String, Object?> tier, int count) {
    final l = context.appLocalizations;
    final when = tier['when'] as String? ?? '';
    final lastResort = tier['last-resort'] == true;
    void move(int to) => _edit((p) {
      final tiers = [...rcxList(p['prefer'])];
      tiers.insert(to, tiers.removeAt(index));
      p['prefer'] = tiers;
    });
    return ContextMenuRegion(
      menuItems: [
        if (index > 0)
          CommonPopupMenuItem(
            glyph: AppGlyphs.arrowUp,
            label: l.rcxMoveUp,
            onPressed: () => move(index - 1),
          ),
        if (index < count - 1)
          CommonPopupMenuItem(
            glyph: AppGlyphs.arrowDown,
            label: l.rcxMoveDown,
            onPressed: () => move(index + 1),
          ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.delete,
          label: l.delete,
          danger: true,
          onPressed: () => _edit(
            (p) => p['prefer'] = [...rcxList(p['prefer'])]..removeAt(index),
          ),
        ),
      ],
      child: DecorationListItem(
        leading: Text(
          '${index + 1}',
          style: context.listTitleStyle.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        title: EmojiText(tier['label'] as String? ?? ''),
        subtitle: Text(
          [
            if (when.isEmpty) l.rcxCondAnyServer else when,
            if (lastResort) l.rcxLastResort,
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () => _editTier(index),
        trailing: const GlyphIcon(AppGlyphs.chevronForward),
      ),
    );
  }

  Future<void> _editTier(int? index) async {
    final tiers = rcxList(_profile['prefer']);
    final tier = await BaseNavigator.push<Map<String, Object?>>(
      context,
      _TierEditor(
        tier: index == null ? null : rcxMap(tiers[index]),
        profile: _profile,
      ),
    );
    if (tier == null) return;
    await _edit((p) {
      final next = [...rcxList(p['prefer'])];
      if (index == null) {
        next.add(tier);
      } else {
        next[index] = tier;
      }
      p['prefer'] = next;
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
          return rcxMap(_profile['tags']).containsKey(text)
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
      profile: _profile,
    );
    if (text == null || text.isEmpty) return;
    await _edit((p) => p['tags'] = {...rcxMap(p['tags']), tag: text});
  }

  Widget _baseRow(AppLocalizations l) {
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final current = _profile['extends'] as String? ?? '';
    final ids = [
      '',
      for (final info in library)
        if (!info.isScenario && info.id != _id && info.error.isEmpty) info.id,
      if (current.isNotEmpty && !library.any((i) => i.id == current)) current,
    ];
    return _options(
      title: l.rcxBasedOn,
      options: ids,
      value: current,
      label: (id) => id.isEmpty
          ? l.none
          : library
                    .where((i) => i.id == id)
                    .firstOrNull
                    ?.displayTitle(locale) ??
                id,
      onChanged: (id) => _edit((p) => p['extends'] = id),
    );
  }

  Widget _options({
    required String title,
    required List<String> options,
    required String value,
    required String Function(String) label,
    required ValueChanged<String> onChanged,
  }) {
    return ListItem<String>.options(
      title: Text(title),
      options: options,
      value: options.contains(value) ? value : options.first,
      textBuilder: label,
      onChanged: (v) {
        if (v != value) onChanged(v);
      },
    );
  }

  Widget _conditionRow({
    required String title,
    required String value,
    required String empty,
    required ValueChanged<String> onChanged,
  }) {
    return DecorationListItem(
      title: EmojiText(title),
      subtitle: Text(
        value.isEmpty ? empty : value,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () async {
        final text = await editCondition(
          context,
          title: title,
          text: value,
          profile: _profile,
        );
        if (text != null && text != value) onChanged(text);
      },
      trailing: const GlyphIcon(AppGlyphs.chevronForward),
    );
  }

  /// What the draft would pick in a smart group now, against what the group
  /// runs; the group is chosen here.
  Widget _checkSection(RcxStudioResult lint) {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final info = lint.info;
    final groups = ref.watch(
      rcxStatusStateProvider.select(
        (status) => [for (final g in status?.groups ?? const []) g.name],
      ),
    );
    if (groups.isEmpty) return const SizedBox.shrink();
    final candidate = lint.candidate;
    final pick = candidate == null ? null : rcxBestOf(candidate);
    String tier(String label) => info?.localize(label, locale) ?? label;
    return generateSection(
      title: l.rcxCheck,
      items: [
        ListItem<String>.options(
          title: Text(l.rcxCheckGroup),
          options: ['', ...groups],
          value: groups.contains(_group) ? _group! : '',
          textBuilder: (name) => name.isEmpty ? l.none : name,
          onChanged: (name) {
            setState(() => _group = name.isEmpty ? null : name);
            unawaited(_check());
          },
        ),
        if (candidate != null) ...[
          DecorationListItem(title: EmojiText(rcxCheckHeadline(l, lint))),
          for (final row in candidate.ranking.take(_checkRows))
            DecorationListItem(
              isSelected: row.name == pick,
              title: EmojiText(row.name, maxLines: 1),
              subtitle: Text(
                row.excluded != null
                    ? rcxReasonText(l, row.excluded!)
                    : [
                        if (row.tierLabel.isNotEmpty) tier(row.tierLabel),
                        if (row.pending.isNotEmpty)
                          l.rcxPendingTier(tier(row.pending)),
                      ].join(' · '),
              ),
              trailing: row.latencyMs > 0 ? Text('${row.latencyMs} ms') : null,
            ),
        ],
      ],
    );
  }

  Widget _endpointsSection(AppLocalizations l, List<RcxEndpoint> endpoints) {
    return generateSection(
      title: l.rcxContacts,
      footer: l.rcxContactsHint,
      items: [
        for (final endpoint in endpoints)
          DecorationListItem(
            title: Text(endpoint.host),
            subtitle: Text(
              [
                rcxEndpointUse(l, endpoint.use),
                if (endpoint.thirdParty) l.rcxThirdParty,
              ].join(' · '),
            ),
          ),
      ],
    );
  }
}

class _TierEditor extends StatefulWidget {
  const _TierEditor({required this.tier, required this.profile});

  final Map<String, Object?>? tier;
  final Map<String, Object?> profile;

  @override
  State<_TierEditor> createState() => _TierEditorState();
}

class _TierEditorState extends State<_TierEditor> {
  late final _label = TextEditingController(
    text: widget.tier?['label'] as String? ?? '',
  );
  late String _when = widget.tier?['when'] as String? ?? 'not dead';
  late bool _lastResort = widget.tier?['last-resort'] == true;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _editWhen() async {
    final text = await editCondition(
      context,
      title: _label.text.isEmpty
          ? context.appLocalizations.rcxTier
          : _label.text,
      text: _when,
      profile: widget.profile,
    );
    if (text != null && mounted) setState(() => _when = text);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final label = _label.text.trim();
    return FormPage(
      title: widget.tier == null ? l.rcxAddTier : l.rcxTier,
      onSave: label.isEmpty
          ? null
          : () => Navigator.of(context).pop(<String, Object?>{
              'label': label,
              'when': _when,
              if (_lastResort) 'last-resort': true,
            }),
      children: [
        generateSection(
          items: [
            FormRow(
              title: l.rcxTierLabel,
              trailing: FormRowTextField(
                controller: _label,
                hintText: l.required,
                onChanged: (_) => setState(() {}),
              ),
            ),
            DecorationListItem(
              title: Text(l.rcxTierWhen),
              subtitle: Text(_when.isEmpty ? l.rcxCondAnyServer : _when),
              onPressed: _editWhen,
              trailing: const GlyphIcon(AppGlyphs.chevronForward),
            ),
            FormRow(
              title: l.rcxLastResort,
              onPressed: () => setState(() => _lastResort = !_lastResort),
              trailing: Switch(
                value: _lastResort,
                onChanged: (value) => setState(() => _lastResort = value),
              ),
            ),
          ],
          footer: l.rcxLastResortHint,
        ),
      ],
    );
  }
}

/// A line diff of two documents, removed lines then added ones in place.
class _DiffPage extends StatelessWidget {
  const _DiffPage({
    required this.title,
    required this.before,
    required this.after,
  });

  final String title;
  final String before;
  final String after;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = AppTextStyle.footnote
        .of(context)
        .copyWith(fontFamily: FontFamily.jetBrainsMono.value);
    final lines = rcxLineDiff(before, after);
    return CommonScaffold(
      title: title,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 20),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final (mark, text) = lines[index];
          return ColoredBox(
            color: switch (mark) {
              '+' => colorScheme.primaryContainer,
              '-' => colorScheme.errorContainer,
              _ => Colors.transparent,
            },
            child: Text('$mark $text', style: style),
          );
        },
      ),
    );
  }
}

/// Lines of [after] against [before], each marked ' ', '-' or '+'. Profiles
/// are small, so the quadratic table is cheap.
List<(String, String)> rcxLineDiff(String before, String after) {
  final a = before.split('\n');
  final b = after.split('\n');
  final table = List.generate(
    a.length + 1,
    (_) => List.filled(b.length + 1, 0),
  );
  for (var i = a.length - 1; i >= 0; i--) {
    for (var j = b.length - 1; j >= 0; j--) {
      table[i][j] = a[i] == b[j]
          ? table[i + 1][j + 1] + 1
          : table[i + 1][j] > table[i][j + 1]
          ? table[i + 1][j]
          : table[i][j + 1];
    }
  }
  final out = <(String, String)>[];
  var i = 0, j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      out.add((' ', a[i]));
      i++;
      j++;
    } else if (table[i + 1][j] >= table[i][j + 1]) {
      out.add(('-', a[i++]));
    } else {
      out.add(('+', b[j++]));
    }
  }
  return [
    ...out,
    for (; i < a.length; i++) ('-', a[i]),
    for (; j < b.length; j++) ('+', b[j]),
  ];
}

String? rcxBestOf(RcxDecision decision) {
  for (final row in decision.ranking) {
    if (row.excluded == null) return row.name;
  }
  return null;
}

/// What the draft would pick in the group, against what runs there now.
String rcxCheckHeadline(AppLocalizations l, RcxStudioResult lint) {
  final now = rcxBestOf(lint.current ?? const RcxDecision());
  return switch (rcxBestOf(lint.candidate ?? const RcxDecision())) {
    null => l.rcxCheckNone,
    final pick when pick == now => l.rcxCheckSame(pick),
    final pick => l.rcxCheckDifferent(pick, now ?? '—'),
  };
}

/// A free name for a profile titled [title] among [taken].
String rcxFreeProfileName(Map<String, Object?> taken, String title) {
  final slug = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final base = slug.isEmpty ? 'profile' : slug;
  var name = base;
  for (var i = 2; taken.containsKey(name); i++) {
    name = '$base-$i';
  }
  return name;
}

String _strandedLabel(AppLocalizations l, String value) => switch (value) {
  'hold' => l.rcxStrandedHold,
  'direct' => l.rcxStrandedDirect,
  _ => value,
};

String rcxEndpointUse(AppLocalizations l, String use) {
  final (kind, name) = switch (use.split(':')) {
    [final kind, final name] => (kind, name),
    _ => (use, ''),
  };
  return switch (kind) {
    'check' => l.rcxUseCheck(name),
    'diagnostic' => l.rcxUseDiagnostic(name),
    'echo' => l.rcxUseEcho,
    _ => use,
  };
}

/// A lint finding in the user's language when the Core gave it a code, with
/// the line it is on.
String rcxIssueText(AppLocalizations l, RcxIssue issue) {
  String arg(String key) => '${issue.args[key] ?? ''}';
  final text = switch (issue.code) {
    'tag.unused' => l.rcxLintTagUnused(arg('tag')),
    'check.unused' => l.rcxLintCheckUnused(arg('check')),
    'tier.unreachable' => l.rcxLintTierUnreachable(arg('tier'), arg('after')),
    'pool.empty' => l.rcxLintPoolEmpty(arg('group')),
    'tier.empty' => l.rcxLintTierEmpty(arg('tier'), arg('group')),
    'group.missing' => l.rcxLintGroupMissing(arg('group')),
    'profile.consent' => l.rcxLintConsent(
      (issue.args['hosts'] as List? ?? const []).join(', '),
    ),
    _ => issue.message,
  };
  return issue.line > 0 ? l.rcxLine(issue.line, text) : text;
}

Map<String, Object?> rcxMap(Object? value) =>
    value is Map ? Map<String, Object?>.from(value) : <String, Object?>{};

List<Object?> rcxList(Object? value) =>
    value is List ? List<Object?>.from(value) : const [];

bool rcxIsEmpty(Object? value) => switch (value) {
  null => true,
  String() => value.isEmpty,
  Map() => value.values.every(rcxIsEmpty),
  List() => value.isEmpty,
  _ => false,
};

Map<String, Object?> rcxDeepCopy(Map<String, Object?> source) => {
  for (final MapEntry(:key, :value) in source.entries)
    key: switch (value) {
      Map() => rcxDeepCopy(Map<String, Object?>.from(value)),
      List() => [
        for (final item in value)
          item is Map ? rcxDeepCopy(Map<String, Object?>.from(item)) : item,
      ],
      _ => value,
    },
};
