import 'dart:convert';
import 'dart:io' show ZLibEncoder;
import 'dart:typed_data' show ByteData;

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/amnezia_config.dart';
import 'package:reclash/common/skipped_node.dart';
import 'package:reclash/common/subscription_links.dart';
import 'package:reclash/common/xray_config.dart';

const _privateKey = '6FYeSwQ3LHkaHK7XR/yM4CBrLr46tr6d4lSCBdOJvlw=';
const _publicKey = '2RbYMI7eFt4OEEnHfil3Idn4HmRmc3hBQvR1ysYzQWc=';

const _v1Conf = '''
# Name = awg-node
[Interface]
PrivateKey = $_privateKey
Address = 10.8.0.2/32, fd00::2/128
DNS = 1.1.1.1, 8.8.8.8
MTU = 1280
Jc = 4
Jmin = 40
Jmax = 70
S1 = 86
S2 = 574
H1 = 1234567890
I1 = 96521

[Peer]
PublicKey = $_publicKey
PresharedKey = FpCyjIcAwSgZRZpxSa7piP4cNT0AGHliS5eQ5jbbNnc=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = wg.example.com:51820
PersistentKeepalive = 25
''';

const _v3Conf = '''
[Device]
Jc = 4
S1 = 12
S2 = 12
H1 = 1234567890
I1 = 96521
HeaderProtectionKey = 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
ContentPaddingAddition = 120-220
RandomTrailers = true
DisableCookies = off

[Interface]
PrivateKey = $_privateKey
Address = 10.8.0.2/32

[Peer]
PublicKey = $_publicKey
Endpoint = v3.example.com:51820
''';

const _plainWgConf = '''
[Interface]
PrivateKey = $_privateKey
Address = 10.8.0.2/32

[Peer]
PublicKey = $_publicKey
AllowedIPs = 10.8.0.0/24
Endpoint = plain.example.com:51820
''';

String _b64url(String text) =>
    base64Url.encode(utf8.encode(text)).replaceAll('=', '');

String _qCompressed(String text) {
  final body = utf8.encode(text);
  final header = ByteData(4)..setUint32(0, body.length);
  return base64Url
      .encode([...header.buffer.asUint8List(), ...ZLibEncoder().convert(body)])
      .replaceAll('=', '');
}

List<String> _proxiesNames(String config) {
  final match = RegExp(
    r'^  - \{name: "((?:[^"\\]|\\.)*)"',
    multiLine: true,
  );
  return [
    for (final m in match.allMatches(config)) m.group(1)!,
  ];
}

void main() {
  group('parseAwgConf', () {
    test('maps v1 fields into a mihomo wireguard proxy', () {
      final proxy = parseAwgConf(_v1Conf);
      expect(proxy, isNotNull);
      expect(proxy!['name'], 'awg-node');
      expect(proxy['type'], 'wireguard');
      expect(proxy['server'], 'wg.example.com');
      expect(proxy['port'], 51820);
      expect(proxy['private-key'], _privateKey);
      expect(proxy['ip'], '10.8.0.2/32');
      expect(proxy['ipv6'], 'fd00::2/128');
      expect(proxy['dns'], ['1.1.1.1', '8.8.8.8']);
      expect(proxy['mtu'], 1280);
      expect(proxy['persistent-keepalive'], 25);
      expect(proxy['udp'], isTrue);
      final peers = proxy['peers']! as List<Map<String, Object?>>;
      expect(peers.single['public-key'], _publicKey);
      expect(peers.single['pre-shared-key'], 'FpCyjIcAwSgZRZpxSa7piP4cNT0AGHliS5eQ5jbbNnc=');
      expect(peers.single['allowed-ips'], ['0.0.0.0/0,::/0']);
      expect(
        proxy['amnezia-wg-option'],
        containsPair('jc', 4),
      );
      final option = proxy['amnezia-wg-option']! as Map<String, Object?>;
      expect(option['jmin'], 40);
      expect(option['jmax'], 70);
      expect(option['s1'], 86);
      expect(option['s2'], 574);
      expect(option['h1'], '1234567890');
      expect(option['i1'], '96521');
      expect(option.containsKey('version'), isFalse);
    });

    test('an explicit name beats the conf comment and the endpoint host', () {
      expect(parseAwgConf(_v1Conf, name: 'Arg')!['name'], 'Arg');
      expect(parseAwgConf(_v1Conf)!['name'], 'awg-node');
      expect(parseAwgConf(_plainWgConf)!['name'], 'plain.example.com');
      const remark = '# my remark\n$_plainWgConf';
      expect(parseAwgConf(remark)!['name'], 'my remark');
    });

    test('v3: [Device] merges, hex key normalizes, v1.5 fields drop', () {
      final proxy = parseAwgConf(_v3Conf);
      expect(proxy, isNotNull);
      final option = proxy!['amnezia-wg-option']! as Map<String, Object?>;
      expect(option['version'], 3);
      expect(option['jc'], 4);
      expect(
        option['header-protection-key'],
        'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=',
      );
      expect(option['content-padding-addition'], '120-220');
      expect(option['random-trailers'], isTrue);
      expect(option['disable-cookies'], isFalse);
      expect(option.containsKey('i1'), isFalse);
      expect(proxy['ip'], '10.8.0.2/32');
    });

    test('plain wireguard conf yields a proxy without amnezia-wg-option', () {
      final proxy = parseAwgConf(_plainWgConf);
      expect(proxy, isNotNull);
      expect(proxy!.containsKey('amnezia-wg-option'), isFalse);
      final peers = proxy['peers']! as List<Map<String, Object?>>;
      expect(peers.single['allowed-ips'], ['10.8.0.0/24']);
    });

    test('hex private and peer keys normalize to base64', () {
      const hex = '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';
      const conf = '''
[Interface]
PrivateKey = $hex

[Peer]
PublicKey = $hex
Endpoint = hex.example.com:51820
''';
      final proxy = parseAwgConf(conf);
      expect(proxy, isNotNull);
      expect(proxy!['private-key'], 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=');
      final peers = proxy['peers']! as List<Map<String, Object?>>;
      expect(peers.single['public-key'], proxy['private-key']);
    });

    test('an empty i1 (Amnezia 2.0 Premium bug) is omitted, not fatal', () {
      final conf = _v1Conf.replaceFirst('I1 = 96521', 'I1 =');
      final proxy = parseAwgConf(conf);
      expect(proxy, isNotNull);
      final option = proxy!['amnezia-wg-option']! as Map<String, Object?>;
      expect(option.containsKey('i1'), isFalse);
      expect(option['jc'], 4);
    });

    test('a keepalive range takes its lower bound', () {
      final conf = _v1Conf.replaceFirst('PersistentKeepalive = 25',
          'PersistentKeepalive = 25-35');
      expect(parseAwgConf(conf)!['persistent-keepalive'], 25);
    });

    test('conf without private key or endpoint is rejected', () {
      expect(parseAwgConf('[Device]\nJc = 4\n'), isNull);
      expect(
        parseAwgConf('[Interface]\nPrivateKey = k\n[Peer]\nPublicKey = p\n'),
        isNull,
      );
      expect(parseAwgConf('not a conf at all'), isNull);
    });
  });

  group('tryConvertWireguardConf', () {
    test('converts a plain conf body', () {
      expect(isWireguardConfInput(_v1Conf), isTrue);
      final result = tryConvertWireguardConf(_v1Conf);
      expect(result, isNotNull);
      expect(result!.config, contains('amnezia-wg-option'));
      expect(result.config, contains('wireguard'));
      expect(result.skipped, isEmpty);
    });

    test('converts a base64-wrapped conf body', () {
      final wrapped = base64.encode(utf8.encode(_v1Conf));
      expect(isWireguardConfInput(wrapped), isTrue);
      expect(tryConvertWireguardConf(wrapped)!.config, contains('awg-node'));
    });

    test('non-conf bodies are not recognized', () {
      expect(isWireguardConfInput('proxies:\n  - name: "x"'), isFalse);
      expect(isWireguardConfInput(''), isFalse);
      expect(tryConvertWireguardConf('hello'), isNull);
    });
  });

  group('tryConvertShareLinks with amnezia links', () {
    test('amneziawg:// and awg:// links convert with fragment names', () {
      final result = tryConvertShareLinks(
        'amneziawg://${_b64url(_v1Conf)}#Germany\n'
        'awg://${_b64url(_v1Conf)}#Netherlands',
      );
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['Germany', 'Netherlands']);
      expect(result.config, contains('amnezia-wg-option'));
      expect(result.skipped, isEmpty);
    });

    test('a link without a fragment falls back to the conf name', () {
      final result = tryConvertShareLinks('amneziawg://${_b64url(_v1Conf)}');
      expect(_proxiesNames(result!.config), ['awg-node']);
    });

    test('amnezia links mix with other protocols in one body', () {
      final result = tryConvertShareLinks(
        'vless://u@h:443#first\namneziawg://${_b64url(_v1Conf)}#second\n'
        'trojan://p@h:443#third',
      );
      expect(_proxiesNames(result!.config), ['first', 'second', 'third']);
    });

    test('an unparsable link body drops that line only', () {
      final result = tryConvertShareLinks(
        'amneziawg://!!!not-base64!!!#broken\nvless://u@h:443#keep',
      );
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['keep']);
      expect(result.skipped, isEmpty);
    });
  });

  group('tryConvertXrayConfig with an INCY container', () {
    test('each server converts; malformed entries skip alone', () {
      final result = tryConvertXrayConfig(jsonEncode({
        'type': 'amneziawg',
        'version': 1,
        'servers': [
          {'name': 'Germany', 'config': _b64url(_v1Conf)},
          {'name': 'Broken', 'config': '%%%'},
          {'config': _b64url(_v1Conf)},
        ],
      }));
      expect(result, isNotNull);
      expect(result!.config, contains('amnezia-wg-option'));
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.name, 'Broken');
      expect(result.skipped.single.kind, 'amneziawg');
    });

    test('identical confs collapse, first named server wins', () {
      final result = tryConvertXrayConfig(jsonEncode({
        'type': 'amneziawg',
        'servers': [
          {'name': 'Germany', 'config': _b64url(_v1Conf)},
          {'name': 'Netherlands', 'config': _b64url(_v1Conf)},
        ],
      }));
      expect(_proxiesNames(result!.config), ['Germany']);
    });

    test('a container sits next to xray configs, order preserved', () {
      final result = tryConvertXrayConfig(jsonEncode([
        {
          'remarks': 'vless node',
          'outbounds': [
            {
              'tag': '',
              'protocol': 'vless',
              'settings': {
                'vnext': [
                  {
                    'address': 'v.example.com',
                    'port': 443,
                    'users': [
                      {'id': 'cea80e62-16cf-4fc0-8dea-b8c407e06199'}
                    ],
                  }
                ],
              },
            },
          ],
        },
        {
          'type': 'amneziawg',
          'servers': [
            {'name': 'awg node', 'config': _b64url(_v1Conf)}
          ],
        },
      ]));
      expect(_proxiesNames(result!.config), ['vless node', 'awg node']);
    });
  });

  group('parseVpnLink', () {
    test('a raw conf payload (3x-ui shape) converts', () {
      final (proxies, skipped) = parseVpnLink(_b64url(_v1Conf));
      expect(proxies, hasLength(1));
      expect(skipped, isEmpty);
      expect(proxies.single['name'], 'awg-node');
      expect(proxies.single['amnezia-wg-option'], isNotNull);
    });

    test('a qCompressed container converts, preferring the native conf', () {
      final share = jsonEncode({
        'description': 'My Amnezia',
        'containers': [
          {
            'container': 'amnezia-awg',
            'amnezia-awg': {
              'last_config': jsonEncode({
                'config': _v1Conf,
                'Jc': '9',
              }),
            },
          },
        ],
      });
      final (proxies, skipped) = parseVpnLink(_qCompressed(share));
      expect(skipped, isEmpty);
      expect(proxies, hasLength(1));
      expect(proxies.single['name'], 'My Amnezia');
      final option = proxies.single['amnezia-wg-option']! as Map<String, Object?>;
      expect(option['jc'], 4);
    });

    test('a container with flat client fields rebuilds a conf', () {
      final share = jsonEncode({
        'containers': [
          {
            'container': 'amnezia-awg',
            'amnezia-awg': {
              'last_config': jsonEncode({
                'Jc': '4',
                'H1': '1234567890',
                'client_priv_key': _privateKey,
                'server_pub_key': _publicKey,
                'psk_key': 'FpCyjIcAwSgZRZpxSa7piP4cNT0AGHliS5eQ5jbbNnc=',
                'hostName': 'flat.example.com',
                'port': 51820,
                'client_ip': '10.8.0.2/32',
              }),
            },
          },
        ],
      });
      final (proxies, skipped) = parseVpnLink(_qCompressed(share));
      expect(skipped, isEmpty);
      expect(proxies, hasLength(1));
      expect(proxies.single['server'], 'flat.example.com');
      expect(proxies.single['ip'], '10.8.0.2/32');
      expect(proxies.single['private-key'], _privateKey);
      final option = proxies.single['amnezia-wg-option']! as Map<String, Object?>;
      expect(option['jc'], 4);
      expect(option['h1'], '1234567890');
    });

    test('non-wireguard containers become named skips', () {
      final share = jsonEncode({
        'containers': [
          {'container': 'openvpn', 'openvpn': {'last_config': '{}'}},
          {'container': 'xray', 'xray': {}},
        ],
      });
      final (proxies, skipped) = parseVpnLink(_qCompressed(share));
      expect(proxies, isEmpty);
      expect(skipped.map((n) => n.kind), ['openvpn', 'xray']);
      expect(
        skipped.every((n) => n.reason == SkippedNodeReason.protocol),
        isTrue,
      );
    });

    test('a vpn:// link line routes through the share-link scanner', () {
      final result = tryConvertShareLinks('vpn://${_b64url(_v1Conf)}');
      expect(result, isNotNull);
      expect(result!.config, contains('awg-node'));
    });

    test('garbage payloads return empty, never throw', () {
      for (final payload in ['', '!!!', _b64url('neither conf nor json')]) {
        final (proxies, skipped) = parseVpnLink(payload);
        expect(proxies, isEmpty, reason: payload);
        expect(skipped, isEmpty, reason: payload);
      }
    });
  });
}
