import 'dart:math' as math;

import 'package:reclash/common/service_probe.dart';
import 'package:reclash/models/models.dart';

/// Fictional network results for a test subscription, which has no working
/// servers. Hosts use reserved names and addresses come from documentation
/// ranges.
class CoreSandbox {
  CoreSandbox();

  static const exitIp = '203.0.113.42';
  static const _traceUrl = 'https://www.cloudflare.com/cdn-cgi/trace';
  static const _mb = 1024 * 1024;

  final _started = DateTime.now();
  final _closed = <String>{};
  var _total = const Traffic();

  /// Seeded by name, so a node keeps its latency between tests.
  Delay delay(String url, String proxyName) {
    final seed = _seed(proxyName);
    return Delay(
      name: proxyName,
      url: url,
      value: seed % 9 == 0 ? -1 : 30 + seed % 220,
    );
  }

  OutboundIpResult outboundIp(OutboundIpParams params) => OutboundIpResult(
    url: _traceUrl,
    body: 'ip=$exitIp\nloc=NL\n',
    delay: 40 + _seed(params.proxyName) % 120,
  );

  List<ServiceCheckItem> serviceCheck(ServiceCheckParams params) {
    final names = params.names.isEmpty
        ? ServiceTarget.values.map((target) => target.id)
        : params.names;
    return [
      for (final name in names)
        ServiceCheckItem(
          name: name,
          status: ServiceProbeStatus.available.id,
          region: 'NL',
          delay: 90 + _seed('${params.proxyName}$name') % 140,
          checkedAt: DateTime.now().millisecondsSinceEpoch,
        ),
    ];
  }

  /// A smooth wave, so the speed sparklines look like a session in progress.
  Traffic traffic() {
    final t = DateTime.now().difference(_started).inMilliseconds / 1000;
    final wave = math.sin(t / 4) + 0.6 * math.sin(t / 1.7 + 1);
    final traffic = Traffic(
      up: ((38 + 14 * wave) * 1024).round(),
      down: ((1.9 + 0.7 * wave) * _mb).round(),
    );
    _total = Traffic(
      up: _total.up + traffic.up,
      down: _total.down + traffic.down,
    );
    return traffic;
  }

  Traffic totalTraffic() => _total;

  List<TrackerInfo> connections() => [
    for (final (i, (process, host, direct, down, up)) in const [
      ('Firefox', 'www.youtube.com', false, 812, 14),
      ('Telegram', '149.154.167.51', false, 46, 9),
      ('Code', 'github.com', false, 23, 3),
      ('Spotify', 'audio-fa.scdn.co', false, 61, 1),
      ('Steam', 'cdn.steamstatic.com', true, 1430, 6),
      ('Discord', 'gateway.discord.gg', false, 4, 2),
    ].indexed)
      if (!_closed.contains('$i'))
        TrackerInfo(
          id: '$i',
          download: down * _mb ~/ 10,
          upload: up * _mb ~/ 10,
          downloadSpeed: down * 1024 ~/ (i + 2),
          uploadSpeed: up * 512 ~/ (i + 2),
          start: _started.subtract(Duration(minutes: 3 + i * 7)),
          metadata: Metadata(
            network: 'tcp',
            host: host,
            destinationPort: '443',
            process: process,
            sourceIP: '192.168.1.24',
          ),
          chains: [direct ? 'DIRECT' : sandboxGroup],
          rule: direct ? 'GeoSite' : 'Match',
          rulePayload: direct ? 'steam' : '',
        ),
  ];

  void closeConnection(String id) => _closed.add(id);

  void closeConnections() => _closed.addAll(['0', '1', '2', '3', '4', '5']);

  static int _seed(String value) =>
      value.codeUnits.fold(17, (hash, unit) => (hash * 31 + unit) & 0xffffff);
}

const sandboxGroup = 'Proxy';

const _sandboxNodes = [
  '🇳🇱 Amsterdam 01',
  '🇩🇪 Frankfurt 02',
  '🇫🇮 Helsinki 01',
  '🇬🇧 London 01',
  '🇵🇱 Warsaw 01',
  '🇯🇵 Tokyo 03',
  '🇸🇬 Singapore 01',
  '🇺🇸 New York 02',
];

/// A test subscription may ship no nodes at all; it gets fictional ones so
/// the proxy pages have something to show.
Map<String, dynamic> withSandboxNodes(Map<String, dynamic> rawConfig) {
  final proxies = rawConfig['proxies'];
  final providers = rawConfig['proxy-providers'];
  if ((proxies is List && proxies.isNotEmpty) ||
      (providers is Map && providers.isNotEmpty)) {
    return rawConfig;
  }
  final groups = rawConfig['proxy-groups'];
  final rules = rawConfig['rules'];
  return {
    ...rawConfig,
    'proxies': [
      for (final (i, name) in _sandboxNodes.indexed)
        {
          'name': name,
          'server': '192.0.2.${10 + i}',
          'port': 443,
          ...switch (i % 3) {
            0 => {'type': 'trojan', 'password': 'sandbox'},
            1 => {'type': 'ss', 'cipher': 'aes-128-gcm', 'password': 'sandbox'},
            _ => {'type': 'socks5'},
          },
        },
    ],
    if (groups is! List || groups.isEmpty)
      'proxy-groups': [
        {'name': sandboxGroup, 'type': 'select', 'proxies': _sandboxNodes},
      ],
    if (rules is! List || rules.isEmpty) 'rules': ['MATCH,$sandboxGroup'],
  };
}
