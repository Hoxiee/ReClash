import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/rules.dart';
import 'package:reclash/views/profiles/overwrite/overwrite_editor.dart';
import 'package:reclash/views/profiles/overwrite/rule_preset.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';

class _RecordingGlobalRules extends TestGlobalRules {
  _RecordingGlobalRules(super.initial);

  final added = <List<Rule>>[];

  @override
  void putAll(List<Rule> rules) {
    added.add(List<Rule>.from(rules));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('rulePresetsForRegion', () {
    test('surfaces only the home domestic preset per region', () {
      expect(rulePresetsForRegion('RU').first, RulePreset.russiaDirect);
      expect(rulePresetsForRegion('IR').first, RulePreset.iranDirect);
      expect(rulePresetsForRegion('CN').first, RulePreset.chinaDirect);

      expect(
        rulePresetsForRegion('RU'),
        isNot(contains(RulePreset.iranDirect)),
      );
      expect(
        rulePresetsForRegion('RU'),
        isNot(contains(RulePreset.chinaDirect)),
      );
    });

    test('other region gets the shared presets without any domestic head', () {
      final presets = rulePresetsForRegion(otherRegionCode);
      expect(presets, isNot(contains(RulePreset.russiaDirect)));
      expect(presets, isNot(contains(RulePreset.iranDirect)));
      expect(presets, isNot(contains(RulePreset.chinaDirect)));
      expect(presets, contains(RulePreset.blockQuic));
      expect(presets, contains(RulePreset.bittorrentDirect));
    });
  });

  testWidgets('quick add appends the picked preset rules', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rules = _RecordingGlobalRules(const []);
    final container = ProviderContainer(
      overrides: [
        globalRulesProvider.overrideWith(() => rules),
        appRegionProvider.overrideWithValue('RU'),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 2400));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AddedRulesView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byGlyph(AppGlyphs.bolt));
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.rulePresetRussiaDirect),
      findsOneWidget,
    );
    await tester.tap(find.text(currentAppLocalizations.rulePresetRussiaDirect));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(rules.added, hasLength(1));
    expect(
      rules.added.single.map((rule) => rule.rawValue),
      RulePreset.russiaDirect.rawRules,
    );
  });

  testWidgets('preset list starts flush under the sheet toolbar', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [appRegionProvider.overrideWithValue('RU')],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: RulePresetSheet(onAdd: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The scaffold already pads the body by the toolbar height; any top
    // padding here doubles the gap above the first preset.
    final listView = tester.widget<ListView>(find.byType(ListView));
    expect((listView.padding! as EdgeInsets).top, 0);
    expect(tester.takeException(), isNull);
  });
}
