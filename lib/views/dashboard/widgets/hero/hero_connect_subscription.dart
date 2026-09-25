part of 'hero_connect.dart';

class _SubscriptionStrip extends StatelessWidget {
  const _SubscriptionStrip({
    super.key,
    required this.sub,
    this.buyPlanUrl,
    this.buyTrafficUrl,
    this.hasAnnounce = false,
  });

  final SubscriptionInfo sub;
  final String? buyPlanUrl;
  final String? buyTrafficUrl;
  final bool hasAnnounce;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final used = sub.upload + sub.download;
    final total = sub.total;
    final unlimited = total <= 0;
    final progress = unlimited ? 0.0 : (used / total).clamp(0.0, 1.0);
    final barColor = progress > 0.9
        ? colorScheme.error
        : progress > 0.7
        ? cautionColor
        : colorScheme.primary;

    final expireDate = subscriptionExpireDate(sub.expire);
    final now = DateTime.now();
    final expired = subscriptionIsExpired(expire: sub.expire, now: now);
    final expiresIn = expireDate?.difference(now).inDays;
    final daysLeft = expired
        ? null
        : expiresIn == null || expiresIn > 0
        ? expiresIn
        : 0;
    final daysUrgent = daysLeft != null && daysLeft <= heroRenewDaysThreshold;
    final daysColor = daysUrgent ? colorScheme.error : colorScheme.primary;

    final free = unlimited ? 0 : (total - used).clamp(0, total);
    final offers = heroBuyOffers(
      hasPlanUrl: buyPlanUrl?.isNotEmpty ?? false,
      hasTrafficUrl: buyTrafficUrl?.isNotEmpty ?? false,
      daysLeft: daysLeft,
      total: total,
      used: used,
    );
    final valueStyle = context.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontFamily: FontFamily.jetBrainsMono.value,
    );

    return HeroSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // A wrap instead of a row: at large text scales the caption and
              // the pill no longer share one line, and neither may be clipped.
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      appLocalizations.subscriptionCaption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (expired)
                      _SubscriptionPill(
                        color: colorScheme.error,
                        label: context
                            .appLocalizations
                            .dashboardSubscriptionExpired,
                      )
                    else if (daysLeft != null)
                      _SubscriptionPill(
                        color: daysColor,
                        label:
                            '${context.appLocalizations.remaining} $daysLeft ${heroDaysWord(daysLeft)}',
                      ),
                  ],
                ),
              ),
              if (hasAnnounce) ...[
                const SizedBox(width: AppSpacing.sm),
                GlyphIcon(
                  AppGlyphs.announce,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
              const SizedBox(width: AppSpacing.xs),
              GlyphIcon(
                AppGlyphs.chevronForward,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (unlimited)
            Text(
              used.traffic.show,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: free.traffic.show, style: valueStyle),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: appLocalizations.trafficFreeOfTotal(
                      total.traffic.show,
                    ),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (!unlimited) ...[
            const SizedBox(height: AppSpacing.md),
            _SubscriptionBar(
              progress: progress <= 0 ? 0.0 : progress,
              color: barColor,
            ),
          ],
          if (offers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final offer in offers) ...[
                  if (offer != offers.first)
                    const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: _BuyChip(
                      offer: offer,
                      url: offer == HeroBuyOffer.renewPlan
                          ? buyPlanUrl!
                          : buyTrafficUrl!,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SubscriptionPill extends StatelessWidget {
  const _SubscriptionPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(heroPillRadius),
      color: color.withValues(alpha: 0.14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlyphIcon(AppGlyphs.calendar, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SubscriptionBar extends StatelessWidget {
  const _SubscriptionBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final trackColor = context.colorScheme.surfaceContainerHighest;
    final gradient = LinearGradient(
      colors: [color.withValues(alpha: 0.7), color],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(heroInlayRadius),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: progress, end: progress),
        duration: context.motionDuration(const Duration(milliseconds: 420)),
        curve: Easing.standard,
        builder: (context, value, _) => CustomPaint(
          size: const Size(double.infinity, 8),
          painter: _SubscriptionBarPainter(
            progress: value,
            trackColor: trackColor,
            gradient: gradient,
          ),
        ),
      ),
    );
  }
}

class _SubscriptionBarPainter extends CustomPainter {
  const _SubscriptionBarPainter({
    required this.progress,
    required this.trackColor,
    required this.gradient,
  });

  final double progress;
  final Color trackColor;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..color = trackColor;
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        rect,
        const Radius.circular(heroInlayRadius),
      ),
      paint,
    );
    if (progress <= 0) return;
    final fillPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        Offset.zero & Size(size.width * progress, size.height),
        const Radius.circular(heroInlayRadius),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_SubscriptionBarPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.gradient != gradient;
}

class _BuyChip extends StatelessWidget {
  const _BuyChip({required this.offer, required this.url});

  final HeroBuyOffer offer;
  final String url;

  @override
  Widget build(BuildContext context) {
    final view = heroBuyOfferViewOf(context.appLocalizations, offer);
    return _ActionChip(
      icon: view.icon,
      label: view.label,
      compact: true,
      onTap: () => unawaited(dialogs.openUrl(url)),
    );
  }
}
