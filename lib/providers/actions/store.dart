part of '../action.dart';

@Riverpod(keepAlive: true)
class StoreAction extends _$StoreAction {
  final _preferencesScheduler = SerialTaskScheduler();

  CoreController get _core => ref.read(coreHandlerProvider);

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

  Future handleClear() async {
    debouncer.cancel(FunctionTag.savePreferences);
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
    await File(await appPath.databasePath).safeDelete(recursive: true);
    await Directory(await appPath.profilesPath).safeDelete(recursive: true);
    await Directory(
      await appPath.wallpapersDirPath,
    ).safeDelete(recursive: true);
    unawaited(ref.read(systemActionProvider.notifier).handleExit(false));
  }
}
