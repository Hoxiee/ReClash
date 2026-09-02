import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/singbox_config.dart';

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

/// A sing-box outbound map in the sing-box spelling: flat dialer fields with
/// nested `tls`/`transport`.
Map<String, Object?> outbound(
  String type,
  String tag, {
  Map<String, Object?> extra = const {},
  Object? tls,
  Object? transport,
}) => {
  'type': type,
  'tag': tag,
  'server': 'sb.example.com',
  'server_port': 443,
  ...extra,
  'tls': ?tls,
  'transport': ?transport,
};

Map<String, Object?> tls(
  Map<String, Object?> extra, {
  Object? utls,
  Object? reality,
}) => {
  'enabled': true,
  'server_name': 'tls.example.com',
  ...extra,
  'utls': ?utls,
  'reality': ?reality,
};

void main() {
  group('isSingboxConfigInput', () {
    test('accepts a config object, rejects arrays, yaml and junk', () {
      expect(isSingboxConfigInput(_json({'outbounds': []})), isTrue);
      expect(isSingboxConfigInput(_json([{'outbounds': []}])), isFalse);
      expect(isSingboxConfigInput('proxies:\n  - name: "x"'), isFalse);
      expect(isSingboxConfigInput('vless://u@h:1'), isFalse);
      expect(isSingboxConfigInput(''), isFalse);
    });
  });

  group('tryConvertSingboxConfig', () {
    test('vless with reality + utls + grpc', () {
      final SingboxConfigResult? result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound(
            'vless',
            'Reality node',
            extra: {
              'uuid': 'uuid-1',
              'flow': 'xtls-rprx-vision',
              'packet_encoding': 'packetaddr',
            },
            tls: tls(
              {
                'alpn': ['h2', 'http/1.1'],
                'insecure': true,
              },
              utls: {'enabled': true, 'fingerprint': 'chrome'},
              reality: {
                'enabled': true,
                'public_key': 'PUBKEY',
                'short_id': 'e6c87ce',
              },
            ),
            transport: {'type': 'grpc', 'service_name': 'svc'},
          ),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['Reality node']);
      final config = result.config;
      expect(config, contains('type: "vless"'));
      expect(config, contains('uuid: "uuid-1"'));
      expect(config, contains('flow: "xtls-rprx-vision"'));
      expect(config, contains('packet-encoding: "packetaddr"'));
      expect(config, contains('network: "grpc"'));
      expect(config, contains('grpc-service-name: "svc"'));
      expect(config, contains('client-fingerprint: "chrome"'));
      expect(config, contains('reality-opts: {public-key: "PUBKEY", short-id: "e6c87ce"}'));
      expect(config, contains('skip-cert-verify: true'));
    });

    test('vmess with ws transport + early data', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound(
            'vmess',
            'WS node',
            extra: {
              'uuid': 'uuid-2',
              'security': 'auto',
              'alter_id': 0,
              'packet_encoding': 'packet',
            },
            tls: tls({'insecure': false}),
            transport: {
              'type': 'ws',
              'path': '/ws',
              'headers': {'Host': 'cdn.example.com'},
              'max_early_data': 2048,
              'early_data_header_name': 'Sec-WebSocket-Protocol',
            },
          ),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "vmess"'));
      expect(config, contains('cipher: "auto"'));
      expect(config, contains('alterId: 0'));
      expect(config, contains('packet-encoding: "packetaddr"'));
      expect(config, contains('network: "ws"'));
      expect(config, contains('path: "/ws"'));
      expect(config, contains('Host: "cdn.example.com"'));
      expect(config, contains('max-early-data: 2048'));
      expect(
        config,
        contains('early-data-header-name: "Sec-WebSocket-Protocol"'),
      );
      expect(config, contains('servername: "tls.example.com"'));
    });

    test('trojan uses sni, not servername', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('trojan', 'TJ-sni', extra: {'password': 'pw'},
              tls: tls({})),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('sni: "tls.example.com"'));
      expect(config, isNot(contains('servername')));
    });

    test('socks5 drops the SNI field entirely', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('socks', 'SK', extra: {'version': '5'},
              tls: tls({})),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "socks5"'));
      expect(config, isNot(contains('sni:')));
      expect(config, isNot(contains('servername')));
    });

    test('trojan, shadowsocks', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('trojan', 'TJ', extra: {'password': 'pw'}),
          outbound('shadowsocks', 'SS', extra: {
            'method': 'aes-128-gcm',
            'password': 'ss-pw',
          }),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['TJ', 'SS']);
      final config = result.config;
      expect(config, contains('type: "trojan"'));
      expect(config, contains('password: "pw"'));
      expect(config, contains('type: "ss"'));
      expect(config, contains('cipher: "aes-128-gcm"'));
    });

    test('ss plugin opts pass through as a map or SIP003 string', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('shadowsocks', 'SS-plugin', extra: {
            'method': 'aes-128-gcm',
            'password': 'ss-pw',
            'plugin': 'v2ray-plugin',
            'plugin_opts': {'mode': 'websocket', 'path': '/v'},
          }),
          outbound('shadowsocks', 'SS-sip003', extra: {
            'method': 'aes-128-gcm',
            'password': 'ss-pw',
            'plugin': 'v2ray-plugin',
            'plugin_opts': 'mode=websocket;path=/s',
          }),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('plugin: "v2ray-plugin"'));
      expect(
        config,
        contains('plugin-opts: {mode: "websocket", path: "/v"}'),
      );
      expect(
        config,
        contains('plugin-opts: {mode: "websocket", path: "/s"}'),
      );
    });

    test('hysteria2 with salamander obfs and bandwidth', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound(
            'hysteria2',
            'HY2',
            extra: {
              'password': 'auth',
              'obfs': {'type': 'salamander', 'password': 'ob'},
              'up_mbps': 100,
              'down_mbps': 500,
            },
            tls: tls({}),
          ),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "hysteria2"'));
      expect(config, contains('password: "auth"'));
      expect(config, contains('obfs: "salamander"'));
      expect(config, contains('obfs-password: "ob"'));
      expect(config, contains('up: "100"'));
      expect(config, contains('down: "500"'));
    });

    test('hysteria v1: auth vs auth-str, obfs key, bandwidth', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound(
            'hysteria',
            'HY1',
            extra: {
              'auth_str': 'plain-auth',
              'obfs': 'xplus',
              'obfs_password': 'obfs-key',
              'up_mbps': 50,
              'down_mbps': 200,
            },
            tls: tls({}),
          ),
          outbound(
            'hysteria',
            'HY1-b64',
            extra: {
              'auth': 'base64-auth',
              'obfs': 'xplus',
              'obfs_password': 'obfs-key2',
              'up_mbps': 50,
              'down_mbps': 200,
            },
            tls: tls({}),
          ),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(_proxiesNames(config), ['HY1', 'HY1-b64']);
      expect(config, contains('auth-str: "plain-auth"'));
      expect(config, contains('auth: "base64-auth"'));
      // mihomo's obfs field is the XPlus key itself, not a mode name.
      expect(config, contains('obfs: "obfs-key"'));
      expect(config, contains('obfs: "obfs-key2"'));
      expect(config, isNot(contains('obfs: "xplus"')));
      expect(config, isNot(contains('obfs-password')));
      expect(config, contains('up: "50"'));
      expect(config, contains('down: "200"'));
    });

    test('hysteria v1 without bandwidth is skipped', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('hysteria', 'HY1-nospeed', extra: {'auth_str': 'a'},
              tls: tls({})),
          outbound('hysteria', 'HY1-half', extra: {'up_mbps': 100},
              tls: tls({})),
          outbound('hysteria2', 'HY2-ok', extra: {
            'password': 'pw',
            'up_mbps': 30,
            'down_mbps': 100,
          }),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['HY2-ok']);
      // v1 requires positive up/down; a missing one kills the proxy in
      // mihomo, so it lands in skipped instead.
      expect(result.skipped, hasLength(2));
      expect(
        result.skipped.map((n) => '${n.kind}:${n.reason.name}'),
        everyElement('bandwidth:protocol'),
      );
    });

    test('tuic gains tls and default alpn when the tls block is absent', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('tuic', 'TUIC', extra: {
            'uuid': 'uuid-t',
            'password': 'pw',
            'congestion_control': 'bbr',
            'udp_relay_mode': 'native',
          }),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "tuic"'));
      expect(config, contains('congestion-controller: "bbr"'));
      expect(config, contains('udp-relay-mode: "native"'));
      expect(config, contains('tls: true'));
      expect(config, contains('alpn: ["h3"]'));
      expect(config, contains('sni: "sb.example.com"'));
    });

    test('wireguard with one peer and both address families', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('wireguard', 'WG', extra: {
            'private_key': 'PRIVATEKEY',
            'local_address': ['10.0.0.2/32', 'fd00::2/128'],
            'mtu': 1420,
            'peers': [
              {
                'server': 'wg.example.com',
                'server_port': 51820,
                'public_key': 'PUBKEY',
                'pre_shared_key': 'PSK',
              }
            ],
          }),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('type: "wireguard"'));
      expect(config, contains('server: "wg.example.com"'));
      expect(config, contains('port: 51820'));
      expect(config, contains('private-key: "PRIVATEKEY"'));
      expect(config, contains('public-key: "PUBKEY"'));
      expect(config, contains('pre-shared-key: "PSK"'));
      expect(config, contains('ip: "10.0.0.2/32"'));
      expect(config, contains('ipv6: "fd00::2/128"'));
      expect(config, contains('mtu: 1420'));
    });

    test('wireguard with multiple peers converts to the peers array', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('wireguard', 'WG-multi', extra: {
            'private_key': 'PRIVATEKEY',
            'local_address': ['10.0.0.2/32', 'fd00::2/128'],
            'peers': [
              {
                'server': 'wg1.example.com',
                'server_port': 51820,
                'public_key': 'PUBKEY1',
                'pre_shared_key': 'PSK1',
                'reserved': [1, 2, 3],
                'allowed_ips': ['10.0.0.0/24'],
              },
              {
                'server': 'wg2.example.com',
                'server_port': 51821,
                'public_key': 'PUBKEY2',
                'reserved': [4, 5, 6],
                'allowed_ips': ['192.168.0.0/16'],
              },
              {
                'server': 'wg3.example.com',
                'server_port': 51822,
                'public_key': 'PUBKEY3',
                'reserved': [7, 8],
              },
            ],
          }),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('server: "wg1.example.com"'));
      expect(config, contains('port: 51820'));
      expect(config, contains('private-key: "PRIVATEKEY"'));
      expect(config, contains('peers:'));
      expect(config, contains('server: "wg2.example.com"'));
      expect(config, contains('public-key: "PUBKEY2"'));
      expect(config, contains('reserved: [4, 5, 6]'));
      // Only the first local address per family survives: comma-joined
      // prefixes fail netip.ParsePrefix downstream.
      expect(config, contains('ip: "10.0.0.2/32"'));
      expect(config, contains('ipv6: "fd00::2/128"'));
      // A peer without allowed_ips defaults to routing everything, and a
      // malformed reserved list is dropped rather than failing the proxy.
      expect(config, contains('allowed-ips: ["0.0.0.0/0,::/0"]'));
      expect(config, isNot(contains('reserved: [7, 8]')));
      // No flat peer fields sit outside the peers array.
      expect(config, isNot(contains('allowed-ips: ["0.0.0.0/0,::/0"], udp')));
      expect(config, contains('peers: [{server: "wg1.example.com"'));
    });

    test('http transport maps to h2, httpupgrade to ws upgrade', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound(
            'vless',
            'H2 node',
            extra: {'uuid': 'u1'},
            tls: tls({}),
            transport: {'type': 'http', 'path': '/h2', 'host': ['a.com']},
          ),
          outbound(
            'trojan',
            'HU node',
            extra: {'password': 'p'},
            tls: tls({}),
            transport: {'type': 'httpupgrade', 'path': '/up', 'host': 'b.com'},
          ),
        ],
      }));
      expect(result, isNotNull);
      final config = result!.config;
      expect(config, contains('network: "h2"'));
      expect(config, contains('h2-opts: {path: "/h2", host: ["a.com"]}'));
      // mihomo has no httpupgrade network — it rides on ws.
      expect(config, contains('network: "ws"'));
      expect(config, contains('v2ray-http-upgrade: true'));
      expect(config, contains('path: "/up"'));
      expect(config, contains('Host: "b.com"'));
      expect(config, isNot(contains('httpupgrade')));
    });

    test('selector, urltest, direct, dns outbounds are skipped', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          {'type': 'selector', 'tag': 'selector', 'outbounds': ['a']},
          {'type': 'urltest', 'tag': 'auto', 'outbounds': ['a']},
          {'type': 'direct', 'tag': 'direct'},
          {'type': 'dns', 'tag': 'dns-out'},
          outbound('trojan', 'TJ', extra: {'password': 'pw'}),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['TJ']);
      expect(result.config, isNot(contains('selector')));
      expect(result.config, isNot(contains('"direct"')));
    });

    test('outbounds mihomo cannot dial are skipped, siblings live', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('naive', 'naive-node'),
          outbound('ssh', 'ssh-node'),
          outbound('socks', 'socks4-node', extra: {'version': '4'}),
          outbound('hysteria', 'hy1-bad-obfs', extra: {
            'auth_str': 'a',
            'obfs': 'salamander',
          }),
          outbound('vless', 'bad-transport', extra: {
            'uuid': 'u1',
          }, transport: {'type': 'weird'}),
          outbound('trojan', 'TJ', extra: {'password': 'pw'}),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['TJ']);
      // Every undialable node is accounted for with its reason.
      expect(result.skipped, hasLength(5));
      expect(
        result.skipped.map((n) => '${n.kind}:${n.reason.name}'),
        containsAll([
          'naive:protocol',
          'ssh:protocol',
          'socks4:protocol',
          'obfs salamander:transport',
          'weird:transport',
        ]),
      );
      expect(result.skipped.every((n) => n.name.isNotEmpty), isTrue);
    });

    test('service outbounds never count as skipped', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          {'type': 'selector', 'tag': 'selector', 'outbounds': ['TJ']},
          {'type': 'urltest', 'tag': 'auto', 'outbounds': ['TJ']},
          {'type': 'direct', 'tag': 'direct'},
          {'type': 'dns', 'tag': 'dns-out'},
          outbound('naive', 'naive-node'),
          outbound('trojan', 'TJ', extra: {'password': 'pw'}),
        ],
      }));
      expect(result, isNotNull);
      final list = result!;
      expect(list.skipped, hasLength(1));
      expect(list.skipped.single.kind, 'naive');
    });

    test('nodes missing required credentials are skipped', () {
      // Silent skips — a broken node is the panel's error, not our
      // capability, and never enters the skipped list.
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('vless', 'no-uuid'),
          outbound('trojan', 'no-password'),
          outbound('shadowsocks', 'no-method', extra: {'password': 'p'}),
          outbound('trojan', 'TJ', extra: {'password': 'pw'}),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['TJ']);
      expect(result.skipped, isEmpty);
    });

    test('a config of only broken nodes returns null and counts nothing',
        () {
      expect(tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('vless', 'no-uuid'),
          outbound('trojan', 'no-password'),
          outbound('shadowsocks', 'no-method', extra: {'password': 'p'}),
        ],
      })), isNull);
    });

    test('duplicate tags collapse by name', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('trojan', 'dup', extra: {'password': 'p'}),
          outbound('trojan', 'dup', extra: {'password': 'p'}),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['dup']);
    });

    test('empty tag falls back to the server host', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [
          outbound('trojan', '', extra: {'password': 'pw'}),
        ],
      }));
      expect(result, isNotNull);
      expect(_proxiesNames(result!.config), ['sb.example.com']);
    });

    test('emits a complete config: group + rule', () {
      final result = tryConvertSingboxConfig(_json({
        'outbounds': [outbound('trojan', 'TJ', extra: {'password': 'pw'})],
      }));
      final config = result!.config;
      expect(config, startsWith('proxies:\n'));
      expect(config, contains('proxy-groups:\n'));
      expect(config, contains('name: "PROXY"'));
      expect(config, contains('type: select'));
      expect(config, contains('- MATCH,PROXY'));
    });

    test('non-config input returns null', () {
      expect(tryConvertSingboxConfig('proxies: []'), isNull);
      expect(tryConvertSingboxConfig('{}'), isNull);
      expect(tryConvertSingboxConfig(''), isNull);
      expect(tryConvertSingboxConfig('vless://u@h:1'), isNull);
    });
  });
}
