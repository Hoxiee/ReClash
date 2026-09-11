import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
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
  final IconData icon;
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
          radius: AppCorner.lg,
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    leading ??
                        Icon(
                          icon,
                          size: 20,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                    const SizedBox(width: 8),
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
                    if (action != null) ...[const SizedBox(width: 8), action!],
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
