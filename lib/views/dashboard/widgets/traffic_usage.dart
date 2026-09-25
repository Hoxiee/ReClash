import 'dart:math';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/finding_preview.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrafficUsage extends StatelessWidget {
  const TrafficUsage({super.key, this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 2),
      child: RepaintBoundary(
        child: CommonCard(
          radius: DashboardWidgetMetrics.radiusOf(context),
          infoPadding: DashboardWidgetMetrics.paddingOf(
            context,
          ).copyWith(bottom: 0),
          info: Info(
            label: appLocalizations.trafficUsage,
            iconData: AppGlyphs.dataUsage,
          ),
          onPressed: () {},
          child: preview
              ? const _PreviewTrafficUsage()
              : Consumer(
                  builder: (_, ref, _) {
                    final totalTraffic = ref.watch(totalTrafficProvider);
                    final rolling = ref.watch(
                      visibleMilestonesProvider.select(
                        (state) => state.unlocked.contains('odometer'),
                      ),
                    );
                    return _TrafficUsageBody(
                      up: totalTraffic.up,
                      down: totalTraffic.down,
                      rolling: rolling,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _PreviewTrafficUsage extends StatefulWidget {
  const _PreviewTrafficUsage();

  @override
  State<_PreviewTrafficUsage> createState() => _PreviewTrafficUsageState();
}

class _PreviewTrafficUsageState extends State<_PreviewTrafficUsage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations || !TickerMode.valuesOf(context).enabled) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _clock,
    builder: (_, _) => _TrafficUsageBody(
      up: 120 * 1024 * 1024 + (_clock.value * 16).floor() * 1024 * 1024,
      down: 480 * 1024 * 1024 + (_clock.value * 16).floor() * 4 * 1024 * 1024,
      rolling: true,
    ),
  );
}

class _TrafficUsageBody extends StatelessWidget {
  const _TrafficUsageBody({
    required this.up,
    required this.down,
    required this.rolling,
  });

  final num up;
  final num down;
  final bool rolling;

  @override
  Widget build(BuildContext context) {
    final upColor = globalState.theme.darken3PrimaryContainer;
    final downColor = globalState.theme.darken2SecondaryContainer;
    return Padding(
      padding: DashboardWidgetMetrics.paddingOf(context).copyWith(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: _TrafficChart(
              up: up,
              down: down,
              upColor: upColor,
              downColor: downColor,
            ),
          ),
          _TrafficDataItem(
            icon: GlyphIcon(AppGlyphs.arrowUp, color: upColor, size: 14),
            value: up,
            rolling: rolling,
          ),
          const SizedBox(height: 8),
          _TrafficDataItem(
            icon: GlyphIcon(AppGlyphs.arrowDown, color: downColor, size: 14),
            value: down,
            rolling: rolling,
          ),
        ],
      ),
    );
  }
}

class _TrafficChart extends StatelessWidget {
  const _TrafficChart({
    required this.up,
    required this.down,
    required this.upColor,
    required this.downColor,
  });

  final num up;
  final num down;
  final Color upColor;
  final Color downColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DonutChart(
              data: [
                DonutChartData(value: up.toDouble(), color: upColor),
                DonutChartData(value: down.toDouble(), color: downColor),
              ],
              duration: context.motionDuration(commonDuration),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: _TrafficLegend(upColor: upColor, downColor: downColor),
          ),
        ],
      ),
    );
  }
}

class _TrafficLegend extends StatelessWidget {
  const _TrafficLegend({required this.upColor, required this.downColor});

  final Color upColor;
  final Color downColor;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final labelStyle = context.textTheme.bodySmall;
    return LayoutBuilder(
      builder: (_, container) {
        final uploadLabel = _label(appLocalizations.upload, labelStyle);
        final downloadLabel = _label(appLocalizations.download, labelStyle);
        final maxLabelWidth = max(
          globalState.measure.computeTextSize(uploadLabel).width,
          globalState.measure.computeTextSize(downloadLabel).width,
        );
        if (maxLabelWidth + 24 > container.maxWidth) {
          return Container();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendEntry(color: upColor, label: uploadLabel),
            const SizedBox(height: 4),
            _LegendEntry(color: downColor, label: downloadLabel),
          ],
        );
      },
    );
  }

  Text _label(String text, TextStyle? style) {
    return Text(
      maxLines: 1,
      text,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final Text label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 8,
          decoration: ShapeDecoration(color: color, shape: AppShape.full),
        ),
        const SizedBox(width: 4),
        label,
      ],
    );
  }
}

class _TrafficDataItem extends StatelessWidget {
  const _TrafficDataItem({
    required this.icon,
    required this.value,
    required this.rolling,
  });

  final GlyphIcon icon;
  final num value;
  final bool rolling;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: _RollingTrafficValue(
                  value: value.traffic.value,
                  rolling: rolling,
                ),
              ),
            ],
          ),
        ),
        Text(value.traffic.unit, style: context.textTheme.bodySmall?.toLighter),
      ],
    );
  }
}

class _RollingTrafficValue extends StatelessWidget {
  const _RollingTrafficValue({required this.value, required this.rolling});

  final String value;
  final bool rolling;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      value,
      key: ValueKey(value),
      style: context.textTheme.bodySmall,
      maxLines: 1,
    );
    if (!rolling || context.disableAnimations) return text;
    return Semantics(
      label: value,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < value.length; index++)
              ClipRect(
                key: ValueKey(value.length - index),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    final offset =
                        Tween<Offset>(
                          begin: const Offset(0, 0.9),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        );
                    return SlideTransition(
                      position: offset,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    value[index],
                    key: ValueKey(value[index]),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
