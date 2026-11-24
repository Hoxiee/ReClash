import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/proxies/routing.dart';
import 'package:reclash/views/proxies/routing_import.dart';
import 'package:reclash/views/proxies/routing_scenario.dart';
import 'package:reclash/views/proxies/routing_studio.dart';
import 'package:reclash/views/proxies/routing_strategy.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The running scenario, its routes, and the switch that turns it on.
class RoutingScenariosView extends ConsumerStatefulWidget {
  const RoutingScenariosView({super.key, this.route});

  /// A route of the running scenario to open in its editor.
  final String? route;

  /// Opens [route] in the hub [context] is in, else in a new one.
  static void showRoute(BuildContext context, String route) {
    final hub = context.findAncestorStateOfType<_RoutingScenariosViewState>();
    if (hub != null) {
      hub._showRoute(route);
    } else {
      unawaited(
        BaseNavigator.push<void>(context, RoutingScenariosView(route: route)),
      );
    }
  }

  @override
  ConsumerState<RoutingScenariosView> createState() =>
      _RoutingScenariosViewState();
}

class _RoutingScenariosViewState extends ConsumerState<RoutingScenariosView> {
  late String? _route = widget.route;

  void _showRoute(String route) => setState(() => _route = route);

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final hasProfile = ref.watch(
      currentProfileProvider.select((profile) => profile != null),
    );
    final status = ref.watch(rcxStatusStateProvider);
    return CommonScaffold(
      title: l.rcxScenarios,
      body: switch (status) {
        _ when !hasProfile => NullStatus(
          label: l.rcxHubNoProfile,
          description: l.rcxHubNoProfileHint,
          illustration: NullStatusIllustration.profile,
        ),
        null => NullStatus(
          label: l.rcxHubNeedsCore,
          illustration: NullStatusIllustration.proxies,
        ),
        final status => RunningScenarioList(
          leading: const [_ScenarioControls()],
          trailing: [
            generateSection(
              items: [
                ListItem(
                  title: Text(l.rcxHubLibrary),
                  leading: const GlyphIcon(AppGlyphs.layers),
                  trailing: const DisclosureIndicator(),
                  onTap: () => unawaited(
                    BaseNavigator.push<void>(
                      context,
                      const RoutingLibraryView(scenarios: true),
                    ),
                  ),
                ),
              ],
            ),
          ],
          route: _route,
          onRouteShown: () => setState(() => _route = null),
          routeLine: (name) => switch (status.groups
              .where((group) => group.name == name)
              .firstOrNull) {
            final group? => _groupLine(l, group, ''),
            null => null,
          },
        ),
      },
    );
  }
}

/// A hub page's scroll view, under the app bar and above the floating bar.
class _HubList extends StatefulWidget {
  const _HubList({required this.id, required this.children});

  final String id;
  final List<Widget> children;

  @override
  State<_HubList> createState() => _HubListState();
}

class _HubListState extends State<_HubList> {
  late final ScrollController _controller = sheetScrollController(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    key: PageStorageKey('routing-${widget.id}'),
    controller: _controller,
    padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.appBarInset, bottom: context.bottomInset + 32) +
        context.bodyInsets,
    children: widget.children,
  );
}

String _profileTitle(List<RcxProfileInfo> library, String id, String locale) =>
    library.where((p) => p.id == id).firstOrNull?.displayTitle(locale) ?? id;

String _description(RcxProfileInfo? info, String locale) =>
    info == null ? '' : info.localize(info.description, locale);

/// A waiting consent is a question for the user, not a fault to flag red.
bool _isFault(RcxReason? problem) =>
    problem != null && problem.code != 'profile.consent';

String _groupLine(AppLocalizations l, RcxGroupStatus group, String mode) {
  if (group.problem case final problem?) return rcxReasonText(l, problem);
  if (group.idle) return l.rcxReasonIdle(rcxModeLabel(mode));
  if (group.fixed.isNotEmpty) return l.rcxFixedOn(group.fixed);
  final current = group.current;
  return [
    if (current != null) ...[
      current.name,
      if (current.exit.isNotEmpty)
        if (rcxCountryLabel(current.exit) case final country
            when !current.name.contains(country.split(' ').first))
          country,
      if (current.latencyMs > 0) '${current.latencyMs} ms',
    ],
    if (group.decision.tier.isNotEmpty) group.decision.tier,
  ].join(' · ');
}

class _ScenarioControls extends ConsumerWidget {
  const _ScenarioControls();

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    List<RcxProfileInfo> library,
    String? current,
  ) async {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final profileId = ref.read(currentProfileIdProvider);
    final byId = {
      for (final p in library)
        if (p.isScenario && p.error.isEmpty) p.id: p,
    };
    final picked = await showInSheet<String>(
      context,
      builder: (sheetContext) => SelectionSheet<String>(
        title: l.rcxHubChange,
        sections: [
          for (final source in const ['user', 'provider', 'builtin'])
            if (byId.values.where((p) => p.source == source).toList()
                case final profiles when profiles.isNotEmpty)
              SelectionSection(
                label: rcxSourceLabel(l, source),
                items: [for (final p in profiles) p.id],
                subtitleBuilder: (_, id) {
                  final text = _description(byId[id], locale);
                  return text.isEmpty ? null : text;
                },
              ),
        ],
        labelBuilder: (id) => _profileTitle(library, id, locale),
        selectedOf: (_) => current,
        onSelected: (id) => Navigator.of(sheetContext).pop(id),
      ),
    );
    if (picked == null ||
        !context.mounted ||
        ref.read(currentProfileIdProvider) != profileId ||
        picked == ref.read(rcxStatusStateProvider)?.scenario?.id) {
      return;
    }
    await ref.read(rcxRoutingActionProvider.notifier).setScenario(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final status = ref.watch(rcxStatusStateProvider);
    final action = ref.read(rcxRoutingActionProvider.notifier);
    if (status == null) return const SizedBox.shrink();
    final scenario = status.scenario;
    final current = scenario?.id ?? '';
    final saved = ref.watch(
      currentRoutingLayerProvider.select((layer) => layer.scenario),
    );
    final canChoose = library.any((p) => p.isScenario && p.error.isEmpty);
    final resumable = library.any(
      (p) => p.isScenario && p.id == saved && p.error.isEmpty,
    );
    final info = library
        .where((p) => p.isScenario && p.id == current)
        .firstOrNull;
    String own(String text) => info?.localize(text, locale) ?? text;
    final kind = scenario?.network?.kind;
    final description = _description(info, locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scenario?.problem case RcxReason(
          code: 'profile.consent',
          :final args,
        ))
          RoutingConsentSection(
            hosts: [
              for (final host in args['hosts'] as List? ?? const []) '$host',
            ],
            title: info?.displayTitle(locale) ?? current,
          ),
        generateAnimatedSection(
          footer: switch (scenario?.problem) {
            final problem? when problem.code != 'profile.consent' =>
              rcxReasonText(l, problem),
            _ => scenario == null ? l.rcxHubOffHint : null,
          },
          items: [
            ListItem.toggle(
              key: const ValueKey('master'),
              title: Text(l.rcxHubAuto),
              value: scenario != null,
              onChanged: scenario == null && !canChoose
                  ? null
                  : (on) => unawaited(
                      !on
                          ? action.setScenario(null)
                          : resumable
                          ? action.setScenario(saved)
                          : _choose(context, ref, library, saved),
                    ),
            ),
            if (scenario != null)
              DecorationListItem(
                key: const ValueKey('scenario'),
                title: EmojiText(
                  info?.displayTitle(locale) ??
                      (scenario.title.isEmpty ? current : scenario.title),
                ),
                subtitle: description.isEmpty ? null : EmojiText(description),
                onPressed: canChoose
                    ? () => unawaited(_choose(context, ref, library, current))
                    : null,
                trailing: canChoose ? const DisclosureIndicator() : null,
              ),
            if (scenario != null && scenario.problem == null)
              DecorationListItem(
                key: const ValueKey('live'),
                title: Text(l.rcxModeIs(rcxModeLabel(status.tunnelMode))),
                subtitle: Text(
                  [
                    if (kind != null)
                      l.rcxNetwork(rcxKindLabel(l, kind, own: own)),
                    scenario.manual
                        ? l.rcxModeManualNow
                        : scenario.mode.isEmpty
                        ? l.rcxModeYours
                        : l.rcxModeByScenario,
                  ].join('\n'),
                ),
              ),
            if (scenario != null && scenario.manual && scenario.holdsMode)
              FormRow(
                key: const ValueKey('back-to-auto'),
                title: l.rcxModeBackToAuto,
                onPressed: () => unawaited(action.setManualMode(false)),
                trailing: const GlyphIcon(AppGlyphs.sparkle),
              ),
          ],
        ),
      ],
    );
  }
}

/// Every group the app selects for, and the way into the behaviour library.
class ScriptedGroupsView extends ConsumerWidget {
  const ScriptedGroupsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final status = ref.watch(rcxStatusStateProvider);
    return CommonScaffold(
      title: l.rcxSmartGroups,
      body: _HubList(
        id: 'scripted-groups',
        children: [
          if (status == null)
            ListFooter(text: l.rcxHubNeedsCore)
          else ...[
            generateSection(
              items: [
                if (ref.watch(canScriptGroupsProvider))
                  ListItem(
                    title: Text(l.rcxAddGroup),
                    leading: const GlyphIcon(AppGlyphs.add),
                    trailing: const DisclosureIndicator(),
                    onTap: () => unawaited(showNewStrategyGroup(context)),
                  ),
                ListItem(
                  title: Text(l.rcxGroupProfiles),
                  leading: const GlyphIcon(AppGlyphs.layers),
                  trailing: const DisclosureIndicator(),
                  onTap: () => unawaited(
                    BaseNavigator.push<void>(
                      context,
                      const RoutingLibraryView(scenarios: false),
                    ),
                  ),
                ),
              ],
            ),
            _active(context, status),
          ],
        ],
      ),
    );
  }

  /// Every group the app selects for: a connected strategy or an engine
  /// binding. One group can carry either, never both in this list.
  Widget _active(BuildContext context, RcxStatus status) {
    final l = context.appLocalizations;
    final routeNames = {
      for (final route in status.scenario?.routes ?? const <RcxRouteStatus>[])
        route.name,
    };
    final groups = {
      for (final group in status.groups)
        if (!group.route && !routeNames.contains(group.name)) group.name: group,
    };
    final names = {...status.strategies.keys, ...groups.keys}.toList()..sort();
    if (names.isEmpty) return ListFooter(text: l.rcxHubGroupsEmpty);
    Widget row(String name) {
      if (status.strategies[name] case final report?) {
        final fault = report.issue.isNotEmpty
            ? l.rcxProblemProfileInvalid(report.issue)
            : report.empty
            ? l.rcxProblemGroupEmpty
            : null;
        return DecorationListItem(
          invalid: fault != null,
          title: EmojiText(name),
          subtitle: EmojiText(
            fault ??
                [
                  rcxSourceLabel(l, report.source),
                  if (report.selected.isNotEmpty) report.selected,
                ].join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: () => unawaited(showGroupBehaviour(context, name)),
          trailing: const DisclosureIndicator(),
        );
      }
      final group = groups[name]!;
      return DecorationListItem(
        invalid: _isFault(group.problem),
        title: EmojiText(name),
        subtitle: EmojiText(
          _groupLine(l, group, status.tunnelMode),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () => unawaited(showRoutingSheet(context, name)),
        trailing: const DisclosureIndicator(),
      );
    }

    return generateSection(
      title: l.rcxActiveScriptedGroups,
      footer: status.energy.requests > 0
          ? l.rcxEnergyToday(
              status.energy.requests,
              status.energy.bytes.traffic.show,
              status.energy.capBytes.traffic.show,
            )
          : null,
      items: [for (final name in names) row(name)],
    );
  }
}

/// Scenarios or behaviours from every source; the user's own entries edit in
/// place, the others open as a copy.
class RoutingLibraryView extends ConsumerStatefulWidget {
  const RoutingLibraryView({super.key, required this.scenarios});

  final bool scenarios;

  @override
  ConsumerState<RoutingLibraryView> createState() => _RoutingLibraryViewState();
}

class _RoutingLibraryViewState extends ConsumerState<RoutingLibraryView> {
  RcxRoutingAction get _action => ref.read(rcxRoutingActionProvider.notifier);

  Future<String?> _sourceOf(RcxProfileInfo info) async {
    final result = await _action.studio({
      'op': 'source',
      'id': info.id,
      if (info.isScenario) 'kind': 'scenario',
    });
    return result?.text;
  }

  Future<void> _open(RcxProfileInfo info, {required bool copy}) async {
    final name = info.id.split('/').last;
    final mine = info.source == 'user';
    if (mine && !copy) {
      return info.isScenario
          ? openScenarioEditor(context, name: name)
          : openRoutingStudio(context, name: name);
    }
    final text = await _sourceOf(info);
    if (text == null || !mounted) return;
    final from = mine ? '' : info.id;
    return info.isScenario
        ? openScenarioEditor(context, text: text, from: from)
        : openRoutingStudio(context, text: text, from: from);
  }

  Future<void> _export(RcxProfileInfo info) async {
    final text = await _sourceOf(info) ?? '';
    if (!mounted) return;
    await exportRoutingDocument(
      context,
      ref,
      id: info.id,
      kind: info.isScenario ? 'scenario' : '',
      text: text,
      title: info.displayTitle(Localizations.localeOf(context).toString()),
    );
  }

  Future<void> _delete(RcxProfileInfo info) async {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final confirmed = await dialogs.showMessage(
      title: l.delete,
      destructive: true,
      message: TextSpan(text: l.rcxDeleteProfile(info.displayTitle(locale))),
    );
    if (confirmed != true) return;
    await _action.saveProfile(info.id.split('/').last, null);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final scenarios = widget.scenarios;
    final active = scenarios
        ? ref.watch(
            rcxStatusStateProvider.select((status) => status?.scenario?.id),
          )
        : null;
    final profiles = [
      for (final p in library)
        if (p.isScenario == scenarios) p,
    ];
    return CommonScaffold(
      title: scenarios ? l.rcxHubLibrary : l.rcxGroupProfiles,
      body: _HubList(
        id: scenarios ? 'scenarios' : 'behaviours',
        children: [
          generateSection(
            items: [
              ListItem(
                leading: const GlyphIcon(AppGlyphs.add),
                title: Text(scenarios ? l.rcxNewScenario : l.rcxNewProfile),
                trailing: const DisclosureIndicator(),
                onTap: () => unawaited(
                  scenarios
                      ? openScenarioEditor(context)
                      : openRoutingStudio(context),
                ),
              ),
              ListItem(
                leading: const GlyphIcon(AppGlyphs.importFile),
                title: Text(l.import),
                onTap: () => unawaited(pickRoutingImport(context)),
              ),
            ],
          ),
          generateAnimatedSection(
            footer: scenarios ? l.rcxScenariosHint : l.rcxGroupProfilesHint,
            items: [
              for (final info in profiles)
                ContextMenuRegion(
                  key: ValueKey(info.id),
                  menuItems: [
                    CommonPopupMenuItem(
                      glyph: AppGlyphs.copy,
                      label: l.rcxDuplicate,
                      onPressed: () => unawaited(_open(info, copy: true)),
                    ),
                    CommonPopupMenuItem(
                      glyph: AppGlyphs.export,
                      label: l.rcxExport,
                      onPressed: () => unawaited(_export(info)),
                    ),
                    if (info.source == 'user')
                      CommonPopupMenuItem(
                        glyph: AppGlyphs.delete,
                        label: l.delete,
                        danger: true,
                        onPressed: () => unawaited(_delete(info)),
                      ),
                  ],
                  child: _LibraryCard(
                    info: info,
                    locale: locale,
                    active: info.id == active,
                    onPressed: () => unawaited(_open(info, copy: false)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.info,
    required this.locale,
    required this.active,
    required this.onPressed,
  });

  final RcxProfileInfo info;
  final String locale;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final description = _description(info, locale);
    return DecorationListItem(
      invalid: info.error.isNotEmpty,
      isSelected: active,
      title: EmojiText(info.displayTitle(locale)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.error.isNotEmpty)
            Text(info.error, maxLines: 3, overflow: TextOverflow.ellipsis)
          else if (description.isNotEmpty)
            EmojiText(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              MetaChip(label: rcxSourceLabel(l, info.source)),
              if (!info.isScenario)
                MetaChip(label: rcxLevelLabel(l, info.level)),
              if (info.consent.isNotEmpty) MetaChip(label: l.rcxNeedsConsent),
            ],
          ),
        ],
      ),
      onPressed: onPressed,
      trailing: active ? const SelectionCheck() : const DisclosureIndicator(),
    );
  }
}
