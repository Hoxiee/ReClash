import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart';
import 'package:reclash/widgets/widgets.dart';

/// One rival against the chosen server. A rival can legitimately rank above it:
/// a dwell or a manual hold keeps the incumbent until the hold expires.
class RoutingDuelRow extends StatelessWidget {
  const RoutingDuelRow({
    super.key,
    required this.report,
    required this.chosen,
    required this.candidate,
  });

  final RcxReport report;
  final RcxCandidateReport chosen;
  final RcxCandidateReport candidate;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final overrides = RoutingVocabularyScope.of(context);
    final colorScheme = context.colorScheme;
    final terrain = report.status.terrain;
    final duel = routingDuel(
      candidate,
      chosen,
      terrain: terrain,
      strategy: report.status.strategy,
      ladder: report.ladder,
    );
    final rung = duel.rung;
    final ahead = rung != null && duel.won;
    final tone = ahead ? colorScheme.tertiary : colorScheme.onSurfaceVariant;
    final phrase = rung == null
        ? appLocalizations.smartRoutingTiedAll
        : ahead
        ? appLocalizations.smartRoutingWinsAt(
            routingRungLabel(appLocalizations, rung, overrides: overrides),
          )
        : appLocalizations.smartRoutingLostAt(
            routingRungLabel(appLocalizations, rung, overrides: overrides),
          );
    final standing = [
      if (candidate.region.isNotEmpty) candidate.region,
      phrase,
    ].join(' · ');
    // The two readings ride the name line so the standing below keeps the full
    // width and never truncates to a headless "Ranks higher at…".
    final versus = rung == null
        ? ''
        : appLocalizations.smartRoutingRungVersus(
            routingRungValueLabel(
              appLocalizations,
              rung,
              candidate,
              terrain,
              overrides: overrides,
            ),
            routingRungValueLabel(
              appLocalizations,
              rung,
              chosen,
              terrain,
              overrides: overrides,
            ),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: GlyphIcon(
              rung == null
                  ? AppGlyphs.dragHandle
                  : ahead
                  ? AppGlyphs.trendUp
                  : AppGlyphs.trendDown,
              size: 15,
              color: tone,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TooltipText(
                        text: Text(
                          candidate.node,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ),
                    if (versus.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 156),
                        child: TooltipText(
                          text: Text(
                            versus,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  standing,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(color: tone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
