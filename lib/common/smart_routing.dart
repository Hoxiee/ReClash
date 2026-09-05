import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

/// Bumped when shipped preset data changes, so the core drops its own copy.
const smartRoutingDefaultsVersion = 4;

class SmartRoutingBundle {
  const SmartRoutingBundle({
    this.censorCountries = const [],
    this.canaryForeign = const [],
    this.canaryDomestic = const [],
    this.openMarkers = const [],
    this.domesticMarkers = const [],
    this.breakerPatterns = const [],
    this.allowDomesticLastResort = true,
    this.requireUdp = false,
    this.respectPick = true,
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
  final bool requireUdp;
  final bool respectPick;
  final int dwellSeconds;
  final int waveWidth;
}

// Canaries are IP literals: DNS often answers while transit is dead, so a
// hostname would measure the resolver instead of the network.
// One operator blocked nationwide is not a whitelist network, hence four ASNs.
const _russia = SmartRoutingBundle(
  censorCountries: ['RU'],
  canaryForeign: [
    '1.1.1.1:443',
    '9.9.9.9:443',
    '8.8.8.8:443',
    '94.140.14.14:443',
  ],
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
    canaryForeign: [
      '1.1.1.1:443',
      '9.9.9.9:443',
      '8.8.8.8:443',
      '94.140.14.14:443',
    ],
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
    canaryForeign: [
      '1.1.1.1:443',
      '9.9.9.9:443',
      '8.8.8.8:443',
      '94.140.14.14:443',
    ],
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

extension SmartRoutingStrategyWire on SmartRoutingStrategy {
  String get wire => switch (this) {
    SmartRoutingStrategy.balanced => 'balanced',
    SmartRoutingStrategy.lowestLatency => 'lowest-latency',
  };
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
      requireUdp: bundle.requireUdp,
      respectPick: bundle.respectPick,
      dwellSeconds: bundle.dwellSeconds,
      waveWidth: bundle.waveWidth,
    );
  }

  bool get matchesPreset => this == applyPreset(preset);

  RcxConfigParams get rcxParams => RcxConfigParams(
    enabled: enabled,
    preset: preset.wire,
    strategy: strategy.wire,
    defaultsVersion: smartRoutingDefaultsVersion,
    censorCountries: censorCountries,
    canaryForeign: canaryForeign,
    canaryDomestic: canaryDomestic,
    openMarkers: openMarkers,
    domesticMarkers: domesticMarkers,
    breakerPatterns: breakerPatterns,
    allowDomesticLastResort: allowDomesticLastResort,
    requireUdp: requireUdp,
    respectPick: respectPick,
    dwellSeconds: dwellSeconds,
    waveWidth: waveWidth,
  );
}

const rcxTrailLimit = 4;

List<String> rcxTrailWith(List<String> trail, String node) {
  if (node.isEmpty) {
    return trail;
  }
  if (trail.isNotEmpty && trail.first == node) {
    return trail;
  }
  final next = [node, ...trail.where((item) => item != node)];
  return next.length <= rcxTrailLimit ? next : next.sublist(0, rcxTrailLimit);
}

/// The node the engine holds and the node the user pinned are two questions.
bool routingPinHolds(RcxStatus? status, String node) =>
    status != null &&
    status.enabled &&
    status.pinNode.isNotEmpty &&
    status.pinNode == node;
