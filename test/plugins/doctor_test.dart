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
}
