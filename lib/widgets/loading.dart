import 'dart:async';
import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';

enum LoadingIndicatorM3EVariant { defaultStyle, contained }

class CommonCircleLoading extends StatefulWidget {
  static const double defaultDimension = 48;

  final LoadingIndicatorM3EVariant variant;
  final Color? color;
  final Color? containerColor;
  final List<RoundedPolygon>? polygons;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;
  final String? semanticValue;

  const CommonCircleLoading({
    super.key,
    this.variant = LoadingIndicatorM3EVariant.defaultStyle,
    this.color,
    this.containerColor,
    this.polygons,
    this.constraints,
    this.padding,
    this.semanticLabel,
    this.semanticValue,
  }) : assert(polygons == null || polygons.length > 1);

  @override
  State<CommonCircleLoading> createState() => _CommonCircleLoadingState();
}

class _CommonCircleLoadingState extends State<CommonCircleLoading>
    with TickerProviderStateMixin {
  static const _globalRotationDuration = Duration(milliseconds: 4666);
  static const _morphInterval = Duration(milliseconds: 650);
  static const _fullRotation = 360.0;
  static const _quarterRotation = _fullRotation / 4;
  static const _activeIndicatorScale = 38 / 48;
  static const _defaultConstraints = BoxConstraints.tightFor(
    width: CommonCircleLoading.defaultDimension,
    height: CommonCircleLoading.defaultDimension,
  );

  static final double _globalRotationSeconds =
      _globalRotationDuration.inMicroseconds / Duration.microsecondsPerSecond;
  static final double _morphCycleSeconds =
      _morphInterval.inMicroseconds / Duration.microsecondsPerSecond;

  static final List<RoundedPolygon> _defaultShapeSequence = [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.oval,
  ];

  final SpringSimulation _morphAnimation = SpringSimulation(
    SpringDescription.withDampingRatio(mass: 1, stiffness: 200, ratio: 0.6),
    0,
    1,
    5,
    snapToEnd: true,
  );

  late final AnimationController _clock;
  var _animating = false;

  List<RoundedPolygon>? _cachedPolygons;
  List<Morph>? _cachedMorphs;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController.unbounded(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  // The clock counts elapsed seconds monotonically and never wraps, so every
  // phase derived from it (morph index, morph progress, rotation) is
  // continuous. Pausing freezes the count; resuming continues from it.
  void _syncAnimation() {
    final shouldAnimate =
        !context.disableAnimations && TickerMode.valuesOf(context).enabled;
    if (shouldAnimate == _animating) {
      return;
    }
    _animating = shouldAnimate;
    if (shouldAnimate) {
      unawaited(_clock.animateWith(_MonotonicClock(_clock.value)));
    } else {
      _clock.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = switch (widget.variant) {
      LoadingIndicatorM3EVariant.defaultStyle =>
        widget.color ?? colorScheme.primary,
      LoadingIndicatorM3EVariant.contained =>
        widget.color ?? colorScheme.onPrimaryContainer,
    };
    final backgroundColor = switch (widget.variant) {
      LoadingIndicatorM3EVariant.defaultStyle =>
        widget.containerColor ?? Colors.transparent,
      LoadingIndicatorM3EVariant.contained =>
        widget.containerColor ?? colorScheme.primaryContainer,
    };
    final shapeSequence = widget.polygons ?? _defaultShapeSequence;
    final morphs = _morphsFor(shapeSequence);
    final padding = (widget.padding ?? EdgeInsets.zero).resolve(
      Directionality.of(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final indicatorConstraints = constraints.deflate(padding);
        final dimension = _resolveDimension(
          indicatorConstraints,
          widget.constraints ?? _defaultConstraints,
        );
        return Align(
          widthFactor: 1,
          heightFactor: 1,
          child: Semantics(
            label: widget.semanticLabel,
            value: widget.semanticValue,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: AppRadius.full,
              ),
              child: Padding(
                padding: padding,
                child: RepaintBoundary(
                  child: SizedBox.square(
                    dimension: dimension,
                    child: AnimatedBuilder(
                      animation: _clock,
                      builder: (context, child) {
                        final elapsed = _clock.value;
                        final completedMorphs = elapsed ~/ _morphCycleSeconds;
                        final cycleOffset =
                            elapsed - completedMorphs * _morphCycleSeconds;
                        final morphProgress = _morphAnimation
                            .x(cycleOffset)
                            .clamp(0.0, 1.0);
                        final rotationDegrees =
                            morphProgress * _quarterRotation +
                            (completedMorphs + 1) *
                                _quarterRotation %
                                _fullRotation +
                            elapsed / _globalRotationSeconds * _fullRotation;
                        return Transform.rotate(
                          angle: rotationDegrees * math.pi / 180,
                          child: CustomPaint(
                            painter: _MorphPainter(
                              morph:
                                  morphs[completedMorphs.truncate() %
                                      shapeSequence.length],
                              progress: morphProgress,
                              color: activeColor,
                              scaleFactor: _activeIndicatorScale,
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Morph> _morphsFor(List<RoundedPolygon> polygons) {
    final cachedMorphs = _cachedMorphs;
    if (cachedMorphs != null && listEquals(_cachedPolygons, polygons)) {
      return cachedMorphs;
    }
    _cachedPolygons = polygons;
    return _cachedMorphs = [
      for (var i = 0; i < polygons.length; i++)
        Morph(polygons[i], polygons[(i + 1) % polygons.length]),
    ];
  }

  double _resolveDimension(
    BoxConstraints parentConstraints,
    BoxConstraints preferredConstraints,
  ) {
    final effectiveConstraints = preferredConstraints.enforce(
      BoxConstraints(
        maxWidth: parentConstraints.maxWidth,
        maxHeight: parentConstraints.maxHeight,
      ),
    );
    final maxWidth = effectiveConstraints.maxWidth;
    final maxHeight = effectiveConstraints.maxHeight;

    if (maxWidth.isFinite && maxHeight.isFinite) {
      return maxWidth < maxHeight ? maxWidth : maxHeight;
    }

    if (maxWidth.isFinite) {
      return maxWidth;
    }

    if (maxHeight.isFinite) {
      return maxHeight;
    }

    return CommonCircleLoading.defaultDimension;
  }
}

class _MonotonicClock extends Simulation {
  _MonotonicClock(this._initialSeconds);

  final double _initialSeconds;

  @override
  double x(double timeInSeconds) => _initialSeconds + timeInSeconds;

  @override
  double dx(double timeInSeconds) => 1.0;

  @override
  bool isDone(double timeInSeconds) => false;
}

class _MorphPainter extends CustomPainter {
  final Morph morph;
  final double progress;
  final Color color;
  final double scaleFactor;
  final Paint _paint;

  _MorphPainter({
    required this.morph,
    required this.progress,
    required this.color,
    required this.scaleFactor,
  }) : _paint = Paint()
         ..style = PaintingStyle.fill
         ..isAntiAlias = true
         ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width * scaleFactor;
    final offset = (size.width - scale) / 2;
    canvas.save();
    canvas.translate(offset, offset);
    canvas.scale(scale);
    canvas.drawPath(morph.toPath(progress: progress), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MorphPainter oldDelegate) {
    return oldDelegate.morph != morph ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
