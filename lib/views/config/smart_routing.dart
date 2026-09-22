import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'smart_routing_service_route.dart';
part 'smart_routing_markers.dart';

const _dwellChoices = [30, 90, 180, 600];
const _waveChoices = [4, 8, 12, 20];

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

  Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      dangerous: true,
      title: appLocalizations.reset,
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (confirmed != true) {
      return;
    }
    _update(
      ref,
      (state) => state.applyPreset(state.preset).applyStrategy(state.strategy),
    );
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
        SettingSection.sliver(
          title: appLocalizations.smartRoutingStrategy,
          actions: [
            const SizedBox(width: 8),
            CommonMinFilledButtonTheme(
              child: FilledButton.tonal(
                onPressed: props.matchesPreset && props.matchesStrategy
                    ? null
                    : () => _handleReset(context, ref),
                child: Text(appLocalizations.reset),
              ),
            ),
          ],
          items: [
            for (final strategy in SmartRoutingStrategy.values)
              DecorationListItem(
                minVerticalPadding: 8,
                isSelected: props.strategy == strategy,
                leading: Icon(
                  props.strategy == strategy
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: props.strategy == strategy
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                title: Text(strategy.label),
                subtitle: Text(strategy.description),
                onPressed: () =>
                    _update(ref, (state) => state.applyStrategy(strategy)),
              ),
          ],
        ),
        SettingSection.sliver(
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
            DecorationListItem.options(
              title: Text(appLocalizations.smartRoutingDwell),
              subtitle: Text(appLocalizations.smartRoutingDwellDesc),
              dialogTitle: appLocalizations.smartRoutingDwell,
              options: _dwellChoices,
              value: props.dwellSeconds,
              textBuilder: (value) =>
                  appLocalizations.smartRoutingSeconds(value as int),
              onChanged: (value) {
                if (value == null) return;
                _update(
                  ref,
                  (state) => state.copyWith(dwellSeconds: value as int),
                );
              },
            ),
          ],
        ),
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
}

/// The expert knobs live one level down so the main screen stays a short list
/// of the choices most users make. Everything here is still preset-seeded and
/// editable; the engine reads the same provider whether the page is open or not.
class _AdvancedRoutingPage extends ConsumerWidget {
  const _AdvancedRoutingPage();

  void _update(WidgetRef ref, SmartRoutingProps Function(SmartRoutingProps) f) {
    ref.read(smartRoutingSettingProvider.notifier).update(f);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    return CommonScaffold(
      title: appLocalizations.advancedConfig,
      body: SettingsListView(
        children: [
          SettingSection(
            top: 16,
            title: appLocalizations.smartRoutingProbing,
            items: [
              DecorationListItem.options(
                title: Text(appLocalizations.smartRoutingWave),
                subtitle: Text(appLocalizations.smartRoutingWaveDesc),
                dialogTitle: appLocalizations.smartRoutingWave,
                options: _waveChoices,
                value: props.waveWidth,
                textBuilder: (value) =>
                    appLocalizations.smartRoutingWaveNodes(value as int),
                onChanged: (value) {
                  if (value == null) return;
                  _update(
                    ref,
                    (state) => state.copyWith(waveWidth: value as int),
                  );
                },
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingDetection,
            items: [
              _StringListItem(
                title: appLocalizations.smartRoutingCanariesForeign,
                desc: appLocalizations.smartRoutingCanariesForeignDesc,
                value: props.canaryForeign,
                write: (state, value) => state.copyWith(canaryForeign: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingCanariesDomestic,
                desc: appLocalizations.smartRoutingCanariesDomesticDesc,
                value: props.canaryDomestic,
                write: (state, value) => state.copyWith(canaryDomestic: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingCensor,
                desc: appLocalizations.smartRoutingCensorDesc,
                value: props.censorCountries,
                write: (state, value) => state.copyWith(censorCountries: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingBreakerPatterns,
                desc: appLocalizations.smartRoutingBreakerPatternsDesc,
                value: props.breakerPatterns,
                write: (state, value) => state.copyWith(breakerPatterns: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingAvoidCountries,
                desc: appLocalizations.smartRoutingAvoidCountriesDesc,
                value: props.avoidCountries,
                write: (state, value) => state.copyWith(avoidCountries: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingCountryEchoes,
                desc: appLocalizations.smartRoutingCountryEchoesDesc,
                value: props.countryEchoes,
                write: (state, value) => state.copyWith(countryEchoes: value),
              ),
              _RulesItem(rules: props.nodeRules),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingMarkers,
            items: [
              _MarkersItem(
                title: appLocalizations.smartRoutingMarkersOpen,
                desc: appLocalizations.smartRoutingMarkersOpenDesc,
                markers: props.openMarkers,
                domestic: false,
              ),
              _MarkersItem(
                title: appLocalizations.smartRoutingMarkersDomestic,
                desc: appLocalizations.smartRoutingMarkersDomesticDesc,
                markers: props.domesticMarkers,
                domestic: true,
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingRanking,
            bottom: 24,
            items: [
              DecorationListItem(
                minVerticalPadding: 8,
                title: Text(appLocalizations.smartRoutingRankOrder),
                subtitle: Text(
                  [
                    appLocalizations.smartRoutingKeyVerdict,
                    appLocalizations.smartRoutingKeyMisfit,
                    appLocalizations.smartRoutingKeyEvidence,
                    appLocalizations.smartRoutingKeyBand,
                  ].join(' → '),
                ),
              ),
              DecorationListItem(
                minVerticalPadding: 8,
                title: Text(appLocalizations.smartRoutingKeyBand),
                subtitle: Text(appLocalizations.smartRoutingRankingDesc),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingLatencyBands,
                desc: appLocalizations.smartRoutingLatencyBandsDesc,
                value: props.latencyBands
                    .map((edge) => edge.toString())
                    .toList(),
                write: (state, value) => state.copyWith(
                  latencyBands: value
                      .map(int.tryParse)
                      .whereType<int>()
                      .where((edge) => edge > 0)
                      .toList(),
                ),
              ),
            ],
          ),
          const SettingBottomInset(),
        ],
      ),
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
