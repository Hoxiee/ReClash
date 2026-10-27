import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/widgets/subscription_promo.dart';

void main() {
  final now = DateTime(2026, 10, 28, 12);

  Profile profile(int id, String? kind, {bool stale = false}) =>
      Profile.normal(label: 'P$id', url: 'https://sub.example/$id').copyWith(
        id: id,
        subscriptionSnapshot: SubscriptionSnapshot(
          metadata: SubscriptionMetadata({'subscription.type': ?kind}),
          receivedAt: now,
          stale: stale,
        ),
      );

  test('a promo counts down in days, then hours, then ends', () async {
    final l = await AppLocalizations.load(const Locale('en'));

    expect(
      promoCountdown(l, now.add(const Duration(days: 3, hours: 2)), now),
      '3 days left',
    );
    expect(
      promoCountdown(l, now.add(const Duration(minutes: 20)), now),
      '1 hour left',
    );
    expect(promoCountdown(l, now, now), 'Ended');
  });

  test('renewal appears only near the end and only with a safe link', () {
    const metadata = SubscriptionMetadata({
      'provider.buyPlanUrl': 'https://shop.example/renew',
    });

    expect(
      promoRenewUrl(metadata, now.add(const Duration(days: 10)), now),
      isNull,
    );
    expect(
      promoRenewUrl(metadata, now.add(const Duration(days: 2)), now),
      Uri.parse('https://shop.example/renew'),
    );
    expect(
      promoRenewUrl(
        const SubscriptionMetadata({'provider.buyPlanDays': 14}),
        now.add(const Duration(days: 10)),
        now,
      ),
      isNull,
    );
  });

  test('a promo that turns into a regular plan is a conversion', () {
    final previous = [
      profile(1, 'promo'),
      profile(2, 'promo'),
      profile(3, null),
    ];

    expect(
      convertedPromos(previous, [
        profile(1, null),
        profile(2, null, stale: true),
        profile(3, null),
      ]).map((profile) => profile.id),
      [1],
    );
    expect(convertedPromos(previous, [profile(1, 'test')]), isEmpty);
  });
}
