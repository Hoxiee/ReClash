library;

import 'dart:convert';

import '../routing/skipped_node.dart';
import '../subscription/subscription_links.dart';
import 'amnezia_config.dart';

bool isXrayConfigInput(String body) {
  final trimmed = body.trimLeft();
  if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return false;
  try {
    return isXrayConfigValue(jsonDecode(trimmed));
  } catch (_) {
    return false;
  }
}

bool isXrayConfigValue(Object? decoded) => _configsOf(decoded).isNotEmpty;

class _XrayConfigResult implements ConvertedSubscription, LossyConversion {
  const _XrayConfigResult({
    required this.config,
    this.skipped = const [],
    this.hasOtherLosses = false,
  });

  @override
  final String config;

  @override
  final List<SkippedNode> skipped;

  @override
  final bool hasOtherLosses;
}

ConvertedSubscription? tryConvertXrayConfig(String body) =>
    tryConvertXrayConfigValue(_tryJson(body));

ConvertedSubscription? tryConvertXrayConfigValue(Object? decoded) {
  if (decoded == null) return null;
  final configs = _configsOf(decoded);
  if (configs.isEmpty) return null;
  return _XrayConversion(configs).run();
}

typedef _NameCandidate = ({String name, int rank});

const _remarksRank = 2;
const _tagRank = 1;
const _hostRank = 0;

class _Node {
  _Node(this.proxy, this.hopKey);

  final Map<String, Object?> proxy;
  final String? hopKey;
  final candidates = <_NameCandidate>[];
}

class _Draft {
  _Draft(this.tag, this.proxy, this.generic, this.dialerTag);

  final String tag;
  final Map<String, Object?> proxy;
  final bool generic;
  final String dialerTag;
  String? key;
  String? hopKey;
}

class _Balancer {
  _Balancer(this.tag, this.source, this.memberKeys, this.tiered);

  final String tag;
  final Map<String, Object?> source;
  final List<String> memberKeys;
  final bool tiered;
}

class _Plan {
  _Plan(this.index, this.source, this.remarks);

  final int index;
  final Map<String, Object?> source;
  final String remarks;
  final awgKeys = <String>[];
  final drafts = <_Draft>[];
  final draftsByTag = <String, _Draft>{};
  final services = <String, String>{};
  final balancers = <_Balancer>[];
  final rules = <Map<String, Object?>>[];
  _Draft? firstDraft;
  _Draft? mainDraft;
  _Balancer? mainBalancer;

  _Balancer? balancerOf(Object? tag) {
    final text = tag?.toString() ?? '';
    for (final balancer in balancers) {
      if (balancer.tag == text) return balancer;
    }
    return null;
  }
}

class _XrayConversion {
  _XrayConversion(this.configs);

  final List<Map<String, Object?>> configs;
  final _nodes = <String, _Node>{};
  final _skipped = <String, SkippedNode>{};
  final _plans = <_Plan>[];
  final _names = <String, String>{};
  final _groupNames = <_Balancer, String>{};
  var _otherLosses = false;

  ConvertedSubscription? run() {
    for (var index = 0; index < configs.length; index++) {
      _plans.add(_read(index, configs[index]));
    }
    if (_nodes.isEmpty && _skipped.isEmpty) return null;

    final taken = {...reservedProxyNames};
    for (final entry in _nodes.entries) {
      final node = entry.value;
      var best = node.candidates.first;
      for (final candidate in node.candidates) {
        if (candidate.rank > best.rank) best = candidate;
      }
      final name = _uniqueName(best.name, taken);
      node.proxy['name'] = name;
      _names[entry.key] = name;
    }
    for (final node in _nodes.values) {
      final hopKey = node.hopKey;
      if (hopKey != null) node.proxy['dialer-proxy'] = _names[hopKey];
    }

    final groups = <Map<String, Object?>>[];
    for (final plan in _plans) {
      for (final balancer in plan.balancers) {
        final isMain = identical(balancer, plan.mainBalancer);
        final name = _uniqueName(
          isMain && plan.remarks.isNotEmpty ? plan.remarks : balancer.tag,
          taken,
        );
        _groupNames[balancer] = name;
        groups.add(_group(plan, balancer, name));
      }
    }

    final entries = _entries();
    return _XrayConfigResult(
      config: emitProxiesConfig(
        [for (final node in _nodes.values) node.proxy],
        groups: groups,
        rules: _rules(),
        entries: entries.isEmpty ? null : entries,
      ),
      skipped: _skipped.values.toList(growable: false),
      hasOtherLosses: _otherLosses,
    );
  }

  void _skip(SkippedNode node, {String? handle}) {
    _skipped.putIfAbsent('${node.kind}|${handle ?? node.name}', () => node);
  }

  _Plan _read(int index, Map<String, Object?> config) {
    final plan = _Plan(
      index,
      config,
      (config['remarks']?.toString() ?? '').trim(),
    );
    if (config['type'] == 'amneziawg') {
      _readAmnezia(plan);
      return plan;
    }
    final outbounds = config['outbounds'];
    if (outbounds is! List) return plan;
    final roles = _roleTags(config);
    for (var position = 0; position < outbounds.length; position++) {
      final outbound = outbounds[position];
      if (outbound is! Map<String, Object?>) continue;
      final tag = outbound['tag']?.toString() ?? '';
      final service = switch (outbound['protocol']?.toString()) {
        'freedom' => 'DIRECT',
        'blackhole' => 'REJECT',
        'dns' => '',
        _ => null,
      };
      if (service != null) {
        if (tag.isNotEmpty) plan.services[tag] = service;
        continue;
      }
      final Map<String, Object?>? proxy;
      try {
        proxy = _convertOutbound(outbound);
      } on _UnsupportedOutbound catch (error) {
        _skip(error.node);
        continue;
      }
      if (proxy == null) continue;
      final transport = proxy.remove('x-unsupported-transport')?.toString();
      if (transport != null) {
        _skip(
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
      final sockopt = _asMap(_asMap(outbound['streamSettings'])?['sockopt']);
      final draft = _Draft(
        tag,
        proxy,
        _isGenericTag(tag, roles),
        sockopt?['dialerProxy']?.toString() ?? '',
      );
      plan.drafts.add(draft);
      if (tag.isNotEmpty) plan.draftsByTag.putIfAbsent(tag, () => draft);
      if (position == 0) plan.firstDraft = draft;
    }

    for (final draft in plan.drafts) {
      _keyOf(plan, draft, {});
    }
    for (final draft in plan.drafts) {
      final node = _nodes.putIfAbsent(
        draft.key!,
        () => _Node(draft.proxy, draft.hopKey),
      );
      node.candidates.add(
        draft.generic || draft.tag.isEmpty
            ? (name: draft.proxy['server']! as String, rank: _hostRank)
            : (name: draft.tag, rank: _tagRank),
      );
    }
    _readBalancers(plan);
    _readRules(plan);
    _chooseMain(plan);
    final main = plan.mainDraft;
    if (main != null && plan.remarks.isNotEmpty) {
      _nodes[main.key]!.candidates.add((
        name: plan.remarks,
        rank: _remarksRank,
      ));
    }
    return plan;
  }

  void _readAmnezia(_Plan plan) {
    final servers = plan.source['servers'];
    if (servers is! List) return;
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
        _skip(
          SkippedNode(
            name: name == null || name.isEmpty ? 'amneziawg' : name,
            kind: 'amneziawg',
            reason: SkippedNodeReason.protocol,
          ),
        );
        continue;
      }
      final key = _fingerprint(proxy);
      _nodes.putIfAbsent(key, () => _Node(proxy, null)).candidates.add((
        name: proxy['name']! as String,
        rank: _tagRank,
      ));
      plan.awgKeys.add(key);
    }
  }

  String _keyOf(_Plan plan, _Draft draft, Set<_Draft> chain) {
    final cached = draft.key;
    if (cached != null) return cached;
    var key = _fingerprint(draft.proxy);
    final hop = plan.draftsByTag[draft.dialerTag];
    if (hop != null) {
      if (!identical(hop, draft) && chain.add(draft)) {
        draft.hopKey = _keyOf(plan, hop, chain);
        chain.remove(draft);
        key = '$key>${draft.hopKey}';
      }
    } else if (plan.services[draft.dialerTag] == 'DIRECT') {
      _otherLosses = true;
    }
    return draft.key = key;
  }

  void _readBalancers(_Plan plan) {
    final raw = _asMap(plan.source['routing'])?['balancers'];
    if (raw is! List) return;
    for (final balancer in raw) {
      if (balancer is! Map<String, Object?>) continue;
      final tag = balancer['tag']?.toString() ?? '';
      final selector = balancer['selector'];
      final prefixes = <String>[
        if (selector is List)
          for (final entry in selector)
            if (entry.toString().isNotEmpty) entry.toString(),
      ];
      if (tag.isEmpty || prefixes.isEmpty) continue;
      final strategy = _asMap(balancer['strategy']);
      final ranked = _rankPrefixes(
        prefixes,
        _asMap(strategy?['settings'])?['costs'],
      );
      final members = <String>[];
      for (final prefix in ranked.prefixes) {
        for (final draft in plan.drafts) {
          if (draft.tag.isEmpty || !draft.tag.startsWith(prefix)) continue;
          if (!members.contains(draft.key)) members.add(draft.key!);
        }
      }
      final fallbackTag = balancer['fallbackTag']?.toString() ?? '';
      final fallback = const {'direct', 'block'}.contains(fallbackTag)
          ? null
          : plan.draftsByTag[fallbackTag];
      if (fallback != null && !members.contains(fallback.key)) {
        members.add(fallback.key!);
      }
      if (members.isEmpty) continue;
      plan.balancers.add(_Balancer(tag, balancer, members, ranked.tiered));
    }
  }

  void _readRules(_Plan plan) {
    final rules = _asMap(plan.source['routing'])?['rules'];
    if (rules is! List) return;
    for (final rule in rules) {
      if (rule is! Map<String, Object?>) continue;
      final type = rule['type'];
      if (type == null || type == 'field') plan.rules.add(rule);
    }
  }

  void _chooseMain(_Plan plan) {
    for (final rule in plan.rules) {
      if (!_isCatchAll(rule)) continue;
      plan.mainBalancer = plan.balancerOf(rule['balancerTag']);
      if (plan.mainBalancer == null) {
        plan.mainDraft = plan.draftsByTag[rule['outboundTag']?.toString()];
      }
      break;
    }
    if (plan.mainBalancer != null || plan.mainDraft != null) return;
    plan.mainDraft = plan.firstDraft;
    if (plan.mainDraft != null) return;
    plan.mainBalancer = plan.balancers.firstOrNull;
    if (plan.mainBalancer == null) plan.mainDraft = plan.drafts.firstOrNull;
  }

  Map<String, Object?> _group(_Plan plan, _Balancer balancer, String name) {
    final kind = _asMap(
      balancer.source['strategy'],
    )?['type']?.toString().toLowerCase();
    final group = <String, Object?>{
      'name': name,
      'type': 'url-test',
      'proxies': [for (final key in balancer.memberKeys) _names[key]],
      ..._healthCheck(plan.source),
    };
    if (balancer.tiered) {
      group['type'] = 'fallback';
    } else if (kind == 'leastload') {
      group['tolerance'] = 50;
    } else if (kind == null ||
        kind.isEmpty ||
        kind == 'random' ||
        kind == 'roundrobin') {
      group['type'] = 'load-balance';
      group['strategy'] = 'round-robin';
    }
    group['hidden'] = true;
    return group;
  }

  List<String> _entries() {
    final entries = <String>[];
    final listed = <String>{};
    void add(String? name) {
      if (name != null && listed.add(name)) entries.add(name);
    }

    for (final plan in _plans) {
      plan.awgKeys.map((key) => _names[key]).forEach(add);
      final mainBalancer = plan.mainBalancer;
      final mainDraft = plan.mainDraft;
      if (mainBalancer != null) {
        add(_groupNames[mainBalancer]);
      } else if (mainDraft != null) {
        add(_names[mainDraft.key]);
      }
      final claimed = <String>{
        for (final balancer in plan.balancers) ...balancer.memberKeys,
        for (final draft in plan.drafts) ?draft.hopKey,
        ?mainDraft?.key,
      };
      for (final draft in plan.drafts) {
        if (!claimed.contains(draft.key)) add(_names[draft.key]);
      }
    }
    return entries;
  }

  List<String> _rules() {
    final result = <String>[];
    final seen = <String>{};
    for (final plan in _plans) {
      final routing = _asMap(plan.source['routing']);
      final strategy = routing?['domainStrategy']?.toString().toLowerCase();
      final noResolve =
          strategy == null || strategy.isEmpty || strategy == 'asis';
      for (final rule in plan.rules) {
        if (_isCatchAll(rule)) break;
        final target = _ruleTarget(plan, rule);
        final fields = _rulePredicates(rule);
        if (target == null || fields == null) continue;
        for (final line in _ruleLines(fields, target, noResolve)) {
          if (seen.add(line)) result.add(line);
        }
      }
    }
    return result;
  }

  String? _ruleTarget(_Plan plan, Map<String, Object?> rule) {
    final balancerTag = rule['balancerTag']?.toString() ?? '';
    if (balancerTag.isNotEmpty) {
      final balancer = plan.balancerOf(balancerTag);
      if (balancer == null) return null;
      return identical(balancer, plan.mainBalancer)
          ? 'PROXY'
          : _groupNames[balancer];
    }
    final tag = rule['outboundTag']?.toString() ?? '';
    if (tag.isEmpty) return null;
    final draft = plan.draftsByTag[tag];
    if (draft != null) {
      return draft.key == plan.mainDraft?.key ? 'PROXY' : _names[draft.key];
    }
    final service = plan.services[tag];
    if (service != null) return service.isEmpty ? null : service;
    return switch (tag.toLowerCase()) {
      'direct' => 'DIRECT',
      'block' || 'blocked' || 'blackhole' => 'REJECT',
      _ => null,
    };
  }
}

const _ruleConditions = {'domain', 'ip', 'port', 'network'};
const _ruleMetadata = {
  'type',
  'outboundTag',
  'balancerTag',
  'ruleTag',
  'domainMatcher',
};

bool _isCatchAll(Map<String, Object?> rule) {
  if (rule.keys.any(
    (key) => key != 'network' && !_ruleMetadata.contains(key),
  )) {
    return false;
  }
  return !rule.containsKey('network') || _coversBothNetworks(rule['network']);
}

bool _coversBothNetworks(Object? value) {
  final networks = _splitList(value).map((item) => item.trim()).toSet();
  return networks.containsAll({'tcp', 'udp'});
}

class _Predicate {
  const _Predicate(this.text, {this.ip = false});

  final String text;
  final bool ip;
}

List<List<_Predicate>>? _rulePredicates(Map<String, Object?> rule) {
  if (rule.keys.any(
    (key) => !_ruleConditions.contains(key) && !_ruleMetadata.contains(key),
  )) {
    return null;
  }
  final fields = <List<_Predicate>>[];
  for (final entry in <(String, List<_Predicate> Function(Object?))>[
    ('domain', _domainPredicates),
    ('ip', _ipPredicates),
    ('port', _portPredicates),
    ('network', _networkPredicates),
  ]) {
    final value = rule[entry.$1];
    if (value == null) continue;
    if (entry.$1 == 'network' && _coversBothNetworks(value)) continue;
    final predicates = entry.$2(value);
    if (predicates.isEmpty) return null;
    fields.add(predicates);
  }
  return fields.isEmpty ? null : fields;
}

List<String> _ruleLines(
  List<List<_Predicate>> fields,
  String target,
  bool noResolve,
) {
  String suffix(_Predicate predicate) =>
      noResolve && predicate.ip ? ',no-resolve' : '';
  if (fields.length == 1) {
    return [
      for (final predicate in fields.single)
        '${predicate.text},$target${suffix(predicate)}',
    ];
  }
  final terms = [
    for (final alternatives in fields)
      alternatives.length == 1
          ? '${alternatives.single.text}${suffix(alternatives.single)}'
          : 'OR,(${alternatives.map((item) => '(${item.text}${suffix(item)})').join(',')})',
  ];
  return ['AND,(${terms.map((item) => '($item)').join(',')}),$target'];
}

Iterable<String> _splitList(Object? value) => switch (value) {
  String() => value.split(','),
  List() => value.map((entry) => entry.toString()),
  num() => [value.toString()],
  _ => const Iterable<String>.empty(),
};

List<_Predicate> _domainPredicates(Object? value) {
  if (value is! List) return const [];
  return [for (final entry in value) ?_domainPredicate(entry.toString())];
}

_Predicate? _domainPredicate(String value) {
  final text = switch (value) {
    _ when value.startsWith('geosite:') => 'GEOSITE,${value.substring(8)}',
    _ when value.startsWith('full:') => 'DOMAIN,${value.substring(5)}',
    _ when value.startsWith('domain:') => 'DOMAIN-SUFFIX,${value.substring(7)}',
    _ when value.startsWith('keyword:') =>
      'DOMAIN-KEYWORD,${value.substring(8)}',
    _ when value.startsWith('regexp:') => 'DOMAIN-REGEX,${value.substring(7)}',
    _ when value.contains(':') => null,
    _ => 'DOMAIN-KEYWORD,$value',
  };
  return text == null || text.endsWith(',') ? null : _Predicate(text);
}

final _ipv4Pattern = RegExp(r'^\d{1,3}(\.\d{1,3}){3}(/\d{1,2})?$');
final _ipv6Pattern = RegExp(r'^[0-9a-fA-F:.]*:[0-9a-fA-F:.]*(/\d{1,3})?$');

List<_Predicate> _ipPredicates(Object? value) {
  if (value is! List) return const [];
  return [for (final entry in value) ?_ipPredicate(entry.toString())];
}

_Predicate? _ipPredicate(String value) {
  if (value.startsWith('geoip:')) {
    final code = value.substring(6);
    if (code.isEmpty || code.startsWith('!')) return null;
    return _Predicate('GEOIP,${code == 'private' ? 'lan' : code}', ip: true);
  }
  if (_ipv4Pattern.hasMatch(value)) {
    return _Predicate(
      'IP-CIDR,${value.contains('/') ? value : '$value/32'}',
      ip: true,
    );
  }
  if (_ipv6Pattern.hasMatch(value)) {
    return _Predicate(
      'IP-CIDR6,${value.contains('/') ? value : '$value/128'}',
      ip: true,
    );
  }
  return null;
}

List<_Predicate> _portPredicates(Object? value) => [
  for (final port in _splitList(value))
    if (port.trim().isNotEmpty) _Predicate('DST-PORT,${port.trim()}'),
];

List<_Predicate> _networkPredicates(Object? value) => [
  for (final network in _splitList(value))
    if (network.trim() == 'tcp' || network.trim() == 'udp')
      _Predicate('NETWORK,${network.trim()}'),
];

Map<String, Object?> _healthCheck(Map<String, Object?> config) {
  final burst = _asMap(config['burstObservatory']);
  final observatory = _asMap(config['observatory']);
  if (burst == null && observatory == null) return const {};
  final String url;
  final int intervalMs;
  var timeoutMs = 5000;
  if (burst != null) {
    final ping = _asMap(burst['pingConfig']);
    url =
        _nonEmpty(ping?['destination']) ??
        'https://www.gstatic.com/generate_204';
    intervalMs = _positive(goDurationMilliseconds(ping?['interval'])) ?? 60000;
    timeoutMs =
        _positive(goDurationMilliseconds(ping?['timeout'])) ?? timeoutMs;
  } else {
    url =
        _nonEmpty(observatory!['probeUrl']) ??
        'https://www.google.com/generate_204';
    intervalMs =
        _positive(goDurationMilliseconds(observatory['probeInterval'])) ??
        10000;
  }
  final seconds = (intervalMs / 1000).ceil();
  return {
    'url': url,
    'interval': seconds < 30 ? 30 : seconds,
    'timeout': timeoutMs,
  };
}

String? _nonEmpty(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int? _positive(int? value) => value != null && value > 0 ? value : null;

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

class _UnsupportedOutbound implements Exception {
  const _UnsupportedOutbound(this.node);

  final SkippedNode node;
}

final _genericTagPattern = RegExp(
  r'^(proxy|node|server|primary|backup|main|out|outbound|direct|block)'
  r'([-_ ]?\d+)?$',
  caseSensitive: false,
);

bool _isGenericTag(String tag, [Set<String> roles = const {}]) {
  final trimmed = tag.trim();
  if (trimmed.isEmpty) return true;
  if (_genericTagPattern.hasMatch(trimmed)) return true;
  return roles.any(trimmed.startsWith);
}

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

Map<String, Object?>? _convertOutbound(Map<String, Object?> outbound) {
  final protocol = outbound['protocol']?.toString() ?? '';
  final tag = outbound['tag']?.toString() ?? '';
  final name = tag;

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
  final flow = sanitizeVlessFlow(users['flow']?.toString() ?? '');
  if (flow != null) proxy['flow'] = flow;

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
    'cipher': sanitizeVmessCipher(users['security']?.toString() ?? 'auto'),
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

  final addressList = settings['address'];
  final address = addressList is List && addressList.isNotEmpty
      ? addressList.first.toString()
      : addressList?.toString();
  if (secretKeyOf(settings) == null || address == null || address.isEmpty) {
    return null;
  }
  final secretKey = secretKeyOf(settings)!;

  final peers = _firstOf(settings['peers']);
  final publicKey = (peers?['publicKey'] ?? settings['publicKey'])?.toString();
  final endpoint =
      (peers?['endpoint'] ?? settings['endpoint'])?.toString() ?? '';
  final presharedKey = (peers?['presharedKey'] ?? settings['presharedKey'])
      ?.toString();

  final split = splitHostPort(endpoint);
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
    proxy['reality-opts'] = <String, Object?>{
      'public-key': publicKey ?? '',
      if ((shortId ?? '').isNotEmpty) 'short-id': shortId,
    };
    applyClientFingerprint(proxy, reality?['fingerprint']?.toString() ?? '');
  } else if (security == 'tls') {
    proxy['tls'] = true;
    if (sni.isNotEmpty) proxy['servername'] = sni;
    if (tlsSettings != null) {
      final alpn = tlsSettings['alpn'];
      if (alpn is List && alpn.isNotEmpty) {
        proxy['alpn'] = [for (final entry in alpn) entry.toString()];
      }
      if (tlsSettings['allowInsecure'] == true) {
        proxy['skip-cert-verify'] = true;
      }
    }
    applyClientFingerprint(
      proxy,
      tlsSettings?['fingerprint']?.toString() ?? '',
    );
  }

  final network = streamSettings['network']?.toString() ?? 'tcp';
  if (network != 'tcp') {
    if (!_applyXrayTransport(proxy, network, streamSettings)) {
      proxy['x-unsupported-transport'] = network;
    }
  }
}

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
      if (proxy['type'] != 'vless') return false;
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
