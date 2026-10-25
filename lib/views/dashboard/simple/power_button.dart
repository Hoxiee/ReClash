import 'dart:async';
import 'dart:math' as math;

import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';

/// What the button shows; [paused] is a run the on-demand rules hold.
enum PowerLink { off, connecting, on, paused }

const _morphDuration = Duration(milliseconds: 450);
const _stateDuration = Duration(milliseconds: 150);
const _haloPeriod = Duration(seconds: 24);

const _connectingProgress = 0.45;

const _haloSize = 1.34;
const _plateSize = 0.54;

final _morph = Morph(MaterialShapes.circle, MaterialShapes.cookie9Sided);

Path _morphPath(double progress) =>
    _morph.toPath(progress: progress, rotationPivotX: 0.5, rotationPivotY: 0.5);

double _morphTurn(double progress) => progress * 2 * math.pi / 9;

const _greyscale = ColorFilter.matrix([
  0.33, 0.59, 0.11, 0, 0, //
  0.33, 0.59, 0.11, 0, 0,
  0.33, 0.59, 0.11, 0, 0,
  0, 0, 0, 1, 0,
]);

/// The provider's logo on a plate in the middle of a shape that grows from a
/// circle into the cookie-9 of a running tunnel.
class PowerButton extends StatefulWidget {
  const PowerButton({
    super.key,
    required this.link,
    required this.size,
    required this.logo,
    required this.tooltip,
    required this.onPressed,
  });

  final PowerLink link;
  final double size;

  /// The provider's logo URL or data URI; empty draws the power glyph.
  final String logo;
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
    }
  }

  void _syncHalo() {
    final spinning =
        widget.link == PowerLink.on || widget.link == PowerLink.connecting;
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
    final fill = switch (link) {
      PowerLink.off => colors.tone,
      PowerLink.connecting || PowerLink.paused => colorScheme.primaryContainer,
      PowerLink.on => colorScheme.primary,
    };
    final ink = switch (link) {
      PowerLink.off => colorScheme.onSurface,
      PowerLink.connecting ||
      PowerLink.paused => colorScheme.onPrimaryContainer,
      PowerLink.on => colorScheme.onPrimary,
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
                progress: progress,
                color: glass ? null : color,
                shadow: link == PowerLink.off
                    ? Colors.black.withValues(alpha: 0.25)
                    : colorScheme.primary.withValues(alpha: 0.3),
                ring: _focused
                    ? focusRingSide(colorScheme, standsOff: true)
                    : null,
              ),
              child: SizedBox.square(dimension: size),
            );
            if (!glass) return painted;
            return LiquidGlass(
              style: LiquidGlassStyle.tinted(colorScheme, color),
              clipper: _BodyClipper(progress),
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
          _Halo(link: link, size: size, turns: _halo),
          Tooltip(
            message: widget.tooltip,
            child: Semantics(
              button: true,
              enabled: enabled,
              label: widget.tooltip,
              child: InkResponse(
                onTap: widget.onPressed,
                onHover: (value) => setState(() => _hovered = value),
                onHighlightChanged: (value) => setState(() => _pressed = value),
                onFocusChange: (value) => setState(() => _focused = value),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
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
                        muted: link == PowerLink.off,
                        raised: link == PowerLink.on,
                      ),
                    ],
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
  const _Halo({required this.link, required this.size, required this.turns});

  final PowerLink link;
  final double size;
  final Animation<double> turns;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final halo = size * _haloSize;
    final Widget child = switch (link) {
      PowerLink.off => ShapeBadge(
        shape: MaterialShapes.circle,
        color: colors.card,
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
          final rotation = 0.12 + turns.value * 2 * math.pi / 9;
          final tint = link == PowerLink.on
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant;
          return Stack(
            alignment: Alignment.center,
            children: [
              ShapeBadge(
                shape: MaterialShapes.cookie9Sided,
                color: tint.withValues(alpha: 0.06),
                size: halo,
                rotation: rotation,
              ),
              ShapeBadge(
                shape: MaterialShapes.cookie9Sided,
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
        key: ValueKey(link == PowerLink.paused ? PowerLink.on : link),
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
    required this.muted,
    required this.raised,
  });

  final double size;
  final String logo;
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
        child: CommonTargetIcon(src: logo, fallback: fallback),
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
    required this.progress,
    required this.color,
    required this.shadow,
    required this.ring,
  });

  static const _shadowOffset = Offset(0, 10);
  static const _shadowBlur = 28.0;

  final double progress;
  final Color? color;
  final Color shadow;
  final BorderSide? ring;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _morphPath(progress);
    final color = this.color;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_morphTurn(progress))
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
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.shadow != shadow ||
      oldDelegate.ring != ring;
}

class _BodyClipper extends CustomClipper<Path> {
  const _BodyClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final transform =
        Matrix4.translationValues(size.width / 2, size.height / 2, 0)
          ..rotateZ(_morphTurn(progress))
          ..scaleByDouble(size.width, size.height, 1, 1)
          ..translateByDouble(-0.5, -0.5, 0, 1);
    return _morphPath(progress).transform(transform.storage);
  }

  @override
  bool shouldReclip(_BodyClipper oldClipper) => oldClipper.progress != progress;
}
