import 'package:reclash/common/device_identity.dart';
import 'package:test/test.dart';

void main() {
  group('DeviceIdentity.hwidFromSource', () {
    test('is stable for the same source', () {
      expect(
        DeviceIdentity.hwidFromSource('device-1'),
        DeviceIdentity.hwidFromSource('device-1'),
      );
    });

    test('separates devices by source', () {
      expect(
        DeviceIdentity.hwidFromSource('device-1'),
        isNot(DeviceIdentity.hwidFromSource('device-2')),
      );
    });

    test('is domain separated from a bare hash of the source', () {
      final bare = DeviceIdentity.hwidFromSource('device-1');
      final salted = DeviceIdentity.hwidFromSource('reclash-device:device-1');
      expect(bare, isNot(salted));
    });
  });
}
