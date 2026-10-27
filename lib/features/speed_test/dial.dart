import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/ui.dart';

/// Mbit/s marks of the dial. Equal arcs between uneven marks keep both a slow
/// mobile link and a gigabit one readable on the same scale.
const speedTestDialMarks = [
  0.0,
  1.0,
  5.0,
  10.0,
  50.0,
  100.0,
  250.0,
  500.0,
  1000.0,
];

/// Where [mbps] sits on the dial, from 0 at the first mark to 1 at the last.
double speedTestDialPosition(double mbps) {
  const marks = speedTestDialMarks;
  if (mbps <= 0) return 0;
  for (var i = 1; i < marks.length; i++) {
    if (mbps <= marks[i]) {
      final within = (mbps - marks[i - 1]) / (marks[i] - marks[i - 1]);
      return (i - 1 + within) / (marks.length - 1);
    }
  }
  return 1;
}

/// A 270° speed dial with [child] in its middle and [footer] in the gap
/// below it.
class SpeedTestDial extends StatelessWidget {
  const SpeedTestDial({
    super.key,
    required this.mbps,
    required this.footer,
    required this.child,
  });

  /// The rate the arc fills to; null leaves the arc empty.
  final double? mbps;
  final Widget footer;
  final Widget child;

  static const _sweep = 1.5 * math.pi;
  static const _stroke = 12.0;
  static const _labelGap = 26.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final label = AppTextStyle.caption1
        .of(context)
        .copyWith(
          color: colorScheme.onSurfaceVariant,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 300.0);
        final radius = size / 2 - _labelGap - _stroke / 2;
        final ends = size / 2 + radius * math.sin(math.pi / 4);
        return Center(
          child: SizedBox(
            width: size,
            height: ends + _labelGap + 12,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: speedTestDialPosition(mbps ?? 0)),
              duration: context.motionDuration(
                const Duration(milliseconds: 420),
              ),
              curve: Curves.easeOutCubic,
              builder: (context, position, child) => CustomPaint(
                painter: _DialPainter(
                  position: position,
                  filled: mbps != null,
                  track: SurfaceLevel.inset.colorOf(colorScheme),
                  ink: colorScheme.primary,
                  knob: colorScheme.onSurface,
                  label: label,
                  textDirection: Directionality.of(context),
                ),
                child: child,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: size / 2 - radius * 0.62,
                    height: radius * 1.24,
                    child: Center(child: child),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: ends - 14,
                    child: Center(
                      child: SizedBox(
                        width: 2 * radius * math.cos(math.pi / 4) - 2 * _stroke,
                        child: FittedBox(fit: BoxFit.scaleDown, child: footer),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.position,
    required this.filled,
    required this.track,
    required this.ink,
    required this.knob,
    required this.label,
    required this.textDirection,
  });

  final double position;
  final bool filled;
  final Color track;
  final Color ink;
  final Color knob;
  final TextStyle label;
  final TextDirection textDirection;

  static const _start = 0.75 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = SpeedTestDial._stroke;
    const sweep = SpeedTestDial._sweep;
    final center = Offset(size.width / 2, size.width / 2);
    final radius = size.width / 2 - SpeedTestDial._labelGap - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, sweep, false, line..color = track);
    if (filled && position > 0) {
      canvas.drawArc(rect, _start, sweep * position, false, line..color = ink);
    }
    if (filled) {
      final angle = _start + sweep * position;
      canvas.drawCircle(
        center + Offset.fromDirection(angle, radius),
        stroke * 0.75,
        Paint()..color = knob,
      );
    }
    const marks = speedTestDialMarks;
    for (final (index, mark) in marks.indexed) {
      final text = index == marks.length - 1
          ? '${mark.round()}+'
          : '${mark.round()}';
      final painter = TextPainter(
        text: TextSpan(text: text, style: label),
        textDirection: textDirection,
      )..layout();
      final angle = _start + sweep * index / (marks.length - 1);
      final anchor =
          center +
          Offset.fromDirection(angle, radius + stroke / 2 + 4) +
          Offset(
            math.cos(angle) * painter.width / 2,
            math.sin(angle) * painter.height / 2,
          );
      painter
        ..paint(canvas, anchor - Offset(painter.width / 2, painter.height / 2))
        ..dispose();
    }
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.position != position ||
      old.filled != filled ||
      old.track != track ||
      old.ink != ink ||
      old.knob != knob ||
      old.label != label ||
      old.textDirection != textDirection;
}
