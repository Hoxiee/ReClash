import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

/// Sent as the wire `dv`, but the core overwrites it with its own
/// `rcxDefaultsVersion` (core/rcx_config.go), the real lever that drops learned
/// facts when shipped preset data changes. Kept only for wire-shape stability.
const smartRoutingDefaultsVersion = 4;

class SmartRoutingBundle {
  const SmartRoutingBundle({
    this.censorCountries = const [],
    this.canaryForeign = const [],
    this.canaryDomestic = const [],
    this.openMarkers = const [],
    this.domesticMarkers = const [],
    this.localMarkers = const [],
    this.nameHints = const [],
    this.egressEchoes = const [],
    this.countryEchoes = const [],
    this.breakerPatterns = const [],
    this.allowDomesticLastResort = true,
    this.requireUdp = false,
    this.respectPick = true,
  });

  final List<String> censorCountries;
  final List<String> canaryForeign;
  final List<String> canaryDomestic;
  final List<RcxMarker> openMarkers;
  final List<RcxMarker> domesticMarkers;
  final List<RcxMarker> localMarkers;
  final List<String> nameHints;
  final List<String> egressEchoes;
  final List<String> countryEchoes;
  final List<String> breakerPatterns;
  final bool allowDomesticLastResort;
  final bool requireUdp;
  final bool respectPick;
}

// An endpoint address names the front, not the exit, so a relay-fronted home
// server reads as foreign in the database while its traffic never leaves the
// country. These answer with the caller's own address through the node itself,
// which is the only way the engine sees where a node actually egresses.
const _egressEchoes = [
  'https://checkip.amazonaws.com/',
  'https://api.ipify.org/',
];

// These answer with the exit's country directly, so they place a fronted node
// more accurately than an mmdb lookup of the echoed IP. They carry request
// limits, so the engine spends them only on verification probes, not the park.
const _countryEchoes = [
  'https://api.country.is/',
  'https://api.ipgeo.ru/json/',
  'https://countries.dev/ip',
];

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
  // Both hosts are unreachable from every Russian egress while working abroad,
  // so reaching either proves a node is abroad and a home-country dud cannot.
  // Two of them means one host going dark does not blind the engine. Telegram
  // stays first (404 counts: its root 404s while the host answers); Instagram is
  // the fallback the probe tries only when Telegram fails.
  openMarkers: [
    RcxMarker(url: 'https://api.telegram.org/', statuses: [200, 404]),
    RcxMarker(url: 'https://www.instagram.com/', statuses: [200]),
  ],
  domesticMarkers: [
    RcxMarker(url: 'https://ya.ru/', statuses: [200, 301, 302]),
  ],
  // localMarkers stay empty until a candidate is device-confirmed to answer only
  // from a Russian egress; an unverified one brands working foreign nodes.
  nameHints: [
    'росси',
    'russia',
    'москва',
    'moscow',
    'санкт',
    'петербург',
    'спб',
  ],
  egressEchoes: _egressEchoes,
  countryEchoes: _countryEchoes,
  breakerPatterns: ['lte', 'обход', 'глушил', 'bypass', 'breaker', 'unblock'],
);

const _neutral = SmartRoutingBundle(
  canaryForeign: [
    '1.1.1.1:443',
    '9.9.9.9:443',
    '8.8.8.8:443',
    '94.140.14.14:443',
  ],
  openMarkers: [
    RcxMarker(url: 'https://www.gstatic.com/generate_204', statuses: [204]),
  ],
  egressEchoes: _egressEchoes,
  countryEchoes: _countryEchoes,
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
    egressEchoes: _egressEchoes,
    countryEchoes: _countryEchoes,
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
    egressEchoes: _egressEchoes,
    countryEchoes: _countryEchoes,
  ),
};

SmartRoutingPreset smartRoutingPresetForLocale(String? locale) {
  final code = locale ?? '';
  if (code.startsWith('ru')) return SmartRoutingPreset.russia;
  if (code.startsWith('fa')) return SmartRoutingPreset.iran;
  if (code.startsWith('zh')) return SmartRoutingPreset.china;
  return SmartRoutingPreset.off;
}

/// The pace belongs to the strategy, not to the region that seeds the rest.
class SmartRoutingPacing {
  const SmartRoutingPacing({
    required this.dwellSeconds,
    required this.waveWidth,
    required this.latencyBands,
  });

  final int dwellSeconds;
  final int waveWidth;
  final List<int> latencyBands;
}

extension SmartRoutingStrategyWire on SmartRoutingStrategy {
  String get wire => switch (this) {
    SmartRoutingStrategy.stable => 'stable',
    SmartRoutingStrategy.balanced => 'balanced',
    SmartRoutingStrategy.lowestLatency => 'lowest-latency',
    SmartRoutingStrategy.saver => 'saver',
  };

  SmartRoutingPacing get pacing => switch (this) {
    SmartRoutingStrategy.stable => const SmartRoutingPacing(
      dwellSeconds: 180,
      waveWidth: 8,
      latencyBands: [200, 400, 800, 1500],
    ),
    SmartRoutingStrategy.balanced => const SmartRoutingPacing(
      dwellSeconds: 90,
      waveWidth: 12,
      latencyBands: [150, 300, 600, 1200],
    ),
    SmartRoutingStrategy.lowestLatency => const SmartRoutingPacing(
      dwellSeconds: 30,
      waveWidth: 20,
      latencyBands: [80, 150, 300, 600],
    ),
    SmartRoutingStrategy.saver => const SmartRoutingPacing(
      dwellSeconds: 600,
      waveWidth: 4,
      latencyBands: [250, 500, 1000, 2000],
    ),
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
    final bundle = value == SmartRoutingPreset.off ? _neutral : value.bundle;
    return copyWith(
      preset: value,
      censorCountries: bundle.censorCountries,
      canaryForeign: bundle.canaryForeign,
      canaryDomestic: bundle.canaryDomestic,
      openMarkers: bundle.openMarkers,
      domesticMarkers: bundle.domesticMarkers,
      localMarkers: bundle.localMarkers,
      nameHints: bundle.nameHints,
      egressEchoes: bundle.egressEchoes,
      countryEchoes: bundle.countryEchoes,
      breakerPatterns: bundle.breakerPatterns,
      allowDomesticLastResort: bundle.allowDomesticLastResort,
      requireUdp: bundle.requireUdp,
      respectPick: bundle.respectPick,
    );
  }

  SmartRoutingProps withEnabled(bool value) => copyWith(
    enabled: value,
    canaryForeign:
        value && preset == SmartRoutingPreset.off && canaryForeign.isEmpty
        ? _neutral.canaryForeign
        : canaryForeign,
    openMarkers:
        value && preset == SmartRoutingPreset.off && openMarkers.isEmpty
        ? _neutral.openMarkers
        : openMarkers,
  );

  bool get matchesPreset => this == applyPreset(preset);

  SmartRoutingProps applyStrategy(SmartRoutingStrategy value) => copyWith(
    strategy: value,
    dwellSeconds: value.pacing.dwellSeconds,
    waveWidth: value.pacing.waveWidth,
    latencyBands: value.pacing.latencyBands,
  );

  bool get matchesStrategy => this == applyStrategy(strategy);

  RcxConfigParams rcxParamsFor(Profile? profile) => RcxConfigParams(
    enabled: enabled,
    preset: preset.wire,
    strategy: strategy.wire,
    defaultsVersion: smartRoutingDefaultsVersion,
    censorCountries: censorCountries,
    canaryForeign: canaryForeign,
    canaryDomestic: canaryDomestic,
    openMarkers: openMarkers,
    domesticMarkers: domesticMarkers,
    localMarkers: localMarkers,
    nameHints: nameHints,
    egressEchoes: egressEchoes,
    countryEchoes: countryEchoes,
    breakerPatterns: breakerPatterns,
    nodeRules: nodeRules,
    avoidCountries: avoidCountries,
    latencyBands: latencyBands,
    allowDomesticLastResort: allowDomesticLastResort,
    requireUdp: requireUdp,
    respectPick: respectPick,
    dwellSeconds: dwellSeconds,
    waveWidth: waveWidth,
    lanes: _effectiveRcxLanes(profile),
  );

  RcxConfigParams get rcxParams => rcxParamsFor(null);
}

String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

List<RcxLaneConfig> _effectiveRcxLanes(Profile? profile) {
  if (profile == null) return const [];
  final manifest = profile.capabilityManifest;
  final supported = effectiveCapabilityIds(manifest);
  final selectorsByCapability = <String, List<RcxLaneSelector>>{};
  final selectorKeys = <String, Set<(String?, String?, String?)>>{};

  void addSelector(
    String capabilityId, {
    String? provider,
    String? nameContains,
    String? group,
  }) {
    if (!supported.contains(capabilityId)) return;
    final effectiveProvider = provider?.trim().isNotEmpty == true
        ? provider!.trim()
        : null;
    final effectiveName = nameContains?.trim().isNotEmpty == true
        ? nameContains!.trim()
        : null;
    final effectiveGroup = group?.trim().isNotEmpty == true
        ? group!.trim()
        : null;
    if (effectiveProvider == null &&
        effectiveName == null &&
        effectiveGroup == null) {
      return;
    }
    final key = (effectiveProvider, effectiveName, effectiveGroup);
    if (!selectorKeys.putIfAbsent(capabilityId, () => {}).add(key)) return;
    selectorsByCapability
        .putIfAbsent(capabilityId, () => [])
        .add(
          RcxLaneSelector(
            provider: effectiveProvider,
            nameContains: effectiveName,
            group: effectiveGroup,
          ),
        );
  }

  if (manifest != null && !manifest.stale) {
    for (final claim in manifest.claims) {
      for (final selector in claim.selectors) {
        addSelector(
          claim.capabilityId,
          provider: selector.provider,
          nameContains: selector.nameContains,
          group: selector.group,
        );
      }
    }
  }
  for (final selector in profile.manualCapabilitySelectors) {
    addSelector(
      selector.capabilityId,
      provider: selector.provider,
      nameContains: selector.nameContains,
    );
  }
  return [
    for (final policy in profile.serviceRoutePolicies)
      if (policy.enabled && supported.contains(policy.capabilityId))
        RcxLaneConfig(
          capabilityId: policy.capabilityId,
          group: capabilityGroupName(policy.capabilityId),
          fallback: policy.fallback.name,
          role: _nullIfEmpty(resolvedClassRole(manifest, policy.capabilityId)),
          strategy: _nullIfEmpty(
            resolvedClassStrategy(manifest, policy.capabilityId),
          ),
          selectors: selectorsByCapability[policy.capabilityId] ?? const [],
        ),
  ];
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
