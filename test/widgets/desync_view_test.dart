import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

class _TestDesyncSetting extends DesyncSetting {
  _TestDesyncSetting(this._initial);

  final DesyncProps _initial;

  @override
  DesyncProps build() => _initial;
}

const _featureOn = DesyncProps(featureEnabled: true);

void main() {
  late ProviderContainer container;

  Future<void> pumpView(
    WidgetTester tester, {
    DesyncProps props = _featureOn,
    Widget child = const DesyncView(),
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        desyncSettingProvider.overrideWith(() => _TestDesyncSetting(props)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ladder numbers and timings do not require findings', (
    tester,
  ) async {
    await pumpView(tester, child: const DesyncLadderPreview());

    List<String?> results() => tester
        .widgetList<Text>(find.textContaining('Ladder result:'))
        .map((text) => text.data)
        .toList();

    final expected = results();
    expect(expected, isNotEmpty);
    expect(expected.first, 'Ladder result: 2/5 · 120 ms');
    expect(find.widgetWithText(CircleAvatar, '1'), findsOneWidget);
    expect(find.widgetWithText(CircleAvatar, '2'), findsOneWidget);
    expect(container.read(milestoneSettingProvider).unlocked, isEmpty);

    for (final settings in [
      const MilestoneProps(unlocked: {'fullLadder'}),
      const MilestoneProps(findingsEnabled: false),
    ]) {
      container.read(milestoneSettingProvider.notifier).update((_) => settings);
      await tester.pumpAndSettle();
      expect(results(), expected);
      expect(find.widgetWithText(CircleAvatar, '1'), findsOneWidget);
      expect(find.widgetWithText(CircleAvatar, '2'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the default ladder is marked active', (tester) async {
    await pumpView(tester);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('the master toggle hides every control while off', (
    tester,
  ) async {
    await pumpView(tester, props: defaultDesyncProps);

    expect(find.text('Enable ByeDPI'), findsOneWidget);
    expect(find.text('Strategy'), findsNothing);
    expect(find.text('Engine'), findsNothing);
    expect(find.text('Default ladder'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(container.read(desyncSettingProvider).featureEnabled, isTrue);
    expect(find.text('Strategy'), findsOneWidget);
    expect(find.text('Default ladder'), findsOneWidget);
  });

  testWidgets('a saved strategy applies on tap and moves the check', (
    tester,
  ) async {
    const args = ['-A', 'conn', '--split', '1'];
    await pumpView(
      tester,
      props: _featureOn.copyWith(
        savedStrategies: const [DesyncStrategy(name: 'Split only', args: args)],
      ),
    );
    expect(find.text('Split only'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Split only'));
    await tester.pumpAndSettle();

    expect(container.read(desyncSettingProvider).strategyArgs, args);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('the default row restores the built-in ladder', (tester) async {
    await pumpView(
      tester,
      props: _featureOn.copyWith(strategyArgs: const ['--split', '1']),
    );

    await tester.tap(find.text('Default ladder'));
    await tester.pumpAndSettle();

    expect(
      container.read(desyncSettingProvider).strategyArgs,
      desyncDefaultStrategy,
    );
  });

  testWidgets('the tester section reports a dead engine', (tester) async {
    await pumpView(tester, props: _featureOn.copyWith(port: 1));
    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text('Start'));
    // The engine probe is real socket IO; FakeAsync needs a turn on the
    // actual event loop to see the connection refused.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The engine is not running — connect with DPI bypass enabled first',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the strategy page identifies the active strategy', (
    tester,
  ) async {
    await pumpView(tester, child: const DesyncStrategyView());

    expect(find.text('Active strategy'), findsOneWidget);
    expect(find.text('Default ladder'), findsNWidgets(2));
    expect(find.text('10 arguments'), findsNWidgets(2));
  });

  testWidgets('the test page opens the real domains in a group', (
    tester,
  ) async {
    await pumpView(tester, child: const DesyncTestView());

    expect(find.text('Test battery'), findsOneWidget);
    expect(find.text('60 presets · 2 groups · 32 hosts'), findsOneWidget);

    await tester.tap(find.text('Test domains'));
    await tester.pumpAndSettle();
    expect(find.textContaining('youtube.com'), findsOneWidget);

    await tester.tap(find.text('YouTube'));
    await tester.pumpAndSettle();
    expect(find.text('youtube.com'), findsOneWidget);
    expect(find.text('youtubei.googleapis.com'), findsOneWidget);
  });

  testWidgets('the engine page previews effective routing rules', (
    tester,
  ) async {
    await pumpView(tester, child: const DesyncEngineView());

    expect(find.text('127.0.0.1:7898'), findsOneWidget);
    expect(find.text('Effective rules'), findsOneWidget);
    expect(find.text('GEOSITE,youtube,DESYNC'), findsOneWidget);
    expect(find.text('GEOSITE,discord,DESYNC'), findsOneWidget);
    expect(find.text('MATCH,DIRECT'), findsOneWidget);
    expect(find.textContaining('bundled GEOSITE database'), findsOneWidget);
  });

  testWidgets('a category toggle drops the category', (tester) async {
    await pumpView(tester);
    expect(find.text('GEOSITE,youtube'), findsOneWidget);

    await tester.tap(find.text('YouTube'));
    await tester.pumpAndSettle();

    expect(container.read(desyncSettingProvider).categories, [
      DesyncCategory.discord,
    ]);
  });
}
