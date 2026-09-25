import 'package:reclash/icons/icons.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';

class DashboardInfoCard extends StatelessWidget {
  const DashboardInfoCard({
    super.key,
    required this.height,
    required this.icon,
    required this.label,
    required this.child,
    this.leading,
    this.action,
    this.onPressed,
  });

  final double height;
  final Glyph icon;
  final String label;
  final Widget child;

  /// Stands in for [icon] when a tile has something better to identify itself
  /// with, such as the flag of the country it is reporting on.
  final Widget? leading;
  final Widget? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RepaintBoundary(
        child: CommonCard(
          radius: DashboardWidgetMetrics.radiusOf(context),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    leading ??
                        GlyphIcon(
                          icon,
                          size: 20,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      action!,
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
