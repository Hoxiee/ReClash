import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/common/regional/regional_network.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _equality = DeepCollectionEquality();

const _regionOptions = ['RU', 'IR', 'CN', 'EG', otherRegionCode];

/// What applying [target] over the active region changes, for a preview.
List<(Glyph, String)> regionChanges(
  WidgetRef ref,
  AppLocalizations l,
  String? target,
) {
  final currentRegionCode = ref.watch(
    appSettingProvider.select((state) => state.regionCode),
  );
  final patchConfig = ref.watch(patchClashConfigProvider);
  final bypassDomain = ref.watch(
    networkSettingProvider.select((state) => state.bypassDomain),
  );
  final next = withRegionDefaults(
    from: currentRegionCode,
    to: target,
    patchConfig: patchConfig,
    bypassDomain: bypassDomain,
  );
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
    regionCode: target,
    order: services.order,
    enabled: services.enabled.toSet(),
    disabled: services.disabled.toSet(),
  );
  final nextConfig = next.patchConfig;
  return [
    if (nextConfig.dns != patchConfig.dns ||
        !_equality.equals(
          nextConfig.dnsOverrideKeys,
          patchConfig.dnsOverrideKeys,
        ))
      (AppGlyphs.dns, l.regionChangeDns),
    if (!_equality.equals(next.bypassDomain, bypassDomain))
      (AppGlyphs.split, l.bypassDomain),
    if (nextConfig.tun.mtu != patchConfig.tun.mtu)
      (AppGlyphs.sliders, l.regionChangeMtu),
    if (!_equality.equals(
      ref.watch(enabledServiceTargetsProvider),
      targetServices,
    ))
      (AppGlyphs.verified, l.regionChangeServices),
  ];
}

class RegionView extends ConsumerStatefulWidget {
  const RegionView({super.key});

  @override
  ConsumerState<RegionView> createState() => _RegionViewState();
}

class _RegionViewState extends ConsumerState<RegionView> {
  late String? _selectedRegionCode;

  @override
  void initState() {
    super.initState();
    _selectedRegionCode = sanitizeRegionCode(
      ref.read(appSettingProvider).regionCode,
    );
  }

  void _select(String? code) => setState(() => _selectedRegionCode = code);

  void _apply() {
    ref.read(systemActionProvider.notifier).applyRegion(_selectedRegionCode);
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
    final detectedRegionCode = ref.watch(
      detectedRegionProvider.select((state) => state.value?.countryCode),
    );
    final isPending =
        selectedRegionCode != null && selectedRegionCode != currentRegionCode;
    final changes = isPending
        ? regionChanges(ref, l, selectedRegionCode)
        : const <(Glyph, String)>[];
    return CommonScaffold(
      title: l.appRegion,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.check,
          tooltip: l.regionApply,
          onPressed: isPending ? _apply : null,
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
                items: [
                  for (final code in _regionOptions)
                    DecorationListItem(
                      isSelected: code == selectedRegionCode,
                      leading: Text(
                        regionFlag(code),
                        style: AppTextStyle.title3
                            .of(context)
                            .toLight
                            .copyWith(fontFamily: FontFamily.twEmoji.value),
                      ),
                      title: Text(regionLabel(l, code)),
                      subtitle: code == detectedRegionCode
                          ? Text(l.regionRecommended)
                          : null,
                      trailing: code == selectedRegionCode
                          ? const SelectionCheck()
                          : null,
                      onPressed: () => _select(code),
                    ),
                ],
                footer: l.regionIntro,
              ),
              if (isPending)
                generateSection(
                  title: l.regionChangesTitle,
                  items: [
                    for (final (glyph, label) in changes)
                      DecorationListItem(
                        leading: GlyphIcon(glyph),
                        title: Text(label),
                      ),
                    if (changes.isEmpty)
                      DecorationListItem(title: Text(l.regionNoChanges)),
                  ],
                  footer: changes.isEmpty ? null : l.regionCustomPreserved,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
