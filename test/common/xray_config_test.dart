import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/skipped_node.dart';
import 'package:reclash/common/xray_config.dart';

String _json(Object? o) => jsonEncode(o);

List<String> _proxiesNames(String config) {
  final match = RegExp(
    r'^  - \{name: "((?:[^"\\]|\\.)*)"',
    multiLine: true,
  );
  return [
    for (final m in match.allMatches(config)) m.group(1)!,
  ];
}

Map<String, Object?> vlessOutbound({
  String tag = 'vless-node',
  String network = 'grpc',
  String security = 'reality',
  Map<String, Object?>? extraStream,
}) =>
    {
      'tag': tag,
      'protocol': 'vless',
      'settings': {
        'vnext': [
          {
            'address': 'v.example.com',
            'port': 443,
            'users': [
              {
                'id': 'cea80e62-16cf-4fc0-8dea-b8c407e06199',
                'encryption': 'none',
                'flow': 'xtls-rprx-vision',
              }
            ],
          }
        ],
      },
      'streamSettings': {
        'network': network,
        'security': security,
        if (security == 'reality')
          'realitySettings': {
            'publicKey': 'PUBKEY',
            'shortId': 'e6c87ce',
            'serverName': 'www.amd.com',
            'fingerprint': 'firefox',
          },
        if (security == 'tls')
          'tlsSettings': {
            'serverName': 'tls.example.com',
            'alpn': ['h2', 'http/1.1'],
            'fingerprint': 'chrome',
          },
        ...?extraStream,
      },
    };

void main() {
  group('isXrayConfigInput', () {
    test('accepts an object with outbounds', () {
      expect(isXrayConfigInput(_json({'outbounds': [{}]})), isTrue);
    });

    test('accepts an array of configs', () {
      expect(
        isXrayConfigInput(_json([
          {'outbounds': [{}]}
        ])),
        isTrue,
      );
    });

    test('rejects links, yaml and other json', () {
      expect(isXrayConfigInput('vless://u@h:1#n'), isFalse);
      expect(isXrayConfigInput('proxies: []'), isFalse);
      expect(isXrayConfigInput(_json({'a': 1})), isFalse);
      expect(isXrayConfigInput(''), isFalse);
    });
  });

  group('tryConvertXrayConfig', () {
    test('vless reality grpc outbound', () {
      final XrayConfigResult? result = tryConvertXrayConfig(_json({
        'outbounds': [vlessOutbound()],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "vless"'));
      expect(config, contains('uuid: "cea80e62-16cf-4fc0-8dea-b8c407e06199"'));
      expect(config, contains('flow: "xtls-rprx-vision"'));
      expect(config, contains('tls: true'));
      expect(config, contains('servername: "www.amd.com"'));
      expect(config, contains('network: "grpc"'));
      expect(config, contains('public-key: "PUBKEY"'));
      expect(config, contains('short-id: "e6c87ce"'));
      // Without client-fingerprint mihomo sends a plain Go-TLS ClientHello;
      // a reality server masks as its cover site and the node just times
      // out. The fingerprint lives in realitySettings, not tlsSettings.
      expect(config, contains('client-fingerprint: "firefox"'));
    });

    test('grpc with serviceName maps grpc-opts', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          vlessOutbound(
            extraStream: {'grpcSettings': {'serviceName': 'gunsvc'}},
          ),
        ],
      }));
      expect(result, isNotNull);
      expect(result!.config, contains('grpc-service-name: "gunsvc"'));
    });

    test('vmess ws outbound', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          {
            'tag': 'vm',
            'protocol': 'vmess',
            'settings': {
              'vnext': [
                {
                  'address': 'vm.example.com',
                  'port': 443,
                  'users': [
                    {'id': '11223344-5566-7788-9900-aabbccddeeff', 'alterId': 0}
                  ],
                }
              ],
            },
            'streamSettings': {
              'network': 'ws',
              'security': 'tls',
              'wsSettings': {
                'path': '/ws',
                'headers': {'Host': 'cdn.example.com'},
              },
            },
          }
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "vmess"'));
      expect(config, contains('cipher: "auto"'));
      expect(config, contains('network: "ws"'));
      expect(config, contains('path: "/ws"'));
      expect(config, contains('Host: "cdn.example.com"'));
    });

    test('trojan and shadowsocks outbounds', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          {
            'tag': 'tj',
            'protocol': 'trojan',
            'settings': {
              'servers': [
                {'address': 't.example.com', 'port': 443, 'password': 'pw'}
              ]
            },
          },
          {
            'tag': 'ss',
            'protocol': 'shadowsocks',
            'settings': {
              'servers': [
                {
                  'address': 's.example.com',
                  'port': 8388,
                  'method': 'aes-128-gcm',
                  'password': 'ssp',
                }
              ]
            },
          },
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['tj', 'ss']);
      expect(result.config, contains('type: "trojan"'));
      expect(result.config, contains('password: "pw"'));
      expect(result.config, contains('type: "ss"'));
      expect(result.config, contains('cipher: "aes-128-gcm"'));
    });

    test('array of configs with remarks names and internal outbounds skipped',
        () {
      final result = tryConvertXrayConfig(_json([
        {
          'remarks': '🇩🇪 Germany',
          'outbounds': [
            vlessOutbound(tag: ''),
            {'tag': 'direct', 'protocol': 'freedom'},
            {'tag': 'block', 'protocol': 'blackhole'},
          ],
        },
        {
          'remarks': '🇵🇱 Poland',
          'outbounds': [
            vlessOutbound(
              tag: '',
              extraStream: {'grpcSettings': {'serviceName': 'plsvc'}},
            ),
          ],
        },
      ]));
      expect(result, isNotNull);
      // Empty tags fall back to config remarks; duplicates get numbered.
      expect(_proxiesNames(result!.config), ['🇩🇪 Germany', '🇵🇱 Poland']);
      // freedom/blackhole never appear.
      expect(result.config, isNot(contains('freedom')));
      expect(result.config, isNot(contains('blackhole')));
    });

    test('a malformed amneziawg server skips alone, siblings still load', () {
      final result = tryConvertXrayConfig(_json([
        {
          'remarks': 'proxy node',
          'outbounds': [vlessOutbound(tag: '')],
        },
        {
          'type': 'amneziawg',
          'servers': [
            {'name': 'awg', 'config': 'AAECAwQF'}
          ],
        },
      ]));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['proxy node']);
      expect(result.config, isNot(contains('wireguard')));
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.name, 'awg');
      expect(result.skipped.single.kind, 'amneziawg');
      expect(result.skipped.single.reason, SkippedNodeReason.protocol);
    });

    test('unknown protocols are skipped with their protocol as the kind, '
        'service outbounds stay silent', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          {
            'tag': 'ssh-node',
            'protocol': 'ssh',
            'settings': {'servers': []},
          },
          {
            'tag': 'freedom',
            'protocol': 'freedom',
            'settings': {},
          },
          {
            'tag': 'dns',
            'protocol': 'dns',
          },
        ],
      }));
      expect(result, isNull);
      // With a surviving sibling the skipped list tells the story.
      final mixed = tryConvertXrayConfig(_json({
        'outbounds': [
          vlessOutbound(tag: 'keep'),
          {
            'tag': 'ssh-node',
            'protocol': 'ssh',
            'settings': {'servers': []},
          },
          {'tag': 'bypass', 'protocol': 'freedom'},
          {'tag': 'reject', 'protocol': 'blackhole'},
        ],
      }));
      expect(mixed, isNotNull);
      expect(_proxiesNames(mixed!.config), ['keep']);
      expect(mixed.skipped, hasLength(1));
      expect(mixed.skipped.single.kind, 'ssh');
      expect(mixed.skipped.single.name, 'ssh-node');
      expect(mixed.skipped.single.reason, SkippedNodeReason.protocol);
    });

    test('vless xhttp transport maps, trojan xhttp drops', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          vlessOutbound(
            tag: 'keep',
            network: 'xhttp',
            extraStream: {
              'xhttpSettings': {'path': '/x', 'host': 'h.example.com'},
            },
          ),
          {
            'tag': 'drop',
            'protocol': 'trojan',
            'settings': {
              'servers': [
                {'address': 't.example.com', 'port': 443, 'password': 'p'}
              ]
            },
            'streamSettings': {
              'network': 'xhttp',
              'security': 'tls',
              'xhttpSettings': {'path': '/x'},
            },
          },
        ],
      }));
      expect(result, isNotNull);
      // mihomo dials xhttp for vless only; the trojan node is dropped.
      expect(_proxiesNames(result!.config), ['keep']);
      expect(result.config, contains('network: "xhttp"'));
      expect(result.config, contains('path: "/x"'));
      expect(result.config, contains('host: "h.example.com"'));
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.name, 'drop');
      expect(result.skipped.single.kind, 'xhttp');
      expect(result.skipped.single.reason, SkippedNodeReason.transport);
    });

    test('a trojan xhttp node repeated under generic tags counts once, '
        'named by its server', () {
      // Panels repeat one node per mode-config under generic routing tags;
      // the skipped list must not recreate the 30-nodes-for-11 confusion.
      Map<String, Object?> trojanXhttp(String tag) => {
        'tag': tag,
        'protocol': 'trojan',
        'settings': {
          'servers': [
            {'address': 't.example.com', 'port': 443, 'password': 'p'}
          ]
        },
        'streamSettings': {
          'network': 'xhttp',
          'security': 'tls',
          'xhttpSettings': {'path': '/x'},
        },
      };
      final result = tryConvertXrayConfig(_json([
        {
          'remarks': 'mode A',
          'outbounds': [vlessOutbound(tag: 'keep'), trojanXhttp('proxy')],
        },
        {
          'remarks': 'mode B',
          'outbounds': [trojanXhttp('proxy-2')],
        },
      ]));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['keep']);
      expect(result.skipped, hasLength(1));
      // Generic tags name the role, not the node — the server host does.
      expect(result.skipped.single.name, 't.example.com');
      expect(result.skipped.single.kind, 'xhttp');
    });

    test('xhttp extra opts and xmux map to mihomo xhttp-opts', () {
      // The lazyka BACKUP shape: tuning knobs in xhttpSettings.extra,
      // xmux for connection reuse.
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          vlessOutbound(
            tag: 'backup',
            network: 'xhttp',
            security: 'tls',
            extraStream: {
              'xhttpSettings': {
                'mode': 'packet-up',
                'host': 'msk1.example.com',
                'path': '/session/api',
                'extra': {
                  'mode': 'packet-up',
                  'path': '/session/api',
                  'xmux': {
                    'cMaxReuseTimes': 32,
                    'maxConcurrency': 4,
                    'maxConnections': 0,
                    'hKeepAlivePeriod': 30,
                  },
                  'seqKey': 'chunk_id',
                  'xPaddingKey': 'pid',
                  'seqPlacement': 'query',
                  'xPaddingBytes': '1-4',
                  'sessionIDTable': 'Base62',
                  'sessionIDLength': '12-16',
                  'uplinkHTTPMethod': 'GET',
                  'xPaddingObfsMode': true,
                  'xPaddingPlacement': 'query',
                  'scMaxBufferedPosts': 64,
                },
              },
            },
          ),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('mode: "packet-up"'));
      expect(config, contains('x-padding-bytes: "1-4"'));
      expect(config, contains('x-padding-obfs-mode: true'));
      expect(config, contains('seq-key: "chunk_id"'));
      expect(config, contains('session-table: "Base62"'));
      expect(config, contains('session-length: "12-16"'));
      expect(config, contains('uplink-http-method: "GET"'));
      // scMaxBufferedPosts has no mihomo counterpart — dropped.
      expect(config, isNot(contains('sc-max-buffered-posts')));
      expect(
        config,
        contains(
          'reuse-settings: {max-concurrency: "4", max-connections: "0", '
          'c-max-reuse-times: "32", h-keep-alive-period: 30}',
        ),
      );
    });

    test('session-table below the core room floor falls back to defaults', () {
      String configWith(Map<String, Object?> extra) {
        final result = tryConvertXrayConfig(_json({
          'outbounds': [
            vlessOutbound(
              tag: 't',
              network: 'xhttp',
              security: 'tls',
              extraStream: {
                'xhttpSettings': {
                  'path': '/x',
                  'extra': extra,
                },
              },
            ),
          ],
        }));
        expect(result, isNotNull);
        return result!.config;
      }
      final small = configWith({
        'sessionIDTable': 'hex',
        'sessionIDLength': '16',
      });
      expect(small, isNot(contains('session-table')));
      expect(small, isNot(contains('session-length')));
      final custom = configWith({
        'sessionIDTable': '0123456789abcdef',
      });
      expect(custom, contains('session-table: "0123456789abcdef"'));
      final predefined = configWith({
        'sessionIDTable': 'alphabet',
        'sessionIDLength': '11-13',
      });
      expect(predefined, contains('session-table: "alphabet"'));
      expect(predefined, contains('session-length: "11-13"'));
      final uuid = configWith({'sessionIDTable': 'uuid'});
      expect(uuid, contains('session-table: "uuid"'));
    });

    test('xhttp headers and uplink data keys map, non-string headers dropped',
        () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          vlessOutbound(
            tag: 'hdr',
            network: 'xhttp',
            security: 'tls',
            extraStream: {
              'xhttpSettings': {
                'extra': {
                  'headers': {
                    'User-Agent': 'Go-http-client/1.1',
                    'X-Empty': '',
                    'X-Count': 5,
                  },
                  'xPaddingHeader': 'Referer',
                  'uplinkDataPlacement': 'query',
                  'uplinkDataKey': 'upkey',
                  'uplinkChunkSize': '2-4',
                  'xmux': {'hMaxRequestTimes': 600, 'hMaxReusableSecs': 180},
                },
              },
            },
          ),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('headers: {User-Agent: "Go-http-client/1.1"}'));
      expect(config, contains('x-padding-header: "Referer"'));
      expect(config, contains('uplink-data-placement: "query"'));
      expect(config, contains('uplink-data-key: "upkey"'));
      expect(config, contains('uplink-chunk-size: "2-4"'));
      expect(config, contains('h-max-request-times: "600"'));
      expect(config, contains('h-max-reusable-secs: "180"'));
    });

    test('httpupgrade and h2 transports map', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          {
            'tag': 'up',
            'protocol': 'trojan',
            'settings': {
              'servers': [
                {'address': 'u.example.com', 'port': 443, 'password': 'p'}
              ]
            },
            'streamSettings': {
              'network': 'httpupgrade',
              'security': 'tls',
              'httpupgradeSettings': {'path': '/up', 'host': 'u.example.com'},
            },
          },
          {
            'tag': 'h2n',
            'protocol': 'trojan',
            'settings': {
              'servers': [
                {'address': 'h.example.com', 'port': 443, 'password': 'p'}
              ]
            },
            'streamSettings': {
              'network': 'h2',
              'security': 'tls',
              'h2Settings': {'path': '/h2', 'host': ['h.example.com']},
            },
          },
        ],
      }));
      expect(result, isNotNull);
      // mihomo has no httpupgrade network: ws + the v2ray-http-upgrade flag.
      expect(result!.config, contains('network: "ws"'));
      expect(result.config, contains('v2ray-http-upgrade: true'));
      expect(result.config, contains('path: "/up"'));
      expect(result.config, contains('Host: "u.example.com"'));
      expect(result.config, contains('network: "h2"'));
    });

    test('wireguard outbound maps with peer', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          {
            'tag': 'wg',
            'protocol': 'wireguard',
            'settings': {
              'secretKey': 'PRIVATEKEY',
              'address': ['10.0.0.2/32'],
              'peers': [
                {'publicKey': 'PUBKEY', 'endpoint': 'wg.example.com:51820'}
              ],
            },
          }
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "wireguard"'));
      expect(config, contains('private-key: "PRIVATEKEY"'));
      expect(config, contains('ip: "10.0.0.2/32"'));
      expect(config, contains('public-key: "PUBKEY"'));
      expect(config, contains('server: "wg.example.com"'));
      expect(config, contains('port: 51820'));
    });

    test('http and socks dialer outbounds map with users', () {
      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          {
            'tag': 'h',
            'protocol': 'http',
            'settings': {
              'servers': [
                {
                  'address': 'p.example.com',
                  'port': 8080,
                  'users': [{'user': 'u', 'pass': 'p'}],
                }
              ]
            },
          },
          {
            'tag': 's',
            'protocol': 'socks',
            'settings': {
              'servers': [
                {
                  'address': 'p2.example.com',
                  'port': 1080,
                  'users': [{'user': 'u2', 'pass': 'p2'}],
                }
              ]
            },
          },
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['h', 's']);
      expect(result.config, contains('type: "http"'));
      expect(result.config, contains('type: "socks5"'));
      expect(result.config, contains('username: "u"'));
    });

    test('a node under several routing tags imports once, best name wins',
        () {
      // The lazeyka shape: an array of mode-configs where the same
      // server+uuid carries routing-role tags (proxy, GEMINI, PRIMARY).
      final result = tryConvertXrayConfig(_json([
        {
          'remarks': '🧠 Умный режим',
          'outbounds': [
            vlessOutbound(tag: 'proxy'),
            vlessOutbound(tag: 'GEMINI'),
            vlessOutbound(
              tag: 'OTHER',
              extraStream: {'grpcSettings': {'serviceName': 'svc2'}},
            ),
          ],
        },
        {
          'remarks': '📋 Авто LTE',
          'outbounds': [vlessOutbound(tag: 'PRIMARY')],
        },
      ]));
      expect(result, isNotNull);
      // proxy/GEMINI/PRIMARY are one node — GEMINI is the first
      // non-generic tag; a different streamSettings makes a distinct node.
      expect(_proxiesNames(result!.config), ['GEMINI', 'OTHER']);
    });

    test('a node whose every tag is generic takes the server host', () {
      final result = tryConvertXrayConfig(_json([
        {
          'remarks': 'mode',
          'outbounds': [vlessOutbound(tag: 'proxy-2')],
        },
        {
          'remarks': 'mode',
          'outbounds': [vlessOutbound(tag: 'PRIMARY-4')],
        },
      ]));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['v.example.com']);
    });

    test('same server but different uuid stays two nodes', () {
      Map<String, Object?> vlessWithId(String tag, String id) {
        final outbound = vlessOutbound(tag: tag);
        final settings = outbound['settings']! as Map<String, Object?>;
        final vnext = settings['vnext']! as List<Object?>;
        final first = vnext.first! as Map<String, Object?>;
        final users = first['users']! as List<Object?>;
        final user = users.first! as Map<String, Object?>;
        user['id'] = id;
        return outbound;
      }

      final result = tryConvertXrayConfig(_json({
        'outbounds': [
          vlessWithId('one', '00000000-0000-0000-0000-000000000000'),
          vlessWithId('second', 'cea80e62-16cf-4fc0-8dea-b8c407e06199'),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['one', 'second']);
    });

    test('only internals / empty input returns null', () {
      expect(
        tryConvertXrayConfig(
            _json({'outbounds': [{'protocol': 'freedom'}]})),
        isNull,
      );
      expect(tryConvertXrayConfig(_json({'outbounds': []})), isNull);
      expect(tryConvertXrayConfig('not json'), isNull);
    });
  });
}
