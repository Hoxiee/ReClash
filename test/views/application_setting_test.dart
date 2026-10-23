import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/widgets/update_preferences.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/providers/setup.dart';

import '../helpers/test_profiles.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/views/developer.dart';

import '../helpers/test_app.dart';

class _PersistingSetupSession extends SetupSession {
  @override
  Future<bool> saveConfig(Config config) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late String previousAppEnv;

  setUp(() {
    previousAppEnv = globalState.appEnv;
    globalState.appEnv = 'stable';
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        detectedRegionProvider.overrideWith((ref) async => null),
        setupSessionProvider.overrideWith(_PersistingSetupSession.new),
      ],
    );
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    container.listen(patchClashConfigProvider, (_, _) {});
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1800));
  });

  tearDown(() {
    container.dispose();
    globalState.appEnv = previousAppEnv;
  });

  testWidgets(
    'opens independent update preferences from application settings',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ApplicationSettingView()),
        ),
      );
      await tester.pumpAndSettle();
      final row = find.text('Update preferences');
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.byType(UpdatePreferences), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    },
  );

  testWidgets('log settings are grouped only in application settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(logLevel: LogLevel.warning));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    final capture = find.text('Logcat');
    final level = find.text('Log level');
    final captureSwitch = find.descendant(
      of: find.widgetWithText(ListTile, 'Logcat'),
      matching: find.byType(Switch),
    );
    expect(capture, findsOneWidget);
    expect(level, findsOneWidget);
    expect(find.text('warning'), findsOneWidget);
    expect(tester.widget<Switch>(captureSwitch).value, isFalse);
    await tester.ensureVisible(level);
    await tester.tap(level);
    await tester.pumpAndSettle();
    await tester.tap(find.text('debug'));
    await tester.pumpAndSettle();
    expect(container.read(patchClashConfigProvider).logLevel, LogLevel.debug);
    expect(container.read(appSettingProvider).openLogs, isFalse);

    await tester.ensureVisible(capture);
    await tester.tap(capture);
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).openLogs, isTrue);
    expect(tester.widget<Switch>(captureSwitch).value, isTrue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: GeneralView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(level, findsNothing);
    expect(capture, findsNothing);
    expect(find.text('Logs and diagnostics'), findsNothing);
    expect(find.text('Turning off Logcat hides the logs entry.'), findsNothing);
    expect(container.read(appSettingProvider).openLogs, isTrue);
    expect(container.read(patchClashConfigProvider).logLevel, LogLevel.debug);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(level, findsOneWidget);
    expect(find.text('debug'), findsOneWidget);
    expect(tester.widget<Switch>(captureSwitch).value, isTrue);
    await tester.ensureVisible(capture);
    await tester.tap(capture);
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).openLogs, isFalse);
    expect(tester.widget<Switch>(captureSwitch).value, isFalse);
    expect(container.read(patchClashConfigProvider).logLevel, LogLevel.debug);
  });

  testWidgets('reopening setup from developer tools keeps a live run', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(setupCompleted: true));
    container.read(runTimeProvider.notifier).value = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DeveloperView()),
      ),
    );
    await tester.pumpAndSettle();

    final entry = find.text('Set up connection');
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(container.read(setupSessionProvider).active, isTrue);
    expect(container.read(isStartProvider), isTrue);
    expect(container.read(runTimeProvider), 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('opens regional adaptation from application settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    final regionRow = find.text('App region');
    await tester.ensureVisible(regionRow);
    await tester.tap(regionRow);
    await tester.pumpAndSettle();

    expect(find.text('Russia'), findsOneWidget);
  });
}
