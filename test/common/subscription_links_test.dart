import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/skipped_node.dart';
import 'package:reclash/common/subscription_links.dart';

List<String> _proxiesNames(String config) {
  final match = RegExp(
    r'^  - \{name: "((?:[^"\\]|\\.)*)"',
    multiLine: true,
  );
  return [
    for (final m in match.allMatches(config)) m.group(1)!,
  ];
}

const _awgConf = '''
[Interface]
PrivateKey = 6FYeSwQ3LHkaHK7XR/yM4CBrLr46tr6d4lSCBdOJvlw=
Address = 10.8.0.2/32
Jc = 4
S1 = 86

[Peer]
PublicKey = 2RbYMI7eFt4OEEnHfil3Idn4HmRmc3hBQvR1ysYzQWc=
Endpoint = wg.example.com:51820
''';

void main() {
  group('isShareLinkInput', () {
    test('accepts each scheme', () {
      for (final scheme in [
        'vmess://',
        'vless://',
        'ss://',
        'trojan://',
        'hysteria2://',
        'hy2://',
        'tuic://',
        'anytls://',
        'hysteria://',
        'socks://',
        'socks5://',
        'wireguard://',
        'wg://',
        'amneziawg://',
        'awg://',
        'vpn://',
      ]) {
        expect(isShareLinkInput('$scheme anything'), isTrue,
            reason: scheme);
      }
    });

    test('rejects urls, yaml and junk', () {
      expect(isShareLinkInput('https://example.com/sub'), isFalse);
      expect(isShareLinkInput('proxies:\n  - name: "x"'), isFalse);
      expect(isShareLinkInput('hello world'), isFalse);
      expect(isShareLinkInput(''), isFalse);
    });

    test('accepts a base64 blob of links', () {
      final blob = base64
          .encode(utf8.encode('vless://a@b:1\nss://c@d:2'));
      expect(isShareLinkInput(blob), isTrue);
    });

    test('rejects base64 of non-links', () {
      expect(isShareLinkInput(base64.encode(utf8.encode('hello'))), isFalse);
    });
  });

  group('tryConvertShareLinks', () {
    test('vmess link becomes a vmess proxy', () {
      final json = jsonEncode({
        'ps': 'Tokyo',
        'add': '1.2.3.4',
        'port': 443,
        'id': 'uuid-1',
        'aid': 0,
        'scy': 'auto',
        'net': 'ws',
        'host': 'cdn.example.com',
        'path': '/ws',
        'tls': 'tls',
        'sni': 'cdn.example.com',
      });
      final result =
          tryConvertShareLinks('vmess://${base64.encode(utf8.encode(json))}');
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['Tokyo']);
      final config = result.config;
      expect(config, contains('type: "vmess"'));
      expect(config, contains('server: "1.2.3.4"'));
      expect(config, contains('port: 443'));
      expect(config, contains('uuid: "uuid-1"'));
      expect(config, contains('network: "ws"'));
      expect(config, contains('path: "/ws"'));
      expect(config, contains('servername: "cdn.example.com"'));
    });

    test('vless reality link', () {
      const link = 'vless://uuid-2@example.com:443'
          '?type=grpc&security=reality&pbk=PUBKEY&sid=abcd&sni=example.com'
          '&fp=chrome&flow=xtls-rprx-vision#Reality%20node';
      final ShareLinksResult? result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['Reality node']);
      final config = result.config;
      expect(config, contains('type: "vless"'));
      expect(config, contains('uuid: "uuid-2"'));
      expect(config, contains('network: "grpc"'));
      expect(config, contains('public-key: "PUBKEY"'));
      expect(config, contains('short-id: "abcd"'));
      expect(config, contains('client-fingerprint: "chrome"'));
      expect(config, contains('flow: "xtls-rprx-vision"'));
    });

    test('ss modern and legacy shapes', () {
      final modern = tryConvertShareLinks(
          'ss://${base64.encode(utf8.encode('aes-128-gcm:pass'))}@1.1.1.1:8388#ss-modern');
      expect(modern, isNotNull);
      expect(modern!.config, contains('cipher: "aes-128-gcm"'));
      expect(modern.config, contains('password: "pass"'));

      final legacy = tryConvertShareLinks(
          'ss://${base64.encode(utf8.encode('aes-128-gcm:pass@1.1.1.1:8388'))}#ss-legacy');
      expect(legacy, isNotNull);
      expect(legacy!.config, contains('server: "1.1.1.1"'));
      expect(legacy.config, contains('port: 8388'));
    });

    test('ss with an unsupported plugin is dropped', () {
      final link =
          'ss://${base64.encode(utf8.encode('aes-128-gcm:pass'))}@1.1.1.1:8388?plugin=trojan-go#x';
      expect(tryConvertShareLinks(link), isNull);
    });

    test('ss with obfs plugin keeps plugin-opts', () {
      final link =
          'ss://${base64.encode(utf8.encode('aes-128-gcm:pass'))}@1.1.1.1:8388'
          '?plugin=obfs-local%3Bobfs%3Dhttp%3Bobfs-host%3Dexample.com#obfs';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('plugin: "obfs"'));
      expect(result.config, contains('mode: "http"'));
      expect(result.config, contains('host: "example.com"'));
    });

    test('trojan link', () {
      const link =
          'trojan://pw@t.example.com:443?sni=t.example.com&allowInsecure=1#Trojan';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('type: "trojan"'));
      expect(result.config, contains('password: "pw"'));
      expect(result.config, contains('sni: "t.example.com"'));
      expect(result.config, contains('skip-cert-verify: true'));
    });

    test('vless xhttp link maps to xhttp-opts', () {
      const link =
          'vless://uuid@x.example.com:443?security=reality&sni=www.amd.com&pbk=PBK&sid=e6c&fp=edge&type=xhttp&path=%2Fxh&host=x.example.com#xhttp-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('network: "xhttp"'));
      expect(result.config, contains('xhttp-opts: {path: "/xh", host: "x.example.com"}'));
    });

    test('splithttp spelling normalises to xhttp', () {
      const link =
          'vless://uuid@x.example.com:443?security=tls&sni=s.example.com&type=splithttp&path=%2Fspl#n';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('network: "xhttp"'));
      expect(result.config, contains('path: "/spl"'));
    });

    test('xhttp on non-vless links is skipped, siblings live', () {
      // mihomo dials xhttp for vless only — trojan/vmess with type=xhttp
      // would silently degrade to TCP and connect nowhere.
      const input = 'trojan://pw@t.example.com:443?type=xhttp&path=%2Fx#dead\n'
          'socks5://u:p@s.example.com:1080#socks';
      final result = tryConvertShareLinks(input);
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['socks']);
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.name, 'dead');
      expect(result.skipped.single.kind, 'xhttp');
      expect(result.skipped.single.reason, SkippedNodeReason.transport);
    });

    test('a vmess link with net=xhttp is skipped as unsupported', () {
      final json = jsonEncode({
        'ps': 'vm-xhttp',
        'add': '1.2.3.4',
        'port': 443,
        'id': 'uuid-x',
        'net': 'xhttp',
      });
      final result =
          tryConvertShareLinks('vmess://${base64.encode(utf8.encode(json))}');
      expect(result, isNull);
    });

    test('a vmess link with net=xhttp survives when a sibling imports', () {
      final json = jsonEncode({
        'ps': 'vm-xhttp',
        'add': '1.2.3.4',
        'port': 443,
        'id': 'uuid-x',
        'net': 'xhttp',
      });
      final blob = 'vmess://${base64.encode(utf8.encode(json))}\n'
          'trojan://p@h:1#keep';
      final result = tryConvertShareLinks(blob);
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['keep']);
      expect(result.skipped.single.name, 'vm-xhttp');
      expect(result.skipped.single.kind, 'xhttp');
      expect(result.skipped.single.reason, SkippedNodeReason.transport);
    });

    test('hysteria2 link', () {
      const link = 'hy2://auth@h.example.com:8443'
          '?sni=h.example.com&insecure=1&obfs=salamander&obfs-password=ob&up=100&down=500#hy2';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('type: "hysteria2"'));
      expect(result.config, contains('password: "auth"'));
      expect(result.config, contains('obfs: "salamander"'));
      expect(result.config, contains('obfs-password: "ob"'));
      expect(result.config, contains('up: "100"'));
    });

    test('ws path with ed= becomes max-early-data, path cleaned', () {
      const link = 'vless://u@h.example.com:443'
          '?security=tls&sni=s.example.com&type=ws&host=cdn.example.com'
          '&path=%2Fws%3Fed%3D2048#ed-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('path: "/ws"'));
      expect(config, contains('max-early-data: 2048'));
      expect(
        config,
        contains('early-data-header-name: "Sec-WebSocket-Protocol"'),
      );
      expect(config, isNot(contains('ed=2048')));
    });

    test('vless httpupgrade maps to ws + v2ray-http-upgrade', () {
      const link = 'vless://u@h.example.com:443'
          '?security=tls&sni=s.example.com&type=httpupgrade&host=cdn.example.com'
          '&path=%2Fup#hu-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('network: "ws"'));
      expect(config, contains('v2ray-http-upgrade: true'));
      expect(config, isNot(contains('v2ray-http-upgrade-fast-open')));
      expect(config, contains('path: "/up"'));
    });

    test('vless httpupgrade with ed= adds fast-open', () {
      const link = 'vless://u@h.example.com:443'
          '?security=tls&sni=s.example.com&type=httpupgrade'
          '&path=%2Fup%3Fed%3D2048#hu-ed-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('v2ray-http-upgrade: true'));
      expect(config, contains('v2ray-http-upgrade-fast-open: true'));
      expect(config, contains('path: "/up"'));
      expect(config, isNot(contains('max-early-data')));
    });

    test('trojan httpupgrade maps to ws + v2ray-http-upgrade', () {
      const link = 'trojan://pw@h.example.com:443'
          '?sni=s.example.com&type=httpupgrade&path=%2Ft&host=h.example.com'
          '#tro-hu';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('network: "ws"'));
      expect(config, contains('v2ray-http-upgrade: true'));
      expect(config, contains('path: "/t"'));
    });

    test('vmess net=httpupgrade maps to ws + v2ray-http-upgrade', () {
      final json = jsonEncode({
        'ps': 'vm-hu',
        'add': '1.2.3.4',
        'port': 443,
        'id': 'uuid-hu',
        'net': 'httpupgrade',
        'path': '/vm?ed=1024',
      });
      final result =
          tryConvertShareLinks('vmess://${base64.encode(utf8.encode(json))}');
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('network: "ws"'));
      expect(config, contains('v2ray-http-upgrade: true'));
      expect(config, contains('v2ray-http-upgrade-fast-open: true'));
      expect(config, contains('path: "/vm"'));
    });

    test('vless encryption param is passed through', () {
      final result = tryConvertShareLinks(
          'vless://u@h.example.com:443?security=tls&sni=s.example.com'
          '&encryption=2022-blake3-aes-128-gcm#enc-node');
      expect(result, isNotNull);
      expect(result!.config, contains('encryption: "2022-blake3-aes-128-gcm"'));
    });

    test('vless encryption=none is omitted', () {
      final result = tryConvertShareLinks(
          'vless://u@h.example.com:443?security=tls&sni=s.example.com'
          '&encryption=none#enc-none');
      expect(result, isNotNull);
      expect(result!.config, isNot(contains('encryption')));
    });

    test('ws path with eh= names the early-data header', () {
      const link = 'trojan://pw@h.example.com:443'
          '?sni=s.example.com&type=ws&path=%2Fws%3Fed%3D2048%26eh%3DSec-WebSocket-Protocol%23x#eh-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('early-data-header-name: "Sec-WebSocket-Protocol#x"'));
    });

    test('ws path with other query params keeps them in the path', () {
      const link = 'vless://u@h.example.com:443'
          '?security=tls&sni=s.example.com&type=ws&path=%2Fws%3Ffoo%3D1%26ed%3D2048#mixed';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('path: "/ws?foo=1"'));
      expect(result.config, contains('max-early-data: 2048'));
    });

    test('plain ws path is untouched', () {
      const link = 'vless://u@h.example.com:443'
          '?security=tls&sni=s.example.com&type=ws&path=%2Fplain#plain';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('path: "/plain"'));
      expect(result.config, isNot(contains('max-early-data')));
    });

    test('tuic v5 link', () {
      const link = 'tuic://uuid-tuic:pw@h.example.com:443'
          '?sni=h.example.com&alpn=h3&congestion_control=bbr&udp_relay_mode=native'
          '&allow_insecure=1#tuic-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "tuic"'));
      expect(config, contains('uuid: "uuid-tuic"'));
      expect(config, contains('password: "pw"'));
      expect(config, contains('alpn: ["h3"]'));
      expect(config, contains('congestion-controller: "bbr"'));
      expect(config, contains('udp-relay-mode: "native"'));
      expect(config, contains('skip-cert-verify: true'));
    });

    test('tuic v4 token link is skipped, v5 without password is skipped', () {
      // The token form has no uuid:password split for mihomo to map.
      expect(tryConvertShareLinks('tuic://token@h.example.com:443#v4'),
          isNull);
      // `:` is the separator; a bare uuid is a v4-style link in disguise.
      expect(tryConvertShareLinks('tuic://uuid-only@h.example.com:443#v5'),
          isNull);
    });

    test('anytls link', () {
      const link = 'anytls://pw@h.example.com:443'
          '?sni=h.example.com&insecure=1#anytls-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "anytls"'));
      expect(config, contains('password: "pw"'));
      expect(config, contains('sni: "h.example.com"'));
      expect(config, contains('skip-cert-verify: true'));
    });

    test('hysteria v1 link', () {
      const link = 'hysteria://h.example.com:443'
          '?auth=secret&peer=h.example.com&insecure=1&upmbps=100&downmbps=500'
          '&alpn=h3&obfs=xplus&obfsParam=xp#hy1-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "hysteria"'));
      expect(config, contains('auth-str: "secret"'));
      expect(config, contains('up: "100"'));
      expect(config, contains('down: "500"'));
      expect(config, contains('obfs: "xp"'));
      expect(config, contains('skip-cert-verify: true'));
    });

    test('hysteria v1 obfs key: obfsParam wins, raw obfs is the fallback key',
        () {
      final withParam = tryConvertShareLinks(
          'hysteria://h.example.com:443?auth=s&up=1&down=1&obfs=anything'
          '&obfsParam=key1#o1');
      expect(withParam, isNotNull);
      expect(withParam!.config, contains('obfs: "key1"'));

      final withoutParam = tryConvertShareLinks(
          'hysteria://h.example.com:443?auth=s&up=1&down=1&obfs=key2#o2');
      expect(withoutParam, isNotNull);
      expect(withoutParam!.config, contains('obfs: "key2"'));
      expect(withoutParam.config, isNot(contains('obfs-password')));
    });

    test('hysteria v1 accepts plain up/down params', () {
      final result = tryConvertShareLinks(
          'hysteria://h.example.com:443?auth=s&upmbps=50&down=80#hy1-alt');
      expect(result, isNotNull);
      expect(result!.config, contains('up: "50"'));
      expect(result.config, contains('down: "80"'));
    });

    test('hysteria v1 without up/down is skipped, siblings live', () {
      final mixed = tryConvertShareLinks(
          'hysteria://h.example.com:443?auth=s#hy-no-bw\n'
          'trojan://p@h:1#keep');
      expect(mixed, isNotNull);
      expect(_proxiesNames(mixed!.config), ['keep']);
      expect(mixed.skipped.single.name, 'hy-no-bw');
      expect(mixed.skipped.single.reason, SkippedNodeReason.bandwidth);

      expect(
        tryConvertShareLinks('hysteria://h.example.com:443?auth=s#x'),
        isNull,
      );
      expect(
        tryConvertShareLinks('hysteria://h.example.com:443?peer=p#noauth'),
        isNull,
      );
    });

    test('socks5 link with credentials', () {
      const link = 'socks://user:pass@h.example.com:1080#socks-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      expect(result!.config, contains('type: "socks5"'));
      expect(result.config, contains('username: "user"'));
      expect(result.config, contains('password: "pass"'));
      expect(_proxiesNames(result.config), ['socks-node']);
    });

    test('socks5 tls without insecure keeps certificate verification', () {
      final plain = tryConvertShareLinks(
          'socks5://u:p@h.example.com:1080?tls=1#tls-socks');
      expect(plain, isNotNull);
      expect(plain!.config, contains('tls: true'));
      expect(plain.config, isNot(contains('skip-cert-verify')));

      final insecure = tryConvertShareLinks(
          'socks5://u:p@h.example.com:1080?tls=1&insecure=1#insec-socks');
      expect(insecure, isNotNull);
      expect(insecure!.config, contains('skip-cert-verify: true'));
    });

    test('socks5:// alias and bare-user form', () {
      final result = tryConvertShareLinks(
          'socks5://justuser@h.example.com:1080#bare');
      expect(result, isNotNull);
      expect(result!.config, contains('username: "justuser"'));
      expect(result.config, isNot(contains('password:')));
    });

    test('http proxy link requires userinfo, bare url stays a url', () {
      expect(
        isShareLinkInput('http://h.example.com:8080/sub'),
        isFalse,
      );
      final result = tryConvertShareLinks(
          'http://user:pass@h.example.com:8080#http-node');
      expect(result, isNotNull);
      expect(result!.config, contains('type: "http"'));
      expect(result.config, contains('username: "user"'));
      expect(result.config, contains('port: 8080'));
    });

    test('wireguard link: keys, peers, v4/v6 addresses', () {
      const link = 'wireguard://PRIVATEKEY@wg.example.com:51820'
          '?publickey=PUBKEY&presharedkey=PSK&address=10.0.0.2/32,fd00::2'
          '&mtu=1420&dns=1.1.1.1#wg-node';
      final result = tryConvertShareLinks(link);
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "wireguard"'));
      expect(config, contains('private-key: "PRIVATEKEY"'));
      expect(config, contains('public-key: "PUBKEY"'));
      expect(config, contains('pre-shared-key: "PSK"'));
      expect(config, contains('ip: "10.0.0.2/32"'));
      expect(config, contains('ipv6: "fd00::2/128"'));
      expect(config, contains('mtu: 1420'));
      expect(config, contains('dns: ["1.1.1.1"]'));
      expect(config, contains('remote-dns-resolve: true'));
      expect(config, contains('allowed-ips: ["0.0.0.0/0,::/0"]'));
    });

    test('wireguard keeps only the first address per family', () {
      final result = tryConvertShareLinks(
          'wg://KEY@wg.example.com:51820'
          '?address=10.0.0.2/32,10.0.0.3/32,fd00::2/64,fd00::3/64#multi');
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('ip: "10.0.0.2/32"'));
      expect(config, contains('ipv6: "fd00::2/64"'));
      expect(config, isNot(contains('10.0.0.3')));
      expect(config, isNot(contains('fd00::3')));
    });

    test('wireguard reserved needs exactly 3 bytes 0-255', () {
      final valid = tryConvertShareLinks(
          'wg://KEY@wg.example.com:51820?reserved=1,2,3#r-ok');
      expect(valid, isNotNull);
      expect(valid!.config, contains('reserved: [1, 2, 3]'));

      for (final bad in [
        'wg://KEY@wg.example.com:51820?reserved=1,2#r-two',
        'wg://KEY@wg.example.com:51820?reserved=1,2,3,4#r-four',
        'wg://KEY@wg.example.com:51820?reserved=1,2,999#r-range',
        'wg://KEY@wg.example.com:51820?reserved=1,2,x#r-junk',
      ]) {
        final result = tryConvertShareLinks(bad);
        expect(result, isNotNull, reason: bad);
        expect(result!.config, isNot(contains('reserved')), reason: bad);
      }
    });

    test('wireguard without address keeps empty ip/ipv6 (mihomo requires the fields)', () {
      final result = tryConvertShareLinks(
          'wg://PRIVATEKEY@wg.example.com:51820?publickey=PUBKEY#wg');
      expect(result, isNotNull);
      expect(result!.config, contains('ip: ""'));
      expect(result.config, contains('ipv6: ""'));
    });

    test('amneziawg links convert, undialable ssr is skipped, siblings live',
        () {
      final input = 'vless://u@h:443#keep\n'
          'amneziawg://${base64Url.encode(utf8.encode(_awgConf))}#awg\n'
          'awg://${base64Url.encode(utf8.encode(_awgConf))}#awg2\n'
          'ssr://abc@h:1#ssr\n'
          'tuic://uuid-tuic:pw@h:1#tuic-now-supported\n';
      // The body IS recognized as link input — it must never go to the network.
      expect(isShareLinkInput(input), isTrue);
      final result = tryConvertShareLinks(input);
      expect(result, isNotNull);
      expect(
        _proxiesNames(result!.config),
        ['keep', 'awg', 'awg2', 'tuic-now-supported'],
      );
      expect(result.config, contains('amnezia-wg-option'));
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.kind, 'ssr');
      expect(result.skipped.single.name, 'ssr');
      expect(result.skipped.single.reason, SkippedNodeReason.protocol);
    });

    test('an ssr line without a fragment uses its raw head as the name', () {
      final result = tryConvertShareLinks(
          'trojan://p@h:1#keep\nssr://aVeryLongBase64BlobWithoutAnyFragmentHere');
      expect(result, isNotNull);
      final ssr = result!.skipped.singleWhere((n) => n.kind == 'ssr');
      expect(ssr.name, startsWith('ssr://'));
      expect(ssr.name.endsWith('…'), isTrue);
    });

    test('a body of only unsupported schemes converts to nothing (null)', () {
      expect(tryConvertShareLinks('ssr://abc@h:1#ssr'), isNull);
    });

    test('probe reports the skipped nodes of an all-unsupported body', () {
      final skipped =
          probeUnsupportedShareLinks('ssr://abc@h:1#ssr\namneziawg://k@h:2#awg');
      // The awg line carries no base64 conf — it imports nothing, skips nothing.
      expect(skipped.map((n) => n.kind), ['ssr']);
    });

    test('probe is empty once anything imports', () {
      expect(
        probeUnsupportedShareLinks(
            'ssr://abc@h:1#ssr\ntrojan://p@h:2#alive'),
        isEmpty,
      );
      // And for input that is not links at all.
      expect(probeUnsupportedShareLinks('https://example.com'), isEmpty);
    });

    test('base64 blob with several links and junk lines', () {
      final plain = '# comment\nvless://u@h1:1#a\n\nnot a link\nss://'
          '${base64.encode(utf8.encode('aes-128-gcm:p'))}@h2:2#b\n';
      final result = tryConvertShareLinks(base64.encode(utf8.encode(plain)));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['a', 'b']);
    });

    test('duplicate names are numbered, not collapsed', () {
      final result =
          tryConvertShareLinks('trojan://p@h:1#same\nvless://u@h:2#same');
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['same', 'same 2']);
      // Both entries must survive in the group.
      expect(result.config, contains('"same", "same 2", DIRECT'));
    });

    test('names needing yaml quoting survive emission', () {
      final result = tryConvertShareLinks(
          'trojan://p@h:1#node: "weird" \\ one\n#hash');
      expect(result, isNotNull);
      expect(result!.config, contains(r'"node: \"weird\" \\ one"'));
    });

    test('control characters in names are escaped as \\xNN', () {
      final result =
          tryConvertShareLinks('trojan://p@h:1#node\x01\x7f\x08#ctrl');
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), [r'node\x01\x7f\x08#ctrl']);
      const quoted = '"node\\x01\\x7f\\x08#ctrl"';
      expect(result.config, contains(quoted));
    });

    test('emits a complete config: group + rule', () {
      final result = tryConvertShareLinks('trojan://p@h:1#node');
      final config = result!.config;
      expect(config, startsWith('proxies:\n'));
      // Flow maps: block-style `k: v, k: v` is invalid YAML.
      expect(config, contains('  - {name: "node"'));
      expect(config, contains('proxy-groups:\n'));
      expect(config, contains('name: "PROXY"'));
      expect(config, contains('type: select'));
      expect(config, contains('- MATCH,PROXY'));
    });

    test('non-link input returns null', () {
      expect(tryConvertShareLinks('proxies: []'), isNull);
      expect(tryConvertShareLinks('https://example.com'), isNull);
      expect(tryConvertShareLinks(''), isNull);
    });

    test('ipv6 host survives', () {
      final result =
          tryConvertShareLinks('trojan://p@[2001:db8::1]:443#v6');
      expect(result, isNotNull);
      expect(result!.config, contains('server: "2001:db8::1"'));
    });
  });

  group('awkward provider input', () {
    const threeNodes = 'vless://u1@h1.example.com:443#Cheap\n'
        'vless://u2@h2.example.com:443#100% Fast\n'
        'vless://u3@h3.example.com:443#Quiet';

    test('a bare % in one name costs no sibling node', () {
      final result = tryConvertShareLinks(threeNodes);
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['Cheap', '100% Fast', 'Quiet']);
    });

    test('the same list as a base64 blob imports all three', () {
      final result =
          tryConvertShareLinks(base64.encode(utf8.encode(threeNodes)));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['Cheap', '100% Fast', 'Quiet']);
      expect(result.config, contains('"Cheap", "100% Fast", "Quiet", DIRECT'));
    });

    test('percent-laden names are kept literally', () {
      expect(
        _proxiesNames(tryConvertShareLinks('vless://u@h:443#50%OFF')!.config),
        ['50%OFF'],
      );
      expect(
        _proxiesNames(
          tryConvertShareLinks('trojan://p@h:443#Node #1 (100%)')!.config,
        ),
        ['Node #1 (100%)'],
      );
    });

    test('correct escaping still decodes', () {
      expect(
        _proxiesNames(tryConvertShareLinks('vless://u@h:443#ru%2Dmsk')!.config),
        ['ru-msk'],
      );
    });

    test('a bare % in a query keeps the node', () {
      final result = tryConvertShareLinks(
          'vless://u@h:443?security=tls&sni=a.example.com&note=100%#pct');
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['pct']);
      expect(result.config, contains('servername: "a.example.com"'));
    });

    test('a bracket after the last colon is unparseable, not fatal', () {
      expect(tryConvertShareLinks('vless://uuid@:]'), isNull);
      expect(tryConvertShareLinks('trojan://pw@:]'), isNull);
      expect(tryConvertShareLinks('hysteria2://auth@:]'), isNull);
    });

    test('an ipv6 literal keeps its own colons out of the port', () {
      final result =
          tryConvertShareLinks('vless://uuid@[2001:db8::1]:443#v6');
      expect(result, isNotNull);
      expect(result!.config, contains('server: "2001:db8::1"'));
      expect(result.config, contains('port: 443'));
    });

    test('an empty vmess ps takes the server host as its name', () {
      final json = jsonEncode({
        'ps': '',
        'add': '9.9.9.9',
        'port': 443,
        'id': 'uuid-3',
      });
      final result =
          tryConvertShareLinks('vmess://${base64.encode(utf8.encode(json))}');
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['9.9.9.9']);
    });

    test('an empty ss name takes the server host', () {
      final result = tryConvertShareLinks(
          'ss://${base64.encode(utf8.encode('aes-128-gcm:pass'))}@1.1.1.1:8388#');
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['1.1.1.1']);
    });
  });
}
