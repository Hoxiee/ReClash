import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

/// Sent as the wire `dv`, but the core overwrites it with its own
/// `rcxDefaultsVersion` (core/rcx_config.go), the real lever that drops learned
/// facts when shipped preset data changes. Kept only for wire-shape stability.
const smartRoutingDefaultsVersion = 5;

class SmartRoutingBundle {
  const SmartRoutingBundle({
    this.censorCountries = const [],
    this.canaryForeign = const [],
    this.canaryDomestic = const [],
    this.censorSNI = const [],
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
  final List<String> censorSNI;
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
// The home-country service rides last: it must never be the first word on
// whether an exit is abroad.
const _countryEchoes = [
  'https://api.country.is/',
  'https://countries.dev/ip',
  'https://api.ipgeo.ru/json/',
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
  // A domain the ТСПУ SNI-DPI cuts, dialed at the foreign anycast IPs the plain
  // canary already reaches: transit is proven there, so a ClientHello that draws
  // no ServerHello is censorship, not a dark link. This is the only signal that
  // arms the censoring ranking on a network that whitelists the bare IPs.
  censorSNI: ['rutracker.org'],
  // Both hosts are unreachable from every Russian egress while working abroad,
  // so reaching either proves a node is abroad and a home-country dud cannot.
  // Two of them means one host going dark does not blind the engine. Telegram
  // stays first (404 counts: its root 404s while the host answers); Instagram is
  // the fallback the probe tries only when Telegram fails. Instagram serves
  // redirects and rate-limit pages, so 301/302 count like 200: the host
  // answered, and only the payload status wobbled.
  openMarkers: [
    RcxMarker(url: 'https://api.telegram.org/', statuses: [200, 404]),
    RcxMarker(url: 'https://www.instagram.com/', statuses: [200, 301, 302]),
  ],
  domesticMarkers: [
    RcxMarker(url: 'https://ya.ru/', statuses: [200, 301, 302]),
  ],
  // localMarkers stay empty until a candidate is device-confirmed to answer only
  // from a Russian egress; an unverified one brands working foreign nodes.
  // Hints match whole tokens (short ones exactly), so a bare 'ru' token names
  // xx-ru nodes without catching surf or permask; rf, msk, ekb stay out.
  nameHints: [
    'росси',
    'russia',
    'москва',
    'moscow',
    'санкт',
    'петербург',
    'спб',
    'рф',
    'rus',
    'ru',
    'spb',
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

const _iran = SmartRoutingBundle(
  censorCountries: ['IR'],
  censorSNI: ['www.instagram.com'],
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
);

const _china = SmartRoutingBundle(
  censorCountries: ['CN'],
  censorSNI: ['www.google.com'],
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
);

// VERIFY before ship: canaryDomestic (a TE Data resolver reachable on :443) and
// domesticMarkers (a reliably-Egyptian host) are best-effort until measured.
const _egypt = SmartRoutingBundle(
  censorCountries: ['EG'],
  canaryForeign: [
    '1.1.1.1:443',
    '9.9.9.9:443',
    '8.8.8.8:443',
    '94.140.14.14:443',
  ],
  canaryDomestic: ['163.121.128.134:443'],
  openMarkers: [
    RcxMarker(url: 'https://www.gstatic.com/generate_204', statuses: [204]),
  ],
  domesticMarkers: [
    RcxMarker(url: 'https://www.te.eg/', statuses: [200, 301, 302]),
  ],
  egressEchoes: _egressEchoes,
  countryEchoes: _countryEchoes,
);

// Keyed by the lower-case preset wire, which doubles as the ISO code a region
// carries. Adding a country is one entry here plus its [CountryProfile] record.
const _bundles = <String, SmartRoutingBundle>{
  'ru': _russia,
  'ir': _iran,
  'cn': _china,
  'eg': _egypt,
};

/// The neutral preset seeds an operable engine with no country claim. Any code
/// without a shipped bundle falls back to it, so an unknown region still runs.
const neutralPreset = 'off';

/// The raw bundle a preset predefines. The neutral preset carries an empty
/// bundle; the operable neutral seed ([_neutral]) is what
/// [SmartRoutingPropsRcx.applyPreset] and enablement lay down instead.
/// An unshipped code falls back to that same neutral seed: an unknown region
/// still runs instead of idling on an engine that can never become operable.
SmartRoutingBundle bundleForPreset(String preset) {
  final code = preset.trim().toLowerCase();
  if (code.isEmpty || code == neutralPreset) return const SmartRoutingBundle();
  return _bundles[code] ?? _neutral;
}

/// The preset wire an upper-case region code seeds, and its inverse. The two
/// stores stay a case flip apart, except that no shipped country is [off] on the
/// routing side and [otherRegionCode] on the region side.
String presetForRegion(String? code) {
  final normalized = code?.trim().toUpperCase();
  return (normalized == null ||
          normalized.isEmpty ||
          normalized == otherRegionCode)
      ? neutralPreset
      : normalized.toLowerCase();
}

String regionForPreset(String preset) {
  final code = preset.trim().toLowerCase();
  return (code.isEmpty || code == neutralPreset)
      ? otherRegionCode
      : code.toUpperCase();
}

/// The pace belongs to the strategy, not to the region that seeds the rest.
class SmartRoutingPacing {
  const SmartRoutingPacing({
    required this.dwellSeconds,
    required this.waveWidth,
    required this.latencyBands,
    required this.absCeilingMs,
    required this.degradeConfirmSeconds,
    required this.proofTtlMinutes,
    this.ladder = const [],
    this.switchImproveMs = 0,
    this.switchImprovePct = 0,
    this.latencyStepMs = 0,
  });

  final int dwellSeconds;
  final int waveWidth;
  final List<int> latencyBands;
  final int absCeilingMs;
  final int degradeConfirmSeconds;
  final int proofTtlMinutes;

  /// Ladder and triggers are strategy-flavored but their shipped seed is
  /// "unset": empty/zero defers to the engine, and lowest-latency drops misfit
  /// through the strategy transform, not a distinct seeded ladder.
  final List<RcxRungSpec> ladder;
  final int switchImproveMs;
  final int switchImprovePct;
  final int latencyStepMs;
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
      latencyBands: [120, 200, 320, 550],
      absCeilingMs: 450,
      degradeConfirmSeconds: 90,
      proofTtlMinutes: 45,
    ),
    SmartRoutingStrategy.balanced => const SmartRoutingPacing(
      dwellSeconds: 90,
      waveWidth: 12,
      latencyBands: [80, 120, 180, 320],
      absCeilingMs: 300,
      degradeConfirmSeconds: 60,
      proofTtlMinutes: 30,
    ),
    SmartRoutingStrategy.lowestLatency => const SmartRoutingPacing(
      dwellSeconds: 30,
      waveWidth: 20,
      latencyBands: [65, 90, 130, 220],
      absCeilingMs: 200,
      degradeConfirmSeconds: 30,
      proofTtlMinutes: 20,
    ),
    SmartRoutingStrategy.saver => const SmartRoutingPacing(
      dwellSeconds: 600,
      waveWidth: 4,
      latencyBands: [150, 260, 420, 750],
      absCeilingMs: 650,
      degradeConfirmSeconds: 120,
      proofTtlMinutes: 60,
    ),
  };
}

/// Reset spares the user-owned avoidCountries/nodeRules, as applyPreset does.
enum RoutingFacetGroup {
  pacing,
  bands,
  probes,
  censorship,
  egress,
  heuristics,
  markers,
  ladder,
  triggers,
  vocabulary,
}

extension SmartRoutingPropsRcx on SmartRoutingProps {
  bool get _presetIsNeutral {
    final code = preset.trim().toLowerCase();
    return code.isEmpty || code == neutralPreset;
  }

  /// A preset seeds every field it owns, so picking a region also rewrites the
  /// canaries and markers the user could since have edited. Enablement is the
  /// user's, never the preset's.
  SmartRoutingProps applyPreset(String preset) {
    final code = preset.trim().toLowerCase();
    final neutral = code.isEmpty || code == neutralPreset;
    final bundle = neutral ? _neutral : bundleForPreset(preset);
    return copyWith(
      preset: preset,
      censorCountries: bundle.censorCountries,
      canaryForeign: bundle.canaryForeign,
      canaryDomestic: bundle.canaryDomestic,
      censorSNI: bundle.censorSNI,
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
    canaryForeign: value && _presetIsNeutral && canaryForeign.isEmpty
        ? _neutral.canaryForeign
        : canaryForeign,
    openMarkers: value && _presetIsNeutral && openMarkers.isEmpty
        ? _neutral.openMarkers
        : openMarkers,
    egressEchoes: value && _presetIsNeutral && egressEchoes.isEmpty
        ? _neutral.egressEchoes
        : egressEchoes,
    countryEchoes: value && _presetIsNeutral && countryEchoes.isEmpty
        ? _neutral.countryEchoes
        : countryEchoes,
  );

  /// Unlocking only opens Auto as a selectable mode; it never activates it.
  /// Locking retires an active Auto so the outbound mode can never point at a
  /// mode the selectors no longer offer.
  SmartRoutingProps withUnlocked(bool value) => copyWith(
    unlocked: value,
    enabled: value && enabled,
    canaryForeign: value && _presetIsNeutral && canaryForeign.isEmpty
        ? _neutral.canaryForeign
        : canaryForeign,
    openMarkers: value && _presetIsNeutral && openMarkers.isEmpty
        ? _neutral.openMarkers
        : openMarkers,
    egressEchoes: value && _presetIsNeutral && egressEchoes.isEmpty
        ? _neutral.egressEchoes
        : egressEchoes,
    countryEchoes: value && _presetIsNeutral && countryEchoes.isEmpty
        ? _neutral.countryEchoes
        : countryEchoes,
  );

  bool get matchesPreset => this == applyPreset(preset);

  SmartRoutingProps applyStrategy(SmartRoutingStrategy value) => copyWith(
    strategy: value,
    dwellSeconds: value.pacing.dwellSeconds,
    waveWidth: value.pacing.waveWidth,
    latencyBands: value.pacing.latencyBands,
    absCeilingMs: value.pacing.absCeilingMs,
    degradeConfirmSeconds: value.pacing.degradeConfirmSeconds,
    proofTtlMinutes: value.pacing.proofTtlMinutes,
    ladder: value.pacing.ladder,
    switchImproveMs: value.pacing.switchImproveMs,
    switchImprovePct: value.pacing.switchImprovePct,
    latencyStepMs: value.pacing.latencyStepMs,
  );

  /// Empty bands mean "unset, let the engine use its default", not a hand-tuned
  /// pace, so they never count as a divergence from the strategy.
  bool get matchesStrategy {
    final seeded = applyStrategy(strategy);
    return this ==
        (latencyBands.isEmpty
            ? seeded.copyWith(latencyBands: const [])
            : seeded);
  }

  /// Reseed strategy thresholds only when the pace hasn't diverged, so an upgrade never clobbers a hand-tuned config.
  SmartRoutingProps reseedStrategyPacing() {
    final pace = strategy.pacing;
    final seeded = copyWith(
      absCeilingMs: pace.absCeilingMs,
      degradeConfirmSeconds: pace.degradeConfirmSeconds,
      proofTtlMinutes: pace.proofTtlMinutes,
    );
    return seeded.matchesStrategy ? seeded : this;
  }

  /// Empty bands are "unset", never a divergence, mirroring matchesStrategy.
  bool matchesSeedGroup(RoutingFacetGroup group) {
    if (group == RoutingFacetGroup.bands && latencyBands.isEmpty) {
      return true;
    }
    return resetSeedGroup(group) == this;
  }

  SmartRoutingProps resetSeedGroup(RoutingFacetGroup group) {
    final seed = applyPreset(preset);
    final pace = strategy.pacing;
    return switch (group) {
      RoutingFacetGroup.pacing => copyWith(
        dwellSeconds: pace.dwellSeconds,
        waveWidth: pace.waveWidth,
        absCeilingMs: pace.absCeilingMs,
        degradeConfirmSeconds: pace.degradeConfirmSeconds,
        proofTtlMinutes: pace.proofTtlMinutes,
      ),
      RoutingFacetGroup.bands => copyWith(latencyBands: pace.latencyBands),
      RoutingFacetGroup.probes => copyWith(
        canaryForeign: seed.canaryForeign,
        canaryDomestic: seed.canaryDomestic,
        censorSNI: seed.censorSNI,
      ),
      RoutingFacetGroup.censorship => copyWith(
        censorCountries: seed.censorCountries,
      ),
      RoutingFacetGroup.egress => copyWith(
        egressEchoes: seed.egressEchoes,
        countryEchoes: seed.countryEchoes,
      ),
      RoutingFacetGroup.heuristics => copyWith(
        nameHints: seed.nameHints,
        breakerPatterns: seed.breakerPatterns,
      ),
      RoutingFacetGroup.markers => copyWith(
        openMarkers: seed.openMarkers,
        domesticMarkers: seed.domesticMarkers,
        localMarkers: seed.localMarkers,
      ),
      // Reset here clears to the "unset" seed rather than rewriting.
      RoutingFacetGroup.ladder => copyWith(ladder: pace.ladder),
      RoutingFacetGroup.triggers => copyWith(
        switchImproveMs: pace.switchImproveMs,
        switchImprovePct: pace.switchImprovePct,
        latencyStepMs: pace.latencyStepMs,
      ),
      RoutingFacetGroup.vocabulary => copyWith(labelOverrides: const {}),
    };
  }

  RcxConfigParams rcxParamsFor(Profile? profile) => RcxConfigParams(
    enabled: enabled,
    preset: preset,
    strategy: strategy.wire,
    defaultsVersion: smartRoutingDefaultsVersion,
    censorCountries: censorCountries,
    canaryForeign: canaryForeign,
    canaryDomestic: canaryDomestic,
    censorSNI: censorSNI,
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
    ladder: ladder,
    allowDomesticLastResort: allowDomesticLastResort,
    requireUdp: requireUdp,
    respectPick: respectPick,
    dwellSeconds: dwellSeconds,
    waveWidth: waveWidth,
    absCeilingMs: absCeilingMs,
    degradeConfirmSeconds: degradeConfirmSeconds,
    proofTtlMinutes: proofTtlMinutes,
    switchImproveMs: switchImproveMs,
    switchImprovePct: switchImprovePct,
    latencyStepMs: latencyStepMs,
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

/// The node to surface now: the engine's pick when smart routing has decided
/// one, otherwise the group's own fallback. Each call site keeps its own gate
/// for [engineDecided]; only this final selection is shared. Generic over the
/// fallback so a nullable pick stays nullable and a non-null one stays String.
T resolveCurrentNode<T extends String?>({
  required bool engineDecided,
  required String engineNode,
  required T fallback,
}) => engineDecided ? engineNode as T : fallback;
