import 'dart:async';
import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<Color> heroRingColors = [
  Color(0xFF10EDF8),
  Color(0xFF2A8BFD),
  Color(0xFF6C58FC),
];

enum HeroOrbPhase { off, connecting, on, paused }

class HeroOrb extends ConsumerStatefulWidget {
  const HeroOrb({
    super.key,
    this.size = 192,
    this.enabled = true,
    this.onPhaseChanged,
  });

  final double size;
  final bool enabled;
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

  HeroOrbPhase _phase = HeroOrbPhase.off;
  bool _pending = false;
  Timer? _pendingTimeout;

  static const _ringStroke = 10.0;
  static const _coreInset = 21.0;

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
    _draw = AnimationController(
      vsync: this,
      value: isStart && !isPaused ? 1 : 0,
      duration: const Duration(milliseconds: 450),
    );
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
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
  void dispose() {
    _pendingTimeout?.cancel();
    _draw.dispose();
    _breathe.dispose();
    _press.dispose();
    _sweep.dispose();
    super.dispose();
  }

  void _setPhase(HeroOrbPhase phase) {
    setState(() {
      _phase = phase;
      _pending = false;
      _pendingTimeout?.cancel();
    });
    widget.onPhaseChanged?.call(phase);
    if (phase == HeroOrbPhase.on) {
      _draw.forward();
      _breathe.repeat(reverse: true);
      _sweep.stop();
    } else {
      _draw.reverse();
      _breathe.stop();
      if (phase == HeroOrbPhase.connecting) {
        _sweep.repeat();
      } else {
        _sweep.stop();
      }
    }
  }

  void _handleTap() {
    if (!widget.enabled || _phase == HeroOrbPhase.connecting) return;
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
    setState(() {
      _phase = HeroOrbPhase.connecting;
      _pending = true;
    });
    widget.onPhaseChanged?.call(HeroOrbPhase.connecting);
    _sweep.repeat();
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
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final size = widget.size;
    final core = size - _coreInset * 2;

    return Tooltip(
      message: switch (_phase) {
        HeroOrbPhase.paused => context.appLocalizations.resume,
        HeroOrbPhase.on => context.appLocalizations.stop,
        _ => context.appLocalizations.start,
      },
      child: RepaintBoundary(
        child: Listener(
          onPointerDown: (_) => _press.forward(),
          onPointerUp: (_) => _press.reverse(),
          onPointerCancel: (_) => _press.reverse(),
          child: FocusableTap(
            autofocus: true,
            borderRadius: size / 2,
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: Listenable.merge([_draw, _breathe, _press, _sweep]),
              builder: (_, _) {
                final breatheScale =
                    disableAnimations || _phase != HeroOrbPhase.on
                    ? 1.0
                    : 1.0 + 0.022 * Curves.easeInOut.transform(_breathe.value);
                final pressScale = 1.0 - 0.03 * _press.value;
                return Transform.scale(
                  scale: pressScale,
                  child: Opacity(
                    opacity: widget.enabled ? 1 : 0.55,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Transform.scale(
                        scale: breatheScale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_draw.value > 0)
                              IgnorePointer(
                                child: Opacity(
                                  opacity: Curves.easeOut.transform(
                                    _draw.value,
                                  ),
                                  child: Container(
                                    width: size + 60,
                                    height: size + 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          heroRingColors[1].withValues(
                                            alpha: 0.30,
                                          ),
                                          heroRingColors[2].withValues(
                                            alpha: 0.10,
                                          ),
                                          Colors.transparent,
                                        ],
                                        stops: const [0, 0.6, 0.75],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            CustomPaint(
                              size: Size.square(size),
                              painter: _HeroOrbPainter(
                                phase: _phase,
                                drawProgress: Curves.easeOut.transform(
                                  _draw.value,
                                ),
                                sweepAngle: _sweep.value * 2 * math.pi,
                                baseColor: colorScheme.outlineVariant
                                    .withValues(alpha: 0.6),
                                coreColor: colorScheme.surfaceContainerHigh
                                    .withValues(alpha: 0.6),
                                coreBorder: colorScheme.outlineVariant
                                    .withValues(alpha: 0.6),
                                stroke: _ringStroke,
                                coreInset: _coreInset,
                              ),
                              child: SizedBox(
                                width: core,
                                height: core,
                                child: Icon(
                                  _phase == HeroOrbPhase.paused
                                      ? Icons.play_arrow_rounded
                                      : Icons.power_settings_new_rounded,
                                  size: core * 0.46,
                                  color: _phase == HeroOrbPhase.on
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroOrbPainter extends CustomPainter {
  _HeroOrbPainter({
    required this.phase,
    required this.drawProgress,
    required this.sweepAngle,
    required this.baseColor,
    required this.coreColor,
    required this.coreBorder,
    required this.stroke,
    required this.coreInset,
  });

  final HeroOrbPhase phase;
  final double drawProgress;
  final double sweepAngle;
  final Color baseColor;
  final Color coreColor;
  final Color coreBorder;
  final double stroke;
  final double coreInset;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - stroke / 2 - 1.5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = baseColor,
    );

    Paint gradientPaint(double rotation) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: heroRingColors,
        transform: GradientRotation(rotation),
      ).createShader(rect);

    if (phase == HeroOrbPhase.on || drawProgress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * drawProgress,
        false,
        gradientPaint(-math.pi / 2),
      );
    }

    if (phase == HeroOrbPhase.paused) {
      canvas.drawCircle(center, radius, gradientPaint(0)..strokeWidth = 3);
    }

    if (phase == HeroOrbPhase.connecting) {
      canvas.drawArc(
        rect,
        -math.pi / 2 + sweepAngle,
        200 / 180 * math.pi,
        false,
        gradientPaint(-math.pi / 2 + sweepAngle),
      );
    }

    final coreRadius = size.shortestSide / 2 - coreInset;
    canvas.drawCircle(center, coreRadius, Paint()..color = coreColor);
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = coreBorder,
    );
  }

  @override
  bool shouldRepaint(_HeroOrbPainter old) =>
      old.phase != phase ||
      old.drawProgress != drawProgress ||
      old.sweepAngle != sweepAngle ||
      old.baseColor != baseColor ||
      old.coreColor != coreColor ||
      old.coreBorder != coreBorder;
}
