import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/imports/config/singbox_config.dart';
import 'package:yaml/yaml.dart';

Map<String, Object?> _vless(String tag, String server) => {
  'type': 'vless',
  'tag': tag,
  'server': server,
  'server_port': 443,
  'uuid': '11111111-1111-4111-8111-111111111111',
};

Map<String, Object?> _config({
  List<Map<String, Object?>>? outbounds,
  Map<String, Object?>? route,
}) => {
  'outbounds':
      outbounds ??
      [
        {
          'type': 'selector',
          'tag': 'select',
          'outbounds': ['auto', '🇩🇪 Germany', '🇳🇱 Netherlands'],
          'default': 'auto',
        },
        {
          'type': 'urltest',
          'tag': 'auto',
          'outbounds': ['🇩🇪 Germany', '🇳🇱 Netherlands'],
          'url': 'https://cp.cloudflare.com/',
          'interval': '10m',
          'tolerance': 100,
          'idle_timeout': '30m',
        },
        _vless('🇩🇪 Germany', 'de.example'),
        _vless('🇳🇱 Netherlands', 'nl.example'),
        {'type': 'direct', 'tag': 'direct'},
        {'type': 'block', 'tag': 'block'},
        {'type': 'dns', 'tag': 'dns-out'},
      ],
  'route': ?route,
};

Map<String, Object?> _convert(Map<String, Object?> config) {
  final result = tryConvertSingboxConfig(jsonEncode(config));
  expect(result, isNotNull);
  return Map<String, Object?>.from(loadYaml(result!.config) as YamlMap);
}

List<Map<String, Object?>> _groups(Map<String, Object?> yaml) => [
  for (final group in yaml['proxy-groups']! as YamlList)
    Map<String, Object?>.from(group as YamlMap),
];

Map<String, Object?> _group(Map<String, Object?> yaml, String name) =>
    _groups(yaml).singleWhere((group) => group['name'] == name);

List<String> _rules(Map<String, Object?> yaml) => [
  for (final rule in yaml['rules']! as YamlList) rule as String,
];

void main() {
  group('sing-box groups', () {
    test('keeps the Hiddify selector and urltest as one auto entry', () {
      final yaml = _convert(
        _config(
          route: {
            'rules': [
              {'ip_is_private': true, 'outbound': 'direct'},
            ],
            'final': 'select',
          },
        ),
      );
      final names = _groups(yaml).map((group) => group['name']).toList();
      expect(names, ['auto', 'PROXY']);
      expect(_group(yaml, 'PROXY')['proxies'], [
        'auto',
        '🇩🇪 Germany',
        '🇳🇱 Netherlands',
        'DIRECT',
      ]);
      expect(_group(yaml, 'auto'), {
        'name': 'auto',
        'type': 'url-test',
        'proxies': ['🇩🇪 Germany', '🇳🇱 Netherlands'],
        'url': 'https://cp.cloudflare.com/',
        'interval': 600,
        'tolerance': 100,
        'hidden': true,
      });
      expect(_rules(yaml), ['GEOIP,lan,DIRECT,no-resolve', 'MATCH,PROXY']);
    });

    test('applies url-test defaults and the interval floor', () {
      final outbounds = [
        {
          'type': 'urltest',
          'tag': 'auto',
          'outbounds': ['a'],
        },
        {
          'type': 'urltest',
          'tag': 'fast',
          'outbounds': ['a'],
          'interval': '10s',
        },
        {
          'type': 'urltest',
          'tag': 'precise',
          'outbounds': ['a'],
          'interval': '1m30s',
        },
        _vless('a', 'a.example'),
      ];
      final yaml = _convert(_config(outbounds: outbounds));
      expect(_group(yaml, 'auto'), containsPair('interval', 180));
      expect(_group(yaml, 'auto'), containsPair('tolerance', 50));
      expect(
        _group(yaml, 'auto'),
        containsPair('url', 'https://www.gstatic.com/generate_204'),
      );
      expect(_group(yaml, 'fast'), containsPair('interval', 30));
      expect(_group(yaml, 'precise'), containsPair('interval', 90));
    });

    test('moves the selector default first in a visible group', () {
      final yaml = _convert(
        _config(
          outbounds: [
            {
              'type': 'selector',
              'tag': 'main',
              'outbounds': ['a', 'pick'],
            },
            {
              'type': 'selector',
              'tag': 'pick',
              'outbounds': ['a', 'b', 'direct', 'block', 'dns-out', 'ghost'],
              'default': 'b',
            },
            _vless('a', 'a.example'),
            _vless('b', 'b.example'),
            {'type': 'direct', 'tag': 'direct'},
            {'type': 'block', 'tag': 'block'},
            {'type': 'dns', 'tag': 'dns-out'},
          ],
        ),
      );
      expect(_group(yaml, 'pick'), {
        'name': 'pick',
        'type': 'select',
        'proxies': ['b', 'a', 'DIRECT', 'REJECT'],
        'hidden': true,
      });
      expect(_group(yaml, 'PROXY')['proxies'], ['a', 'pick', 'DIRECT']);
    });

    test('drops groups left empty and references to them', () {
      final yaml = _convert(
        _config(
          outbounds: [
            {
              'type': 'selector',
              'tag': 'main',
              'outbounds': ['empty', 'a'],
            },
            {
              'type': 'urltest',
              'tag': 'empty',
              'outbounds': ['ghost', 'dns-out'],
            },
            _vless('a', 'a.example'),
            {'type': 'dns', 'tag': 'dns-out'},
          ],
          route: {
            'rules': [
              {'domain': 'x.example', 'outbound': 'empty'},
            ],
          },
        ),
      );
      expect(_groups(yaml).map((group) => group['name']), ['PROXY']);
      expect(_group(yaml, 'PROXY')['proxies'], ['a', 'DIRECT']);
      expect(_rules(yaml), ['MATCH,PROXY']);
    });

    test('uses a urltest final as the single auto entry', () {
      final yaml = _convert(
        _config(
          outbounds: [
            {
              'type': 'selector',
              'tag': 'manual',
              'outbounds': ['a', 'b'],
            },
            {
              'type': 'urltest',
              'tag': 'auto',
              'outbounds': ['a'],
            },
            _vless('a', 'a.example'),
            _vless('b', 'b.example'),
            _vless('c', 'c.example'),
          ],
          route: {'final': 'auto'},
        ),
      );
      expect(_group(yaml, 'PROXY')['proxies'], ['auto', 'c', 'DIRECT']);
      expect(_group(yaml, 'auto'), containsPair('hidden', true));
      expect(_group(yaml, 'manual').containsKey('hidden'), isFalse);
      expect(_rules(yaml), ['MATCH,PROXY']);
    });

    test('falls back to the first selector without a usable final', () {
      final yaml = _convert(
        _config(
          outbounds: [
            {
              'type': 'urltest',
              'tag': 'auto',
              'outbounds': ['a'],
            },
            {
              'type': 'selector',
              'tag': 'manual',
              'outbounds': ['auto', 'b'],
            },
            _vless('a', 'a.example'),
            _vless('b', 'b.example'),
            {'type': 'direct', 'tag': 'direct'},
          ],
          route: {'final': 'direct'},
        ),
      );
      expect(_group(yaml, 'PROXY')['proxies'], ['auto', 'b', 'DIRECT']);
      expect(_rules(yaml), ['MATCH,DIRECT']);
    });

    test('keeps the flat list when the config has no groups', () {
      final yaml = _convert(
        _config(
          outbounds: [_vless('a', 'a.example'), _vless('b', 'b.example')],
        ),
      );
      expect(_groups(yaml).single['proxies'], ['a', 'b', 'DIRECT']);
      expect(_rules(yaml), ['MATCH,PROXY']);
    });

    test('does not let a group take the generated PROXY name', () {
      final yaml = _convert(
        _config(
          outbounds: [
            {
              'type': 'selector',
              'tag': 'main',
              'outbounds': ['PROXY', 'a'],
            },
            {
              'type': 'urltest',
              'tag': 'PROXY',
              'outbounds': ['a'],
            },
            _vless('a', 'a.example'),
          ],
        ),
      );
      expect(_group(yaml, 'PROXY 2'), containsPair('type', 'url-test'));
      expect(_group(yaml, 'PROXY')['proxies'], ['PROXY 2', 'a', 'DIRECT']);
    });
  });

  group('sing-box rules', () {
    Map<String, Object?> convertRules(
      List<Map<String, Object?>> rules, {
      String? finalTag = 'select',
    }) => _convert(_config(route: {'rules': rules, 'final': ?finalTag}));

    test('maps single-field predicates to individual rules', () {
      final yaml = convertRules([
        {
          'domain': ['a.example'],
          'domain_suffix': null,
          'outbound': 'direct',
        },
        {
          'domain_suffix': ['.example.com', 'example.org'],
          'outbound': 'select',
        },
        {'domain_keyword': 'ads', 'action': 'reject'},
        {'domain_regex': r'^ad\d+\.', 'outbound': 'block'},
        {
          'ip_cidr': ['10.0.0.0/8', '2001:db8::/32', '1.1.1.1'],
          'outbound': 'direct',
        },
        {'geosite': 'cn', 'outbound': 'direct'},
        {
          'geoip': ['private', 'cn'],
          'outbound': 'direct',
        },
        {
          'port': [80, '443'],
          'outbound': '🇩🇪 Germany',
        },
        {
          'port_range': ['1000:2000', ':53', '8000:'],
          'outbound': 'auto',
        },
        {'network': 'udp', 'outbound': 'block'},
      ]);
      expect(_rules(yaml), [
        'DOMAIN,a.example,DIRECT',
        'DOMAIN-SUFFIX,example.com,PROXY',
        'DOMAIN-SUFFIX,example.org,PROXY',
        'DOMAIN-KEYWORD,ads,REJECT',
        r'DOMAIN-REGEX,^ad\d+\.,REJECT',
        'IP-CIDR,10.0.0.0/8,DIRECT,no-resolve',
        'IP-CIDR6,2001:db8::/32,DIRECT,no-resolve',
        'IP-CIDR,1.1.1.1/32,DIRECT,no-resolve',
        'GEOSITE,cn,DIRECT',
        'GEOIP,lan,DIRECT,no-resolve',
        'GEOIP,cn,DIRECT,no-resolve',
        'DST-PORT,80,🇩🇪 Germany',
        'DST-PORT,443,🇩🇪 Germany',
        'DST-PORT,1000-2000,auto',
        'DST-PORT,0-53,auto',
        'DST-PORT,8000-65535,auto',
        'NETWORK,udp,REJECT',
        'MATCH,PROXY',
      ]);
    });

    test('combines fields with AND and values with OR', () {
      final yaml = convertRules([
        {
          'network': 'tcp',
          'port': [80, 443],
          'ip_cidr': ['10.0.0.0/8'],
          'outbound': 'direct',
        },
        {
          'domain_suffix': ['a.example'],
          'network': 'udp',
          'outbound': 'direct',
        },
      ]);
      expect(_rules(yaml), [
        'AND,((NETWORK,tcp),(OR,((DST-PORT,80),(DST-PORT,443))),(IP-CIDR,10.0.0.0/8,no-resolve)),DIRECT',
        'AND,((DOMAIN-SUFFIX,a.example),(NETWORK,udp)),DIRECT',
        'MATCH,PROXY',
      ]);
    });

    test('skips rules it cannot express faithfully', () {
      final yaml = convertRules([
        {'action': 'sniff'},
        {'action': 'hijack-dns', 'protocol': 'dns'},
        {'action': 'resolve'},
        {'action': 'route-options', 'domain': 'x.example'},
        {'protocol': 'dns', 'outbound': 'direct'},
        {
          'rule_set': ['geoip-cn'],
          'outbound': 'direct',
        },
        {
          'process_name': ['curl'],
          'outbound': 'direct',
        },
        {'clash_mode': 'direct', 'outbound': 'direct'},
        {
          'inbound': ['tun'],
          'outbound': 'direct',
        },
        {'domain': 'x.example', 'invert': true, 'outbound': 'direct'},
        {
          'domain': 'x.example',
          'rule_set': ['a'],
          'outbound': 'direct',
        },
        {'ip_is_private': false, 'outbound': 'direct'},
        {'port_range': 'bad', 'outbound': 'direct'},
        {'domain': 'x.example', 'outbound': 'dns-out'},
        {'domain': 'x.example', 'outbound': 'missing'},
        {
          'type': 'logical',
          'mode': 'and',
          'rules': [
            {'domain': 'x.example'},
          ],
          'outbound': 'direct',
        },
        {'outbound': 'direct'},
      ]);
      expect(_rules(yaml), ['MATCH,PROXY']);
    });

    test('deduplicates identical rules and keeps first order', () {
      final yaml = convertRules([
        {'domain_suffix': 'a.example', 'outbound': 'direct'},
        {'domain_suffix': 'b.example', 'outbound': 'direct'},
        {'domain_suffix': '.a.example', 'outbound': 'direct'},
      ]);
      expect(_rules(yaml), [
        'DOMAIN-SUFFIX,a.example,DIRECT',
        'DOMAIN-SUFFIX,b.example,DIRECT',
        'MATCH,PROXY',
      ]);
    });

    test('maps the final outbound', () {
      expect(_rules(convertRules([], finalTag: 'direct')), ['MATCH,DIRECT']);
      expect(_rules(convertRules([], finalTag: 'block')), ['MATCH,REJECT']);
      expect(_rules(convertRules([], finalTag: '🇳🇱 Netherlands')), [
        'MATCH,🇳🇱 Netherlands',
      ]);
      expect(_rules(convertRules([], finalTag: null)), ['MATCH,PROXY']);
      expect(_rules(convertRules([], finalTag: 'dns-out')), ['MATCH,PROXY']);
    });
  });
}
