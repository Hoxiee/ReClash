import 'dart:math' as math;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// No health: `broken` is a verdict on a tunnel that is still `on`.
enum HeroOrbPhase {
  offline,
  off,
  checking,
  connecting,
  reconnecting,
  on,
  paused,
}

/// `unknown` is not a middle ground: it withholds the verdict, so a missing or
/// in-flight measurement can never paint the orb red.
enum HeroHealth { unknown, healthy, degraded, broken }

enum HeroStatus {
  offline,
  off,
  checking,
  connecting,
  reconnecting,
  secured,
  degraded,
  broken,
  paused,
}

extension HeroStatusExt on HeroStatus {
  bool get isLive =>
      this != HeroStatus.offline &&
      this != HeroStatus.off &&
      this != HeroStatus.checking;

  bool get isAlert =>
      this == HeroStatus.paused ||
      this == HeroStatus.degraded ||
      this == HeroStatus.broken ||
      this == HeroStatus.offline;

  bool get isSweeping =>
      this == HeroStatus.checking ||
      this == HeroStatus.connecting ||
      this == HeroStatus.reconnecting;

  bool get isTransitioning =>
      this == HeroStatus.connecting || this == HeroStatus.reconnecting;

  bool get flows => this == HeroStatus.secured || this == HeroStatus.degraded;
}

/// Only the breathe period reads this: `repeat` captures its period.
enum HeroOrbActivity { idle, active }

HeroOrbActivity heroActivityBandOf(HeroOrbActivity current, double activity) =>
    switch (current) {
      HeroOrbActivity.idle =>
        activity > 0.28 ? HeroOrbActivity.active : HeroOrbActivity.idle,
      HeroOrbActivity.active =>
        activity < 0.18 ? HeroOrbActivity.idle : HeroOrbActivity.active,
    };

/// Matches `getDelayColor`, so amber in the proxy list is never healthy here.
const heroDegradedDelay = 600;

HeroHealth heroHealthOf({required int? delay, required bool measuring}) {
  if (measuring) return HeroHealth.unknown;
  if (delay == null || delay == 0) return HeroHealth.unknown;
  if (delay < 0) return HeroHealth.broken;
  if (delay >= heroDegradedDelay) return HeroHealth.degraded;
  return HeroHealth.healthy;
}

final heroLifecycleProvider = Provider<HeroOrbPhase>((ref) {
  final reachable = ref.watch(networkReachableProvider) ?? true;
  if (!reachable) return HeroOrbPhase.offline;
  final phase = heroLifecycleOf(
    isStart: ref.watch(isStartProvider),
    paused: ref.watch(pausedProvider),
    coreConnecting:
        ref.watch(coreStatusProvider) == CoreStatus.connecting &&
        ref.watch(initProvider),
  );
  final probing = ref.watch(
    pendingDelayTestsProvider.select((state) => state.isNotEmpty),
  );
  return heroPhaseWithProbe(phase, probing);
});

/// Nothing here auto-retries, so recovery is only a core reconnecting.
HeroOrbPhase heroLifecycleOf({
  required bool isStart,
  required bool paused,
  required bool coreConnecting,
}) {
  if (!isStart) return HeroOrbPhase.off;
  if (paused) return HeroOrbPhase.paused;
  return coreConnecting ? HeroOrbPhase.reconnecting : HeroOrbPhase.on;
}

HeroOrbPhase heroPhaseWithProbe(HeroOrbPhase phase, bool probing) =>
    probing && phase == HeroOrbPhase.off ? HeroOrbPhase.checking : phase;

HeroStatus heroStatusOf(HeroOrbPhase phase, HeroHealth health) =>
    switch (phase) {
      HeroOrbPhase.offline => HeroStatus.offline,
      HeroOrbPhase.off => HeroStatus.off,
      HeroOrbPhase.checking => HeroStatus.checking,
      HeroOrbPhase.connecting => HeroStatus.connecting,
      HeroOrbPhase.reconnecting => HeroStatus.reconnecting,
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

const List<Color> _reconnectingRing = [
  Color(0xFF10EDF8),
  Color(0xFFFFC93C),
  Color(0xFFF03E3E),
];

const List<Color> _checkingRing = [
  Color(0xFF9BF6FF),
  Color(0xFF10EDF8),
  Color(0xFF2A8BFD),
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

  @override
  bool operator ==(Object other) =>
      other is HeroPalette &&
      other.glow == glow &&
      other.accent == accent &&
      _sameRing(other.ring, ring);

  @override
  int get hashCode => Object.hash(glow, accent, Object.hashAll(ring));

  static bool _sameRing(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Every palette change animates, so a theme switch travels as smoothly as a
/// status change does.
class HeroPaletteTween extends Tween<HeroPalette> {
  HeroPaletteTween({super.begin, super.end});

  @override
  HeroPalette lerp(double t) => HeroPalette.lerp(begin!, end!, t);
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
    case HeroStatus.offline:
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
    case HeroStatus.checking:
      final ring = tuned(_checkingRing);
      return HeroPalette(
        ring: ring,
        glow: ring[1],
        accent: colorScheme.onSurfaceVariant,
      );
    case HeroStatus.reconnecting:
      return alert(_reconnectingRing);
    case HeroStatus.paused:
      return alert(_pausedRing);
    case HeroStatus.degraded:
      return alert(_degradedRing);
    case HeroStatus.broken:
      return alert(_brokenRing);
  }
}
