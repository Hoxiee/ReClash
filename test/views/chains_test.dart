import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_ui/common_button.dart' as prism;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/chains/band.dart';
import 'package:reclash/views/chains/editor.dart';
import 'package:reclash/views/chains/marks.dart';
import 'package:reclash/views/chains/page.dart';
import 'package:reclash/views/dashboard/simple/location_card.dart';
import 'package:reclash/views/proxies/list.dart';
import 'package:reclash/views/proxies/tab.dart';

import '../helpers/context_menu.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _chainGroup = 'RU 1 → NL 1';

const _chain = ProxyChain(
  id: 7,
  profileId: 0,
  name: _chainGroup,
  hops: ['RU 1', 'NL 1'],
);

class _FakeChainsAction extends ProxyChainsAction {
  static Map<String, ChainIssueCode> blocked = const {};
  static final List<(int, String)> replaced = [];
  static final List<int> tested = [];
  static final List<(int, bool)> offered = [];
  static final List<(int, bool)> enabled = [];

  @override
  Future<ChainInspection> inspect(
    List<String> hops, {
    int? slot,
    String? targetGroup,
  }) async => ChainInspection(blocked: slot == null ? const {} : blocked);

  @override
  Future<ChainDelay> testDelay(ProxyChain chain) async {
    tested.add(chain.id);
    return (entry: 40, chain: 210);
  }

  @override
  Future<ProxyChain> setOffered(ProxyChain chain, bool value) async {
    offered.add((chain.id, value));
    return chain.copyWith(offered: value);
  }

  @override
  Future<ProxyChain> setEnabled(ProxyChain chain, bool value) async {
    enabled.add((chain.id, value));
    return chain.copyWith(enabled: value);
  }

  @override
  Future<ProxyChain> replaceHop(
    ProxyChain chain,
    int hop,
    String replacement,
  ) async {
    replaced.add((hop, replacement));
    return chain;
  }
}

const _flagged = ProxyChain(
  id: 7,
  profileId: 0,
  name: '🇷🇺 RU 1 → 🇳🇱 NL 1',
  hops: ['🇷🇺 RU 1', '🇳🇱 NL 1'],
);

Group _main({bool withChain = true}) => Group(
  type: GroupType.Selector,
  name: 'Main',
  all: [
    if (withChain) const Proxy(name: _chainGroup, type: 'Selector'),
    const Proxy(name: 'RU 1', type: 'ss'),
    const Proxy(name: 'RU 4', type: 'ss'),
    const Proxy(name: 'NL 1', type: 'ss'),
    const Proxy(name: 'DE 1', type: 'ss'),
  ],
);

ChainReport _report({
  ChainStatus status = ChainStatus.ok,
  String group = _chainGroup,
}) => ChainReport(
  id: _chain.id,
  group: group,
  status: status,
  target: 'Main',
  issues: [
    if (status == ChainStatus.broken)
      const ChainIssue(
        hop: 0,
        code: ChainIssueCode.missingHop,
        suggest: ['RU 4'],
      ),
  ],
);

void main() {
  setUp(() {
    _FakeChainsAction.replaced.clear();
    _FakeChainsAction.tested.clear();
    _FakeChainsAction.offered.clear();
    _FakeChainsAction.enabled.clear();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget child, {
    List<Group>? groups,
    List<ProxyChain> chains = const [_chain],
    ChainReport? report,
    Map<String, String> selectedMap = const {},
    String? region,
  }) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    groups ??= [_main()];
    final profile = Profile.normal().copyWith(
      selectedMap: selectedMap,
      unfoldSet: const {'Main'},
    );
    final container = ProviderContainer(
      overrides: [
        viewModeProvider.overrideWithValue(ViewMode.mobile),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: groups),
        ),
        currentProfileChainsProvider.overrideWithValue(AsyncData(chains)),
        chainReportsProvider.overrideWithBuild((_, _) => {_chain.id: ?report}),
        chainsHintDismissedProvider.overrideWithBuild((_, _) => const {}),
        proxyChainsActionProvider.overrideWith(_FakeChainsAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(groupsProvider.notifier).value = groups;
    if (region != null) {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(regionCode: region));
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          homeBuilder: (child) => Scaffold(body: child),
          child: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  group('band', () {
    testWidgets('lists the chain above the servers of its group', (
      tester,
    ) async {
      await pump(tester, const ProxiesListView(), report: _report());

      expect(find.byType(ChainTile), findsOneWidget);
      final chains = tester.getTopLeft(find.text('Chains'));
      final servers = tester.getTopLeft(find.text('Servers'));
      final tile = tester.getTopLeft(find.byType(ChainTile));
      expect(chains.dy, lessThan(tile.dy));
      expect(tile.dy, lessThan(servers.dy));
      expect(find.text('All chains'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a broken chain says so on its tile', (tester) async {
      await pump(
        tester,
        const ProxiesListView(),
        report: _report(status: ChainStatus.broken),
      );

      expect(
        find.descendant(
          of: find.byType(ChainTile),
          matching: find.text('not working'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the first-contact card stays hidden', (tester) async {
      await pump(
        tester,
        const ProxiesListView(),
        groups: [_main(withChain: false)],
        chains: const [],
        region: 'RU',
      );

      expect(find.byType(ChainHintCard), findsNothing);
      expect(find.byType(ChainTile), findsNothing);
    });

    testWidgets('the first-contact card stays out of other regions', (
      tester,
    ) async {
      await pump(
        tester,
        const ProxiesListView(),
        groups: [_main(withChain: false)],
        chains: const [],
        region: 'DE',
      );

      expect(find.byType(ChainHintCard), findsNothing);
    });

    testWidgets('the main group page lists the chain above its servers', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pump(
        tester,
        ProxyGroupView(
          group: _main(),
          controller: controller,
          columns: 1,
          cardType: ProxyCardType.standard,
        ),
        report: _report(),
      );

      expect(find.byType(ChainTile), findsOneWidget);
      final chains = tester.getTopLeft(find.text('Chains'));
      final servers = tester.getTopLeft(find.text('Servers'));
      final tile = tester.getTopLeft(find.byType(ChainTile));
      expect(chains.dy, lessThan(tile.dy));
      expect(tile.dy, lessThan(servers.dy));
      expect(tester.takeException(), isNull);
    });
  });

  group('menu', () {
    testWidgets('a chain tile offers open, test, remove and turn off', (
      tester,
    ) async {
      await pump(tester, const ProxiesListView(), report: _report());

      await rightClick(tester, find.byType(ChainTile));
      await tester.pumpAndSettle();

      expect(find.text('Open chain'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Remove from servers'), findsOneWidget);
      expect(find.text('Turn off'), findsOneWidget);
    });

    testWidgets('test on a chain tile tests that chain', (tester) async {
      await pump(tester, const ProxiesListView(), report: _report());

      await rightClick(tester, find.byType(ChainTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(_FakeChainsAction.tested, [_chain.id]);
    });

    testWidgets('remove from servers on a chain tile unoffers the chain', (
      tester,
    ) async {
      await pump(tester, const ProxiesListView(), report: _report());

      await rightClick(tester, find.byType(ChainTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove from servers'));
      await tester.pumpAndSettle();

      expect(_FakeChainsAction.offered, [(_chain.id, false)]);
    });

    testWidgets('turn off on a chain tile disables the chain', (tester) async {
      await pump(tester, const ProxiesListView(), report: _report());

      await rightClick(tester, find.byType(ChainTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Turn off'));
      await tester.pumpAndSettle();

      expect(_FakeChainsAction.enabled, [(_chain.id, false)]);
    });
  });

  group('editor', () {
    testWidgets('shows the tested entry and path on the strip', (tester) async {
      await pump(tester, const ChainEditor(chain: _chain), report: _report());

      expect(find.text('entry · 40\u00A0ms'), findsOneWidget);
      expect(find.text('210\u00A0ms'), findsOneWidget);
    });

    testWidgets('a broken chain shows no Internet delay on the strip', (
      tester,
    ) async {
      await pump(
        tester,
        const ChainEditor(chain: _chain),
        report: _report(status: ChainStatus.broken),
      );

      expect(
        find.descendant(of: find.byType(RouteStrip), matching: find.text('—')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(RouteStrip),
          matching: find.text('210\u00A0ms'),
        ),
        findsNothing,
      );
    });

    testWidgets('offers the middle server only as a route row', (tester) async {
      await pump(tester, const ChainEditor(chain: _chain), report: _report());

      expect(find.text('Middle server'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RouteStrip),
          matching: find.byWidgetPredicate(
            (widget) => widget is GlyphIcon && widget.glyph == AppGlyphs.add,
          ),
        ),
        findsNothing,
      );
      expect(find.byTooltip('Middle server'), findsNothing);
    });

    testWidgets('a new chain is ready to save once both ends are picked', (
      tester,
    ) async {
      await pump(tester, const ChainEditor(), chains: const []);
      prism.IconButton save() => tester.widget<prism.IconButton>(
        find.ancestor(
          of: find.byTooltip('Save'),
          matching: find.byType(prism.IconButton),
        ),
      );
      expect(save().onPressed, isNull);

      await tester.tap(find.text('RU 1').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('NL 1').last);
      await tester.pumpAndSettle();

      expect(find.text('RU 1 → NL 1'), findsOneWidget);
      expect(save().onPressed, isNotNull);
      expect(find.text('Delete chain'), findsNothing);
    });

    testWidgets('an existing chain can be deleted', (tester) async {
      await pump(tester, const ChainEditor(chain: _chain), report: _report());

      expect(find.text('Delete chain'), findsOneWidget);
    });

    testWidgets('dims a candidate the Core blocks, with its reason', (
      tester,
    ) async {
      _FakeChainsAction.blocked = const {'DE 1': ChainIssueCode.loop};
      addTearDown(() => _FakeChainsAction.blocked = const {});
      await pump(tester, const ChainEditor(), chains: const []);

      expect(
        find.text('Entry is the server your device connects to.'),
        findsOneWidget,
      );
      final reason = find.text('Won’t fit: it is the server list itself');
      expect(reason, findsOneWidget);
      expect(
        find.ancestor(of: reason, matching: find.byType(Opacity)),
        findsWidgets,
      );
    });

    testWidgets('the strip of a saved chain tests its delay', (tester) async {
      await pump(tester, const ChainEditor(chain: _chain), report: _report());
      // The editor also tests once on open; only the menu's test is counted.
      _FakeChainsAction.tested.clear();

      await rightClick(tester, find.byType(RouteStrip));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(_FakeChainsAction.tested, [_chain.id]);
    });

    testWidgets('the strip of a new chain offers no menu', (tester) async {
      await pump(tester, const ChainEditor(), chains: const []);

      await rightClick(tester, find.byType(RouteStrip));
      await tester.pumpAndSettle();

      expect(find.byType(CommonPopupMenu), findsNothing);
    });
  });

  group('titles', () {
    testWidgets('an auto name lists its hops without their flags', (
      tester,
    ) async {
      final group = Group(
        type: GroupType.Selector,
        name: 'Main',
        all: [
          Proxy(name: _flagged.name, type: 'Selector'),
          const Proxy(name: '🇷🇺 RU 1', type: 'ss'),
          const Proxy(name: '🇳🇱 NL 1', type: 'ss'),
        ],
      );
      await pump(
        tester,
        const ProxiesListView(),
        groups: [group],
        chains: const [_flagged],
        report: _report(group: _flagged.name),
      );

      expect(
        find.descendant(
          of: find.byType(ChainTile),
          matching: find.text('RU 1 → NL 1'),
        ),
        findsOneWidget,
      );
      expect(find.text(_flagged.name), findsNothing);
    });

    test('a typed name shows as it is', () {
      expect(chainTitle(_flagged), 'RU 1 → NL 1');
      expect(
        chainTitle(_flagged.copyWith(name: '🏠 Home', nameAuto: false)),
        '🏠 Home',
      );
    });
  });

  group('home', () {
    testWidgets('a broken selected chain offers its suggestion', (
      tester,
    ) async {
      await pump(
        tester,
        const LocationCard(),
        report: _report(status: ChainStatus.broken),
        selectedMap: const {'Main': _chainGroup},
      );

      expect(find.text(_chainGroup), findsOneWidget);
      expect(find.text('“RU 1” left the subscription'), findsOneWidget);
      expect(find.text('Another server'), findsOneWidget);

      await tester.tap(find.text('Take “RU 4”'));
      await tester.pumpAndSettle();
      expect(_FakeChainsAction.replaced, [(0, 'RU 4')]);
    });

    testWidgets('a working chain gives no problem line', (tester) async {
      await pump(
        tester,
        const LocationCard(),
        report: _report(),
        selectedMap: const {'Main': _chainGroup},
      );

      expect(find.text(_chainGroup), findsOneWidget);
      expect(find.text('Another server'), findsNothing);
      expect(find.text('Sites see Netherlands'), findsOneWidget);
    });
  });

  group('page', () {
    testWidgets('a selected chain row names its entry and path delays', (
      tester,
    ) async {
      await pump(
        tester,
        const ChainsView(),
        report: _report(),
        selectedMap: const {'Main': _chainGroup},
      );

      final row = find.byType(ChainRow);
      expect(row, findsOneWidget);
      expect(
        find.descendant(
          of: row,
          matching: find.textContaining('entry 40\u00A0ms'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: row,
          matching: find.textContaining('path 210\u00A0ms'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('latency', () {
    testWidgets('a delay under the Russian locale is counted in мс', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(locale: Locale('ru'), child: ChainDelayText(delay: 120)),
      );

      expect(find.text('120\u00A0мс'), findsOneWidget);
      expect(find.text('120\u00A0ms'), findsNothing);
    });
  });
}
