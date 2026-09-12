import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The hero orb reduced to a rail-sized mark: the app's identity wearing the
/// same status colours. It shares the orb's vocabulary but none of its
/// machinery — one controller, and only while the status is actually moving.
class HeroStatusMark extends ConsumerStatefulWidget {
  const HeroStatusMark({super.key, this.size = NavRailMetrics.markSize});

  final double size;

  @override
  ConsumerState<HeroStatusMark> createState() => _HeroStatusMarkState();
}

class _HeroStatusMarkState extends ConsumerState<HeroStatusMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _motionScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static bool _moving(HeroStatus status) => switch (status) {
    HeroStatus.checking ||
    HeroStatus.diagnosing ||
    HeroStatus.connecting ||
    HeroStatus.reconnecting => true,
    HeroStatus.offline ||
    HeroStatus.off ||
    HeroStatus.secured ||
    HeroStatus.degraded ||
    HeroStatus.broken ||
    HeroStatus.paused => false,
  };

  void _syncMotion(bool moving) {
    final shouldMove = moving && !context.disableAnimations;
    if (shouldMove == _controller.isAnimating || _motionScheduled) return;
    _motionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _motionScheduled = false;
      if (!mounted) return;
      if (shouldMove) {
        _controller.repeat();
        return;
      }
      _controller.stop();
      _controller.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = heroStatusOf(
      ref.watch(heroLifecycleProvider),
      heroDoctorHealthOf(ref.watch(connectionDoctorProvider)),
    );
    _syncMotion(_moving(status));
    return SizedBox.square(
      dimension: widget.size,
      child: TweenAnimationBuilder<HeroPalette>(
        tween: HeroPaletteTween(end: heroPaletteOf(context, status)),
        duration: context.motionDuration(const Duration(milliseconds: 420)),
        builder: (context, palette, child) => AnimatedBuilder(
          animation: _controller,
          builder: (context, core) => CustomPaint(
            painter: _MarkPainter(palette: palette, spin: _controller.value),
            child: core,
          ),
          child: child,
        ),
        child: const Padding(
          padding: EdgeInsets.all(NavRailMetrics.markPadding),
          child: Image(image: AssetImage('assets/images/icon.png')),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.palette, required this.spin});

  final HeroPalette palette;
  final double spin;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.shortestSide * 0.07;
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 2.4
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 1.6)
        ..color = palette.glow.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = SweepGradient(
          colors: [...palette.ring, palette.ring.first],
          transform: GradientRotation(-math.pi / 2 + spin * 2 * math.pi),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.palette != palette || oldDelegate.spin != spin;
}
