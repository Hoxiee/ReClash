import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/features/form/rule_preset.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/clash_config.dart';
import 'package:reclash/providers/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  group('RulePreset', () {
    test('every raw rule round-trips through Rule.parse', () {
      for (final preset in RulePreset.values) {
        for (final raw in preset.rawRules) {
          final rule = Rule.parse(raw);
          expect(rule.rawValue, raw, reason: preset.name);
          expect(rule.payloadError, isNull, reason: preset.name);
        }
      }
    });

    test('regional presets use the matching country catalog', () {
      const expected = {
        RulePreset.russiaDirect: [
          'GEOSITE,category-ru,DIRECT',
          'GEOIP,RU,DIRECT,no-resolve',
        ],
        RulePreset.iranDirect: [
          'GEOSITE,category-ir,DIRECT',
          'GEOIP,IR,DIRECT,no-resolve',
        ],
        RulePreset.chinaDirect: [
          'GEOSITE,cn,DIRECT',
          'GEOIP,CN,DIRECT,no-resolve',
        ],
        RulePreset.egyptDirect: ['GEOIP,EG,DIRECT,no-resolve'],
      };
      for (final entry in expected.entries) {
        expect(entry.key.rawRules, entry.value);
        expect(entry.key.rawRules, directRulesForCode(entry.key.regionCode));
      }
    });

    test('blockQuic drops UDP on 443 through a logic rule', () {
      final rule = Rule.parse(RulePreset.blockQuic.rawRules.single);

      expect(rule.content, '((NETWORK,UDP),(DST-PORT,443))');
      expect(rule.ruleTarget, 'REJECT-DROP');
    });
  });

  for (final preset in [
    RulePreset.russiaDirect,
    RulePreset.iranDirect,
    RulePreset.chinaDirect,
    RulePreset.egyptDirect,
  ]) {
    testWidgets('${preset.name} scrolls, cancels and adds only on confirm', (
      tester,
    ) async {
      final added = <List<Rule>>[];
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          overrides: [
            viewSizeProvider.overrideWithBuild((_, _) => const Size(800, 600)),
          ],
          child: Builder(
            builder: (context) => FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RulePresetSheet(onAdd: added.add),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      final l10n = AppLocalizations.current;
      for (var round = 0; round < 2; round++) {
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byTooltip(l10n.confirm), findsNothing);
        final label = find.text(preset.label(l10n));
        await tester.scrollUntilVisible(label, 250);
        await tester.tap(label);
        await tester.pump();
        expect(added, isEmpty);
        if (round == 0) {
          await tester.pageBack();
        } else {
          await tester.tap(find.byTooltip(l10n.confirm));
        }
        await tester.pumpAndSettle();
      }
      expect(added, hasLength(1));
      expect(added.single.map((rule) => rule.rawValue), preset.rawRules);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('adds the selected presets in order only on confirm', (
    tester,
  ) async {
    final added = <List<Rule>>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 800)),
        ],
        child: Builder(
          builder: (context) => FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RulePresetSheet(onAdd: added.add),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    final l10n = AppLocalizations.current;
    final confirm = find.byTooltip(l10n.confirm);

    for (var round = 0; round < 2; round++) {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(confirm, findsNothing);

      await tester.tap(find.text(l10n.rulePresetLanDirect));
      await tester.tap(find.text(l10n.rulePresetBlockQuic));
      await tester.pump();
      expect(added, hasLength(round), reason: 'nothing added before confirm');

      await tester.tap(confirm);
      await tester.pumpAndSettle();
    }

    final expected = [
      ...RulePreset.blockQuic.rawRules,
      ...RulePreset.lanDirect.rawRules,
    ];
    expect(added, hasLength(2));
    for (final rules in added) {
      expect(rules.map((rule) => rule.rawValue), expected);
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
