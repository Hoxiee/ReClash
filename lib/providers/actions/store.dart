part of '../action.dart';

@Riverpod(keepAlive: true)
class StoreAction extends _$StoreAction {
  bool _resetting = false;

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  Future<void> shakingStore() async {
    // The lists leave out rows they cannot read, whose files must survive, and
    // the tables may not hold an optimistic write yet.
    final profileIds = {
      ...ref.read(profilesProvider).map((item) => item.id),
      ...await database.profilesDao.ids().get(),
    };
    final scripts = await ref.read(scriptsProvider.future);
    final scriptIds = {
      ...scripts.map((item) => item.id),
      ...await database.scriptsDao.ids().get(),
    };
    final providerFileNames = await database.clashProvidersDao
        .fileNames()
        .get();
    final pathsToDelete = await shakingProfileTask((
      profileIds: profileIds,
      scriptIds: scriptIds,
      providerFileNames: providerFileNames,
    ));
    await Future.wait(pathsToDelete.map(safeDeletePath));
  }

  void savePreferencesDebounce() {
    if (_resetting) return;
    debouncer.call(FunctionTag.savePreferences, () async {
      await preferences.saveConfig(ref.read(configProvider));
    });
  }

  Future<void> resetAllData() async {
    if (_resetting) return;
    _resetting = true;
    debouncer.cancel(FunctionTag.savePreferences);
    debouncer.cancel(FunctionTag.autoLaunch);
    try {
      final dashboard = ref.read(webDashboardActionProvider.notifier);
      await dashboard.endAccess();
      await dashboard.cancelAndWait();
      await ref.read(systemActionProvider.notifier).resetAllDataAndExit();
    } catch (_) {
      _resetting = false;
      rethrow;
    }
  }

  Future handleClear() async {
    final dashboard = ref.read(webDashboardActionProvider.notifier);
    await dashboard.endAccess();
    await dashboard.cancelAndWait();
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
    await clearAppData();
    unawaited(ref.read(systemActionProvider.notifier).handleExit(false));
  }
}
