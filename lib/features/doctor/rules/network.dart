import 'package:reclash/plugins/doctor.dart';

import '../cause.dart';
import '../finding.dart';
import '../snapshot.dart';

/// Strict Private DNS resolves over TLS to its own host, past the Core's DNS
/// and fake-IP rules; opportunistic mode follows the VPN's DNS.
Finding? privateDnsRule(DiagnosticSnapshot snapshot) {
  if (snapshot.valueOf(Facts.privateDns) != PrivateDnsMode.strict) return null;
  return Finding(
    id: 'network.privateDns',
    severity: CheckSeverity.warning,
    evidence: [Facts.privateDns.id, Facts.privateDnsHost.id],
    titleKey: 'doctorPrivateDnsTitle',
    detailKey: 'doctorPrivateDnsDetail',
    args: {'host': snapshot.valueOf(Facts.privateDnsHost) ?? ''},
    remedyIds: const ['device.openPrivateDnsSettings'],
  );
}

Finding? captivePortalRule(DiagnosticSnapshot snapshot) {
  if (snapshot.valueOf(Facts.captivePortal) != true) return null;
  return Finding(
    id: 'network.captivePortal',
    severity: CheckSeverity.warning,
    cause: FailureCause.captivePortal,
    evidence: [Facts.captivePortal.id],
    titleKey: 'doctorCauseCaptivePortal',
    detailKey: 'doctorCaptivePortalDetail',
    remedyIds: const ['network.openCaptivePortal'],
  );
}
