import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<dynamic, dynamic> _groupNamed(
  Map<dynamic, dynamic> rawConfig,
  String name,
) {
  final groups = rawConfig['proxy-groups'] as List;
  return groups.whereType<Map>().firstWhere((group) => group['name'] == name);
}

String? _proxyGroupNameForTest(Object? group) =>
    group is Map ? group['name']?.toString() : null;

void main() {
  test('an inline profile routes MATCH through the node group', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'Amsterdam #1'},
        {'name': 'Amsterdam #2'},
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['DOMAIN-SUFFIX,lan,DIRECT', 'MATCH,PROXY'],
    );

    expect(rules.last, 'MATCH,RCX-FINAL');
    // A direct rule is the profile's domestic policy: it follows the terrain.
    expect(rules.first, 'DOMAIN-SUFFIX,lan,RCX-DIRECT');
    final node = _groupNamed(rawConfig, 'RCX-NODE');
    expect(node['proxies'], ['Amsterdam #1', 'Amsterdam #2']);
    expect(node.containsKey('use'), isFalse);
    expect(node.containsKey('url'), isFalse);
    expect(node.containsKey('interval'), isFalse);
    final wiring = _groupNamed(rawConfig, 'RCX-FINAL');
    expect(wiring['hidden'], isTrue);
    expect(wiring['proxies'], ['RCX-NODE', 'DIRECT']);
  });

  test('a provider profile falls back to REJECT rather than DIRECT', () {
    final rawConfig = <String, Object?>{
      'proxy-providers': {
        'main': {'type': 'http'},
      },
    };

    injectRcxSkeleton(rawConfig: rawConfig, rules: ['MATCH,PROXY']);

    final node = _groupNamed(rawConfig, 'RCX-NODE');
    expect(node['use'], ['main']);
    // Index 0 is where an unknown selection lands, and DIRECT there would put
    // the request on the wire while the provider is still loading.
    expect((node['proxies'] as List).first, 'REJECT');
  });

  test('a profile with no MATCH rule gains one', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['DOMAIN-SUFFIX,lan,DIRECT'],
    );

    expect(rules, ['DOMAIN-SUFFIX,lan,RCX-DIRECT', 'MATCH,RCX-FINAL']);
  });

  test('only the effective MATCH is retargeted', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['MATCH,PROXY', 'MATCH,DIRECT'],
    );

    // Only the first MATCH is live; a parked one still retargets DIRECT.
    expect(rules, ['MATCH,RCX-FINAL', 'MATCH,RCX-DIRECT']);
  });

  test('a profile that already owns the names is left alone', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
      'proxy-groups': [
        {
          'name': 'RCX-NODE',
          'type': 'select',
          'proxies': ['node'],
        },
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['MATCH,PROXY'],
    );

    expect(rules, ['MATCH,PROXY']);
    expect((rawConfig['proxy-groups'] as List).length, 1);
  });

  test('a park with nothing in it emits no skeleton', () {
    final rawConfig = <String, Object?>{'proxies': const []};

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['MATCH,PROXY'],
    );

    expect(rules, ['MATCH,PROXY']);
    expect(rawConfig.containsKey('proxy-groups'), isFalse);
  });

  test('domestic direct rules retarget, local ranges stay direct', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: [
        'DOMAIN-SUFFIX,yandex.ru,DIRECT',
        'GEOIP,RU,DIRECT',
        'GEOIP,private,DIRECT,no-resolve',
        'IP-CIDR,10.0.0.0/8,DIRECT',
        'IP-CIDR,192.168.1.0/24,DIRECT',
        'IP-CIDR,172.16.0.0/12,DIRECT',
        'IP-CIDR,127.0.0.1/32,DIRECT',
        'DOMAIN-SUFFIX,google.com,PROXY',
      ],
    );

    expect(rules, [
      'DOMAIN-SUFFIX,yandex.ru,RCX-DIRECT',
      'GEOIP,RU,RCX-DIRECT',
      'GEOIP,private,DIRECT,no-resolve',
      'IP-CIDR,10.0.0.0/8,DIRECT',
      'IP-CIDR,192.168.1.0/24,DIRECT',
      'IP-CIDR,172.16.0.0/12,DIRECT',
      'IP-CIDR,127.0.0.1/32,DIRECT',
      'DOMAIN-SUFFIX,google.com,PROXY',
      'MATCH,RCX-FINAL',
    ]);
    final split = _groupNamed(rawConfig, 'RCX-DIRECT');
    expect(split['hidden'], isTrue);
    // DIRECT is index 0, so an unconfigured group starts on the safe path.
    expect(split['proxies'], ['DIRECT', 'RCX-NODE']);
  });

  test('no-resolve rides along on a retargeted rule', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['GEOIP,RU,DIRECT,no-resolve', 'MATCH,DIRECT'],
    );

    expect(rules, ['GEOIP,RU,RCX-DIRECT,no-resolve', 'MATCH,RCX-FINAL']);
  });

  test('a patched config is not patched twice', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };

    final once = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['GEOIP,RU,DIRECT', 'MATCH,DIRECT'],
    );

    final twice = injectRcxSkeleton(rawConfig: rawConfig, rules: once);

    expect(twice, once);
  });

  test('enabled capability routes add hidden selectors and local rules', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'plain'},
        {'name': '⭐ premium'},
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: [
        'DOMAIN,override.test,DIRECT',
        'DOMAIN-SUFFIX,gemini.google.com,PROXY',
        'MATCH,PROXY',
      ],
      userRuleCount: 1,
      serviceRoutes: const [
        ServiceRoutePolicy(
          capabilityId: 'gemini-access',
          enabled: true,
          fallback: ServiceRouteFallback.main,
        ),
      ],
    );

    final lane = _groupNamed(rawConfig, 'RCX-CAP-GEMINI_ACCESS');
    expect(lane['hidden'], isTrue);
    expect(lane['proxies'], ['REJECT', 'RCX-NODE', 'plain', '⭐ premium']);
    expect(rules, [
      'DOMAIN,override.test,RCX-DIRECT',
      'DOMAIN-SUFFIX,gemini.google.com,RCX-CAP-GEMINI_ACCESS',
      'DOMAIN,aistudio.google.com,RCX-CAP-GEMINI_ACCESS',
      'DOMAIN-SUFFIX,ai.google.dev,RCX-CAP-GEMINI_ACCESS',
      'DOMAIN,generativelanguage.googleapis.com,RCX-CAP-GEMINI_ACCESS',
      'DOMAIN,bard.google.com,RCX-CAP-GEMINI_ACCESS',
      'DOMAIN-SUFFIX,gemini.google.com,PROXY',
      'MATCH,RCX-FINAL',
    ]);
  });

  test('capability rules are canonicalized after user overrides', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };
    const duplicate = 'DOMAIN-SUFFIX,gemini.google.com,RCX-CAP-GEMINI_ACCESS';

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: [
        'DOMAIN,override.test,DIRECT',
        duplicate,
        'DOMAIN,source.test,PROXY',
        'MATCH,PROXY',
      ],
      userRuleCount: 1,
      serviceRoutes: const [
        ServiceRoutePolicy(capabilityId: 'gemini-access', enabled: true),
      ],
    );

    expect(rules.first, 'DOMAIN,override.test,RCX-DIRECT');
    expect(rules[1], duplicate);
    expect(rules.where((rule) => rule == duplicate), hasLength(1));
    expect(
      rules.indexOf('DOMAIN,bard.google.com,RCX-CAP-GEMINI_ACCESS'),
      lessThan(rules.indexOf('DOMAIN,source.test,PROXY')),
    );
    expect(rules.last, 'MATCH,RCX-FINAL');
  });

  test('a fully protected rule list keeps service rules above MATCH', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };
    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['DOMAIN-SUFFIX,gemini.google.com,PROXY', 'MATCH,PROXY'],
      userRuleCount: 2,
      serviceRoutes: const [
        ServiceRoutePolicy(capabilityId: 'gemini-access', enabled: true),
      ],
    );

    expect(rules.first, 'DOMAIN-SUFFIX,gemini.google.com,PROXY');
    expect(rules.last, 'MATCH,RCX-FINAL');
    expect(
      rules.indexOf('DOMAIN,bard.google.com,RCX-CAP-GEMINI_ACCESS'),
      lessThan(rules.indexOf('MATCH,RCX-FINAL')),
    );
  });

  test('strict capability fallback never contains the base lane', () {
    final rawConfig = <String, Object?>{
      'proxy-providers': {
        'main': {'type': 'http'},
      },
    };

    injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['MATCH,PROXY'],
      serviceRoutes: const [
        ServiceRoutePolicy(
          capabilityId: 'youtube-adfree',
          enabled: true,
          fallback: ServiceRouteFallback.reject,
        ),
      ],
    );

    final lane = _groupNamed(rawConfig, 'RCX-CAP-YOUTUBE_ADFREE');
    expect(lane['proxies'], ['REJECT']);
    expect(lane['use'], ['main']);
  });

  test('unsupported and disabled capabilities emit no topology', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
    };

    injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['MATCH,PROXY'],
      serviceRoutes: const [
        ServiceRoutePolicy(capabilityId: 'gemini-access'),
        ServiceRoutePolicy(capabilityId: 'future', enabled: true),
      ],
    );

    expect(
      (rawConfig['proxy-groups'] as List).map(_proxyGroupNameForTest),
      isNot(contains(startsWith('RCX-CAP-'))),
    );
  });

  test('a capability name collision leaves the profile untouched', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
      'proxy-groups': [
        {
          'name': 'RCX-CAP-GEMINI_ACCESS',
          'type': 'select',
          'proxies': ['node'],
        },
      ],
    };
    final originalRules = ['MATCH,PROXY'];

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: originalRules,
      serviceRoutes: const [
        ServiceRoutePolicy(capabilityId: 'gemini-access', enabled: true),
      ],
    );

    expect(rules, originalRules);
    expect((rawConfig['proxy-groups'] as List), hasLength(1));
  });

  test('groups the overwrite feature built survive the append', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
      'proxy-groups': <Object?>[
        const ProxyGroup(id: 1, name: 'Mine', type: GroupType.Selector),
      ],
    };

    injectRcxSkeleton(rawConfig: rawConfig, rules: ['MATCH,PROXY']);

    final groups = rawConfig['proxy-groups'] as List;
    expect(groups.length, 4);
    expect((groups.first as ProxyGroup).name, 'Mine');
  });
}
