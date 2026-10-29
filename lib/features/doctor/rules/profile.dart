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
        ? 'doctorSubscriptionExpiredTitle'
        : 'doctorTrafficExhaustedTitle',
    detailKey: 'doctorSubscriptionDetail',
    args: {
      'profileId': subscription.profileId,
      if (expiresAt != null) 'expiresAt': expiresAt.millisecondsSinceEpoch,
    },
    remedyIds: const ['profile.update'],
  );
}
