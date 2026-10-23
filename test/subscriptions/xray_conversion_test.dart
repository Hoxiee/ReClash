import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/imports/config/xray_config.dart';
import 'package:reclash/subscriptions/imports/subscription/subscription_links.dart';
import 'package:yaml/yaml.dart';

const _servers = [
  ('de1.example', '11111111-1111-4111-8111-111111111111'),
  ('nl1.example', '22222222-2222-4222-8222-222222222222'),
  ('fi1.example', '33333333-3333-4333-8333-333333333333'),
];

Map<String, Object?> _vless(
  String tag,
  int server, {
  Object? fingerprint = 'chrome',
  Map<String, Object?>? sockopt,
}) => {
  'tag': tag,
  'protocol': 'vless',
  'settings': {
    'vnext': [
      {
        'address': _servers[server].$1,
        'port': 443,
        'users': [
          {
            'id': _servers[server].$2,
            'encryption': 'none',
            'flow': 'xtls-rprx-vision',
          },
        ],
      },
    ],
  },
  'streamSettings': {
    'network': 'tcp',
    'security': 'reality',
    'realitySettings': {
      'serverName': 'cdn.example',
      'publicKey': 'pbk$server',
      'shortId': 'ab',
      'spiderX': '/',
      'fingerprint': ?fingerprint,
    },
    'sockopt': ?sockopt,
  },
};

const _direct = {'tag': 'direct', 'protocol': 'freedom'};
const _block = {'tag': 'block', 'protocol': 'blackhole'};

List<Map<String, Object?>> _baseRules(Object catchAll) => [
  {
    'type': 'field',
    'domain': ['geosite:private'],
    'outboundTag': 'direct',
  },
  {
    'type': 'field',
    'ip': ['geoip:private'],
    'outboundTag': 'direct',
  },
  {'type': 'field', 'network': 'tcp,udp', ...(catchAll as Map<String, Object>)},
];

Map<String, Object?> _balancerConfig({
  String strategy = 'leastPing',
  Map<String, Object?>? observatory,
  String? domainStrategy,
  Object? fallbackTag,
}) => {
  'remarks': ' 🚀 Авто | Лучший ',
  'outbounds': [
    for (var i = 0; i < 3; i++) _vless('proxy-${i + 1}', i, fingerprint: null),
    _direct,
    _block,
  ],
  'routing': {
    'domainStrategy': ?domainStrategy,
    'balancers': [
      {
        'tag': 'auto',
        'selector': ['proxy'],
        'strategy': {'type': strategy},
        'fallbackTag': ?fallbackTag,
      },
    ],
    'rules': _baseRules({'balancerTag': 'auto'}),
  },
  ...?observatory,
};

Map<String, Object?> _countryConfig(String remarks, int server) => {
  'remarks': remarks,
  'outbounds': [_vless('proxy', server, fingerprint: null), _direct, _block],
  'routing': {
    'rules': _baseRules({'outboundTag': 'proxy'}),
  },
};

const _burst = {
  'burstObservatory': {
    'subjectSelector': ['proxy'],
    'pingConfig': {
      'destination': 'https://probe.example/204',
      'interval': '1m30s',
      'timeout': '3s',
      'sampling': 2,
    },
  },
};

const _countries = ['🇩🇪 Германия', '🇳🇱 Нидерланды', '🇫🇮 Финляндия'];

List<Object?> _remnawave({Map<String, Object?>? balancer}) => [
  balancer ?? _balancerConfig(observatory: _burst),
  for (var i = 0; i < 3; i++) _countryConfig(_countries[i], i),
];

YamlMap _convert(Object? input) {
  final result = tryConvertXrayConfigValue(input);
  expect(result, isNotNull);
  return loadYaml(result!.config) as YamlMap;
}

YamlMap _group(YamlMap doc, String name) => (doc['proxy-groups'] as YamlList)
    .cast<YamlMap>()
    .firstWhere((group) => group['name'] == name);

YamlMap _proxy(YamlMap doc, String name) => (doc['proxies'] as YamlList)
    .cast<YamlMap>()
    .firstWhere((proxy) => proxy['name'] == name);

void main() {
  group('Remnawave-style array', () {
    late YamlMap doc;

    setUp(() => doc = _convert(_remnawave()));

    test('lists one PROXY entry per config in source order', () {
      expect(_group(doc, 'PROXY')['proxies'], [
        '🚀 Авто | Лучший',
        ..._countries,
        'DIRECT',
      ]);
    });

    test('names the standalone servers by remarks and emits each once', () {
      final proxies = (doc['proxies'] as YamlList).cast<YamlMap>();
      expect(proxies.map((proxy) => proxy['name']), _countries);
      expect(proxies.map((proxy) => proxy['server']), [
        for (final server in _servers) server.$1,
      ]);
    });

    test('turns the main balancer into a hidden group named by remarks', () {
      final group = _group(doc, '🚀 Авто | Лучший');
      expect(group['type'], 'url-test');
      expect(group['hidden'], isTrue);
      expect(group['proxies'], _countries);
      expect(group['url'], 'https://probe.example/204');
      expect(group['interval'], 90);
      expect(group['timeout'], 3000);
      expect(group.containsKey('lazy'), isFalse);
    });

    test('merges routing into one list without catch-alls', () {
      expect(doc['rules'], [
        'GEOSITE,private,DIRECT',
        'GEOIP,lan,DIRECT,no-resolve',
        'MATCH,PROXY',
      ]);
    });

    test('names members after a later remarks-named config', () {
      final configs = _remnawave().reversed.toList();
      final reordered = _convert(configs);
      expect(_group(reordered, '🚀 Авто | Лучший')['proxies'], [
        _countries[0],
        _countries[1],
        _countries[2],
      ]);
    });
  });

  group('health checks', () {
    test('uses observatory probe settings with a 30 second floor', () {
      final doc = _convert([
        _balancerConfig(
          observatory: {
            'observatory': {
              'subjectSelector': ['proxy'],
              'probeInterval': '10s',
            },
          },
        ),
      ]);
      final group = _group(doc, '🚀 Авто | Лучший');
      expect(group['url'], 'https://www.google.com/generate_204');
      expect(group['interval'], 30);
      expect(group['timeout'], 5000);
    });

    test('emits no probe settings without an observatory', () {
      final group = _group(_convert([_balancerConfig()]), '🚀 Авто | Лучший');
      expect(group.containsKey('url'), isFalse);
      expect(group.containsKey('interval'), isFalse);
      expect(group.containsKey('timeout'), isFalse);
    });

    test('defaults burst probe values', () {
      final doc = _convert([
        _balancerConfig(
          observatory: {
            'burstObservatory': {'pingConfig': <String, Object?>{}},
          },
        ),
      ]);
      final group = _group(doc, '🚀 Авто | Лучший');
      expect(group['url'], 'https://www.gstatic.com/generate_204');
      expect(group['interval'], 60);
      expect(group['timeout'], 5000);
    });
  });

  group('balancer strategies', () {
    test('maps leastLoad to url-test with tolerance', () {
      final group = _group(
        _convert([_balancerConfig(strategy: 'leastLoad')]),
        '🚀 Авто | Лучший',
      );
      expect(group['type'], 'url-test');
      expect(group['tolerance'], 50);
    });

    test('maps random and roundRobin to round-robin load balancing', () {
      for (final strategy in ['random', 'roundRobin']) {
        final group = _group(
          _convert([_balancerConfig(strategy: strategy)]),
          '🚀 Авто | Лучший',
        );
        expect(group['type'], 'load-balance');
        expect(group['strategy'], 'round-robin');
      }
    });

    test('ignores a direct fallbackTag but appends a proxy fallback', () {
      final direct = _group(
        _convert([_balancerConfig(fallbackTag: 'direct')]),
        '🚀 Авто | Лучший',
      );
      expect(direct['proxies'], hasLength(3));

      final config = _balancerConfig(fallbackTag: 'backup');
      (config['outbounds']! as List).add({
        ..._vless('backup', 0),
        'settings': {
          'vnext': [
            {
              'address': 'backup.example',
              'port': 443,
              'users': [
                {'id': _servers[0].$2},
              ],
            },
          ],
        },
      });
      final doc = _convert([config]);
      expect(_group(doc, '🚀 Авто | Лучший')['proxies'], hasLength(4));
      expect(_group(doc, 'PROXY')['proxies'], ['🚀 Авто | Лучший', 'DIRECT']);
    });

    test('keeps tiered costs as fallback groups', () {
      final config = _balancerConfig(strategy: 'leastLoad');
      final balancer =
          ((config['routing']! as Map)['balancers'] as List).first
              as Map<String, Object?>;
      balancer['selector'] = ['proxy-1', 'proxy-2'];
      balancer['strategy'] = {
        'type': 'leastLoad',
        'settings': {
          'costs': [
            {'match': 'proxy-2', 'value': 5},
          ],
        },
      };
      final group = _group(_convert([config]), '🚀 Авто | Лучший');
      expect(group['type'], 'fallback');
    });
  });

  group('entries', () {
    test('lists unclaimed proxies after the config entry', () {
      final doc = _convert({
        'remarks': 'Edge',
        'outbounds': [_vless('primary', 0), _vless('spare', 1), _direct],
      });
      expect(_group(doc, 'PROXY')['proxies'], ['Edge', 'spare', 'DIRECT']);
    });

    test('prefers a catch-all target over the first outbound', () {
      final doc = _convert({
        'remarks': 'Edge',
        'outbounds': [_vless('first', 0), _vless('chosen', 1)],
        'routing': {
          'rules': [
            {'type': 'field', 'outboundTag': 'chosen', 'network': 'tcp,udp'},
          ],
        },
      });
      expect(_proxy(doc, 'Edge')['server'], 'nl1.example');
      expect(_group(doc, 'PROXY')['proxies'], ['Edge', 'first', 'DIRECT']);
    });

    test('falls back to the first balancer when no proxy leads', () {
      final config = _balancerConfig();
      (config['outbounds']! as List).insert(0, _direct);
      final doc = _convert([config]);
      expect(_group(doc, 'PROXY')['proxies'], ['🚀 Авто | Лучший', 'DIRECT']);
    });

    test('hides secondary balancers behind rules', () {
      final config = _balancerConfig();
      final routing = config['routing']! as Map<String, Object?>;
      (routing['balancers']! as List).add({
        'tag': 'pair',
        'selector': ['proxy-1', 'proxy-2'],
        'strategy': {'type': 'random'},
      });
      (routing['rules']! as List).insert(0, {
        'type': 'field',
        'domain': ['domain:video.example'],
        'balancerTag': 'pair',
      });
      final doc = _convert([config]);
      expect(_group(doc, 'pair')['hidden'], isTrue);
      expect(_group(doc, 'PROXY')['proxies'], ['🚀 Авто | Лучший', 'DIRECT']);
      expect(
        (doc['rules'] as YamlList).first,
        'DOMAIN-SUFFIX,video.example,pair',
      );
    });

    test('falls back to host names for generic tags without remarks', () {
      final doc = _convert({
        'outbounds': [_vless('proxy-1', 0), _vless('proxy', 1)],
      });
      expect(_group(doc, 'PROXY')['proxies'], [
        'de1.example',
        'nl1.example',
        'DIRECT',
      ]);
    });
  });

  group('dialerProxy', () {
    test('links a convertible hop and does not list it as an entry', () {
      final doc = _convert({
        'remarks': 'Chained',
        'outbounds': [
          _vless('exit', 0, sockopt: {'dialerProxy': 'hop'}),
          _vless('hop', 1),
        ],
      });
      expect(_proxy(doc, 'Chained')['dialer-proxy'], 'hop');
      expect(_group(doc, 'PROXY')['proxies'], ['Chained', 'DIRECT']);
    });

    test('reports a freedom dialer as a loss', () {
      final result = tryConvertXrayConfigValue({
        'remarks': 'Fragmented',
        'outbounds': [
          _vless('exit', 0, sockopt: {'dialerProxy': 'frag'}),
          {
            'tag': 'frag',
            'protocol': 'freedom',
            'settings': {
              'fragment': {'packets': 'tlshello', 'length': '10-20'},
            },
          },
        ],
      });
      expect(result, isA<LossyConversion>());
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      expect(result.config, isNot(contains('dialer-proxy')));
    });

    test('is not a loss without dialers', () {
      final result = tryConvertXrayConfigValue(_remnawave());
      expect((result! as LossyConversion).hasOtherLosses, isFalse);
    });
  });

  group('routing rules', () {
    Map<String, Object?> withRules(
      List<Map<String, Object?>> rules, {
      String? domainStrategy,
    }) => {
      'remarks': 'Edge',
      'outbounds': [_vless('proxy', 0), _vless('other', 1), _direct, _block],
      'routing': {'domainStrategy': ?domainStrategy, 'rules': rules},
    };

    test('maps targets, geo predicates and bare addresses', () {
      final doc = _convert(
        withRules([
          {
            'type': 'field',
            'domain': ['geosite:google', 'full:a.example', 'ext:x:y'],
            'outboundTag': 'proxy',
          },
          {
            'type': 'field',
            'ip': ['geoip:cn', 'geoip:!us', '1.2.3.4', '2001:db8::1'],
            'outboundTag': 'block',
          },
          {'type': 'field', 'port': '53', 'outboundTag': 'other'},
          {
            'type': 'field',
            'domain': ['ext:foo'],
            'outboundTag': 'direct',
          },
        ]),
      );
      expect(doc['rules'], [
        'GEOSITE,google,PROXY',
        'DOMAIN,a.example,PROXY',
        'GEOIP,cn,REJECT,no-resolve',
        'IP-CIDR,1.2.3.4/32,REJECT,no-resolve',
        'IP-CIDR6,2001:db8::1/128,REJECT,no-resolve',
        'DST-PORT,53,other',
        'MATCH,PROXY',
      ]);
    });

    test('keeps IP rules resolvable for non-AsIs domain strategies', () {
      final doc = _convert(
        withRules([
          {
            'type': 'field',
            'ip': ['geoip:private'],
            'outboundTag': 'direct',
          },
        ], domainStrategy: 'IPIfNonMatch'),
      );
      expect(doc['rules'], ['GEOIP,lan,DIRECT', 'MATCH,PROXY']);
    });

    test('places no-resolve inside logical sub-rules', () {
      final doc = _convert(
        withRules([
          {
            'type': 'field',
            'ip': ['10.0.0.0/8'],
            'network': 'tcp',
            'outboundTag': 'direct',
          },
        ]),
      );
      expect(doc['rules'], [
        'AND,((IP-CIDR,10.0.0.0/8,no-resolve),(NETWORK,tcp)),DIRECT',
        'MATCH,PROXY',
      ]);
    });

    test('drops dns targets and rules with only unsupported values', () {
      final config = withRules([
        {
          'type': 'field',
          'domain': ['domain:a.example'],
          'outboundTag': 'dns-out',
        },
        {
          'type': 'field',
          'ip': ['geoip:!cn'],
          'outboundTag': 'direct',
        },
        {
          'type': 'field',
          'protocol': ['bittorrent'],
          'outboundTag': 'direct',
        },
      ]);
      (config['outbounds']! as List).add({'tag': 'dns-out', 'protocol': 'dns'});
      expect(_convert(config)['rules'], ['MATCH,PROXY']);
    });

    test('ignores rules shadowed by a catch-all', () {
      final doc = _convert(
        withRules([
          {'type': 'field', 'outboundTag': 'proxy'},
          {
            'type': 'field',
            'domain': ['domain:late.example'],
            'outboundTag': 'direct',
          },
        ]),
      );
      expect(doc['rules'], ['MATCH,PROXY']);
    });
  });

  group('TLS fidelity', () {
    Map<String, Object?> outbound(
      Object? fingerprint, {
      String security = 'reality',
    }) {
      final proxy = _vless('edge-a', 0, fingerprint: fingerprint);
      if (security == 'tls') {
        (proxy['streamSettings']! as Map<String, Object?>)
          ..['security'] = 'tls'
          ..remove('realitySettings')
          ..['tlsSettings'] = {
            'serverName': 'tls.example',
            'fingerprint': ?fingerprint,
          };
      }
      return proxy;
    }

    YamlMap node(Map<String, Object?> proxy) => _proxy(
      _convert({
        'outbounds': [proxy],
      }),
      'edge-a',
    );

    test('defaults a missing fingerprint to chrome with mlkem on REALITY', () {
      final proxy = node(outbound(null));
      expect(proxy['client-fingerprint'], 'chrome');
      expect(
        (proxy['reality-opts'] as YamlMap)['support-x25519mlkem768'],
        true,
      );
      expect(
        (proxy['reality-opts'] as YamlMap).containsKey('spider-x'),
        isFalse,
      );
    });

    test('treats an empty fingerprint as chrome', () {
      expect(node(outbound(''))['client-fingerprint'], 'chrome');
    });

    test('skips the key share for non-chrome fingerprints', () {
      final proxy = node(outbound('firefox'));
      expect(proxy['client-fingerprint'], 'firefox');
      expect(
        (proxy['reality-opts'] as YamlMap).containsKey(
          'support-x25519mlkem768',
        ),
        isFalse,
      );
    });

    test('omits unsafe on TLS and maps unknown names to chrome', () {
      expect(
        node(
          outbound('unsafe', security: 'tls'),
        ).containsKey('client-fingerprint'),
        isFalse,
      );
      expect(
        node(
          outbound('hellochrome_133', security: 'tls'),
        )['client-fingerprint'],
        'chrome',
      );
      expect(
        node(outbound('bogus', security: 'tls'))['client-fingerprint'],
        'chrome',
      );
      expect(
        node(outbound('hellofirefox_120'))['client-fingerprint'],
        'firefox120',
      );
    });

    test('applies chrome to TLS without tlsSettings fingerprint', () {
      expect(
        node(outbound(null, security: 'tls'))['client-fingerprint'],
        'chrome',
      );
    });
  });
}
