/// Xray-JSON subscription import (Happ/INCY panels): xray outbounds in, a
/// Clash config out; undialable ones are skipped, not silently degraded.
library;

import 'dart:convert';

import 'skipped_node.dart';
import 'subscription_links.dart';

bool isXrayConfigInput(String body) {
  final trimmed = body.trimLeft();
  if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return false;
  try {
    final decoded = jsonDecode(trimmed);
    return _configsOf(decoded).isNotEmpty;
  } catch (_) {
    return false;
  }
}

class XrayConfigResult implements ConvertedSubscription {
  const XrayConfigResult({required this.config, this.skipped = const []});

  @override
  final String config;

  @override
  final List<SkippedNode> skipped;
}

XrayConfigResult? tryConvertXrayConfig(String body) {
  final decoded = _tryJson(body);
  if (decoded == null) return null;
  final configs = _configsOf(decoded);
  if (configs.isEmpty) return null;

  // One server can appear under several routing tags across mode-configs.
  final groups = <String, (Map<String, Object?>, List<({String name, bool generic})>)>{};
  final skipped = <String, SkippedNode>{};

  void recordSkipped(SkippedNode node, {String? handle}) {
    skipped.putIfAbsent('${node.kind}|${handle ?? node.name}', () => node);
  }

  for (final config in configs) {
    // An INCY amneziawg container is skipped wholesale, each server named.
    if (config['type'] == 'amneziawg') {
      final servers = config['servers'];
      if (servers is List && servers.isNotEmpty) {
        for (final server in servers) {
          final name = server is Map<String, Object?>
              ? (server['name'] ?? server['remark'])?.toString() ?? ''
              : '';
          recordSkipped(SkippedNode(
            name: name.isEmpty ? 'amneziawg' : name,
            kind: 'amneziawg',
            reason: SkippedNodeReason.protocol,
          ));
        }
      } else {
        recordSkipped(const SkippedNode(
          name: 'amneziawg',
          kind: 'amneziawg',
          reason: SkippedNodeReason.protocol,
        ));
      }
      continue;
    }
    final remarks = config['remarks']?.toString();
    final outbounds = config['outbounds'];
    if (outbounds is! List) continue;
    for (final outbound in outbounds) {
      if (outbound is! Map<String, Object?>) continue;
      final Map<String, Object?>? proxy;
      try {
        proxy = _convertOutbound(outbound, fallbackName: remarks);
      } on _UnsupportedOutbound catch (e) {
        recordSkipped(e.node);
        continue;
      }
      if (proxy == null) continue;
      final transport = proxy.remove('x-unsupported-transport')?.toString();
      if (transport != null) {
        final tag = outbound['tag']?.toString() ?? '';
        recordSkipped(
          SkippedNode(
            name: _isGenericTag(tag)
                ? proxy['server']?.toString() ?? tag
                : tag,
            kind: transport == 'splithttp' ? 'xhttp' : transport,
            reason: SkippedNodeReason.transport,
          ),
          handle: proxy['server']?.toString(),
        );
        continue;
      }
      final tag = outbound['tag']?.toString() ?? '';
      final candidate = (
        name: proxy['name']! as String,
        generic: _isGenericTag(tag),
      );
      final entry = groups[_fingerprint(proxy)];
      if (entry == null) {
        groups[_fingerprint(proxy)] = (proxy, [candidate]);
      } else {
        entry.$2.add(candidate);
      }
    }
  }

  final proxies = <Map<String, Object?>>[];
  final seen = <String>{};
  for (final entry in groups.values) {
    final (proxy, candidates) = entry;
    var name = candidates
        .firstWhere((c) => !c.generic, orElse: () => candidates.first)
        .name;
    if (candidates.every((c) => c.generic)) {
      name = proxy['server']! as String;
    }
    final base = name;
    var suffix = 2;
    while (seen.contains(name)) {
      name = '$base $suffix';
      suffix++;
    }
    proxy['name'] = name;
    seen.add(name);
    proxies.add(proxy);
  }

  if (proxies.isEmpty) return null;
  return XrayConfigResult(
    config: emitProxiesConfig(proxies),
    skipped: skipped.values.toList(growable: false),
  );
}

/// Thrown for protocols mihomo cannot dial; service outbounds are routing machinery and return null.
class _UnsupportedOutbound implements Exception {
  const _UnsupportedOutbound(this.node);

  final SkippedNode node;
}

/// Routing-role tags name the role, not the node; an empty tag is not generic.
final _genericTagPattern = RegExp(
  r'^(proxy|node|server|primary|backup|main|out|outbound|direct|block)'
  r'([-_ ]?\d+)?$',
  caseSensitive: false,
);

bool _isGenericTag(String tag) => _genericTagPattern.hasMatch(tag.trim());

String _fingerprint(Map<String, Object?> proxy) {
  final keys = proxy.keys.where((k) => k != 'name').toList()..sort();
  return '[${[for (final k in keys) '$k:${_canon(proxy[k])}'].join(',')}]';
}

String _canon(Object? value) {
  if (value is Map<String, Object?>) {
    final keys = value.keys.toList()..sort();
    return '{${[for (final k in keys) '$k:${_canon(value[k])}'].join(',')}}';
  }
  if (value is List) return '[${value.map(_canon).join(',')}]';
  return jsonEncode(value);
}

// Shape walking.

List<Map<String, Object?>> _configsOf(Object? decoded) {
  if (decoded is Map<String, Object?> && decoded['outbounds'] is List) {
    return [decoded];
  }
  if (decoded is List) {
    return [
      for (final entry in decoded)
        if (entry is Map<String, Object?> &&
            // An amneziawg container has no outbounds — it IS the payload.
            (entry['outbounds'] is List || entry['type'] == 'amneziawg'))
          entry,
    ];
  }
  return const [];
}

Object? _tryJson(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return null;
  }
}

// Outbound mapping — xray fields to mihomo proxy maps.

Map<String, Object?>? _convertOutbound(
  Map<String, Object?> outbound, {
  required String? fallbackName,
}) {
  final protocol = outbound['protocol']?.toString() ?? '';
  final tag = outbound['tag']?.toString() ?? '';
  final name = tag.isNotEmpty ? tag : (fallbackName ?? '');

  return switch (protocol) {
    'vless' => _convertVless(outbound, name),
    'vmess' => _convertVmess(outbound, name),
    'trojan' => _convertTrojan(outbound, name),
    'shadowsocks' => _convertShadowsocks(outbound, name),
    'http' => _convertHttp(outbound, name),
    'socks' => _convertSocks(outbound, name),
    'wireguard' => _convertWireguardOutbound(outbound, name),
    '' || 'freedom' || 'blackhole' || 'dns' => null,
    _ => throw _UnsupportedOutbound(SkippedNode(
        name: name.isEmpty ? protocol : name,
        kind: protocol,
        reason: SkippedNodeReason.protocol,
      )),
  };
}

Map<String, Object?>? _convertVless(Map<String, Object?> outbound, String name) {
  final settings = outbound['settings'];
  if (settings is! Map<String, Object?>) return null;
  final vnext = _firstOf(settings['vnext']);
  if (vnext == null) return null;
  final users = _firstOf(vnext['users']);
  if (users == null) return null;

  final server = vnext['address']?.toString();
  final port = _toInt(vnext['port']);
  final uuid = users['id']?.toString();
  if (server == null || server.isEmpty || port == null || uuid == null) {
    return null;
  }

  final proxy = <String, Object?>{
    'name': name.isEmpty ? server : name,
    'type': 'vless',
    'server': server,
    'port': port,
    'uuid': uuid,
    'udp': true,
  };
  final flow = users['flow']?.toString() ?? '';
  if (flow.isNotEmpty) proxy['flow'] = flow;

  _applyStreamSettings(proxy, outbound['streamSettings'], fallbackSni: server);
  return proxy;
}

Map<String, Object?>? _convertVmess(Map<String, Object?> outbound, String name) {
  final settings = outbound['settings'];
  if (settings is! Map<String, Object?>) return null;
  final vnext = _firstOf(settings['vnext']);
  if (vnext == null) return null;
  final users = _firstOf(vnext['users']);
  if (users == null) return null;

  final server = vnext['address']?.toString();
  final port = _toInt(vnext['port']);
  final uuid = users['id']?.toString();
  if (server == null || server.isEmpty || port == null || uuid == null) {
    return null;
  }

  final proxy = <String, Object?>{
    'name': name.isEmpty ? server : name,
    'type': 'vmess',
    'server': server,
    'port': port,
    'uuid': uuid,
    'alterId': _toInt(users['alterId']) ?? 0,
    'cipher': users['security']?.toString() ?? 'auto',
    'udp': true,
  };

  _applyStreamSettings(proxy, outbound['streamSettings'], fallbackSni: server);
  return proxy;
}

Map<String, Object?>? _convertTrojan(Map<String, Object?> outbound, String name) {
  final proxy = _fromServersList(outbound, name, 'trojan', credentialKey: 'password');
  if (proxy == null) return proxy;
  _applyStreamSettings(
    proxy,
    outbound['streamSettings'],
    fallbackSni: proxy['server']! as String,
  );
  return proxy;
}

Map<String, Object?>? _convertShadowsocks(
  Map<String, Object?> outbound,
  String name,
) {
  // Two shapes: settings.servers[] or the vnext-less settings.vnext[] form.
  final proxy = _fromServersList(outbound, name, 'ss', credentialKey: 'password',
      extraKey: 'method');
  return proxy;
}

Map<String, Object?>? _convertHttp(Map<String, Object?> outbound, String name) =>
    _fromServersList(outbound, name, 'http', credentialKey: null);

Map<String, Object?>? _convertSocks(Map<String, Object?> outbound, String name) {
  final proxy = _fromServersList(
    outbound,
    name,
    'socks5',
    credentialKey: null,
  );
  return proxy;
}

Map<String, Object?>? _fromServersList(
  Map<String, Object?> outbound,
  String name,
  String type, {
  required String? credentialKey,
  String? extraKey,
}) {
  final settings = outbound['settings'];
  if (settings is! Map<String, Object?>) return null;
  final servers = _firstOf(settings['servers']);
  if (servers == null) return null;

  final server = servers['address']?.toString();
  final port = _toInt(servers['port']);
  if (server == null || server.isEmpty || port == null) return null;

  final proxy = <String, Object?>{
    'name': name.isEmpty ? server : name,
    'type': type,
    'server': server,
    'port': port,
    'udp': true,
  };
  if (credentialKey != null) {
    final credential = servers[credentialKey]?.toString();
    if (credential == null || credential.isEmpty) return null;
    proxy[credentialKey == 'password' ? 'password' : credentialKey] = credential;
  }
  if (extraKey != null) {
    final extra = servers[extraKey]?.toString();
    if (extra != null && extra.isNotEmpty) {
      proxy[extraKey == 'method' ? 'cipher' : extraKey] = extra;
    }
  }
  final users = _firstOf(servers['users']);
  if (users != null) {
    final user = users['user']?.toString();
    final pass = users['pass']?.toString();
    if (user != null && user.isNotEmpty) proxy['username'] = user;
    if (pass != null && pass.isNotEmpty) proxy['password'] = pass;
  }
  return proxy;
}

Map<String, Object?>? _convertWireguardOutbound(
  Map<String, Object?> outbound,
  String name,
) {
  final settings = outbound['settings'];
  if (settings is! Map<String, Object?>) return null;

  // `address` is a list of CIDRs, one per family; mihomo wants the first.
  final addressList = settings['address'];
  final address = addressList is List && addressList.isNotEmpty
      ? addressList.first.toString()
      : addressList?.toString();
  if (secretKeyOf(settings) == null ||
      address == null ||
      address.isEmpty) {
    return null;
  }
  final secretKey = secretKeyOf(settings)!;

  // The peer is settings.peers[0] or flattened into settings, per generator.
  final peers = _firstOf(settings['peers']);
  final publicKey =
      (peers?['publicKey'] ?? settings['publicKey'])?.toString();
  final endpoint =
      (peers?['endpoint'] ?? settings['endpoint'])?.toString() ?? '';
  final presharedKey =
      (peers?['presharedKey'] ?? settings['presharedKey'])?.toString();

  final split = _splitHostPort(endpoint);
  if (split == null) return null;
  final (server, port) = split;

  final peer = <String, Object?>{
    'server': server,
    'port': port,
    if ((publicKey ?? '').isNotEmpty) 'public-key': publicKey,
    if ((presharedKey ?? '').isNotEmpty) 'pre-shared-key': presharedKey,
    'allowed-ips': ['0.0.0.0/0,::/0'],
  };

  return <String, Object?>{
    'name': name.isEmpty ? server : name,
    'type': 'wireguard',
    'server': server,
    'port': port,
    'private-key': secretKey,
    'ip': address,
    'ipv6': '',
    'peers': [peer],
    'udp': true,
  };
}

String? secretKeyOf(Map<String, Object?> settings) =>
    settings['secretKey']?.toString();

void _applyStreamSettings(
  Map<String, Object?> proxy,
  Object? streamSettings, {
  required String fallbackSni,
}) {
  if (streamSettings is! Map<String, Object?>) return;

  final security = streamSettings['security']?.toString() ?? 'none';
  final sni = (streamSettings['servername'] ??
          streamSettings['host'] ??
          fallbackSni)
      .toString();

  if (security == 'reality') {
    final reality = _asMap(streamSettings['realitySettings']);
    final publicKey = reality?['publicKey']?.toString();
    final shortId = reality?['shortId']?.toString();
    proxy['tls'] = true;
    proxy['servername'] = reality?['serverName']?.toString() ?? sni;
    proxy['reality-opts'] = {
      'public-key': publicKey ?? '',
      if ((shortId ?? '').isNotEmpty) 'short-id': shortId,
    };
    // Reality without uTLS is a plain timeout: the server masks as its cover site.
    final fingerprint = reality?['fingerprint']?.toString();
    if (fingerprint != null && fingerprint.isNotEmpty) {
      proxy['client-fingerprint'] = fingerprint;
    }
  } else if (security == 'tls') {
    proxy['tls'] = true;
    if (sni.isNotEmpty) proxy['servername'] = sni;
    final tls = streamSettings['tlsSettings'];
    if (tls is Map<String, Object?>) {
      final alpn = tls['alpn'];
      if (alpn is List && alpn.isNotEmpty) {
        proxy['alpn'] = [for (final entry in alpn) entry.toString()];
      }
      if (tls['allowInsecure'] == true) proxy['skip-cert-verify'] = true;
      final fingerprint = tls['fingerprint']?.toString();
      if (fingerprint != null && fingerprint.isNotEmpty) {
        proxy['client-fingerprint'] = fingerprint;
      }
    }
  }

  final network = streamSettings['network']?.toString() ?? 'tcp';
  if (network != 'tcp') {
    if (!_applyXrayTransport(proxy, network, streamSettings)) {
      // Sentinel key: a null type is not representable here.
      proxy['x-unsupported-transport'] = network;
    }
  }
}

/// Returns false when [network] has no mihomo equivalent.
bool _applyXrayTransport(
  Map<String, Object?> proxy,
  String network,
  Map<String, Object?> streamSettings,
) {
  switch (network) {
    case 'ws':
      final ws = _asMap(streamSettings['wsSettings']);
      final headers = _asMap(ws?['headers']);
      proxy['network'] = 'ws';
      proxy['ws-opts'] = {
        if ((ws?['path'] ?? '').toString().isNotEmpty)
          'path': ws!['path'].toString(),
        if (headers != null && (headers['Host'] ?? '').toString().isNotEmpty)
          'headers': {'Host': headers['Host'].toString()},
      };
      return true;
    case 'grpc':
      final grpc = _asMap(streamSettings['grpcSettings']);
      final serviceName = grpc?['serviceName']?.toString() ?? '';
      proxy['network'] = 'grpc';
      if (serviceName.isNotEmpty) {
        proxy['grpc-opts'] = {'grpc-service-name': serviceName};
      }
      return true;
    case 'h2' || 'http':
      // xray's `http` network (h2 prior to v4-era naming) maps to mihomo h2.
      final h2 = _asMap(streamSettings['httpSettings'] ??
          streamSettings['h2Settings'] ??
          streamSettings['kcpSettings']);
      final host = h2?['host'];
      proxy['network'] = 'h2';
      proxy['h2-opts'] = {
        if ((h2?['path'] ?? '').toString().isNotEmpty)
          'path': h2!['path'].toString(),
        if (host is List && host.isNotEmpty) 'host': [host.first.toString()],
        if (host is String && host.isNotEmpty) 'host': [host],
      };
      return true;
    case 'httpupgrade':
      // mihomo has no httpupgrade network; ws plus the upgrade flag dials it.
      final upgrade = _asMap(streamSettings['httpupgradeSettings']);
      proxy['network'] = 'ws';
      proxy['ws-opts'] = {
        'v2ray-http-upgrade': true,
        if ((upgrade?['path'] ?? '').toString().isNotEmpty)
          'path': upgrade!['path'].toString(),
        if ((upgrade?['host'] ?? '').toString().isNotEmpty)
          'headers': {'Host': upgrade!['host'].toString()},
      };
      return true;
    case 'xhttp' || 'splithttp':
      // mihomo dials xhttp for vless only.
      if (proxy['type'] != 'vless') return false;
      // Tuning knobs live in xhttpSettings.extra, not the top level.
      final xhttp = _asMap(
        streamSettings['xhttpSettings'] ?? streamSettings['splithttpSettings'],
      );
      final extra = _asMap(xhttp?['extra']);
      final mode = (extra?['mode'] ?? xhttp?['mode'])?.toString() ?? '';
      final path = (extra?['path'] ?? xhttp?['path'])?.toString() ?? '';
      final host = (extra?['host'] ?? xhttp?['host'])?.toString() ?? '';
      proxy['network'] = 'xhttp';
      proxy['xhttp-opts'] = {
        if (path.isNotEmpty) 'path': path,
        if (host.isNotEmpty) 'host': host,
        if (mode.isNotEmpty) 'mode': mode,
        ..._xhttpExtraOpts(extra),
      };
      return true;
    default:
      return false;
  }
}

/// xray `xhttpSettings.extra` → mihomo `xhttp-opts` keys; unmatched keys dropped.
const _xhttpExtraKeys = {
  'headers': 'headers',
  'scMaxEachPostBytes': 'sc-max-each-post-bytes',
  'scMinPostsIntervalMs': 'sc-min-posts-interval-ms',
  'xPaddingBytes': 'x-padding-bytes',
  'xPaddingObfsMode': 'x-padding-obfs-mode',
  'xPaddingKey': 'x-padding-key',
  'xPaddingHeader': 'x-padding-header',
  'xPaddingPlacement': 'x-padding-placement',
  'xPaddingMethod': 'x-padding-method',
  'uplinkHTTPMethod': 'uplink-http-method',
  'uplinkDataPlacement': 'uplink-data-placement',
  'uplinkDataKey': 'uplink-data-key',
  'uplinkChunkSize': 'uplink-chunk-size',
  'sessionIDPlacement': 'session-placement',
  'sessionIDKey': 'session-key',
  'sessionIDTable': 'session-table',
  'sessionIDLength': 'session-length',
  'seqPlacement': 'seq-placement',
  'seqKey': 'seq-key',
  'noGRPCHeader': 'no-grpc-header',
};

Map<String, Object?> _xhttpExtraOpts(Map<String, Object?>? extra) {
  if (extra == null) return const {};
  final opts = <String, Object?>{};
  for (final entry in _xhttpExtraKeys.entries) {
    final value = extra[entry.key];
    if (value is bool) {
      opts[entry.value] = value;
    } else if (value is Map<String, Object?>) {
      final strings = <String, Object?>{
        for (final e in value.entries)
          if (e.value is String && (e.value as String).isNotEmpty)
            e.key: e.value,
      };
      if (strings.isNotEmpty) opts[entry.value] = strings;
    } else if (value != null && value.toString().isNotEmpty) {
      opts[entry.value] = value.toString();
    }
  }
  if (!_sessionIdsSafe(extra)) {
    opts.remove('session-table');
    opts.remove('session-length');
  }
  // xmux → reuse-settings; max* knobs are strings, hKeepAlivePeriod an int.
  final xmux = _asMap(extra['xmux']);
  if (xmux != null) {
    final reuse = <String, Object?>{
      if (xmux['maxConcurrency'] != null)
        'max-concurrency': xmux['maxConcurrency'].toString(),
      if (xmux['maxConnections'] != null)
        'max-connections': xmux['maxConnections'].toString(),
      if (xmux['cMaxReuseTimes'] != null)
        'c-max-reuse-times': xmux['cMaxReuseTimes'].toString(),
      if (xmux['hMaxRequestTimes'] != null)
        'h-max-request-times': xmux['hMaxRequestTimes'].toString(),
      if (xmux['hMaxReusableSecs'] != null)
        'h-max-reusable-secs': xmux['hMaxReusableSecs'].toString(),
      if (xmux['hKeepAlivePeriod'] is int)
        'h-keep-alive-period': xmux['hKeepAlivePeriod'],
    };
    if (reuse.isNotEmpty) opts['reuse-settings'] = reuse;
  }
  return opts;
}

/// Cores with the v1.19.28 roomSize bug reject session-table/session-length
/// pairs whose room (sum of tableLen^k over the length range) is below 2^31;
/// the literal, unexpanded table value is measured, so the guard uses it too.
bool _sessionIdsSafe(Map<String, Object?> extra) {
  final table = extra['sessionIDTable']?.toString();
  if (table == null || table.isEmpty || table == 'uuid') return true;
  if (!table.codeUnits.every((unit) => unit < 0x80)) return false;
  final range = _parseSessionRange(extra['sessionIDLength']?.toString());
  if (range == null) return false;
  final (min, max) = range;
  final base = table.length;
  if (base >= 2 && max >= 31) return true;
  if (base <= 1) return max - min + 1 >= 2147483648;
  final bigBase = BigInt.from(base);
  var room = BigInt.zero;
  for (var k = min; k <= max; k++) {
    room += bigBase.pow(k);
  }
  return room.compareTo(BigInt.from(2) << 30) >= 0;
}

(int, int)? _parseSessionRange(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return (16, 32);
  final parts = text.split('-');
  if (parts.length == 1) {
    final v = int.tryParse(parts[0]);
    if (v == null || v < 0) return null;
    return (v, v);
  }
  if (parts.length != 2) return null;
  final min = int.tryParse(parts[0].trim());
  final max = int.tryParse(parts[1].trim());
  if (min == null || max == null || min < 0 || max < min) return null;
  return (min, max);
}

// Small helpers (tolerant of generator quirks).

Map<String, Object?>? _asMap(Object? value) =>
    value is Map<String, Object?> ? value : null;

Map<String, Object?>? _firstOf(Object? value) {
  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is Map<String, Object?>) return first;
  }
  return null;
}

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

(String, int)? _splitHostPort(String hostPort) {
  if (hostPort.isEmpty) return null;
  final colonIdx = hostPort.lastIndexOf(':');
  if (colonIdx <= 0) return null;
  final server = hostPort.substring(0, colonIdx);
  final port = int.tryParse(hostPort.substring(colonIdx + 1));
  if (server.isEmpty || port == null) return null;
  return (server, port);
}
