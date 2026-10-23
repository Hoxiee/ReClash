import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../../lib/subscriptions/imports/import.dart';

Uint8List _bytes(String value) => Uint8List.fromList(utf8.encode(value));

void main() {
  group('convertSubscriptionImport', () {
    test('passes unknown and encrypted bytes through unchanged', () {
      final source = Uint8List.fromList([0xff, 0x00, 0x7f]);
      final unknown = convertSubscriptionImport(source);
      final encrypted = convertSubscriptionImport(source, encrypted: true);
      expect(unknown.format, SubscriptionFormat.unknown);
      expect(unknown.bytes, source);
      expect(encrypted.format, SubscriptionFormat.encrypted);
      expect(encrypted.bytes, source);
    });

    test('prepares imports on a worker isolate', () async {
      final result = await prepareSubscriptionImport(_bytes('opaque payload'));
      expect(result.format, SubscriptionFormat.unknown);
      expect(utf8.decode(result.bytes), 'opaque payload');
    });

    test('converts share links without config-section loss', () {
      const source = 'ss://YWVzLTI1Ni1nY206cGFzcw==@example.com:443#edge';
      final result = convertSubscriptionImport(_bytes(source));
      expect(result.format, SubscriptionFormat.shareLinks);
      expect(utf8.decode(result.bytes), contains('type: "ss"'));
      expect(result.summary.nodes, 1);
      expect(result.summary.hasLosses, isFalse);
    });

    test('recognizes Clash provider-only configurations', () {
      const source =
          'proxy-providers:\n  remote:\n    type: http\n    url: https://example.invalid/list\n';
      final result = convertSubscriptionImport(_bytes(source));
      expect(result.format, SubscriptionFormat.clash);
      expect(result.summary.nodes, 0);
      expect(result.summary.remoteProviders, 1);
    });

    test('summarizes Clash proxies, groups, and providers', () {
      const source =
          'proxies:\n  - name: edge\n    type: ss\nproxy-groups:\n  - name: auto\n    type: select\n    proxies: [edge]\nproxy-providers:\n  remote:\n    type: http\n';
      final result = convertSubscriptionImport(_bytes(source));
      expect(result.format, SubscriptionFormat.clash);
      expect(result.summary.nodes, 1);
      expect(result.summary.groups, 1);
      expect(result.summary.remoteProviders, 1);
    });

    test('does not classify arbitrary JSON outbounds as a Core config', () {
      final result = convertSubscriptionImport(
        _bytes('{"outbounds":[{"type":"mystery","server":"example.com"}]}'),
      );
      expect(result.format, SubscriptionFormat.unknown);
      expect(result.summary.rejectCoreFallback, isTrue);
    });

    test('converts a list of Xray subscription profiles', () {
      final result = convertSubscriptionImport(
        _bytes(
          jsonEncode([
            {
              'remarks': 'First',
              'outbounds': [
                {
                  'tag': 'edge',
                  'protocol': 'vless',
                  'settings': {
                    'vnext': [
                      {
                        'address': 'first.example',
                        'port': 443,
                        'users': [
                          {
                            'id': '11111111-1111-4111-8111-111111111111',
                            'encryption': 'none',
                          },
                        ],
                      },
                    ],
                  },
                  'streamSettings': {'network': 'tcp'},
                },
              ],
            },
            {
              'remarks': 'Second',
              'outbounds': [
                {
                  'tag': 'edge',
                  'protocol': 'vless',
                  'settings': {
                    'vnext': [
                      {
                        'address': 'second.example',
                        'port': 443,
                        'users': [
                          {
                            'id': '22222222-2222-4222-8222-222222222222',
                            'encryption': 'none',
                          },
                        ],
                      },
                    ],
                  },
                  'streamSettings': {'network': 'tcp'},
                },
              ],
            },
          ]),
        ),
      );
      expect(result.format, SubscriptionFormat.xray);
      expect(result.summary.nodes, 2);
      expect(utf8.decode(result.bytes), contains('first.example'));
      expect(utf8.decode(result.bytes), contains('second.example'));
    });

    test('converts Xray nodes and records discarded config sections', () {
      const source =
          '{"inbounds":[{"port":1080}],"dns":{"servers":["1.1.1.1"]},"routing":{"rules":[]},"outbounds":[{"tag":"edge","protocol":"vless","settings":{"vnext":[{"address":"edge.example","port":443,"users":[{"id":"11111111-1111-4111-8111-111111111111","encryption":"none"}]}]},"streamSettings":{"network":"tcp"}}]}';
      final result = convertSubscriptionImport(_bytes(source));
      expect(result.format, SubscriptionFormat.xray);
      expect(result.summary.nodes, 1);
      expect(result.summary.ignoredSections, containsAll(['inbounds', 'dns']));
      expect(result.summary.hasLosses, isTrue);
    });

    test('converts sing-box nodes and records discarded config sections', () {
      const source =
          '{"inbounds":[{"type":"mixed","tag":"local"}],"dns":{"servers":[]},"route":{"rules":[]},"outbounds":[{"type":"vless","tag":"edge","server":"edge.example","server_port":443,"uuid":"11111111-1111-4111-8111-111111111111"},{"type":"unsupported","tag":"skip","server":"bad.example","server_port":1}]}';
      final result = convertSubscriptionImport(_bytes(source));
      expect(result.format, SubscriptionFormat.singbox);
      expect(result.summary.nodes, 1);
      expect(
        result.summary.ignoredSections,
        containsAll(['inbounds', 'dns', 'route']),
      );
      expect(result.summary.hasLosses, isTrue);
      expect(result.summary.skippedNodes, hasLength(1));
      expect(result.summary.skippedNodes.single.kind, 'unsupported');
      expect(result.summary.skippedNodes.single.name, 'skip');
    });

    test(
      'converts WireGuard configs and reports omitted full-config sections',
      () {
        const source =
            '[Interface]\nPrivateKey = private\nAddress = 10.0.0.2/32\nDNS = 1.1.1.1\n[Peer]\nPublicKey = public\nEndpoint = edge.example:51820\nAllowedIPs = 0.0.0.0/0\n';
        final result = convertSubscriptionImport(_bytes(source));
        expect(result.format, SubscriptionFormat.wireguard);
        expect(result.summary.nodes, 1);
        expect(result.summary.hasLosses, isTrue);
        expect(result.summary.hasOtherLosses, isTrue);
        expect(result.summary.ignoredSections, isEmpty);
      },
    );

    test('converts Amnezia WireGuard links', () {
      const conf =
          '[Interface]\nPrivateKey = private\n[Peer]\nPublicKey = public\nEndpoint = edge.example:51820\n';
      final link = 'awg://${base64Url.encode(utf8.encode(conf))}#edge';
      final result = convertSubscriptionImport(_bytes(link));
      expect(result.format, SubscriptionFormat.amnezia);
      expect(result.summary.nodes, 1);
      expect(result.summary.hasLosses, isTrue);
      expect(result.summary.hasOtherLosses, isTrue);
    });

    test('passes malformed JSON through as unknown without leaking data', () {
      const source = '{"password":"private-secret",';
      final result = convertSubscriptionImport(_bytes(source));
      expect(result.format, SubscriptionFormat.unknown);
      expect(utf8.decode(result.bytes), source);
    });

    test('rejects oversized YAML node lists', () {
      final entries = List.filled(
        maxSubscriptionImportNodes + 1,
        '  - name: edge',
      ).join('\n');
      expect(
        () => convertSubscriptionImport(_bytes('proxies:\n$entries')),
        throwsA(isA<SubscriptionImportException>()),
      );
    });

    test('bounds total bytes and parsed node counts', () {
      expect(
        () => convertSubscriptionImport(
          Uint8List(maxSubscriptionImportBytes + 1),
        ),
        throwsA(isA<SubscriptionImportException>()),
      );
      final items = List.filled(maxSubscriptionImportNodes + 1, '{}').join(',');
      expect(
        () => convertSubscriptionImport(_bytes('{"items":[$items]}')),
        throwsA(isA<SubscriptionImportException>()),
      );
    });

    test('does not expose source credentials in conversion errors', () {
      const source =
          '{"outbounds":[{"protocol":"vless","settings":{"password":"secret-token"}}]}';
      try {
        convertSubscriptionImport(_bytes(source));
        fail('expected conversion to fail');
      } on SubscriptionImportException catch (error) {
        expect(error.toString(), isNot(contains('secret-token')));
      }
    });
  });
}
