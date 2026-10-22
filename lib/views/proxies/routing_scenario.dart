import 'dart:async';

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
import 'routing_import.dart';
import 'routing_studio.dart';

const _titleDelay = Duration(milliseconds: 500);
const _modes = ['', 'rule', 'global', 'direct'];

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

/// The connection-wide auto control: the tunnel mode and what each group
/// does, on every network and on each network kind it recognizes.
class ScenarioEditor extends ConsumerStatefulWidget {
  const ScenarioEditor({super.key, this.name, this.text, this.from = ''});

  final String? name;
  final String? text;
  final String from;

  @override
  ConsumerState<ScenarioEditor> createState() => _ScenarioEditorState();
}

class _ScenarioEditorState extends ConsumerState<ScenarioEditor> {
  late RcxUserProfile _saved;
  late String _text;
  final _title = TextEditingController();
  Timer? _titleDebounce;
  RcxStudioResult? _lint;
  Map<String, Object?> _scenario = const {};
  bool _saving = false;
  int _request = 0;

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
          text: widget.text ?? _blankScenario,
          kind: 'scenario',
          from: widget.from,
          base: widget.from.isEmpty ? '' : widget.text ?? '',
        );
    _text = _saved.text;
    unawaited(_check());
  }

  @override
  void dispose() {
    _titleDebounce?.cancel();
    _title.dispose();
    super.dispose();
  }

  bool get _dirty => widget.name == null || _text != _saved.text;

  Future<void> _check() async {
    final id = ++_request;
    final result = await _action.studio({
      'op': 'lint',
      'kind': 'scenario',
      'text': _text,
      'id': _id,
    });
    if (!mounted || id != _request || result == null) return;
    setState(() {
      _lint = result;
      if (result.scenario case final scenario?) {
        _scenario = scenario;
        final title = scenario['title'] as String? ?? '';
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

  /// Section edits rewrite the document from its parsed form. An empty
  /// program stays: `'*': {}` means "every group, as it is".
  Future<void> _edit(
    void Function(Map<String, Object?> scenario) update,
  ) async {
    final scenario = rcxDeepCopy(_scenario);
    update(scenario);
    scenario.removeWhere(
      (_, value) =>
          value == null ||
          value == '' ||
          value is Iterable && value.isEmpty ||
          value is Map && value.isEmpty,
    );
    final result = await _action.studio({
      'op': 'format',
      'kind': 'scenario',
      'scenario': scenario,
    });
    if (!mounted || result == null) return;
    _setText(result.text);
  }

  void _onTitleChanged(String title) {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(_titleDelay, () {
      unawaited(_edit((s) => s['title'] = title.trim()));
    });
  }

  Future<void> _editYaml() async {
    final text = await BaseNavigator.push<String>(
      context,
      EditorPage(
        title: context.appLocalizations.rcxYaml,
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
            _scenario['title'] as String? ?? '',
          );
      await _action.saveProfile(
        name,
        _saved.copyWith(text: _text, kind: 'scenario'),
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

  String _titleOf(BuildContext context) {
    final title = _scenario['title'] as String? ?? '';
    return title.isEmpty ? context.appLocalizations.rcxNewScenario : title;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final lint = _lint;
    final errors = lint?.errors ?? const <RcxIssue>[];
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
          if (lint?.scenario != null) ..._sections(l),
          if (lint != null && lint.warnings.isNotEmpty)
            generateSection(
              title: l.rcxWarnings,
              items: [
                for (final warning in lint.warnings)
                  DecorationListItem(title: Text(rcxIssueText(l, warning))),
              ],
            ),
          if (lint != null && lint.endpoints.isNotEmpty)
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
        ],
      ),
    );
  }

  List<Widget> _sections(AppLocalizations l) {
    final s = _scenario;
    final network = rcxMap(s['network']);
    final kinds = [for (final kind in rcxList(network['kinds'])) rcxMap(kind)];
    final overrides = rcxMap(s['on']);
    final tags = rcxMap(s['tags']);
    return [
      generateSection(
        title: l.rcxGeneral,
        items: [
          FormRow(
            title: l.rcxProfileName,
            trailing: FormRowTextField(
              controller: _title,
              hintText: l.rcxNewScenario,
              onChanged: _onTitleChanged,
            ),
          ),
          _modeRow(
            l,
            s['mode'] as String? ?? '',
            (mode) => _edit((s) => s['mode'] = mode),
          ),
        ],
      ),
      ProgramsSection(
        title: l.rcxScenarioGroups,
        footer: l.rcxScenarioGroupsHint,
        programs: rcxMap(s['groups']),
        tags: tags,
        onChanged: (programs) => _edit((s) => s['groups'] = programs),
      ),
      generateSection(
        title: l.rcxNetworkKinds,
        footer: l.rcxScenarioKindsHint,
        items: [
          for (final (index, kind) in kinds.indexed)
            _kindRow(l, index, kind, rcxMap(overrides[kind['kind']])),
          FormRow(
            title: l.rcxAddKind,
            leading: EntryButton.add(onPressed: _addKind),
            onPressed: _addKind,
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
                    (s) => s['tags'] = {...rcxMap(s['tags'])}..remove(key),
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
                    await _edit(
                      (s) => s['tags'] = {...rcxMap(s['tags']), key: text},
                    );
                  }
                },
                trailing: const GlyphIcon(AppGlyphs.chevronForward),
              ),
            ),
          FormRow(
            title: l.rcxAddTag,
            leading: EntryButton.add(onPressed: _addTag),
            onPressed: _addTag,
          ),
        ],
      ),
      if (rcxMap(network['diagnose']).isNotEmpty ||
          rcxMap(s['l10n']).isNotEmpty)
        generateSection(
          title: l.rcxAdvanced,
          footer: l.rcxAdvancedHint,
          items: [
            if (rcxMap(network['diagnose']) case final diag
                when diag.isNotEmpty)
              DecorationListItem(
                title: Text(l.rcxDiagnostics),
                subtitle: Text(diag.keys.join(', ')),
                onPressed: _editYaml,
                trailing: const GlyphIcon(AppGlyphs.code),
              ),
            if (rcxMap(s['l10n']) case final languages
                when languages.isNotEmpty)
              DecorationListItem(
                title: Text(l.rcxTranslations),
                subtitle: Text(languages.keys.join(', ')),
                onPressed: _editYaml,
                trailing: const GlyphIcon(AppGlyphs.code),
              ),
          ],
        ),
    ];
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
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.delete,
          label: l.delete,
          danger: true,
          onPressed: () => _edit((s) {
            final network = rcxMap(s['network']);
            network['kinds'] = [...rcxList(network['kinds'])]..removeAt(index);
            s['network'] = network;
            s['on'] = {...rcxMap(s['on'])}..remove(name);
          }),
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
        onPressed: () => _editKind(index),
        trailing: const GlyphIcon(AppGlyphs.chevronForward),
      ),
    );
  }

  Future<void> _addKind() async {
    final l = context.appLocalizations;
    final taken = {
      for (final kind in rcxList(rcxMap(_scenario['network'])['kinds']))
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
    await _edit((s) {
      final network = rcxMap(s['network']);
      network['kinds'] = [
        ...rcxList(network['kinds']),
        {'kind': kind, 'when': ''},
      ];
      s['network'] = network;
    });
    final index = rcxList(rcxMap(_scenario['network'])['kinds']).length - 1;
    if (mounted && index >= 0) await _editKind(index);
  }

  Future<void> _editKind(int index) async {
    final kinds = rcxList(rcxMap(_scenario['network'])['kinds']);
    if (index >= kinds.length) return;
    final kind = rcxMap(kinds[index]);
    final name = kind['kind'] as String? ?? '';
    final result = await BaseNavigator.push<_KindEdit>(
      context,
      _KindEditor(
        kind: kind,
        layer: rcxMap(rcxMap(_scenario['on'])[name]),
        scenario: _scenario,
      ),
    );
    if (result == null) return;
    await _edit((s) {
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
          return rcxMap(_scenario['tags']).containsKey(text)
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
    await _edit((s) => s['tags'] = {...rcxMap(s['tags']), tag: text});
  }
}

Widget _modeRow(
  AppLocalizations l,
  String mode,
  ValueChanged<String> onChanged,
) {
  return ListItem<String>.options(
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
  });

  final Map<String, Object?> kind;
  final Map<String, Object?> layer;
  final Map<String, Object?> scenario;

  @override
  State<_KindEditor> createState() => _KindEditorState();
}

class _KindEditorState extends State<_KindEditor> {
  late Map<String, Object?> _kind = {...widget.kind};
  late Map<String, Object?> _layer = {...widget.layer};

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

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final when = _kind['when'] as String? ?? '';
    return FormPage(
      title: rcxKindLabel(l, _kind['kind'] as String? ?? ''),
      onSave: () {
        final layer = {..._layer}
          ..removeWhere(
            (_, value) =>
                value == null || value == '' || value is Map && value.isEmpty,
          );
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
              trailing: const GlyphIcon(AppGlyphs.chevronForward),
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
        ProgramsSection(
          title: l.rcxScenarioGroups,
          footer: l.rcxKindGroupsHint,
          programs: rcxMap(_layer['groups']),
          tags: rcxMap(widget.scenario['tags']),
          onChanged: (programs) =>
              setState(() => _layer = {..._layer, 'groups': programs}),
        ),
      ],
    );
  }
}

/// The groups a scenario names and what it does with each; a group is
/// added from the config's select groups or as the main group or every
/// group.
class ProgramsSection extends ConsumerWidget {
  const ProgramsSection({
    super.key,
    required this.title,
    required this.programs,
    required this.tags,
    required this.onChanged,
    this.footer,
  });

  final String title;
  final String? footer;
  final Map<String, Object?> programs;
  final Map<String, Object?> tags;
  final ValueChanged<Map<String, Object?>> onChanged;

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
      for (final target in [r'$main', '*', 'GLOBAL', ...groups])
        if (!programs.containsKey(target)) target,
    ];
    Future<void> edit(String target) async {
      final program = await BaseNavigator.push<Map<String, Object?>>(
        context,
        _ProgramEditor(
          target: target,
          program: rcxMap(programs[target]),
          tags: tags,
        ),
      );
      if (program != null) onChanged({...programs, target: program});
    }

    return generateSection(
      title: title,
      footer: footer,
      items: [
        for (final MapEntry(:key, :value) in programs.entries)
          ContextMenuRegion(
            menuItems: [
              CommonPopupMenuItem(
                glyph: AppGlyphs.delete,
                label: l.delete,
                danger: true,
                onPressed: () => onChanged({...programs}..remove(key)),
              ),
            ],
            child: DecorationListItem(
              title: EmojiText(rcxProgramLabel(l, key)),
              subtitle: Text(
                _programSummary(context, ref, rcxMap(value)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => edit(key),
              trailing: const GlyphIcon(AppGlyphs.chevronForward),
            ),
          ),
        if (targets.isNotEmpty)
          CommonPopupBox(
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
                    onPressed: () => unawaited(edit(target)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

String _programSummary(
  BuildContext context,
  WidgetRef ref,
  Map<String, Object?> program,
) {
  final l = context.appLocalizations;
  final to = program['to'] as String? ?? '';
  if (to.isNotEmpty) return l.rcxFixedOn(to);
  final profile = program['profile'] as String? ?? '';
  final pool = rcxMap(program['pool']);
  return [
    profile.isEmpty ? l.rcxOwnProfile : rcxProfileTitle(context, ref, profile),
    if ((pool['include'] as String? ?? '').isNotEmpty) pool['include'],
    if ((pool['exclude'] as String? ?? '').isNotEmpty)
      l.rcxExcept(pool['exclude'] as String),
  ].join(' · ');
}

/// What a scenario does with one group: run a profile over a pool, or hand
/// the whole group to one member such as a balancer.
class _ProgramEditor extends ConsumerStatefulWidget {
  const _ProgramEditor({
    required this.target,
    required this.program,
    required this.tags,
  });

  final String target;
  final Map<String, Object?> program;
  final Map<String, Object?> tags;

  @override
  ConsumerState<_ProgramEditor> createState() => _ProgramEditorState();
}

class _ProgramEditorState extends ConsumerState<_ProgramEditor> {
  late Map<String, Object?> _program = {...widget.program};
  late bool _fixed = (widget.program['to'] as String? ?? '').isNotEmpty;

  Map<String, Object?> get _pool => rcxMap(_program['pool']);

  /// The group the target names in this config, for its member list.
  String? _groupName() {
    final target = widget.target;
    if (target == '*') return null;
    if (target != r'$main') return target;
    final scenario = ref.read(rcxStatusStateProvider)?.scenario;
    return scenario?.groups.entries
        .where((entry) => entry.value == r'$main')
        .firstOrNull
        ?.key;
  }

  Future<void> _editPool(String key, String title) async {
    final text = await editCondition(
      context,
      title: title,
      text: _pool[key] as String? ?? '',
      profile: {'tags': widget.tags},
    );
    if (text == null || !mounted) return;
    setState(
      () => _program = {
        ..._program,
        'pool': {..._pool, key: text},
      },
    );
  }

  Map<String, Object?> get _result {
    if (_fixed) return {'to': _program['to']};
    final pool = {..._pool}..removeWhere((_, value) => value == '');
    return {
      if ((_program['profile'] as String? ?? '').isNotEmpty)
        'profile': _program['profile'],
      if (pool.isNotEmpty) 'pool': pool,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final groupName = _groupName();
    final members = ref.watch(
      groupsProvider.select(
        (groups) => [
          for (final proxy
              in groups.getGroup(groupName ?? '')?.all ?? const <Proxy>[])
            proxy.name,
        ],
      ),
    );
    final to = _program['to'] as String? ?? '';
    final profile = _program['profile'] as String? ?? '';
    final profiles = [
      '',
      for (final info in library)
        if (!info.isScenario && info.error.isEmpty) info.id,
    ];
    return FormPage(
      title: rcxProgramLabel(l, widget.target),
      onSave: _fixed && to.isEmpty
          ? null
          : () => Navigator.of(context).pop(_result),
      children: [
        generateSection(
          footer: _fixed ? l.rcxFixedHint : l.rcxProfileProgramHint,
          items: [
            if (widget.target != '*')
              ListItem<bool>.options(
                title: Text(l.rcxProgramAction),
                options: const [false, true],
                value: _fixed,
                textBuilder: (fixed) =>
                    fixed ? l.rcxProgramFixed : l.rcxProgramPick,
                onChanged: (fixed) => setState(() => _fixed = fixed),
              ),
            if (_fixed)
              if (members.isEmpty)
                FormRow(
                  title: l.rcxProgramMember,
                  trailing: FormRowTextField(
                    initialValue: to,
                    hintText: l.required,
                    autocorrect: false,
                    onChanged: (value) => setState(
                      () => _program = {..._program, 'to': value.trim()},
                    ),
                  ),
                )
              else
                ListItem<String>.options(
                  title: Text(l.rcxProgramMember),
                  options: [if (!members.contains(to)) to, ...members],
                  value: to,
                  textBuilder: (name) => name.isEmpty ? l.none : name,
                  onChanged: (name) =>
                      setState(() => _program = {..._program, 'to': name}),
                )
            else ...[
              ListItem<String>.options(
                title: Text(l.rcxProfile),
                options: [
                  if (!profiles.contains(profile)) profile,
                  ...profiles,
                ],
                value: profile,
                textBuilder: (id) => id.isEmpty
                    ? l.rcxOwnProfile
                    : library
                              .where((i) => i.id == id)
                              .firstOrNull
                              ?.displayTitle(locale) ??
                          id,
                onChanged: (id) =>
                    setState(() => _program = {..._program, 'profile': id}),
              ),
              DecorationListItem(
                title: Text(l.rcxPoolInclude),
                subtitle: Text(
                  (_pool['include'] as String? ?? '').isEmpty
                      ? l.rcxCondAnyServer
                      : _pool['include'] as String,
                ),
                onPressed: () => _editPool('include', l.rcxPoolInclude),
                trailing: const GlyphIcon(AppGlyphs.chevronForward),
              ),
              DecorationListItem(
                title: Text(l.rcxPoolExclude),
                subtitle: Text(
                  (_pool['exclude'] as String? ?? '').isEmpty
                      ? l.none
                      : _pool['exclude'] as String,
                ),
                onPressed: () => _editPool('exclude', l.rcxPoolExclude),
                trailing: const GlyphIcon(AppGlyphs.chevronForward),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
