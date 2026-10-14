import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/widgets/widgets.dart';

import 'doctor_path.dart';

class ConnectionDoctorPathMap extends StatefulWidget {
  const ConnectionDoctorPathMap({
    super.key,
    required this.snapshot,
    this.blame,
    this.reduceMotion = false,
  });

  final DoctorSnapshot snapshot;

  /// Path stage the verdict blames, used when the raw stages carry no explicit
  /// failure so the picture and the answer never disagree about the culprit.
  final String? blame;

  final bool reduceMotion;

  @override
  State<ConnectionDoctorPathMap> createState() =>
      _ConnectionDoctorPathMapState();
}

class _ConnectionDoctorPathMapState extends State<ConnectionDoctorPathMap>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 640),
  );

  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  // One animation per station, built once: a `CurvedAnimation` created in build
  // would register a fresh status listener on every rebuild.
  late final List<CurvedAnimation> _reveals = [
    for (final (index, _) in doctorPathStageIds.indexed)
      CurvedAnimation(parent: _intro, curve: _stageInterval(index)),
  ];

  @override
  void initState() {
    super.initState();
    _intro.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) _intro.value = 1;
  }

  @override
  void didUpdateWidget(covariant ConnectionDoctorPathMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature(oldWidget.snapshot) == _signature(widget.snapshot)) return;
    if (_still) {
      _intro.value = 1;
      return;
    }
    _intro.forward(from: 0);
  }

  bool get _still => context.disableAnimations || widget.reduceMotion;

  // Keyed on the shape of the path, not the per-stage states: the cascade must
  // not restart while an exam ticks.
  String _signature(DoctorSnapshot snapshot) {
    return '${snapshot.supported}|${snapshot.pathKind.name}';
  }

  @override
  void dispose() {
    for (final reveal in _reveals) {
      reveal.dispose();
    }
    _flow.dispose();
    _intro.dispose();
    super.dispose();
  }

  // Only `repeat`/`stop` here: assigning `value` would notify listeners from
  // inside build and mark already-built descendants dirty.
  void _syncFlow(bool wanted) {
    if (wanted == _flow.isAnimating) return;
    if (wanted) {
      _flow.repeat();
      return;
    }
    _flow.stop();
  }

  @override
  Widget build(BuildContext context) {
    final stages = resolveDoctorPathStages(
      context,
      widget.snapshot,
      widget.blame,
    );
    final summary = doctorPathSummary(context, widget.snapshot, stages);
    final timings = doctorStageTimings(widget.snapshot);
    final roundTrip = doctorPathRoundTripMs(widget.snapshot);
    final checking = stages.any(
      (stage) => stage.state == DoctorStageState.checking,
    );
    _syncFlow(checking && !_still);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.appLocalizations.doctorPathTitle,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (roundTrip > 0)
              FadeScaleBox(
                child: MetaChip(
                  key: ValueKey(roundTrip),
                  label: context.delayText(roundTrip),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        // The one-line reading of the whole path, so the picture is understood
        // before a single station is examined in detail.
        Text(
          summary,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final (index, stage) in stages.indexed) ...[
          _DoctorPathNode(
            key: ValueKey('node_${stage.id}'),
            stage: stage,
            millis: timings[stage.id] ?? 0,
            reveal: _reveals[index],
          ),
          if (index < stages.length - 1)
            _DoctorPathRail(
              key: ValueKey('rail_${stage.id}'),
              state: _connectorState(stage, stages[index + 1]),
              reveal: _reveals[index],
              // Without motion the rail stays a solid state colour: a frozen
              // dim rail with no travelling head reads as a dead segment.
              flow:
                  stages[index + 1].state == DoctorStageState.checking &&
                      !_still
                  ? _flow
                  : null,
            ),
        ],
      ],
    );
  }
}

Interval _stageInterval(int index) {
  final start = index * 0.62 / doctorPathStageIds.length;
  return Interval(start, math.min(1, start + 0.44));
}

final _markerScale = Tween<double>(begin: 0.82, end: 1);
final _bodyFade = Tween<double>(begin: 0.35, end: 1);
final _revealCurve = CurveTween(curve: Curves.easeOutCubic);

class _DoctorPathNode extends StatelessWidget {
  const _DoctorPathNode({
    super.key,
    required this.stage,
    required this.millis,
    required this.reveal,
  });

  final DoctorPathStage stage;
  final int millis;
  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) {
    final stateLabel = doctorPathStateLabel(context, stage.state);
    final visual = doctorPathVisual(context, stage.state);
    final eased = reveal.drive(_revealCurve);
    // Constant diameter keeps the vertical rail perfectly straight; the culprit
    // stands out through its glow and bold label, not a wider marker. The
    // marker reads as proof beneath the verdict, so it stays smaller than the
    // answer medallion above it.
    final marker = ScaleTransition(
      scale: eased.drive(_markerScale),
      child: _DoctorPathMarker(stage: stage, visual: visual),
    );
    return Semantics(
      key: ValueKey('doctor_path_${stage.id}'),
      label: _semanticsLabel(stateLabel),
      child: Opacity(
        opacity: stage.dimmed ? 0.5 : 1,
        child: FadeTransition(
          opacity: eased.drive(_bodyFade),
          child: SizedBox(
            width: double.infinity,
            child: _verticalBody(context, marker, stateLabel, visual.foreground),
          ),
        ),
      ),
    );
  }

  String _semanticsLabel(String stateLabel) {
    final base = '${stage.label}, $stateLabel';
    return stage.description.isEmpty ? base : '$base. ${stage.description}';
  }

  Widget _verticalBody(
    BuildContext context,
    Widget marker,
    String stateLabel,
    Color accent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        marker,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.label,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: stage.culprit
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (millis > 0 && !stage.dimmed) ...[
                      const SizedBox(width: AppSpacing.sm),
                      RollingDigits(
                        value: context.delayText(millis),
                        style: context.textTheme.labelSmall
                            ?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            )
                            .toJetBrainsMono,
                      ),
                    ],
                    // Below the break the dimmed marker and the "skipped" line
                    // already say the station was never reached; a state chip
                    // there only repeats that in a longer, weaker word.
                    if (!stage.dimmed) ...[
                      const SizedBox(width: AppSpacing.sm),
                      AppTag(
                        stateLabel,
                        foreground: accent,
                        background: accent.withValues(alpha: 0.14),
                      ),
                    ],
                  ],
                ),
                if (stage.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    stage.description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DoctorPathMarker extends StatelessWidget {
  const _DoctorPathMarker({required this.stage, required this.visual});

  final DoctorPathStage stage;
  final DoctorPathVisual visual;

  static const _diameter = 40.0;

  @override
  Widget build(BuildContext context) {
    final icon = visual.icon ?? stage.icon;
    return TweenAnimationBuilder<_StageTone>(
      tween: _StageToneTween(end: _toneOf(visual, stage)),
      duration: context.motionDuration(commonDuration),
      curve: Curves.easeOut,
      builder: (context, tone, child) => Container(
        width: _diameter,
        height: _diameter,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: tone.background,
          shape: AppShape.circle.copyWith(
            side: BorderSide(color: tone.foreground, width: tone.border),
          ),
          shadows: tone.glowAlpha <= 0
              ? null
              : [
                  BoxShadow(
                    color: tone.foreground.withValues(alpha: tone.glowAlpha),
                    blurRadius: tone.glowBlur,
                    spreadRadius: tone.glowSpread,
                  ),
                ],
        ),
        child: FadeScaleBox(
          child: GlyphIcon(
            icon,
            key: ValueKey(icon),
            color: tone.foreground,
            size: 20,
          ),
        ),
      ),
    );
  }
}

typedef _StageTone = ({
  Color foreground,
  Color background,
  double border,
  double glowAlpha,
  double glowBlur,
  double glowSpread,
});

class _StageToneTween extends Tween<_StageTone> {
  _StageToneTween({super.end});

  @override
  _StageTone lerp(double t) {
    final from = begin ?? end!;
    final to = end ?? begin!;
    return (
      foreground: Color.lerp(from.foreground, to.foreground, t)!,
      background: Color.lerp(from.background, to.background, t)!,
      border: lerpDouble(from.border, to.border, t)!,
      glowAlpha: lerpDouble(from.glowAlpha, to.glowAlpha, t)!,
      glowBlur: lerpDouble(from.glowBlur, to.glowBlur, t)!,
      glowSpread: lerpDouble(from.glowSpread, to.glowSpread, t)!,
    );
  }
}

_StageTone _toneOf(DoctorPathVisual visual, DoctorPathStage stage) {
  final glow = _glow(stage);
  return (
    foreground: visual.foreground,
    background: visual.background,
    border: stage.culprit ? 2.5 : 2,
    glowAlpha: glow?.alpha ?? 0,
    glowBlur: glow?.blur ?? 0,
    glowSpread: glow?.spread ?? 0,
  );
}

({double alpha, double blur, double spread})? _glow(DoctorPathStage stage) {
  if (stage.culprit) {
    return (alpha: 0.6, blur: 20, spread: 1);
  }
  return switch (stage.state) {
    DoctorStageState.checking => (alpha: 0.5, blur: 14, spread: 0),
    DoctorStageState.passed => (alpha: 0.32, blur: 11, spread: 0),
    _ => null,
  };
}

class _DoctorPathRail extends StatelessWidget {
  const _DoctorPathRail({
    super.key,
    required this.state,
    required this.reveal,
    required this.flow,
  });

  final DoctorStageState state;
  final Animation<double> reveal;
  final Animation<double>? flow;

  // Sits centred under the 40px marker (20 − half the 4px track) so the rail
  // runs straight down the column of stations.
  static const _width = 4.0;
  static const _height = 18.0;
  static const _inset = 18.0;

  @override
  Widget build(BuildContext context) {
    final color = doctorPathVisual(context, state).foreground;
    final track = context.colorScheme.surfaceContainerHighest;
    final flow = this.flow;
    return Padding(
      padding: const EdgeInsets.only(left: _inset),
      child: RepaintBoundary(
        child: SizedBox(
          width: _width,
          height: _height,
          child: AnimatedBuilder(
            animation: flow == null
                ? reveal
                : Listenable.merge([reveal, flow]),
            builder: (context, _) => CustomPaint(
              painter: _RailPainter(
                color: color,
                track: track,
                fill: math.max(0.02, Curves.easeOutCubic.transform(reveal.value)),
                flow: flow?.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.color,
    required this.track,
    required this.fill,
    required this.flow,
  });

  final Color color;
  final Color track;
  final double fill;

  /// Head position of the travelling light, or null when the path is settled.
  final double? flow;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.width / 2);
    final shape = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(shape, Paint()..color = track);
    final flow = this.flow;
    final filled = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height * fill.clamp(0, 1)),
      radius,
    );
    // A probe in flight leaves the rail dim so the travelling head reads as the
    // live part.
    canvas.drawRRect(
      filled,
      Paint()..color = flow == null ? color : color.withValues(alpha: 0.24),
    );
    if (flow == null) return;
    const tail = 10.0;
    final head = (size.height + tail) * flow - tail;
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRect(
      Rect.fromLTRB(0, head - tail, size.width, head),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0), color],
        ).createShader(Rect.fromLTRB(0, head - tail, size.width, head)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill ||
      oldDelegate.flow != flow;
}

DoctorStageState _connectorState(
  DoctorPathStage current,
  DoctorPathStage next,
) {
  if (next.state == DoctorStageState.failed) return DoctorStageState.failed;
  if (next.state == DoctorStageState.checking) {
    return DoctorStageState.checking;
  }
  if (current.state == DoctorStageState.passed &&
      next.state == DoctorStageState.passed) {
    return DoctorStageState.passed;
  }
  if (next.state == DoctorStageState.consequence) {
    return DoctorStageState.consequence;
  }
  return DoctorStageState.unknown;
}
