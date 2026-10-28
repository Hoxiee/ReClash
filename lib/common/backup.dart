import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/migration.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

enum BackupFailure { invalid, newerVersion }

final class BackupException implements Exception {
  final BackupFailure failure;

  const BackupException(this.failure);

  @override
  String toString() => 'BackupException(${failure.name})';
}

/// Archive entries mirror the data directory, so an entry name is also the
/// file's path relative to the home directory.
abstract final class BackupEntries {
  static String profile(Object id) => '$profilesDirectoryName/$id.yaml';

  static String script(Object id) => 'scripts/$id.js';

  static String wallpaper(String fileName) {
    if (!isWallpaperFileName(fileName)) {
      throw const BackupException(BackupFailure.invalid);
    }
    return 'wallpapers/$fileName';
  }

  static String provider(ClashProvider provider) =>
      '$providersDirectoryName/$rulesProviderDirectoryName/${provider.fileName}';

  /// A remote provider's cache belongs to the Core and downloads again.
  static List<String> of({
    required Iterable<int> profileIds,
    required Iterable<int> scriptIds,
    required Iterable<ClashProvider> providers,
    Iterable<String> wallpaperLibrary = const [],
  }) {
    return [
      ...profileIds.map(profile),
      ...scriptIds.map(script),
      ...providers.where((item) => !item.isRemote).map(provider),
      ...sanitizeWallpaperLibrary(wallpaperLibrary).map(wallpaper),
    ];
  }

  static List<String> ofData(
    MigrationData data, {
    bool includeWallpapers = true,
  }) {
    return of(
      profileIds: data.profiles.map((item) => item.id),
      scriptIds: data.scripts.map((item) => item.id),
      providers: data.clashProviders,
      wallpaperLibrary: includeWallpapers
          ? wallpaperLibraryOf(data.configMap)
          : const [],
    );
  }

  static String resolve(String root, String entry) {
    final path = _stagedEntryPath(root, entry);
    if (path == null) {
      throw const BackupException(BackupFailure.invalid);
    }
    return path;
  }
}

typedef BackupArchiveRequest = ({
  String archivePath,
  Map<String, Object?> configMap,
  String databaseSnapshotPath,
  String homeDirPath,
  List<String> entries,
});

typedef RestoreArchiveRequest = ({String archivePath, String stagingDirPath});

Future<void> backupTask(BackupArchiveRequest request) {
  return compute(_backupTask, request);
}

Future<void> _backupTask(BackupArchiveRequest request) {
  return writeBackupArchive(
    archivePath: request.archivePath,
    configMap: request.configMap,
    databaseSnapshotPath: request.databaseSnapshotPath,
    homeDirPath: request.homeDirPath,
    entries: request.entries,
  );
}

Future<MigrationData> restoreTask(RestoreArchiveRequest request) {
  return compute(_restoreTask, request);
}

Future<MigrationData> _restoreTask(RestoreArchiveRequest request) {
  return readBackupArchive(
    archivePath: request.archivePath,
    stagingDirPath: request.stagingDirPath,
  );
}

@visibleForTesting
Future<void> writeBackupArchive({
  required String archivePath,
  required Map<String, Object?> configMap,
  required String databaseSnapshotPath,
  required String homeDirPath,
  required Iterable<String> entries,
}) async {
  final encoder = ZipFileEncoder()..create(archivePath);
  try {
    encoder.addArchiveFile(
      ArchiveFile.string(configJsonName, json.encode(configMap)),
    );
    await encoder.addFile(File(databaseSnapshotPath), backupDatabaseName);
    for (final entry in entries) {
      final file = File(BackupEntries.resolve(homeDirPath, entry));
      if (entry.startsWith('wallpapers/') &&
          await FileSystemEntity.type(file.path, followLinks: false) !=
              FileSystemEntityType.file) {
        throw const BackupException(BackupFailure.invalid);
      }
      if (await file.exists()) {
        await encoder.addFile(file, entry);
      }
    }
  } finally {
    await encoder.close();
  }
}

/// Writes nothing outside [stagingDirPath]; the files the result names are left
/// there at their [BackupEntries] paths.
@visibleForTesting
Future<MigrationData> readBackupArchive({
  required String archivePath,
  required String stagingDirPath,
}) async {
  await _extract(archivePath, stagingDirPath);
  final configFile = File(join(stagingDirPath, configJsonName));
  if (!await configFile.exists()) {
    throw const BackupException(BackupFailure.invalid);
  }
  final configMap = _decodeConfig(await configFile.readAsString());
  final version = configMap['version'] ?? 0;
  if (version is! int) {
    throw const BackupException(BackupFailure.invalid);
  }
  if (version > Migration.currentVersion) {
    throw const BackupException(BackupFailure.newerVersion);
  }
  if (version == 0) {
    return migrateLegacyConfig(
      configMap: configMap,
      sourcePath: stagingDirPath,
      targetPath: stagingDirPath,
    );
  }
  final databaseFile = File(join(stagingDirPath, backupDatabaseName));
  if (!await databaseFile.exists()) {
    return MigrationData(configMap: configMap);
  }
  final schemaVersion = await _readSchemaVersion(databaseFile);
  final database = Database(
    driftDatabase(
      name: basenameWithoutExtension(backupDatabaseName),
      // Left unset, drift asks path_provider for a temp directory, and this
      // isolate has no platform channel to answer it.
      native: DriftNativeOptions(
        databaseDirectory: () async => Directory(stagingDirPath),
        tempDirectoryPath: () async => stagingDirPath,
      ),
    ),
  );
  try {
    if (schemaVersion > database.schemaVersion) {
      throw const BackupException(BackupFailure.newerVersion);
    }
    final results = await Future.wait([
      database.profilesDao.query().get(),
      database.scriptsDao.query().get(),
      (database.select(database.rules)..orderBy([
            (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
          ]))
          .map((item) => item.toRule())
          .get(),
      database
          .select(database.disabledRules)
          .map((item) => item.toDisabledRule())
          .get(),
      (database.select(database.proxyGroups)..orderBy([
            (t) => OrderingTerm(expression: t.order, nulls: NullsOrder.last),
          ]))
          .map((item) => item.toProxyGroup())
          .get(),
      database.clashProvidersDao.query().get(),
      database.customProxiesDao.query().get(),
      database.proxyDialers.readable((row) => row.toProxyDialer()).get(),
    ]);
    return MigrationData(
      configMap: configMap,
      profiles: results[0].cast<Profile>(),
      scripts: results[1].cast<Script>(),
      rules: results[2].cast<Rule>(),
      disabledRules: results[3].cast<DisabledRule>(),
      proxyGroups: results[4].cast<ProxyGroup>(),
      clashProviders: results[5].cast<ClashProvider>(),
      customProxies: results[6].cast<CustomProxy>(),
      proxyDialers: results[7].cast<ProxyDialer>(),
    );
  } finally {
    await database.close();
  }
}

Future<void> _extract(String archivePath, String stagingDirPath) async {
  await Directory(stagingDirPath).create(recursive: true);
  final input = InputFileStream(archivePath);
  try {
    final directory = ZipDirectory();
    try {
      directory.read(input);
    } on Exception {
      throw const BackupException(BackupFailure.invalid);
    }
    var wallpaperEntries = 0;
    for (final header in directory.fileHeaders) {
      final file = header.file;
      if (file == null) {
        throw const BackupException(BackupFailure.invalid);
      }
      if (file.filename.endsWith('/') ||
          file.filename.endsWith('\\') ||
          (header.externalFileAttributes >> 16) & 0xf000 == 0xa000) {
        continue;
      }
      if (file.crc32 != header.crc32) {
        throw const BackupException(BackupFailure.invalid);
      }
      final name = posix.normalize(file.filename.replaceAll('\\', '/'));
      final isWallpaper = name.startsWith('wallpapers/');
      if (isWallpaper &&
          (posix.dirname(name) != 'wallpapers' ||
              !isWallpaperFileName(posix.basename(name)) ||
              file.uncompressedSize > 32 * 1024 * 1024 ||
              wallpaperEntries >= maxWallpaperLibrary)) {
        continue;
      }
      if (isWallpaper) wallpaperEntries++;
      final outPath = _stagedEntryPath(stagingDirPath, file.filename);
      if (outPath == null) {
        continue;
      }
      if (file.uncompressedSize < 0) {
        throw const BackupException(BackupFailure.invalid);
      }
      await Directory(dirname(outPath)).create(recursive: true);
      final output = _VerifiedBackupOutput(outPath, file.uncompressedSize);
      try {
        file.decompress(output);
        if (output.length != file.uncompressedSize ||
            output.crc != file.crc32) {
          throw const BackupException(BackupFailure.invalid);
        }
      } on FormatException {
        throw const BackupException(BackupFailure.invalid);
      } finally {
        await output.close();
      }
    }
  } finally {
    await input.close();
  }
}

class _VerifiedBackupOutput extends OutputFileStream {
  _VerifiedBackupOutput(String path, this.limit)
    : super.withFileHandle(FileHandle(path, mode: FileAccess.write));

  final int limit;
  int crc = 0;

  void _check(int count) {
    if (length + count > limit) {
      throw const BackupException(BackupFailure.invalid);
    }
  }

  @override
  void writeByte(int value) {
    _check(1);
    crc = getCrc32Byte(crc ^ 0xffffffff, value) ^ 0xffffffff;
    super.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final count = length ?? bytes.length;
    _check(count);
    crc = getCrc32(
      count == bytes.length ? bytes : bytes.sublist(0, count),
      crc,
    );
    super.writeBytes(bytes, length: count);
  }
}

/// `posix.normalize` collapses `a/../b`, but a name that starts with `../`
/// normalizes to itself and an absolute one stays absolute, so either would
/// write wherever the archive asks. A backup file is untrusted input.
String? _stagedEntryPath(String stagingDirPath, String name) {
  final normalized = posix.normalize(name.replaceAll('\\', '/'));
  if (normalized.isEmpty ||
      posix.isAbsolute(normalized) ||
      normalized == '..' ||
      normalized.startsWith('../')) {
    return null;
  }
  final outPath = normalize(
    joinAll([stagingDirPath, ...posix.split(normalized)]),
  );
  if (!isWithin(stagingDirPath, outPath)) {
    return null;
  }
  return outPath;
}

Map<String, Object?> _decodeConfig(String source) {
  final Object? decoded;
  try {
    decoded = json.decode(source);
  } on FormatException {
    throw const BackupException(BackupFailure.invalid);
  }
  if (decoded is! Map<String, Object?>) {
    throw const BackupException(BackupFailure.invalid);
  }
  return decoded;
}

/// Opening the database through drift would already run its migrations, so the
/// version is read from the file header: SQLite keeps `user_version` as a
/// big-endian integer at byte 60.
Future<int> _readSchemaVersion(File databaseFile) async {
  final handle = await databaseFile.open();
  try {
    final header = await handle.read(64);
    if (header.length < 64) {
      throw const BackupException(BackupFailure.invalid);
    }
    return ByteData.sublistView(header).getInt32(60);
  } finally {
    await handle.close();
  }
}
