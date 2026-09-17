import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class ProfilePatina extends StatefulWidget {
  const ProfilePatina({
    super.key,
    required this.level,
    required this.reduceMotion,
    required this.child,
  });

  final int level;
  final bool reduceMotion;
  final Widget child;

  @override
  State<ProfilePatina> createState() => _ProfilePatinaState();
}

class _ProfilePatinaState extends State<ProfilePatina>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late double _from = widget.level.toDouble();
  Offset? _origin;

  @override
  void didUpdateWidget(ProfilePatina oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion) {
      _blow.stop();
      _from = widget.level.toDouble();
      _blow.value = 1;
    } else if (oldWidget.level != widget.level) {
      _from = oldWidget.level.toDouble();
      _blow.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _blow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (event) => _origin = event.localPosition,
    child: AnimatedBuilder(
      animation: _blow,
      child: widget.child,
      builder: (_, child) => CustomPaint(
        painter: _PatinaPainter(
          from: _from,
          to: widget.level.toDouble(),
          progress: _blow.value,
          origin: _origin,
          color: context.colorScheme.onSurfaceVariant,
        ),
        child: child,
      ),
    ),
  );
}

class _PatinaPainter extends CustomPainter {
  const _PatinaPainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.origin,
    required this.color,
  });

  final double from;
  final double to;
  final double progress;
  final Offset? origin;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final removing = to == 0 && from > 0;
    final level = removing ? from : from + (to - from) * progress;
    if (level <= 0 || (removing && progress >= 1)) return;
    final opacity = removing ? 1 - progress : 1.0;
    final strength = (0.025 + level * 0.018).clamp(0.0, 0.085) * opacity;
    final paint = Paint()..color = color.withValues(alpha: strength);
    final source = origin ?? size.center(Offset.zero);
    final count = (14 + level * 12).round();
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var index = 0; index < count; index++) {
      var point = Offset(
        ((index * 47 + 13) % 101) / 101 * size.width,
        ((index * 31 + 7) % 89) / 89 * size.height,
      );
      if (removing) {
        final delta = point - source;
        final direction = delta / math.max(delta.distance, 1);
        point += direction * progress * (36 + index % 7 * 9);
      }
      canvas.drawCircle(point, 0.65 + (index % 4) * 0.32, paint);
    }
    if (level >= 2) {
      final strip = Paint()
        ..color = color.withValues(alpha: strength * 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.80, size.width, size.height * 0.14),
        strip,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PatinaPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.progress != progress ||
      oldDelegate.origin != origin ||
      oldDelegate.color != color;
}
