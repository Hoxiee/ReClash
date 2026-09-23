import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/companion.dart';
import 'package:reclash/widgets/theme/wallpaper_scope.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

// Shared visual kit for the companion surfaces. It mirrors the dashboard's card language
// (superellipse AppShape, tinted metric tiles, mono numerals) so the panels do not invent a
// second visual system, and every tappable card carries the TV focus outline.

class CompanionCard extends StatelessWidget {
  const CompanionCard({
    super.key,
    required this.child,
    this.tone,
    this.onTap,
    this.autofocus = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  final Widget child;
  final Color? tone;
  final VoidCallback? onTap;
  final bool autofocus;
  final EdgeInsetsGeometry padding;

  Color _base(BuildContext context) => tone == null
      ? context.colorScheme.surfaceContainerHigh
      : tone!.withValues(alpha: 0.12);

  @override
  Widget build(BuildContext context) {
    final base = _base(context);
    if (onTap == null) {
      return DecoratedBox(
        decoration: ShapeDecoration(
          shape: AppShape.xl,
          color: WallpaperSurfaceScope.colorOf(context, base),
        ),
        child: Padding(padding: padding, child: child),
      );
    }
    return ValueListenableBuilder<bool>(
      valueListenable: FocusHighlightVisibility.visible,
      builder: (context, _, _) => FilledButton(
        autofocus: autofocus,
        onPressed: onTap,
        style:
            FilledButton.styleFrom(
              padding: padding,
              shape: AppShape.xl,
              elevation: 0,
              side: BorderSide.none,
              foregroundColor: context.colorScheme.onSurface,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => _background(context, states, base),
              ),
              overlayColor: WidgetStateProperty.resolveWith(
                (states) => companionFocusOverlay(context, states),
              ),
              side: WidgetStateProperty.resolveWith(
                (states) => companionFocusSide(context, states),
              ),
            ),
        child: child,
      ),
    );
  }

  Color? _background(BuildContext context, Set<WidgetState> states, Color base) {
    var color = base;
    if (companionFocusVisible(states)) {
      color = Color.alphaBlend(
        context.colorScheme.primary.withValues(alpha: system.isTV ? 0.20 : 0.12),
        color,
      );
    }
    return WallpaperSurfaceScope.colorOf(context, color);
  }
}

// Focus is shown the way the app's own cards show it (WidgetState.focused gated by the
// focus-visible flag): a primary ring plus a soft overlay, and never after a mouse click.
bool companionFocusVisible(Set<WidgetState> states) =>
    states.contains(WidgetState.focused) &&
    FocusHighlightVisibility.visible.value;

BorderSide companionFocusSide(BuildContext context, Set<WidgetState> states) =>
    companionFocusVisible(states)
    ? BorderSide(color: context.colorScheme.primary, width: 2)
    : BorderSide.none;

Color? companionFocusOverlay(BuildContext context, Set<WidgetState> states) {
  final base = context.colorScheme.onSurface;
  if (states.contains(WidgetState.pressed)) return base.withValues(alpha: 0.10);
  if (states.contains(WidgetState.hovered)) return base.withValues(alpha: 0.08);
  if (companionFocusVisible(states)) return base.withValues(alpha: 0.08);
  return null;
}

// Lands the focus ring on the first control when a pushed companion route opens (D-pad/keyboard).
class CompanionPage extends StatelessWidget {
  const CompanionPage({super.key, required this.child, this.autofocus = true});

  final Widget child;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return PageFocusScope(
      autofocus: autofocus,
      child: FocusTraversalGroup(
        policy: PageTraversalPolicy(),
        child: child,
      ),
    );
  }
}

class CompanionSectionTitle extends StatelessWidget {
  const CompanionSectionTitle({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: ShapeDecoration(
        shape: AppShape.md,
        color: tone.withValues(alpha: 0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tone),
              const SizedBox(width: 6),
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
          const SizedBox(height: 6),
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

class CompanionDelayPill extends StatelessWidget {
  const CompanionDelayPill({super.key, required this.delayMs});

  final int? delayMs;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final delay = delayMs;
    if (delay == null || delay <= 0) {
      return Text(
        l.companionNoMeasurement,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final color =
        context.colorScheme.delayColor(delay) ??
        context.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        shape: AppShape.all(AppCorner.full),
        color: color.withValues(alpha: 0.14),
      ),
      child: Text(
        '$delay ms',
        style: context.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.jetBrainsMono.value,
        ),
      ),
    );
  }
}

class CompanionStatusDot extends StatelessWidget {
  const CompanionStatusDot({super.key, required this.color, this.pulsing = false});

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
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)]
            : null,
      ),
    );
  }
}

class CompanionIconBadge extends StatelessWidget {
  const CompanionIconBadge({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 44,
  });

  final IconData icon;
  final Color tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        shape: AppShape.md,
        color: tone.withValues(alpha: 0.14),
      ),
      child: Icon(icon, color: tone, size: size * 0.5),
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
