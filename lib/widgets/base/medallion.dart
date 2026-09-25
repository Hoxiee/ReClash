import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/widgets/feedback/loading.dart';
import 'package:material_ui/material_ui.dart';

/// A tinted rounded square holding one state-coloured glyph: the app's single
/// way to mark a thing with a status, so every medallion reads as one family.
class AppMedallion extends StatelessWidget {
  const AppMedallion({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 38,
    this.busy = false,
  });

  final Glyph icon;
  final Color tone;
  final double size;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: AppShape.all(size / 2.8),
        color: tone.withValues(alpha: 0.14),
      ),
      child: busy
          ? SizedBox.square(
              dimension: size * 0.44,
              child: CommonCircleLoading(color: tone),
            )
          : GlyphIcon(icon, size: size * 0.5, color: tone),
    );
  }
}
