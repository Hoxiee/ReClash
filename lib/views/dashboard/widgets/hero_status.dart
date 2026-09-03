import 'dart:math' as math;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:material_ui/material_ui.dart';

enum HeroOrbPhase { off, connecting, on, paused }

/// `unknown` is not a middle ground: it withholds the verdict, so a missing or
/// in-flight measurement can never paint the orb red.
enum HeroHealth { unknown, healthy, degraded, broken }

enum HeroStatus { off, connecting, secured, degraded, broken, paused }

extension HeroStatusExt on HeroStatus {
  bool get isLive => this != HeroStatus.off;

  bool get isAlert =>
      this == HeroStatus.paused ||
      this == HeroStatus.degraded ||
      this == HeroStatus.broken;

  bool get flows => this == HeroStatus.secured || this == HeroStatus.degraded;
}

/// Matches `getDelayColor`, so amber in the proxy list is never healthy here.
const heroDegradedDelay = 600;

HeroHealth heroHealthOf({required int? delay, required bool measuring}) {
  if (measuring) return HeroHealth.unknown;
  if (delay == null || delay == 0) return HeroHealth.unknown;
  if (delay < 0) return HeroHealth.broken;
  if (delay >= heroDegradedDelay) return HeroHealth.degraded;
  return HeroHealth.healthy;
}

HeroStatus heroStatusOf(HeroOrbPhase phase, HeroHealth health) =>
    switch (phase) {
      HeroOrbPhase.off => HeroStatus.off,
      HeroOrbPhase.connecting => HeroStatus.connecting,
      HeroOrbPhase.paused => HeroStatus.paused,
      HeroOrbPhase.on => switch (health) {
        HeroHealth.broken => HeroStatus.broken,
        HeroHealth.degraded => HeroStatus.degraded,
        HeroHealth.healthy || HeroHealth.unknown => HeroStatus.secured,
      },
    };

/// Log scale, so a few KB/s registers and tens of MB/s still has headroom.
double heroActivityOf(Traffic? traffic) {
  final bytes = (traffic?.speed ?? 0).toDouble();
  if (bytes <= 0) return 0;
  const floor = 8 * 1024;
  const ceiling = 8 * 1024 * 1024;
  final value = math.log(1 + bytes / floor) / math.log(1 + ceiling / floor);
  return value.clamp(0.0, 1.0);
}

const List<Color> heroRingColors = [
  Color(0xFF10EDF8),
  Color(0xFF2A8BFD),
  Color(0xFF6C58FC),
];

const List<Color> _pausedRing = [
  Color(0xFFFFE066),
  Color(0xFFFFC93C),
  Color(0xFFF2A60C),
];

const List<Color> _degradedRing = [
  Color(0xFFFFC078),
  Color(0xFFFF922B),
  Color(0xFFE8590C),
];

const List<Color> _brokenRing = [
  Color(0xFFFF8787),
  Color(0xFFF03E3E),
  Color(0xFFC92A2A),
];

class HeroPalette {
  const HeroPalette({
    required this.ring,
    required this.glow,
    required this.accent,
  });

  /// Sweep-gradient stops, ordered from the leading edge backwards.
  final List<Color> ring;
  final Color glow;
  final Color accent;

  static HeroPalette lerp(HeroPalette a, HeroPalette b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    return HeroPalette(
      ring: [
        for (var i = 0; i < a.ring.length; i++)
          Color.lerp(a.ring[i], b.ring[i], t)!,
      ],
      glow: Color.lerp(a.glow, b.glow, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
    );
  }
}

HeroPalette heroPaletteOf(BuildContext context, HeroStatus status) {
  final colorScheme = context.colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;

  List<Color> tuned(List<Color> ring) => [
    for (final color in ring)
      isDark
          ? color.harmonizeWith(colorScheme.primary)
          : color.harmonizeWith(colorScheme.primary).darken(6),
  ];

  HeroPalette alert(List<Color> ring) {
    final tunedRing = tuned(ring);
    return HeroPalette(
      ring: tunedRing,
      glow: tunedRing[1],
      accent: isDark ? tunedRing[0].lighten(4) : tunedRing[2].darken(12),
    );
  }

  switch (status) {
    case HeroStatus.off:
      final idle = colorScheme.outlineVariant;
      return HeroPalette(
        ring: [idle, idle, idle],
        glow: idle.opacity0,
        accent: colorScheme.onSurfaceVariant,
      );
    case HeroStatus.connecting:
    case HeroStatus.secured:
      final ring = tuned(heroRingColors);
      return HeroPalette(
        ring: ring,
        glow: ring[1],
        accent: colorScheme.primary,
      );
    case HeroStatus.paused:
      return alert(_pausedRing);
    case HeroStatus.degraded:
      return alert(_degradedRing);
    case HeroStatus.broken:
      return alert(_brokenRing);
  }
}
