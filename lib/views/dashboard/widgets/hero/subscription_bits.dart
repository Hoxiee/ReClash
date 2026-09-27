import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';

/// The subscription's time status as a pill — days remaining, perpetual, or
/// expired. Shared by the hero strip and the classic dashboard tile so both
/// read the quota with one visual language.
class SubscriptionPill extends StatelessWidget {
  const SubscriptionPill({
    super.key,
    required this.color,
    required this.label,
    this.glyph = AppGlyphs.calendar,
  });

  final Color color;
  final String label;
  final Glyph glyph;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(heroPillRadius),
      color: color.withValues(alpha: 0.14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlyphIcon(glyph, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

/// The gradient quota bar shown under the subscription figures.
class SubscriptionBar extends StatelessWidget {
  const SubscriptionBar({
    super.key,
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final trackColor = context.colorScheme.surfaceContainerHighest;
    final gradient = LinearGradient(
      colors: [color.withValues(alpha: 0.7), color],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(heroInlayRadius),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: progress, end: progress),
        duration: context.motionDuration(const Duration(milliseconds: 420)),
        curve: Easing.standard,
        builder: (context, value, _) => CustomPaint(
          size: const Size(double.infinity, 8),
          painter: _SubscriptionBarPainter(
            progress: value,
            trackColor: trackColor,
            gradient: gradient,
          ),
        ),
      ),
    );
  }
}

class _SubscriptionBarPainter extends CustomPainter {
  const _SubscriptionBarPainter({
    required this.progress,
    required this.trackColor,
    required this.gradient,
  });

  final double progress;
  final Color trackColor;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..color = trackColor;
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        rect,
        const Radius.circular(heroInlayRadius),
      ),
      paint,
    );
    if (progress <= 0) return;
    final fillPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        Offset.zero & Size(size.width * progress, size.height),
        const Radius.circular(heroInlayRadius),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_SubscriptionBarPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.gradient != gradient;
}
