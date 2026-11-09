import 'dart:math' as math;

import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/notification/record.dart';

import 'face.dart';

/// The plan nears its end by the provider's reminder thresholds, the same
/// ones the subscription card warns at; an ended plan is the kernel's.
AccountAttention? accountAttention({
  required SubscriptionMetadata metadata,
  required int used,
  required int total,
  required int expire,
  required DateTime now,
}) {
  if (!metadata.perpetual &&
      subscriptionExpireDate(expire) != null &&
      !subscriptionIsExpired(expire: expire, now: now)) {
    final days = remainingDays(expire: expire, now: now);
    final thresholds = metadata.numbers('reminder.expireDays');
    final warnAt = (thresholds.isEmpty ? defaultExpireNotifyDays : thresholds)
        .reduce(math.max);
    if (days >= 0 && days <= warnAt) return AccountAttention.days(days);
  }
  if (!metadata.unlimited && total > 0) {
    final left = total - used;
    final levels = metadata.numbers('reminder.trafficPercent');
    final warnAt = (levels.isEmpty ? defaultTrafficNotifyPercent : levels)
        .reduce(math.min);
    if (left > 0 && usedPercent(used: used, total: total) >= warnAt) {
      return AccountAttention.traffic(left);
    }
  }
  return null;
}

Uri? accountLinkUrl(SubscriptionMetadata metadata, PowerAction action) =>
    switch (action) {
      PowerAction.renew => _link(metadata, 'provider.buyPlanUrl'),
      PowerAction.topUp => _link(metadata, 'provider.buyTrafficUrl'),
      PowerAction.support => switch (metadata.text('provider.supportUrl')) {
        final value? => safeSubscriptionSupportLink(value),
        null => null,
      },
      _ => null,
    };

AccountLinks accountLinks(SubscriptionMetadata metadata) => AccountLinks(
  renew: accountLinkUrl(metadata, PowerAction.renew) != null,
  topUp: accountLinkUrl(metadata, PowerAction.topUp) != null,
  support: accountLinkUrl(metadata, PowerAction.support) != null,
);

Uri? _link(SubscriptionMetadata metadata, String path) =>
    switch (metadata.text(path)) {
      final value? => safeSubscriptionLink(value),
      null => null,
    };
