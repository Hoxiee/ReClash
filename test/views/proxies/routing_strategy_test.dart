import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/proxies/routing_strategy.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _DraftAction extends RcxRoutingAction {
  Map<String, Object?>? lastRequest;

  @override
  Future<bool> setStrategy(String name, String? source) async => false;

  @override
  Future<RcxStudioResult?> studio(Map<String, Object?> request) async {
    lastRequest = request;
    return const RcxStudioResult(
      strategyLevels: [
        ['DE * Fast'],
        ['DE * Fast', 'NL Standard'],
      ],
    );
  }
}

void main() {
  setUpAll(mockPreferences);

  testWidgets('builds a group from one subscription with an ordered draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final action = _DraftAction();
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        overrides: [
          profilesProvider.overrideWith(
            () => TestProfiles(const [
              Profile(id: 1, autoUpdateDuration: Duration.zero),
            ]),
          ),
          currentProfileIdProvider.overrideWithBuild((_, _) => 1),
          rcxRoutingActionProvider.overrideWith(() => action),
        ],
        child: const ScriptedGroupEditor(),
      ),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    expect(fields, findsOneWidget);
    expect(find.text('Preview'), findsNothing);
    await tester.enterText(fields.first, 'Main');
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(1), '*');
    await tester.enterText(fields.at(2), 'ru');
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    final request = action.lastRequest!;
    expect(request['group'], 'Main');
    expect(request['create'], true);
    expect((request['localGroup'] as Map)['includeAll'], true);
    expect(request['text'], contains('name-contains: "*"'));
    expect(request['text'], contains('countries: ["RU"]'));
    expect(find.text('DE * Fast'), findsOneWidget);
  });

  testWidgets('keeps the editor open when the core rejects a live save', (
    tester,
  ) async {
    final action = _DraftAction();
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        overrides: [
          profilesProvider.overrideWith(
            () => TestProfiles(const [
              Profile(id: 1, autoUpdateDuration: Duration.zero),
            ]),
          ),
          currentProfileIdProvider.overrideWithBuild((_, _) => 1),
          rcxRoutingActionProvider.overrideWith(() => action),
        ],
        child: const ScriptedGroupEditor(group: 'Main'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(ScriptedGroupEditor), findsOneWidget);
    expect(find.text('Could not apply the strategy'), findsOneWidget);
  });
}
