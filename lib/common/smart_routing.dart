import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

/// Bumped when shipped preset data changes, so the core drops its own copy.
const smartRoutingDefaultsVersion = 2;

class SmartRoutingBundle {
  const SmartRoutingBundle({
    this.censorCountries = const [],
    this.canaryForeign = const [],
    this.canaryDomestic = const [],
    this.openMarkers = const [],
    this.domesticMarkers = const [],
    this.breakerPatterns = const [],
    this.allowDomesticLastResort = true,
    this.saveMobileData = true,
    this.requireUdp = false,
    this.manualHoldMinutes = 60,
    this.dwellSeconds = 90,
    this.waveWidth = 12,
  });

  final List<String> censorCountries;
  final List<String> canaryForeign;
  final List<String> canaryDomestic;
  final List<RcxMarker> openMarkers;
  final List<RcxMarker> domesticMarkers;
  final List<String> breakerPatterns;
  final bool allowDomesticLastResort;
  final bool saveMobileData;
  final bool requireUdp;
  final int manualHoldMinutes;
  final int dwellSeconds;
  final int waveWidth;
}

// Canaries are IP literals: DNS often answers while transit is dead, so a
// hostname would measure the resolver instead of the network.
const _russia = SmartRoutingBundle(
  censorCountries: ['RU'],
  canaryForeign: ['1.1.1.1:443', '9.9.9.9:443'],
  canaryDomestic: ['77.88.8.8:443', '213.180.204.242:443'],
  openMarkers: [
    RcxMarker(url: 'https://www.youtube.com/generate_204', statuses: [204]),
    // 404 counts: api.telegram.org is unreachable from every Russian egress
    // while Telegram works, so demanding 200 would disqualify usable nodes.
    RcxMarker(url: 'https://api.telegram.org/', statuses: [200, 404]),
  ],
  domesticMarkers: [
    RcxMarker(url: 'https://ya.ru/', statuses: [200, 301, 302]),
  ],
  breakerPatterns: ['lte', 'обход', 'глушил', 'bypass', 'breaker', 'unblock'],
);

const _smartRoutingBundles = {
  SmartRoutingPreset.off: SmartRoutingBundle(),
  SmartRoutingPreset.russia: _russia,
  SmartRoutingPreset.iran: SmartRoutingBundle(
    censorCountries: ['IR'],
    canaryForeign: ['1.1.1.1:443', '9.9.9.9:443'],
    canaryDomestic: ['5.200.200.200:443'],
    openMarkers: [
      RcxMarker(url: 'https://www.gstatic.com/generate_204', statuses: [204]),
    ],
    domesticMarkers: [
      RcxMarker(url: 'https://www.aparat.com/', statuses: [200, 301, 302]),
    ],
  ),
  SmartRoutingPreset.china: SmartRoutingBundle(
    censorCountries: ['CN'],
    canaryForeign: ['1.1.1.1:443', '9.9.9.9:443'],
    canaryDomestic: ['223.5.5.5:443'],
    openMarkers: [
      RcxMarker(url: 'https://www.gstatic.com/generate_204', statuses: [204]),
    ],
    domesticMarkers: [
      RcxMarker(url: 'https://www.baidu.com/', statuses: [200, 301, 302]),
    ],
  ),
};

SmartRoutingPreset smartRoutingPresetForLocale(String? locale) {
  final code = locale ?? '';
  if (code.startsWith('ru')) return SmartRoutingPreset.russia;
  if (code.startsWith('fa')) return SmartRoutingPreset.iran;
  if (code.startsWith('zh')) return SmartRoutingPreset.china;
  return SmartRoutingPreset.off;
}

extension SmartRoutingPresetBundle on SmartRoutingPreset {
  SmartRoutingBundle get bundle =>
      _smartRoutingBundles[this] ?? const SmartRoutingBundle();

  String get wire => switch (this) {
    SmartRoutingPreset.off => 'off',
    SmartRoutingPreset.russia => 'ru',
    SmartRoutingPreset.iran => 'ir',
    SmartRoutingPreset.china => 'cn',
  };
}

extension SmartRoutingPropsRcx on SmartRoutingProps {
  /// A preset seeds every field it owns, so picking a region also rewrites the
  /// canaries and markers the user could since have edited. Enablement is the
  /// user's, never the preset's.
  SmartRoutingProps applyPreset(SmartRoutingPreset value) {
    final bundle = value.bundle;
    return copyWith(
      preset: value,
      censorCountries: bundle.censorCountries,
      canaryForeign: bundle.canaryForeign,
      canaryDomestic: bundle.canaryDomestic,
      openMarkers: bundle.openMarkers,
      domesticMarkers: bundle.domesticMarkers,
      breakerPatterns: bundle.breakerPatterns,
      allowDomesticLastResort: bundle.allowDomesticLastResort,
      saveMobileData: bundle.saveMobileData,
      requireUdp: bundle.requireUdp,
      manualHoldMinutes: bundle.manualHoldMinutes,
      dwellSeconds: bundle.dwellSeconds,
      waveWidth: bundle.waveWidth,
    );
  }

  bool get matchesPreset => this == applyPreset(preset);

  RcxConfigParams get rcxParams => RcxConfigParams(
    enabled: enabled,
    preset: preset.wire,
    defaultsVersion: smartRoutingDefaultsVersion,
    censorCountries: censorCountries,
    canaryForeign: canaryForeign,
    canaryDomestic: canaryDomestic,
    openMarkers: openMarkers,
    domesticMarkers: domesticMarkers,
    breakerPatterns: breakerPatterns,
    allowDomesticLastResort: allowDomesticLastResort,
    saveMobileData: saveMobileData,
    requireUdp: requireUdp,
    manualHoldMinutes: manualHoldMinutes,
    dwellSeconds: dwellSeconds,
    waveWidth: waveWidth,
  );
}
