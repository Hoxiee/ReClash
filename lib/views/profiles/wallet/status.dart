import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/power/attention.dart';
import 'package:reclash/features/power/face.dart' show PowerAction;
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/branding/brand.dart';
import 'package:reclash/subscriptions/branding/color.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/notification/record.dart';

enum WalletState { ok, critical, expired }

enum WalletCta { topUp, renew }

/// What a pass or a stack card shows for one profile, judged by the same
/// reminder thresholds as the dashboard and the power button.
class WalletFacts {
  const WalletFacts({
    required this.state,
    this.subscription = false,
    this.used = 0,
    this.total,
    this.expire,
    this.daysLeft,
    this.cta,
    this.ctaUrl,
  });

  final WalletState state;

  /// A URL profile; local and custom ones carry no usage or expiry.
  final bool subscription;
  final int used;

  /// Bytes; null for an unlimited plan or a provider that sends no total.
  final int? total;

  /// Null for a perpetual plan or a provider that sends no expiry.
  final DateTime? expire;
  final int? daysLeft;

  /// Set only for [WalletState.critical] and [WalletState.expired] when the
  /// provider names where to pay; the pass then shows it in place of actions.
  final WalletCta? cta;
  final Uri? ctaUrl;

  int? get left => total == null ? null : math.max(0, total! - used);

  /// From 0 to 1; null without a total.
  double? get leftFraction =>
      total == null || total == 0 ? null : (left! / total!).clamp(0.0, 1.0);

  bool get unlimited => subscription && total == null;
}

WalletFacts walletFactsOf(Profile profile, DateTime now) {
  if (profile.type != ProfileType.url) {
    return const WalletFacts(state: WalletState.ok);
  }
  final metadata =
      profile.subscriptionSnapshot?.metadata ?? const SubscriptionMetadata();
  final info = profile.subscriptionInfo ?? const SubscriptionInfo();
  final used = info.upload + info.download;
  final total = info.total > 0 && !metadata.unlimited ? info.total : null;
  final expireDate = metadata.perpetual
      ? null
      : subscriptionExpireDate(info.expire);
  final daysLeft = expireDate == null
      ? null
      : remainingDays(expire: info.expire, now: now);
  WalletFacts facts(WalletState state, [WalletCta? cta]) {
    final url = switch (cta) {
      null => null,
      WalletCta.topUp => accountLinkUrl(metadata, PowerAction.topUp),
      // A provider selling only traffic packs still lets an ended plan pay.
      WalletCta.renew =>
        accountLinkUrl(metadata, PowerAction.renew) ??
            accountLinkUrl(metadata, PowerAction.topUp),
    };
    return WalletFacts(
      state: state,
      subscription: true,
      used: used,
      total: total,
      expire: expireDate,
      daysLeft: daysLeft,
      cta: url == null ? null : cta,
      ctaUrl: url,
    );
  }

  if (expireDate != null &&
      subscriptionIsExpired(expire: info.expire, now: now)) {
    return facts(WalletState.expired, WalletCta.renew);
  }
  if (total != null && used >= total) {
    return facts(WalletState.critical, WalletCta.topUp);
  }
  final attention = accountAttention(
    metadata: metadata,
    used: used,
    total: total ?? 0,
    expire: info.expire,
    now: now,
  );
  if (attention == null) return facts(WalletState.ok);
  return facts(
    WalletState.critical,
    attention.byTraffic ? WalletCta.topUp : WalletCta.renew,
  );
}

/// The color a profile's surfaces take: the logo's, else the monogram's hue
/// while no logo was found; null keeps local, custom and gray-logo profiles
/// neutral.
Color? walletBrandColor(Profile profile, ProviderBrand? brand) {
  if (profile.type != ProfileType.url) return null;
  if (brand == null || brand.source == ProviderBrandSource.monogram) {
    return Color(monogramColor(monogramHue(profile.realLabel)));
  }
  return brand.color == null ? null : Color(brand.color!);
}
