import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview_parts.dart';
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
              icon: Icons.compare_arrows_rounded,
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
              const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
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
    final standing = rung == null
        ? appLocalizations.smartRoutingTiedAll
        : ahead
        ? appLocalizations.smartRoutingWinsAt(
            routingRungLabel(appLocalizations, rung),
          )
        : appLocalizations.smartRoutingLostAt(
            routingRungLabel(appLocalizations, rung),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            rung == null
                ? Icons.drag_handle_rounded
                : ahead
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 15,
            color: tone,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TooltipText(
                  text: Text(
                    candidate.node,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                ),
                Text(
                  [
                    if (candidate.region.isNotEmpty) candidate.region,
                    standing,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(color: tone),
                ),
              ],
            ),
          ),
          if (rung != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: TooltipText(
                text: Text(
                  appLocalizations.smartRoutingRungVersus(
                    routingRungValueLabel(
                      appLocalizations,
                      rung,
                      candidate,
                      terrain,
                    ),
                    routingRungValueLabel(
                      appLocalizations,
                      rung,
                      chosen,
                      terrain,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
