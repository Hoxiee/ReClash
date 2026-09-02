import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

const double heroPillRadius = AppCorner.full;
const double heroCardRadius = AppCorner.lg;
const double heroInlayRadius = AppCorner.sm;
const double heroBoardMaxWidth = 560;

BoxDecoration heroSurfaceDecoration(
  BuildContext context, {
  double radius = heroCardRadius,
}) {
  final colorScheme = context.colorScheme;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
    border: Border.all(
      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
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
  });

  final Widget child;
  final double radius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    padding: padding,
    alignment: alignment,
    decoration: heroSurfaceDecoration(context, radius: radius),
    child: child,
  );
}
