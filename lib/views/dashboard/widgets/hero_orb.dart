import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class HeroOrb extends ConsumerStatefulWidget {
  const HeroOrb({
    super.key,
    this.size = 192,
    this.enabled = true,
    this.health = HeroHealth.unknown,
    this.activity = 0,
    this.serviceLogo,
    this.onPhaseChanged,
    this.onLongPress,
  });

  final double size;
  final bool enabled;

  final String? serviceLogo;

  /// Verdict on the live connection. Today it comes from the incumbent node's
  /// last delay measurement; the connection doctor will replace the source
  /// without touching this widget.
  final HeroHealth health;

  /// Throughput as `0..1` — brightens the ring and stirs the plasma.
  final double activity;

  /// Fired only on a genuine transition, so the listeners' immediate fire in
  /// `initState` can never rebuild an ancestor mid-build.
  final void Function(HeroOrbPhase phase)? onPhaseChanged;

  /// Opens the VPN / ByeDPI mode picker.
  final VoidCallback? onLongPress;

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

  /// `repeat` restarts at the lower bound, so these carry the phase across a
  /// retime rather than letting it snap.
  double _sweepPhase = 0;
  double _breathePhase = 0;

  HeroOrbPhase _phase = HeroOrbPhase.off;
  HeroStatus _status = HeroStatus.off;

  /// What the ring is unwinding out of, so switching off never cuts to empty.
  HeroStatus _exiting = HeroStatus.secured;

  double _handoff = 0;

  HeroOrbActivity _band = HeroOrbActivity.idle;
  HeroPalette? _palette;
  HeroPalette? _tintFrom;
  HeroPalette? _tintTo;
  double _activityFrom = 0;
  bool _pending = false;
  bool _still = false;
  Timer? _pendingTimeout;

  @override
  void initState() {
    super.initState();
    _phase = ref.read(heroLifecycleProvider);
    _status = heroStatusOf(_phase, widget.health);
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
      duration: const Duration(milliseconds: 12000),
    );
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
    _applyStatus(_status);
  }

  @override
  void didUpdateWidget(HeroOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity) {
      _activityFrom = _activity;
      _settle.forward(from: 0);
      final band = heroActivityBandOf(_band, widget.activity);
      if (band != _band) {
        _band = band;
        _runBreathing();
      }
    }
    if (oldWidget.health != widget.health) {
      _applyStatus(heroStatusOf(_phase, widget.health));
    }
  }

  @override
  void dispose() {
    _pendingTimeout?.cancel();
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
    HeroStatus.broken => const Duration(milliseconds: 1400),
    HeroStatus.paused => const Duration(milliseconds: 2400),
    _ =>
      _band == HeroOrbActivity.active
          ? const Duration(milliseconds: 3100)
          : const Duration(milliseconds: 3600),
  };

  Duration get _sweepDuration => switch (_status) {
    HeroStatus.checking => const Duration(milliseconds: 700),
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

  void _setPhase(HeroOrbPhase phase) {
    _pendingTimeout?.cancel();
    _pending = false;
    _adoptPhase(phase);
  }

  void _adoptPhase(HeroOrbPhase phase) {
    final changed = _phase != phase;
    _phase = phase;
    if (changed) widget.onPhaseChanged?.call(phase);
    _applyStatus(heroStatusOf(phase, widget.health));
  }

  void _runBreathing() {
    final wanted =
        !_still && _status != HeroStatus.off && _status != HeroStatus.offline;
    if (!wanted) {
      _breathe.stop();
      return;
    }
    if (_breathe.isAnimating && _breathe.duration == _breatheDuration) return;
    _breathePhase = _breatheValue;
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
    _sweepPhase = _sweepValue;
    _sweep.duration = _sweepDuration;
    _sweep.repeat();
  }

  void _applyStatus(HeroStatus status) {
    final previous = _status;
    setState(() => _status = status);
    if (previous != status) {
      _morph.forward(from: 0);
      if (status.isAlert) _onset.forward(from: 0);
      if (status != HeroStatus.off) _exiting = status;
      if (previous.isSweeping && !status.isSweeping) {
        _handoff = _sweepValue;
      } else if (!status.isSweeping) {
        _handoff = 0;
      }
    }
    // The ring draws itself in only on the way into a settled live state; a
    // status change between two live states must not replay it.
    if (status.isLive && !status.isTransitioning) {
      if (!previous.isLive || previous.isTransitioning) {
        _draw.forward();
        _ripple.forward(from: 0);
      }
    } else if (!status.isLive) {
      _draw.reverse();
    }

    _runBreathing();
    _runSweep();
    if (status.flows && !_still) {
      if (!_flow.isAnimating) _flow.repeat();
      if (!_aurora.isAnimating) _aurora.repeat();
    } else {
      _flow.stop();
      if (!_still && (status == HeroStatus.paused || status.isAlert)) {
        if (!_aurora.isAnimating) _aurora.repeat();
      } else {
        _aurora.stop();
      }
    }
  }

  void _handleTap() {
    if (!widget.enabled || _status.isTransitioning) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      HapticFeedback.mediumImpact();
    }
    _ripple.forward(from: 0);
    if (_phase == HeroOrbPhase.paused) {
      ref.read(commonActionProvider.notifier).togglePaused();
      return;
    }
    if (_status.isLive) {
      _setPhase(HeroOrbPhase.off);
      ref.read(commonActionProvider.notifier).toggleRunning();
      return;
    }
    _beginConnecting(revertTo: HeroOrbPhase.offline);
    ref.read(commonActionProvider.notifier).toggleRunning();
  }

  void _beginConnecting({required HeroOrbPhase revertTo}) {
    _pending = true;
    _adoptPhase(HeroOrbPhase.connecting);
    _pendingTimeout?.cancel();
    _pendingTimeout = Timer(const Duration(seconds: 15), () {
      if (mounted && _pending) {
        _setPhase(revertTo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final size = widget.size;
    final core = size - _coreInset * 2;
    // Retargeted here rather than on a status change alone, so a new theme or
    // seed colour travels the same way a status does.
    final target = heroPaletteOf(context, _status);
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

    return Tooltip(
      message: switch (_status) {
        HeroStatus.paused => context.appLocalizations.resume,
        HeroStatus.off ||
        HeroStatus.offline ||
        HeroStatus.checking ||
        HeroStatus.connecting ||
        HeroStatus.reconnecting => context.appLocalizations.start,
        _ => context.appLocalizations.stop,
      },
      child: RepaintBoundary(
        child: Listener(
          onPointerDown: (_) => _press.forward(),
          onPointerUp: (_) => _press.reverse(),
          onPointerCancel: (_) => _press.reverse(),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _draw,
              _breathe,
              _press,
              _sweep,
              _flow,
              _aurora,
              _ripple,
              _morph,
              _settle,
              _onset,
              _tint,
            ]),
            builder: (context, _) {
              final palette = _palette = HeroPalette.lerp(
                _tintFrom!,
                _tintTo!,
                Curves.easeOutCubic.transform(_tint.value),
              );
              final still = _still;
              // A cosine: a period change alters speed, never current depth.
              final pulse = still
                  ? 0.0
                  : 0.5 - 0.5 * math.cos(2 * math.pi * _breatheValue);
              final activity = still ? 0.4 : _activity;
              final drawProgress = Curves.easeOutCubic.transform(_draw.value);
              final morph = Curves.easeOutCubic.transform(_morph.value);
              final sweep = still ? 0.18 : _sweepValue;
              final amplitude = switch (_status) {
                HeroStatus.secured => 0.022,
                HeroStatus.degraded => 0.014,
                HeroStatus.paused => 0.008,
                _ => 0.0,
              };
              final breatheScale = 1 + amplitude * pulse;
              final pressScale = 1.0 - 0.035 * _press.value;
              final halo =
                  (_status.isSweeping ? morph : drawProgress) *
                  (0.55 + 0.45 * pulse) *
                  (0.62 + 0.38 * activity) *
                  switch (_status) {
                    HeroStatus.checking => 0.45,
                    HeroStatus.paused => 0.30,
                    _ => 1.0,
                  };

              return Transform.scale(
                scale: pressScale,
                child: Opacity(
                  opacity: widget.enabled ? 1 : 0.55,
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: -_haloSpread,
                          top: -_haloSpread,
                          width: size + _haloSpread * 2,
                          height: size + _haloSpread * 2,
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _HeroHaloPainter(
                                glow: palette.glow,
                                intensity: halo,
                                ripple: still ? 1 : _ripple.value,
                                orbRadius: size / 2,
                              ),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: breatheScale,
                          child: FocusableTap(
                            autofocus: true,
                            borderRadius: size / 2,
                            onTap: _handleTap,
                            onLongPress: widget.onLongPress,
                            child: CustomPaint(
                              size: Size.square(size),
                              painter: _HeroOrbPainter(
                                status: _status,
                                exiting: _exiting,
                                palette: palette,
                                drawProgress: drawProgress,
                                sweep: sweep,
                                handoff: _handoff,
                                flow: still ? 0.12 : _flow.value,
                                aurora: still ? 0.2 : _aurora.value,
                                pulse: pulse,
                                activity: activity,
                                morph: morph,
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
                              child: SizedBox(
                                width: core,
                                height: core,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 260),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.7,
                                            end: 1,
                                          ).animate(animation),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        ),
                                    child: _coreChild(
                                      core,
                                      palette.accent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData get _statusIcon => switch (_status) {
    HeroStatus.paused => Icons.play_arrow_rounded,
    HeroStatus.checking => Icons.wifi_tethering_rounded,
    HeroStatus.offline => Icons.wifi_off_rounded,
    _ => Icons.power_settings_new_rounded,
  };

  Widget _coreChild(double core, Color accent) {
    switch (heroCoreMarkOf(_status, widget.serviceLogo)) {
      case HeroCoreMark.serviceLogo:
        return SizedBox(
          key: const ValueKey('core-mark'),
          width: core * 0.5,
          height: core * 0.5,
          child: _mono(
            accent,
            ImageCacheWidget(
              src: widget.serviceLogo!,
              fit: BoxFit.contain,
              defaultWidget: _appMark(accent),
            ),
          ),
        );
      case HeroCoreMark.appMark:
        return SizedBox(
          key: const ValueKey('core-mark'),
          width: core * 0.5,
          height: core * 0.5,
          child: _appMark(accent),
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
    accent,
    Image.asset('assets/images/icon_variants/mark_mono.png', fit: BoxFit.contain),
  );

  Widget _mono(Color accent, Widget image) => ColorFiltered(
    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
    child: image,
  );
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

class _HeroOrbPainter extends CustomPainter {
  _HeroOrbPainter({
    required this.status,
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
    required this.onset,
    required this.trackColor,
    required this.coreColor,
    required this.coreHighlight,
    required this.coreBorder,
  });

  final HeroStatus status;
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
  final double onset;
  final Color trackColor;
  final Color coreColor;
  final Color coreHighlight;
  final Color coreBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _ringStroke / 2 - 1.5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final coreRadius = size.shortestSide / 2 - _coreInset;

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
        _paintNoSignalRing(canvas, rect, radius, morph);
      case HeroStatus.off:
        // Still unwinding, so the light fades instead of vanishing.
        if (drawProgress <= 0.004) break;
        switch (exiting) {
          case HeroStatus.paused:
            _paintPausedRing(canvas, rect, radius, 1);
          case HeroStatus.broken:
            _paintBrokenRing(canvas, rect, 1);
          case HeroStatus.offline:
            _paintNoSignalRing(canvas, rect, radius, 1);
          case _:
            _paintFlowRing(canvas, center, rect, radius, bloom: false);
        }
      case HeroStatus.checking:
        _paintComet(canvas, rect, tail: _checkingTail, stroke: _checkingStroke);
      case HeroStatus.connecting:
      case HeroStatus.reconnecting:
        _paintComet(canvas, rect, tail: _connectingTail, stroke: _ringStroke);
      case HeroStatus.secured:
      case HeroStatus.degraded:
        _paintFlowRing(canvas, center, rect, radius);
      case HeroStatus.broken:
        _paintBrokenRing(canvas, rect, morph);
      case HeroStatus.paused:
        _paintPausedRing(canvas, rect, radius, morph);
    }
  }

  Paint _ringPaint(
    Rect rect,
    double rotation, {
    double? strokeWidth,
    double alpha = 1,
  }) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth ?? _ringStroke
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

    if (status.isLive) {
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      final amplitude = (0.24 + 0.20 * activity) * (0.75 + 0.25 * pulse);
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
  }) {
    final speed =
        (status == HeroStatus.degraded ? 0.45 : 1.0) * (1 + 0.3 * activity);
    final rotation = -math.pi / 2 + flow * speed * 2 * math.pi;
    final start = -math.pi / 2 + handoff * 2 * math.pi;
    canvas.drawArc(
      rect,
      start,
      2 * math.pi * drawProgress,
      false,
      _ringPaint(rect, rotation),
    );
    if (!bloom || drawProgress < 0.98) return;
    // The gradient seam is the brightest point of the ring; a bloom pinned to
    // it is what makes the rotation legible instead of merely present.
    final head = center + Offset.fromDirection(rotation, radius);
    final headRadius = _ringStroke * (1.5 + 0.8 * activity);
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
  }) {
    final length = tail * (0.25 + 0.75 * morph);
    final head = -math.pi / 2 + sweep * 2 * math.pi;
    final span = length / (2 * math.pi);
    canvas.drawArc(
      rect,
      head - length,
      length,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * (0.6 + 0.4 * morph)
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [
            palette.ring[2].withValues(alpha: 0),
            palette.ring[1].withValues(alpha: 0.55 * morph),
            palette.ring[0].withValues(alpha: morph),
          ],
          stops: [0, span * 0.7, span],
          transform: GradientRotation(head - length),
        ).createShader(rect),
    );
  }

  /// `onset` makes the first dip the deepest.
  void _paintBrokenRing(Canvas canvas, Rect rect, double morph) {
    final gap = math.pi * morph;
    final dip = lerpDouble(0.20, 0.45, onset)!;
    canvas.drawArc(
      rect,
      -math.pi / 2 + gap / 2,
      (2 * math.pi - gap) * drawProgress,
      false,
      _ringPaint(rect, -math.pi / 2, alpha: lerpDouble(1, dip, pulse)!),
    );
  }

  void _paintNoSignalRing(Canvas canvas, Rect rect, double radius, morph) {
    final count = math.max(6, (2 * math.pi * radius / _noSignalPeriod).round());
    final step = 2 * math.pi / count;
    final fill = lerpDouble(1, _noSignalDash / _noSignalPeriod, morph);
    final paint = _ringPaint(
      rect,
      -math.pi / 2,
      strokeWidth: lerpDouble(_ringStroke, _pausedStroke, morph),
      alpha: lerpDouble(1, 0.55, morph)!,
    );
    for (var i = 0; i < count; i++) {
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * step,
        step * fill! * drawProgress,
        false,
        paint,
      );
    }
  }

  void _paintPausedRing(Canvas canvas, Rect rect, double radius, double morph) {
    final count = math.max(12, (2 * math.pi * radius / _pausedPeriod).round());
    final step = 2 * math.pi / count;
    final fill = lerpDouble(1, _pausedDash / _pausedPeriod, morph)!;
    final paint = _ringPaint(
      rect,
      -math.pi / 2,
      strokeWidth: lerpDouble(_ringStroke, _pausedStroke, morph),
      alpha: lerpDouble(1, 0.70, pulse)!,
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
      old.status != status ||
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
      old.onset != onset ||
      old.trackColor != trackColor ||
      old.coreColor != coreColor ||
      old.coreBorder != coreBorder;
}
