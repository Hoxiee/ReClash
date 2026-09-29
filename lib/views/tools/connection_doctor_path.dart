import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';

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
    if (oldWidget.blame != widget.blame ||
        _signature(oldWidget.snapshot) != _signature(widget.snapshot)) {
      _intro.forward(from: 0);
    }
  }

  // Restart the cascade only when the stages actually change, not on every
  // revision tick, so the reveal does not flicker under passive updates.
  String _signature(DoctorSnapshot snapshot) {
    if (!snapshot.isFresh) return 'stale';
    final states = {for (final stage in snapshot.stages) stage.id: stage.state};
    return [
      snapshot.pathKind.name,
      for (final id in doctorPathStageIds) '$id:${states[id]?.name ?? '_'}',
    ].join('|');
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.appLocalizations.doctorPathTitle,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedBuilder(
          animation: _intro,
          builder: (context, _) {
            final progress = context.disableAnimations ? 1.0 : _intro.value;
            return LayoutBuilder(
              builder: (context, constraints) {
                final vertical = constraints.maxWidth < 340 || textScale > 1.3;
                return vertical
                    ? _VerticalDoctorPath(stages: stages, progress: progress)
                    : _HorizontalDoctorPath(stages: stages, progress: progress);
              },
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

class _HorizontalDoctorPath extends StatelessWidget {
  const _HorizontalDoctorPath({required this.stages, required this.progress});

  final List<DoctorPathStage> stages;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < stages.length; index++) ...[
          Expanded(
            child: _DoctorPathNode(
              stage: stages[index],
              reveal: _staged(progress, index, stages.length),
            ),
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

class _VerticalDoctorPath extends StatelessWidget {
  const _VerticalDoctorPath({required this.stages, required this.progress});

  final List<DoctorPathStage> stages;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < stages.length; index++) ...[
          _DoctorPathNode(
            stage: stages[index],
            reveal: _staged(progress, index, stages.length),
            vertical: true,
          ),
          if (index < stages.length - 1)
            _DoctorPathConnector(
              state: _connectorState(stages[index], stages[index + 1]),
              fill: _staged(progress, index, stages.length),
              vertical: true,
            ),
        ],
      ],
    );
  }
}

class _DoctorPathNode extends StatelessWidget {
  const _DoctorPathNode({
    required this.stage,
    required this.reveal,
    this.vertical = false,
  });

  final DoctorPathStage stage;
  final double reveal;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final stateLabel = doctorPathStateLabel(context, stage.state);
    final visual = doctorPathVisual(context, stage.state);
    final diameter = stage.culprit ? 52.0 : 44.0;
    final glow = _glow(visual, stage);
    final marker = Transform.scale(
      scale: 0.82 + 0.18 * reveal,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: ShapeDecoration(
          color: visual.background,
          shape: AppShape.circle.copyWith(
            side: BorderSide(color: visual.foreground, width: 2),
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
          size: stage.culprit ? 26 : 22,
        ),
      ),
    );
    final content = Semantics(
      key: ValueKey('doctor_path_${stage.id}'),
      label: '${stage.label}, $stateLabel',
      child: Tooltip(
        message: stateLabel,
        child: Opacity(
          opacity: (stage.dimmed ? 0.5 : 1.0) * (0.35 + 0.65 * reveal),
          child: vertical
              ? _verticalBody(context, marker, stateLabel, visual.foreground)
              : _horizontalBody(context, marker),
        ),
      ),
    );
    return vertical
        ? SizedBox(width: double.infinity, child: content)
        : content;
  }

  Widget _horizontalBody(BuildContext context, Widget marker) {
    return Column(
      children: [
        marker,
        const SizedBox(height: AppSpacing.sm),
        Text(
          stage.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: stage.culprit ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _verticalBody(
    BuildContext context,
    Widget marker,
    String stateLabel,
    Color accent,
  ) {
    return Row(
      children: [
        marker,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stage.label, style: context.textTheme.bodyMedium),
              Text(
                stateLabel,
                style: context.textTheme.bodySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
  const _DoctorPathConnector({
    required this.state,
    required this.fill,
    this.vertical = false,
  });

  final DoctorStageState state;
  final double fill;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final color = doctorPathVisual(context, state).foreground;
    final track = context.colorScheme.surfaceContainerHighest;
    final progress = math.max(0.02, fill);
    if (vertical) {
      return Container(
        width: 4,
        height: 20,
        margin: const EdgeInsets.only(left: 20),
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(color: track, borderRadius: AppRadius.full),
        child: FractionallySizedBox(heightFactor: progress, child: _bar(color)),
      );
    }
    return Container(
      width: 14,
      height: 4,
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: track, borderRadius: AppRadius.full),
      child: FractionallySizedBox(widthFactor: progress, child: _bar(color)),
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
