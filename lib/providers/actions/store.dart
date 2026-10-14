part of '../action.dart';

@Riverpod(keepAlive: true)
class StoreAction extends _$StoreAction {
  final _preferencesScheduler = SerialTaskScheduler();

  CoreHandlerInterface get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  Future<void> shakingStore() async {
    final profileIds = ref.read(profilesProvider).map((item) => item.id);
    final scripts = await ref.read(scriptsProvider.future);
    final scriptIds = scripts.map((item) => item.id);
    final pathsToDelete = await shakingProfileTask((
      profileIds: profileIds,
      scriptIds: scriptIds,
    ));
    await Future.wait(pathsToDelete.map(safeDeletePath));
  }

  Future<bool> savePreferences() {
    debouncer.cancel(FunctionTag.savePreferences);
    final config = ref.read(configProvider);
    return _preferencesScheduler.run(() async {
      try {
        return await preferences.saveConfig(config);
      } catch (error, stackTrace) {
        commonPrint.log(
          'Failed to save preferences: ${compactError(error)}, $stackTrace',
          logLevel: LogLevel.warning,
        );
        return false;
      }
    });
  }

  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, () async {
      if (!await savePreferences()) {
        commonPrint.log(
          'Failed to save preferences',
          logLevel: LogLevel.warning,
        );
      }
    });
  }

  Future<void> _stopTunnelBeforeClear() async {
    if (!ref.read(isStartProvider)) {
      return;
    }
    try {
      await ref.read(setupActionProvider.notifier).setRunning(false);
    } catch (error) {
      commonPrint.log(
        'Tunnel stop before clear failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future handleClear() async {
    debouncer.cancel(FunctionTag.savePreferences);
    await _stopTunnelBeforeClear();
    final profileIds = ref
        .read(profilesProvider)
        .map((item) => item.id)
        .toSet();
    final providersDir = Directory(await appPath.getProvidersRootPath());
    if (await providersDir.exists()) {
      await for (final entity in providersDir.list(followLinks: false)) {
        if (entity is! Directory) continue;
        final profileId = int.tryParse(basename(entity.path));
        if (profileId != null && profileId > 0) {
          profileIds.add(profileId);
        }
      }
    }
    final clearResults = await Future.wait(
      profileIds.map((profileId) async {
        try {
          return await _core.clearEffect(profileId);
        } catch (error) {
          return 'clearEffect($profileId) failed: $error';
        }
      }),
    );
    for (final error in clearResults.where((error) => error.isNotEmpty)) {
      commonPrint.log(error, logLevel: LogLevel.warning);
    }
    await preferences.clearPreferences();
    commonPrint.log('clear preferences');
    await database.close();
    final databasePath = await appPath.databasePath;
    await File(databasePath).safeDelete(recursive: true);
    for (final suffix in const ['-wal', '-shm', '-journal']) {
      await File('$databasePath$suffix').safeDelete();
    }
    final homeDirPath = await appPath.homeDirPath;
    await Directory(await appPath.profilesPath).safeDelete(recursive: true);
    await Directory(await appPath.scriptsDirPath).safeDelete(recursive: true);
    await Directory(
      await appPath.wallpapersDirPath,
    ).safeDelete(recursive: true);
    await File(await appPath.configFilePath).safeDelete();
    await Directory(await appPath.restoreDirPath).safeDelete(recursive: true);
    await safeDeletePath(webDashboardDirIn(homeDirPath));
    for (final geoFileName in const [MMDB, GEOIP, GEOSITE, ASN]) {
      await File(join(homeDirPath, geoFileName)).safeDelete();
    }
    await _deleteStaleUpdateApks(homeDirPath);
    // The file sink holds the logs directory open; close it before deleting.
    await fileLogger.dispose();
    await Directory(
      join(homeDirPath, 'logs'),
    ).safeDelete(recursive: true);
    // backup.zip, the lock file and the core binary copy stay: the backup is
    // the only way back, the rest belongs to the running install itself.
    unawaited(ref.read(systemActionProvider.notifier).handleExit(false));
  }

  Future<void> _deleteStaleUpdateApks(String homeDirPath) async {
    try {
      await for (final entity in Directory(homeDirPath).list()) {
        if (entity is! File) continue;
        if (isStaleUpdateApk(basename(entity.path), keepFileName: '')) {
          await entity.safeDelete();
        }
      }
    } catch (_) {}
  }
}
