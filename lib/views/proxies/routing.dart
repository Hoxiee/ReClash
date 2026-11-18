import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/config/routing.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'routing_choice.dart';
import 'routing_country.dart';
import 'routing_route.dart' show RoutingLivePage;
import 'routing_scenario.dart';
import 'routing_studio.dart';

const _whyRows = 8;
const _historyRows = 20;
const _maxFlagChips = 8;

/// The sheet holds its own pages, so the profile chooser opens inside it.
/// Opened from the auto-routing settings, its link back only closes it.
Future<void> showRoutingSheet(BuildContext context, String groupName) {
  final fromHub =
      context.findAncestorWidgetOfExactType<RoutingSettingsView>() != null;
  return showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (sheetContext) => NestedPagedSheet(
      builder: (_) => RoutingSheet(
        groupName: groupName,
        onOpenSettings: () {
          Navigator.of(sheetContext).pop();
          if (!fromHub && context.mounted) {
            unawaited(
              BaseNavigator.push<void>(context, const RoutingSettingsView()),
            );
          }
        },
        onOpenRoute: () {
          Navigator.of(sheetContext).pop();
          if (context.mounted) {
            RoutingSettingsView.showRoute(context, groupName);
          }
        },
      ),
    ),
  );
}

/// One smart group: what it holds and why, how it is controlled, where it
/// may change to, how it picks, and its own settings.
class RoutingSheet extends ConsumerStatefulWidget {
  const RoutingSheet({
    super.key,
    required this.groupName,
    this.onOpenSettings,
    this.onOpenRoute,
  });

  final String groupName;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenRoute;

  @override
  ConsumerState<RoutingSheet> createState() => _RoutingSheetState();
}

class _RoutingSheetState extends ConsumerState<RoutingSheet>
    with ScenarioDocument, RunningScenarioDocument {
  RcxExplanation? _explanation;
  List<RcxJournalEntry> _journal = const [];
  Map<String, String> _programErrors = const {};
  final _revision = ValueNotifier(0);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    watchRunningScenario();
    unawaited(_load());
    ref.listenManual(rcxGroupProvider(widget.groupName), (previous, next) {
      if (previous?.decision != next?.decision || previous?.now != next?.now) {
        unawaited(_load());
      }
    });
  }

  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final name = widget.groupName;
    final results = await Future.wait([
      action.explain(name),
      action.journal(name),
    ]);
    if (!mounted) return;
    setState(() {
      _explanation = results[0] as RcxExplanation?;
      _journal = (results[1] as List<RcxJournalEntry>).reversed.toList();
    });
    _revision.value++;
  }

  Future<void> _run(Future<void> Function() work) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  RcxBinding _savedBinding(RcxGroupStatus group) =>
      ref.read(currentRoutingLayerProvider).groups[widget.groupName] ??
      RcxBinding(profile: group.profile);

  void _setBinding(RcxBinding binding) =>
      unawaited(action.setBinding(widget.groupName, binding));

  void _removeChip(RcxGroupStatus group, RcxChip chip) {
    final binding = _savedBinding(group);
    _setBinding(
      binding.copyWith(
        chips: binding.chips.where((c) => c != chip).toList(),
        pool: binding.pool.include == chip.include
            ? binding.pool.copyWith(include: null)
            : binding.pool,
      ),
    );
  }

  Future<void> _act(RcxAction action, {String? node}) {
    return _run(() async {
      await this.action.act(widget.groupName, action, node: node);
      await _load();
    });
  }

  void _setControl(RcxGroupStatus group, String mode) {
    switch (mode) {
      case 'pinned' when group.now.isNotEmpty:
        unawaited(_act(RcxAction.pin, node: group.now));
      case 'manual':
        unawaited(_act(RcxAction.manual));
      case 'auto':
        unawaited(_act(RcxAction.auto));
    }
  }

  Future<void> _enable() {
    return _run(
      () => action.setBinding(
        widget.groupName,
        const RcxBinding(profile: rcxDefaultProfile),
      ),
    );
  }

  /// Where the running scenario programs the group: its route for a route
  /// group, else the program key the engine reports it under.
  _Program? _program(RcxGroupStatus group) {
    if (runningId == null || lint?.scenario == null) return null;
    if (group.route) {
      final routes = rcxList(scenario['routes']);
      final index = routes.indexWhere((r) => rcxMap(r)['name'] == group.name);
      if (index < 0) return null;
      return (
        path: 'routes.$index',
        value: rcxMap(routes[index]),
        put: (s, next) =>
            s['routes'] = [...rcxList(s['routes'])]..[index] = next,
      );
    }
    final key = group.program;
    if (key.isEmpty) return null;
    // A change under '*' would reach every group; it gets a program of its own.
    final target = key == '*' ? group.name : key;
    return (
      path: 'groups.$target',
      value: rcxMap(rcxMap(scenario['groups'])[key]),
      put: (s, next) => s['groups'] = {...rcxMap(s['groups']), target: next},
    );
  }

  Future<void> _editProgram(
    String path,
    void Function(Map<String, Object?> scenario) update,
  ) async {
    if (!await ensureOwn() || !mounted) return;
    final errors = await validateRunning(path, update);
    if (!mounted) return;
    setState(() => _programErrors = errors);
    if (errors.isEmpty) await editRunning(update);
  }

  void _openDetails() {
    unawaited(
      showInSheet<void>(
        context,
        builder: (_) => RoutingLivePage(
          title: context.appLocalizations.rcxDetails,
          revision: _revision,
          builder: (l) => mounted ? _detailSections(l) : const [],
        ),
      ),
    );
  }

  String Function(String) _own(String? profile) {
    final library = ref.read(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final info = library.where((p) => p.id == profile).firstOrNull;
    return (text) => info?.localize(text, locale) ?? text;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final group = ref.watch(rcxGroupProvider(widget.groupName));
    final problems = ref.watch(
      rcxStatusStateProvider.select(
        (status) => status?.problems ?? const <RcxReason>[],
      ),
    );
    ref.watch(rcxLibraryProvider);
    final saved = ref.watch(
      currentRoutingLayerProvider.select(
        (layer) => layer.groups[widget.groupName],
      ),
    );
    final direct = _watchNames(ref, widget.groupName);
    // The engine's ranking lists the servers behind flattened nested
    // selectors too, which is what a pool narrows.
    final ranking = _explanation?.decision.ranking;
    final names = ranking == null || ranking.isEmpty
        ? direct
        : [for (final row in ranking) row.name];
    return CommonScaffold(
      title: widget.groupName,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 20),
        children: [
          AnimatedEntries(
            children: group == null
                ? [
                    _Intro(
                      key: const ValueKey('intro'),
                      groupName: widget.groupName,
                      busy: _busy,
                      onEnable: _enable,
                    ),
                  ]
                : _sections(l, group, problems, saved, names),
          ),
        ],
      ),
    );
  }

  List<Widget> _sections(
    AppLocalizations l,
    RcxGroupStatus group,
    List<RcxReason> problems,
    RcxBinding? saved,
    List<String> names,
  ) {
    final control = group.control;
    final own = _own(group.profile);
    final onOpenSettings = widget.onOpenSettings;
    final program = _program(group);
    final fault = switch (group.problem) {
      final problem? when problem.code != 'profile.consent' => problem,
      _ => null,
    };
    final ranked = _explanation?.decision.ranking ?? const <RcxRanked>[];
    return [
      for (final (index, problem) in [...problems, ?fault].indexed)
        Padding(
          key: ValueKey('problem-$index-${problem.code}'),
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            rcxReasonText(l, problem, own: own),
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: context.colorScheme.error),
          ),
        ),
      if (group.problem case RcxReason(code: 'profile.consent', :final args))
        RoutingConsentSection(
          key: const ValueKey('consent'),
          hosts: [
            for (final host in args['hosts'] as List? ?? const []) '$host',
          ],
          title: own(group.profileTitle),
        ),
      _StatusSection(
        key: const ValueKey('status'),
        group: group,
        own: own,
        busy: _busy,
        onChange: () => _act(RcxAction.change),
      ),
      KeyedSubtree(
        key: const ValueKey('control'),
        child: generateSection(
          title: l.rcxControl,
          footer: [
            if (group.program.isNotEmpty) l.rcxScenarioDrives(_scenarioTitle()),
            switch (control.mode) {
              'pinned' => l.rcxModePinnedHint(control.pinName),
              'manual' => l.rcxModeManualHint,
              _ => l.rcxModeAutoHint,
            },
          ].join(' '),
          items: [
            SegmentedControl<String>(
              segments: [
                ('auto', l.rcxModeAuto),
                ('pinned', l.rcxPinnedLabel),
                ('manual', l.rcxModeManual),
              ],
              value: control.mode,
              onChanged: (mode) => _setControl(group, mode),
            ),
          ],
        ),
      ),
      KeyedSubtree(
        key: const ValueKey('choice'),
        child: RoutingChoiceSection(
          layers: [
            if (program != null)
              RcxChoiceLayer(
                value: program.value,
                fields: group.route ? rcxRouteFields : rcxProgramFields,
                origin: l.rcxFromScenario(_scenarioTitle()),
                onChanged: (next) => unawaited(
                  _editProgram(program.path, (s) => program.put(s, next)),
                ),
              ),
            RcxChoiceLayer(
              value: rcxBindingChoice(saved),
              fields: RcxChoiceField.values.toSet(),
              origin: l.rcxFromYours,
              onChanged: (value) =>
                  _setBinding(rcxBindingWith(_savedBinding(group), value)),
            ),
          ],
          profile: group.profile,
          groupName: widget.groupName,
          servers: names,
          scenario: program == null ? null : scenario,
          ownProfile: program != null && !group.route,
          fixed: group.fixed,
          errors: program == null
              ? const {}
              : {...issuesUnder(program.path), ..._programErrors},
          removableChips: saved?.chips ?? const [],
          onRemoveChip: (chip) => _removeChip(group, chip),
        ),
      ),
      if (group.directSplit.isNotEmpty)
        KeyedSubtree(
          key: const ValueKey('split'),
          child: _splitSection(l, group, saved?.directSplit ?? false),
        ),
      if (ranked.isNotEmpty || _journal.isNotEmpty)
        KeyedSubtree(
          key: const ValueKey('details'),
          child: generateSection(
            items: [
              DecorationListItem(
                title: Text(l.rcxDetails),
                subtitle: ranked.isEmpty
                    ? null
                    : Text(l.rcxWhyCount(ranked.length)),
                onPressed: _openDetails,
                trailing: const DisclosureIndicator(),
              ),
            ],
          ),
        ),
      if (onOpenSettings != null)
        KeyedSubtree(
          key: const ValueKey('settings-link'),
          child: generateSection(
            items: [
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.shuffle),
                title: Text(l.rcxSettingsLink),
                subtitle: Text(l.rcxSettingsLinkHint),
                onPressed: onOpenSettings,
                trailing: const DisclosureIndicator(),
              ),
            ],
          ),
        ),
      if (group.route)
        KeyedSubtree(
          key: const ValueKey('route'),
          child: generateSection(
            title: l.rcxRouteGroup,
            items: [
              DecorationListItem(
                title: Text(l.rcxRouteEdit),
                subtitle: EmojiText(l.rcxRouteGroupHint(_scenarioTitle())),
                onPressed: widget.onOpenRoute,
                trailing: widget.onOpenRoute == null
                    ? null
                    : const DisclosureIndicator(),
              ),
            ],
          ),
        )
      else if (group.source == 'user')
        KeyedSubtree(
          key: const ValueKey('turn-off'),
          child: generateSection(
            footer: l.rcxTurnOffHint,
            items: [
              DecorationListItem(
                title: Text(
                  l.rcxTurnOff,
                  style: TextStyle(color: context.colorScheme.error),
                ),
                onPressed: _busy
                    ? null
                    : () =>
                          _run(() => action.setBinding(widget.groupName, null)),
              ),
            ],
          ),
        ),
    ];
  }

  String _scenarioTitle() {
    final scenario = ref.read(rcxStatusStateProvider)?.scenario;
    if (scenario == null) return '';
    final library = ref.read(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    return library
            .where((p) => p.isScenario && p.id == scenario.id)
            .firstOrNull
            ?.displayTitle(locale) ??
        scenario.title;
  }

  Widget _splitSection(AppLocalizations l, RcxGroupStatus group, bool on) {
    return generateAnimatedSection(
      title: l.network,
      footer: l.rcxDirectSplitHint,
      items: [
        ListItem.toggle(
          key: const ValueKey('split'),
          title: Text(l.rcxDirectSplit),
          value: on,
          onChanged: (on) =>
              _setBinding(_savedBinding(group).copyWith(directSplit: on)),
        ),
        if (on)
          DecorationListItem(
            key: const ValueKey('split-state'),
            title: Text(
              group.directSplit == 'active'
                  ? l.rcxDirectSplitActive
                  : l.rcxDirectSplitStandby,
            ),
          ),
      ],
    );
  }

  List<Widget> _detailSections(AppLocalizations l) {
    final group = ref.read(rcxGroupProvider(widget.groupName));
    final own = _own(group?.profile);
    final ranking = _explanation?.decision.ranking ?? const <RcxRanked>[];
    return [
      if (ranking.isNotEmpty)
        KeyedSubtree(
          key: const ValueKey('why'),
          child: generateSection(
            title: l.rcxWhy,
            items: [
              for (final row in ranking.take(_whyRows))
                DecorationListItem(
                  key: ValueKey('why-${row.name}'),
                  isSelected: row.current,
                  title: EmojiText(row.name, maxLines: 1),
                  subtitle: EmojiText(_rowDetail(l, row, own)),
                  trailing: row.latencyMs > 0
                      ? Text('${row.latencyMs} ms')
                      : null,
                ),
            ],
          ),
        ),
      if (_journal.isNotEmpty)
        KeyedSubtree(
          key: const ValueKey('history'),
          child: generateSection(
            title: l.rcxHistory,
            items: [
              for (final entry in _journal.take(_historyRows))
                DecorationListItem(
                  key: ValueKey('history-${entry.seq}'),
                  title: EmojiText(rcxJournalText(l, entry), maxLines: 3),
                  subtitle: Text(entry.at.getLastUpdateTimeDesc(context)),
                ),
            ],
          ),
        ),
    ];
  }

  String _rowDetail(
    AppLocalizations l,
    RcxRanked row,
    String Function(String) own,
  ) {
    final parts = [
      if (row.excluded != null)
        rcxReasonText(l, row.excluded!, own: own)
      else ...[
        if (row.tierLabel.isNotEmpty) own(row.tierLabel),
        rcxHealthLabel(l, row.health),
      ],
      if (row.pending.isNotEmpty) l.rcxPendingTier(own(row.pending)),
      if (row.exit.isNotEmpty) l.rcxExit(rcxCountryLabel(row.exit)),
      for (final MapEntry(:key, :value) in row.checks.entries)
        '${rcxCheckLabel(l, key, own: own)} ${_checkMarks[value] ?? value}',
      if (row.checkedAt case final at?)
        at.getLastUpdateTimeDesc(context, compact: true),
    ];
    return parts.join(' · ');
  }
}

typedef _Program = ({
  String path,
  Map<String, Object?> value,
  void Function(Map<String, Object?> scenario, Map<String, Object?> next) put,
});

/// Third-party hosts a provider profile or scenario waits on.
class RoutingConsentSection extends ConsumerStatefulWidget {
  const RoutingConsentSection({
    super.key,
    required this.hosts,
    required this.title,
  });

  final List<String> hosts;
  final String title;

  @override
  ConsumerState<RoutingConsentSection> createState() =>
      _RoutingConsentSectionState();
}

class _RoutingConsentSectionState extends ConsumerState<RoutingConsentSection> {
  bool _busy = false;

  Future<void> _allow() async {
    setState(() => _busy = true);
    try {
      await ref.read(rcxRoutingActionProvider.notifier).trust(widget.hosts);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return generateSection(
      title: l.rcxConsentTitle,
      footer: l.rcxConsentHint,
      items: [
        DecorationListItem(
          title: EmojiText(l.rcxConsentAsk(widget.title)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(widget.hosts.join('\n')),
              FilledButton(
                onPressed: _busy ? null : _allow,
                child: Text(l.rcxConsentAllow),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A group without auto routing: what turning it on would do, and the one
/// button that does it.
class _Intro extends ConsumerWidget {
  const _Intro({
    super.key,
    required this.groupName,
    required this.busy,
    required this.onEnable,
  });

  final String groupName;
  final bool busy;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final info = library.where((p) => p.id == rcxDefaultProfile).firstOrNull;
    final servers = _watchNames(ref, groupName).length;
    final description = info?.localize(info.description, locale) ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.rcxMakeSmartHint, style: AppTextStyle.body.of(context)),
        generateSection(
          title: l.rcxWouldDo,
          footer: l.rcxWouldServers(servers),
          items: [
            DecorationListItem(
              title: EmojiText(info?.displayTitle(locale) ?? l.rcxProfile),
              subtitle: description.isEmpty ? null : Text(description),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: busy ? null : onEnable,
          child: Text(l.rcxMakeSmart),
        ),
      ],
    );
  }
}

/// What the group holds now: the server with its flag and latency, why in
/// one line, and the button that moves it on.
class _StatusSection extends StatelessWidget {
  const _StatusSection({
    super.key,
    required this.group,
    required this.own,
    required this.busy,
    required this.onChange,
  });

  final RcxGroupStatus group;
  final String Function(String) own;
  final bool busy;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final decision = group.decision;
    final until = decision.until;
    final latency = group.current?.latencyMs ?? 0;
    final exit = group.current?.exit ?? '';
    final country = exit.isNotEmpty ? exit : rcxCountryOfName(group.now);
    final flag = country == null ? '' : rcxCountryFlag(country);
    final network = group.network;
    final kind = switch (network) {
      RcxGroupNetwork(kind: final kind) when kind.isNotEmpty => kind,
      RcxGroupNetwork(next: final next) when next.isNotEmpty => '',
      _ => null,
    };
    final details = [
      if (country != null) rcxCountryName(context, country),
      if (decision.tier.isNotEmpty &&
          decision.reason.args['tier'] != decision.tier)
        own(decision.tier),
      if (kind != null) l.rcxNetwork(rcxKindLabel(l, kind, own: own)),
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        generateSection(
          items: [
            DecorationListItem(
              leading: flag.isEmpty || group.now.contains(flag)
                  ? null
                  : EmojiText(flag, style: AppTextStyle.title2.of(context)),
              title: EmojiText(group.now.isEmpty ? '—' : group.now),
              subtitle: EmojiText(
                [
                  rcxReasonText(l, decision.reason, own: own),
                  if (until != null) rcxReasonText(l, until, own: own),
                  details,
                ].where((line) => line.isNotEmpty).join('\n'),
              ),
              trailing: latency > 0 ? Text('$latency ms') : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: busy || group.control.isManual ? null : onChange,
          child: Text(l.rcxChangeServer),
        ),
      ],
    );
  }
}

List<String> _watchNames(WidgetRef ref, String groupName) => ref.watch(
  groupsProvider.select(
    (groups) => [
      for (final proxy in groups.getGroup(groupName)?.all ?? const <Proxy>[])
        proxy.name,
    ],
  ),
);

final _flag = RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true);

/// Country flags in server names, most common first, as ready-made pools.
/// None are offered when every server shares one country.
List<RcxChip> rcxFlagChips(List<String> names) {
  final counts = <String, int>{};
  for (final name in names) {
    final flag = _flag.firstMatch(name)?.group(0);
    if (flag != null) counts[flag] = (counts[flag] ?? 0) + 1;
  }
  if (counts.length < 2) return const [];
  final flags = counts.keys.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : a.compareTo(b);
    });
  return [
    for (final flag in flags.take(_maxFlagChips))
      RcxChip(label: flag, include: rcxIncludeOf(flag)!),
  ];
}

/// The pool condition the pattern field writes, a case-insensitive name match.
String? rcxIncludeOf(String pattern) {
  if (pattern.isEmpty) return null;
  return 'name ~ /${pattern.replaceAll('/', r'\/')}/i';
}

String rcxPatternOf(String? include) {
  final match = RegExp(r'^name ~ /(.*)/i$').firstMatch(include ?? '');
  return match?.group(1)?.replaceAll(r'\/', '/') ?? '';
}

/// Null when the pattern does not compile.
int? rcxCountMatches(String pattern, List<String> names) {
  if (pattern.isEmpty) return names.length;
  try {
    final regex = RegExp(pattern, caseSensitive: false);
    return names.where(regex.hasMatch).length;
  } on FormatException {
    return null;
  }
}

String rcxFeelLabel(AppLocalizations l, String value) => switch (value) {
  'calm' => l.rcxFeelCalm,
  'eager' => l.rcxFeelEager,
  _ => l.rcxBalanced,
};

String rcxEnergyLabel(AppLocalizations l, String value) => switch (value) {
  'eco' => l.rcxEnergyEco,
  'precise' => l.rcxEnergyPrecise,
  _ => l.rcxBalanced,
};

String rcxSourceLabel(AppLocalizations l, String source) => switch (source) {
  'provider' => l.rcxSourceProvider,
  'user' => l.rcxSourceUser,
  _ => l.rcxSourceBuiltin,
};

/// A profile's title in the app's language, as its own catalog gives it.
String rcxProfileTitle(BuildContext context, WidgetRef ref, String id) {
  final library = ref.watch(rcxLibraryProvider).value ?? const [];
  final info = library.where((p) => p.id == id).firstOrNull;
  return info?.displayTitle(Localizations.localeOf(context).toString()) ??
      context.appLocalizations.rcxModeAuto;
}

/// A tunnel mode as the mode switch names it.
String rcxModeLabel(String mode) =>
    Mode.values.asNameMap()[mode]?.label ?? mode;

/// What a scenario's program key names: the main group, every group, or
/// one group by name.
String rcxProgramLabel(AppLocalizations l, String key) => switch (key) {
  r'$main' => l.rcxMainGroup,
  '*' => l.rcxAllGroups,
  _ => key,
};

String rcxLevelLabel(AppLocalizations l, String level) =>
    level == 'advanced' ? l.rcxLevelAdvanced : l.rcxLevelSimple;

const _checkMarks = {'pass': '✓', 'fail': '×', 'soft': '~'};

/// A flag and the ISO code, as the Core reports a verified country.
String rcxCountryLabel(String code) {
  final upper = code.toUpperCase();
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(upper)) return code;
  final flag = String.fromCharCodes(upper.codeUnits.map((c) => c + 0x1F1A5));
  return '$flag $upper';
}

/// Kinds the built-in profiles declare; a profile's own kind shows in the
/// profile's own translation, or as named.
String rcxKindLabel(
  AppLocalizations l,
  String kind, {
  String Function(String)? own,
}) => switch (kind) {
  '' => l.rcxKindChecking,
  'open' => l.rcxKindOpen,
  'whitelist' => l.rcxKindWhitelist,
  'portal' => l.rcxKindPortal,
  _ => own?.call(kind) ?? kind,
};

String rcxCheckLabel(
  AppLocalizations l,
  String id, {
  String Function(String)? own,
}) => id == 'open' ? l.rcxCheckOpen : own?.call(id) ?? id;

String rcxHealthLabel(AppLocalizations l, String health) => switch (health) {
  'alive' => l.rcxHealthAlive,
  'stale' => l.rcxHealthStale,
  'dead' => l.rcxHealthDead,
  _ => l.rcxHealthUnknown,
};

String _arg(RcxReason reason, String key) => '${reason.args[key] ?? ''}';

int _intArg(RcxReason reason, String key) =>
    (reason.args[key] as num?)?.toInt() ?? 0;

/// The sentence for a reason code from the Core. An unknown code shows as
/// itself, so a newer Core never renders an empty line. [own] translates the
/// profile's own words, such as tier labels.
String rcxReasonText(
  AppLocalizations l,
  RcxReason r, {
  String Function(String)? own,
}) => switch (r.code) {
  'manual' || 'manual.requested' => l.rcxReasonManual,
  'hold.pinned' => l.rcxReasonHoldPinned,
  'switch.pinned' => l.rcxReasonSwitchPinned(_arg(r, 'node')),
  'stranded.no-candidates' => l.rcxReasonStranded,
  'switch.stranded' => l.rcxReasonSwitchStranded(_arg(r, 'node')),
  'switch.initial' => l.rcxReasonInitial,
  'switch.change-server' => l.rcxReasonChangeServer(_arg(r, 'from')),
  'switch.failover' => l.rcxReasonFailover(_arg(r, 'from')),
  'switch.out-of-pool' => l.rcxReasonOutOfPool(_arg(r, 'from')),
  'hold.no-alternative' => l.rcxReasonNoAlternative,
  'hold.best' => l.rcxReasonBest,
  'hold.checking' => l.rcxReasonChecking,
  'hold.working' => l.rcxReasonWorking,
  'hold.dwell' => l.rcxReasonDwell,
  'hold.flap-limit' => l.rcxReasonFlapLimit(_intArg(r, 'limit')),
  'hold.confirming' => l.rcxReasonConfirming,
  'switch.better-tier' => l.rcxReasonBetterTier(
    own?.call(_arg(r, 'tier')) ?? _arg(r, 'tier'),
  ),
  'switch.faster' => l.rcxReasonFaster(_arg(r, 'from'), _intArg(r, 'gainMs')),
  'select.failed' => l.rcxReasonSelectFailed,
  'until.check-better-tier' => l.rcxUntilCheck(_arg(r, 'node')),
  'until.dwell' => l.rcxUntilDwell(
    _arg(r, 'node'),
    (_intArg(r, 'seconds') / 60).ceil(),
  ),
  'until.confirm' => l.rcxUntilConfirm(_arg(r, 'node'), _intArg(r, 'gainMs')),
  'pool.no-match' => l.rcxExcludedNoMatch,
  'pool.excluded' => l.rcxExcludedByProfile,
  'pool.unroutable' => l.rcxExcludedUnroutable,
  'cooldown' => l.rcxExcludedCooldown,
  'dead' => l.rcxHealthDead,
  'no-tier' => l.rcxExcludedNoTier,
  'profile.missing' => l.rcxProblemProfileMissing(_arg(r, 'profile')),
  'profile.invalid' => l.rcxProblemProfileInvalid(_arg(r, 'error')),
  'group.unavailable' => l.rcxProblemGroupUnavailable,
  'group.empty' => l.rcxProblemGroupEmpty,
  'network.suspect' => l.rcxReasonNetworkSuspect,
  'network.changed' => l.rcxReasonNetworkChanged,
  'network.kind' when _arg(r, 'kind').isEmpty => l.rcxReasonNetworkChanged,
  'network.kind' => l.rcxNetwork(rcxKindLabel(l, _arg(r, 'kind'), own: own)),
  'hold.paused' => l.rcxReasonPaused(
    rcxKindLabel(l, _arg(r, 'kind'), own: own),
  ),
  'profile.consent' => l.rcxNeedsConsent,
  'pending' => l.rcxExcludedPending,
  'split.on' => l.rcxReasonSplitOn,
  'split.off' => l.rcxReasonSplitOff,
  'store.failed' => l.rcxProblemStoreFailed(_arg(r, 'error')),
  'failure.confirmed' => l.rcxHealthDead,
  'pin.manual' || 'pin.requested' => l.rcxPinnedLabel,
  'auto.requested' => l.rcxBackToAuto,
  'change.requested' => l.rcxChangeServer,
  'hold.fixed' => l.rcxReasonFixed(_arg(r, 'node')),
  'switch.fixed' => l.rcxReasonSwitchFixed(_arg(r, 'node')),
  'fixed.missing' => l.rcxReasonFixedMissing(_arg(r, 'node')),
  'hold.idle' => l.rcxReasonIdle(rcxModeLabel(_arg(r, 'mode'))),
  'route.name-taken' => l.rcxReasonRouteNameTaken(_arg(r, 'route')),
  'route.to-missing' => l.rcxReasonRouteToMissing(
    _arg(r, 'route'),
    _arg(r, 'to'),
  ),
  'route.invalid' => l.rcxReasonRouteInvalid(
    _arg(r, 'route'),
    _arg(r, 'error'),
  ),
  'route.not-rule-mode' => l.rcxHubRoutesRuleOnly(
    rcxModeLabel(_arg(r, 'mode')),
  ),
  _ => r.code,
};

String rcxJournalText(AppLocalizations l, RcxJournalEntry entry) {
  return switch (entry.kind) {
    'switch' =>
      '${entry.from} → ${entry.to}: ${rcxReasonText(l, entry.reason)}',
    'failure' => l.rcxJournalFailure(entry.from),
    'pin' => l.rcxPinned(entry.to),
    'mode' => l.rcxJournalMode(
      rcxModeLabel(entry.from),
      rcxModeLabel(entry.to),
    ),
    _ => rcxReasonText(l, entry.reason),
  };
}
