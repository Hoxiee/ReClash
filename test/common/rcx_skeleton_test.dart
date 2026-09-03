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
    expect(rules.first, 'DOMAIN-SUFFIX,lan,DIRECT');
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

    expect(rules, ['DOMAIN-SUFFIX,lan,DIRECT', 'MATCH,RCX-FINAL']);
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

    expect(rules, ['MATCH,RCX-FINAL', 'MATCH,DIRECT']);
  });

  test('a profile that already owns the names is left alone', () {
    final rawConfig = <String, Object?>{
      'proxies': [
        {'name': 'node'},
      ],
      'proxy-groups': [
        {'name': 'RCX-NODE', 'type': 'select', 'proxies': ['node']},
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
    expect(groups.length, 3);
    expect((groups.first as ProxyGroup).name, 'Mine');
  });
}
