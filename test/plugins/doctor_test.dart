import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/plugins/doctor.dart';

void main() {
  group('DeviceDoctorState.fromMap alwaysOnVpnApp', () {
    DeviceDoctorState parse(String? app) => DeviceDoctorState.fromMap({
      'vpnPermission': 'granted',
      'alwaysOnVpnApp': app,
      'packageName': 'com.reclash.dev',
    });

    test('drops the running package, whatever the build flavor', () {
      expect(parse('com.reclash.dev').alwaysOnVpnApp, isNull);
    });

    test('keeps a foreign package and the empty "none set" value', () {
      expect(parse('com.example.vpn').alwaysOnVpnApp, 'com.example.vpn');
      expect(parse('').alwaysOnVpnApp, '');
    });

    test('keeps the release id when it is not the running package', () {
      expect(parse('com.reclash').alwaysOnVpnApp, 'com.reclash');
    });
  });

  group('DeviceDoctorState.fromMap vpnLostTo', () {
    DeviceDoctorState parse(Object? lost) => DeviceDoctorState.fromMap({
      'vpnPermission': 'granted',
      'vpnLostTo': lost,
    });

    test('keeps the apps in order', () {
      expect(parse(['A', 'B']).vpnLostTo, ['A', 'B']);
    });

    test('is empty when the key is missing', () {
      final state = DeviceDoctorState.fromMap({'vpnPermission': 'granted'});

      expect(state.vpnLostTo, isEmpty);
    });

    test('drops entries that are not strings', () {
      expect(parse(['A', 1, null, 'B']).vpnLostTo, ['A', 'B']);
    });
  });

  group('DeviceDoctorState equality with vpnLostTo', () {
    DeviceDoctorState withLost(List<String> apps) => DeviceDoctorState(
      vpnPermission: VpnPermission.granted,
      vpnLostTo: apps,
    );

    test('matches the same apps and differs when they change', () {
      expect(withLost(['A']), withLost(['A']));
      expect(withLost(['A']), isNot(withLost(['B'])));
      expect(withLost(['A']), isNot(withLost(const [])));
    });
  });
}
