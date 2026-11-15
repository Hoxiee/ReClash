import 'package:reclash/plugins/doctor.dart';

import '../cause.dart';
import '../finding.dart';
import '../snapshot.dart';

Finding? vpnPermissionRule(DiagnosticSnapshot snapshot) {
  if (snapshot.valueOf(Facts.vpnPermission) != VpnPermission.revoked) {
    return null;
  }
  return Finding(
    id: 'tunnel.vpnPermission',
    severity: CheckSeverity.critical,
    cause: FailureCause.tunnelDenied,
    evidence: [Facts.vpnPermission.id],
    titleKey: 'doctorVpnRevokedTitle',
    detailKey: 'doctorVpnRevokedDetail',
    remedyIds: const ['device.requestVpnPermission'],
  );
}

/// The system revoked the running tunnel, typically because another app with
/// VPN consent asked for the slot, often a second copy or fork merely checking
/// its permission. The apps are the suspects, not a proven culprit.
Finding? vpnLostRule(DiagnosticSnapshot snapshot) {
  final apps = snapshot.valueOf(Facts.vpnLostTo);
  if (apps == null) return null;
  return Finding(
    id: 'tunnel.vpnLost',
    severity: CheckSeverity.critical,
    cause: FailureCause.tunnelTaken,
    evidence: [Facts.vpnLostTo.id],
    titleKey: 'doctorVpnLostTitle',
    detailKey: 'doctorVpnLostDetail',
    args: {'apps': apps},
    remedyIds: const ['device.openVpnSettings'],
  );
}

Finding? otherVpnRule(DiagnosticSnapshot snapshot) {
  if (snapshot.valueOf(Facts.otherVpn) != true) return null;
  if (snapshot.valueOf(Facts.vpnLostTo) != null) return null;
  return Finding(
    id: 'tunnel.otherVpn',
    severity: CheckSeverity.critical,
    cause: FailureCause.tunnelTaken,
    evidence: [Facts.otherVpn.id],
    titleKey: 'doctorCauseTunnelTaken',
    detailKey: 'doctorOtherVpnDetail',
    remedyIds: const ['device.openVpnSettings'],
  );
}

/// Another app as always-on VPN takes the tunnel back after every reboot; no
/// always-on app at all is only a missed safety net.
Finding? alwaysOnVpnRule(DiagnosticSnapshot snapshot) {
  final app = snapshot.valueOf(Facts.alwaysOnVpnApp);
  if (app == null) return null;
  final other = app.isNotEmpty;
  return Finding(
    id: 'tunnel.alwaysOn',
    severity: other ? CheckSeverity.critical : CheckSeverity.tip,
    cause: other ? FailureCause.tunnelTaken : null,
    evidence: [Facts.alwaysOnVpnApp.id],
    titleKey: other ? 'doctorAlwaysOnOtherTitle' : 'doctorAlwaysOnOffTitle',
    detailKey: other ? 'doctorAlwaysOnOtherDetail' : 'doctorAlwaysOnOffDetail',
    remedyIds: const ['device.openVpnSettings'],
  );
}
