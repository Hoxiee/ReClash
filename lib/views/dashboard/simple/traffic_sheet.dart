import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/traffic_forecast/forecast.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/traffic_card.dart';
import 'package:reclash/views/dashboard/style.dart';

Future<void> showTrafficUsageSheet(BuildContext context) => showSheet<void>(
  context: context,
  builder: (_) => const TrafficUsageSheet(),
);

enum _Period { today, week, month, all }

/// The current subscription's daily spending by period, and its plan.
class TrafficUsageSheet extends ConsumerStatefulWidget {
  const TrafficUsageSheet({super.key});

  @override
  ConsumerState<TrafficUsageSheet> createState() => _TrafficUsageSheetState();
}

class _TrafficUsageSheetState extends ConsumerState<TrafficUsageSheet> {
  _Period _period = _Period.week;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final info = profile?.type == ProfileType.url
        ? profile?.subscriptionInfo
        : null;
    if (profile == null || info == null) return const SizedBox.shrink();
    final metadata =
        profile.subscriptionSnapshot?.metadata ?? const SubscriptionMetadata();
    final days =
        ref.watch(trafficUsageProvider(profile.id)).value ?? const <UsageDay>[];
    final topUp = trafficTopUpLink(metadata);
    final now = DateTime.now();
    final today = usageDayOf(now);
    final first = switch (_period) {
      _Period.today => today,
      _Period.week => today - usageWindowDays + 1,
      _Period.month => usageDayOf(DateTime(now.year, now.month)),
      _Period.all => math.max(
        days.isEmpty ? today : days.map((day) => day.day).reduce(math.min),
        today - usageRetentionDays + 1,
      ),
    };
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + context.bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            appLocalizations.usageSheetTitle,
            textAlign: TextAlign.center,
            style: AppTextStyle.title3.of(context, emphasized: true),
          ),
          SegmentedControl<_Period>(
            segments: [
              (_Period.today, appLocalizations.usagePeriodToday),
              (_Period.week, appLocalizations.usagePeriodWeek),
              (_Period.month, appLocalizations.usagePeriodMonth),
              (_Period.all, appLocalizations.usagePeriodAll),
            ],
            value: _period,
            onChanged: (period) => setState(() => _period = period),
          ),
          _Spending(days: days, first: first, today: today),
          _Plan(info: info, metadata: metadata, days: days),
          if (topUp != null)
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                unawaited(dialogs.openUrl(topUp.toString()));
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              iconAlignment: IconAlignment.end,
              icon: const GlyphIcon(AppGlyphs.openExternal, size: 18, fill: 1),
              label: Text(appLocalizations.topUpTraffic),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: DashboardColors.of(context).card,
        shape: AppShape.xl,
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _Spending extends StatelessWidget {
  const _Spending({
    required this.days,
    required this.first,
    required this.today,
  });

  final List<UsageDay> days;
  final int first;
  final int today;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final spent = {for (final day in days) day.day: day.bytes};
    final range = [for (var day = first; day <= today; day++) day];
    final total = range.fold(0, (sum, day) => sum + (spent[day] ?? 0));
    final (:value, :unit) = total.trafficParts;
    final perDay = range.length > 1 && total > 0 ? total ~/ range.length : null;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: DashboardText.figure(context, AppTextStyle.largeTitle),
                ),
                TextSpan(text: ' $unit', style: DashboardText.unit(context)),
              ],
            ),
          ),
          if (perDay != null)
            Text(
              appLocalizations.simpleForecastPace(
                dashboardTraffic(perDay).replaceAll(' ', '\u00a0'),
              ),
              style: DashboardText.label(context),
            ),
          if (range.length > 1) ...[
            const SizedBox(height: 12),
            _DayBars(range: range, spent: spent, today: today),
          ],
        ],
      ),
    );
  }
}

class _DayBars extends StatelessWidget {
  const _DayBars({
    required this.range,
    required this.spent,
    required this.today,
  });

  static const _height = 96.0;
  static const _floor = 4.0;
  static const _maxWidth = 16.0;

  final List<int> range;
  final Map<int, int> spent;
  final int today;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final localizations = MaterialLocalizations.of(context);
    final peak = range.map((day) => spent[day] ?? 0).fold(0, math.max);
    final gap = range.length > 31 ? 2.0 : 4.0;
    final label = AppTextStyle.caption2
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          SizedBox(
            height: _height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = math.min(
                  _maxWidth,
                  (constraints.maxWidth - gap * (range.length - 1)) /
                      range.length,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in range)
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          end: peak == 0 ? 0 : (spent[day] ?? 0) / peak,
                        ),
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
                            width: width,
                            height: _floor + (_height - _floor) * fill,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.formatShortMonthDay(usageDateOf(range.first)),
                style: label,
              ),
              Text(
                localizations.formatShortMonthDay(usageDateOf(range.last)),
                style: label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({required this.info, required this.metadata, required this.days});

  final SubscriptionInfo info;
  final SubscriptionMetadata metadata;
  final List<UsageDay> days;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = DashboardColors.of(context);
    final (:figure, :lines, :alarming) = readTrafficForecast(
      context,
      info: info,
      metadata: metadata,
      days: days,
      pace: false,
    );
    final used = info.upload + info.download;
    final limited = !metadata.unlimited && info.total > 0;
    final ends = metadata.perpetual ? null : info.expireDate;
    final rows = [
      (
        appLocalizations.usageUsed,
        limited
            ? '${dashboardTraffic(used)} / ${dashboardTraffic(info.total)}'
            : dashboardTraffic(used),
      ),
      if (limited)
        (
          appLocalizations.usageLeft,
          dashboardTraffic(math.max(info.total - used, 0)),
        ),
      if (ends != null)
        (
          appLocalizations.usagePlanEnds,
          MaterialLocalizations.of(context).formatMediumDate(ends),
        ),
    ];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 8),
          for (final (title, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyle.subheadline
                          .of(context)
                          .copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyle.subheadline
                        .of(context, emphasized: true)
                        .toTabular,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
