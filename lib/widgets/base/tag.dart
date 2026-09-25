import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

/// The app's single small labelled tag: colour is caller-supplied (it carries
/// role/tone/level meaning) while the chrome is fixed so tags read as one family.
class AppTag extends StatelessWidget {
  const AppTag(
    this.label, {
    super.key,
    this.foreground,
    this.background,
    this.side,
    this.shape,
    this.mono = false,
    this.uppercase = false,
    this.letterSpacing = 0.2,
    this.fontWeight = FontWeight.w600,
    this.onTap,
    this.maxLines = 1,
  });

  final String label;
  final Color? foreground;
  final Color? background;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final bool mono;
  final bool uppercase;
  final double letterSpacing;
  final FontWeight fontWeight;
  final VoidCallback? onTap;
  final int maxLines;

  static const _padding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final fill =
        background ??
        (side != null ? Colors.transparent : colorScheme.surfaceContainerHighest);
    var shapeBorder = shape ?? AppShape.sm;
    if (side != null) {
      shapeBorder = shapeBorder.copyWith(side: side);
    }
    var textStyle = context.textTheme.labelSmall?.copyWith(
      color: foreground ?? colorScheme.onSurfaceVariant,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
    if (mono) {
      textStyle = textStyle?.toJetBrainsMono;
    }
    final text = Text(
      uppercase ? label.toUpperCase() : label,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
    if (onTap != null) {
      return Material(
        color: fill,
        shape: shapeBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: _padding, child: text),
        ),
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(color: fill, shape: shapeBorder),
      child: Padding(padding: _padding, child: text),
    );
  }
}
