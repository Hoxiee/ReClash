import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/doctor/sensors/device.dart';
import 'package:reclash/features/doctor/supervisor/network.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/features/traffic_forecast/forecast.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/ip_quality.dart';
import 'package:reclash/providers/outbound_ip.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/subscriptions/branding/brand.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/provider_settings.dart';
import 'package:reclash/ui/wallpaper_image.dart';
import 'package:reclash/views/navigation.dart';

import '../../test/helpers/test_profiles.dart';

/// Fictional subscriptions, nodes and traffic for README screenshots. Hosts
/// use reserved names and addresses come from documentation ranges.

const _gb = 1024 * 1024 * 1024;
const _mb = 1024 * 1024;
const exitIp = '203.0.113.42';

int _expiresIn(Duration duration) =>
    DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000;

final _env = Platform.environment;

/// `SNAPSHOT_BRAND=halo` (or `1`) or `ember` makes that subscription current,
/// delivering its customization the way a subscription with a provider config does.
final _brand = switch (_env['SNAPSHOT_BRAND']) {
  'ember' => 'ember',
  '1' || 'halo' => 'halo',
  _ => null,
};
final branded = _brand != null;
final _currentId = switch (_brand) {
  'ember' => 2,
  'halo' => 3,
  _ => 1,
};

/// The demo brand of the website mock; `SNAPSHOT_BRAND_ASSETS` points at its
/// `public/assets/mock` directory.
final _assets = Directory(
  _env['SNAPSHOT_BRAND_ASSETS'] ?? '../reclash-site/public/assets/mock',
);

Uint8List _asset(String name) {
  final file = File('${_assets.path}/$name');
  if (!file.existsSync()) {
    throw StateError('Missing ${file.path}; set SNAPSHOT_BRAND_ASSETS');
  }
  return file.readAsBytesSync();
}

String _dataUri(String name) =>
    'data:image/svg+xml;base64,${base64Encode(_asset(name))}';

final _mainGroup = switch (_brand) {
  'ember' => 'Ember Select',
  'halo' => 'Halo',
  _ => 'Proxy',
};
const _emberWallpaperUrl = 'https://cdn.ember.example/bg-ember.svg';
const _haloWallpaperUrl = 'https://cdn.halo.example/halo-wallpaper.svg';

final _haloBrand = ProviderBrand(
  source: ProviderBrandSource.manifest,
  resolvedAt: DateTime.now(),
  color: 0xFF3FD8C2,
  logo: ProviderLogo(bytes: _asset('halo-logo.svg'), svg: true),
  logoDark: ProviderLogo(bytes: _asset('halo-logo-dark.svg'), svg: true),
);

final _emberBrand = ProviderBrand(
  source: ProviderBrandSource.manifest,
  resolvedAt: DateTime.now(),
  color: 0xFFFF6B1A,
  logo: ProviderLogo(bytes: _asset('logo-ember.svg'), svg: true),
  logoDark: ProviderLogo(bytes: _asset('logo-ember-dark.svg'), svg: true),
);

final _brands = <int, ProviderBrand>{2: _emberBrand, 3: _haloBrand};

final _haloMetadata = SubscriptionMetadata({
  'provider.name': 'Halo',
  'provider.logo': _dataUri('halo-logo.svg'),
  'provider.logoDark': _dataUri('halo-logo-dark.svg'),
  'provider.announce':
      'A brief eclipse: Halo shows a provider with full branding.',
  'provider.announceUrl': 'https://example.com/halo/news',
  'provider.notice': 'Maintenance at 02:00 UTC. Connections may drop.',
  'provider.noticeUrl': 'https://example.com/halo/status',
  'subscription.type': 'test',
  'presentation.hideUrl': true,
  'presentation.serverGroup': _mainGroup,
});

/// The hosted file of Halo, minus the images a render cannot fetch.
final _haloConfig = jsonEncode({
  'version': 1,
  'view': {
    'app': {
      'color': '#3FD8C2',
      'color-dark': '#7CF3E1',
      'style': 'vivid',
      'black': true,
      'glass': 'ultra',
      'navbar': 'floating',
    },
    'proxies': {
      'type': 'list',
      'sort': 'delay',
      'layout': 'tight',
      'icon': 'filled',
      'card': 'compact',
    },
  },
  'power-button': {
    'shape': ['sunny', 'verySunny', 'flower'],
    'type': 'solid',
  },
  'wallpaper': {'url': _haloWallpaperUrl, 'opacity': 45},
  'widgets': [
    'currentOutbound',
    'health',
    'networkSpeed',
    'outboundMode',
    'serviceStatus',
    'profiles',
    'proxyGroups',
    'connectionStats',
  ],
  'power-labels': {
    'off': 'Step into the light',
    'on': ['Quiet and protected'],
    'connecting': {'title': 'Connecting to {server}', 'hint': 'Just a moment'},
  },
});

ProviderHints _haloHints() {
  final parsed = parseProviderConfig(_haloConfig, 'en');
  if (parsed.config == null || parsed.warnings.isNotEmpty) {
    throw StateError('Halo config: ${parsed.warnings}');
  }
  return ProviderHints(_haloMetadata, config: parsed.config);
}

final _emberMetadata = SubscriptionMetadata({
  'provider.name': 'Ember Line',
  'provider.logo': _dataUri('logo-ember.svg'),
  'provider.logoDark': _dataUri('logo-ember-dark.svg'),
  'provider.announce':
      'Ember Line: provider styling from wallpaper to the connect button.',
  'provider.announceUrl': 'https://example.com/ember/news',
  'provider.notice': 'Maintenance at 02:00 UTC. Connections may drop.',
  'provider.noticeUrl': 'https://example.com/ember/status',
  'subscription.type': 'test',
});

/// The Ember Line mock of the website, minus the cards whose images a render
/// cannot fetch.
final _emberConfig = jsonEncode({
  'version': 1,
  'view': {
    'app': {
      'color': '#FF6B1A',
      'color-dark': '#FFA66B',
      'style': 'vivid',
      'black': true,
      'glass': 'ultra',
      'navbar': 'floating',
    },
  },
  'power-button': {
    'shape': ['sharpBurst', 'puffyDiamond', 'clover8Leaf'],
    'type': 'tonal',
  },
  'wallpaper': {'url': _emberWallpaperUrl, 'opacity': 22},
  'widgets': [
    'currentOutbound',
    'health',
    'outboundMode',
    'serviceStatus',
    'profiles',
    'proxyGroups',
  ],
  'power-labels': {
    'off': 'Tap to ignite',
    'on': ['The fire is lit'],
    'connecting': {'title': 'Connecting to {server}', 'hint': 'Just a moment'},
  },
});

ProviderHints _emberHints() {
  final parsed = parseProviderConfig(_emberConfig, 'en');
  if (parsed.config == null || parsed.warnings.isNotEmpty) {
    throw StateError('Ember Line config: ${parsed.warnings}');
  }
  return ProviderHints(_emberMetadata, config: parsed.config);
}

String get _wallpaperFile =>
    '${md5.convert(utf8.encode(_brand == 'ember' ? _emberWallpaperUrl : _haloWallpaperUrl))}.svg';

/// A week of daily use at roughly 3 GB a day, ending with a partial today.
List<UsageDay> _usage() {
  const gb = 1024 * 1024 * 1024;
  const daily = [2.8, 3.6, 2.1, 4.0, 3.3, 2.9, 3.4];
  final today = usageDayOf(DateTime.now());
  return [
    for (var i = 0; i < daily.length; i++)
      UsageDay(today - daily.length + i, (daily[i] * gb).round(), 0),
    UsageDay(today, gb ~/ 2, 42 * gb),
  ];
}

SubscriptionSnapshot? _snapshot(int id) => switch (id) {
  _ when id != _currentId => null,
  2 => SubscriptionSnapshot(
    metadata: _emberMetadata,
    receivedAt: DateTime.now(),
  ),
  3 => SubscriptionSnapshot(
    metadata: _haloMetadata,
    receivedAt: DateTime.now(),
  ),
  _ => null,
};

Profile _subscription(
  int id,
  String label,
  String url, {
  required Duration updated,
  required int used,
  required int total,
  required Duration left,
}) => Profile.normal(label: label, url: url).copyWith(
  id: id,
  lastUpdateDate: DateTime.now().subtract(updated),
  selectedMap: id == _currentId ? {_mainGroup: '🇳🇱 Amsterdam 01'} : {},
  unfoldSet: id == _currentId ? {_mainGroup} : {},
  favoriteSet: id == _currentId ? {'🇩🇪 Frankfurt 02', '🇯🇵 Tokyo 03'} : {},
  subscriptionSnapshot: _snapshot(id),
  subscriptionInfo: SubscriptionInfo(
    upload: used ~/ 10,
    download: used - used ~/ 10,
    total: total,
    expire: _expiresIn(left),
  ),
);

final profiles = [
  _subscription(
    1,
    'Nebula Cloud',
    'https://sub.nebula.example/clash',
    updated: const Duration(hours: 2),
    used: 42 * _gb,
    total: 100 * _gb,
    left: const Duration(days: 23),
  ),
  _subscription(
    2,
    'Ember Line',
    'https://sub.emberline.example/clash',
    updated: const Duration(hours: 5),
    used: 21 * _gb,
    total: 100 * _gb,
    left: const Duration(days: 29),
  ),
  _subscription(
    3,
    'Halo',
    'https://sub.halo.example/clash',
    updated: const Duration(minutes: 40),
    used: 21 * _gb,
    total: 100 * _gb,
    left: const Duration(days: 30),
  ),
  _subscription(
    4,
    'Aurora Mesh',
    'https://aurora.example/api/v1/sub',
    updated: const Duration(days: 1),
    used: 212 * _gb,
    total: 500 * _gb,
    left: const Duration(days: 148),
  ),
  Profile.normal(label: 'Home server').copyWith(
    id: 5,
    lastUpdateDate: DateTime.now().subtract(const Duration(days: 6)),
  ),
];

const _delays = {
  'Auto': 48,
  '🇳🇱 Amsterdam 01': 42,
  '🇩🇪 Frankfurt 02': 38,
  '🇫🇮 Helsinki 01': 55,
  '🇬🇧 London 01': 61,
  '🇵🇱 Warsaw 01': 47,
  '🇯🇵 Tokyo 03': 214,
  '🇸🇬 Singapore 01': 176,
  '🇺🇸 New York 02': 118,
  '🇺🇸 Los Angeles 01': 163,
};

const _types = {
  '🇫🇮 Helsinki 01': 'Hysteria2',
  '🇯🇵 Tokyo 03': 'Trojan',
  '🇺🇸 New York 02': 'VMess',
  '🇬🇧 London 01': 'TUIC',
};

Proxy _node(String name) => Proxy(name: name, type: _types[name] ?? 'VLESS');

final _nodes = [
  for (final name in _delays.keys)
    if (name != 'Auto') _node(name),
];

/// Routes through a domestic entry, offered in the main group.
final _chains = [
  for (final (i, exit) in const [
    '🇳🇱 Amsterdam 01',
    '🇫🇮 Helsinki 01',
  ].indexed)
    ProxyChain(
      id: i + 1,
      profileId: 1,
      name: autoChainName(['🇷🇺 Moscow 01', exit]),
      hops: ['🇷🇺 Moscow 01', exit],
      sortIndex: i,
    ),
];

const _chainDelays = [71, 86];

final groups = [
  Group(
    type: GroupType.Selector,
    name: _mainGroup,
    hidden: false,
    now: '🇳🇱 Amsterdam 01',
    all: [
      const Proxy(name: 'Auto', type: 'URLTest'),
      for (final chain in _chains) Proxy(name: chain.name, type: 'Selector'),
      ..._nodes,
    ],
  ),
  Group(
    type: GroupType.URLTest,
    name: 'Auto',
    hidden: false,
    now: '🇩🇪 Frankfurt 02',
    all: _nodes.take(5).toList(),
  ),
  Group(
    type: GroupType.Selector,
    name: 'Streaming',
    hidden: false,
    now: '🇯🇵 Tokyo 03',
    all: [
      _node('🇯🇵 Tokyo 03'),
      _node('🇺🇸 New York 02'),
      _node('🇺🇸 Los Angeles 01'),
    ],
  ),
  Group(
    type: GroupType.Selector,
    name: 'AI',
    hidden: false,
    now: '🇺🇸 New York 02',
    all: [_node('🇺🇸 New York 02'), _node('🇺🇸 Los Angeles 01')],
  ),
  Group(
    type: GroupType.Fallback,
    name: 'Telegram',
    hidden: false,
    now: '🇳🇱 Amsterdam 01',
    all: [_node('🇳🇱 Amsterdam 01'), _node('🇫🇮 Helsinki 01')],
  ),
];

/// A smooth curve, so the speed sparklines look like a session in progress.
FixedList<Traffic> _traffics() {
  var list = FixedList<Traffic>(trafficSampleLength);
  for (var i = 0; i < trafficSampleLength; i++) {
    final wave = math.sin(i / 4) + 0.6 * math.sin(i / 1.7 + 1);
    list = list.append(
      Traffic(
        up: ((38 + 14 * wave) * 1024).round(),
        down: ((1.9 + 0.7 * wave) * _mb).round(),
      ),
    );
  }
  return list;
}

final _connections = [
  for (final (i, (process, host, port, chain, down, up)) in const [
    ('Firefox', 'www.youtube.com', '443', '🇯🇵 Tokyo 03', 812, 14),
    ('Telegram', '149.154.167.51', '443', '🇳🇱 Amsterdam 01', 46, 9),
    ('Code', 'github.com', '443', '🇳🇱 Amsterdam 01', 23, 3),
    ('Spotify', 'audio-fa.scdn.co', '443', '🇳🇱 Amsterdam 01', 61, 1),
    ('Steam', 'cdn.steamstatic.com', '443', 'DIRECT', 1430, 6),
    ('Discord', 'gateway.discord.gg', '443', '🇩🇪 Frankfurt 02', 4, 2),
    ('Firefox', 'chatgpt.com', '443', '🇺🇸 New York 02', 18, 4),
  ].indexed)
    TrackerInfo(
      id: '$i',
      download: down * _mb ~/ 10,
      upload: up * _mb ~/ 10,
      downloadSpeed: down * 1024 ~/ (i + 2),
      uploadSpeed: up * 512 ~/ (i + 2),
      start: DateTime.now().subtract(Duration(minutes: 3 + i * 7)),
      metadata: Metadata(
        network: 'tcp',
        host: host,
        destinationPort: port,
        process: process,
        sourceIP: '192.168.1.24',
      ),
      chains: [chain],
      rule: chain == 'DIRECT' ? 'GeoSite' : 'Match',
      rulePayload: chain == 'DIRECT' ? 'steam' : '',
    ),
];

class _Core extends Mock implements CoreHandlerInterface {}

CoreController _core() {
  final core = _Core();
  when(core.getConnections).thenAnswer((_) async => _connections);
  when(core.getConnectionCount).thenAnswer((_) async => _connections.length);
  when(core.getMemoryStats).thenAnswer(
    (_) async => const CoreMemoryStats(
      rss: 61 * _mb,
      heapInuse: 24 * _mb,
      heapIdle: 9 * _mb,
      stackInuse: 2 * _mb,
      runtimeOther: 7 * _mb,
    ),
  );
  // ignore: invalid_use_of_visible_for_testing_member
  return CoreController.scoped(core);
}

class _OutboundIp extends OutboundIpProbe {
  @override
  RoutedProbeState<String, IpInfo> build() => RoutedProbeState({
    for (final target in [routedOutbound, ..._delays.keys])
      target: const ProbeEntry(
        phase: ProbePhase.fresh,
        value: IpInfo(ip: exitIp, countryCode: 'NL'),
      ),
  });

  @override
  void watch(String target) {}

  @override
  void unwatch(String target) {}
}

class _Services extends ServiceStatus {
  @override
  RoutedProbeState<ServiceTarget, ServiceCheck> build() => RoutedProbeState({
    for (final (i, target) in ServiceTarget.values.indexed)
      target: ProbeEntry(
        phase: ProbePhase.fresh,
        value: ServiceCheck(
          ServiceProbeStatus.available,
          delay: 90 + (i * 37) % 140,
          region: 'NL',
          checkedAt: DateTime.now(),
        ),
      ),
  });

  @override
  void watch(ServiceTarget target) {}

  @override
  void unwatch(ServiceTarget target) {}
}

/// Never schedules the periodic update check, which would outlive a capture.
class _NoUpdates extends AppUpdateAction {
  @override
  AppUpdateState build() => const AppUpdateState();
}

Future<void> setUp() async {
  navigationPort = navigation;
}

/// A render has no platform side for connectivity_plus or the battery event
/// channel, so the providers that listen to them get fixed answers.
class _Network implements NetworkWatch {
  @override
  Future<NetworkCostSnapshot> read() async =>
      const NetworkCostSnapshot(cost: NetworkCost.unmetered, identity: 'wifi');

  @override
  Stream<Object?> get events => const Stream.empty();
}

class _Health extends ConnectionHealthState {
  @override
  ConnectionHealth build() => ConnectionHealth(
    phase: ConnectionPhase.verified,
    checkedAt: DateTime.now(),
  );
}

class _Battery extends BatteryOptimizationIgnored {
  @override
  Stream<bool?> build() => Stream.value(true);
}

/// What a subscription's provider config leaves in the app settings, applied
/// by the same code that applies a real one.
Config _config(DashboardStyle dashboard, ProviderHints? hints) {
  final base = Config(
    currentProfileId: _currentId,
    themeProps: defaultThemeProps,
    appSettingProps: AppSettingProps(
      dashboardStyle: dashboard,
      sidebarExpanded: true,
    ),
  );
  return hints == null
      ? base
      : applyProviderSettings(
          base,
          ProviderSettingsInput(hints, backgroundFile: _wallpaperFile),
        );
}

List<Override> overrides({DashboardStyle dashboard = DashboardStyle.detailed}) {
  final hints = switch (_brand) {
    'ember' => _emberHints(),
    'halo' => _haloHints(),
    _ => null,
  };
  final config = _config(dashboard, hints);
  return [
    initProvider.overrideWithBuild((_, _) => true),
    ...buildConfigOverrides(config),
    if (hints != null) ...[
      providerHintsProvider.overrideWithValue(hints),
      effectiveWallpaperImageProvider.overrideWithValue(
        SvgWallpaperSource(
          SvgBytesLoader(
            _asset(_brand == 'ember' ? 'bg-ember.svg' : 'halo-wallpaper.svg'),
          ),
        ),
      ),
    ],
    for (final MapEntry(:key, :value) in _brands.entries)
      profileBrandProvider(key).overrideWith((_) async => value),
    for (final id in [1, 2, 3, 4])
      trafficUsageProvider(id).overrideWith((_) => Stream.value(_usage())),
    networkWatchProvider.overrideWithValue(_Network()),
    deviceDoctorStateProvider.overrideWith((_) => const Stream.empty()),
    connectionHealthProvider.overrideWith(_Health.new),
    batteryOptimizationIgnoredProvider.overrideWith(_Battery.new),
    coreHandlerProvider.overrideWithValue(_core()),
    coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
    profilesProvider.overrideWith(() => TestProfiles(profiles)),
    groupsProvider.overrideWithBuild((_, _) => groups),
    chainReportsProvider.overrideWith(_ChainReports.new),
    profileChainsProvider(
      _currentId,
    ).overrideWith((_) => Stream.value(_chains)),
    delayDataSourceProvider.overrideWithBuild(
      (_, _) => {
        defaultTestUrl: {
          ..._delays,
          for (final (i, chain) in _chains.indexed) chain.name: _chainDelays[i],
        },
      },
    ),
    runTimeProvider.overrideWithBuild((_, _) => 8037000),
    localIpProvider.overrideWithBuild((_, _) => '192.168.1.24'),
    requestCountProvider.overrideWithBuild((_, _) => 1284),
    dnsQueryCountProvider.overrideWithBuild((_, _) => 342),
    trafficsProvider.overrideWithBuild((_, _) => _traffics()),
    totalTrafficProvider.overrideWithBuild(
      (_, _) => const Traffic(up: 1288490188, down: 9234179686),
    ),
    appUpdateActionProvider.overrideWith(_NoUpdates.new),
    outboundIpProbeProvider.overrideWith(_OutboundIp.new),
    serviceStatusProvider.overrideWith(_Services.new),
    ipQualityProvider(exitIp).overrideWith(
      (_) async => const IpQuality(
        ip: exitIp,
        source: IpQualitySource.ipApiIs,
        type: IpType.residential,
        organization: 'Example Broadband',
      ),
    ),
  ];
}

class _ChainReports extends ChainReports {
  @override
  Map<int, ChainReport> build() => {
    for (final chain in _chains)
      chain.id: ChainReport(
        id: chain.id,
        group: chain.name,
        status: ChainStatus.ok,
        target: _mainGroup,
      ),
  };
}
