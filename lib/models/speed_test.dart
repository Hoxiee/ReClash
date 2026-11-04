import 'package:flutter/foundation.dart';

enum SpeedTestMode { complete, latencyOnly }

enum SpeedTestProtocol {
  http2('h2', 'HTTP/2'),
  http3('h3', 'HTTP/3');

  const SpeedTestProtocol(this.value, this.label);

  final String value;
  final String label;
}

@immutable
class SpeedTestServer {
  const SpeedTestServer({
    this.id = '',
    this.name = '',
    this.host = '',
    this.country = '',
    this.sponsor = '',
    this.latencyMs,
  });

  factory SpeedTestServer.fromJson(Map<String, dynamic> json) =>
      SpeedTestServer(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        host: json['host'] as String? ?? '',
        country: json['country'] as String? ?? '',
        sponsor: json['sponsor'] as String? ?? '',
        latencyMs: (json['latencyMs'] as num?)?.toDouble(),
      );

  final String id;
  final String name;
  final String host;
  final String country;
  final String sponsor;
  final double? latencyMs;

  String get title =>
      [sponsor, name].where((value) => value.isNotEmpty).join(' · ');

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'country': country,
    'sponsor': sponsor,
    'latencyMs': latencyMs,
  };

  @override
  bool operator ==(Object other) =>
      other is SpeedTestServer &&
      id == other.id &&
      name == other.name &&
      host == other.host &&
      country == other.country &&
      sponsor == other.sponsor &&
      latencyMs == other.latencyMs;

  @override
  int get hashCode => Object.hash(id, name, host, country, sponsor, latencyMs);
}

@immutable
class SpeedTestSettings {
  const SpeedTestSettings({
    this.backendId = 'cloudflare',
    this.mode = SpeedTestMode.complete,
    this.budgetMiB = 100,
    this.durationSeconds = 10,
    this.multiThread = true,
    this.protocol = SpeedTestProtocol.http2,
    this.useSystemDns = false,
    this.server,
  });

  static const platforms = {
    'apple': 'Apple',
    'cloudflare': 'Cloudflare',
    'speedtest': 'Speedtest.net',
    'librespeed': 'LibreSpeed',
  };
  static const budgets = [25, 50, 100, 250, 500, 1024];
  static const durations = [5, 10, 15, 20];

  final String backendId;
  final SpeedTestMode mode;
  final int budgetMiB;
  final int durationSeconds;
  final bool multiThread;
  final SpeedTestProtocol protocol;
  final bool useSystemDns;
  final SpeedTestServer? server;

  int get byteLimit => budgetMiB * 1024 * 1024;
  int get streams => multiThread ? 8 : 1;
  String get platformName => platforms[backendId] ?? backendId;

  static SpeedTestSettings safeFromJson(Object? value) {
    if (value is! Map) return const SpeedTestSettings();
    SpeedTestServer? server;
    try {
      final data = value['server'];
      if (data is Map) {
        server = SpeedTestServer.fromJson(Map<String, dynamic>.from(data));
      }
    } on Object {
      server = null;
    }
    return SpeedTestSettings(
      backendId: switch (value['backendId']) {
        final String id when platforms.containsKey(id) => id,
        _ => 'cloudflare',
      },
      mode: value['mode'] == SpeedTestMode.latencyOnly.name
          ? SpeedTestMode.latencyOnly
          : SpeedTestMode.complete,
      budgetMiB: budgets.contains(value['budgetMiB'])
          ? value['budgetMiB'] as int
          : 100,
      durationSeconds: durations.contains(value['durationSeconds'])
          ? value['durationSeconds'] as int
          : 10,
      multiThread: value['multiThread'] != false,
      protocol: value['protocol'] == 'h3'
          ? SpeedTestProtocol.http3
          : SpeedTestProtocol.http2,
      useSystemDns: value['useSystemDns'] == true,
      server: server,
    );
  }

  Map<String, Object?> toJson() => {
    'backendId': backendId,
    'mode': mode.name,
    'budgetMiB': budgetMiB,
    'durationSeconds': durationSeconds,
    'multiThread': multiThread,
    'protocol': protocol.value,
    'useSystemDns': useSystemDns,
    'server': server?.toJson(),
  };

  Map<String, Object?> toRequest({
    required String requestId,
    required String proxyName,
    required bool direct,
  }) => {
    'requestId': requestId,
    'backendId': backendId,
    'mode': mode.name,
    'durationSeconds': durationSeconds,
    'streams': streams,
    'protocol': protocol.value,
    'useSystemDns': direct && useSystemDns,
    'byteLimit': mode == SpeedTestMode.latencyOnly ? 0 : byteLimit,
    'proxyName': proxyName,
    'direct': direct,
    'server': backendId == 'speedtest' ? server?.toJson() : null,
  };

  SpeedTestSettings copyWith({
    String? backendId,
    SpeedTestMode? mode,
    int? budgetMiB,
    int? durationSeconds,
    bool? multiThread,
    SpeedTestProtocol? protocol,
    bool? useSystemDns,
    SpeedTestServer? server,
    bool clearServer = false,
  }) => SpeedTestSettings(
    backendId: backendId ?? this.backendId,
    mode: mode ?? this.mode,
    budgetMiB: budgetMiB ?? this.budgetMiB,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    multiThread: multiThread ?? this.multiThread,
    protocol: protocol ?? this.protocol,
    useSystemDns: useSystemDns ?? this.useSystemDns,
    server: clearServer ? null : server ?? this.server,
  );

  @override
  bool operator ==(Object other) =>
      other is SpeedTestSettings &&
      backendId == other.backendId &&
      mode == other.mode &&
      budgetMiB == other.budgetMiB &&
      durationSeconds == other.durationSeconds &&
      multiThread == other.multiThread &&
      protocol == other.protocol &&
      useSystemDns == other.useSystemDns &&
      server == other.server;

  @override
  int get hashCode => Object.hash(
    backendId,
    mode,
    budgetMiB,
    durationSeconds,
    multiThread,
    protocol,
    useSystemDns,
    server,
  );
}
