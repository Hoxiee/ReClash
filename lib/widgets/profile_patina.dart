import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:reclash/common/common.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class ProfilePatina extends StatefulWidget {
  const ProfilePatina({
    super.key,
    required this.level,
    required this.reduceMotion,
    required this.child,
    this.seed = 0,
  });

  final double level;
  final bool reduceMotion;
  final int seed;
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
  late double _from = widget.level;
  Offset? _origin;

  @override
  void didUpdateWidget(ProfilePatina oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only a true clean animates; continuous accumulation would fire the
    // ticker and haptics on every fractional rebuild, so it just snaps.
    final cleaned = oldWidget.level > 0.05 && widget.level <= 0.05;
    if (widget.reduceMotion) {
      _blow.stop();
      _from = widget.level;
      _blow.value = 1;
    } else if (cleaned) {
      _from = oldWidget.level;
      _blow.forward(from: 0);
      HapticFeedback.selectionClick();
    } else {
      _from = widget.level;
      _blow.value = 1;
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
          to: widget.level,
          progress: _blow.value,
          origin: _origin,
          seed: widget.seed,
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
    required this.seed,
    required this.color,
  });

  final double from;
  final double to;
  final double progress;
  final Offset? origin;
  final int seed;
  final Color color;

  // Deterministic 0..1 hash so each card dusts its own way, allocation-free.
  double _rand(int index, int salt) {
    var h = seed * 0x9E3779B1 ^ index * 0x85EBCA77 ^ salt * 0xC2B2AE3D;
    h ^= h >> 15;
    h = (h * 0x27D4EB2F) & 0x7FFFFFFF;
    h ^= h >> 13;
    return (h & 0xFFFFF) / 0xFFFFF;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final removing = to == 0 && from > 0;
    final level = removing ? from : to;
    if (level <= 0 || (removing && progress >= 1)) return;
    final fade = removing ? Curves.easeIn.transform(1 - progress) : 1.0;
    final strength = (0.03 + level * 0.026).clamp(0.0, 0.11) * fade;
    final source = origin ?? Offset(size.width * 0.5, size.height);

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    if (!removing) {
      final hazeTop = size.height * (0.66 - level * 0.06).clamp(0.4, 0.66);
      final haze = Paint()
        ..shader =
            ui.Gradient.linear(Offset(0, hazeTop), Offset(0, size.height), [
              color.withValues(alpha: 0),
              color.withValues(alpha: strength * 0.5),
            ]);
      canvas.drawRect(
        Rect.fromLTWH(0, hazeTop, size.width, size.height - hazeTop),
        haze,
      );
      if (level >= 1.6) {
        final warm = const Color(0xFF8A6A45)
            .withValues(alpha: (0.014 * (level - 1.6)).clamp(0.0, 0.03));
        canvas.drawRect(Offset.zero & size, Paint()..color = warm);
      }
    } else {
      final puff = math.sin(progress * math.pi);
      if (puff > 0) {
        final radius = size.shortestSide * (0.25 + progress * 0.9);
        canvas.drawCircle(
          source,
          radius,
          Paint()
            ..shader = ui.Gradient.radial(source, radius, [
              color.withValues(alpha: 0.05 * puff),
              color.withValues(alpha: 0),
            ]),
        );
      }
    }

    final paint = Paint();
    final count = (16 + level * 16).round().clamp(0, 66);
    for (var index = 0; index < count; index++) {
      final rx = _rand(index, 1);
      final ry = _rand(index, 2);
      final corner = _rand(index, 3);
      Offset point;
      if (corner < 0.28) {
        final cx = (index & 1) == 0 ? 0.06 : 0.94;
        final cy = (index & 2) == 0 ? 0.08 : 0.92;
        point = Offset(
          (cx + (rx - 0.5) * 0.22).clamp(0.0, 1.0) * size.width,
          (cy + (ry - 0.5) * 0.22).clamp(0.0, 1.0) * size.height,
        );
      } else {
        // pow(<1) biases the vertical toward the floor, like settling dust.
        point = Offset(
          rx * size.width,
          math.pow(ry, 0.55).toDouble() * size.height,
        );
      }
      final big = _rand(index, 4) > 0.86;
      var motes = strength * (0.6 + _rand(index, 5) * 0.9);
      if (removing) {
        final delta = point - source;
        final dir = delta / math.max(delta.distance, 1);
        final push = Curves.easeOutCubic.transform(progress);
        point += dir * push * (30 + index % 7 * 12) - Offset(0, push * 10);
        motes *= 1 - progress;
      }
      paint.color = color.withValues(alpha: motes.clamp(0.0, 0.14));
      canvas.drawCircle(point, (big ? 1.5 : 0.7) + (index % 3) * 0.28, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PatinaPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.progress != progress ||
      oldDelegate.origin != origin ||
      oldDelegate.seed != seed ||
      oldDelegate.color != color;
}
