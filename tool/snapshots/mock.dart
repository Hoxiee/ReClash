import 'dart:math' as math;

import 'package:flutter_riverpod/misc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/ip_quality.dart';
import 'package:reclash/providers/outbound_ip.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/views/navigation.dart';

import '../../test/helpers/test_profiles.dart';

/// Fictional subscriptions, nodes and traffic for README screenshots. Hosts
/// use reserved names and addresses come from documentation ranges.

const _gb = 1024 * 1024 * 1024;
const _mb = 1024 * 1024;
const exitIp = '203.0.113.42';

int _expiresIn(Duration duration) =>
    DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000;

final profiles = [
  Profile.normal(
    label: 'Nebula Cloud',
    url: 'https://sub.nebula.example/clash',
  ).copyWith(
    id: 1,
    lastUpdateDate: DateTime.now().subtract(const Duration(hours: 2)),
    selectedMap: const {'Proxy': '🇳🇱 Amsterdam 01'},
    unfoldSet: const {'Proxy'},
    subscriptionInfo: SubscriptionInfo(
      upload: 6 * _gb,
      download: 36 * _gb,
      total: 100 * _gb,
      expire: _expiresIn(const Duration(days: 23)),
    ),
  ),
  Profile.normal(
    label: 'Aurora Mesh',
    url: 'https://aurora.example/api/v1/sub',
  ).copyWith(
    id: 2,
    lastUpdateDate: DateTime.now().subtract(const Duration(days: 1)),
    subscriptionInfo: SubscriptionInfo(
      download: 212 * _gb,
      total: 500 * _gb,
      expire: _expiresIn(const Duration(days: 148)),
    ),
  ),
  Profile.normal(
    label: 'Lumen VPN',
    url: 'https://lumen.example/s/3f9c2a',
  ).copyWith(
    id: 3,
    lastUpdateDate: DateTime.now().subtract(const Duration(hours: 9)),
    subscriptionInfo: SubscriptionInfo(
      upload: 2 * _gb,
      download: 17 * _gb,
      total: 50 * _gb,
      expire: _expiresIn(const Duration(days: 4)),
    ),
  ),
  Profile.normal(label: 'Home server').copyWith(
    id: 4,
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

final groups = [
  Group(
    type: GroupType.Selector,
    name: 'Proxy',
    hidden: false,
    now: '🇳🇱 Amsterdam 01',
    all: [
      const Proxy(name: 'Auto', type: 'URLTest'),
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

List<Override> overrides({
  DashboardStyle dashboard = DashboardStyle.detailed,
}) => [
  initProvider.overrideWithBuild((_, _) => true),
  appSettingProvider.overrideWithBuild(
    (_, _) => AppSettingProps(dashboardStyle: dashboard, sidebarExpanded: true),
  ),
  coreHandlerProvider.overrideWithValue(_core()),
  coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
  profilesProvider.overrideWith(() => TestProfiles(profiles)),
  currentProfileIdProvider.overrideWithBuild((_, _) => 1),
  groupsProvider.overrideWithBuild((_, _) => groups),
  delayDataSourceProvider.overrideWithBuild(
    (_, _) => {defaultTestUrl: _delays},
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
