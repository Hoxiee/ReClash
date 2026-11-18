import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/proxies/routing_ladder.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';

Override _advanced(bool on) => appSettingProvider.overrideWithBuild(
  (_, _) => AppSettingProps(routingAdvanced: on),
);

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    await mockPreferences();
    l = await AppLocalizations.load(const Locale('en'));
  });

  for (final fromButton in [false, true]) {
    testWidgets(
      'adding a condition from the ${fromButton ? 'button' : 'row'} keeps the menu anchored to the button',
      (tester) async {
        await tester.pumpWidget(
          TestApp(
            overrides: [_advanced(true)],
            child: const RoutingStepEditor(
              step: null,
              number: 1,
              scope: {},
              scenario: false,
              groupName: null,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final label = find.text(l.rcxCondAdd);
        await tester.ensureVisible(label);
        await tester.pumpAndSettle();
        final row = find.ancestor(of: label, matching: find.byType(FormRow));
        final button = find.descendant(
          of: row,
          matching: find.byType(EntryButton),
        );
        final anchor = tester.getRect(button);
        await tester.tap(fromButton ? button : label);
        await tester.pumpAndSettle();
        final menu = find.byType(CommonPopupMenu);
        final route = ModalRoute.of(tester.element(menu))! as CommonPopupRoute;
        expect(route.anchorOf(), anchor);
        await tester.tap(
          find.descendant(of: menu, matching: find.text(l.rcxFieldUdp)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CommonPopupMenu), findsNothing);
        expect(find.text(l.rcxFieldUdp), findsOneWidget);
        expect(label, findsOneWidget);
        await tester.tap(label);
        await tester.pumpAndSettle();
        expect(find.byType(CommonPopupMenu), findsOneWidget);
        expect(
          find.descendant(of: menu, matching: find.text(l.rcxFieldUdp)),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final advanced in [false, true]) {
    testWidgets('step editor shows power-user rows only when advanced is '
        '$advanced', (tester) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [_advanced(advanced)],
          child: const RoutingStepEditor(
            step: null,
            number: 1,
            scope: {},
            scenario: false,
            groupName: null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l.rcxLadderNameContains), findsOneWidget);
      expect(find.text(l.rcxTierLabel), findsOneWidget);
      expect(find.text(l.rcxCondAdd), advanced ? findsOneWidget : findsNothing);
      expect(
        find.text(l.rcxLastResort),
        advanced ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('step editor keeps a condition the step already uses', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [_advanced(false)],
        child: const RoutingStepEditor(
          step: {'when': 'udp and latency < 200'},
          number: 1,
          scope: {},
          scenario: false,
          groupName: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(l.rcxFieldUdp), findsOneWidget);
    expect(find.text(l.rcxCondAdd), findsNothing);
  });

  group('RcxStepQuery', () {
    test('reads ⚡ and * in a name as literal text', () {
      final bolt = RcxStepQuery.parse('country = RU and name ~ /⚡/');
      expect(bolt.name, '⚡');
      expect(bolt.countries, ['RU']);
      expect(bolt.other, isEmpty);
      expect(rcxConditionSummary(l, 'name ~ /⚡/'), l.rcxLadderNameHas('⚡'));

      final star = RcxStepQuery.parse(r'name ~ /\*/');
      expect(star.name, '*');
      expect(star.when, r'name ~ /\*/i');
      expect(RcxStepQuery.parse(star.when).name, '*');
    });

    test('unescapes literals and keeps real patterns as written', () {
      expect(RcxStepQuery.parse(r'name ~ /a\.b\+/i').name, 'a.b+');
      expect(RcxStepQuery.parse('name ~ /a.b/i').other, ['name ~ /a.b/i']);
      expect(RcxStepQuery.parse('name ~ /Fast/').other, ['name ~ /Fast/']);
    });
  });
}
