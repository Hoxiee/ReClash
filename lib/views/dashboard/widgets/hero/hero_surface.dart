import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
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

const Object heroReserveGesture = Object();

class HeroReserveGesture extends StatelessWidget {
  const HeroReserveGesture({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      MetaData(metaData: heroReserveGesture, child: child);
}

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
    this.onPressed,
    this.onLongPress,
  });

  final Widget child;
  final double radius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Color? accent;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    Widget card = CommonCard(
      radius: radius,
      accent: accent,
      padding: padding,
      onPressed: onPressed,
      onLongPress: onLongPress,
      minimumSize: Size.zero,
      visualDensity: VisualDensity.standard,
      clipBehavior: Clip.none,
      child: alignment == null
          ? child
          : Align(alignment: alignment!, child: child),
    );
    if (width != null || height != null) {
      card = SizedBox(width: width, height: height, child: card);
    }
    return card;
  }
}
