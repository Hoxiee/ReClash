import 'package:reclash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('subscriptionNodeLabelsOf', () {
    // The runtime config the reporter reads is the merged one: GLOBAL, the
    // visible RCX-NODE selector, and hidden RCX plumbing sit alongside the
    // provider's real groups. Only the provider's groups may reach the labels,
    // or the decoder site's exact group-set match can never succeed.
    test('drops engine-owned groups and keeps provider groups', () {
      final labels = subscriptionNodeLabelsOf({
        'GLOBAL': {
          'type': 'Selector',
          'all': ['node-a', 'node-b', 'Quattro VPN', 'RCX-NODE'],
        },
        'RCX-NODE': {
          'type': 'Selector',
          'all': ['node-a', 'node-b'],
        },
        'RCX-DIRECT': {
          'type': 'Selector',
          'hidden': true,
          'all': ['node-a'],
        },
        'Quattro VPN': {
          'type': 'Selector',
          'all': ['node-a', 'node-b'],
        },
        'node-a': {'type': 'vless'},
        'node-b': {'type': 'vless'},
      });

      expect(labels['node-a']?.groups, ['Quattro VPN']);
      expect(labels['node-b']?.groups, ['Quattro VPN']);
      // positionHint counts within the provider group, not GLOBAL's ordering.
      expect(labels['node-a']?.positionHint, 1);
      expect(labels['node-b']?.positionHint, 2);
    });

    test('a node only in engine groups reports no groups', () {
      final labels = subscriptionNodeLabelsOf({
        'GLOBAL': {
          'type': 'Selector',
          'all': ['orphan'],
        },
        'RCX-NODE': {
          'type': 'Selector',
          'all': ['orphan'],
        },
        'orphan': {'type': 'trojan'},
      });

      expect(labels['orphan']?.groups, isEmpty);
      expect(labels['orphan']?.positionHint, 0);
      expect(labels['orphan']?.protocol, 'trojan');
    });
  });
}
