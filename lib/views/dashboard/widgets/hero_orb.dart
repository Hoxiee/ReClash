import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the bloom reaches past the ring. Painted outside the widget's own
/// box so the orb keeps its layout footprint and its tap target.
const double _haloSpread = 34;

const _ringStroke = 10.0;
const _coreInset = 21.0;
const _brokenGap = 46 * math.pi / 180;
const _pausedDashes = 30;

class HeroOrb extends ConsumerStatefulWidget {
  const HeroOrb({
    super.key,
    this.size = 192,
    this.enabled = true,
    this.health = HeroHealth.unknown,
    this.activity = 0,
    this.onPhaseChanged,
  });

  final double size;
  final bool enabled;

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

  HeroOrbPhase _phase = HeroOrbPhase.off;
  HeroStatus _status = HeroStatus.off;
  HeroPalette? _palette;
  HeroPalette? _previousPalette;
  double _activityFrom = 0;
  bool _pending = false;
  Timer? _pendingTimeout;

  @override
  void initState() {
    super.initState();
    final isStart = ref.read(runTimeProvider) != null;
    final isPaused = isStart && ref.read(pausedProvider);
    _phase = isPaused
        ? HeroOrbPhase.paused
        : isStart
        ? HeroOrbPhase.on
        : HeroOrbPhase.off;
    _status = heroStatusOf(_phase, widget.health);
    _draw = AnimationController(
      vsync: this,
      value: _status.isLive && _phase != HeroOrbPhase.connecting ? 1 : 0,
      duration: const Duration(milliseconds: 620),
    );
    _breathe = AnimationController(vsync: this, duration: _breatheDuration);
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
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
      duration: const Duration(milliseconds: 420),
    );
    _settle = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 900),
    );
    ref.listenManual(runTimeProvider.select((value) => value != null), (
      prev,
      next,
    ) {
      if (!mounted) return;
      if (next) {
        _setPhase(
          ref.read(pausedProvider) ? HeroOrbPhase.paused : HeroOrbPhase.on,
        );
      } else if (_phase != HeroOrbPhase.off) {
        _setPhase(HeroOrbPhase.off);
      }
    }, fireImmediately: true);
    ref.listenManual(pausedProvider, (prev, next) {
      if (!mounted || ref.read(runTimeProvider) == null) return;
      _setPhase(next ? HeroOrbPhase.paused : HeroOrbPhase.on);
    }, fireImmediately: true);
  }

  @override
  void didUpdateWidget(HeroOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity) {
      _activityFrom = _activity;
      _settle.forward(from: 0);
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
    super.dispose();
  }

  Duration get _breatheDuration => switch (_status) {
    HeroStatus.broken => const Duration(milliseconds: 1250),
    HeroStatus.paused => const Duration(milliseconds: 4800),
    _ => const Duration(milliseconds: 3600),
  };

  double get _activity =>
      lerpDouble(
        _activityFrom,
        widget.activity,
        Curves.easeOut.transform(_settle.value),
      ) ??
      widget.activity;

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

  void _applyStatus(HeroStatus status) {
    final previous = _status;
    setState(() => _status = status);
    if (previous != status) {
      _previousPalette = _palette;
      _morph.forward(from: 0);
    }
    // The ring draws itself in only on the way into a live state; a status
    // change between two live states must not replay it.
    if (status.isLive && status != HeroStatus.connecting) {
      if (!previous.isLive || previous == HeroStatus.connecting) {
        _draw.forward();
        _ripple.forward(from: 0);
      }
    } else if (status == HeroStatus.off) {
      _draw.reverse();
    }

    _breathe.duration = _breatheDuration;
    if (status == HeroStatus.off || status == HeroStatus.connecting) {
      _breathe.stop();
    } else {
      _breathe.repeat(reverse: status != HeroStatus.broken);
    }
    if (status.flows) {
      if (!_flow.isAnimating) _flow.repeat();
      if (!_aurora.isAnimating) _aurora.repeat();
    } else {
      _flow.stop();
      if (status == HeroStatus.paused || status == HeroStatus.broken) {
        if (!_aurora.isAnimating) _aurora.repeat();
      } else {
        _aurora.stop();
      }
    }
    if (status == HeroStatus.connecting) {
      _sweep.repeat();
    } else {
      _sweep.stop();
    }
  }

  void _handleTap() {
    if (!widget.enabled || _status == HeroStatus.connecting) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      HapticFeedback.mediumImpact();
    }
    if (_phase == HeroOrbPhase.paused) {
      ref.read(commonActionProvider.notifier).togglePaused();
      return;
    }
    if (_phase == HeroOrbPhase.on) {
      _setPhase(HeroOrbPhase.off);
      ref.read(commonActionProvider.notifier).toggleRunning();
      return;
    }
    _beginConnecting(revertTo: HeroOrbPhase.off);
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

  /// Two spikes per cycle, so a broken link reads as a pulse rather than as the
  /// calm breath of a healthy one.
  double _heartbeat(double t) {
    double spike(double centre) =>
        math.exp(-math.pow((t - centre) * 11, 2).toDouble());
    return math.max(spike(0.08), 0.62 * spike(0.30)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final size = widget.size;
    final core = size - _coreInset * 2;
    final target = heroPaletteOf(context, _status);
    _palette = HeroPalette.lerp(
      _previousPalette ?? target,
      target,
      Curves.easeOutCubic.transform(_morph.value),
    );

    return Tooltip(
      message: switch (_status) {
        HeroStatus.paused => context.appLocalizations.resume,
        HeroStatus.off || HeroStatus.connecting =>
          context.appLocalizations.start,
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
            ]),
            builder: (context, _) {
              final palette = _palette!;
              final still = disableAnimations;
              final breathe = still ? 0.0 : _breathe.value;
              final pulse = _status == HeroStatus.broken
                  ? _heartbeat(breathe)
                  : Curves.easeInOut.transform(breathe);
              final activity = still ? 0.4 : _activity;
              final drawProgress = Curves.easeOutCubic.transform(_draw.value);
              final amplitude = switch (_status) {
                HeroStatus.secured => 0.022,
                HeroStatus.degraded => 0.014,
                HeroStatus.broken => 0.030,
                HeroStatus.paused => 0.008,
                _ => 0.0,
              };
              final breatheScale = 1 + amplitude * pulse;
              final pressScale = 1.0 - 0.035 * _press.value;
              final halo =
                  drawProgress *
                  (0.55 + 0.45 * pulse) *
                  (0.62 + 0.38 * activity);

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
                            child: CustomPaint(
                              size: Size.square(size),
                              painter: _HeroOrbPainter(
                                status: _status,
                                palette: palette,
                                drawProgress: drawProgress,
                                sweep: _sweep.value,
                                flow: still ? 0.12 : _flow.value,
                                aurora: still ? 0.2 : _aurora.value,
                                pulse: pulse,
                                activity: activity,
                                trackColor: colorScheme.outlineVariant.opacity60,
                                coreColor:
                                    colorScheme.surfaceContainerHigh.opacity60,
                                coreHighlight: colorScheme.surfaceBright,
                                coreBorder: colorScheme.outlineVariant.opacity60,
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
                                    child: Icon(
                                      _status == HeroStatus.paused
                                          ? Icons.play_arrow_rounded
                                          : Icons.power_settings_new_rounded,
                                      key: ValueKey(
                                        _status == HeroStatus.paused,
                                      ),
                                      size: core * 0.46,
                                      color: _status == HeroStatus.off
                                          ? colorScheme.onSurfaceVariant
                                          : palette.accent,
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
    required this.palette,
    required this.drawProgress,
    required this.sweep,
    required this.flow,
    required this.aurora,
    required this.pulse,
    required this.activity,
    required this.trackColor,
    required this.coreColor,
    required this.coreHighlight,
    required this.coreBorder,
  });

  final HeroStatus status;
  final HeroPalette palette;
  final double drawProgress;
  final double sweep;
  final double flow;
  final double aurora;
  final double pulse;
  final double activity;
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
      case HeroStatus.off:
        break;
      case HeroStatus.connecting:
        _paintComet(canvas, rect);
      case HeroStatus.secured:
      case HeroStatus.degraded:
        _paintFlowRing(canvas, center, rect, radius);
      case HeroStatus.broken:
        _paintBrokenRing(canvas, rect);
      case HeroStatus.paused:
        _paintPausedRing(canvas, rect);
    }
  }

  Paint _ringPaint(Rect rect, double rotation, {double? strokeWidth}) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth ?? _ringStroke
    ..strokeCap = StrokeCap.round
    ..shader = SweepGradient(
      colors: [...palette.ring, palette.ring.first],
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
            ..shader = RadialGradient(
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

  void _paintFlowRing(
    Canvas canvas,
    Offset center,
    Rect rect,
    double radius,
  ) {
    final speed = status == HeroStatus.degraded ? 0.45 : 1.0;
    final rotation = -math.pi / 2 + flow * speed * 2 * math.pi;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * drawProgress,
      false,
      _ringPaint(rect, rotation),
    );
    if (drawProgress < 0.98) return;
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

  void _paintComet(Canvas canvas, Rect rect) {
    const tail = 220 * math.pi / 180;
    final head = -math.pi / 2 + sweep * 2 * math.pi;
    const span = tail / (2 * math.pi);
    canvas.drawArc(
      rect,
      head - tail,
      tail,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [
            palette.ring[2].withValues(alpha: 0),
            palette.ring[1].withValues(alpha: 0.55),
            palette.ring[0],
          ],
          stops: [0, span * 0.7, span],
          transform: GradientRotation(head - tail),
        ).createShader(rect),
    );
  }

  void _paintBrokenRing(Canvas canvas, Rect rect) {
    canvas.drawArc(
      rect,
      -math.pi / 2 + _brokenGap / 2,
      (2 * math.pi - _brokenGap) * drawProgress,
      false,
      _ringPaint(rect, -math.pi / 2),
    );
  }

  void _paintPausedRing(Canvas canvas, Rect rect) {
    const step = 2 * math.pi / _pausedDashes;
    final paint = _ringPaint(
      rect,
      -math.pi / 2,
      strokeWidth: _ringStroke * 0.66,
    );
    for (var i = 0; i < _pausedDashes; i++) {
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * step,
        step * 0.52 * drawProgress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeroOrbPainter old) =>
      old.status != status ||
      old.palette.glow != palette.glow ||
      old.palette.ring.first != palette.ring.first ||
      old.drawProgress != drawProgress ||
      old.sweep != sweep ||
      old.flow != flow ||
      old.aurora != aurora ||
      old.pulse != pulse ||
      old.activity != activity ||
      old.trackColor != trackColor ||
      old.coreColor != coreColor ||
      old.coreBorder != coreBorder;
}
