enum HeroBuyOffer { renewPlan, topUpTraffic }

const heroRenewDaysThreshold = 3;
const _topUpTrafficFraction = 0.1;

/// Panels sell two things and each has its own trigger: a plan renewal as the
/// subscription nears its end, a traffic top-up as the quota runs out. Both can
/// fire at once, so the card may carry two buttons.
List<HeroBuyOffer> heroBuyOffers({
  required bool hasPlanUrl,
  required bool hasTrafficUrl,
  required int? daysLeft,
  required int total,
  required int used,
}) {
  return [
    if (hasPlanUrl && daysLeft != null && daysLeft <= heroRenewDaysThreshold)
      HeroBuyOffer.renewPlan,
    if (hasTrafficUrl &&
        total > 0 &&
        (total - used) < total * _topUpTrafficFraction)
      HeroBuyOffer.topUpTraffic,
  ];
}
