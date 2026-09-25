part of 'smart_routing.dart';

typedef _LaneView = ({Glyph icon, Color color, String text});

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
      icon: AppGlyphs.circleOutline,
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
        icon: AppGlyphs.bolt,
        color: colorScheme.primary,
        text: node.isEmpty
            ? appLocalizations.smartRoutingOn
            : appLocalizations.smartRoutingServiceVia(node),
      );
    case 'searching':
      return (
        icon: AppGlyphs.sync,
        color: muted,
        text: appLocalizations.smartRoutingSearching,
      );
    case 'fallback':
      final reject = (status?.fallback ?? fallback.name) == 'reject';
      return reject
          ? (
              icon: AppGlyphs.block,
              color: colorScheme.error,
              text: appLocalizations.smartRoutingServiceFallbackActiveReject,
            )
          : (
              icon: AppGlyphs.route,
              color: muted,
              text: appLocalizations.smartRoutingServiceFallbackActiveMain,
            );
    default:
      return (
        icon: AppGlyphs.hourglass,
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
      leading: GlyphIcon(view.icon, color: view.color),
      title: Text(title),
      subtitle: Text(view.text),
      blur: false,
      forceFull: false,
      maxWidth: 400,
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
      floatBody: true,
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
          SizedBox(height: context.appBarInset),
          if (policy.enabled)
            SettingSection(
              top: 16,
              title: appLocalizations.smartRoutingServiceStatus,
              items: [
                DecorationListItem(
                  leading: GlyphIcon(view.icon, color: view.color),
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
              DecorationListItem.open(
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
                blur: false,
                forceFull: false,
                maxWidth: 400,
                widget: OptionsPickerPage<ServiceRouteFallback>(
                  title: appLocalizations.smartRoutingServiceFallback,
                  options: ServiceRouteFallback.values,
                  value: policy.fallback,
                  textBuilder: (value) => _fallbackText(context, value),
                ),
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
                          icon: const GlyphIcon(AppGlyphs.delete),
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
