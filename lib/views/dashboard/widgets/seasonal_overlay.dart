import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:reclash/common/seasonal.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:reclash/common/seasonal.dart';

class SeasonalDashboardOverlay extends ConsumerStatefulWidget {
  const SeasonalDashboardOverlay({
    super.key,
    required this.child,
    this.visible = true,
  });

  final bool visible;

  final Widget child;

  @override
  ConsumerState<SeasonalDashboardOverlay> createState() =>
      _SeasonalDashboardOverlayState();
}

class _SeasonalDashboardOverlayState
    extends ConsumerState<SeasonalDashboardOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(
      milestoneSettingProvider.select((state) => state.seasonalEnabled),
    );
    final status = heroStatusOf(
      ref.watch(heroLifecycleProvider),
      heroDoctorHealthOf(ref.watch(connectionDoctorProvider)),
    );
    final motif = ref.watch(visibleSeasonProvider);
    final subscription = ref.watch(currentProfileProvider)?.subscriptionInfo;
    final visible =
        widget.visible &&
        enabled &&
        motif == SeasonalMotif.newYear &&
        PageActivityScope.isActiveOf(context) &&
        (ModalRoute.of(context)?.isCurrent ?? true) &&
        !(subscription != null &&
            subscriptionIsExpired(
              expire: subscription.expire,
              now: DateTime.now(),
            )) &&
        status == HeroStatus.secured;
    final reduceMotion =
        context.disableAnimations || ref.watch(appSettingProvider).reduceMotion;
    if (visible && !reduceMotion && !_ticker.isAnimating) {
      _ticker.repeat();
    } else if ((!visible || reduceMotion) && _ticker.isAnimating) {
      _ticker.stop();
    }
    if (!visible) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ticker,
              builder: (_, _) => CustomPaint(
                painter: _SnowPainter(
                  progress: reduceMotion ? 0.32 : _ticker.value,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SnowPainter extends CustomPainter {
  const _SnowPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const _flakes = <(double, double, double, double)>[
    (0.03, 0.11, 1.2, 0.82),
    (0.08, 0.57, 1.7, 1.08),
    (0.14, 0.83, 1.0, 0.93),
    (0.19, 0.32, 1.4, 1.17),
    (0.24, 0.71, 1.9, 0.77),
    (0.29, 0.18, 1.1, 1.02),
    (0.35, 0.94, 1.6, 1.14),
    (0.41, 0.45, 1.3, 0.88),
    (0.47, 0.64, 1.8, 1.06),
    (0.52, 0.05, 1.0, 0.79),
    (0.58, 0.78, 1.5, 1.19),
    (0.63, 0.27, 1.9, 0.91),
    (0.69, 0.52, 1.2, 1.12),
    (0.74, 0.89, 1.6, 0.84),
    (0.80, 0.38, 1.1, 1.15),
    (0.86, 0.69, 1.8, 0.96),
    (0.91, 0.14, 1.4, 1.03),
    (0.96, 0.60, 1.0, 0.86),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.28);
    for (final (x, phase, radius, speed) in _flakes) {
      final y = ((phase + progress * speed) % 1) * size.height;
      final drift = math.sin((progress + phase) * math.pi * 2) * 8;
      canvas.drawCircle(Offset(x * size.width + drift, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SnowPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
