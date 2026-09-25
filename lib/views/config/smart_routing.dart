import 'dart:convert';
import 'package:reclash/icons/icons.dart';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/options_picker_page.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'smart_routing_service_route.dart';
part 'smart_routing_markers.dart';
part 'smart_routing_expert.dart';

const _dwellChoices = [30, 90, 180, 600];
const _waveChoices = [4, 8, 12, 20];
const _ceilingChoices = [200, 300, 450, 650, 900];
const _degradeChoices = [30, 60, 90, 120];
const _proofTtlChoices = [15, 20, 30, 45, 60];

/// Where each strategy sits on the three axes a user actually weighs, on a 1..3
/// scale. Presentation only: the engine ranks by pacing numbers, not by these.
typedef _StrategyAxes = ({int stability, int speed, int data});

_StrategyAxes _axesOf(SmartRoutingStrategy strategy) => switch (strategy) {
  SmartRoutingStrategy.stable => (stability: 3, speed: 1, data: 2),
  SmartRoutingStrategy.balanced => (stability: 2, speed: 2, data: 2),
  SmartRoutingStrategy.lowestLatency => (stability: 1, speed: 3, data: 1),
  SmartRoutingStrategy.saver => (stability: 1, speed: 1, data: 3),
};

/// Everything a preset seeds is editable here, because a preset is named defaults
/// and nothing more: canaries and markers go stale, and a user on a network the
/// region table never modelled has to be able to correct them.
class SmartRoutingView extends ConsumerWidget {
  const SmartRoutingView({super.key});

  void _update(WidgetRef ref, SmartRoutingProps Function(SmartRoutingProps) f) {
    ref.read(smartRoutingSettingProvider.notifier).update(f);
  }

  void _handleEnabled(WidgetRef ref, bool value) {
    _update(ref, (state) => state.withEnabled(value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
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
    final slivers = <Widget>[
      SettingSection.sliver(
        top: 16,
        items: [
          DecorationListItem.toggle(
            title: Text(appLocalizations.smartRouting),
            subtitle: Text(appLocalizations.smartRoutingDesc),
            value: props.enabled,
            onChanged: (value) => _handleEnabled(ref, value),
          ),
        ],
      ),
    ];

    if (props.enabled) {
      slivers.addAll([
        _regionSection(context, props),
        _strategySection(context, ref, props),
        _behaviourSection(context, ref, props),
        _diagnosticsSection(context, ref),
        SettingSection.sliver(
          title: appLocalizations.smartRoutingServiceRoutes,
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
        SettingSection.sliver(
          bottom: 24,
          items: [
            DecorationListItem.open(
              leading: const GlyphIcon(AppGlyphs.sliders),
              title: Text(appLocalizations.advancedConfig),
              subtitle: Text(appLocalizations.advancedConfigDesc),
              blur: false,
              forceFull: false,
              maxWidth: 400,
              widget: const _AdvancedRoutingPage(),
            ),
          ],
        ),
      ]);
    } else {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: NullStatus(label: appLocalizations.smartRoutingOffHint),
          ),
        ),
      );
    }

    return CommonScaffold(
      title: appLocalizations.smartRouting,
      floatBody: true,
      body: SettingsScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: context.appBarInset)),
          ...slivers,
          const SettingBottomInset.sliver(),
        ],
      ),
    );
  }

  Widget _regionSection(BuildContext context, SmartRoutingProps props) {
    final appLocalizations = context.appLocalizations;
    return SettingSection.sliver(
      items: [
        DecorationListItem.open(
          leading: const GlyphIcon(AppGlyphs.globeSearch),
          title: Text(appLocalizations.smartRoutingRegionCard),
          subtitle: Text(appLocalizations.smartRoutingRegionCardDesc),
          blur: false,
          forceFull: false,
          maxWidth: 400,
          widget: const _RegionDetailsPage(),
        ),
      ],
    );
  }

  Widget _strategySection(
    BuildContext context,
    WidgetRef ref,
    SmartRoutingProps props,
  ) {
    final appLocalizations = context.appLocalizations;
    return SettingSection.sliver(
      title: appLocalizations.smartRoutingStrategy,
      actions: [
        if (!props.matchesStrategy) ...[
          const SizedBox(width: AppSpacing.sm),
          CommonMinFilledButtonTheme(
            child: FilledButton.tonal(
              onPressed: () => _handleReseedStrategy(context, ref),
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
            onPressed: () =>
                _update(ref, (state) => state.applyStrategy(strategy)),
          ),
      ],
    );
  }

  Future<void> _handleReseedStrategy(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      dangerous: true,
      title: appLocalizations.reset,
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (confirmed != true) {
      return;
    }
    _update(ref, (state) => state.applyStrategy(state.strategy));
  }

  Widget _behaviourSection(
    BuildContext context,
    WidgetRef ref,
    SmartRoutingProps props,
  ) {
    final appLocalizations = context.appLocalizations;
    return SettingSection.sliver(
      title: appLocalizations.smartRoutingBehaviour,
      items: [
        DecorationListItem.toggle(
          title: Text(appLocalizations.smartRoutingDomestic),
          subtitle: Text(appLocalizations.smartRoutingDomesticDesc),
          value: props.allowDomesticLastResort,
          onChanged: (value) => _update(
            ref,
            (state) => state.copyWith(allowDomesticLastResort: value),
          ),
        ),
        DecorationListItem.toggle(
          title: Text(appLocalizations.smartRoutingRequireUdp),
          subtitle: Text(appLocalizations.smartRoutingRequireUdpDesc),
          value: props.requireUdp,
          onChanged: (value) =>
              _update(ref, (state) => state.copyWith(requireUdp: value)),
        ),
        DecorationListItem.toggle(
          title: Text(appLocalizations.smartRoutingManualHold),
          subtitle: Text(appLocalizations.smartRoutingManualHoldDesc),
          value: props.respectPick,
          onChanged: (value) =>
              _update(ref, (state) => state.copyWith(respectPick: value)),
        ),
      ],
    );
  }

  Widget _diagnosticsSection(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final enabled = ref.watch(
      appSettingProvider.select((state) => state.smartRoutingDiagnostics),
    );
    return SettingSection.sliver(
      title: appLocalizations.smartRoutingDiagnostics,
      items: [
        DecorationListItem.toggle(
          title: Text(appLocalizations.smartRoutingDiagnostics),
          subtitle: Text(appLocalizations.smartRoutingDiagnosticsDesc),
          value: enabled,
          onChanged: (value) => ref
              .read(appSettingProvider.notifier)
              .update(
                (state) => state.copyWith(smartRoutingDiagnostics: value),
              ),
        ),
      ],
    );
  }
}

/// Read-only tour of what the active region sets up. It reads the live props, so
/// a region that seeds name hints and breaker patterns shows them filled while
/// one that does not shows them as unused — the difference the user asked to see.
/// Nothing here is a control; every value is edited under Advanced configuration.
class _RegionDetailsPage extends ConsumerWidget {
  const _RegionDetailsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    final region = AppRegion.fromPreset(props.preset);
    final facets = <(String, List<String>)>[
      (appLocalizations.smartRoutingCensor, props.censorCountries),
      (appLocalizations.smartRoutingCanariesForeign, props.canaryForeign),
      (appLocalizations.smartRoutingCanariesDomestic, props.canaryDomestic),
      (
        appLocalizations.smartRoutingMarkersOpen,
        [for (final marker in props.openMarkers) marker.url],
      ),
      (
        appLocalizations.smartRoutingMarkersDomestic,
        [for (final marker in props.domesticMarkers) marker.url],
      ),
      (
        appLocalizations.smartRoutingMarkersLocal,
        [for (final marker in props.localMarkers) marker.url],
      ),
      (appLocalizations.smartRoutingNameHints, props.nameHints),
      (appLocalizations.smartRoutingBreakerPatterns, props.breakerPatterns),
    ];
    return CommonScaffold(
      title: region.label(context),
      floatBody: true,
      body: SettingsListView(
        children: [
          SettingSection(
            top: 16,
            title: appLocalizations.smartRoutingRegionSeeds,
            subTitle: appLocalizations.smartRoutingRegionHow,
            items: [
              for (final (label, values) in facets)
                DecorationListItem(
                  title: Text(label),
                  subtitle: Text(
                    values.isEmpty
                        ? appLocalizations.smartRoutingRegionUnused
                        : values.join(', '),
                  ),
                ),
            ],
          ),
          SettingSection(
            bottom: 24,
            items: [
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.compose),
                title: Text(appLocalizations.smartRoutingRegionEditNote),
              ),
            ],
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: AppRadius.sm,
              ),
              child: Text(
                appLocalizations.smartRoutingStrategyPace,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
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
    required this.title,
    required this.desc,
    required this.value,
    required this.write,
    this.itemValidator,
    this.itemMaxLength,
  });

  final String title;
  final String desc;
  final List<String> value;
  final SmartRoutingProps Function(SmartRoutingProps, List<String>) write;
  final String? Function(String item)? itemValidator;
  final int? itemMaxLength;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecorationListItem.open(
      title: Text(title),
      subtitle: Text(value.isEmpty ? desc : value.join(', ')),
      blur: false,
      forceFull: false,
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
