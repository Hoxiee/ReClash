part of 'task.dart';

const rcxNodeGroupName = 'RCX-NODE';
const rcxFinalGroupName = 'RCX-FINAL';
const rcxDirectGroupName = 'RCX-DIRECT';

String? _proxyGroupName(Object? group) => switch (group) {
  final ProxyGroup value => value.name,
  final Map value => value['name']?.toString(),
  _ => null,
};

/// Group membership and rule targets are fixed for the life of a config, so the
/// skeleton has to be emitted before the first packet. The choice inside
/// RCX-NODE belongs to the core.
List<String> injectRcxSkeleton({
  required Map<dynamic, dynamic> rawConfig,
  required List<String> rules,
  List<ServiceRoutePolicy> serviceRoutes = const [],
  Map<String, List<String>> serviceRules = const {},
  int userRuleCount = 0,
}) {
  final groups = rawConfig['proxy-groups'];
  final existing = groups is List ? groups : const [];
  final names = existing.map(_proxyGroupName).whereType<String>().toSet();
  final enabledRoutes = serviceRoutes
      .where(
        (route) =>
            route.enabled &&
            (serviceRules[route.capabilityId]?.isNotEmpty ?? false),
      )
      .toList();
  final reservedNames = {
    rcxNodeGroupName,
    rcxDirectGroupName,
    rcxFinalGroupName,
    for (final route in enabledRoutes) capabilityGroupName(route.capabilityId),
  };
  if (names.intersection(reservedNames).isNotEmpty) {
    return rules;
  }

  final providers =
      (rawConfig['proxy-providers'] as Map?)?.keys
          .map((key) => key.toString())
          .toList() ??
      const <String>[];
  final inline =
      (rawConfig['proxies'] as List?)
          ?.map((proxy) => proxy is Map ? proxy['name']?.toString() : null)
          .whereType<String>()
          .where((name) => name != desyncOutboundName)
          .toList() ??
      const <String>[];
  if (providers.isEmpty && inline.isEmpty) {
    return rules;
  }

  // Index 0 is where an unknown selection lands: a node keeps it proxied, and
  // REJECT stands in while a provider loads because DIRECT would leak.
  final members = inline.isNotEmpty ? inline : const ['REJECT'];
  final capabilityGroups = [
    for (final route in enabledRoutes)
      <String, Object?>{
        'name': capabilityGroupName(route.capabilityId),
        'type': 'select',
        'hidden': true,
        'proxies': <String>[
          'REJECT',
          if (route.fallback == ServiceRouteFallback.main) rcxNodeGroupName,
          ...inline,
        ],
        if (providers.isNotEmpty) 'use': providers,
      },
  ];
  rawConfig['proxy-groups'] = <Object?>[
    ...existing,
    <String, Object?>{
      'name': rcxNodeGroupName,
      'type': 'select',
      'proxies': members,
      if (providers.isNotEmpty) 'use': providers,
    },
    ...capabilityGroups,
    <String, Object?>{
      'name': rcxDirectGroupName,
      'type': 'select',
      'hidden': true,
      'proxies': <String>['DIRECT', rcxNodeGroupName],
    },
    <String, Object?>{
      'name': rcxFinalGroupName,
      'type': 'select',
      'hidden': true,
      'proxies': <String>[rcxNodeGroupName, 'DIRECT'],
    },
  ];

  return _patchRcxRules(rules, enabledRoutes, serviceRules, userRuleCount);
}

List<String> _patchRcxRules(
  List<String> rules,
  List<ServiceRoutePolicy> serviceRoutes,
  Map<String, List<String>> serviceRules,
  int userRuleCount,
) {
  final patched = List<String>.from(rules);
  for (var i = 0; i < patched.length; i++) {
    final parts = patched[i].split(',');
    final target = _ruleTargetOf(parts);
    if (target < 0 || parts[target].trim().toUpperCase() != 'DIRECT') {
      continue;
    }
    if (_isLocalRule(parts)) {
      continue;
    }
    parts[target] = rcxDirectGroupName;
    patched[i] = parts.join(',');
  }
  final capabilityRules = [
    for (final route in serviceRoutes)
      for (final rule in serviceRules[route.capabilityId] ?? const [])
        '$rule,${capabilityGroupName(route.capabilityId)}',
  ];
  final protected = userRuleCount.clamp(0, patched.length);
  final capabilitySet = capabilityRules.toSet();
  for (var i = patched.length - 1; i >= protected; i--) {
    if (capabilitySet.contains(patched[i])) {
      patched.removeAt(i);
    }
  }
  final matchIndex = patched.indexWhere(
    (rule) => rule.split(',').first.trim().toUpperCase() == 'MATCH',
  );
  if (matchIndex >= 0) {
    patched[matchIndex] = 'MATCH,$rcxFinalGroupName';
  } else {
    patched.add('MATCH,$rcxFinalGroupName');
  }
  // Nothing below the catch-all is ever evaluated, so a protected prefix that
  // reaches past MATCH cannot push the service rules there.
  final ceiling = matchIndex >= 0 ? matchIndex : patched.length - 1;
  patched.insertAll(protected < ceiling ? protected : ceiling, capabilityRules);
  return patched;
}

// src/no-resolve flags trail the target field.
int _ruleTargetOf(List<String> parts) {
  for (var i = parts.length - 1; i >= 1; i--) {
    final flag = parts[i].trim().toLowerCase();
    if (flag == 'src' || flag == 'no-resolve') {
      continue;
    }
    return i;
  }
  return -1;
}

bool _isLocalRule(List<String> parts) {
  final action = parts.first.trim().toUpperCase();
  final content = parts.length > 1 ? parts[1].trim().toLowerCase() : '';
  if (action == 'GEOIP') {
    return content == 'private' || content == 'lan';
  }
  if (action == 'IP-CIDR' || action == 'IP-CIDR6') {
    final host = content.split('/').first;
    return host == '127.0.0.1' || host == '::1' || _isPrivateCidr(host);
  }
  return false;
}

bool _isPrivateCidr(String host) {
  final ipv4 = host.split('.');
  if (ipv4.length != 4) {
    return false;
  }
  final first = int.tryParse(ipv4[0]);
  final second = int.tryParse(ipv4[1]);
  if (first == null || second == null) {
    return false;
  }
  if (first == 10 || (first == 192 && second == 168)) {
    return true;
  }
  return first == 172 && second >= 16 && second <= 31;
}
