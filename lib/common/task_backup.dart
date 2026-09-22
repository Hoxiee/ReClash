part of 'task.dart';

Future<void> createDatabaseSnapshot(
  Database database,
  String snapshotPath,
) async {
  await File(snapshotPath).safeDelete();
  await database.customStatement('VACUUM INTO ?', [snapshotPath]);
}

Future<String> backupTask(
  Map<String, dynamic> configMap,
  Iterable<String> fileNames, {
  String? databasePath,
}) async {
  return compute<
    ({
      Map<String, dynamic> configMap,
      Iterable<String> fileNames,
      String? databasePath,
      RootIsolateToken token,
    }),
    String
  >(_backupTask, (
    configMap: configMap,
    fileNames: fileNames,
    databasePath: databasePath,
    token: RootIsolateToken.instance!,
  ));
}

Future<String> _backupTask<T>(
  ({
    Map<String, dynamic> configMap,
    Iterable<String> fileNames,
    String? databasePath,
    RootIsolateToken token,
  })
  args,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(args.token);
  final tempPath = await appPath.tempPath;
  final prefix = 'backup$uniqueId';
  return writeBackupArchive(
    configMap: args.configMap,
    fileNames: args.fileNames,
    databasePath: args.databasePath ?? await appPath.databasePath,
    profilesDirPath: await appPath.profilesPath,
    scriptsDirPath: await appPath.scriptsDirPath,
    wallpapersDirPath: await appPath.wallpapersDirPath,
    zipFilePath: join(tempPath, '$prefix.zip'),
    tempDatabasePath: join(tempPath, '$prefix.db'),
    tempConfigPath: join(tempPath, '$prefix.json'),
  );
}

// Duplicated from the store limit to keep the backup isolate free of dart:ui.
const maxBackupWallpaperBytes = 32 * 1024 * 1024;

@visibleForTesting
Future<String> writeBackupArchive({
  required Map<String, dynamic> configMap,
  required Iterable<String> fileNames,
  required String databasePath,
  required String profilesDirPath,
  required String scriptsDirPath,
  String? wallpapersDirPath,
  required String zipFilePath,
  required String tempDatabasePath,
  required String tempConfigPath,
}) async {
  final configStr = json.encode(configMap);
  final profilesDir = Directory(profilesDirPath);
  final scriptsDir = Directory(scriptsDirPath);
  final tempDBFile = File(tempDatabasePath);
  final tempConfigFile = File(tempConfigPath);
  final dbFile = File(databasePath);
  if (await dbFile.exists()) {
    await dbFile.copy(tempDBFile.path);
  }
  final encoder = ZipFileEncoder();
  encoder.create(zipFilePath);
  await tempConfigFile.writeAsString(configStr);
  await encoder.addFile(tempDBFile, backupDatabaseName);
  await encoder.addFile(tempConfigFile, configJsonName);
  ZipFileOperation keepListed(FileSystemEntity entity, double _) {
    if (!fileNames.contains(basename(entity.path))) {
      return ZipFileOperation.skip;
    }
    return ZipFileOperation.include;
  }

  if (await profilesDir.exists()) {
    await encoder.addDirectory(profilesDir, filter: keepListed);
  }
  if (await scriptsDir.exists()) {
    await encoder.addDirectory(scriptsDir, filter: keepListed);
  }
  final dirPath =
      wallpapersDirPath ?? join(dirname(profilesDirPath), 'wallpapers');
  for (final wallpaperFileName in wallpaperLibraryOf(configMap)) {
    final file = File(join(dirPath, wallpaperFileName));
    try {
      if (await file.exists() &&
          await file.length() <= maxBackupWallpaperBytes) {
        await encoder.addFile(file, 'wallpapers/$wallpaperFileName');
      }
    } catch (_) {}
  }
  await encoder.close();
  await tempConfigFile.safeDelete();
  await tempDBFile.safeDelete();
  return zipFilePath;
}

Future<MigrationData> restoreTask({
  required String backupFilePath,
  required String restoreDirPath,
}) async {
  return compute<
    ({RootIsolateToken token, String backupFilePath, String restoreDirPath}),
    MigrationData
  >(_restoreTask, (
    token: RootIsolateToken.instance!,
    backupFilePath: backupFilePath,
    restoreDirPath: restoreDirPath,
  ));
}

Future<MigrationData> _restoreTask(
  ({RootIsolateToken token, String backupFilePath, String restoreDirPath}) args,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(args.token);
  return readBackupArchive(
    backupFilePath: args.backupFilePath,
    restoreDirPath: args.restoreDirPath,
  );
}

/// `posix.normalize` was doing this on its own and it does not: it collapses
/// `a/../b`, but a name that starts with `../` normalizes to itself and an
/// absolute one stays absolute, so either writes wherever the archive asks. A
/// backup file is untrusted input — it is whatever the user picked off disk.
String? _restoreEntryPath(String restoreDirPath, String name) {
  final normalized = posix.normalize(name.replaceAll('\\', '/'));
  if (normalized.isEmpty ||
      posix.isAbsolute(normalized) ||
      normalized == '..' ||
      normalized.startsWith('../')) {
    return null;
  }
  final outPath = normalize(join(restoreDirPath, normalized));
  if (!isWithin(restoreDirPath, outPath)) {
    return null;
  }
  return outPath;
}

Map<String, Object?> _upgradeUpstreamBackupConfig(
  Map<String, Object?> configMap,
) {
  final map = Map<String, Object?>.from(configMap);
  final patch = map['patchClashConfig'];
  if (patch is Map && patch['global-ua'] == null) {
    map['patchClashConfig'] = Map<String, Object?>.from(patch)
      ..['global-ua'] = flClashXCompatUa;
  }
  final rawSettings = map['appSettingProps'];
  final settings = Map<String, Object?>.from(
    rawSettings is Map ? rawSettings : const {},
  );
  settings
    ..['setupCompleted'] = true
    ..['autoCheckUpdate'] = defaultAppSettingProps.autoCheckUpdate
    ..['sendDeviceIdentity'] = defaultAppSettingProps.sendDeviceIdentity;
  final legacyStopAction = settings['showNotificationStopAction'];
  final rawNotification = settings['notificationSettings'];
  final notification = Map<String, Object?>.from(
    rawNotification is Map ? rawNotification : const {},
  );
  notification
    ..['showStopAction'] = legacyStopAction is bool
        ? legacyStopAction
        : defaultNotificationSettings.showStopAction
    ..['showPauseAction'] = defaultNotificationSettings.showPauseAction
    ..['hideSensitiveOnLockScreen'] =
        defaultNotificationSettings.hideSensitiveOnLockScreen
    ..['subscriptionReminders'] =
        defaultNotificationSettings.subscriptionReminders;
  settings
    ..remove('showNotificationStopAction')
    ..['notificationSettings'] = notification;
  map['appSettingProps'] = settings;
  return map;
}

Map<String, Object?> _normalizeBackupConfig(Map<String, Object?> configMap) {
  final normalized =
      jsonDecode(jsonEncode(Config.realFromJson(configMap)))
          as Map<String, Object?>;
  normalized['version'] = currentDataVersion;
  return normalized;
}

@visibleForTesting
Future<MigrationData> readBackupArchive({
  required String backupFilePath,
  required String restoreDirPath,
}) async {
  final dir = Directory(restoreDirPath);
  await dir.safeDelete(recursive: true);
  await dir.create(recursive: true);
  final zipDecoder = ZipDecoder();
  final input = InputFileStream(backupFilePath);
  try {
    final archive = zipDecoder.decodeStream(input);
    for (final file in archive.files) {
      final outPath = _restoreEntryPath(restoreDirPath, file.name);
      if (outPath == null) {
        continue;
      }
      final outputStream = OutputFileStream(outPath);
      try {
        file.writeContent(outputStream);
      } finally {
        await outputStream.close();
      }
    }
  } finally {
    await input.close();
  }
  final restoreConfigFile = File(join(restoreDirPath, configJsonName));
  if (!await restoreConfigFile.exists()) {
    throw MessageException(currentAppLocalizations.invalidBackupFile);
  }
  final decoded = json.decode(await restoreConfigFile.readAsString());
  if (decoded is! Map<String, Object?>) {
    throw MessageException(currentAppLocalizations.invalidBackupFile);
  }
  final rawVersion = decoded['version'] ?? 0;
  if (rawVersion is! int || rawVersion < 0 || rawVersion > currentDataVersion) {
    throw MessageException(currentAppLocalizations.invalidBackupFile);
  }
  MigrationData migrationData;
  if (rawVersion == 0) {
    final clashConfigFile = File(join(restoreDirPath, 'clashConfig.json'));
    if (await clashConfigFile.exists()) {
      final clashConfig = json.decode(await clashConfigFile.readAsString());
      if (clashConfig is! Map<String, Object?>) {
        throw MessageException(currentAppLocalizations.invalidBackupFile);
      }
      decoded['patchClashConfig'] = clashConfig;
    }
    migrationData = await migrateLegacyConfig(
      configMap: decoded,
      sourcePath: restoreDirPath,
      targetPath: restoreDirPath,
    );
  } else {
    final currentMap = Map<String, Object?>.from(decoded);
    migrationData = MigrationData(
      configMap: rawVersion == 1
          ? _upgradeUpstreamBackupConfig(currentMap)
          : currentMap,
    );
  }
  migrationData = migrationData.copyWith(
    configMap: _normalizeBackupConfig(migrationData.configMap ?? const {}),
  );
  if (rawVersion == 0) return migrationData;
  final backupDatabaseFile = File(join(restoreDirPath, backupDatabaseName));
  if (!await backupDatabaseFile.exists()) {
    return migrationData;
  }
  final database = Database(
    driftDatabase(
      name: 'database',
      native: DriftNativeOptions(
        databaseDirectory: () async => Directory(restoreDirPath),
      ),
    ),
  );
  try {
    final results = await Future.wait([
      database.profilesDao.query().get(),
      database.scriptsDao.query().get(),
      database.rules.all().map((item) => item.toRule()).get(),
      database.profileRuleLinks.all().map((item) => item.toLink()).get(),
      database.proxyGroups.all().map((item) => item.toProxyGroup()).get(),
    ]);
    final profiles = results[0].cast<Profile>();
    final scripts = results[1].cast<Script>();
    return migrationData.copyWith(
      profiles: profiles,
      scripts: scripts,
      rules: results[2].cast<Rule>(),
      links: results[3].cast<ProfileRuleLink>(),
      proxyGroups: results[4].cast<ProxyGroup>(),
    );
  } finally {
    await database.close();
  }
}
