import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/proxies/routing.dart';
import 'package:reclash/views/proxies/routing_ladder.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _status = RcxStatus(
  tunnelMode: 'rule',
  scenario: RcxScenarioStatus(
    id: 'builtin/every-group',
    title: 'Every group',
    routes: [RcxRouteStatus(name: 'Video')],
  ),
  groups: [
    RcxGroupStatus(
      name: 'Proxy',
      profile: 'builtin/fastest',
      source: 'user',
      now: 'NL-2',
      current: RcxCurrentNode(name: 'NL-2', latencyMs: 40),
    ),
    RcxGroupStatus(
      name: 'Video',
      profile: 'builtin/fastest',
      route: true,
      now: 'DE-1',
      current: RcxCurrentNode(name: 'DE-1', exit: 'de', latencyMs: 80),
    ),
    RcxGroupStatus(
      name: 'Manual',
      profile: 'builtin/fastest',
      source: 'user',
      control: RcxControl(mode: 'manual'),
      now: 'NL-1',
    ),
  ],
);

const _library = [
  RcxProfileInfo(
    id: 'builtin/fastest',
    title: 'Fastest',
    description: 'Always the quickest server',
    source: 'builtin',
  ),
];

const _inherited = {'label': 'Fast', 'when': 'latency < 200'};

// English titles of keys the ARB no longer defines, so no generated getter can name them.
const _retiredRowTitles = [
  'Add a pattern',
  'Availability checks',
  'Exit-country check',
  'Group settings',
  'Network diagnostics',
  'Network kinds',
  'Per-network changes',
  'Translations',
];

class _FixedStatus extends RcxStatusState {
  @override
  RcxStatus? build() => _status;
}

class _FakeAction extends RcxRoutingAction {
  _FakeAction({this.entries = const []});

  final List<RcxJournalEntry> entries;
  final bindings = <(String, RcxBinding?)>[];
  final actions = <(String, RcxAction, String?)>[];

  @override
  Future<void> setBinding(String groupName, RcxBinding? binding) async {
    bindings.add((groupName, binding));
  }

  @override
  Future<bool> act(String groupName, RcxAction action, {String? node}) async {
    actions.add((groupName, action, node));
    return true;
  }

  @override
  Future<RcxExplanation?> explain(String groupName) async => null;

  @override
  Future<List<RcxJournalEntry>> journal(String groupName) async => entries;

  @override
  Future<RcxStudioResult?> studio(Map<String, Object?> request) async {
    return switch (request['op']) {
      'source' => const RcxStudioResult(text: 'rcx: 1\ntitle: Fastest\n'),
      'lint' => const RcxStudioResult(
        profile: {
          'rcx': 1,
          'title': 'Fastest',
          'prefer': [_inherited],
        },
      ),
      _ => const RcxStudioResult(),
    };
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
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

  Future<_FakeAction> pumpSheet(
    WidgetTester tester,
    String group, {
    List<RcxJournalEntry> entries = const [],
  }) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final action = _FakeAction(entries: entries);
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
          rcxLibraryProvider.overrideWith((_) async => _library),
          rcxRoutingActionProvider.overrideWith(() => action),
        ],
        child: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => unawaited(showRoutingSheet(context, group)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _pumpFrames(tester);
    return action;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    // The sheet's app bar floats over the top of its list.
    unawaited(Scrollable.ensureVisible(tester.element(finder), alignment: 0.5));
    await _pumpFrames(tester);
    await tester.tap(finder);
    await _pumpFrames(tester);
  }

  testWidgets('the segmented control switches who controls the group', (
    tester,
  ) async {
    final action = await pumpSheet(tester, 'Proxy');
    expect(_text(l.rcxModeAutoHint), findsOneWidget);

    await tester.tap(_text(l.rcxModeManual));
    await _pumpFrames(tester);
    await tester.tap(_text(l.rcxPinnedLabel));
    await _pumpFrames(tester);

    expect(action.actions, [
      ('Proxy', RcxAction.manual, null),
      ('Proxy', RcxAction.pin, 'NL-2'),
    ]);
  });

  testWidgets('a plain selector can be given a scripted binding', (
    tester,
  ) async {
    final action = await pumpSheet(tester, 'Plain');
    expect(_text(l.rcxMakeSmart), findsOneWidget);

    await tester.tap(_text(l.rcxMakeSmart));
    await _pumpFrames(tester);
    expect(action.bindings, [
      ('Plain', const RcxBinding(profile: rcxDefaultProfile)),
    ]);
  });

  testWidgets('removes scripted selection for a user binding', (tester) async {
    final action = await pumpSheet(tester, 'Proxy');
    expect(_text(l.rcxTurnOff), findsNothing);
    await tester.tap(find.byGlyph(AppGlyphs.more));
    await _pumpFrames(tester);
    await tester.tap(_text(l.rcxTurnOff));
    await _pumpFrames(tester);

    expect(action.bindings, [('Proxy', null)]);
  });

  testWidgets('the server order row opens the group order and saves it', (
    tester,
  ) async {
    final action = await pumpSheet(tester, 'Proxy');
    await tapVisible(tester, _text(l.rcxLadderTitle));

    final ladder = tester.widget<RoutingLadderSection>(
      find.byType(RoutingLadderSection),
    );
    expect(ladder.steps, isEmpty);
    expect(ladder.inherited, [_inherited]);

    ladder.onChanged([
      {'label': 'Near', 'when': 'country = NL'},
    ]);
    await _pumpFrames(tester);

    final (name, binding) = action.bindings.single;
    expect(name, 'Proxy');
    expect(binding?.profile, 'builtin/fastest');
    expect(binding?.prefer, [
      const RcxTier(label: 'Near', when: 'country = NL'),
    ]);
  });

  testWidgets('a route group says where it comes from instead of turning off', (
    tester,
  ) async {
    await pumpSheet(tester, 'Video');

    expect(_text(l.rcxRouteGroup), findsOneWidget);
    expect(_text(l.rcxRouteGroupHint('Every group')), findsOneWidget);
    await tester.tap(find.byGlyph(AppGlyphs.more));
    await _pumpFrames(tester);
    expect(_text(l.rcxScenarios), findsOneWidget);
    expect(_text(l.rcxTurnOff), findsNothing);
  });

  testWidgets('manual control hides the server choice and the change row', (
    tester,
  ) async {
    await pumpSheet(tester, 'Manual');

    expect(_text(l.rcxModeManualHint), findsOneWidget);
    expect(_text(l.rcxHowToChoose), findsNothing);
    expect(_text(l.rcxLadderTitle), findsNothing);
    expect(_text(l.rcxChangeServer), findsNothing);
  });

  testWidgets('the header opens the history, and no retired row shows', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      'Proxy',
      entries: [
        RcxJournalEntry(
          seq: 1,
          at: DateTime.utc(2026),
          group: 'Proxy',
          kind: 'switch',
          from: 'NL-1',
          to: 'NL-2',
        ),
      ],
    );

    expect(_text(l.rcxChangeServer), findsOneWidget);
    for (final title in _retiredRowTitles) {
      expect(_text(title), findsNothing);
    }

    expect(_text(l.rcxHistory), findsNothing);
    await tester.tap(find.byTooltip(l.rcxHistory));
    await _pumpFrames(tester);
    expect(_text(l.rcxHistory), findsOneWidget);
  });
}
