import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('no category means no rules', () {
    expect(desyncRules(categories: [], forceTcp: true), isEmpty);
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
