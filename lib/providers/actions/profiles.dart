part of '../action.dart';

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  Future<void> deleteProfile(int id) async {
    await ref.read(profilesProvider.notifier).del(id);
    await clearEffect(id);
    final currentProfileId = ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        ref.read(currentProfileIdProvider.notifier).value = null;
        unawaited(ref.read(setupActionProvider.notifier).setRunning(false));
      }
    }
  }

  Future<String> validateConfigWithData(String data) async {
    return _core.validateConfigWithData(data);
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(compactError(e), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (ref.read(currentProfileIdProvider) != null) return;
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> updateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) continue;
      await updateProfile(profile);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    final operation = showLoading
        ? ref.read(updatingKeysProvider.notifier).start(profile.updatingKey)
        : null;
    try {
      ref.read(profilesProvider.notifier).put(profile);
      final newProfile = await profile.update(
        validate: (path) => _core.validateConfig(path),
        requestHeaders: await deviceIdentity.subscriptionHeaders(
          includeDeviceIdentity: true,
        ),
      );
      ref.read(profilesProvider.notifier).put(newProfile);
      unawaited(handlePanelVerdicts(newProfile.panelMeta));
      if (profile.id == ref.read(currentProfileIdProvider)) {
        applyPanelWidgetsFromMeta(
          newProfile.panelMeta,
          previousMeta: profile.panelMeta,
        );
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
    } finally {
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(profile.updatingKey, operation);
      }
    }
  }

  Future<void> handlePanelVerdicts(PanelMeta? panelMeta) async {
    if (panelMeta == null) return;
    if (panelMeta.hwidMaxDevicesReached) {
      final confirmed = await dialogs.showMessage(
        title: currentAppLocalizations.deviceLimitReached,
        message: TextSpan(
          text: panelMeta.announce.takeFirstValid(
            [currentAppLocalizations.deviceLimitReachedTip],
          ),
        ),
        confirmText: panelMeta.supportUrl != null
            ? currentAppLocalizations.support
            : null,
      );
      if (confirmed == true && panelMeta.supportUrl != null) {
        await dialogs.openUrl(panelMeta.supportUrl!);
      }
    } else if (panelMeta.hwidNotSupported) {
      await dialogs.showMessage(
        title: currentAppLocalizations.clientNotSupported,
        message: TextSpan(text: currentAppLocalizations.clientNotSupportedTip),
      );
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    final bytes = await platformFile.readBytes();
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          label: platformFile.name,
        ).saveFile(bytes, validate: (path) => _core.validateConfig(path));
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
    }
  }

  Future<void> addProfileFormURL(String url) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).value = PageLabel.profiles;
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          url: url,
        ).update(
          validate: (path) => _core.validateConfig(path),
          requestHeaders: await deviceIdentity.subscriptionHeaders(
            includeDeviceIdentity: false,
          ),
        );
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
      applyPanelWidgetsFromMeta(profile.panelMeta);
      applyPanelSettingsDefaults(profile.panelMeta);
      unawaited(handlePanelVerdicts(profile.panelMeta));
    }
  }

  // Add-time only: afterwards the settings are the user's to change.
  void applyPanelSettingsDefaults(PanelMeta? meta) {
    final tokens = meta?.settings;
    if (tokens == null || tokens.isEmpty) return;
    final set = tokens.toSet();
    ref.read(appSettingProvider.notifier).update(
          (state) => state.copyWith(
            minimizeOnExit: set.contains('minimize'),
            autoRun: set.contains('autorun'),
            silentLaunch: set.contains('shadowstart'),
            autoLaunch: set.contains('autostart'),
            autoCheckUpdate: set.contains('autoupdate'),
            openLogs: set.contains('openlogs'),
            closeConnections: set.contains('closeconnections'),
          ),
        );
  }

  void applyPanelWidgetsFromMeta(PanelMeta? meta, {PanelMeta? previousMeta}) {
    final names = meta?.widgets;
    if (names == null || names.isEmpty) return;
    final panelWidgets = parsePanelWidgets(names);
    if (panelWidgets.isEmpty) return;
    final previousNames = previousMeta?.widgets;
    final previousPanelWidgets = previousNames == null || previousNames.isEmpty
        ? const <DashboardWidget>[]
        : parsePanelWidgets(previousNames);
    final current = ref.read(appSettingProvider).dashboardWidgets;
    final next = applyPanelWidgets(
      panelWidgets: panelWidgets,
      mode: meta!.widgetsApplyMode,
      current: current,
      previousPanelWidgets: previousPanelWidgets,
    );
    if (sameWidgets(next, current)) return;
    ref.read(appSettingProvider.notifier).update(
          (state) => state.copyWith(dashboardWidgets: next),
        );
  }

  void applyPanelWidgetsOnProfileSwitch(int? previousProfileId) {
    final previousMeta = ref
        .read(profilesProvider)
        .getProfile(previousProfileId)
        ?.panelMeta;
    applyPanelWidgetsFromMeta(
      ref.read(currentProfileProvider)?.panelMeta,
      previousMeta: previousMeta,
    );
  }

  void setProfileAndAutoApply(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await globalState.safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    unawaited(addProfileFormURL(url));
  }

  void reorder(List<Profile> profiles) {
    ref.read(profilesProvider.notifier).reorder(profiles);
  }

  Future<void> clearEffect(int profileId) async {
    final profilePath = await appPath.getProfilePath(profileId.toString());
    final profileFile = File(profilePath);
    final isExists = await profileFile.exists();
    if (isExists) {
      await profileFile.safeDelete(recursive: true);
    }
    try {
      final error = await _core.clearEffect(profileId);
      if (error.isNotEmpty) {
        commonPrint.log(error, logLevel: LogLevel.warning);
      }
    } catch (error) {
      commonPrint.log(
        'clearEffect($profileId) failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }
}
