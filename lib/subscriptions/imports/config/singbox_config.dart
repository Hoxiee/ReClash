library;

import 'dart:convert';

import '../routing/skipped_node.dart';
import '../subscription/subscription_links.dart';

const _serviceTypes = {'selector', 'urltest', 'direct', 'block', 'dns'};

bool isSingboxConfigInput(String body) {
  final trimmed = body.trimLeft();
  if (!trimmed.startsWith('{')) return false;
  final decoded = _tryJson(trimmed);
  return decoded is Map<String, Object?> && _hasSingboxOutbounds(decoded);
}

bool _hasSingboxOutbounds(Map<String, Object?> config) {
  final outbounds = config['outbounds'];
  return outbounds is List &&
      outbounds.any(
        (outbound) => outbound is Map && outbound['type'] is String,
      ) &&
      !outbounds.any(
        (outbound) => outbound is Map && outbound['protocol'] is String,
      );
}

class _SingboxConfigResult implements ConvertedSubscription {
  const _SingboxConfigResult({required this.config, this.skipped = const []});

  @override
  final String config;

  @override
  final List<SkippedNode> skipped;
}

ConvertedSubscription? tryConvertSingboxConfig(String body) =>
    tryConvertSingboxConfigValue(_tryJson(body));

ConvertedSubscription? tryConvertSingboxConfigValue(Object? decoded) {
  if (decoded is! Map<String, Object?> || !_hasSingboxOutbounds(decoded)) {
    return null;
  }
  final outbounds = decoded['outbounds'];
  if (outbounds is! List) return null;

  final proxies = <Map<String, Object?>>[];
  final skipped = <SkippedNode>[];
  final seen = {...reservedProxyNames};
  for (final outbound in outbounds) {
    if (outbound is! Map<String, Object?>) continue;
    if (_serviceTypes.contains(outbound['type'])) continue;
    final Map<String, Object?>? proxy;
    try {
      proxy = _convertOutbound(outbound);
    } on _UnsupportedOutbound catch (error) {
      skipped.add(error.node);
      continue;
    }
    if (proxy == null) continue;
    var name = proxy['name']! as String;
    if (reservedProxyNames.contains(name)) name = '$name node';
    final base = name;
    var suffix = 2;
    while (!seen.add(name)) {
      name = '$base $suffix';
      suffix++;
    }
    proxy['name'] = name;
    proxies.add(proxy);
  }

  if (proxies.isEmpty && skipped.isEmpty) return null;
  return _SingboxConfigResult(
    config: emitProxiesConfig(proxies),
    skipped: skipped,
  );
}

Object? _tryJson(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return null;
  }
}

class _UnsupportedOutbound implements Exception {
  const _UnsupportedOutbound(this.node);

  final SkippedNode node;
}

const _requiredFields = {
  'vless': ['uuid'],
  'vmess': ['uuid'],
  'trojan': ['password'],
  'ss': ['cipher', 'password'],
  'hysteria2': ['password'],
  'hysteria': [],
  'tuic': ['uuid', 'password'],
  'anytls': ['password'],
  'http': [],
  'socks5': [],
  'wireguard': ['private-key', 'public-key'],
};

Map<String, Object?>? _convertOutbound(Map<String, Object?> outbound) {
  final type = outbound['type']?.toString() ?? '';
  final tag = outbound['tag']?.toString() ?? '';
  final server = outbound['server']?.toString() ?? '';
  final port = _toInt(outbound['server_port']);
  if (server.isEmpty || port == null) return null;

  final name = tag.isNotEmpty ? tag : server;
  final proxy = <String, Object?>{'name': name, 'server': server, 'port': port};

  void unsupported(String kind, SkippedNodeReason reason) {
    throw _UnsupportedOutbound(
      SkippedNode(name: name, kind: kind, reason: reason),
    );
  }

  switch (type) {
    case 'vless':
      proxy['type'] = 'vless';
      proxy['udp'] = true;
      _set(proxy, 'uuid', outbound['uuid']);
      final flow = sanitizeVlessFlow(outbound['flow']?.toString() ?? '');
      if (flow != null) proxy['flow'] = flow;
      final packetEncoding = outbound['packet_encoding']?.toString() ?? '';
      if (packetEncoding == 'packetaddr' || packetEncoding == 'packet') {
        proxy['packet-encoding'] = 'packetaddr';
      }
    case 'vmess':
      proxy['type'] = 'vmess';
      proxy['udp'] = true;
      _set(proxy, 'uuid', outbound['uuid']);
      proxy['alterId'] = _toInt(outbound['alter_id']) ?? 0;
      proxy['cipher'] = sanitizeVmessCipher(
        outbound['security']?.toString() ?? 'auto',
      );
      final packetEncoding = outbound['packet_encoding']?.toString() ?? '';
      if (packetEncoding == 'packetaddr' || packetEncoding == 'packet') {
        proxy['packet-encoding'] = 'packetaddr';
      }
    case 'trojan':
      proxy['type'] = 'trojan';
      proxy['udp'] = true;
      _set(proxy, 'password', outbound['password']);
    case 'shadowsocks':
      proxy['type'] = 'ss';
      proxy['udp'] = true;
      _set(proxy, 'cipher', outbound['method']);
      _set(proxy, 'password', outbound['password']);
      final plugin = outbound['plugin']?.toString() ?? '';
      if (plugin.isNotEmpty &&
          plugin != 'obfs-local' &&
          plugin != 'v2ray-plugin') {
        unsupported('plugin $plugin', SkippedNodeReason.transport);
      }
      _set(proxy, 'plugin', plugin == 'obfs-local' ? 'obfs' : plugin);
      final pluginOpts = _pluginOpts(outbound['plugin_opts']);
      if (pluginOpts != null) proxy['plugin-opts'] = pluginOpts;
    case 'hysteria2':
      proxy['type'] = 'hysteria2';
      proxy['udp'] = true;
      _set(proxy, 'password', outbound['password']);
      final obfs = _asMap(outbound['obfs']);
      if (obfs?['type'] == 'salamander' &&
          (obfs?['password'] ?? '').toString().isNotEmpty) {
        proxy['obfs'] = 'salamander';
        proxy['obfs-password'] = obfs!['password'].toString();
      }
      _bandwidth(proxy, outbound);
    case 'hysteria':
      proxy['type'] = 'hysteria';
      proxy['udp'] = true;
      _set(proxy, 'auth', outbound['auth']);
      _set(proxy, 'auth-str', outbound['auth_str']);
      final obfs = outbound['obfs']?.toString() ?? '';
      if (obfs.isNotEmpty) {
        if (obfs != 'xplus') {
          unsupported('obfs $obfs', SkippedNodeReason.transport);
        }
        _set(proxy, 'obfs', outbound['obfs_password']);
      }
      _bandwidth(proxy, outbound);
      if (proxy['up'] == null || proxy['down'] == null) {
        unsupported('bandwidth', SkippedNodeReason.protocol);
      }
    case 'tuic':
      proxy['type'] = 'tuic';
      proxy['udp'] = true;
      _set(proxy, 'uuid', outbound['uuid']);
      _set(proxy, 'password', outbound['password']);
      _set(proxy, 'congestion-controller', outbound['congestion_control']);
      _set(proxy, 'udp-relay-mode', outbound['udp_relay_mode']);
    case 'anytls':
      proxy['type'] = 'anytls';
      _set(proxy, 'password', outbound['password']);
    case 'wireguard':
      return _convertWireguard(outbound, name, server, port);
    case 'http':
      proxy['type'] = 'http';
      _set(proxy, 'username', outbound['username']);
      _set(proxy, 'password', outbound['password']);
    case 'socks':
      proxy['type'] = 'socks5';
      proxy['udp'] = true;
      final version = outbound['version']?.toString() ?? '5';
      if (version == '4' || version == '4a') {
        unsupported('socks4', SkippedNodeReason.protocol);
      }
      _set(proxy, 'username', outbound['username']);
      _set(proxy, 'password', outbound['password']);
    default:
      unsupported(type, SkippedNodeReason.protocol);
  }

  for (final key in _requiredFields[proxy['type']] ?? const <String>[]) {
    final value = proxy[key];
    if (value == null || value.toString().isEmpty) return null;
  }

  _applyTls(proxy, outbound['tls'], fallbackSni: server);
  _applyTransport(proxy, outbound['transport']);
  if (proxy['type'] == 'tuic' && proxy['tls'] != true) {
    proxy['tls'] = true;
    proxy['sni'] = server;
    proxy['alpn'] = ['h3'];
  } else if (proxy['type'] == 'tuic') {
    proxy['alpn'] = proxy['alpn'] ?? ['h3'];
  }
  return proxy;
}

Map<String, Object?>? _convertWireguard(
  Map<String, Object?> outbound,
  String name,
  String server,
  int port,
) {
  final privateKey = outbound['private_key']?.toString() ?? '';
  if (privateKey.isEmpty) return null;

  final peers = _wireguardPeers(outbound);
  if (peers.isEmpty) return null;
  final first = peers.first;

  String? ip;
  String? ipv6;
  for (final address in _listOf(outbound['local_address'])) {
    final value = address.toString();
    if (ip == null && value.contains('.')) ip = value;
    if (ipv6 == null && value.contains(':')) ipv6 = value;
  }

  final mtu = _toInt(outbound['mtu']);
  return <String, Object?>{
    'name': name,
    'type': 'wireguard',
    'server': first['server']?.toString() ?? server,
    'port': first['port'] ?? port,
    'private-key': privateKey,
    'ip': ip ?? '',
    'ipv6': ipv6 ?? '',
    if (peers.length == 1) ...{
      'public-key': first['public-key'],
      'pre-shared-key': first['pre-shared-key'],
      'allowed-ips': first['allowed-ips'],
    },
    if (peers.length > 1) 'peers': peers,
    if (mtu != null && mtu > 0) 'mtu': mtu,
    'udp': true,
  };
}

List<Map<String, Object?>> _wireguardPeers(Map<String, Object?> outbound) {
  final peers = <Map<String, Object?>>[];
  for (final entry in _listOf(outbound['peers'])) {
    if (entry is! Map<String, Object?>) continue;
    final publicKey = entry['public_key']?.toString() ?? '';
    if (publicKey.isEmpty) continue;
    final allowedIps = [
      ..._listOf(entry['allowed_ips']).map((ip) => ip.toString()),
    ];
    final reserved = _peerReserved(entry['reserved']);
    final port = _toInt(entry['server_port']);
    peers.add(<String, Object?>{
      'server': entry['server']?.toString() ?? '',
      'port': ?port,
      'public-key': publicKey,
      if ((entry['pre_shared_key'] ?? '').toString().isNotEmpty)
        'pre-shared-key': entry['pre_shared_key'].toString(),
      'reserved': ?reserved,
      'allowed-ips': allowedIps.isEmpty ? ['0.0.0.0/0', '::/0'] : allowedIps,
    });
  }
  return peers;
}

List<int>? _peerReserved(Object? value) {
  final list = _listOf(value);
  if (list.length != 3) return null;
  final reserved = <int>[];
  for (final item in list) {
    final byte = _toInt(item);
    if (byte == null || byte < 0 || byte > 255) return null;
    reserved.add(byte);
  }
  return reserved;
}

void _applyTls(
  Map<String, Object?> proxy,
  Object? tlsValue, {
  required String fallbackSni,
}) {
  if (tlsValue is! Map<String, Object?>) return;
  if (tlsValue['enabled'] != true) return;

  proxy['tls'] = true;
  final disableSni = tlsValue['disable_sni'] == true;
  final type = proxy['type']?.toString() ?? '';
  if (disableSni && type == 'tuic') proxy['disable-sni'] = true;
  final sni = disableSni
      ? ''
      : tlsValue['server_name']?.toString() ?? fallbackSni;
  if (sni.isNotEmpty && type != 'socks5') {
    final key = type == 'vmess' || type == 'vless' ? 'servername' : 'sni';
    proxy[key] = sni;
  }
  final alpn = _listOf(tlsValue['alpn']);
  if (alpn.isNotEmpty) proxy['alpn'] = alpn;
  if (tlsValue['insecure'] == true) proxy['skip-cert-verify'] = true;

  final utls = _asMap(tlsValue['utls']);
  final fingerprint = utls?['fingerprint']?.toString() ?? '';
  if (utls?['enabled'] == true && fingerprint.isNotEmpty) {
    proxy['client-fingerprint'] = fingerprint;
  }

  final reality = _asMap(tlsValue['reality']);
  final publicKey = reality?['public_key']?.toString() ?? '';
  if (reality?['enabled'] == true && publicKey.isNotEmpty) {
    proxy['reality-opts'] = {
      'public-key': publicKey,
      if ((reality?['short_id'] ?? '').toString().isNotEmpty)
        'short-id': reality?['short_id'].toString(),
    };
  }
}

void _applyTransport(Map<String, Object?> proxy, Object? transportValue) {
  if (transportValue is! Map<String, Object?>) return;
  final type = transportValue['type']?.toString() ?? '';
  final path = transportValue['path']?.toString() ?? '';
  final headers = _asMap(transportValue['headers']);
  final hostValue = transportValue['host'];
  final host =
      (hostValue is List && hostValue.isNotEmpty
          ? hostValue.first.toString()
          : hostValue?.toString()) ??
      headers?['Host']?.toString() ??
      '';
  switch (type) {
    case 'ws':
      proxy['network'] = 'ws';
      final earlyData = _toInt(transportValue['max_early_data']);
      final wsOpts = <String, Object?>{
        if (path.isNotEmpty) 'path': path,
        if (host.isNotEmpty) 'headers': {'Host': host},
        if (earlyData != null && earlyData > 0) 'max-early-data': earlyData,
      };
      proxy['ws-opts'] = wsOpts;
      final earlyHeader =
          transportValue['early_data_header_name']?.toString() ??
          (earlyData != null ? 'Sec-WebSocket-Protocol' : '');
      if (earlyHeader.isNotEmpty) {
        wsOpts['early-data-header-name'] = earlyHeader;
      }
    case 'grpc':
      proxy['network'] = 'grpc';
      final serviceName = transportValue['service_name']?.toString() ?? '';
      if (serviceName.isNotEmpty) {
        proxy['grpc-opts'] = {'grpc-service-name': serviceName};
      }
    case 'http':
      proxy['network'] = 'h2';
      proxy['h2-opts'] = {
        if (path.isNotEmpty) 'path': path,
        if (host.isNotEmpty) 'host': [host],
      };
    case 'httpupgrade':
      proxy['network'] = 'ws';
      proxy['ws-opts'] = {
        'v2ray-http-upgrade': true,
        if (path.isNotEmpty) 'path': path,
        if (host.isNotEmpty) 'headers': {'Host': host},
      };
    default:
      throw _UnsupportedOutbound(
        SkippedNode(
          name: proxy['name']! as String,
          kind: type,
          reason: SkippedNodeReason.transport,
        ),
      );
  }
}

void _set(Map<String, Object?> proxy, String key, Object? value) {
  if (value == null) return;
  final text = value.toString();
  if (text.isEmpty) return;
  proxy[key] = text;
}

void _bandwidth(Map<String, Object?> proxy, Map<String, Object?> outbound) {
  for (final field in ['up', 'down']) {
    final mbps = _toInt(outbound['${field}_mbps']);
    if (mbps != null && mbps > 0) proxy[field] = '$mbps';
  }
}

Map<String, Object?>? _asMap(Object? value) =>
    value is Map<String, Object?> ? value : null;

Map<String, Object?>? _pluginOpts(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is! String || value.isEmpty) return null;
  final opts = <String, Object?>{};
  for (final segment in value.split(';')) {
    final eq = segment.indexOf('=');
    if (eq <= 0) continue;
    opts[segment.substring(0, eq)] = segment.substring(eq + 1);
  }
  return opts.isEmpty ? null : opts;
}

List<Object?> _listOf(Object? value) =>
    value is List ? value : const <Object?>[];

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
