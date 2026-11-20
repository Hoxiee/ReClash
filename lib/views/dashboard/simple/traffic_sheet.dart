import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart' show HapticFeedback;
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
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/traffic_card.dart';
import 'package:reclash/views/dashboard/style.dart';

Future<void> showTrafficUsageSheet(BuildContext context) => showSheet<void>(
  context: context,
  builder: (_) => const TrafficUsageSheet(),
);

enum _Period { week, month, all }

const _monthDays = 30;

/// What is left of the current subscription's plan, and its daily spending.
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
    final today = usageDayOf(DateTime.now());
    final recorded = days.isEmpty
        ? null
        : days.map((day) => day.day).reduce(math.min);
    final first = switch (_period) {
      _Period.week => today - usageWindowDays + 1,
      _Period.month => today - _monthDays + 1,
      _Period.all => math.max(
        recorded ?? today,
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
          _Plan(info: info, metadata: metadata, days: days, today: today),
          SegmentedControl<_Period>(
            segments: [
              (_Period.week, appLocalizations.usagePeriodWeek),
              (_Period.month, appLocalizations.usagePeriodMonth),
              (_Period.all, appLocalizations.usagePeriodAll),
            ],
            value: _period,
            onChanged: (period) => setState(() => _period = period),
          ),
          _Spending(
            days: days,
            first: first,
            today: today,
            recorded: recorded,
            comparable: _period != _Period.all,
          ),
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

String _nonBreaking(String text) => text.replaceAll(' ', ' ');

NumberFormat _percentFormat(BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  return NumberFormat.percentPattern(
    NumberFormat.localeExists(locale) ? locale : 'en',
  );
}

class _Figure extends StatelessWidget {
  const _Figure({required this.bytes, this.suffix, this.color});

  final int bytes;
  final String? suffix;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final (:value, :unit) = bytes.trafficParts;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: DashboardText.figure(
              context,
              AppTextStyle.largeTitle,
              color: color,
            ),
          ),
          TextSpan(text: ' $unit', style: DashboardText.unit(context)),
          if (suffix != null)
            TextSpan(
              text: '  $suffix',
              style: AppTextStyle.subheadline
                  .of(context)
                  .toTabular
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({
    required this.info,
    required this.metadata,
    required this.days,
    required this.today,
  });

  final SubscriptionInfo info;
  final SubscriptionMetadata metadata;
  final List<UsageDay> days;
  final int today;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = DashboardColors.of(context);
    final (:figure, :lines, :alarming, :kind) = readTrafficForecast(
      context,
      info: info,
      metadata: metadata,
      days: days,
    );
    final tight = alarming || kind == TrafficForecastKind.early;
    final used = info.upload + info.download;
    final limited = !metadata.unlimited && info.total > 0;
    final left = math.max(info.total - used, 0);
    final ends = metadata.perpetual ? null : info.expireDate;
    final label = DashboardText.label(context);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text(
            limited ? appLocalizations.usageLeft : appLocalizations.usageUsed,
            style: label,
          ),
          _Figure(
            bytes: limited ? left : used,
            suffix: limited
                ? appLocalizations.usageOfTotal(
                    _nonBreaking(dashboardTraffic(info.total)),
                  )
                : null,
            color: alarming ? colors.warn : null,
          ),
          if (limited) ...[
            const SizedBox(height: 8),
            _QuotaBar(
              left: left / info.total,
              color: tight ? colors.warn : context.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    '${appLocalizations.usageUsed} '
                    '${_nonBreaking(dashboardTraffic(used))}',
                    style: label,
                  ),
                ),
                Text(
                  _percentFormat(context).format(used / info.total),
                  style: label,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            figure,
            style: DashboardText.figure(
              context,
              AppTextStyle.title3,
              color: tight ? colors.warn : null,
            ),
          ),
          Text(
            [
              ...lines,
              if (ends != null)
                appLocalizations.usagePlanEndsIn(
                  math.max(usageDayOf(ends) - today, 0),
                  MaterialLocalizations.of(context).formatShortMonthDay(ends),
                ),
            ].join('\n'),
            style: label.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _QuotaBar extends StatelessWidget {
  const _QuotaBar({required this.left, required this.color});

  static const _height = 10.0;

  final double left;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: DashboardColors.of(context).track,
          shape: AppShape.full,
        ),
        child: SizedBox(
          height: _height,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: left.clamp(0.0, 1.0)),
              duration: context.motionDuration(
                const Duration(milliseconds: 360),
              ),
              curve: Curves.easeOutCubic,
              builder: (context, fill, _) => FractionallySizedBox(
                widthFactor: fill,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: color,
                    shape: AppShape.full,
                  ),
                  child: const SizedBox(height: _height),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Spending extends StatefulWidget {
  const _Spending({
    required this.days,
    required this.first,
    required this.today,
    required this.recorded,
    required this.comparable,
  });

  final List<UsageDay> days;
  final int first;
  final int today;

  /// The first day with a sample; days before it hold no data, not zero.
  final int? recorded;
  final bool comparable;

  @override
  State<_Spending> createState() => _SpendingState();
}

class _SpendingState extends State<_Spending> {
  int? _selected;

  @override
  void didUpdateWidget(_Spending oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.first != widget.first || oldWidget.today != widget.today) {
      _selected = null;
    }
  }

  void _select(int? day) {
    if (day == _selected) return;
    if (day != null) unawaited(HapticFeedback.selectionClick());
    setState(() => _selected = day);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final first = widget.first;
    final today = widget.today;
    final recorded = widget.recorded;
    final spent = {for (final day in widget.days) day.day: day.bytes};
    int sum(int from, int to) {
      var total = 0;
      for (var day = from; day <= to; day++) {
        total += spent[day] ?? 0;
      }
      return total;
    }

    final range = [for (var day = first; day <= today; day++) day];
    final total = sum(first, today);
    final completeFrom = math.max(first, recorded ?? today);
    final complete = today - completeFrom;
    final average = complete > 0
        ? sum(completeFrom, today - 1) ~/ complete
        : null;
    final peak = range.map((day) => spent[day] ?? 0).fold(0, math.max);
    final previousFirst = first - range.length;
    final previous =
        widget.comparable && recorded != null && recorded <= previousFirst
        ? sum(previousFirst, first - 1) / range.length
        : null;
    final change = average != null && previous != null && previous > 0
        ? average / previous - 1
        : null;
    final selected = _selected;
    final label = DashboardText.label(context);
    final known = selected == null || recorded == null || selected >= recorded;
    final heading = switch (selected) {
      null => appLocalizations.usagePeriodTotal,
      final day when day == today => appLocalizations.usagePeriodToday,
      final day => MaterialLocalizations.of(
        context,
      ).formatMediumDate(usageDateOf(day)),
    };
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text(heading, style: label),
          if (known)
            _Figure(bytes: selected == null ? total : spent[selected] ?? 0)
          else
            Text(
              '—',
              style: DashboardText.figure(context, AppTextStyle.largeTitle),
            ),
          Text(
            selected == null && change != null
                ? _changeText(context, change)
                : '',
            style: label,
          ),
          const SizedBox(height: 12),
          _DayChart(
            range: range,
            spent: spent,
            today: today,
            recorded: recorded,
            peak: peak,
            average: average,
            selected: selected,
            onSelect: _select,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _Stat(
                title: appLocalizations.usagePeriodToday,
                value: dashboardTraffic(spent[today] ?? 0),
              ),
              _Stat(
                title: appLocalizations.usageAverage,
                value: average == null ? '—' : dashboardTraffic(average),
              ),
              _Stat(
                title: appLocalizations.usagePeak,
                value: peak == 0 ? '—' : dashboardTraffic(peak),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _changeText(BuildContext context, double change) {
    final percent = _percentFormat(context).format(change.abs());
    final sign = switch ((change * 100).round()) {
      > 0 => '+',
      < 0 => '−',
      _ => '',
    };
    return context.appLocalizations.usageChange(_nonBreaking('$sign$percent'));
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: DashboardColors.of(context).tone,
          shape: AppShape.md,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.subheadline
                    .of(context, emphasized: true)
                    .toTabular,
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DashboardText.label(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One bar a day; a tap, drag, or hover picks the day the header shows.
class _DayChart extends StatelessWidget {
  const _DayChart({
    required this.range,
    required this.spent,
    required this.today,
    required this.recorded,
    required this.peak,
    required this.average,
    required this.selected,
    required this.onSelect,
  });

  static const _height = 112.0;
  static const _floor = 4.0;
  static const _maxWidth = 24.0;
  static const _labelWidth = 64.0;

  final List<int> range;
  final Map<int, int> spent;
  final int today;
  final int? recorded;
  final int peak;
  final int? average;
  final int? selected;
  final ValueChanged<int?> onSelect;

  double _barHeight(int bytes) =>
      _floor + (_height - _floor) * (peak == 0 ? 0 : bytes / peak);

  Color _barColor(BuildContext context, int day) {
    final recorded = this.recorded;
    if (recorded == null || day < recorded) {
      return DashboardColors.of(context).track;
    }
    final highlighted = selected == null ? day == today : day == selected;
    return highlighted
        ? context.colorScheme.primary
        : DashboardColors.of(context).series2;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weekday = DateFormat.E(
      DateFormat.localeExists(locale) ? locale : 'en',
    );
    final count = range.length;
    final gap = count > 31 ? 2.0 : 4.0;
    final step = count <= usageWindowDays ? 1 : (count > 31 ? 14 : 7);
    final label = AppTextStyle.caption2
        .of(context)
        .toTabular
        .copyWith(color: colorScheme.onSurfaceVariant);
    final strong = AppTextStyle.caption2
        .of(context, emphasized: true)
        .toTabular
        .copyWith(color: colorScheme.onSurface);
    final average = this.average;
    final marked = selected ?? today;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final bar = math.min(_maxWidth, (width - gap * (count - 1)) / count);
          final pitch = count == 1 ? 0.0 : (width - bar) / (count - 1);
          double centerOf(int index) =>
              count == 1 ? width / 2 : bar / 2 + pitch * index;
          int? dayAt(double dx) {
            if (dx < 0 || dx > width) return null;
            final index = count == 1
                ? 0
                : ((dx - bar / 2) / pitch).round().clamp(0, count - 1);
            return range[index];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              MouseRegion(
                onHover: (event) => onSelect(dayAt(event.localPosition.dx)),
                onExit: (_) => onSelect(null),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    final day = dayAt(details.localPosition.dx);
                    onSelect(day == selected ? null : day);
                  },
                  onHorizontalDragStart: (details) =>
                      onSelect(dayAt(details.localPosition.dx)),
                  onHorizontalDragUpdate: (details) =>
                      onSelect(dayAt(details.localPosition.dx)),
                  child: SizedBox(
                    height: _height,
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: count == 1
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final day in range)
                              _Bar(
                                width: bar,
                                height: _barHeight(spent[day] ?? 0),
                                color: _barColor(context, day),
                              ),
                          ],
                        ),
                        if (average != null && average > 0 && peak > 0)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: _height - _barHeight(average),
                            child: CustomPaint(
                              size: const Size.fromHeight(1),
                              painter: _DashPainter(
                                colorScheme.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: label.fontSize! * 1.4,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var index = count - 1; index >= 0; index -= step)
                      Positioned(
                        top: 0,
                        width: _labelWidth,
                        left: (centerOf(index) - _labelWidth / 2).clamp(
                          0.0,
                          math.max(width - _labelWidth, 0.0),
                        ),
                        child: Text(
                          step == 1
                              ? weekday.format(usageDateOf(range[index]))
                              : localizations.formatShortMonthDay(
                                  usageDateOf(range[index]),
                                ),
                          maxLines: 1,
                          textAlign: switch (centerOf(index)) {
                            final x when x < _labelWidth / 2 => TextAlign.start,
                            final x when x > width - _labelWidth / 2 =>
                              TextAlign.end,
                            _ => TextAlign.center,
                          },
                          style: range[index] == marked ? strong : label,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(const Duration(milliseconds: 240));
    return TweenAnimationBuilder<double>(
      tween: Tween(end: height),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, height, _) => AnimatedContainer(
        duration: duration,
        width: width,
        height: height,
        decoration: ShapeDecoration(color: color, shape: AppShape.full),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  static const _dash = 4.0;
  static const _space = 4.0;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += _dash + _space) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + _dash, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
