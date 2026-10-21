part of '../action.dart';

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  CoreController get _core => ref.read(coreHandlerProvider);
  final Map<int, int> _subscriptionUpdateIntents = {};
  final _profileUpdateCancellations = <int, SubscriptionCancellation>{};
  final _reservedSubscriptionUrls = <String>{};
  Future<void> _lossReviewQueue = Future<void>.value();

  @override
  void build() {}

  Future<PreparedSubscriptionUpdate> prepareProfileCompatibility(
    Profile candidate, {
    SubscriptionCancellation? cancellation,
  }) => _prepareProfileCompatibility(candidate, cancellation: cancellation);

  Future<SubscriptionClientPreset?> lastSuccessfulProfileClient(
    Profile candidate,
  ) => _lastSuccessfulProfileClient(candidate);

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
    _subscriptionUpdateIntents[id] = (_subscriptionUpdateIntents[id] ?? 0) + 1;
    _profileUpdateCancellations.remove(id)?.cancel();
    await serializeProfileMutation(id, () async {
      await ref.read(profilesProvider.notifier).del(id);
      await clearEffect(id);
      await const SubscriptionClientCache().forget(id);
    });
    try {
      await (await DeviceIdentityStore.create()).revoke(id);
    } on Object {
      commonPrint.log('Could not clear local subscription consent');
    }
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
    for (final id in [
      for (final profile in ref.read(profilesProvider)) profile.id,
    ]) {
      final profile = ref.read(profilesProvider).getProfile(id);
      if (profile == null || !profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type != ProfileType.url) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(compactError(e), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile, {bool select = true}) {
    ref.read(profilesProvider.notifier).put(profile);
    if (!select || ref.read(currentProfileIdProvider) != null) return;
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> _saveImportedProfile(
    Profile profile, {
    SubscriptionCancellation? cancellation,
  }) => ref
      .read(profilesProvider.notifier)
      .putAndWait(
        profile,
        isCurrent: cancellation == null ? null : () => !cancellation.cancelled,
      );

  Profile _importedProfile(Profile profile, {required bool select}) {
    final saved = ref.read(profilesProvider).getProfile(profile.id);
    if (saved == null) {
      throw MessageException(currentAppLocalizations.nullProfileDesc);
    }
    if (select && ref.read(currentProfileIdProvider) == null) {
      ref.read(currentProfileIdProvider.notifier).value = saved.id;
    }
    return saved;
  }

  Future<List<Profile>> providerUsers(Profile profile) async {
    if (profile.type == ProfileType.custom) {
      return const [];
    }
    final users = await ref
        .read(clashProvidersActionProvider.notifier)
        .profilesReferencing(ProviderKind.proxy, profile.realLabel);
    return [
      for (final user in users)
        if (user.id != profile.id) user,
    ];
  }

  /// Where a profile's own group takes a name, the name stands for that group.
  Future<List<Profile>> proxyUsers(Set<String> names) async {
    final (ruleTargets, dialerTargets) = await (
      database.rulesDao.targetsNaming(names),
      database.proxyDialersDao.targetsNaming(names),
    ).wait;
    final users = <Profile>[];
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type != ProfileType.custom) {
        continue;
      }
      final groups = await database.proxyGroupsDao.query(profile.id).get();
      final inUse = proxyNamesInUse(
        names.difference({for (final group in groups) group.name}),
        groups: groups,
        ruleTargets: ruleTargets[profile.id] ?? const {},
        dialerTargets: dialerTargets[profile.id] ?? const {},
        overrides: profile.overrides,
      );
      if (inUse.isNotEmpty) {
        users.add(profile);
      }
    }
    return users;
  }

  Future<Set<String>> groupsInUse(int profileId, Set<int> groupIds) async {
    final groups = await database.proxyGroupsDao.query(profileId).get();
    final names = {
      for (final group in groups)
        if (groupIds.contains(group.id)) group.name,
    };
    final (ruleTargets, dialerTargets) = await (
      database.rulesDao.targetsNaming(names),
      database.proxyDialersDao.targetsNaming(names),
    ).wait;
    return proxyNamesInUse(
      names,
      groups: groups.where((group) => !groupIds.contains(group.id)),
      ruleTargets: ruleTargets[profileId] ?? const {},
      dialerTargets: dialerTargets[profileId] ?? const {},
      overrides:
          ref.read(profilesProvider).getProfile(profileId)?.overrides ??
          const ProfileOverrides(),
    );
  }

  Future<void> updateProfiles() async {
    for (final id in [
      for (final profile in ref.read(profilesProvider)) profile.id,
    ]) {
      final profile = ref.read(profilesProvider).getProfile(id);
      if (profile == null || profile.type != ProfileType.url) continue;
      await updateProfile(profile, showLoading: true, allowLossReview: true);
    }
  }

  Future<Map<String, String>> _subscriptionIdentityHeaders(
    Profile profile,
  ) async {
    final origin = Uri.tryParse(profile.url);
    if (origin == null ||
        origin.host.isEmpty ||
        !const {'http', 'https'}.contains(origin.scheme.toLowerCase())) {
      return const {};
    }
    try {
      final store = await DeviceIdentityStore.create();
      return await store.requestFields(profile.id, origin) ?? const {};
    } on Object {
      return const {};
    }
  }

  SubscriptionTransport _subscriptionTransport() {
    if (!system.isAndroid && !system.isDesktop) return SubscriptionTransport();
    bool canBypass() {
      if (!ref.read(isStartProvider) || ref.read(suspendProvider)) return false;
      final settings = ref.read(vpnSettingProvider);
      return system.isAndroid
          ? settings.enable && settings.allowBypass
          : settings.enable && ref.read(tunAppliedProvider);
    }

    return SubscriptionTransport(
      canUseProtected: canBypass,
      protectedFetcher: (uri, headers, timeout, cancellation) async {
        final requestId = snowflake.id.toString();
        unawaited(
          cancellation.whenCancelled.then(
            (_) => _core.cancelSubscriptionFetch(requestId),
          ),
        );
        try {
          return await _core.fetchSubscription(
            requestId,
            uri,
            headers: headers,
            timeout: timeout,
            maxBytes: subscriptionWireLimit,
            protected: system.isAndroid,
            bypass: true,
          );
        } on CoreMethodException catch (error) {
          throw SubscriptionException(
            error.code == 'subscription_timeout'
                ? SubscriptionFailure.timeout
                : SubscriptionFailure.transport,
          );
        }
      },
    );
  }

  Future<SubscriptionImportApproval?> _approveImportLosses(
    PreparedSubscriptionUpdate prepared, {
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) {
    final context =
        reviewContext ?? globalState.navigatorKey.currentState?.context;
    if (context == null || !context.mounted) return Future.value(null);
    final route = SubscriptionImportReviewRoute.fromContext(context);
    final queued = _lossReviewQueue.then<SubscriptionImportApproval?>((
      _,
    ) async {
      if ((cancellation?.cancelled ?? false) || !route.navigator.mounted) {
        return null;
      }
      final approval = await approveSubscriptionImportAt(
        route,
        format: prepared.payload.format,
        summary: prepared.summary,
        sourceScope: subscriptionImportScope(
          prepared.sourceUrl,
          prepared.sourceAgeSecretKey,
        ),
      );
      return cancellation?.cancelled == true ? null : approval;
    });
    _lossReviewQueue = queued.then<void>((_) {}, onError: (_, _) {});
    return queued;
  }

  Future<Profile?> updateProfile(
    Profile profile, {
    bool showLoading = false,
    bool allowLossReview = false,
    bool persistProfileSettings = false,
    PreparedSubscriptionUpdate? preparedUpdate,
    SubscriptionImportPolicy? importPolicy,
    bool acceptLosses = false,
    BuildContext? reviewContext,
  }) async {
    final intent = (_subscriptionUpdateIntents[profile.id] ?? 0) + 1;
    _subscriptionUpdateIntents[profile.id] = intent;
    _profileUpdateCancellations[profile.id]?.cancel();
    final cancellation = SubscriptionCancellation();
    _profileUpdateCancellations[profile.id] = cancellation;
    bool hasIntent() =>
        !cancellation.cancelled &&
        _subscriptionUpdateIntents[profile.id] == intent &&
        identical(_profileUpdateCancellations[profile.id], cancellation);
    final operation = showLoading
        ? ref.read(updatingKeysProvider.notifier).start(profile.updatingKey)
        : null;
    try {
      final original = ref.read(profilesProvider).getProfile(profile.id);
      if (original == null || !hasIntent()) return null;
      final candidate = persistProfileSettings ? profile : original;
      final request = await _subscriptionRequestInputs(candidate);
      if (!hasIntent() ||
          ref.read(profilesProvider).getProfile(profile.id) != original) {
        throw const SubscriptionUpdateSuperseded();
      }
      if (preparedUpdate != null) {
        _ensurePreparedSubscriptionCurrent(candidate, preparedUpdate, request);
      }
      if (persistProfileSettings) {
        await serializeProfileMutation(profile.id, () async {
          if (!hasIntent() ||
              ref.read(profilesProvider).getProfile(profile.id) != original) {
            throw const SubscriptionUpdateSuperseded();
          }
          final profiles = ref.read(profilesProvider.notifier);
          final edited = profiles.labeled(profile);
          await profiles.putAndWait(
            edited,
            isCurrent: () {
              final current = ref.read(profilesProvider).getProfile(profile.id);
              return hasIntent() &&
                  current != null &&
                  (current == original || current == edited);
            },
          );
        });
      }
      final sourceProfile = ref.read(profilesProvider).getProfile(profile.id);
      if (sourceProfile == null || !hasIntent()) return null;
      final prepared =
          preparedUpdate ??
          await _prepareProfileCompatibility(
            sourceProfile,
            cancellation: cancellation,
            request: request,
          );
      _ensurePreparedSubscriptionCurrent(sourceProfile, prepared, request);
      var policy = importPolicy;
      var acceptedLosses =
          acceptLosses ||
          (policy ?? sourceProfile.subscriptionPreferences.client.importPolicy)
              .allows(
                prepared.payload.format,
                prepared.summary,
                sourceScope: subscriptionImportScope(
                  sourceProfile.url,
                  sourceProfile.ageSecretKey,
                ),
              );
      if (prepared.summary.hasLosses && !acceptedLosses && allowLossReview) {
        if (!hasIntent() || reviewContext != null && !reviewContext.mounted) {
          return null;
        }
        final approval = await _approveImportLosses(
          prepared,
          reviewContext: reviewContext,
          cancellation: cancellation,
        );
        if (approval == null) return null;
        acceptedLosses = true;
        policy = approval.rememberedPolicy;
      }
      if (prepared.summary.hasLosses && !acceptedLosses) {
        throw const SubscriptionUpdateCancelled();
      }
      final latest = ref.read(profilesProvider).getProfile(profile.id);
      if (latest == null || !hasIntent()) return null;
      final latestRequest = await _subscriptionRequestInputs(latest);
      if (!hasIntent() ||
          ref.read(profilesProvider).getProfile(profile.id) != latest) {
        throw const SubscriptionUpdateSuperseded();
      }
      _ensurePreparedSubscriptionCurrent(latest, prepared, latestRequest);
      bool isCurrent() {
        final current = ref
            .read(profilesProvider)
            .getProfile(prepared.profileId);
        return hasIntent() && current == latest;
      }

      final updated = await latest.commitPreparedUpdate(
        prepared,
        validate: (path, _) => _core.validateConfig(path),
        acceptLosses: acceptedLosses,
        importPolicy: policy,
        isCurrent: isCurrent,
        onCommitted: (saved) => ref
            .read(profilesProvider.notifier)
            .putAndWait(
              saved,
              isCurrent: () {
                final current = ref.read(profilesProvider).getProfile(saved.id);
                return hasIntent() &&
                    current != null &&
                    (current == latest || current == saved);
              },
            ),
      );
      if (profile.id == ref.read(currentProfileIdProvider)) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      } else {
        final label = ref
            .read(profilesProvider.notifier)
            .labeled(updated)
            .realLabel;
        unawaited(
          ref.read(clashProvidersActionProvider.notifier).applyIfReferenced(
            ProviderKind.proxy,
            {label},
            force: true,
          ),
        );
      }
      return updated;
    } on SubscriptionUpdateCancelled {
      return null;
    } on SubscriptionUpdateSuperseded {
      return null;
    } finally {
      if (identical(_profileUpdateCancellations[profile.id], cancellation)) {
        _profileUpdateCancellations.remove(profile.id);
      }
      cancellation.cancel();
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(profile.updatingKey, operation);
      }
    }
  }

  Future<Profile?> saveImportedProfileFile(
    Profile profile,
    Uint8List bytes, {
    BuildContext? reviewContext,
    bool promptAgeKey = true,
    SubscriptionCancellation? cancellation,
    Future<void> Function(Profile saved)? onCommitted,
  }) {
    Future<Profile?> save(Profile candidate) async {
      void ensureCurrent() {
        if (cancellation?.cancelled == true) {
          throw const SubscriptionUpdateCancelled();
        }
      }

      ensureCurrent();
      final content = await _core.decryptProfilePayload(
        bytes,
        candidate.ageSecretKey,
      );
      ensureCurrent();
      final imported = await prepareSubscriptionImport(content);
      ensureCurrent();
      if (imported.summary.rejectCoreFallback) {
        throw MessageException(currentAppLocalizations.importConfigInvalid);
      }
      if (imported.summary.hasLosses) {
        final context =
            reviewContext ?? globalState.navigatorKey.currentState?.context;
        if (context == null || !context.mounted) return null;
        final accepted = await reviewSubscriptionImport(
          context,
          format: imported.format,
          summary: imported.summary,
        );
        ensureCurrent();
        if (accepted != true) return null;
      }
      return candidate.saveFile(
        imported.bytes,
        validate: (path, _) => _core.validateConfig(path),
        isCurrent: cancellation == null ? null : () => !cancellation.cancelled,
        onCommitted: onCommitted,
      );
    }

    return promptAgeKey ? _withAgeSecretKey(profile, save) : save(profile);
  }

  Future<Profile?> importProfileData(
    List<int> data, {
    required String name,
    String ageSecretKey = '',
    bool select = true,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    final profile = await saveImportedProfileFile(
      Profile.normal(label: name).copyWith(ageSecretKey: ageSecretKey),
      Uint8List.fromList(data),
      reviewContext: reviewContext,
      promptAgeKey: false,
      cancellation: cancellation,
      onCommitted: (saved) =>
          _saveImportedProfile(saved, cancellation: cancellation),
    );
    return profile == null ? null : _importedProfile(profile, select: select);
  }

  Future<Profile?> importProfileFile({
    String ageSecretKey = '',
    bool select = true,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    final platformFile = await picker.pickerFile();
    if (platformFile == null) return null;
    final bytes = await platformFile.readBytes();
    if (reviewContext != null && !reviewContext.mounted) return null;
    return importProfileData(
      bytes,
      name: platformFile.name,
      ageSecretKey: ageSecretKey,
      select: select,
      reviewContext: reviewContext,
      cancellation: cancellation,
    );
  }

  Future<Profile?> importProfileQrCode({
    String ageSecretKey = '',
    bool select = true,
    SubscriptionClientSettings? clientSettings,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    final link = await picker.pickerConfigQRCode();
    if (link == null || reviewContext != null && !reviewContext.mounted) {
      return null;
    }
    return importProfileFromLink(
      link,
      ageSecretKey: ageSecretKey,
      select: select,
      clientSettings: clientSettings,
      reviewContext: reviewContext,
      cancellation: cancellation,
    );
  }

  Future<Profile> importProfileFromLink(
    String link, {
    String? label,
    required String ageSecretKey,
    bool select = true,
    SubscriptionClientSettings? clientSettings,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    final source = await resolveProfileLink(link);
    if (reviewContext != null && !reviewContext.mounted) {
      throw const SubscriptionUpdateCancelled();
    }
    return importProfileLinkSource(
      source,
      label: label,
      ageSecretKey: ageSecretKey,
      select: select,
      clientSettings: clientSettings,
      reviewContext: reviewContext,
      cancellation: cancellation,
    );
  }

  Future<Profile> importProfileLinkSource(
    ProfileLinkSource source, {
    String? label,
    String ageSecretKey = '',
    bool select = true,
    SubscriptionClientSettings? clientSettings,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    if (cancellation?.cancelled == true ||
        reviewContext != null && !reviewContext.mounted) {
      throw const SubscriptionUpdateCancelled();
    }
    final name = label?.trim().isNotEmpty == true ? label!.trim() : source.name;
    if (source.bytes case final bytes?) {
      final profile = await importProfileData(
        bytes,
        name: name ?? currentAppLocalizations.unnamed,
        ageSecretKey: ageSecretKey,
        select: select,
        reviewContext: reviewContext,
        cancellation: cancellation,
      );
      if (profile == null) throw const SubscriptionUpdateCancelled();
      return profile;
    }
    Future<void> save(Profile saved) =>
        _saveImportedProfile(saved, cancellation: cancellation);
    final Profile profile;
    if (source.shareLink case final link?) {
      profile = await _fromShareLinks(
        Profile.normal(label: name),
        [link],
        cancellation: cancellation,
        onCommitted: save,
      );
    } else {
      final url = source.url!;
      final reservation = _reserveSubscriptionUrl(url);
      try {
        final chosenSettings =
            clientSettings ?? const SubscriptionClientSettings.forNewProfile();
        final settings =
            clientSettings == null &&
                chosenSettings.preset == SubscriptionClientPreset.auto &&
                source.preset != null
            ? chosenSettings.copyWith(preset: source.preset)
            : chosenSettings;
        final draft = _withClientSettings(
          Profile.normal(
            label: name,
            url: url,
          ).copyWith(ageSecretKey: ageSecretKey),
          settings,
        );
        if (settings.sendDeviceIdentity case final send?) {
          final store = await DeviceIdentityStore.create();
          await store.setProfileSendOverride(draft.id, send);
          if (cancellation?.cancelled == true ||
              reviewContext != null && !reviewContext.mounted) {
            throw const SubscriptionUpdateCancelled();
          }
        }
        profile = await _download(
          draft,
          reviewContext: reviewContext,
          cancellation: cancellation,
          onCommitted: save,
        );
      } finally {
        if (reservation != null) _reservedSubscriptionUrls.remove(reservation);
      }
    }
    return _importedProfile(profile, select: select);
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    final bytes = await platformFile.readBytes();
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () => saveImportedProfileFile(
        Profile.normal(label: platformFile.name),
        bytes,
      ),
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
    }
  }

  int addCustomProfile(String label) {
    final profile = Profile.custom(label: label);
    putProfile(profile);
    return profile.id;
  }

  void touchProfile(int id) {
    final profile = ref.read(profilesProvider).getProfile(id);
    if (profile == null) return;
    ref
        .read(profilesProvider.notifier)
        .put(profile.copyWith(lastUpdateDate: DateTime.now()));
  }

  Future<CustomProfileImport> readCustomImport(
    int profileId,
    Uint8List bytes,
  ) async {
    final profiles = ref.read(profilesProvider);
    final (ruleProviders, proxies, groupNames) = await (
      database.clashProvidersDao.query().get(),
      database.customProxiesDao.query().get(),
      database.proxyGroupsDao.names(except: profileId).get(),
    ).wait;
    final CustomImportApp app = (
      profileLabels: {
        for (final profile in profiles) ...[profile.label, profile.realLabel],
      },
      profileSources: {
        for (final profile in profiles)
          if (profile.type == ProfileType.url)
            (
              url: profile.url,
              ageSecretKey: profile.ageSecretKey,
              headers: profile.subscriptionPreferences.headers,
            ): profile.realLabel,
      },
      ruleProviderLabels: {
        for (final provider in ruleProviders) provider.label,
      },
      ruleProviderSources: {
        for (final provider in ruleProviders)
          if (provider.isRemote)
            (url: provider.url, ageSecretKey: '', headers: provider.headers):
                provider.label,
      },
      proxies: [for (final proxy in proxies) proxy.definition],
      groupNames: groupNames.toSet(),
    );
    try {
      return await compute(readCustomProfileImport, (bytes: bytes, app: app));
    } on CustomImportException catch (error) {
      final appLocalizations = currentAppLocalizations;
      throw MessageException(switch (error.issue) {
        CustomImportIssue.unreadable => appLocalizations.importConfigInvalid,
        CustomImportIssue.ruleType => appLocalizations.failedItem(
          error.item,
          appLocalizations.ruleTextInvalid,
        ),
        CustomImportIssue.entry => appLocalizations.failedItem(
          error.item,
          error.detail,
        ),
      });
    }
  }

  /// [config] replaces what [profileId] holds. The providers it adds are saved
  /// before the groups and rules naming them, and loaded afterwards; the
  /// future completes once they have loaded.
  Future<void> importCustomProfile(int profileId, CustomProfileImport config) {
    final profiles = ref.read(profilesProvider.notifier);
    final clashProviders = ref.read(clashProvidersProvider.notifier);
    final loads = <({String label, Future<void> Function() load})>[];
    for (final (:label, :url, :ageSecretKey, :content, :headers)
        in config.proxyProviders) {
      final baseProfile = Profile.normal(label: label, url: url);
      final profile = baseProfile.copyWith(
        ageSecretKey: ageSecretKey,
        subscriptionPreferences: baseProfile.subscriptionPreferences.copyWith(
          headers: headers,
        ),
      );
      profiles.put(profile);
      loads.add((
        label: label,
        load: url.isNotEmpty
            ? () => updateProfile(
                profile,
                showLoading: true,
                allowLossReview: true,
              )
            : () async => profiles.put(
                await profile.saveFile(
                  utf8.encode(content),
                  validate: (path, key) => _core.validateProfile(path, key),
                ),
              ),
      ));
    }
    for (final (:label, :url, ageSecretKey: _, :content, :headers)
        in config.ruleProviders) {
      final provider = ClashProvider.create(
        label: label,
        url: url,
      ).copyWith(headers: headers);
      clashProviders.put(provider);
      loads.add((
        label: label,
        load: url.isNotEmpty
            ? () => ref
                  .read(resourcesActionProvider.notifier)
                  .updateRuleProvider(provider)
            : () => ref
                  .read(clashProvidersActionProvider.notifier)
                  .putProvider(provider, content: utf8.encode(content)),
      ));
    }
    final customProxies = ref.read(customProxiesProvider.notifier);
    customProxies.putAll([
      for (final definition in config.proxies)
        CustomProxy.fromDefinition(definition),
    ]);
    final proxyIds = {
      for (final proxy in customProxies.value) proxy.name: proxy.id,
    };
    ref.read(proxyGroupsProvider(profileId).notifier).setAll([
      for (final group in config.proxyGroups) group.copyWith(id: snowflake.id),
    ]);
    ref.read(profileRulesProvider(profileId).notifier).setAll([
      for (final rule in config.rules) rule.copyWith(id: snowflake.id),
    ]);
    ref.read(proxyDialersProvider(profileId).notifier).setAll({
      for (final MapEntry(:key, :value) in config.dialers.entries)
        ?proxyIds[key]: value,
    });
    profiles.updateProfile(
      profileId,
      (profile) => profile.copyWith(overrides: config.overrides),
    );
    return globalState.batchRun(
      loads,
      (item) => item.load(),
      label: (item) => item.label,
      concurrency: maxConcurrentImports,
      tag: null,
    );
  }

  Profile _withClientSettings(
    Profile profile,
    SubscriptionClientSettings? settings,
  ) => settings == null
      ? profile
      : profile.copyWith(
          subscriptionPreferences: profile.subscriptionPreferences.copyWith(
            client: settings,
          ),
        );

  void _showProfiles() {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).value = PageLabel.profiles;
  }

  Future<void> addProfileFromLink(
    String link, {
    String? label,
    String ageSecretKey = '',
    SubscriptionClientSettings? clientSettings,
  }) async {
    final source = await globalState.safeRun(() => resolveProfileLink(link));
    if (source == null) return;
    await addProfileLinkSource(
      source,
      label: label,
      ageSecretKey: ageSecretKey,
      clientSettings: clientSettings,
    );
  }

  Future<void> addProfileLinkSource(
    ProfileLinkSource source, {
    String? label,
    String ageSecretKey = '',
    SubscriptionClientSettings? clientSettings,
  }) async {
    _showProfiles();
    await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () => _saveProfileLinkSource(
        source,
        label: label,
        ageSecretKey: ageSecretKey,
        clientSettings: clientSettings,
      ),
      title: currentAppLocalizations.addProfile,
    );
  }

  Future<Profile> _addProfileLink(
    ProfileLinkInput input, {
    SubscriptionClientSettings? clientSettings,
  }) async {
    final source = await resolveProfileLink(input.url);
    return _saveProfileLinkSource(
      source,
      label: input.label,
      ageSecretKey: input.ageSecretKey,
      clientSettings: clientSettings,
    );
  }

  Future<Profile> _saveProfileLinkSource(
    ProfileLinkSource source, {
    String? label,
    String ageSecretKey = '',
    SubscriptionClientSettings? clientSettings,
  }) async {
    Future<Profile> save(String key) => importProfileLinkSource(
      source,
      label: label,
      ageSecretKey: key,
      clientSettings: clientSettings,
    );
    try {
      return await save(ageSecretKey);
    } on AgeSecretKeyRequiredException {
      final key = (await dialogs.showAgeSecretKeyInput())?.trim();
      if (key == null || key.isEmpty) {
        throw const SubscriptionUpdateCancelled();
      }
      return save(key);
    }
  }

  Future<void> addProfilesFromLinks(
    List<ProfileLinkInput> links, {
    SubscriptionClientSettings? clientSettings,
    int skippedExisting = 0,
  }) async {
    _showProfiles();
    final shareLinks = [
      for (final input in links)
        if (input.url.isShareLink) input.url,
    ];
    await globalState.batchRun(
      [
        for (final input in links)
          if (!input.url.isShareLink)
            (input: input, shareLinks: const <String>[])
          else if (input.url == shareLinks.first)
            (input: input, shareLinks: shareLinks),
      ],
      (item) async {
        if (item.shareLinks.isEmpty) {
          await _addProfileLink(item.input, clientSettings: clientSettings);
        } else {
          final profile = await _fromShareLinks(
            Profile.normal(label: item.input.label),
            item.shareLinks,
            onCommitted: _saveImportedProfile,
          );
          _importedProfile(profile, select: true);
        }
      },
      label: (item) => profileLinkDisplaySource(item.input.url),
      concurrency: maxConcurrentImports,
      tag: LoadingTag.profiles,
      skipped: skippedExisting,
      reportSummary: true,
    );
  }

  /// A link import pointed at a subscription URL that an existing profile
  /// already tracks is refused instead of creating a duplicate. Share links
  /// and file imports have no stable URL and skip this check at the call site.
  String? _reserveSubscriptionUrl(String url) {
    if (!ref.read(appSettingProvider).preventDuplicateProfiles) return null;
    final normalizedUrl = url.trim();
    final hasDuplicate =
        _reservedSubscriptionUrls.contains(normalizedUrl) ||
        ref
            .read(profilesProvider)
            .any((profile) => profile.url.trim() == normalizedUrl);
    if (hasDuplicate) {
      throw MessageException(currentAppLocalizations.profileImportDuplicate);
    }
    _reservedSubscriptionUrls.add(normalizedUrl);
    return normalizedUrl;
  }

  Future<Profile> _download(
    Profile profile, {
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
    Future<void> Function(Profile saved)? onCommitted,
  }) async {
    final request = await _subscriptionRequestInputs(profile);
    final prepared = await _prepareProfileCompatibility(
      profile,
      request: request,
      cancellation: cancellation,
    );
    if (reviewContext != null && !reviewContext.mounted) {
      throw const SubscriptionUpdateCancelled();
    }
    SubscriptionImportApproval? approval = const SubscriptionImportApproval();
    if (!profile.subscriptionPreferences.client.importPolicy.allows(
      prepared.payload.format,
      prepared.summary,
      sourceScope: subscriptionImportScope(profile.url, profile.ageSecretKey),
    )) {
      approval = await _approveImportLosses(
        prepared,
        reviewContext: reviewContext,
        cancellation: cancellation,
      );
      if (approval == null) throw const SubscriptionUpdateCancelled();
    }
    _ensurePreparedSubscriptionCurrent(
      profile,
      prepared,
      await _subscriptionRequestInputs(profile),
    );
    if (cancellation?.cancelled == true) {
      throw const SubscriptionUpdateCancelled();
    }
    return profile.commitPreparedUpdate(
      prepared,
      validate: (path, _) => _core.validateConfig(path),
      acceptLosses: true,
      allowProviderLabel: true,
      importPolicy: approval.rememberedPolicy,
      isCurrent: cancellation == null ? null : () => !cancellation.cancelled,
      onCommitted: onCommitted,
    );
  }

  Future<T> _withAgeSecretKey<T>(
    Profile profile,
    Future<T> Function(Profile profile) save,
  ) async {
    try {
      return await save(profile);
    } on AgeSecretKeyRequiredException {
      final key = (await dialogs.showAgeSecretKeyInput())?.trim();
      if (key == null || key.isEmpty) {
        throw const SubscriptionUpdateCancelled();
      }
      return save(profile.copyWith(ageSecretKey: key));
    }
  }

  Future<Profile> _fromShareLinks(
    Profile profile,
    List<String> links, {
    SubscriptionCancellation? cancellation,
    Future<void> Function(Profile saved)? onCommitted,
  }) async {
    if (cancellation?.cancelled == true) {
      throw const SubscriptionUpdateCancelled();
    }
    final appLocalizations = currentAppLocalizations;
    final decoded = await _core.decodeShareLinks(links);
    if (cancellation?.cancelled == true) {
      throw const SubscriptionUpdateCancelled();
    }
    final taken = {...reservedCustomProxyNames};
    final proxies = <Map<String, dynamic>>[];
    for (final (index, definitions) in decoded.indexed) {
      if (definitions.isEmpty) {
        throw MessageException(
          links.length == 1
              ? appLocalizations.shareLinksInvalid
              : appLocalizations.shareLinkUnreadable(
                  profileLinkDisplaySource(links[index]),
                ),
        );
      }
      for (final definition in definitions) {
        final name = freeProxyName(linkProxyName(definition), taken);
        proxies.add({...definition, 'name': name});
      }
    }
    final first = proxies.first['name'] as String;
    final label = proxies.length == 1
        ? first
        : appLocalizations.proxiesProfileLabel(first, proxies.length);
    final config = await encodeYamlTask({'proxies': proxies});
    return profile
        .copyWith(label: profile.label.takeFirstValid([label]))
        .saveFile(
          utf8.encode(config),
          validate: (path, _) => _core.validateConfig(path),
          isCurrent: cancellation == null
              ? null
              : () => !cancellation.cancelled,
          onCommitted: onCommitted,
        );
  }

  Future<void> addProfileFormQrCode() async {
    final url = await globalState.safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    unawaited(addProfileFromLink(url));
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
