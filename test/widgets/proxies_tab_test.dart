import 'package:reclash/common/desktop/system.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/proxies/tab.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

final _tabStateProvider = NotifierProvider<_TabStateNotifier, ProxiesTabState>(
  _TabStateNotifier.new,
);

class _TabStateNotifier extends Notifier<ProxiesTabState> {
  @override
  ProxiesTabState build() => _tabState([_group('B'), _group('C')]);

  void set(ProxiesTabState value) => state = value;
}

void main() {
  late ProviderContainer globalContainer;
  late ProviderSubscription<Profile?> currentProfileSubscription;

  setUp(() {
    final profile = Profile.normal().copyWith(currentGroupName: 'B');
    globalContainer = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: [_group('A'), _group('B'), _group('C')]),
        ),
        proxiesTabStateProvider.overrideWith(
          (ref) => ref.watch(_tabStateProvider),
        ),
      ],
    );
    globalState.container = globalContainer;
    currentProfileSubscription = globalContainer.listen(
      currentProfileProvider,
      (_, _) {},
    );
  });

  tearDown(() {
    currentProfileSubscription.close();
    globalContainer.dispose();
  });

  Future<GlobalKey<ProxiesTabViewState>> pumpTabView(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) async {
    final key = GlobalKey<ProxiesTabViewState>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: globalContainer,
        child: TestApp(
          child: ProxiesTabView(key: key),
          homeBuilder: (child) => MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump();
    return key;
  }

  testWidgets('TV tab and active list share one traversal boundary', (
    tester,
  ) async {
    system.isTVForTesting = true;
    addTearDown(() => system.isTVForTesting = false);

    await pumpTabView(tester);

    final column = tester.widget<Column>(
      find
          .ancestor(of: find.byType(TabBar), matching: find.byType(Column))
          .last,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is FocusTraversalGroup && identical(widget.child, column),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ProxyGroupView),
        matching: find.byType(FocusTraversalGroup),
      ),
      findsNothing,
    );
  });

  testWidgets('non-TV tab adds no traversal boundary', (tester) async {
    system.isTVForTesting = false;

    await pumpTabView(tester);

    final column = tester.widget<Column>(
      find
          .ancestor(of: find.byType(TabBar), matching: find.byType(Column))
          .last,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is FocusTraversalGroup && identical(widget.child, column),
      ),
      findsNothing,
    );
  });

  testWidgets('current group follows the rendered tab list', (tester) async {
    final key = await pumpTabView(tester);

    expect(key.currentState?.currentGroup?.name, 'B');

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    tabBar.controller?.animateTo(1);
    await tester.pumpAndSettle();

    expect(key.currentState?.currentGroup?.name, 'C');
    expect(globalContainer.read(currentProfileProvider)?.currentGroupName, 'C');
  });

  testWidgets(
    'keeps the outgoing tab bar usable while the empty state enters',
    (tester) async {
      final key = await pumpTabView(tester);

      globalContainer.read(_tabStateProvider.notifier).set(_tabState([]));
      await tester.pump();

      expect(find.byType(TabBar), findsOneWidget);
      await tester.tap(find.byType(Tab).at(1), warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(key.currentState?.currentGroup, isNull);

      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('scrollToGroupSelected jumps under reduced motion', (
    tester,
  ) async {
    globalContainer
        .read(_tabStateProvider.notifier)
        .set(_tabState([_group('B', proxyCount: 40), _group('C')]));
    final key = await pumpTabView(tester, disableAnimations: true);
    final grid = tester.widget<GridView>(
      find.descendant(
        of: find.byType(ProxyGroupView).first,
        matching: find.byType(GridView),
      ),
    );
    final position = grid.controller!.position;
    expect(position.maxScrollExtent, greaterThan(0));
    expect(position.pixels, 0);

    key.currentState?.scrollToGroupSelected();
    final jumpedTo = position.pixels;
    await tester.pump(const Duration(milliseconds: 16));

    expect(jumpedTo, greaterThan(0));
    expect(position.pixels, jumpedTo);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'delay test button hides during the run and restores in finally',
    (tester) async {
      var clicks = 0;
      await tester.pumpWidget(
        TestApp(
          homeBuilder: (child) => MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: child),
          ),
          child: DelayTestButton(
            onClick: () async {
              clicks++;
              await Future<void>.delayed(const Duration(milliseconds: 50));
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(DelayTestButton));
      await tester.pump();
      expect(clicks, 1);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.hasRunningAnimations, isFalse);

      // The control stays operable after the run, so a second tap works.
      await tester.tap(find.byType(DelayTestButton));
      await tester.pumpAndSettle();
      expect(clicks, 2);
    },
  );

  testWidgets('a failing healthcheck still restores the button', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(body: child),
        ),
        child: DelayTestButton(
          onClick: () async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            throw Exception('core died');
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(DelayTestButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('rebuilds the tab bar when groups return', (tester) async {
    final key = await pumpTabView(tester);

    globalContainer.read(_tabStateProvider.notifier).set(_tabState([]));
    await tester.pumpAndSettle();
    globalContainer
        .read(_tabStateProvider.notifier)
        .set(_tabState([_group('A'), _group('B'), _group('C')]));
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.length, 3);
    expect(key.currentState?.currentGroup?.name, 'B');
    expect(tester.takeException(), isNull);
  });
}

ProxiesTabState _tabState(List<Group> groups) {
  return ProxiesTabState(
    groups: groups,
    currentGroupName: 'B',
    proxyCardType: ProxyCardType.expand,
  );
}

Group _group(String name, {int proxyCount = 0}) {
  return Group(
    type: GroupType.Selector,
    name: name,
    all: [
      for (var index = 0; index < proxyCount; index++)
        Proxy(name: '$name-$index', type: 'Direct'),
    ],
  );
}
