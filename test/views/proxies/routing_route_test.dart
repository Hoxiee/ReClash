import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/proxies/routing_match.dart';
import 'package:reclash/views/proxies/routing_route.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';

class _FakeAction extends RcxRoutingAction {
  final requests = <Map<String, Object?>>[];

  @override
  Future<RcxStudioResult?> studio(Map<String, Object?> request) async {
    requests.add(request);
    return const RcxStudioResult();
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    await mockPreferences();
    l = await AppLocalizations.load(const Locale('en'));
  });

  group('match entries', () {
    test('round-trip a rule head with its no-resolve flag', () {
      const head = 'IP-CIDR,10.0.0.0/8,no-resolve';
      final entry = rcxMatchEntry(head);

      expect(entry.type, 'IP-CIDR');
      expect(entry.value, '10.0.0.0/8');
      expect(entry.noResolve, isTrue);
      expect(rcxMatchHead(entry), head);
    });

    test('reject a value the type cannot hold', () {
      expect(rcxMatchError(l, 'DOMAIN-SUFFIX', ''), l.required);
      expect(rcxMatchError(l, 'IP-CIDR', 'example.com'), l.rcxMatchInvalid);
      expect(rcxMatchError(l, 'IP-CIDR', '10.0.0.0/8'), isNull);
      expect(rcxMatchError(l, 'DOMAIN-SUFFIX', 'example.com'), isNull);
    });

    test('summarize services by name and own entries by value', () {
      final telegram = rcxTrafficPresets.firstWhere(
        (preset) => preset.label == 'Telegram',
      );

      expect(rcxTrafficSummary(l, const []), l.rcxMatchNone);
      expect(rcxTrafficSummary(l, telegram.heads), 'Telegram');
      expect(
        rcxTrafficSummary(l, [...telegram.heads, 'DOMAIN-SUFFIX,t.me']),
        l.rcxMatchMore('Telegram', 1),
      );
      expect(rcxTrafficName(telegram.heads), telegram.routeName);
      expect(rcxTrafficName(const ['DOMAIN,example.com']), '');
    });
  });

  group('rcxProgramSummary', () {
    test('names a fixed destination before any ladder', () {
      expect(rcxProgramSummary(l, const {'to': 'DIRECT'}), l.direct);
      expect(rcxProgramSummary(l, const {'to': 'US'}), l.rcxFixedOn('US'));
      expect(rcxProgramSummary(l, const {}), l.rcxCondAnyServer);
    });
  });

  group('RouteEditor', () {
    Future<void> open(
      WidgetTester tester,
      Map<String, Object?> value, {
      Set<String> taken = const {},
    }) async {
      tester.view.physicalSize = const Size(412, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TestApp(
          overrides: [rcxRoutingActionProvider.overrideWith(_FakeAction.new)],
          homeBuilder: (_) => Builder(
            builder: (context) => TextButton(
              onPressed: () => editRoute(
                context,
                value: value,
                scenario: const {'rcx': 1},
                taken: taken,
              ),
              child: const Text('open'),
            ),
          ),
          child: const SizedBox.shrink(),
        ),
      );
      await tester.tap(find.text('open'));
      await _pumpFrames(tester);
    }

    testWidgets('sends a route direct and drops its ladder', (tester) async {
      Map<String, Object?>? result;
      await tester.pumpWidget(
        TestApp(
          overrides: [rcxRoutingActionProvider.overrideWith(_FakeAction.new)],
          homeBuilder: (_) => Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await editRoute(
                  context,
                  value: const {
                    'name': 'Video',
                    'match': ['GEOSITE,youtube'],
                    'prefer': [
                      {'when': 'not dead'},
                    ],
                  },
                  scenario: const {'rcx': 1},
                );
              },
              child: const Text('open'),
            ),
          ),
          child: const SizedBox.shrink(),
        ),
      );
      await tester.tap(find.text('open'));
      await _pumpFrames(tester);

      await tester.ensureVisible(find.text(l.rcxSendDirect).first);
      await _pumpFrames(tester);
      await tester.tap(find.text(l.rcxSendDirect).first);
      await _pumpFrames(tester);
      await tester.tap(find.byTooltip(l.save));
      await _pumpFrames(tester);

      expect(result, {
        'name': 'Video',
        'match': ['GEOSITE,youtube'],
        'to': 'DIRECT',
      });
    });

    testWidgets('deletes a route it was opened on', (tester) async {
      Map<String, Object?>? result;
      await tester.pumpWidget(
        TestApp(
          overrides: [rcxRoutingActionProvider.overrideWith(_FakeAction.new)],
          homeBuilder: (_) => Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await editRoute(
                  context,
                  value: const {
                    'name': 'Video',
                    'match': ['GEOSITE,youtube'],
                  },
                  scenario: const {'rcx': 1},
                  deletable: true,
                );
              },
              child: const Text('open'),
            ),
          ),
          child: const SizedBox.shrink(),
        ),
      );
      await tester.tap(find.text('open'));
      await _pumpFrames(tester);

      await tester.tap(find.byTooltip(l.delete));
      await _pumpFrames(tester);

      expect(result, isEmpty);
    });

    testWidgets('keeps the best server when picking one server is dismissed', (
      tester,
    ) async {
      await open(tester, const {
        'name': 'Video',
        'match': ['GEOSITE,youtube'],
      });

      await tester.tap(find.text(l.rcxRouteSendFixed));
      await _pumpFrames(tester);
      expect(find.text(l.rcxRouteTarget), findsOneWidget);
      await tester.binding.handlePopRoute();
      await _pumpFrames(tester);
      await _pumpFrames(tester);

      expect(find.text(l.rcxRouteTarget), findsNothing);
      expect(find.text(l.rcxHowToChoose), findsOneWidget);
    });

    testWidgets('picks the server on its own page', (tester) async {
      await open(tester, const {
        'name': 'Video',
        'match': ['GEOSITE,youtube'],
      });

      await tester.tap(find.text(l.rcxHowToChoose));
      await _pumpFrames(tester);

      expect(find.text(l.rcxBehaviour), findsOneWidget);
      expect(find.text(l.rcxPoolExclude), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('refuses a name another route or group holds', (tester) async {
      await open(
        tester,
        const {
          'name': 'Proxy',
          'match': ['GEOSITE,youtube'],
        },
        taken: const {'Proxy'},
      );

      expect(find.text(l.existsTip('Proxy')), findsOneWidget);
    });
  });
}
