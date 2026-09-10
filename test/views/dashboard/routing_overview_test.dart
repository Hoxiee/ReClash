import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/routing_details_tab.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview.dart';
import 'package:reclash/views/dashboard/widgets/routing_ranking_tab.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

const _report = RcxReport(
  status: RcxStatus(
    enabled: true,
    mode: 'rule',
    terrain: 'whitelist',
    node: 'Amsterdam #3',
    delay: 112,
    reason: 'verdict-gain',
    candidates: 3,
    eligible: 2,
  ),
  link: RcxLinkReport(
    transport: 'wifi',
    foreign: 'fail',
    domestic: 'ok',
    metered: true,
  ),
  canaries: [
    RcxCanaryReport(addr: '1.1.1.1:443', outcome: 'fail'),
    RcxCanaryReport(
      addr: '77.88.8.8:443',
      domestic: true,
      outcome: 'ok',
      delay: 24,
    ),
  ],
  candidates: [
    RcxCandidateReport(
      node: 'Amsterdam #3',
      country: 'NL',
      verdict: 'preferred',
      evidence: 'live',
      delay: 112,
      current: true,
    ),
    RcxCandidateReport(
      node: 'Frankfurt #1',
      verdict: 'viable',
      evidence: 'fresh',
      delay: 240,
    ),
    RcxCandidateReport(
      node: 'Paris #7',
      verdict: 'reject',
      evidence: 'none',
      block: 'cooling',
      hostDelay: 60,
      fails: 4,
    ),
  ],
  history: [
    RcxSwitchReport(
      from: 'Paris #7',
      to: 'Amsterdam #3',
      reason: 'incumbent-dead',
    ),
  ],
  metrics: RcxMetricsReport(
    enabledMillis: 7200000,
    availableMillis: 7140000,
    availability: 99,
    incidents: 3,
    standbyHits: 2,
    providerIncidents: 1,
    markerIncidents: 1,
    lastFailover: 2300,
    averageFailover: 4100,
    lastOutage: 2300,
    averageOutage: 4100,
    activeCircuits: ['provider-a'],
    activeMarkers: ['https://marker.example/'],
  ),
  probesLeft: 31,
  probeCap: 40,
);

const _lanes = [
  RcxLaneStatus(
    id: 'youtube-adfree',
    state: 'active',
    node: 'Amsterdam #3',
    candidates: 4,
    eligible: 2,
  ),
  RcxLaneStatus(id: 'gemini-access', state: 'fallback', fallback: 'reject'),
];

Future<void> _pump(
  WidgetTester tester, {
  required bool enabled,
  RcxReport? report,
  bool running = true,
}) async {
  final container = ProviderContainer(
    overrides: [
      smartRoutingSettingProvider.overrideWithValue(
        SmartRoutingProps(enabled: enabled),
      ),
      isStartProvider.overrideWithValue(running),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        includeNavigatorKey: false,
        setTheme: false,
        child: RoutingOverviewView(reportReader: () async => report),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDetails(WidgetTester tester) async {
  await tester.tap(find.text('Details'));
  await tester.pumpAndSettle();
}

Future<void> _openRanking(WidgetTester tester) async {
  await tester.tap(find.text('Ranking'));
  await tester.pumpAndSettle();
}

final _rankingScroll = find.descendant(
  of: find.byType(RoutingRankingTab),
  matching: find.byType(Scrollable),
);

Future<void> _toggleTechnical(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.code_rounded));
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    200,
    scrollable: _detailsScroll,
  );
  await tester.pumpAndSettle();
}

final _detailsScroll = find.descendant(
  of: find.byType(RoutingDetailsTab),
  matching: find.byType(Scrollable),
);

void main() {
  testWidgets('an engine that is off explains itself instead of showing rows', (
    tester,
  ) async {
    await _pump(tester, enabled: false, report: _report);

    expect(
      find.text('Turn smart routing on to let it pick servers for you'),
      findsOne,
    );
    expect(find.text('Amsterdam #3'), findsNothing);
  });

  testWidgets('a report the core has not answered yet reads as starting', (
    tester,
  ) async {
    await _pump(tester, enabled: true);

    expect(find.text('Picking a server…'), findsOne);
  });

  testWidgets('a stopped core waits for the tunnel instead of picking', (
    tester,
  ) async {
    await _pump(tester, enabled: true, running: false);

    expect(find.text('Smart routing is on · waiting for the tunnel'), findsOne);
  });

  testWidgets('reduced motion opens the disclosure without a ticker', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        smartRoutingSettingProvider.overrideWithValue(
          const SmartRoutingProps(enabled: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: TestApp(
            includeNavigatorKey: false,
            setTheme: false,
            child: RoutingOverviewView(reportReader: () async => _report),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 4));

    expect(tester.hasRunningAnimations, isFalse);
    await _openDetails(tester);
    await _reveal(tester, 'Link check');
    expect(tester.hasRunningAnimations, isFalse);
    await tester.tap(find.text('Link check'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    expect(find.text('1.1.1.1:443'), findsOne);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the chosen server comes with the reason it was chosen', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);

    expect(find.text('Amsterdam #3'), findsWidgets);
    expect(find.text('112 ms'), findsWidgets);
    expect(
      find.text('This one is proven to reach the open internet'),
      findsOne,
    );
    expect(find.text('Confirmed by your own traffic'), findsWidgets);
  });

  testWidgets('the network format names the facts behind it', (tester) async {
    await _pump(tester, enabled: true, report: _report);

    expect(find.text('Restricted'), findsOne);
    expect(
      find.text('Only local services answer, foreign ones do not'),
      findsOne,
    );
    expect(find.text('No foreign address answered'), findsOne);
    expect(find.text('A local address answered'), findsOne);
    expect(find.text('Metered link'), findsOne);
  });

  testWidgets('the park is shown as a whole, not as a list to read', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);

    await tester.scrollUntilVisible(
      find.text('2 of 3 servers can be used right now'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('2 of 3 servers can be used right now'), findsOne);
    await tester.scrollUntilVisible(
      find.text('31 of 40 probes left this hour'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('31 of 40 probes left this hour'), findsOne);
  });

  testWidgets('the canaries that produced the format are one tap away', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);

    await _openDetails(tester);

    await _reveal(tester, 'Link check');

    expect(find.text('1 of 2 answered'), findsOne);
    await tester.tap(find.text('Link check'));
    await tester.pumpAndSettle();

    expect(find.text('1.1.1.1:443'), findsOne);
    expect(find.text('no answer'), findsWidgets);
    expect(find.text('24 ms'), findsOne);
  });

  testWidgets('a link the canaries answered is not a tested server', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);

    await _openDetails(tester);

    await _reveal(tester, 'Server checks');

    expect(find.text('measured 2 of 3'), findsOne);
    await tester.tap(find.text('Server checks'));
    await tester.pumpAndSettle();

    expect(find.text('Frankfurt #1'), findsOne);
    expect(find.text('240 ms'), findsOne);
    expect(find.text('Paris #7'), findsNothing);
  });

  testWidgets('a server nobody probed still shows the delay test that has it', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await _openDetails(tester);
    await tester.scrollUntilVisible(
      find.text('All servers'),
      200,
      scrollable: _detailsScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All servers'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('≈60 ms'), findsOne);
    expect(find.text('untested'), findsNothing);
  });

  testWidgets('a blocked server states its gate, not a score', (tester) async {
    await _pump(tester, enabled: true, report: _report);
    await _openDetails(tester);
    await tester.scrollUntilVisible(
      find.text('All servers'),
      200,
      scrollable: _detailsScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All servers'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.textContaining('Cooling down after 4 failures'), findsOne);
  });

  testWidgets('local reliability shows recovery and active safeguards', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await _openDetails(tester);
    await tester.scrollUntilVisible(
      find.text('99% over 2 hours'),
      200,
      scrollable: _detailsScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('99% over 2 hours'), findsOne);
    expect(find.text('3 seconds'), findsOne);
    expect(find.text('5 seconds'), findsOne);
    expect(find.text('provider-a'), findsOne);
    expect(find.text('https://marker.example/'), findsOne);
  });

  testWidgets('a provider circuit states its gate instead of its verdict', (
    tester,
  ) async {
    final report = _report.copyWith(
      candidates: [
        ..._report.candidates,
        const RcxCandidateReport(
          node: 'Circuit node',
          verdict: 'preferred',
          block: 'provider-circuit',
        ),
      ],
    );
    await _pump(tester, enabled: true, report: report);
    await _openDetails(tester);
    await tester.scrollUntilVisible(
      find.text('All servers'),
      200,
      scrollable: _detailsScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All servers'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(
      find.text('Provider temporarily held back after independent failures'),
      findsOne,
    );
  });

  testWidgets('the decision is told as the sequence that produced it', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await _openDetails(tester);
    await tester.scrollUntilVisible(
      find.text('Ranked what was left'),
      200,
      scrollable: _detailsScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('Read the network'), findsOne);
    expect(find.text('2 of 3 servers passed, 1 were held back'), findsOne);
    expect(find.text('Landed here'), findsOne);
  });

  testWidgets('the last switch keeps its reason', (tester) async {
    await _pump(tester, enabled: true, report: _report);
    await _openDetails(tester);
    await tester.scrollUntilVisible(
      find.text('Paris #7 → Amsterdam #3'),
      200,
      scrollable: _detailsScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('Paris #7 → Amsterdam #3'), findsOne);
    expect(find.textContaining('Previous server stopped answering'), findsOne);
  });

  testWidgets('the overview names the services that got a route', (
    tester,
  ) async {
    await _pump(
      tester,
      enabled: true,
      report: _report.copyWith(status: _report.status.copyWith(lanes: _lanes)),
    );
    await tester.scrollUntilVisible(
      find.text('YouTube without ads'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Through Amsterdam #3'), findsOne);
    expect(find.text('2 of 4 servers ready'), findsOne);
    expect(find.text('Gemini access'), findsOne);
    expect(find.text('No specialist ready · service blocked'), findsOne);
  });

  testWidgets('a routing without service lanes says so instead of nothing', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await tester.scrollUntilVisible(
      find.text('No service routes are set up'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('No service routes are set up'), findsOne);
  });

  testWidgets('the technical toggle adds the engine state to the details', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await _openDetails(tester);

    expect(find.text('Terrain code'), findsNothing);
    await _toggleTechnical(tester);
    await tester.scrollUntilVisible(
      find.text('Terrain code'),
      200,
      scrollable: _detailsScroll,
    );

    expect(find.text('whitelist'), findsOne);
    expect(find.text('wifi'), findsOne);
    expect(find.text('rule'), findsOne);
    expect(find.text('Last switchover'), findsOne);
  });

  testWidgets('the ranking tab reads the ladder the strategy actually uses', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await _openRanking(tester);

    expect(find.text('Balanced'), findsOne);
    expect(find.text('Allowed to compete'), findsOne);
    expect(find.text('Fit for this network'), findsOne);
    expect(find.text('Stable tiebreak'), findsOne);
    expect(find.text('Reaches the open internet'), findsOne);
    expect(find.text('Does not fit'), findsOne);
  });

  testWidgets('lowest latency never ranks by a terrain fit it ignores', (
    tester,
  ) async {
    await _pump(
      tester,
      enabled: true,
      report: _report.copyWith(
        status: _report.status.copyWith(strategy: 'lowest-latency'),
      ),
    );
    await _openRanking(tester);

    expect(find.text('Lowest latency'), findsOne);
    expect(find.text('Fit for this network'), findsNothing);
    expect(find.text('Has carried traffic'), findsOne);
  });

  testWidgets('a rival names the line it lost on and both readings of it', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await _openRanking(tester);
    await tester.scrollUntilVisible(
      find.text('Frankfurt #1'),
      200,
      scrollable: _rankingScroll,
    );

    expect(find.text('Lost at: Verdict'), findsOne);
    expect(find.text('Usable vs Reaches the open internet'), findsOne);
  });

  testWidgets('a gated rival loses before any comparison is made', (
    tester,
  ) async {
    await _pump(tester, enabled: true, report: _report);
    await _openRanking(tester);
    await tester.scrollUntilVisible(
      find.text('Paris #7'),
      200,
      scrollable: _rankingScroll,
    );

    expect(find.text('Lost at: Allowed to compete'), findsOne);
    expect(find.text('Cooling down after 4 failures vs Allowed'), findsOne);
  });

  testWidgets(
    'a server held out of use is shown ranking above the one in use',
    (tester) async {
      await _pump(
        tester,
        enabled: true,
        report: _report.copyWith(
          status: _report.status.copyWith(reason: 'dwell-hold'),
          candidates: [
            const RcxCandidateReport(
              node: 'Amsterdam #3',
              verdict: 'viable',
              evidence: 'fresh',
              current: true,
            ),
            const RcxCandidateReport(
              node: 'Oslo #2',
              verdict: 'preferred',
              evidence: 'live',
            ),
          ],
        ),
      );
      await _openRanking(tester);

      expect(find.text('Ranks higher at: Verdict'), findsOne);
    },
  );

  testWidgets('a park of one states there is nothing to compare against', (
    tester,
  ) async {
    await _pump(
      tester,
      enabled: true,
      report: _report.copyWith(candidates: [_report.candidates.first]),
    );
    await _openRanking(tester);

    expect(find.text('No other servers to compare with'), findsOne);
  });
}
