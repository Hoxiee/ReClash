import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/imports/subscription/subscription_links.dart';
import 'package:yaml/yaml.dart';

const _uuid = '11111111-1111-4111-8111-111111111111';
final _realityKey = base64Url.encode(List.filled(32, 1)).replaceAll('=', '');
final _mldsaKey = base64Url.encode(List.filled(1952, 7)).replaceAll('=', '');

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
        '&pbk=$_realityKey&sid=ab&pqv=$_mldsaKey&pcs=AA%3ABB'
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
        'delay': '5-10',
      });
      final reality = node['reality-opts'] as YamlMap;
      expect(reality['public-key'], _realityKey);
      expect(reality['short-id'], 'ab');
      expect(reality['mldsa65-verify'], _mldsaKey);
      expect(node['finalmask'], isA<YamlMap>());
    });

    test('maps Trojan REALITY and certificate verification', () {
      final proxy = _one(
        'trojan://pw@edge.example:443?security=reality&pbk=$_realityKey&sid=ab'
        '&pqv=$_mldsaKey&sni=front.example&vcn=front.example&pcs=AA%3ABB#T',
      );
      expect(proxy['tls'], isTrue);
      expect(proxy['sni'], 'front.example');
      expect(proxy['fingerprint'], 'AA:BB');
      expect(proxy['name-cert-verify'], 'front.example');
      final reality = proxy['reality-opts'] as YamlMap;
      expect(reality['public-key'], _realityKey);
      expect(reality['short-id'], 'ab');
      expect(reality['mldsa65-verify'], _mldsaKey);
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
        'delay': '5-10',
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
        'vless://$_uuid@edge.example:443?security=reality&pbk=$_realityKey&sid=ab'
        '&sni=a.example&flow=xtls-rprx-vision#a',
      );
      expect(proxy['client-fingerprint'], 'chrome');
      final reality = proxy['reality-opts'] as YamlMap;
      expect(reality['public-key'], _realityKey);
      expect(reality['support-x25519mlkem768'], isTrue);
    });

    test('honors an explicit MLKEM opt-out', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?security=reality&pbk=$_realityKey'
        '&support-x25519mlkem768=false#a',
      );
      final reality = proxy['reality-opts'] as YamlMap;
      expect(reality['support-x25519mlkem768'], isFalse);
    });

    test('skips REALITY links with an unusable key', () {
      final result = tryConvertShareLinks(
        'vless://$_uuid@bad.example:443?security=reality&pbk=not-a-key#bad\n'
        'vless://$_uuid@good.example:443?security=tls#good',
      );
      expect(result, isNotNull);
      expect(result!.hasSecurityLoss, isTrue);
      expect(result.skipped.single.kind, 'reality');
      expect(result.config, isNot(contains('bad.example')));
      expect(result.config, contains('good.example'));
    });

    test('skips REALITY links without a public key', () {
      final result = tryConvertShareLinks(
        'vless://$_uuid@bad.example:443?security=reality&sid=ab#bad\n'
        'vless://$_uuid@good.example:443?security=tls#good',
      );
      expect(result, isNotNull);
      expect(result!.hasSecurityLoss, isTrue);
      expect(result.skipped.single.kind, 'reality');
      expect(result.config, isNot(contains('"public-key": ""')));
    });

    test('skips REALITY links with an unusable short id', () {
      final result = tryConvertShareLinks(
        'vless://$_uuid@bad.example:443?security=reality'
        '&pbk=$_realityKey&sid=zz#bad\n'
        'vless://$_uuid@good.example:443?security=tls#good',
      );
      expect(result, isNotNull);
      expect(result!.hasSecurityLoss, isTrue);
      expect(result.skipped.single.kind, 'reality');
    });

    test('skips a malformed ECH config as a security loss', () {
      final result = tryConvertShareLinks(
        'vless://$_uuid@bad.example:443?security=tls&ech=not-base64#bad\n'
        'vless://$_uuid@good.example:443?security=tls#good',
      );
      expect(result, isNotNull);
      expect(result!.hasSecurityLoss, isTrue);
      expect(result.skipped.single.kind, 'ech');
    });

    test('accepts the legacy VMess TLS flag instead of dropping the node', () {
      final vmess = base64.encode(
        utf8.encode(
          jsonEncode({
            'v': '2',
            'ps': 'vm',
            'add': 'vm.example',
            'port': '443',
            'id': _uuid,
            'net': 'ws',
            'path': '/x',
            'tls': '1',
            'sni': 'cdn.example',
          }),
        ),
      );
      final proxy = _one('vmess://$vmess');
      expect(proxy['tls'], isTrue);
      expect(proxy['servername'], 'cdn.example');
    });

    test('keeps VMess KCP options', () {
      final vmess = base64.encode(
        utf8.encode(
          jsonEncode({
            'v': '2',
            'ps': 'kcp',
            'add': 'kcp.example',
            'port': '443',
            'id': _uuid,
            'net': 'kcp',
            'mtu': '1350',
            'tti': '20',
            'uplinkCapacity': '5',
            'downlinkCapacity': '20',
            'congestion': true,
            'readBufferSize': '1',
            'writeBufferSize': '2',
            'seed': 'seed',
            'type': 'srtp',
          }),
        ),
      );
      final proxy = _one('vmess://$vmess');
      expect(proxy['mkcp-opts'], {
        'mtu': 1350,
        'tti': 20,
        'uplink-capacity': 5,
        'downlink-capacity': 20,
        'congestion': true,
        'read-buffer': 1,
        'write-buffer': 2,
        'seed': 'seed',
        'header': 'srtp',
      });
    });

    test('keeps v2ray-plugin tls=false as no TLS', () {
      final credential = base64.encode(utf8.encode('aes-128-gcm:pw'));
      final plugin = Uri.encodeComponent(
        'v2ray-plugin;tls=false;host=cdn.example',
      );
      final proxy = _one('ss://$credential@ss.example:8388?plugin=$plugin#ss');
      expect((proxy['plugin-opts'] as YamlMap).containsKey('tls'), isFalse);
    });

    test('drops finalmask UDP masks that Core cannot use on TCP', () {
      final fm = Uri.encodeComponent(
        jsonEncode({
          'tcp': [
            {
              'type': 'fragment',
              'settings': {'packets': 'tlshello'},
            },
          ],
          'udp': [
            {'type': 'noise', 'settings': {}},
          ],
        }),
      );
      final result = tryConvertShareLinks(
        'vless://$_uuid@edge.example:443?security=tls&fm=$fm#a',
      );
      expect(result, isNotNull);
      expect(result!.hasOtherLosses, isTrue);
      final node = (loadYaml(result.config) as YamlMap)['proxies'] as YamlList;
      final mask = (node.single as YamlMap)['finalmask'] as YamlMap;
      expect(mask.containsKey('udp'), isFalse);
      expect(mask.containsKey('tcp'), isTrue);
    });

    test('keeps other known fingerprints without the key share', () {
      final proxy = _one(
        'vless://$_uuid@edge.example:443?security=reality&pbk=$_realityKey&fp=safari#a',
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

    test('maps raw and http transports to Core names', () {
      final raw = _one(
        'vless://$_uuid@edge.example:443?security=tls&type=raw#raw',
      );
      expect(raw['network'], 'tcp');

      final http = _one(
        'vless://$_uuid@edge.example:443?security=tls&type=http'
        '&host=front.example&path=/h2#http',
      );
      expect(http['network'], 'h2');
      expect(http['h2-opts'], {
        'path': '/h2',
        'host': ['front.example'],
      });
    });

    test('reports an invalid flow instead of emitting it', () {
      final result = tryConvertShareLinks(
        'vless://$_uuid@edge.example:443?security=tls&flow=short#bad',
      );
      expect(result, isNotNull);
      expect(result!.hasOtherLosses, isTrue);
      final node = (loadYaml(result.config) as YamlMap)['proxies'] as YamlList;
      expect((node.single as YamlMap).containsKey('flow'), isFalse);
    });

    test('skips VMess REALITY instead of silently downgrading it', () {
      final vmess = base64.encode(
        utf8.encode(
          jsonEncode({
            'v': '2',
            'ps': 'vm',
            'add': 'edge.example',
            'port': '443',
            'id': _uuid,
            'net': 'tcp',
            'tls': 'reality',
            'pbk': _realityKey,
          }),
        ),
      );
      final result = tryConvertShareLinks(
        'vless://$_uuid@good.example:443?security=tls#good\n'
        'vmess://$vmess',
      );
      expect(result, isNotNull);
      expect(result!.skipped.single.kind, 'reality');
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
