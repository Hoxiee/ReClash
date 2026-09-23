/// Xray-JSON subscription import (Happ/INCY panels): xray outbounds in, a
/// Clash config out; undialable ones are skipped, not silently degraded.
library;

import 'dart:convert';

import 'amnezia_config.dart';
import '../routing/skipped_node.dart';
import '../subscription/subscription_links.dart';

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

String _scopedTag(int index, Object? tag) => '$index:${tag ?? ''}';

XrayConfigResult? tryConvertXrayConfig(String body) {
  final decoded = _tryJson(body);
  if (decoded == null) return null;
  final configs = _configsOf(decoded);
  if (configs.isEmpty) return null;

  // One server can appear under several routing tags across mode-configs.
  final groups =
      <String, (Map<String, Object?>, List<({String name, bool generic})>)>{};
  final skipped = <String, SkippedNode>{};

  void recordSkipped(SkippedNode node, {String? handle}) {
    skipped.putIfAbsent('${node.kind}|${handle ?? node.name}', () => node);
  }

  String record(
    Map<String, Object?> proxy,
    String name, {
    bool generic = false,
  }) {
    final key = _fingerprint(proxy);
    final entry = groups[key];
    if (entry == null) {
      groups[key] = (proxy, [(name: name, generic: generic)]);
    } else {
      entry.$2.add((name: name, generic: generic));
    }
    return key;
  }

  // Balancer selectors address outbounds by tag, which dedup does not preserve.
  final tagKeys = <String, String>{};

  for (var index = 0; index < configs.length; index++) {
    final config = configs[index];
    if (config['type'] == 'amneziawg') {
      final servers = config['servers'];
      if (servers is List) {
        for (final server in servers) {
          if (server is! Map<String, Object?>) continue;
          final name = (server['name'] ?? server['remark'])?.toString();
          final conf = tryBase64Decode(server['config']?.toString() ?? '');
          final proxy = conf == null
              ? null
              : parseAwgConf(
                  conf,
                  name: name == null || name.isEmpty ? null : name,
                );
          if (proxy == null) {
            // One bad location must not take the rest of the subscription down.
            recordSkipped(
              SkippedNode(
                name: name == null || name.isEmpty ? 'amneziawg' : name,
                kind: 'amneziawg',
                reason: SkippedNodeReason.protocol,
              ),
            );
            continue;
          }
          record(proxy, proxy['name']! as String);
        }
      }
      continue;
    }
    final remarks = config['remarks']?.toString();
    final outbounds = config['outbounds'];
    if (outbounds is! List) continue;
    final roles = _roleTags(config);
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
            name: _isGenericTag(tag, roles)
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
      final key = record(
        proxy,
        proxy['name']! as String,
        generic: _isGenericTag(tag, roles),
      );
      if (tag.isNotEmpty) tagKeys[_scopedTag(index, tag)] = key;
    }
  }

  final proxies = <Map<String, Object?>>[];
  final seen = <String>{'PROXY', 'DIRECT'};
  final tagNames = <String, String>{};
  for (final entry in groups.entries) {
    final (proxy, candidates) = entry.value;
    var name = candidates
        .firstWhere((c) => !c.generic, orElse: () => candidates.first)
        .name;
    if (candidates.every((c) => c.generic)) {
      name = proxy['server']! as String;
    }
    name = _uniqueName(name, seen);
    proxy['name'] = name;
    proxies.add(proxy);
    for (final tag in tagKeys.entries) {
      if (tag.value == entry.key) tagNames[tag.key] = name;
    }
  }

  if (proxies.isEmpty) return null;
  final balancerGroups = _balancerGroups(configs, tagNames, seen);
  return XrayConfigResult(
    config: emitProxiesConfig(
      proxies,
      groups: balancerGroups.groups,
      rules: _routingRules(configs, tagNames, balancerGroups.names),
    ),
    skipped: skipped.values.toList(growable: false),
  );
}

/// A balancer is the panel's real topology: tag prefixes plus a strategy. Each
/// becomes one group; per config they nest under a select named by `remarks` —
/// the single entry Happ would have shown for that mode.
({List<Map<String, Object?>> groups, Map<String, String> names})
_balancerGroups(
  List<Map<String, Object?>> configs,
  Map<String, String> tagNames,
  Set<String> taken,
) {
  final result = <Map<String, Object?>>[];
  final names = <String, String>{};
  for (var index = 0; index < configs.length; index++) {
    final config = configs[index];
    final balancers = _asMap(config['routing'])?['balancers'];
    if (balancers is! List) continue;
    final outbounds = config['outbounds'];
    final tags = <String>[
      if (outbounds is List)
        for (final outbound in outbounds)
          if (outbound is Map<String, Object?>)
            outbound['tag']?.toString() ?? '',
    ];
    final configGroups = <Map<String, Object?>>[];
    for (final balancer in balancers) {
      if (balancer is! Map<String, Object?>) continue;
      final sourceTag = balancer['tag']?.toString() ?? '';
      final group = _balancerGroup(balancer, index, tags, tagNames);
      if (group == null) continue;
      group['name'] = _uniqueName(group['name']! as String, taken);
      if (sourceTag.isNotEmpty) {
        names[_scopedTag(index, sourceTag)] = group['name']! as String;
      }
      configGroups.add(group);
    }
    final remarks = config['remarks']?.toString() ?? '';
    if (remarks.isEmpty) {
      result.addAll(configGroups);
    } else if (configGroups.length == 1) {
      final group = configGroups.single;
      final oldName = group['name']! as String;
      group['name'] = _uniqueName(remarks, taken);
      names.updateAll(
        (key, value) =>
            key.startsWith(_scopedTag(index, null)) && value == oldName
            ? group['name']! as String
            : value,
      );
      result.add(group);
    } else if (configGroups.isNotEmpty) {
      result.add({
        'name': _uniqueName(remarks, taken),
        'type': 'select',
        'proxies': [for (final group in configGroups) group['name']],
      });
      // Reachable through the wrapper; listing each one at the top level is
      // the heap the wrapper exists to replace.
      for (final group in configGroups) {
        group['hidden'] = true;
      }
      result.addAll(configGroups);
    }
  }
  return (groups: result, names: names);
}

List<String> _routingRules(
  List<Map<String, Object?>> configs,
  Map<String, String> tagNames,
  Map<String, String> balancerNames,
) {
  final result = <String>[];
  for (var index = 0; index < configs.length; index++) {
    final rules = _asMap(configs[index]['routing'])?['rules'];
    if (rules is! List) continue;
    for (var ruleIndex = 0; ruleIndex < rules.length; ruleIndex++) {
      final value = rules[ruleIndex];
      if (value is! Map<String, Object?> || value['type'] != 'field') continue;
      if (!_supportedRoutingRule(value)) continue;
      final target = _routingTarget(
        value,
        configs[index],
        index,
        tagNames,
        balancerNames,
      );
      if (target == null &&
          ruleIndex == rules.length - 1 &&
          _isNetworkCatchAll(value)) {
        result.add('MATCH,PROXY');
        continue;
      }
      if (target == null) continue;
      final predicates = <List<String>>[
        _domainPredicates(value['domain']),
        _cidrPredicates(value['ip']),
        _portPredicates(value['port']),
        _networkPredicates(value['network']),
      ].where((items) => items.isNotEmpty).toList();
      result.addAll(_combineRoutingPredicates(predicates, target));
    }
  }
  return result;
}

String? _routingTarget(
  Map<String, Object?> rule,
  Map<String, Object?> config,
  int index,
  Map<String, String> tagNames,
  Map<String, String> balancerNames,
) {
  final balancerTag = rule['balancerTag']?.toString() ?? '';
  if (balancerTag.isNotEmpty) {
    return balancerNames[_scopedTag(index, balancerTag)];
  }
  final outboundTag = rule['outboundTag']?.toString() ?? '';
  if (outboundTag.isEmpty) return null;
  final service = _serviceTarget(outboundTag, config);
  if (service != null) return service;
  return tagNames[_scopedTag(index, outboundTag)];
}

String? _serviceTarget(String tag, Map<String, Object?> config) {
  final outbounds = config['outbounds'];
  if (outbounds is! List) return null;
  for (final outbound in outbounds) {
    if (outbound is! Map<String, Object?> || outbound['tag'] != tag) continue;
    return switch (outbound['protocol']?.toString()) {
      'freedom' => 'DIRECT',
      'blackhole' => 'REJECT',
      _ => null,
    };
  }
  return switch (tag.toLowerCase()) {
    'direct' => 'DIRECT',
    'block' || 'blocked' || 'blackhole' => 'REJECT',
    _ => null,
  };
}

bool _supportedRoutingRule(Map<String, Object?> rule) {
  const conditions = {'domain', 'ip', 'port', 'network'};
  const metadata = {'type', 'outboundTag', 'balancerTag', 'ruleTag'};
  return rule.keys.every(
    (key) => conditions.contains(key) || metadata.contains(key),
  );
}

List<String> _domainPredicates(Object? value) {
  if (value is! List) return const [];
  return [for (final entry in value) ?_domainPredicate(entry.toString())];
}

String? _domainPredicate(String value) {
  if (value.startsWith('full:')) return 'DOMAIN,${value.substring(5)}';
  if (value.startsWith('domain:')) {
    return 'DOMAIN-SUFFIX,${value.substring(7)}';
  }
  if (value.startsWith('keyword:')) {
    return 'DOMAIN-KEYWORD,${value.substring(8)}';
  }
  if (value.startsWith('regexp:')) {
    return 'DOMAIN-REGEX,${value.substring(7)}';
  }
  return value.contains(':') ? null : 'DOMAIN-SUFFIX,$value';
}

List<String> _cidrPredicates(Object? value) {
  if (value is! List) return const [];
  return [
    for (final entry in value)
      if (entry.toString().contains('/'))
        '${entry.toString().contains(':') ? 'IP-CIDR6' : 'IP-CIDR'},${entry.toString()}',
  ];
}

List<String> _portPredicates(Object? value) {
  final ports = switch (value) {
    String() => value.split(','),
    List() => value.map((entry) => entry.toString()),
    _ => const Iterable<String>.empty(),
  };
  return [
    for (final port in ports)
      if (port.trim().isNotEmpty) 'DST-PORT,${port.trim()}',
  ];
}

List<String> _networkPredicates(Object? value) {
  final networks = switch (value) {
    String() => value.split(','),
    List() => value.map((entry) => entry.toString()),
    _ => const Iterable<String>.empty(),
  };
  return [
    for (final network in networks)
      if (network.trim() == 'tcp' || network.trim() == 'udp')
        'NETWORK,${network.trim()}',
  ];
}

List<String> _combineRoutingPredicates(
  List<List<String>> predicates,
  String target,
) {
  if (predicates.isEmpty) return const [];
  if (predicates.length == 1) {
    return [for (final predicate in predicates.single) '$predicate,$target'];
  }
  final fields = [
    for (final alternatives in predicates)
      alternatives.length == 1
          ? alternatives.single
          : 'OR,(${alternatives.map((item) => '($item)').join(',')})',
  ];
  if (fields.length == 1) return ['${fields.single},$target'];
  return ['AND,(${fields.map((item) => '($item)').join(',')}),$target'];
}

bool _isNetworkCatchAll(Map<String, Object?> rule) {
  if (rule['outboundTag'] != null || rule['balancerTag'] != null) return false;
  if (rule.keys.any(
    (key) => !const {'type', 'network', 'ruleTag'}.contains(key),
  )) {
    return false;
  }
  final networks = _networkPredicates(rule['network']).toSet();
  return networks.containsAll({'NETWORK,tcp', 'NETWORK,udp'});
}

Map<String, Object?>? _balancerGroup(
  Map<String, Object?> balancer,
  int index,
  List<String> tags,
  Map<String, String> tagNames,
) {
  final tag = balancer['tag']?.toString() ?? '';
  if (tag.isEmpty) return null;
  final selector = balancer['selector'];
  final prefixes = <String>[
    if (selector is List)
      for (final entry in selector)
        if (entry.toString().isNotEmpty) entry.toString(),
  ];
  if (prefixes.isEmpty) return null;

  final strategy = _asMap(balancer['strategy']);
  final ranked = _rankPrefixes(
    prefixes,
    _asMap(strategy?['settings'])?['costs'],
  );

  final members = <String>[];
  for (final prefix in ranked.prefixes) {
    for (final candidate in tags) {
      if (!candidate.startsWith(prefix)) continue;
      final name = tagNames[_scopedTag(index, candidate)];
      if (name == null || members.contains(name)) continue;
      members.add(name);
    }
  }
  // The xray fallback is a last resort, and `block` resolves to no node at all.
  final fallback = tagNames[_scopedTag(index, balancer['fallbackTag'])];
  if (fallback != null && !members.contains(fallback)) members.add(fallback);
  if (members.isEmpty) return null;

  if (ranked.tiered) {
    return {'name': tag, 'type': 'fallback', 'proxies': members};
  }
  if (strategy?['type']?.toString() == 'random') {
    return {
      'name': tag,
      'type': 'load-balance',
      'strategy': 'round-robin',
      'proxies': members,
    };
  }
  return {'name': tag, 'type': 'url-test', 'proxies': members};
}

/// `costs` tier a balancer: 1e-06 preferred, 1e9 last resort. Distinct costs ask
/// for an order, which is `fallback`, not a latency race between tiers.
({List<String> prefixes, bool tiered}) _rankPrefixes(
  List<String> prefixes,
  Object? costs,
) {
  if (costs is! List || costs.isEmpty) {
    return (prefixes: prefixes, tiered: false);
  }
  final weights = <String, double>{
    for (final prefix in prefixes) prefix: _costOf(prefix, costs),
  };
  if (weights.values.toSet().length < 2) {
    return (prefixes: prefixes, tiered: false);
  }
  final ordered = [...prefixes]
    ..sort((a, b) {
      final byCost = weights[a]!.compareTo(weights[b]!);
      return byCost != 0 ? byCost : prefixes.indexOf(a) - prefixes.indexOf(b);
    });
  return (prefixes: ordered, tiered: true);
}

double _costOf(String prefix, List<Object?> costs) {
  for (final cost in costs) {
    if (cost is! Map<String, Object?>) continue;
    final match = cost['match']?.toString() ?? '';
    if (match.isEmpty) continue;
    final hit = cost['regexp'] == true
        ? (_tryRegExp(match)?.hasMatch(prefix) ?? false)
        : prefix.contains(match);
    if (hit) return _toDouble(cost['value']) ?? 1;
  }
  return 1;
}

RegExp? _tryRegExp(String pattern) {
  try {
    return RegExp(pattern);
  } on FormatException {
    return null;
  }
}

String _uniqueName(String base, Set<String> taken) {
  var name = base;
  var suffix = 2;
  while (taken.contains(name)) {
    name = '$base $suffix';
    suffix++;
  }
  taken.add(name);
  return name;
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

bool _isGenericTag(String tag, [Set<String> roles = const {}]) {
  final trimmed = tag.trim();
  if (_genericTagPattern.hasMatch(trimmed)) return true;
  return roles.any(trimmed.startsWith);
}

/// A selected or fallback tag is a routing role, whatever it is called.
Set<String> _roleTags(Map<String, Object?> config) {
  final balancers = _asMap(config['routing'])?['balancers'];
  if (balancers is! List) return const {};
  return <String>{
    for (final balancer in balancers)
      if (balancer is Map<String, Object?>) ...[
        ...?(balancer['selector'] as List?)?.map((e) => e.toString()),
        ?balancer['fallbackTag']?.toString(),
      ],
  }..removeWhere((tag) => tag.isEmpty);
}

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

bool _isXrayConfig(Map<String, Object?> config) {
  if (config['type'] == 'amneziawg') return true;
  final outbounds = config['outbounds'];
  return outbounds is List &&
      outbounds.any(
        (outbound) => outbound is Map && outbound['protocol'] is String,
      ) &&
      !outbounds.any(
        (outbound) => outbound is Map && outbound['type'] is String,
      );
}

List<Map<String, Object?>> _configsOf(Object? decoded) {
  if (decoded is Map<String, Object?> && _isXrayConfig(decoded)) {
    return [decoded];
  }
  if (decoded is List) {
    if (decoded.any(
      (entry) =>
          entry is Map<String, Object?> &&
          entry.containsKey('outbounds') &&
          !_isXrayConfig(entry),
    )) {
      return const [];
    }
    return [
      for (final entry in decoded)
        if (entry is Map<String, Object?> && _isXrayConfig(entry)) entry,
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
    _ => throw _UnsupportedOutbound(
      SkippedNode(
        name: name.isEmpty ? protocol : name,
        kind: protocol,
        reason: SkippedNodeReason.protocol,
      ),
    ),
  };
}

Map<String, Object?>? _convertVless(
  Map<String, Object?> outbound,
  String name,
) {
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

Map<String, Object?>? _convertVmess(
  Map<String, Object?> outbound,
  String name,
) {
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

Map<String, Object?>? _convertTrojan(
  Map<String, Object?> outbound,
  String name,
) {
  final proxy = _fromServersList(
    outbound,
    name,
    'trojan',
    credentialKey: 'password',
  );
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
  final proxy = _fromServersList(
    outbound,
    name,
    'ss',
    credentialKey: 'password',
    extraKey: 'method',
  );
  return proxy;
}

Map<String, Object?>? _convertHttp(
  Map<String, Object?> outbound,
  String name,
) => _fromServersList(outbound, name, 'http', credentialKey: null);

Map<String, Object?>? _convertSocks(
  Map<String, Object?> outbound,
  String name,
) {
  final proxy = _fromServersList(outbound, name, 'socks5', credentialKey: null);
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
    proxy[credentialKey == 'password' ? 'password' : credentialKey] =
        credential;
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
  if (secretKeyOf(settings) == null || address == null || address.isEmpty) {
    return null;
  }
  final secretKey = secretKeyOf(settings)!;

  // The peer is settings.peers[0] or flattened into settings, per generator.
  final peers = _firstOf(settings['peers']);
  final publicKey = (peers?['publicKey'] ?? settings['publicKey'])?.toString();
  final endpoint =
      (peers?['endpoint'] ?? settings['endpoint'])?.toString() ?? '';
  final presharedKey = (peers?['presharedKey'] ?? settings['presharedKey'])
      ?.toString();

  final split = _splitHostPort(endpoint);
  if (split == null) return null;
  final (server, port) = split;

  final peer = <String, Object?>{
    'server': server,
    'port': port,
    if ((publicKey ?? '').isNotEmpty) 'public-key': publicKey,
    if ((presharedKey ?? '').isNotEmpty) 'pre-shared-key': presharedKey,
    'allowed-ips': ['0.0.0.0/0', '::/0'],
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
  final tlsSettings = _asMap(streamSettings['tlsSettings']);
  final sni =
      (tlsSettings?['serverName'] ??
              streamSettings['servername'] ??
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
      final h2 = _asMap(
        streamSettings['httpSettings'] ??
            streamSettings['h2Settings'] ??
            streamSettings['kcpSettings'],
      );
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

double? _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
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
