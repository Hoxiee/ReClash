import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A whitelisted decorative overlay a panel switches on by preset name, never
/// by code. Mirrors [SeasonalDashboardOverlay]'s gating and never-remount Stack.
class ProviderEffectOverlay extends ConsumerStatefulWidget {
  const ProviderEffectOverlay({
    super.key,
    required this.child,
    this.visible = true,
  });

  final bool visible;

  final Widget child;

  @override
  ConsumerState<ProviderEffectOverlay> createState() =>
      _ProviderEffectOverlayState();
}

class _ProviderEffectOverlayState extends ConsumerState<ProviderEffectOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(
      milestoneSettingProvider.select((state) => state.providerEffectsEnabled),
    );
    final effect = ref.watch(providerHeroEffectProvider);
    final status = heroStatusOf(
      ref.watch(heroLifecycleProvider),
      ref.watch(connectionDoctorProvider.select(heroDoctorHealthOf)),
    );
    final profile = ref.watch(currentProfileProvider);
    final subscription = profile?.subscriptionInfo;
    final visible =
        widget.visible &&
        enabled &&
        effect != ProviderHeroEffect.none &&
        PageActivityScope.isActiveOf(context) &&
        (ModalRoute.of(context)?.isCurrent ?? true) &&
        !(subscription != null &&
            subscriptionIsExpired(
              expire: subscription.expire,
              now: DateTime.now(),
            )) &&
        status == HeroStatus.secured;
    final reduceMotion =
        context.disableAnimations || ref.watch(appSettingProvider).reduceMotion;
    if (visible && !reduceMotion && !_ticker.isAnimating) {
      _ticker.repeat();
    } else if ((!visible || reduceMotion) && _ticker.isAnimating) {
      _ticker.stop();
    }
    final ring =
        parsePanelHeroRing(profile?.panelMeta?.heroRing) ??
        <Color>[context.colorScheme.primary];
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (visible)
          IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _ticker,
                builder: (_, _) => CustomPaint(
                  painter: _AuroraPainter(
                    progress: reduceMotion ? 0.28 : _ticker.value,
                    colors: ring,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  /// Per-ribbon `(centre, amplitude, wavelength, phase, speed)`, canvas fractions.
  static const _ribbons = <(double, double, double, double, double)>[
    (0.14, 0.05, 0.9, 0.00, 1.00),
    (0.22, 0.07, 1.3, 0.35, 0.72),
    (0.30, 0.04, 0.7, 0.68, 1.24),
  ];

  Color _colorAt(double t) {
    if (colors.length == 1) return colors.first;
    final span = t * (colors.length - 1);
    final index = span.floor().clamp(0, colors.length - 2);
    return Color.lerp(colors[index], colors[index + 1], span - index)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _ribbons.length; i++) {
      final (centre, amplitude, wavelength, phase, speed) = _ribbons[i];
      final color = _colorAt(
        _ribbons.length == 1 ? 0 : i / (_ribbons.length - 1),
      );
      final y = centre * size.height;
      final band = size.height * (0.10 + amplitude);
      final path = Path()..moveTo(0, y);
      const steps = 24;
      for (var s = 0; s <= steps; s++) {
        final x = size.width * s / steps;
        final wave =
            math.sin(
              (s / steps) * math.pi * 2 * wavelength +
                  (progress * speed + phase) * math.pi * 2,
            ) *
            amplitude *
            size.height;
        path.lineTo(x, y + wave);
      }
      path
        ..lineTo(size.width, y + band)
        ..lineTo(0, y + band)
        ..close();
      final shimmer = lerpDouble(
        0.10,
        0.20,
        (math.sin((progress * speed + phase) * math.pi * 2) + 1) / 2,
      )!;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: shimmer),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, y, size.width, band))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors;
}
