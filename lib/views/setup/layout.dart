import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';

import 'coverage_choice.dart';
import 'widgets.dart';

/// A single wizard phase. Persistence still rides the saved step index; this
/// enum only gives the index a name so navigation and the receipt read as
/// stages.
enum SetupStage { welcome, legal, subscription, coverage, check }

/// How far the final step got. The receipt is the only place that reports it,
/// so the check step hands its outcome up instead of drawing a second summary.
enum SetupCheckOutcome { pending, running, passed, failed, saved }

String setupStageLabel(BuildContext context, SetupStage stage) {
  final l = context.appLocalizations;
  return switch (stage) {
    SetupStage.welcome => l.language,
    SetupStage.legal => l.setupStageConsent,
    SetupStage.subscription => l.profile,
    SetupStage.coverage => l.setupStageCoverage,
    SetupStage.check => l.setupStageCheck,
  };
}

/// Frames the active step. Wide desktop windows get the receipt beside the
/// content; everywhere else keeps the centred column with dot progress on top.
class SetupShell extends StatelessWidget {
  const SetupShell({
    super.key,
    required this.stages,
    required this.index,
    required this.onJump,
    required this.outcome,
    this.outcomeDetail,
    required this.child,
  });

  /// Stages in display order; [index] points into this list.
  final List<SetupStage> stages;
  final int index;

  /// Jump to another stage by its index. Only called for stages the step list
  /// allows (the shell itself gates to already-visited stages).
  final ValueChanged<int> onJump;

  final SetupCheckOutcome outcome;

  /// One line of evidence under the check row, such as the measured egress.
  final String? outcomeDetail;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final wide =
            constraints.maxWidth >= 960 * scale.clamp(1, 1.5) &&
            constraints.maxHeight >= 480;
        return SetupLayoutScope(
          wide: wide,
          aside: wide
              ? SetupReceipt(
                  stages: stages,
                  index: index,
                  onJump: onJump,
                  outcome: outcome,
                  outcomeDetail: outcomeDetail,
                )
              : null,
          banner: wide
              ? null
              : Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    bottom: AppSpacing.sm,
                  ),
                  child: SetupProgress(
                    count: stages.length,
                    index: index,
                    label: l.setupStepProgress(index + 1, stages.length),
                  ),
                ),
          child: child,
        );
      },
    );
  }
}

/// The running record of what the wizard has decided, with each value and where
/// it came from. It replaces both the step rail and the summary card: progress,
/// provenance and back-navigation in one pane.
class SetupReceipt extends ConsumerWidget {
  const SetupReceipt({
    super.key,
    required this.stages,
    required this.index,
    required this.onJump,
    required this.outcome,
    this.outcomeDetail,
  });

  final List<SetupStage> stages;
  final int index;
  final ValueChanged<int> onJump;
  final SetupCheckOutcome outcome;
  final String? outcomeDetail;

  _ReceiptEntry _entry(BuildContext context, WidgetRef ref, SetupStage stage) {
    final l = context.appLocalizations;
    return switch (stage) {
      SetupStage.welcome => _ReceiptEntry(
        value:
            getLocaleForString(
              ref.watch(appSettingProvider.select((state) => state.locale)),
            )?.nativeLabel ??
            l.setupSystemLanguage,
      ),
      SetupStage.legal => _ReceiptEntry(value: l.setupReceiptConsent),
      SetupStage.subscription => _profileEntry(context, ref),
      SetupStage.coverage => _ReceiptEntry(
        value: setupCoverageLabel(context, setupCoverageOf(ref)),
      ),
      SetupStage.check => _checkEntry(context),
    };
  }

  _ReceiptEntry _profileEntry(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    final profile = ref.watch(currentProfileProvider) ?? profiles.firstOrNull;
    if (profile == null) {
      return _ReceiptEntry(value: l.setupReceiptNoProfile);
    }
    return _ReceiptEntry(
      value: profile.label.takeFirstValid([l.profile]),
      why: profiles.length > 1 ? l.setupProfilesReady(profiles.length) : null,
    );
  }

  _ReceiptEntry _checkEntry(BuildContext context) {
    final l = context.appLocalizations;
    return switch (outcome) {
      SetupCheckOutcome.pending => _ReceiptEntry(
        value: l.setupReceiptCheckPending,
      ),
      SetupCheckOutcome.running => _ReceiptEntry(
        value: l.setupReceiptCheckRunning,
        why: outcomeDetail,
      ),
      SetupCheckOutcome.passed => _ReceiptEntry(
        value: l.setupReceiptCheckPassed,
        why: outcomeDetail,
      ),
      SetupCheckOutcome.failed => _ReceiptEntry(
        value: l.setupReceiptCheckFailed,
        why: outcomeDetail,
        alert: true,
      ),
      SetupCheckOutcome.saved => _ReceiptEntry(
        value: l.setupSavedTitle,
        why: outcomeDetail,
      ),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    return SetupCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: Text(
                    l.setupReceiptTitle,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  l.setupStepProgress(index + 1, stages.length),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          for (final (step, stage) in stages.indexed)
            _ReceiptRow(
              label: setupStageLabel(context, stage),
              entry: _entry(context, ref, stage),
              step: step,
              current: index,
              // Only visited stages are reachable; forward jumps would skip the
              // gating each step owns (consent, a chosen profile).
              onTap: step < index ? () => onJump(step) : null,
            ),
          if (index > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Text(
                l.setupReceiptHint,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ReceiptEntry {
  const _ReceiptEntry({required this.value, this.why, this.alert = false});

  final String value;
  final String? why;
  final bool alert;
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.entry,
    required this.step,
    required this.current,
    this.onTap,
  });

  final String label;
  final _ReceiptEntry entry;
  final int step;
  final int current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final done = step < current;
    final active = step == current;
    final shown = entry;
    final alert = shown.alert;
    final mark = alert
        ? GlyphIcon(AppGlyphs.warning, size: 18, color: colorScheme.error)
        : done
        ? GlyphIcon(AppGlyphs.checkCircle, size: 18, color: colorScheme.primary)
        : GlyphIcon(
            active ? AppGlyphs.arrowForward : AppGlyphs.circleOutline,
            size: 18,
            color: active
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          );
    final row = ListItem(
      padding: EdgeInsets.symmetric(horizontal: active ? AppSpacing.sm : 16),
      leading: mark,
      title: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shown.value,
            style: textTheme.bodyMedium?.copyWith(
              color: alert
                  ? colorScheme.error
                  : done || active
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (shown.why case final why?)
            Text(
              why,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
    if (!active) return row;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Material(
        color: colorScheme.secondaryContainer,
        shape: AppShape.all(AppCorner.md),
        clipBehavior: Clip.antiAlias,
        child: row,
      ),
    );
  }
}
