import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/database/database.dart' as db;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late _MockCoreHandlerInterface core;
  late db.Database testDatabase;

  setUpAll(() {
    registerFallbackValue(0);
    registerFallbackValue(const OdometerSignal(OdometerSignalKind.prepareDown));
    home = Directory.systemTemp.createTempSync('reclash-store-');
    AppPath.supportDirectory = () async => home;
    AppPath.temporaryDirectory = () async => home;
    AppPath.cacheDirectory = () async => home;
    AppPath.downloadDirectory = () async => home;
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await preferences.setVersion(7);
    core = _MockCoreHandlerInterface();
    when(() => core.clearEffect(any())).thenAnswer((_) async => '');
    when(() => core.stopListener()).thenAnswer((_) async => true);
    when(() => core.getTraffic(any())).thenAnswer((_) async => const Traffic());
    when(
      () => core.getTotalTraffic(any()),
    ).thenAnswer((_) async => const Traffic());
    when(() => core.signalOdometer(any())).thenAnswer((_) async => true);
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
        coreHandlerProvider.overrideWithValue(core),
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

  group('StoreAction preferences', () {
    test('an immediate save cancels the older debounced snapshot', () async {
      final container = buildContainer();
      final action = container.read(storeActionProvider.notifier);

      action.savePreferencesDebounce();
      container
          .read(desyncSettingProvider.notifier)
          .update((state) => state.copyWith(testRunning: true));
      expect(await action.savePreferences(), isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 700));

      final config = await preferences.getConfig();
      expect(config?.desyncProps.testRunning, isTrue);
    });
  });

  group('StoreAction.handleClear', () {
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

    test('removes scripts, the applied config and local caches', () async {
      final homeDirPath = await appPath.homeDirPath;
      final scriptsDir = Directory(await appPath.scriptsDirPath)
        ..createSync(recursive: true);
      File(join(scriptsDir.path, '1.js')).writeAsStringSync('x');
      final configFile = File(await appPath.configFilePath)
        ..writeAsStringSync('x');
      final restoreDir = Directory(await appPath.restoreDirPath)
        ..createSync(recursive: true);
      File(join(restoreDir.path, 'stale.json')).writeAsStringSync('x');
      final logsDir = Directory(join(homeDirPath, 'logs'))
        ..createSync(recursive: true);
      File(join(logsDir.path, 'ReClash_2026-01-01.log'))
          .writeAsStringSync('x');
      final dashboardEntry = File(
        join(webDashboardDirIn(homeDirPath), 'zashboard', 'index.html'),
      )..createSync(recursive: true);
      dashboardEntry.writeAsStringSync('x');
      final geoFiles = [MMDB, GEOIP, GEOSITE, ASN]
          .map((name) => File(join(homeDirPath, name))..writeAsStringSync('x'))
          .toList();
      final staleApk = File(join(homeDirPath, 'update-v1.apk'))
        ..writeAsStringSync('x');
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      expect(scriptsDir.existsSync(), isFalse);
      expect(configFile.existsSync(), isFalse);
      expect(restoreDir.existsSync(), isFalse);
      expect(logsDir.existsSync(), isFalse);
      expect(Directory(webDashboardDirIn(homeDirPath)).existsSync(), isFalse);
      for (final geoFile in geoFiles) {
        expect(geoFile.existsSync(), isFalse);
      }
      expect(staleApk.existsSync(), isFalse);
    });

    test('removes database sidecar files but keeps the backup', () async {
      final databasePath = await appPath.databasePath;
      final sidecars = ['-wal', '-shm', '-journal']
          .map((suffix) => File('$databasePath$suffix')..writeAsStringSync('x'))
          .toList();
      final backupFile = File(await appPath.backupFilePath)
        ..writeAsStringSync('x');
      final lockFile = File(await appPath.lockFilePath)
        ..writeAsStringSync('x');
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      for (final sidecar in sidecars) {
        expect(sidecar.existsSync(), isFalse);
      }
      expect(
        backupFile.existsSync(),
        isTrue,
        reason: 'the backup is the only way back the dialog promises.',
      );
      expect(lockFile.existsSync(), isTrue);
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

    test('stops the running tunnel before wiping', () async {
      final container = buildContainer();
      container.read(runTimeProvider.notifier).value = 0;

      await container.read(storeActionProvider.notifier).handleClear();

      verify(() => core.stopListener()).called(1);
      expect(
        container.read(runTimeProvider),
        isNull,
        reason: 'the tunnel is down before its profiles are deleted.',
      );
      expect(_RecordingSystemAction.exits, [false]);
    });

    test('skips the tunnel stop when it is already down', () async {
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      verifyNever(() => core.stopListener());
      expect(_RecordingSystemAction.exits, [false]);
    });

    test('a failed tunnel stop never blocks the wipe', () async {
      when(() => core.stopListener()).thenThrow(Exception('tunnel stuck'));
      final container = buildContainer();
      container.read(runTimeProvider.notifier).value = 0;

      await container.read(storeActionProvider.notifier).handleClear();

      expect(
        await preferences.getVersion(),
        0,
        reason:
            'the exit at the end tears the tunnel down anyway, so a stop '
            'failure must not cancel the wipe.',
      );
      expect(_RecordingSystemAction.exits, [false]);
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
