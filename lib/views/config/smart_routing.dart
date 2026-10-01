import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_diag.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_ladder_editor.dart';
import 'package:reclash/widgets/widgets.dart';

part 'smart_routing_expert.dart';
part 'smart_routing_markers.dart';
part 'smart_routing_service_route.dart';

const _dwellChoices = [30, 90, 180, 600];
const _waveChoices = [4, 8, 12, 20];
const _ceilingChoices = [200, 300, 450, 650, 900];
const _degradeChoices = [30, 60, 90, 120];
const _proofTtlChoices = [15, 20, 30, 45, 60];
const _switchImproveMsChoices = [0, 20, 30, 50, 80, 120];
const _switchImprovePctChoices = [0, 10, 15, 20, 30];
const _latencyStepChoices = [0, 10, 20, 30, 50];

/// Where each strategy sits on the three axes a user actually weighs, on a 1..3
/// scale. Presentation only: the engine ranks by pacing numbers, not by these.
typedef _StrategyAxes = ({int stability, int speed, int data});

_StrategyAxes _axesOf(SmartRoutingStrategy strategy) => switch (strategy) {
  SmartRoutingStrategy.stable => (stability: 3, speed: 1, data: 2),
  SmartRoutingStrategy.balanced => (stability: 2, speed: 2, data: 2),
  SmartRoutingStrategy.lowestLatency => (stability: 1, speed: 3, data: 1),
  SmartRoutingStrategy.saver => (stability: 1, speed: 1, data: 3),
};

/// One shared consent so the wizard and settings toggles warn identically.
Future<bool> confirmSmartRoutingExperimental(BuildContext context) {
  final appLocalizations = context.appLocalizations;
  return dialogs.showExperimentalNotice(
    context: context,
    message: appLocalizations.smartRoutingExperimentalNotice,
    confirmText: appLocalizations.experimentalEnable,
  );
}

/// Matches the tools detail pane cap so the studio fills that column instead of
/// narrowing a second time inside it.
const _studioReadingWidth = 840.0;

/// The one screen that is the smart-routing editor. Its spine is the decision
/// pipeline in the order the engine runs it, but it reads as a settings menu,
/// not one endless scroll: the decision core a user actually tunes — strategy,
/// the admission gates, the comparison ladder — stays inline, and every later
/// stage (switch triggers, pace, the measured signals, service routes,
/// behaviour, backup, the log) is a drill-in row that opens its own page. It is
/// pure settings; the live read-out lives on the dashboard, not here. A preset
/// only seeds these values — nothing here stops being editable because a
/// strategy filled it in.
class RoutingStudioView extends ConsumerStatefulWidget {
  const RoutingStudioView({super.key});

  @override
  ConsumerState<RoutingStudioView> createState() => _RoutingStudioViewState();
}

class _RoutingStudioViewState extends ConsumerState<RoutingStudioView> {
  void _update(SmartRoutingProps Function(SmartRoutingProps) f) {
    ref.read(smartRoutingSettingProvider.notifier).update(f);
  }

  Future<void> _handleEnabled(BuildContext context, bool value) async {
    if (value && !await confirmSmartRoutingExperimental(context)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    _update((state) => state.withUnlocked(value));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    return CommonScaffold(
      title: appLocalizations.smartRouting,
      floatBody: true,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _studioReadingWidth),
          child: SettingsScrollView(slivers: _masterSlivers(context, props)),
        ),
      ),
    );
  }

  List<Widget> _masterSlivers(BuildContext context, SmartRoutingProps props) {
    final appLocalizations = context.appLocalizations;
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Builder(
          builder: (context) => SizedBox(height: context.appBarInset),
        ),
      ),
      SettingSection.sliver(
        top: 16,
        items: [
          DecorationListItem.toggle(
            title: Row(
              spacing: AppSpacing.sm,
              children: [
                Flexible(child: Text(appLocalizations.smartRouting)),
                const ExperimentalBadge(),
              ],
            ),
            subtitle: Text(appLocalizations.smartRoutingDesc),
            value: props.unlocked,
            onChanged: (value) => _handleEnabled(context, value),
          ),
        ],
      ),
    ];

    if (props.unlocked) {
      slivers.addAll([
        _strategySection(context, props),
        _admissionSection(context, props),
        const RoutingLadderEditorSliver(),
        _pipelineRowsSection(context),
      ]);
    } else {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: NullStatus(
              label: appLocalizations.smartRoutingOffHint,
              illustration: NullStatusIllustration.routing,
            ),
          ),
        ),
      );
    }
    slivers.add(const SettingBottomInset.sliver());
    return slivers;
  }

  Widget _strategySection(BuildContext context, SmartRoutingProps props) {
    final appLocalizations = context.appLocalizations;
    return SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingStrategy,
      actions: [
        if (!props.matchesStrategy) ...[
          const SizedBox(width: AppSpacing.sm),
          CommonMinFilledButtonTheme(
            child: FilledButton.tonal(
              onPressed: () => _handleReseedStrategy(context),
              child: Text(appLocalizations.reset),
            ),
          ),
        ],
      ],
      items: [
        for (final strategy in SmartRoutingStrategy.values)
          _StrategyCard(
            strategy: strategy,
            selected: props.strategy == strategy,
            adjusted: props.strategy == strategy && !props.matchesStrategy,
            onPressed: () => _update((state) => state.applyStrategy(strategy)),
          ),
      ],
    );
  }

  Future<void> _handleReseedStrategy(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      dangerous: true,
      title: appLocalizations.reset,
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (confirmed != true) {
      return;
    }
    _update((state) => state.applyStrategy(state.strategy));
  }

  Widget _admissionSection(BuildContext context, SmartRoutingProps props) {
    final appLocalizations = context.appLocalizations;
    return SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingKeyAdmission,
      items: [
        DecorationListItem.toggle(
          leading: const GlyphIcon(AppGlyphs.router),
          search: const SettingSearch(),
          title: Text(appLocalizations.smartRoutingDomestic),
          subtitle: Text(appLocalizations.smartRoutingDomesticDesc),
          value: props.allowDomesticLastResort,
          onChanged: (value) => _update(
            (state) => state.copyWith(allowDomesticLastResort: value),
          ),
        ),
        DecorationListItem.toggle(
          leading: const GlyphIcon(AppGlyphs.bolt),
          search: const SettingSearch(),
          title: Text(appLocalizations.smartRoutingRequireUdp),
          subtitle: Text(appLocalizations.smartRoutingRequireUdpDesc),
          value: props.requireUdp,
          onChanged: (value) =>
              _update((state) => state.copyWith(requireUdp: value)),
        ),
      ],
    );
  }

  Widget _pipelineRowsSection(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SettingSection.sliver(
      bottom: 24,
      items: [
        _drillRow(
          context,
          glyph: AppGlyphs.swap,
          title: appLocalizations.smartRoutingTriggers,
          subtitle: appLocalizations.smartRoutingTriggersDesc,
          page: _RoutingSubPage(
            title: appLocalizations.smartRoutingTriggers,
            builder: _triggersSlivers,
          ),
        ),
        _drillRow(
          context,
          glyph: AppGlyphs.speed,
          title: appLocalizations.smartRoutingPacing,
          subtitle: appLocalizations.smartRoutingPacingDesc,
          page: _RoutingSubPage(
            title: appLocalizations.smartRoutingPacing,
            builder: _pacingSlivers,
          ),
        ),
        _drillRow(
          context,
          glyph: AppGlyphs.signalChart,
          title: appLocalizations.smartRoutingSignals,
          subtitle: appLocalizations.smartRoutingSignalsDesc,
          page: _RoutingSubPage(
            title: appLocalizations.smartRoutingSignals,
            builder: _signalsSlivers,
          ),
        ),
        _drillRow(
          context,
          glyph: AppGlyphs.split,
          title: appLocalizations.smartRoutingServiceRoutes,
          subtitle: appLocalizations.smartRoutingServiceRoutesDesc,
          page: _RoutingSubPage(
            title: appLocalizations.smartRoutingServiceRoutes,
            builder: _serviceRoutesSlivers,
          ),
        ),
        _drillRow(
          context,
          glyph: AppGlyphs.sliders,
          title: appLocalizations.smartRoutingBehaviour,
          subtitle: appLocalizations.smartRoutingBehaviourDesc,
          page: _RoutingSubPage(
            title: appLocalizations.smartRoutingBehaviour,
            builder: _behaviourSlivers,
          ),
        ),
        _drillRow(
          context,
          glyph: AppGlyphs.save,
          title: appLocalizations.smartRoutingBackup,
          subtitle: appLocalizations.smartRoutingBackupDesc,
          page: _RoutingSubPage(
            title: appLocalizations.smartRoutingBackup,
            builder: _backupSlivers,
          ),
        ),
        _drillRow(
          context,
          glyph: AppGlyphs.history,
          title: appLocalizations.smartRoutingLog,
          subtitle: appLocalizations.smartRoutingLogDesc,
          page: const RoutingDiagView(),
        ),
      ],
    );
  }

  Widget _drillRow(
    BuildContext context, {
    required Glyph glyph,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return DecorationListItem.open(
      leading: GlyphIcon(glyph),
      title: Text(title),
      subtitle: Text(subtitle),
      blur: false,
      forceFull: false,
      maxWidth: 400,
      widget: page,
    );
  }
}

/// Each pipeline stage past the inline core opens as its own reading-width page,
/// so a drill row lands on the same centered column the studio uses rather than
/// a bare full-bleed list. The stage builds its slivers against the live props,
/// so an edit made on the page settles straight back into the shared config.
class _RoutingSubPage extends ConsumerWidget {
  const _RoutingSubPage({required this.title, required this.builder});

  final String title;
  final List<Widget> Function(BuildContext, WidgetRef, SmartRoutingProps)
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(smartRoutingSettingProvider);
    return CommonScaffold(
      title: title,
      floatBody: true,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _studioReadingWidth),
          child: SettingsScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) => SizedBox(height: context.appBarInset),
                ),
              ),
              ...builder(context, ref, props),
              const SettingBottomInset.sliver(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A drill row that opens one more stage page, for pages that are themselves an
/// index of sub-stages (Signals splits its measured inputs this way). Mirrors
/// the master list's own [_RoutingStudioViewState._drillRow] so a nested row
/// reads and opens exactly like a top-level one.
Widget _routingStageRow(
  BuildContext context, {
  required Glyph glyph,
  required String title,
  required String subtitle,
  required List<Widget> Function(BuildContext, WidgetRef, SmartRoutingProps)
  builder,
}) {
  return DecorationListItem.open(
    leading: GlyphIcon(glyph),
    title: Text(title),
    subtitle: Text(subtitle),
    blur: false,
    forceFull: false,
    maxWidth: 400,
    widget: _RoutingSubPage(title: title, builder: builder),
  );
}

List<Widget> _serviceRoutesSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  final profile = ref.watch(currentProfileProvider);
  final servicePolicies = {
    for (final policy in profile?.serviceRoutePolicies ?? const [])
      policy.capabilityId: policy,
  };
  final laneStatusById = {
    for (final lane in ref.watch(
      smartRoutingStatusProvider.select(
        (status) => status?.lanes ?? const <RcxLaneStatus>[],
      ),
    ))
      lane.id: lane,
  };
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingServiceRoutes,
      subTitle: appLocalizations.smartRoutingServiceRoutesDesc,
      items: [
        for (final capabilityId in effectiveCapabilityIds(
          profile?.capabilityManifest,
        ))
          _ServiceRouteItem(
            capabilityId: capabilityId,
            policy:
                servicePolicies[capabilityId] ??
                ServiceRoutePolicy(
                  capabilityId: capabilityId,
                  fallback: defaultFallbackFor(capabilityId),
                ),
            laneStatus: laneStatusById[capabilityId],
            manifest: profile?.capabilityManifest,
            manualSelectors: profile?.manualCapabilitySelectors ?? const [],
          ),
      ],
    ),
  ];
}

List<Widget> _behaviourSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  final diagnostics = ref.watch(
    appSettingProvider.select((state) => state.smartRoutingDiagnostics),
  );
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingBehaviour,
      subTitle: appLocalizations.smartRoutingBehaviourDesc,
      items: [
        DecorationListItem.toggle(
          leading: const GlyphIcon(AppGlyphs.pin),
          search: const SettingSearch(),
          title: Text(appLocalizations.smartRoutingManualHold),
          subtitle: Text(appLocalizations.smartRoutingManualHoldDesc),
          value: props.respectPick,
          onChanged: (value) => ref
              .read(smartRoutingSettingProvider.notifier)
              .update((state) => state.copyWith(respectPick: value)),
        ),
        DecorationListItem.toggle(
          leading: const GlyphIcon(AppGlyphs.logs),
          search: const SettingSearch(),
          title: Text(appLocalizations.smartRoutingDiagnostics),
          subtitle: Text(appLocalizations.smartRoutingDiagnosticsDesc),
          value: diagnostics,
          onChanged: (value) => ref
              .read(appSettingProvider.notifier)
              .update(
                (state) => state.copyWith(smartRoutingDiagnostics: value),
              ),
        ),
      ],
    ),
  ];
}

List<Widget> _backupSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingBackup,
      subTitle: appLocalizations.smartRoutingBackupDesc,
      items: [
        DecorationListItem(
          minVerticalPadding: 8,
          leading: const GlyphIcon(AppGlyphs.share),
          search: const SettingSearch(),
          title: Text(appLocalizations.smartRoutingExport),
          subtitle: Text(appLocalizations.smartRoutingExportDesc),
          onPressed: () => _handleExport(context, props),
        ),
        DecorationListItem(
          minVerticalPadding: 8,
          leading: const GlyphIcon(AppGlyphs.document),
          search: const SettingSearch(),
          title: Text(appLocalizations.smartRoutingImport),
          subtitle: Text(appLocalizations.smartRoutingImportDesc),
          onPressed: () => _handleImport(context, ref),
        ),
      ],
    ),
  ];
}

/// A strategy is a pace, not a region. The card stays a one-line choice; only
/// the selected one expands with the tradeoff meters, so the list reads as four
/// options rather than a wall of numbers.
class _StrategyCard extends StatelessWidget {
  const _StrategyCard({
    required this.strategy,
    required this.selected,
    required this.adjusted,
    required this.onPressed,
  });

  final SmartRoutingStrategy strategy;
  final bool selected;
  final bool adjusted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return DecorationListItem(
      minVerticalPadding: 10,
      isSelected: selected,
      leading: GlyphIcon(
        selected ? AppGlyphs.radio : AppGlyphs.circleOutline,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Row(
        spacing: 8,
        children: [
          Flexible(child: Text(strategy.label)),
          if (adjusted)
            AppTag(
              appLocalizations.smartRoutingStrategyPace,
              foreground: colorScheme.onTertiaryContainer,
              background: colorScheme.tertiaryContainer,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(strategy.description),
          if (selected) _TradeoffBars(axes: _axesOf(strategy)),
        ],
      ),
      onPressed: onPressed,
    );
  }
}

class _TradeoffBars extends StatelessWidget {
  const _TradeoffBars({required this.axes});

  final _StrategyAxes axes;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      children: [
        Expanded(
          child: _meter(
            context,
            appLocalizations.smartRoutingAxisStability,
            axes.stability,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _meter(
            context,
            appLocalizations.smartRoutingAxisSpeed,
            axes.speed,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _meter(
            context,
            appLocalizations.smartRoutingAxisData,
            axes.data,
          ),
        ),
      ],
    );
  }

  Widget _meter(BuildContext context, String label, int level) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Row(
          spacing: 3,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 14,
                height: 5,
                decoration: BoxDecoration(
                  color: i < level
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.full,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StringListItem extends ConsumerWidget {
  const _StringListItem({
    required this.glyph,
    required this.title,
    required this.desc,
    required this.value,
    required this.write,
    this.itemValidator,
    this.itemMaxLength,
    this.search,
  });

  final Glyph glyph;
  final String title;
  final String desc;
  final List<String> value;
  final SmartRoutingProps Function(SmartRoutingProps, List<String>) write;
  final String? Function(String item)? itemValidator;
  final int? itemMaxLength;
  final SettingSearch? search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecorationListItem.open(
      leading: GlyphIcon(glyph),
      title: Text(title),
      subtitle: Text(value.isEmpty ? desc : value.join(', ')),
      blur: false,
      forceFull: false,
      preferSheet: true,
      maxWidth: 400,
      widget: ListInputPage(
        title: title,
        items: value,
        titleBuilder: Text.new,
        itemValidator: itemValidator,
        itemMaxLength: itemMaxLength,
      ),
      onChanged: (items) => ref
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => write(state, List<String>.from(items as List))),
    );
  }
}
