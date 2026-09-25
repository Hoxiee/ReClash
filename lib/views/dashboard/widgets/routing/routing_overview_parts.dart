import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_words.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

String routingReasonLabel(AppLocalizations l10n, String reason) =>
    switch (reason) {
      'cold-start' => l10n.smartRoutingReasonColdStart,
      'hold' => l10n.smartRoutingReasonHold,
      'incumbent-dead' => l10n.smartRoutingReasonIncumbentDead,
      'verdict-gain' => l10n.smartRoutingReasonVerdictGain,
      'latency-gain' => l10n.smartRoutingReasonLatencyGain,
      'reliability-gain' => l10n.smartRoutingReasonReliabilityGain,
      'quality-confirming' => l10n.smartRoutingReasonQualityConfirming,
      'handoff-recovery' => l10n.smartRoutingReasonHandoffRecovery,
      'terrain-changed' => l10n.smartRoutingReasonTerrainChanged,
      'stranded' => l10n.smartRoutingReasonStranded,
      'no-candidate' => l10n.smartRoutingReasonNoCandidate,
      'dwell-hold' => l10n.smartRoutingReasonDwellHold,
      'manual-hold' => l10n.smartRoutingReasonManualHold,
      'degraded' => l10n.smartRoutingReasonDegraded,
      'measuring' => l10n.smartRoutingReasonMeasuring,
      'pin-return' => l10n.smartRoutingReasonPinReturn,
      _ => l10n.unknown,
    };

String routingVerdictLabel(AppLocalizations l10n, String verdict) =>
    switch (verdict) {
      'preferred' => l10n.smartRoutingVerdictPreferred,
      'viable' => l10n.smartRoutingVerdictViable,
      'last-resort' => l10n.smartRoutingVerdictLastResort,
      _ => l10n.smartRoutingVerdictReject,
    };

String routingEvidenceLabel(AppLocalizations l10n, String evidence) =>
    switch (evidence) {
      'live' => l10n.smartRoutingEvidenceLive,
      'fresh' => l10n.smartRoutingEvidenceFresh,
      'stale' => l10n.smartRoutingEvidenceStale,
      _ => l10n.smartRoutingEvidenceNone,
    };

/// The block is the gate that actually stopped the node, so it replaces the
/// verdict in the row: telling the user both would be telling them twice.
String routingBlockLabel(AppLocalizations l10n, RcxCandidateReport candidate) =>
    switch (candidate.block) {
      'absent' => l10n.smartRoutingBlockAbsent,
      'no-udp' => l10n.smartRoutingBlockNoUdp,
      'cooling' => l10n.smartRoutingBlockCooling(candidate.fails),
      'disproven' => l10n.smartRoutingBlockDisproven,
      'last-resort-barred' => l10n.smartRoutingBlockLastResort,
      'terrain-unfit' => l10n.smartRoutingBlockTerrainUnfit,
      'provider-circuit' => l10n.smartRoutingBlockProviderCircuit,
      'ignored' => l10n.smartRoutingBlockIgnored,
      'avoid-exit' => l10n.smartRoutingBlockAvoidExit,
      _ => routingVerdictLabel(l10n, candidate.verdict),
    };

/// Where the node sits relative to the censored country, in the same two words
/// the canaries use, so one vocabulary covers both halves of the evidence.
String routingOriginLabel(AppLocalizations l10n, String origin) =>
    switch (origin) {
      'foreign' => l10n.smartRoutingCanaryForeign,
      'domestic' => l10n.smartRoutingCanaryDomestic,
      _ => l10n.unknown,
    };

String routingRungLabel(AppLocalizations l10n, RoutingRung rung) =>
    switch (rung) {
      RoutingRung.admission => l10n.smartRoutingKeyAdmission,
      RoutingRung.verdict => l10n.smartRoutingKeyVerdict,
      RoutingRung.misfit => l10n.smartRoutingKeyMisfit,
      RoutingRung.recurrence => l10n.smartRoutingDegraded,
      RoutingRung.degraded => l10n.smartRoutingReasonDegraded,
      RoutingRung.homeRisk => l10n.smartRoutingKeyHomeRisk,
      RoutingRung.evidence => l10n.smartRoutingKeyEvidence,
      RoutingRung.latency => l10n.smartRoutingKeyBand,
      RoutingRung.unproven => l10n.smartRoutingKeyUnproven,
      RoutingRung.incumbent => l10n.smartRoutingKeyIncumbent,
      RoutingRung.tiebreak => l10n.smartRoutingKeyTiebreak,
    };

/// What one server reads as on one rung. The gate replaces the admission word
/// the same way it replaces the verdict in a row: a held-back node is not
/// "allowed, but", it is stopped by a named gate.
String routingRungValueLabel(
  AppLocalizations l10n,
  RoutingRung rung,
  RcxCandidateReport candidate,
  String terrain,
) => switch (rung) {
  RoutingRung.admission =>
    candidate.eligible
        ? l10n.smartRoutingAdmittedYes
        : routingBlockLabel(l10n, candidate),
  RoutingRung.verdict => routingVerdictLabel(l10n, candidate.verdict),
  RoutingRung.misfit =>
    routingRungValue(rung, candidate, terrain) == 0
        ? l10n.smartRoutingFitYes
        : l10n.smartRoutingFitNo,
  RoutingRung.recurrence => candidate.recurrence.toString(),
  RoutingRung.degraded =>
    candidate.degraded ? l10n.smartRoutingDegraded : l10n.smartRoutingProvenYes,
  RoutingRung.homeRisk => switch (candidate.homeRisk) {
    0 => l10n.smartRoutingProvenYes,
    1 => l10n.unknown,
    _ => l10n.smartRoutingProvenNo,
  },
  RoutingRung.evidence => routingEvidenceLabel(l10n, candidate.evidence),
  RoutingRung.latency =>
    candidate.latencyMs > 0 ? '${candidate.latencyMs} ms' : l10n.unknown,
  RoutingRung.unproven =>
    candidate.unproven ? l10n.smartRoutingProvenNo : l10n.smartRoutingProvenYes,
  RoutingRung.incumbent =>
    candidate.current
        ? l10n.smartRoutingIncumbentYes
        : l10n.smartRoutingIncumbentNo,
  RoutingRung.tiebreak => '#${candidate.order}',
};

String routingStrategyLabel(AppLocalizations l10n, String strategy) =>
    switch (strategy) {
      'lowest-latency' => l10n.smartRoutingStrategyLowestLatency,
      'stable' => l10n.smartRoutingStrategyStable,
      'saver' => l10n.smartRoutingStrategySaver,
      _ => l10n.smartRoutingStrategyBalanced,
    };

NetworkFormat routingFormatOf(RcxReport report) =>
    networkFormatOf(report.status.terrain);

Color routingFormatAccent(BuildContext context, NetworkFormat format) {
  final colorScheme = context.colorScheme;
  return switch (format) {
    NetworkFormat.open => colorScheme.primary,
    NetworkFormat.restricted || NetworkFormat.portal => colorScheme.tertiary,
    NetworkFormat.offline => colorScheme.error,
    NetworkFormat.unknown => colorScheme.onSurfaceVariant,
  };
}

Glyph routingFormatIcon(NetworkFormat format) => switch (format) {
  NetworkFormat.open => AppGlyphs.language,
  NetworkFormat.restricted => AppGlyphs.shieldMoon,
  NetworkFormat.portal => AppGlyphs.wifiLock,
  NetworkFormat.offline => AppGlyphs.cloudOff,
  NetworkFormat.unknown => AppGlyphs.globeSearch,
};

bool routingFailed(RcxStatus status) =>
    status.reason == 'stranded' || status.reason == 'no-candidate';

RcxCandidateReport? routingChosenOf(RcxReport report) {
  for (final candidate in report.candidates) {
    if (candidate.current) return candidate;
  }
  return null;
}

int routingMinutesSince(RcxReport report, int at) {
  final elapsed = report.at - at;
  return elapsed < 0 ? 0 : elapsed ~/ 60000;
}

String routingMetricDuration(BuildContext context, int millis) {
  if (millis <= 0) return context.appLocalizations.smartRoutingNoRecovery;
  final minutes = millis ~/ 60000;
  if (minutes > 0) return heroDurationWords(minutes);
  final seconds = (millis / 1000).ceil();
  return context.appLocalizations.secondsCount(seconds);
}

String routingMetricPeriod(BuildContext context, int millis) {
  if (millis >= 60000) return heroDurationWords(millis ~/ 60000);
  final seconds = (millis / 1000).ceil();
  return context.appLocalizations.secondsCount(seconds);
}

Widget routingSliver(Widget child) => SliverPadding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
  sliver: SliverToBoxAdapter(child: child),
);

Widget routingHeader(String title) => SliverPadding(
  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
  sliver: SliverToBoxAdapter(
    child: ListHeader(title: title, padding: EdgeInsets.zero),
  ),
);

ShapeDecoration routingCardDecoration(BuildContext context, {Color? accent}) =>
    ShapeDecoration(
      shape: AppShape.xl,
      color: accent == null
          ? context.colorScheme.surfaceContainerHigh
          : accent.withValues(alpha: 0.10),
    );

const routingCardPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

class RoutingCard extends StatelessWidget {
  const RoutingCard({super.key, required this.child, this.accent});

  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: routingCardDecoration(context, accent: accent),
    child: Padding(padding: routingCardPadding, child: child),
  );
}

class RoutingNotice extends StatelessWidget {
  const RoutingNotice({super.key, required this.icon, required this.text});

  final Glyph icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RoutingCard(
      child: Row(
        children: [
          GlyphIcon(
            icon,
            size: 18,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// A tinted square with an icon: the one shape on the page that marks a thing
/// with a state.
class RoutingBadge extends StatelessWidget {
  const RoutingBadge({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 38,
    this.busy = false,
  });

  final Glyph icon;
  final Color tone;
  final double size;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: AppShape.all(size / 2.8),
        color: tone.withValues(alpha: 0.14),
      ),
      child: busy
          ? SizedBox.square(
              dimension: size * 0.44,
              child: CommonCircleLoading(color: tone),
            )
          : GlyphIcon(icon, size: size * 0.5, color: tone),
    );
  }
}

/// A short reading rides the label's line; a sentence-long one drops under it,
/// so a ledger of mixed counts and phrases never wraps to a ragged right edge.
class RoutingStat extends StatelessWidget {
  const RoutingStat({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  static double _measure(String text, TextStyle? style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final labelStyle = context.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final valueStyle = context.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: valueColor ?? colorScheme.onSurface,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        const gap = 16.0;
        final fits =
            _measure(label, labelStyle, scaler) +
                gap +
                _measure(value, valueStyle, scaler) <=
            constraints.maxWidth;
        if (fits) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              const SizedBox(width: gap),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: valueStyle,
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: AppSpacing.xxs),
            Text(value, style: valueStyle),
          ],
        );
      },
    );
  }
}

/// A single big number over its caption, so one count reads the same wherever
/// it sits.
class RoutingTile extends StatelessWidget {
  const RoutingTile({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
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

/// Number tiles laid two to a row, reading as a small board of counts.
class RoutingTileGrid extends StatelessWidget {
  const RoutingTileGrid({super.key, required this.tiles});

  final List<({String value, String label, Color? color})> tiles;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < tiles.length; index += 2) {
      final left = tiles[index];
      final right = index + 1 < tiles.length ? tiles[index + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RoutingTile(
                value: left.value,
                label: left.label,
                valueColor: left.color,
              ),
            ),
            Expanded(
              child: right == null
                  ? const SizedBox.shrink()
                  : RoutingTile(
                      value: right.value,
                      label: right.label,
                      valueColor: right.color,
                    ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.lg),
          rows[index],
        ],
      ],
    );
  }
}

/// The latency reading as a pill tinted in the server's own delay colour.
class RoutingDelayPill extends StatelessWidget {
  const RoutingDelayPill({super.key, required this.delay, this.approx = false});

  final int delay;
  final bool approx;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.delayColor(delay) ?? context.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.14),
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          approx ? '≈$delay ms' : '$delay ms',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: approx ? FontWeight.w500 : FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// A muted caption inside a card, above a run of chips or rows.
class RoutingCaption extends StatelessWidget {
  const RoutingCaption({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}

class RoutingHairline extends StatelessWidget {
  const RoutingHairline({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
  );
}

/// A fold whose collapsed state still says what is inside, so only the evidence
/// costs a tap.
class RoutingDisclosure extends StatefulWidget {
  const RoutingDisclosure({
    super.key,
    required this.label,
    required this.child,
    this.summary,
  });

  final String label;
  final Widget child;
  final String? summary;

  @override
  State<RoutingDisclosure> createState() => _RoutingDisclosureState();
}

class _RoutingDisclosureState extends State<RoutingDisclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final summary = widget.summary;
    final expandDuration = context.motionDuration(
      const Duration(milliseconds: 180),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: AppRadius.sm,
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: expandDuration,
                  curve: Curves.easeOutCubic,
                  child: GlyphIcon(
                    AppGlyphs.chevronDown,
                    size: 17,
                    color: colorScheme.primary,
                  ),
                ),
                if (summary != null && !_open) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        expandDuration == Duration.zero
            ? (_open
                  ? widget.child
                  : const SizedBox(width: double.infinity, height: 0))
            : AnimatedSize(
                duration: expandDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _open
                    ? widget.child
                    : const SizedBox(width: double.infinity, height: 0),
              ),
      ],
    );
  }
}

class RoutingCandidateList extends StatelessWidget {
  const RoutingCandidateList({
    super.key,
    required this.rows,
    required this.technical,
  });

  final List<RcxCandidateReport> rows;
  final bool technical;

  /// Above this many rows the list takes its own bounded scroll area rather than
  /// pushing the rest of the page a screenful down; a deep scan sweeps hundreds.
  static const _inlineLimit = 8;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          context.appLocalizations.smartRoutingEmpty,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    Widget rowAt(int index) =>
        RoutingCandidateRow(candidate: rows[index], technical: technical);
    if (rows.length <= _inlineLimit) {
      return Column(children: List.generate(rows.length, rowAt));
    }
    return Container(
      height: 280,
      margin: const EdgeInsets.only(top: 2),
      decoration: ShapeDecoration(
        shape: AppShape.sm,
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        // The page's own scroll view already owns the primary controller.
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: rows.length,
        itemBuilder: (_, index) => rowAt(index),
      ),
    );
  }
}

class RoutingCandidateRow extends StatelessWidget {
  const RoutingCandidateRow({
    super.key,
    required this.candidate,
    required this.technical,
  });

  final RcxCandidateReport candidate;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final muted = colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    final eligible = candidate.eligible;
    final hosted = candidate.delay <= 0 && candidate.hostDelay > 0;
    final delay = hosted ? candidate.hostDelay : candidate.delay;
    final tags = <String>[
      if (candidate.breaker) appLocalizations.smartRoutingBreaker,
      if (candidate.degraded) appLocalizations.smartRoutingDegraded,
      if (technical && candidate.region.isNotEmpty) candidate.region,
      if (technical && candidate.origin != 'unknown')
        routingOriginLabel(appLocalizations, candidate.origin),
      if (technical &&
          (candidate.trust == 'branded' || candidate.trust == 'suspect'))
        candidate.trust,
      if (technical && candidate.coolFor > 0)
        appLocalizations.smartRoutingCoolFor(candidate.coolFor),
      if (technical && hosted) appLocalizations.smartRoutingHostDelay,
      if (technical && delay > 0)
        appLocalizations.smartRoutingBandLabel(candidate.band),
      if (technical && !candidate.udp) appLocalizations.smartRoutingNodeNoUdp,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GlyphIcon(
            candidate.current
                ? AppGlyphs.checkCircle
                : eligible
                ? AppGlyphs.circleOutline
                : AppGlyphs.block,
            size: 15,
            color: candidate.current
                ? colorScheme.primary
                : eligible
                ? colorScheme.onSurfaceVariant
                : colorScheme.error.withValues(alpha: 0.7),
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
                    style: context.textTheme.bodySmall?.copyWith(
                      color: eligible
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: candidate.current ? FontWeight.w600 : null,
                    ),
                  ),
                ),
                Text(
                  [
                    eligible
                        ? routingEvidenceLabel(
                            appLocalizations,
                            candidate.evidence,
                          )
                        : routingBlockLabel(appLocalizations, candidate),
                    ...tags,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            switch (delay) {
              > 0 when hosted => '≈$delay ms',
              > 0 => '$delay ms',
              _ when candidate.block == 'disproven' || candidate.coolFor > 0 =>
                appLocalizations.smartRoutingNoAnswer,
              _ => appLocalizations.smartRoutingUntested,
            },
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: hosted || delay <= 0 ? null : FontWeight.w600,
              color: delay > 0
                  ? (colorScheme.delayColor(delay) ?? colorScheme.onSurfaceVariant)
                  : muted,
            ),
          ),
        ],
      ),
    );
  }
}

class RoutingCanaryRow extends StatelessWidget {
  const RoutingCanaryRow({
    super.key,
    required this.canary,
    required this.technical,
  });

  final RcxCanaryReport canary;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final muted = colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          GlyphIcon(
            canary.answered ? AppGlyphs.checkCircle : AppGlyphs.removeCircle,
            size: 16,
            color: canary.answered ? colorScheme.primary : muted,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TooltipText(
              text: Text(
                canary.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
            ),
          ),
          if (technical) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              canary.domestic
                  ? appLocalizations.smartRoutingCanaryDomestic
                  : appLocalizations.smartRoutingCanaryForeign,
              style: context.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          Text(
            canary.answered
                ? '${canary.delay} ms'
                : canary.forged
                ? appLocalizations.smartRoutingEvidenceForeignForged
                : canary.measured
                ? appLocalizations.smartRoutingNoAnswer
                : appLocalizations.smartRoutingUntested,
            style: context.textTheme.labelSmall?.copyWith(
              color: canary.answered ? colorScheme.onSurfaceVariant : muted,
            ),
          ),
        ],
      ),
    );
  }
}
