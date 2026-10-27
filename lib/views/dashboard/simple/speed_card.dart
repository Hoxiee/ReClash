import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/speed_test/sheet.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/widgets/widgets.dart';

/// Mbit/s each step of the meter needs: messaging, HD, 4K, everything.
const _steps = [1.0, 5.0, 25.0, 100.0];

/// Where the first step starts filling on the log scale.
const _floor = 0.2;

/// The rate in what it is enough for, not as a dial nobody can read.
class SimpleSpeedCard extends ConsumerWidget {
  const SimpleSpeedCard({super.key});

  String _verdict(BuildContext context, double mbps) {
    final appLocalizations = context.appLocalizations;
    return switch (_steps.where((step) => mbps >= step).length) {
      0 => appLocalizations.simpleSpeedSlow,
      1 => appLocalizations.simpleSpeedChat,
      2 => appLocalizations.simpleSpeedHd,
      3 => appLocalizations.simpleSpeed4k,
      _ => appLocalizations.simpleSpeedAll,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final viaVpn = ref.watch(speedTestViaVpnProvider);
    final test = ref.watch(speedTestProvider);
    final notifier = ref.read(speedTestProvider.notifier);
    final mbps = test.mbps;
    final description = switch (test.phase) {
      SpeedTestPhase.running => appLocalizations.simpleSpeedMeasuring,
      SpeedTestPhase.failed => appLocalizations.simpleSpeedFailed,
      SpeedTestPhase.cancelled => appLocalizations.speedTestCancelled,
      _ when test.limited => appLocalizations.speedTestLimited,
      _ when mbps != null => _verdict(context, mbps),
      _ => appLocalizations.speedTestIdleDesc,
    };
    final stale =
        test.phase == SpeedTestPhase.failed ||
        (!test.running && test.viaVpn != viaVpn);
    final label = DashboardText.label(context);
    return DashboardCard(
      semanticLabel: appLocalizations.simpleSpeedTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.speed,
            title: appLocalizations.simpleSpeedTitle,
            trailing: [
              if (test.checkedAt != null && !test.running)
                LastUpdateTimeText(
                  lastUpdateDate: test.checkedAt,
                  compact: true,
                  style: label,
                ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mbps != null)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _figure(mbps),
                              style:
                                  DashboardText.figure(
                                    context,
                                    AppTextStyle.title1,
                                  ).copyWith(
                                    color: stale
                                        ? colorScheme.onSurfaceVariant
                                        : null,
                                  ),
                            ),
                            TextSpan(
                              text: ' ${appLocalizations.simpleSpeedUnit}',
                              style: DashboardText.unit(
                                context,
                                AppTextStyle.footnote,
                              ),
                            ),
                            if (!test.viaVpn)
                              TextSpan(
                                text:
                                    ' · ${appLocalizations.speedTestRouteSystem}',
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
                      description,
                      style:
                          (mbps == null
                                  ? label
                                  : AppTextStyle.subheadline.of(
                                      context,
                                      emphasized: true,
                                    ))
                              .copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
              if (test.running)
                FilledButton.tonalIcon(
                  onPressed: notifier.cancel,
                  icon: const CommonCircleLoading(size: 18),
                  label: Text(appLocalizations.cancel),
                )
              else
                FilledButton.tonal(
                  onPressed: () => unawaited(showSpeedTestSheet(context)),
                  child: Text(appLocalizations.speedTestOpen),
                ),
            ],
          ),
          _StepMeter(mbps: mbps ?? 0, muted: stale),
        ],
      ),
    );
  }

  static String _figure(double mbps) =>
      mbps < 10 ? mbps.toStringAsFixed(1) : mbps.round().toString();
}

/// Four steps named by what the rate is enough for, each filling on a log
/// scale up to the rate it needs.
class _StepMeter extends StatelessWidget {
  const _StepMeter({required this.mbps, required this.muted});

  final double mbps;
  final bool muted;

  double _fill(int index) {
    if (mbps <= 0) return 0;
    final low = math.log(index == 0 ? _floor : _steps[index - 1]);
    final high = math.log(_steps[index]);
    return ((math.log(mbps) - low) / (high - low)).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final labels = [
      appLocalizations.simpleSpeedLevelChat,
      appLocalizations.simpleSpeedLevelHd,
      appLocalizations.simpleSpeedLevel4k,
      appLocalizations.simpleSpeedLevelAll,
    ];
    final ink = muted ? colorScheme.onSurfaceVariant : colorScheme.primary;
    final caption = AppTextStyle.caption2.of(context);
    return Row(
      spacing: 4,
      children: [
        for (final (index, text) in labels.indexed)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: _fill(index)),
                  duration: context.motionDuration(
                    const Duration(milliseconds: 240),
                  ),
                  curve: Curves.easeOutCubic,
                  builder: (context, fill, _) => DecoratedBox(
                    decoration: ShapeDecoration(
                      color: colors.tone,
                      shape: AppShape.full,
                    ),
                    child: SizedBox(
                      height: 6,
                      width: double.infinity,
                      child: FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: fill,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: ink,
                            shape: AppShape.full,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: caption.copyWith(
                    color: _fill(index) >= 1
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
