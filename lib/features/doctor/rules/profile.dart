import '../cause.dart';
import '../finding.dart';
import '../snapshot.dart';

Finding? subscriptionRule(DiagnosticSnapshot snapshot) {
  final subscription = snapshot.valueOf(Facts.subscription);
  if (subscription == null) return null;
  final expiresAt = subscription.expiresAt;
  final cause = switch (subscription) {
    _ when expiresAt != null && !expiresAt.isAfter(snapshot.takenAt) =>
      FailureCause.subscriptionExpired,
    SubscriptionFact(:final total, :final used)
        when total > 0 && used >= total =>
      FailureCause.trafficExhausted,
    _ => null,
  };
  if (cause == null) return null;
  return Finding(
    id: 'profile.subscription',
    severity: CheckSeverity.critical,
    cause: cause,
    evidence: [Facts.subscription.id],
    titleKey: cause == FailureCause.subscriptionExpired
        ? 'doctorCauseSubscriptionExpired'
        : 'doctorCauseTrafficExhausted',
    detailKey: 'doctorSubscriptionDetail',
    args: {
      'profileId': subscription.profileId,
      if (expiresAt != null) 'expiresAt': expiresAt.millisecondsSinceEpoch,
    },
    remedyIds: const ['profile.update'],
  );
}

const _revokedStatuses = {401, 403, 404, 410};

/// The subscription URL itself refuses or no longer exists, which no node
/// switch or retry can fix.
Finding? profileRevokedRule(DiagnosticSnapshot snapshot) {
  final update = snapshot.valueOf(Facts.profileUpdate);
  final status = update?.status;
  if (update == null || !_revokedStatuses.contains(status)) return null;
  return Finding(
    id: 'profile.revoked',
    severity: CheckSeverity.critical,
    cause: FailureCause.authRejected,
    evidence: [Facts.profileUpdate.id],
    titleKey: 'doctorProfileRevokedTitle',
    detailKey: 'doctorProfileRevokedDetail',
    args: {'profileId': update.profileId, 'status': status!},
    remedyIds: const ['profile.update'],
  );
}

Finding? profileNoServersRule(DiagnosticSnapshot snapshot) {
  final update = snapshot.valueOf(Facts.profileUpdate);
  if (update == null || update.servers != 0) return null;
  return Finding(
    id: 'profile.noServers',
    severity: CheckSeverity.critical,
    cause: FailureCause.profileInvalid,
    evidence: [Facts.profileUpdate.id],
    titleKey: 'doctorProfileNoServersTitle',
    detailKey: 'doctorProfileNoServersDetail',
    args: {'profileId': update.profileId},
    remedyIds: const ['profile.update'],
  );
}
