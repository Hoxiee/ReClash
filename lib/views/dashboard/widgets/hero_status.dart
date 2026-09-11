import 'dart:math' as math;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HeroOrbPhase {
  offline,
  off,
  checking,
  connecting,
  reconnecting,
  on,
  paused,
  failed,
}

/// `unknown` is not a middle ground: it withholds the verdict, so a missing or
/// in-flight measurement can never paint the orb red.
enum HeroHealth { unknown, checking, healthy, degraded, broken }

enum HeroOrbVariant { vpn, byedpi }

enum HeroStatus {
  offline,
  off,
  checking,
  diagnosing,
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
      this == HeroStatus.broken;

  bool get isSweeping =>
      this == HeroStatus.checking ||
      this == HeroStatus.diagnosing ||
      this == HeroStatus.connecting ||
      this == HeroStatus.reconnecting;

  bool get isTransitioning =>
      this == HeroStatus.connecting || this == HeroStatus.reconnecting;

  bool get flows =>
      this == HeroStatus.diagnosing ||
      this == HeroStatus.secured ||
      this == HeroStatus.degraded;
}

/// Only the breathe period reads this: `repeat` captures its period.
enum HeroOrbActivity { idle, active }

enum HeroOrbTransition {
  steady,
  ignition,
  lockOn,
  shutdown,
  pause,
  resume,
  fault,
  recovery,
  networkLoss,
  networkReturn,
  healthShift,
  crossfade,
}

HeroOrbTransition heroOrbTransitionOf(HeroStatus from, HeroStatus to) {
  if (from == to) return HeroOrbTransition.steady;
  if (to == HeroStatus.offline) return HeroOrbTransition.networkLoss;
  if (to == HeroStatus.off) return HeroOrbTransition.shutdown;
  if (to == HeroStatus.broken) return HeroOrbTransition.fault;
  if (from == HeroStatus.offline) return HeroOrbTransition.networkReturn;
  if (from == HeroStatus.broken || to == HeroStatus.reconnecting) {
    return HeroOrbTransition.recovery;
  }
  if (to == HeroStatus.paused) return HeroOrbTransition.pause;
  if (from == HeroStatus.paused) return HeroOrbTransition.resume;
  if (to == HeroStatus.connecting) return HeroOrbTransition.ignition;
  if (from.isSweeping && to.flows) return HeroOrbTransition.lockOn;
  if (from.flows && to.flows) return HeroOrbTransition.healthShift;
  return HeroOrbTransition.crossfade;
}

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
  if (measuring) return HeroHealth.checking;
  if (delay == null || delay == 0) return HeroHealth.unknown;
  if (delay < 0) return HeroHealth.unknown;
  if (delay >= heroDegradedDelay) return HeroHealth.degraded;
  return HeroHealth.healthy;
}

HeroHealth heroDoctorHealthOf(DoctorSnapshot snapshot) {
  if (!snapshot.supported || !snapshot.isFresh) return HeroHealth.unknown;
  if (snapshot.state == DoctorExamState.examining) return HeroHealth.checking;
  return switch (snapshot.health) {
    DoctorHealth.healthy => HeroHealth.healthy,
    DoctorHealth.degraded => HeroHealth.degraded,
    DoctorHealth.broken => HeroHealth.broken,
    DoctorHealth.unknown => HeroHealth.unknown,
  };
}

final heroLifecycleProvider = Provider<HeroOrbPhase>((ref) {
  final reachable = ref.watch(networkReachableProvider) ?? true;
  if (!reachable) return HeroOrbPhase.offline;
  final coreStatus = ref.watch(coreStatusProvider);
  final request = ref.watch(runRequestStateProvider);
  final phase = coreStatus == CoreStatus.disconnected
      ? HeroOrbPhase.failed
      : request.isStarting
      ? HeroOrbPhase.connecting
      : heroLifecycleOf(
          isStart: ref.watch(isStartProvider),
          paused: ref.watch(pausedProvider),
          coreConnecting:
              coreStatus == CoreStatus.connecting && ref.watch(initProvider),
          coreDisconnected: coreStatus == CoreStatus.disconnected,
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
  bool coreDisconnected = false,
}) {
  if (!isStart) return HeroOrbPhase.off;
  if (coreDisconnected) return HeroOrbPhase.failed;
  if (paused) return HeroOrbPhase.paused;
  if (coreConnecting) return HeroOrbPhase.reconnecting;
  return HeroOrbPhase.on;
}

HeroOrbPhase heroPhaseWithProbe(HeroOrbPhase phase, bool probing) =>
    probing && phase == HeroOrbPhase.off ? HeroOrbPhase.checking : phase;

/// What the orb's core carries: the provider's mark while the tunnel flows,
/// the app's own mark when the panel sent none, the state icon otherwise.
enum HeroCoreMark { serviceLogo, appMark, statusIcon }

HeroCoreMark heroCoreMarkOf(HeroStatus status, String? serviceLogo) =>
    status.flows
    ? (serviceLogo != null && serviceLogo.isNotEmpty
          ? HeroCoreMark.serviceLogo
          : HeroCoreMark.appMark)
    : HeroCoreMark.statusIcon;

HeroStatus heroStatusOf(HeroOrbPhase phase, HeroHealth health) =>
    switch (phase) {
      HeroOrbPhase.offline => HeroStatus.offline,
      HeroOrbPhase.off => HeroStatus.off,
      HeroOrbPhase.checking => HeroStatus.checking,
      HeroOrbPhase.connecting => HeroStatus.connecting,
      HeroOrbPhase.reconnecting => HeroStatus.reconnecting,
      HeroOrbPhase.paused => HeroStatus.paused,
      HeroOrbPhase.failed => HeroStatus.broken,
      HeroOrbPhase.on => switch (health) {
        HeroHealth.checking => HeroStatus.diagnosing,
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

const List<Color> byedpiHeroRingColors = [
  Color(0xFF55E6A5),
  Color(0xFF00B8A9),
  Color(0xFF168AAD),
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
  Color(0xFF9BF6FF),
  Color(0xFF10EDF8),
  Color(0xFFFFC93C),
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

HeroPalette byedpiHeroPaletteOf(BuildContext context, HeroStatus status) {
  if (status != HeroStatus.connecting &&
      status != HeroStatus.diagnosing &&
      status != HeroStatus.secured) {
    return heroPaletteOf(context, status);
  }
  final colorScheme = context.colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;
  final ring = [
    for (final color in byedpiHeroRingColors)
      isDark
          ? color.harmonizeWith(colorScheme.tertiary)
          : color.harmonizeWith(colorScheme.tertiary).darken(6),
  ];
  return HeroPalette(
    ring: ring,
    glow: ring[1],
    accent: isDark ? ring[0].lighten(4) : ring[2].darken(10),
  );
}

/// Every palette change animates, so a theme switch travels as smoothly as a
/// status change does.
class HeroPaletteTween extends Tween<HeroPalette> {
  HeroPaletteTween({super.begin, super.end});

  @override
  HeroPalette lerp(double t) => HeroPalette.lerp(begin!, end!, t);
}

HeroPalette heroPaletteOf(
  BuildContext context,
  HeroStatus status, {
  List<Color>? heroRing,
}) {
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
    case HeroStatus.diagnosing:
      final ring = heroRing ?? tuned(heroRingColors);
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
