import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'capture.dart';
import 'stage.dart';

const _rowHeight = 48.0;
const _markSize = 22.0;

/// How far along the whole build is; the server check, the one step that
/// grows with the profile, takes most of the ring.
double reportOverallProgress(ReportProgress progress) {
  final sweep = progress.total > 0 ? progress.done / progress.total : 0.0;
  return switch (progress.phase) {
    ReportPhase.snapshot => 0.04,
    ReportPhase.path => 0.12,
    ReportPhase.sweep => 0.2 + 0.65 * sweep,
    ReportPhase.services => 0.88,
    ReportPhase.packing => 0.96,
  };
}

/// [eta] rounded up to 5 s steps, or to whole minutes past one.
String _etaText(AppLocalizations l, Duration eta) {
  final seconds = eta.inSeconds;
  if (seconds >= 60) return l.reportEtaMinutes((seconds + 59) ~/ 60);
  return l.reportEtaSeconds(((seconds + 4) ~/ 5).clamp(1, 12) * 5);
}

class ReportRecordingView extends StatelessWidget {
  const ReportRecordingView({
    super.key,
    required this.secondsLeft,
    required this.onFinish,
    required this.onCancel,
  });

  final int secondsLeft;
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final total = reportCaptureLength.inSeconds;
    return CommonScaffold(
      title: l.reportProblem,
      body: ReportStageLayout(
        hero: ReportHero(
          badge: Semantics(
            label: l.reportSecondsLeft(secondsLeft),
            excludeSemantics: true,
            child: ReportBadge(
              color: reportAlertColor(context),
              value: (total - secondsLeft + 1) / total,
              motion: const Duration(seconds: 1),
              curve: Curves.linear,
              child: Text(
                '$secondsLeft',
                key: const ValueKey('report-seconds'),
                style: reportFigureStyle(context, AppTextStyle.title1),
              ),
            ),
          ),
          title: l.reportRecording,
          subtitle: Text(l.reportRecordingHint),
        ),
        primary: FilledButton(
          key: const ValueKey('report-finish'),
          onPressed: onFinish,
          child: Text(l.reportFinishRecording),
        ),
        secondary: TextButton(onPressed: onCancel, child: Text(l.cancel)),
      ),
    );
  }
}

enum _StepState { pending, active, done, skipped }

class ReportBuildingView extends StatelessWidget {
  const ReportBuildingView({
    super.key,
    required this.progress,
    required this.recorded,
    required this.sweepStopped,
    required this.eta,
    required this.onSkip,
    required this.onCancel,
  });

  final ReportProgress progress;
  final bool recorded;
  final bool sweepStopped;
  final Duration? eta;
  final VoidCallback onSkip;
  final VoidCallback onCancel;

  _StepState _stateOf(ReportPhase phase) {
    final current = progress.phase.index;
    if (phase == ReportPhase.sweep && sweepStopped && current >= phase.index) {
      return _StepState.skipped;
    }
    if (phase.index < current) return _StepState.done;
    if (phase.index == current) return _StepState.active;
    return _StepState.pending;
  }

  String _label(AppLocalizations l, ReportPhase phase) => switch (phase) {
    ReportPhase.snapshot => l.reportPhaseSnapshot,
    ReportPhase.path => l.reportPhasePath,
    ReportPhase.sweep => l.reportPhaseServers,
    ReportPhase.services => l.reportPhaseServices,
    ReportPhase.packing => l.reportPhasePacking,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final overall = reportOverallProgress(progress);
    final percent = NumberFormat.percentPattern(
      Localizations.localeOf(context).toString(),
    ).format(overall);
    final sweeping =
        progress.phase == ReportPhase.sweep &&
        progress.total > 0 &&
        !sweepStopped;
    final eta = this.eta;
    final level = context.raisedSurfaceLevel;
    return CommonScaffold(
      title: l.reportProblem,
      body: ReportStageLayout(
        hero: ReportHero(
          badge: Semantics(
            label: percent,
            excludeSemantics: true,
            child: ReportBadge(
              color: colorScheme.primary,
              value: overall,
              child: Text(
                percent,
                style: reportFigureStyle(context, AppTextStyle.title3),
              ),
            ),
          ),
          title: l.reportBuildingTitle,
          subtitle: Text(
            eta == null ? l.reportBuildingHint : _etaText(l, eta),
            key: const ValueKey('report-eta'),
          ),
        ),
        body: [
          DecoratedBox(
            decoration: ShapeDecoration(
              color: level.colorOf(colorScheme),
              shape: AppShape.xl,
            ),
            child: SurfaceScope(
              level: level,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    if (recorded)
                      _StepRow(
                        state: _StepState.done,
                        label: l.reportPhaseRecorded,
                      ),
                    for (final phase in ReportPhase.values)
                      _StepRow(
                        key: ValueKey(('report-step', phase)),
                        state: _stateOf(phase),
                        label: _label(l, phase),
                        trailing: phase == ReportPhase.sweep
                            ? switch (_stateOf(phase)) {
                                _StepState.skipped => _StepNote(
                                  l.reportPhaseSkipped,
                                ),
                                _StepState.active when sweeping => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 10,
                                  children: [
                                    _StepNote(
                                      l.reportCount(
                                        progress.done,
                                        progress.total,
                                      ),
                                      key: const ValueKey('report-sweep-count'),
                                    ),
                                    TonalButton(
                                      key: const ValueKey('report-skip'),
                                      size: TonalButtonSize.compact,
                                      label: l.reportSkipServers,
                                      onPressed: onSkip,
                                    ),
                                  ],
                                ),
                                _ => null,
                              }
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
        secondary: TextButton(
          key: const ValueKey('report-cancel'),
          onPressed: onCancel,
          child: Text(l.cancel),
        ),
      ),
    );
  }
}

class _StepNote extends StatelessWidget {
  const _StepNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyle.subheadline
          .of(context)
          .copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    super.key,
    required this.state,
    required this.label,
    this.trailing,
  });

  final _StepState state;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final trailing = this.trailing;
    final muted = state == _StepState.pending;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          spacing: 12,
          children: [
            SizedBox.square(
              dimension: _markSize,
              child: AnimatedSwitcher(
                duration: context.motionDuration(midDuration),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(Tween(begin: 0.6, end: 1)),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(state),
                  child: switch (state) {
                    _StepState.done => GlyphIcon(
                      AppGlyphs.checkCircle,
                      size: _markSize,
                      color: colorScheme.success,
                    ),
                    _StepState.active => const CommonCircleLoading(
                      size: _markSize - 2,
                    ),
                    _StepState.skipped => GlyphIcon(
                      AppGlyphs.skip,
                      size: _markSize,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    _StepState.pending => Center(
                      child: SizedBox.square(
                        dimension: 8,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.35,
                            ),
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                    ),
                  },
                ),
              ),
            ),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: context.motionDuration(midDuration),
                style: AppTextStyle.body
                    .of(context, emphasized: state == _StepState.active)
                    .copyWith(
                      color: muted
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                child: Text(label),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
