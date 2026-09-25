import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// Why this server and not one of the others, rung by rung. The ladder comes
/// from the strategy the core reports, so the page cannot show the balanced
/// order while the engine is comparing by latency.
class RoutingRankingTab extends StatelessWidget {
  const RoutingRankingTab({super.key, required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final rows = report.candidates;
    final current = rows.indexWhere((row) => row.current);
    final index = current >= 0
        ? current
        : rows.isEmpty
        ? -1
        : 0;
    final chosen = index < 0 ? null : rows[index];
    final rivals = [
      for (var at = 0; at < rows.length; at++)
        if (at != index) rows[at],
    ];
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        routingHeader(appLocalizations.smartRoutingSectionLadder),
        routingSliver(RoutingLadderCard(report: report, chosen: chosen)),
        routingHeader(appLocalizations.smartRoutingSectionRivals),
        if (chosen == null || rivals.isEmpty)
          routingSliver(
            RoutingNotice(
              icon: AppGlyphs.swap,
              text: appLocalizations.smartRoutingNoRivals,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: DecoratedSliver(
              decoration: routingCardDecoration(context),
              sliver: SliverList.builder(
                itemCount: rivals.length,
                itemBuilder: (_, at) => Padding(
                  padding: EdgeInsets.only(
                    left: routingCardPadding.left,
                    right: routingCardPadding.right,
                    top: at == 0 ? routingCardPadding.top : 0,
                    bottom: at == rivals.length - 1
                        ? routingCardPadding.bottom
                        : 0,
                  ),
                  child: RoutingDuelRow(
                    report: report,
                    chosen: chosen,
                    candidate: rivals[at],
                  ),
                ),
              ),
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

/// The ladder in force, numbered, with the chosen server's own reading on each
/// rung: the page states the rule and the values it was applied to at once.
class RoutingLadderCard extends StatelessWidget {
  const RoutingLadderCard({super.key, required this.report, this.chosen});

  final RcxReport report;
  final RcxCandidateReport? chosen;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final chosen = this.chosen;
    final strategy = report.status.strategy;
    final ladder = routingLadder(strategy);
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TooltipText(
                  text: Text(
                    chosen?.node ?? appLocalizations.smartRoutingChosenNone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              MetaChip(label: routingStrategyLabel(appLocalizations, strategy)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            appLocalizations.smartRoutingLadderHint,
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          const RoutingHairline(),
          for (var step = 0; step < ladder.length; step++)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    child: Text(
                      '${step + 1}',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: chosen == null
                        ? Text(
                            routingRungLabel(appLocalizations, ladder[step]),
                            style: context.textTheme.bodySmall,
                          )
                        : RoutingStat(
                            label: routingRungLabel(
                              appLocalizations,
                              ladder[step],
                            ),
                            value: routingRungValueLabel(
                              appLocalizations,
                              ladder[step],
                              chosen,
                              report.status.terrain,
                            ),
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

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
    final colorScheme = context.colorScheme;
    final terrain = report.status.terrain;
    final duel = routingDuel(
      candidate,
      chosen,
      terrain: terrain,
      strategy: report.status.strategy,
    );
    final rung = duel.rung;
    final ahead = rung != null && duel.won;
    final tone = ahead ? colorScheme.tertiary : colorScheme.onSurfaceVariant;
    final phrase = rung == null
        ? appLocalizations.smartRoutingTiedAll
        : ahead
        ? appLocalizations.smartRoutingWinsAt(
            routingRungLabel(appLocalizations, rung),
          )
        : appLocalizations.smartRoutingLostAt(
            routingRungLabel(appLocalizations, rung),
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
            routingRungValueLabel(appLocalizations, rung, candidate, terrain),
            routingRungValueLabel(appLocalizations, rung, chosen, terrain),
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
