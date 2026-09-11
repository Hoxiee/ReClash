import 'package:reclash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

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

typedef HeroBuyOfferView = ({IconData icon, String label});

HeroBuyOfferView heroBuyOfferViewOf(
  AppLocalizations appLocalizations,
  HeroBuyOffer offer,
) => switch (offer) {
  HeroBuyOffer.renewPlan => (
    icon: Icons.autorenew_rounded,
    label: appLocalizations.renewSubscription,
  ),
  HeroBuyOffer.topUpTraffic => (
    icon: Icons.add_shopping_cart_rounded,
    label: appLocalizations.topUpTraffic,
  ),
};
