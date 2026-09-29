import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/general.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required String region,
  required bool sendIdentity,
}) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      ...buildConfigOverrides(
        Config(
          themeProps: defaultThemeProps,
          appSettingProps: AppSettingProps(
            region: region,
            sendDeviceIdentity: sendIdentity,
          ),
        ),
      ),
      profilesProvider.overrideWith(TestProfiles.new),
    ],
  );
  addTearDown(container.dispose);
  container.listen(configProvider, (_, _) {});
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 1600));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Scaffold(
          body: ListView(children: const [SendDeviceIdentityItem()]),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('settings confirm HWID disable in Russia', (tester) async {
    final container = await _pump(
      tester,
      region: 'RU',
      sendIdentity: true,
    );

    await tester.tap(find.text('Send HWID'));
    await tester.pumpAndSettle();
    expect(find.text('Turn off'), findsOneWidget);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);

    await tester.tap(find.text('Turn off'));
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
  });

  testWidgets('settings skip HWID confirm outside Russia', (tester) async {
    final container = await _pump(
      tester,
      region: 'IR',
      sendIdentity: true,
    );

    await tester.tap(find.text('Send HWID'));
    await tester.pumpAndSettle();
    expect(find.text('Turn off'), findsNothing);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
  });
}
