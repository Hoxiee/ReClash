import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/appearance/appearance.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_details_tab.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_diag.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_tab.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_ranking_tab.dart';
import 'package:reclash/widgets/widgets.dart';

export 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart'
    show
        routingBlockLabel,
        routingEvidenceLabel,
        routingReasonLabel,
        routingVerdictLabel;

/// Every line on both tabs comes from the key the core actually ranked by, so
/// the page cannot tell a different story than the routing it explains.
class RoutingLiveView extends ConsumerStatefulWidget {
  const RoutingLiveView({super.key, this.reportReader});

  @visibleForTesting
  final Future<RcxReport?> Function()? reportReader;

  @override
  ConsumerState<RoutingLiveView> createState() => _RoutingLiveViewState();
}

class _RoutingLiveViewState extends ConsumerState<RoutingLiveView>
    with WidgetsBindingObserver, ActivePollingMixin<RoutingLiveView> {
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
        : await ref.refresh(rcxReportProvider.future);
    if (report == null || !isCurrent()) {
      return;
    }
    setState(() => _report = report);
  }

  Future<void> _handleDeepScan() async {
    await _core.smartRoutingDeepScan();
    restartPolling();
  }

  void _handleLog() {
    showExtend(context, builder: (context) => const RoutingDiagView());
  }

  void _handleExportLog() {
    exportSmartRoutingLog(context.appLocalizations, core: _core);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final enabled = ref.watch(
      smartRoutingSettingProvider.select((state) => state.enabled),
    );
    final report = _report;
    final running = ref.watch(isStartProvider);
    final labelOverrides = ref.watch(
      smartRoutingSettingProvider.select((state) => state.labelOverrides),
    );
    return RoutingVocabularyScope(
      overrides: labelOverrides,
      child: CommonScaffold(
        title: appLocalizations.smartRoutingOverview,
        floatBody: true,
        actions: [
          CommonPopupBox(
            popupBuilder: (_) => CommonPopupMenu(
              items: [
                CommonPopupMenuItem(
                  glyph: _technical
                      ? AppGlyphs.checkCircle
                      : AppGlyphs.checkboxBlank,
                  label: appLocalizations.smartRoutingTechnical,
                  onPressed: () => setState(() => _technical = !_technical),
                ),
                CommonPopupMenuItem(
                  glyph: AppGlyphs.history,
                  label: appLocalizations.smartRoutingLog,
                  onPressed: _handleLog,
                ),
                CommonPopupMenuItem(
                  glyph: AppGlyphs.export,
                  label: appLocalizations.smartRoutingLogExport,
                  onPressed: _handleExportLog,
                ),
              ],
            ),
            targetBuilder: (open) => IconButton(
              tooltip: appLocalizations.smartRoutingMore,
              onPressed: () => open(),
              icon: const GlyphIcon(AppGlyphs.more),
            ),
          ),
        ],
        body: AppBarClearance(
          child: switch ((enabled, report)) {
            (false, _) => _notice(
              icon: AppGlyphs.pause,
              text: appLocalizations.smartRoutingOffHint,
            ),
            (true, null) => _notice(
              icon: running ? AppGlyphs.sync : AppGlyphs.hourglass,
              text: running
                  ? appLocalizations.smartRoutingSearching
                  : appLocalizations.smartRoutingWaitingTunnel,
            ),
            (true, final RcxReport report) => DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  SettingsTabs(
                    labels: [
                      appLocalizations.smartRoutingTabOverview,
                      appLocalizations.smartRoutingTabRanking,
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _overview(context, report),
                        _ranking(context, report),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }

  /// What the engine chose, the network it is on first because that is what the
  /// person most needs to see, then the round, service routes, park health, and
  /// — under the technical toggle — the raw engine state. The server-by-server
  /// ranking is its own tab: hundreds of rows have no place in this glance.
  Widget _overview(BuildContext context, RcxReport report) {
    final appLocalizations = context.appLocalizations;
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        routingSliver(
          RoutingVerdictCard(report: report, technical: _technical),
        ),
        routingHeader(appLocalizations.smartRoutingSectionNetwork),
        routingSliver(RoutingNetworkCard(report: report)),
        routingSliver(
          RoutingEvidenceCard(report: report, technical: _technical),
        ),
        routingHeader(appLocalizations.smartRoutingSectionRound),
        routingSliver(RoutingRoundCard(report: report, technical: _technical)),
        routingHeader(appLocalizations.smartRoutingServiceRoutes),
        routingSliver(RoutingLanesCard(report: report)),
        routingHeader(appLocalizations.smartRoutingSectionHealth),
        routingSliver(RoutingHealthCard(report: report)),
        routingSliver(
          RoutingScanCard(report: report, onDeepScan: _handleDeepScan),
        ),
        routingHeader(appLocalizations.smartRoutingSectionReliability),
        routingSliver(
          RoutingReliabilityCard(report: report, technical: _technical),
        ),
        routingHeader(appLocalizations.smartRoutingSectionHistory),
        routingSliver(RoutingHistoryCard(report: report)),
        if (_technical) ...[
          routingHeader(appLocalizations.smartRoutingSectionEngine),
          routingSliver(RoutingEngineCard(report: report)),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  /// Every rival against the chosen server, naming the rung it won or lost on.
  /// A lazy sliver list keeps a park of hundreds cheap: only the rows on screen
  /// are built, so this tab can be scrolled without the engine feeling it.
  Widget _ranking(BuildContext context, RcxReport report) {
    final appLocalizations = context.appLocalizations;
    final rows = report.candidates;
    final chosenIndex = rows.indexWhere((row) => row.current);
    final pickedIndex = chosenIndex >= 0
        ? chosenIndex
        : rows.isEmpty
        ? -1
        : 0;
    final chosen = pickedIndex < 0 ? null : rows[pickedIndex];
    final rivals = [
      for (var at = 0; at < rows.length; at++)
        if (at != pickedIndex) rows[at],
    ];
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
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

  Widget _notice({required Glyph icon, required String text}) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Align(
      alignment: Alignment.topCenter,
      child: RoutingNotice(icon: icon, text: text),
    ),
  );
}
