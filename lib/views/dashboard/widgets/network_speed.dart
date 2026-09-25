import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkSpeed extends StatefulWidget {
  const NetworkSpeed({super.key});

  @override
  State<NetworkSpeed> createState() => _NetworkSpeedState();
}

class _NetworkSpeedState extends State<NetworkSpeed> {
  static const _chartDuration = Duration(milliseconds: 400);

  List<Point> initPoints = const [Point(0, 0), Point(1, 0)];

  List<Point> _getPoints(List<Traffic> traffics) {
    final trafficPoints = <Point>[];
    for (var index = 0; index < traffics.length; index++) {
      trafficPoints.add(
        Point(
          (index + initPoints.length).toDouble(),
          traffics[index].speed.toDouble(),
        ),
      );
    }

    return [...initPoints, ...trafficPoints];
  }

  Traffic _getLastTraffic(List<Traffic> traffics) {
    if (traffics.isEmpty) return const Traffic();
    return traffics.last;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final color = context.colorScheme.onSurfaceVariant.opacity80;
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 2),
      child: RepaintBoundary(
        child: CommonCard(
          radius: DashboardWidgetMetrics.radiusOf(context),
          onPressed: () {},
          child: Consumer(
            builder: (_, ref, _) {
              final traffics = ref.watch(trafficsProvider).list;
              return Column(
                children: [
                  Padding(
                    padding: DashboardWidgetMetrics.paddingOf(
                      context,
                    ).copyWith(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: InfoHeader(
                            padding: EdgeInsets.zero,
                            info: Info(
                              label: appLocalizations.networkSpeed,
                              glyph: AppGlyphs.speed,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _getLastTraffic(traffics).speedText,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16,
                      ).copyWith(bottom: 0, left: 0, right: 0),
                      child: LineChart(
                        gradient: true,
                        color: Theme.of(context).colorScheme.primary,
                        points: _getPoints(traffics),
                        duration: context.motionDuration(_chartDuration),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
