import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/traffic_forecast/forecast.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/dashboard/widgets/profile_detail.dart';
import 'package:reclash/widgets/widgets.dart';

const _barWidth = 12.0;
const _barFloor = 4.0;
const _barRange = 38.0;

/// Whether the quota lasts, as the day it runs out at the recent pace.
class SimpleTrafficCard extends ConsumerWidget {
  const SimpleTrafficCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final info = profile?.type == ProfileType.url
        ? profile?.subscriptionInfo
        : null;
    final metadata =
        profile?.subscriptionSnapshot?.metadata ?? const SubscriptionMetadata();
    final days = profile == null || info == null
        ? const <UsageDay>[]
        : ref.watch(trafficUsageProvider(profile.id)).value ??
              const <UsageDay>[];
    final topUp = switch (metadata.text('provider.buyTrafficUrl')) {
      final value? => safeSubscriptionLink(value),
      null => null,
    };
    return DashboardCard(
      semanticLabel: appLocalizations.simpleForecastTitle,
      onTap: profile == null || info == null
          ? null
          : () => showProfileDetailSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.dataUsage,
            title: appLocalizations.simpleForecastTitle,
            trailing: [
              if (topUp != null)
                TextButton(
                  onPressed: () => unawaited(dialogs.openUrl(topUp.toString())),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(appLocalizations.topUpTraffic),
                ),
            ],
          ),
          if (info == null)
            Text(
              appLocalizations.simpleForecastUnknown,
              style: DashboardText.label(context).copyWith(height: 1.3),
            )
          else
            _Forecast(info: info, metadata: metadata, days: days),
        ],
      ),
    );
  }
}

class _Forecast extends StatelessWidget {
  const _Forecast({
    required this.info,
    required this.metadata,
    required this.days,
  });

  final SubscriptionInfo info;
  final SubscriptionMetadata metadata;
  final List<UsageDay> days;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = DashboardColors.of(context);
    final now = DateTime.now();
    final unlimited = metadata.unlimited || info.total <= 0;
    final forecast = unlimited
        ? TrafficForecast(
            TrafficForecastKind.plenty,
            perDay: usagePace(days, usageDayOf(now)),
          )
        : forecastTraffic(
            days: days,
            used: info.upload + info.download,
            total: info.total,
            expiry: metadata.perpetual ? null : info.expireDate,
            now: now,
          );
    final perDay = forecast.perDay;
    final runsOut = forecast.runsOut;
    final figure = switch (forecast.kind) {
      _ when unlimited => appLocalizations.simpleForecastUnlimited,
      TrafficForecastKind.gathering => appLocalizations.simpleForecastGathering,
      TrafficForecastKind.depleted => appLocalizations.simpleForecastDepleted,
      TrafficForecastKind.plenty => appLocalizations.simpleForecastPlenty,
      TrafficForecastKind.lasts => appLocalizations.simpleForecastLasts,
      TrafficForecastKind.until ||
      TrafficForecastKind.early => appLocalizations.simpleForecastUntil(
        MaterialLocalizations.of(context).formatShortMonthDay(runsOut!),
      ),
    };
    final lines = [
      if (forecast.kind == TrafficForecastKind.gathering)
        appLocalizations.simpleForecastGatheringHint,
      if (perDay != null && perDay > 0)
        appLocalizations.simpleForecastPace(
          dashboardTraffic(perDay).replaceAll(' ', ' '),
        ),
      if (forecast.kind == TrafficForecastKind.early)
        appLocalizations.simpleForecastEarly(forecast.daysEarly),
    ];
    final alarming = forecast.kind == TrafficForecastKind.depleted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 16,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                figure,
                style: DashboardText.figure(
                  context,
                  AppTextStyle.title2,
                ).copyWith(color: alarming ? colors.warn : null),
              ),
              if (lines.isNotEmpty)
                Text(
                  lines.join('\n'),
                  style: DashboardText.label(context).copyWith(height: 1.3),
                ),
            ],
          ),
        ),
        _WeekBars(days: days, today: usageDayOf(now)),
      ],
    );
  }
}

/// The last [usageWindowDays] days as bars, today in the primary colour.
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.days, required this.today});

  final List<UsageDay> days;
  final int today;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weekday = DateFormat.E(
      DateFormat.localeExists(locale) ? locale : 'en',
    );
    final spent = {for (final day in days) day.day: day.bytes};
    final week = [for (var i = today - usageWindowDays + 1; i <= today; i++) i];
    final peak = week.map((day) => spent[day] ?? 0).fold(0, math.max);
    final label = AppTextStyle.caption2
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    return ExcludeSemantics(
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 5,
          children: [
            for (final day in week)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 4,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: peak == 0 ? 0 : (spent[day] ?? 0) / peak),
                    duration: context.motionDuration(
                      const Duration(milliseconds: 240),
                    ),
                    curve: Curves.easeOutCubic,
                    builder: (context, fill, _) => DecoratedBox(
                      decoration: ShapeDecoration(
                        color: day == today
                            ? colorScheme.primary
                            : colors.series2,
                        shape: AppShape.full,
                      ),
                      child: SizedBox(
                        width: _barWidth,
                        height: _barFloor + _barRange * fill,
                      ),
                    ),
                  ),
                  Text(weekday.format(usageDateOf(day)), style: label),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
