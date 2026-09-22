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
    );
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
    _cinematicEntry = OverlayEntry(builder: _buildCinematic);
    overlay.insert(_cinematicEntry!);
  }

  void _hideCinematic() {
    _cinematicEntry?.remove();
    _cinematicEntry = null;
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
    final gain = (screenShort / 720).clamp(0.8, 1.7);
    final lurch = math.cos(k * 8 * math.pi) * 60 * decay;
    final swing = math.sin(k * 6 * math.pi + 0.7) * 52 * decay;
    final buzz = math.sin(s * 124) * 26 * decay;
    return Offset((swing + buzz) * gain, (lurch + buzz * 0.7) * gain);
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
          final screenShake = _screenShake(s, screenShort);
          // Overhang so the recoiling scrim and flash never uncover a bright
          // strip of the app at the edge as the whole overlay is translated.
          const shakePad = 96.0;
          final scrimEnvelope = showSingularity
              ? (1 -
                    Curves.easeInCubic.transform(
                      ((s - _evaporatePeak) / (1 - _evaporatePeak)).clamp(
                        0.0,
                        1.0,
                      ),
                    ))
              : Curves.easeInCubic.transform(collapseLocal);
          final scrim = 0.8 * scrimEnvelope;

          return Transform.translate(
            offset: screenShake,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
              Positioned(
                left: -shakePad,
                top: -shakePad,
                right: -shakePad,
                bottom: -shakePad,
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
                Positioned(
                  left: -shakePad,
                  top: -shakePad,
                  right: -shakePad,
                  bottom: -shakePad,
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
            ),
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

List<_NovaSpark> _novaSparks(math.Random random, {int count = _novaSparkCount}) =>
    [
      for (var i = 0; i < count; i++)
        _NovaSpark(
          angle: (i + random.nextDouble() * 0.8) / count * 2 * math.pi,
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

/// The second wind-up made literal: the light the nova threw is dragged back
/// into a well. A near-edge-on accretion disk lights around a growing shadow;
/// its far side is lensed up and over the top while its near side sweeps
/// across the front, a razor photon ring traces the event horizon, the flank
/// turning toward the eye is beamed to white and the receding one reddens, and
/// twin jets fire from the poles — all of it winding faster into the big bang.
/// Owns no state.
class _HeroCollapsePainter extends CustomPainter {
  _HeroCollapsePainter({
    required this.progress,
    required this.palette,
    required this.scale,
    required this.coreRadius,
    this.fade = 1,
  });

  final double progress;
  final HeroPalette palette;
  final double scale;
  final double coreRadius;
  final double fade;

  static const _armCount = 26;
  static const _starCount = 44;
  static const _diskBands = 7;
  static const _hotSpots = 22;

  /// The disk is a plate seen from a shallow angle: squashing its height is
  /// what gives it a near and a far edge. The lensed halo stays near-circular
  /// instead, and that mismatch — flat bar through a round ring — is the read.
  static const _squash = 0.34;

  /// Shared by the plane, the ansae and the lensed halo so all three agree on
  /// where the disk ends.
  double _diskOuter(double pull) => coreRadius * lerpDouble(2.3, 1.5, pull)!;

  @override
  void paint(Canvas canvas, Size size) {
    final local = ((progress - _collapseTell) / (1 - _collapseTell)).clamp(
      0.0,
      1.0,
    );
    if (local <= 0) return;
    final center = size.center(Offset.zero);
    final reach = size.shortestSide / 2;
    final faded = fade < 1;
    if (faded) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Color.fromRGBO(255, 255, 255, fade.clamp(0.0, 1.0)),
      );
    }
    final pull = Curves.easeInCubic.transform(local);
    final spin = local * 2.2 + local * local * 6.0;
    final open = Curves.easeOutBack.transform(
      ((local - 0.12) / 0.4).clamp(0.0, 1.0),
    );
    final breathe = 1 + 0.03 * math.sin(local * 4 * 2 * math.pi);
    final horizon = coreRadius * lerpDouble(0.05, 0.52, open)! * breathe;
    final split = 0.5 * scale;

    _paintDeepSpace(canvas, center, reach, pull);
    _paintOrbBody(canvas, center, local, pull);
    _paintStars(canvas, center, reach, horizon, pull, spin);
    _paintInfall(canvas, center, reach, horizon, local, pull, spin);

    // Far half of the plate (behind the hole): the opaque shadow drawn next
    // cuts its inner edge, so what survives reads as diving in behind.
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        center.dx - reach,
        center.dy - reach,
        center.dx + reach,
        center.dy + split,
      ),
    );
    _paintDiskPlane(canvas, center, horizon, pull, spin);
    canvas.restore();

    _paintShadow(canvas, center, horizon, pull);
    _paintLensHalo(canvas, center, horizon, pull, spin);
    _paintPhotonRing(canvas, center, horizon, pull, local, spin);

    // Near half, drawn last: additive gas over the black shadow lights its
    // lower rim, which is exactly how the front of the plate should occlude it.
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        center.dx - reach,
        center.dy - split,
        center.dx + reach,
        center.dy + reach,
      ),
    );
    _paintDiskPlane(canvas, center, horizon, pull, spin);
    canvas.restore();

    _paintDoppler(canvas, center, pull, spin);
    _paintJets(canvas, center, horizon, reach, pull, spin);
    _paintShimmer(canvas, center, horizon, pull, spin);
    if (faded) canvas.restore();
  }

  void _paintOrbBody(Canvas canvas, Offset center, double local, double pull) {
    final fadeIn = (local / 0.18).clamp(0.0, 1.0);
    final fade = fadeIn * (1 - pull / 0.86).clamp(0.0, 1.0);
    if (fade <= 0) return;
    final r =
        coreRadius * lerpDouble(1.0, 0.3, Curves.easeInCubic.transform(pull))!;
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.accent.withValues(alpha: 0.95 * fade),
            palette.ring.first.withValues(alpha: 0.6 * fade),
            _shift(
              palette.ring.last,
              hue: 12,
              light: -0.1,
            ).withValues(alpha: 0.3 * fade),
          ],
          stops: const [0, 0.6, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      r * 1.02,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke * scale * (0.4 + 0.6 * fade)
        ..color = palette.ring.first.lighten(8).withValues(alpha: 0.85 * fade),
    );
  }

  /// A blurred additive glow; the blooms carry most of the collapse's light.
  void _bloom(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double sigma,
  ) {
    if (radius <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma)
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintDeepSpace(Canvas canvas, Offset center, double reach, double pull) {
    final rect = Rect.fromCenter(
      center: center,
      width: reach * 2,
      height: reach * 2,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.5 * pull),
          ],
          stops: [0, lerpDouble(0.62, 0.34, pull)!, 1],
        ).createShader(Rect.fromCircle(center: center, radius: reach)),
    );
  }

  /// The field being pulled in: points wind around the well and smear into
  /// short tangential streaks, brightest as they cross the lensing radius
  /// where a real photon would be swung the furthest.
  void _paintStars(
    Canvas canvas,
    Offset center,
    double reach,
    double horizon,
    double pull,
    double spin,
  ) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;
    final lensR = horizon * 2.6;
    for (var i = 0; i < _starCount; i++) {
      final seed = 0.28 + (i % 7) / 7 * 0.72;
      final r = reach * seed * (1 - 0.58 * pull);
      final angle = i * 2.39996 + spin * (0.35 + seed * 0.6);
      final head = center + Offset.fromDirection(angle, r);
      final lens = 1 + 1.6 * math.exp(-math.pow((r - lensR) / (lensR * 0.5), 2));
      final stretch = (5 + 30 * pull) * scale * (1 - seed * 0.5) * lens;
      final tail = center + Offset.fromDirection(angle + 0.16, r + stretch);
      final twinkle = 0.5 + 0.5 * (0.5 + 0.5 * math.sin(spin * 1.1 + i));
      paint
        ..strokeWidth = (0.6 + 0.8 * (1 - seed)) * scale
        ..color = Colors.white.withValues(
          alpha: (0.42 * pull * twinkle * seed * lens).clamp(0.0, 0.9),
        );
      canvas.drawLine(tail, head, paint);
    }
  }

  /// The accretion disk as a plane, painted once per depth half. A radial
  /// temperature ramp runs white-hot at the inner rim out to a cool ember
  /// edge; concentric bands churn on their own phases so the gas turns rather
  /// than spinning rigidly; a left-to-right beam brightens the approaching
  /// flank and reddens the receding one.
  void _paintDiskPlane(
    Canvas canvas,
    Offset center,
    double horizon,
    double pull,
    double spin,
  ) {
    final inner = horizon * 1.02;
    final outer = _diskOuter(pull);
    final outerRect = Rect.fromCenter(
      center: center,
      width: outer * 2,
      height: outer * 2 * _squash,
    );
    final innerRect = Rect.fromCenter(
      center: center,
      width: inner * 2,
      height: inner * 2 * _squash,
    );
    final annulus = Path()
      ..addOval(outerRect)
      ..addOval(innerRect)
      ..fillType = PathFillType.evenOdd;
    final hIn = (inner / outer).clamp(0.02, 0.6);
    final mid = palette.ring[palette.ring.length ~/ 2];

    canvas.drawPath(
      annulus,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.85 * pull),
            palette.ring.first.lighten(14).withValues(alpha: 0.7 * pull),
            mid.withValues(alpha: 0.42 * pull),
            _shift(
              palette.ring.last,
              hue: 20,
              light: -0.04,
            ).withValues(alpha: 0.22 * pull),
            palette.ring.last.withValues(alpha: 0),
          ],
          stops: [
            hIn * 0.96,
            hIn,
            lerpDouble(hIn, 1, 0.2)!,
            lerpDouble(hIn, 1, 0.52)!,
            0.84,
            1,
          ],
        ).createShader(outerRect),
    );

    // Differential-rotation banding.
    for (var b = 0; b < _diskBands; b++) {
      final t = b / (_diskBands - 1);
      final wobble = 1 + 0.05 * math.sin(spin * 1.3 + b * 1.7);
      final radius = lerpDouble(outer * 0.97, inner * 1.06, t)! * wobble;
      final rect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 2 * _squash,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lerpDouble(5, 12, t)! * scale
          ..blendMode = BlendMode.plus
          ..shader = SweepGradient(
            colors: _diskSweep((0.1 + 0.18 * t) * pull),
            transform: GradientRotation(spin + b),
          ).createShader(rect),
      );
    }

    // Doppler beaming across the whole plate.
    canvas.drawPath(
      annulus,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.95 * pull),
            _shift(
              palette.ring.first,
              hue: -20,
              light: 0.22,
            ).withValues(alpha: 0.6 * pull),
            _shift(
              palette.ring.first,
              hue: -20,
              light: 0.22,
            ).withValues(alpha: 0),
            _shift(
              palette.ring.last,
              hue: 16,
              light: -0.08,
            ).withValues(alpha: 0.32 * pull),
          ],
          stops: const [0, 0.24, 0.6, 1],
        ).createShader(outerRect),
    );

    canvas.drawOval(
      innerRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * scale
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5 * scale)
        ..color = Colors.white.withValues(alpha: 0.7 * pull),
    );

    _paintHotSpots(canvas, center, inner, outer, pull, spin);
  }

  void _paintHotSpots(
    Canvas canvas,
    Offset center,
    double inner,
    double outer,
    double pull,
    double spin,
  ) {
    for (var i = 0; i < _hotSpots; i++) {
      final a = i * 2.39996 + spin * (0.8 + (i % 3) * 0.2);
      final rr = lerpDouble(inner, outer, (i % 5) / 4)!;
      final p = center + Offset(math.cos(a) * rr, math.sin(a) * rr * _squash);
      // Beamed brighter on the approaching (left) flank, dim on the right.
      final beam = 0.45 + 0.55 * (0.5 - 0.5 * math.cos(a));
      final flick = 0.6 + 0.4 * (0.5 + 0.5 * math.sin(spin * 1.4 + i * 1.7));
      final radius = (2.5 + (i % 3) * 2.2) * scale;
      final tint = palette.ring[i % palette.ring.length].lighten(20);
      canvas.drawCircle(
        p,
        radius,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.85 * pull * flick * beam),
              tint.withValues(alpha: 0.5 * pull * flick * beam),
              tint.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: p, radius: radius)),
      );
    }
  }

  /// Matter spiralling down the well and stretching thin as it goes — more
  /// turns the closer it falls — each stream ending in a hot head right where
  /// it is about to cross the horizon and be swallowed.
  void _paintInfall(
    Canvas canvas,
    Offset center,
    double reach,
    double horizon,
    double local,
    double pull,
    double spin,
  ) {
    const steps = 12;
    for (var i = 0; i < _armCount; i++) {
      final base = i * 2.39996 + spin;
      final outer = lerpDouble(reach * 0.92, coreRadius * 1.6, pull)!;
      final side = math.cos(base);
      final tint = _shift(
        palette.ring[i % palette.ring.length],
        hue: side * -18,
        light: side * 0.12,
      ).lighten(8);
      final swirl = 1.4 + 2.2 * pull;
      final path = Path();
      for (var s = 0; s <= steps; s++) {
        final t = s / steps;
        final r = lerpDouble(outer, horizon * 0.98, t)!;
        final angle = base + t * t * swirl;
        final point = center + Offset.fromDirection(angle, r);
        s == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (0.6 + 1.5 * pull) * scale
          ..strokeCap = StrokeCap.round
          ..blendMode = BlendMode.plus
          ..color = tint.withValues(alpha: (0.28 + 0.26 * pull) * local),
      );
      final head = center + Offset.fromDirection(base + swirl, horizon * 1.02);
      final hr = (2.0 + 2.2 * pull) * scale;
      canvas.drawCircle(
        head,
        hr,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.8 * pull),
              tint.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: head, radius: hr)),
      );
    }
  }

  /// Twin relativistic jets fired along the poles: a blurred sheath round a
  /// white spine with knots riding out, igniting once the fall is underway.
  void _paintJets(
    Canvas canvas,
    Offset center,
    double horizon,
    double reach,
    double pull,
    double spin,
  ) {
    final ignite = ((pull - 0.18) / 0.82).clamp(0.0, 1.0);
    if (ignite <= 0) return;
    final length = reach * lerpDouble(0.35, 1.3, ignite)!;
    final tint = _shift(palette.ring.first, hue: -14, light: 0.2).lighten(6);
    const steps = 14;
    for (final axis in [-math.pi / 2, math.pi / 2]) {
      for (var s = 0; s < steps; s++) {
        final t = s / steps;
        final r0 = horizon * 0.5 + length * t;
        final r1 = horizon * 0.5 + length * (s + 1) / steps;
        final p0 = center + Offset.fromDirection(axis, r0);
        final p1 = center + Offset.fromDirection(axis, r1);
        final taper = 1 - t;
        final width = (3 + 13 * taper) * scale;
        final fade = math.pow(1 - t, 1.4).toDouble() * ignite;
        canvas.drawLine(
          p0,
          p1,
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = width * 2.6
            ..blendMode = BlendMode.plus
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, width)
            ..color = tint.withValues(alpha: 0.24 * fade),
        );
        canvas.drawLine(
          p0,
          p1,
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = width * 0.5
            ..blendMode = BlendMode.plus
            ..color = Colors.white.withValues(alpha: 0.5 * fade),
        );
      }
      for (var k = 0; k < 4; k++) {
        final kt = (spin * 0.12 + k / 4) % 1.0;
        final rr = horizon * 0.5 + length * kt;
        final wob = math.sin(spin * 2 + k * 2) * 6 * scale * (1 - kt);
        final p = center + Offset.fromDirection(axis, rr) + Offset(wob, 0);
        _bloom(
          canvas,
          p,
          (5 + 7 * (1 - kt)) * scale,
          Colors.white.withValues(alpha: 0.7 * ignite * (1 - kt)),
          3 * scale,
        );
      }
    }
  }

  /// The event horizon: a true black disk that grows as the fall deepens, with
  /// a short falloff so its rim reads sharp against the light sitting on it.
  void _paintShadow(Canvas canvas, Offset center, double horizon, double pull) {
    final r = horizon * (1 + 0.012 * math.sin(pull * 30));
    final edge = r * 1.1;
    canvas.drawCircle(
      center,
      edge,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black,
            Colors.black,
            Colors.black.withValues(alpha: 0),
          ],
          stops: [0, r / edge, 1],
        ).createShader(Rect.fromCircle(center: center, radius: edge)),
    );
  }

  /// The lensed emission wrapping the shadow: the disk's light bent into a
  /// near-circular ring that closes the top and bottom the flat plate cannot,
  /// beamed the same way — blinding on the left, an ember on the right.
  void _paintLensHalo(
    Canvas canvas,
    Offset center,
    double horizon,
    double pull,
    double spin,
  ) {
    final radius = horizon * 1.14;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (10 + 12 * pull) * scale
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * scale)
        ..shader = SweepGradient(
          colors: _diskSweep(0.5 * pull),
          transform: GradientRotation(spin * 0.3),
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (5 + 6 * pull) * scale
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * scale)
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.85 * pull),
            _shift(
              palette.ring.first,
              hue: -18,
              light: 0.2,
            ).withValues(alpha: 0.42 * pull),
            _shift(
              palette.ring.first,
              hue: -18,
              light: 0.2,
            ).withValues(alpha: 0),
            _shift(
              palette.ring.last,
              hue: 14,
              light: -0.06,
            ).withValues(alpha: 0.24 * pull),
          ],
          stops: const [0, 0.28, 0.62, 1],
        ).createShader(rect),
    );
  }

  /// The photon ring: a razor-thin, near-perfect circle of light grazing the
  /// horizon, with a fainter second image stacked just inside the way the
  /// higher-order rings pile up against the shadow's edge.
  void _paintPhotonRing(
    Canvas canvas,
    Offset center,
    double horizon,
    double pull,
    double local,
    double spin,
  ) {
    final radius = horizon * 1.02;
    final glow = 0.82 + 0.18 * math.sin(local * 2 * 2 * math.pi);
    final fx = ((local - 0.5) / 0.22).clamp(0.0, 1.0);
    final form =
        1 +
        2.8 * math.pow(fx, 0.3).toDouble() * math.pow(1 - fx, 1.7).toDouble();
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (10 + 10 * pull) * scale
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * scale)
        ..color = palette.ring.first.lighten(18).withValues(
          alpha: (0.36 * pull * form).clamp(0.0, 1.0),
        ),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2.4 + 2.4 * pull) * scale
        ..blendMode = BlendMode.plus
        ..shader = SweepGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95 * pull),
            palette.ring.first.lighten(16).withValues(alpha: 0.5 * pull),
            _shift(
              palette.ring.last,
              hue: 12,
              light: -0.04,
            ).withValues(alpha: 0.3 * pull),
            Colors.white.withValues(alpha: 0.95 * pull),
          ],
          stops: const [0, 0.5, 0.75, 1],
          transform: const GradientRotation(math.pi),
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.1 + 1.0 * pull) * scale
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withValues(
          alpha: ((0.8 + 0.2 * glow) * pull * form).clamp(0.0, 1.0),
        ),
    );
    canvas.drawCircle(
      center,
      radius * 0.965,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 * scale
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withValues(
          alpha: (0.4 * pull * form).clamp(0.0, 1.0),
        ),
    );
  }

  /// The two ansae where the disk turns edge-on: the approaching flank beamed
  /// to a blinding point with an anamorphic streak, the receding one a dim
  /// ember. This is the brightest thing on the board.
  void _paintDoppler(Canvas canvas, Offset center, double pull, double spin) {
    final ansa = _diskOuter(pull) * 0.96;
    final flick = 0.9 + 0.1 * math.sin(spin * 1.4);
    final near = center + Offset(-ansa, 0);
    final far = center + Offset(ansa, 0);
    _bloom(
      canvas,
      near,
      (18 + 16 * pull) * scale,
      _shift(
        palette.ring.first,
        hue: -22,
        light: 0.24,
      ).withValues(alpha: 0.55 * pull),
      5 * scale,
    );
    _bloom(
      canvas,
      near,
      (9 + 8 * pull) * scale,
      Colors.white.withValues(alpha: 0.95 * pull * flick),
      2 * scale,
    );
    final streak = Rect.fromCenter(
      center: near,
      width: ansa * 2.4,
      height: 4 * scale,
    );
    canvas.drawRect(
      streak,
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * scale)
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.72 * pull * flick),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(streak),
    );
    _bloom(
      canvas,
      far,
      (8 + 7 * pull) * scale,
      _shift(
        palette.ring.last,
        hue: 14,
        light: -0.05,
      ).withValues(alpha: 0.5 * pull),
      3 * scale,
    );
  }

  /// Space refusing to hold its shape at the rim: the red and blue channels
  /// split and wobble, the tell that light here is being bent, not lit.
  void _paintShimmer(
    Canvas canvas,
    Offset center,
    double horizon,
    double pull,
    double spin,
  ) {
    final radius = horizon * 1.08;
    final wob = math.sin(spin * 2) * 1.4 * scale * pull;
    final alpha = 0.24 * pull;
    canvas.drawCircle(
      center + Offset(wob, 0),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * scale
        ..blendMode = BlendMode.plus
        ..color = const Color(0xFF4488FF).withValues(alpha: alpha),
    );
    canvas.drawCircle(
      center - Offset(wob, 0),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * scale
        ..blendMode = BlendMode.plus
        ..color = const Color(0xFFFF3355).withValues(alpha: alpha),
    );
  }

  List<Color> _diskSweep(double alpha) => [
    for (final color in [...palette.ring, palette.ring.first])
      color.lighten(6).withValues(alpha: alpha),
  ];

  Color _shift(Color c, {double hue = 0, double light = 0, double sat = 0}) {
    final hsl = HSLColor.fromColor(c);
    final h = (hsl.hue + hue) % 360;
    return HSLColor.fromAHSL(
      hsl.alpha,
      h < 0 ? h + 360 : h,
      (hsl.saturation + sat).clamp(0.0, 1.0),
      (hsl.lightness + light).clamp(0.0, 1.0),
    ).toColor();
  }

  @override
  bool shouldRepaint(_HeroCollapsePainter old) =>
      old.progress != progress ||
      old.palette != palette ||
      old.scale != scale ||
      old.coreRadius != coreRadius ||
      old.fade != fade;
}

class _HeroSingularityPainter extends CustomPainter {
  _HeroSingularityPainter({
    required this.progress,
    required this.palette,
    required this.scale,
    required this.ringRadius,
    required this.coreRadius,
    required this.sparks,
    required this.spinPhase,
  });

  final double progress;
  final HeroPalette palette;
  final double scale;
  final double ringRadius;
  final double coreRadius;
  final List<_NovaSpark> sparks;

  final double spinPhase;

  double _span(double start, double length) =>
      ((progress - start) / length).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final reach = size.shortestSide / 2;
    _paintPinch(canvas, center);
    _paintDevour(canvas, center, reach);
    _paintBlast(canvas, center, reach);
    _paintPoint(canvas, center);
    _paintFlash(canvas, center, reach);
    _paintShock(canvas, center, reach);
    _paintQuanta(canvas, center, reach);
    _paintShells(canvas, center, reach);
  }

  void _paintPinch(Canvas canvas, Offset center) {
    final crush = _span(0, 0.28);
    if (crush >= 1) return;
    final eased = Curves.easeInCubic.transform(
      ((crush - 0.12) / 0.88).clamp(0.0, 1.0),
    );
    final horizon = coreRadius * 0.5 * (1 - eased);
    final spin = spinPhase + crush * 4 + crush * crush * 8;
    final glowUp = 0.5 + 1.1 * eased;

    final diskR = horizon * 1.7;
    if (diskR > 1) {
      final bed = Rect.fromCenter(
        center: center,
        width: diskR * 2,
        height: diskR * 2 * 0.55,
      );
      canvas.drawOval(
        bed,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (6 + 6 * (1 - crush)) * scale
          ..blendMode = BlendMode.plus
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * scale)
          ..shader = SweepGradient(
            colors: [
              for (final color in [...palette.ring, palette.ring.first])
                color.lighten(8).withValues(alpha: 0.45 * (1 - crush)),
            ],
            transform: GradientRotation(spin),
          ).createShader(bed),
      );
    }

    if (horizon > 0.6) {
      final edge = horizon * 1.12;
      canvas.drawCircle(
        center,
        edge,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.black,
              Colors.black,
              Colors.black.withValues(alpha: 0),
            ],
            stops: [0, horizon / edge, 1],
          ).createShader(Rect.fromCircle(center: center, radius: edge)),
      );
    }

    final ringR = math.max(horizon * 1.06, 1.0);
    canvas.drawCircle(
      center,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (7 + 9 * eased) * scale
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * scale)
        ..color = palette.ring.first
            .lighten(16)
            .withValues(alpha: (0.4 * glowUp).clamp(0.0, 1.0)),
    );
    canvas.drawCircle(
      center,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.4 + 1.4 * eased) * scale
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withValues(alpha: (0.7 * glowUp).clamp(0.0, 1.0)),
    );
  }

  void _paintPoint(Canvas canvas, Offset center) {
    final live = _span(0.2, 0.65);
    if (live <= 0 || live >= 1) return;
    final double strength;
    final double r;
    if (progress < _evaporatePeak) {
      final b = ((progress - 0.2) / (_evaporatePeak - 0.2)).clamp(0.0, 1.0);
      final throb = 0.5 + 0.5 * math.sin(b * 2.5 * 2 * math.pi);
      strength =
          (0.6 + 0.4 * throb) *
          (0.5 + 0.5 * Curves.easeInCubic.transform(b));
      r = coreRadius * (0.05 + 0.015 * throb);
    } else {
      final d = ((progress - _evaporatePeak) / 0.33).clamp(0.0, 1.0);
      strength = 1.4 * math.pow(1 - d, 2.2).toDouble();
      r = coreRadius * (0.06 + 0.14 * d);
    }
    _bloom(
      canvas,
      center,
      r * 4.5,
      palette.glow.lighten(16).withValues(alpha: (0.7 * strength).clamp(0.0, 1.0)),
      12 * scale,
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: strength.clamp(0.0, 1.0)),
            palette.glow
                .lighten(10)
                .withValues(alpha: (0.5 * strength).clamp(0.0, 1.0)),
            palette.glow.withValues(alpha: 0),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  void _paintDevour(Canvas canvas, Offset center, double reach) {
    final inhale = _span(0.42, 0.1);
    final purge = _span(_evaporatePeak, 0.34);
    final cover = inhale * math.pow(1 - purge, 1.6).toDouble();
    if (cover <= 0.01) return;
    final radius = lerpDouble(
      coreRadius * 0.3,
      reach * 1.6,
      Curves.easeIn.transform(inhale),
    )!;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.97 * cover),
            Colors.black.withValues(alpha: 0.97 * cover),
            Colors.black.withValues(alpha: 0),
          ],
          stops: const [0, 0.72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintBlast(Canvas canvas, Offset center, double reach) {
    final b = _span(_evaporatePeak, 0.55);
    if (b <= 0 || b >= 1) return;
    final e = Curves.easeOutCubic.transform(b);
    final radius = lerpDouble(coreRadius * 0.12, reach * 1.45, e)!;
    final fade = math.pow(1 - b, 2.0).toDouble();
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.55 * fade),
            palette.glow.lighten(12).withValues(alpha: 0.42 * fade),
            palette.ring.first.withValues(alpha: 0.16 * fade),
            palette.glow.withValues(alpha: 0),
          ],
          stops: const [0, 0.22, 0.6, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintFlash(Canvas canvas, Offset center, double reach) {
    final boil = _span(_evaporatePeak, 1 - _evaporatePeak);
    if (boil <= 0 || boil >= 1) return;
    final swell = Curves.easeOutCubic.transform(boil);
    final fade = math.pow(1 - boil, 1.8).toDouble();
    final radius = lerpDouble(coreRadius * 0.2, reach * 1.25, swell)!;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * scale)
        ..shader = RadialGradient(
          colors: [
            palette.glow.lighten(18).withValues(alpha: 0.6 * fade),
            palette.glow.lighten(6).withValues(alpha: 0.32 * fade),
            palette.glow.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintShock(Canvas canvas, Offset center, double reach) {
    final local = _span(_evaporatePeak, 0.42);
    if (local <= 0 || local >= 1) return;
    final eased = Curves.easeOutQuart.transform(local);
    final radius = lerpDouble(coreRadius * 0.4, reach * 1.35, eased)!;
    final fade = math.pow(1 - local, 1.5).toDouble();
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2 + 22 * (1 - eased)) * scale
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * scale)
        ..shader = SweepGradient(
          colors: [
            for (final color in [...palette.ring, palette.ring.first])
              color.lighten(14).withValues(alpha: 0.55 * fade),
          ],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1 + 3 * (1 - eased)) * scale
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withValues(alpha: 0.9 * fade),
    );
    final lead = _span(_evaporatePeak, 0.28);
    if (lead > 0 && lead < 1) {
      final le = Curves.easeOutQuart.transform(lead);
      final lr = lerpDouble(coreRadius * 0.4, reach * 1.5, le)!;
      canvas.drawCircle(
        center,
        lr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (0.8 + 2 * (1 - le)) * scale
          ..blendMode = BlendMode.plus
          ..color = Colors.white.withValues(
            alpha: 0.8 * math.pow(1 - lead, 1.6).toDouble(),
          ),
      );
    }
  }

  void _paintQuanta(Canvas canvas, Offset center, double reach) {
    for (final spark in sparks) {
      final local = _span(_evaporatePeak - 0.04 + spark.delay * 0.4, 0.7);
      if (local <= 0 || local >= 1) continue;
      final eased = Curves.easeOutCubic.transform(local);
      final distance =
          lerpDouble(coreRadius * 0.1, reach * spark.reach * 1.25, eased)!;
      final tail = (12 + 56 * (1 - eased)) * scale;
      final fade = math.pow(1 - local, 1.7).toDouble();
      final drift = spark.angle + math.sin(local * math.pi) * 0.2;
      final head = center + Offset.fromDirection(drift, distance);
      final back =
          center + Offset.fromDirection(drift, math.max(0, distance - tail));
      final tint = palette.ring[spark.tint % palette.ring.length];
      canvas.drawLine(
        back,
        head,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = spark.width * 0.8 * scale
          ..blendMode = BlendMode.plus
          ..shader = LinearGradient(
            colors: [
              tint.withValues(alpha: 0),
              tint.lighten(16).withValues(alpha: 0.8 * fade),
            ],
          ).createShader(Rect.fromPoints(back, head).inflate(1)),
      );
    }
  }

  void _paintShells(Canvas canvas, Offset center, double reach) {
    for (var i = 0; i < 3; i++) {
      final local = _span(_evaporatePeak + i * 0.07, 0.62);
      if (local <= 0 || local >= 1) continue;
      final eased = Curves.easeOutQuart.transform(local);
      final radius =
          lerpDouble(ringRadius * 0.5, reach * (1.2 - i * 0.16), eased)!;
      final fade = math.pow(1 - local, 2).toDouble();
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2 + 5 * (1 - eased)) * scale
          ..blendMode = BlendMode.plus
          ..shader = SweepGradient(
            colors: [
              for (final color in [...palette.ring, palette.ring.first])
                color.lighten(12).withValues(alpha: (0.46 - i * 0.12) * fade),
            ],
            transform: GradientRotation(-math.pi / 2 + eased * math.pi),
          ).createShader(rect),
      );
    }
  }

  void _bloom(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double sigma,
  ) {
    if (radius <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma)
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_HeroSingularityPainter old) =>
      old.progress != progress ||
      old.palette != palette ||
      old.scale != scale ||
      old.ringRadius != ringRadius ||
      old.coreRadius != coreRadius ||
      old.spinPhase != spinPhase ||
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
