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

void main() {
  late ProviderContainer container;

  Future<void> pumpView(
    WidgetTester tester, {
    DesyncProps props = defaultDesyncProps,
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
        child: const TestApp(child: DesyncView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the default ladder is marked active', (tester) async {
    await pumpView(tester);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('a saved strategy applies on tap and moves the check', (
    tester,
  ) async {
    const args = ['-A', 'conn', '--split', '1'];
    await pumpView(
      tester,
      props: defaultDesyncProps.copyWith(
        savedStrategies: const [DesyncStrategy(name: 'Split only', args: args)],
      ),
    );
    expect(find.text('Split only'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Split only'));
    await tester.pumpAndSettle();

    expect(
      container.read(desyncSettingProvider).strategyArgs,
      args,
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('the default row restores the built-in ladder', (tester) async {
    await pumpView(
      tester,
      props: defaultDesyncProps.copyWith(
        strategyArgs: const ['--split', '1'],
      ),
    );

    await tester.tap(find.text('Default ladder'));
    await tester.pumpAndSettle();

    expect(
      container.read(desyncSettingProvider).strategyArgs,
      desyncDefaultStrategy,
    );
  });

  testWidgets('a category toggle drops the category', (tester) async {
    await pumpView(tester);
    expect(find.text('GEOSITE,youtube'), findsOneWidget);

    await tester.tap(find.text('YouTube'));
    await tester.pumpAndSettle();

    expect(
      container.read(desyncSettingProvider).categories,
      [DesyncCategory.discord],
    );
  });
}
