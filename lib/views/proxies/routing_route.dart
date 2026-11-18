import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'routing.dart';
import 'routing_choice.dart';
import 'routing_ladder.dart';
import 'routing_match.dart';
import 'routing_studio.dart';

const _routeProfile = 'builtin/simple';
const _maxNameBytes = 64;
const _reserved = {r'$main', '*', 'GLOBAL', 'DIRECT', 'REJECT'};

/// Lints the edited value inside its scenario: problems by the key path
/// under the value ('name', 'match.0', 'to', …), and '' for the rest.
typedef RouteValidator =
    Future<Map<String, String>> Function(Map<String, Object?> value);

enum _Send { auto, direct, fixed }

/// Edits one route of [scenario], or with [target] the program the scenario
/// gives that group ($main, `*`, GLOBAL or a group by name). Null when the
/// user backs out; an empty map when [deletable] and the user deletes it.
Future<Map<String, Object?>?> editRoute(
  BuildContext context, {
  required Map<String, Object?> value,
  required Map<String, Object?> scenario,
  String? target,
  Set<String> taken = const {},
  RouteValidator? validate,
  bool deletable = false,
}) {
  return BaseNavigator.push<Map<String, Object?>>(
    context,
    RouteEditor(
      value: value,
      scenario: scenario,
      target: target,
      taken: taken,
      validate: validate,
      deletable: deletable,
    ),
  );
}

/// The group a program target runs as in this config, for live counts and
/// members; null for `*`, or when the config has no such group yet.
String? rcxTargetGroup(WidgetRef ref, String target) {
  if (target == '*') return null;
  if (target != r'$main') return target;
  final scenario = ref.read(rcxStatusStateProvider)?.scenario;
  return scenario?.groups.entries
      .where((entry) => entry.value == r'$main')
      .firstOrNull
      ?.key;
}

/// A route's destination or a program in a few words: "1 ⚡ RU → 2 Any",
/// "Direct", "Through US-balancer".
String rcxProgramSummary(
  AppLocalizations l,
  Map<String, Object?> value, {
  String Function(String id)? profileTitle,
}) {
  final to = value['to'] as String? ?? '';
  if (to == 'DIRECT') return l.direct;
  if (to.isNotEmpty) return l.rcxFixedOn(to);
  final steps = [for (final step in rcxList(value['prefer'])) rcxMap(step)];
  final profile = value['profile'] as String? ?? '';
  final exclude = rcxMap(value['pool'])['exclude'] as String? ?? '';
  return [
    if (steps.isEmpty) l.rcxCondAnyServer else _stepsSummary(l, steps),
    if (profile.isNotEmpty && profileTitle != null) profileTitle(profile),
    if (exclude.isNotEmpty) l.rcxExcept(rcxConditionSummary(l, exclude)),
  ].join(' · ');
}

String _stepsSummary(AppLocalizations l, List<Map<String, Object?>> steps) => [
  for (final (index, step) in steps.indexed)
    steps.length == 1
        ? rcxStepSummary(l, step)
        : '${index + 1} ${rcxStepSummary(l, step)}',
].join(' → ');

/// A page that rebuilds from its opener's state on each [revision], for a
/// part of an editor the opener still owns.
class RoutingLivePage extends StatelessWidget {
  const RoutingLivePage({
    super.key,
    required this.title,
    required this.revision,
    required this.builder,
  });

  final String title;
  final ValueListenable<int> revision;
  final List<Widget> Function(AppLocalizations l) builder;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      body: ValueListenableBuilder<int>(
        valueListenable: revision,
        builder: (context, _, _) => ListView(
          padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: context.sectionsTopPadding, bottom: 20) +
              context.bodyInsets,
          children: builder(context.appLocalizations),
        ),
      ),
    );
  }
}

class RouteEditor extends ConsumerStatefulWidget {
  const RouteEditor({
    super.key,
    required this.value,
    required this.scenario,
    this.target,
    this.taken = const {},
    this.validate,
    this.deletable = false,
  });

  final Map<String, Object?> value;
  final Map<String, Object?> scenario;
  final String? target;
  final Set<String> taken;
  final RouteValidator? validate;
  final bool deletable;

  @override
  ConsumerState<RouteEditor> createState() => _RouteEditorState();
}

class _RouteEditorState extends ConsumerState<RouteEditor> {
  late Map<String, Object?> _value = rcxDeepCopy(widget.value);
  late final _name = TextEditingController(
    text: widget.value['name'] as String? ?? '',
  );
  late _Send _send = switch (widget.value['to'] as String? ?? '') {
    '' => _Send.auto,
    'DIRECT' when _isRoute => _Send.direct,
    _ => _Send.fixed,
  };
  Map<String, String> _errors = const {};
  List<Map<String, Object?>> _inherited = const [];
  String? _inheritedOf;
  bool _saving = false;
  int _request = 0;
  final _revision = ValueNotifier(0);

  bool get _isRoute => widget.target == null;

  RcxRoutingAction get _action => ref.read(rcxRoutingActionProvider.notifier);

  @override
  void initState() {
    super.initState();
    unawaited(_loadInherited());
  }

  @override
  void dispose() {
    _name.dispose();
    _revision.dispose();
    super.dispose();
  }

  void _changed(VoidCallback fn) {
    setState(fn);
    _revision.value++;
  }

  List<String> get _match => [
    for (final head in rcxList(_value['match'])) '$head',
  ];

  List<Map<String, Object?>> get _steps => [
    for (final step in rcxList(_value['prefer'])) rcxMap(step),
  ];

  Map<String, Object?> get _pool => rcxMap(_value['pool']);

  String get _profile => _value['profile'] as String? ?? '';

  /// The profile whose own server order applies while this one sets none.
  String? _effectiveProfile() {
    if (_profile.isNotEmpty) return _profile;
    if (_isRoute) return _routeProfile;
    final group = rcxTargetGroup(ref, widget.target!);
    if (group == null) return null;
    final profile = ref.read(rcxGroupProvider(group))?.profile ?? '';
    return profile.isEmpty ? null : profile;
  }

  Future<void> _loadInherited() async {
    final id = _effectiveProfile();
    if (id == _inheritedOf) return;
    _inheritedOf = id;
    final request = ++_request;
    if (id == null) {
      _changed(() => _inherited = const []);
      return;
    }
    final doc = await rcxProfileDocument(_action, id);
    if (!mounted || request != _request) return;
    _changed(() {
      _inherited = [for (final step in rcxList(doc['prefer'])) rcxMap(step)];
    });
  }

  void _set(String key, Object? value) {
    _changed(() {
      _value = {..._value, key: value};
      _errors = const {};
    });
  }

  String? _autoName;

  void _setMatch(List<String> match) {
    final name = _name.text.trim();
    if (name.isEmpty || name == _autoName) {
      final auto = rcxTrafficName(match);
      _name.text = _autoName = widget.taken.contains(auto) ? '' : auto;
    }
    _set('match', match);
  }

  String? _nameError(AppLocalizations l) {
    final name = _name.text.trim();
    if (name.isEmpty) return l.required;
    if (utf8.encode(name).length > _maxNameBytes) return l.rcxRouteNameLong;
    if (_reserved.contains(name)) return l.rcxRouteNameReserved;
    if (widget.taken.contains(name)) return l.existsTip(name);
    return null;
  }

  Map<String, Object?> _result() {
    final result = {..._value};
    if (_isRoute) {
      result['name'] = _name.text.trim();
      result['match'] = _match;
    }
    switch (_send) {
      case _Send.auto:
        result.remove('to');
      case _Send.direct:
        result['to'] = 'DIRECT';
      case _Send.fixed:
        break;
    }
    if (_send != _Send.auto) {
      result
        ..remove('profile')
        ..remove('prefer')
        ..remove('pool');
    }
    final pool = {..._pool}..removeWhere((_, value) => rcxIsEmpty(value));
    if (pool.isEmpty) {
      result.remove('pool');
    } else if (_send == _Send.auto) {
      result['pool'] = pool;
    }
    result.removeWhere((_, value) => rcxIsEmpty(value));
    return result;
  }

  bool _canSave(AppLocalizations l) {
    if (_isRoute && (_nameError(l) != null || _match.isEmpty)) return false;
    if (_send == _Send.fixed && (_value['to'] as String? ?? '').isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (_saving) return;
    final result = _result();
    final validate = widget.validate;
    if (validate == null) {
      Navigator.of(context).pop(result);
      return;
    }
    setState(() => _saving = true);
    try {
      final errors = await validate(result);
      if (!mounted) return;
      if (errors.isEmpty) {
        Navigator.of(context).pop(result);
      } else {
        setState(() => _errors = errors);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// The first problem under [prefix], for the field it belongs to.
  String? _errorAt(String prefix) => _errors.entries
      .where((e) => e.key == prefix || e.key.startsWith('$prefix.'))
      .firstOrNull
      ?.value;

  Map<int, String> _matchErrors() => {
    for (final MapEntry(:key, :value) in _errors.entries)
      if (RegExp(r'^match\.(\d+)').firstMatch(key) case final m?)
        int.parse(m.group(1)!): value,
  };

  String? _bannerError() {
    final known = ['name', 'match', 'to', 'prefer', 'pool', 'profile'];
    return _errors.entries
        .where((e) => !known.any((k) => e.key == k || e.key.startsWith('$k.')))
        .firstOrNull
        ?.value;
  }

  Future<void> _pickTarget() async {
    final l = context.appLocalizations;
    final groups = ref.read(groupsProvider);
    final String title;
    final List<SelectionSection<String>> sections;
    if (_isRoute) {
      final groupNames = {for (final group in groups) group.name};
      final servers = {
        for (final group in groups)
          for (final proxy in group.all)
            if (!groupNames.contains(proxy.name)) proxy.name,
      };
      title = l.rcxRouteTarget;
      sections = [
        SelectionSection(
          label: l.rcxScenarioGroups,
          items: [
            for (final name in groupNames)
              if (name != _name.text.trim()) name,
          ],
        ),
        SelectionSection(label: l.rcxServers, items: servers.toList()),
      ];
    } else {
      final group = rcxTargetGroup(ref, widget.target!);
      title = l.rcxProgramMember;
      sections = [
        SelectionSection(
          items: [
            for (final proxy
                in groups.getGroup(group ?? '')?.all ?? const <Proxy>[])
              proxy.name,
          ],
        ),
      ];
    }
    final current = _value['to'] as String? ?? '';
    final picked = await showInSheet<String>(
      context,
      builder: (sheetContext) => SelectionSheet<String>(
        title: title,
        sections: sections,
        labelBuilder: (name) => name,
        titleBuilder: (name, _) => EmojiText(name, maxLines: 1),
        selectedOf: (_) => current.isEmpty ? null : current,
        onSelected: (name) => Navigator.of(sheetContext).pop(name),
      ),
    );
    if (picked != null && mounted) _set('to', picked);
  }

  String get _to => _value['to'] as String? ?? '';

  Future<void> _choose(_Send send) async {
    final previous = _send;
    _changed(() {
      _send = send;
      _errors = const {};
      if (send == _Send.auto || send == _Send.fixed && _to == 'DIRECT') {
        _value = {..._value}..remove('to');
      }
    });
    if (send != _Send.fixed) return;
    await _pickTarget();
    if (mounted && _to.isEmpty) setState(() => _send = previous);
  }

  String? _groupName() => _isRoute
      ? ref.read(groupsProvider).getGroup(_name.text.trim())?.name
      : rcxTargetGroup(ref, widget.target!);

  String _behaviour(AppLocalizations l) {
    if (_profile.isEmpty && !_isRoute) return l.rcxOwnProfile;
    final id = _profile.isEmpty ? _routeProfile : _profile;
    final library = ref.read(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    return library.where((p) => p.id == id).firstOrNull?.displayTitle(locale) ??
        id;
  }

  String? get _choiceError =>
      _errorAt('profile') ?? _errorAt('prefer') ?? _errorAt('pool');

  String _choiceSummary(AppLocalizations l) {
    final steps = _steps.isEmpty ? _inherited : _steps;
    final include = _pool['include'] as String? ?? '';
    final exclude = _pool['exclude'] as String? ?? '';
    return [
      _behaviour(l),
      if (steps.isNotEmpty) _stepsSummary(l, steps),
      if (include.isNotEmpty) l.rcxOnly(rcxConditionSummary(l, include)),
      if (exclude.isNotEmpty) l.rcxExcept(rcxConditionSummary(l, exclude)),
    ].join(' · ');
  }

  Future<void> _openChoice() => BaseNavigator.push<void>(
    context,
    RoutingLivePage(
      title: context.appLocalizations.rcxHowToChoose,
      revision: _revision,
      builder: (l) => mounted ? _choiceSections(l) : const [],
    ),
  );

  static const _choiceKeys = ['profile', 'prefer', 'pool'];

  List<Widget> _choiceSections(AppLocalizations l) {
    final group = _groupName();
    return [
      RoutingChoiceSection(
        layers: [
          RcxChoiceLayer(
            value: _value,
            fields: _isRoute ? rcxRouteFields : rcxProgramFields,
            onChanged: (next) {
              final profile = next['profile'] != _value['profile'];
              _changed(() {
                _value = next;
                _errors = const {};
              });
              if (profile) unawaited(_loadInherited());
            },
          ),
          if (!_isRoute && group != null)
            RcxChoiceLayer(
              value: rcxBindingChoice(
                ref.read(currentRoutingLayerProvider).groups[group],
              ),
              fields: rcxProgramFields,
              origin: l.rcxFromYours,
            ),
        ],
        profile: _isRoute
            ? _routeProfile
            : group == null
            ? null
            : ref.read(rcxGroupProvider(group))?.profile,
        groupName: group,
        scenario: widget.scenario,
        ownProfile: !_isRoute,
        errors: {
          for (final MapEntry(:key, :value) in _errors.entries)
            if (_choiceKeys.any((k) => key == k || key.startsWith('$k.')))
              key: value,
        },
      ),
    ];
  }

  Widget _sendSection(AppLocalizations l) {
    final to = _to;
    Widget option(_Send send, String title, String subtitle) {
      final selected = _send == send;
      return DecorationListItem(
        key: ValueKey(send),
        isSelected: selected,
        invalid: selected && send == _Send.fixed && _errorAt('to') != null,
        title: Text(title),
        subtitle: EmojiText(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () => unawaited(_choose(send)),
        trailing: selected ? const SelectionCheck() : null,
      );
    }

    return generateSection(
      title: l.rcxRouteWhere,
      footer:
          _errorAt('to') ??
          (_send == _Send.fixed && !_isRoute ? l.rcxFixedHint : null),
      items: [
        option(_Send.auto, l.rcxSendBest, l.rcxRouteSendAutoHint),
        if (widget.target != '*')
          option(
            _Send.fixed,
            l.rcxRouteSendFixed,
            _send == _Send.fixed && to.isNotEmpty
                ? to
                : _isRoute
                ? l.rcxRouteSendFixedHint
                : l.rcxRouteChoose,
          ),
        if (_isRoute)
          option(_Send.direct, l.rcxSendDirect, l.rcxRouteSendDirectHint),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    ref.watch(rcxLibraryProvider);
    final nameError = _isRoute && _name.text.trim().isNotEmpty
        ? _nameError(l) ?? _errorAt('name')
        : _errorAt('name');
    final name = _name.text.trim();
    final choiceError = _choiceError;
    return FormPage(
      title: _isRoute
          ? (name.isEmpty ? l.rcxRouteNew : name)
          : rcxProgramLabel(l, widget.target!),
      saving: _saving,
      error: _bannerError(),
      onSave: _canSave(l) ? _save : null,
      actions: [
        if (widget.deletable)
          IconButtonData(
            glyph: AppGlyphs.delete,
            tooltip: l.delete,
            onPressed: () =>
                Navigator.of(context).pop(const <String, Object?>{}),
          ),
      ],
      children: [
        if (_isRoute) ...[
          RouteTrafficSection(
            match: _match,
            errors: _matchErrors(),
            onChanged: _setMatch,
          ),
          generateSection(
            footer: nameError,
            items: [
              FormRow(
                title: l.rcxRouteName,
                invalid: nameError != null,
                trailing: FormRowTextField(
                  controller: _name,
                  hintText: '▶️ YouTube',
                  autocorrect: false,
                  onChanged: (_) => setState(() => _errors = const {}),
                ),
              ),
            ],
          ),
        ],
        _sendSection(l),
        AnimatedEntries(
          children: [
            if (_send == _Send.auto)
              KeyedSubtree(
                key: const ValueKey('choice'),
                child: generateSection(
                  items: [
                    DecorationListItem(
                      invalid: choiceError != null,
                      title: Text(l.rcxHowToChoose),
                      subtitle: EmojiText(
                        choiceError ?? _choiceSummary(l),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => unawaited(_openChoice()),
                      trailing: const DisclosureIndicator(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
