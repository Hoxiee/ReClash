import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/core/sandbox.dart';
import 'package:reclash/models/models.dart';

void main() {
  group('withSandboxNodes', () {
    test('fills a subscription that ships no nodes', () {
      final config = withSandboxNodes({'proxies': [], 'mode': 'rule'});

      expect(config['mode'], 'rule');
      expect(config['proxies'], isNotEmpty);
      expect(config['proxy-groups'], [containsPair('name', sandboxGroup)]);
      expect(config['rules'], ['MATCH,$sandboxGroup']);
    });

    test('keeps the nodes and groups a subscription ships', () {
      final config = {
        'proxies': [
          {'name': 'Own', 'type': 'socks5'},
        ],
      };

      expect(withSandboxNodes(config), same(config));
      expect(
        withSandboxNodes({
          'proxy-providers': {'p': {}},
          'proxy-groups': [
            {'name': 'G'},
          ],
        })['proxy-groups'],
        [
          {'name': 'G'},
        ],
      );
    });
  });

  test('a node keeps its latency between tests', () {
    final first = CoreSandbox().delay('u', '🇳🇱 Amsterdam 01');
    final second = CoreSandbox().delay('u', '🇳🇱 Amsterdam 01');

    expect(second, first);
  });

  test('the outbound address parses like a real lookup', () {
    final result = CoreSandbox().outboundIp(
      const OutboundIpParams(timeout: 1000),
    );

    expect(parseOutboundIp(result)?.ip, CoreSandbox.exitIp);
  });

  test('a closed connection stays closed', () {
    final sandbox = CoreSandbox();
    final id = sandbox.connections().first.id;

    sandbox.closeConnection(id);

    expect(sandbox.connections().map((info) => info.id), isNot(contains(id)));
    sandbox.closeConnections();
    expect(sandbox.connections(), isEmpty);
  });
}
