import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// Plays [spring] over the first [seconds] of an animation, easing out the
/// remaining residual so the curve still ends exactly at 1.
class SpringCurve extends Curve {
  SpringCurve(SpringDescription spring, {required this.seconds})
    : _simulation = SpringSimulation(spring, 0, 1, 0);

  final double seconds;
  final SpringSimulation _simulation;

  late final double _residual = 1 - _simulation.x(seconds);

  @override
  double transformInternal(double t) =>
      _simulation.x(t * seconds) + _residual * t;
}

class AppSprings {
  AppSprings._();

  static final route = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 440),
  );

  static final sheet = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 420),
  );

  static final morph = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 420),
    bounce: 0.28,
  );
}

class AppSpringCurves {
  AppSpringCurves._();

  static final route = SpringCurve(AppSprings.route, seconds: 0.5);

  static final sheet = SpringCurve(AppSprings.sheet, seconds: 0.5);

  /// Overshoots past 1 mid-flight, so drive a scale with it, never an opacity.
  static final morph = SpringCurve(AppSprings.morph, seconds: 0.55);
}
