import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class SeasonalSpark extends StatefulWidget {
  const SeasonalSpark({
    super.key,
    required this.reduceMotion,
    this.visible = true,
  });

  final bool reduceMotion;
  final bool visible;

  @override
  State<SeasonalSpark> createState() => _SeasonalSparkState();
}

class _SeasonalSparkState extends State<SeasonalSpark> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    if (widget.visible) _started = true;
    if (!_started) return const SizedBox.shrink();
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: widget.reduceMotion
            ? Duration.zero
            : const Duration(seconds: 3),
        builder: (_, progress, _) => CustomPaint(
          painter: _SparkPainter(
            progress: widget.visible ? progress : 1,
            color: context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.47;
    final opacity = math.sin(progress * math.pi);
    for (var index = 0; index < 12; index++) {
      final angle = progress * 2 * math.pi - index * 0.018 - math.pi / 2;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        2.1 - index * 0.13,
        Paint()..color = color.withValues(alpha: opacity * (1 - index / 12)),
      );
    }
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
