import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/constant.dart' as common;
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/imports/routing/skipped_node.dart';
import 'package:reclash/subscriptions/imports/subscription/subscription_links.dart';
import 'package:yaml/yaml.dart';

const _uuid = '11111111-1111-4111-8111-111111111111';
const _vless = 'vless://$_uuid@edge.example:443?security=tls#Edge';

SubscriptionImportResult _import(String input) =>
    convertSubscriptionImport(Uint8List.fromList(utf8.encode(input)));

List<YamlMap> _proxies(SubscriptionImportResult result) =>
    ((loadYaml(utf8.decode(result.bytes)) as YamlMap)['proxies'] as YamlList)
        .cast<YamlMap>();

List<int> _varint(int value) {
  if (value < 0x40) return [value];
  if (value < 0x4000) return [0x40 | (value >> 8), value & 0xff];
  return [
    0x80 | (value >> 24),
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];
}

List<int> _tlv(int tag, Object value) {
  final bytes = value is String ? utf8.encode(value) : value as List<int>;
  return [..._varint(tag), ..._varint(bytes.length), ...bytes];
}

String _ttLink(List<List<int>> entries, {String fragment = ''}) =>
    'tt://?${base64Url.encode(entries.expand((e) => e).toList()).replaceAll('=', '')}$fragment';

List<List<int>> _ttBase({List<List<int>> extra = const []}) => [
  _tlv(0, [2]),
  _tlv(1, 'tt.example'),
  _tlv(2, '203.0.113.7:8443'),
  _tlv(5, 'user'),
  _tlv(6, 'pass'),
  _tlv(0x7f, 'unknown'),
  ...extra,
];

void main() {
  test('Xray and URI imports share XHTTP options and loss reporting', () {
    for (final extra in [
      {
        'headers': {'X-Test': 'required'},
        'xPaddingBytes': '100-200',
      },
      {'futureOption': true},
    ]) {
      final uri = _import(
        'vless://$_uuid@edge.example:443?type=xhttp'
        '&extra=${Uri.encodeComponent(jsonEncode(extra))}#Edge',
      );
      final xray = _import(
        jsonEncode({
          'outbounds': [
            {
              'protocol': 'vless',
              'settings': {
                'vnext': [
                  {
                    'address': 'edge.example',
                    'port': 443,
                    'users': [
                      {'id': _uuid},
                    ],
                  },
                ],
              },
              'streamSettings': {
                'network': 'xhttp',
                'xhttpSettings': {'extra': extra},
              },
            },
          ],
        }),
      );
      expect(
        _proxies(xray).single['xhttp-opts'],
        _proxies(uri).single['xhttp-opts'],
      );
      expect(xray.summary.hasOtherLosses, extra.containsKey('futureOption'));
      expect(xray.summary.hasLosses, uri.summary.hasLosses);
      expect(utf8.decode(xray.bytes), isNot(contains('x-import-losses')));
    }
  });

  test('subscription schemes include every direct Core share-link scheme', () {
    expect(shareLinkSchemes, containsAll(common.shareLinkSchemes));
  });

  test('preserves every Mieru endpoint in plain and base64 lists', () {
    const source =
        '$_vless\n'
        'mierus://user:p%40ss@mesh.example?port=443&port=5000-5010'
        '&protocol=TCP&protocol=UDP&profile=Mesh'
        '&multiplexing=MULTIPLEXING_HIGH&handshake-mode=HANDSHAKE_NO_WAIT'
        '&traffic-pattern=pattern';
    for (final input in [source, base64Url.encode(utf8.encode(source))]) {
      final result = _import(input);
      final proxies = _proxies(result);
      expect(result.format, SubscriptionFormat.shareLinks);
      expect(result.summary.nodes, 3);
      expect(result.summary.hasLosses, isFalse);
      expect(proxies[1], containsPair('name', 'Mesh:443/TCP'));
      expect(proxies[1], containsPair('password', 'p@ss'));
      expect(proxies[1], containsPair('port', 443));
      expect(proxies[1], containsPair('multiplexing', 'MULTIPLEXING_HIGH'));
      expect(proxies[1], containsPair('handshake-mode', 'HANDSHAKE_NO_WAIT'));
      expect(proxies[1], containsPair('traffic-pattern', 'pattern'));
      expect(proxies[2], containsPair('port-range', '5000-5010'));
      expect(proxies[2], containsPair('transport', 'UDP'));
    }
  });

  test('retains valid Mieru endpoints and reports invalid ones', () {
    final result = _import(
      'mierus://user:pass@mesh.example?port=443&port=bad'
      '&protocol=TCP&protocol=UDP#Mesh',
    );
    expect(result.summary.nodes, 1);
    expect(result.summary.hasLosses, isTrue);
  });

  test('recognizes uppercase schemes and SOCKS5H credentials', () {
    final auth = base64.encode(utf8.encode('user:pass'));
    final result = _import('SOCKS5H://$auth@proxy.example:1080#Proxy');
    final proxy = _proxies(result).single;
    expect(result.summary.hasLosses, isFalse);
    expect(proxy['type'], 'socks5');
    expect(proxy['username'], 'user');
    expect(proxy['password'], 'pass');
  });

  test('imports a SOCKS5H proxy without authentication', () {
    final result = _import('socks5h://proxy.example:1080#Proxy');
    expect(_proxies(result).single['server'], 'proxy.example');
    expect(result.summary.hasLosses, isFalse);
  });

  test('preserves realm settings, repeated STUN values and default port', () {
    for (final scheme in ['hysteria2+realm', 'hy2+realm']) {
      final result = _import(
        '$scheme://t%40ken@rendezvous.example/room%20one'
        '?auth=p%40ss&stun=stun1:3478&stun=stun2:3478#Realm',
      );
      final proxy = _proxies(result).single;
      expect(result.summary.hasLosses, isFalse);
      expect(proxy['type'], 'hysteria2');
      expect(proxy['port'], 443);
      expect(proxy['password'], 'p@ss');
      expect(proxy['realm-opts'], {
        'enable': true,
        'server-url': 'https://rendezvous.example',
        'token': 't@ken',
        'realm-id': 'room one',
        'stun-servers': ['stun1:3478', 'stun2:3478'],
      });
    }
  });

  test('accepts the Hysteria2 default port and trailing slash', () {
    for (final authority in ['edge.example', 'edge.example:443']) {
      final result = _import('hy2://p%40ss@$authority/#Hy2');
      expect(_proxies(result).single['port'], 443);
      expect(_proxies(result).single['password'], 'p@ss');
    }
  });

  test('reports unknown and malformed nodes in a mixed list', () {
    final result = _import(
      '$_vless\n'
      'future://private-secret@other.example:443#Future\n'
      'vmess://invalid#Broken\n'
      '# a comment',
    );
    expect(result.summary.nodes, 1);
    expect(result.summary.hasLosses, isTrue);
    expect(result.summary.skippedNodes.map((node) => node.name), [
      'Future',
      'Broken',
    ]);
    expect(result.summary.skipped.join(), isNot(contains('private-secret')));
  });

  group('XHTTP extra', () {
    test('preserves headers, ranges, aliases and reuse settings', () {
      final extra = Uri.encodeComponent(
        jsonEncode({
          'headers': {'X-Test': 'required'},
          'xPaddingBytes': '100-200',
          'scMaxEachPostBytes': 2000000,
          'noGRPCHeader': false,
          'sessionPlacement': 'header',
          'sessionKey': 'X-Session',
          'xmux': {'maxConcurrency': '4-8', 'hKeepAlivePeriod': 30},
        }),
      );
      final result = _import(
        'vless://$_uuid@edge.example:443?security=tls&type=xhttp'
        '&path=%2Fendpoint&mode=packet-up&extra=$extra#XHTTP',
      );
      final options = _proxies(result).single['xhttp-opts'] as YamlMap;
      expect(options['path'], '/endpoint');
      expect(options['mode'], 'packet-up');
      expect(options['headers'], {'X-Test': 'required'});
      expect(options['x-padding-bytes'], '100-200');
      expect(options['sc-max-each-post-bytes'].toString(), '2000000');
      expect(options['no-grpc-header'], isFalse);
      expect(options['session-placement'], 'header');
      expect(options['session-key'], 'X-Session');
      expect(options['reuse-settings'], {
        'max-concurrency': '4-8',
        'h-keep-alive-period': 30,
      });
      expect(result.summary.hasLosses, isFalse);
    });

    test('preserves separate download connection settings', () {
      final extra = Uri.encodeComponent(
        jsonEncode({
          'downloadSettings': {
            'address': 'download.example',
            'port': 8443,
            'network': 'xhttp',
            'security': 'tls',
            'tlsSettings': {
              'serverName': 'cdn.example',
              'fingerprint': 'chrome',
              'alpn': ['h2'],
              'allowInsecure': false,
            },
            'xhttpSettings': {
              'path': '/download',
              'host': 'cdn.example',
              'headers': {'X-Download': 'required'},
              'extra': {
                'xmux': {'maxConnections': 2},
              },
            },
          },
        }),
      );
      final result = _import(
        'vless://$_uuid@edge.example:443?type=xhttp&extra=$extra#XHTTP',
      );
      final options = _proxies(result).single['xhttp-opts'] as YamlMap;
      expect(options['download-settings'], {
        'server': 'download.example',
        'port': 8443,
        'tls': true,
        'reality-opts': {'public-key': ''},
        'servername': 'cdn.example',
        'client-fingerprint': 'chrome',
        'alpn': ['h2'],
        'skip-cert-verify': false,
        'path': '/download',
        'host': 'cdn.example',
        'headers': {'X-Download': 'required'},
        'reuse-settings': {'max-connections': '2'},
      });
      expect(result.summary.hasLosses, isFalse);
    });

    test('preserves explicit empty download overrides', () {
      final extra = Uri.encodeComponent(
        jsonEncode({
          'downloadSettings': {
            'security': 'none',
            'xhttpSettings': {
              'path': '',
              'host': '',
              'headers': <String, Object?>{},
            },
          },
        }),
      );
      final result = _import(
        'vless://$_uuid@edge.example:443?security=tls&type=xhttp'
        '&extra=$extra#XHTTP',
      );
      final options = _proxies(result).single['xhttp-opts'] as YamlMap;
      expect(options['download-settings'], {
        'tls': false,
        'reality-opts': {'public-key': ''},
        'path': '',
        'host': '',
        'headers': <String, Object?>{},
      });
      expect(result.summary.hasLosses, isFalse);
    });

    test('reports malformed or unsupported extra settings', () {
      for (final extra in [
        '{',
        '[]',
        'null',
        jsonEncode({'futureOption': true}),
        jsonEncode({
          'xmux': {'futureOption': true},
        }),
      ]) {
        final result = _import(
          'vless://$_uuid@edge.example:443?type=xhttp'
          '&extra=${Uri.encodeComponent(extra)}#XHTTP',
        );
        expect(result.summary.nodes, 1);
        expect(result.summary.hasLosses, isTrue, reason: extra);
        expect(result.summary.hasOtherLosses, isTrue, reason: extra);
      }
    });
  });

  group('share link authority path', () {
    test('ignores a trailing slash before the query', () {
      final result = _import(
        'anytls://secret@edge.example:8443/?sni=edge.example#Any\n'
        'trojan://secret@edge.example:443/path?sni=edge.example#Tro',
      );
      final proxies = _proxies(result);
      expect(proxies, hasLength(2));
      expect(proxies[0]['type'], 'anytls');
      expect(proxies[0]['server'], 'edge.example');
      expect(proxies[0]['port'], 8443);
      expect(proxies[1]['port'], 443);
    });
  });

  group('AmneziaWG links', () {
    test('imports a URI-style link with AWG 2.x fields', () {
      final result = _import(
        'amneziawg://abcKEY%3D@edge.example:51820'
        '?address=10.0.0.2%2F32&dns=1.1.1.1%2C+8.8.8.8&h1=10-20&h2=30-40'
        '&i1=%3Cb+0x1603%3E&jc=6&jmax=50&jmin=10&keepalive=25&mtu=1420'
        '&presharedkey=pskKEY&publickey=pubKEY&s1=57&s2=29#Awg',
      );
      final proxy = _proxies(result).single;
      expect(proxy['name'], 'Awg');
      expect(proxy['type'], 'wireguard');
      expect(proxy['server'], 'edge.example');
      expect(proxy['port'], 51820);
      expect(proxy['private-key'], 'abcKEY=');
      expect(proxy['persistent-keepalive'], 25);
      final option = proxy['amnezia-wg-option'] as YamlMap;
      expect(option['h1'], '10-20');
      expect(option['i1'], '<b 0x1603>');
      expect(option['jc'], 6);
      expect(option['s2'], 29);
    });

    test('drops a link without a host', () {
      final result = _import('amneziawg://key@:51820?address=10.0.0.2');
      expect(result.summary.nodes, 0);
    });
  });

  group('AmneziaVPN vpn:// containers', () {
    test('imports an awg container with last_config fields', () {
      final lastConfig = jsonEncode({
        'H1': '10-20',
        'I1': '<b 0x1603>',
        'Jc': '6',
        'Jmax': '50',
        'Jmin': '10',
        'S1': '57',
        'client_ip': '10.0.0.2/32',
        'client_priv_key': 'privKEY',
        'hostName': 'edge.example',
        'port': 51820,
        'psk_key': 'pskKEY',
        'server_pub_key': 'pubKEY',
      });
      final share = jsonEncode({
        'containers': [
          {
            'container': 'amnezia-awg',
            'awg': {'last_config': lastConfig},
          },
        ],
        'description': 'Edge',
        'hostName': 'edge.example',
      });
      final result = _import(
        'vpn://${base64Url.encode(utf8.encode(share)).replaceAll('=', '')}',
      );
      final proxy = _proxies(result).single;
      expect(proxy['name'], 'Edge');
      expect(proxy['server'], 'edge.example');
      expect(proxy['port'], 51820);
      expect((proxy['amnezia-wg-option'] as YamlMap)['h1'], '10-20');
    });
  });

  group('TrustTunnel links', () {
    test('imports an h2 link', () {
      final result = _import(_ttLink(_ttBase(extra: [_tlv(0x0c, 'Edge 🚀')])));
      expect(result.summary.hasLosses, isFalse);
      expect(_proxies(result).single, {
        'name': 'Edge 🚀',
        'type': 'trusttunnel',
        'server': '203.0.113.7',
        'port': 8443,
        'username': 'user',
        'password': 'pass',
        'udp': true,
        'sni': 'tt.example',
      });
    });

    test('uses HTTP/3, custom SNI and the fragment name', () {
      final result = _import(
        _ttLink([
          ..._ttBase(
            extra: [
              _tlv(3, 'front.example'),
              _tlv(9, [2]),
            ],
          ),
        ], fragment: '#Frag'),
      );
      final proxy = _proxies(result).single;
      expect(proxy['name'], 'Frag');
      expect(proxy['quic'], isTrue);
      expect(proxy['sni'], 'front.example');
    });

    test('falls back to the hostname and port 443', () {
      final proxy = _proxies(
        _import(
          _ttLink([_tlv(1, 'tt.example'), _tlv(5, 'user'), _tlv(6, 'pass')]),
        ),
      ).single;
      expect(proxy['name'], 'tt.example');
      expect(proxy['server'], 'tt.example');
      expect(proxy['port'], 443);
    });

    test('strips IPv6 brackets and reads two-byte varint lengths', () {
      final longName = 'n' * 100;
      final proxy = _proxies(
        _import(
          _ttLink(
            _ttBase(extra: [_tlv(0x0c, longName)])
              ..[2] = _tlv(2, '[2001:db8::1]:443'),
          ),
        ),
      ).single;
      expect(proxy['server'], '2001:db8::1');
      expect(proxy['name'], longName);
    });

    test('honors skip_verification', () {
      final proxy = _proxies(
        _import(
          _ttLink(
            _ttBase(
              extra: [
                _tlv(7, [1]),
              ],
            ),
          ),
        ),
      ).single;
      expect(proxy['skip-cert-verify'], isTrue);
    });

    test('pins the first certificate of the chain', () {
      final first = [0x30, 0x03, 1, 2, 3];
      final result = _import(
        _ttLink(
          _ttBase(
            extra: [
              _tlv(8, [...first, 0x30, 0x01, 9]),
            ],
          ),
        ),
      );
      expect(result.summary.hasLosses, isFalse);
      expect(
        _proxies(result).single['fingerprint'],
        sha256.convert(first).toString(),
      );
    });

    test('reports extra addresses and unsupported obfuscation', () {
      for (final extra in [
        [_tlv(2, '203.0.113.8:8443')],
        [_tlv(0x0b, '548e85a3/ffffffff')],
        [
          _tlv(0x0a, [1]),
        ],
      ]) {
        final result = _import(_ttLink(_ttBase(extra: extra)));
        expect(result.summary.nodes, 1);
        expect(result.summary.hasLosses, isTrue);
      }
    });

    test('skips truncated and credential-less links', () {
      final full = _ttLink(_ttBase());
      for (final link in [
        full.substring(0, full.length - 6),
        _ttLink([_tlv(1, 'tt.example')]),
        'tt://?!!!',
      ]) {
        expect(tryConvertShareLinks(link), isNull);
        expect(probeUnsupportedShareLinks(link), hasLength(1));
      }
    });

    test('imports from a base64 subscription beside other links', () {
      final source = '$_vless\n${_ttLink(_ttBase())}';
      final result = _import(base64.encode(utf8.encode(source)));
      expect(result.summary.nodes, 2);
      expect(_proxies(result)[1]['type'], 'trusttunnel');
    });
  });

  group('extension links', () {
    const flux = 'openflux://v1/q1YqS8xNVbJSUHJLzMlPLskszs9TUkhJTVKqBQA';

    test('imports an OpenFlux line as an extension node', () {
      final result = _import(flux);
      expect(result.summary.nodes, 1);
      expect(result.summary.hasLosses, isFalse);
      expect(_proxies(result).single, {
        'name': 'OpenFlux 1',
        'type': 'extension',
        'extension': 'openflux',
        'link': flux,
      });
    });

    test('names the node from the fragment and matches the scheme loosely', () {
      final proxy = _proxies(_import('OpenFlux://v1/abc#My%20Flux')).single;
      expect(proxy['name'], 'My Flux');
      expect(proxy['link'], 'openflux://v1/abc#My%20Flux');
    });

    test('numbers unnamed lines per extension', () {
      final names = _proxies(
        _import('$flux\n$flux\n'),
      ).map((p) => p['name']).toList();
      expect(names, ['OpenFlux 1', 'OpenFlux 2']);
    });

    test('unknown schemes are still skipped as protocols', () {
      const link = 'qwdtt://v1/abc';
      expect(tryConvertShareLinks(link), isNull);
      final skipped = probeUnsupportedShareLinks(link);
      expect(skipped, hasLength(1));
      expect(skipped.single.reason, SkippedNodeReason.protocol);
    });

    test('keeps native nodes beside extension nodes without skips', () {
      final result = tryConvertShareLinks('$_vless\n$flux')!;
      expect(result.skipped, isEmpty);
      expect(result.hasOtherLosses, isFalse);
      expect(probeUnsupportedShareLinks('$_vless\n$flux'), isEmpty);
      expect(probeUnsupportedShareLinks(flux), isEmpty);
      final types = _proxies(_import('$_vless\n$flux')).map((p) => p['type']);
      expect(types, ['vless', 'extension']);
    });
  });
}
