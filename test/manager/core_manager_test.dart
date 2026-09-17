import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/theme.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/manager/core_manager.dart';
import 'package:reclash/manager/status_manager.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/connection_doctor.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _RecordingSetupAction extends SetupAction {
  int fullSetupCalls = 0;

  @override
  Future<bool> fullSetup() async {
    fullSetupCalls++;
    return true;
  }
}

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

const _nullProfileSetupState = SetupState(
  profileId: null,
  profileLastUpdateDate: null,
  overwriteType: OverwriteType.standard,
  rules: [],
  proxyGroups: [],
  addedRules: [],
  script: null,
  overrideDns: false,
  dns: Dns(),
);

const _crash = CoreEvent(type: CoreEventType.crash, data: 'boom');

CoreEvent _geoUpdate({
  bool updating = false,
  bool skipped = false,
  String? error,
}) {
  return CoreEvent(
    type: CoreEventType.geoUpdate,
    data: <String, dynamic>{
      'type': 'MMDB',
      'updating': updating,
      'skipped': skipped,
      'error': error,
    },
  );
}

_MockCoreHandlerInterface _coreInterface() {
  final coreInterface = _MockCoreHandlerInterface();
  when(() => coreInterface.startLog()).thenAnswer((_) {});
  when(() => coreInterface.stopLog()).thenAnswer((_) {});
  return coreInterface;
}

Future<ProviderContainer> _pumpCoreManager(
  WidgetTester tester,
  CoreHandlerInterface coreInterface, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  final container = ProviderContainer(
    overrides: [
      coreHandlerProvider.overrideWithValue(
        CoreController.scoped(coreInterface),
      ),
      ...overrides,
    ],
  );
  globalState.container = container;
  globalState.lastConfigMd5 = null;
  addTearDown(container.dispose);
  container.listen(currentProfileIdProvider, (_, _) {});
  container.listen(initProvider, (_, _) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return StatusManager(child: child!);
        },
        home: const CoreManager(child: SizedBox()),
      ),
    ),
  );
  return container;
}

// Loading.stop leaves a minDuration timer (up to 1000ms) pending after
// setupConfig resolves. Polling on the actual outcome instead of a fixed
// pump budget avoids racing it, and draining past it here keeps its
// callback from firing on a disposed container.
Future<void> _waitForSetupToSettle(
  WidgetTester tester,
  bool Function() condition,
) async {
  for (var attempt = 0; attempt < 2000 && !condition(); attempt++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pump(const Duration(milliseconds: 1100));
}

void main() {
  late Directory profileSwitchTempDir;

  setUpAll(() async {
    registerFallbackValue(const SetupParams(selectedMap: {}, testUrl: ''));
    await AppLocalizations.load(const Locale('en'));
    profileSwitchTempDir = Directory.systemTemp.createTempSync(
      'core_manager_test',
    );
    PathProviderPlatform.instance = _FakePathProvider(
      profileSwitchTempDir.path,
    );
  });

  tearDownAll(() {
    try {
      profileSwitchTempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  testWidgets('doctor status waits for Android UI before fetching a snapshot', (
    tester,
  ) async {
    final coreInterface = _coreInterface();
    when(() => coreInterface.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 8, supported: true),
    );
    final container = await _pumpCoreManager(tester, coreInterface);
    final doctor = container.read(connectionDoctorProvider.notifier);
    await doctor.updateActivity(
      lifecycleState: AppLifecycleState.hidden,
      isAndroid: true,
    );
    for (final revision in [4, 8, 6]) {
      coreEventManager.sendEvent(
        CoreEvent(
          type: CoreEventType.doctorStatus,
          data: {'revision': revision},
        ),
      );
    }
    await tester.pump();
    verifyNever(() => coreInterface.doctorSnapshot());

    await doctor.updateActivity(
      lifecycleState: AppLifecycleState.resumed,
      isAndroid: true,
    );
    expect(container.read(connectionDoctorProvider).revision, 8);
    verify(() => coreInterface.doctorSnapshot()).called(1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('duplicate crash events disconnect the core only once', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.stopLog()).thenAnswer((_) {});
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(coreInterface),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CoreManager(child: SizedBox())),
      ),
    );
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    final transitions = <CoreStatus>[];
    final subscription = container.listen<CoreStatus>(
      coreStatusProvider,
      (_, next) => transitions.add(next),
    );
    addTearDown(subscription.close);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    coreEventManager.sendEvent(_crash);
    coreEventManager.sendEvent(_crash);
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(transitions, [CoreStatus.disconnected]);
    verifyNever(() => coreInterface.stop());

    await tester.pumpWidget(const SizedBox());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('a crash while the app is visible surfaces the message', (
    tester,
  ) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    coreEventManager.sendEvent(_crash);
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(find.text('boom'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a crash is ignored when the core is not connected', (
    tester,
  ) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    final transitions = <CoreStatus>[];
    final subscription = container.listen<CoreStatus>(
      coreStatusProvider,
      (_, next) => transitions.add(next),
    );
    addTearDown(subscription.close);

    coreEventManager.sendEvent(_crash);
    await tester.pump();

    expect(container.read(coreStatusProvider), CoreStatus.connecting);
    expect(transitions, isEmpty);
    expect(find.text('boom'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the log stream follows the openLogs setting', (tester) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);

    verify(() => coreInterface.stopLog()).called(1);
    verifyNever(() => coreInterface.startLog());

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: true));
    await tester.pump();

    verify(() => coreInterface.startLog()).called(1);

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: false));
    await tester.pump();

    verify(() => coreInterface.stopLog()).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('core logs are recorded for the logs view', (tester) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);

    coreEventManager.sendEvent(
      const CoreEvent(
        type: CoreEventType.log,
        data: {'LogLevel': 'info', 'Payload': 'hello'},
      ),
    );
    await tester.pump();

    expect(
      container.read(logsProvider).list.map((log) => log.payload),
      contains('hello'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('geo events are forwarded to the geo resource action', (
    tester,
  ) async {
    final coreInterface = _coreInterface();
    final container = await _pumpCoreManager(tester, coreInterface);
    final key = GeoResource.MMDB.updatingKey;
    final subscription = container.listen<bool>(
      isUpdatingProvider(key),
      (_, _) {},
    );
    addTearDown(subscription.close);

    coreEventManager.sendEvent(_geoUpdate(updating: true));
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isTrue);

    coreEventManager.sendEvent(_geoUpdate(error: 'background failure'));
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);
    expect(find.text('background failure'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('non-geo Core errors retain global notifications', (
    tester,
  ) async {
    final coreInterface = _coreInterface();
    await _pumpCoreManager(tester, coreInterface);

    coreEventManager.sendEvent(
      const CoreEvent(
        type: CoreEventType.log,
        data: {'LogLevel': 'error', 'Payload': 'core failure'},
      ),
    );
    await tester.pump();

    expect(find.text('core failure'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('profile switch failure', () {
    late Profile previous;
    late Profile next;
    List<Override> profileOverrides() => [
      initProvider.overrideWithBuild((_, _) => true),
      profilesProvider.overrideWith(() => TestProfiles([previous, next])),
      currentProfileIdProvider.overrideWithBuild((_, _) => previous.id),
      setupStateProvider.overrideWith((_, _) => _nullProfileSetupState),
      setupActionProvider.overrideWith(_RecordingSetupAction.new),
      byeDpiSupportedProvider.overrideWithValue(true),
    ];

    setUp(() {
      previous = const Profile(
        id: 1001,
        label: 'previous',
        autoUpdateDuration: defaultUpdateDuration,
      );
      next = const Profile(
        id: 1002,
        label: 'next',
        autoUpdateDuration: defaultUpdateDuration,
      );
    });

    testWidgets('keeps the selected profile when Core rejects it', (
      tester,
    ) async {
      final coreInterface = _coreInterface();
      final container = await _pumpCoreManager(
        tester,
        coreInterface,
        overrides: profileOverrides(),
      );
      globalState.container = container;

      final setup =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;
      container.read(currentProfileIdProvider.notifier).value = next.id;
      await tester.pump();

      expect(container.read(currentProfileIdProvider), next.id);
      expect(setup.fullSetupCalls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('profile metadata change schedules only one full setup', (
      tester,
    ) async {
      final coreInterface = _coreInterface();
      final enriched = next.copyWith(
        capabilityManifest: ProviderCapabilityManifest(
          version: 1,
          receivedAt: DateTime.utc(2026, 9, 11),
          sourceHost: 'provider.test',
        ),
      );
      final container = await _pumpCoreManager(
        tester,
        coreInterface,
        overrides: profileOverrides(),
      );
      globalState.container = container;

      final setup =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;
      container.read(profilesProvider.notifier).put(enriched);
      container.read(currentProfileIdProvider.notifier).value = next.id;
      await tester.pump();

      expect(setup.fullSetupCalls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('rapid A -> B -> C schedules both profile setups', (
      tester,
    ) async {
      final coreInterface = _coreInterface();
      const a = Profile(
        id: 2001,
        label: 'a',
        autoUpdateDuration: defaultUpdateDuration,
      );
      const b = Profile(
        id: 2002,
        label: 'b',
        autoUpdateDuration: defaultUpdateDuration,
      );
      const c = Profile(
        id: 2003,
        label: 'c',
        autoUpdateDuration: defaultUpdateDuration,
      );
      final container = await _pumpCoreManager(
        tester,
        coreInterface,
        overrides: [
          initProvider.overrideWithBuild((_, _) => true),
          profilesProvider.overrideWith(() => TestProfiles([a, b, c])),
          currentProfileIdProvider.overrideWithBuild((_, _) => a.id),
          setupStateProvider.overrideWith((_, _) => _nullProfileSetupState),
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          byeDpiSupportedProvider.overrideWithValue(true),
        ],
      );
      globalState.container = container;

      final setup =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;
      container.read(currentProfileIdProvider.notifier).value = b.id;
      await tester.pump();
      container.read(currentProfileIdProvider.notifier).value = c.id;
      await tester.pump();

      expect(container.read(currentProfileIdProvider), c.id);
      expect(setup.fullSetupCalls, 2);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'a missing profile id recovers to a fallback without looping when '
      'the fallback is also rejected',
      (tester) async {
        final coreInterface = _coreInterface();
        var setupCalls = 0;
        when(() => coreInterface.setupConfig(any())).thenAnswer((_) async {
          setupCalls++;
          return 'rejected';
        });
        const missingId = -1;
        final container = await _pumpCoreManager(
          tester,
          coreInterface,
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            profilesProvider.overrideWith(() => TestProfiles([previous])),
            currentProfileIdProvider.overrideWithBuild((_, _) => null),
            setupStateProvider.overrideWith((_, _) => _nullProfileSetupState),
            byeDpiSupportedProvider.overrideWithValue(true),
          ],
        );
        globalState.container = container;

        container.read(currentProfileIdProvider.notifier).value = missingId;
        await _waitForSetupToSettle(
          tester,
          () => container.read(currentProfileIdProvider) == previous.id,
        );

        expect(setupCalls, lessThanOrEqualTo(3));
        expect(container.read(currentProfileIdProvider), previous.id);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });
}
