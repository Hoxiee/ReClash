import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          title: appLocalizations.smartRoutingPreset,
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
            DecorationListItem.options(
              title: Text(appLocalizations.smartRoutingStrategy),
              subtitle: Text(
                props.matchesStrategy
                    ? props.strategy.description
                    : appLocalizations.smartRoutingStrategyEdited(
                        props.strategy.label,
                      ),
              ),
              dialogTitle: appLocalizations.smartRoutingStrategy,
              options: SmartRoutingStrategy.values,
              value: props.strategy,
              textBuilder: (value) => (value as SmartRoutingStrategy).label,
              subtitleBuilder: (value) =>
                  (value as SmartRoutingStrategy).description,
              onChanged: (value) {
                if (value == null) return;
                _update(
                  ref,
                  (state) => state.applyStrategy(value as SmartRoutingStrategy),
                );
              },
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
        SettingSection.sliver(
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
          ],
        ),
        SettingSection.sliver(
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
        SettingSection.sliver(
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

typedef _LaneView = ({IconData icon, Color color, String text});

/// One reading of a lane for the row and its detail header: the toggle state,
/// then whichever live verdict the engine last reported. Without a status the
/// route is enabled but the core has not spoken yet, so it reads as pending
/// rather than as working or broken.
_LaneView _laneView(
  BuildContext context, {
  required bool enabled,
  required ServiceRouteFallback fallback,
  required RcxLaneStatus? status,
  required int selectorCount,
}) {
  final appLocalizations = context.appLocalizations;
  final colorScheme = context.colorScheme;
  final muted = colorScheme.onSurfaceVariant;
  if (!enabled) {
    return (
      icon: Icons.circle_outlined,
      color: muted,
      text: selectorCount == 0
          ? appLocalizations.smartRoutingServiceNoCandidates
          : appLocalizations.smartRoutingServiceCandidates(selectorCount),
    );
  }
  switch (status?.state) {
    case 'active':
      final node = status!.node.trim();
      return (
        icon: Icons.bolt_rounded,
        color: colorScheme.primary,
        text: node.isEmpty
            ? appLocalizations.smartRoutingOn
            : appLocalizations.smartRoutingServiceVia(node),
      );
    case 'searching':
      return (
        icon: Icons.autorenew_rounded,
        color: muted,
        text: appLocalizations.smartRoutingSearching,
      );
    case 'fallback':
      final reject = (status?.fallback ?? fallback.name) == 'reject';
      return reject
          ? (
              icon: Icons.block_rounded,
              color: colorScheme.error,
              text: appLocalizations.smartRoutingServiceFallbackActiveReject,
            )
          : (
              icon: Icons.alt_route_rounded,
              color: muted,
              text: appLocalizations.smartRoutingServiceFallbackActiveMain,
            );
    default:
      return (
        icon: Icons.hourglass_empty_rounded,
        color: muted,
        text: appLocalizations.smartRoutingServicePending,
      );
  }
}

int _providerSelectorCount(
  ProviderCapabilityManifest? manifest,
  String capabilityId,
) =>
    manifest?.claims
        .where((claim) => claim.capabilityId == capabilityId)
        .fold<int>(0, (total, claim) => total + claim.selectors.length) ??
    0;

String capabilityTitle(
  BuildContext context,
  String capabilityId, {
  ProviderCapabilityManifest? manifest,
}) {
  switch (capabilityId) {
    case 'youtube-adfree':
      return context.appLocalizations.smartRoutingServiceYouTube;
    case 'gemini-access':
      return context.appLocalizations.smartRoutingServiceGemini;
  }
  final title = manifest?.claims
      .firstWhereOrNull(
        (claim) => claim.capabilityId == capabilityId && claim.title != null,
      )
      ?.title;
  return title ?? capabilityId;
}

String _fallbackText(BuildContext context, ServiceRouteFallback fallback) =>
    switch (fallback) {
      ServiceRouteFallback.main =>
        context.appLocalizations.smartRoutingServiceFallbackMain,
      ServiceRouteFallback.reject =>
        context.appLocalizations.smartRoutingServiceFallbackReject,
    };

class _ServiceRouteItem extends StatelessWidget {
  const _ServiceRouteItem({
    required this.capabilityId,
    required this.policy,
    required this.laneStatus,
    required this.manifest,
    required this.manualSelectors,
  });

  final String capabilityId;
  final ServiceRoutePolicy policy;
  final RcxLaneStatus? laneStatus;
  final ProviderCapabilityManifest? manifest;
  final List<ManualCapabilitySelector> manualSelectors;

  @override
  Widget build(BuildContext context) {
    final selectorCount =
        _providerSelectorCount(manifest, capabilityId) +
        manualSelectors
            .where((selector) => selector.capabilityId == capabilityId)
            .length;
    final view = _laneView(
      context,
      enabled: policy.enabled,
      fallback: policy.fallback,
      status: laneStatus,
      selectorCount: selectorCount,
    );
    final title = capabilityTitle(context, capabilityId, manifest: manifest);
    return DecorationListItem.open(
      leading: Icon(view.icon, color: view.color),
      title: Text(title),
      subtitle: Text(view.text),
      blur: false,
      widget: _ServiceRoutePage(title: title, capabilityId: capabilityId),
    );
  }
}

/// Reads the profile rather than the values the row held when it was tapped:
/// the pushed page outlives that build, so a captured copy would keep showing
/// the old policy and would let one edit overwrite the previous one.
class _ServiceRoutePage extends ConsumerWidget {
  const _ServiceRoutePage({required this.title, required this.capabilityId});

  final String title;
  final String capabilityId;

  void _updateProfile(WidgetRef ref, Profile Function(Profile profile) update) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    ref.read(profilesProvider.notifier).updateProfile(profile.id, update);
  }

  void _updatePolicy(
    WidgetRef ref,
    ServiceRoutePolicy Function(ServiceRoutePolicy policy) update,
  ) {
    _updateProfile(ref, (profile) {
      final policies = [...profile.serviceRoutePolicies];
      final index = policies.indexWhere(
        (policy) => policy.capabilityId == capabilityId,
      );
      final current = index < 0
          ? ServiceRoutePolicy(capabilityId: capabilityId)
          : policies[index];
      final next = update(current);
      if (index < 0) {
        policies.add(next);
      } else {
        policies[index] = next;
      }
      return profile.copyWith(serviceRoutePolicies: policies);
    });
  }

  void _updateManual(
    WidgetRef ref,
    List<ManualCapabilitySelector> Function(
      List<ManualCapabilitySelector> current,
    )
    update,
  ) {
    _updateProfile(ref, (profile) {
      final mine = <ManualCapabilitySelector>[];
      final others = <ManualCapabilitySelector>[];
      for (final selector in profile.manualCapabilitySelectors) {
        (selector.capabilityId == capabilityId ? mine : others).add(selector);
      }
      return profile.copyWith(
        manualCapabilitySelectors: [...others, ...update(mine)],
      );
    });
  }

  Future<void> _addManual(WidgetRef ref) async {
    final result = await dialogs.showCommonDialog<ManualCapabilitySelector>(
      child: _ManualCapabilitySelectorDialog(capabilityId: capabilityId),
    );
    if (result == null) return;
    _updateManual(ref, (current) => [...current, result]);
  }

  Future<void> _editManual(
    WidgetRef ref,
    ManualCapabilitySelector selector,
  ) async {
    final result = await dialogs.showCommonDialog<ManualCapabilitySelector>(
      child: _ManualCapabilitySelectorDialog(
        capabilityId: capabilityId,
        selector: selector,
      ),
    );
    if (result == null) return;
    _updateManual(ref, (current) {
      final index = current.indexOf(selector);
      if (index < 0) return current;
      return [...current]..[index] = result;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final policy =
        profile?.serviceRoutePolicies.firstWhereOrNull(
          (policy) => policy.capabilityId == capabilityId,
        ) ??
        ServiceRoutePolicy(capabilityId: capabilityId);
    final manualSelectors = [
      for (final selector
          in profile?.manualCapabilitySelectors ??
              const <ManualCapabilitySelector>[])
        if (selector.capabilityId == capabilityId) selector,
    ];
    final providerSelectors = _providerSelectorCount(
      profile?.capabilityManifest,
      capabilityId,
    );
    final status = ref.watch(
      smartRoutingStatusProvider.select(
        (status) =>
            status?.lanes.firstWhereOrNull((lane) => lane.id == capabilityId),
      ),
    );
    final view = _laneView(
      context,
      enabled: policy.enabled,
      fallback: policy.fallback,
      status: status,
      selectorCount: providerSelectors + manualSelectors.length,
    );
    return CommonScaffold(
      title: title,
      actions: [
        CommonMinFilledButtonTheme(
          child: FilledButton.tonal(
            onPressed: () => _addManual(ref),
            child: Text(appLocalizations.add),
          ),
        ),
        const SizedBox(width: 8),
      ],
      body: SettingsListView(
        children: [
          if (policy.enabled)
            SettingSection(
              top: 16,
              title: appLocalizations.smartRoutingServiceStatus,
              items: [
                DecorationListItem(
                  leading: Icon(view.icon, color: view.color),
                  title: Text(view.text),
                  subtitle: status == null
                      ? null
                      : Text(
                          status.candidates == 0
                              ? appLocalizations.smartRoutingServiceMatchedNone
                              : appLocalizations.smartRoutingServiceReady(
                                  status.eligible,
                                  status.candidates,
                                ),
                        ),
                ),
              ],
            ),
          SettingSection(
            top: policy.enabled ? 0 : 16,
            title: appLocalizations.smartRoutingServiceRoute,
            items: [
              DecorationListItem.toggle(
                title: Text(appLocalizations.smartRoutingServiceEnabled),
                subtitle: Text(appLocalizations.smartRoutingServiceEnabledDesc),
                value: policy.enabled,
                onChanged: (value) => _updatePolicy(
                  ref,
                  (policy) => policy.copyWith(enabled: value),
                ),
              ),
              DecorationListItem.options(
                title: Text(appLocalizations.smartRoutingServiceFallback),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appLocalizations.smartRoutingServiceFallbackDesc),
                    const SizedBox(height: 4),
                    Text(
                      _fallbackText(context, policy.fallback),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.opacity60,
                      ),
                    ),
                  ],
                ),
                dialogTitle: appLocalizations.smartRoutingServiceFallback,
                options: ServiceRouteFallback.values,
                value: policy.fallback,
                textBuilder: (value) =>
                    _fallbackText(context, value as ServiceRouteFallback),
                onChanged: (value) {
                  if (value == null) return;
                  _updatePolicy(
                    ref,
                    (policy) => policy.copyWith(
                      fallback: value as ServiceRouteFallback,
                    ),
                  );
                },
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingServiceSources,
            items: [
              DecorationListItem(
                title: Text(appLocalizations.smartRoutingServiceProviderSource),
                subtitle: Text(
                  appLocalizations.smartRoutingServiceProviderCandidates(
                    providerSelectors,
                  ),
                ),
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingServiceManual,
            bottom: 24,
            items: manualSelectors.isEmpty
                ? [
                    DecorationListItem(
                      title: Text(
                        appLocalizations.smartRoutingServiceManualEmpty,
                      ),
                      subtitle: Text(
                        appLocalizations.smartRoutingServiceManualEmptyDesc,
                      ),
                    ),
                  ]
                : [
                    for (final selector in manualSelectors)
                      DecorationListItem(
                        title: Text(selector.nameContains),
                        subtitle: Text(_selectorSummary(context, selector)),
                        trailing: IconButton(
                          tooltip: appLocalizations.delete,
                          onPressed: () => _updateManual(
                            ref,
                            (current) => current
                                .where((item) => item != selector)
                                .toList(),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                        onPressed: () => _editManual(ref, selector),
                      ),
                  ],
          ),
        ],
      ),
    );
  }
}

String _selectorSummary(
  BuildContext context,
  ManualCapabilitySelector selector,
) {
  final provider = selector.provider;
  if (provider == null || provider.isEmpty) {
    return context.appLocalizations.smartRoutingServiceAnyProvider;
  }
  return context.appLocalizations.smartRoutingServiceProvider(provider);
}

class _ManualCapabilitySelectorDialog extends StatefulWidget {
  const _ManualCapabilitySelectorDialog({
    required this.capabilityId,
    this.selector,
  });

  final String capabilityId;
  final ManualCapabilitySelector? selector;

  @override
  State<_ManualCapabilitySelectorDialog> createState() =>
      _ManualCapabilitySelectorDialogState();
}

class _ManualCapabilitySelectorDialogState
    extends State<_ManualCapabilitySelectorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameContains;
  late final TextEditingController _provider;

  @override
  void initState() {
    super.initState();
    _nameContains = TextEditingController(
      text: widget.selector?.nameContains ?? '',
    );
    _provider = TextEditingController(text: widget.selector?.provider ?? '');
  }

  @override
  void dispose() {
    _nameContains.dispose();
    _provider.dispose();
    super.dispose();
  }

  int _utf8Length(String value) => utf8.encode(value.trim()).length;

  String? _validateToken(String? value, String label, {bool optional = false}) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return optional ? null : context.appLocalizations.emptyTip(label);
    }
    if (_utf8Length(normalized) > 64) {
      return context.appLocalizations.smartRoutingServiceTokenTooLong(label);
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final provider = _provider.text.trim();
    Navigator.of(context).pop(
      ManualCapabilitySelector(
        capabilityId: widget.capabilityId,
        provider: provider.isEmpty ? null : provider,
        nameContains: _nameContains.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.smartRoutingServiceManualSelector,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          spacing: 16,
          children: [
            TextFormField(
              controller: _nameContains,
              decoration: InputDecoration(
                labelText: appLocalizations.smartRoutingServiceNameContains,
                helperText:
                    appLocalizations.smartRoutingServiceNameContainsDesc,
              ),
              validator: (value) => _validateToken(
                value,
                appLocalizations.smartRoutingServiceNameContains,
              ),
            ),
            TextFormField(
              controller: _provider,
              decoration: InputDecoration(
                labelText: appLocalizations.smartRoutingServiceProviderOptional,
                helperText: appLocalizations.smartRoutingServiceProviderDesc,
              ),
              validator: (value) => _validateToken(
                value,
                appLocalizations.smartRoutingServiceProviderOptional,
                optional: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A marker is a URL plus the statuses that count, so it cannot ride the plain
/// string-list editor: a bare URL would silently mean "any completed exchange".
class _MarkersItem extends StatelessWidget {
  const _MarkersItem({
    required this.title,
    required this.desc,
    required this.markers,
    required this.domestic,
  });

  final String title;
  final String desc;
  final List<RcxMarker> markers;
  final bool domestic;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      title: Text(title),
      subtitle: Text(
        markers.isEmpty ? desc : markers.map((marker) => marker.url).join(', '),
      ),
      blur: false,
      widget: _MarkersPage(title: title, domestic: domestic),
    );
  }
}

class _MarkersPage extends ConsumerStatefulWidget {
  const _MarkersPage({required this.title, required this.domestic});

  final String title;
  final bool domestic;

  @override
  ConsumerState<_MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends ConsumerState<_MarkersPage> {
  Set<String> _selection = {};

  void _deleteSelected() {
    _writeMarkers(
      ref,
      widget.domestic,
      _markerRowsOf(
        ref.read(smartRoutingSettingProvider),
        widget.domestic,
      ).where((marker) => !_selection.contains(marker.url)).toList(),
    );
    setState(() => _selection = {});
  }

  void _toggleSelectAll() {
    final markers = _markerRowsOf(
      ref.read(smartRoutingSettingProvider),
      widget.domestic,
    );
    setState(() {
      _selection = _selection.length == markers.length
          ? {}
          : markers.map((marker) => marker.url).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selection;
    final appLocalizations = context.appLocalizations;
    return CommonPopScope(
      onPop: (_) {
        if (selection.isEmpty) {
          return true;
        }
        setState(() => _selection = {});
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        actions: [
          if (selection.isNotEmpty) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                tooltip: appLocalizations.delete,
                onPressed: _deleteSelected,
                icon: const Icon(Icons.delete),
              ),
            ),
            const SizedBox(width: 2),
          ],
          CommonMinFilledButtonTheme(
            child: selection.isNotEmpty
                ? FilledButton(
                    onPressed: _toggleSelectAll,
                    child: Text(appLocalizations.selectAll),
                  )
                : FilledButton.tonal(
                    onPressed: () =>
                        showMarkerDialog(context, ref, widget.domestic),
                    child: Text(appLocalizations.add),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        body: _MarkersBody(
          domestic: widget.domestic,
          selection: selection,
          onSelected: (url) => setState(() {
            _selection = {..._selection}..addOrRemove(url);
          }),
        ),
      ),
    );
  }
}

List<RcxMarker> _markerRowsOf(SmartRoutingProps props, bool domestic) =>
    domestic ? props.domesticMarkers : props.openMarkers;

void _writeMarkers(WidgetRef ref, bool domestic, List<RcxMarker> next) {
  ref
      .read(smartRoutingSettingProvider.notifier)
      .update(
        (state) => domestic
            ? state.copyWith(domesticMarkers: next)
            : state.copyWith(openMarkers: next),
      );
}

Future<void> showMarkerDialog(
  BuildContext context,
  WidgetRef ref,
  bool domestic, [
  int? index,
]) async {
  final rows = _markerRowsOf(ref.read(smartRoutingSettingProvider), domestic);
  final result = await dialogs.showCommonDialog<RcxMarker>(
    child: _MarkerDialog(marker: index == null ? null : rows[index]),
  );
  if (result == null) {
    return;
  }
  final next = [...rows];
  if (index == null) {
    next.add(result);
  } else {
    next[index] = result;
  }
  _writeMarkers(ref, domestic, next);
}

class _MarkersBody extends ConsumerWidget {
  const _MarkersBody({
    required this.domestic,
    required this.selection,
    required this.onSelected,
  });

  final bool domestic;
  final Set<String> selection;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _markerRowsOf(
      ref.watch(smartRoutingSettingProvider),
      domestic,
    );
    if (rows.isEmpty) {
      return NullStatus(
        label: context.appLocalizations.smartRoutingMarkersEmpty,
      );
    }
    Widget itemAt(int index) => _markerRow(context, ref, rows, index);
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
        bottom: 16 + 64,
        top: 16,
        left: 16,
        right: 16,
      ),
      buildDefaultDragHandles: false,
      itemCount: rows.length,
      itemBuilder: (_, index) => itemAt(index),
      proxyDecorator: (child, index, animation) =>
          commonProxyDecorator(itemAt(index), index, animation),
      onReorderItem: (oldIndex, newIndex) =>
          _writeMarkers(ref, domestic, rows.copyAndReorder(oldIndex, newIndex)),
    );
  }

  Widget _markerRow(
    BuildContext context,
    WidgetRef ref,
    List<RcxMarker> rows,
    int index,
  ) {
    final marker = rows[index];
    return ReorderableDelayedDragStartListener(
      key: ValueKey(marker.url),
      index: index,
      child: ItemPositionProvider(
        position: ItemPosition.get(index, rows.length),
        child: SelectedDecorationListItem(
          title: TooltipText(
            text: Text(
              marker.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Text(marker.statuses.join(', ')),
          isSelected: selection.contains(marker.url),
          isEditing: selection.isNotEmpty,
          onSelected: () => onSelected(marker.url),
          onPressed: () => selection.isEmpty
              ? showMarkerDialog(context, ref, domestic, index)
              : onSelected(marker.url),
        ),
      ),
    );
  }
}

class _MarkerDialog extends StatefulWidget {
  const _MarkerDialog({this.marker});

  final RcxMarker? marker;

  @override
  State<_MarkerDialog> createState() => _MarkerDialogState();
}

class _MarkerDialogState extends State<_MarkerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _url;
  late final TextEditingController _statuses;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.marker?.url ?? '');
    _statuses = TextEditingController(
      text: (widget.marker?.statuses ?? const [204]).join(', '),
    );
  }

  @override
  void dispose() {
    _url.dispose();
    _statuses.dispose();
    super.dispose();
  }

  List<int>? _parseStatuses(String? raw) {
    final parts = (raw ?? '')
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final parsed = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 100 || value > 599) {
        return null;
      }
      parsed.add(value);
    }
    return parsed.isEmpty ? null : parsed;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.of(context).pop(
      RcxMarker(
        url: _url.text.trim(),
        statuses: _parseStatuses(_statuses.text) ?? const [204],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.smartRoutingMarkers,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            TextFormField(
              controller: _url,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.smartRoutingMarkerUrl,
              ),
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) {
                  return appLocalizations.emptyTip(
                    appLocalizations.smartRoutingMarkerUrl,
                  );
                }
                return raw.isUrl
                    ? null
                    : appLocalizations.urlTip(
                        appLocalizations.smartRoutingMarkerUrl,
                      );
              },
            ),
            TextFormField(
              controller: _statuses,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.smartRoutingMarkerStatuses,
                hintText: appLocalizations.smartRoutingMarkerStatusesHint,
              ),
              validator: (value) => _parseStatuses(value) == null
                  ? appLocalizations.smartRoutingMarkerStatusesTip
                  : null,
            ),
          ],
        ),
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
      subtitle: Text(
        value.isEmpty ? desc : '${value.length} · ${value.join(', ')}',
      ),
      blur: false,
      widget: ListInputPage(title: title, items: value, titleBuilder: Text.new),
      onChanged: (items) => ref
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => write(state, List<String>.from(items as List))),
    );
  }
}
