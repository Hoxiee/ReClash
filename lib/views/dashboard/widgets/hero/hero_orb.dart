import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/common/milestones/finding_events.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_spark.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_overlay.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'hero_orb_painters.dart';

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

const _collapseCharge = Duration(milliseconds: 2400);

const _singularityDuration = Duration(milliseconds: 2600);
const _singularitySparkCount = 66;

const _evaporatePeak = 0.52;
const _regrowDuration = Duration(milliseconds: 1180);

const _collapseTell = 0.34;

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
  @visibleForTesting
  static const Key collapseKey = ValueKey('orb-collapse');
  @visibleForTesting
  static const Key singularityKey = ValueKey('orb-singularity');

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
  late final AnimationController _collapse;
  late final AnimationController _singularity;

  late final AnimationController _regrow;

  /// Drawn once per detonation so the spray is stable across its frames and
  /// different every time.
  List<_NovaSpark> _sparks = const [];
  List<_NovaSpark> _singularitySparks = const [];

  /// Set once the big bang has fired so a finger still down after it never
  /// re-arms the charge or the collapse.
  bool _spent = false;
  final List<Timer> _pulseTimers = [];

  OverlayEntry? _cinematicEntry;
  Rect _cinematicOrbRect = Rect.zero;
  double _cinematicScreenShort = 0;

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
    _collapse = AnimationController(
      vsync: this,
      duration: _collapseCharge,
      reverseDuration: const Duration(milliseconds: 620),
    )
      ..addStatusListener(_handleCollapse)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && !_spent) _hideCinematic();
      });
    _singularity = AnimationController(
      vsync: this,
      duration: _singularityDuration,
    )..addListener(_driveImpact);
    _regrow = AnimationController(
      vsync: this,
      value: 1,
      duration: _regrowDuration,
    );
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
    _hideCinematic();
    screenImpactOffset.value = Offset.zero;
    _connectingHold?.cancel();
    _swallowTimer?.cancel();
    _landingTimer?.cancel();
    _oscilloscopeHold?.cancel();
    _oscilloscopeTimer?.cancel();
    _multiTouchRelease?.cancel();
    for (final timer in _pulseTimers) {
      timer.cancel();
    }
    _charge.dispose();
    _nova.dispose();
    _collapse.dispose();
    _singularity.dispose();
    _regrow.dispose();
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
    for (final timer in _pulseTimers) {
      timer.cancel();
    }
    _pulseTimers.clear();
    _spent = false;
    _collapse.value = 0;
    _singularity.value = 0;
    _regrow.value = 1;
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
    if (_still ||
        !widget.enabled ||
        _nova.isAnimating ||
        _collapse.isAnimating ||
        _singularity.isAnimating ||
        _spent ||
        _multiTouch) {
      return;
    }
    _chargeOrigin = position;
    _charge.forward(from: 0);
  }

  void _clearPulses() {
    for (final timer in _pulseTimers) {
      timer.cancel();
    }
    _pulseTimers.clear();
  }

  void _cancelCharge() {
    _chargeOrigin = null;
    _spent = false;
    _clearPulses();
    if (_collapse.value > 0 && !_singularity.isAnimating) {
      _collapse.reverse();
      if (!_still) _ripple.forward(from: 0);
    }
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
      if (!mounted) return;
      _nova.value = 0;
      _maybeCollapse();
    });
  }

  // The nova is done and the finger never left: the orb caves into the collapse
  // that arms the big bang.
  void _maybeCollapse() {
    if (_still ||
        _spent ||
        _multiTouch ||
        _chargeOrigin == null ||
        _pointers.isEmpty ||
        !_charge.isCompleted) {
      return;
    }
    _collapse.forward(from: 0);
    _showCinematic();
    if (defaultTargetPlatform != TargetPlatform.android) return;
    for (final at in const [0.45, 0.7, 0.88]) {
      _pulseTimers.add(
        Timer(_collapseCharge * at, () {
          if (mounted && _collapse.isAnimating) HapticFeedback.lightImpact();
        }),
      );
    }
  }

  void _handleCollapse(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _evaporate();
  }

  void _evaporate() {
    _spent = true;
    _clearPulses();
    _singularitySparks = _novaSparks(
      math.Random(DateTime.now().microsecondsSinceEpoch),
      count: _singularitySparkCount,
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      HapticFeedback.mediumImpact();
      for (final at in const [0.16, 0.28]) {
        _pulseTimers.add(
          Timer(_singularityDuration * at, () {
            if (mounted) HapticFeedback.lightImpact();
          }),
        );
      }
      // A salvo of heavy hits at the detonation, tapering off, so the blast is
      // a felt rumble on the fingertips rather than a single knock.
      final peak = _singularityDuration * _evaporatePeak;
      for (final ms in const [0, 45, 95, 155]) {
        _pulseTimers.add(
          Timer(peak + Duration(milliseconds: ms), () {
            if (mounted) HapticFeedback.heavyImpact();
          }),
        );
      }
      for (final ms in const [235, 340]) {
        _pulseTimers.add(
          Timer(peak + Duration(milliseconds: ms), () {
            if (mounted) HapticFeedback.mediumImpact();
          }),
        );
      }
    }
    _maybeDiscoverSingularity();
    _singularity.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _singularity.value = 0;
      _collapse.value = 0;
      _charge.value = 0;
      _hideCinematic();
      _regrowOrb();
    });
  }

  void _regrowOrb() {
    _spent = true;
    if (_still) {
      _regrow.value = 1;
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      _pulseTimers.add(
        Timer(_regrowDuration ~/ 2, () {
          if (mounted) HapticFeedback.selectionClick();
        }),
      );
    }
    _ripple.forward(from: 0);
    _regrow.forward(from: 0);
  }

  void _maybeDiscoverSingularity() {
    if (_status != HeroStatus.secured ||
        !PageActivityScope.isActiveOf(context) ||
        !ref.read(milestoneSettingProvider).findingsEnabled ||
        ref.read(findingPreviewProvider).enabled) {
      return;
    }
    ref.read(milestonesProvider.notifier).discover('singularity');
  }

  void _showCinematic() {
    if (_cinematicEntry != null) return;
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context);
    if (box == null || !box.hasSize || overlay == null) return;
    _cinematicOrbRect = box.localToGlobal(Offset.zero) & box.size;
    _cinematicScreenShort = MediaQuery.sizeOf(context).shortestSide;
    _cinematicEntry = OverlayEntry(builder: _buildCinematic);
    overlay.insert(_cinematicEntry!);
  }

  void _hideCinematic() {
    _cinematicEntry?.remove();
    _cinematicEntry = null;
    screenImpactOffset.value = Offset.zero;
  }

  void _driveImpact() {
    final s = _singularity.value;
    screenImpactOffset.value = (s > 0 && s < 1)
        ? _screenShake(s, _cinematicScreenShort)
        : Offset.zero;
  }

  Offset _cinematicShake() {
    final s = _singularity.value;
    if (s > 0) {
      if (s < 0.42) {
        final b = s / 0.42;
        final amp = b * b * 3.0;
        return Offset(math.sin(s * 23) * amp * 0.4, math.sin(s * 19) * amp);
      }
      if (s < _evaporatePeak) {
        final b = (s - 0.42) / (_evaporatePeak - 0.42);
        final amp = 4 + b * b * 22;
        return Offset(math.sin(s * 57) * amp * 0.7, math.sin(s * 63) * amp);
      }
      // The screen carries the slam now; the field only keeps a fine judder
      // on top so the collapsing point trembles inside the moving frame.
      final k = ((s - _evaporatePeak) / (1 - _evaporatePeak)).clamp(0.0, 1.0);
      final decay = math.pow(1 - k, 1.8).toDouble();
      final tremble = math.sin(s * 96) * 9 * decay;
      return Offset(tremble * 0.6, tremble);
    }
    final c = _collapse.value;
    if (c <= _collapseTell) return Offset.zero;
    final local = (c - _collapseTell) / (1 - _collapseTell);
    final tremor = local * local * 1.6;
    return Offset(math.sin(c * 15) * tremor * 0.4, math.sin(c * 12) * tremor);
  }

  /// The big-bang kick, thrown at the whole overlay so the screen itself
  /// recoils. A hard low-frequency lurch that is already at full throw on the
  /// first frame, stacked with a high-frequency buzz, both ringing down fast
  /// under a steep decay so it hits like an impact rather than a wobble.
  Offset _screenShake(double s, double screenShort) {
    if (s < _evaporatePeak) return Offset.zero;
    final k = ((s - _evaporatePeak) / (1 - _evaporatePeak)).clamp(0.0, 1.0);
    final decay = math.pow(1 - k, 2.3).toDouble();
    final amp = (screenShort <= 0 ? 720.0 : screenShort) * 0.055;
    final lurch = math.cos(k * 8 * math.pi) * amp * decay;
    final swing = math.sin(k * 6 * math.pi + 0.7) * amp * 0.9 * decay;
    final buzz = math.sin(s * 130) * amp * 0.5 * decay;
    return Offset(swing + buzz, lurch + buzz * 0.7);
  }

  Widget _buildCinematic(BuildContext overlayContext) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_collapse, _singularity, _tint]),
        builder: (context, _) {
          final s = _singularity.value;
          final sWarp = s < _evaporatePeak
              ? _evaporatePeak * Curves.easeInOutCubic.transform(s / _evaporatePeak)
              : _evaporatePeak +
                    (1 - _evaporatePeak) *
                        Curves.easeOutQuart.transform(
                          (s - _evaporatePeak) / (1 - _evaporatePeak),
                        );
          final collapseLocal =
              ((_collapse.value - _collapseTell) / (1 - _collapseTell)).clamp(
                0.0,
                1.0,
              );
          final showSingularity = s > 0 && s < 1;
          final showCollapse = !showSingularity && collapseLocal > 0;
          if (!showSingularity && !showCollapse) {
            return const SizedBox.shrink();
          }

          final screen = MediaQuery.sizeOf(context);
          final screenShort = math.min(screen.width, screen.height);
          final screenCenter = Offset(screen.width / 2, screen.height / 2);
          final grow = Curves.easeInOutCubic.transform(
            ((collapseLocal - 0.12) / 0.78).clamp(0.0, 1.0),
          );
          final risePos = showSingularity ? 1.0 : grow;
          final riseScale = showSingularity ? 1.0 : grow;
          final focal = Offset.lerp(
            _cinematicOrbRect.center,
            screenCenter,
            risePos,
          )!;
          final bodyDia = lerpDouble(
            _cinematicOrbRect.shortestSide * 0.92,
            screenShort * 0.5,
            riseScale,
          )!;
          final cine = bodyDia / heroOrbBaseSize;
          final coreRadius = bodyDia / 2 - _coreInset * cine;
          final ringRadius = bodyDia / 2 - (_ringStroke / 2 + 1.5) * cine;
          final field =
              math.sqrt(
                screen.width * screen.width + screen.height * screen.height,
              ) *
              1.3;
          final shake = _cinematicShake();
          final scrimEnvelope = showSingularity
              ? (1 -
                    Curves.easeInCubic.transform(
                      ((s - _evaporatePeak) / (1 - _evaporatePeak)).clamp(
                        0.0,
                        1.0,
                      ),
                    ))
              : Curves.easeInCubic.transform(collapseLocal);
          // Lighter than a black-out so the recoiling app stays visible.
          final scrim = 0.62 * scrimEnvelope;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        (focal.dx / screen.width) * 2 - 1,
                        (focal.dy / screen.height) * 2 - 1,
                      ),
                      radius: 0.95,
                      colors: [
                        Colors.black.withValues(alpha: scrim * 0.4),
                        Colors.black.withValues(alpha: scrim),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: focal.dx - field / 2 + shake.dx,
                top: focal.dy - field / 2 + shake.dy,
                width: field,
                height: field,
                child: showSingularity
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          if (sWarp < 0.22)
                            CustomPaint(
                              key: HeroOrb.collapseKey,
                              painter: _HeroCollapsePainter(
                                progress: 1,
                                palette: _currentPalette,
                                scale: cine,
                                coreRadius: coreRadius,
                                fade: 1 - (sWarp / 0.22),
                              ),
                            ),
                          CustomPaint(
                            key: HeroOrb.singularityKey,
                            painter: _HeroSingularityPainter(
                              progress: sWarp,
                              palette: _currentPalette,
                              scale: cine,
                              ringRadius: ringRadius,
                              coreRadius: coreRadius,
                              sparks: _singularitySparks,
                              spinPhase: 1.8 + 5.0,
                            ),
                          ),
                        ],
                      )
                    : CustomPaint(
                        key: HeroOrb.collapseKey,
                        painter: _HeroCollapsePainter(
                          progress: _collapse.value,
                          palette: _currentPalette,
                          scale: cine,
                          coreRadius: coreRadius,
                        ),
                      ),
              ),
              if (showSingularity && s >= _evaporatePeak)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withValues(
                      alpha:
                          0.32 *
                          math
                              .pow(
                                1 -
                                    ((s - _evaporatePeak) / (1 - _evaporatePeak))
                                        .clamp(0.0, 1.0),
                                5,
                              )
                              .toDouble(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
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
    if (_charge.isCompleted) return 1;
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

  double get _orbScale {
    if (_regrow.value < 1) return _regrowScale;
    if (_singularity.value > 0) return _drainScale;
    if (_collapse.value > 0) return _collapseScale;
    return _novaScale;
  }

  Offset get _orbKick {
    if (_regrow.value < 1 || _singularity.value > 0) return Offset.zero;
    if (_collapse.value > 0) return _collapseKick;
    return _novaKick;
  }

  double get _orbTilt =>
      (_regrow.value < 1 || _singularity.value > 0) ? 0 : _novaTilt;

  double get _orbGlow {
    final r = _regrow.value;
    if (r < 1) {
      final local = ((r - 0.14) / 0.5).clamp(0.0, 1.0);
      return local <= 0 || local >= 1 ? 0 : math.sin(math.pi * local);
    }
    if (_singularity.value > 0 || _collapse.value > 0) return 0;
    return _novaGlow;
  }

  double get _orbBodyOpacity {
    final r = _regrow.value;
    if (r < 1) {
      return Curves.easeOutCubic.transform(
        ((r - 0.14) / 0.34).clamp(0.0, 1.0),
      );
    }
    if (_singularity.value > 0) return 0;
    final c = _collapse.value;
    if (c <= 0) return 1;
    final local = ((c - _collapseTell) / (1 - _collapseTell)).clamp(0.0, 1.0);
    return 1 - Curves.easeInCubic.transform((local / 0.18).clamp(0.0, 1.0));
  }

  double get _collapseScale {
    final c = _collapse.value;
    if (c <= 0) return _novaScale;
    final gather = Curves.easeInCubic.transform(c);
    final tremor = math.sin(c * 30) * 0.016 * c;
    return lerpDouble(1, 0.5, gather)! + tremor;
  }

  Offset get _collapseKick {
    final c = _collapse.value;
    if (c <= _collapseTell) return Offset.zero;
    final local = (c - _collapseTell) / (1 - _collapseTell);
    final amp = local * local * 5.5;
    final phase = c * 40;
    return Offset(math.sin(phase) * amp, math.cos(phase * 1.3) * amp);
  }

  double get _drainScale => 0.05;

  double get _regrowScale {
    final r = _regrow.value;
    if (r >= 1) return 1;
    if (r < 0.14) return 0;
    return Curves.elasticOut.transform(((r - 0.14) / 0.86).clamp(0.0, 1.0));
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
          animation: Listenable.merge([
            _press,
            _charge,
            _nova,
            _collapse,
            _singularity,
            _regrow,
          ]),
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
                          _collapse,
                          _singularity,
                          _regrow,
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
                              intensity: math.max(halo, _orbGlow),
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
                          if (_charge.value > _chargeTell &&
                              !_charge.isCompleted) {
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
          builder: (context, child) {
            final body = _orbBodyOpacity;
            final scaled = Transform.translate(
              offset: _orbKick * scale,
              child: Transform.rotate(
                angle: _orbTilt,
                child: Transform.scale(
                  scale: (1.0 - 0.035 * _press.value) * _orbScale,
                  child: child,
                ),
              ),
            );
            return body >= 1 ? scaled : Opacity(opacity: body, child: scaled);
          },
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
