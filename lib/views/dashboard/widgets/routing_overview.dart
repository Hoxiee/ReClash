import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the engine decided and why, in four answers in the order they get asked:
/// what you are on, what kind of network this is, how much of the subscription is
/// alive, and how the last decision got there. Every line comes from the key the
/// core actually ranked by, so the page cannot tell a different story than the
/// routing it explains; the numbers the engine reasons in stay one tap away under
/// the technical toggle.
class RoutingOverviewView extends ConsumerStatefulWidget {
  const RoutingOverviewView({super.key, this.reportReader});

  @visibleForTesting
  final Future<RcxReport?> Function()? reportReader;

  @override
  ConsumerState<RoutingOverviewView> createState() =>
      _RoutingOverviewViewState();
}

class _RoutingOverviewViewState extends ConsumerState<RoutingOverviewView>
    with WidgetsBindingObserver, ActivePollingMixin<RoutingOverviewView> {
  RcxReport? _report;
  bool _technical = false;

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => const Duration(seconds: 3);

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final reader = widget.reportReader;
    final report = reader != null
        ? await reader()
        : await _core.smartRoutingReport();
    if (report == null || !isCurrent()) {
      return;
    }
    setState(() => _report = report);
  }

  Future<void> _handleDeepScan() async {
    await _core.smartRoutingDeepScan();
    restartPolling();
  }

  void _handleSettings() {
    showExtend(context, builder: (context) => const SmartRoutingView());
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final enabled = ref.watch(
      smartRoutingSettingProvider.select((state) => state.enabled),
    );
    final report = _report;
    return CommonScaffold(
      title: appLocalizations.smartRoutingOverview,
      actions: [
        IconButton(
          tooltip: appLocalizations.smartRoutingTechnical,
          isSelected: _technical,
          onPressed: () => setState(() => _technical = !_technical),
          icon: const Icon(Icons.code_rounded),
        ),
        IconButton(
          tooltip: appLocalizations.settings,
          onPressed: _handleSettings,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          if (!enabled)
            _sliver(
              _NoticeCard(
                icon: Icons.pause_circle_outline,
                text: appLocalizations.smartRoutingOffHint,
              ),
            )
          else if (report == null)
            _sliver(
              _NoticeCard(
                icon: Icons.autorenew_rounded,
                text: appLocalizations.smartRoutingSearching,
              ),
            )
          else ...[
            _sliver(_VerdictCard(report: report, technical: _technical)),
            _header(appLocalizations.smartRoutingSectionNetwork),
            _sliver(_NetworkCard(report: report, technical: _technical)),
            _header(appLocalizations.smartRoutingSectionHealth),
            _sliver(_HealthCard(report: report)),
            _sliver(_ScanCard(report: report, onDeepScan: _handleDeepScan)),
            _header(appLocalizations.smartRoutingSectionRound),
            _sliver(_RoundCard(report: report, technical: _technical)),
            _header(appLocalizations.smartRoutingSectionHistory),
            _sliver(_HistoryCard(report: report)),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

Widget _sliver(Widget child) => SliverPadding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
  sliver: SliverToBoxAdapter(child: child),
);

Widget _header(String title) => SliverPadding(
  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
  sliver: SliverToBoxAdapter(
    child: ListHeader(title: title, padding: EdgeInsets.zero),
  ),
);

String routingReasonLabel(AppLocalizations l10n, String reason) =>
    switch (reason) {
      'cold-start' => l10n.smartRoutingReasonColdStart,
      'hold' => l10n.smartRoutingReasonHold,
      'incumbent-dead' => l10n.smartRoutingReasonIncumbentDead,
      'verdict-gain' => l10n.smartRoutingReasonVerdictGain,
      'latency-gain' => l10n.smartRoutingReasonLatencyGain,
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
      _ => routingVerdictLabel(l10n, candidate.verdict),
    };

NetworkFormat _formatOf(RcxReport report) =>
    networkFormatOf(report.status.terrain);

Color _formatAccent(BuildContext context, NetworkFormat format) {
  final colorScheme = context.colorScheme;
  return switch (format) {
    NetworkFormat.open => colorScheme.primary,
    NetworkFormat.restricted || NetworkFormat.portal => colorScheme.tertiary,
    NetworkFormat.offline => colorScheme.error,
    NetworkFormat.unknown => colorScheme.onSurfaceVariant,
  };
}

IconData _formatIcon(NetworkFormat format) => switch (format) {
  NetworkFormat.open => Icons.public_rounded,
  NetworkFormat.restricted => Icons.shield_moon_rounded,
  NetworkFormat.portal => Icons.wifi_lock_rounded,
  NetworkFormat.offline => Icons.cloud_off_rounded,
  NetworkFormat.unknown => Icons.travel_explore_rounded,
};

class _Card extends StatelessWidget {
  const _Card({required this.child, this.accent});

  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final accent = this.accent;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.xl,
        color: accent == null
            ? context.colorScheme.surfaceContainerHigh
            : accent.withValues(alpha: 0.10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: child,
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// A tinted square with an icon: the one shape on the page that marks a thing
/// with a state.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.tone,
    this.size = 38,
    this.busy = false,
  });

  final IconData icon;
  final Color tone;
  final double size;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2.8),
        color: tone.withValues(alpha: 0.14),
      ),
      child: busy
          ? SizedBox.square(
              dimension: size * 0.44,
              child: CommonCircleLoading(color: tone),
            )
          : Icon(icon, size: size * 0.5, color: tone),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
  );
}

/// A fold whose collapsed state still says what is inside, so only the evidence
/// costs a tap.
class _Disclosure extends StatefulWidget {
  const _Disclosure({required this.label, required this.child, this.summary});

  final String label;
  final Widget child;
  final String? summary;

  @override
  State<_Disclosure> createState() => _DisclosureState();
}

class _DisclosureState extends State<_Disclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final summary = widget.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
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
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.expand_more_rounded,
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
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
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

/// The one card that has to read without reading the page.
class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.report, required this.technical});

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final status = report.status;
    final format = _formatOf(report);
    final chosen = report.candidates.firstWhereOrNull(
      (candidate) => candidate.current,
    );
    final failed =
        status.reason == 'stranded' || status.reason == 'no-candidate';
    final tone = failed ? colorScheme.error : _formatAccent(context, format);
    final ours = status.delay > 0 ? status.delay : chosen?.delay ?? 0;
    final delay = ours > 0 ? ours : chosen?.hostDelay ?? 0;
    final counts = routingCountsOf(report);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              _Badge(
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
                if (chosen.country.isNotEmpty) MetaChip(label: chosen.country),
                MetaChip(
                  label: chosen.breaker
                      ? appLocalizations.smartRoutingBreaker
                      : appLocalizations.smartRoutingNotBreaker,
                ),
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
          const _Hairline(),
          _Stat(
            label: appLocalizations.smartRoutingServers,
            value: '${counts.eligible} / ${counts.total}',
          ),
          _Stat(
            label: appLocalizations.smartRoutingSectionHistory,
            value: status.switchedAt > 0
                ? appLocalizations.smartRoutingSwitchedAgo(
                    heroDurationWords(_minutesSince(report, status.switchedAt)),
                  )
                : appLocalizations.smartRoutingNeverSwitched,
          ),
          if (report.manual)
            _Stat(
              label: appLocalizations.smartRoutingManualHold,
              value: appLocalizations.smartRoutingManualPinned,
            ),
          if (technical && status.env.isNotEmpty)
            _Stat(
              label: appLocalizations.smartRoutingEnvKey,
              value: status.env,
            ),
        ],
      ),
    );
  }
}

int _minutesSince(RcxReport report, int at) {
  final elapsed = report.at - at;
  return elapsed < 0 ? 0 : elapsed ~/ 60000;
}

/// The format, what it means for the person on it, and every measurement that
/// produced it — so a user who disagrees can see which one to distrust.
class _NetworkCard extends StatelessWidget {
  const _NetworkCard({required this.report, required this.technical});

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final format = _formatOf(report);
    final accent = _formatAccent(context, format);
    final link = report.link;
    final canaries = report.canaries;
    final answered = canaries.where((canary) => canary.answered).length;
    final probed = report.candidates
        .where((candidate) => candidate.delay > 0)
        .toList();
    final facts = <String>[
      if (link.portal) appLocalizations.smartRoutingEvidencePortal,
      if (link.validated)
        appLocalizations.smartRoutingEvidenceValidated
      else
        appLocalizations.smartRoutingEvidenceUnvalidated,
      if (link.foreignMeasured)
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
    return _Card(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              _Badge(icon: _formatIcon(format), tone: accent),
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
          if (canaries.isNotEmpty)
            _Disclosure(
              label: appLocalizations.smartRoutingWhatWasTested,
              summary: appLocalizations.smartRoutingCanariesAnswered(
                answered,
                canaries.length,
              ),
              child: Column(
                children: canaries
                    .map(
                      (canary) =>
                          _CanaryRow(canary: canary, technical: technical),
                    )
                    .toList(),
              ),
            ),
          // The canaries are fixed addresses dialled outside any tunnel, so
          // their answer says nothing about a server: the counts sit together
          // because reading one as the other is what makes the screen lie.
          if (report.candidates.isNotEmpty)
            _Disclosure(
              label: appLocalizations.smartRoutingNodeChecks,
              summary: appLocalizations.smartRoutingNodesMeasured(
                probed.length,
                report.candidates.length,
              ),
              child: _CandidateList(rows: probed, technical: technical),
            ),
        ],
      ),
    );
  }
}

class _CanaryRow extends StatelessWidget {
  const _CanaryRow({required this.canary, required this.technical});

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
          Icon(
            canary.answered
                ? Icons.check_circle_rounded
                : Icons.remove_circle_outline_rounded,
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
            const SizedBox(width: 8),
            Text(
              canary.domestic
                  ? appLocalizations.smartRoutingCanaryDomestic
                  : appLocalizations.smartRoutingCanaryForeign,
              style: context.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ],
          const SizedBox(width: 8),
          Text(
            canary.answered
                ? '${canary.delay} ms'
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

/// The one picture on the page: how much of the subscription is actually alive.
class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final counts = routingCountsOf(report);
    final proven = counts.eligible - counts.unknown;
    final blocked = colorScheme.error.withValues(alpha: 0.55);
    final idle = colorScheme.surfaceContainerHighest;
    return _Card(
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
          _Meter(
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
              _Legend(
                color: colorScheme.primary,
                label: appLocalizations.smartRoutingHealthUsable,
                count: proven < 0 ? 0 : proven,
              ),
              if (counts.unknown > 0)
                _Legend(
                  color: idle,
                  label: appLocalizations.smartRoutingHealthUnknown,
                  count: counts.unknown,
                ),
              _Legend(
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

typedef _MeterSegment = ({int weight, Color color});

/// One bar split by counts, rounded as a single shape so it reads as a whole
/// that is divided rather than three bars that touch.
class _Meter extends StatelessWidget {
  const _Meter({required this.segments, required this.empty});

  final List<_MeterSegment> segments;
  final Color empty;

  @override
  Widget build(BuildContext context) {
    final filled = segments.where((segment) => segment.weight > 0).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
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

class _Legend extends StatelessWidget {
  const _Legend({
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

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.report, required this.onDeepScan});

  final RcxReport report;
  final VoidCallback onDeepScan;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final running = report.status.searching;
    return _Card(
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

@immutable
class _StepData {
  const _StepData({
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
class _RoundCard extends StatelessWidget {
  const _RoundCard({required this.report, required this.technical});

  final RcxReport report;
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);
    return _Card(
      child: Column(
        children: List.generate(
          steps.length,
          (index) =>
              _StepTile(data: steps[index], last: index == steps.length - 1),
        ),
      ),
    );
  }

  List<_StepData> _steps(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final status = report.status;
    final counts = routingCountsOf(report);
    final format = _formatOf(report);
    final answered = report.canaries.where((canary) => canary.answered).length;
    final chosen = report.candidates.firstWhereOrNull(
      (candidate) => candidate.current,
    );
    final failed =
        status.reason == 'stranded' || status.reason == 'no-candidate';
    final bands = report.bands.isEmpty
        ? ''
        : appLocalizations.smartRoutingBands(
            report.bands.map((band) => '$band ms').join(' · '),
          );
    return [
      _StepData(
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
      _StepData(
        icon: Icons.filter_alt_outlined,
        title: appLocalizations.smartRoutingStepAdmit,
        body: appLocalizations.smartRoutingStepAdmitBody(
          counts.eligible,
          counts.total,
          counts.blocked,
        ),
      ),
      _StepData(
        icon: Icons.sort_rounded,
        title: appLocalizations.smartRoutingStepRank,
        body: [
          appLocalizations.smartRoutingStepRankBody,
          if (technical && bands.isNotEmpty) bands,
        ].join(' · '),
        childLabel: appLocalizations.smartRoutingRankOrder,
        child: const _RankOrder(),
      ),
      _StepData(
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
        child: _CandidateList(rows: report.candidates, technical: technical),
      ),
    ];
  }
}

/// The comparison order, spelled out: the first line that differs between two
/// servers is the reason one of them won.
class _RankOrder extends StatelessWidget {
  const _RankOrder();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final rows = [
      appLocalizations.smartRoutingKeyVerdict,
      appLocalizations.smartRoutingKeyMisfit,
      appLocalizations.smartRoutingKeyEvidence,
      appLocalizations.smartRoutingKeyBand,
      appLocalizations.smartRoutingKeyHistory,
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

class _StepTile extends StatelessWidget {
  const _StepTile({required this.data, required this.last});

  final _StepData data;
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
              child: _Badge(icon: data.icon, tone: tone, size: _railWidth),
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
                      _Disclosure(label: data.childLabel, child: child),
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

class _CandidateList extends StatelessWidget {
  const _CandidateList({required this.rows, required this.technical});

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
        _CandidateRow(candidate: rows[index], technical: technical);
    if (rows.length <= _inlineLimit) {
      return Column(children: List.generate(rows.length, rowAt));
    }
    return Container(
      height: 280,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.candidate, required this.technical});

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
      if (technical && candidate.country.isNotEmpty) candidate.country,
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
          Icon(
            candidate.current
                ? Icons.check_circle_rounded
                : eligible
                ? Icons.radio_button_unchecked
                : Icons.block_rounded,
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
          const SizedBox(width: 8),
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
                  ? (getDelayColor(delay) ?? colorScheme.onSurfaceVariant)
                  : muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.report});

  final RcxReport report;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final history = report.history.reversed.toList();
    if (history.isEmpty) {
      return _NoticeCard(
        icon: Icons.history_rounded,
        text: appLocalizations.smartRoutingHistoryEmpty,
      );
    }
    return _Card(
      child: Column(
        children: List.generate(history.length, (index) {
          final entry = history[index];
          return Column(
            children: [
              if (index > 0) const _Hairline(),
              _SwitchRow(entry: entry, at: report.at),
            ],
          );
        }),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.entry, required this.at});

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
