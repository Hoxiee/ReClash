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
      'fingerprint': ?fingerprint,
    },
    'sockopt': ?sockopt,
  },
};

Map<String, Object?> _vlessUsers(Map<String, Object?> outbound) =>
    ((((outbound['settings']! as Map<String, Object?>)['vnext']! as List).first
                    as Map<String, Object?>)['users']!
                as List)
            .first
        as Map<String, Object?>;

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

    test('maps a freedom fragment dialer to fragment-opts', () {
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
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isFalse);
      expect(result.config, isNot(contains('dialer-proxy')));
      final proxy = _proxy(loadYaml(result.config) as YamlMap, 'Fragmented');
      expect(proxy['fragment-opts'], {
        'packets': 'tlshello',
        'length': '10-20',
      });
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

    test('reports spiderX as a conversion loss', () {
      final proxy = _vless('edge-a', 0);
      ((proxy['streamSettings']! as Map<String, Object?>)['realitySettings']!
              as Map<String, Object?>)['spiderX'] =
          '/';
      final result = tryConvertXrayConfigValue({
        'outbounds': [proxy],
      });
      expect(result, isA<LossyConversion>());
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      expect((result as SecurityLossyConversion).hasSecurityLoss, isTrue);
      expect(result.config, isNot(contains('spider-x')));
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
        'chrome133',
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

    test('maps TLS certificate pins, name verification and ECH', () {
      final raw = _vless('edge-a', 0);
      final stream = raw['streamSettings']! as Map<String, Object?>;
      stream
        ..['security'] = 'tls'
        ..remove('realitySettings')
        ..['tlsSettings'] = {
          'serverName': 'front.example',
          'pinnedPeerCertSha256': 'AA:BB',
          'verifyPeerCertByName': 'front.example,alt.example',
          'echConfigList': 'udp://1.1.1.1',
        };
      final proxy = _proxy(
        _convert({
          'outbounds': [raw],
        }),
        'edge-a',
      );
      expect(proxy['fingerprint'], 'AA:BB');
      expect(proxy['name-cert-verify'], 'front.example,alt.example');
      expect(proxy['ech-opts'], {
        'enable': true,
        'query-server': 'udp://1.1.1.1',
      });
    });

    test('maps the new REALITY password and ML-DSA fields', () {
      final raw = _vless('edge-a', 0);
      final reality =
          (raw['streamSettings']! as Map<String, Object?>)['realitySettings']!
              as Map<String, Object?>;
      reality
        ..remove('publicKey')
        ..['password'] = 'new-public-key'
        ..['mldsa65Verify'] = 'mldsa-key';
      final proxy = _proxy(
        _convert({
          'outbounds': [raw],
        }),
        'edge-a',
      );
      final options = proxy['reality-opts'] as YamlMap;
      expect(options['public-key'], 'new-public-key');
      expect(options['mldsa65-verify'], 'mldsa-key');
    });

    test('maps sockopt and WS headers, and reports keepalive loss', () {
      final raw = _vless('edge-a', 0);
      final stream = raw['streamSettings']! as Map<String, Object?>;
      stream
        ..['network'] = 'ws'
        ..['wsSettings'] = {
          'path': '/ws',
          'headers': {'Host': 'front.example', 'X-Test': 'yes'},
          'maxEarlyData': 2048,
          'earlyDataHeaderName': 'Sec-WebSocket-Protocol',
        }
        ..['sockopt'] = {
          'tcpFastOpen': true,
          'tcpMptcp': true,
          'mark': 123,
          'interface': 'eth0',
          'tcpKeepAliveInterval': 15,
        };
      final result = tryConvertXrayConfigValue({
        'outbounds': [raw],
      });
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      final proxy = _proxy(loadYaml(result.config) as YamlMap, 'edge-a');
      expect(proxy['tfo'], true);
      expect(proxy['mptcp'], true);
      expect(proxy['routing-mark'], 123);
      expect(proxy['interface-name'], 'eth0');
      expect(proxy['ws-opts'], {
        'path': '/ws',
        'headers': {'Host': 'front.example', 'X-Test': 'yes'},
        'max-early-data': 2048,
        'early-data-header-name': 'Sec-WebSocket-Protocol',
      });
    });

    test('maps Xray mux to mux.cool, except with Vision', () {
      final plain = _vless('edge-a', 0);
      final users =
          ((((plain['settings']! as Map<String, Object?>)['vnext']! as List)
                              .first
                          as Map<String, Object?>)['users']!
                      as List)
                  .first
              as Map<String, Object?>;
      users.remove('flow');
      plain['mux'] = {
        'enabled': true,
        'concurrency': 8,
        'xudpConcurrency': 16,
        'xudpProxyUDP443': 'allow',
      };
      final proxy = _proxy(
        _convert({
          'outbounds': [plain],
        }),
        'edge-a',
      );
      expect(proxy['mux.cool'], {
        'enabled': true,
        'max-concurrency': 8,
        'xudp-concurrency': 16,
        'xudp-proxy-udp443': 'allow',
      });

      final vision = _vless('edge-b', 1);
      vision['mux'] = {'enabled': true, 'concurrency': 8};
      final result = tryConvertXrayConfigValue({
        'outbounds': [vision],
      });
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      expect(result.config, isNot(contains('mux.cool')));
    });

    test('maps raw to tcp and http to h2', () {
      final raw = _vless('raw-node', 0);
      final rawStream = raw['streamSettings']! as Map<String, Object?>;
      rawStream
        ..['network'] = 'raw'
        ..['security'] = 'tls'
        ..remove('realitySettings')
        ..['tlsSettings'] = {'serverName': 'raw.example'};
      final rawProxy = _proxy(
        _convert({
          'outbounds': [raw],
        }),
        'raw-node',
      );
      expect(rawProxy.containsKey('network'), isFalse);

      final http = _vless('http-node', 1);
      final httpStream = http['streamSettings']! as Map<String, Object?>;
      httpStream
        ..['network'] = 'http'
        ..['security'] = 'tls'
        ..remove('realitySettings')
        ..['tlsSettings'] = {'serverName': 'http.example'}
        ..['httpSettings'] = {
          'path': '/h2',
          'host': ['front.example'],
        };
      final httpProxy = _proxy(
        _convert({
          'outbounds': [http],
        }),
        'http-node',
      );
      expect(httpProxy['network'], 'h2');
      expect(httpProxy['h2-opts'], {
        'path': '/h2',
        'host': ['front.example'],
      });
    });

    test('drops an invalid xhttp session-length and records the loss', () {
      final raw = _vless('edge-a', 0);
      final stream = raw['streamSettings']! as Map<String, Object?>;
      stream['network'] = 'xhttp';
      stream['xhttpSettings'] = {
        'path': '/x',
        'sessionIDTable': 'a',
        'sessionIDLength': '2147483647',
      };
      final result = tryConvertXrayConfigValue({
        'outbounds': [raw],
      });
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      final proxy = _proxy(loadYaml(result.config) as YamlMap, 'edge-a');
      final opts = proxy['xhttp-opts'] as YamlMap;
      expect(opts.containsKey('session-table'), isFalse);
      expect(opts.containsKey('session-length'), isFalse);
    });

    test('reports an invalid VLESS flow instead of emitting it', () {
      final raw = _vless('edge-flow', 0);
      final users = _vlessUsers(raw);
      users['flow'] = 'short';
      final result = tryConvertXrayConfigValue({
        'outbounds': [raw],
      });
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      final proxy = _proxy(loadYaml(result.config) as YamlMap, 'edge-flow');
      expect(proxy.containsKey('flow'), isFalse);
    });

    test('reports an invalid VLESS encryption instead of dropping it', () {
      final raw = _vless('edge-encryption', 1);
      final users = _vlessUsers(raw);
      users['encryption'] = 'not-a-known-scheme';
      final result = tryConvertXrayConfigValue({
        'outbounds': [raw],
      });
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      final proxy = _proxy(
        loadYaml(result.config) as YamlMap,
        'edge-encryption',
      );
      expect(proxy.containsKey('encryption'), isFalse);
    });

    test('maps stream finalmask on VLESS and Trojan only', () {
      final raw = _vless('edge-a', 0);
      (raw['streamSettings']! as Map<String, Object?>)['finalmask'] = {
        'tcp': [
          {
            'type': 'fragment',
            'settings': {'packets': 'tlshello'},
          },
        ],
      };
      final proxy = _proxy(
        _convert({
          'outbounds': [raw],
        }),
        'edge-a',
      );
      expect(proxy['finalmask'], {
        'tcp': [
          {
            'type': 'fragment',
            'settings': {'packets': 'tlshello'},
          },
        ],
      });
    });

    test('drops finalmask UDP masks that Core cannot use on TCP', () {
      final raw = _vless('edge-a', 0);
      (raw['streamSettings']! as Map<String, Object?>)['finalmask'] = {
        'tcp': [
          {
            'type': 'fragment',
            'settings': {'packets': 'tlshello'},
          },
        ],
        'udp': [
          {'type': 'noise', 'settings': {}},
        ],
      };
      final result = tryConvertXrayConfigValue({
        'outbounds': [raw],
      });
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      final proxy = _proxy(loadYaml(result.config) as YamlMap, 'edge-a');
      final mask = proxy['finalmask'] as YamlMap;
      expect(mask.containsKey('udp'), isFalse);
      expect(mask.containsKey('tcp'), isTrue);
    });

    test('keeps TLS HTTP header, WS headers and source rules', () {
      final raw = _vless('edge-a', 0);
      (raw['streamSettings']! as Map<String, Object?>)
        ..['network'] = 'tcp'
        ..['tcpSettings'] = {
          'header': {
            'type': 'http',
            'request': {
              'method': 'POST',
              'path': ['/upload'],
              'headers': {
                'Host': ['front.example'],
              },
            },
          },
        };
      final doc = _convert({
        'outbounds': [raw],
        'routing': {
          'rules': [
            {
              'type': 'field',
              'source': ['10.0.0.0/8'],
              'sourcePort': '53',
              'outboundTag': 'direct',
            },
          ],
        },
      });
      final proxy = _proxy(doc, 'edge-a');
      expect(proxy['network'], 'http');
      expect(proxy['http-opts'], {
        'method': 'POST',
        'path': ['/upload'],
        'headers': {
          'Host': ['front.example'],
        },
      });
      expect(doc['rules'], [
        'AND,((SRC-IP-CIDR,10.0.0.0/8),(SRC-PORT,53)),DIRECT',
        'MATCH,PROXY',
      ]);
    });

    test('uses TLS serverName as the WS Host and reads rawSettings', () {
      final ws = _vless('ws-node', 0);
      final wsStream = ws['streamSettings']! as Map<String, Object?>;
      wsStream
        ..['network'] = 'ws'
        ..['security'] = 'tls'
        ..remove('realitySettings')
        ..['tlsSettings'] = {'serverName': 'front.example'}
        ..['wsSettings'] = {'path': '/ws'};
      final wsProxy = _proxy(
        _convert({
          'outbounds': [ws],
        }),
        'ws-node',
      );
      expect((wsProxy['ws-opts'] as YamlMap)['headers'], {
        'Host': 'front.example',
      });

      final raw = _vless('raw-node', 1);
      final rawStream = raw['streamSettings']! as Map<String, Object?>;
      rawStream
        ..['network'] = 'raw'
        ..['security'] = 'tls'
        ..remove('realitySettings')
        ..['tlsSettings'] = {'serverName': 'raw.example'}
        ..['rawSettings'] = {
          'header': {
            'type': 'http',
            'request': {
              'path': ['/raw'],
              'headers': {
                'Host': ['front.example'],
              },
            },
          },
        };
      final rawProxy = _proxy(
        _convert({
          'outbounds': [raw],
        }),
        'raw-node',
      );
      expect(rawProxy['network'], 'http');
      expect((rawProxy['http-opts'] as YamlMap)['path'], ['/raw']);
    });

    test('keeps settings-level WireGuard reserved bytes', () {
      final proxy = _proxy(
        _convert({
          'outbounds': [
            {
              'tag': 'wg',
              'protocol': 'wireguard',
              'settings': {
                'secretKey': 'secret',
                'address': ['10.0.0.2/32'],
                'reserved': [0, 0, 0],
                'peers': [
                  {'publicKey': 'public', 'endpoint': 'engage.example:2408'},
                ],
              },
            },
          ],
        }),
        'wg',
      );
      final peer = (proxy['peers'] as YamlList).single as YamlMap;
      expect(peer['reserved'], [0, 0, 0]);
    });

    test('handles negative Xray mux concurrency', () {
      final off = _vless('mux-off', 0);
      _vlessUsers(off).remove('flow');
      off['mux'] = {'enabled': true, 'concurrency': -1};
      expect(
        _proxy(
          _convert({
            'outbounds': [off],
          }),
          'mux-off',
        ).containsKey('mux.cool'),
        isFalse,
      );

      final udpOff = _vless('mux-udp-off', 1);
      _vlessUsers(udpOff).remove('flow');
      udpOff['mux'] = {'enabled': true, 'xudpConcurrency': -1};
      final result = tryConvertXrayConfigValue({
        'outbounds': [udpOff],
      });
      expect(result, isNotNull);
      expect((result! as LossyConversion).hasOtherLosses, isTrue);
      final proxy = _proxy(loadYaml(result.config) as YamlMap, 'mux-udp-off');
      expect(
        (proxy['mux.cool'] as YamlMap).containsKey('xudp-concurrency'),
        isFalse,
      );
    });

    test('prefers the REALITY password over a stale public key', () {
      final raw = _vless('edge-a', 0);
      final reality =
          ((raw['streamSettings']! as Map<String, Object?>)['realitySettings']!
                as Map<String, Object?>)
            ..['password'] = 'new-key';
      reality['publicKey'] = 'old-key';
      final proxy = _proxy(
        _convert({
          'outbounds': [raw],
        }),
        'edge-a',
      );
      expect((proxy['reality-opts'] as YamlMap)['public-key'], 'new-key');
    });

    test('lets an xhttp extra headers block win over sibling headers', () {
      final raw = _vless('edge-a', 0);
      final stream = raw['streamSettings']! as Map<String, Object?>;
      stream['network'] = 'xhttp';
      stream['xhttpSettings'] = {
        'path': '/x',
        'headers': {'X-Top': '1'},
        'extra': {
          'headers': {'X-Extra': '2'},
        },
      };
      final proxy = _proxy(
        _convert({
          'outbounds': [raw],
        }),
        'edge-a',
      );
      expect((proxy['xhttp-opts'] as YamlMap)['headers'], {'X-Extra': '2'});
    });
  });
}
