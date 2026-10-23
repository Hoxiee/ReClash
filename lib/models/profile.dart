import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/cache.dart';
import 'package:reclash/subscriptions/compatibility/import_policy.dart';
import 'package:reclash/subscriptions/compatibility/prepare.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/transport/header_policy.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import 'clash_config.dart';

part 'generated/profile.freezed.dart';
part 'generated/profile.g.dart';

typedef ValidateConfig =
    Future<String> Function(String path, String ageSecretKey);

typedef DecryptProfilePayload =
    Future<Uint8List> Function(Uint8List bytes, String ageSecretKey);

final _profileMutationQueue = <int, Future<void>>{};

Future<T> serializeProfileMutation<T>(
  int profileId,
  Future<T> Function() action,
) {
  final previous = _profileMutationQueue[profileId] ?? Future<void>.value();
  final run = previous.then((_) => action());
  final release = run.then<void>((_) {}, onError: (Object _) {});
  _profileMutationQueue[profileId] = release;
  unawaited(
    release.then((_) {
      if (identical(_profileMutationQueue[profileId], release)) {
        _profileMutationQueue.remove(profileId);
      }
    }),
  );
  return run;
}

@freezed
abstract class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    @Default(0) int upload,
    @Default(0) int download,
    @Default(0) int total,
    @Default(0) int expire,
  }) = _SubscriptionInfo;

  factory SubscriptionInfo.fromJson(Map<String, Object?> json) =>
      _$SubscriptionInfoFromJson(json);

  factory SubscriptionInfo.formHString(String? info) {
    if (info == null) return const SubscriptionInfo();
    final Map<String, int> map = {};
    for (final field in info.split(';')) {
      final separator = field.indexOf('=');
      if (separator == -1) continue;
      final value = _parseCount(field.substring(separator + 1).trim());
      if (value != null) {
        map[field.substring(0, separator).trim().toLowerCase()] = value;
      }
    }
    return SubscriptionInfo(
      upload: map['upload'] ?? 0,
      download: map['download'] ?? 0,
      total: map['total'] ?? 0,
      expire: map['expire'] ?? 0,
    );
  }

  static int? _parseCount(String value) {
    final count = int.tryParse(value);
    if (count != null) return count;
    final decimal = double.tryParse(value);
    return decimal != null && decimal.isFinite ? decimal.truncate() : null;
  }
}

extension SubscriptionInfoExt on SubscriptionInfo {
  double? get usage =>
      total > 0 ? ((upload + download) / total).clamp(0.0, 1.0) : null;

  DateTime? get expireDate =>
      expire > 0 ? DateTime.fromMillisecondsSinceEpoch(expire * 1000) : null;
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required int id,
    @Default(ProfileType.file) ProfileType type,
    @Default('') String label,
    String? currentGroupName,
    @Default('') String url,
    @Default('') String ageSecretKey,
    DateTime? lastUpdateDate,
    required Duration autoUpdateDuration,
    SubscriptionInfo? subscriptionInfo,
    @Default(SubscriptionPreferences())
    @JsonKey(fromJson: SubscriptionPreferences.safeFromJson)
    SubscriptionPreferences subscriptionPreferences,
    @JsonKey(fromJson: SubscriptionSnapshot.safeFromJson)
    SubscriptionSnapshot? subscriptionSnapshot,
    @Default(true) bool autoUpdate,
    @Default({}) Map<String, String> selectedMap,
    @Default({}) Set<String> unfoldSet,
    @Default(ExtendType.standard) ExtendType extendType,
    int? scriptId,
    String? matchTarget,
    int? order,
    @Default(ProfileOverrides())
    @JsonKey(fromJson: ProfileOverrides.safeFromJson)
    ProfileOverrides overrides,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);

  factory Profile.normal({String? label, String url = ''}) {
    final id = snowflake.id;
    return Profile(
      type: url.isEmpty ? ProfileType.file : ProfileType.url,
      label: label ?? '',
      url: url,
      id: id,
      autoUpdateDuration: defaultUpdateDuration,
      subscriptionPreferences: const SubscriptionPreferences(
        client: SubscriptionClientSettings.forNewProfile(),
      ),
    );
  }

  factory Profile.custom({String? label}) {
    return Profile(
      id: snowflake.id,
      type: ProfileType.custom,
      label: label ?? '',
      lastUpdateDate: DateTime.now(),
      autoUpdate: false,
      autoUpdateDuration: defaultUpdateDuration,
    );
  }
}

/// A profile leaving out one of the global rules its extension would add.
@freezed
abstract class DisabledRule with _$DisabledRule {
  const factory DisabledRule({required int profileId, required int ruleId}) =
      _DisabledRule;
}

extension ProfilesExt on List<Profile> {
  Profile? getProfile(int? profileId) {
    final index = indexWhere((profile) => profile.id == profileId);
    return index == -1 ? null : this[index];
  }

  Profile optimizeLabel(Profile profile) {
    return profile.copyWith(
      label: uniqueLabelFor(
        profile.label,
        fallback: profile.defaultLabel,
        taken: (label) =>
            any((item) => item.label == label && item.id != profile.id),
      ),
    );
  }
}

class PreparedSubscriptionUpdate {
  const PreparedSubscriptionUpdate({
    required this.profileId,
    required this.sourceUrl,
    required this.sourceAgeSecretKey,
    required this.sourcePreferences,
    required this.payload,
    required this.metadata,
    required this.subscriptionInfo,
    required this.snapshot,
    required this.label,
    required this.client,
    this.clientFingerprint = '',
    this.routingBundle,
    this.migratedUrl,
  });

  final int profileId;
  final String sourceUrl;
  final String sourceAgeSecretKey;
  final SubscriptionPreferences sourcePreferences;
  final SubscriptionImportResult payload;
  final SubscriptionMetadataResult metadata;
  final SubscriptionInfo? subscriptionInfo;
  final SubscriptionSnapshot snapshot;
  final String label;
  final SubscriptionClientPreset client;
  final String clientFingerprint;
  final String? routingBundle;

  /// The subscription URL the profile moves to once this update commits.
  final String? migratedUrl;

  SubscriptionImportSummary get summary => payload.summary;

  PreparedSubscriptionUpdate copyWithUrl(String url) =>
      PreparedSubscriptionUpdate(
        profileId: profileId,
        sourceUrl: sourceUrl,
        sourceAgeSecretKey: sourceAgeSecretKey,
        sourcePreferences: sourcePreferences,
        payload: payload,
        metadata: metadata,
        subscriptionInfo: subscriptionInfo,
        snapshot: snapshot,
        label: label,
        client: client,
        clientFingerprint: clientFingerprint,
        routingBundle: routingBundle,
        migratedUrl: url,
      );
}

class SubscriptionUpdateCancelled implements Exception {
  const SubscriptionUpdateCancelled();

  @override
  String toString() => 'Subscription update cancelled';
}

class SubscriptionUpdateSuperseded implements Exception {
  const SubscriptionUpdateSuperseded();

  @override
  String toString() =>
      'Profile changed before the subscription update committed';
}

class SubscriptionUpdateRejected implements Exception {
  const SubscriptionUpdateRejected(this.reason);
  final SubscriptionRetryReason reason;

  @override
  String toString() => 'Subscription update failed (${reason.name})';
}

/// Failures another host of the same provider may not share.
bool _hostCanBeReplaced(SubscriptionRetryReason reason) => switch (reason) {
  SubscriptionRetryReason.transport ||
  SubscriptionRetryReason.timeout ||
  SubscriptionRetryReason.tls ||
  SubscriptionRetryReason.rateLimited ||
  SubscriptionRetryReason.invalidResponse => true,
  _ => false,
};

Uri? _withAuthority(Uri uri, String authority) {
  final colon = authority.lastIndexOf(':');
  final port = colon == -1
      ? null
      : int.tryParse(authority.substring(colon + 1));
  final host = colon == -1 ? authority : authority.substring(0, colon);
  if (host.isEmpty || (colon != -1 && port == null)) return null;
  return Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: host,
    port: port,
    path: uri.path,
    query: uri.hasQuery ? uri.query : null,
  );
}

bool _looksLikeAgeEncrypted(Uint8List bytes) {
  const prefix = '-----BEGIN AGE ENCRYPTED FILE-----';
  if (bytes.length < prefix.length) return false;
  for (var index = 0; index < prefix.length; index++) {
    if (bytes[index] != prefix.codeUnitAt(index)) return false;
  }
  return true;
}

SubscriptionInfo? _mergeSubscriptionInfo(
  SubscriptionInfo? previous,
  SubscriptionMetadata incoming,
) {
  const usageFields = {
    'subscription.upload',
    'subscription.download',
    'subscription.total',
    'subscription.expire',
  };
  if (!incoming.fields.keys.any(usageFields.contains)) return previous;
  return SubscriptionInfo(
    upload: incoming.count('subscription.upload') ?? previous?.upload ?? 0,
    download:
        incoming.count('subscription.download') ?? previous?.download ?? 0,
    total: incoming.count('subscription.total') ?? previous?.total ?? 0,
    expire: incoming.count('subscription.expire') ?? previous?.expire ?? 0,
  );
}

SubscriptionRetryReason _retryReason(SubscriptionException error) {
  if (error.failure == SubscriptionFailure.http &&
      (error.status == 406 || error.status == 415)) {
    return SubscriptionRetryReason.unsupportedMediaType;
  }
  return switch (error.failure) {
    SubscriptionFailure.cancelled ||
    SubscriptionFailure.superseded => SubscriptionRetryReason.cancelled,
    SubscriptionFailure.timeout => SubscriptionRetryReason.timeout,
    SubscriptionFailure.transport => SubscriptionRetryReason.transport,
    SubscriptionFailure.tls => SubscriptionRetryReason.tls,
    SubscriptionFailure.unauthorized =>
      error.status == 403
          ? SubscriptionRetryReason.forbidden
          : SubscriptionRetryReason.unauthorized,
    SubscriptionFailure.rateLimited => SubscriptionRetryReason.rateLimited,
    SubscriptionFailure.deviceRequired =>
      SubscriptionRetryReason.deviceConsentRequired,
    SubscriptionFailure.deviceLimit =>
      SubscriptionRetryReason.deviceLimitReached,
    SubscriptionFailure.http ||
    SubscriptionFailure.redirect ||
    SubscriptionFailure.oversized ||
    SubscriptionFailure.invalid ||
    SubscriptionFailure.empty => SubscriptionRetryReason.invalidResponse,
  };
}

extension ProfileExtension on Profile {
  bool get realAutoUpdate => type == ProfileType.url && autoUpdate;

  String get realLabel => label.takeFirstValid([defaultLabel]);

  String get defaultLabel => url.webUri?.host ?? id.toString();

  String get fileName => '$id.yaml';

  String get exportFileName {
    final label = realLabel;
    final lower = label.toLowerCase();
    if (lower.endsWith('.yaml') || lower.endsWith('.yml')) {
      return label;
    }
    return '$label.yaml';
  }

  String get updatingKey => 'profile_$id';

  Future<Profile?> checkAndUpdateAndCopy({
    required ValidateConfig validate,
    required String defaultUserAgent,
    DecryptProfilePayload? decrypt,
  }) async {
    if (type != ProfileType.url) {
      return null;
    }
    final mFile = await _getFile(false);
    if (await mFile.exists()) {
      return null;
    }
    return update(
      validate: validate,
      defaultUserAgent: defaultUserAgent,
      decrypt: decrypt,
    );
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

  Future<File> get file async => _getFile();

  Future<PreparedSubscriptionUpdate> prepareUpdate({
    required String defaultUserAgent,
    SubscriptionTransport? transport,
    SubscriptionCancellation? cancellation,
    Map<String, String> identityHeaders = const {},
    DecryptProfilePayload? decrypt,
    ValidateConfig? validate,
    String? locale,
  }) async {
    if (type != ProfileType.url) {
      throw StateError('Only URL profiles can be updated');
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.host.isEmpty ||
        !const {'http', 'https'}.contains(uri.scheme.toLowerCase())) {
      throw const SubscriptionException(SubscriptionFailure.invalid);
    }
    Future<PreparedSubscriptionUpdate> prepareAt(Uri source) => _prepareAt(
      source,
      defaultUserAgent: defaultUserAgent,
      transport: transport,
      cancellation: cancellation,
      identityHeaders: identityHeaders,
      decrypt: decrypt,
      validate: validate,
      locale: locale,
    );
    final stored = subscriptionSnapshot?.metadata;
    final hosts = uri.scheme == 'https'
        ? [
            ...?stored?.strings('transport.newDomain'),
            ...?stored?.strings('transport.fallbackHosts'),
          ]
        : const <String>[];
    PreparedSubscriptionUpdate prepared;
    try {
      prepared = await prepareAt(uri);
    } on SubscriptionUpdateRejected catch (error) {
      if (!_hostCanBeReplaced(error.reason)) rethrow;
      PreparedSubscriptionUpdate? served;
      for (final host in hosts) {
        final candidate = _withAuthority(uri, host);
        if (candidate == null || candidate.authority == uri.authority) continue;
        try {
          served = await prepareAt(candidate);
          break;
        } on SubscriptionUpdateRejected catch (fallback) {
          if (!_hostCanBeReplaced(fallback.reason)) rethrow;
        }
      }
      if (served == null) rethrow;
      prepared = served;
    }
    final target = uri.scheme == 'https'
        ? prepared.metadata.metadata.strings('transport.newDomain').firstOrNull
        : null;
    final moved = target == null ? null : _withAuthority(uri, target);
    if (moved == null || moved.authority == uri.authority) return prepared;
    try {
      return (await prepareAt(moved)).copyWithUrl(moved.toString());
    } on SubscriptionUpdateRejected {
      return prepared;
    }
  }

  Future<PreparedSubscriptionUpdate> _prepareAt(
    Uri uri, {
    required String defaultUserAgent,
    SubscriptionTransport? transport,
    SubscriptionCancellation? cancellation,
    Map<String, String> identityHeaders = const {},
    DecryptProfilePayload? decrypt,
    ValidateConfig? validate,
    String? locale,
  }) async {
    final preferences = subscriptionPreferences;
    if (!preferences.client.isValid) {
      throw const SubscriptionUpdateRejected(
        SubscriptionRetryReason.invalidResponse,
      );
    }
    final requestFingerprint = subscriptionClientRequestFingerprint(
      url: url,
      ageSecretKey: ageSecretKey,
      preferences: preferences.toJson(),
      defaultUserAgent: defaultUserAgent,
      managedHeaders: identityHeaders,
      locale: locale,
    );
    final lastSuccessful = await const SubscriptionClientCache().read(
      id,
      subscriptionClientCacheKey(
        requestFingerprint,
        preferences.client.importPolicy.toJson(),
      ),
    );
    final attempts = subscriptionClientAttempts(
      selected: preferences.client.preset,
      defaultUserAgent: defaultUserAgent,
      lastSuccessful: lastSuccessful,
      locale: locale,
    );
    final fetcher = transport ?? SubscriptionTransport();
    final negotiation =
        await negotiateSubscriptionClients<PreparedSubscriptionUpdate>(
          attempts: attempts,
          isCancelled: () => cancellation?.cancelled ?? false,
          cancellationSignal: cancellation?.whenCancelled,
          runAttempt: (preset, timeout, attemptCancellation) async {
            final requestCancellation = SubscriptionCancellation();
            unawaited(
              attemptCancellation.whenCancelled.then(
                (_) => requestCancellation.cancel(),
              ),
            );
            if (cancellation != null) {
              unawaited(
                cancellation.whenCancelled.then(
                  (_) => requestCancellation.cancel(),
                ),
              );
            }
            try {
              final clientHeaders = subscriptionClientRequestHeaders(
                preset,
                defaultUserAgent: defaultUserAgent,
                customUserAgent: preferences.client.customUserAgent,
                locale: locale,
              );
              final headers = overlaySubscriptionHeaders(clientHeaders, {
                ...preferences.headers,
                ...identityHeaders,
              }, allowManaged: true);
              final response = await fetcher.fetch(
                uri,
                headers: headers,
                timeout: timeout,
                cancellation: requestCancellation,
              );
              var content = response.bytes;
              if (_looksLikeAgeEncrypted(content)) {
                if (ageSecretKey.isEmpty) {
                  throw const AgeSecretKeyRequiredException();
                }
                if (decrypt == null) {
                  throw const SubscriptionUpdateRejected(
                    SubscriptionRetryReason.invalidResponse,
                  );
                }
                content = await decrypt(content, ageSecretKey);
              }
              if (requestCancellation.cancelled) {
                throw const SubscriptionUpdateCancelled();
              }
              final body = utf8.decode(content, allowMalformed: true);
              if (body.trim().isEmpty) {
                return const SubscriptionClientRejected(
                  SubscriptionRetryReason.invalidResponse,
                );
              }
              final payload = await prepareSubscriptionImport(content);
              final decodedMetadata = withConfigPackages(
                readSubscriptionMetadata(
                  response.headers,
                  body: body,
                  clientPreset: preset,
                ),
                excluded: payload.summary.excludedPackages,
                included: payload.summary.includedPackages,
              );
              if (payload.summary.rejectCoreFallback ||
                  payload.format == SubscriptionFormat.unknown) {
                return const SubscriptionClientRejected(
                  SubscriptionRetryReason.incompatibleResponse,
                );
              }
              if (payload.summary.nodes == 0 &&
                  payload.summary.groups == 0 &&
                  payload.summary.remoteProviders == 0) {
                return const SubscriptionClientRejected(
                  SubscriptionRetryReason.invalidResponse,
                );
              }
              if (validate != null) {
                await validateSubscriptionImport(
                  payload,
                  validate: validate,
                  isCancelled: () => requestCancellation.cancelled,
                );
              }
              final previous = subscriptionSnapshot;
              final staleFields = [
                for (final key
                    in previous?.metadata.fields.keys ?? const <String>[])
                  if (!decodedMetadata.metadata.fields.containsKey(key)) key,
              ];
              final mergedMetadata =
                  (previous?.metadata ?? const SubscriptionMetadata()).merge(
                    decodedMetadata.metadata,
                  );
              final snapshot = SubscriptionSnapshot(
                metadata: mergedMetadata,
                receivedAt: DateTime.now().toUtc(),
                stale: staleFields.isNotEmpty,
                staleFields: staleFields,
                source: decodedMetadata.source,
                deviceStatus: decodedMetadata.deviceStatus,
                warnings: decodedMetadata.warnings,
              );
              final info = _mergeSubscriptionInfo(
                subscriptionInfo,
                decodedMetadata.metadata,
              );
              final bundleUrl = decodedMetadata.metadata.text(
                'routing.bundleUrl',
              );
              final routingBundle = bundleUrl == null
                  ? null
                  : await _fetchRoutingBundle(
                      fetcher,
                      bundleUrl,
                      subscription: uri,
                      headers: headers,
                      timeout: timeout,
                      cancellation: requestCancellation,
                    );
              if (requestCancellation.cancelled) {
                throw const SubscriptionUpdateCancelled();
              }
              final disposition =
                  response.headers['content-disposition']?.singleOrNull;
              final resolvedLabel = label.takeFirstValid([
                getFileNameForDisposition(disposition),
                decodedMetadata.metadata.accountTitle,
                decodedMetadata.metadata.name,
                defaultLabel,
              ]);
              return SubscriptionClientReady(
                PreparedSubscriptionUpdate(
                  profileId: id,
                  sourceUrl: url,
                  sourceAgeSecretKey: ageSecretKey,
                  sourcePreferences: preferences,
                  payload: payload,
                  metadata: decodedMetadata,
                  subscriptionInfo: info,
                  snapshot: snapshot,
                  label: resolvedLabel,
                  client: preset,
                  clientFingerprint: requestFingerprint,
                  routingBundle: routingBundle,
                ),
                requiresReview:
                    payload.summary.hasLosses &&
                    !preferences.client.importPolicy.allows(
                      payload.format,
                      payload.summary,
                      sourceScope: subscriptionImportScope(url, ageSecretKey),
                    ),
              );
            } on SubscriptionException catch (error) {
              return SubscriptionClientRejected(_retryReason(error));
            } on SubscriptionImportException {
              return const SubscriptionClientRejected(
                SubscriptionRetryReason.invalidResponse,
              );
            } on SubscriptionHeaderException {
              return const SubscriptionClientRejected(
                SubscriptionRetryReason.invalidResponse,
              );
            } on FormatException {
              return const SubscriptionClientRejected(
                SubscriptionRetryReason.invalidResponse,
              );
            }
          },
        );
    return switch (negotiation) {
      SubscriptionNegotiationReady(:final value) => value,
      SubscriptionNegotiationFailed(:final reason)
          when reason == SubscriptionRetryReason.cancelled =>
        throw const SubscriptionUpdateCancelled(),
      SubscriptionNegotiationFailed(:final reason) =>
        throw SubscriptionUpdateRejected(reason),
    };
  }

  Future<Profile> commitPreparedUpdate(
    PreparedSubscriptionUpdate prepared, {
    required ValidateConfig validate,
    bool acceptLosses = false,
    bool allowProviderLabel = false,
    SubscriptionImportPolicy? importPolicy,
    bool Function()? isCurrent,
    Future<void> Function(Profile saved)? onCommitted,
  }) async {
    if (prepared.profileId != id ||
        prepared.sourceUrl != url ||
        prepared.sourceAgeSecretKey != ageSecretKey ||
        jsonEncode(prepared.sourcePreferences.toJson()) !=
            jsonEncode(subscriptionPreferences.toJson())) {
      throw const SubscriptionUpdateSuperseded();
    }
    final policy = importPolicy ?? subscriptionPreferences.client.importPolicy;
    if (prepared.summary.hasLosses &&
        !acceptLosses &&
        !policy.allows(
          prepared.payload.format,
          prepared.summary,
          sourceScope: subscriptionImportScope(url, ageSecretKey),
        )) {
      throw const SubscriptionUpdateCancelled();
    }
    final hintedInterval = subscriptionPreferences.intervalOverride
        ? null
        : prepared.metadata.metadata.count('update.intervalMinutes');
    final saved =
        await copyWith(
          url: prepared.migratedUrl ?? url,
          subscriptionPreferences: importPolicy == null
              ? subscriptionPreferences
              : subscriptionPreferences.copyWith(
                  client: subscriptionPreferences.client.copyWith(
                    importPolicy: importPolicy,
                  ),
                ),
          label: allowProviderLabel
              ? label.takeFirstValid([prepared.label])
              : label,
          subscriptionInfo: prepared.subscriptionInfo,
          subscriptionSnapshot: prepared.snapshot,
          autoUpdateDuration: hintedInterval == null
              ? autoUpdateDuration
              : Duration(minutes: hintedInterval),
        ).saveFile(
          prepared.payload.bytes,
          validate: validate,
          isCurrent: isCurrent,
          onCommitted: (saved) async {
            await onCommitted?.call(saved);
            if (prepared.clientFingerprint.isNotEmpty) {
              await const SubscriptionClientCache().remember(
                id,
                subscriptionClientCacheKey(
                  prepared.clientFingerprint,
                  saved.subscriptionPreferences.client.importPolicy.toJson(),
                ),
                prepared.client,
              );
            }
          },
        );
    await _storeRoutingBundle(prepared.routingBundle);
    return saved;
  }

  Future<void> _storeRoutingBundle(String? bundle) async {
    if (bundle == null) return;
    try {
      await serializeProfileMutation(
        id,
        () async => File(
          await appPath.getProfileRoutingPath(id.toString()),
        ).writeAsStringAtomically(bundle),
      );
    } on Object catch (error) {
      commonPrint.log(
        'Could not store the routing bundle: $error',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<Profile> update({
    required ValidateConfig validate,
    required String defaultUserAgent,
    Future<bool> Function(PreparedSubscriptionUpdate prepared)? approveLosses,
    SubscriptionTransport? transport,
    SubscriptionCancellation? cancellation,
    Map<String, String> identityHeaders = const {},
    DecryptProfilePayload? decrypt,
  }) async {
    final prepared = await prepareUpdate(
      defaultUserAgent: defaultUserAgent,
      transport: transport,
      cancellation: cancellation,
      identityHeaders: identityHeaders,
      decrypt: decrypt,
      validate: validate,
    );
    final accepted =
        !prepared.summary.hasLosses ||
        subscriptionPreferences.client.importPolicy.allows(
          prepared.payload.format,
          prepared.summary,
          sourceScope: subscriptionImportScope(url, ageSecretKey),
        ) ||
        approveLosses != null && await approveLosses(prepared);
    if (!accepted) throw const SubscriptionUpdateCancelled();
    return commitPreparedUpdate(
      prepared,
      validate: validate,
      acceptLosses: prepared.summary.hasLosses,
      allowProviderLabel: true,
    );
  }

  Future<Profile> saveFile(
    Uint8List bytes, {
    required ValidateConfig validate,
    bool Function()? isCurrent,
    Future<void> Function(Profile saved)? onCommitted,
  }) async {
    final path = await appPath.tempFilePath;
    final tempFile = File('$path.$id.${DateTime.now().microsecondsSinceEpoch}');
    await tempFile.safeWriteAsBytes(bytes);
    try {
      final message = await validate(tempFile.path, ageSecretKey);
      if (message.isNotEmpty) throw MessageException(message);
      final candidate = await tempFile.readAsBytes();
      return await serializeProfileMutation(id, () async {
        void ensureCurrent() {
          if (isCurrent != null && !isCurrent()) {
            throw const SubscriptionUpdateSuperseded();
          }
        }

        ensureCurrent();
        final target = await _getFile(false);
        final staged = File('${target.path}.staged');
        final backup = File('${target.path}.previous');
        ensureCurrent();
        await target.parent.create(recursive: true);
        if (!await target.exists() && await backup.exists()) {
          await backup.rename(target.path);
        } else if (await target.exists() && await backup.exists()) {
          await backup.safeDelete();
        }
        await staged.safeDelete();
        try {
          await staged.safeWriteAsBytes(candidate);
          final hadTarget = await target.exists();
          ensureCurrent();
          if (hadTarget) await target.rename(backup.path);
          final saved = copyWith(lastUpdateDate: DateTime.now());
          try {
            ensureCurrent();
            await staged.rename(target.path);
            ensureCurrent();
            await onCommitted?.call(saved);
          } on Object {
            if (await backup.exists()) {
              await target.safeDelete();
              await backup.rename(target.path);
            } else {
              await target.safeDelete();
            }
            rethrow;
          }
          if (hadTarget) {
            try {
              await backup.safeDelete();
            } on FileSystemException {
              commonPrint.log('Could not remove the previous profile file');
            }
          }
          return saved;
        } finally {
          await staged.safeDelete();
        }
      });
    } finally {
      await tempFile.safeDelete();
    }
  }
}

const routingBundleMaxBytes = 256 * 1024;

Future<String?> _fetchRoutingBundle(
  SubscriptionTransport fetcher,
  String bundleUrl, {
  required Uri subscription,
  required Map<String, String> headers,
  required Duration timeout,
  required SubscriptionCancellation cancellation,
}) async {
  try {
    final uri = Uri.tryParse(bundleUrl.trim());
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        scheme != 'https' &&
            !(scheme == 'http' &&
                subscription.scheme.toLowerCase() == 'http')) {
      throw const FormatException('unsupported routing bundle URL');
    }
    final response = await fetcher.fetch(
      uri,
      headers: headers,
      timeout: timeout,
      cancellation: cancellation,
    );
    if (response.bytes.length > routingBundleMaxBytes) {
      throw const FormatException('routing bundle is too large');
    }
    final text = utf8.decode(response.bytes);
    if (text.trim().isEmpty) throw const FormatException('empty bundle');
    return text;
  } on Object catch (error) {
    if (!cancellation.cancelled) {
      commonPrint.log(
        'Could not download the routing bundle: $error',
        logLevel: LogLevel.warning,
      );
    }
    return null;
  }
}
