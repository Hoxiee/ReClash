import 'dart:math' as math;

import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

/// Where a long press on the running power button stands. Only [fired] and
/// the two holds change what the status text says.
enum EggStage { idle, holding, almost, fired }

/// The status text an egg stage shows; a null [line] keeps the normal one.
@immutable
class EggStatus {
  const EggStatus(this.title, [this.line]);

  final String title;
  final String? line;
}

const eggBurstDuration = Duration(milliseconds: 1500);
const eggTextDuration = Duration(seconds: 3);
const eggPressDuration = Duration(milliseconds: 300);

/// The egg's switches, timings and looks. A null text, shape pool, glyph pool
/// or color pool means the app's default, so a provider fills in only what it
/// customises.
@immutable
class EggConfig {
  const EggConfig({
    this.enabled = true,
    this.hold = const Duration(milliseconds: 1500),
    this.particles = 20,
    this.shapes,
    this.glyphs,
    this.colors,
    this.holdText,
    this.almostText,
    this.fireText,
    this.greeting,
  });

  final bool enabled;

  /// How long the press must last once it is recognised.
  final Duration hold;
  final int particles;
  final List<RoundedPolygon>? shapes;
  final List<Glyph>? glyphs;
  final List<Color>? colors;
  final String? holdText;
  final String? almostText;
  final String? fireText;

  /// The second line after the burst, replacing the "provider says hi" default.
  final String? greeting;

  List<RoundedPolygon> get shapePool => shapes ?? _defaultShapes;
  List<Glyph> get glyphPool => glyphs ?? _defaultGlyphs;
}

final _defaultShapes = <RoundedPolygon>[
  MaterialShapes.clover4Leaf,
  MaterialShapes.sunny,
  MaterialShapes.heart,
  MaterialShapes.cookie4Sided,
  MaterialShapes.gem,
  MaterialShapes.pill,
  MaterialShapes.flower,
  MaterialShapes.triangle,
  MaterialShapes.puffy,
  MaterialShapes.softBurst,
];

const _defaultGlyphs = <Glyph>[
  AppGlyphs.sparkle,
  AppGlyphs.bolt,
  AppGlyphs.star,
  AppGlyphs.heart,
  AppGlyphs.sun,
  AppGlyphs.wifi,
  AppGlyphs.verified,
  AppGlyphs.vpn,
];

/// One piece of the burst: a shape or a glyph, launched from the rim.
@immutable
class EggParticle {
  const EggParticle({
    required this.angle,
    required this.speed,
    required this.delay,
    required this.extent,
    required this.turn,
    required this.spin,
    required this.color,
    this.shape,
    this.glyph,
  });

  final double angle;

  /// Launch speed in button sizes per second.
  final double speed;

  /// Seconds after the burst starts.
  final double delay;

  /// Size in button sizes.
  final double extent;
  final double turn;

  /// Radians per second.
  final double spin;
  final Color color;
  final RoundedPolygon? shape;
  final Glyph? glyph;
}

/// An even spread of angles with jitter, a random mix of shapes and glyphs,
/// and tints of the scheme's accents.
List<EggParticle> buildEggParticles(
  EggConfig config,
  ColorScheme scheme,
  math.Random random,
) {
  final colors =
      config.colors ??
      [
        scheme.primary,
        scheme.tertiary,
        scheme.secondary,
        scheme.primary,
        scheme.tertiary,
        scheme.primaryContainer,
        scheme.tertiaryContainer,
        scheme.secondaryContainer,
      ];
  final shapes = config.shapePool;
  final glyphs = config.glyphPool;
  final count = config.particles;
  final base = random.nextDouble() * 2 * math.pi;
  return [
    for (var i = 0; i < count; i++)
      () {
        final useShape = random.nextDouble() < 0.55;
        final extent = useShape
            ? 0.15 + random.nextDouble() * 0.12
            : 0.2 + random.nextDouble() * 0.1;
        return EggParticle(
          angle:
              base +
              (i + random.nextDouble() * 0.6 - 0.3) / count * 2 * math.pi,
          speed: 1.1 + random.nextDouble() * 0.9,
          delay: random.nextDouble() * 0.12,
          extent: extent,
          turn: random.nextDouble() * 2 * math.pi,
          spin: (random.nextDouble() * 2 - 1) * 4,
          color: colors[random.nextInt(colors.length)],
          shape: useShape ? shapes[random.nextInt(shapes.length)] : null,
          glyph: useShape ? null : glyphs[random.nextInt(glyphs.length)],
        );
      }(),
  ];
}

/// The ring that fills around the halo while the press holds.
class EggRingPainter extends CustomPainter {
  EggRingPainter({required this.progress, required this.color})
    : super(repaint: progress);

  static const _stroke = 4.0;

  final Animation<double> progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final value = progress.value;
    if (value <= 0) return;
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.14);
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(EggRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// A shockwave and [particles] flying out of a button of side [unit], from
/// the middle of the canvas.
class EggBurstPainter extends CustomPainter {
  EggBurstPainter({
    required this.progress,
    required this.particles,
    required this.unit,
    required this.wave,
  }) : super(repaint: progress);

  static const _drag = 2.2;
  static const _gravity = 0.45;
  static const _rim = 0.46;
  static const _waveShare = 0.5;
  static final _seconds = eggBurstDuration.inMilliseconds / 1000;

  final Animation<double> progress;
  final List<EggParticle> particles;
  final double unit;
  final Color wave;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final t = progress.value * _seconds;
    final spread = progress.value / _waveShare;
    if (spread < 1) {
      final eased = Curves.easeOutCubic.transform(spread);
      canvas.drawCircle(
        centre,
        unit * (0.6 + 0.85 * eased),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 + unit * 0.04 * (1 - eased)
          ..color = wave.withValues(alpha: 0.35 * (1 - eased)),
      );
    }
    final fill = Paint();
    for (final p in particles) {
      final local = t - p.delay;
      if (local <= 0) continue;
      final life = local / (_seconds - p.delay);
      final pop = life < 0.2 ? Curves.easeOutBack.transform(life / 0.2) : 1.0;
      final fade = life < 0.6
          ? 1.0
          : 1 - Curves.easeIn.transform((life - 0.6) / 0.4);
      if (fade <= 0) continue;
      final reach =
          unit * (_rim + p.speed / _drag * (1 - math.exp(-_drag * local)));
      final at =
          centre +
          Offset.fromDirection(p.angle, reach) +
          Offset(0, unit * 0.5 * _gravity * local * local);
      final side = unit * p.extent * pop;
      final color = p.color.withValues(alpha: p.color.a * fade);
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(p.turn + p.spin * local);
      if (p.shape case final shape?) {
        canvas
          ..scale(side)
          ..translate(-0.5, -0.5)
          ..drawPath(shapePathOf(shape), fill..color = color);
      } else if (p.glyph case final glyph?) {
        canvas.translate(-side / 2, -side / 2);
        GlyphPainter(
          glyph: glyph,
          fill: 1,
          color: color,
        ).paint(canvas, Size.square(side));
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(EggBurstPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.particles != particles ||
      oldDelegate.unit != unit ||
      oldDelegate.wave != wave;
}
