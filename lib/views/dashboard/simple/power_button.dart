import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/simple/egg.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/provider_image.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';

export 'package:reclash/features/power/face.dart' show PowerLink, PowerTone;
export 'package:reclash/views/dashboard/simple/egg.dart'
    show EggConfig, EggStage, EggStatus;

/// The verdict glyph on the rim; [tone] picks its fill.
@immutable
class PowerBadge {
  const PowerBadge(this.glyph, this.tone);

  final Glyph glyph;
  final PowerTone tone;

  @override
  bool operator ==(Object other) =>
      other is PowerBadge && other.glyph == glyph && other.tone == tone;

  @override
  int get hashCode => Object.hash(glyph, tone);
}

const _morphDuration = Duration(milliseconds: 450);
const _stateDuration = Duration(milliseconds: 150);
const _haloPeriod = Duration(seconds: 24);

const _connectingProgress = 0.45;

/// A badge that comes with the morph to running waits for it to land.
const _badgeDelay = Duration(milliseconds: 570);
const _badgeDuration = Duration(milliseconds: 250);

const _eggSettle = Duration(milliseconds: 500);
const _eggCancel = Duration(milliseconds: 400);
const _eggTwist = math.pi / 4;

const _haloSize = 1.34;

/// How far the burst's canvas reaches past the halo, in button sizes.
const _burstReach = 0.93;
const _plateSize = 0.54;

const _outlineStroke = BorderSide(width: 4);

/// A running shape and the number of identical turns it has, so one step of
/// the morph's rotation lands it on itself.
typedef _Silhouette = ({RoundedPolygon polygon, int symmetry});

final _silhouettes = <ProviderPowerShape, _Silhouette>{
  ProviderPowerShape.cookie: (
    polygon: MaterialShapes.cookie9Sided,
    symmetry: 9,
  ),
  ProviderPowerShape.circle: (polygon: MaterialShapes.circle, symmetry: 1),
  ProviderPowerShape.scallop: (
    polygon: MaterialShapes.cookie12Sided,
    symmetry: 12,
  ),
  ProviderPowerShape.sunny: (polygon: MaterialShapes.sunny, symmetry: 8),
  ProviderPowerShape.flower: (polygon: MaterialShapes.flower, symmetry: 8),
  ProviderPowerShape.clover: (polygon: MaterialShapes.clover4Leaf, symmetry: 4),
  ProviderPowerShape.burst: (polygon: MaterialShapes.softBurst, symmetry: 10),
  ProviderPowerShape.puffy: (polygon: MaterialShapes.puffy, symmetry: 2),
  ProviderPowerShape.puffyDiamond: (
    polygon: MaterialShapes.puffyDiamond,
    symmetry: 4,
  ),
  ProviderPowerShape.clover8Leaf: (
    polygon: MaterialShapes.clover8Leaf,
    symmetry: 8,
  ),
  ProviderPowerShape.cookie4Sided: (
    polygon: MaterialShapes.cookie4Sided,
    symmetry: 4,
  ),
  ProviderPowerShape.cookie6Sided: (
    polygon: MaterialShapes.cookie6Sided,
    symmetry: 6,
  ),
  ProviderPowerShape.verySunny: (
    polygon: MaterialShapes.verySunny,
    symmetry: 8,
  ),
  ProviderPowerShape.square: (polygon: MaterialShapes.square, symmetry: 4),
  ProviderPowerShape.diamond: (polygon: MaterialShapes.diamond, symmetry: 2),
  ProviderPowerShape.pentagon: (polygon: MaterialShapes.pentagon, symmetry: 1),
  ProviderPowerShape.gem: (polygon: MaterialShapes.gem, symmetry: 1),
  ProviderPowerShape.pixelCircle: (
    polygon: MaterialShapes.pixelCircle,
    symmetry: 2,
  ),
  ProviderPowerShape.softBoom: (polygon: MaterialShapes.softBoom, symmetry: 16),
  ProviderPowerShape.boom: (polygon: MaterialShapes.boom, symmetry: 15),
  ProviderPowerShape.sharpBurst: (polygon: MaterialShapes.burst, symmetry: 12),
};

final _morphs = <ProviderPowerShape, Morph>{};

Morph _morphOf(ProviderPowerShape shape) => _morphs.putIfAbsent(
  shape,
  () => Morph(MaterialShapes.circle, _silhouettes[shape]!.polygon),
);

Path _morphPath(ProviderPowerShape shape, double progress) => _morphOf(
  shape,
).toPath(progress: progress, rotationPivotX: 0.5, rotationPivotY: 0.5);

final _eggMorphs = <ProviderPowerShape, Morph>{};

/// The running shape on its way to the flower the egg pops.
Path _eggPath(ProviderPowerShape shape, double hold) => _eggMorphs
    .putIfAbsent(
      shape,
      () => Morph(_silhouettes[shape]!.polygon, MaterialShapes.flower),
    )
    .toPath(progress: hold, rotationPivotX: 0.5, rotationPivotY: 0.5);

Path _bodyPath(ProviderPowerShape shape, double progress, double hold) =>
    hold > 0 ? _eggPath(shape, hold) : _morphPath(shape, progress);

double _bodyTurn(ProviderPowerShape shape, double progress, double hold) =>
    hold > 0 ? hold * _eggTwist : _morphTurn(shape, progress);

double _morphTurn(ProviderPowerShape shape, double progress) =>
    progress * 2 * math.pi / _silhouettes[shape]!.symmetry;

/// The share of the rim's distance from the centre the badge sits at.
const _badgeReach = 0.93;

/// Where the morph's rim crosses the bottom-right diagonal, from the centre.
Offset _rimOffset(ProviderPowerShape shape, double progress, double size) {
  const samples = 96;
  final turn = _morphTurn(shape, progress);
  final aim = Offset.fromDirection(math.pi / 4 - turn);
  final rim = _morphPath(shape, progress).computeMetrics().first;
  const centre = Offset(0.5, 0.5);
  Offset at(int i) =>
      rim.getTangentForOffset(rim.length * i / samples)!.position - centre;
  var hit = Offset(aim.dx, aim.dy) * 0.5;
  var from = at(0);
  for (var i = 1; i <= samples; i++) {
    final to = at(i);
    final before = aim.dx * from.dy - aim.dy * from.dx;
    final after = aim.dx * to.dy - aim.dy * to.dx;
    if (before * after <= 0 &&
        before != after &&
        aim.dx * from.dx + aim.dy * from.dy > 0) {
      hit = Offset.lerp(from, to, before / (before - after))!;
      break;
    }
    from = to;
  }
  final cos = math.cos(turn);
  final sin = math.sin(turn);
  return Offset(hit.dx * cos - hit.dy * sin, hit.dx * sin + hit.dy * cos) *
      (size * _badgeReach);
}

const _greyscale = ColorFilter.matrix([
  0.33, 0.59, 0.11, 0, 0, //
  0.33, 0.59, 0.11, 0, 0,
  0.33, 0.59, 0.11, 0, 0,
  0, 0, 0, 1, 0,
]);

/// The logo stays upright while the selected shape grows from a circle.
class PowerButton extends StatefulWidget {
  const PowerButton({
    super.key,
    required this.link,
    required this.size,
    required this.logo,
    required this.images,
    required this.label,
    required this.onPressed,
    this.look = defaultProviderPowerButton,
    this.tone = PowerTone.normal,
    this.badge,
    this.spin = false,
    this.egg = const EggConfig(),
    this.onEggStage,
  });

  /// Holding a running button sets off the egg; it never toggles the tunnel.
  final EggConfig egg;

  /// Told as the egg moves between stages, so the status text can follow.
  final ValueChanged<EggStage>? onEggStage;

  final PowerTone tone;
  final PowerBadge? badge;

  /// The app is repairing a running tunnel: the halo spins around the full
  /// shape.
  final bool spin;

  final PowerLink link;
  final double size;

  /// The shape and fill of the running button, which the provider picks.
  final ProviderPowerButton look;

  /// The provider's logo URL or data URI; empty draws the power glyph.
  final String logo;
  final ProviderImages images;
  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// The side of the square the button and its halo take at [size].
  static double extentOf(double size) => size * _haloSize;

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with TickerProviderStateMixin {
  late final AnimationController _morphController = AnimationController(
    vsync: this,
    duration: _morphDuration,
    value: _targetOf(widget.link),
  );
  late final AnimationController _halo = AnimationController(
    vsync: this,
    duration: _haloPeriod,
  );
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.egg.hold,
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: eggBurstDuration,
  );
  late final Listenable _bodyMotion = Listenable.merge([
    _morphController,
    _hold,
    _burst,
  ]);
  var _hovered = false;
  var _pressed = false;
  var _focused = false;
  var _stage = EggStage.idle;

  /// The body stays a flower from the burst until it has settled back.
  var _fired = false;
  var _particles = const <EggParticle>[];
  Timer? _textTimer;

  static double _targetOf(PowerLink link) => switch (link) {
    PowerLink.off => 0,
    PowerLink.connecting => _connectingProgress,
    PowerLink.on || PowerLink.paused => 1,
  };

  @override
  void initState() {
    super.initState();
    _hold
      ..addListener(_onHold)
      ..addStatusListener(_onHoldStatus);
    _burst.addStatusListener(_onBurstStatus);
  }

  bool get _eggReady =>
      widget.egg.enabled && widget.link == PowerLink.on && !widget.spin;

  void _setStage(EggStage stage) {
    if (_stage == stage) return;
    _stage = stage;
    final notify = widget.onEggStage;
    if (notify == null) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) notify(_stage);
      });
    } else {
      notify(stage);
    }
  }

  void _eggStart() {
    if (!_eggReady || _stage != EggStage.idle) return;
    _setStage(EggStage.holding);
    unawaited(_hold.forward());
  }

  void _eggEnd() {
    if (_stage != EggStage.holding && _stage != EggStage.almost) return;
    _setStage(EggStage.idle);
    unawaited(
      _hold.animateBack(0, duration: _eggCancel, curve: Curves.easeOutBack),
    );
  }

  void _onHold() {
    if (_stage == EggStage.holding && _hold.value >= 0.5) {
      _setStage(EggStage.almost);
    }
  }

  void _onHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        (_stage == EggStage.holding || _stage == EggStage.almost)) {
      _fire();
    } else if (status == AnimationStatus.dismissed && _fired) {
      setState(() => _fired = false);
    }
  }

  void _fire() {
    unawaited(HapticFeedback.mediumImpact());
    _setStage(EggStage.fired);
    _textTimer?.cancel();
    _textTimer = Timer(eggTextDuration, () => _setStage(EggStage.idle));
    if (context.disableAnimations) {
      _hold.value = 0;
      return;
    }
    setState(() {
      _fired = true;
      _particles = buildEggParticles(
        widget.egg,
        context.colorScheme,
        math.Random(),
      );
    });
    unawaited(_burst.forward(from: 0));
  }

  void _onBurstStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() => _particles = const []);
    unawaited(_hold.animateBack(0, duration: _eggSettle));
  }

  void _resetEgg() {
    _textTimer?.cancel();
    _fired = false;
    _particles = const [];
    _burst.value = 0;
    _hold
      ..stop()
      ..value = 0;
    _setStage(EggStage.idle);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncHalo();
  }

  @override
  void didUpdateWidget(PowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hold.duration = widget.egg.hold;
    if (!_eggReady) _resetEgg();
    if (oldWidget.link != widget.link) {
      final target = _targetOf(widget.link);
      if (context.disableAnimations) {
        _morphController.value = target;
      } else {
        unawaited(
          _morphController.animateTo(
            target,
            curve: target > _morphController.value
                ? Curves.easeOutBack
                : Curves.easeInCubic,
          ),
        );
      }
      _syncHalo();
    } else if (oldWidget.spin != widget.spin) {
      _syncHalo();
    }
  }

  void _syncHalo() {
    final spinning =
        widget.link == PowerLink.on ||
        widget.link == PowerLink.connecting ||
        widget.spin;
    if (spinning && !context.disableAnimations) {
      if (!_halo.isAnimating) unawaited(_halo.repeat());
    } else {
      _halo.stop();
    }
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _hold.dispose();
    _burst.dispose();
    _morphController.dispose();
    _halo.dispose();
    super.dispose();
  }

  double get _overlay => widget.onPressed == null
      ? 0
      : _focused
      ? 0.1
      : _hovered
      ? 0.08
      : 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final glass = LiquidGlassScope.of(context);
    final size = widget.size;
    final link = widget.link;
    final enabled = widget.onPressed != null;
    final shape = widget.look.shape;
    final type = widget.look.type;
    // Chroma means traffic flows: a running tunnel that carries nothing
    // keeps the provider's shape in grey, whatever the theme's hue.
    final stalled =
        link == PowerLink.on &&
        (widget.tone == PowerTone.failure || widget.tone == PowerTone.quiet);
    final tonal =
        link == PowerLink.on && !stalled && type == ProviderPowerType.tonal;
    final hollow =
        link == PowerLink.on && !stalled && type == ProviderPowerType.outline;
    final fill = switch (link) {
      PowerLink.off => colors.tone,
      PowerLink.connecting || PowerLink.paused => colorScheme.primaryContainer,
      PowerLink.on =>
        stalled
            ? colors.tone
            : tonal
            ? colorScheme.primaryContainer
            : hollow
            ? Colors.transparent
            : colorScheme.primary,
    };
    final ink = switch (link) {
      PowerLink.off => colorScheme.onSurface,
      PowerLink.connecting ||
      PowerLink.paused => colorScheme.onPrimaryContainer,
      PowerLink.on =>
        stalled
            ? colorScheme.onSurface
            : tonal
            ? colorScheme.onPrimaryContainer
            : hollow
            ? colorScheme.primary
            : colorScheme.onPrimary,
    };
    final reduced = context.disableAnimations;
    final stateDuration = context.motionDuration(_stateDuration);
    final body = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: fill),
      duration: context.motionDuration(_morphDuration),
      builder: (_, fill, _) => TweenAnimationBuilder<double>(
        tween: Tween(end: _overlay),
        duration: stateDuration,
        builder: (_, overlay, _) => AnimatedBuilder(
          animation: _bodyMotion,
          builder: (_, _) {
            final progress = _morphController.value;
            final hold = reduced ? 0.0 : _hold.value;
            final pop = reduced
                ? 1.0
                : 1 +
                      0.14 *
                          math.sin(math.pi * math.min(1, _burst.value / 0.3));
            final color = Color.alphaBlend(
              ink.withValues(alpha: overlay),
              fill!,
            );
            final painted = CustomPaint(
              painter: _BodyPainter(
                shape: shape,
                progress: progress,
                hold: hold,
                color: glass || hollow ? null : color,
                shadow: link == PowerLink.off || stalled
                    ? Colors.black.withValues(alpha: 0.25)
                    : colorScheme.primary.withValues(alpha: 0.3),
                ring: _focused
                    ? focusRingSide(colorScheme, standsOff: true)
                    : hollow
                    ? _outlineStroke.copyWith(color: ink)
                    : null,
              ),
              child: SizedBox.square(dimension: size),
            );
            final Widget face = !glass || hollow
                ? painted
                : LiquidGlass(
                    style: LiquidGlassStyle.tinted(colorScheme, color),
                    clipper: _BodyClipper(shape, progress, hold),
                    pressed: _pressed,
                    child: painted,
                  );
            return pop == 1 ? face : Transform.scale(scale: pop, child: face);
          },
        ),
      ),
    );
    return SizedBox.square(
      dimension: size * _haloSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _Halo(
            link: link,
            shape: shape,
            size: size,
            turns: _halo,
            tone: widget.tone,
            spin: widget.spin,
          ),
          if (link == PowerLink.on && !_fired)
            IgnorePointer(
              child: CustomPaint(
                size: Size.square(size * _haloSize),
                painter: EggRingPainter(
                  progress: _hold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          Semantics(
            button: true,
            enabled: enabled,
            label: widget.label,
            child: GestureDetector(
              onHorizontalDragUpdate: (_) {},
              onVerticalDragUpdate: (_) {},
              child: RawGestureDetector(
                gestures: {
                  if (_eggReady)
                    LongPressGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          LongPressGestureRecognizer
                        >(
                          () => LongPressGestureRecognizer(
                            duration: eggPressDuration,
                          ),
                          (recognizer) => recognizer
                            ..onLongPressStart = ((_) => _eggStart())
                            ..onLongPressEnd = ((_) => _eggEnd())
                            ..onLongPressCancel = _eggEnd,
                        ),
                },
                child: InkResponse(
                  onTap: widget.onPressed,
                  onHover: (value) => setState(() => _hovered = value),
                  onHighlightChanged: (value) =>
                      setState(() => _pressed = value),
                  onFocusChange: (value) => setState(() => _focused = value),
                  overlayColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  customBorder: AppShape.circle,
                  child: ElasticPress(
                    enabled: enabled,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        body,
                        AnimatedBuilder(
                          animation: _hold,
                          child: _LogoPlate(
                            size: size * _plateSize,
                            logo: widget.logo,
                            images: widget.images,
                            muted: link == PowerLink.off,
                            raised: link == PowerLink.on,
                          ),
                          builder: (_, child) {
                            final v = _hold.value;
                            if (reduced || v == 0) return child!;
                            return Transform.rotate(
                              angle:
                                  0.16 *
                                  v *
                                  (1 - math.pow(v, 8)) *
                                  math.sin(v * 40),
                              child: child,
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _morphController,
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: _BadgeSlot(
                                badge: widget.badge,
                                size: size * 0.24,
                                delay: _morphController.isAnimating
                                    ? _badgeDelay
                                    : Duration.zero,
                              ),
                            ),
                          ),
                          builder: (_, child) => Transform.translate(
                            offset: _rimOffset(
                              shape,
                              _morphController.value,
                              size,
                            ),
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_particles.isNotEmpty)
            Positioned(
              left: -size * _burstReach,
              top: -size * _burstReach,
              right: -size * _burstReach,
              bottom: -size * _burstReach,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: EggBurstPainter(
                      progress: _burst,
                      particles: _particles,
                      unit: size,
                      wave: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({
    required this.link,
    required this.shape,
    required this.size,
    required this.turns,
    required this.tone,
    required this.spin,
  });

  final PowerTone tone;
  final bool spin;
  final PowerLink link;
  final ProviderPowerShape shape;
  final double size;
  final Animation<double> turns;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final halo = size * _haloSize;
    final Widget child = switch (spin ? PowerLink.connecting : link) {
      PowerLink.off => ShapeBadge(
        shape: MaterialShapes.circle,
        color: switch (tone) {
          PowerTone.problem => colors.warnContainer,
          PowerTone.failure => colorScheme.errorContainer,
          _ => colors.card,
        },
        size: size * 1.16,
      ),
      PowerLink.connecting => CustomPaint(
        size: Size.square(size * 1.2),
        painter: _SpinPainter(
          turns: turns,
          color: colorScheme.primary,
          track: colors.card,
        ),
      ),
      PowerLink.on || PowerLink.paused => AnimatedBuilder(
        animation: turns,
        builder: (_, _) {
          final silhouette = _silhouettes[shape]!;
          final rotation =
              0.12 + turns.value * 2 * math.pi / silhouette.symmetry;
          final tint = link != PowerLink.on || tone == PowerTone.quiet
              ? colorScheme.onSurfaceVariant
              : tone == PowerTone.failure
              ? colorScheme.error
              : colorScheme.primary;
          return Stack(
            alignment: Alignment.center,
            children: [
              ShapeBadge(
                shape: silhouette.polygon,
                color: tint.withValues(alpha: 0.06),
                size: halo,
                rotation: rotation,
              ),
              ShapeBadge(
                shape: silhouette.polygon,
                color: tint.withValues(alpha: 0.12),
                size: size * 1.17,
                rotation: rotation,
              ),
            ],
          );
        },
      ),
    };
    return AnimatedSwitcher(
      duration: context.motionDuration(_morphDuration),
      child: KeyedSubtree(
        key: ValueKey(
          spin
              ? PowerLink.connecting
              : link == PowerLink.paused
              ? PowerLink.on
              : link,
        ),
        child: child,
      ),
    );
  }
}

/// [CommonCircleLoading]'s stroke grows with its size, too heavy for a rim.
class _SpinPainter extends CustomPainter {
  _SpinPainter({required this.turns, required this.color, required this.track})
    : super(repaint: turns);

  static const _stroke = 5.0;
  static const _sweep = 0.3 * 2 * math.pi;

  final Animation<double> turns;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    final start = turns.value * _haloPeriod.inSeconds * 2 * math.pi;
    canvas
      ..drawArc(rect, 0, 2 * math.pi, false, paint..color = track)
      ..drawArc(rect, start, _sweep, false, paint..color = color);
  }

  @override
  bool shouldRepaint(_SpinPainter oldDelegate) =>
      oldDelegate.turns != turns ||
      oldDelegate.color != color ||
      oldDelegate.track != track;
}

class _LogoPlate extends StatelessWidget {
  const _LogoPlate({
    required this.size,
    required this.logo,
    required this.images,
    required this.muted,
    required this.raised,
  });

  final double size;
  final String logo;
  final ProviderImages images;
  final bool muted;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final mark = size * 0.62;
    final fallback = GlyphIcon(
      AppGlyphs.power,
      size: mark * 0.8,
      color: muted ? colorScheme.onSurfaceVariant : colorScheme.primary,
    );
    Widget content = SizedBox.square(
      dimension: mark,
      child: IconTheme.merge(
        data: IconThemeData(size: mark),
        child: images.logo(logo, fallback: fallback),
      ),
    );
    if (muted && logo.isNotEmpty) {
      content = Opacity(
        opacity: 0.55,
        child: ColorFiltered(colorFilter: _greyscale, child: content),
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: DashboardColors.of(context).card,
        shape: AppShape.circle,
        shadows: raised ? DashboardShadows.e1(context) : null,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(child: content),
      ),
    );
  }
}

/// Fills the morph, or with no [color] leaves its inside to glass and casts
/// [shadow] only outside it, as one under glass would show through.
class _BodyPainter extends CustomPainter {
  const _BodyPainter({
    required this.shape,
    required this.progress,
    required this.hold,
    required this.color,
    required this.shadow,
    required this.ring,
  });

  static const _shadowOffset = Offset(0, 10);
  static const _shadowBlur = 28.0;

  final ProviderPowerShape shape;
  final double progress;
  final double hold;
  final Color? color;
  final Color shadow;
  final BorderSide? ring;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _bodyPath(shape, progress, hold);
    final color = this.color;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_bodyTurn(shape, progress, hold))
      ..scale(size.width, size.height)
      ..translate(-0.5, -0.5);
    canvas.save();
    if (color == null) {
      canvas.clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(const Rect.fromLTRB(-1, -1, 2, 2))
          ..addPath(path, Offset.zero),
      );
    }
    canvas
      ..translate(_shadowOffset.dx / size.width, _shadowOffset.dy / size.height)
      ..drawPath(
        path,
        Paint()
          ..color = shadow
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            _shadowBlur / 2 / size.width,
          ),
      )
      ..restore();
    if (color != null) {
      canvas.drawPath(path, Paint()..color = color);
    }
    if (ring case final ring?) {
      strokeUnitShape(canvas, path, size.width, ring);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BodyPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.progress != progress ||
      oldDelegate.hold != hold ||
      oldDelegate.color != color ||
      oldDelegate.shadow != shadow ||
      oldDelegate.ring != ring;
}

class _BodyClipper extends CustomClipper<Path> {
  const _BodyClipper(this.shape, this.progress, this.hold);

  final ProviderPowerShape shape;
  final double progress;
  final double hold;

  @override
  Path getClip(Size size) {
    final transform =
        Matrix4.translationValues(size.width / 2, size.height / 2, 0)
          ..rotateZ(_bodyTurn(shape, progress, hold))
          ..scaleByDouble(size.width, size.height, 1, 1)
          ..translateByDouble(-0.5, -0.5, 0, 1);
    return _bodyPath(shape, progress, hold).transform(transform.storage);
  }

  @override
  bool shouldReclip(_BodyClipper oldClipper) =>
      oldClipper.shape != shape ||
      oldClipper.progress != progress ||
      oldClipper.hold != hold;
}

/// Pops the badge in and out; one that arrives with a morph waits [delay] so
/// it lands on the finished shape.
class _BadgeSlot extends StatefulWidget {
  const _BadgeSlot({
    required this.badge,
    required this.size,
    required this.delay,
  });

  final PowerBadge? badge;
  final double size;
  final Duration delay;

  @override
  State<_BadgeSlot> createState() => _BadgeSlotState();
}

class _BadgeSlotState extends State<_BadgeSlot> {
  late PowerBadge? _shown = widget.badge;
  Timer? _pending;

  @override
  void didUpdateWidget(_BadgeSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.badge == oldWidget.badge) return;
    _pending?.cancel();
    final delay = context.disableAnimations || widget.badge == null
        ? Duration.zero
        : widget.delay;
    if (delay == Duration.zero) {
      _show(widget.badge);
    } else {
      _pending = Timer(delay, () => _show(widget.badge));
    }
  }

  void _show(PowerBadge? badge) {
    if (!mounted || badge == _shown) return;
    if (badge?.tone == PowerTone.normal) {
      unawaited(HapticFeedback.lightImpact());
    }
    setState(() => _shown = badge);
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    return AnimatedSwitcher(
      duration: context.motionDuration(_badgeDuration),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: shown == null
          ? SizedBox.square(key: const ValueKey(0), dimension: widget.size)
          : _RimBadge(key: ValueKey(shown), badge: shown, size: widget.size),
    );
  }
}

class _RimBadge extends StatelessWidget {
  const _RimBadge({super.key, required this.badge, required this.size});

  final PowerBadge badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final (fill, ink) = switch (badge.tone) {
      PowerTone.normal => (colors.ok, colors.card),
      PowerTone.attention || PowerTone.problem => (colors.warn, colors.card),
      PowerTone.failure => (colorScheme.error, colorScheme.onError),
      PowerTone.quiet => (colors.tone2, colorScheme.onSurfaceVariant),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: fill,
        shape: AppShape.circle.copyWith(
          side: BorderSide(
            color: colors.page,
            width: 3,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: GlyphIcon(badge.glyph, size: size * 0.6, color: ink),
        ),
      ),
    );
  }
}
