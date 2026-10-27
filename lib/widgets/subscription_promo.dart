import 'dart:math' as math;

import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/notification/record.dart';

/// A promo is a deadline, so it counts down instead of naming a date.
String promoCountdown(AppLocalizations l, DateTime expire, DateTime now) {
  final left = expire.difference(now);
  if (left <= Duration.zero) return l.promoEnded;
  if (left.inDays > 0) return l.promoDaysLeft(left.inDays);
  return l.promoHoursLeft(math.max(1, left.inHours));
}

/// Where a promo near or past its end sends the user to pay, by the same
/// threshold the expiry reminders use; null while there is time left or the
/// provider names nowhere to go.
Uri? promoRenewUrl(
  SubscriptionMetadata metadata,
  DateTime expire,
  DateTime now,
) {
  final thresholds = metadata.numbers('reminder.expireDays');
  final warnAt =
      metadata.count('provider.buyPlanDays') ??
      (thresholds.isEmpty ? defaultExpireNotifyDays : thresholds).reduce(
        math.max,
      );
  if (expire.difference(now).inDays > warnAt) return null;
  final link =
      metadata.text('provider.buyPlanUrl') ??
      metadata.text('provider.buyTrafficUrl');
  return link == null ? null : safeSubscriptionLink(link);
}

/// Profiles a provider moved from a promo to a regular plan between two
/// states of the list. A stale snapshot carries no fresh type, so it never
/// counts as a conversion.
Iterable<Profile> convertedPromos(List<Profile> previous, List<Profile> next) {
  final promos = {
    for (final profile in previous)
      if (profile.subscriptionSnapshot?.metadata.kind == SubscriptionKind.promo)
        profile.id,
  };
  return next.where((profile) {
    final snapshot = profile.subscriptionSnapshot;
    return promos.contains(profile.id) &&
        profile.type == ProfileType.url &&
        snapshot != null &&
        !snapshot.stale &&
        snapshot.metadata.kind == null;
  });
}
