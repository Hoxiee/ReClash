import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/connection/dns_queries.dart';
import 'package:reclash/widgets/base/scroll.dart';
import 'package:reclash/widgets/feedback/null_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

DnsQuery _query({
  required String domain,
  String type = 'A',
  DnsQueryInitiator? initiator = DnsQueryInitiator.app,
  String upstream = 'https://1.1.1.1/dns-query',
  bool cached = false,
  List<String> answers = const ['93.184.216.34'],
  String rcode = 'NOERROR',
  String error = '',
  int delay = 12,
  DateTime? time,
}) {
  return DnsQuery(
    domain: domain,
    type: type,
    initiator: initiator,
    upstream: upstream,
    cached: cached,
    answers: answers,
    rcode: rcode,
    error: error,
    delay: delay,
    time: time ?? DateTime.utc(2026),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));
  });

  tearDown(() => container.dispose());

  void seedQueries(List<DnsQuery> queries) {
    final notifier = container.read(dnsQueriesProvider.notifier);
    notifier.value = FixedList<DnsQuery>(500);
    for (final query in queries) {
      notifier.addDnsQuery(query);
    }
  }

  Future<void> pumpQueries(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DnsQueriesView()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('shows the empty state without any query', (tester) async {
    await pumpQueries(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('renders the queries already in the store on mount', (
    tester,
  ) async {
    seedQueries([_query(domain: 'alpha.test'), _query(domain: 'beta.test')]);

    await pumpQueries(tester);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('a query arriving after mount reaches the list', (tester) async {
    seedQueries([_query(domain: 'alpha.test')]);

    await pumpQueries(tester);
    expect(find.textContaining('gamma.test'), findsNothing);

    container
        .read(dnsQueriesProvider.notifier)
        .addDnsQuery(_query(domain: 'gamma.test'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('gamma.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('opening a query reveals its detail sheet', (tester) async {
    seedQueries([_query(domain: 'alpha.test', type: 'AAAA')]);

    await pumpQueries(tester);

    await tester.tap(find.textContaining('alpha.test').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('AAAA'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('following pauses when the list is scrolled off its head and '
      'resumes when it is scrolled back', (tester) async {
    seedQueries([for (var i = 0; i < 60; i++) _query(domain: 'd$i.test')]);

    await pumpQueries(tester);
    await tester.pumpAndSettle();

    final box = find.byType(ScrollToEndBox<DnsQuery>);
    bool following() => tester.widget<ScrollToEndBox<DnsQuery>>(box).enable;
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(following(), isTrue);

    // The list is reversed, so its head is the end of the scroll extent and
    // an upward drag moves away from it.
    await tester.drag(box, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(following(), isFalse);

    await tester.drag(box, const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(following(), isTrue);

    await teardownView(tester);
  });
}
