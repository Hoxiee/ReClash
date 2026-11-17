import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable, listEquals;
import 'package:flutter/widgets.dart';

import 'calendar.dart';

/// Particle counts are given for a phone-sized area and scale with it.
const _referenceArea = 400.0 * 800.0;

class _Spec {
  const _Spec({
    required this.count,
    required this.maxCount,
    required this.size,
    this.speed = (0, 0),
    this.sway = (0, 0),
    this.swayRate = (0, 0),
    this.spin = (0, 0),
    required this.alpha,
    this.rising = false,
  });

  final int count;
  final int maxCount;
  final (double, double) size;
  final (double, double) speed;
  final (double, double) sway;
  final (double, double) swayRate;
  final (double, double) spin;
  final (double, double) alpha;
  final bool rising;
}

const _specs = {
  SeasonalEffectKind.snow: _Spec(
    count: 80,
    maxCount: 220,
    size: (1.2, 3.8),
    speed: (16, 52),
    sway: (6, 22),
    swayRate: (0.3, 0.9),
    alpha: (0.3, 0.85),
  ),
  SeasonalEffectKind.lights: _Spec(
    count: 10,
    maxCount: 24,
    size: (26, 72),
    speed: (3, 8),
    sway: (18, 40),
    swayRate: (0.08, 0.22),
    spin: (0.3, 0.9),
    alpha: (0.12, 0.24),
    rising: true,
  ),
  SeasonalEffectKind.stars: _Spec(
    count: 34,
    maxCount: 90,
    size: (2, 5),
    spin: (0.4, 1.3),
    alpha: (0.3, 0.8),
  ),
  SeasonalEffectKind.leaves: _Spec(
    count: 16,
    maxCount: 40,
    size: (7, 13),
    speed: (20, 42),
    sway: (20, 50),
    swayRate: (0.4, 0.9),
    spin: (0.6, 1.6),
    alpha: (0.45, 0.75),
  ),
  SeasonalEffectKind.petals: _Spec(
    count: 22,
    maxCount: 56,
    size: (3.5, 6.5),
    speed: (14, 32),
    sway: (18, 40),
    swayRate: (0.4, 1.0),
    spin: (0.8, 2.0),
    alpha: (0.45, 0.8),
  ),
  SeasonalEffectKind.confetti: _Spec(
    count: 24,
    maxCount: 70,
    size: (3, 5.5),
    speed: (28, 58),
    sway: (8, 20),
    swayRate: (0.6, 1.4),
    spin: (2, 5),
    alpha: (0.5, 0.85),
  ),
  SeasonalEffectKind.hearts: _Spec(
    count: 10,
    maxCount: 26,
    size: (6, 10),
    speed: (10, 22),
    sway: (10, 24),
    swayRate: (0.3, 0.7),
    spin: (0.5, 1.1),
    alpha: (0.55, 0.85),
    rising: true,
  ),
};

const _densityFactor = {
  SeasonalDensity.low: 0.55,
  SeasonalDensity.medium: 1.0,
  SeasonalDensity.high: 1.6,
};

class _Particle {
  _Particle(math.Random random, _Spec spec)
    : x = random.nextDouble(),
      y = random.nextDouble(),
      depth = random.nextDouble(),
      jitter = 0.8 + random.nextDouble() * 0.4,
      sway = _lerp(spec.sway, random.nextDouble()),
      swayRate = _lerp(spec.swayRate, random.nextDouble()),
      swayPhase = random.nextDouble() * math.pi * 2,
      spin =
          _lerp(spec.spin, random.nextDouble()) * (random.nextBool() ? 1 : -1),
      spinPhase = random.nextDouble() * math.pi * 2,
      tone = random.nextInt(1 << 16);

  final double x;
  final double y;

  /// Near particles are larger, faster and more opaque.
  final double depth;
  final double jitter;
  final double sway;
  final double swayRate;
  final double swayPhase;
  final double spin;
  final double spinPhase;
  final int tone;
}

double _lerp((double, double) range, double t) =>
    range.$1 + (range.$2 - range.$1) * t;

final _particles = <(SeasonalEffectKind, int), List<_Particle>>{};

/// The same kind and count give the same particles, so every copy of the
/// background paints them in the same place.
List<_Particle> _particlesOf(SeasonalEffect effect, Size size) {
  final spec = _specs[effect.kind]!;
  final scale = size.width * size.height / _referenceArea;
  final count = (spec.count * _densityFactor[effect.density]! * scale)
      .round()
      .clamp(1, spec.maxCount);
  return _particles.putIfAbsent((effect.kind, count), () {
    final random = math.Random(effect.kind.index + 1);
    return [for (var i = 0; i < count; i++) _Particle(random, spec)];
  });
}

List<Color> _paletteOf(SeasonalEffect effect, bool dark, Color tint) {
  if (effect.colors.isNotEmpty) {
    return [for (final color in effect.colors) Color(color)];
  }
  return switch (effect.kind) {
    SeasonalEffectKind.snow => [
      dark ? const Color(0xFFFFFFFF) : const Color(0xFF8FA6C2),
    ],
    SeasonalEffectKind.stars => [
      if (dark) ...const [Color(0xFFFFFFFF), Color(0xFFFFE6A8)] else tint,
    ],
    SeasonalEffectKind.lights => const [
      Color(0xFFFFC857),
      Color(0xFFFF5D5D),
      Color(0xFF5BD68A),
      Color(0xFF6FA8FF),
    ],
    SeasonalEffectKind.leaves => const [
      Color(0xFFE07B39),
      Color(0xFFC8553D),
      Color(0xFFE9A23B),
      Color(0xFF9C6644),
    ],
    SeasonalEffectKind.petals => const [
      Color(0xFFF7B7C8),
      Color(0xFFF4A3B8),
      Color(0xFFFAD2DC),
    ],
    SeasonalEffectKind.confetti => [
      tint,
      const Color(0xFFFFC857),
      const Color(0xFFFF6B8A),
      const Color(0xFF5BD68A),
      const Color(0xFF6FA8FF),
    ],
    SeasonalEffectKind.hearts => const [
      Color(0xFFFF6B8A),
      Color(0xFFFF8FA3),
      Color(0xFFE94B6E),
    ],
  };
}

final Path _leaf = Path()
  ..moveTo(0, -1)
  ..quadraticBezierTo(0.7, -0.3, 0, 1)
  ..quadraticBezierTo(-0.7, -0.3, 0, -1)
  ..close();

final Path _petal = Path()
  ..moveTo(0, -1)
  ..cubicTo(0.8, -0.6, 0.6, 0.7, 0, 1)
  ..cubicTo(-0.6, 0.7, -0.8, -0.6, 0, -1)
  ..close();

final Path _heart = Path()
  ..moveTo(0, 0.9)
  ..cubicTo(-1.1, 0.1, -0.9, -0.95, 0, -0.45)
  ..cubicTo(0.9, -0.95, 1.1, 0.1, 0, 0.9)
  ..close();

final Path _sparkle = Path()
  ..moveTo(0, -1)
  ..lineTo(0.2, -0.2)
  ..lineTo(1, 0)
  ..lineTo(0.2, 0.2)
  ..lineTo(0, 1)
  ..lineTo(-0.2, 0.2)
  ..lineTo(-1, 0)
  ..lineTo(-0.2, -0.2)
  ..close();

class SeasonalPainter extends CustomPainter {
  SeasonalPainter({
    required this.effects,
    required this.time,
    required this.presence,
    required this.dark,
    required this.tint,
  }) : super(repaint: Listenable.merge([time, presence]));

  final List<SeasonalEffect> effects;

  /// Seconds on the frame clock every copy of the background shares.
  final ValueListenable<double> time;
  final Animation<double> presence;
  final bool dark;
  final Color tint;

  final _fill = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = presence.value;
    if (opacity <= 0 || size.isEmpty) return;
    final t = time.value;
    for (final effect in effects) {
      final spec = _specs[effect.kind]!;
      final palette = _paletteOf(effect, dark, tint);
      final particles = _particlesOf(effect, size);
      for (final p in particles) {
        final color = palette[p.tone % palette.length];
        final alpha = _lerp(spec.alpha, p.depth) * opacity * (dark ? 1 : 0.85);
        final radius = _lerp(spec.size, p.depth) * p.jitter;
        switch (effect.kind) {
          case SeasonalEffectKind.stars:
            _star(canvas, size, p, t, radius, color, alpha);
          case SeasonalEffectKind.lights:
            _light(canvas, size, spec, p, t, radius, color, alpha);
          default:
            _falling(
              canvas,
              size,
              effect.kind,
              spec,
              p,
              t,
              radius,
              color,
              alpha,
            );
        }
      }
    }
  }

  Offset _drift(Size size, _Spec spec, _Particle p, double t, double margin) {
    final speed = _lerp(spec.speed, p.depth) * p.jitter;
    final span = size.height + margin * 2;
    final travel = p.y * span + (spec.rising ? -1 : 1) * t * speed;
    final y = travel % span - margin;
    final x =
        p.x * size.width + math.sin(t * p.swayRate + p.swayPhase) * p.sway;
    return Offset(x, y);
  }

  void _falling(
    Canvas canvas,
    Size size,
    SeasonalEffectKind kind,
    _Spec spec,
    _Particle p,
    double t,
    double radius,
    Color color,
    double alpha,
  ) {
    final margin = radius * 2 + p.sway;
    final at = _drift(size, spec, p, t, margin);
    var fade = 1.0;
    if (spec.rising) {
      final progress = ((at.dy + margin) / (size.height + margin * 2)).clamp(
        0.0,
        1.0,
      );
      fade = math.sin(progress * math.pi);
    }
    _fill
      ..color = color.withValues(alpha: alpha * fade)
      ..maskFilter = null;
    if (kind == SeasonalEffectKind.snow) {
      if (p.depth > 0.8) {
        _fill.maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          radius * 0.5,
        );
      }
      canvas.drawCircle(at, radius, _fill);
      return;
    }
    final angle = p.spinPhase + t * p.spin;
    canvas
      ..save()
      ..translate(at.dx, at.dy);
    switch (kind) {
      case SeasonalEffectKind.hearts:
        canvas
          ..rotate(math.sin(angle) * 0.35)
          ..scale(radius);
        canvas.drawPath(_heart, _fill);
      case SeasonalEffectKind.confetti:
        final flip = math.cos(angle * 1.3);
        canvas
          ..rotate(angle)
          ..scale(
            radius * (flip.abs() < 0.15 ? 0.15 * flip.sign : flip),
            radius,
          );
        canvas.drawRect(const Rect.fromLTRB(-1, -0.45, 1, 0.45), _fill);
      default:
        final flip = math.cos(angle * 0.7);
        canvas
          ..rotate(angle)
          ..scale(
            radius * (flip.abs() < 0.25 ? 0.25 * flip.sign : flip),
            radius,
          );
        canvas.drawPath(
          kind == SeasonalEffectKind.leaves ? _leaf : _petal,
          _fill,
        );
    }
    canvas.restore();
  }

  void _star(
    Canvas canvas,
    Size size,
    _Particle p,
    double t,
    double radius,
    Color color,
    double alpha,
  ) {
    final wave = 0.5 + 0.5 * math.sin(t * p.spin.abs() + p.spinPhase);
    final glow = 0.25 + 0.75 * wave * wave * wave;
    final at = Offset(p.x * size.width, math.pow(p.y, 1.4) * size.height);
    _fill
      ..color = color.withValues(alpha: alpha * glow)
      ..maskFilter = null;
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(radius * (0.8 + 0.2 * wave));
    canvas
      ..drawPath(_sparkle, _fill)
      ..restore();
  }

  void _light(
    Canvas canvas,
    Size size,
    _Spec spec,
    _Particle p,
    double t,
    double radius,
    Color color,
    double alpha,
  ) {
    final at = _drift(size, spec, p, t, radius);
    final pulse = 0.7 + 0.3 * math.sin(t * p.spin.abs() + p.spinPhase);
    final strength = alpha * pulse * (dark ? 1 : 1.4);
    _fill
      ..maskFilter = null
      ..color = const Color(0xFFFFFFFF)
      ..shader = ui.Gradient.radial(
        at,
        radius,
        [
          color.withValues(alpha: strength),
          color.withValues(alpha: strength * 0.45),
          color.withValues(alpha: 0),
        ],
        const [0, 0.45, 1],
      );
    canvas.drawCircle(at, radius, _fill);
    _fill.shader = null;
  }

  @override
  bool shouldRepaint(SeasonalPainter oldDelegate) =>
      !listEquals(oldDelegate.effects, effects) ||
      oldDelegate.dark != dark ||
      oldDelegate.tint != tint ||
      oldDelegate.time != time ||
      oldDelegate.presence != presence;
}
