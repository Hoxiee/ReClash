import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/proxies/routing.dart';
import 'package:reclash/views/proxies/routing_advanced.dart';
import 'package:reclash/views/proxies/routing_import.dart';
import 'package:reclash/views/proxies/routing_scenario.dart';
import 'package:reclash/views/proxies/routing_studio.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Auto routing as a whole on one page: the running scenario and its routes,
/// the groups auto routing drives, and the way into the library.
class RoutingSettingsView extends ConsumerStatefulWidget {
  const RoutingSettingsView({super.key, this.route});

  /// A route of the running scenario to open in its editor.
  final String? route;

  /// Opens [route] in the hub [context] is in, else in a new one.
  static void showRoute(BuildContext context, String route) {
    final hub = context.findAncestorStateOfType<_RoutingSettingsViewState>();
    if (hub != null) {
      hub._showRoute(route);
    } else {
      unawaited(
        BaseNavigator.push<void>(context, RoutingSettingsView(route: route)),
      );
    }
  }

  @override
  ConsumerState<RoutingSettingsView> createState() =>
      _RoutingSettingsViewState();
}

class _RoutingSettingsViewState extends ConsumerState<RoutingSettingsView> {
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
      title: l.rcxTitle,
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
          leading: const [_HubHeader()],
          trailing: const [
            _HubGroups(),
            _LibraryEntry(),
            RoutingAdvancedToggle(),
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

/// The switch, the running scenario and the mode it holds.
class _HubHeader extends ConsumerWidget {
  const _HubHeader();

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    List<RcxProfileInfo> library,
    String current,
  ) async {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final byId = {
      for (final p in library)
        if (p.isScenario) p.id: p,
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
    if (picked == null || picked == current) return;
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
              onChanged: (on) => unawaited(
                action.setScenario(on ? rcxScenarioToTurnOn(ref) : null),
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
                onPressed: () =>
                    unawaited(_choose(context, ref, library, current)),
                trailing: Text(
                  l.rcxHubChange,
                  style: AppTextStyle.body
                      .of(context)
                      .copyWith(color: context.colorScheme.primary),
                ),
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

/// The smart groups auto routing drives outside the scenario's routes.
class _HubGroups extends ConsumerWidget {
  const _HubGroups();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final status = ref.watch(rcxStatusStateProvider);
    final layer = ref.watch(currentRoutingLayerProvider);
    if (status == null) return const SizedBox.shrink();
    final routeNames = {
      for (final route in status.scenario?.routes ?? const <RcxRouteStatus>[])
        route.name,
    };
    final groups = [
      for (final group in status.groups)
        if (!group.route && !routeNames.contains(group.name)) group,
    ];
    if (groups.isEmpty && layer.scenarioOff) return const SizedBox.shrink();
    return generateSection(
      title: l.rcxSmartGroups,
      footer: status.energy.requests > 0
          ? l.rcxEnergyToday(
              status.energy.requests,
              status.energy.bytes.traffic.show,
              status.energy.capBytes.traffic.show,
            )
          : groups.isEmpty
          ? l.rcxHubGroupsEmpty
          : null,
      items: [
        for (final group in groups)
          DecorationListItem(
            invalid: _isFault(group.problem),
            title: EmojiText(group.name),
            subtitle: EmojiText(
              _groupLine(l, group, status.tunnelMode),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onPressed: () => unawaited(showRoutingSheet(context, group.name)),
            trailing: const DisclosureIndicator(),
          ),
      ],
    );
  }
}

class _LibraryEntry extends StatelessWidget {
  const _LibraryEntry();

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return generateSection(
      items: [
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.layers),
          title: Text(l.rcxHubLibrary),
          subtitle: Text(l.rcxHubLibraryHint),
          onPressed: () => unawaited(
            BaseNavigator.push<void>(context, const RoutingLibraryView()),
          ),
          trailing: const DisclosureIndicator(),
        ),
      ],
    );
  }
}

/// Scenarios and group profiles from every source; the user's own entries
/// edit in place, the others open as a copy to edit.
class RoutingLibraryView extends ConsumerStatefulWidget {
  const RoutingLibraryView({super.key});

  @override
  ConsumerState<RoutingLibraryView> createState() => _RoutingLibraryViewState();
}

class _RoutingLibraryViewState extends ConsumerState<RoutingLibraryView> {
  bool _scenarios = true;

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

  Future<void> _run(RcxProfileInfo info) async {
    final running = ref.read(rcxStatusStateProvider)?.scenario?.id;
    if (info.id == running) return;
    await _action.setScenario(info.id);
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
    final active = ref.watch(
      rcxStatusStateProvider.select((status) => status?.scenario?.id),
    );
    final profiles = [
      for (final p in library)
        if (p.isScenario == _scenarios) p,
    ];
    return CommonScaffold(
      title: l.rcxHubLibrary,
      body: _HubList(
        id: 'library',
        children: [
          generateSection(
            items: [
              ListItem(
                leading: const GlyphIcon(AppGlyphs.add),
                title: Text(l.rcxNewScenario),
                trailing: const GlyphIcon(AppGlyphs.chevronForward),
                onTap: () => unawaited(openScenarioEditor(context)),
              ),
              ListItem(
                leading: const GlyphIcon(AppGlyphs.add),
                title: Text(l.rcxNewProfile),
                trailing: const GlyphIcon(AppGlyphs.chevronForward),
                onTap: () => unawaited(openRoutingStudio(context)),
              ),
              ListItem(
                leading: const GlyphIcon(AppGlyphs.importFile),
                title: Text(l.import),
                onTap: () => unawaited(pickRoutingImport(context)),
              ),
            ],
          ),
          const ListSectionGap(),
          SegmentedControl<bool>(
            segments: [(true, l.rcxScenarios), (false, l.rcxGroupProfiles)],
            value: _scenarios,
            onChanged: (value) => setState(() => _scenarios = value),
          ),
          const SizedBox(height: 8),
          generateAnimatedSection(
            footer: _scenarios ? l.rcxScenariosHint : l.rcxGroupProfilesHint,
            items: [
              for (final info in profiles)
                ContextMenuRegion(
                  key: ValueKey(info.id),
                  menuItems: [
                    if (info.source == 'user')
                      CommonPopupMenuItem(
                        glyph: AppGlyphs.edit,
                        label: l.edit,
                        onPressed: () => unawaited(_open(info, copy: false)),
                      ),
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
                    active: info.isScenario && info.id == active,
                    onPressed: info.isScenario && info.error.isEmpty
                        ? () => unawaited(_run(info))
                        : () => unawaited(_open(info, copy: false)),
                    onEdit: info.isScenario
                        ? () => unawaited(_open(info, copy: false))
                        : null,
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
    this.onEdit,
  });

  final RcxProfileInfo info;
  final String locale;
  final bool active;
  final VoidCallback onPressed;

  /// Opens the entry to edit when a tap does something else, as running a
  /// scenario does.
  final VoidCallback? onEdit;

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
      trailing: switch (onEdit) {
        final onEdit? => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (active) const SelectionCheck(),
            IconButton(
              tooltip: info.source == 'user' ? l.edit : l.rcxDuplicate,
              onPressed: onEdit,
              icon: const GlyphIcon(AppGlyphs.edit),
            ).withAppTooltip(),
          ],
        ),
        null => active ? const SelectionCheck() : null,
      },
    );
  }
}
