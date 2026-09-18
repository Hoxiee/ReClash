part of '../action.dart';

sealed class ProfileImportRequest {
  const ProfileImportRequest();

  const factory ProfileImportRequest.link(
    String url, {
    SubscriptionClient client,
    String? name,
    String customUserAgent,
  }) = ProfileLinkImportRequest;

  const factory ProfileImportRequest.file() = ProfileFileImportRequest;

  const factory ProfileImportRequest.qrCode() = ProfileQrCodeImportRequest;

  const factory ProfileImportRequest.raw(String content) =
      ProfileRawImportRequest;
}

final class ProfileLinkImportRequest extends ProfileImportRequest {
  const ProfileLinkImportRequest(
    this.url, {
    this.client = SubscriptionClient.auto,
    this.name,
    this.customUserAgent = '',
  });

  final String url;
  final SubscriptionClient client;
  final String? name;
  final String customUserAgent;
}

final class ProfileFileImportRequest extends ProfileImportRequest {
  const ProfileFileImportRequest();
}

final class ProfileQrCodeImportRequest extends ProfileImportRequest {
  const ProfileQrCodeImportRequest();
}

final class ProfileRawImportRequest extends ProfileImportRequest {
  const ProfileRawImportRequest(this.content);

  final String content;
}

class ProfileImportResult {
  const ProfileImportResult._({this.profile, this.summary, this.failure});

  const ProfileImportResult.cancelled() : this._();

  const ProfileImportResult.failed(ProfileImportFailure failure)
    : this._(failure: failure);

  const ProfileImportResult.imported(
    Profile profile,
    ProfileImportSummary summary,
  ) : this._(profile: profile, summary: summary);

  final Profile? profile;
  final ProfileImportSummary? summary;
  final ProfileImportFailure? failure;

  bool get isImported => profile != null;
  bool get isCancelled => profile == null && failure == null;
  bool get isFailed => failure != null;
}

class ProfileOperationSupersededException implements Exception {
  const ProfileOperationSupersededException();
}

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  final _profileSchedulers = <int, SerialTaskScheduler>{};
  final _profileRevisions = <int, int>{};

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  int _nextProfileRevision(int profileId) => _profileRevisions.update(
    profileId,
    (revision) => revision + 1,
    ifAbsent: () => 1,
  );

  Future<T> _runProfileOperation<T>(
    int profileId,
    Future<T> Function() operation,
  ) {
    final scheduler = _profileSchedulers.putIfAbsent(
      profileId,
      SerialTaskScheduler.new,
    );
    return scheduler.run(operation);
  }

  void _ensureCurrentProfileRevision(int profileId, int revision) {
    if (_profileRevisions[profileId] != revision) {
      throw const ProfileOperationSupersededException();
    }
  }

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
    _nextProfileRevision(id);
    await _runProfileOperation(id, () async {
      await ref.read(profilesProvider.notifier).del(id);
      await clearEffect(id);
      unawaited(subscriptionReminder.forget(id));
      unawaited(preferences.forgetSubscriptionHosts(id));
    });
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
        await updateProfile(profile, isAutoUpdate: true);
      } on ProfileEmptyAfterUpdateException {
        final name = profile.label.isEmpty ? '${profile.id}' : profile.label;
        commonPrint.log(
          'Auto-update for $name kept the previous config: refresh produced no '
          'dialable nodes',
          logLevel: LogLevel.info,
        );
      } catch (e) {
        commonPrint.log(compactError(e), logLevel: LogLevel.warning);
      }
    }
  }

  void markProfileUsed(int profileId, [DateTime? usedAt]) {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (profile) => profile.copyWith(lastUsedAt: usedAt ?? DateTime.now()),
        );
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
    bool isAutoUpdate = false,
  }) async {
    final revision = _nextProfileRevision(profile.id);
    final operation = showLoading
        ? ref.read(updatingKeysProvider.notifier).start(profile.updatingKey)
        : null;
    try {
      ref.read(profilesProvider.notifier).put(profile);
      final prepared = await prepareProfileUpdate(
        profile,
        allowDirectRetry: showLoading,
        isAutoUpdate: isAutoUpdate,
      );
      await _runProfileOperation(profile.id, () async {
        _ensureCurrentProfileRevision(profile.id, revision);
        final current = ref.read(profilesProvider).getProfile(profile.id);
        if (current == null) {
          throw const ProfileOperationSupersededException();
        }
        final merged = _mergePreparedProfile(current, prepared.profile);
        final committedPrepared = PreparedProfileImport(
          profile: merged,
          content: prepared.content,
          skippedNodes: prepared.skippedNodes,
          summary: prepared.summary,
          responseHeaders: prepared.responseHeaders,
          undialableNodes: prepared.undialableNodes,
        );
        final newProfile = await merged.commitPreparedFile(
          committedPrepared,
          persist: ref.read(profilesProvider.notifier).putAsync,
        );
        await _rememberPreparedHosts(prepared, newProfile);
        unawaited(handlePanelVerdicts(newProfile.panelMeta));
        if (ref
            .read(appSettingProvider)
            .notificationSettings
            .subscriptionReminders) {
          unawaited(subscriptionReminder.check(newProfile));
        }
        if (profile.id == ref.read(currentProfileIdProvider)) {
          applyPanelWidgetsFromMeta(
            newProfile.panelMeta,
            previousMeta: current.panelMeta,
          );
          ref
              .read(setupActionProvider.notifier)
              .applyProfileDebounce(silence: true);
        }
      });
    } catch (error, stackTrace) {
      if (_profileRevisions[profile.id] == revision) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    } finally {
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(profile.updatingKey, operation);
      }
    }
  }

  @visibleForTesting
  Future<PreparedProfileImport> prepareProfileUpdate(
    Profile profile, {
    bool allowDirectRetry = false,
    bool isAutoUpdate = false,
  }) async {
    final allowDeviceIdentity = ref.read(appSettingProvider).sendDeviceIdentity;
    final probe = SubscriptionUpdateProbe();
    try {
      return await profile.prepareUpdate(
        fetch: _subscriptionFetch(allowDirectRetry: allowDirectRetry),
        validate: (path) => _core.validateConfig(path),
        inspect: (path) => _core.inspectConfig(path),
        requestHeaders: await deviceIdentity.subscriptionHeaders(
          includeDeviceIdentity: allowDeviceIdentity,
        ),
        allowDeviceIdentityRetry: allowDeviceIdentity,
        guardEmptyPlummet: isAutoUpdate,
        updateProbe: probe,
      );
    } finally {
      unawaited(preferences.saveSubscriptionUpdateReport(probe.build()));
    }
  }

  Future<SubscriptionReport> buildSubscriptionReport() async {
    final proxies = await _core.getProxies();
    final labels = subscriptionNodeLabelsOf(proxies.proxies);
    final metadata = SubscriptionMetadata(
      nodes: labels,
      presets: _activeSubscriptionPresets(),
    );
    await _core.setSubscriptionMetadata(metadata);
    final report = await _core.exportSubscriptionReport();
    final update = await preferences.getSubscriptionUpdateReport();
    final doctor = ref.read(connectionDoctorProvider);
    final fault = subscriptionFaultOf(
      terrain: report.terrain,
      doctorCauseCode: doctor.causeCode,
      doctorLayer: doctor.layer,
      update: update,
      dial: report.runtimeDial,
    );
    return report.copyWith(
      appVersion: globalState.packageInfo.version,
      subscriptionUpdate: update,
      verdict: SubscriptionVerdict(
        fault: fault,
        health: doctor.health.name,
        causeCode: doctor.causeCode,
        layer: doctor.layer.name,
        terrain: report.terrain,
        env: report.env,
      ),
    );
  }

  List<String> _activeSubscriptionPresets() {
    final routing = ref.read(smartRoutingSettingProvider);
    final desync = ref.read(desyncSettingProvider);
    return [
      'route=${routing.preset.name}',
      if (desync.enabled) 'desync=on' else 'desync=off',
    ];
  }

  Profile _mergePreparedProfile(Profile current, Profile prepared) {
    return current.copyWith(
      url: prepared.url,
      label: current.userLabel ? current.label : prepared.label,
      subscriptionInfo: prepared.subscriptionInfo,
      panelMeta: prepared.panelMeta,
      capabilityManifest: prepared.capabilityManifest,
      capabilityManifestIssue: prepared.capabilityManifestIssue,
      autoUpdateDuration: prepared.autoUpdateDuration,
      lastWorkingClient: prepared.lastWorkingClient,
    );
  }

  Future<void> handlePanelVerdicts(
    PanelMeta? panelMeta, {
    bool onImport = false,
  }) async {
    if (panelMeta == null) return;
    if (panelMeta.hwidMaxDevicesReached) {
      final confirmed = await dialogs.showMessage(
        title: currentAppLocalizations.deviceLimitReached,
        message: TextSpan(
          text: panelMeta.announce.takeFirstValid([
            currentAppLocalizations.deviceLimitReachedTip,
          ]),
        ),
        confirmText: panelMeta.supportUrl != null
            ? currentAppLocalizations.support
            : null,
      );
      if (confirmed == true && panelMeta.supportUrl != null) {
        await dialogs.openUrl(panelMeta.supportUrl!);
      }
    } else if (onImport && panelMeta.hwidNotSupported) {
      await dialogs.showMessage(
        title: currentAppLocalizations.panelHwidNotSupported,
        message: TextSpan(text: _panelHwidMessage()),
      );
    }
  }

  String _panelHwidMessage() => [
    currentAppLocalizations.panelHwidNotSupportedTip,
    if (!ref.read(appSettingProvider).sendDeviceIdentity)
      currentAppLocalizations.panelHwidIdentityDisabled,
  ].join('\n\n');

  Future<ProfileImportResult> importProfile(
    ProfileImportRequest request,
  ) async {
    ref.read(loadingProvider(LoadingTag.profiles).notifier).start();
    try {
      final imported = await performProfileImport(request);
      if (imported == null) return const ProfileImportResult.cancelled();
      _showImportSummary(imported.profile, imported.prepared.summary);
      return ProfileImportResult.imported(
        imported.profile,
        imported.prepared.summary,
      );
    } catch (error) {
      final failure = profileImportFailure(error, request);
      commonPrint.log(
        'Profile import failed: ${failure.name}',
        logLevel: LogLevel.warning,
      );
      await dialogs.showMessage(
        title: currentAppLocalizations.addProfile,
        message: TextSpan(
          text: error is ProfilePanelException
              ? error.meta.hwidMaxDevicesReached
                    ? currentAppLocalizations.deviceLimitReachedTip
                    : _panelHwidMessage()
              : profileImportFailureMessage(failure, currentAppLocalizations),
        ),
        cancelable: false,
      );
      return ProfileImportResult.failed(failure);
    } finally {
      await ref.read(loadingProvider(LoadingTag.profiles).notifier).stop();
    }
  }

  void _showImportSummary(Profile profile, ProfileImportSummary summary) {
    final skipped = profile.skippedNodes.length;
    if (profile.undialableNodes) {
      if (profile.panelMeta?.hwidMaxDevicesReached == true) return;
      unawaited(
        dialogs.showMessage(
          title: currentAppLocalizations.addProfile,
          message: TextSpan(
            text: currentAppLocalizations.subscriptionUndialable,
          ),
          cancelable: false,
        ),
      );
      return;
    }
    final format = profileImportFormatLabel(
      summary.format,
      currentAppLocalizations,
    );
    final client = subscriptionClientLabel(
      profile.effectiveClient ?? SubscriptionClient.auto,
      currentAppLocalizations,
    );
    final message = currentAppLocalizations.profileImportSuccessSummary(
      format,
      client,
      summary.nodeCount,
      summary.groupCount,
    );
    if (skipped > 0) {
      dialogs.showNotifier(
        '$message · ${currentAppLocalizations.profileImportSkippedNodes(skipped)}',
        level: MessageLevel.warning,
      );
      return;
    }
    dialogs.showNotifier(message, level: MessageLevel.success);
  }

  @visibleForTesting
  Future<({PreparedProfileImport prepared, Profile profile})?>
  performProfileImport(ProfileImportRequest request) async {
    final prepared = await prepareProfileImport(request);
    if (prepared == null) return null;
    final profile = await commitPreparedImport(prepared);
    await _applyImportSideEffects(prepared, profile);
    return (prepared: prepared, profile: profile);
  }

  @visibleForTesting
  Future<PreparedProfileImport?> prepareProfileImport(
    ProfileImportRequest request,
  ) async {
    return switch (request) {
      ProfileLinkImportRequest() => _prepareLink(request),
      ProfileFileImportRequest() => _prepareFile(),
      ProfileQrCodeImportRequest() => _prepareQrCode(),
      ProfileRawImportRequest() => _prepareRaw(request.content),
    };
  }

  @visibleForTesting
  Future<Profile> commitPreparedImport(PreparedProfileImport prepared) async {
    final profile = await prepared.profile.commitPreparedFile(
      prepared,
      persist: ref.read(profilesProvider.notifier).putAsync,
    );
    if (ref.read(currentProfileIdProvider) == null) {
      ref.read(currentProfileIdProvider.notifier).value = profile.id;
    }
    return profile;
  }

  Future<void> _rememberPreparedHosts(
    PreparedProfileImport prepared,
    Profile profile,
  ) async {
    try {
      await profile.rememberPreparedHosts(prepared);
    } catch (error) {
      commonPrint.log(
        'Subscription host metadata was not saved: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<void> _applyImportSideEffects(
    PreparedProfileImport prepared,
    Profile profile,
  ) async {
    if (prepared.responseHeaders.isNotEmpty) {
      await _rememberPreparedHosts(prepared, profile);
      applyPanelWidgetsFromMeta(profile.panelMeta);
      await confirmAndApplyPanelSettings(profile.panelMeta);
      unawaited(handlePanelVerdicts(profile.panelMeta, onImport: true));
    }
  }

  @visibleForTesting
  ProfileImportFailure profileImportFailure(
    Object error,
    ProfileImportRequest request,
  ) {
    if (error is ProfileImportUrlException) {
      return ProfileImportFailure.invalidUrl;
    }
    if (error is ProfilePanelException) {
      return ProfileImportFailure.fetchRejected;
    }
    if (error is ProfileValidationException) {
      return ProfileImportFailure.invalidConfig;
    }
    if (error is ProfileFetchException) {
      return error.failure == ProfileFetchFailure.emptyResponse
          ? ProfileImportFailure.emptyResponse
          : ProfileImportFailure.fetchFailed;
    }
    if (error is CoreMethodException &&
        error.code.startsWith('subscription_')) {
      return ProfileImportFailure.fetchFailed;
    }
    if (error is DioException) {
      return error.type == DioExceptionType.badResponse
          ? ProfileImportFailure.fetchRejected
          : ProfileImportFailure.fetchFailed;
    }
    final networkMessage = networkErrorMessage(error, currentAppLocalizations);
    if (networkMessage == currentAppLocalizations.networkException) {
      return ProfileImportFailure.fetchRejected;
    }
    if (networkMessage != null) {
      return ProfileImportFailure.fetchFailed;
    }
    if (error is MessageException && request is ProfileQrCodeImportRequest) {
      return ProfileImportFailure.invalidQrCode;
    }
    if (request is ProfileFileImportRequest && error is FileSystemException) {
      return ProfileImportFailure.fileReadFailed;
    }
    return ProfileImportFailure.unexpected;
  }

  Future<PreparedProfileImport?> _prepareFile() async {
    final platformFile = await picker.pickerFile();
    if (platformFile == null) return null;
    final bytes = await platformFile.readBytes();
    return Profile.normal(
      label: platformFile.name,
    ).prepareFile(bytes, validate: (path) => _core.validateConfig(path));
  }

  Future<PreparedProfileImport> _prepareRaw(String content) {
    return Profile.normal().prepareContent(
      content,
      validate: (path) => _core.validateConfig(path),
    );
  }

  FetchProfileResponse _subscriptionFetch({bool allowDirectRetry = true}) {
    bool allowed() =>
        allowDirectRetry &&
        system.isAndroid &&
        ref.mounted &&
        ref.read(isStartProvider) &&
        !ref.read(pausedProvider) &&
        ref.read(vpnSettingProvider).enable &&
        ref.read(vpnSettingProvider).allowBypass;
    final transport = ProtectedSubscriptionTransport(
      hop: _core.fetchSubscription,
      allowed: allowed,
    );
    return SubscriptionRetry(
      fetchNormally: request.getFileResponseForUrl,
      fetchProtected: transport.download,
      allowed: allowed,
      confirm: () async =>
          await dialogs.showMessage(
            title: currentAppLocalizations.subscriptionDirectRetryTitle,
            message: TextSpan(
              text: currentAppLocalizations.subscriptionDirectRetryMessage,
            ),
            confirmText: currentAppLocalizations.subscriptionDirectRetryConfirm,
          ) ==
          true,
    ).fetch;
  }

  Future<PreparedProfileImport> _prepareLink(
    ProfileLinkImportRequest request,
  ) async {
    final uri = Uri.tryParse(request.url);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      throw const ProfileImportUrlException();
    }
    if (profilePointsToListener(
      request.url,
      ref.read(patchClashConfigProvider).mixedPort,
    )) {
      dialogs.showNotifier(
        currentAppLocalizations.subscriptionLoopbackWarning,
        level: MessageLevel.warning,
      );
    }
    final allowDeviceIdentity = ref.read(appSettingProvider).sendDeviceIdentity;
    return Profile.normal(
      url: request.url,
      label: request.name,
      clientCompatibility: request.client,
      customUserAgent: request.customUserAgent,
    ).prepareUpdate(
      fetch: _subscriptionFetch(),
      validate: (path) => _core.validateConfig(path),
      inspect: (path) => _core.inspectConfig(path),
      requestHeaders: await deviceIdentity.subscriptionHeaders(
        includeDeviceIdentity: allowDeviceIdentity,
      ),
      allowDeviceIdentityRetry: allowDeviceIdentity,
    );
  }

  Future<PreparedProfileImport?> _prepareQrCode() async {
    final url = await picker.pickerConfigQRCode();
    if (url == null) return null;
    return _prepareLink(ProfileLinkImportRequest(url));
  }

  Future<bool> installDeveloperSubscription(
    DeveloperSubscription fixture,
  ) async {
    final profiles = ref.read(profilesProvider);
    final existing = profiles
        .where((profile) => profile.panelMeta?.serviceLogo == fixture.logo)
        .firstOrNull;
    final base = existing ?? Profile.normal(label: fixture.name);
    final previousMeta = existing?.panelMeta;
    final content = await rootBundle.loadString(fixture.configAsset);
    final saved = await globalState.loadingRun<Profile>(
      tag: LoadingTag.profiles,
      () {
        return base
            .copyWith(
              label: existing?.userLabel == true
                  ? existing!.label
                  : fixture.name,
              url: '',
              autoUpdate: false,
              subscriptionInfo: fixture.subscriptionInfo,
              panelMeta: fixture.panelMeta,
            )
            .saveFileWithString(
              content,
              validate: (path) => _core.validateConfig(path),
            );
      },
      title: currentAppLocalizations.addProfile,
    );
    if (saved == null) return false;
    putProfile(saved);
    if (saved.id == ref.read(currentProfileIdProvider)) {
      applyPanelWidgetsFromMeta(saved.panelMeta, previousMeta: previousMeta);
    }
    return true;
  }

  @visibleForTesting
  Future<bool> confirmAndApplyPanelSettings(PanelMeta? meta) async {
    final tokens = meta?.settings;
    if (tokens == null || tokens.isEmpty) return false;
    final requested = _panelSettings(tokens);
    if (requested.isEmpty) return false;
    final confirmed = await dialogs.showMessage(
      title: currentAppLocalizations.panelSettingsConfirmTitle,
      message: TextSpan(
        text: currentAppLocalizations.panelSettingsConfirmMessage(
          requested.join('\n'),
        ),
      ),
    );
    if (confirmed != true) return false;
    _applyPanelSettingsDefaults(tokens);
    return true;
  }

  List<String> _panelSettings(List<String> tokens) {
    final labels = <String, String>{
      'minimize': currentAppLocalizations.minimizeOnExit,
      'autorun': currentAppLocalizations.autoRun,
      'shadowstart': currentAppLocalizations.silentLaunch,
      'autostart': currentAppLocalizations.autoLaunch,
      'autoupdate': currentAppLocalizations.autoCheckUpdate,
      'openlogs': currentAppLocalizations.logs,
      'closeconnections': currentAppLocalizations.closeConnections,
    };
    return tokens
        .map((token) => labels[token])
        .nonNulls
        .map((label) => '• $label')
        .toList();
  }

  void _applyPanelSettingsDefaults(List<String> tokens) {
    final set = tokens.toSet();
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            minimizeOnExit: set.contains('minimize')
                ? true
                : state.minimizeOnExit,
            autoRun: set.contains('autorun') ? true : state.autoRun,
            silentLaunch: set.contains('shadowstart')
                ? true
                : state.silentLaunch,
            autoLaunch: set.contains('autostart') ? true : state.autoLaunch,
            autoCheckUpdate: set.contains('autoupdate')
                ? true
                : state.autoCheckUpdate,
            openLogs: set.contains('openlogs') ? true : state.openLogs,
            closeConnections: set.contains('closeconnections')
                ? true
                : state.closeConnections,
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
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(dashboardWidgets: next));
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
