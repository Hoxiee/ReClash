import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

Map<dynamic, dynamic> _proxyNamed(
  Map<dynamic, dynamic> rawConfig,
  String name,
) {
  final proxies = rawConfig['proxies'] as List;
  return proxies.whereType<Map>().firstWhere((proxy) => proxy['name'] == name);
}

void main() {
  test('the desync outbound is a loopback socks5 on the configured port', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'Amsterdam #1'},
      ],
    };

    appendDesyncProxy(rawConfig: rawConfig, port: 7899);

    final proxy = _proxyNamed(rawConfig, 'DESYNC');
    expect(proxy['type'], 'socks5');
    expect(proxy['server'], '127.0.0.1');
    expect(proxy['port'], 7899);
    expect(proxy['udp'], isTrue);
    expect((rawConfig['proxies'] as List).length, 2);
  });

  test('a profile that owns the name keeps its own outbound', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'DESYNC', 'type': 'vless'},
      ],
    };

    appendDesyncProxy(rawConfig: rawConfig, port: 7898);

    expect((rawConfig['proxies'] as List).length, 1);
    expect(_proxyNamed(rawConfig, 'DESYNC')['type'], 'vless');
  });

  test('a config without proxies still gets the outbound', () {
    final rawConfig = <String, Object?>{};

    appendDesyncProxy(rawConfig: rawConfig, port: 7898);

    expect(_proxyNamed(rawConfig, 'DESYNC')['port'], 7898);
  });

  test('quic is refused before the category reaches the outbound', () {
    final rules = desyncRules(
      categories: [DesyncCategory.youtube],
      forceTcp: true,
    );

    expect(rules, [
      'AND,((NETWORK,udp),(DST-PORT,443),(GEOSITE,youtube)),REJECT',
      'GEOSITE,youtube,DESYNC',
    ]);
  });

  test('leaving quic alone drops the reject', () {
    final rules = desyncRules(
      categories: [DesyncCategory.discord],
      forceTcp: false,
    );

    expect(rules, ['GEOSITE,discord,DESYNC']);
  });

  test('telegram routes the app itself by datacenter IP', () {
    final rules = desyncRules(
      categories: [DesyncCategory.telegram],
      forceTcp: false,
    );

    expect(rules, [
      'GEOSITE,telegram,DESYNC',
      for (final cidr in desyncTelegramCidrs) 'IP-CIDR,$cidr,DESYNC',
    ]);
  });

  test('forceTcp refuses quic to the datacenter ranges too', () {
    final rules = desyncRules(
      categories: [DesyncCategory.telegram],
      forceTcp: true,
    );

    expect(rules, [
      'AND,((NETWORK,udp),(DST-PORT,443),(GEOSITE,telegram)),REJECT',
      'GEOSITE,telegram,DESYNC',
      for (final cidr in desyncTelegramCidrs)
        'AND,((NETWORK,udp),(DST-PORT,443),(IP-CIDR,$cidr)),REJECT',
      for (final cidr in desyncTelegramCidrs) 'IP-CIDR,$cidr,DESYNC',
    ]);
  });

  test('no category means no rules', () {
    expect(desyncRules(categories: [], forceTcp: true), isEmpty);
  });

  test('only-dpi mode keeps the rest of the traffic off the engine', () {
    expect(desyncOnlyFallback(), ['MATCH,DIRECT']);
  });

  test('an only-dpi config builds with no profile at all', () async {
    final result = await makeRealProfileTask(
      const MakeRealProfileState(
        profilesPath: '/profiles',
        profileId: null,
        rawConfig: {},
        realPatchConfig: PatchClashConfig(),
        overrideDns: false,
        appendSystemDns: false,
        proxyGroups: [],
        rules: [],
        addedRules: [],
        defaultUA: 'ReClash-Test',
        desync: true,
        desyncOnly: true,
        desyncCategories: [DesyncCategory.youtube],
      ),
    );

    final yaml = loadYaml(result.yaml) as YamlMap;
    expect(yaml['rules'], [
      'AND,((NETWORK,udp),(DST-PORT,443),(GEOSITE,youtube)),REJECT',
      'GEOSITE,youtube,DESYNC',
      'MATCH,DIRECT',
    ]);
    // Fake-ip would hand the engine unmapped 198.18.x dials it cannot route.
    expect(yaml['dns']['enhanced-mode'], 'redir-host');
    final proxies = yaml['proxies'] as YamlList;
    expect(
      proxies.whereType<YamlMap>().any((proxy) => proxy['name'] == 'DESYNC'),
      isTrue,
    );
  });

  test('a provider dialer-proxy at the reserved name is stripped', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'DESYNC', 'type': 'vless', 'dialer-proxy': 'DESYNC'},
        {'name': 'Amsterdam #1', 'type': 'vless', 'dialer-proxy': 'DESYNC'},
        {'name': 'Berlin #2', 'type': 'vless', 'dialer-proxy': 'other'},
      ],
    };

    stripDesyncDialerProxy(rawConfig);

    expect(
      (rawConfig['proxies'] as List).map(
        (proxy) => (proxy as Map)['dialer-proxy'],
      ),
      [null, null, 'other'],
    );
  });

  test('the strip leaves a config without proxies alone', () {
    final rawConfig = <String, Object?>{
      'proxies': ['not a map', null],
    };
    stripDesyncDialerProxy(rawConfig);
    expect(rawConfig['proxies'], ['not a map', null]);
  });

  test('the rule target and the outbound name are the same string', () {
    expect(RuleTarget.DESYNC.name, desyncOutboundName);
  });

  test('the target is offered only while the bypass is on', () {
    expect(RuleTarget.targetNames(desync: false), ['DIRECT', 'REJECT']);
    expect(RuleTarget.targetNames(desync: true), [
      'DIRECT',
      'REJECT',
      'DESYNC',
    ]);
    expect(RuleTarget.baseTargets, {'DIRECT', 'REJECT'});
  });

  // The ranker reads membership from RCX-NODE alone and would pick a loopback
  // outbound for its latency, sending everything into the desync branch.
  test('the desync outbound never becomes a node', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'DESYNC'},
        {'name': 'Amsterdam #1'},
      ],
    };

    injectRcxSkeleton(rawConfig: rawConfig, rules: ['MATCH,PROXY']);

    final groups = rawConfig['proxy-groups'] as List;
    final node = groups.whereType<Map>().firstWhere(
      (group) => group['name'] == 'RCX-NODE',
    );
    expect(node['proxies'], ['Amsterdam #1']);
  });

  test('a profile of only the reserved name gets no skeleton at all', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'DESYNC'},
      ],
    };

    final rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: ['MATCH,DIRECT'],
    );

    expect(rawConfig.containsKey('proxy-groups'), isFalse);
    expect(rules, ['MATCH,DIRECT']);
  });
}
