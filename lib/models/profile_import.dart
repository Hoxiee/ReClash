import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/config/amnezia_config.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:path/path.dart' show basename, join;
import 'package:yaml/yaml.dart';

import 'capability.dart';
import 'capability_headers.dart';
import 'panel_headers.dart';
import 'panel_meta.dart';
import 'profile.dart';

final _profileCommitTails = <int, Future<void>>{};

Future<T> _serializeProfileCommit<T>(
  int profileId,
  Future<T> Function() action,
) async {
  final previous = _profileCommitTails[profileId];
  final release = Completer<void>();
  final current = release.future;
  _profileCommitTails[profileId] = current;
  if (previous != null) {
    await previous;
  }
  try {
    return await action();
  } finally {
    release.complete();
    if (identical(_profileCommitTails[profileId], current)) {
      final _ = _profileCommitTails.remove(profileId);
    }
  }
}

class _IdentifiedResponse {
  const _IdentifiedResponse({
    required this.response,
    required this.headers,
    this.identityRejected = false,
  });

  final Response<Uint8List> response;
  final Map<String, String> headers;
  final bool identityRejected;
}

extension ProfileExtension on Profile {
  ProfileType get type =>
      url.isEmpty == true ? ProfileType.file : ProfileType.url;

  bool get realAutoUpdate => url.isEmpty == true ? false : autoUpdate;

  String get realLabel => label.takeFirstValid([id.toString()]);

  /// Null while `auto` has not yet settled on a format, so callers can tell
  /// "not probed" apart from a preset the user pinned.
  SubscriptionClient? get effectiveClient =>
      clientCompatibility == SubscriptionClient.auto
      ? lastWorkingClient
      : clientCompatibility;

  String get fileName => '$id.yaml';

  String get updatingKey => 'profile_$id';

  Future<Profile?> checkAndUpdateAndCopy({
    required ValidateConfig validate,
    required InspectConfig inspect,
    Map<String, String>? requestHeaders,
    bool allowDeviceIdentityRetry = false,
  }) async {
    final mFile = await _getFile(false);
    final isExists = await mFile.exists();
    if (isExists || url.isEmpty) {
      return null;
    }
    final prepared = await prepareUpdate(
      validate: validate,
      inspect: inspect,
      requestHeaders: requestHeaders,
      allowDeviceIdentityRetry: allowDeviceIdentityRetry,
    );
    final committed = await commitPreparedFile(prepared);
    try {
      await committed.rememberPreparedHosts(prepared);
    } catch (error) {
      commonPrint.log(
        'Subscription host metadata was not saved: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
    return committed;
  }

  Future<File> _getFile([bool autoCreate = true]) async {
    final path = await appPath.getProfilePath(id.toString());
    final file = File(path);
    final isExists = await file.exists();
    if (!isExists && autoCreate) {
      return file.create(recursive: true);
    }
    return file;
  }

  Future<File> get file async {
    return _getFile();
  }

  Future<Profile> update({
    required ValidateConfig validate,
    required InspectConfig inspect,
    Map<String, String>? requestHeaders,
    bool allowDeviceIdentityRetry = false,
    FetchProfileResponse? fetch,
  }) async {
    final prepared = await prepareUpdate(
      validate: validate,
      inspect: inspect,
      requestHeaders: requestHeaders,
      allowDeviceIdentityRetry: allowDeviceIdentityRetry,
      fetch: fetch,
    );
    return commitPreparedFile(
      prepared,
      persist: (committed) async {
        try {
          await rememberPreparedHosts(prepared);
        } catch (error) {
          commonPrint.log(
            'Subscription host metadata was not saved: ${compactError(error)}',
            logLevel: LogLevel.warning,
          );
        }
        return committed;
      },
    );
  }

  Future<PreparedProfileImport> prepareUpdate({
    required ValidateConfig validate,
    required InspectConfig inspect,
    Map<String, String>? requestHeaders,
    bool allowDeviceIdentityRetry = false,
    bool guardEmptyPlummet = false,
    FetchProfileResponse? fetch,
    SubscriptionUpdateProbe? updateProbe,
  }) async {
    final target = normalizeSubscriptionUrl(url);
    final record = await preferences.getSubscriptionHostRecord();
    final fetchResponse = fetch ?? request.getFileResponseForUrl;
    Object? lastError;
    ProfilePanelException? panelFailure;
    PreparedProfileImport? stubFallback;
    // The HWID gate belongs to the panel, not to the compatibility preset, so one
    // refusal is enough to stop paying for a second request per probe.
    var identityRejected = false;
    for (final host in subscriptionUrlCandidates(target, record.hostsFor(id))) {
      final clients = probeOrder(
        clientCompatibility,
        lastWorking: lastWorkingClient,
      );
      final probes = clientCompatibility == SubscriptionClient.auto
          ? <SubscriptionClient?>[null, ...clients]
          : <SubscriptionClient?>[...clients];
      for (final probe in probes) {
        final client = probe ?? SubscriptionClient.auto;
        final headers = buildSubscriptionHeaders(
          client,
          deviceDetails: await deviceIdentity.info,
          defaultUa: requestHeaders?['User-Agent'],
          identityUserAgent: requestHeaders?['User-Agent'],
          customUserAgent: customUserAgent,
          sendDeviceHeaders: hasDeviceIdentityHeaders(requestHeaders),
        );
        updateProbe?.recordAttempt(host);
        final Response<Uint8List> response;
        try {
          response = await fetchResponse(host, headers: headers);
        } catch (error) {
          if (error is DioException &&
              error.type == DioExceptionType.badResponse) {
            final meta = PanelMeta.fromHeaders(
              error.response?.headers.map ?? const {},
            );
            if (meta.hwidMaxDevicesReached) {
              updateProbe?.recordHwidRejected(host);
              throw ProfilePanelException(meta);
            }
            if (meta.hwidNotSupported) {
              updateProbe?.recordHwidRejected(host);
              panelFailure = ProfilePanelException(meta);
            }
          }
          updateProbe?.recordFailure(
            host,
            SubscriptionUpdateProbe.stageFetch,
            compactError(error),
          );
          if (shouldTryNextSubscriptionClient(error)) {
            lastError = error;
            continue;
          }
          if (!shouldTryFallbackHost(error)) {
            rethrow;
          }
          lastError = error;
          break;
        }
        final identified = identityRejected
            ? _IdentifiedResponse(response: response, headers: headers)
            : await _retryWithDeviceIdentity(
                response,
                host: host,
                headers: headers,
                allowed: allowDeviceIdentityRetry,
                fetch: fetchResponse,
              );
        identityRejected |= identified.identityRejected;
        final data = identified.response.data;
        if (data == null) {
          updateProbe?.recordEmptyResponse(host);
          lastError = const ProfileFetchException.emptyResponse();
          continue;
        }
        try {
          final prepared = await _prepareUpdate(
            identified.response,
            data,
            profileUrl: target,
            sourceUrl: identified.response.realUri.toString(),
            validate: validate,
            workingClient: client,
          );
          final migrated = await _tryDomainMigration(
            prepared,
            primaryUrl: target,
            headers: identified.headers,
            validate: validate,
            inspect: inspect,
            fetch: fetchResponse,
            workingClient: client,
          );
          if (migrated != null) {
            updateProbe?.recordSuccess(host);
            return migrated;
          }
          if (await _isPreparedDialable(prepared, inspect)) {
            updateProbe?.recordSuccess(host);
            return prepared;
          }
          updateProbe?.recordUndialable(host);
          stubFallback ??= prepared;
        } on ProfilePanelException catch (error) {
          if (error.meta.hwidMaxDevicesReached) {
            updateProbe?.recordHwidRejected(host);
            rethrow;
          }
          updateProbe?.recordHwidRejected(host);
          panelFailure = error;
          lastError = error;
        } on ProfileValidationException catch (error) {
          updateProbe?.recordFailure(
            host,
            SubscriptionUpdateProbe.stageParse,
            error.diagnostic,
          );
          lastError = error;
        }
      }
    }
    if (stubFallback != null) {
      // A background refresh that collapses a working config to zero dialable
      // nodes is almost always a broken update (provider mistake, whitelist
      // rotation), not a deliberately empty subscription. Refuse it so the
      // previous config keeps serving instead of stranding the user (#13109).
      if (guardEmptyPlummet && await _currentConfigDialable(inspect)) {
        throw const ProfileEmptyAfterUpdateException();
      }
      return stubFallback.withUndialableNodes();
    }
    if (panelFailure != null) throw panelFailure;
    if (lastError != null) _throwProfileUpdateError(lastError);
    throw const ProfileFetchException.failed();
  }

  Never _throwProfileUpdateError(Object error) {
    if (error is Exception) throw error;
    if (error is Error) throw error;
    throw const ProfileFetchException.failed();
  }

  Future<_IdentifiedResponse> _retryWithDeviceIdentity(
    Response<Uint8List> response, {
    required String host,
    required Map<String, String> headers,
    required bool allowed,
    required FetchProfileResponse fetch,
  }) async {
    if (!allowed ||
        hasDeviceIdentityHeaders(headers) ||
        !PanelMeta.fromHeaders(response.headers.map).hwidNotSupported) {
      return _IdentifiedResponse(response: response, headers: headers);
    }
    final retryHeaders = withDeviceIdentityHeaders(
      headers,
      await deviceIdentity.info,
    );
    final Response<Uint8List> retried;
    try {
      retried = await fetch(host, headers: retryHeaders);
    } catch (error) {
      if (error is DioException && error.type == DioExceptionType.badResponse) {
        rethrow;
      }
      commonPrint.log(
        'subscription device-identity retry skipped: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return _IdentifiedResponse(
        response: response,
        headers: headers,
        identityRejected: true,
      );
    }
    if (retried.data == null) {
      return _IdentifiedResponse(
        response: response,
        headers: headers,
        identityRejected: true,
      );
    }
    return _IdentifiedResponse(
      response: retried,
      headers: retryHeaders,
      identityRejected: PanelMeta.fromHeaders(
        retried.headers.map,
      ).hwidNotSupported,
    );
  }

  Future<PreparedProfileImport?> _tryDomainMigration(
    PreparedProfileImport source, {
    required String primaryUrl,
    required Map<String, String> headers,
    required ValidateConfig validate,
    required InspectConfig inspect,
    required FetchProfileResponse fetch,
    required SubscriptionClient workingClient,
  }) async {
    final candidateUrl = subscriptionDomainCandidate(
      primaryUrl,
      source.profile.panelMeta?.newDomain,
    );
    if (candidateUrl == null) return null;
    try {
      final response = await fetch(candidateUrl, headers: headers);
      final data = response.data;
      if (data == null) return null;
      final prepared = await _prepareUpdate(
        response,
        data,
        profileUrl: candidateUrl,
        sourceUrl: response.realUri.toString(),
        validate: validate,
        workingClient: workingClient,
      );
      return await _isPreparedDialable(prepared, inspect) ? prepared : null;
    } catch (error) {
      commonPrint.log(
        'subscription domain migration skipped: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<bool> _isPreparedDialable(
    PreparedProfileImport prepared,
    InspectConfig inspect,
  ) async {
    final path = await appPath.tempFilePath;
    final file = File(path);
    try {
      await file.safeWriteAsString(prepared.content);
      final inspection = await inspect(path);
      return inspection == null || hasDialableNode(inspection);
    } finally {
      await file.safeDelete();
    }
  }

  // The config already committed on disk. Only reports true when it is present
  // and inspects to at least one dialable node: an absent or unparseable file
  // is nothing worth protecting, so the guard lets such an update through.
  Future<bool> _currentConfigDialable(InspectConfig inspect) async {
    final file = await _getFile(false);
    if (!await file.exists()) return false;
    final inspection = await inspect(file.path);
    return inspection != null && hasDialableNode(inspection);
  }

  Future<void> rememberPreparedHosts(PreparedProfileImport prepared) async {
    if (prepared.responseHeaders.isEmpty) return;
    final primaryUrl = normalizeSubscriptionUrl(url);
    final record = await preferences.getSubscriptionHostRecord();
    await _rememberSpareHosts(
      record: record,
      headers: prepared.responseHeaders,
      primaryUrl: primaryUrl,
      updatedUrl: prepared.profile.url,
    );
  }

  Future<void> _rememberSpareHosts({
    required SubscriptionHostRecord record,
    required Map<String, List<String>> headers,
    required String primaryUrl,
    required String updatedUrl,
  }) async {
    final rotatedHost = updatedUrl == primaryUrl
        ? null
        : Uri.tryParse(primaryUrl)?.host;
    final spares = [
      ...parseFallbackHosts(normalizePanelHeaders(headers)['fallbackHosts']),
      if (rotatedHost != null && rotatedHost.isNotEmpty) rotatedHost,
    ];
    if (spares.isEmpty) return;
    final merged = record.remember(profileId: id, hosts: spares);
    if (merged.hostsFor(id).join(',') == record.hostsFor(id).join(',')) return;
    await preferences.saveSubscriptionHostRecord(merged);
  }

  Future<PreparedProfileImport> _prepareUpdate(
    Response<Uint8List> response,
    Uint8List data, {
    required String profileUrl,
    String? sourceUrl,
    required ValidateConfig validate,
    required SubscriptionClient workingClient,
  }) async {
    final disposition = response.headers.value('content-disposition');
    final userinfo = response.headers.value('subscription-userinfo');
    final panelMeta = PanelMeta.fromHeaders(response.headers.map);
    final capabilityHeader = parseCapabilityManifestHeader(
      response.headers.map,
    );
    final responseUrl = sourceUrl ?? profileUrl;
    final capabilityState = _updatedCapabilityState(
      capabilityHeader,
      sourceHost: Uri.tryParse(responseUrl)?.host ?? '',
    );
    final updateInterval = panelMeta.updateIntervalMinutes;
    final naming = ProfileNaming.fromResponse(
      headers: response.headers.map,
      host: Uri.tryParse(responseUrl)?.host,
      profileTitle: panelMeta.profileTitle,
      dispositionFilename: getFileNameForDisposition(disposition),
    );
    final enrichedMeta = panelMeta.hasContent || naming.username != null
        ? panelMeta.copyWith(accountUsername: naming.username)
        : null;
    final resolvedLabel = userLabel
        ? null
        : naming.label.takeFirstValid([
            getFileNameForDisposition(disposition),
            Uri.tryParse(responseUrl)?.host,
          ]);
    final ({
      String content,
      List<SkippedNode> skipped,
      ProfileImportFormat format,
    })
    validated;
    try {
      validated = await _validatedConfig(
        utf8.decode(data, allowMalformed: true),
        validate: validate,
      );
    } on ProfileValidationException {
      if (panelMeta.hwidMaxDevicesReached || panelMeta.hwidNotSupported) {
        throw ProfilePanelException(panelMeta);
      }
      rethrow;
    }
    final content = validated.content;
    final skipped = validated.skipped;
    return PreparedProfileImport(
      profile: copyWith(
        url: profileUrl,
        label: resolvedLabel ?? label,
        subscriptionInfo: SubscriptionInfo.formHString(userinfo),
        panelMeta: enrichedMeta,
        capabilityManifest: capabilityState.$1,
        capabilityManifestIssue: capabilityState.$2,
        autoUpdateDuration: updateInterval != null
            ? Duration(minutes: updateInterval)
            : autoUpdateDuration,
        lastWorkingClient: clientCompatibility == SubscriptionClient.auto
            ? (workingClient == SubscriptionClient.auto ? null : workingClient)
            : clientCompatibility,
      ),
      content: content,
      skippedNodes: skipped,
      summary: _importSummary(validated.format, content),
      responseHeaders: response.headers.map,
    );
  }

  (ProviderCapabilityManifest?, CapabilityManifestIssue?)
  _updatedCapabilityState(
    CapabilityManifestHeaderResult result, {
    required String sourceHost,
  }) {
    return switch (result) {
      CapabilityManifestHeaderValid(:final claims) => (
        ProviderCapabilityManifest(
          version: 1,
          claims: claims,
          receivedAt: DateTime.now().toUtc(),
          sourceHost: sourceHost,
        ),
        null,
      ),
      CapabilityManifestHeaderAbsent() => (
        capabilityManifest?.copyWith(stale: true),
        null,
      ),
      CapabilityManifestHeaderInvalid() => (
        capabilityManifest,
        CapabilityManifestIssue.invalidHeader,
      ),
    };
  }

  Future<PreparedProfileImport> prepareFile(
    Uint8List bytes, {
    required ValidateConfig validate,
  }) {
    return prepareContent(
      utf8.decode(bytes, allowMalformed: true),
      validate: validate,
    );
  }

  Future<PreparedProfileImport> prepareContent(
    String value, {
    required ValidateConfig validate,
  }) async {
    final validated = await _validatedConfig(value, validate: validate);
    return PreparedProfileImport(
      profile: this,
      content: validated.content,
      skippedNodes: validated.skipped,
      summary: _importSummary(validated.format, validated.content),
    );
  }

  Future<Profile> commitPreparedFile(
    PreparedProfileImport prepared, {
    Future<Profile> Function(Profile profile)? persist,
  }) {
    return _serializeProfileCommit(
      prepared.profile.id,
      () => _commitPreparedFileUnlocked(prepared, persist: persist),
    );
  }

  Future<Profile> _commitPreparedFileUnlocked(
    PreparedProfileImport prepared, {
    Future<Profile> Function(Profile profile)? persist,
  }) async {
    final targetPath = await appPath.getProfilePath(
      prepared.profile.id.toString(),
    );
    final target = File(targetPath);
    await target.parent.create(recursive: true);
    final staged = File(
      join(
        target.parent.path,
        '.${basename(target.path)}.import-$uniqueId.tmp',
      ),
    );
    File? backup;
    try {
      await staged.writeAsString(prepared.content, flush: true);
      if (await target.exists()) {
        backup = File(
          join(
            target.parent.path,
            '.${basename(target.path)}.import-$uniqueId.bak',
          ),
        );
        await target.rename(backup.path);
      }
      try {
        await staged.rename(target.path);
      } catch (error, stackTrace) {
        await _restoreImportBackup(target, backup);
        Error.throwWithStackTrace(error, stackTrace);
      }
      final committed = prepared.profile.copyWith(
        lastUpdateDate: DateTime.now(),
        skippedNodes: prepared.skippedNodes,
        undialableNodes: prepared.undialableNodes,
      );
      if (persist != null) {
        final Profile persisted;
        try {
          persisted = await persist(committed);
        } catch (error, stackTrace) {
          await _restoreImportBackup(target, backup);
          Error.throwWithStackTrace(error, stackTrace);
        }
        await _deleteImportBackup(backup);
        return persisted;
      }
      await _deleteImportBackup(backup);
      return committed;
    } finally {
      await _deleteImportArtifact(staged, 'staging file');
    }
  }

  Future<void> _restoreImportBackup(File target, File? backup) async {
    Object? rollbackError;
    try {
      await target.safeDelete();
    } catch (error) {
      rollbackError = error;
    }
    try {
      if (backup != null && await backup.exists()) {
        await backup.rename(target.path);
      }
    } catch (error) {
      rollbackError ??= error;
    }
    if (rollbackError != null) {
      commonPrint.log(
        'Profile import rollback failed: ${compactError(rollbackError)}',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<void> _deleteImportBackup(File? backup) async {
    if (backup == null) return;
    await _deleteImportArtifact(backup, 'backup');
  }

  Future<void> _deleteImportArtifact(File file, String name) async {
    try {
      await file.safeDelete();
    } catch (error) {
      commonPrint.log(
        'Profile import $name cleanup failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<Profile> saveFile(
    Uint8List bytes, {
    required ValidateConfig validate,
  }) async {
    final prepared = await prepareFile(bytes, validate: validate);
    return commitPreparedFile(prepared);
  }

  Future<Profile> saveFileWithString(
    String value, {
    required ValidateConfig validate,
  }) async {
    final prepared = await prepareContent(value, validate: validate);
    return commitPreparedFile(prepared);
  }

  Future<
    ({String content, List<SkippedNode> skipped, ProfileImportFormat format})
  >
  _validatedConfig(String content, {required ValidateConfig validate}) async {
    final recognized = switch (content) {
      _ when isShareLinkInput(content) => (
        convert: () => tryConvertShareLinks(content),
        format: ProfileImportFormat.shareLinks,
      ),
      _ when isXrayConfigInput(content) => (
        convert: () => tryConvertXrayConfig(content),
        format: ProfileImportFormat.xray,
      ),
      _ when isSingboxConfigInput(content) => (
        convert: () => tryConvertSingboxConfig(content),
        format: ProfileImportFormat.singbox,
      ),
      _ when isWireguardConfInput(content) => (
        convert: () => tryConvertWireguardConf(content),
        format: ProfileImportFormat.wireguard,
      ),
      _ => null,
    };
    if (recognized != null) {
      final converted = recognized.convert();
      if (converted == null) {
        throw const ProfileValidationException(diagnostic: 'invalid config');
      }
      final message = await validateData(converted.config, validate);
      if (message.isEmpty) {
        return (
          content: converted.config,
          skipped: converted.skipped,
          format: recognized.format,
        );
      }
      throw ProfileValidationException(diagnostic: message);
    }

    if (_hasForeignOutbounds(content)) {
      throw const ProfileValidationException(
        diagnostic: 'unrecognized outbound config',
      );
    }
    final message = await validateData(content, validate);
    if (message.isEmpty) {
      return (
        content: content,
        skipped: const <SkippedNode>[],
        format: ProfileImportFormat.clash,
      );
    }

    final converters =
        <
          ({
            ConvertedSubscription? Function() convert,
            ProfileImportFormat format,
          })
        >[
          (
            convert: () => tryConvertShareLinks(content),
            format: ProfileImportFormat.shareLinks,
          ),
          (
            convert: () => tryConvertXrayConfig(content),
            format: ProfileImportFormat.xray,
          ),
          (
            convert: () => tryConvertSingboxConfig(content),
            format: ProfileImportFormat.singbox,
          ),
          (
            convert: () => tryConvertWireguardConf(content),
            format: ProfileImportFormat.wireguard,
          ),
        ];
    for (final converter in converters) {
      final converted = converter.convert();
      if (converted == null) continue;
      final convertedMessage = await validateData(converted.config, validate);
      if (convertedMessage.isEmpty) {
        return (
          content: converted.config,
          skipped: converted.skipped,
          format: converter.format,
        );
      }
    }
    throw ProfileValidationException(
      diagnostic: message.isEmpty ? 'invalid config' : message,
    );
  }

  bool _hasForeignOutbounds(String content) {
    try {
      final decoded = jsonDecode(content);
      return switch (decoded) {
        Map() => decoded.containsKey('outbounds'),
        List() => decoded.any(
          (entry) => entry is Map && entry.containsKey('outbounds'),
        ),
        _ => false,
      };
    } on FormatException {
      return false;
    }
  }

  ProfileImportSummary _importSummary(
    ProfileImportFormat format,
    String content,
  ) {
    try {
      final yaml = loadYaml(content);
      if (yaml is! YamlMap) {
        return ProfileImportSummary(
          format: format,
          nodeCount: 0,
          groupCount: 0,
          hasProviders: false,
        );
      }
      final proxies = yaml['proxies'];
      final groups = yaml['proxy-groups'];
      final providers = yaml['proxy-providers'];
      return ProfileImportSummary(
        format: format,
        nodeCount: proxies is YamlList ? proxies.length : 0,
        groupCount: groups is YamlList ? groups.length : 0,
        hasProviders: providers is YamlMap && providers.isNotEmpty,
      );
    } catch (_) {
      return ProfileImportSummary(
        format: format,
        nodeCount: 0,
        groupCount: 0,
        hasProviders: false,
      );
    }
  }

  Future<String> validateData(String data, ValidateConfig validate) async {
    final path = await appPath.tempFilePath;
    final tempFile = File(path);
    try {
      await tempFile.safeWriteAsString(data);
      return await validate(path);
    } finally {
      await tempFile.safeDelete();
    }
  }
}
