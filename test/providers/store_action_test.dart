import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/common/web_dashboard/installation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/database/database.dart' as db;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/web_dashboard.dart';
import 'package:reclash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/app_paths.dart';
import '../helpers/preferences.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _RecordingSystemAction extends SystemAction {
  static final exits = <bool>[];

  @override
  Future<void> handleExit([bool needSave = true]) async {
    exits.add(needSave);
  }
}

class _TestProfiles extends Profiles {
  _TestProfiles(this._profiles);

  final List<Profile> _profiles;

  @override
  List<Profile> build() => _profiles;
}

class _CancellableDashboardStore extends WebDashboardStore {
  _CancellableDashboardStore()
    : super(
        homeDirectory: () async => '',
        download:
            (uri, path, {required onProgress, required cancelToken}) async =>
                null,
      );

  final started = Completer<void>();
  bool cancelled = false;

  @override
  Future<Map<WebDashboardFlavor, WebDashboardInstallation>>
  installations() async => {};

  @override
  Future<void> install(
    WebDashboardFlavor flavor, {
    required CancelToken cancelToken,
    required ValueChanged<WebDashboardProgress> onProgress,
    WebDashboardRelease? release,
  }) async {
    started.complete();
    await cancelToken.whenCancel;
    cancelled = true;
    throw const WebDashboardException(WebDashboardFailure.cancelled);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late _MockCoreHandlerInterface core;
  late db.Database testDatabase;

  setUpAll(() async {
    registerFallbackValue(0);
    home = Directory.systemTemp.createTempSync('reclash-store-');
    await useAppPaths(home);
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  setUp(() async {
    await mockPreferences();
    await preferences.setVersion(7);
    core = _MockCoreHandlerInterface();
    when(() => core.clearEffect(any())).thenAnswer((_) async => '');
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    _RecordingSystemAction.exits.clear();
    debouncer.cancel(FunctionTag.savePreferences);

    final profilesDir = Directory(await appPath.profilesPath);
    if (profilesDir.existsSync()) profilesDir.deleteSync(recursive: true);
  });

  tearDown(() async {
    await testDatabase.close();
  });

  ProviderContainer buildContainer({List<Profile> profiles = const []}) {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        systemActionProvider.overrideWith(_RecordingSystemAction.new),
        profilesProvider.overrideWith(() => _TestProfiles(profiles)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    return container;
  }

  Future<Directory> providerDirFor(int profileId) async {
    final path = join(await appPath.getProvidersRootPath(), '$profileId');
    return Directory(path)..createSync(recursive: true);
  }

  Profile profile(int id) =>
      Profile(id: id, label: 'p$id', autoUpdateDuration: Duration.zero);

  group('StoreAction.handleClear', () {
    test(
      'cancels dashboard installation before clearing managed files',
      () async {
        final store = _CancellableDashboardStore();
        final container = ProviderContainer(
          overrides: [
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            systemActionProvider.overrideWith(_RecordingSystemAction.new),
            profilesProvider.overrideWith(() => _TestProfiles([])),
            webDashboardStoreProvider.overrideWithValue(store),
          ],
        );
        addTearDown(container.dispose);
        globalState.container = container;
        final dashboard = container.read(webDashboardActionProvider.notifier);
        final access = container.read(webDashboardAccessProvider.notifier);
        final owner = access.acquire(WebDashboardFlavor.zashboard);
        access.keepForBrowser(owner);
        final installation = dashboard.install(WebDashboardFlavor.zashboard);
        await store.started.future;
        final managed = Directory(join(home.path, webDashboardDirectoryName))
          ..createSync();
        File(join(managed.path, 'old')).writeAsStringSync('old');

        await container.read(storeActionProvider.notifier).handleClear();

        expect(await installation, isFalse);
        expect(store.cancelled, isTrue);
        expect(container.read(webDashboardActionProvider).busy, isFalse);
        expect(access.contains(owner), isFalse);
        expect(managed.existsSync(), isFalse);
        expect(_RecordingSystemAction.exits, [false]);
      },
    );

    test('clears the core effect of every profile still in state', () async {
      final container = buildContainer(profiles: [profile(1), profile(2)]);

      await container.read(storeActionProvider.notifier).handleClear();

      final cleared = verify(() => core.clearEffect(captureAny())).captured;
      expect(cleared.toSet(), {1, 2});
    });

    test('also clears profiles that only survive on disk', () async {
      await providerDirFor(41);
      await providerDirFor(42);
      final container = buildContainer(profiles: [profile(1)]);

      await container.read(storeActionProvider.notifier).handleClear();

      final cleared = verify(() => core.clearEffect(captureAny())).captured;
      expect(
        cleared.toSet(),
        {1, 41, 42},
        reason:
            'a provider directory left behind by a profile the database no '
            'longer knows about still holds downloaded rule data.',
      );
    });

    test('ignores provider entries that are not a profile id', () async {
      final root = Directory(await appPath.getProvidersRootPath())
        ..createSync(recursive: true);
      File(join(root.path, 'stray.txt')).writeAsStringSync('x');
      Directory(join(root.path, 'not-a-number')).createSync();
      Directory(join(root.path, '0')).createSync();
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      verifyNever(() => core.clearEffect(any()));
    });

    test('empties the preferences it was asked to clear', () async {
      final container = buildContainer();
      expect(await preferences.getVersion(), 7);

      await container.read(storeActionProvider.notifier).handleClear();

      expect(await preferences.getVersion(), 0);
    });

    test('removes the profiles directory', () async {
      await providerDirFor(3);
      final profilesDir = Directory(await appPath.profilesPath);
      expect(profilesDir.existsSync(), isTrue);
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      expect(profilesDir.existsSync(), isFalse);
    });

    test('exits without asking for a save', () async {
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      expect(
        _RecordingSystemAction.exits,
        [false],
        reason:
            'saving on the way out would write the config back over the '
            'preferences that were just cleared.',
      );
    });

    test('a pending preference save never lands after the clear', () async {
      final container = buildContainer();
      final action = container.read(storeActionProvider.notifier);

      action.savePreferencesDebounce();
      await action.handleClear();
      await Future<void>.delayed(const Duration(milliseconds: 700));

      expect(
        await preferences.getConfigMap(),
        isNull,
        reason:
            'handleClear cancels the debounced save first; without that the '
            'timer fires afterwards and writes the config straight back into '
            'the preferences that were just cleared.',
      );
    });
  });
}
