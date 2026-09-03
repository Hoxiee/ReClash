import 'package:reclash/views/dashboard/widgets/hero_offers.dart';
import 'package:test/test.dart';

const _gb = 1024 * 1024 * 1024;

List<HeroBuyOffer> offers({
  bool hasPlanUrl = true,
  bool hasTrafficUrl = true,
  int? daysLeft,
  int total = 100 * _gb,
  int used = 0,
}) {
  return heroBuyOffers(
    hasPlanUrl: hasPlanUrl,
    hasTrafficUrl: hasTrafficUrl,
    daysLeft: daysLeft,
    total: total,
    used: used,
  );
}

void main() {
  group('heroBuyOffers', () {
    test('offers a renewal on the last days and after expiry', () {
      for (final daysLeft in [3, 1, 0]) {
        expect(offers(hasTrafficUrl: false, daysLeft: daysLeft), [
          HeroBuyOffer.renewPlan,
        ], reason: '$daysLeft days left must trigger a renewal');
      }
    });

    test('stays quiet while the subscription is healthy', () {
      expect(offers(daysLeft: 4), isEmpty);
      expect(offers(daysLeft: null), isEmpty);
    });

    test('offers a top-up below a tenth of the quota', () {
      expect(offers(hasPlanUrl: false, used: 91 * _gb), [
        HeroBuyOffer.topUpTraffic,
      ]);
      expect(offers(hasPlanUrl: false, used: 90 * _gb), isEmpty);
    });

    test('ignores traffic triggers for unlimited subscriptions', () {
      expect(offers(hasPlanUrl: false, total: 0, used: 10 * _gb), isEmpty);
    });

    test('shows both offers when both triggers fire', () {
      expect(offers(daysLeft: 2, used: 99 * _gb), [
        HeroBuyOffer.renewPlan,
        HeroBuyOffer.topUpTraffic,
      ]);
    });

    test('skips offers the panel has no url for', () {
      expect(
        offers(
          hasPlanUrl: false,
          hasTrafficUrl: false,
          daysLeft: 0,
          used: 99 * _gb,
        ),
        isEmpty,
      );
    });
  });
}
