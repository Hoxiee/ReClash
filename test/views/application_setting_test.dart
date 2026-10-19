import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/providers/setup.dart';

import '../helpers/test_profiles.dart';
import 'package:reclash/views/application_setting.dart';

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
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1800));
  });

  tearDown(() {
    container.dispose();
    globalState.appEnv = previousAppEnv;
  });

  testWidgets('a prerelease build defaults the selector to Pre', (
    tester,
  ) async {
    globalState.appEnv = 'pre';
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

    expect(find.text('Pre-release'), findsOneWidget);
    expect(container.read(appSettingProvider).updateChannel, isNull);
  });

  testWidgets('channel selector defaults from the build and stores a choice', (
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

    expect(find.text('Update channel'), findsOneWidget);
    expect(find.text('Release'), findsOneWidget);
    expect(container.read(appSettingProvider).updateChannel, isNull);

    await tester.tap(find.text('Update channel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pre-release').last);
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).updateChannel, UpdateChannel.pre);
  });

  testWidgets('reopening setup from application settings keeps a live run', (
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
        child: const TestApp(child: ApplicationSettingView()),
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

    expect(find.text('Region profile'), findsOneWidget);
  });
}
