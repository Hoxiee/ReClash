import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/number_text.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/notification/record.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/widgets/provider_image.dart';

/// The days a full ring stands for, a month's plan.
const _ringDays = 30;

typedef SubscriptionUsage = ({int used, int total, int expire});

/// The plan as two gauges a glance can read: what is left to spend and how
/// long it lasts, with the provider's actions.
class SubscriptionCardView extends StatelessWidget {
  const SubscriptionCardView({
    super.key,
    required this.hasProfile,
    required this.title,
    required this.metadata,
    required this.usage,
    required this.images,
    required this.onTap,
    required this.onOpenLink,
    this.subtitle,
    this.sync,
    this.hideActions = false,
  });

  final bool hasProfile;
  final String title;
  final SubscriptionMetadata metadata;

  /// Null hides the gauges.
  final SubscriptionUsage? usage;
  final ProviderImages images;
  final VoidCallback onTap;
  final void Function(Uri url) onOpenLink;
  final Widget? subtitle;
  final Widget? sync;

  /// The power button already offers renewing or topping up.
  final bool hideActions;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final colors = DashboardColors.of(context);
    final usage = this.usage;
    final support = switch (metadata.text('provider.supportUrl')) {
      final value? => safeSubscriptionSupportLink(value),
      null => null,
    };
    return DashboardCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 12,
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: colors.tone,
                  shape: AppShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Center(
                    child: SizedBox.square(
                      dimension: 22,
                      child: !hasProfile
                          ? const GlyphIcon(AppGlyphs.add, size: 22)
                          : images.logo(
                              metadata.logoFor(
                                    dark:
                                        context.colorScheme.brightness ==
                                        Brightness.dark,
                                  ) ??
                                  '',
                              fallback: const GlyphIcon(
                                AppGlyphs.profiles,
                                size: 22,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmojiText(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.headline.of(context),
                    ),
                    ?subtitle,
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?sync,
                  if (support != null)
                    DashboardIconButton(
                      glyph: AppGlyphs.support,
                      tooltip: appLocalizations.subscriptionProviderSupport,
                      onPressed: () => onOpenLink(support),
                    ),
                ],
              ),
            ],
          ),
          if (hasProfile && usage != null) ...[
            const SizedBox(height: 8),
            ..._gauges(context, usage, colors),
          ],
        ],
      ),
    );
  }

  List<Widget> _gauges(
    BuildContext context,
    SubscriptionUsage usage,
    DashboardColors colors,
  ) {
    final traffic = _trafficGauge(context, usage);
    final days = _daysGauge(context, usage, colors);
    final actions = hideActions
        ? const <_Action>[]
        : [?days.action, ?traffic.action];
    return [
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Expanded(child: traffic.gauge),
            Expanded(child: days.gauge),
          ],
        ),
      ),
      if (actions.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            for (final action in actions)
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => onOpenLink(action.url),
                  icon: const GlyphIcon(
                    AppGlyphs.openExternal,
                    size: 16,
                    fill: 1,
                  ),
                  label: Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ],
    ];
  }

  _Gauge _trafficGauge(BuildContext context, SubscriptionUsage usage) {
    final appLocalizations = AppLocalizations.of(context);
    final colorScheme = context.colorScheme;
    if (metadata.unlimited || usage.total <= 0) {
      return (
        gauge: _GaugeBlock(
          value: 1,
          glyph: AppGlyphs.dataUsage,
          figure: '∞',
          caption: appLocalizations.simpleTrafficUnlimited,
          color: colorScheme.primary,
        ),
        action: null,
      );
    }
    final used = usage.used;
    final left = math.max(0, usage.total - used);
    final levels = metadata.numbers('reminder.trafficPercent');
    final warnAt = (levels.isEmpty ? defaultTrafficNotifyPercent : levels)
        .reduce(math.min);
    final percent = usedPercent(used: used, total: usage.total);
    final low = percent >= warnAt;
    final buyAt = metadata.count('provider.buyTrafficPercent');
    final show = left.trafficParts;
    return (
      gauge: _GaugeBlock(
        value: left / usage.total,
        glyph: AppGlyphs.dataUsage,
        figure: show.value,
        unit: show.unit,
        caption: appLocalizations.simpleTrafficLeft(
          dashboardTraffic(usage.total).replaceAll(' ', '\u00a0'),
        ),
        color: low ? DashboardColors.of(context).warn : colorScheme.primary,
      ),
      action: _providerLink(
        metadata,
        'provider.buyTrafficUrl',
        appLocalizations.topUpTraffic,
        when: buyAt == null ? low : percent >= buyAt,
      ),
    );
  }

  _Gauge _daysGauge(
    BuildContext context,
    SubscriptionUsage usage,
    DashboardColors colors,
  ) {
    final appLocalizations = AppLocalizations.of(context);
    final expiry = metadata.perpetual
        ? null
        : subscriptionExpireDate(usage.expire);
    if (expiry == null) {
      return (
        gauge: _GaugeBlock(
          value: 1,
          glyph: AppGlyphs.clock,
          figure: '∞',
          caption: appLocalizations.simpleNoExpiry,
          color: colors.ok,
        ),
        action: null,
      );
    }
    final days = remainingDays(expire: usage.expire, now: DateTime.now());
    final thresholds = metadata.numbers('reminder.expireDays');
    final warnAt = (thresholds.isEmpty ? defaultExpireNotifyDays : thresholds)
        .reduce(math.max);
    final buyAt = metadata.count('provider.buyPlanDays');
    return (
      gauge: _GaugeBlock(
        value: days / _ringDays,
        glyph: AppGlyphs.clock,
        figure: '$days',
        unit: appLocalizations
            .simpleDaysCount(days)
            .replaceFirst('$days', '')
            .trim(),
        caption: appLocalizations.simpleUntilDate(
          MaterialLocalizations.of(context).formatShortMonthDay(expiry),
        ),
        color: days <= warnAt ? colors.warn : colors.ok,
      ),
      action: _providerLink(
        metadata,
        'provider.buyPlanUrl',
        appLocalizations.renewSubscription,
        when: days <= (buyAt ?? warnAt),
      ),
    );
  }
}

typedef _Action = ({String label, Uri url});

typedef _Gauge = ({Widget gauge, _Action? action});

_Action? _providerLink(
  SubscriptionMetadata metadata,
  String path,
  String label, {
  required bool when,
}) {
  if (!when) return null;
  final url = switch (metadata.text(path)) {
    final value? => safeSubscriptionLink(value),
    null => null,
  };
  return url == null ? null : (label: label, url: url);
}

class _GaugeBlock extends StatelessWidget {
  const _GaugeBlock({
    required this.value,
    required this.glyph,
    required this.figure,
    this.unit,
    required this.caption,
    required this.color,
  });

  final double value;
  final Glyph glyph;
  final String figure;
  final String? unit;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = DashboardColors.of(context);
    final unit = this.unit;
    return DashboardBlock(
      radius: DashboardCorner.mobileBlock,
      padding: const EdgeInsets.all(10),
      child: Row(
        spacing: 10,
        children: [
          SizedBox.square(
            dimension: 46,
            child: CustomPaint(
              painter: _RingPainter(
                value: value.clamp(0, 1).toDouble(),
                track: colors.tone2,
                color: color,
              ),
              child: Center(child: GlyphIcon(glyph, size: 18, color: color)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: figure,
                        style: DashboardText.figure(
                          context,
                          AppTextStyle.title2,
                        ),
                      ),
                      if (unit != null)
                        TextSpan(
                          text: ' $unit',
                          style: DashboardText.unit(
                            context,
                            AppTextStyle.footnote,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                ),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardText.label(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.track,
    required this.color,
  });

  static const _stroke = 5.0;

  final double value;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawArc(rect, 0, 2 * math.pi, false, paint..color = track)
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * value,
        false,
        paint..color = color,
      );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.track != track ||
      oldDelegate.color != color;
}
