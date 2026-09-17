part of '../action.dart';

class _RestoreFileRollback {
  _RestoreFileRollback(this.entries);

  final List<_RestoreFileEntry> entries;

  static Future<_RestoreFileRollback> prepare(
    List<({String from, String to})> copies, {
    String? rollbackPath,
  }) async {
    final root = rollbackPath == null ? null : Directory(rollbackPath);
    if (root != null) {
      await root.safeDelete(recursive: true);
      await root.create(recursive: true);
    }
    final entries = <_RestoreFileEntry>[];
    for (final (index, copy) in copies.indexed) {
      final target = File(copy.to);
      final existed = await target.exists();
      File? backup;
      if (existed) {
        if (root != null) {
          backup = File(join(root.path, '$index.backup'));
        } else {
          backup = File('${target.path}.restore-backup-$uniqueId');
        }
        await target.safeCopy(backup.path);
      }
      entries.add(
        _RestoreFileEntry(
          source: File(copy.from),
          target: target,
          backup: backup,
          existed: existed,
        ),
      );
    }
    return _RestoreFileRollback(entries);
  }

  Future<void> apply() async {
    for (final entry in entries) {
      await entry.source.safeCopy(entry.target.path);
    }
  }

  Future<void> discard() async {
    for (final entry in entries) {
      final backup = entry.backup;
      if (backup != null) await backup.safeDelete();
    }
  }

  Future<void> restore() async {
    for (final entry in entries.reversed) {
      if (entry.existed) {
        final backup = entry.backup;
        if (backup != null) await backup.safeCopy(entry.target.path);
      } else {
        await entry.target.safeDelete();
      }
    }
  }
}

class _RestoreFileEntry {
  const _RestoreFileEntry({
    required this.source,
    required this.target,
    required this.backup,
    required this.existed,
  });

  final File source;
  final File target;
  final File? backup;
  final bool existed;
}

@immutable
class RestoreSummary {
  const RestoreSummary({
    required this.profiles,
    required this.scripts,
    required this.rules,
    required this.proxyGroups,
    required this.hasSettings,
  });

  factory RestoreSummary.fromData(MigrationData data) => RestoreSummary(
    profiles: data.profiles.length,
    scripts: data.scripts.length,
    rules: data.rules.length,
    proxyGroups: data.proxyGroups.length,
    hasSettings: data.configMap != null,
  );

  final int profiles;
  final int scripts;
  final int rules;
  final int proxyGroups;
  final bool hasSettings;
}

@immutable
class PreparedRestore {
  const PreparedRestore({
    required this.stagingPath,
    required this.data,
    required this.summary,
  });

  final String stagingPath;
  final MigrationData data;
  final RestoreSummary summary;
}

@immutable
class RestoreApplyContext {
  const RestoreApplyContext({this.mergeAppSettings});

  factory RestoreApplyContext.setup(AppSettingProps current) {
    return RestoreApplyContext(
      mergeAppSettings: (restored) => restored.copyWith(
        disclaimerAccepted: current.disclaimerAccepted,
        crashlyticsTip: current.crashlyticsTip,
        crashlytics: current.crashlytics,
        setupCompleted: current.setupCompleted,
        setupStep: current.setupStep,
      ),
    );
  }

  final AppSettingProps Function(AppSettingProps restored)? mergeAppSettings;
}

@visibleForTesting
String? restoreWallpaperFileName(Map? configMap) =>
    wallpaperFileNameOf(configMap);

@Riverpod(keepAlive: true)
class BackupAction extends _$BackupAction {
  @override
  void build() {}

  Future<bool> consumeBackup(Future<bool> Function(String path) send) async {
    final path = await backup();
    if (path.isEmpty) {
      return false;
    }
    try {
      return await send(path);
    } finally {
      await File(path).safeDelete();
    }
  }

  @visibleForTesting
  Future<String> backup() async {
    final res = await Future.wait([
      database.profilesDao.fileNames().get(),
      database.scriptsDao.fileNames().get(),
    ]);
    final profileFileNames = res[0];
    final scriptFileNames = res[1];
    final configMap = ref.read(configProvider).toJson();
    configMap['version'] = currentDataVersion;
    final snapshotPath = join(
      await appPath.tempPath,
      'backup_snapshot_$uniqueId.sqlite',
    );
    try {
      await createDatabaseSnapshot(database, snapshotPath);
      return await backupTask(configMap, [
        ...profileFileNames,
        ...scriptFileNames,
      ], databasePath: snapshotPath);
    } finally {
      await File(snapshotPath).safeDelete();
    }
  }

  Future<PreparedRestore?> preparePickedRestore() async {
    final file = await globalState.safeRun(picker.pickerFile);
    final path = file?.path;
    if (path == null) return null;
    return prepareRestoreFromPath(path);
  }

  Future<PreparedRestore> prepareRestoreFromPath(String archivePath) async {
    final stagingPath = join(await appPath.tempPath, 'restore_$uniqueId');
    final stagingDir = Directory(stagingPath);
    final stagedArchivePath = join(stagingPath, 'backup.zip');
    try {
      await stagingDir.create(recursive: true);
      if (File(archivePath).absolute.path !=
          File(stagedArchivePath).absolute.path) {
        await File(archivePath).safeCopy(stagedArchivePath);
      }
      final data = await restoreTask(
        backupFilePath: stagedArchivePath,
        restoreDirPath: join(stagingPath, 'content'),
      );
      return PreparedRestore(
        stagingPath: stagingPath,
        data: data,
        summary: RestoreSummary.fromData(data),
      );
    } catch (_) {
      await stagingDir.safeDelete(recursive: true);
      rethrow;
    }
  }

  Future<void> discardPreparedRestore(PreparedRestore prepared) async {
    await Directory(prepared.stagingPath).safeDelete(recursive: true);
  }

  Future<void> applyPreparedRestore(
    PreparedRestore prepared,
    RestoreOption option, {
    RestoreApplyContext context = const RestoreApplyContext(),
  }) async {
    await applyRestore(
      prepared.data,
      option,
      context: context,
      stagingPath: join(prepared.stagingPath, 'content'),
      rollbackPath: join(prepared.stagingPath, 'rollback'),
    );
    await discardPreparedRestore(prepared);
  }

  Future<void> restore(RestoreOption option) async {
    final prepared = await prepareRestoreFromPath(await appPath.backupFilePath);
    await applyPreparedRestore(prepared, option);
  }

  Future<bool> restorePickedFile(RestoreOption option) async {
    final prepared = await preparePickedRestore();
    if (prepared == null) return false;
    await applyPreparedRestore(prepared, option);
    return true;
  }

  @visibleForTesting
  Future<void> applyRestore(
    MigrationData data,
    RestoreOption option, {
    RestoreApplyContext context = const RestoreApplyContext(),
    String? stagingPath,
    String? rollbackPath,
  }) async {
    final restoreStrategy = ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final isOverride = restoreStrategy == RestoreStrategy.override;
    final profilesOnly = option == RestoreOption.onlyProfiles;
    final configMap = data.configMap;
    final config = profilesOnly || configMap == null
        ? null
        : Config.realFromJson(configMap);
    final copies = stagingPath == null
        ? const <({String from, String to})>[]
        : await _restoreCopies(data, stagingPath, profilesOnly: profilesOnly);
    final rollback = await _RestoreFileRollback.prepare(
      copies,
      rollbackPath: rollbackPath,
    );
    final previousConfig = config == null ? null : ref.read(configProvider);
    var committed = false;
    try {
      await rollback.apply();
      await database.transaction(() async {
        if (profilesOnly) {
          await database.restoreProfiles(data.profiles, isOverride: isOverride);
        } else {
          await database.restore(
            data.profiles,
            data.scripts,
            data.rules,
            data.links,
            data.proxyGroups,
            isOverride: isOverride,
          );
        }
      });
      committed = true;
      if (config != null) {
        try {
          _publishConfig(config, context);
        } catch (error, stackTrace) {
          if (previousConfig != null) {
            try {
              _publishConfig(previousConfig, const RestoreApplyContext());
            } catch (rollbackError) {
              commonPrint.log(
                'Settings rollback failed: ${compactError(rollbackError)}',
                logLevel: LogLevel.warning,
              );
            }
          }
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
      await rollback.discard();
      await _pruneReplacedWallpaper(previousConfig, config, profilesOnly);
    } catch (error, stackTrace) {
      if (committed) {
        try {
          await rollback.discard();
        } catch (rollbackError) {
          commonPrint.log(
            'Restore cleanup failed: ${compactError(rollbackError)}',
            logLevel: LogLevel.warning,
          );
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
      try {
        await rollback.restore();
      } catch (rollbackError) {
        commonPrint.log(
          'Restore rollback failed: ${compactError(rollbackError)}',
          logLevel: LogLevel.warning,
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<List<({String from, String to})>> _restoreCopies(
    MigrationData data,
    String stagingPath, {
    required bool profilesOnly,
  }) async {
    final homePath = await appPath.homeDirPath;
    final copies = <({String from, String to})>[
      for (final profile in data.profiles)
        (
          from: join(stagingPath, 'profiles', '${profile.id}.yaml'),
          to: join(homePath, 'profiles', '${profile.id}.yaml'),
        ),
      if (!profilesOnly)
        for (final script in data.scripts)
          (
            from: join(stagingPath, 'scripts', '${script.id}.js'),
            to: join(homePath, 'scripts', '${script.id}.js'),
          ),
    ];
    for (final copy in copies) {
      if (!await File(copy.from).exists()) {
        throw FileSystemException('Backup content is missing', copy.from);
      }
    }
    if (!profilesOnly) {
      final fileName = restoreWallpaperFileName(data.configMap);
      if (fileName != null) {
        final staged = File(join(stagingPath, 'wallpapers', fileName));
        if (!await staged.exists()) return copies;
        try {
          await WallpaperStore.readStoredImage(staged);
          copies.add((
            from: staged.path,
            to: join(homePath, 'wallpapers', fileName),
          ));
        } catch (error) {
          commonPrint.log(
            'Invalid wallpaper in backup, skipping: ${compactError(error)}',
            logLevel: LogLevel.warning,
          );
        }
      }
    }
    return copies;
  }

  Future<void> _pruneReplacedWallpaper(
    Config? previous,
    Config? next,
    bool profilesOnly,
  ) async {
    if (profilesOnly) return;
    final oldName = previous?.themeProps.wallpaper.fileName;
    final newName = next?.themeProps.wallpaper.fileName;
    if (oldName == null || oldName == newName) return;
    if (!isWallpaperFileName(oldName)) return;
    try {
      final file = File(join(await appPath.wallpapersDirPath, oldName));
      if (await FileSystemEntity.type(file.path, followLinks: false) ==
          FileSystemEntityType.file) {
        await file.delete();
      }
    } catch (_) {}
  }

  void _publishConfig(Config config, RestoreApplyContext context) {
    final appSettings =
        context.mergeAppSettings?.call(config.appSettingProps) ??
        config.appSettingProps;
    ref.read(davSettingProvider.notifier).update((_) => config.davProps);
    ref.read(patchClashConfigProvider.notifier).value = config.patchClashConfig;
    ref.read(appSettingProvider.notifier).value = appSettings;
    ref.read(currentProfileIdProvider.notifier).value = config.currentProfileId;
    ref.read(themeSettingProvider.notifier).value = config.themeProps;
    ref.read(windowSettingProvider.notifier).value = config.windowProps;
    ref.read(vpnSettingProvider.notifier).value = config.vpnProps;
    ref.read(proxiesStyleSettingProvider.notifier).value =
        config.proxiesStyleProps;
    ref.read(overrideDnsProvider.notifier).value = config.overrideDns;
    ref.read(networkSettingProvider.notifier).value = config.networkProps;
    ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
    ref.read(smartRoutingSettingProvider.notifier).value =
        config.smartRoutingProps;
    ref.read(desyncSettingProvider.notifier).value = config.desyncProps;
  }
}
