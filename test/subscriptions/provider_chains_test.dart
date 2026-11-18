import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/subscriptions/metadata/provider_chains.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';

void main() {
  ProviderConfigResult parse(String chains) =>
      parseProviderConfig('version: 1\nchains:\n$chains', 'en');

  test('reads chains with their fingerprints', () {
    final result = parse('''
  - name: Via Frankfurt
    hops: [DE entry, NL exit]
    target-group: Proxy
    offered: false
    fingerprints:
      - { type: vless, server: de1.example.net, port: 443 }
      - null
''');

    expect(result.warnings, isEmpty);
    final chain = result.config!.chains.single;
    expect(chain.name, 'Via Frankfurt');
    expect(chain.hops, ['DE entry', 'NL exit']);
    expect(chain.targetGroup, 'Proxy');
    expect(chain.offered, isFalse);
    expect(chain.fingerprints.first?.server, 'de1.example.net');
    expect(chain.fingerprints.last, isNull);
  });

  test('skips an invalid chain and keeps the others', () {
    final result = parse('''
  - { name: Short, hops: [only] }
  - { name: Fine, hops: [a, b] }
  - { name: Fine, hops: [c, d] }
  - { name: Four, hops: [a, b, c, d] }
  - { name: Odd, hops: [a, b], fingerprints: [null] }
  - { name: Port, hops: [a, b], fingerprints: [{type: ss, server: s, port: 0}, null] }
  - { name: Extra, hops: [a, b], speed: fast }
''');

    expect(result.config!.chains.map((chain) => chain.name), ['Fine']);
    expect(result.config!.chains.single.hops, ['a', 'b']);
    expect(result.warnings, hasLength(6));
  });

  test('ignores a section that is not a list', () {
    final result = parseProviderConfig('version: 1\nchains: {name: x}\n', 'en');

    expect(result.config!.chains, isEmpty);
    expect(result.warnings, ['Invalid chains section']);
  });

  test('uses at most $providerChainLimit chains', () {
    final lines = [
      for (var i = 0; i <= providerChainLimit; i++)
        '  - { name: c$i, hops: [a, b] }',
    ];

    final result = parse(lines.join('\n'));

    expect(result.config!.chains, hasLength(providerChainLimit));
    expect(result.warnings, hasLength(1));
  });

  test('a fingerprinted chain asks the Core to heal a missing hop', () {
    final result = parse('''
  - { name: Plain, hops: [a, b] }
  - name: Pinned
    hops: [a, b]
    fingerprints:
      - null
      - { type: ss, server: s, port: 8388 }
''');
    final chains = result.config!.chains;

    final plain = chains.first.toSpec(providerChainId(0)).toJson();
    final pinned = chains.last.toSpec(providerChainId(1)).toJson();

    expect(plain.containsKey('heal'), isFalse);
    expect(plain.containsKey('fingerprints'), isFalse);
    expect(pinned['heal'], isTrue);
    expect(pinned['id'], -2);
    expect(isProviderChainId(pinned['id']! as int), isTrue);
    expect(isProviderChainId(1), isFalse);
  });
}
