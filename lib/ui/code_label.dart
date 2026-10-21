import 'package:reclash/ui/context.dart';
import 'package:reclash/ui/shape.dart';
import 'package:reclash/ui/surface.dart';
import 'package:reclash/ui/text_style.dart';
import 'package:reclash/ui/typography.dart';
import 'package:material_ui/material_ui.dart';

class CodeLabel extends StatelessWidget {
  const CodeLabel(
    this.text, {
    super.key,
    this.maxLines,
    this.selectable = false,
  });

  final String text;
  final int? maxLines;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final level = context.raisedSurfaceLevel;
    final style = AppTextStyle.footnote
        .of(context)
        .toJetBrainsMono
        .copyWith(color: context.colorScheme.onSurface);
    return SurfaceScope(
      level: level,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: ShapeDecoration(
          color: level.colorOf(context.colorScheme),
          shape: AppShape.sm,
        ),
        child: selectable
            ? SelectableText(text, style: style)
            : Text(
                text,
                maxLines: maxLines,
                overflow: maxLines == null ? null : TextOverflow.ellipsis,
                style: style,
              ),
      ),
    );
  }
}
