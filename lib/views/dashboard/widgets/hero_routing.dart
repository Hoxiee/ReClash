import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class HeroRoutingRow extends StatelessWidget {
  const HeroRoutingRow({super.key});

  @override
  Widget build(BuildContext context) {
    final muted =
        context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
      child: Row(
        children: [
          Icon(Icons.pause_circle_outline, size: 15, color: muted),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              context.appLocalizations.heroRoutingStub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
