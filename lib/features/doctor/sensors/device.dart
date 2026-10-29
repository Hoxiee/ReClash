import 'package:reclash/plugins/doctor.dart';
import 'package:riverpod/riverpod.dart';

import '../kernel.dart';
import '../snapshot.dart';

/// Android's view of the tunnel and the network; silent elsewhere.
final deviceDoctorStateProvider = StreamProvider<DeviceDoctorState>(
  (ref) => doctorPlugin?.onChanged ?? const Stream.empty(),
);

void deviceSensor(Ref ref, FactSink sink) {
  ref.listen(deviceDoctorStateProvider, (_, state) {
    final device = state.value;
    if (device == null) return;
    sink
      ..put(Facts.vpnPermission, device.vpnPermission)
      ..put(Facts.otherVpn, device.otherVpn)
      ..put(Facts.alwaysOnVpnApp, device.alwaysOnVpnApp)
      ..put(Facts.privateDns, device.privateDns)
      ..put(Facts.privateDnsHost, device.privateDnsHost)
      ..put(Facts.captivePortal, device.captivePortal);
  }, fireImmediately: true);
}
