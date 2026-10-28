import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/config/routing.dart';
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
  @override
  RcxStatus? build() => _status;
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
          profilesProvider.overrideWith(
            () => TestProfiles(const [
              Profile(id: 1, autoUpdateDuration: Duration.zero),
            ]),
          ),
          currentProfileIdProvider.overrideWithBuild((_, _) => 1),
          rcxStatusStateProvider.overrideWith(_FixedStatus.new),
          rcxLibraryProvider.overrideWith((_) async => library),
          rcxRoutingActionProvider.overrideWith(() => action),
        ],
        child:
            wrap?.call(const RoutingSettingsView()) ??
            const RoutingSettingsView(),
      ),
    );
    await _pumpFrames(tester);
    return action;
  }

  Finder destination(String label) => find.descendant(
    of: find.byType(GlyphSegmentedControl<int>),
    matching: find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == label,
    ),
  );

  testWidgets('overview shows the scenario, its routes and the groups', (
    tester,
  ) async {
    await pumpHub(tester);

    expect(_text('Every group'), findsOneWidget);
    expect(_text('Each group picks its own server'), findsOneWidget);
    expect(_text('Video'), findsOneWidget);
    expect(find.textContaining('DE-1', findRichText: true), findsOneWidget);
    expect(_text('Bank'), findsOneWidget);
    expect(_text(l.direct), findsOneWidget);
    expect(find.textContaining('NL-2', findRichText: true), findsOneWidget);
  });

  for (final scenario in [true, false]) {
    testWidgets(
      'the compact library opens a new ${scenario ? 'scenario' : 'profile'} without overflow actions',
      (tester) async {
        final action = await pumpHub(
          tester,
          size: const Size(320, 740),
          library: const [],
        );
        expect(find.byTooltip(l.more), findsNothing);

        await tester.tap(destination(l.rcxHubLibrary));
        await _pumpFrames(tester);

        expect(find.text(l.rcxNewScenario).hitTestable(), findsOneWidget);
        expect(find.text(l.rcxNewProfile).hitTestable(), findsOneWidget);
        expect(find.text(l.import).hitTestable(), findsOneWidget);
        final importRow = find.ancestor(
          of: find.text(l.import),
          matching: find.byType(ListItem),
        );
        expect(
          tester.getTopLeft(find.byType(SegmentedControl<bool>)).dy,
          greaterThan(tester.getBottomLeft(importRow).dy),
        );
        expect(tester.takeException(), isNull);

        await tester.tap(
          find.text(scenario ? l.rcxNewScenario : l.rcxNewProfile),
        );
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
    await pumpHub(
      tester,
      size: const Size(320, 740),
      wrap: (child) => PageNavigationScope(
        canOpen: (_) => false,
        open: (_) {},
        push: <T>(context, page) async {
          opened.add(page);
          return null;
        },
        child: child,
      ),
    );
    await tester.tap(destination(l.rcxHubLibrary));
    await _pumpFrames(tester);

    await tester.tap(find.text(l.rcxNewScenario));
    await _pumpFrames(tester);
    expect(opened, [isA<ScenarioEditor>()]);

    await tester.tap(find.text(l.rcxNewProfile));
    await _pumpFrames(tester);
    expect(opened, [isA<ScenarioEditor>(), isA<RoutingStudio>()]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the library keeps import available when it is empty', (
    tester,
  ) async {
    await pumpHub(tester, library: const []);
    await tester.tap(destination(l.rcxHubLibrary));
    await _pumpFrames(tester);
    await tester.tap(find.text(l.import));
    await _pumpFrames(tester);

    expect(find.text(l.clipboardImport), findsOneWidget);
    expect(find.text(l.importFile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a library tap runs a scenario and the pencil edits it', (
    tester,
  ) async {
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
    await tester.tap(destination(l.rcxHubLibrary));
    await _pumpFrames(tester);

    await tester.tap(_text('Whitelists'));
    await _pumpFrames(tester);
    expect(action.scenarios, ['builtin/whitelist']);
    expect(find.byType(ScenarioEditor), findsNothing);

    await tester.tap(_text('Every group'));
    await _pumpFrames(tester);
    expect(action.scenarios, ['builtin/whitelist']);

    await tester.tap(find.byTooltip(l.rcxDuplicate).first);
    await _pumpFrames(tester);
    expect(find.byType(ScenarioEditor), findsOneWidget);
  });

  testWidgets('rarer scenario settings open on their own pages', (
    tester,
  ) async {
    await pumpHub(tester);
    await tester.tap(destination(l.rcxHubRoutes));
    await _pumpFrames(tester);

    expect(find.text(l.rcxAddGroup), findsNothing);
    await tester.ensureVisible(_text(l.rcxHubOtherGroups));
    await tester.tap(_text(l.rcxHubOtherGroups));
    await _pumpFrames(tester);

    expect(find.text(l.rcxAddGroup), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the master switch turns the scenario off', (tester) async {
    final action = await pumpHub(tester);

    await tester.tap(find.text(l.rcxHubAuto));
    await _pumpFrames(tester);

    expect(action.scenarios, [null]);
  });

  testWidgets('the first edit of a built-in scenario runs a copy', (
    tester,
  ) async {
    final action = await pumpHub(tester);
    await tester.tap(destination(l.rcxHubRoutes));
    await _pumpFrames(tester);

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
