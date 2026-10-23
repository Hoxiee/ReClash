library;

import 'dart:convert';

import '../routing/skipped_node.dart';
import '../subscription/subscription_links.dart';

const _serviceTypes = {'selector', 'urltest', 'direct', 'block', 'dns'};
const _groupTypes = {'selector', 'urltest'};
const _defaultUrlTestUrl = 'https://www.gstatic.com/generate_204';

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
  final targets = <String, String>{};
  final groupDefs = <String, Map<String, Object?>>{};
  for (final outbound in outbounds) {
    if (outbound is! Map<String, Object?>) continue;
    final type = outbound['type'];
    final tag = outbound['tag']?.toString() ?? '';
    if (tag.isNotEmpty) {
      if (_groupTypes.contains(type)) groupDefs[tag] = outbound;
      if (type == 'direct') targets[tag] = 'DIRECT';
      if (type == 'block') targets[tag] = 'REJECT';
    }
    if (_serviceTypes.contains(type)) continue;
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
    if (tag.isNotEmpty) targets[tag] = name;
  }

  if (proxies.isEmpty && skipped.isEmpty) return null;
  seen.add('PROXY');
  final route = _asMap(decoded['route']);
  final plan = _planGroups(
    groupDefs,
    targets,
    proxies,
    seen,
    route?['final']?.toString() ?? '',
  );
  return _SingboxConfigResult(
    config: emitProxiesConfig(
      proxies,
      groups: plan?.groups ?? const [],
      rules: _convertRules(route, plan, targets),
      entries: plan?.entries,
    ),
    skipped: skipped,
  );
}

class _GroupPlan {
  const _GroupPlan({
    required this.groups,
    required this.entries,
    required this.mainTag,
    required this.groupNames,
  });

  final List<Map<String, Object?>> groups;
  final List<String> entries;
  final String mainTag;
  final Map<String, String> groupNames;
}

_GroupPlan? _planGroups(
  Map<String, Map<String, Object?>> groupDefs,
  Map<String, String> targets,
  List<Map<String, Object?>> proxies,
  Set<String> seen,
  String finalTag,
) {
  final members = {
    for (final entry in groupDefs.entries)
      entry.key: [
        for (final member in _listOf(entry.value['outbounds']))
          if (member.toString() != entry.key) member.toString(),
      ],
  };
  final alive = {...groupDefs.keys};
  var changed = true;
  while (changed) {
    changed = false;
    for (final tag in alive.toList()) {
      final reachable = members[tag]!.any(
        (member) => targets.containsKey(member) || alive.contains(member),
      );
      if (!reachable) {
        alive.remove(tag);
        changed = true;
      }
    }
  }

  String? firstAlive(String type) {
    for (final tag in alive) {
      if (groupDefs[tag]!['type'] == type) return tag;
    }
    return null;
  }

  final mainTag = alive.contains(finalTag)
      ? finalTag
      : firstAlive('selector') ?? firstAlive('urltest');
  if (mainTag == null) return null;
  final mainIsSelector = groupDefs[mainTag]!['type'] == 'selector';

  final groupNames = <String, String>{};
  for (final tag in alive) {
    if (tag == mainTag && mainIsSelector) {
      groupNames[tag] = 'PROXY';
      continue;
    }
    var name = tag;
    var suffix = 2;
    while (!seen.add(name)) {
      name = '$tag $suffix';
      suffix++;
    }
    groupNames[tag] = name;
  }

  List<String> memberNames(String tag) {
    final names = <String>{
      for (final member in members[tag]!)
        if (alive.contains(member)) groupNames[member]! else ?targets[member],
    };
    final defaultTag = groupDefs[tag]!['default']?.toString() ?? '';
    final defaultName = alive.contains(defaultTag)
        ? groupNames[defaultTag]
        : targets[defaultTag];
    if (groupDefs[tag]!['type'] == 'selector' && names.contains(defaultName)) {
      return [defaultName!, ...names.where((name) => name != defaultName)];
    }
    return names.toList();
  }

  final resolved = {for (final tag in alive) tag: memberNames(tag)};
  final List<String> entries;
  if (mainIsSelector) {
    entries = [
      for (final name in resolved[mainTag]!)
        if (name != 'DIRECT') name,
    ];
  } else {
    final grouped = {for (final names in resolved.values) ...names};
    entries = [
      groupNames[mainTag]!,
      for (final proxy in proxies)
        if (!grouped.contains(proxy['name'])) proxy['name']! as String,
    ];
  }

  final hidden = entries.toSet();
  final groups = <Map<String, Object?>>[];
  for (final tag in alive) {
    if (tag == mainTag && mainIsSelector) continue;
    final def = groupDefs[tag]!;
    final name = groupNames[tag]!;
    final isUrlTest = def['type'] == 'urltest';
    groups.add(<String, Object?>{
      'name': name,
      'type': isUrlTest ? 'url-test' : 'select',
      'proxies': resolved[tag],
      if (isUrlTest) ...{
        'url': _nonEmpty(def['url']) ?? _defaultUrlTestUrl,
        'interval': _urlTestInterval(def['interval']),
        'tolerance': _toInt(def['tolerance']) ?? 50,
      },
      if (hidden.contains(name)) 'hidden': true,
    });
  }
  return _GroupPlan(
    groups: groups,
    entries: entries,
    mainTag: mainTag,
    groupNames: groupNames,
  );
}

String? _nonEmpty(Object? value) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? null : text;
}

int _urlTestInterval(Object? value) {
  final milliseconds = goDurationMilliseconds(value);
  return milliseconds == null || milliseconds <= 0
      ? 180
      : (milliseconds / 1000).round().clamp(30, 1 << 30);
}

typedef _Predicate = ({String text, bool ip});

List<String> _convertRules(
  Map<String, Object?>? route,
  _GroupPlan? plan,
  Map<String, String> targets,
) {
  if (route == null) return const [];
  String? target(String tag) {
    if (tag == plan?.mainTag) return 'PROXY';
    return plan?.groupNames[tag] ?? targets[tag];
  }

  final rules = <String>{};
  for (final rule in _listOf(route['rules'])) {
    if (rule is! Map<String, Object?>) continue;
    final action = rule['action']?.toString() ?? 'route';
    final String? ruleTarget;
    if (action == 'reject') {
      ruleTarget = 'REJECT';
    } else if (action == 'route') {
      ruleTarget = target(rule['outbound']?.toString() ?? '');
    } else {
      ruleTarget = null;
    }
    if (ruleTarget == null) continue;
    final predicates = _rulePredicates(rule);
    if (predicates == null || predicates.isEmpty) continue;
    rules.addAll(_combineRulePredicates(predicates, ruleTarget));
  }

  final finalTag = route['final']?.toString() ?? '';
  if (finalTag.isNotEmpty && finalTag != plan?.mainTag) {
    final finalTarget = plan?.groupNames[finalTag] ?? targets[finalTag];
    if (finalTarget != null) rules.add('MATCH,$finalTarget');
  }
  return rules.toList();
}

const _ruleMetadataKeys = {'type', 'outbound', 'action', 'method', 'no_drop'};

List<List<_Predicate>>? _rulePredicates(Map<String, Object?> rule) {
  if (rule['type'] != null && rule['type'] != 'default') return null;
  final predicates = <List<_Predicate>>[];
  for (final entry in rule.entries) {
    final key = entry.key;
    if (_ruleMetadataKeys.contains(key) || entry.value == null) continue;
    final values = entry.value is List ? entry.value as List : [entry.value];
    if (values.isEmpty) continue;
    final List<_Predicate>? field;
    if (key == 'ip_is_private') {
      if (entry.value != true) return null;
      field = [(text: 'GEOIP,lan', ip: true)];
    } else {
      field = _fieldPredicates(key, [for (final v in values) v.toString()]);
    }
    if (field == null) return null;
    predicates.add(field);
  }
  return predicates;
}

List<_Predicate>? _fieldPredicates(String key, List<String> values) {
  final predicates = <_Predicate>[];
  for (final value in values) {
    final predicate = switch (key) {
      'domain' => (text: 'DOMAIN,$value', ip: false),
      'domain_suffix' => (
        text:
            'DOMAIN-SUFFIX,${value.startsWith('.') ? value.substring(1) : value}',
        ip: false,
      ),
      'domain_keyword' => (text: 'DOMAIN-KEYWORD,$value', ip: false),
      'domain_regex' => (text: 'DOMAIN-REGEX,$value', ip: false),
      'ip_cidr' => (
        text:
            '${value.contains(':') ? 'IP-CIDR6' : 'IP-CIDR'},${_withPrefix(value)}',
        ip: true,
      ),
      'geosite' => (text: 'GEOSITE,$value', ip: false),
      'geoip' => (
        text: 'GEOIP,${value == 'private' ? 'lan' : value}',
        ip: true,
      ),
      'port' when int.tryParse(value) != null => (
        text: 'DST-PORT,$value',
        ip: false,
      ),
      'port_range' => _portRange(value),
      'network' when value == 'tcp' || value == 'udp' => (
        text: 'NETWORK,$value',
        ip: false,
      ),
      _ => null,
    };
    if (predicate == null) return null;
    predicates.add(predicate);
  }
  return predicates;
}

String _withPrefix(String cidr) =>
    cidr.contains('/') ? cidr : '$cidr/${cidr.contains(':') ? 128 : 32}';

_Predicate? _portRange(String value) {
  final bounds = value.split(':');
  if (bounds.length != 2) return null;
  final low = bounds[0].isEmpty ? 0 : int.tryParse(bounds[0]);
  final high = bounds[1].isEmpty ? 65535 : int.tryParse(bounds[1]);
  if (low == null || high == null) return null;
  return (text: 'DST-PORT,$low-$high', ip: false);
}

List<String> _combineRulePredicates(
  List<List<_Predicate>> fields,
  String target,
) {
  String bare(_Predicate p) => p.ip ? '${p.text},no-resolve' : p.text;
  if (fields.length == 1) {
    return [
      for (final p in fields.single)
        p.ip ? '${p.text},$target,no-resolve' : '${p.text},$target',
    ];
  }
  final parts = [
    for (final alternatives in fields)
      alternatives.length == 1
          ? bare(alternatives.single)
          : 'OR,(${alternatives.map((p) => '(${bare(p)})').join(',')})',
  ];
  return ['AND,(${parts.map((part) => '($part)').join(',')}),$target'];
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
