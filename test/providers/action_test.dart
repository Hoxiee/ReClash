import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingImportProfilesAction extends ProfilesAction {
  ({PreparedProfileImport prepared, Profile profile})? result;
  Exception? error;

  @override
  Future<({PreparedProfileImport prepared, Profile profile})?>
  performProfileImport(ProfileImportRequest request) async {
    final currentError = error;
    if (currentError != null) throw currentError;
    return result;
  }
}

class _ControlledUpdateProfilesAction extends ProfilesAction {
  final preparations = <int, Queue<Completer<PreparedProfileImport>>>{};

  Completer<PreparedProfileImport> enqueue(Profile profile) {
    final completer = Completer<PreparedProfileImport>();
    preparations.putIfAbsent(profile.id, Queue.new).add(completer);
    return completer;
  }

  @override
  Future<PreparedProfileImport> prepareProfileUpdate(Profile profile) {
    final queue = preparations[profile.id];
    if (queue == null || queue.isEmpty) {
      throw StateError('No prepared update for ${profile.id}');
    }
    return queue.removeFirst().future;
  }
}

PreparedProfileImport _preparedUpdate(Profile profile, String marker) {
  return PreparedProfileImport(
    profile: profile,
    content: 'proxies: []\n# $marker',
    skippedNodes: const [],
    summary: const ProfileImportSummary(
      format: ProfileImportFormat.clash,
      nodeCount: 0,
      groupCount: 0,
      hasProviders: false,
    ),
  );
}

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  group('ProfilesAction', () {
    test('keeps edited profile data when remote update fails', () async {
      final original = Profile.normal(label: 'old label', url: 'bad-url');
      final edited = original.copyWith(
        label: 'new label',
        url: 'still-bad-url',
      );
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => TestProfiles([original])),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(profilesProvider).getProfile(original.id),
        original,
      );

      await expectLater(
        container.read(profilesActionProvider.notifier).updateProfile(edited),
        throwsA(anything),
      );

      final profile = container.read(profilesProvider).getProfile(original.id);
      expect(profile?.label, edited.label);
      expect(profile?.url, edited.url);
    });

    test('updates selection, inserts first profile, and reorders profiles', () {
      final first = Profile.normal(label: 'First');
      final second = Profile.normal(label: 'Second');
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => first.id),
          profilesProvider.overrideWith(() => TestProfiles([first])),
        ],
      );
      addTearDown(container.dispose);
      final action = container.read(profilesActionProvider.notifier);

      action.updateCurrentSelectedMap('Group', 'Proxy');
      final updatedFirst = container.read(profilesProvider).single;
      expect(updatedFirst.selectedMap['Group'], 'Proxy');

      action.updateCurrentSelectedMap('Group', 'Proxy');
      expect(container.read(profilesProvider), hasLength(1));

      container.read(currentProfileIdProvider.notifier).value = null;
      action.putProfile(second);
      expect(container.read(currentProfileIdProvider), second.id);
      expect(container.read(profilesProvider), [updatedFirst, second]);

      action.reorder([second, updatedFirst]);
      expect(container.read(profilesProvider), [second, updatedFirst]);
    });

    test(
      'skips profile updates that are disabled, fresh, or file-based',
      () async {
        final profiles = [
          Profile.normal(label: 'Disabled').copyWith(autoUpdate: false),
          Profile.normal(label: 'Fresh').copyWith(
            autoUpdate: true,
            lastUpdateDate: DateTime.now().add(const Duration(days: 1)),
          ),
          Profile.normal(label: 'File').copyWith(
            autoUpdate: true,
            lastUpdateDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => null),
            profilesProvider.overrideWith(() => TestProfiles(profiles)),
          ],
        );
        addTearDown(container.dispose);
        final action = container.read(profilesActionProvider.notifier);

        await action.autoUpdateProfiles();
        await action.updateProfiles();

        expect(container.read(profilesProvider), profiles);
      },
    );

    test('setProfileAndAutoApply stores a non-current profile', () {
      final current = Profile.normal(label: 'Current');
      final other = Profile.normal(label: 'Other');
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => current.id),
          profilesProvider.overrideWith(() => TestProfiles([current])),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(profilesActionProvider.notifier)
          .setProfileAndAutoApply(other);

      expect(container.read(profilesProvider), [current, other]);
      expect(container.read(currentProfileIdProvider), current.id);
    });

    test('panel widgets take over the default dashboard', () {
      final current = Profile.normal(
        label: 'Current',
      ).copyWith(panelMeta: const PanelMeta(widgets: ['announce', 'metaInfo']));
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => current.id),
          profilesProvider.overrideWith(() => TestProfiles([current])),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(profilesActionProvider.notifier)
          .applyPanelWidgetsOnProfileSwitch(null);

      expect(container.read(appSettingProvider).dashboardWidgets, [
        DashboardWidget.announce,
        DashboardWidget.metaInfo,
      ]);
    });

    test('panel widgets append to a user-customized dashboard', () {
      final current = Profile.normal(
        label: 'Current',
      ).copyWith(panelMeta: const PanelMeta(widgets: ['announce']));
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => current.id),
          profilesProvider.overrideWith(() => TestProfiles([current])),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(appSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              dashboardWidgets: [DashboardWidget.networkSpeed],
            ),
          );

      container
          .read(profilesActionProvider.notifier)
          .applyPanelWidgetsOnProfileSwitch(null);

      expect(container.read(appSettingProvider).dashboardWidgets, [
        DashboardWidget.networkSpeed,
        DashboardWidget.announce,
      ]);
    });

    test('classifies profile import failures without raw diagnostics', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final action = container.read(profilesActionProvider.notifier);
      const request = ProfileImportRequest.link('https://example.com/sub');

      expect(
        action.profileImportFailure(
          const ProfileValidationException(diagnostic: 'secret detail'),
          request,
        ),
        ProfileImportFailure.invalidConfig,
      );
      expect(
        action.profileImportFailure(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.badResponse,
          ),
          request,
        ),
        ProfileImportFailure.fetchRejected,
      );
      expect(
        action.profileImportFailure(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionError,
          ),
          request,
        ),
        ProfileImportFailure.fetchFailed,
      );
      expect(
        action.profileImportFailure(
          const ProfileFetchException.emptyResponse(),
          request,
        ),
        ProfileImportFailure.emptyResponse,
      );
      expect(
        action.profileImportFailure(
          const FileSystemException('denied'),
          const ProfileImportRequest.file(),
        ),
        ProfileImportFailure.fileReadFailed,
      );
      expect(
        action.profileImportFailure(
          const MessageException('invalid QR'),
          const ProfileImportRequest.qrCode(),
        ),
        ProfileImportFailure.invalidQrCode,
      );
    });

    test('returns imported and cancelled results and cleans loading', () async {
      final profile = Profile.normal(label: 'Imported');
      final prepared = PreparedProfileImport(
        profile: profile,
        content: 'proxies: []',
        skippedNodes: const [],
        summary: const ProfileImportSummary(
          format: ProfileImportFormat.clash,
          nodeCount: 0,
          groupCount: 0,
          hasProviders: false,
        ),
      );
      final action = _RecordingImportProfilesAction()
        ..result = (prepared: prepared, profile: profile);
      final container = ProviderContainer(
        overrides: [profilesActionProvider.overrideWith(() => action)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(profilesActionProvider.notifier);

      final imported = await notifier.importProfile(
        const ProfileImportRequest.raw('proxies: []'),
      );
      expect(imported.profile, profile);
      expect(imported.isImported, isTrue);
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(container.read(loadingProvider(LoadingTag.profiles)), isFalse);

      action.result = null;
      final cancelled = await notifier.importProfile(
        const ProfileImportRequest.file(),
      );
      expect(cancelled.isCancelled, isTrue);
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(container.read(loadingProvider(LoadingTag.profiles)), isFalse);
    });

    testWidgets('returns a typed failed result and cleans loading', (
      tester,
    ) async {
      final action = _RecordingImportProfilesAction()
        ..error = const ProfileImportUrlException();
      final container = ProviderContainer(
        overrides: [profilesActionProvider.overrideWith(() => action)],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: Scaffold()),
        ),
      );
      await tester.pump();
      final notifier = container.read(profilesActionProvider.notifier);

      final future = notifier.importProfile(
        const ProfileImportRequest.link('not-a-url'),
      );
      await tester.pump();
      expect(container.read(loadingProvider(LoadingTag.profiles)), isTrue);
      expect(find.text(AppLocalizations.current.addProfile), findsOneWidget);
      Navigator.of(globalState.navigatorKey.currentContext!).pop(true);
      await tester.pumpAndSettle();
      final failed = await future;

      expect(failed.failure, ProfileImportFailure.invalidUrl);
      expect(failed.isFailed, isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(container.read(loadingProvider(LoadingTag.profiles)), isFalse);
    });

    testWidgets('panel settings require explicit consent', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => TestProfiles(const [])),
        ],
      );
      addTearDown(container.dispose);
      container.listen(appSettingProvider, (_, _) {});
      globalState.container = container;
      container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: Scaffold()),
        ),
      );
      final notifier = container.read(profilesActionProvider.notifier);
      const meta = PanelMeta(settings: ['minimize', 'autorun', 'openlogs']);

      final declined = notifier.confirmAndApplyPanelSettings(meta);
      await tester.pumpAndSettle();
      expect(
        find.textContaining(AppLocalizations.current.autoRun),
        findsOneWidget,
      );
      Navigator.of(globalState.navigatorKey.currentContext!).pop(false);
      await tester.pumpAndSettle();
      expect(await declined, isFalse);
      expect(container.read(appSettingProvider).autoRun, isFalse);

      final accepted = notifier.confirmAndApplyPanelSettings(meta);
      await tester.pumpAndSettle();
      Navigator.of(globalState.navigatorKey.currentContext!).pop(true);
      await tester.pumpAndSettle();
      expect(await accepted, isTrue);

      final state = container.read(appSettingProvider);
      expect(state.minimizeOnExit, isTrue);
      expect(state.autoRun, isTrue);
      expect(state.openLogs, isTrue);
      expect(state.silentLaunch, isFalse);
      expect(state.autoLaunch, isFalse);
      expect(state.autoCheckUpdate, isFalse);
      expect(state.closeConnections, isTrue);
    });
  });

  group('ProfilesAction lifecycle', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('profile_lifecycle_test');
      PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    ProviderContainer containerFor(
      Profile profile,
      _ControlledUpdateProfilesAction action,
    ) {
      return ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          profilesActionProvider.overrideWith(() => action),
        ],
      );
    }

    test('latest update wins when an older fetch completes last', () async {
      final original = Profile.normal(label: 'Original', url: 'https://old');
      final action = _ControlledUpdateProfilesAction();
      final firstPreparation = action.enqueue(original);
      final secondPreparation = action.enqueue(original);
      final container = containerFor(original, action);
      addTearDown(container.dispose);
      final notifier = container.read(profilesActionProvider.notifier);

      final first = notifier.updateProfile(original);
      final second = notifier.updateProfile(original);
      secondPreparation.complete(
        _preparedUpdate(
          original.copyWith(
            url: 'https://second',
            subscriptionInfo: const SubscriptionInfo(download: 2),
          ),
          'second',
        ),
      );
      await second;
      firstPreparation.complete(
        _preparedUpdate(
          original.copyWith(
            url: 'https://first',
            subscriptionInfo: const SubscriptionInfo(download: 1),
          ),
          'first',
        ),
      );
      await first;

      final saved = container.read(profilesProvider).single;
      expect(saved.url, 'https://second');
      expect(saved.subscriptionInfo?.download, 2);
      expect(
        await saved.file.then((file) => file.readAsString()),
        contains('second'),
      );
    });

    test('delete supersedes a pending update without resurrection', () async {
      final original = Profile.normal(label: 'Original', url: 'https://old');
      final action = _ControlledUpdateProfilesAction();
      final preparation = action.enqueue(original);
      final core = _MockCoreHandlerInterface();
      when(() => core.clearEffect(original.id)).thenAnswer((_) async => '');
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => TestProfiles([original])),
          profilesActionProvider.overrideWith(() => action),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(profilesActionProvider.notifier);
      final file = await original.file;
      await file.writeAsString('old');

      final update = notifier.updateProfile(original, showLoading: true);
      await notifier.deleteProfile(original.id);
      preparation.complete(
        _preparedUpdate(original.copyWith(url: 'https://late'), 'late'),
      );
      await update;

      expect(container.read(profilesProvider), isEmpty);
      expect(await file.exists(), isFalse);
      expect(
        container.read(updatingKeysProvider).contains(original.updatingKey),
        isFalse,
      );
    });

    test('remote update preserves concurrent user-owned fields', () async {
      final original = Profile.normal(label: 'Original', url: 'https://old');
      final action = _ControlledUpdateProfilesAction();
      final preparation = action.enqueue(original);
      final container = containerFor(original, action);
      addTearDown(container.dispose);
      final notifier = container.read(profilesActionProvider.notifier);

      final update = notifier.updateProfile(original);
      container
          .read(profilesProvider.notifier)
          .put(
            original.copyWith(
              label: 'User label',
              userLabel: true,
              selectedMap: {'Auto': 'Manual choice'},
              autoUpdate: false,
            ),
          );
      preparation.complete(
        _preparedUpdate(
          original.copyWith(
            label: 'Remote label',
            url: 'https://migrated',
            subscriptionInfo: const SubscriptionInfo(download: 9),
          ),
          'remote',
        ),
      );
      await update;

      final saved = container.read(profilesProvider).single;
      expect(saved.label, 'User label');
      expect(saved.userLabel, isTrue);
      expect(saved.selectedMap, {'Auto': 'Manual choice'});
      expect(saved.autoUpdate, isFalse);
      expect(saved.url, 'https://migrated');
      expect(saved.subscriptionInfo?.download, 9);
    });
  });

  group('developer subscriptions', () {
    late Directory tempDir;

    setUpAll(() async {
      await AppLocalizations.load(const Locale('en'));
      tempDir = Directory.systemTemp.createTempSync(
        'developer_subscription_test',
      );
      PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    });

    tearDownAll(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('installs and reinstalls a fixture without duplicates', () async {
      final core = _MockCoreHandlerInterface();
      when(() => core.validateConfig(any())).thenAnswer((_) async => '');
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => TestProfiles(const [])),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      final action = container.read(profilesActionProvider.notifier);
      final fixture = developerSubscriptions.first;

      expect(await action.installDeveloperSubscription(fixture), isTrue);
      final first = container.read(profilesProvider).single;
      expect(first.panelMeta, fixture.panelMeta);
      expect(first.subscriptionInfo, fixture.subscriptionInfo);
      expect(first.type, ProfileType.file);
      expect(await first.file.then((file) => file.exists()), isTrue);

      expect(await action.installDeveloperSubscription(fixture), isTrue);
      final reinstalled = container.read(profilesProvider).single;
      expect(reinstalled.id, first.id);
      expect(container.read(profilesProvider), hasLength(1));
      verify(() => core.validateConfig(any())).called(2);
    });

    test(
      'keeps another profile current and does not apply fixture widgets',
      () async {
        final current = Profile.normal(label: 'Current');
        final core = _MockCoreHandlerInterface();
        when(() => core.validateConfig(any())).thenAnswer((_) async => '');
        final container = ProviderContainer(
          overrides: [
            currentProfileIdProvider.overrideWithBuild((_, _) => current.id),
            profilesProvider.overrideWith(() => TestProfiles([current])),
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          ],
        );
        addTearDown(container.dispose);
        globalState.container = container;
        final before = container.read(appSettingProvider).dashboardWidgets;

        final installed = await container
            .read(profilesActionProvider.notifier)
            .installDeveloperSubscription(developerSubscriptions.last);

        expect(installed, isTrue);
        expect(container.read(currentProfileIdProvider), current.id);
        expect(container.read(profilesProvider), hasLength(2));
        expect(container.read(appSettingProvider).dashboardWidgets, before);
      },
    );
  });

  group('GeoResourceAction', () {
    test('GeoResource has correct updatingKey', () {
      expect(GeoResource.MMDB.updatingKey, 'geo_resource_MMDB');
      expect(GeoResource.ASN.updatingKey, 'geo_resource_ASN');
      expect(GeoResource.GEOIP.updatingKey, 'geo_resource_GEOIP');
      expect(GeoResource.GEOSITE.updatingKey, 'geo_resource_GEOSITE');
    });

    test('IsUpdating provider works with geo resource key', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final key = GeoResource.MMDB.updatingKey;
      expect(container.read(isUpdatingProvider(key)), false);

      final operation = container
          .read(updatingKeysProvider.notifier)
          .start(key);
      expect(container.read(isUpdatingProvider(key)), true);

      container.read(updatingKeysProvider.notifier).stop(key, operation);
      expect(container.read(isUpdatingProvider(key)), false);
    });

    test('forwards a manual resource update to Core', () async {
      final core = _MockCoreHandlerInterface();
      when(() => core.updateGeoData('MMDB')).thenAnswer((_) async => '');
      final container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      addTearDown(container.dispose);
      final action = container.read(geoResourceActionProvider.notifier);

      await action.updateGeoResource(GeoResource.MMDB);

      verify(() => core.updateGeoData('MMDB')).called(1);
    });

    test('propagates a failed manual Core request', () async {
      final core = _MockCoreHandlerInterface();
      when(
        () => core.updateGeoData('MMDB'),
      ).thenThrow(StateError('disconnected'));
      final container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ],
      );
      addTearDown(container.dispose);
      final action = container.read(geoResourceActionProvider.notifier);

      await expectLater(
        action.updateGeoResource(GeoResource.MMDB),
        throwsStateError,
      );
      verify(() => core.updateGeoData('MMDB')).called(1);
    });

    test('updates valid resource URLs and rejects malformed URLs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final action = container.read(geoResourceActionProvider.notifier);

      expect(
        () => action.updateGeoResourceUrl(GeoResource.MMDB, 'not-a-url'),
        throwsA(isA<ArgumentError>()),
      );

      const url = 'https://example.com/Country.mmdb';
      action.updateGeoResourceUrl(GeoResource.MMDB, url);
      expect(
        container.read(patchClashConfigProvider).geoXUrl[GeoResource.MMDB],
        url,
      );
    });
  });

  group('CoreAction', () {
    test('applies the profile after restarting a stopped core', () async {
      final container = ProviderContainer(
        overrides: [
          coreActionProvider.overrideWith(_TestCoreAction.new),
          setupActionProvider.overrideWith(_TestSetupAction.new),
        ],
      );
      addTearDown(container.dispose);
      final coreAction =
          container.read(coreActionProvider.notifier) as _TestCoreAction;
      final setupAction =
          container.read(setupActionProvider.notifier) as _TestSetupAction;

      await coreAction.restartCore();

      expect(coreAction.lifecycleRestartCount, 1);
      expect(setupAction.setRunningCount, 0);
      expect(setupAction.applyProfileCount, 1);
    });

    test(
      'restores the started state after restarting a running core',
      () async {
        final container = ProviderContainer(
          overrides: [
            coreActionProvider.overrideWith(_TestCoreAction.new),
            setupActionProvider.overrideWith(_TestSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        container.read(runTimeProvider.notifier).value = 0;
        final coreAction =
            container.read(coreActionProvider.notifier) as _TestCoreAction;
        final setupAction =
            container.read(setupActionProvider.notifier) as _TestSetupAction;

        await coreAction.restartCore();

        expect(coreAction.lifecycleRestartCount, 1);
        expect(setupAction.setRunningCount, 1);
        expect(setupAction.applyProfileCount, 0);
      },
    );

    test(
      'a rejected setup while running reports restartCore as unsuccessful',
      () async {
        final container = ProviderContainer(
          overrides: [
            coreActionProvider.overrideWith(_TestCoreAction.new),
            setupActionProvider.overrideWith(_TestSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        container.read(runTimeProvider.notifier).value = 0;
        final coreAction =
            container.read(coreActionProvider.notifier) as _TestCoreAction;
        final setupAction =
            container.read(setupActionProvider.notifier) as _TestSetupAction;
        setupAction.setRunningResult = false;

        final applied = await coreAction.restartCore();

        expect(applied, isFalse);
        expect(setupAction.setRunningCount, 1);
      },
    );

    test(
      'coalesces concurrent restart requests into one lifecycle restart',
      () async {
        final container = ProviderContainer(
          overrides: [
            coreActionProvider.overrideWith(_TestCoreAction.new),
            setupActionProvider.overrideWith(_TestSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final coreAction =
            container.read(coreActionProvider.notifier) as _TestCoreAction;
        final setupAction =
            container.read(setupActionProvider.notifier) as _TestSetupAction;
        final restartCompleter = Completer<CoreLifecycleResult>();
        coreAction.restartCompleter = restartCompleter;

        final first = coreAction.restartCore();
        final second = coreAction.restartCore();
        await Future<void>.delayed(Duration.zero);

        expect(coreAction.lifecycleRestartCount, 1);
        restartCompleter.complete(_restartResult);
        await Future.wait([first, second]);

        expect(setupAction.applyProfileCount, 1);
      },
    );

    test('reapplies the latest request without restarting twice', () async {
      final container = ProviderContainer(
        overrides: [
          coreActionProvider.overrideWith(_TestCoreAction.new),
          setupActionProvider.overrideWith(_TestSetupAction.new),
        ],
      );
      addTearDown(container.dispose);
      final coreAction =
          container.read(coreActionProvider.notifier) as _TestCoreAction;
      final setupAction =
          container.read(setupActionProvider.notifier) as _TestSetupAction;
      final restartCompleter = Completer<CoreLifecycleResult>();
      final firstApplyStarted = Completer<void>();
      final firstApplyCompleter = Completer<void>();
      coreAction.restartCompleter = restartCompleter;
      setupAction.firstApplyStarted = firstApplyStarted;
      setupAction.firstApplyCompleter = firstApplyCompleter;

      final first = coreAction.restartCore();
      await Future<void>.delayed(Duration.zero);
      restartCompleter.complete(_restartResult);
      await firstApplyStarted.future;

      final second = coreAction.restartCore();
      firstApplyCompleter.complete();
      await Future.wait([first, second]);

      expect(coreAction.lifecycleRestartCount, 1);
      expect(setupAction.applyProfileCount, 2);
    });

    test('surfaces a failed restart to its caller as a rejection', () async {
      final container = ProviderContainer(
        overrides: [
          coreActionProvider.overrideWith(_TestCoreAction.new),
          setupActionProvider.overrideWith(_TestSetupAction.new),
        ],
      );
      addTearDown(container.dispose);
      final coreAction =
          container.read(coreActionProvider.notifier) as _TestCoreAction;
      final restartCompleter = Completer<CoreLifecycleResult>();
      coreAction.restartCompleter = restartCompleter;

      final restart = coreAction.restartCore();
      restartCompleter.completeError(StateError('core is gone'));

      await expectLater(restart, throwsA(isA<StateError>()));
      expect(container.read(coreStatusProvider), CoreStatus.disconnected);

      // The failed operation must not latch: a later restart still runs.
      coreAction.restartCompleter = null;
      await coreAction.restartCore();
      expect(coreAction.lifecycleRestartCount, 2);
      expect(container.read(coreStatusProvider), CoreStatus.connected);
    });

    test(
      'startCore leaves status and initCore to the superseding operation',
      () async {
        final container = ProviderContainer(
          overrides: [coreActionProvider.overrideWith(_TestCoreAction.new)],
        );
        addTearDown(container.dispose);
        final coreAction =
            container.read(coreActionProvider.notifier) as _TestCoreAction;
        coreAction.startResult = const CoreLifecycleResult(
          revision: 1,
          outcome: CoreLifecycleOutcome.superseded,
        );

        await coreAction.startCore();

        expect(coreAction.initCoreCount, 0);
        expect(container.read(coreStatusProvider), CoreStatus.connecting);
      },
    );

    test('startCore treats a coalesced outcome as applied', () async {
      final container = ProviderContainer(
        overrides: [coreActionProvider.overrideWith(_TestCoreAction.new)],
      );
      addTearDown(container.dispose);
      final coreAction =
          container.read(coreActionProvider.notifier) as _TestCoreAction;
      coreAction.startResult = const CoreLifecycleResult(
        revision: 1,
        outcome: CoreLifecycleOutcome.coalesced,
      );

      await coreAction.startCore();

      expect(coreAction.initCoreCount, 1);
      expect(container.read(coreStatusProvider), CoreStatus.connected);
    });

    test(
      'restartCore leaves status and initCore to the superseding operation',
      () async {
        final container = ProviderContainer(
          overrides: [
            coreActionProvider.overrideWith(_TestCoreAction.new),
            setupActionProvider.overrideWith(_TestSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final coreAction =
            container.read(coreActionProvider.notifier) as _TestCoreAction;
        final setupAction =
            container.read(setupActionProvider.notifier) as _TestSetupAction;
        coreAction.restartCompleter = Completer<CoreLifecycleResult>()
          ..complete(
            const CoreLifecycleResult(
              revision: 1,
              outcome: CoreLifecycleOutcome.superseded,
            ),
          );

        final applied = await coreAction.restartCore();

        expect(applied, isFalse);
        expect(coreAction.initCoreCount, 0);
        expect(container.read(coreStatusProvider), CoreStatus.connecting);
        expect(setupAction.setRunningCount, 0);
        expect(setupAction.applyProfileCount, 0);
      },
    );

    test('restartCore treats a coalesced outcome as applied', () async {
      final container = ProviderContainer(
        overrides: [
          coreActionProvider.overrideWith(_TestCoreAction.new),
          setupActionProvider.overrideWith(_TestSetupAction.new),
        ],
      );
      addTearDown(container.dispose);
      final coreAction =
          container.read(coreActionProvider.notifier) as _TestCoreAction;
      coreAction.restartCompleter = Completer<CoreLifecycleResult>()
        ..complete(
          const CoreLifecycleResult(
            revision: 1,
            outcome: CoreLifecycleOutcome.coalesced,
          ),
        );

      await coreAction.restartCore();

      expect(coreAction.initCoreCount, 1);
      expect(container.read(coreStatusProvider), CoreStatus.connected);
    });
  });

  group('SetupAction', () {
    group('rapid status changes', () {
      test('updates runtime and traffic while core start is pending', () async {
        final startCompleter = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            commonActionProvider.overrideWith(_RaceCommonAction.new),
            setupActionProvider.overrideWith(_RaceSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final action =
            container.read(setupActionProvider.notifier) as _RaceSetupAction;
        final commonAction =
            container.read(commonActionProvider.notifier) as _RaceCommonAction;
        action.startCompleter = startCompleter;

        final startFuture = action.setRunning(true);
        final initialRunTime = container.read(runTimeProvider)!;
        await Future<void>.delayed(const Duration(milliseconds: 1100));

        expect(container.read(runTimeProvider), greaterThan(initialRunTime));
        expect(commonAction.updateTrafficCount, greaterThanOrEqualTo(2));

        startCompleter.complete(true);
        await startFuture;

        expect(action.transitions, [true]);
        await action.setRunning(false);
      });

      test('serializes listener changes while latest start owns UI', () async {
        final stopCompleter = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            commonActionProvider.overrideWith(_RaceCommonAction.new),
            setupActionProvider.overrideWith(_RaceSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final action =
            container.read(setupActionProvider.notifier) as _RaceSetupAction;
        await action.setRunning(true);
        action.transitions.clear();
        action.applyProfileDebounceCount = 0;
        action.stopCompleter = stopCompleter;

        final stopFuture = action.setRunning(false);
        await Future<void>.delayed(Duration.zero);
        expect(action.transitions, [false]);

        final startFuture = action.setRunning(true);

        expect(container.read(runTimeProvider), isNotNull);

        stopCompleter.complete(true);
        await Future.wait([stopFuture, startFuture]);

        expect(action.transitions, [false, true]);
        expect(container.read(runTimeProvider), isNotNull);
        expect(container.read(isStartProvider), isTrue);
        expect(action.applyProfileDebounceCount, 1);
        expect(action.resetCoreTrafficCount, 0);

        await action.setRunning(false);
      });

      test('newer stop prevents stale start continuation', () async {
        final startCompleter = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            commonActionProvider.overrideWith(_RaceCommonAction.new),
            setupActionProvider.overrideWith(_RaceSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final action =
            container.read(setupActionProvider.notifier) as _RaceSetupAction;
        action.startCompleter = startCompleter;

        final startFuture = action.setRunning(true);
        await Future<void>.delayed(Duration.zero);
        expect(action.transitions, [true]);

        final stopFuture = action.setRunning(false);
        expect(container.read(runTimeProvider), isNull);

        startCompleter.complete(true);
        await Future.wait([startFuture, stopFuture]);

        expect(action.transitions, [true, false]);
        expect(container.read(runTimeProvider), isNull);
        expect(container.read(isStartProvider), isFalse);
        expect(action.applyProfileDebounceCount, 0);
        expect(action.resetCoreTrafficCount, 1);
      });

      test('skips an intermediate stop when a newer start is queued', () async {
        final startCompleter = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            commonActionProvider.overrideWith(_RaceCommonAction.new),
            setupActionProvider.overrideWith(_RaceSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final action =
            container.read(setupActionProvider.notifier) as _RaceSetupAction;
        action.startCompleter = startCompleter;

        final firstStart = action.setRunning(true);
        await Future<void>.delayed(Duration.zero);
        final stop = action.setRunning(false);
        final latestStart = action.setRunning(true);

        startCompleter.complete(true);
        await Future.wait([firstStart, stop, latestStart]);

        expect(action.transitions, [true, true]);
        expect(container.read(isStartProvider), isTrue);
        expect(action.applyProfileDebounceCount, 1);
        expect(action.resetCoreTrafficCount, 0);

        await action.setRunning(false);
      });

      test('stale initialization cannot start after a newer stop', () async {
        final container = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            commonActionProvider.overrideWith(_RaceCommonAction.new),
            setupActionProvider.overrideWith(_InitializingSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final action =
            container.read(setupActionProvider.notifier)
                as _InitializingSetupAction;

        final start = action.setRunning(true, initialize: true);
        final stop = action.setRunning(false);
        await stop;

        expect(action.transitions, [false]);
        expect(container.read(isStartProvider), isFalse);

        action.continueInitialization();
        await start;

        expect(action.transitions, [false]);
        expect(container.read(isStartProvider), isFalse);
      });

      test('a paused start is only skipped on Android', () async {
        final container = ProviderContainer(
          overrides: [
            initProvider.overrideWithBuild((_, _) => true),
            pausedProvider.overrideWith((ref) => true),
            commonActionProvider.overrideWith(_RaceCommonAction.new),
            setupActionProvider.overrideWith(_RaceSetupAction.new),
          ],
        );
        addTearDown(container.dispose);
        final action =
            container.read(setupActionProvider.notifier) as _RaceSetupAction;

        await action.setRunning(true);

        expect(action.transitions, [true]);
        expect(container.read(isStartProvider), isTrue);
        expect(action.applyProfileDebounceCount, 1);

        await action.setRunning(false);
        expect(action.transitions, [true, false]);
      });
    });

    test(
      'restarts core after newly granting admin during config update',
      () async {
        late _AuthorizationSetupAction setupAction;
        late _RestartRecordingCoreAction coreAction;
        final container = ProviderContainer(
          overrides: [
            setupActionProvider.overrideWith(() {
              setupAction = _AuthorizationSetupAction([AuthorizeCode.success]);
              return setupAction;
            }),
            coreActionProvider.overrideWith(() {
              coreAction = _RestartRecordingCoreAction();
              return coreAction;
            }),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith.tun(enable: true));
        container.read(setupActionProvider);
        container.read(coreActionProvider);

        await setupAction.updateConfig();

        expect(setupAction.authorizationRequestCount, 1);
        expect(
          container.read(authorizedTunEnableProvider),
          TunAuthorizationState.authorized,
        );
        expect(coreAction.restartCount, 1);
      },
    );

    test(
      'a config Core rejects on the handoff path reports failure, not success',
      () async {
        late _AuthorizationSetupAction setupAction;
        late _RestartRecordingCoreAction coreAction;
        final container = ProviderContainer(
          overrides: [
            currentProfileProvider.overrideWithValue(null),
            setupActionProvider.overrideWith(() {
              setupAction = _AuthorizationSetupAction([AuthorizeCode.success]);
              return setupAction;
            }),
            coreActionProvider.overrideWith(() {
              coreAction = _RestartRecordingCoreAction()..restartResult = false;
              return coreAction;
            }),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith.tun(enable: true));
        container.read(setupActionProvider);
        container.read(coreActionProvider);

        final succeeded = await setupAction.applyProfile(force: true);

        expect(coreAction.restartCount, 1);
        expect(succeeded, isFalse);
      },
    );

    test('reopens authorization and propagates a failed restart', () async {
      late _AuthorizationSetupAction setupAction;
      final container = ProviderContainer(
        overrides: [
          currentProfileProvider.overrideWithValue(null),
          setupActionProvider.overrideWith(() {
            setupAction = _AuthorizationSetupAction([AuthorizeCode.success]);
            return setupAction;
          }),
          coreActionProvider.overrideWith(_FailingRestartCoreAction.new),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith.tun(enable: true));
      container.read(setupActionProvider);
      container.read(coreActionProvider);

      await expectLater(
        setupAction.applyProfile(force: true),
        throwsA(same(_restartFailure)),
      );

      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.none,
      );
    });

    test('re-prompts while the core binary stays unauthorized', () async {
      late _AuthorizationSetupAction setupAction;
      final container = ProviderContainer(
        overrides: [
          setupActionProvider.overrideWith(() {
            setupAction = _AuthorizationSetupAction([
              AuthorizeCode.error,
              AuthorizeCode.success,
            ]);
            return setupAction;
          }),
        ],
      );
      addTearDown(container.dispose);
      container.read(setupActionProvider);

      expect(await setupAction.requestAdmin(true), isTrue);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.unauthorized,
      );

      expect(await setupAction.requestAdmin(true), isFalse);
      expect(setupAction.authorizationRequestCount, 2);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.authorized,
      );
    });

    test(
      'skips the prompt when the core binary is already privileged',
      () async {
        late _AuthorizationSetupAction setupAction;
        final container = ProviderContainer(
          overrides: [
            setupActionProvider.overrideWith(() {
              setupAction = _AuthorizationSetupAction([AuthorizeCode.success])
                ..adminAuthorized = true;
              return setupAction;
            }),
          ],
        );
        addTearDown(container.dispose);
        container.read(setupActionProvider);

        expect(await setupAction.requestAdmin(true), isTrue);
        expect(setupAction.authorizationRequestCount, 0);
        expect(
          container.read(authorizedTunEnableProvider),
          TunAuthorizationState.authorized,
        );
      },
    );

    test('keeps tun disabled while authorization stays unauthorized', () async {
      late _AuthorizationSetupAction setupAction;
      final container = ProviderContainer(
        overrides: [
          setupActionProvider.overrideWith(() {
            setupAction = _AuthorizationSetupAction([AuthorizeCode.error]);
            return setupAction;
          }),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith.tun(enable: true));
      container.read(setupActionProvider);

      await setupAction.requestAdmin(true);

      expect(container.read(shouldPatchSystemDnsProvider), isFalse);
    });
  });
}

class _TestCoreAction extends CoreAction {
  int lifecycleRestartCount = 0;
  int initCoreCount = 0;
  Completer<CoreLifecycleResult>? restartCompleter;
  Completer<CoreLifecycleResult>? startCompleter;
  CoreLifecycleResult startResult = _restartResult;

  @override
  Future<void> initCore() async {
    initCoreCount++;
  }

  @override
  Future<CoreLifecycleResult> startLifecycle() {
    return startCompleter?.future ?? Future.value(startResult);
  }

  @override
  Future<CoreLifecycleResult> restartLifecycle() {
    lifecycleRestartCount++;
    return restartCompleter?.future ?? Future.value(_restartResult);
  }
}

class _TestSetupAction extends SetupAction {
  int setRunningCount = 0;
  int applyProfileCount = 0;
  bool setRunningResult = true;
  Completer<void>? firstApplyStarted;
  Completer<void>? firstApplyCompleter;

  @override
  Future<bool> setRunning(bool running, {bool initialize = false}) async {
    setRunningCount++;
    return setRunningResult;
  }

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    applyProfileCount++;
    if (applyProfileCount == 1) {
      firstApplyStarted?.complete();
      await firstApplyCompleter?.future;
    }
    return true;
  }
}

const _restartResult = CoreLifecycleResult(
  revision: 1,
  outcome: CoreLifecycleOutcome.applied,
);

class _RestartRecordingCoreAction extends CoreAction {
  int restartCount = 0;
  bool restartResult = true;

  @override
  Future<bool> restartCore() async {
    restartCount++;
    return restartResult;
  }
}

class _FailingRestartCoreAction extends CoreAction {
  @override
  Future<bool> restartCore() async {
    throw _restartFailure;
  }
}

final _restartFailure = Exception('restart failed');

class _AuthorizationSetupAction extends SetupAction {
  final List<AuthorizeCode> authorizationResults;
  int authorizationRequestCount = 0;
  bool adminAuthorized = false;

  _AuthorizationSetupAction(this.authorizationResults);

  @override
  Future<AuthorizeCode> authorizeCore() async {
    return authorizationResults[authorizationRequestCount++];
  }

  @override
  Future<bool> checkCoreAuthorization() async => adminAuthorized;
}

class _RaceSetupAction extends SetupAction {
  int applyProfileDebounceCount = 0;
  int resetCoreTrafficCount = 0;
  final transitions = <bool>[];
  Completer<bool>? startCompleter;
  Completer<bool>? stopCompleter;

  @override
  void applyProfileDebounce({bool silence = false, bool force = false}) {
    applyProfileDebounceCount++;
  }

  @override
  Future<bool> setCoreRunning(bool running) async {
    transitions.add(running);
    return running
        ? await startCompleter?.future ?? true
        : await stopCompleter?.future ?? true;
  }

  @override
  void resetCoreTraffic() {
    resetCoreTrafficCount++;
  }
}

class _InitializingSetupAction extends _RaceSetupAction {
  final _initializationCompleter = Completer<void>();

  void continueInitialization() {
    _initializationCompleter.complete();
  }

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    await _initializationCompleter.future;
    await preloadInvoke?.call();
    return true;
  }
}

class _RaceCommonAction extends CommonAction {
  int updateTrafficCount = 0;

  @override
  Future<void> updateTraffic() async {
    updateTrafficCount++;
  }
}
