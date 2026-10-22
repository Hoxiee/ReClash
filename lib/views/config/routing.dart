import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/proxies/routing.dart';
import 'package:reclash/views/proxies/routing_import.dart';
import 'package:reclash/views/proxies/routing_scenario.dart';
import 'package:reclash/views/proxies/routing_studio.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Auto routing as a whole: the scenario that drives the connection, the
/// smart groups with their detailed settings, and the library of scenarios
/// and group profiles, where both are made and edited.
class RoutingSettingsView extends ConsumerWidget {
  const RoutingSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final status = ref.watch(rcxStatusStateProvider);
    final hasProfile = ref.watch(
      currentProfileProvider.select((profile) => profile != null),
    );
    final locale = Localizations.localeOf(context).toString();
    return CommonScaffold(
      title: l.rcxTitle,
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.add,
          label: l.rcxNewScenario,
          onPressed: () => unawaited(openScenarioEditor(context)),
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.add,
          label: l.rcxNewProfile,
          onPressed: () => unawaited(openRoutingStudio(context)),
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.importFile,
          label: l.import,
          onPressed: () => unawaited(pickRoutingImport(context)),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 20),
        children: [
          if (hasProfile) _ScenarioSection(library: library, status: status),
          if (status != null && status.groups.isNotEmpty)
            generateSection(
              title: l.rcxSmartGroups,
              footer: status.energy.requests > 0
                  ? l.rcxEnergyToday(
                      status.energy.requests,
                      status.energy.bytes.traffic.show,
                      status.energy.capBytes.traffic.show,
                    )
                  : null,
              items: [
                for (final group in status.groups)
                  DecorationListItem(
                    title: EmojiText(group.name),
                    subtitle: EmojiText(
                      [
                        if (group.fixed.isNotEmpty)
                          l.rcxFixedOn(group.fixed)
                        else
                          _titleOf(library, group.profile, locale) ??
                              group.profileTitle,
                        if (group.program.isNotEmpty &&
                            group.program != group.name)
                          rcxProgramLabel(l, group.program),
                        if (group.idle)
                          l.rcxReasonIdle(rcxModeLabel(status.tunnelMode)),
                      ].join(' · '),
                    ),
                    onPressed: () => BaseNavigator.push<void>(
                      context,
                      RoutingGroupSettings(groupName: group.name),
                    ),
                    trailing: const GlyphIcon(AppGlyphs.chevronForward),
                  ),
              ],
            ),
          _LibrarySection(
            title: l.rcxScenarios,
            footer: l.rcxScenariosHint,
            profiles: [
              for (final p in library)
                if (p.isScenario) p,
            ],
          ),
          _LibrarySection(
            title: l.rcxGroupProfiles,
            footer: l.rcxGroupProfilesHint,
            profiles: [
              for (final p in library)
                if (!p.isScenario) p,
            ],
          ),
        ],
      ),
    );
  }
}

String? _titleOf(List<RcxProfileInfo> library, String id, String locale) =>
    library.where((p) => p.id == id).firstOrNull?.displayTitle(locale);

/// The scenario this subscription runs, picked from a menu, with what it
/// holds now on this network.
class _ScenarioSection extends ConsumerWidget {
  const _ScenarioSection({required this.library, required this.status});

  final List<RcxProfileInfo> library;
  final RcxStatus? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final action = ref.read(rcxRoutingActionProvider.notifier);
    final scenario = status?.scenario;
    final scenarios = [
      for (final p in library)
        if (p.isScenario) p.id,
    ];
    final current = scenario?.id ?? '';
    final options = [
      '',
      ...scenarios,
      if (current.isNotEmpty && !scenarios.contains(current)) current,
    ];
    final info = library
        .where((p) => p.isScenario && p.id == current)
        .firstOrNull;
    String own(String text) => info?.localize(text, locale) ?? text;
    final kind = scenario?.network?.kind;
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
        generateSection(
          title: l.rcxAutoControl,
          footer: switch (scenario?.problem) {
            final problem? when problem.code != 'profile.consent' =>
              rcxReasonText(l, problem),
            _ => l.rcxAutoControlHint,
          },
          items: [
            ListItem<String>.options(
              title: Text(l.rcxScenario),
              options: options,
              value: current,
              textBuilder: (id) => id.isEmpty
                  ? l.rcxScenarioOff
                  : _titleOf(library, id, locale) ?? id,
              onChanged: (id) {
                if (id != current) {
                  unawaited(action.setScenario(id.isEmpty ? null : id));
                }
              },
            ),
            if (scenario != null && scenario.problem == null)
              DecorationListItem(
                title: Text(
                  [
                    if (kind != null)
                      l.rcxNetwork(rcxKindLabel(l, kind, own: own)),
                    l.rcxModeIs(rcxModeLabel(status!.tunnelMode)),
                  ].join(' · '),
                ),
                subtitle: Text(
                  scenario.manual
                      ? l.rcxModeManualNow
                      : scenario.mode.isEmpty
                      ? l.rcxModeYours
                      : l.rcxModeByScenario,
                ),
              ),
            if (scenario != null && scenario.manual && scenario.holdsMode)
              FormRow(
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

/// A library list; the user's own entries edit in place, the others open
/// as a copy to edit.
class _LibrarySection extends ConsumerWidget {
  const _LibrarySection({
    required this.title,
    required this.footer,
    required this.profiles,
  });

  final String title;
  final String footer;
  final List<RcxProfileInfo> profiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final action = ref.read(rcxRoutingActionProvider.notifier);

    Future<String?> sourceOf(RcxProfileInfo info) async {
      final result = await action.studio({
        'op': 'source',
        'id': info.id,
        if (info.isScenario) 'kind': 'scenario',
      });
      return result?.text;
    }

    Future<void> open(RcxProfileInfo info, {required bool copy}) async {
      final name = info.id.split('/').last;
      final mine = info.source == 'user';
      if (mine && !copy) {
        return info.isScenario
            ? openScenarioEditor(context, name: name)
            : openRoutingStudio(context, name: name);
      }
      final text = await sourceOf(info);
      if (text == null || !context.mounted) return;
      final from = mine ? '' : info.id;
      return info.isScenario
          ? openScenarioEditor(context, text: text, from: from)
          : openRoutingStudio(context, text: text, from: from);
    }

    Future<void> export(RcxProfileInfo info) async {
      final text = await sourceOf(info);
      if (text == null || !context.mounted) return;
      await showRoutingExport(
        context,
        text: text,
        title: info.displayTitle(locale),
      );
    }

    return generateSection(
      title: title,
      footer: footer,
      items: [
        for (final info in profiles)
          ContextMenuRegion(
            menuItems: [
              if (info.source == 'user')
                CommonPopupMenuItem(
                  glyph: AppGlyphs.edit,
                  label: l.edit,
                  onPressed: () => unawaited(open(info, copy: false)),
                ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.copy,
                label: l.rcxDuplicate,
                onPressed: () => unawaited(open(info, copy: true)),
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.export,
                label: l.rcxExport,
                onPressed: () => unawaited(export(info)),
              ),
              if (info.source == 'user')
                CommonPopupMenuItem(
                  glyph: AppGlyphs.delete,
                  label: l.delete,
                  danger: true,
                  onPressed: () => unawaited(
                    action.saveProfile(info.id.split('/').last, null),
                  ),
                ),
            ],
            child: DecorationListItem(
              invalid: info.error.isNotEmpty,
              title: EmojiText(info.displayTitle(locale)),
              subtitle: Text(
                info.error.isNotEmpty
                    ? info.error
                    : [
                        rcxSourceLabel(l, info.source),
                        if (!info.isScenario) rcxLevelLabel(l, info.level),
                        if (info.consent.isNotEmpty) l.rcxNeedsConsent,
                      ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => unawaited(open(info, copy: false)),
              trailing: GlyphIcon(
                info.source == 'user'
                    ? AppGlyphs.chevronForward
                    : AppGlyphs.copy,
              ),
            ),
          ),
      ],
    );
  }
}

/// The detailed settings of one smart group: its profile, the servers it
/// may use, how eagerly it switches and checks, and direct split.
class RoutingGroupSettings extends ConsumerStatefulWidget {
  const RoutingGroupSettings({super.key, required this.groupName});

  final String groupName;

  @override
  ConsumerState<RoutingGroupSettings> createState() =>
      _RoutingGroupSettingsState();
}

class _RoutingGroupSettingsState extends ConsumerState<RoutingGroupSettings> {
  late final _pattern = TextEditingController(
    text: rcxPatternOf(
      ref.read(rcxGroupProvider(widget.groupName))?.binding.pool.include,
    ),
  );

  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  void _update(RcxBinding Function(RcxBinding) update) {
    final group = ref.read(rcxGroupProvider(widget.groupName));
    unawaited(
      ref
          .read(rcxRoutingActionProvider.notifier)
          .setBinding(
            widget.groupName,
            update(rcxSavedBinding(ref, widget.groupName, group)),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final group = ref.watch(rcxGroupProvider(widget.groupName));
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();
    final binding = rcxSavedBinding(ref, widget.groupName, group);
    final names = ref.watch(
      groupsProvider.select(
        (groups) => [
          for (final proxy
              in groups.getGroup(widget.groupName)?.all ?? const <Proxy>[])
            proxy.name,
        ],
      ),
    );
    final profiles = [
      for (final info in library)
        if (!info.isScenario && info.error.isEmpty) info.id,
    ];
    final selected = binding.profile ?? group?.profile ?? rcxDefaultProfile;
    final pattern = _pattern.text.trim();
    final matched = rcxCountMatches(pattern, names);
    return CommonScaffold(
      title: widget.groupName,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 20),
        children: [
          generateSection(
            title: l.rcxProfile,
            footer: group != null && group.program.isNotEmpty
                ? l.rcxScenarioDrives(
                    ref.watch(rcxStatusStateProvider)?.scenario?.title ?? '',
                  )
                : null,
            items: [
              ListItem<String>.options(
                title: Text(l.rcxProfile),
                options: [
                  if (!profiles.contains(selected)) selected,
                  ...profiles,
                ],
                value: selected,
                textBuilder: (id) => _titleOf(library, id, locale) ?? id,
                onChanged: (id) => _update((b) => b.copyWith(profile: id)),
              ),
            ],
          ),
          generateSection(
            title: l.rcxServers,
            footer: matched == null
                ? l.rcxPatternInvalid
                : l.rcxServersMatch(matched, names.length),
            items: [
              FormRow(
                title: l.rcxServersPattern,
                trailing: FormRowTextField(
                  controller: _pattern,
                  autocorrect: false,
                  hintText: l.rcxAnyServer,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (value) {
                    if (rcxCountMatches(value.trim(), names) != null) {
                      _update(
                        (b) => b.copyWith(
                          pool: b.pool.copyWith(
                            include: rcxIncludeOf(value.trim()),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          generateSection(
            title: l.rcxBehaviour,
            items: [
              ListItem<String>.options(
                title: Text(l.rcxSwitching),
                options: rcxFeels,
                value: binding.feel ?? 'balanced',
                textBuilder: (v) => rcxFeelLabel(l, v),
                onChanged: (v) => _update((b) => b.copyWith(feel: v)),
              ),
              ListItem<String>.options(
                title: Text(l.rcxChecks),
                options: rcxEnergies,
                value: binding.energy ?? 'balanced',
                textBuilder: (v) => rcxEnergyLabel(l, v),
                onChanged: (v) => _update((b) => b.copyWith(energy: v)),
              ),
            ],
          ),
          if (group != null && group.directSplit.isNotEmpty)
            generateSection(
              title: l.network,
              footer: l.rcxDirectSplitHint,
              items: [
                ListItem.toggle(
                  title: Text(l.rcxDirectSplit),
                  subtitle: binding.directSplit
                      ? Text(
                          group.directSplit == 'active'
                              ? l.rcxDirectSplitActive
                              : l.rcxDirectSplitStandby,
                        )
                      : null,
                  value: binding.directSplit,
                  onChanged: (on) =>
                      _update((b) => b.copyWith(directSplit: on)),
                ),
              ],
            ),
          if (group?.source == 'user')
            generateSection(
              items: [
                DecorationListItem(
                  title: Text(l.rcxTurnOff),
                  onPressed: () {
                    unawaited(
                      ref
                          .read(rcxRoutingActionProvider.notifier)
                          .setBinding(widget.groupName, null),
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// The auto-routing entry of the advanced settings.
Widget routingSettingsItem(AppLocalizations l) => ListItem.open(
  title: Text(l.rcxTitle),
  leading: const GlyphIcon(AppGlyphs.shuffle),
  widget: const RoutingSettingsView(),
);
