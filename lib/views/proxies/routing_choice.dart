import 'dart:async';

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
import 'routing_condition.dart';
import 'routing_country.dart';
import 'routing_ladder.dart';
import 'routing_route.dart' show RoutingLivePage;
import 'routing_studio.dart';

/// What one layer of a group's choice can hold.
enum RcxChoiceField { profile, prefer, include, exclude, feel, energy }

const rcxProgramFields = {
  RcxChoiceField.profile,
  RcxChoiceField.prefer,
  RcxChoiceField.include,
  RcxChoiceField.exclude,
};

const rcxRouteFields = {
  RcxChoiceField.profile,
  RcxChoiceField.prefer,
  RcxChoiceField.exclude,
};

/// One layer of how a group picks a server, in a program's shape: profile,
/// prefer, pool and, for a group binding, feel and energy.
class RcxChoiceLayer {
  const RcxChoiceLayer({
    required this.value,
    required this.fields,
    this.origin,
    this.onChanged,
  });

  final Map<String, Object?> value;
  final Set<RcxChoiceField> fields;

  /// Where a value set here comes from, in words; null on the edited layer.
  final String? origin;

  /// Null for a layer shown only for what applies beneath the edited one.
  final ValueChanged<Map<String, Object?>>? onChanged;

  Object? operator [](RcxChoiceField field) => switch (field) {
    RcxChoiceField.include ||
    RcxChoiceField.exclude => rcxMap(value['pool'])[field.name],
    _ => value[field.name],
  };

  Map<String, Object?> _with(RcxChoiceField field, Object? next) {
    final out = {...value};
    final pooled =
        field == RcxChoiceField.include || field == RcxChoiceField.exclude;
    final target = pooled ? {...rcxMap(out['pool'])} : out;
    if (rcxIsEmpty(next)) {
      target.remove(field.name);
    } else {
      target[field.name] = next;
    }
    if (pooled) {
      if (target.isEmpty) {
        out.remove('pool');
      } else {
        out['pool'] = target;
      }
    }
    return out;
  }
}

Map<String, Object?> rcxStepOf(RcxTier tier) => {
  if (tier.label.isNotEmpty) 'label': tier.label,
  'when': tier.when,
  if (tier.lastResort) 'last-resort': true,
};

/// A group binding as a choice layer's value.
Map<String, Object?> rcxBindingChoice(RcxBinding? binding) {
  if (binding == null) return const {};
  final pool = {
    'include': ?binding.pool.include,
    'exclude': ?binding.pool.exclude,
  };
  return {
    'profile': ?binding.profile,
    if (binding.prefer.isNotEmpty)
      'prefer': [for (final tier in binding.prefer) rcxStepOf(tier)],
    if (pool.isNotEmpty) 'pool': pool,
    'feel': ?binding.feel,
    'energy': ?binding.energy,
  };
}

/// [binding] with what a choice layer [value] holds; a binding always keeps
/// a profile.
RcxBinding rcxBindingWith(RcxBinding binding, Map<String, Object?> value) {
  final pool = rcxMap(value['pool']);
  return binding.copyWith(
    profile: value['profile'] as String? ?? binding.profile,
    prefer: [
      for (final step in rcxList(value['prefer']))
        RcxTier.fromJson(rcxMap(step)),
    ],
    pool: RcxPool(
      include: pool['include'] as String?,
      exclude: pool['exclude'] as String?,
    ),
    feel: value['feel'] as String?,
    energy: value['energy'] as String?,
  );
}

/// A behaviour as its editor parses it; empty while the Core cannot say.
Future<Map<String, Object?>> rcxProfileDocument(
  RcxRoutingAction action,
  String id,
) async {
  final source = await action.studio({'op': 'source', 'id': id});
  final text = source?.text ?? '';
  if (text.isEmpty) return const {};
  final lint = await action.studio({'op': 'lint', 'text': text, 'id': id});
  return lint?.profile ?? const {};
}

/// How a group picks a server over [layers], the winning one first: a row
/// shows the first layer that sets it, writes to the first that can hold
/// it, and falls back to the behaviour's own value.
class RoutingChoiceSection extends ConsumerStatefulWidget {
  const RoutingChoiceSection({
    super.key,
    required this.layers,
    this.profile,
    this.groupName,
    this.servers,
    this.scenario,
    this.ownProfile = false,
    this.fixed = '',
    this.errors = const {},
    this.title,
    this.footer,
    this.orderHint,
    this.removableChips = const [],
    this.onRemoveChip,
  });

  final List<RcxChoiceLayer> layers;

  /// The behaviour in force while no layer names one.
  final String? profile;
  final String? groupName;

  /// The servers a pool narrows; the group's members when null.
  final List<String>? servers;

  /// The scenario whose tags steps and conditions see while a scenario
  /// layer is edited; the behaviour's otherwise.
  final Map<String, Object?>? scenario;

  /// The behaviour page offers keeping the behaviour beneath this layer.
  final bool ownProfile;

  /// The member a scenario holds the group on, leaving nothing to pick.
  final String fixed;

  /// Problems by key path under the edited layer: profile, prefer.0, pool.
  final Map<String, String> errors;
  final String? title;
  final String? footer;
  final String? orderHint;
  final List<RcxChip> removableChips;
  final ValueChanged<RcxChip>? onRemoveChip;

  @override
  ConsumerState<RoutingChoiceSection> createState() =>
      _RoutingChoiceSectionState();
}

typedef _Found = ({Object value, String? origin});

class _RoutingChoiceSectionState extends ConsumerState<RoutingChoiceSection> {
  final _revision = ValueNotifier(0);
  Map<String, Object?> _template = const {};
  String? _templateOf;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTemplate());
  }

  @override
  void didUpdateWidget(RoutingChoiceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_loadTemplate());
    // An open page is another route's subtree, which a build may not dirty.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revision.value++;
    });
  }

  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  String? get _profileId =>
      _find(RcxChoiceField.profile)?.value as String? ?? widget.profile;

  Future<void> _loadTemplate() async {
    final id = _profileId;
    if (id == _templateOf) return;
    _templateOf = id;
    if (id == null || id.isEmpty) {
      _template = const {};
      return;
    }
    final doc = await rcxProfileDocument(
      ref.read(rcxRoutingActionProvider.notifier),
      id,
    );
    if (!mounted || _templateOf != id) return;
    setState(() => _template = doc);
    _revision.value++;
  }

  _Found? _find(RcxChoiceField field, [int from = 0]) {
    for (final layer in widget.layers.skip(from)) {
      if (!layer.fields.contains(field)) continue;
      final value = layer[field];
      if (value != null && !rcxIsEmpty(value)) {
        return (value: value, origin: layer.origin);
      }
    }
    return null;
  }

  /// The layer that already sets the field takes the change, so it applies;
  /// otherwise the last writable one, which is the narrowest in scope.
  int _writer(RcxChoiceField field) {
    bool writes(RcxChoiceLayer layer) =>
        layer.onChanged != null && layer.fields.contains(field);
    final setting = widget.layers.indexWhere(
      (layer) => writes(layer) && !rcxIsEmpty(layer[field]),
    );
    return setting >= 0 ? setting : widget.layers.lastIndexWhere(writes);
  }

  bool _can(RcxChoiceField field) => _writer(field) >= 0;

  bool _shown(RcxChoiceField field) => _can(field);

  Object? _own(RcxChoiceField field) {
    final index = _writer(field);
    return index < 0 ? null : widget.layers[index][field];
  }

  void _write(RcxChoiceField field, Object? next) {
    final index = _writer(field);
    if (index < 0) return;
    final layer = widget.layers[index];
    layer.onChanged!(layer._with(field, next));
  }

  String? _errorAt(String prefix) => widget.errors.entries
      .where((e) => e.key == prefix || e.key.startsWith('$prefix.'))
      .firstOrNull
      ?.value;

  Map<String, Object?> get _scope => widget.scenario ?? _template;

  String _profileTitle(String id) {
    final library = ref.read(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    return library.where((p) => p.id == id).firstOrNull?.displayTitle(locale) ??
        id;
  }

  /// Text the running behaviour wrote, in its own translation.
  String _localized(String text) {
    final library = ref.read(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final info = library.where((p) => p.id == _profileId).firstOrNull;
    return info?.localize(text, locale) ?? text;
  }

  List<Map<String, Object?>> get _templateSteps => [
    for (final step in rcxList(_template['prefer'])) rcxMap(step),
  ];

  List<String> _servers() {
    if (widget.servers case final servers?) return servers;
    final name = widget.groupName;
    if (name == null) return const [];
    return [
      for (final proxy
          in ref.read(groupsProvider).getGroup(name)?.all ?? const <Proxy>[])
        proxy.name,
    ];
  }

  List<RcxChip> _chips(List<String> names) {
    final name = widget.groupName;
    final offered = name == null
        ? const <RcxChip>[]
        : ref.read(rcxGroupProvider(name))?.binding.chips ?? const <RcxChip>[];
    final known = {for (final chip in offered) chip.include};
    return [
      ...offered,
      ...rcxFlagChips(names).where((chip) => !known.contains(chip.include)),
    ];
  }

  Future<void> _push(
    String title,
    List<Widget> Function(AppLocalizations l) page,
  ) => pushRoutingPage<void>(
    context,
    RoutingLivePage(
      title: title,
      revision: _revision,
      builder: (l) => mounted ? page(l) : const [],
    ),
  );

  Future<void> _pickProfile() async {
    final name = widget.groupName;
    final offered = name == null
        ? const <String>[]
        : ref.read(rcxGroupProvider(name))?.offered ?? const <String>[];
    final own = _own(RcxChoiceField.profile) as String? ?? '';
    final picked = await pushRoutingPage<String>(
      context,
      _BehaviourPage(
        selected: own.isEmpty && !widget.ownProfile ? _profileId ?? '' : own,
        own: widget.ownProfile,
        offered: offered.toSet(),
      ),
    );
    if (picked != null && mounted) _write(RcxChoiceField.profile, picked);
  }

  Widget _link({
    required RcxChoiceField field,
    required String title,
    required String value,
    required String? origin,
    required String errorKey,
    required VoidCallback onPressed,
  }) {
    return DecorationListItem(
      key: ValueKey(field),
      invalid: _errorAt(errorKey) != null,
      title: Text(title),
      subtitle: origin == null ? null : EmojiText(origin, maxLines: 2),
      onPressed: onPressed,
      trailing: _LinkValue(value),
    );
  }

  Widget _behaviourRow(AppLocalizations l) {
    final found = _find(RcxChoiceField.profile);
    final id = found?.value as String? ?? widget.profile ?? '';
    return _link(
      field: RcxChoiceField.profile,
      title: l.rcxBehaviour,
      value: id.isEmpty ? l.rcxOwnProfile : _profileTitle(id),
      origin: found?.origin,
      errorKey: 'profile',
      onPressed: () => unawaited(_pickProfile()),
    );
  }

  Widget _orderRow(AppLocalizations l) {
    final found = _find(RcxChoiceField.prefer);
    final steps = found == null
        ? _templateSteps
        : [for (final step in rcxList(found.value)) rcxMap(step)];
    return _link(
      field: RcxChoiceField.prefer,
      title: l.rcxLadderTitle,
      value: steps.isEmpty
          ? l.rcxLadderAnyWorking
          : steps.map((s) => _localized(rcxStepSummary(l, s))).join(' → '),
      origin: found?.origin,
      errorKey: 'prefer',
      onPressed: () => unawaited(_push(l.rcxLadderTitle, _orderPage)),
    );
  }

  List<Widget> _orderPage(AppLocalizations l) {
    final writer = _writer(RcxChoiceField.prefer);
    if (writer < 0) return const [];
    final beneath = _find(RcxChoiceField.prefer, writer + 1);
    final own = widget.layers[writer][RcxChoiceField.prefer];
    return [
      RoutingLadderSection(
        steps: [for (final step in rcxList(own)) rcxMap(step)],
        onChanged: (steps) => _write(RcxChoiceField.prefer, steps),
        scope: _scope,
        scenario: widget.scenario != null,
        groupName: widget.groupName,
        inherited: beneath == null
            ? _templateSteps
            : [for (final step in rcxList(beneath.value)) rcxMap(step)],
        footer: _errorAt('prefer') ?? widget.orderHint,
      ),
    ];
  }

  String _poolText(AppLocalizations l, String include, List<RcxChip> chips) {
    final label = chips
        .where((chip) => chip.include == include)
        .firstOrNull
        ?.label;
    if (label == null) return l.rcxOnly(rcxConditionSummary(l, include));
    final country = rcxCountryOfName(label);
    return country != null && label == rcxCountryFlag(country)
        ? '$label ${rcxCountryName(context, country)}'
        : label;
  }

  Widget _serversRow(AppLocalizations l) {
    final include = _find(RcxChoiceField.include);
    final exclude = _find(RcxChoiceField.exclude);
    final chips = _chips(_servers());
    return _link(
      field: RcxChoiceField.include,
      title: l.rcxServers,
      value: [
        if (include == null)
          l.rcxAnyServer
        else
          _poolText(l, include.value as String, chips),
        if (exclude != null)
          l.rcxExcept(rcxConditionSummary(l, exclude.value as String)),
      ].join(' · '),
      origin: include?.origin ?? exclude?.origin,
      errorKey: 'pool',
      onPressed: () => unawaited(_push(l.rcxServers, _serversPage)),
    );
  }

  Future<void> _editCondition(RcxChoiceField field, String title) async {
    final current = _own(field) as String? ?? '';
    final text = await editCondition(
      context,
      title: title,
      text: current,
      profile: {'tags': rcxMap(_scope['tags'])},
    );
    if (text != null && text != current && mounted) _write(field, text);
  }

  Widget _conditionRow(RcxChoiceField field, String title, String empty) {
    final text = _own(field) as String? ?? '';
    return DecorationListItem(
      key: ValueKey(field),
      invalid: _errorAt('pool.${field.name}') != null,
      title: Text(title),
      subtitle: EmojiText(
        text.isEmpty ? empty : text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () => unawaited(_editCondition(field, title)),
      trailing: const DisclosureIndicator(),
    );
  }

  List<Widget> _serversPage(AppLocalizations l) {
    final names = _servers();
    final include = _can(RcxChoiceField.include);
    final conditions = [
      if (_shown(RcxChoiceField.include))
        _conditionRow(
          RcxChoiceField.include,
          l.rcxPoolInclude,
          l.rcxCondAnyServer,
        ),
      if (_shown(RcxChoiceField.exclude))
        _conditionRow(RcxChoiceField.exclude, l.rcxPoolExclude, l.none),
    ];
    return [
      if (include)
        _PoolSection(
          include: _own(RcxChoiceField.include) as String? ?? '',
          names: names,
          chips: _chips(names),
          removable: widget.removableChips,
          onRemove: widget.onRemoveChip,
          error: _errorAt('pool.include'),
          onChanged: (next) => _write(RcxChoiceField.include, next),
        ),
      if (conditions.isNotEmpty)
        generateSection(footer: _errorAt('pool.exclude'), items: conditions),
    ];
  }

  Widget _optionsRow(AppLocalizations l, RcxChoiceField field) {
    final feel = field == RcxChoiceField.feel;
    final found = _find(field);
    final fallback = feel
        ? rcxMap(_template['switch'])['feel'] as String?
        : _template['energy'] as String?;
    final options = feel ? rcxFeels : rcxEnergies;
    final value = found?.value as String? ?? fallback ?? 'balanced';
    final origin = found?.origin;
    return ListItem<String>.options(
      key: ValueKey(field),
      title: Text(feel ? l.rcxSwitching : l.rcxChecks),
      subtitle: origin == null ? null : EmojiText(origin, maxLines: 2),
      options: options,
      value: options.contains(value) ? value : 'balanced',
      textBuilder: (v) => feel ? rcxFeelLabel(l, v) : rcxEnergyLabel(l, v),
      onChanged: (v) {
        if (v != value) _write(field, v);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    ref.watch(rcxLibraryProvider);
    return generateSection(
      title: widget.title,
      footer: widget.errors.values.firstOrNull ?? widget.footer,
      items: widget.fixed.isNotEmpty
          ? [
              DecorationListItem(
                key: const ValueKey('fixed'),
                title: EmojiText(l.rcxFixedOn(widget.fixed)),
                subtitle: switch (widget.layers.firstOrNull?.origin) {
                  final origin? => EmojiText(origin),
                  null => null,
                },
              ),
            ]
          : [
              if (_can(RcxChoiceField.profile)) _behaviourRow(l),
              if (_can(RcxChoiceField.prefer)) _orderRow(l),
              if (_can(RcxChoiceField.include) ||
                  _shown(RcxChoiceField.exclude))
                _serversRow(l),
              if (_can(RcxChoiceField.feel))
                _optionsRow(l, RcxChoiceField.feel),
              if (_can(RcxChoiceField.energy))
                _optionsRow(l, RcxChoiceField.energy),
            ],
    );
  }
}

/// A link row's current value, held to the width an options row gives its
/// own so a long behaviour name leaves the title room.
class _LinkValue extends StatelessWidget {
  const _LinkValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: EmojiText(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.listTitleStyle.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const DisclosureIndicator(),
      ],
    );
  }
}

/// Ready-made pools and the name pattern, both narrowing the group to the
/// servers they match.
class _PoolSection extends StatefulWidget {
  const _PoolSection({
    required this.include,
    required this.names,
    required this.chips,
    required this.removable,
    required this.onRemove,
    required this.error,
    required this.onChanged,
  });

  final String include;
  final List<String> names;
  final List<RcxChip> chips;
  final List<RcxChip> removable;
  final ValueChanged<RcxChip>? onRemove;
  final String? error;
  final ValueChanged<String?> onChanged;

  @override
  State<_PoolSection> createState() => _PoolSectionState();
}

class _PoolSectionState extends State<_PoolSection> {
  late final _pattern = TextEditingController(
    text: rcxPatternOf(widget.include),
  );

  @override
  void didUpdateWidget(_PoolSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.include != oldWidget.include &&
        rcxIncludeOf(_pattern.text.trim()) != widget.include) {
      _pattern.text = rcxPatternOf(widget.include);
    }
  }

  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final pattern = value.trim();
    if (rcxCountMatches(pattern, widget.names) == null) return;
    final include = rcxIncludeOf(pattern);
    if (include != (widget.include.isEmpty ? null : widget.include)) {
      widget.onChanged(include);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final names = widget.names;
    final matched = rcxCountMatches(_pattern.text.trim(), names);
    final onRemove = widget.onRemove;
    return generateSection(
      title: l.rcxChangeTo,
      footer:
          widget.error ??
          (matched == null
              ? l.rcxPatternInvalid
              : l.rcxServersMatch(matched, names.length)),
      items: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PoolChip(
              label: l.rcxAnyServer,
              selected: widget.include.isEmpty,
              onPressed: () => widget.onChanged(null),
            ),
            for (final chip in widget.chips)
              ContextMenuRegion(
                menuItems: onRemove != null && widget.removable.contains(chip)
                    ? [
                        CommonPopupMenuItem(
                          label: l.delete,
                          glyph: AppGlyphs.delete,
                          danger: true,
                          onPressed: () => onRemove(chip),
                        ),
                      ]
                    : null,
                child: _PoolChip(
                  label: chip.label,
                  selected: chip.include == widget.include,
                  onPressed: () => widget.onChanged(chip.include),
                ),
              ),
          ],
        ),
        FormRow(
          title: l.rcxServersPattern,
          trailing: FormRowTextField(
            controller: _pattern,
            autocorrect: false,
            hintText: l.rcxAnyServer,
            onChanged: (_) => setState(() {}),
            onFieldSubmitted: _submit,
          ),
        ),
      ],
    );
  }
}

class _PoolChip extends StatelessWidget {
  const _PoolChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: 36,
      child: CommonCard(
        isSelected: selected,
        fillsSelection: true,
        shape: AppShape.full,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onPressed: onPressed,
        child: EmojiText(
          label,
          maxLines: 1,
          style: AppTextStyle.subheadline
              .of(context, emphasized: true)
              .copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

/// The behaviours a group can run, each with what it does; a provider group
/// offers only what its subscription lists.
class _BehaviourPage extends ConsumerWidget {
  const _BehaviourPage({
    required this.selected,
    required this.own,
    required this.offered,
  });

  final String selected;

  /// Offers the behaviour beneath, which a layer keeps by naming none.
  final bool own;
  final Set<String> offered;

  bool _shown(RcxProfileInfo p) =>
      !p.isScenario &&
      (p.source != 'provider' ||
          offered.isEmpty ||
          offered.contains(p.id) ||
          offered.contains(p.id.split('/').last));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    Widget row(
      String id,
      String title,
      String? subtitle, {
      bool invalid = false,
    }) {
      final isSelected = id == selected;
      return DecorationListItem(
        isSelected: isSelected,
        invalid: invalid,
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
            ).copyWith(top: context.sectionsTopPadding, bottom: 20) +
            context.bodyInsets,
        children: [
          if (own)
            generateSection(
              items: [row('', l.rcxOwnProfile, l.rcxOwnProfileHint)],
            ),
          for (final source in const ['builtin', 'provider', 'user'])
            if (library.where((p) => p.source == source && _shown(p))
                case final profiles when profiles.isNotEmpty)
              generateSection(
                title: rcxSourceLabel(l, source),
                items: [
                  for (final profile in profiles)
                    row(
                      profile.id,
                      profile.displayTitle(locale),
                      profile.error.isNotEmpty
                          ? profile.error
                          : [
                              if (profile.description.isNotEmpty)
                                profile.localize(profile.description, locale)
                              else
                                rcxLevelLabel(l, profile.level),
                              if (profile.consent.isNotEmpty) l.rcxNeedsConsent,
                            ].join(' · '),
                      invalid: profile.error.isNotEmpty,
                    ),
                ],
              ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.rcxManageHint,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
