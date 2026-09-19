import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/common/finding_events.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_spark.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_overlay.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every absolute length below is authored against this diameter and scaled
/// from it, so a 120px orb keeps the same ring-to-core proportions as a 280px
/// one instead of turning into a thick donut.
const double heroOrbBaseSize = 192;

/// How far the bloom reaches past the ring. Painted outside the widget's own
/// box so the orb keeps its layout footprint and its tap target.
const double _haloSpread = 34;

const _ringStroke = 10.0;
const _coreInset = 21.0;
const _pausedStroke = 3.0;
const _checkingStroke = 4.0;

const _pausedDash = 5.0;
const _pausedPeriod = 13.0;

const _noSignalDash = 2.0;
const _noSignalPeriod = 40.0;

const _connectingTail = 220 * math.pi / 180;
const _checkingTail = 70 * math.pi / 180;

/// A hold this far past `kLongPressTimeout` cannot be reached by accident,
/// which is the whole point: the orb keeps its tap and its calm.
const _novaCharge = Duration(milliseconds: 2400);
const _novaDuration = Duration(milliseconds: 2800);

/// How far past the orb the front travels, in base-size pixels. Far enough to
/// leave the board: the ancestors clip it, and a wave that dies inside its own
/// widget never reads as a wave.
const _novaSpread = 260.0;
const _novaSparkCount = 26;
const _novaStreakCount = 34;

/// The blast throws the orb; this is where it comes back down. The second beat
/// is what makes the button felt rather than merely watched.
const _novaLanding = 0.74;

/// The wind-up stays hidden behind the hold's own tell: a finger that leaves
/// before this has seen nothing at all.
const _chargeTell = 0.55;

Color _seasonalGlow(Color color) {
  final now = DateTime.now();
  final day = now.difference(DateTime(now.year)).inDays;
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withHue((hsl.hue + 3 * math.sin(day / 365 * 2 * math.pi)) % 360)
      .toColor();
}

class HeroOrb extends ConsumerStatefulWidget {
  @visibleForTesting
  static const Key novaKey = ValueKey('orb-nova');
  @visibleForTesting
  static const Key chargeKey = ValueKey('orb-charge');

  const HeroOrb({
    super.key,
    this.size = heroOrbBaseSize,
    this.enabled = true,
    this.health = HeroHealth.unknown,
    this.activity = 0,
    this.serviceLogo,
    this.heroRing,
    this.subscriptionExpired = false,
    this.variant = HeroOrbVariant.vpn,
    this.onPhaseChanged,
  });

  final double size;
  final bool enabled;

  final String? serviceLogo;
  final List<Color>? heroRing;
  final bool subscriptionExpired;
  final HeroOrbVariant variant;

  /// Verdict on the live connection. Today it comes from the incumbent node's
  /// last delay measurement; the connection doctor will replace the source
  /// without touching this widget.
  final HeroHealth health;

  /// Throughput as `0..1` — brightens the ring and stirs the plasma.
  final double activity;

  /// Fired only on a genuine transition, so the listeners' immediate fire in
  /// `initState` can never rebuild an ancestor mid-build.
  final void Function(HeroOrbPhase phase)? onPhaseChanged;

  @override
  ConsumerState<HeroOrb> createState() => _HeroOrbState();
}

class _HeroOrbState extends ConsumerState<HeroOrb>
    with TickerProviderStateMixin {
  late final AnimationController _draw;
  late final AnimationController _breathe;
  late final AnimationController _press;
  late final AnimationController _sweep;
  late final AnimationController _flow;
  late final AnimationController _aurora;
  late final AnimationController _ripple;
  late final AnimationController _morph;
  late final AnimationController _settle;
  late final AnimationController _tint;

  /// Decays over a new fault's first cycle, making its opening pulse deepest.
  late final AnimationController _onset;

  late final AnimationController _charge;
  late final AnimationController _nova;

  /// Drawn once per detonation so the spray is stable across its frames and
  /// different every time.
  List<_NovaSpark> _sparks = const [];

  Offset? _chargeOrigin;
  bool _swallowTap = false;
  Timer? _swallowTimer;
  Timer? _landingTimer;
  Timer? _oscilloscopeHold;
  Timer? _oscilloscopeTimer;
  final Set<int> _pointers = {};
  bool _oscilloscope = false;
  bool _multiTouch = false;
  Timer? _multiTouchRelease;
  DateTime? _sessionTick;
  int _turn = 0;

  /// `repeat` restarts at the lower bound, so these carry the phase across a
  /// retime rather than letting it snap.
  double _sweepPhase = 0;
  double _breathePhase = 0;
  double _flowPhase = 0;
  Duration? _flowTickAt;

  static const _minimumConnecting = Duration(milliseconds: 620);

  HeroOrbPhase _phase = HeroOrbPhase.off;
  HeroStatus _status = HeroStatus.off;
  HeroStatus _previousStatus = HeroStatus.off;
  HeroOrbTransition _transition = HeroOrbTransition.steady;

  /// What the ring is unwinding out of, so switching off never cuts to empty.
  HeroStatus _exiting = HeroStatus.secured;

  double _handoff = 0;

  HeroOrbActivity _band = HeroOrbActivity.idle;
  HeroPalette? _palette;
  HeroPalette? _tintFrom;
  HeroPalette? _tintTo;
  double _activityFrom = 0;
  bool _still = false;
  bool _minimumConnectingElapsed = true;
  HeroOrbPhase? _deferredPhase;
  Timer? _connectingHold;

  @override
  void initState() {
    super.initState();
    _phase = ref.read(heroLifecycleProvider);
    _status = _statusOf(_phase, widget.health);
    _draw = AnimationController(
      vsync: this,
      value: _status.isLive && !_status.isTransitioning ? 1 : 0,
      duration: const Duration(milliseconds: 620),
      reverseDuration: const Duration(milliseconds: 420),
    );
    _breathe = AnimationController(vsync: this, duration: _breatheDuration);
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _sweep = AnimationController(vsync: this, duration: _sweepDuration);
    _flow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_advanceFlow);
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    );
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _morph = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 460),
    );
    _settle = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 900),
    );
    _onset = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 1400),
    );
    _tint = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 420),
    );
    _charge = AnimationController(
      vsync: this,
      duration: _novaCharge,
      reverseDuration: const Duration(milliseconds: 260),
    )..addStatusListener(_handleCharge);
    _nova = AnimationController(vsync: this, duration: _novaDuration);
    ref.listenManual(runTimeProvider, (_, runtime) {
      final now = DateTime.now();
      final previous = _sessionTick;
      _sessionTick = runtime == null ? null : now;
      if (runtime == null ||
          previous == null ||
          !sessionCrossedNewYear(previous, now, runtime) ||
          _status != HeroStatus.secured ||
          !PageActivityScope.isActiveOf(context) ||
          !ref.read(milestoneSettingProvider).findingsEnabled ||
          ref.read(findingPreviewProvider).enabled) {
        return;
      }
      ref.read(milestonesProvider.notifier).discover('turn');
      setState(() => _turn++);
    });
    ref.listenManual(heroLifecycleProvider, (prev, next) {
      if (!mounted) return;
      _setPhase(next);
    }, fireImmediately: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still == _still) return;
    _still = still;
    if (still) {
      final deferred = _deferredPhase;
      _connectingHold?.cancel();
      _connectingHold = null;
      _minimumConnectingElapsed = true;
      _deferredPhase = null;
      if (deferred != null) _setPhase(deferred);
      _finishFiniteMotion();
    }
    _applyStatus(_status);
  }

  @override
  void didUpdateWidget(HeroOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity) {
      final current = _still
          ? oldWidget.activity
          : lerpDouble(
                  _activityFrom,
                  oldWidget.activity,
                  Curves.easeOut.transform(_settle.value),
                ) ??
                oldWidget.activity;
      _activityFrom = _still ? widget.activity : current;
      if (_still) {
        _settle.value = 1;
      } else {
        _settle.forward(from: 0);
      }
      final band = heroActivityBandOf(_band, widget.activity);
      if (band != _band) {
        _band = band;
        _runBreathing();
      }
    }
    if (oldWidget.health != widget.health ||
        oldWidget.subscriptionExpired != widget.subscriptionExpired) {
      _applyStatus(_statusOf(_phase, widget.health));
    }
  }

  @override
  void dispose() {
    _connectingHold?.cancel();
    _swallowTimer?.cancel();
    _landingTimer?.cancel();
    _oscilloscopeHold?.cancel();
    _oscilloscopeTimer?.cancel();
    _multiTouchRelease?.cancel();
    _charge.dispose();
    _nova.dispose();
    _draw.dispose();
    _breathe.dispose();
    _press.dispose();
    _sweep.dispose();
    _flow.dispose();
    _aurora.dispose();
    _ripple.dispose();
    _morph.dispose();
    _settle.dispose();
    _onset.dispose();
    _tint.dispose();
    super.dispose();
  }

  Duration get _breatheDuration => switch (_status) {
    HeroStatus.broken ||
    HeroStatus.blocked => const Duration(milliseconds: 1400),
    HeroStatus.subscriptionExpired => const Duration(milliseconds: 2800),
    HeroStatus.paused => const Duration(milliseconds: 2400),
    _ =>
      _band == HeroOrbActivity.active
          ? const Duration(milliseconds: 3100)
          : const Duration(milliseconds: 3600),
  };

  Duration get _sweepDuration => switch (_status) {
    HeroStatus.checking ||
    HeroStatus.diagnosing => const Duration(milliseconds: 700),
    HeroStatus.reconnecting => const Duration(milliseconds: 850),
    _ => const Duration(milliseconds: 1150),
  };

  double get _activity =>
      lerpDouble(
        _activityFrom,
        widget.activity,
        Curves.easeOut.transform(_settle.value),
      ) ??
      widget.activity;

  double get _sweepValue => (_sweepPhase + _sweep.value) % 1.0;

  double get _breatheValue => (_breathePhase + _breathe.value) % 1.0;

  void _advanceFlow() {
    final now = _flow.lastElapsedDuration;
    final previous = _flowTickAt;
    _flowTickAt = now;
    if (now == null || previous == null || now <= previous || !_status.flows) {
      return;
    }
    final speed = _status == HeroStatus.degraded ? 0.45 : 1.0;
    final elapsed =
        (now - previous).inMicroseconds / Duration.microsecondsPerSecond;
    _flowPhase =
        (_flowPhase + elapsed / 12 * speed * (1 + 0.3 * _activity)) % 1.0;
  }

  void _startFlow() {
    if (_still || !_status.flows) return;
    if (!_flow.isAnimating) {
      _flowTickAt = null;
      _flow.repeat();
    }
  }

  void _stopFlow() {
    _flow.stop();
    _flowTickAt = null;
  }

  /// The palette currently on screen: `_tintFrom` lerped toward `_tintTo`.
  HeroPalette get _currentPalette => HeroPalette.lerp(
    _tintFrom!,
    _tintTo!,
    Curves.easeOutCubic.transform(_tint.value),
  );

  bool get _canTap => widget.enabled && !_status.isTransitioning;

  double _headOf(HeroStatus status) {
    if (status.isSweeping) return _sweepValue;
    if (status.flows) return _flowPhase;
    return _handoff;
  }

  void _finishFiniteMotion() {
    _cancelCharge();
    _landingTimer?.cancel();
    _landingTimer = null;
    _nova.value = 0;
    _press.value = 0;
    _ripple.value = 1;
    _morph.value = 1;
    _flowTickAt = null;
    _flow.value = 0;
    _settle.value = 1;
    _onset.value = 1;
    _tint.value = 1;
    _draw.value = _status.isLive && !_status.isTransitioning ? 1 : 0;
  }

  void _setPhase(HeroOrbPhase phase) {
    final delaysSuccessfulConnection =
        phase == HeroOrbPhase.on || phase == HeroOrbPhase.reconnecting;
    if (_phase == HeroOrbPhase.connecting &&
        phase != HeroOrbPhase.connecting &&
        delaysSuccessfulConnection) {
      if (!_still && !_minimumConnectingElapsed) {
        _deferredPhase = phase;
        return;
      }
    }
    _connectingHold?.cancel();
    _connectingHold = null;
    _minimumConnectingElapsed = true;
    _deferredPhase = null;
    _adoptPhase(phase);
  }

  HeroStatus _statusOf(HeroOrbPhase phase, HeroHealth health) {
    final status = heroStatusOf(phase, health);
    return widget.subscriptionExpired && status.flows
        ? HeroStatus.subscriptionExpired
        : status;
  }

  void _adoptPhase(HeroOrbPhase phase) {
    final changed = _phase != phase;
    _phase = phase;
    if (changed) widget.onPhaseChanged?.call(phase);
    _applyStatus(_statusOf(phase, widget.health));
  }

  void _runBreathing() {
    final wanted =
        !_still && _status != HeroStatus.off && _status != HeroStatus.offline;
    if (!wanted) {
      _breathe.stop();
      return;
    }
    if (_breathe.isAnimating && _breathe.duration == _breatheDuration) return;
    _breathe.stop();
    _breathePhase = _breatheValue;
    _breathe.value = 0;
    _breathe.duration = _breatheDuration;
    _breathe.repeat();
  }

  void _runSweep() {
    final wanted = _status.isSweeping && !_still;
    if (!wanted) {
      _sweep.stop();
      return;
    }
    if (_sweep.isAnimating && _sweep.duration == _sweepDuration) return;
    _sweep.stop();
    _sweepPhase = _sweepValue;
    _sweep.value = 0;
    _sweep.duration = _sweepDuration;
    _sweep.repeat();
  }

  void _applyStatus(HeroStatus status) {
    final previous = _status;
    final changed = previous != status;
    if (changed) {
      _handoff = _headOf(previous);
      _previousStatus = previous;
      _transition = heroOrbTransitionOf(previous, status);
      if (status == HeroStatus.off) {
        _exiting = previous;
      }
      if (status.isSweeping) {
        _sweepPhase = _handoff;
        _sweep.value = 0;
      } else if (status.flows && !previous.flows) {
        _flowPhase = _handoff;
      }
    }
    setState(() => _status = status);

    if (changed) {
      if (_still) {
        _morph.value = 1;
        _onset.value = 1;
      } else {
        _morph.forward(from: 0);
        if (status.isAlert) _onset.forward(from: 0);
        if (_transition == HeroOrbTransition.fault) {
          _ripple.forward(from: 0);
        }
      }
    }

    if (status.isLive && !status.isTransitioning) {
      if (!previous.isLive || previous.isTransitioning) {
        if (_still) {
          _draw.value = 1;
          _ripple.value = 1;
        } else {
          _draw.forward();
          _ripple.forward(from: 0);
        }
      }
    } else if (!status.isLive) {
      if (_still) {
        _draw.value = 0;
      } else {
        _draw.reverse();
      }
    }

    _runBreathing();
    _runSweep();
    if (status.flows && !_still) {
      _startFlow();
      if (!_aurora.isAnimating) _aurora.repeat();
    } else {
      _stopFlow();
      if (!_still &&
          (status == HeroStatus.paused ||
              status == HeroStatus.diagnosing ||
              status.isAlert)) {
        if (!_aurora.isAnimating) _aurora.repeat();
      } else {
        _aurora.stop();
      }
    }
  }

  void _handleTap() {
    if (_multiTouch) return;
    // The pointer that armed the nova is still a tap to the recognizer, and
    // that tap would toggle the tunnel the egg promised not to touch.
    if (_swallowTap) {
      _swallowTap = false;
      _swallowTimer?.cancel();
      _swallowTimer = null;
      return;
    }
    if (!_canTap) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      HapticFeedback.mediumImpact();
    }
    if (_still) {
      _ripple.value = 1;
    } else {
      _ripple.forward(from: 0);
    }
    if (_phase == HeroOrbPhase.paused) {
      ref.read(commonActionProvider.notifier).togglePaused();
      return;
    }
    if (ref.read(isStartProvider)) {
      _setPhase(HeroOrbPhase.off);
      ref.read(commonActionProvider.notifier).toggleRunning();
      return;
    }
    _beginConnecting();
    ref.read(commonActionProvider.notifier).toggleRunning();
  }

  void _pointerDown(PointerDownEvent event) {
    if (_pointers.isEmpty) {
      _multiTouchRelease?.cancel();
      _multiTouch = false;
    }
    _pointers.add(event.pointer);
    if (_pointers.length != 2) return;
    _multiTouch = true;
    _multiTouchRelease?.cancel();
    _cancelCharge();
    _oscilloscopeHold?.cancel();
    _oscilloscopeHold = Timer(const Duration(milliseconds: 700), () {
      if (!mounted ||
          _pointers.length < 2 ||
          _status != HeroStatus.secured ||
          !PageActivityScope.isActiveOf(context) ||
          !ref.read(milestoneSettingProvider).findingsEnabled) {
        return;
      }
      if (!ref.read(findingPreviewProvider).enabled) {
        ref.read(milestonesProvider.notifier).discover('oscilloscope');
      }
      setState(() => _oscilloscope = true);
      _oscilloscopeTimer?.cancel();
      _oscilloscopeTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _oscilloscope = false);
      });
    });
  }

  void _pointerUp(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty && _multiTouch) {
      _multiTouchRelease?.cancel();
      _multiTouchRelease = Timer(const Duration(milliseconds: 300), () {
        _multiTouch = false;
      });
    }
    if (_pointers.length < 2) {
      _oscilloscopeHold?.cancel();
      _oscilloscopeHold = null;
    }
  }

  void _beginCharge(Offset position) {
    if (_still || !widget.enabled || _nova.isAnimating || _multiTouch) return;
    _chargeOrigin = position;
    _charge.forward(from: 0);
  }

  void _cancelCharge() {
    _chargeOrigin = null;
    if (_charge.isDismissed) return;
    if (_charge.isCompleted) {
      _charge.value = 0;
      return;
    }
    _charge.reverse();
  }

  void _handleCharge(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _detonate();
  }

  void _detonate() {
    _sparks = _novaSparks(math.Random(DateTime.now().microsecondsSinceEpoch));
    _press.reverse();
    _ripple.forward(from: 0);
    final android = defaultTargetPlatform == TargetPlatform.android;
    if (android) HapticFeedback.heavyImpact();
    _landingTimer?.cancel();
    _landingTimer = android
        ? Timer(_novaDuration * _novaLanding, () {
            _landingTimer = null;
            if (mounted) HapticFeedback.heavyImpact();
          })
        : null;
    _nova.forward(from: 0).whenComplete(() {
      if (mounted) _nova.value = 0;
    });
  }

  void _releaseCharge() {
    if (_charge.isCompleted) {
      _swallowTap = true;
      _swallowTimer?.cancel();
      _swallowTimer = Timer(const Duration(milliseconds: 300), () {
        _swallowTap = false;
        _swallowTimer = null;
      });
    }
    _cancelCharge();
  }

  /// Four beats, the way a thrown punch reads: wind up, hit, ride the recoil,
  /// come down. `easeInCubic` keeps the first second of the hold visually
  /// silent, so only someone already committed sees the wind-up at all.
  double get _novaScale {
    final nova = _nova.value;
    if (nova > 0) {
      if (nova < 0.07) {
        return lerpDouble(
          0.94,
          0.78,
          Curves.easeInCubic.transform(nova / 0.07),
        )!;
      }
      if (nova < _novaLanding) {
        final rebound = ((nova - 0.07) / 0.34).clamp(0.0, 1.0);
        return lerpDouble(0.78, 1.05, Curves.elasticOut.transform(rebound))!;
      }
      // The drop: it overshoots into a squash and springs out of it, which is
      // the beat the finger feels through the second haptic.
      final landing = ((nova - _novaLanding) / (1 - _novaLanding)).clamp(
        0.0,
        1.0,
      );
      if (landing < 0.24) {
        return lerpDouble(
          1.05,
          0.90,
          Curves.easeInCubic.transform(landing / 0.24),
        )!;
      }
      final settle = ((landing - 0.24) / 0.76).clamp(0.0, 1.0);
      return lerpDouble(0.90, 1, Curves.elasticOut.transform(settle))!;
    }
    return 1 - 0.06 * Curves.easeInCubic.transform(_charge.value);
  }

  double get _novaGlow {
    if (_nova.value <= 0) return 0;
    final local = ((_nova.value - 0.04) / 0.34).clamp(0.0, 1.0);
    if (local <= 0 || local >= 1) return 0;
    return math.sin(math.pi * local);
  }

  /// Two impulses, never a wobble: the blast throws the orb, the landing
  /// drives it into the board. Both decay hard, so each reads as a single hit.
  Offset get _novaKick {
    final nova = _nova.value;
    if (nova > 0.04 && nova < 0.34) {
      final local = (nova - 0.04) / 0.30;
      final decay = math.pow(1 - local, 1.9).toDouble();
      final phase = local * 7 * 2 * math.pi;
      return Offset(
        math.sin(phase) * 11 * decay,
        math.cos(phase * 0.82) * 8.5 * decay,
      );
    }
    if (nova > _novaLanding && nova < _novaLanding + 0.16) {
      final local = (nova - _novaLanding) / 0.16;
      final decay = math.pow(1 - local, 2.6).toDouble();
      final phase = local * 6 * 2 * math.pi;
      return Offset(
        math.sin(phase * 1.1) * 6 * decay,
        math.cos(phase) * 7.5 * decay,
      );
    }
    return Offset.zero;
  }

  /// A few degrees of tilt is the difference between a blast and a bounce.
  double get _novaTilt {
    if (_nova.value <= 0.04 || _nova.value >= 0.40) return 0;
    final local = (_nova.value - 0.04) / 0.36;
    final decay = math.pow(1 - local, 2.0).toDouble();
    return math.sin(local * 4 * 2 * math.pi) * 0.085 * decay;
  }

  void _beginConnecting() {
    _minimumConnectingElapsed = _still;
    _connectingHold?.cancel();
    _connectingHold = _still
        ? null
        : Timer(_minimumConnecting, () {
            if (!mounted) return;
            _minimumConnectingElapsed = true;
            final deferred = _deferredPhase;
            _deferredPhase = null;
            _connectingHold = null;
            if (deferred != null) _setPhase(deferred);
          });
    _adoptPhase(HeroOrbPhase.connecting);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final size = widget.size;
    final scale = size / heroOrbBaseSize;
    final haloSpread = _haloSpread * scale;
    final novaSpread = _novaSpread * scale;
    final core = size - _coreInset * scale * 2;
    final milestoneSettings = ref.watch(visibleMilestonesProvider);
    final preview = ref.watch(findingPreviewProvider);
    final motif = ref.watch(visibleSeasonProvider);
    final seasonal = milestoneSettings.seasonalEnabled;
    final calmRewards =
        _status == HeroStatus.secured &&
        PageActivityScope.isActiveOf(context) &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    final showOscilloscope =
        calmRewards &&
        milestoneSettings.findingsEnabled &&
        (_oscilloscope || preview.active == 'oscilloscope');
    final oscilloscopeSamples = !showOscilloscope
        ? const <double>[]
        : preview.active == 'oscilloscope'
        ? const <double>[2, 5, 3, 9, 4, 12, 8, 3, 6, 11, 2, 7]
        : ref
              .watch(trafficsProvider)
              .list
              .map((traffic) => (traffic.up + traffic.down).toDouble())
              .toList();
    // Retargeted here rather than on a status change alone, so a new theme or
    // seed colour travels the same way a status does.
    final target = widget.variant == HeroOrbVariant.byedpi
        ? byedpiHeroPaletteOf(context, _status)
        : heroPaletteOf(context, _status, heroRing: widget.heroRing);
    if (_tintTo != target) {
      final from = _palette;
      _tintFrom = from ?? target;
      _tintTo = target;
      if (from == null || _still) {
        _tint.value = 1;
      } else {
        _tint.forward(from: 0);
      }
    }

    final running = ref.watch(isStartProvider);

    // The ambient controllers repaint painters and the two scale transforms
    // only; everything a tap or a status change owns is built once here, so
    // the core mark, its image chain and the switcher never rebuild per tick.
    final coreChild = SizedBox(
      key: const ValueKey('orb-core'),
      width: core,
      height: core,
      child: Center(
        child: AnimatedBuilder(
          animation: _tint,
          builder: (context, _) => AnimatedSwitcher(
            duration: context.motionDuration(const Duration(milliseconds: 360)),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final scale = Tween<double>(
                begin: 0.72,
                end: 1,
              ).animate(animation);
              return ScaleTransition(
                scale: scale,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _coreChild(core, _currentPalette.accent),
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: Listener(
        onPointerDown: (event) {
          _pointerDown(event);
          if (_canTap && !_still) _press.forward();
          _beginCharge(event.position);
        },
        // A finger on its way into the board's scroll is not a hold.
        onPointerMove: (event) {
          final origin = _chargeOrigin;
          if (origin == null) return;
          if ((event.position - origin).distance > kTouchSlop) {
            _cancelCharge();
          }
        },
        onPointerUp: (event) {
          _pointerUp(event);
          _press.reverse();
          _releaseCharge();
        },
        onPointerCancel: (event) {
          _pointerUp(event);
          _press.reverse();
          _cancelCharge();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_press, _charge, _nova]),
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.72,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: -haloSpread,
                    top: -haloSpread,
                    width: size + haloSpread * 2,
                    height: size + haloSpread * 2,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _draw,
                          _breathe,
                          _morph,
                          _ripple,
                          _settle,
                          _tint,
                          _nova,
                        ]),
                        builder: (context, _) {
                          // A cosine: a period change alters speed, never
                          // current depth.
                          final pulse = _still
                              ? 0.0
                              : 0.5 -
                                    0.5 * math.cos(2 * math.pi * _breatheValue);
                          final activity = _still ? 0.4 : _activity;
                          final halo =
                              (_status.isSweeping
                                  ? Curves.easeOutCubic.transform(_morph.value)
                                  : Curves.easeOutCubic.transform(
                                      _draw.value,
                                    )) *
                              (0.55 + 0.45 * pulse) *
                              (0.62 + 0.38 * activity) *
                              switch (_status) {
                                HeroStatus.checking ||
                                HeroStatus.diagnosing => 0.45,
                                HeroStatus.subscriptionExpired => 0.36,
                                HeroStatus.paused => 0.30,
                                _ => 1.0,
                              };
                          return CustomPaint(
                            painter: _HeroHaloPainter(
                              glow: seasonal && calmRewards
                                  ? _seasonalGlow(_currentPalette.glow)
                                  : _currentPalette.glow,
                              intensity: math.max(halo, _novaGlow),
                              ripple: _still ? 1 : _ripple.value,
                              orbRadius: size / 2,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _breathe,
                    child: Semantics(
                      button: true,
                      enabled: _canTap,
                      label: _semanticLabel(context),
                      onTapHint: _phase == HeroOrbPhase.paused
                          ? context.appLocalizations.resume
                          : running
                          ? context.appLocalizations.stop
                          : context.appLocalizations.start,
                      child: FocusableTap(
                        autofocus: true,
                        borderRadius: size / 2,
                        onTap: _canTap ? _handleTap : null,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _draw,
                            _breathe,
                            _sweep,
                            _flow,
                            _aurora,
                            _morph,
                            _settle,
                            _onset,
                            _tint,
                          ]),
                          child: coreChild,
                          builder: (context, child) {
                            final palette = _palette = _currentPalette;
                            final still = _still;
                            final pulse = still
                                ? 0.0
                                : 0.5 -
                                      0.5 *
                                          math.cos(2 * math.pi * _breatheValue);
                            return CustomPaint(
                              size: Size.square(size),
                              painter: _HeroOrbPainter(
                                scale: scale,
                                status: _status,
                                previousStatus: _previousStatus,
                                transition: _transition,
                                exiting: _exiting,
                                palette: palette,
                                drawProgress: Curves.easeOutCubic.transform(
                                  _draw.value,
                                ),
                                sweep: still ? 0.18 : _sweepValue,
                                handoff: _handoff,
                                flow: still ? 0.12 : _flowPhase,
                                aurora: still ? 0.2 : _aurora.value,
                                pulse: pulse,
                                activity: still ? 0.4 : _activity,
                                morph: Curves.easeOutCubic.transform(
                                  _morph.value,
                                ),
                                transitionProgress: Curves.easeOutCubic
                                    .transform(_morph.value),
                                onset: still
                                    ? 1
                                    : Curves.easeOut.transform(_onset.value),
                                trackColor:
                                    colorScheme.outlineVariant.opacity60,
                                coreColor:
                                    colorScheme.surfaceContainerHigh.opacity60,
                                coreHighlight: colorScheme.surfaceBright,
                                coreBorder:
                                    colorScheme.outlineVariant.opacity60,
                              ),
                              child: SizedBox.square(
                                dimension: size,
                                child: Center(child: child),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    builder: (context, child) {
                      final pulse = _still
                          ? 0.0
                          : 0.5 - 0.5 * math.cos(2 * math.pi * _breatheValue);
                      final amplitude = switch (_status) {
                        HeroStatus.secured => 0.022,
                        HeroStatus.degraded => 0.014,
                        HeroStatus.subscriptionExpired => 0.010,
                        HeroStatus.paused => 0.008,
                        _ => 0.0,
                      };
                      return Transform.scale(
                        scale: 1 + amplitude * pulse,
                        child: child,
                      );
                    },
                  ),
                  if (showOscilloscope)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          key: const ValueKey('hero-oscilloscope'),
                          painter: _HeroOscilloscopePainter(
                            samples: oscilloscopeSamples,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  if ((seasonal &&
                          (motif == SeasonalMotif.birthday ||
                              motif == SeasonalMotif.firstRun)) ||
                      (milestoneSettings.findingsEnabled &&
                          (preview.active == 'turn' || _turn > 0)))
                    Positioned.fill(
                      child: SeasonalSpark(
                        key: ValueKey((motif, preview.active == 'turn', _turn)),
                        reduceMotion: _still,
                        visible: calmRewards,
                      ),
                    ),
                  Positioned(
                    left: -novaSpread,
                    top: -novaSpread,
                    width: size + novaSpread * 2,
                    height: size + novaSpread * 2,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_nova, _charge, _tint]),
                        builder: (context, _) {
                          final coreRadius = size / 2 - _coreInset * scale;
                          if (_nova.value > 0 && _nova.value < 1) {
                            return CustomPaint(
                              key: HeroOrb.novaKey,
                              painter: _HeroNovaPainter(
                                progress: _nova.value,
                                palette: _currentPalette,
                                scale: scale,
                                ringRadius:
                                    size / 2 - (_ringStroke / 2 + 1.5) * scale,
                                coreRadius: coreRadius,
                                sparks: _sparks,
                              ),
                            );
                          }
                          if (_charge.value > _chargeTell) {
                            return CustomPaint(
                              key: HeroOrb.chargeKey,
                              painter: _HeroChargePainter(
                                progress: _charge.value,
                                palette: _currentPalette,
                                scale: scale,
                                coreRadius: coreRadius,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          builder: (context, child) => Transform.translate(
            offset: _novaKick * scale,
            child: Transform.rotate(
              angle: _novaTilt,
              child: Transform.scale(
                scale: (1.0 - 0.035 * _press.value) * _novaScale,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(BuildContext context) => switch (_status) {
    HeroStatus.offline => context.appLocalizations.noNetwork,
    HeroStatus.off => context.appLocalizations.heroNotProtected,
    HeroStatus.checking ||
    HeroStatus.diagnosing => context.appLocalizations.heroChecking,
    HeroStatus.connecting => context.appLocalizations.heroConnecting,
    HeroStatus.reconnecting => context.appLocalizations.heroReconnecting,
    HeroStatus.secured => context.appLocalizations.heroProtected,
    HeroStatus.degraded => context.appLocalizations.heroProtected,
    HeroStatus.subscriptionExpired =>
      context.appLocalizations.dashboardSubscriptionExpired,
    HeroStatus.broken => context.appLocalizations.heroLinkBroken,
    HeroStatus.blocked => context.appLocalizations.heroBlockedTitle,
    HeroStatus.paused => context.appLocalizations.heroPaused,
  };

  IconData get _statusIcon => switch (_status) {
    HeroStatus.paused => Icons.play_arrow_rounded,
    HeroStatus.checking ||
    HeroStatus.diagnosing => Icons.wifi_tethering_rounded,
    HeroStatus.subscriptionExpired => Icons.event_busy_rounded,
    HeroStatus.offline => Icons.wifi_off_rounded,
    _ => Icons.power_settings_new_rounded,
  };

  static const _coreMarkExtent = 0.54;
  static const _appMarkInset = 0.0216;

  Widget _coreChild(double core, Color accent) {
    if (widget.variant == HeroOrbVariant.byedpi && _status.flows) {
      return Icon(
        Icons.blur_on_rounded,
        key: const ValueKey('byedpi-core-mark'),
        size: core * 0.5,
        color: accent.opacity80,
      );
    }
    switch (heroCoreMarkOf(_status, widget.serviceLogo)) {
      case HeroCoreMark.serviceLogo:
        return SizedBox(
          key: const ValueKey('core-mark'),
          width: core * _coreMarkExtent,
          height: core * _coreMarkExtent,
          child: ImageCacheWidget(
            src: widget.serviceLogo!,
            fit: BoxFit.contain,
            defaultWidget: Padding(
              padding: EdgeInsets.all(core * _appMarkInset),
              child: Image.asset(
                'assets/images/icon_variants/mark_mono.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      case HeroCoreMark.appMark:
        return SizedBox(
          key: const ValueKey('core-mark'),
          width: core * _coreMarkExtent,
          height: core * _coreMarkExtent,
          child: Padding(
            padding: EdgeInsets.all(core * _appMarkInset),
            child: _appMark(accent),
          ),
        );
      case HeroCoreMark.statusIcon:
        return Icon(
          _statusIcon,
          key: ValueKey(_statusIcon),
          size: core * 0.46,
          color: _status == HeroStatus.off
              ? context.colorScheme.onSurfaceVariant
              : accent,
        );
    }
  }

  Widget _appMark(Color accent) => _mono(
    accent.opacity80,
    Image.asset(
      'assets/images/icon_variants/mark_mono.png',
      fit: BoxFit.contain,
    ),
  );

  Widget _mono(Color accent, Widget image) => ColorFiltered(
    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
    child: image,
  );
}

class _HeroOscilloscopePainter extends CustomPainter {
  const _HeroOscilloscopePainter({required this.samples, required this.color});

  final List<double> samples;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.455;
    final path = Path();
    final peak = samples.fold<double>(1, math.max);
    for (var index = 0; index <= 96; index++) {
      final angle = index / 96 * math.pi * 2 - math.pi / 2;
      final position = index / 96 * math.max(0, samples.length - 1);
      final low = position.floor();
      final high = math.min(low + 1, samples.length - 1);
      final sample = samples.isEmpty
          ? 0.0
          : lerpDouble(samples[low], samples[high], position - low)!;
      final r = radius + sample / peak * 9;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.86)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_HeroOscilloscopePainter oldDelegate) =>
      !listEquals(oldDelegate.samples, samples) || oldDelegate.color != color;
}

class _HeroHaloPainter extends CustomPainter {
  _HeroHaloPainter({
    required this.glow,
    required this.intensity,
    required this.ripple,
    required this.orbRadius,
  });

  final Color glow;
  final double intensity;
  final double ripple;
  final double orbRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    if (intensity > 0.01) {
      final inner = (orbRadius / radius).clamp(0.0, 0.98);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              glow.withValues(alpha: 0.16 * intensity),
              glow.withValues(alpha: 0.26 * intensity),
              glow.withValues(alpha: 0),
            ],
            stops: [0, inner, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
    if (ripple > 0 && ripple < 1) {
      final t = Curves.easeOutCubic.transform(ripple);
      canvas.drawCircle(
        center,
        orbRadius + (radius - orbRadius) * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8 + 2.6 * (1 - t)
          ..color = glow.withValues(alpha: 0.42 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(_HeroHaloPainter old) =>
      old.glow != glow ||
      old.intensity != intensity ||
      old.ripple != ripple ||
      old.orbRadius != orbRadius;
}

class _NovaSpark {
  const _NovaSpark({
    required this.angle,
    required this.reach,
    required this.delay,
    required this.width,
    required this.tint,
  });

  final double angle;
  final double reach;
  final double delay;
  final double width;
  final int tint;
}

List<_NovaSpark> _novaSparks(math.Random random) => [
  for (var i = 0; i < _novaSparkCount; i++)
    _NovaSpark(
      angle: (i + random.nextDouble() * 0.8) / _novaSparkCount * 2 * math.pi,
      reach: 0.62 + random.nextDouble() * 0.46,
      delay: random.nextDouble() * 0.14,
      width: 1.2 + random.nextDouble() * 2.4,
      tint: random.nextInt(3),
    ),
];

/// The wind-up: shards falling inwards while the hold is still being made.
/// It starts only past `_chargeTell`, so a finger that leaves early never
/// learns the orb had anything to give.
class _HeroChargePainter extends CustomPainter {
  _HeroChargePainter({
    required this.progress,
    required this.palette,
    required this.scale,
    required this.coreRadius,
  });

  final double progress;
  final HeroPalette palette;
  final double scale;
  final double coreRadius;

  static const _shardCount = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final local = ((progress - _chargeTell) / (1 - _chargeTell)).clamp(
      0.0,
      1.0,
    );
    if (local <= 0) return;
    final center = size.center(Offset.zero);
    final gather = Curves.easeInCubic.transform(local);
    for (var i = 0; i < _shardCount; i++) {
      final angle = i * 2.39996 + local * 1.4;
      final outer = lerpDouble(coreRadius * 3.1, coreRadius * 1.04, gather)!;
      final length = (26 + 34 * (1 - gather)) * scale;
      final head = center + Offset.fromDirection(angle, outer);
      final tail = center + Offset.fromDirection(angle, outer + length);
      final tint = palette.ring[i % palette.ring.length];
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = (0.8 + 1.4 * gather) * scale
          ..shader = LinearGradient(
            colors: [
              tint.withValues(alpha: 0),
              tint.lighten(20).withValues(alpha: 0.62 * gather),
            ],
          ).createShader(Rect.fromPoints(tail, head).inflate(1)),
      );
    }
  }

  @override
  bool shouldRepaint(_HeroChargePainter old) =>
      old.progress != progress ||
      old.palette != palette ||
      old.scale != scale ||
      old.coreRadius != coreRadius;
}

/// One pass over a single `0..1`: the core implodes, flashes white, throws
/// three shockwaves and a spray of packets, and spins the ring through its own
/// spectrum on the way back down. Painted above the orb and owning no state,
/// so nothing it does can outlive its controller.
class _HeroNovaPainter extends CustomPainter {
  _HeroNovaPainter({
    required this.progress,
    required this.palette,
    required this.scale,
    required this.ringRadius,
    required this.coreRadius,
    required this.sparks,
  });

  final double progress;
  final HeroPalette palette;
  final double scale;
  final double ringRadius;
  final double coreRadius;
  final List<_NovaSpark> sparks;

  static const _waveCount = 4;

  double _span(double start, double length) =>
      ((progress - start) / length).clamp(0.0, 1.0);

  List<Color> _sweep(double alpha, {double lighten = 0}) => [
    for (final color in [...palette.ring, palette.ring.first])
      (lighten > 0 ? color.lighten(lighten) : color).withValues(alpha: alpha),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final reach = size.shortestSide / 2;
    _paintGhost(canvas, center, reach);
    _paintWaves(canvas, center, reach);
    _paintStreaks(canvas, center, reach);
    _paintSparks(canvas, center, reach);
    _paintRing(canvas, center);
    _paintFlash(canvas, center);
    _paintGlint(canvas, center, reach);
    _paintLanding(canvas, center);
  }

  void _paintFlash(Canvas canvas, Offset center) {
    final local = _span(0.06, 0.30);
    if (local <= 0 || local >= 1) return;
    // Rises in a fifth of its window and falls over the rest, which is what
    // separates a detonation from a throb.
    final strength = local < 0.2
        ? local / 0.2
        : math.pow(1 - (local - 0.2) / 0.8, 2.4).toDouble();
    final radius = coreRadius * (0.7 + 2.6 * local);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: strength),
            Colors.white.withValues(alpha: 0.86 * strength),
            palette.ring.first.withValues(alpha: 0.62 * strength),
            palette.glow.withValues(alpha: 0),
          ],
          stops: const [0, 0.18, 0.5, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  /// A front, not a ring: the rim is thin and bright, the band behind it is
  /// the compressed air it drags, and both decelerate the way a real blast
  /// does — fast out of the core, then leaning on the brakes.
  void _paintWaves(Canvas canvas, Offset center, double reach) {
    for (var i = 0; i < _waveCount; i++) {
      final local = _span(0.08 + i * 0.07, 0.68);
      if (local <= 0 || local >= 1) continue;
      final eased = Curves.easeOutQuart.transform(local);
      final radius = lerpDouble(
        coreRadius * 0.7,
        reach * (1 - i * 0.13),
        eased,
      )!;
      if (radius <= 0) continue;
      final fade = math.pow(1 - local, 1.6).toDouble();
      final rect = Rect.fromCircle(center: center, radius: radius);
      final rotation = GradientRotation(eased * 2 * math.pi + i);
      final band = (26 + 54 * (1 - eased)) * scale;

      canvas.drawCircle(
        center,
        math.max(radius - band / 2, 0.1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = band
          ..shader = SweepGradient(
            colors: _sweep((0.30 - i * 0.06) * fade),
            transform: rotation,
          ).createShader(rect),
      );

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2.2 + 5.4 * (1 - eased)) * scale
          ..shader = SweepGradient(
            colors: _sweep((0.95 - i * 0.16) * fade, lighten: 16),
            transform: rotation,
          ).createShader(rect),
      );

      _paintFringe(
        canvas,
        center,
        radius,
        rect,
        rotation,
        fade * (1 - i * 0.3),
      );
    }
  }

  /// The rim outruns its own colours: each stop is drawn a little ahead of the
  /// next, and `plus` lets the overlap burn white where they still agree.
  void _paintFringe(
    Canvas canvas,
    Offset center,
    double radius,
    Rect rect,
    GradientRotation rotation,
    double fade,
  ) {
    if (fade <= 0) return;
    for (var i = 0; i < palette.ring.length; i++) {
      final offset = (i - 1) * 3.5 * scale;
      final tinted = radius + offset;
      if (tinted <= 0) continue;
      canvas.drawCircle(
        center,
        tinted,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 * scale
          ..blendMode = BlendMode.plus
          ..shader = SweepGradient(
            colors: [
              for (final color in [...palette.ring, palette.ring.first])
                color.withValues(alpha: 0.34 * fade),
            ],
            transform: rotation,
          ).createShader(rect),
      );
    }
  }

  /// The pressure that arrives before the light does.
  void _paintGhost(Canvas canvas, Offset center, double reach) {
    final local = _span(0.06, 0.34);
    if (local <= 0 || local >= 1) return;
    final eased = Curves.easeOutQuart.transform(local);
    final radius = lerpDouble(coreRadius, reach * 1.12, eased)!;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (10 + 26 * (1 - eased)) * scale
        ..shader = RadialGradient(
          colors: [
            palette.glow.withValues(alpha: 0),
            palette.glow.withValues(
              alpha: 0.20 * math.pow(1 - local, 1.4).toDouble(),
            ),
          ],
          stops: const [0.72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  /// The impact frame: hairline speed lines struck outwards for a handful of
  /// frames. They carry no colour of their own, which is what keeps them
  /// reading as force rather than as more ring.
  void _paintStreaks(Canvas canvas, Offset center, double reach) {
    final local = _span(0.07, 0.26);
    if (local <= 0 || local >= 1) return;
    final eased = Curves.easeOutQuart.transform(local);
    final fade = math.pow(1 - local, 2.2).toDouble();
    for (var i = 0; i < _novaStreakCount; i++) {
      // The golden angle spaces them without a random seed, so the frame is
      // the same every time the egg fires.
      final angle = i * 2.39996;
      final span = 0.42 + (i % 5) * 0.14;
      final head = lerpDouble(coreRadius, reach * span * 1.35, eased)!;
      final tail = head - (52 + 150 * (1 - eased)) * scale * span;
      if (tail >= head) continue;
      canvas.drawLine(
        center + Offset.fromDirection(angle, math.max(tail, coreRadius * 0.3)),
        center + Offset.fromDirection(angle, head),
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = (0.9 + (i % 3) * 0.7) * scale
          ..blendMode = BlendMode.plus
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.72 * fade),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: head)),
      );
    }
  }

  /// A single horizontal flare across the white-out. One bar, one frame's
  /// worth of it: two would be a sparkle, and a sparkle is not a hit.
  void _paintGlint(Canvas canvas, Offset center, double reach) {
    final local = _span(0.08, 0.16);
    if (local <= 0 || local >= 1) return;
    final strength = math.sin(math.pi * local);
    final half = reach * 0.92 * (0.4 + 0.6 * local);
    final rect = Rect.fromCenter(
      center: center,
      width: half * 2,
      height: 10 * scale,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.85 * strength),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
  }

  /// The orb hitting the board. Short, thick and close in — the eye reads
  /// weight from how little ground it covers, not from how far it reaches.
  void _paintLanding(Canvas canvas, Offset center) {
    final local = _span(_novaLanding + 0.03, 0.20);
    if (local <= 0 || local >= 1) return;
    final eased = Curves.easeOutQuart.transform(local);
    final fade = math.pow(1 - local, 1.5).toDouble();
    final radius = lerpDouble(coreRadius * 0.9, ringRadius * 1.62, eased)!;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (3 + 13 * (1 - eased)) * scale
        ..shader = SweepGradient(
          colors: _sweep(0.9 * fade, lighten: 20),
          transform: GradientRotation(-math.pi / 2 - eased * math.pi),
        ).createShader(rect),
    );
  }

  void _paintSparks(Canvas canvas, Offset center, double reach) {
    for (final spark in sparks) {
      final local = _span(0.10 + spark.delay, 0.70);
      if (local <= 0 || local >= 1) continue;
      final eased = Curves.easeOutQuart.transform(local);
      final distance = lerpDouble(
        coreRadius * 0.5,
        reach * spark.reach,
        eased,
      )!;
      final tail = (14 + 88 * (1 - eased)) * scale;
      final fade = math.pow(1 - local, 2).toDouble();
      final head = center + Offset.fromDirection(spark.angle, distance);
      final back =
          center +
          Offset.fromDirection(
            spark.angle,
            math.max(coreRadius * 0.4, distance - tail),
          );
      final tint = palette.ring[spark.tint % palette.ring.length];
      canvas.drawLine(
        back,
        head,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = spark.width * scale
          ..shader = LinearGradient(
            colors: [
              tint.withValues(alpha: 0),
              tint.lighten(18).withValues(alpha: 0.9 * fade),
            ],
          ).createShader(Rect.fromPoints(back, head).inflate(1)),
      );
    }
  }

  void _paintRing(Canvas canvas, Offset center) {
    final local = _span(0.14, 0.80);
    if (local <= 0 || local >= 1) return;
    final fade = math.sin(math.pi * local);
    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke * scale * (0.45 + 0.55 * fade)
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: _sweep(0.85 * fade, lighten: 14),
          transform: GradientRotation(-math.pi / 2 + local * 3 * 2 * math.pi),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_HeroNovaPainter old) =>
      old.progress != progress ||
      old.palette != palette ||
      old.scale != scale ||
      old.ringRadius != ringRadius ||
      old.coreRadius != coreRadius ||
      !identical(old.sparks, sparks);
}

class _HeroOrbPainter extends CustomPainter {
  _HeroOrbPainter({
    required this.scale,
    required this.status,
    required this.previousStatus,
    required this.transition,
    required this.exiting,
    required this.palette,
    required this.drawProgress,
    required this.sweep,
    required this.handoff,
    required this.flow,
    required this.aurora,
    required this.pulse,
    required this.activity,
    required this.morph,
    required this.transitionProgress,
    required this.onset,
    required this.trackColor,
    required this.coreColor,
    required this.coreHighlight,
    required this.coreBorder,
  });

  final double scale;
  final HeroStatus status;
  final HeroStatus previousStatus;
  final HeroOrbTransition transition;
  final HeroStatus exiting;
  final HeroPalette palette;
  final double drawProgress;
  final double sweep;
  final double handoff;
  final double flow;
  final double aurora;
  final double pulse;
  final double activity;
  final double morph;
  final double transitionProgress;
  final double onset;
  final Color trackColor;
  final Color coreColor;
  final Color coreHighlight;
  final Color coreBorder;

  double get _ring => _ringStroke * scale;
  double get _paused => _pausedStroke * scale;
  double get _checking => _checkingStroke * scale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - (_ringStroke / 2 + 1.5) * scale;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final coreRadius = size.shortestSide / 2 - _coreInset * scale;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = trackColor,
    );

    _paintCore(canvas, center, coreRadius);

    switch (status) {
      case HeroStatus.offline:
        if (transition == HeroOrbTransition.networkLoss &&
            previousStatus.flows) {
          _paintFlowRing(
            canvas,
            center,
            rect,
            radius,
            bloom: false,
            alpha: 1 - transitionProgress,
          );
        }
        _paintNoSignalRing(
          canvas,
          rect,
          radius,
          transition == HeroOrbTransition.networkLoss ? transitionProgress : 1,
          visibility: 1,
        );
      case HeroStatus.off:
        if (drawProgress <= 0.004) break;
        _paintPreviousRing(
          canvas,
          center,
          rect,
          radius,
          alpha: 1,
          source: exiting,
        );
      case HeroStatus.checking:
        _paintComet(canvas, rect, tail: _checkingTail, stroke: _checking);
      case HeroStatus.diagnosing:
        _paintFlowRing(canvas, center, rect, radius);
        _paintComet(canvas, rect, tail: _checkingTail, stroke: _checking);
      case HeroStatus.connecting:
      case HeroStatus.reconnecting:
        if (transitionProgress < 1) {
          _paintPreviousRing(
            canvas,
            center,
            rect,
            radius,
            alpha: 1 - transitionProgress,
          );
        }
        _paintComet(
          canvas,
          rect,
          tail: _connectingTail,
          stroke: _ring,
          alpha: transitionProgress,
        );
      case HeroStatus.secured:
      case HeroStatus.degraded:
        if (transition == HeroOrbTransition.resume &&
            previousStatus == HeroStatus.paused) {
          _paintPausedRing(
            canvas,
            rect,
            radius,
            1,
            alpha: 1 - transitionProgress,
          );
        } else if (transition == HeroOrbTransition.recovery &&
            previousStatus == HeroStatus.broken) {
          _paintBrokenRing(canvas, rect, 1, alpha: 1 - transitionProgress);
        }
        _paintFlowRing(
          canvas,
          center,
          rect,
          radius,
          alpha:
              transition == HeroOrbTransition.resume ||
                  transition == HeroOrbTransition.recovery
              ? transitionProgress
              : 1,
        );
      case HeroStatus.subscriptionExpired:
        if (transitionProgress < 1) {
          _paintPreviousRing(
            canvas,
            center,
            rect,
            radius,
            alpha: 1 - transitionProgress,
          );
        }
        _paintSubscriptionExpiredRing(
          canvas,
          rect,
          radius,
          morph,
          alpha: transitionProgress,
        );
      case HeroStatus.blocked:
      case HeroStatus.broken:
        if (transitionProgress < 1) {
          _paintPreviousRing(
            canvas,
            center,
            rect,
            radius,
            alpha: 1 - transitionProgress,
          );
        }
        _paintBrokenRing(
          canvas,
          rect,
          morph,
          alpha: transition == HeroOrbTransition.fault ? transitionProgress : 1,
        );
      case HeroStatus.paused:
        if (transitionProgress < 1) {
          _paintPreviousRing(
            canvas,
            center,
            rect,
            radius,
            alpha: 1 - transitionProgress,
          );
        }
        _paintPausedRing(
          canvas,
          rect,
          radius,
          morph,
          alpha: transition == HeroOrbTransition.pause ? transitionProgress : 1,
        );
    }
  }

  void _paintPreviousRing(
    Canvas canvas,
    Offset center,
    Rect rect,
    double radius, {
    required double alpha,
    HeroStatus? source,
  }) {
    switch (source ?? previousStatus) {
      case HeroStatus.offline:
        _paintNoSignalRing(
          canvas,
          rect,
          radius,
          1,
          alpha: alpha,
          visibility: 1,
        );
      case HeroStatus.off:
        return;
      case HeroStatus.checking:
        _paintComet(
          canvas,
          rect,
          tail: _checkingTail,
          stroke: _checking,
          alpha: alpha,
          geometryProgress: 1,
        );
      case HeroStatus.diagnosing:
        _paintFlowRing(
          canvas,
          center,
          rect,
          radius,
          bloom: false,
          alpha: alpha,
        );
        _paintComet(
          canvas,
          rect,
          tail: _checkingTail,
          stroke: _checking,
          alpha: alpha,
          geometryProgress: 1,
        );
      case HeroStatus.connecting:
      case HeroStatus.reconnecting:
        _paintComet(
          canvas,
          rect,
          tail: _connectingTail,
          stroke: _ring,
          alpha: alpha,
          geometryProgress: 1,
        );
      case HeroStatus.secured:
      case HeroStatus.degraded:
        _paintFlowRing(
          canvas,
          center,
          rect,
          radius,
          bloom: false,
          alpha: alpha,
        );
      case HeroStatus.subscriptionExpired:
        _paintSubscriptionExpiredRing(canvas, rect, radius, 1, alpha: alpha);
      case HeroStatus.blocked:
      case HeroStatus.broken:
        _paintBrokenRing(canvas, rect, 1, alpha: alpha);
      case HeroStatus.paused:
        _paintPausedRing(canvas, rect, radius, 1, alpha: alpha);
    }
  }

  Paint _ringPaint(
    Rect rect,
    double rotation, {
    double? strokeWidth,
    double alpha = 1,
  }) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth ?? _ring
    ..strokeCap = StrokeCap.round
    ..shader = SweepGradient(
      colors: [
        for (final color in [...palette.ring, palette.ring.first])
          alpha >= 1 ? color : color.withValues(alpha: alpha),
      ],
      transform: GradientRotation(rotation),
    ).createShader(rect);

  void _paintCore(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(center, radius, Paint()..color = coreColor);

    final liveStrength = switch (status) {
      HeroStatus.connecting => 0.35 + 0.65 * transitionProgress,
      HeroStatus.reconnecting => 0.65 + 0.35 * transitionProgress,
      HeroStatus.diagnosing => 0.86,
      HeroStatus.degraded => 0.72,
      HeroStatus.subscriptionExpired => 0.48,
      HeroStatus.broken => 0.28,
      HeroStatus.paused => 0.42,
      HeroStatus.secured => 1.0,
      HeroStatus.off ||
      HeroStatus.offline when previousStatus.isLive => 1 - transitionProgress,
      _ => 0.0,
    };
    if (liveStrength > 0.001) {
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      final amplitude =
          (0.24 + 0.20 * activity) * (0.75 + 0.25 * pulse) * liveStrength;
      for (var i = 0; i < 2; i++) {
        final spin = (aurora + i * 0.5) * 2 * math.pi * (i == 0 ? 1 : -1);
        final drift = radius * (0.30 + 0.12 * math.sin(spin * 0.5));
        final blobCentre =
            center + Offset(math.cos(spin) * drift, math.sin(spin) * drift);
        final blobRadius = radius * (0.82 + 0.12 * i);
        final tint = palette.ring[i == 0 ? 0 : 2];
        canvas.drawCircle(
          blobCentre,
          blobRadius,
          Paint()
            ..shader =
                RadialGradient(
                  colors: [
                    tint.withValues(alpha: amplitude * (i == 0 ? 1 : 0.78)),
                    tint.withValues(alpha: 0),
                  ],
                ).createShader(
                  Rect.fromCircle(center: blobCentre, radius: blobRadius),
                ),
        );
      }
      canvas.restore();
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            coreHighlight.withValues(alpha: 0.22),
            coreHighlight.withValues(alpha: 0),
          ],
          stops: const [0, 0.55],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = coreBorder,
    );
  }

  /// Grows from `handoff`, so the ring continues the segment that preceded it.
  void _paintFlowRing(
    Canvas canvas,
    Offset center,
    Rect rect,
    double radius, {
    bool bloom = true,
    double alpha = 1,
  }) {
    final rotation = -math.pi / 2 + flow * 2 * math.pi;
    final start = -math.pi / 2 + handoff * 2 * math.pi;
    canvas.drawArc(
      rect,
      start,
      2 * math.pi * drawProgress,
      false,
      _ringPaint(rect, rotation, alpha: alpha),
    );
    if (!bloom || drawProgress < 0.98 || alpha < 0.98) return;
    // The gradient seam is the brightest point of the ring; a bloom pinned to
    // it is what makes the rotation legible instead of merely present.
    final head = center + Offset.fromDirection(rotation, radius);
    final headRadius = _ring * (1.5 + 0.8 * activity);
    final tip = palette.ring.first.lighten(22);
    canvas.drawCircle(
      head,
      headRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            tip.withValues(alpha: 0.30 + 0.45 * activity),
            tip.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: head, radius: headRadius)),
    );
  }

  void _paintComet(
    Canvas canvas,
    Rect rect, {
    required double tail,
    required double stroke,
    double alpha = 1,
    double? geometryProgress,
  }) {
    final progress = geometryProgress ?? morph;
    final length = tail * (0.25 + 0.75 * progress);
    final head = -math.pi / 2 + sweep * 2 * math.pi;
    final span = length / (2 * math.pi);
    canvas.drawArc(
      rect,
      head - length,
      length,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * (0.6 + 0.4 * progress)
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [
            palette.ring[2].withValues(alpha: 0),
            palette.ring[1].withValues(alpha: 0.55 * progress * alpha),
            palette.ring[0].withValues(alpha: progress * alpha),
          ],
          stops: [0, span * 0.7, span],
          transform: GradientRotation(head - length),
        ).createShader(rect),
    );
  }

  void _paintSubscriptionExpiredRing(
    Canvas canvas,
    Rect rect,
    double radius,
    double morph, {
    double alpha = 1,
  }) {
    final rotation = lerpDouble(-math.pi / 2, -math.pi * 0.38, morph)!;
    final mainSweep = lerpDouble(2 * math.pi, math.pi * 1.46, morph)!;
    final stroke = lerpDouble(_ring, _ring * 0.68, morph)!;
    final opacity = alpha * lerpDouble(1, 0.72 + 0.08 * pulse, morph)!;
    final paint = _ringPaint(
      rect,
      rotation,
      strokeWidth: stroke,
      alpha: opacity,
    );
    canvas.drawArc(rect, rotation, mainSweep, false, paint);

    if (morph <= 0.02) return;
    final remnantStart = rotation + mainSweep + math.pi * 0.20 * morph;
    final remnantSweep = math.pi * 0.16 * morph;
    canvas.drawArc(
      rect,
      remnantStart,
      remnantSweep,
      false,
      _ringPaint(
        rect,
        rotation,
        strokeWidth: stroke * 0.72,
        alpha: opacity * 0.34,
      ),
    );
    final terminal =
        rect.center + Offset.fromDirection(rotation + mainSweep, radius);
    canvas.drawCircle(
      terminal,
      stroke * 0.42 * morph,
      Paint()..color = palette.ring.first.withValues(alpha: opacity * 0.88),
    );
  }

  /// `onset` makes the first dip the deepest.
  void _paintBrokenRing(
    Canvas canvas,
    Rect rect,
    double morph, {
    double alpha = 1,
  }) {
    const settledStart = 0.0;
    final carriedStart = -math.pi / 2 + handoff * 2 * math.pi;
    final anchor = lerpDouble(carriedStart, settledStart, morph)!;
    final sweepAngle = math.pi * (2 - morph) * drawProgress;
    final dip = lerpDouble(0.20, 0.45, onset)!;
    canvas.drawArc(
      rect,
      anchor,
      sweepAngle,
      false,
      _ringPaint(rect, carriedStart, alpha: alpha * lerpDouble(1, dip, pulse)!),
    );
  }

  void _paintNoSignalRing(
    Canvas canvas,
    Rect rect,
    double radius,
    double morph, {
    double alpha = 1,
    double visibility = 1,
  }) {
    final period = _noSignalPeriod * scale;
    final count = math.max(6, (2 * math.pi * radius / period).round());
    final step = 2 * math.pi / count;
    final fill = lerpDouble(1, _noSignalDash / _noSignalPeriod, morph);
    final paint = _ringPaint(
      rect,
      -math.pi / 2,
      strokeWidth: lerpDouble(_ring, _paused, morph),
      alpha: alpha * lerpDouble(1, 0.55, morph)!,
    );
    for (var i = 0; i < count; i++) {
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * step,
        step * fill! * visibility,
        false,
        paint,
      );
    }
  }

  void _paintPausedRing(
    Canvas canvas,
    Rect rect,
    double radius,
    double morph, {
    double alpha = 1,
  }) {
    final period = _pausedPeriod * scale;
    final count = math.max(12, (2 * math.pi * radius / period).round());
    final step = 2 * math.pi / count;
    final fill = lerpDouble(1, _pausedDash / _pausedPeriod, morph)!;
    final paint = _ringPaint(
      rect,
      -math.pi / 2,
      strokeWidth: lerpDouble(_ring, _paused, morph),
      alpha: alpha * lerpDouble(1, 0.70, pulse)!,
    );
    for (var i = 0; i < count; i++) {
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * step,
        step * fill * drawProgress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeroOrbPainter old) =>
      old.scale != scale ||
      old.status != status ||
      old.previousStatus != previousStatus ||
      old.transition != transition ||
      old.exiting != exiting ||
      old.palette != palette ||
      old.drawProgress != drawProgress ||
      old.sweep != sweep ||
      old.handoff != handoff ||
      old.flow != flow ||
      old.aurora != aurora ||
      old.pulse != pulse ||
      old.activity != activity ||
      old.morph != morph ||
      old.transitionProgress != transitionProgress ||
      old.onset != onset ||
      old.trackColor != trackColor ||
      old.coreColor != coreColor ||
      old.coreHighlight != coreHighlight ||
      old.coreBorder != coreBorder;
}
