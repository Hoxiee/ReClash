import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

const double heroPillRadius = AppCorner.full;
const double heroCardRadius = AppCorner.lg;
const double heroInlayRadius = AppCorner.sm;
const double heroBoardMaxWidth = 560;

/// Ceilings for the two-column board. The left one stops just past the widest
/// orb plus its caption; the right one keeps card text at a readable measure
/// on a 1600px window instead of stretching it edge to edge.
const double heroSplitLeftMaxWidth = 420;
const double heroSplitRightMaxWidth = 560;
const double heroSplitGap = 24;

BoxDecoration heroSurfaceDecoration(
  BuildContext context, {
  double radius = heroCardRadius,
  Color? accent,
}) {
  final colorScheme = context.colorScheme;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: accent == null
        ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
        : Color.alphaBlend(
            accent.withValues(alpha: 0.06),
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
          ),
    border: Border.all(
      color:
          accent?.withValues(alpha: 0.42) ??
          colorScheme.outlineVariant.withValues(alpha: 0.6),
    ),
  );
}

class HeroCardDivider extends StatelessWidget {
  const HeroCardDivider({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: context.colorScheme.outlineVariant.withValues(alpha: 0.6),
  );
}

class HeroSurface extends StatelessWidget {
  const HeroSurface({
    super.key,
    required this.child,
    this.radius = heroCardRadius,
    this.padding,
    this.width = double.infinity,
    this.height,
    this.alignment,
    this.accent,
  });

  final Widget child;
  final double radius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Color? accent;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: context.motionDuration(const Duration(milliseconds: 420)),
    curve: Easing.standard,
    width: width,
    height: height,
    padding: padding,
    alignment: alignment,
    decoration: heroSurfaceDecoration(context, radius: radius, accent: accent),
    child: child,
  );
}
