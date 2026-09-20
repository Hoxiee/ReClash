import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Relics (T2) accumulate from odometer facts; crown closes the set and is
// shown on its own. Moments (T1) are one-off events kept with a date.
const _relicIds = <String>[
  'vigil',
  'auscultation',
  'fullLadder',
  'silentAutopilot',
  'odometer',
  'meridian',
  'porcelain',
];
const _momentIds = <String>[
  'oscilloscope',
  'marks',
  'pi',
  'turn',
];

const _dayMillis = 24 * 60 * 60 * 1000;

class FindingsView extends ConsumerWidget {
  const FindingsView({super.key});

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    if (ref.read(findingPreviewProvider).enabled) {
      ref.read(findingPreviewProvider.notifier).reset();
      return;
    }
    final localizations = context.appLocalizations;
    final confirmed = await dialogs.showCommonDialog<bool>(
      child: CommonDialog(
        title: localizations.resetFindingsTitle,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.reset),
          ),
        ],
        child: Text(localizations.resetFindingsConfirm),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(milestonesProvider.notifier).resetFindings();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(visibleMilestonesProvider);
    final preview = ref.watch(findingPreviewProvider).enabled;
    final localizations = context.appLocalizations;
    final shown = settings.revealedAt.keys.toSet();

    final relicsFound = _relicIds.where(shown.contains).length;
    final momentsFound = _momentIds.where(shown.contains).length;
    final crownFound = shown.contains('crown');

    return CommonScaffold(
      title: localizations.findings,
      body: CustomScrollView(
        slivers: [
          SettingSection.sliver(
            top: 12,
            items: [
              DecorationListItem(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(localizations.findingsDesc),
                subtitle: Text(
                  '${localizations.findingsMoments}: '
                  '${localizations.findingsCount(momentsFound, _momentIds.length)}'
                  '  ·  ${localizations.findingsRelics}: '
                  '${localizations.findingsCount(relicsFound, _relicIds.length)}',
                ),
              ),
              const _ContinuityItem(),
            ],
          ),
          _RelicsSection(shown: shown),
          _MomentsSection(settings: settings),
          if (crownFound) _CrownSection(revealedAt: settings.revealedAt),
          SettingSection.sliver(
            items: [
              DecorationListItem(
                leading: const Icon(Icons.restart_alt_outlined),
                title: Text(
                  preview
                      ? localizations.developerPreviewReset
                      : localizations.resetFindings,
                ),
                subtitle: Text(
                  preview
                      ? localizations.developerFindingsDesc
                      : localizations.resetFindingsDesc,
                ),
                onPressed: () => _reset(context, ref),
              ),
            ],
          ),
          const SettingBottomInset.sliver(),
        ],
      ),
    );
  }
}

// The single progress line allowed by the design: continuity toward the next
// unearned coverage milestone. Hidden once both vigil and crown are earned.
class _ContinuityItem extends ConsumerWidget {
  const _ContinuityItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(visibleMilestonesProvider);
    final snapshot = ref.watch(visibleOdometerProvider);
    if (snapshot == null) return const SizedBox.shrink();
    final localizations = context.appLocalizations;

    final int targetDays;
    final int currentMillis;
    if (!settings.unlocked.contains('vigil')) {
      targetDays = 90;
      currentMillis = snapshot.streakMillis;
    } else if (!settings.unlocked.contains('crown')) {
      targetDays = 360;
      currentMillis = snapshot.totalCoveredMillis;
    } else {
      return const SizedBox.shrink();
    }

    final targetMillis = targetDays * _dayMillis;
    final progress = (currentMillis / targetMillis).clamp(0.0, 1.0);
    final remainingDays = math.max(
      0,
      ((targetMillis - currentMillis) / _dayMillis).ceil(),
    );

    return DecorationListItem(
      leading: const Icon(Icons.trending_up_outlined),
      title: Text(localizations.findingsNextMilestone(remainingDays)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppCorner.xs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class _RelicsSection extends StatelessWidget {
  const _RelicsSection({required this.shown});

  final Set<String> shown;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    return SettingSection.sliver(
      title: localizations.findingsRelics,
      items: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final columns = math.max(
                (constraints.maxWidth / 108).floor(),
                3,
              );
              final tileWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final id in _relicIds)
                    _RelicTile(
                      id: id,
                      width: tileWidth,
                      revealed: shown.contains(id),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RelicTile extends StatelessWidget {
  const _RelicTile({
    required this.id,
    required this.width,
    required this.revealed,
  });

  final String id;
  final double width;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final glyphColor = revealed ? scheme.primary : scheme.outlineVariant;
    return SizedBox(
      width: width,
      height: 116,
      child: CommonCard(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: CustomPaint(
                    size: const Size.square(44),
                    painter: _FindingGlyph(id: id, color: glyphColor),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                revealed ? findingName(context, id) : '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: revealed
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentsSection extends StatelessWidget {
  const _MomentsSection({required this.settings});

  final MilestoneProps settings;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final materialLocalizations = MaterialLocalizations.of(context);
    final found =
        _momentIds
            .where((id) => settings.revealedAt.containsKey(id))
            .toList()
          ..sort((a, b) {
        final da = settings.revealedAt[a] ?? 0;
        final db = settings.revealedAt[b] ?? 0;
        return db.compareTo(da);
      });
    final lockedCount = _momentIds.length - found.length;
    return SettingSection.sliver(
      title: localizations.findingsMoments,
      items: [
        for (final id in found)
          DecorationListItem(
            leading: CustomPaint(
              size: const Size.square(24),
              painter: _FindingGlyph(id: id, color: context.colorScheme.primary),
            ),
            title: Text(findingName(context, id)),
            subtitle: Text(findingDescription(context, id)),
            trailing: settings.revealedAt[id] == null
                ? null
                : Text(
                    materialLocalizations.formatMediumDate(
                      DateTime.fromMillisecondsSinceEpoch(
                        settings.revealedAt[id]!,
                      ),
                    ),
                    textAlign: TextAlign.end,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        if (lockedCount > 0)
          DecorationListItem(
            leading: const Icon(Icons.more_horiz),
            title: Text(localizations.findingsLocked(lockedCount)),
          ),
      ],
    );
  }
}

class _CrownSection extends StatelessWidget {
  const _CrownSection({required this.revealedAt});

  final Map<String, int> revealedAt;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final materialLocalizations = MaterialLocalizations.of(context);
    final at = revealedAt['crown'];
    return SettingSection.sliver(
      title: localizations.findingCrown,
      items: [
        DecorationListItem(
          leading: CustomPaint(
            size: const Size.square(24),
            painter: _FindingGlyph(
              id: 'crown',
              color: context.colorScheme.primary,
            ),
          ),
          title: Text(localizations.milestoneRevealCrown),
          subtitle: at == null
              ? null
              : Text(
                  localizations.findingDiscoveredOn(
                    materialLocalizations.formatMediumDate(
                      DateTime.fromMillisecondsSinceEpoch(at),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// Compact scheme-colored vectors, one per finding, drawn in the app's own
// visual language instead of stock Material glyphs.
class _FindingGlyph extends CustomPainter {
  const _FindingGlyph({required this.id, required this.color});

  final String id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.4;

    switch (id) {
      case 'vigil':
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          -math.pi / 3,
          math.pi * 1.4,
          false,
          stroke,
        );
      case 'auscultation':
        final path = Path()..moveTo(c.dx - r, c.dy);
        path.lineTo(c.dx - r * 0.4, c.dy);
        path.lineTo(c.dx - r * 0.15, c.dy - r * 0.7);
        path.lineTo(c.dx + r * 0.1, c.dy + r * 0.7);
        path.lineTo(c.dx + r * 0.35, c.dy);
        path.lineTo(c.dx + r, c.dy);
        canvas.drawPath(path, stroke);
      case 'fullLadder':
        for (var i = 0; i < 3; i++) {
          final y = c.dy + r - i * r * 0.7;
          final w = r * (0.5 + i * 0.25);
          canvas.drawLine(
            Offset(c.dx - w, y),
            Offset(c.dx + w, y),
            stroke,
          );
        }
      case 'silentAutopilot':
        canvas.drawCircle(c, r * 0.2, fill);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: r * 2, height: r * 1.1),
          stroke,
        );
      case 'odometer':
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          math.pi * 0.75,
          math.pi * 1.5,
          false,
          stroke,
        );
        canvas.drawLine(c, Offset(c.dx + r * 0.5, c.dy - r * 0.5), stroke);
      case 'meridian':
        canvas.drawCircle(c, r, stroke);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: r, height: r * 2),
          stroke,
        );
        canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), stroke);
      case 'porcelain':
        canvas.drawCircle(c, r, stroke);
        final half = Path()
          ..addArc(
            Rect.fromCircle(center: c, radius: r),
            -math.pi / 2,
            math.pi,
          );
        canvas.drawPath(half, fill);
      case 'crown':
        final path = Path()..moveTo(c.dx - r, c.dy + r * 0.5);
        path.lineTo(c.dx - r, c.dy - r * 0.5);
        path.lineTo(c.dx - r * 0.5, c.dy);
        path.lineTo(c.dx, c.dy - r * 0.7);
        path.lineTo(c.dx + r * 0.5, c.dy);
        path.lineTo(c.dx + r, c.dy - r * 0.5);
        path.lineTo(c.dx + r, c.dy + r * 0.5);
        path.close();
        canvas.drawPath(path, stroke);
      case 'oscilloscope':
        final path = Path();
        for (var i = 0; i <= 32; i++) {
          final t = i / 32;
          final x = c.dx - r + t * 2 * r;
          final y = c.dy - math.sin(t * math.pi * 4) * r * 0.6;
          i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
        }
        canvas.drawPath(path, stroke);
      case 'marks':
        for (var i = 0; i < 3; i++) {
          final o = Offset(c.dx - r * 0.4 + i * r * 0.4, c.dy - r * 0.3 + i * r * 0.3);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: o, width: r, height: r),
              Radius.circular(r * 0.25),
            ),
            stroke,
          );
        }
      case 'pi':
        canvas.drawLine(
          Offset(c.dx - r * 0.8, c.dy - r * 0.5),
          Offset(c.dx + r * 0.8, c.dy - r * 0.5),
          stroke,
        );
        canvas.drawLine(
          Offset(c.dx - r * 0.4, c.dy - r * 0.5),
          Offset(c.dx - r * 0.5, c.dy + r * 0.7),
          stroke,
        );
        canvas.drawLine(
          Offset(c.dx + r * 0.4, c.dy - r * 0.5),
          Offset(c.dx + r * 0.4, c.dy + r * 0.7),
          stroke,
        );
      case 'turn':
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          -math.pi / 2,
          math.pi * 1.5,
          false,
          stroke,
        );
        final tip = c + Offset(0, -r);
        canvas.drawLine(tip, tip + Offset(r * 0.35, -r * 0.1), stroke);
        canvas.drawLine(tip, tip + Offset(r * 0.1, r * 0.35), stroke);
      default:
        canvas.drawCircle(c, r, stroke);
    }
  }

  @override
  bool shouldRepaint(_FindingGlyph oldDelegate) =>
      oldDelegate.id != id || oldDelegate.color != color;
}

String findingName(BuildContext context, String id) => switch (id) {
  'vigil' => context.appLocalizations.findingVigil,
  'auscultation' => context.appLocalizations.findingAuscultation,
  'fullLadder' => context.appLocalizations.findingFullLadder,
  'silentAutopilot' => context.appLocalizations.findingSilentAutopilot,
  'odometer' => context.appLocalizations.findingOdometer,
  'meridian' => context.appLocalizations.findingMeridian,
  'porcelain' => context.appLocalizations.findingPorcelain,
  'crown' => context.appLocalizations.findingCrown,
  'oscilloscope' => context.appLocalizations.findingOscilloscope,
  'marks' => context.appLocalizations.findingMarks,
  'pi' => context.appLocalizations.findingPi,
  'turn' => context.appLocalizations.findingTurn,
  _ => id,
};

String findingDescription(BuildContext context, String id) => switch (id) {
  'vigil' => context.appLocalizations.milestoneRevealVigil,
  'auscultation' => context.appLocalizations.milestoneRevealAuscultation,
  'fullLadder' => context.appLocalizations.milestoneRevealFullLadder,
  'silentAutopilot' => context.appLocalizations.milestoneRevealSilentAutopilot,
  'odometer' => context.appLocalizations.milestoneRevealOdometer,
  'meridian' => context.appLocalizations.milestoneRevealMeridian,
  'porcelain' => context.appLocalizations.milestoneRevealPorcelain,
  'crown' => context.appLocalizations.milestoneRevealCrown,
  'oscilloscope' => context.appLocalizations.findingOscilloscopeDesc,
  'marks' => context.appLocalizations.findingMarksDesc,
  'pi' => context.appLocalizations.findingPiDesc,
  'turn' => context.appLocalizations.findingTurnDesc,
  _ => '',
};
