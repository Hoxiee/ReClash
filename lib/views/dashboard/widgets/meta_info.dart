import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_offers.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:reclash/widgets/theme/wallpaper_scope.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _expiringSoonDays = 3;

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
    final expireDate = expire == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expire * 1000);
    final isPerpetual =
        expire == 0 || (expireDate?.year ?? 0) >= perpetualExpireYear;
    var daysLeft = expireDate?.difference(DateTime.now()).inDays;
    if (daysLeft != null && daysLeft < 0) daysLeft = 0;
    final status = isPerpetual
        ? appLocalizations.perpetualSubscription
        : daysLeft == null
        ? appLocalizations.infiniteTime
        : appLocalizations.daysLeft(daysLeft);
    final urgent =
        !isPerpetual && daysLeft != null && daysLeft <= _expiringSoonDays;
    final statusColor = urgent ? colorScheme.error : colorScheme.onSurface;

    final hasQuota = info != null && !info.unlimited;
    final used = info?.used ?? 0;
    final usedFraction = hasQuota
        ? (used / info.total).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final free = hasQuota ? (info.total - used).clamp(0, info.total) : 0;
    final freePercent = hasQuota ? ((1 - usedFraction) * 100).round() : 0;
    final ringColor = usedFraction > 0.9
        ? colorScheme.error
        : usedFraction > 0.7
        ? const Color(0xFFC57F0A)
        : colorScheme.primary;

    final trafficCaption = info == null || hasQuota
        ? appLocalizations.remainingTraffic
        : appLocalizations.usedTraffic;
    final trafficValue = info == null
        ? '—'
        : hasQuota
        ? '${free.traffic.show} / ${info.total.traffic.show}'
        : used.traffic.show;

    final offers = heroBuyOffers(
      hasPlanUrl: buyPlanUrl?.isNotEmpty ?? false,
      hasTrafficUrl: buyTrafficUrl?.isNotEmpty ?? false,
      daysLeft: isPerpetual ? null : daysLeft,
      total: hasQuota ? info.total : 0,
      used: used,
    );

    final label = profileLabel.isEmpty
        ? appLocalizations.metaInfo
        : profileLabel;
    final logo = serviceLogo;
    final profile = this.profile;

    return DashboardInfoCard(
      height: DashboardWidgetMetrics.heightOf(context, 2),
      icon: AppGlyphs.calendar,
      label: label,
      leading: logo == null || logo.isEmpty
          ? null
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
      action: profile != null && profile.type == ProfileType.url
          ? _UpdateAction(profile: profile)
          : const GlyphIcon(AppGlyphs.chevronForward, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const SubscriptionOverviewView()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final side = constraints.maxHeight.isFinite
                    ? constraints.maxHeight.clamp(0.0, 104.0)
                    : 88.0;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          status,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ExcludeSemantics(
                      child: SizedBox.square(
                        dimension: side,
                        child: hasQuota
                            ? _QuotaRing(
                                fraction: (1 - usedFraction).clamp(0.0, 1.0),
                                percent: freePercent,
                                color: ringColor,
                              )
                            : _StatusMedallion(
                                color: colorScheme.primary,
                                child: info == null
                                    ? GlyphIcon(
                                        AppGlyphs.calendar,
                                        size: 20,
                                        color: colorScheme.onSurfaceVariant,
                                      )
                                    : Text(
                                        '∞',
                                        style: context.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _Footer(
            offers: offers,
            trafficCaption: trafficCaption,
            trafficValue: trafficValue,
            buyPlanUrl: buyPlanUrl,
            buyTrafficUrl: buyTrafficUrl,
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.offers,
    required this.trafficCaption,
    required this.trafficValue,
    required this.buyPlanUrl,
    required this.buyTrafficUrl,
  });

  final List<HeroBuyOffer> offers;
  final String trafficCaption;
  final String trafficValue;
  final String? buyPlanUrl;
  final String? buyTrafficUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: offers.isEmpty
              ? Text(
                  trafficCaption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                )
              // The caption only names the number beside it; an offer that is
              // live right now is worth more than the repetition.
              : _BuyOfferRow(
                  offers: offers,
                  buyPlanUrl: buyPlanUrl,
                  buyTrafficUrl: buyTrafficUrl,
                ),
        ),
        const SizedBox(width: 12),
        Text(
          trafficValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
            fontFamily: FontFamily.jetBrainsMono.value,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuotaRing extends StatelessWidget {
  const _QuotaRing({
    required this.fraction,
    required this.percent,
    required this.color,
  });

  /// Remaining quota, 0..1. The arc depletes as the subscription is spent.
  final double fraction;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final trackColor = WallpaperSurfaceScope.colorOf(
      context,
      colorScheme.onSurface.withValues(alpha: 0.10),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: context.motionDuration(const Duration(milliseconds: 640)),
      curve: Easing.standard,
      builder: (context, value, child) => CustomPaint(
        key: const ValueKey('subscription-ring'),
        painter: _QuotaRingPainter(
          fraction: value,
          color: color,
          trackColor: trackColor,
        ),
        child: child,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FittedBox(
            child: Text(
              '$percent%',
              style: context.textTheme.titleMedium?.copyWith(
                fontFamily: FontFamily.jetBrainsMono.value,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuotaRingPainter extends CustomPainter {
  const _QuotaRingPainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
  });

  final double fraction;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = (size.shortestSide * 0.12).clamp(5.0, 11.0);
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    if (radius <= 0) return;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);
    if (fraction <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.6), color],
        transform: const GradientRotation(-pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -pi / 2, 2 * pi * fraction.clamp(0.0, 1.0), false, arc);
  }

  @override
  bool shouldRepaint(_QuotaRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

class _StatusMedallion extends StatelessWidget {
  const _StatusMedallion({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final trackColor = WallpaperSurfaceScope.colorOf(
      context,
      color.withValues(alpha: 0.28),
    );
    return CustomPaint(
      painter: _QuotaRingPainter(
        fraction: 0,
        color: color,
        trackColor: trackColor,
      ),
      child: Center(child: FittedBox(child: child)),
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
          if (offer != offers.first) const SizedBox(width: 4),
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
                padding: EdgeInsets.all(8),
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
