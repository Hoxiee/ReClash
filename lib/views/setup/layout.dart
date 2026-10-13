import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';
import 'package:reclash/widgets/widgets.dart';

import 'widgets.dart';

/// A single wizard phase. Persistence still rides the saved step index; this
/// enum only gives the index a name so navigation and the rail read as stages.
enum SetupStage { welcome, legal, subscription, finish }

String setupStageLabel(BuildContext context, SetupStage stage) {
  final l = context.appLocalizations;
  return switch (stage) {
    SetupStage.welcome => l.language,
    SetupStage.legal => l.setupLegalTitle,
    SetupStage.subscription => l.profile,
    SetupStage.finish => l.setupSummaryTitle,
  };
}

/// Frames the active step. Wide desktop windows get a step rail beside the
/// content; everywhere else keeps the centred column with dot progress on top.
class SetupShell extends StatelessWidget {
  const SetupShell({
    super.key,
    required this.stages,
    required this.index,
    required this.onJump,
    this.footer,
    required this.child,
  });

  /// Stages in display order; [index] points into this list.
  final List<SetupStage> stages;
  final int index;

  /// Jump to another stage by its index. Only called for stages the step list
  /// allows (the shell itself gates to already-visited stages).
  final ValueChanged<int> onJump;

  /// The active profile label, shown at the foot of the rail when present.
  final String? footer;
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
        if (!wide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: heroBoardMaxWidth),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: SetupProgress(
                      count: stages.length,
                      index: index,
                      label: l.setupStepProgress(index + 1, stages.length),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    child: _SetupRail(
                      stages: stages,
                      index: index,
                      onJump: onJump,
                      footer: footer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A compact sidebar card sized to its content: branding and the step list sit
/// at the top, the active profile closes it off, and the whole card rides the
/// vertical centre next to the step so neither pane strands empty space.
class _SetupRail extends StatelessWidget {
  const _SetupRail({
    required this.stages,
    required this.index,
    required this.onJump,
    this.footer,
  });

  final List<SetupStage> stages;
  final int index;
  final ValueChanged<int> onJump;
  final String? footer;

  @override
  Widget build(BuildContext context) {
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
              AppSpacing.md,
            ),
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                const GlyphIcon(AppGlyphs.vpn),
                Expanded(
                  child: Text(
                    appName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final (step, stage) in stages.indexed)
            _RailStep(
              label: setupStageLabel(context, stage),
              step: step,
              current: index,
              // Only visited stages are reachable; forward jumps would skip the
              // gating each step owns (consent, a chosen profile).
              onTap: step < index ? () => onJump(step) : null,
            ),
          if (footer case final footer?) ...[
            const Divider(height: 1),
            Padding(
              padding: AppInsets.lg,
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  const GlyphIcon(AppGlyphs.profiles, size: 20),
                  Expanded(
                    child: Text(
                      footer,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _RailStep extends StatelessWidget {
  const _RailStep({
    required this.label,
    required this.step,
    required this.current,
    this.onTap,
  });

  final String label;
  final int step;
  final int current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final done = step < current;
    final active = step == current;
    final glyph = done
        ? AppGlyphs.checkCircle
        : active
        ? AppGlyphs.arrowForward
        : AppGlyphs.circleOutline;
    final tone = active
        ? colorScheme.onSecondaryContainer
        : done
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final row = ListItem(
      // 8 here plus the pill's 8 margin keeps the active row's text on the same
      // left edge as the plain rows (which inset 16).
      padding: EdgeInsets.symmetric(horizontal: active ? AppSpacing.sm : 16),
      leading: GlyphIcon(glyph, color: tone),
      title: Text(
        label,
        style: TextStyle(
          color: tone,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        ),
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
