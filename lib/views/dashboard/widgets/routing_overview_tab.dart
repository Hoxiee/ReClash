import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview_parts.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// The friendly half: what you are on, what the network is, which services have
/// a route, how much of the park is alive. Every measurement that produced an
/// answer here lives in the details tab, so this one never has to argue.
class RoutingOverviewTab extends StatelessWidget {
  const RoutingOverviewTab({
    super.key,
    required this.report,
    required this.technical,
    required this.onDeepScan,
  });

  final RcxReport report;
  final bool technical;
  final VoidCallback onDeepScan;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        routingSliver(RoutingVerdictCard(report: report, technical: technical)),
        routingHeader(appLocalizations.smartRoutingSectionNetwork),
        routingSliver(RoutingNetworkCard(report: report)),
        routingHeader(appLocalizations.smartRoutingServiceRoutes),
        routingSliver(RoutingLanesCard(report: report)),
        routingHeader(appLocalizations.smartRoutingSectionHealth),
        routingSliver(RoutingHealthCard(report: report)),
        routingSliver(RoutingScanCard(report: report, onDeepScan: onDeepScan)),
        routingHeader(appLocalizations.smartRoutingSectionReliability),
        routingSliver(RoutingStabilityCard(report: report)),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class RoutingVerdictCard extends StatelessWidget {
  const RoutingVerdictCard({
    super.key,
    required this.report,
    required this.technical,
  });

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final status = report.status;
    final chosen = routingChosenOf(report);
    final failed = routingFailed(status);
    final tone = failed
        ? colorScheme.error
        : routingFormatAccent(context, routingFormatOf(report));
    final ours = status.delay > 0 ? status.delay : chosen?.delay ?? 0;
    final delay = ours > 0 ? ours : chosen?.hostDelay ?? 0;
    final counts = routingCountsOf(report);
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              RoutingBadge(
                icon: failed
                    ? Icons.error_outline_rounded
                    : status.searching
                    ? Icons.autorenew_rounded
                    : Icons.verified_rounded,
                tone: tone,
                size: 46,
                busy: status.searching,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TooltipText(
                      text: Text(
                        status.node.isEmpty
                            ? appLocalizations.smartRoutingChosenNone
                            : status.node,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      routingReasonLabel(appLocalizations, status.reason),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (delay > 0) ...[
                const SizedBox(width: 10),
                Text(
                  ours > 0 ? '$delay ms' : '≈$delay ms',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: ours > 0 ? FontWeight.w600 : FontWeight.w400,
                    color: getDelayColor(delay) ?? colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (chosen != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                MetaChip(
                  label: routingVerdictLabel(appLocalizations, chosen.verdict),
                ),
                MetaChip(
                  label: routingEvidenceLabel(
                    appLocalizations,
                    chosen.evidence,
                  ),
                ),
                if (chosen.region.isNotEmpty) MetaChip(label: chosen.region),
                if (chosen.breaker)
                  MetaChip(label: appLocalizations.smartRoutingBreaker),
                if (chosen.degraded)
                  MetaChip(label: appLocalizations.smartRoutingDegraded),
                if (technical)
                  MetaChip(
                    label: appLocalizations.smartRoutingBandLabel(chosen.band),
                  ),
              ],
            ),
          if (chosen != null && chosen.breaker)
            Text(
              appLocalizations.smartRoutingBreakerDesc,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          const RoutingHairline(),
          RoutingStat(
            label: appLocalizations.smartRoutingServers,
            value: '${counts.eligible} / ${counts.total}',
          ),
          RoutingStat(
            label: appLocalizations.smartRoutingSectionHistory,
            value: status.switchedAt > 0
                ? appLocalizations.smartRoutingSwitchedAgo(
                    heroDurationWords(
                      routingMinutesSince(report, status.switchedAt),
                    ),
                  )
                : appLocalizations.smartRoutingNeverSwitched,
          ),
          if (report.manual)
            RoutingStat(
              label: appLocalizations.smartRoutingManualHold,
              value: appLocalizations.smartRoutingManualPinned,
            ),
        ],
      ),
    );
  }
}

/// The format and what it means for the person on it. The measurements behind
/// it are one tab away, so this card can stay a sentence and a few facts.
class RoutingNetworkCard extends StatelessWidget {
  const RoutingNetworkCard({super.key, required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final format = routingFormatOf(report);
    final accent = routingFormatAccent(context, format);
    final link = report.link;
    final facts = <String>[
      if (link.portal) appLocalizations.smartRoutingEvidencePortal,
      if (link.validated)
        appLocalizations.smartRoutingEvidenceValidated
      else
        appLocalizations.smartRoutingEvidenceUnvalidated,
      if (link.foreignForged)
        appLocalizations.smartRoutingEvidenceForeignForged
      else if (link.foreignMeasured)
        link.foreignReached
            ? appLocalizations.smartRoutingEvidenceForeignOk
            : appLocalizations.smartRoutingEvidenceForeignFail,
      if (link.domesticMeasured)
        link.domesticReached
            ? appLocalizations.smartRoutingEvidenceDomesticOk
            : appLocalizations.smartRoutingEvidenceDomesticFail,
      if (report.status.direct == 'node')
        appLocalizations.smartRoutingDomesticViaNode
      else if (report.status.direct == 'direct')
        appLocalizations.smartRoutingDomesticViaDirect,
    ];
    return RoutingCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              RoutingBadge(icon: routingFormatIcon(format), tone: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  format.label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
              if (link.metered)
                MetaChip(label: appLocalizations.smartRoutingMetered),
            ],
          ),
          Text(
            format.description,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          ...facts.map(
            (line) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

typedef RoutingLaneView = ({IconData icon, Color color, String text});

RoutingLaneView routingLaneView(BuildContext context, RcxLaneStatus lane) {
  final appLocalizations = context.appLocalizations;
  final colorScheme = context.colorScheme;
  final muted = colorScheme.onSurfaceVariant;
  return switch (lane.state) {
    'active' => (
      icon: Icons.bolt_rounded,
      color: colorScheme.primary,
      text: lane.node.isEmpty
          ? appLocalizations.smartRoutingOn
          : appLocalizations.smartRoutingServiceVia(lane.node),
    ),
    'searching' => (
      icon: Icons.autorenew_rounded,
      color: muted,
      text: appLocalizations.smartRoutingSearching,
    ),
    'fallback' when lane.fallback == 'reject' => (
      icon: Icons.block_rounded,
      color: colorScheme.error,
      text: appLocalizations.smartRoutingServiceFallbackActiveReject,
    ),
    'fallback' => (
      icon: Icons.alt_route_rounded,
      color: muted,
      text: appLocalizations.smartRoutingServiceFallbackActiveMain,
    ),
    _ => (
      icon: Icons.hourglass_empty_rounded,
      color: muted,
      text: appLocalizations.smartRoutingServicePending,
    ),
  };
}

/// Which capabilities actually have a route right now. A lane is the only part
/// of the engine the user asked for by name, so it says whether it got one.
class RoutingLanesCard extends StatelessWidget {
  const RoutingLanesCard({super.key, required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final lanes = report.status.lanes;
    if (lanes.isEmpty) {
      return RoutingNotice(
        icon: Icons.alt_route_rounded,
        text: appLocalizations.smartRoutingServiceRoutesEmpty,
      );
    }
    return RoutingCard(
      child: Column(
        children: lanes
            .mapIndexed(
              (index, lane) => Column(
                children: [
                  if (index > 0) const RoutingHairline(),
                  RoutingLaneRow(lane: lane),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class RoutingLaneRow extends StatelessWidget {
  const RoutingLaneRow({super.key, required this.lane});

  final RcxLaneStatus lane;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final view = routingLaneView(context, lane);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          RoutingBadge(icon: view.icon, tone: view.color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TooltipText(
                  text: Text(
                    capabilityTitle(context, lane.id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TooltipText(
                  text: Text(
                    view.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (lane.candidates > 0) ...[
            const SizedBox(width: 8),
            Text(
              appLocalizations.smartRoutingServiceReady(
                lane.eligible,
                lane.candidates,
              ),
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The one picture on the page: how much of the subscription is actually alive.
class RoutingHealthCard extends StatelessWidget {
  const RoutingHealthCard({super.key, required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final counts = routingCountsOf(report);
    final proven = counts.eligible - counts.unknown;
    final blocked = colorScheme.error.withValues(alpha: 0.55);
    final idle = colorScheme.surfaceContainerHighest;
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${counts.eligible}',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appLocalizations.smartRoutingAliveCount(
                    counts.eligible,
                    counts.total,
                  ),
                  maxLines: 2,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          RoutingMeter(
            segments: [
              (weight: proven < 0 ? 0 : proven, color: colorScheme.primary),
              (weight: counts.unknown, color: idle),
              (weight: counts.blocked, color: blocked),
            ],
            empty: idle,
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              RoutingLegend(
                color: colorScheme.primary,
                label: appLocalizations.smartRoutingHealthUsable,
                count: proven < 0 ? 0 : proven,
              ),
              if (counts.unknown > 0)
                RoutingLegend(
                  color: idle,
                  label: appLocalizations.smartRoutingHealthUnknown,
                  count: counts.unknown,
                ),
              RoutingLegend(
                color: blocked,
                label: appLocalizations.smartRoutingHealthBlocked,
                count: counts.blocked,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

typedef RoutingMeterSegment = ({int weight, Color color});

/// One bar split by counts, rounded as a single shape so it reads as a whole
/// that is divided rather than three bars that touch.
class RoutingMeter extends StatelessWidget {
  const RoutingMeter({super.key, required this.segments, required this.empty});

  final List<RoutingMeterSegment> segments;
  final Color empty;

  @override
  Widget build(BuildContext context) {
    final filled = segments.where((segment) => segment.weight > 0).toList();
    return ClipRRect(
      borderRadius: AppRadius.full,
      child: SizedBox(
        height: 10,
        child: filled.isEmpty
            ? ColoredBox(color: empty)
            : Row(
                children: filled
                    .map(
                      (segment) => Expanded(
                        flex: segment.weight,
                        child: ColoredBox(color: segment.color),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

class RoutingLegend extends StatelessWidget {
  const RoutingLegend({
    super.key,
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          '$count',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class RoutingScanCard extends StatelessWidget {
  const RoutingScanCard({
    super.key,
    required this.report,
    required this.onDeepScan,
  });

  final RcxReport report;
  final VoidCallback onDeepScan;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final running = report.status.searching;
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            report.status.deep && running
                ? appLocalizations.smartRoutingDeepScanRunning
                : appLocalizations.smartRoutingDeepScan,
            style: context.textTheme.titleSmall,
          ),
          Text(
            appLocalizations.smartRoutingDeepScanHint,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.smartRoutingProbeBudget(
                    report.probesLeft,
                    report.probeCap,
                  ),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              CommonMinFilledButtonTheme(
                child: FilledButton.tonal(
                  onPressed: running ? null : onDeepScan,
                  child: Text(appLocalizations.start),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Three numbers that answer "has this been holding up". The full ledger the
/// engine keeps sits in the details tab; here only the headline survives.
class RoutingStabilityCard extends StatelessWidget {
  const RoutingStabilityCard({super.key, required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final metrics = report.metrics;
    return RoutingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RoutingTile(
                  value: '${metrics.availability}%',
                  label: appLocalizations.smartRoutingAvailability,
                ),
              ),
              Expanded(
                child: RoutingTile(
                  value: '${metrics.incidents}',
                  label: appLocalizations.smartRoutingIncidents,
                ),
              ),
              Expanded(
                child: RoutingTile(
                  value: '${metrics.standbyHits}',
                  label: appLocalizations.smartRoutingStandbyHits,
                ),
              ),
            ],
          ),
          const RoutingHairline(),
          Text(
            appLocalizations.smartRoutingMeasuredOver(
              routingMetricPeriod(context, metrics.enabledMillis),
            ),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class RoutingTile extends StatelessWidget {
  const RoutingTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
