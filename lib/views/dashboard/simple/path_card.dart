import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/doctor/path.dart';

/// The connection path as a chain of step badges, one line once it passes.
class SimplePathCard extends ConsumerStatefulWidget {
  const SimplePathCard({super.key});

  @override
  ConsumerState<SimplePathCard> createState() => _SimplePathCardState();
}

class _SimplePathCardState extends ConsumerState<SimplePathCard> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(isStartProvider, (previous, started) {
      if (started && previous != true) _run();
    });
    if (ref.read(isStartProvider)) _run();
  }

  void _run() => unawaited(ref.read(diagnosticKernelProvider).runPath());

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final started = ref.watch(isStartProvider);
    final path = ref.watch(pathProvider).value;
    final failed = path?.failed;
    final idle = !started && (path == null || failed?.cause == null);
    final label = DashboardText.label(context).copyWith(height: 1.3);
    return DashboardCard(
      semanticLabel: l.doctorPathTitle,
      onTap: () => unawaited(showPathSheet(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.status,
            title: l.doctorPathTitle,
            chevron: true,
          ),
          if (idle)
            Text(l.doctorPathIdle, style: label)
          else if (path == null)
            Text(l.doctorPathChecking, style: label)
          else if (path.passed)
            Row(
              spacing: 8,
              children: [
                GlyphIcon(AppGlyphs.checkCircle, size: 20, color: colors.ok),
                Expanded(
                  child: Text(
                    l.doctorPathAllPass(path.duration.inMilliseconds),
                    style: AppTextStyle.subheadline.of(
                      context,
                      emphasized: true,
                    ),
                  ),
                ),
              ],
            )
          else ...[
            _PathChain(path: path),
            Text(switch (path) {
              PathResult(cancelled: true) => l.doctorPathCancelled,
              PathResult(complete: false) => l.doctorPathChecking,
              _ => l.doctorPathFailedAt(failed?.step.label(l) ?? ''),
            }, style: AppTextStyle.subheadline.of(context, emphasized: true)),
            if (path.complete && failed != null)
              Text(
                failureText(l, failed),
                style: label.copyWith(
                  color: failed.cause == null ? colors.warn : colorScheme.error,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PathChain extends StatelessWidget {
  const _PathChain({required this.path});

  static const _gap = 2.0;

  final PathResult path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final steps = path.steps;
    (Color, Color) tones(PathStepResult step) => switch (step.status) {
      PathStepStatus.pass => (colors.okContainer, colors.onOkContainer),
      PathStepStatus.fail when step.cause == null => (
        colors.warnContainer,
        colors.onWarnContainer,
      ),
      PathStepStatus.fail => (colorScheme.error, colorScheme.onError),
      PathStepStatus.running => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      _ => (colors.track, colorScheme.onSurfaceVariant),
    };
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size =
              ((constraints.maxWidth - _gap * 2 * steps.length) / steps.length)
                  .clamp(16.0, 28.0);
          return Row(
            children: [
              for (final (index, step) in steps.indexed) ...[
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: _gap),
                      color: step.status == PathStepStatus.pass
                          ? colors.ok
                          : colors.track,
                    ),
                  ),
                ShapeBadge(
                  shape: switch (step.status) {
                    PathStepStatus.fail => MaterialShapes.softBurst,
                    PathStepStatus.running => MaterialShapes.cookie9Sided,
                    _ => MaterialShapes.circle,
                  },
                  color: tones(step).$1,
                  size: size,
                  child: GlyphIcon(
                    step.step.glyph,
                    size: size * 0.56,
                    color: tones(step).$2,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
