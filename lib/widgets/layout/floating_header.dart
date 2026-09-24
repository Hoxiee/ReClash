import 'package:material_ui/material_ui.dart';

/// Fades the surface behind [child] toward its foot so content reads through,
/// easing out over [overhang] past the foot so the fade shows no edge.
class FloatingHeader extends StatelessWidget {
  const FloatingHeader({
    super.key,
    required this.backgroundColor,
    this.fadeStart = 0.5,
    this.overhang = 0,
    required this.child,
  });

  static const _alpha = 0.9;
  static const _fadeSteps = 8;

  final Color backgroundColor;
  final double fadeStart;
  final double overhang;
  final Widget child;

  Gradient _scrimOf(double height) {
    final start = (height - overhang) * fadeStart / height;
    final stops = <double>[0];
    final colors = <Color>[backgroundColor.withValues(alpha: _alpha)];
    for (var i = 0; i <= _fadeSteps; i++) {
      final t = i / _fadeSteps;
      stops.add(start + (1 - start) * t);
      colors.add(
        backgroundColor.withValues(
          alpha: _alpha * (1 - Curves.easeInOut.transform(t)),
        ),
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: stops,
      colors: colors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -overhang,
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (_, constraints) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _scrimOf(constraints.maxHeight),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
