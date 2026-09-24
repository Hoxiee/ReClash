import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/appearance/appearance.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_details_tab.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_tab.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_ranking_tab.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart'
    show
        routingBlockLabel,
        routingEvidenceLabel,
        routingReasonLabel,
        routingVerdictLabel;

/// Every line on both tabs comes from the key the core actually ranked by, so
/// the page cannot tell a different story than the routing it explains.
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
    final running = ref.watch(isStartProvider);
    return CommonScaffold(
      title: appLocalizations.smartRoutingOverview,
      floatBody: true,
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
      body: AppBarClearance(
        child: switch ((enabled, report)) {
          (false, _) => _notice(
            icon: Icons.pause_circle_outline,
            text: appLocalizations.smartRoutingOffHint,
          ),
          (true, null) => _notice(
            icon: running
                ? Icons.autorenew_rounded
                : Icons.hourglass_empty_rounded,
            text: running
                ? appLocalizations.smartRoutingSearching
                : appLocalizations.smartRoutingWaitingTunnel,
          ),
          (true, final RcxReport report) => DefaultTabController(
            length: 3,
            child: Column(
              children: [
                SettingsTabs(
                  labels: [
                    appLocalizations.smartRoutingTabOverview,
                    appLocalizations.smartRoutingTabDetails,
                    appLocalizations.smartRoutingTabRanking,
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      RoutingOverviewTab(
                        report: report,
                        technical: _technical,
                        onDeepScan: _handleDeepScan,
                      ),
                      RoutingDetailsTab(report: report, technical: _technical),
                      RoutingRankingTab(report: report),
                    ],
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }

  Widget _notice({required IconData icon, required String text}) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Align(
      alignment: Alignment.topCenter,
      child: RoutingNotice(icon: icon, text: text),
    ),
  );
}
