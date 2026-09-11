import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

class _StubbedArchiveBackupAction extends BackupAction {
  _StubbedArchiveBackupAction(this.archivePath);

  final String archivePath;

  @override
  Future<String> backup() async => archivePath;
}

class _ThrowingRestoreBackupAction extends BackupAction {
  @override
  Future<void> applyRestore(
    MigrationData data,
    RestoreOption option, {
    RestoreApplyContext context = const RestoreApplyContext(),
    String? stagingPath,
    String? rollbackPath,
  }) async {
    throw StateError('apply failed');
  }
}

Profile _profile(int id, String label) => Profile(
  id: id,
  label: label,
  autoUpdateDuration: Duration.zero,
  overwriteType: OverwriteType.standard,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database testDatabase;

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

  group('consumeBackup owns the archive it produced', () {
    File stubArchive() {
      final directory = Directory.systemTemp.createTempSync('reclash_backup');
      addTearDown(() => directory.deleteSync(recursive: true));
      final file = File('${directory.path}/backup.zip')
        ..writeAsBytesSync(const [80, 75, 5, 6]);
      return file;
    }

    ProviderContainer containerFor(String archivePath) {
      final container = ProviderContainer(
        overrides: [
          backupActionProvider.overrideWith(
            () => _StubbedArchiveBackupAction(archivePath),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('deletes the archive once it has been sent', () async {
      final archive = stubArchive();
      final container = containerFor(archive.path);
      String? sent;

      final result = await actionOf(container).consumeBackup((path) async {
        sent = path;
        return true;
      });

      expect(result, isTrue);
      expect(sent, archive.path);
      expect(archive.existsSync(), isFalse);
    });

    test('deletes the archive when sending it fails', () async {
      final archive = stubArchive();
      final container = containerFor(archive.path);

      await expectLater(
        actionOf(
          container,
        ).consumeBackup((_) async => throw const SocketException('offline')),
        throwsA(isA<SocketException>()),
      );

      expect(archive.existsSync(), isFalse);
    });
  });

  group('prepared restore lifecycle', () {
    late Directory root;
    late Directory originalDataDir;
    late Directory originalTempDir;

    File writeFile(String path, String content) => File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(content);

    Future<String> archive({
      String profileContent = 'proxies: []',
      Map<String, dynamic> configMap = const {'version': currentDataVersion},
    }) async {
      final source = Directory(join(root.path, 'source'))
        ..createSync(recursive: true);
      final profileFile = writeFile(
        join(source.path, 'profiles', '1.yaml'),
        profileContent,
      );
      final configFile = writeFile(
        join(source.path, configJsonName),
        jsonEncode(configMap),
      );
      final zipPath = join(root.path, 'backup.zip');
      final encoder = ZipFileEncoder()..create(zipPath);
      await encoder.addFile(configFile, configJsonName);
      await encoder.addFile(profileFile, 'profiles/1.yaml');
      await encoder.close();
      return zipPath;
    }

    PreparedRestore stagedRestore({
      String profileContent = 'restored',
      MigrationData? data,
      String? scriptContent,
    }) {
      final stagingPath = join(root.path, 'restore_stage');
      writeFile(
        join(stagingPath, 'content', 'profiles', '1.yaml'),
        profileContent,
      );
      if (scriptContent != null) {
        writeFile(
          join(stagingPath, 'content', 'scripts', '2.js'),
          scriptContent,
        );
      }
      final restoreData =
          data ?? MigrationData(profiles: [_profile(1, 'From backup')]);
      return PreparedRestore(
        stagingPath: stagingPath,
        data: restoreData,
        summary: RestoreSummary.fromData(restoreData),
      );
    }

    setUp(() async {
      root = Directory.systemTemp.createTempSync('prepared_restore');
      AppPath.supportDirectory = () async => root;
      AppPath.temporaryDirectory = () async => root;
      AppPath.cacheDirectory = () async => root;
      AppPath.downloadDirectory = () async => root;
      originalDataDir = await appPath.dataDir.future;
      originalTempDir = await appPath.tempDir.future;
      appPath.dataDir = Completer<Directory>()..complete(root);
      appPath.tempDir = Completer<Directory>()..complete(root);
    });

    tearDown(() {
      appPath.dataDir = Completer<Directory>()..complete(originalDataDir);
      appPath.tempDir = Completer<Directory>()..complete(originalTempDir);
      root.deleteSync(recursive: true);
    });

    test('prepare stages data without touching live files or rows', () async {
      final container = buildContainer();
      await testDatabase.profilesDao.putAll([
        _profile(9, 'Pre-existing').toCompanion(0),
      ]);
      writeFile(join(root.path, 'profiles', '9.yaml'), 'live');

      final prepared = await actionOf(
        container,
      ).prepareRestoreFromPath(await archive());

      expect(prepared.summary.profiles, 0);
      expect(prepared.summary.hasSettings, isTrue);
      expect(
        File(
          join(prepared.stagingPath, 'content', 'profiles', '1.yaml'),
        ).readAsStringSync(),
        'proxies: []',
      );
      expect(File(join(root.path, 'profiles', '1.yaml')).existsSync(), isFalse);
      expect(
        File(join(root.path, 'profiles', '9.yaml')).readAsStringSync(),
        'live',
      );
      final stored = await testDatabase.profilesDao.query().get();
      expect(stored.map((profile) => profile.label), ['Pre-existing']);
    });

    test(
      'discard removes staged content without changing live state',
      () async {
        final container = buildContainer();
        final prepared = await actionOf(
          container,
        ).prepareRestoreFromPath(await archive());

        await actionOf(container).discardPreparedRestore(prepared);

        expect(Directory(prepared.stagingPath).existsSync(), isFalse);
        expect(
          File(join(root.path, 'profiles', '1.yaml')).existsSync(),
          isFalse,
        );
        expect(await testDatabase.profilesDao.query().get(), isEmpty);
      },
    );

    test(
      'apply copies staged files and removes the stage on success',
      () async {
        final container = buildContainer();
        final prepared = stagedRestore();

        await actionOf(
          container,
        ).applyPreparedRestore(prepared, RestoreOption.onlyProfiles);

        expect(
          File(join(root.path, 'profiles', '1.yaml')).readAsStringSync(),
          'restored',
        );
        expect(Directory(prepared.stagingPath).existsSync(), isFalse);
        final stored = await testDatabase.profilesDao.query().get();
        expect(stored.map((profile) => profile.label), ['From backup']);
      },
    );

    test('failed apply retains the stage for recovery', () async {
      final container = ProviderContainer(
        overrides: [
          backupActionProvider.overrideWith(_ThrowingRestoreBackupAction.new),
        ],
      );
      addTearDown(container.dispose);
      final prepared = stagedRestore();

      await expectLater(
        actionOf(
          container,
        ).applyPreparedRestore(prepared, RestoreOption.onlyProfiles),
        throwsA(isA<StateError>()),
      );

      expect(Directory(prepared.stagingPath).existsSync(), isTrue);
      expect(
        File(
          join(prepared.stagingPath, 'content', 'profiles', '1.yaml'),
        ).readAsStringSync(),
        'restored',
      );
    });

    test('profiles-only restore does not copy staged scripts', () async {
      final container = buildContainer();
      final script = Script(
        id: 2,
        label: 'Backup script',
        lastUpdateTime: DateTime(2026),
      );
      final prepared = stagedRestore(
        data: MigrationData(
          profiles: [_profile(1, 'From backup')],
          scripts: [script],
        ),
        scriptContent: 'console.log(2);',
      );

      await actionOf(
        container,
      ).applyPreparedRestore(prepared, RestoreOption.onlyProfiles);

      expect(File(join(root.path, 'scripts', '2.js')).existsSync(), isFalse);
      expect(await testDatabase.scriptsDao.query().get(), isEmpty);
    });

    test(
      'failed database restore rolls back files and retains stage',
      () async {
        final container = buildContainer();
        await testDatabase.profilesDao.putAll([
          _profile(1, 'Original').toCompanion(0),
        ]);
        writeFile(join(root.path, 'profiles', '1.yaml'), 'original');
        await testDatabase.customStatement('''
        CREATE TRIGGER reject_restore
        BEFORE UPDATE ON profiles
        WHEN NEW.label = 'From backup'
        BEGIN
          SELECT RAISE(ABORT, 'rejected');
        END
      ''');
        final prepared = stagedRestore(profileContent: 'replacement');

        await expectLater(
          actionOf(
            container,
          ).applyPreparedRestore(prepared, RestoreOption.onlyProfiles),
          throwsA(isA<Exception>()),
        );

        expect(
          File(join(root.path, 'profiles', '1.yaml')).readAsStringSync(),
          'original',
        );
        expect(
          (await testDatabase.profilesDao.query().get()).single.label,
          'Original',
        );
        expect(Directory(prepared.stagingPath).existsSync(), isTrue);
        expect(
          File(
            join(prepared.stagingPath, 'content', 'profiles', '1.yaml'),
          ).readAsStringSync(),
          'replacement',
        );
      },
    );

    test('setup context publishes only merged onboarding settings', () async {
      final source = buildContainer();
      source.read(appSettingProvider.notifier).value = const AppSettingProps(
        disclaimerAccepted: false,
        crashlyticsTip: false,
        crashlytics: true,
        setupCompleted: true,
        setupStep: 0,
      );
      final configMap = configMapOf(source);
      final target = ProviderContainer(
        overrides: [
          appSettingProvider.overrideWithBuild(
            (_, _) => const AppSettingProps(),
          ),
        ],
      );
      addTearDown(target.dispose);
      final before = target
          .read(appSettingProvider)
          .copyWith(
            disclaimerAccepted: true,
            crashlyticsTip: true,
            setupStep: 2,
          );
      target.read(appSettingProvider.notifier).value = before;
      final values = <AppSettingProps>[before];
      final subscription = target.listen<AppSettingProps>(
        appSettingProvider,
        (_, next) => values.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await actionOf(target).applyRestore(
        MigrationData(configMap: configMap),
        RestoreOption.all,
        context: RestoreApplyContext.setup(before),
      );
      values.add(target.read(appSettingProvider));

      expect(
        values,
        everyElement(
          isA<AppSettingProps>()
              .having(
                (settings) => settings.disclaimerAccepted,
                'disclaimerAccepted',
                isTrue,
              )
              .having(
                (settings) => settings.crashlyticsTip,
                'crashlyticsTip',
                isTrue,
              )
              .having(
                (settings) => settings.setupCompleted,
                'setupCompleted',
                isFalse,
              )
              .having((settings) => settings.setupStep, 'setupStep', 2),
        ),
      );
      expect(target.read(appSettingProvider).crashlytics, isFalse);
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

    test('profiles-only restore leaves non-profile rows untouched', () async {
      final container = buildContainer();
      final keptScript = Script(
        id: 2,
        label: 'Kept script',
        lastUpdateTime: DateTime(2026),
      );
      const keptRule = Rule(
        id: 3,
        content: 'kept.example',
        ruleTarget: 'DIRECT',
      );
      const keptGroup = ProxyGroup(
        id: 4,
        profileId: 1,
        name: 'Kept group',
        type: GroupType.Selector,
      );
      await testDatabase.restore(
        [_profile(1, 'Existing')],
        [keptScript],
        [keptRule],
        const [
          ProfileRuleLink(profileId: 1, ruleId: 3, scene: RuleScene.added),
        ],
        [keptGroup],
        isOverride: true,
      );
      container
          .read(appSettingProvider.notifier)
          .update(
            (state) =>
                state.copyWith(restoreStrategy: RestoreStrategy.override),
          );
      final backupScript = Script(
        id: 12,
        label: 'Backup script',
        lastUpdateTime: DateTime(2026),
      );

      await actionOf(container).applyRestore(
        MigrationData(
          profiles: [_profile(1, 'From backup')],
          scripts: [backupScript],
          rules: const [
            Rule(id: 13, content: 'backup.example', ruleTarget: 'REJECT'),
          ],
          proxyGroups: const [
            ProxyGroup(
              id: 14,
              profileId: 1,
              name: 'Backup group',
              type: GroupType.Selector,
            ),
          ],
        ),
        RestoreOption.onlyProfiles,
      );

      expect(
        (await testDatabase.profilesDao.query().get()).map((item) => item.id),
        [1],
      );
      expect(
        (await testDatabase.scriptsDao.query().get()).map((item) => item.id),
        [keptScript.id],
      );
      expect(
        (await testDatabase.rulesDao.queryProfileAddedRules(1).get()).map(
          (item) => item.id,
        ),
        [keptRule.id],
      );
      expect(
        (await testDatabase.proxyGroupsDao.query(1).get()).map(
          (item) => item.id,
        ),
        [keptGroup.id],
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
      source.read(overrideDnsProvider.notifier).value = true;
      final configMap = configMapOf(source);

      final target = buildContainer();
      await actionOf(
        target,
      ).applyRestore(MigrationData(configMap: configMap), RestoreOption.all);

      expect(target.read(currentProfileIdProvider), 42);
      expect(target.read(appSettingProvider).autoLaunch, isTrue);
      expect(target.read(patchClashConfigProvider).mixedPort, 7899);
      expect(target.read(overrideDnsProvider), isTrue);
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

  group('a malformed config aborts before the database is touched', () {
    test('leaves the existing profiles in place', () async {
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

      await expectLater(
        actionOf(container).applyRestore(
          MigrationData(
            configMap: const {'currentProfileId': 'not an int'},
            profiles: [_profile(1, 'From backup')],
          ),
          RestoreOption.all,
        ),
        throwsA(isA<TypeError>()),
      );

      final stored = await testDatabase.profilesDao.query().get();
      expect(
        stored.map((item) => item.label),
        ['Pre-existing'],
        reason:
            'an override restore deletes every profile the backup omits, so a '
            'config that cannot be parsed must abort before the batch runs; '
            'otherwise the profiles are replaced and currentProfileId still '
            'points at a row that was just deleted',
      );
    });
  });
}
