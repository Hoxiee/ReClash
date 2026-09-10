import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview_parts.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// The other half: the route it took to a decision, the measurements it took on
/// the way, and — under the technical toggle — the raw state the core reasons
/// in, so a reader who distrusts the overview can check every claim it made.
class RoutingDetailsTab extends StatelessWidget {
  const RoutingDetailsTab({
    super.key,
    required this.report,
    required this.technical,
  });

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        routingHeader(appLocalizations.smartRoutingSectionRound),
        routingSliver(RoutingRoundCard(report: report, technical: technical)),
        routingHeader(appLocalizations.smartRoutingSectionNetwork),
        routingSliver(
          RoutingEvidenceCard(report: report, technical: technical),
        ),
        routingHeader(appLocalizations.smartRoutingSectionReliability),
        routingSliver(
          RoutingReliabilityCard(report: report, technical: technical),
        ),
        routingHeader(appLocalizations.smartRoutingSectionHistory),
        routingSliver(RoutingHistoryCard(report: report)),
        if (technical) ...[
          routingHeader(appLocalizations.smartRoutingSectionEngine),
          routingSliver(RoutingEngineCard(report: report)),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

@immutable
class RoutingStepData {
  const RoutingStepData({
    required this.icon,
    required this.title,
    required this.body,
    this.tone,
    this.chips = const [],
    this.child,
    this.childLabel = '',
  });

  final IconData icon;
  final String title;
  final String body;
  final Color? tone;
  final List<Widget> chips;
  final Widget? child;
  final String childLabel;
}

/// The decision as a sequence, because the sequence *is* the explanation: it read
/// the network, so it knew who was allowed, so it ordered those, so it landed
/// where it landed. Each step's evidence folds away behind it.
class RoutingRoundCard extends StatelessWidget {
  const RoutingRoundCard({
    super.key,
    required this.report,
    required this.technical,
  });

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);
    return RoutingCard(
      child: Column(
        children: List.generate(
          steps.length,
          (index) => RoutingStepTile(
            data: steps[index],
            last: index == steps.length - 1,
          ),
        ),
      ),
    );
  }

  List<RoutingStepData> _steps(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final status = report.status;
    final counts = routingCountsOf(report);
    final format = routingFormatOf(report);
    final answered = report.canaries.where((canary) => canary.answered).length;
    final chosen = routingChosenOf(report);
    final failed = routingFailed(status);
    final bands = report.bands.isEmpty
        ? ''
        : appLocalizations.smartRoutingBands(
            report.bands.map((band) => '$band ms').join(' · '),
          );
    return [
      RoutingStepData(
        icon: Icons.wifi_find_outlined,
        title: appLocalizations.smartRoutingStepNetwork,
        body: [
          format.label,
          if (report.canaries.isNotEmpty)
            appLocalizations.smartRoutingCanariesAnswered(
              answered,
              report.canaries.length,
            ),
        ].join(' · '),
      ),
      RoutingStepData(
        icon: Icons.filter_alt_outlined,
        title: appLocalizations.smartRoutingStepAdmit,
        body: appLocalizations.smartRoutingStepAdmitBody(
          counts.eligible,
          counts.total,
          counts.blocked,
        ),
      ),
      RoutingStepData(
        icon: Icons.sort_rounded,
        title: appLocalizations.smartRoutingStepRank,
        body: [
          appLocalizations.smartRoutingStepRankBody,
          if (technical && bands.isNotEmpty) bands,
        ].join(' · '),
        childLabel: appLocalizations.smartRoutingRankOrder,
        child: RoutingRankOrder(strategy: status.strategy),
      ),
      RoutingStepData(
        icon: failed ? Icons.error_outline_rounded : Icons.verified_rounded,
        tone: failed ? colorScheme.error : colorScheme.primary,
        title: appLocalizations.smartRoutingStepDecision,
        body: routingReasonLabel(appLocalizations, status.reason),
        chips: [
          if (status.node.isNotEmpty) MetaChip(label: status.node),
          if (chosen != null)
            MetaChip(
              label: routingVerdictLabel(appLocalizations, chosen.verdict),
            ),
        ],
        childLabel: appLocalizations.smartRoutingAllServers,
        child: RoutingCandidateList(
          rows: report.candidates,
          technical: technical,
        ),
      ),
    ];
  }
}

/// The comparison order, spelled out: the first line that differs between two
/// servers is the reason one of them won. Latency ranks by a shorter ladder
/// than balanced does, so the list is read from the strategy, never fixed.
class RoutingRankOrder extends StatelessWidget {
  const RoutingRankOrder({super.key, required this.strategy});

  final String strategy;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final rows = [
      for (final rung in routingLadder(strategy))
        routingRungLabel(appLocalizations, rung),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        rows.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '${index + 1}',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(rows[index], style: context.textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoutingStepTile extends StatelessWidget {
  const RoutingStepTile({super.key, required this.data, required this.last});

  final RoutingStepData data;
  final bool last;

  static const _railWidth = 30.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tone = data.tone ?? colorScheme.onSurfaceVariant;
    final child = data.child;
    return Stack(
      children: [
        // The connector is positioned rather than stretched in the row: a step's
        // content can hold a LayoutBuilder, which IntrinsicHeight cannot measure.
        if (!last)
          Positioned(
            top: _railWidth + 4,
            bottom: 0,
            left: _railWidth / 2 - 0.75,
            child: Container(
              width: 1.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _railWidth,
              child: RoutingBadge(
                icon: data.icon,
                tone: tone,
                size: _railWidth,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: last ? 4 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (data.body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        data.body,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (data.chips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: data.chips),
                    ],
                    if (child != null)
                      RoutingDisclosure(label: data.childLabel, child: child),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The canaries are fixed addresses dialled outside any tunnel, so their answer
/// says nothing about a server: the two counts sit together because reading one
/// as the other is what makes the screen lie.
class RoutingEvidenceCard extends StatelessWidget {
  const RoutingEvidenceCard({
    super.key,
    required this.report,
    required this.technical,
  });

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final canaries = report.canaries;
    final answered = canaries.where((canary) => canary.answered).length;
    final probed = report.candidates
        .where((candidate) => candidate.delay > 0)
        .toList();
    if (canaries.isEmpty && report.candidates.isEmpty) {
      return RoutingNotice(
        icon: Icons.science_outlined,
        text: appLocalizations.smartRoutingEmpty,
      );
    }
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canaries.isNotEmpty)
            RoutingDisclosure(
              label: appLocalizations.smartRoutingWhatWasTested,
              summary: appLocalizations.smartRoutingCanariesAnswered(
                answered,
                canaries.length,
              ),
              child: Column(
                children: canaries
                    .map(
                      (canary) => RoutingCanaryRow(
                        canary: canary,
                        technical: technical,
                      ),
                    )
                    .toList(),
              ),
            ),
          if (report.candidates.isNotEmpty)
            RoutingDisclosure(
              label: appLocalizations.smartRoutingNodeChecks,
              summary: appLocalizations.smartRoutingNodesMeasured(
                probed.length,
                report.candidates.length,
              ),
              child: RoutingCandidateList(rows: probed, technical: technical),
            ),
        ],
      ),
    );
  }
}

class RoutingReliabilityCard extends StatelessWidget {
  const RoutingReliabilityCard({
    super.key,
    required this.report,
    required this.technical,
  });

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final metrics = report.metrics;
    final active = <Widget>[
      if (metrics.activeCircuits.isNotEmpty)
        RoutingStat(
          label: appLocalizations.smartRoutingActiveCircuits,
          value: metrics.activeCircuits.join(', '),
        ),
      if (metrics.activeMarkers.isNotEmpty)
        RoutingStat(
          label: appLocalizations.smartRoutingActiveMarkers,
          value: metrics.activeMarkers.join(', '),
        ),
    ];
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          RoutingStat(
            label: appLocalizations.smartRoutingAvailability,
            value: appLocalizations.smartRoutingAvailabilityValue(
              metrics.availability,
              routingMetricPeriod(context, metrics.enabledMillis),
            ),
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingIncidents,
            value: '${metrics.incidents}',
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingStandbyHits,
            value: '${metrics.standbyHits}',
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingLastRecovery,
            value: routingMetricDuration(context, metrics.lastOutage),
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingAverageRecovery,
            value: routingMetricDuration(context, metrics.averageOutage),
          ),
          if (technical) ...[
            RoutingStat(
              label: appLocalizations.smartRoutingLastFailover,
              value: routingMetricDuration(context, metrics.lastFailover),
            ),
            RoutingStat(
              label: appLocalizations.smartRoutingAverageFailover,
              value: routingMetricDuration(context, metrics.averageFailover),
            ),
            RoutingStat(
              label: appLocalizations.smartRoutingEngineAvailable,
              value: routingMetricPeriod(context, metrics.availableMillis),
            ),
          ],
          RoutingStat(
            label: appLocalizations.smartRoutingProviderIncidents,
            value: '${metrics.providerIncidents}',
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingMarkerIncidents,
            value: '${metrics.markerIncidents}',
          ),
          if (active.isNotEmpty) const RoutingHairline(),
          ...active,
        ],
      ),
    );
  }
}

class RoutingHistoryCard extends StatelessWidget {
  const RoutingHistoryCard({super.key, required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final history = report.history.reversed.toList();
    if (history.isEmpty) {
      return RoutingNotice(
        icon: Icons.history_rounded,
        text: appLocalizations.smartRoutingHistoryEmpty,
      );
    }
    return RoutingCard(
      child: Column(
        children: List.generate(history.length, (index) {
          final entry = history[index];
          return Column(
            children: [
              if (index > 0) const RoutingHairline(),
              RoutingSwitchRow(entry: entry, at: report.at),
            ],
          );
        }),
      ),
    );
  }
}

class RoutingSwitchRow extends StatelessWidget {
  const RoutingSwitchRow({super.key, required this.entry, required this.at});

  final RcxSwitchReport entry;
  final int at;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TooltipText(
                  text: Text(
                    entry.from.isEmpty
                        ? entry.to
                        : appLocalizations.smartRoutingSwitchLine(
                            entry.from,
                            entry.to,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                ),
                Text(
                  [
                    routingReasonLabel(appLocalizations, entry.reason),
                    if (entry.at > 0)
                      appLocalizations.smartRoutingSwitchedAgo(
                        heroDurationWords(
                          at - entry.at < 0 ? 0 : (at - entry.at) ~/ 60000,
                        ),
                      ),
                  ].join(' · '),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

/// The state the core actually keeps, named rather than interpreted. Nothing
/// here is phrased for a first reader; it exists so a report can be compared
/// against the engine that produced it.
class RoutingEngineCard extends StatelessWidget {
  const RoutingEngineCard({super.key, required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final status = report.status;
    final link = report.link;
    final unknown = appLocalizations.unknown;
    final lanes = status.lanes;
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          RoutingStat(
            label: appLocalizations.smartRoutingEngineReportAge,
            value: report.at > 0
                ? routingMetricPeriod(
                    context,
                    DateTime.now().millisecondsSinceEpoch - report.at,
                  )
                : unknown,
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingEnginePreset,
            value: status.preset.isEmpty ? unknown : status.preset,
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingEngineMode,
            value: status.mode.isEmpty ? unknown : status.mode,
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingEngineTerrain,
            value: status.terrain,
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingEnvKey,
            value: status.env.isEmpty ? appLocalizations.none : status.env,
          ),
          const RoutingHairline(),
          RoutingStat(
            label: appLocalizations.smartRoutingEngineTransport,
            value: link.transport.isEmpty ? unknown : link.transport,
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingEngineLinkAge,
            value: link.since > 0
                ? heroDurationWords(routingMinutesSince(report, link.since))
                : unknown,
          ),
          const RoutingHairline(),
          RoutingStat(
            label: appLocalizations.smartRoutingEnginePin,
            value: status.pinned
                ? (status.pinNode.isEmpty ? status.node : status.pinNode)
                : appLocalizations.off,
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingEngineDeepScan,
            value: status.deep
                ? appLocalizations.smartRoutingDeepScanRunning
                : appLocalizations.off,
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingKeyBand,
            value: report.bands.isEmpty
                ? appLocalizations.none
                : report.bands.map((band) => '$band ms').join(' · '),
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingEngineLanes,
            value: lanes.isEmpty
                ? appLocalizations.none
                : lanes
                      .map(
                        (lane) => [
                          lane.id,
                          lane.state,
                          if (lane.node.isNotEmpty) lane.node,
                        ].join(' '),
                      )
                      .join(', '),
          ),
        ],
      ),
    );
  }
}
