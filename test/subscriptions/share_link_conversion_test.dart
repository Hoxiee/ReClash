import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/imports/subscription/subscription_links.dart';
import 'package:yaml/yaml.dart';

const _uuid = '11111111-1111-4111-8111-111111111111';

String _description(String text) => base64.encode(utf8.encode(text));

List<YamlMap> _convert(List<String> links) {
  final result = tryConvertShareLinks(links.join('\n'));
  expect(result, isNotNull);
  final doc = loadYaml(result!.config) as YamlMap;
  return (doc['proxies'] as YamlList).cast<YamlMap>();
}

YamlMap _one(String link) => _convert([link]).single;

void main() {
  group('Happ extended names', () {
    test('strips serverDescription from fragments', () {
      final description = Uri.encodeComponent(_description('Fast route'));
      final german = Uri.encodeComponent('🇩🇪 Германия');
      final proxies = _convert([
        'vless://$_uuid@de1.example:443?security=tls#$german?serverDescription=$description',
        'trojan://pw@nl1.example:443#Nederland?serverDescription=${_description('x')}',
        'ss://YWVzLTI1Ni1nY206cGFzcw==@fi1.example:8388#Finland',
      ]);
      expect(proxies.map((proxy) => proxy['name']), [
        '🇩🇪 Германия',
        'Nederland',
        'Finland',
      ]);
    });

    test('strips resolve-address, host and insecure extras together', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?security=tls#Front'
        '?resolve-address=visa.com&host=front.example&insecure=1',
      );
      expect(proxy['name'], 'Front');
    });

    test('keeps names whose query tail is not a known extension', () {
      expect(
        _one('vless://$_uuid@edge.example:443#Why%3F%20not')['name'],
        'Why? not',
      );
      expect(
        _one('vless://$_uuid@edge.example:443#Name%3Ffoo%3Dbar')['name'],
        'Name?foo=bar',
      );
      expect(
        _one(
          'vless://$_uuid@edge.example:443#Name%3FserverDescription%3Dx%26foo%3Dy',
        )['name'],
        'Name?serverDescription=x&foo=y',
      );
    });

    test('strips the tail from skipped link names', () {
      final result = tryConvertShareLinks(
        'vless://$_uuid@edge.example:443#Ok\n'
        'hysteria://bad.example:443?auth=x#Bad?serverDescription=eA==',
      );
      expect(result!.skipped.single.name, 'Bad');
    });
  });

  group('Incy and Happ advanced parameters', () {
    test('maps REALITY pins, ECH, fragments and finalmask', () {
      final fm = Uri.encodeComponent(
        jsonEncode({
          'tcp': [
            {'type': 'fragment', 'packets': 'tlshello', 'length': '10-20'},
          ],
        }),
      );
      final result = tryConvertShareLinks(
        'vless://$_uuid@edge.example:443?security=reality'
        '&pbk=key&sid=ab&pqv=mldsa&pcs=AA%3ABB'
        '&vcn=front.example&ech=${Uri.encodeComponent('udp://1.1.1.1')}'
        '&fragmentPackets=tlshello&fragmentLength=10-20'
        '&fragmentInterval=5-10&fm=$fm&spx=%2F#Edge',
      );
      expect(result, isNotNull);
      expect(result!.hasOtherLosses, isTrue);
      final proxy = (loadYaml(result.config) as YamlMap)['proxies'] as YamlList;
      final node = proxy.single as YamlMap;
      expect(node['fingerprint'], 'AA:BB');
      expect(node['name-cert-verify'], 'front.example');
      expect(node['ech-opts'], {
        'enable': true,
        'query-server': 'udp://1.1.1.1',
      });
      expect(node['fragment-opts'], {
        'packets': 'tlshello',
        'length': '10-20',
        'interval': '5-10',
      });
      final reality = node['reality-opts'] as YamlMap;
      expect(reality['public-key'], 'key');
      expect(reality['short-id'], 'ab');
      expect(reality['mldsa65-verify'], 'mldsa');
      expect(node['finalmask'], isA<YamlMap>());
    });

    test('maps Trojan REALITY and certificate verification', () {
      final proxy = _one(
        'trojan://pw@edge.example:443?security=reality&pbk=key&sid=ab'
        '&pqv=mldsa&sni=front.example&vcn=front.example&pcs=AA%3ABB#T',
      );
      expect(proxy['tls'], isTrue);
      expect(proxy['sni'], 'front.example');
      expect(proxy['fingerprint'], 'AA:BB');
      expect(proxy['name-cert-verify'], 'front.example');
      final reality = proxy['reality-opts'] as YamlMap;
      expect(reality['public-key'], 'key');
      expect(reality['short-id'], 'ab');
      expect(reality['mldsa65-verify'], 'mldsa');
    });

    test('maps XHTTP session parameters into extra', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?type=xhttp&sit=uuid'
        '&sil=16-32&path=%2Fx&host=front.example#X',
      );
      final options = proxy['xhttp-opts'] as YamlMap;
      expect(options['path'], '/x');
      expect(options['host'], 'front.example');
      expect(options['session-table'], 'uuid');
      expect(options['session-length'], '16-32');
    });

    test('maps the legacy Happ fragment tuple', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?security=tls'
        '&fragment=10-20,5-10,tlshello,3-6#F',
      );
      expect(proxy['fragment-opts'], {
        'packets': 'tlshello',
        'length': '10-20',
        'interval': '5-10',
        'max-split': '3-6',
      });
    });

    test('accepts Hysteria2 port and hop aliases', () {
      final proxy = _one(
        'hysteria2://pw@edge.example:443?mport=443,5000-5010'
        '&mportHopInt=30&sni=front.example#H',
      );
      expect(proxy['ports'], '443,5000-5010');
      expect(proxy['hop-interval'], 30);
    });
  });

  group('TLS fingerprints', () {
    test('defaults a missing fp to chrome on TLS', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?security=tls&sni=a.example#a',
      );
      expect(proxy['client-fingerprint'], 'chrome');
    });

    test('adds the hybrid key share to chrome REALITY links', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?security=reality&pbk=key&sid=ab'
        '&sni=a.example&flow=xtls-rprx-vision#a',
      );
      expect(proxy['client-fingerprint'], 'chrome');
      final reality = proxy['reality-opts'] as YamlMap;
      expect(reality['public-key'], 'key');
      expect(reality['support-x25519mlkem768'], isTrue);
    });

    test('keeps other known fingerprints without the key share', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?security=reality&pbk=key&fp=safari#a',
      );
      expect(proxy['client-fingerprint'], 'safari');
      expect(
        (proxy['reality-opts'] as YamlMap).containsKey(
          'support-x25519mlkem768',
        ),
        isFalse,
      );
    });

    test('omits unsafe on TLS and maps unknown names to chrome', () {
      expect(
        _one(
          'vless://$_uuid@edge.example:443?security=tls&fp=unsafe#a',
        ).containsKey('client-fingerprint'),
        isFalse,
      );
      expect(
        _one(
          'vless://$_uuid@edge.example:443?security=tls&fp=bogus#a',
        )['client-fingerprint'],
        'chrome',
      );
    });

    test('does not invent a fingerprint without TLS', () {
      final proxy = _one('vless://$_uuid@edge.example:80?security=none#a');
      expect(proxy.containsKey('client-fingerprint'), isFalse);
    });

    test('defaults trojan and TLS vmess links to chrome', () {
      expect(
        _one(
          'trojan://pw@edge.example:443?sni=a.example#t',
        )['client-fingerprint'],
        'chrome',
      );
      final vmess = base64.encode(
        utf8.encode(
          jsonEncode({
            'v': '2',
            'ps': 'vm',
            'add': 'edge.example',
            'port': '443',
            'id': _uuid,
            'net': 'tcp',
            'tls': 'tls',
          }),
        ),
      );
      expect(_one('vmess://$vmess')['client-fingerprint'], 'chrome');
    });
  });
}
