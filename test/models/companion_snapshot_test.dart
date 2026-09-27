import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/companion.dart';

void main() {
  // Gson decodes every JSON number as a double, so the bridge map arrives with doubles where the
  // fields are int; a plain `as int` cast throws and the panel wrongly shows "unreachable".
  group('CompanionStateSnapshot.fromMap', () {
    test('accepts double numerics from the Gson bridge', () {
      final snapshot = CompanionStateSnapshot.fromMap(const {
        'running': false,
        'profileLabel': 'Black Cat VPN',
        'groupName': 'RCX-NODE',
        'nodeName': 'Netherlands',
        'revision': 12345.0,
        'trafficUp': 0.0,
        'trafficDown': 1636874276.0,
        'subscription': {
          'upload': 10.0,
          'download': 1636874276.0,
          'total': 0.0,
          'expire': 1893456000.0,
        },
      });

      expect(snapshot.trafficDown, 1636874276);
      expect(snapshot.revision, 12345);
      expect(snapshot.subscription?.download, 1636874276);
      expect(snapshot.subscription?.expire, 1893456000);
    });
  });

  group('CompanionProfileView.fromMap', () {
    test('accepts double id and lastUpdate from the Gson bridge', () {
      final view = CompanionProfileView.fromMap(const {
        'id': 7.0,
        'label': 'Main',
        'active': true,
        'lastUpdate': 1893456000.0,
      });

      expect(view.id, 7);
      expect(view.lastUpdate, 1893456000);
    });
  });
}
