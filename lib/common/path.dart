import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const portableDirectoryName = 'config';

/// Portable install: a `config/` dir next to the executable holds all data,
/// so nothing touches the OS user profile. Desktop only, never Android/iOS.
bool isPortableModeFor(String executableDir) {
  if (!system.isDesktop) {
    return false;
  }
  return Directory(join(executableDir, portableDirectoryName)).existsSync();
}

bool get isPortableMode =>
    isPortableModeFor(dirname(Platform.resolvedExecutable));

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
    unawaited(_initDataDir());
    unawaited(_initTempDir());
    unawaited(_initCacheDir());
    // A resolver failure (no path_provider binding, e.g. under a bare unit
    // test) reaches whoever awaits the completer; these keep the error from
    // also surfacing as an unhandled zone error when nobody has awaited yet.
    dataDir.future.ignore();
    tempDir.future.ignore();
    cacheDir.future.ignore();
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  bool get isPortable => isPortableModeFor(executableDirPath);

  Directory _portableBase() {
    final directory = Directory(join(executableDirPath, portableDirectoryName));
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }

  Future<void> _initDataDir() async {
    try {
      if (isPortable) {
        dataDir.complete(_portableBase());
        return;
      }
      dataDir.complete(await supportDirectory());
    } catch (error, stackTrace) {
      if (!dataDir.isCompleted) {
        dataDir.completeError(error, stackTrace);
      }
    }
  }

  Future<void> _initTempDir() async {
    try {
      if (isPortable) {
        final directory = Directory(join(_portableBase().path, 'tmp'));
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        tempDir.complete(directory);
        return;
      }
      tempDir.complete(await temporaryDirectory());
    } catch (error, stackTrace) {
      if (!tempDir.isCompleted) {
        tempDir.completeError(error, stackTrace);
      }
    }
  }

  Future<void> _initCacheDir() async {
    try {
      if (isPortable) {
        final directory = Directory(join(_portableBase().path, '.cache'));
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        cacheDir.complete(directory);
        return;
      }
      cacheDir.complete(await cacheDirectory());
    } catch (error, stackTrace) {
      if (!cacheDir.isCompleted) {
        cacheDir.completeError(error, stackTrace);
      }
    }
  }

  @visibleForTesting
  Future<void> reinitDirsForTesting() async {
    await Future.wait([_initDataDir(), _initTempDir(), _initCacheDir()]);
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

  /// A read-only install (AppImage squashfs, root-owned /opt) resolves
  /// [corePath] to a fresh unprivileged app-support copy.
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
    try {
      final bundledMode = await _unixMode(bundled.path);
      if (bundledMode & 0xC00 != 0) {
        final directory = await dataDir.future;
        await _installUnprivilegedCore(bundled, directory);
        return _resolveCorePath();
      }
    } catch (error) {
      commonPrint.log('core privilege check failed: $error');
      return _resolveCorePath();
    }
    if (_isDirectoryWritable(executableDirPath)) {
      return _resolveCorePath();
    }
    try {
      final directory = await dataDir.future;
      await _installUnprivilegedCore(bundled, directory);
    } catch (error) {
      commonPrint.log('writable core copy failed: $error');
    }
    _resolveCorePath();
  }

  Future<void> _installUnprivilegedCore(
    File bundled,
    Directory directory,
  ) async {
    final target = File(join(directory.path, 'ReClashCore'));
    final staged = File('${target.path}.staged');
    if (await staged.exists()) {
      await staged.delete();
    }
    await bundled.copy(staged.path);
    final chmodResult = await Process.run('chmod', ['755', staged.path]);
    if (chmodResult.exitCode != 0) {
      await staged.delete();
      throw FileSystemException(
        'Failed to make Core unprivileged',
        staged.path,
      );
    }
    await staged.rename(target.path);
    _coreOverridePath = target.path;
  }

  Future<int> _unixMode(String path) async {
    final result = await Process.run('stat', ['-c', '%f', path]);
    if (result.exitCode != 0) {
      throw FileSystemException('Failed to inspect Core mode', path);
    }
    return int.parse(result.stdout.toString().trim(), radix: 16);
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

  Future<String> get wallpapersDirPath async {
    return join(await homeDirPath, 'wallpapers');
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
