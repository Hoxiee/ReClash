import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_offers.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_words.dart';
import 'package:reclash/views/dashboard/widgets/hero/subscription_bits.dart';
import 'package:reclash/views/dashboard/widgets/hero/subscription_sheet.dart';
import 'package:reclash/widgets/widgets.dart';

class MetaInfo extends ConsumerWidget {
  const MetaInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final panelMeta = profile?.panelMeta;
    return _SubscriptionCard(
      profile: profile,
      serviceLogo: panelMeta?.serviceLogo,
      profileLabel: profile?.realLabel ?? '',
      subscriptionInfo: profile?.subscriptionInfo,
      buyPlanUrl: panelMeta?.buyPlanUrl,
      buyTrafficUrl: panelMeta?.buyTrafficUrl,
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.profile,
    required this.serviceLogo,
    required this.profileLabel,
    required this.subscriptionInfo,
    required this.buyPlanUrl,
    required this.buyTrafficUrl,
  });

  final Profile? profile;
  final String? serviceLogo;
  final String profileLabel;
  final SubscriptionInfo? subscriptionInfo;
  final String? buyPlanUrl;
  final String? buyTrafficUrl;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final info = subscriptionInfo;

    final expire = info?.expire ?? 0;
    final now = DateTime.now();
    final expired =
        info != null && subscriptionIsExpired(expire: expire, now: now);
    final expireDate = subscriptionExpireDate(expire);
    final remaining = expireDate?.difference(now);
    final expiresInDays = remaining?.inDays;
    final daysLeft = expiresInDays == null
        ? null
        : expiresInDays > 0
        ? expiresInDays
        : 0;
    final daysUrgent = daysLeft != null && daysLeft <= heroRenewDaysThreshold;

    final unlimited = info == null || info.unlimited;
    final used = info?.used ?? 0;
    final total = info?.total ?? 0;
    final progress = unlimited
        ? 0.0
        : (used / total).clamp(0.0, 1.0).toDouble();
    final free = unlimited ? 0 : (total - used).clamp(0, total);
    final barColor = progress > 0.9
        ? colorScheme.error
        : progress > 0.7
        ? cautionColor
        : colorScheme.primary;

    final offers = heroBuyOffers(
      hasPlanUrl: buyPlanUrl?.isNotEmpty ?? false,
      hasTrafficUrl: buyTrafficUrl?.isNotEmpty ?? false,
      daysLeft: daysLeft,
      total: total,
      used: used,
    );

    final label = profileLabel.isEmpty
        ? appLocalizations.metaInfo
        : profileLabel;
    final valueStyle = context.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontFamily: FontFamily.jetBrainsMono.value,
    );

    final Widget? pill;
    if (info == null) {
      pill = null;
    } else if (expired) {
      pill = SubscriptionPill(
        color: colorScheme.error,
        label: appLocalizations.dashboardSubscriptionExpired,
      );
    } else if (daysLeft != null) {
      pill = SubscriptionPill(
        color: daysUrgent ? colorScheme.error : colorScheme.primary,
        label: '${appLocalizations.remaining} ${heroTimeLeftWords(remaining!)}',
      );
    } else {
      pill = SubscriptionPill(
        color: colorScheme.primary,
        label: appLocalizations.perpetualSubscription,
      );
    }

    final logo = serviceLogo;
    final currentProfile = profile;

    final Widget value;
    if (info == null) {
      value = Text(
        '—',
        style: valueStyle?.copyWith(color: colorScheme.onSurfaceVariant),
      );
    } else if (unlimited) {
      value = Text(
        used.traffic.show,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: valueStyle,
      );
    } else {
      value = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: free.traffic.show, style: valueStyle),
            const TextSpan(text: ' '),
            TextSpan(
              text: appLocalizations.trafficFreeOfTotal(total.traffic.show),
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RepaintBoundary(
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        padding: DashboardWidgetMetrics.paddingOf(context),
        onPressed: () => showSubscriptionSheet(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                logo == null || logo.isEmpty
                    ? GlyphIcon(
                        AppGlyphs.calendar,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : SizedBox.square(
                        dimension: 24,
                        child: ImageCacheWidget(
                          src: logo,
                          defaultWidget: GlyphIcon(
                            AppGlyphs.calendar,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ?pill,
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                currentProfile != null && currentProfile.type == ProfileType.url
                    ? _UpdateAction(profile: currentProfile)
                    : GlyphIcon(
                        AppGlyphs.chevronForward,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            value,
            if (info != null && !unlimited) ...[
              const SizedBox(height: AppSpacing.xs),
              SubscriptionBar(
                progress: progress <= 0 ? 0.0 : progress,
                color: barColor,
              ),
            ],
            if (offers.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _BuyOfferRow(
                    offers: offers,
                    buyPlanUrl: buyPlanUrl,
                    buyTrafficUrl: buyTrafficUrl,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BuyOfferRow extends StatelessWidget {
  const _BuyOfferRow({
    required this.offers,
    required this.buyPlanUrl,
    required this.buyTrafficUrl,
  });

  final List<HeroBuyOffer> offers;
  final String? buyPlanUrl;
  final String? buyTrafficUrl;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final offer in offers) ...[
          if (offer != offers.first) const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
                textStyle: context.textTheme.bodySmall,
              ),
              onPressed: () => dialogs.openUrl(
                offer == HeroBuyOffer.renewPlan ? buyPlanUrl! : buyTrafficUrl!,
              ),
              icon: GlyphIcon(
                heroBuyOfferViewOf(appLocalizations, offer).icon,
                size: 16,
              ),
              label: Text(
                heroBuyOfferViewOf(appLocalizations, offer).label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UpdateAction extends ConsumerWidget {
  const _UpdateAction({required this.profile});

  final Profile profile;

  Future<void> _handleUpdate(WidgetRef ref) async {
    try {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    } catch (error) {
      dialogs.showNotifier(
        userFacingErrorMessage(error, currentAppLocalizations),
        level: MessageLevel.error,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    return FadeThroughBox(
      child: isUpdating
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 36,
              height: 36,
              child: Padding(
                padding: AppInsets.sm,
                child: CommonCircleLoading(),
              ),
            )
          : IconButton(
              key: const ValueKey('update'),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              tooltip: context.appLocalizations.update,
              onPressed: () => _handleUpdate(ref),
              icon: const GlyphIcon(AppGlyphs.sync),
            ),
    );
  }
}
