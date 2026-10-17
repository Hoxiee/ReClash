import 'dart:convert';

import 'package:reclash/manager/android_manager.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/service.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/preferences.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingSetupAction extends SetupAction {
  static final requests = <bool>[];

  @override
  Future<bool> setRunning(bool running, {bool initialize = false}) async {
    requests.add(running);
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SharedPreferences store;

  setUp(() async {
    await mockPreferences();
    store = await SharedPreferences.getInstance();
    _RecordingSetupAction.requests.clear();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
        // Bypassing private addresses computes the routes in Isolate.run, which
        // the fake clock never lets finish.
        networkSettingProvider.overrideWithBuild(
          (_, _) => const NetworkProps(bypassPrivateRoute: false),
        ),
      ],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpAndroidManager(WidgetTester tester) async {
    await container.read(vpnOptionsProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: AndroidManager(child: SizedBox(key: Key('child'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders its child unchanged', (tester) async {
    await pumpAndroidManager(tester);

    expect(find.byKey(const Key('child')), findsOneWidget);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a stop the service reports turns the running state off', (
    tester,
  ) async {
    await pumpAndroidManager(tester);
    final listener =
        tester.state(find.byType(AndroidManager)) as ServiceListener;

    listener.onServiceStopped();
    await tester.pump();

    expect(_RecordingSetupAction.requests, [false]);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('persists shared state after the debounce window', (
    tester,
  ) async {
    await pumpAndroidManager(tester);
    expect(store.getString('sharedState'), isNull);

    container.read(appSettingProvider.notifier).value = const AppSettingProps(
      testUrl: 'http://shared.test',
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final raw = store.getString('sharedState');
    expect(raw, isNotNull);
    final restored = SharedState.fromJson(
      json.decode(raw!) as Map<String, Object?>,
    );
    expect(restored.onlyStatisticsProxy, isFalse);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('does not persist when shared state is unchanged', (
    tester,
  ) async {
    await pumpAndroidManager(tester);

    container.read(appSettingProvider.notifier).value = const AppSettingProps();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(store.getString('sharedState'), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
