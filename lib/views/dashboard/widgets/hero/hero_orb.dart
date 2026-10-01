import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/milestones/finding_events.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_overlay.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_spark.dart';
import 'package:reclash/widgets/widgets.dart';

part 'hero_orb_painters.dart';
part 'hero_orb_cinematic.dart';

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

const _singularityDuration = Duration(milliseconds: 3200);
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
    with TickerProviderStateMixin, _HeroCinematic {
  late final AnimationController _draw;
  late final AnimationController _breathe;
  @override
  late final AnimationController _press;
  late final AnimationController _sweep;
  late final AnimationController _flow;
  late final AnimationController _aurora;
  @override
  late final AnimationController _ripple;
  late final AnimationController _morph;
  late final AnimationController _settle;

  /// 0 = fully live, 1 = at rest. Idle folds the ambient loops through this
  /// instead of cutting them, so the orb eases to its calm pose; the loops keep
  /// running until it reaches 1 so no phase snaps mid-blend.
  late final AnimationController _stillness;
  @override
  late final AnimationController _tint;

  /// Decays over a new fault's first cycle, making its opening pulse deepest.
  late final AnimationController _onset;

  Timer? _oscilloscopeHold;
  Timer? _oscilloscopeTimer;
  @override
  final Set<int> _pointers = {};
  bool _oscilloscope = false;
  @override
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
  @override
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
  @override
  bool _still = false;
  bool _motionDisabled = false;
  bool _uiIdle = false;
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
    _stillness = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _freezeAmbientLoops();
    });
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
    _initCinematic();
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
    _uiIdle = ref.read(uiIdleProvider);
    ref.listenManual(uiIdleProvider, (_, next) {
      if (!mounted || next == _uiIdle) return;
      _uiIdle = next;
      _refreshStill();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Off-screen (pager/inactive route) is as motionless as reduce-motion: both
    // fold into `_still` so the ambient loops stop instead of burning frames.
    _motionDisabled =
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ||
        !PageActivityScope.isActiveOf(context);
    _refreshStill();
  }

  // A settled UI counts as still on mobile, but only outside sweeping states:
  // freezing a connecting/checking orb the user is waiting on reads as a hang.
  bool _computeStill(HeroStatus status) =>
      _motionDisabled || (_uiIdle && !status.isSweeping);

  // Still is the intent; settled-still is the arrival. The ambient loops keep
  // turning through the wind-down so their phases stay continuous, and only
  // once the blend lands do they park.
  bool get _settledStill => _still && _stillness.isCompleted;

  double get _stillFactor => Curves.easeInOut.transform(_stillness.value);

  void _syncStillness() {
    final instant = _motionDisabled;
    if (_still) {
      if (instant) {
        _stillness.value = 1;
        _freezeAmbientLoops();
      } else if (_stillness.status != AnimationStatus.completed &&
          _stillness.status != AnimationStatus.forward) {
        _stillness.forward();
      }
    } else {
      if (instant) {
        _stillness.value = 0;
      } else if (_stillness.status != AnimationStatus.dismissed &&
          _stillness.status != AnimationStatus.reverse) {
        _stillness.reverse();
      }
    }
  }

  void _freezeAmbientLoops() {
    if (!_still) return;
    _breathe.stop();
    _stopFlow();
    _aurora.stop();
  }

  @override
  void _refreshStill() {
    final still = _computeStill(_status);
    if (still == _still) return;
    // Defer the freeze until the egg cinematic ends; a controller settle re-runs
    // this once nothing is in flight.
    if (still && _cinematicActive) return;
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
    _disposeCinematic();
    _connectingHold?.cancel();
    _oscilloscopeHold?.cancel();
    _oscilloscopeTimer?.cancel();
    _multiTouchRelease?.cancel();
    _draw.dispose();
    _breathe.dispose();
    _press.dispose();
    _sweep.dispose();
    _flow.dispose();
    _aurora.dispose();
    _ripple.dispose();
    _morph.dispose();
    _settle.dispose();
    _stillness.dispose();
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
    if (_settledStill || !_status.flows) return;
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
  @override
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
    _hideCinematic();
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
        !_settledStill &&
        _status != HeroStatus.off &&
        _status != HeroStatus.offline;
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
    final wanted = _status.isSweeping && !_settledStill;
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
    // Sweeping states pull the orb out of an idle freeze, so recompute against
    // the incoming status before any loop reads `_still`. A running egg keeps
    // the orb awake so a status change cannot park it mid-cinematic.
    _still = _computeStill(status) && !_cinematicActive;
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
      if (_settledStill) {
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
        if (_settledStill) {
          _draw.value = 1;
          _ripple.value = 1;
        } else {
          _draw.forward();
          _ripple.forward(from: 0);
        }
      }
    } else if (!status.isLive) {
      if (_settledStill) {
        _draw.value = 0;
      } else {
        _draw.reverse();
      }
    }

    _syncStillness();
    _runBreathing();
    _runSweep();
    if (status.flows && !_settledStill) {
      _startFlow();
      if (!_aurora.isAnimating) _aurora.repeat();
    } else {
      _stopFlow();
      if (!_settledStill &&
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
    final orbOpacity = ref.watch(
      themeSettingProvider.select((value) => value.wallpaper.orbOpacity),
    );
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
                          _stillness,
                          _tint,
                          _nova,
                          _collapse,
                          _singularity,
                          _regrow,
                        ]),
                        builder: (context, _) {
                          // A cosine: a period change alters speed, never
                          // current depth.
                          final still = _stillFactor;
                          final pulse =
                              (0.5 -
                                  0.5 * math.cos(2 * math.pi * _breatheValue)) *
                              (1 - still);
                          final activity = lerpDouble(_activity, 0.4, still)!;
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
                              ripple: lerpDouble(_ripple.value, 1, still)!,
                              orbRadius: size / 2,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: Listenable.merge([_breathe, _stillness]),
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
                            _stillness,
                            _onset,
                            _tint,
                          ]),
                          child: coreChild,
                          builder: (context, child) {
                            final palette = _palette = _currentPalette;
                            final still = _stillFactor;
                            final pulse =
                                (0.5 -
                                    0.5 *
                                        math.cos(
                                          2 * math.pi * _breatheValue,
                                        )) *
                                (1 - still);
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
                                sweep: lerpDouble(_sweepValue, 0.18, still)!,
                                handoff: _handoff,
                                flow: _flowPhase,
                                aurora: _aurora.value,
                                pulse: pulse,
                                activity: lerpDouble(_activity, 0.4, still)!,
                                morph: Curves.easeOutCubic.transform(
                                  _morph.value,
                                ),
                                transitionProgress: Curves.easeOutCubic
                                    .transform(_morph.value),
                                onset: lerpDouble(
                                  Curves.easeOut.transform(_onset.value),
                                  1,
                                  still,
                                )!,
                                trackColor:
                                    colorScheme.outlineVariant.opacity60,
                                coreColor: colorScheme.surfaceContainerHigh
                                    .withValues(alpha: orbOpacity),
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
                      final pulse =
                          (0.5 - 0.5 * math.cos(2 * math.pi * _breatheValue)) *
                          (1 - _stillFactor);
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
                          // In-tree, not in an overlay: the blast must share the
                          // orb's exact geometry or its ring drifts off the orb's
                          // own. The elastic flow paints this head last, so it
                          // still sits above the cards.
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
    HeroStatus.broken =>
      ref.watch(
            runRequestStateProvider.select(
              (state) => state.fault == RunRequestFault.configInvalid,
            ),
          )
          ? context.appLocalizations.heroConfigInvalidTitle
          : context.appLocalizations.heroLinkBroken,
    HeroStatus.blocked => context.appLocalizations.heroBlockedTitle,
    HeroStatus.paused => context.appLocalizations.heroPaused,
  };

  Glyph get _statusIcon => switch (_status) {
    HeroStatus.paused => AppGlyphs.play,
    HeroStatus.checking || HeroStatus.diagnosing => AppGlyphs.tethering,
    HeroStatus.subscriptionExpired => AppGlyphs.calendar,
    HeroStatus.offline => AppGlyphs.wifiOff,
    _ => AppGlyphs.power,
  };

  static const _coreMarkExtent = 0.54;
  static const _appMarkInset = 0.0216;

  Widget _coreChild(double core, Color accent) {
    if (widget.variant == HeroOrbVariant.byedpi && _status.flows) {
      return GlyphIcon(
        AppGlyphs.blur,
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
        return GlyphIcon(
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
