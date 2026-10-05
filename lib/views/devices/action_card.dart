import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

/// A filled card that opens a device flow: a tinted medallion, a title/subtitle
/// pair and a trailing chevron. Shared by the devices list and the TV receiver.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tone,
  });

  final Glyph icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      padding: AppInsets.lg,
      onPressed: onTap,
      child: Row(
        children: [
          AppMedallion(icon: icon, tone: tone ?? colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GlyphIcon(
            AppGlyphs.chevronForward,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
