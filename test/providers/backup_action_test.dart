import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:reclash/common/common.dart';
import 'package:archive/archive.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/app_paths.dart';
import '../helpers/preferences.dart';

final _wallpaperPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Profile _profile(int id, String label) => Profile(
  id: id,
  label: label,
  autoUpdateDuration: Duration.zero,
  extendType: ExtendType.standard,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database testDatabase;
  late Directory home;

  setUpAll(() async {
    await mockPreferences({'version': 1});
    await AppLocalizations.load(const Locale('en'));
    home = Directory.systemTemp.createTempSync('reclash-backup-action-');
    await useAppPaths(home);
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  setUp(() {
    testDatabase = Database(NativeDatabase.memory());
    database = testDatabase;
  });

  tearDown(() async {
    await testDatabase.close();
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  BackupAction actionOf(ProviderContainer container) =>
      container.read(backupActionProvider.notifier);

  Map<String, Object?> configMapOf(ProviderContainer container) =>
      jsonDecode(jsonEncode(container.read(configProvider).toJson()))
          as Map<String, Object?>;

  group('backup and restore round trip', () {
    late Directory kept;

    setUp(() {
      kept = Directory.systemTemp.createTempSync('reclash-backup-kept-');
      addTearDown(() => kept.deleteSync(recursive: true));
    });

    Set<String> workDirs() => home
        .listSync()
        .map((entity) => basename(entity.path))
        .where((name) => name.startsWith('backup'))
        .toSet();

    Future<String> backupToKept(BackupAction action) async {
      final keptPath = join(kept.path, 'kept.zip');
      final delivered = await action.backup((archivePath) async {
        File(archivePath).copySync(keptPath);
        return true;
      });
      expect(delivered, isTrue);
      return keptPath;
    }

    test('restores wallpaper files and removes old library orphans', () async {
      const name = '0123456789abcdef0123456789abcdef.png';
      final source = buildContainer()..listen(configProvider, (_, _) {});
      const oldName = 'fedcba9876543210fedcba9876543210.png';
      const oldTheme = ThemeProps(
        wallpaper: WallpaperProps(
          enabled: true,
          fileName: oldName,
          library: [oldName],
        ),
      );
      source.read(themeSettingProvider.notifier).value = const ThemeProps(
        wallpaper: WallpaperProps(
          enabled: true,
          fileName: name,
          library: [name],
        ),
      );
      final oldFile =
          File(
              join(
                await appPath.wallpapersDirPath,
                'fedcba9876543210fedcba9876543210.png',
              ),
            )
            ..createSync(recursive: true)
            ..writeAsBytesSync([1]);
      final newFile = File(join(await appPath.wallpapersDirPath, name))
        ..createSync(recursive: true)
        ..writeAsBytesSync(_wallpaperPng);
      expect(newFile.existsSync(), isTrue);
      expect(
        BackupEntries.of(
          profileIds: const [],
          scriptIds: const [],
          providers: const [],
          wallpaperLibrary: source
              .read(configProvider)
              .themeProps
              .wallpaper
              .library,
        ),
        contains('wallpapers/$name'),
      );
      final archivePath = await backupToKept(actionOf(source));
      final archiveEntries = ZipDecoder()
          .decodeBytes(File(archivePath).readAsBytesSync())
          .files
          .map((file) => file.name);
      expect(archiveEntries, contains('wallpapers/$name'));
      newFile.deleteSync();
      final target = buildContainer()..listen(configProvider, (_, _) {});
      target.read(themeSettingProvider.notifier).value = oldTheme;

      await actionOf(
        target,
      ).restore(RestoreOption.all, (_) async => archivePath);

      expect(
        File(join(await appPath.wallpapersDirPath, name)).readAsBytesSync(),
        _wallpaperPng,
      );
      expect(oldFile.existsSync(), isFalse);
      expect(target.read(themeSettingProvider).wallpaper.fileName, name);
    });

    test(
      'onlyProfiles leaves wallpaper settings and files untouched',
      () async {
        const name = '0123456789abcdef0123456789abcdef.png';
        const wallpaper = WallpaperProps(
          enabled: true,
          fileName: name,
          library: [name],
        );
        final original = File(join(await appPath.wallpapersDirPath, name))
          ..createSync(recursive: true)
          ..writeAsBytesSync(_wallpaperPng);
        final container = buildContainer()..listen(configProvider, (_, _) {});
        container.read(themeSettingProvider.notifier).value = const ThemeProps(
          wallpaper: wallpaper,
        );

        await actionOf(container).applyRestore(
          const MigrationData(configMap: {'themeProps': {}}),
          RestoreOption.onlyProfiles,
        );

        expect(container.read(themeSettingProvider).wallpaper, wallpaper);
        expect(original.readAsBytesSync(), _wallpaperPng);
      },
    );

    test('a restore with a missing referenced wallpaper is rejected', () async {
      const name = '0123456789abcdef0123456789abcdef.png';
      final source = buildContainer()..listen(configProvider, (_, _) {});
      source.read(themeSettingProvider.notifier).value = const ThemeProps(
        wallpaper: WallpaperProps(fileName: name, library: [name]),
      );
      final configMap = configMapOf(source)..['version'] = 1;
      final archive = Archive()
        ..addFile(ArchiveFile.string(configJsonName, jsonEncode(configMap)));
      final archivePath = join(kept.path, 'missing-wallpaper.zip');
      File(archivePath).writeAsBytesSync(ZipEncoder().encode(archive));
      final target = buildContainer()..listen(configProvider, (_, _) {});

      await expectLater(
        actionOf(target).restore(RestoreOption.all, (_) async => archivePath),
        throwsA(isA<MessageException>()),
      );
      expect(target.read(themeSettingProvider).wallpaper.library, isEmpty);
    });

    test('restores the rows, files and settings a backup carries', () async {
      await testDatabase.profilesDao.putAll([
        _profile(1, 'Backed up').toCompanion(0),
      ]);
      final profileFile = File(await appPath.getProfilePath('1'))
        ..createSync(recursive: true)
        ..writeAsStringSync('proxies: []');
      final source = buildContainer()..listen(configProvider, (_, _) {});
      source.read(excludeSSIDsProvider.notifier).value = ['home-wifi'];
      final archivePath = await backupToKept(actionOf(source));

      await testDatabase.delete(testDatabase.profiles).go();
      profileFile.deleteSync();
      final target = buildContainer()..listen(configProvider, (_, _) {});
      final restored = await actionOf(
        target,
      ).restore(RestoreOption.all, (_) async => archivePath);

      expect(restored, isTrue);
      final stored = await testDatabase.profilesDao.query().get();
      expect(stored.map((item) => item.label), ['Backed up']);
      expect(profileFile.readAsStringSync(), 'proxies: []');
      expect(target.read(excludeSSIDsProvider), ['home-wifi']);
      expect(workDirs(), isEmpty);
    });

    test('removes the work directory when delivery fails', () async {
      final container = buildContainer();

      await expectLater(
        actionOf(
          container,
        ).backup((_) async => throw const SocketException('offline')),
        throwsA(isA<SocketException>()),
      );

      expect(workDirs(), isEmpty);
    });

    test('a cancelled fetch changes nothing', () async {
      final container = buildContainer();

      final restored = await actionOf(
        container,
      ).restore(RestoreOption.all, (_) async => null);

      expect(restored, isFalse);
    });

    test('an unreadable archive is reported and changes nothing', () async {
      await testDatabase.profilesDao.putAll([
        _profile(9, 'Pre-existing').toCompanion(0),
      ]);
      final bogus = File(join(kept.path, 'bogus.zip'))
        ..writeAsStringSync('not a zip');
      final container = buildContainer();

      await expectLater(
        actionOf(container).restore(RestoreOption.all, (_) async => bogus.path),
        throwsA(
          isA<MessageException>().having(
            (error) => error.message,
            'message',
            currentAppLocalizations.invalidBackupFile,
          ),
        ),
      );

      final stored = await testDatabase.profilesDao.query().get();
      expect(stored.map((item) => item.label), ['Pre-existing']);
      expect(workDirs(), isEmpty);
    });

    test('removes the staging an earlier version left behind', () async {
      final legacyArchive = File(join(home.path, 'backup.zip'))
        ..writeAsStringSync('stale');
      final legacyStaging = Directory(join(home.path, 'restore'))..createSync();
      final container = buildContainer();

      await actionOf(container).restore(RestoreOption.all, (_) async => null);

      expect(legacyArchive.existsSync(), isFalse);
      expect(legacyStaging.existsSync(), isFalse);
    });
  });

  group('applyRestore writes the database', () {
    test('inserts the profiles the backup carries', () async {
      final container = buildContainer();

      await actionOf(container).applyRestore(
        MigrationData(profiles: [_profile(1, 'From backup')]),
        RestoreOption.onlyProfiles,
      );

      final stored = await testDatabase.profilesDao.query().get();
      expect(stored.map((item) => item.label), ['From backup']);
    });

    test('an override restore drops profiles the backup omits', () async {
      final container = buildContainer();
      await testDatabase.profilesDao.putAll([
        _profile(9, 'Pre-existing').toCompanion(0),
      ]);
      container
          .read(appSettingProvider.notifier)
          .update(
            (state) =>
                state.copyWith(restoreStrategy: RestoreStrategy.override),
          );

      await actionOf(container).applyRestore(
        MigrationData(profiles: [_profile(1, 'From backup')]),
        RestoreOption.onlyProfiles,
      );

      final stored = await testDatabase.profilesDao.query().get();
      expect(stored.map((item) => item.label), ['From backup']);
    });

    test('a compatible restore keeps profiles the backup omits', () async {
      final container = buildContainer();
      await testDatabase.profilesDao.putAll([
        _profile(9, 'Pre-existing').toCompanion(0),
      ]);
      container
          .read(appSettingProvider.notifier)
          .update(
            (state) =>
                state.copyWith(restoreStrategy: RestoreStrategy.compatible),
          );

      await actionOf(container).applyRestore(
        MigrationData(profiles: [_profile(1, 'From backup')]),
        RestoreOption.onlyProfiles,
      );

      final stored = await testDatabase.profilesDao.query().get();
      expect(stored.map((item) => item.label).toSet(), {
        'Pre-existing',
        'From backup',
      });
    });

    test('a restore drops the cache of a provider it replaced', () async {
      const dropped = ClashProvider(
        id: 5,
        label: 'Dropped',
        url: 'https://example.com/dropped.yaml',
      );
      const kept = ClashProvider(id: 6, label: 'Kept');
      await testDatabase.clashProvidersDao.putAll(
        [dropped, kept].map((item) => item.toCompanion()),
      );
      for (final path in [
        await dropped.path,
        await dropped.compiledPath,
        await kept.path,
        await kept.compiledPath,
      ]) {
        File(path).createSync(recursive: true);
      }
      final container = buildContainer();
      container
          .read(appSettingProvider.notifier)
          .update(
            (state) =>
                state.copyWith(restoreStrategy: RestoreStrategy.override),
          );

      await actionOf(container).applyRestore(
        const MigrationData(clashProviders: [kept]),
        RestoreOption.onlyProfiles,
      );

      expect(File(await dropped.path).existsSync(), isFalse);
      expect(File(await dropped.compiledPath).existsSync(), isFalse);
      expect(File(await kept.path).existsSync(), isTrue);
      expect(
        File(await kept.compiledPath).existsSync(),
        isFalse,
        reason: 'the restored source is compiled again on first use',
      );
    });

    test('rows that fail to restore take their files back out', () async {
      final replaced = File(await appPath.getProfilePath('41'))
        ..createSync(recursive: true)
        ..writeAsStringSync('current');
      final added = File(await appPath.getProfilePath('42'));
      final staging = Directory.systemTemp.createTempSync('reclash-staging-');
      addTearDown(() => staging.deleteSync(recursive: true));
      for (final id in [41, 42]) {
        File(BackupEntries.resolve(staging.path, BackupEntries.profile(id)))
          ..createSync(recursive: true)
          ..writeAsStringSync('from backup');
      }
      await testDatabase.customStatement(
        'CREATE TRIGGER refuse_profiles BEFORE INSERT ON profiles '
        "BEGIN SELECT RAISE(ABORT, 'refused'); END",
      );

      await expectLater(
        actionOf(buildContainer()).applyRestore(
          MigrationData(profiles: [_profile(41, 'One'), _profile(42, 'Two')]),
          RestoreOption.onlyProfiles,
          stagingDirPath: staging.path,
        ),
        throwsA(anything),
      );

      expect(replaced.readAsStringSync(), 'current');
      expect(added.existsSync(), isFalse);
    });

    test('a backup carrying only proxy groups still writes them', () async {
      await testDatabase.profiles.put(
        const Profile(id: 7, autoUpdateDuration: Duration.zero).toCompanion(),
      );
      final container = buildContainer();

      await actionOf(container).applyRestore(
        const MigrationData(
          proxyGroups: [
            ProxyGroup(
              id: 1,
              profileId: 7,
              name: 'Selector',
              type: GroupType.Selector,
            ),
          ],
        ),
        RestoreOption.onlyProfiles,
      );

      final stored = await testDatabase.proxyGroupsDao.query(7).get();
      expect(
        stored.map((item) => item.name),
        ['Selector'],
        reason:
            'proxyGroups belongs in the guard that decides whether the batch '
            'runs, not only in the batch body',
      );
    });
  });

  group('applyRestore writes the settings providers', () {
    test('restores every settings provider the config carries', () async {
      final source = buildContainer();
      source
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(autoLaunch: true));
      source.read(currentProfileIdProvider.notifier).value = 42;
      source
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mixedPort: 7899));
      final configMap = configMapOf(source);

      final target = buildContainer();
      await actionOf(
        target,
      ).applyRestore(MigrationData(configMap: configMap), RestoreOption.all);

      expect(target.read(currentProfileIdProvider), 42);
      expect(target.read(appSettingProvider).autoLaunch, isTrue);
      expect(target.read(patchClashConfigProvider).mixedPort, 7899);
    });

    test('keeps the bound WebDAV account when the backup has none', () async {
      final configMap = configMapOf(buildContainer());
      const dav = DAVProps(uri: 'https://dav.example', user: 'me');
      final target = buildContainer();
      target.read(davSettingProvider.notifier).value = dav;

      await actionOf(
        target,
      ).applyRestore(MigrationData(configMap: configMap), RestoreOption.all);

      expect(target.read(davSettingProvider), dav);
    });

    test('keeps the picked apps when the backup lists none', () async {
      final configMap = configMapOf(buildContainer());
      const picked = AccessControlProps(
        enable: true,
        mode: AccessControlMode.acceptSelected,
        acceptList: ['com.example.browser'],
      );
      final target = buildContainer();
      target
          .read(vpnSettingProvider.notifier)
          .update((state) => state.copyWith(accessControlProps: picked));

      await actionOf(
        target,
      ).applyRestore(MigrationData(configMap: configMap), RestoreOption.all);

      expect(target.read(vpnSettingProvider).accessControlProps, picked);
    });

    test('takes the apps a backup lists from another phone', () async {
      const listed = AccessControlProps(
        enable: true,
        rejectList: ['com.example.bank'],
      );
      final source = buildContainer();
      source
          .read(vpnSettingProvider.notifier)
          .update((state) => state.copyWith(accessControlProps: listed));
      final configMap = configMapOf(source);
      final target = buildContainer();
      target
          .read(vpnSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              accessControlProps: const AccessControlProps(
                acceptList: ['com.example.browser'],
              ),
            ),
          );

      await actionOf(
        target,
      ).applyRestore(MigrationData(configMap: configMap), RestoreOption.all);

      expect(target.read(vpnSettingProvider).accessControlProps, listed);
    });

    test('leaves the settings untouched for an onlyProfiles restore', () async {
      final source = buildContainer();
      source.read(currentProfileIdProvider.notifier).value = 42;
      final configMap = configMapOf(source);

      final target = buildContainer();
      final before = target.read(currentProfileIdProvider);

      await actionOf(target).applyRestore(
        MigrationData(configMap: configMap, profiles: [_profile(1, 'P')]),
        RestoreOption.onlyProfiles,
      );

      expect(target.read(currentProfileIdProvider), before);
      expect(await testDatabase.profilesDao.query().get(), hasLength(1));
    });

    test('a backup without a config still restores the database', () async {
      final container = buildContainer();
      final before = container.read(currentProfileIdProvider);

      await actionOf(container).applyRestore(
        MigrationData(profiles: [_profile(1, 'P')]),
        RestoreOption.all,
      );

      expect(container.read(currentProfileIdProvider), before);
      expect(await testDatabase.profilesDao.query().get(), hasLength(1));
    });
  });

  group('a config with unreadable values', () {
    test('restores the rest without keeping a dropped profile', () async {
      final container = buildContainer();
      await testDatabase.profilesDao.putAll([
        _profile(9, 'Pre-existing').toCompanion(0),
      ]);
      container.read(currentProfileIdProvider.notifier).value = 9;
      container
          .read(appSettingProvider.notifier)
          .update(
            (state) =>
                state.copyWith(restoreStrategy: RestoreStrategy.override),
          );

      await actionOf(container).applyRestore(
        MigrationData(
          configMap: const {
            'currentProfileId': 'not an int',
            'appSettingProps': {'hideIp': true},
          },
          profiles: [_profile(1, 'From backup')],
        ),
        RestoreOption.all,
      );

      final stored = await testDatabase.profilesDao.query().get();
      expect(stored.map((item) => item.label), ['From backup']);
      expect(container.read(currentProfileIdProvider), isNull);
      expect(container.read(appSettingProvider).hideIp, true);
    });
  });
}
