import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/views/tools/doctor_path.dart';
import 'package:reclash/widgets/widgets.dart';

/// Classic-dashboard sibling of the doctor journey: a full-width strip of the
/// five path stages, cross-fading between verdicts so the deck never jumps.
class ConnectionPath extends ConsumerWidget {
  const ConnectionPath({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final snapshot = ref.watch(connectionDoctorProvider);
    final answer = connectionDoctorAnswer(appLocalizations, snapshot);
    return DashboardInfoCard(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      icon: AppGlyphs.route,
      label: appLocalizations.doctorPathTitle,
      action: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const ConnectionDoctorView()),
      child: FadeThroughBox(
        child: KeyedSubtree(
          key: ValueKey(_signature(snapshot)),
          child: snapshot.supported
              ? _SupportedBody(snapshot: snapshot, answer: answer)
              : _VerdictLine(
                  text: answer.headline,
                  color: context.colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}

String _signature(DoctorSnapshot snapshot) {
  if (!snapshot.supported) return 'unsupported';
  if (!snapshot.isFresh) return 'stale:${snapshot.health.name}';
  final states = {for (final stage in snapshot.stages) stage.id: stage.state};
  return [
    snapshot.pathKind.name,
    snapshot.health.name,
    for (final id in doctorPathStageIds) '$id:${states[id]?.name ?? '_'}',
  ].join('|');
}

class _SupportedBody extends StatelessWidget {
  const _SupportedBody({required this.snapshot, required this.answer});

  final DoctorSnapshot snapshot;
  final DoctorAnswer answer;

  @override
  Widget build(BuildContext context) {
    final stages = resolveDoctorPathStages(context, snapshot, answer.blame);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MiniPathStrip(stages: stages),
        _VerdictLine(
          text: answer.headline,
          color: _toneColor(context, answer.tone),
        ),
      ],
    );
  }
}

Color _toneColor(BuildContext context, DoctorAnswerTone tone) {
  final colors = context.colorScheme;
  return switch (tone) {
    DoctorAnswerTone.bad => colors.error,
    DoctorAnswerTone.warning => colors.warning,
    DoctorAnswerTone.good || DoctorAnswerTone.working => colors.onSurface,
    DoctorAnswerTone.neutral => colors.onSurfaceVariant,
  };
}

class _VerdictLine extends StatelessWidget {
  const _VerdictLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TooltipText(
      text: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniPathStrip extends StatelessWidget {
  const _MiniPathStrip({required this.stages});

  final List<DoctorPathStage> stages;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < stages.length; index++) ...[
          _MiniPathNode(stage: stages[index]),
          if (index < stages.length - 1)
            Expanded(
              child: _MiniConnector(
                color: doctorPathVisual(
                  context,
                  _linkState(stages[index], stages[index + 1]),
                ).foreground,
              ),
            ),
        ],
      ],
    );
  }
}

DoctorStageState _linkState(DoctorPathStage current, DoctorPathStage next) {
  if (next.state == DoctorStageState.failed) return DoctorStageState.failed;
  if (next.state == DoctorStageState.checking) {
    return DoctorStageState.checking;
  }
  if (current.state == DoctorStageState.passed &&
      next.state == DoctorStageState.passed) {
    return DoctorStageState.passed;
  }
  return DoctorStageState.unknown;
}

class _MiniPathNode extends StatelessWidget {
  const _MiniPathNode({required this.stage});

  final DoctorPathStage stage;

  @override
  Widget build(BuildContext context) {
    final visual = doctorPathVisual(context, stage.state);
    final diameter = stage.culprit ? 22.0 : 18.0;
    return AppTooltip(
      message: '${stage.label} · ${doctorPathStateLabel(context, stage.state)}',
      child: Opacity(
        opacity: stage.dimmed ? 0.5 : 1.0,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: ShapeDecoration(
            color: visual.background,
            shape: AppShape.circle.copyWith(
              side: BorderSide(color: visual.foreground, width: 2),
            ),
          ),
          alignment: Alignment.center,
          child: GlyphIcon(
            visual.icon ?? stage.icon,
            color: visual.foreground,
            size: stage.culprit ? 14 : 12,
          ),
        ),
      ),
    );
  }
}

class _MiniConnector extends StatelessWidget {
  const _MiniConnector({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.full),
    );
  }
}
