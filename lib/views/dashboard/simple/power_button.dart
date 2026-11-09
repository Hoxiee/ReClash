import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/provider_image.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';

export 'package:reclash/features/power/face.dart' show PowerLink, PowerTone;

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

const _haloSize = 1.34;
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

double _morphTurn(ProviderPowerShape shape, double progress) =>
    progress * 2 * math.pi / _silhouettes[shape]!.symmetry;

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
    required this.tooltip,
    required this.onPressed,
    this.look = defaultProviderPowerButton,
    this.tone = PowerTone.normal,
    this.badge,
    this.spin = false,
  });

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
  final String tooltip;

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
  var _hovered = false;
  var _pressed = false;
  var _focused = false;

  static double _targetOf(PowerLink link) => switch (link) {
    PowerLink.off => 0,
    PowerLink.connecting => _connectingProgress,
    PowerLink.on || PowerLink.paused => 1,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncHalo();
  }

  @override
  void didUpdateWidget(PowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    final stateDuration = context.motionDuration(_stateDuration);
    final body = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: fill),
      duration: context.motionDuration(_morphDuration),
      builder: (_, fill, _) => TweenAnimationBuilder<double>(
        tween: Tween(end: _overlay),
        duration: stateDuration,
        builder: (_, overlay, _) => AnimatedBuilder(
          animation: _morphController,
          builder: (_, _) {
            final progress = _morphController.value;
            final color = Color.alphaBlend(
              ink.withValues(alpha: overlay),
              fill!,
            );
            final painted = CustomPaint(
              painter: _BodyPainter(
                shape: shape,
                progress: progress,
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
            if (!glass || hollow) return painted;
            return LiquidGlass(
              style: LiquidGlassStyle.tinted(colorScheme, color),
              clipper: _BodyClipper(shape, progress),
              pressed: _pressed,
              child: painted,
            );
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
          Tooltip(
            message: widget.tooltip,
            child: Semantics(
              button: true,
              enabled: enabled,
              label: widget.tooltip,
              child: GestureDetector(
                onHorizontalDragUpdate: (_) {},
                onVerticalDragUpdate: (_) {},
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
                        _LogoPlate(
                          size: size * _plateSize,
                          logo: widget.logo,
                          images: widget.images,
                          muted: link == PowerLink.off,
                          raised: link == PowerLink.on,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(size * 0.33, size * 0.33),
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
    required this.color,
    required this.shadow,
    required this.ring,
  });

  static const _shadowOffset = Offset(0, 10);
  static const _shadowBlur = 28.0;

  final ProviderPowerShape shape;
  final double progress;
  final Color? color;
  final Color shadow;
  final BorderSide? ring;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _morphPath(shape, progress);
    final color = this.color;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_morphTurn(shape, progress))
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
      oldDelegate.color != color ||
      oldDelegate.shadow != shadow ||
      oldDelegate.ring != ring;
}

class _BodyClipper extends CustomClipper<Path> {
  const _BodyClipper(this.shape, this.progress);

  final ProviderPowerShape shape;
  final double progress;

  @override
  Path getClip(Size size) {
    final transform =
        Matrix4.translationValues(size.width / 2, size.height / 2, 0)
          ..rotateZ(_morphTurn(shape, progress))
          ..scaleByDouble(size.width, size.height, 1, 1)
          ..translateByDouble(-0.5, -0.5, 0, 1);
    return _morphPath(shape, progress).transform(transform.storage);
  }

  @override
  bool shouldReclip(_BodyClipper oldClipper) =>
      oldClipper.shape != shape || oldClipper.progress != progress;
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
