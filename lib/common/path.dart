import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppPath {
  static AppPath? _instance;
  Completer<Directory> dataDir = Completer();
  late final Future<Directory?> _downloadDir = downloadDirectory();
  Completer<Directory> tempDir = Completer();
  Completer<Directory> cacheDir = Completer();
  late String appDirPath;
  String? _coreOverridePath;
  final Completer<void> _corePathResolved = Completer<void>();

  @visibleForTesting
  static Future<Directory> Function() supportDirectory =
      getApplicationSupportDirectory;

  @visibleForTesting
  static Future<Directory> Function() temporaryDirectory =
      getTemporaryDirectory;

  @visibleForTesting
  static Future<Directory> Function() cacheDirectory =
      getApplicationCacheDirectory;

  @visibleForTesting
  static Future<Directory?> Function() downloadDirectory =
      getDownloadsDirectory;

  AppPath._internal() {
    appDirPath = join(dirname(Platform.resolvedExecutable));
    if (!Platform.isLinux) {
      _corePathResolved.complete();
    }
    supportDirectory().then((value) {
      dataDir.complete(value);
    });
    temporaryDirectory().then((value) {
      tempDir.complete(value);
    });
    cacheDirectory().then((value) {
      cacheDir.complete(value);
    });
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  String get executableExtension {
    return system.isWindows ? '.exe' : '';
  }

  @visibleForTesting
  static String Function() executableDirectory = () =>
      dirname(Platform.resolvedExecutable);

  @visibleForTesting
  void debugResetCoreOverride() {
    _coreOverridePath = null;
  }

  String get executableDirPath {
    return executableDirectory();
  }

  String get corePath {
    return _coreOverridePath ??
        join(executableDirPath, 'ReClashCore$executableExtension');
  }

  Future<void> get corePathReady => _corePathResolved.future;

  /// A read-only install (AppImage squashfs, root-owned /opt) cannot hold a
  /// setuid core, so [corePath] resolves to a writable app-support copy; a
  /// size/mtime match keeps the existing copy and its setuid bit.
  Future<void> ensureWritableCore() async {
    if (!Platform.isLinux) {
      return _resolveCorePath();
    }
    final bundled = File(
      join(executableDirPath, 'ReClashCore$executableExtension'),
    );
    if (!await bundled.exists()) {
      return _resolveCorePath();
    }
    if (_isDirectoryWritable(executableDirPath)) {
      return _resolveCorePath();
    }
    try {
      final directory = await dataDir.future;
      final target = File(join(directory.path, 'ReClashCore'));
      final needsCopy =
          !await target.exists() ||
          await target.length() != await bundled.length() ||
          (await target.lastModified()).isBefore(await bundled.lastModified());
      if (needsCopy) {
        final staged = File('${target.path}.staged');
        await bundled.copy(staged.path);
        await Process.run('chmod', ['755', staged.path]);
        await staged.rename(target.path);
      }
      _coreOverridePath = target.path;
    } catch (error) {
      commonPrint.log('writable core copy failed: $error');
    }
    _resolveCorePath();
  }

  void _resolveCorePath() {
    if (!_corePathResolved.isCompleted) {
      _corePathResolved.complete();
    }
  }

  bool _isDirectoryWritable(String path) {
    try {
      final probe = File(join(path, '.reclash-write-probe'));
      probe.writeAsStringSync('', flush: true);
      probe.deleteSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  String get helperPath {
    return join(executableDirPath, '$appHelperService$executableExtension');
  }

  Future<String> get downloadDirPath async {
    final directory = await _downloadDir;
    return directory?.path ?? await homeDirPath;
  }

  Future<String> get homeDirPath async {
    final directory = await dataDir.future;
    return directory.path;
  }

  Future<String> get databasePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'database.sqlite');
  }

  Future<String> get backupFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'backup.zip');
  }

  Future<String> get restoreDirPath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'restore');
  }

  Future<String> get tempFilePath async {
    final mTempDir = await tempDir.future;
    return join(mTempDir.path, 'temp$uniqueId');
  }

  Future<String> get lockFilePath async {
    final homeDirPath = await appPath.homeDirPath;
    return join(homeDirPath, 'ReClash.lock');
  }

  Future<String> get configFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'config.yaml');
  }

  Future<String> get sharedPreferencesPath async {
    final directory = await dataDir.future;
    return join(directory.path, 'shared_preferences.json');
  }

  Future<String> get profilesPath async {
    final directory = await dataDir.future;
    return join(directory.path, profilesDirectoryName);
  }

  Future<String> getProfilePath(String fileName) async {
    return join(await profilesPath, '$fileName.yaml');
  }

  Future<String> get scriptsDirPath async {
    final path = await homeDirPath;
    return join(path, 'scripts');
  }

  Future<String> getScriptPath(String fileName) async {
    final path = await scriptsDirPath;
    return join(path, '$fileName.js');
  }

  Future<String> getProvidersRootPath() async {
    final directory = await profilesPath;
    return join(directory, providersDirectoryName);
  }

  Future<String> getProviderDirPath(int profileId, String type) async {
    final directory = await getProvidersRootPath();
    return join(directory, profileId.toString(), type);
  }

  Future<void> ensureProviderDirs(int profileId) async {
    for (final type in const [
      proxiesProviderDirectoryName,
      rulesProviderDirectoryName,
    ]) {
      final directory = Directory(await getProviderDirPath(profileId, type));
      if (await directory.exists()) {
        continue;
      }
      await directory.create(recursive: true);
    }
  }

  Future<String> get tempPath async {
    final directory = await tempDir.future;
    return directory.path;
  }
}

final appPath = AppPath();

String getBackupFileName() {
  return '${appName}_backup_${DateTime.now().show}.zip';
}

String get logFileName {
  return '${appName}_${DateTime.now().show}.log';
}
