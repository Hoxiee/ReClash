import 'dart:async';
import 'dart:convert';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'routing.dart';
import 'routing_condition.dart';
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
/// user backs out.
Future<Map<String, Object?>?> editRoute(
  BuildContext context, {
  required Map<String, Object?> value,
  required Map<String, Object?> scenario,
  String? target,
  Set<String> taken = const {},
  RouteValidator? validate,
}) {
  return BaseNavigator.push<Map<String, Object?>>(
    context,
    RouteEditor(
      value: value,
      scenario: scenario,
      target: target,
      taken: taken,
      validate: validate,
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
    if (steps.isEmpty)
      l.rcxCondAnyServer
    else
      [
        for (final (index, step) in steps.indexed)
          steps.length == 1
              ? rcxStepSummary(l, step)
              : '${index + 1} ${rcxStepSummary(l, step)}',
      ].join(' → '),
    if (profile.isNotEmpty && profileTitle != null) profileTitle(profile),
    if (exclude.isNotEmpty) l.rcxExcept(rcxConditionSummary(l, exclude)),
  ].join(' · ');
}

class RouteEditor extends ConsumerStatefulWidget {
  const RouteEditor({
    super.key,
    required this.value,
    required this.scenario,
    this.target,
    this.taken = const {},
    this.validate,
  });

  final Map<String, Object?> value;
  final Map<String, Object?> scenario;
  final String? target;
  final Set<String> taken;
  final RouteValidator? validate;

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
    super.dispose();
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
      setState(() => _inherited = const []);
      return;
    }
    final source = await _action.studio({'op': 'source', 'id': id});
    final text = source?.text ?? '';
    final lint = text.isEmpty
        ? null
        : await _action.studio({'op': 'lint', 'text': text, 'id': id});
    if (!mounted || request != _request) return;
    setState(() {
      _inherited = [
        for (final step in rcxList(lint?.profile?['prefer'])) rcxMap(step),
      ];
    });
  }

  void _set(String key, Object? value) {
    setState(() {
      _value = {..._value, key: value};
      _errors = const {};
    });
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

  Future<void> _pickProfile() async {
    final picked = await BaseNavigator.push<String>(
      context,
      _BehaviourPage(selected: _profile, own: !_isRoute),
    );
    if (picked == null || !mounted) return;
    _set('profile', picked);
    unawaited(_loadInherited());
  }

  Future<void> _editPool(String key, String title) async {
    final text = await editCondition(
      context,
      title: title,
      text: _pool[key] as String? ?? '',
      profile: {'tags': rcxMap(widget.scenario['tags'])},
    );
    if (text == null || !mounted) return;
    _set('pool', {..._pool, key: text});
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final groupName = _isRoute
        ? ref.watch(
            groupsProvider.select(
              (groups) => groups.getGroup(_name.text.trim())?.name,
            ),
          )
        : rcxTargetGroup(ref, widget.target!);
    final profileInfo = library
        .where((p) => p.id == (_profile.isEmpty ? _routeProfile : _profile))
        .firstOrNull;
    final profileTitle = _profile.isEmpty && !_isRoute
        ? l.rcxOwnProfile
        : profileInfo?.displayTitle(locale) ?? _profile;
    final description = _profile.isEmpty && !_isRoute
        ? null
        : profileInfo?.localize(profileInfo.description, locale);
    final nameError = _isRoute && _name.text.trim().isNotEmpty
        ? _nameError(l) ?? _errorAt('name')
        : _errorAt('name');
    final to = _value['to'] as String? ?? '';
    final sends = [
      (_Send.auto, l.rcxModeAuto),
      if (widget.target != '*') (_Send.fixed, l.rcxRouteSendFixed),
      if (_isRoute) (_Send.direct, l.direct),
    ];
    final name = _name.text.trim();
    return FormPage(
      title: _isRoute
          ? (name.isEmpty ? l.rcxRouteNew : name)
          : rcxProgramLabel(l, widget.target!),
      saving: _saving,
      error: _bannerError(),
      onSave: _canSave(l) ? _save : null,
      children: [
        if (_isRoute) ...[
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
          RouteTrafficSection(
            match: _match,
            errors: _matchErrors(),
            onChanged: (match) => _set('match', match),
          ),
        ],
        if (sends.length > 1)
          generateSection(
            title: l.rcxRouteSend,
            footer: switch (_send) {
              _Send.auto => l.rcxRouteSendAutoHint,
              _Send.direct => l.rcxRouteSendDirectHint,
              _Send.fixed =>
                _isRoute ? l.rcxRouteSendFixedHint : l.rcxFixedHint,
            },
            items: [
              SegmentedControl<_Send>(
                segments: sends,
                value: _send,
                onChanged: (send) => setState(() {
                  _send = send;
                  _errors = const {};
                  if (send == _Send.auto ||
                      send == _Send.fixed && to == 'DIRECT') {
                    _value = {..._value}..remove('to');
                  }
                }),
              ),
            ],
          ),
        AnimatedEntries(
          children: [
            if (_send == _Send.fixed)
              KeyedSubtree(
                key: const ValueKey('target'),
                child: generateSection(
                  footer: _errorAt('to'),
                  items: [
                    DecorationListItem(
                      invalid: _errorAt('to') != null,
                      title: Text(
                        _isRoute ? l.rcxRouteTarget : l.rcxProgramMember,
                      ),
                      subtitle: EmojiText(to.isEmpty ? l.rcxRouteChoose : to),
                      onPressed: _pickTarget,
                      trailing: const DisclosureIndicator(),
                    ),
                  ],
                ),
              ),
            if (_send == _Send.auto) ...[
              KeyedSubtree(
                key: const ValueKey('ladder'),
                child: RoutingLadderSection(
                  steps: _steps,
                  onChanged: (steps) => _set('prefer', steps),
                  scope: widget.scenario,
                  scenario: true,
                  groupName: groupName,
                  inherited: _inherited,
                  footer: _errorAt('prefer'),
                ),
              ),
              KeyedSubtree(
                key: const ValueKey('behaviour'),
                child: generateSection(
                  title: l.rcxBehaviour,
                  footer:
                      _errorAt('profile') ?? _errorAt('pool') ?? description,
                  items: [
                    DecorationListItem(
                      invalid: _errorAt('profile') != null,
                      title: Text(l.rcxBehaviour),
                      subtitle: EmojiText(profileTitle),
                      onPressed: _pickProfile,
                      trailing: const DisclosureIndicator(),
                    ),
                    if (!_isRoute)
                      _poolRow(
                        l,
                        'include',
                        l.rcxPoolInclude,
                        l.rcxCondAnyServer,
                      ),
                    _poolRow(l, 'exclude', l.rcxPoolExclude, l.none),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _poolRow(AppLocalizations l, String key, String title, String empty) {
    final text = _pool[key] as String? ?? '';
    return DecorationListItem(
      invalid: _errorAt('pool.$key') != null,
      title: Text(title),
      subtitle: EmojiText(
        text.isEmpty ? empty : text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () => _editPool(key, title),
      trailing: const DisclosureIndicator(),
    );
  }
}

/// The group profiles a route or group can run, each with what it does.
class _BehaviourPage extends ConsumerWidget {
  const _BehaviourPage({required this.selected, required this.own});

  final String selected;

  /// Offers the group's own profile, which a program keeps by naming none.
  final bool own;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final current = selected.isEmpty && !own ? _routeProfile : selected;
    Widget row(String id, String title, String? subtitle) {
      final isSelected = id == current;
      return DecorationListItem(
        isSelected: isSelected,
        title: EmojiText(title),
        subtitle: subtitle == null || subtitle.isEmpty
            ? null
            : Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis),
        onPressed: () => Navigator.of(context).pop(id),
        trailing: isSelected ? const SelectionCheck() : null,
      );
    }

    return CommonScaffold(
      title: l.rcxBehaviour,
      body: ListView(
        padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.contentTopPadding, bottom: 20) +
            context.bodyInsets,
        children: [
          if (own)
            generateSection(
              items: [row('', l.rcxOwnProfile, l.rcxOwnProfileHint)],
            ),
          for (final source in const ['builtin', 'provider', 'user'])
            if (library.where(
                  (p) => p.source == source && !p.isScenario && p.error.isEmpty,
                )
                case final profiles when profiles.isNotEmpty)
              generateSection(
                title: rcxSourceLabel(l, source),
                items: [
                  for (final profile in profiles)
                    row(
                      profile.id,
                      profile.displayTitle(locale),
                      profile.description.isEmpty
                          ? rcxLevelLabel(l, profile.level)
                          : profile.localize(profile.description, locale),
                    ),
                ],
              ),
        ],
      ),
    );
  }
}
