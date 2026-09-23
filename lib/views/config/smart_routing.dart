import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview.dart';
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
        const SettingSection.sliver(items: [_LiveStatusPanel()]),
        _strategySection(context, ref, props),
        _behaviourSection(context, ref, props),
        _regionSection(context, ref, props),
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
              leading: const Icon(Icons.tune_rounded),
              title: Text(appLocalizations.advancedConfig),
              subtitle: Text(appLocalizations.advancedConfigDesc),
              blur: false,
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
      body: SettingsScrollView(
        slivers: [...slivers, const SettingBottomInset.sliver()],
      ),
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
          const SizedBox(width: 8),
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

  Future<void> _handleReseedStrategy(BuildContext context, WidgetRef ref) async {
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

  Widget _regionSection(
    BuildContext context,
    WidgetRef ref,
    SmartRoutingProps props,
  ) {
    final appLocalizations = context.appLocalizations;
    final flag = countryCodeToEmoji(_presetCode(props.preset));
    return SettingSection.sliver(
      title: appLocalizations.smartRoutingPreset,
      items: [
        DecorationListItem(
          minVerticalPadding: 8,
          leading: flag == null
              ? const Icon(Icons.public_rounded)
              : Text(flag, style: const TextStyle(fontSize: 24)),
          title: Text(
            props.matchesPreset
                ? props.preset.label
                : appLocalizations.smartRoutingPresetEdited(props.preset.label),
          ),
          subtitle: Text(appLocalizations.smartRoutingRegionManaged),
          trailing: props.matchesPreset
              ? null
              : CommonMinFilledButtonTheme(
                  child: FilledButton.tonal(
                    onPressed: () => _handleReseedRegion(context, ref, props),
                    child: Text(appLocalizations.reset),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleReseedRegion(
    BuildContext context,
    WidgetRef ref,
    SmartRoutingProps props,
  ) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      dangerous: true,
      title: appLocalizations.smartRoutingResetSection,
      message: TextSpan(text: appLocalizations.smartRoutingResetSectionDesc),
    );
    if (confirmed != true) {
      return;
    }
    _update(ref, (state) => state.applyPreset(state.preset));
  }
}

String _presetCode(SmartRoutingPreset preset) => switch (preset) {
  SmartRoutingPreset.russia => 'RU',
  SmartRoutingPreset.iran => 'IR',
  SmartRoutingPreset.china => 'CN',
  SmartRoutingPreset.off => '',
};

/// The compact read-out of what the engine is doing right now. It never restates
/// the full diagnostics page: it names the format and the chosen node and hands
/// off to the overview for the candidate table and the evidence behind it.
class _LiveStatusPanel extends ConsumerWidget {
  const _LiveStatusPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final status = ref.watch(smartRoutingStatusProvider);
    final scanning = status?.deep == true || status?.searching == true;
    final node = status?.node.trim() ?? '';
    final delay = status?.delay ?? 0;
    final reason = status?.reason ?? '';
    final format = networkFormatOf(status?.terrain ?? 'unknown');
    final chosen = node.isEmpty
        ? appLocalizations.smartRoutingChosenNone
        : delay > 0
        ? '$node · ${appLocalizations.smartRoutingMillis(delay)}'
        : node;
    return DecorationListItem(
      minVerticalPadding: 10,
      leading: Icon(_formatIcon(format), color: colorScheme.primary),
      title: Text(status == null ? appLocalizations.smartRoutingEmpty : format.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(chosen),
          if (status != null)
            Text(
              appLocalizations.smartRoutingServersCount(
                status.eligible,
                status.candidates,
              ),
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (reason.isNotEmpty)
            Text(
              routingReasonLabel(appLocalizations, reason),
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          CommonMinIconButtonTheme(
            child: IconButton.filledTonal(
              tooltip: scanning
                  ? appLocalizations.smartRoutingDeepScanRunning
                  : appLocalizations.smartRoutingDeepScan,
              onPressed: scanning
                  ? null
                  : () => ref.read(coreHandlerProvider).smartRoutingDeepScan(),
              icon: scanning
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.travel_explore_rounded),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
        ],
      ),
      onPressed: () => showExtend(
        context,
        builder: (_) => const RoutingOverviewView(),
      ),
    );
  }
}

IconData _formatIcon(NetworkFormat format) => switch (format) {
  NetworkFormat.open => Icons.public_rounded,
  NetworkFormat.restricted => Icons.shield_rounded,
  NetworkFormat.portal => Icons.wifi_lock_rounded,
  NetworkFormat.offline => Icons.cloud_off_rounded,
  NetworkFormat.unknown => Icons.help_outline_rounded,
};

/// A strategy is a pace, not a region, so the card shows the tradeoff it makes
/// and the pacing numbers it seeds rather than a bare radio label.
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
      leading: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
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
                borderRadius: BorderRadius.circular(8),
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
          _TradeoffBars(axes: _axesOf(strategy)),
          _PacingChips(pacing: strategy.pacing),
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
        const SizedBox(width: 16),
        Expanded(
          child: _meter(
            context,
            appLocalizations.smartRoutingAxisSpeed,
            axes.speed,
          ),
        ),
        const SizedBox(width: 16),
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
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PacingChips extends StatelessWidget {
  const _PacingChips({required this.pacing});

  final SmartRoutingPacing pacing;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _chip(context, appLocalizations.smartRoutingSeconds(pacing.dwellSeconds)),
        _chip(context, appLocalizations.smartRoutingWaveNodes(pacing.waveWidth)),
        _chip(context, appLocalizations.smartRoutingMillis(pacing.absCeilingMs)),
      ],
    );
  }

  Widget _chip(BuildContext context, String text) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: context.textTheme.labelSmall),
    );
  }
}

class _StringListItem extends ConsumerWidget {
  const _StringListItem({
    required this.title,
    required this.desc,
    required this.value,
    required this.write,
  });

  final String title;
  final String desc;
  final List<String> value;
  final SmartRoutingProps Function(SmartRoutingProps, List<String>) write;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecorationListItem.open(
      title: Text(title),
      subtitle: Text(value.isEmpty ? desc : value.join(', ')),
      blur: false,
      widget: ListInputPage(title: title, items: value, titleBuilder: Text.new),
      onChanged: (items) => ref
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => write(state, List<String>.from(items as List))),
    );
  }
}
