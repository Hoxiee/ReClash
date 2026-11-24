import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/routing.dart';
import 'package:reclash/views/proxies/routing_route.dart';
import 'package:reclash/views/proxies/routing_scenario.dart';
import 'package:reclash/views/proxies/routing_studio.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _scenarioId = 'builtin/every-group';

const _status = RcxStatus(
  tunnelMode: 'rule',
  scenario: RcxScenarioStatus(
    id: _scenarioId,
    title: 'Every group',
    routes: [
      RcxRouteStatus(name: 'Video'),
      RcxRouteStatus(name: 'Bank', to: 'DIRECT'),
    ],
  ),
  groups: [
    RcxGroupStatus(
      name: 'Video',
      route: true,
      current: RcxCurrentNode(name: 'DE-1', exit: 'de', latencyMs: 80),
    ),
    RcxGroupStatus(
      name: 'Proxy',
      current: RcxCurrentNode(name: 'NL-2', latencyMs: 40),
    ),
  ],
);

const _library = [
  RcxProfileInfo(
    id: _scenarioId,
    kind: 'scenario',
    title: 'Every group',
    description: 'Each group picks its own server',
    source: 'builtin',
  ),
  RcxProfileInfo(id: 'builtin/fastest', title: 'Fastest', source: 'builtin'),
];

class _FixedStatus extends RcxStatusState {
  _FixedStatus(this.status);

  final RcxStatus? status;

  @override
  RcxStatus? build() => status;
}

class _FakeAction extends RcxRoutingAction {
  final requests = <Map<String, Object?>>[];
  final saved = <(String, RcxUserProfile?)>[];
  final scenarios = <String?>[];

  @override
  Future<RcxStudioResult?> studio(Map<String, Object?> request) async {
    requests.add(request);
    return switch (request['op']) {
      'source' => const RcxStudioResult(text: 'rcx: 1\ntitle: Every group\n'),
      'format' => const RcxStudioResult(text: 'rcx: 1\ntitle: Edited\n'),
      'lint' when request['kind'] == 'scenario' => const RcxStudioResult(
        scenario: {
          'rcx': 1,
          'title': 'Every group',
          'routes': [
            {
              'name': 'Video',
              'match': ['GEOSITE,youtube'],
            },
            {
              'name': 'Bank',
              'match': ['GEOSITE,bank'],
              'to': 'DIRECT',
            },
          ],
          'groups': {'*': {}},
        },
      ),
      _ => const RcxStudioResult(),
    };
  }

  @override
  Future<void> saveProfile(String name, RcxUserProfile? profile) async {
    saved.add((name, profile));
  }

  @override
  Future<void> setScenario(String? id) async {
    scenarios.add(id);
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Finder _text(String text) => find.text(text, findRichText: true);

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    await mockPreferences();
    l = await AppLocalizations.load(const Locale('en'));
  });

  Future<_FakeAction> pumpHub(
    WidgetTester tester, {
    Size size = const Size(412, 915),
    List<RcxProfileInfo> library = _library,
    RcxStatus? status = _status,
    Profile profile = const Profile(id: 1, autoUpdateDuration: Duration.zero),
    Widget view = const RoutingScenariosView(),
    Widget Function(Widget child)? wrap,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final action = _FakeAction();
    await tester.pumpWidget(
      TestApp(
        overrides: [
          coreStatusProvider.overrideWithValue(CoreStatus.connected),
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => 1),
          rcxStatusStateProvider.overrideWith(() => _FixedStatus(status)),
          rcxLibraryProvider.overrideWith((_) async => library),
          rcxRoutingActionProvider.overrideWith(() => action),
        ],
        child: wrap?.call(view) ?? view,
      ),
    );
    await _pumpFrames(tester);
    return action;
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const PageStorageKey('routing-routes')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
    await tester.pump();
  }

  Future<void> openLibrary(WidgetTester tester, {bool scenarios = true}) async {
    final row = find.text(scenarios ? l.rcxHubLibrary : l.rcxGroupProfiles);
    if (scenarios) await reveal(tester, row);
    await tester.tap(row);
    await _pumpFrames(tester);
  }

  testWidgets('the scenarios page shows routes and their live selections', (
    tester,
  ) async {
    await pumpHub(tester);

    expect(find.byType(GlyphSegmentedControl<int>), findsNothing);
    expect(_text('Each group picks its own server'), findsOneWidget);
    expect(_text('Video'), findsOneWidget);
    expect(find.textContaining('DE-1', findRichText: true), findsOneWidget);
    expect(_text('Bank'), findsOneWidget);
    expect(find.textContaining('NL-2', findRichText: true), findsNothing);
    await reveal(tester, find.text(l.rcxHubLibrary));
    expect(find.text(l.rcxHubLibrary), findsOneWidget);
  });

  testWidgets('scripted groups have their own page', (tester) async {
    await pumpHub(tester, view: const ScriptedGroupsView());

    expect(_text('Proxy'), findsOneWidget);
    expect(find.textContaining('NL-2', findRichText: true), findsOneWidget);
    expect(_text('Video'), findsNothing);
    expect(_text(l.rcxHubAuto), findsNothing);
  });

  testWidgets('scripted groups name the missing core', (tester) async {
    await pumpHub(tester, view: const ScriptedGroupsView(), status: null);

    expect(find.text(l.rcxHubNeedsCore), findsOneWidget);
    expect(find.text(l.rcxGroupProfiles), findsNothing);
  });

  for (final scenario in [true, false]) {
    testWidgets(
      'the compact library opens a new ${scenario ? 'scenario' : 'profile'} without overflow actions',
      (tester) async {
        final action = await pumpHub(
          tester,
          size: const Size(320, 740),
          library: const [],
          view: scenario
              ? const RoutingScenariosView()
              : const ScriptedGroupsView(),
        );
        expect(find.byTooltip(l.more), findsNothing);

        await openLibrary(tester, scenarios: scenario);

        final create = find.text(scenario ? l.rcxNewScenario : l.rcxNewProfile);
        expect(create.hitTestable(), findsOneWidget);
        expect(
          find.text(scenario ? l.rcxNewProfile : l.rcxNewScenario),
          findsNothing,
        );
        expect(find.text(l.import).hitTestable(), findsOneWidget);
        expect(find.byType(SegmentedControl<bool>), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(create);
        await _pumpFrames(tester);

        expect(
          find.byType(scenario ? ScenarioEditor : RoutingStudio),
          findsOneWidget,
        );
        expect(action.saved, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('library creation actions stay in the owning workspace', (
    tester,
  ) async {
    final opened = <Widget>[];
    late final Widget Function(Widget) scope;
    scope = (child) => PageNavigationScope(
      canOpen: (_) => false,
      open: (_) {},
      push: <T>(context, page) async {
        if (page is RoutingLibraryView) {
          return Navigator.of(
            context,
          ).push<T>(MaterialPageRoute(builder: (_) => scope(page)));
        }
        opened.add(page);
        return null;
      },
      child: child,
    );
    await pumpHub(tester, size: const Size(320, 740), wrap: scope);
    await openLibrary(tester);

    await tester.tap(find.text(l.rcxNewScenario).hitTestable());
    await _pumpFrames(tester);
    expect(opened, [isA<ScenarioEditor>()]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the library keeps import available when it is empty', (
    tester,
  ) async {
    await pumpHub(tester, library: const []);
    await openLibrary(tester);
    await tester.tap(find.text(l.import));
    await _pumpFrames(tester);

    expect(find.text(l.clipboardImport), findsOneWidget);
    expect(find.text(l.importFile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a library tap opens a scenario for editing', (tester) async {
    final action = await pumpHub(
      tester,
      library: [
        ..._library,
        const RcxProfileInfo(
          id: 'builtin/whitelist',
          kind: 'scenario',
          title: 'Whitelists',
          source: 'builtin',
        ),
      ],
    );
    await openLibrary(tester);
    expect(_text('Fastest'), findsNothing);

    await tester.tap(_text('Whitelists').hitTestable());
    await _pumpFrames(tester);
    expect(action.scenarios, isEmpty);
    expect(find.byType(ScenarioEditor), findsOneWidget);
  });

  testWidgets('advanced settings open both RCX pages', (tester) async {
    await pumpHub(tester, view: const AdvancedConfigView());

    expect(find.text(l.rcxScenarios), findsOneWidget);
    expect(find.text(l.rcxSmartGroups), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('turning scenarios back on resumes the last choice', (
    tester,
  ) async {
    final action = await pumpHub(
      tester,
      status: const RcxStatus(),
      profile: Profile.normal().copyWith(
        id: 1,
        overrides: const ProfileOverrides(
          routing: RcxUserLayer(scenario: _scenarioId),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('master')).last);
    await _pumpFrames(tester);

    expect(action.scenarios, [_scenarioId]);
  });

  testWidgets('enabling scenarios requires a choice', (tester) async {
    final action = await pumpHub(tester, status: const RcxStatus());

    await tester.tap(find.text(l.rcxHubAuto));
    await _pumpFrames(tester);
    expect(find.text(l.rcxHubChange), findsOneWidget);
    expect(action.scenarios, isEmpty);

    await tester.tap(_text('Every group').hitTestable());
    await _pumpFrames(tester);
    expect(action.scenarios, [_scenarioId]);
  });

  testWidgets('rarer scenario settings open on their own pages', (
    tester,
  ) async {
    await pumpHub(tester);

    expect(find.text(l.rcxAddGroup), findsNothing);
    await reveal(tester, _text(l.rcxHubOtherGroups));
    await tester.tap(_text(l.rcxHubOtherGroups));
    await _pumpFrames(tester);

    expect(find.text(l.rcxAddGroup), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final fromButton in [false, true]) {
    testWidgets(
      'adding a group from the ${fromButton ? 'button' : 'row'} keeps the menu anchored to the button',
      (tester) async {
        await pumpHub(tester);
        await reveal(tester, _text(l.rcxHubOtherGroups));
        await tester.tap(_text(l.rcxHubOtherGroups));
        await _pumpFrames(tester);
        await tester.pumpAndSettle();

        final row = find.byKey(const ValueKey('add-group'));
        final button = find.descendant(
          of: row,
          matching: find.byType(EntryButton),
        );
        final anchor = tester.getRect(button);
        await tester.tap(fromButton ? button : find.text(l.rcxAddGroup));
        await _pumpFrames(tester);
        final menu = find.byType(CommonPopupMenu);
        final route = ModalRoute.of(tester.element(menu))! as CommonPopupRoute;
        expect(route.anchorOf(), anchor);
        await tester.tap(
          find.descendant(of: menu, matching: find.text('GLOBAL')),
        );
        await _pumpFrames(tester);
        await _pumpFrames(tester);
        expect(find.byType(CommonPopupMenu), findsNothing);
        expect(
          tester.widget<RouteEditor>(find.byType(RouteEditor)).target,
          'GLOBAL',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('the master switch turns the scenario off', (tester) async {
    final action = await pumpHub(tester);

    await tester.tap(find.byKey(const ValueKey('master')).last);
    await _pumpFrames(tester);

    expect(action.scenarios, [null]);
  });

  testWidgets('the first edit of a built-in scenario runs a copy', (
    tester,
  ) async {
    final action = await pumpHub(tester);

    expect(_text('Video'), findsOneWidget);
    expect(
      action.requests.where((r) => r['op'] == 'source').single['id'],
      _scenarioId,
    );

    await tester.tap(_text(l.rcxHubEverythingElse));
    await _pumpFrames(tester);
    await tester.tap(find.byTooltip(l.save));
    await _pumpFrames(tester);

    expect(find.text(l.rcxHubCopyTitle), findsOneWidget);
    await tester.tap(find.text(l.rcxHubCopyConfirm));
    await _pumpFrames(tester);

    expect(action.saved, hasLength(1));
    final (name, profile) = action.saved.single;
    expect(profile?.kind, 'scenario');
    expect(profile?.from, _scenarioId);
    expect(action.scenarios, ['user/$name']);
    expect(action.requests.where((r) => r['op'] == 'format'), hasLength(1));
  });
}
