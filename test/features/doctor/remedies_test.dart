import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/remedies/catalog.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/snapshot.dart';

final _request = RemedyRequest(
  snapshot: DiagnosticSnapshot(takenAt: DateTime(2026, 10, 29, 12)),
);

void main() {
  group('SystemScreenRemedy', () {
    test('is a system fix that verifies after the screen reports back', () {
      final remedy = SystemScreenRemedy(
        'device.openVpnSettings',
        () async => true,
      );

      expect(remedy.id, 'device.openVpnSettings');
      expect(remedy.kind, FixKind.system);
      expect(remedy.undoable, isFalse);
      expect(remedy.settle, greaterThan(Duration.zero));
    });

    test('completes once the screen opened', () async {
      final remedy = SystemScreenRemedy(
        'device.openVpnSettings',
        () async => true,
      );

      await expectLater(remedy.apply(_request), completes);
    });

    test('fails when no screen could be opened', () async {
      final remedy = SystemScreenRemedy(
        'device.openVpnSettings',
        () async => false,
      );

      await expectLater(
        remedy.apply(_request),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('device.openVpnSettings'),
          ),
        ),
      );
    });
  });

  group('VpnPermissionRemedy', () {
    test('is a system fix that asks for the VPN permission', () {
      final remedy = VpnPermissionRemedy(() async => true);

      expect(remedy.id, 'device.requestVpnPermission');
      expect(remedy.kind, FixKind.system);
      expect(remedy.undoable, isFalse);
    });

    test('completes once the permission is granted', () async {
      final remedy = VpnPermissionRemedy(() async => true);

      await expectLater(remedy.apply(_request), completes);
    });

    test('fails when the permission is refused', () async {
      final remedy = VpnPermissionRemedy(() async => false);

      await expectLater(remedy.apply(_request), throwsStateError);
    });
  });
}
