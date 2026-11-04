import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/constant.dart' as common;
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/imports/subscription/subscription_links.dart';
import 'package:yaml/yaml.dart';

const _uuid = '11111111-1111-4111-8111-111111111111';
const _vless = 'vless://$_uuid@edge.example:443?security=tls#Edge';

SubscriptionImportResult _import(String input) =>
    convertSubscriptionImport(Uint8List.fromList(utf8.encode(input)));

List<YamlMap> _proxies(SubscriptionImportResult result) =>
    ((loadYaml(utf8.decode(result.bytes)) as YamlMap)['proxies'] as YamlList)
        .cast<YamlMap>();

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
}
