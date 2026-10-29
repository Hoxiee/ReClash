import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:reclash/common/common.dart';

enum VpnPermission { granted, revoked, notAsked }

enum PrivateDnsMode { off, opportunistic, strict }

enum DoctorSettings { vpn, privateDns, dateTime, captivePortal }

/// What Android tells about the tunnel and the network beneath it.
@immutable
final class DeviceDoctorState {
  const DeviceDoctorState({
    required this.vpnPermission,
    this.otherVpn = false,
    this.alwaysOnVpnApp,
    this.privateDns,
    this.privateDnsHost,
    this.captivePortal = false,
  });

  factory DeviceDoctorState.fromMap(Map<Object?, Object?> map) {
    return DeviceDoctorState(
      vpnPermission: VpnPermission.values.byName(
        map['vpnPermission'] as String? ?? VpnPermission.notAsked.name,
      ),
      otherVpn: map['otherVpn'] == true,
      alwaysOnVpnApp: map['alwaysOnVpnApp'] as String?,
      privateDns: switch (map['privateDns']) {
        final String name => PrivateDnsMode.values.asNameMap()[name],
        _ => null,
      },
      privateDnsHost: map['privateDnsHost'] as String?,
      captivePortal: map['captivePortal'] == true,
    );
  }

  /// Revoked only once it was granted before, so a fresh install that has
  /// not asked yet raises nothing.
  final VpnPermission vpnPermission;

  /// A VPN network another app owns is up.
  final bool otherVpn;

  /// The always-on VPN package, empty when none is set and null when the
  /// system does not let the app read it.
  final String? alwaysOnVpnApp;

  /// Of the underlying network; null before Android 9.
  final PrivateDnsMode? privateDns;
  final String? privateDnsHost;
  final bool captivePortal;

  @override
  bool operator ==(Object other) =>
      other is DeviceDoctorState &&
      other.vpnPermission == vpnPermission &&
      other.otherVpn == otherVpn &&
      other.alwaysOnVpnApp == alwaysOnVpnApp &&
      other.privateDns == privateDns &&
      other.privateDnsHost == privateDnsHost &&
      other.captivePortal == captivePortal;

  @override
  int get hashCode => Object.hash(
    vpnPermission,
    otherVpn,
    alwaysOnVpnApp,
    privateDns,
    privateDnsHost,
    captivePortal,
  );
}

class DoctorPlugin {
  DoctorPlugin._();

  static final instance = DoctorPlugin._();

  static const _methodChannel = MethodChannel('$packageName/doctor');
  static const _eventChannel = EventChannel('$packageName/doctor/state');

  /// The current state on listen, then one per change, network changes and
  /// returns to the app included.
  late final Stream<DeviceDoctorState> onChanged = _eventChannel
      .receiveBroadcastStream()
      .map(
        (event) => DeviceDoctorState.fromMap(event as Map<Object?, Object?>),
      );

  /// Completes with whether the app may start the tunnel now.
  Future<bool> requestVpnPermission() async =>
      await _methodChannel.invokeMethod<bool>('requestVpnPermission') ?? false;

  /// Completes once the user returns from the screen, false when none opened.
  Future<bool> openSettings(DoctorSettings target) async =>
      await _methodChannel.invokeMethod<bool>('openSettings', target.name) ??
      false;
}

final doctorPlugin = system.isAndroid ? DoctorPlugin.instance : null;
