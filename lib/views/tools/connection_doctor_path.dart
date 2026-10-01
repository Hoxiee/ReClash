import 'dart:math' as math;

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
  });

  final DoctorSnapshot snapshot;

  /// Path stage the verdict blames, used when the raw stages carry no explicit
  /// failure so the picture and the answer never disagree about the culprit.
  final String? blame;

  @override
  State<ConnectionDoctorPathMap> createState() =>
      _ConnectionDoctorPathMapState();
}

class _ConnectionDoctorPathMapState extends State<ConnectionDoctorPathMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 640),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant ConnectionDoctorPathMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature(oldWidget.snapshot) != _signature(widget.snapshot)) {
      _intro.forward(from: 0);
    }
  }

  // The reveal cascade is a first-impression flourish, so it plays once for a
  // given shape of path and never again while an exam ticks. Keying it on the
  // per-stage states made every check restart the whole animation — that was
  // the picture "jumping" on each probe. Individual stations now swap colour
  // and icon in place instead, with no layout move.
  String _signature(DoctorSnapshot snapshot) {
    return '${snapshot.supported}|${snapshot.isFresh}|${snapshot.pathKind.name}';
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
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
            if (roundTrip > 0) MetaChip(label: context.delayText(roundTrip)),
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
        AnimatedBuilder(
          animation: _intro,
          builder: (context, _) {
            final progress = context.disableAnimations ? 1.0 : _intro.value;
            // The journey is always vertical: the stations read as a top-down
            // route at any width, so nothing cramps on a narrow screen.
            return _VerticalDoctorPath(
              stages: stages,
              timings: timings,
              progress: progress,
            );
          },
        ),
      ],
    );
  }
}

double _staged(double progress, int index, int count) {
  final span = count > 1 ? 0.62 / count : 0.0;
  final start = index * span;
  final local = ((progress - start) / 0.44).clamp(0.0, 1.0);
  return Curves.easeOutCubic.transform(local);
}

class _VerticalDoctorPath extends StatelessWidget {
  const _VerticalDoctorPath({
    required this.stages,
    required this.timings,
    required this.progress,
  });

  final List<DoctorPathStage> stages;
  final Map<String, int> timings;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Left-align so the narrow connector rail keeps its 18px offset under the
      // marker column; a centering Column floats it into the middle instead.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < stages.length; index++) ...[
          _DoctorPathNode(
            stage: stages[index],
            millis: timings[stages[index].id] ?? 0,
            reveal: _staged(progress, index, stages.length),
          ),
          if (index < stages.length - 1)
            _DoctorPathConnector(
              state: _connectorState(stages[index], stages[index + 1]),
              fill: _staged(progress, index, stages.length),
            ),
        ],
      ],
    );
  }
}

class _DoctorPathNode extends StatelessWidget {
  const _DoctorPathNode({
    required this.stage,
    required this.millis,
    required this.reveal,
  });

  final DoctorPathStage stage;
  final int millis;
  final double reveal;

  @override
  Widget build(BuildContext context) {
    final stateLabel = doctorPathStateLabel(context, stage.state);
    final visual = doctorPathVisual(context, stage.state);
    // Constant diameter keeps the vertical rail perfectly straight; the culprit
    // stands out through its glow and bold label, not a wider marker. The
    // marker reads as proof beneath the verdict, so it stays smaller than the
    // answer medallion above it.
    const diameter = 40.0;
    final glow = _glow(visual, stage);
    final marker = Transform.scale(
      scale: 0.82 + 0.18 * reveal,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: ShapeDecoration(
          color: visual.background,
          shape: AppShape.circle.copyWith(
            side: BorderSide(
              color: visual.foreground,
              width: stage.culprit ? 2.5 : 2,
            ),
          ),
          shadows: glow == null
              ? null
              : [
                  BoxShadow(
                    color: glow.color.withValues(alpha: glow.alpha * reveal),
                    blurRadius: glow.blur,
                    spreadRadius: glow.spread,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: GlyphIcon(
          visual.icon ?? stage.icon,
          color: visual.foreground,
          size: 20,
        ),
      ),
    );
    return Semantics(
      key: ValueKey('doctor_path_${stage.id}'),
      label: _semanticsLabel(stateLabel),
      child: Opacity(
        opacity: (stage.dimmed ? 0.5 : 1.0) * (0.35 + 0.65 * reveal),
        child: SizedBox(
          width: double.infinity,
          child: _verticalBody(context, marker, stateLabel, visual.foreground),
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
                      Text(
                        context.delayText(millis),
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

({Color color, double alpha, double blur, double spread})? _glow(
  DoctorPathVisual visual,
  DoctorPathStage stage,
) {
  if (stage.culprit) {
    return (color: visual.foreground, alpha: 0.6, blur: 20, spread: 1);
  }
  return switch (stage.state) {
    DoctorStageState.checking => (
      color: visual.foreground,
      alpha: 0.5,
      blur: 14,
      spread: 0,
    ),
    DoctorStageState.passed => (
      color: visual.foreground,
      alpha: 0.32,
      blur: 11,
      spread: 0,
    ),
    _ => null,
  };
}

class _DoctorPathConnector extends StatelessWidget {
  const _DoctorPathConnector({required this.state, required this.fill});

  final DoctorStageState state;
  final double fill;

  @override
  Widget build(BuildContext context) {
    final color = doctorPathVisual(context, state).foreground;
    final track = context.colorScheme.surfaceContainerHighest;
    final progress = math.max(0.02, fill);
    // Sits centred under the 40px marker (20 − half the 4px track) so the rail
    // runs straight down the column of stations.
    return Container(
      width: 4,
      height: 18,
      margin: const EdgeInsets.only(left: 18),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(color: track, borderRadius: AppRadius.full),
      child: FractionallySizedBox(heightFactor: progress, child: _bar(color)),
    );
  }

  Widget _bar(Color color) => DecoratedBox(
    decoration: BoxDecoration(color: color, borderRadius: AppRadius.full),
  );
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
