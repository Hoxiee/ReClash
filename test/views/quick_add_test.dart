import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/rules.dart';
import 'package:reclash/views/profiles/overwrite/overwrite_editor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(rulePresetsForRegion(AppRegion.russia).first, RulePreset.russiaDirect);
      expect(rulePresetsForRegion(AppRegion.iran).first, RulePreset.iranDirect);
      expect(rulePresetsForRegion(AppRegion.china).first, RulePreset.chinaDirect);

      expect(
        rulePresetsForRegion(AppRegion.russia),
        isNot(contains(RulePreset.iranDirect)),
      );
      expect(
        rulePresetsForRegion(AppRegion.russia),
        isNot(contains(RulePreset.chinaDirect)),
      );
    });

    test('other region gets the shared presets without any domestic head', () {
      final presets = rulePresetsForRegion(AppRegion.other);
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
        appRegionProvider.overrideWithValue(AppRegion.russia),
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
}
