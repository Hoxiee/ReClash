import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/common/regional/regional_network.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _equality = DeepCollectionEquality();

String _detectionSourceLabel(
  AppLocalizations l,
  RegionDetectionSource source,
) => switch (source) {
  RegionDetectionSource.timeZone => l.regionSourceTimeZone,
  RegionDetectionSource.localeCountry => l.regionSourceLocaleCountry,
  RegionDetectionSource.localeLanguage => l.regionSourceLocaleLanguage,
};

class RegionView extends ConsumerStatefulWidget {
  const RegionView({
    super.key,
    this.isAndroid,
    this.initialRegionCode,
    this.onApply,
  });

  final bool? isAndroid;
  final String? initialRegionCode;
  final ValueChanged<String?>? onApply;

  @override
  ConsumerState<RegionView> createState() => _RegionViewState();
}

class _RegionViewState extends ConsumerState<RegionView> {
  late String? _selectedRegionCode;

  @override
  void initState() {
    super.initState();
    _selectedRegionCode = sanitizeRegionCode(
      widget.onApply != null
          ? widget.initialRegionCode
          : ref.read(appSettingProvider).regionCode,
    );
  }

  void _select(String? code) => setState(() => _selectedRegionCode = code);

  void _apply() {
    if (widget.onApply != null) {
      widget.onApply!(_selectedRegionCode);
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(regionCode: _selectedRegionCode));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final currentRegionCode = sanitizeRegionCode(
      ref.watch(appSettingProvider.select((state) => state.regionCode)),
    );
    ref.listen(appSettingProvider.select((state) => state.regionCode), (
      previous,
      next,
    ) {
      if (_selectedRegionCode == sanitizeRegionCode(previous)) {
        _select(sanitizeRegionCode(next));
      }
    });
    final selectedRegionCode = _selectedRegionCode;
    final isAndroid = widget.isAndroid ?? system.isAndroid;
    final detected = ref.watch(detectedRegionProvider);
    final currentNetwork = ref.watch(regionalNetworkConfigProvider);
    final base = ref.watch(patchClashConfigProvider);
    final targetNetwork = regionalNetworkConfigFor(
      regionCode: selectedRegionCode,
      base: base,
      defaultBypassDomains: defaultBypassDomain,
      bypassDomains: ref.watch(
        networkSettingProvider.select((state) => state.bypassDomain),
      ),
    );
    final profile = ref.watch(currentProfileProvider);
    final customOverrides = profile?.type == ProfileType.custom
        ? profile!.overrides
        : null;
    ProfileOverrides overridesOf(PatchClashConfig patch) =>
        regionalProfileOverridesFor(
          patchConfig: patch,
          appDnsOverrideKeys: base.dnsOverrideKeys,
          customOverrides: customOverrides,
        );
    final currentOverrides = overridesOf(currentNetwork.patchConfig);
    final targetOverrides = overridesOf(targetNetwork.patchConfig);
    final dnsChanges = <String>[];
    for (final key in DnsOverrideKey.values) {
      final current = currentOverrides.dns.overrideJson(
        currentOverrides.dnsOverrideKeys.intersection({key}),
        keepEmpty: customOverrides == null,
      );
      final target = targetOverrides.dns.overrideJson(
        targetOverrides.dnsOverrideKeys.intersection({key}),
        keepEmpty: customOverrides == null,
      );
      if (!_equality.equals(current, target)) {
        final value = target.isEmpty
            ? l.regionProfileDefaults
            : _dnsValue(target, key, l.none);
        dnsChanges.add('${key.path}: $value');
      }
    }
    final bypassChanges = [
      for (final domain in currentNetwork.bypassDomain)
        if (!targetNetwork.bypassDomain.contains(domain)) '− $domain',
      for (final domain in targetNetwork.bypassDomain)
        if (!currentNetwork.bypassDomain.contains(domain)) '+ $domain',
    ];
    final mtuChanged = isAndroid
        ? currentNetwork.patchConfig.tun.mtu !=
              targetNetwork.patchConfig.tun.mtu
        : !_equality.equals(
            currentOverrides.tun.overrideJson(
              currentOverrides.tunOverrideKeys.intersection({
                TunOverrideKey.mtu,
              }),
            ),
            targetOverrides.tun.overrideJson(
              targetOverrides.tunOverrideKeys.intersection({
                TunOverrideKey.mtu,
              }),
            ),
          );
    final mtuValue = isAndroid
        ? '${targetNetwork.patchConfig.tun.mtu}'
        : targetOverrides.tunOverrideKeys.contains(TunOverrideKey.mtu)
        ? '${targetOverrides.tun.mtu}'
        : l.regionProfileDefaults;
    final services = ref.watch(
      appSettingProvider.select(
        (state) => (
          order: state.serviceOrder,
          enabled: state.enabledServices,
          disabled: state.disabledServices,
        ),
      ),
    );
    final targetServices = enabledServiceTargetsForRegion(
      regionCode: selectedRegionCode,
      order: services.order,
      enabled: services.enabled.toSet(),
      disabled: services.disabled.toSet(),
    );
    final servicesChanged = !_equality.equals(
      ref.watch(enabledServiceTargetsProvider),
      targetServices,
    );
    final hasChanges =
        widget.onApply != null || currentRegionCode != selectedRegionCode;
    return CommonScaffold(
      title: l.regionTitle,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.check,
          tooltip: l.regionApply,
          onPressed: hasChanges ? _apply : null,
        ),
      ],
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.appBarInset, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              generateSection(
                title: l.appRegion,
                items: [
                  DecorationListItem(
                    title: Text(l.regionCurrent),
                    subtitle: Text(regionLabel(l, currentRegionCode)),
                  ),
                  ListItem<String?>.options(
                    title: Text(l.regionChoose),
                    options: const [
                      null,
                      'RU',
                      'IR',
                      'CN',
                      'EG',
                      otherRegionCode,
                    ],
                    value: selectedRegionCode,
                    textBuilder: (code) => regionLabel(l, code),
                    onChanged: _select,
                  ),
                ],
                footer: l.regionWarning,
              ),
              generateSection(
                title: l.regionDetectionTitle,
                actions: [
                  IconButtonData(
                    glyph: AppGlyphs.refresh,
                    tooltip: l.update,
                    isLoading: detected.isLoading,
                    onPressed: detected.isLoading
                        ? null
                        : () => ref.invalidate(detectedRegionProvider),
                  ),
                ],
                items: detected.when(
                  data: (detection) => [
                    if (detection == null)
                      DecorationListItem(title: Text(l.regionNoDetected))
                    else
                      DecorationListItem(
                        leading: const GlyphIcon(AppGlyphs.sparkle),
                        title: Text(l.regionUseDetected),
                        subtitle: Text(
                          l.regionDetected(
                            regionLabel(l, detection.countryCode),
                            _detectionSourceLabel(l, detection.source),
                          ),
                        ),
                        trailing: detection.countryCode == selectedRegionCode
                            ? const SelectionCheck()
                            : null,
                        onPressed: detection.countryCode == selectedRegionCode
                            ? null
                            : () => _select(detection.countryCode),
                      ),
                  ],
                  error: (_, _) => [
                    DecorationListItem(title: Text(l.regionNoDetected)),
                  ],
                  loading: () => const <Widget>[],
                ),
              ),
              generateSection(
                title: l.regionPreviewTitle,
                items: [
                  DecorationListItem(
                    title: Text(
                      l.regionPreviewBase(regionLabel(l, selectedRegionCode)),
                    ),
                  ),
                  if (dnsChanges.isNotEmpty)
                    DecorationListItem(
                      title: const Text('DNS'),
                      subtitle: Text(dnsChanges.join('\n')),
                    ),
                  if (bypassChanges.isNotEmpty)
                    DecorationListItem(
                      title: Text(l.bypassDomain),
                      subtitle: Text(bypassChanges.join('\n')),
                    ),
                  if (mtuChanged)
                    DecorationListItem(
                      title: Text(l.regionPreviewMtu(mtuValue)),
                    ),
                  if (servicesChanged)
                    DecorationListItem(
                      title: Text(
                        l.regionPreviewServices(
                          targetServices.isEmpty
                              ? l.regionNoServices
                              : targetServices
                                    .map((target) => target.label)
                                    .join(', '),
                        ),
                      ),
                    ),
                  if (dnsChanges.isEmpty &&
                      bypassChanges.isEmpty &&
                      !mtuChanged &&
                      !servicesChanged)
                    DecorationListItem(title: Text(l.regionNoChanges)),
                ],
                footer: [
                  l.regionCustomPreserved,
                  if (isAndroid) l.regionPreviewAndroid,
                ].join('\n'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dnsValue(
  Map<String, Object?> override,
  DnsOverrideKey key,
  String emptyLabel,
) {
  Object? value = override;
  for (final part in key.path.split('.')) {
    value = (value as Map)[part];
  }
  return switch (value) {
    List() => value.isEmpty ? emptyLabel : value.join(', '),
    String() => value.isEmpty ? emptyLabel : value,
    _ => '$value',
  };
}
