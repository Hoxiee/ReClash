import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/views/proxies/routing_condition.dart';
import 'package:reclash/views/proxies/routing_scenario.dart';
import 'package:reclash/views/proxies/routing_studio.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _profileMap = <String, Object?>{
  'rcx': 1,
  'title': 'My EU servers',
  'level': 'simple',
  'prefer': [
    {'label': 'Premium', 'when': 'tag(premium) and not dead'},
    {'label': 'Working', 'when': 'not dead'},
  ],
};

class _FakeAction extends RcxRoutingAction {
  _FakeAction(this.lint);

  final RcxStudioResult lint;
  final requests = <Map<String, Object?>>[];
  final saved = <(String, RcxUserProfile?)>[];

  @override
  Future<RcxStudioResult?> studio(Map<String, Object?> request) async {
    requests.add(request);
    return switch (request['op']) {
      'lint' => lint,
      'cond' => const RcxStudioResult(
        text: 'not dead and exit.country in [DE, NL]',
        form: RcxCondForm(
          join: 'and',
          flat: true,
          clauses: [
            RcxClause(field: 'dead', negated: true),
            RcxClause(field: 'exit.country', op: 'in', values: ['DE', 'NL']),
          ],
        ),
        fields: [
          RcxField(name: 'name', kind: 'string', ops: ['=', '~']),
          RcxField(name: 'exit.country', kind: 'string', ops: ['in', '~']),
        ],
      ),
      _ => const RcxStudioResult(),
    };
  }

  @override
  Future<void> saveProfile(String name, RcxUserProfile? profile) async {
    saved.add((name, profile));
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _openPage(
  WidgetTester tester,
  _FakeAction action,
  Widget page,
) async {
  await tester.pumpWidget(
    TestApp(
      overrides: [rcxRoutingActionProvider.overrideWith(() => action)],
      homeBuilder: (_) => Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => page)),
          child: const Text('open'),
        ),
      ),
      child: const SizedBox.shrink(),
    ),
  );
  await tester.tap(find.text('open'));
  await _pumpFrames(tester);
}

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    l = await AppLocalizations.load(const Locale('en'));
  });

  group('rcxLineDiff', () {
    test('marks equal, removed and added lines in document order', () {
      expect(rcxLineDiff('a\nb\nc', 'a\nx\nc'), [
        (' ', 'a'),
        ('-', 'b'),
        ('+', 'x'),
        (' ', 'c'),
      ]);
    });

    test('appends trailing additions and removals', () {
      expect(rcxLineDiff('a', 'a\nb'), [(' ', 'a'), ('+', 'b')]);
      expect(rcxLineDiff('a\nb', 'a'), [(' ', 'a'), ('-', 'b')]);
    });
  });

  group('rcxFreeProfileName', () {
    test('slugs the title', () {
      expect(rcxFreeProfileName({}, 'My EU servers!'), 'my-eu-servers');
    });

    test('falls back to profile for non-Latin or empty titles', () {
      expect(rcxFreeProfileName({}, 'Мои серверы'), 'profile');
      expect(rcxFreeProfileName({}, ''), 'profile');
    });

    test('numbers names that are taken', () {
      expect(rcxFreeProfileName({'profile': 1}, ''), 'profile-2');
      expect(
        rcxFreeProfileName({'profile': 1, 'profile-2': 1}, ''),
        'profile-3',
      );
    });
  });

  group('rcxClauseText', () {
    test('reads a negated dead clause as Working', () {
      expect(
        rcxClauseText(l, const RcxClause(field: 'dead', negated: true)),
        l.rcxFieldAlive,
      );
    });

    test('joins list values', () {
      final text = rcxClauseText(
        l,
        const RcxClause(field: 'exit.country', op: 'in', values: ['DE', 'NL']),
      );
      expect(text, contains('DE, NL'));
    });

    test('shows a case-insensitive pattern as a regex literal', () {
      final text = rcxClauseText(
        l,
        const RcxClause(
          field: 'name',
          op: '~',
          values: ['de'],
          ignoreCase: true,
        ),
      );
      expect(text, contains('/de/i'));
    });
  });

  group('RcxProfileInfoExt', () {
    const info = RcxProfileInfo(
      id: 'user/x',
      title: 'Simple',
      l10n: {
        'zh-CN': {'Simple': 'A'},
        'ru': {'Simple': 'B'},
      },
    );

    test('localize prefers the full tag, then the language', () {
      expect(info.localize('Simple', 'zh_CN'), 'A');
      expect(info.localize('Simple', 'ru_RU'), 'B');
      expect(info.localize('Simple', 'de'), 'Simple');
    });

    test('displayTitle falls back to the id for an empty title', () {
      expect(info.displayTitle('ru'), 'B');
      expect(const RcxProfileInfo(id: 'user/x').displayTitle('ru'), 'user/x');
    });
  });

  group('rcxIssueText', () {
    test('words a coded issue with its line and arguments', () {
      final text = rcxIssueText(
        l,
        const RcxIssue(code: 'tag.unused', args: {'tag': 'x'}, line: 3),
      );
      expect(text, contains('3'));
      expect(text, contains('x'));
    });

    test('uses the message of an unknown code', () {
      expect(
        rcxIssueText(l, const RcxIssue(code: 'nope', message: 'raw message')),
        'raw message',
      );
    });
  });

  group('RoutingStudio', () {
    setUpAll(() async {
      await mockPreferences();
    });

    testWidgets('shows the tiers and saves under a name from the title', (
      tester,
    ) async {
      final action = _FakeAction(const RcxStudioResult(profile: _profileMap));
      await _openPage(
        tester,
        action,
        const RoutingStudio(text: 'rcx: 1\n', groupName: 'Proxy'),
      );

      expect(find.textContaining('Premium'), findsWidgets);
      expect(find.textContaining('Working'), findsWidgets);

      await tester.tap(find.byTooltip(l.save));
      await _pumpFrames(tester);
      await tester.pump(const Duration(seconds: 1));

      expect(action.saved, hasLength(1));
      expect(action.saved.single.$1, 'my-eu-servers');
      expect(action.saved.single.$2?.text, 'rcx: 1\n');
      expect(find.byType(RoutingStudio), findsNothing);
    });

    testWidgets('disables save and shows the first error', (tester) async {
      final action = _FakeAction(
        const RcxStudioResult(
          profile: _profileMap,
          errors: [RcxIssue(message: 'broken tier syntax')],
        ),
      );
      await _openPage(
        tester,
        action,
        const RoutingStudio(text: 'rcx: 1\n', groupName: 'Proxy'),
      );

      expect(find.text('broken tier syntax'), findsOneWidget);
      await tester.tap(find.byTooltip(l.save), warnIfMissed: false);
      await _pumpFrames(tester);

      expect(action.saved, isEmpty);
      expect(find.byType(RoutingStudio), findsOneWidget);
    });
  });

  group('ConditionEditor', () {
    testWidgets('choosing Any condition re-requests the form with join or', (
      tester,
    ) async {
      final action = _FakeAction(const RcxStudioResult());
      await _openPage(
        tester,
        action,
        const ConditionEditor(
          title: 'Condition',
          text: 'not dead',
          profile: {},
          network: false,
        ),
      );

      await tester.tap(find.text(l.rcxCondMatch));
      await _pumpFrames(tester);
      await tester.tap(find.text(l.rcxCondAny));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      final conds = action.requests.where((r) => r['op'] == 'cond').toList();
      expect(conds, hasLength(2));
      expect(conds.first['text'], 'not dead');
      expect((conds.last['form'] as Map)['join'], 'or');
    });

    testWidgets('picking a negated condition sends a negated clause', (
      tester,
    ) async {
      final action = _FakeAction(const RcxStudioResult());
      await _openPage(
        tester,
        action,
        const ConditionEditor(
          title: 'Condition',
          text: 'not dead',
          profile: {},
          network: false,
        ),
      );

      final negated = '${l.rcxCondNotPrefix} ${rcxOpLabel(l, 'in')}';
      await tester.tap(find.text(rcxOpLabel(l, 'in')));
      await _pumpFrames(tester);
      await tester.tap(find.text(negated));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      final conds = action.requests.where((r) => r['op'] == 'cond').toList();
      expect(conds, hasLength(2));
      final clauses = (conds.last['form'] as Map)['clauses'] as List;
      final clause = clauses[1] as RcxClause;
      expect(clause.op, 'in');
      expect(clause.negated, isTrue);
    });
  });

  group('ScenarioEditor', () {
    setUpAll(() async {
      await mockPreferences();
    });

    testWidgets('lists the groups and saves under a name from the title', (
      tester,
    ) async {
      final action = _FakeAction(
        const RcxStudioResult(
          scenario: {
            'rcx': 1,
            'title': 'Home',
            'groups': {
              r'$main': {'profile': 'builtin/fastest'},
              '*': {},
            },
          },
        ),
      );
      await _openPage(
        tester,
        action,
        const ScenarioEditor(text: 'rcx: 1\ntitle: Home\n'),
      );

      expect(find.text(l.rcxMainGroup), findsWidgets);
      expect(find.text(l.rcxAllGroups), findsWidgets);
      final lints = action.requests.where((r) => r['op'] == 'lint');
      expect(lints, isNotEmpty);
      expect(lints.every((r) => r['kind'] == 'scenario'), isTrue);

      await tester.tap(find.byTooltip(l.save));
      await _pumpFrames(tester);
      await tester.pump(const Duration(seconds: 1));

      expect(action.saved, hasLength(1));
      expect(action.saved.single.$1, 'home');
      expect(action.saved.single.$2?.kind, 'scenario');
    });
  });

  group('routing providers', () {
    late ProviderContainer container;

    ProviderContainer make([List<Profile> profiles = const []]) {
      final c = ProviderContainer(
        overrides: [
          coreStatusProvider.overrideWithValue(CoreStatus.disconnected),
          profilesProvider.overrideWith(() => TestProfiles(profiles)),
          currentProfileIdProvider.overrideWithBuild(
            (_, _) => profiles.firstOrNull?.id,
          ),
        ],
      );
      addTearDown(c.dispose);
      c.listen(rcxProfilesProvider, (_, _) {});
      c.listen(currentRoutingLayerProvider, (_, _) {});
      return c;
    }

    setUpAll(() async {
      await mockPreferences();
    });

    group('RcxRoutingAction.saveProfile', () {
      setUp(() => container = make());

      RcxRoutingAction action() =>
          container.read(rcxRoutingActionProvider.notifier);
      Map<String, RcxUserProfile> library() =>
          container.read(rcxProfilesProvider);

      test('keeps the replaced text as the newest history entry', () async {
        await action().saveProfile('p', const RcxUserProfile(text: 'v1'));
        await action().saveProfile('p', const RcxUserProfile(text: 'v2'));
        await action().saveProfile('p', const RcxUserProfile(text: 'v3'));

        expect(library()['p']!.text, 'v3');
        expect(library()['p']!.history.map((v) => v.text), ['v2', 'v1']);
      });

      test('does not add history for an unchanged text', () async {
        await action().saveProfile('p', const RcxUserProfile(text: 'v1'));
        await action().saveProfile('p', const RcxUserProfile(text: 'v1'));

        expect(library()['p']!.history, isEmpty);
      });

      test('caps history at rcxProfileHistory', () async {
        for (var i = 0; i < rcxProfileHistory + 5; i++) {
          await action().saveProfile('p', RcxUserProfile(text: 'v$i'));
        }

        final history = library()['p']!.history;
        expect(history, hasLength(rcxProfileHistory));
        expect(history.first.text, 'v${rcxProfileHistory + 3}');
      });

      test('removes the profile when saving null', () async {
        await action().saveProfile('p', const RcxUserProfile(text: 'v1'));
        await action().saveProfile('p', null);

        expect(library(), isNot(contains('p')));
      });
    });

    group('currentRoutingLayer', () {
      test('carries the library texts without a current profile', () {
        container = make();
        container.read(rcxProfilesProvider.notifier).value = {
          'a': const RcxUserProfile(text: 'text a'),
        };

        final layer = container.read(currentRoutingLayerProvider);
        expect(layer.profiles, {'a': 'text a'});
        expect(layer.providerHosts, isEmpty);
      });

      test('adds routing, library texts and provider hosts', () {
        final base = Profile.normal(
          label: 'sub',
          url: 'https://sub.example.com/token',
        );
        final profile = base.copyWith(
          overrides: base.overrides.copyWith(
            routing: const RcxUserLayer(trusted: ['t.example.org']),
          ),
          subscriptionSnapshot: SubscriptionSnapshot(
            metadata: const SubscriptionMetadata({
              'routing.bundleUrl': 'https://bundle.example.net/rcx.zip',
            }),
            receivedAt: DateTime(2026),
          ),
        );
        container = make([profile]);
        container.read(rcxProfilesProvider.notifier).value = {
          'a': const RcxUserProfile(text: 'text a'),
        };

        final layer = container.read(currentRoutingLayerProvider);
        expect(layer.trusted, ['t.example.org']);
        expect(layer.profiles, {'a': 'text a'});
        expect(layer.providerHosts, ['sub.example.com', 'bundle.example.net']);
      });
    });
  });
}
