import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/companion.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

// Companion-only pieces the canonical catalog has no twin for: the TV focus landing, the paired
// tinted metric tile, the subscription quota bar and the reachability tone. Everything else on the
// companion surfaces (cards, medallions, tags, section headers) uses the shared design system.

// Lands the focus ring on the first control when a pushed companion route opens (D-pad/keyboard).
class CompanionPage extends StatelessWidget {
  const CompanionPage({super.key, required this.child, this.autofocus = true});

  final Widget child;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return PageFocusScope(
      autofocus: autofocus,
      child: FocusTraversalGroup(policy: PageTraversalPolicy(), child: child),
    );
  }
}

class CompanionMetric extends StatelessWidget {
  const CompanionMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final Glyph icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.md,
      decoration: ShapeDecoration(
        shape: AppShape.md,
        color: tone.withValues(alpha: 0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlyphIcon(icon, size: 16, color: tone),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.jetBrainsMono.value,
            ),
          ),
        ],
      ),
    );
  }
}

class CompanionQuotaBar extends StatelessWidget {
  const CompanionQuotaBar({super.key, required this.fraction, this.tone});

  final double fraction;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final color = tone ?? context.colorScheme.primary;
    return ClipRRect(
      borderRadius: AppRadius.full,
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: 10,
        backgroundColor: context.colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class CompanionStatusDot extends StatelessWidget {
  const CompanionStatusDot({
    super.key,
    required this.color,
    this.pulsing = false,
  });

  final Color color;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: pulsing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

Color companionReachabilityColor(
  BuildContext context,
  CompanionReachability reachability,
) {
  final colorScheme = context.colorScheme;
  return switch (reachability) {
    CompanionReachability.reachable => colorScheme.primary,
    CompanionReachability.identityChanged ||
    CompanionReachability.accessRevoked => colorScheme.error,
    CompanionReachability.incompatible => colorScheme.tertiary,
    _ => colorScheme.onSurfaceVariant,
  };
}
