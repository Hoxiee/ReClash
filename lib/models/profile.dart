import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'clash_config.dart';
import 'core.dart';
import 'panel_headers.dart';
import 'panel_meta.dart';

part 'generated/profile.freezed.dart';
part 'generated/profile.g.dart';

typedef ValidateConfig = Future<String> Function(String path);

typedef InspectConfig = Future<ConfigInspection?> Function(String path);

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
    final list = info.split(';');
    final Map<String, int?> map = {};
    for (final i in list) {
      final keyValue = i.trim().split('=');
      map[keyValue[0]] = int.tryParse(keyValue[1]);
    }
    return SubscriptionInfo(
      upload: map['upload'] ?? 0,
      download: map['download'] ?? 0,
      total: map['total'] ?? 0,
      expire: map['expire'] ?? 0,
    );
  }
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required int id,
    @Default('') String label,
    String? currentGroupName,
    @Default('') String url,
    DateTime? lastUpdateDate,
    required Duration autoUpdateDuration,
    SubscriptionInfo? subscriptionInfo,
    PanelMeta? panelMeta,
    @Default(true) bool autoUpdate,
    @Default({}) Map<String, String> selectedMap,
    @Default({}) Set<String> unfoldSet,
    @Default(OverwriteType.standard) OverwriteType overwriteType,
    int? scriptId,
    String? matchTarget,
    int? order,
    @Default(SubscriptionClient.auto) SubscriptionClient clientEmulation,
    @Default('') String customUserAgent,
    @JsonKey(includeToJson: false, includeFromJson: false)
    SubscriptionClient? lastWorkingClient,
    @Default([]) @SkippedNodesConverter() List<SkippedNode> skippedNodes,
    @Default(false) bool undialableNodes,
    @Default(false) bool userLabel,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);

  factory Profile.normal({
    String? label,
    String url = '',
    SubscriptionClient clientEmulation = SubscriptionClient.auto,
    String customUserAgent = '',
  }) {
    final id = snowflake.id;
    return Profile(
      label: label ?? '',
      url: url,
      id: id,
      clientEmulation: clientEmulation,
      customUserAgent: customUserAgent,
      autoUpdateDuration: defaultUpdateDuration,
    );
  }
}

@freezed
abstract class ProfileRuleLink with _$ProfileRuleLink {
  const factory ProfileRuleLink({
    int? profileId,
    required int ruleId,
    RuleScene? scene,
    String? order,
  }) = _ProfileRuleLink;
}

extension ProfileRuleLinkExt on ProfileRuleLink {
  String get key {
    final splits = <String?>[
      profileId?.toString(),
      ruleId.toString(),
      scene?.name,
    ];
    return splits.where((item) => item != null).join('_');
  }
}

@freezed
abstract class StandardOverwrite with _$StandardOverwrite {
  const factory StandardOverwrite({
    @Default([]) List<Rule> addedRules,
    @Default([]) List<int> disabledRuleIds,
  }) = _StandardOverwrite;

  factory StandardOverwrite.fromJson(Map<String, Object?> json) =>
      _$StandardOverwriteFromJson(json);
}

@freezed
abstract class ScriptOverwrite with _$ScriptOverwrite {
  const factory ScriptOverwrite({int? scriptId}) = _ScriptOverwrite;

  factory ScriptOverwrite.fromJson(Map<String, Object?> json) =>
      _$ScriptOverwriteFromJson(json);
}

extension ProfilesExt on List<Profile> {
  Profile? getProfile(int? profileId) {
    final index = indexWhere((profile) => profile.id == profileId);
    return index == -1 ? null : this[index];
  }

  String _getLabel(String label, int id) {
    final realLabel = label.takeFirstValid([id.toString()]);
    final hasDup =
        indexWhere(
          (element) => element.label == realLabel && element.id != id,
        ) !=
        -1;
    if (hasDup) {
      return _getLabel(getOverwriteLabel(realLabel), id);
    } else {
      return realLabel;
    }
  }

  Profile optimizeLabel(Profile profile) {
    return profile.copyWith(label: _getLabel(profile.label, profile.id));
  }
}

extension ProfileExtension on Profile {
  ProfileType get type =>
      url.isEmpty == true ? ProfileType.file : ProfileType.url;

  bool get realAutoUpdate => url.isEmpty == true ? false : autoUpdate;

  String get realLabel => label.takeFirstValid([id.toString()]);

  String get fileName => '$id.yaml';

  String get updatingKey => 'profile_$id';

  Future<Profile?> checkAndUpdateAndCopy({
    required ValidateConfig validate,
    required InspectConfig inspect,
    Map<String, String>? requestHeaders,
  }) async {
    final mFile = await _getFile(false);
    final isExists = await mFile.exists();
    if (isExists || url.isEmpty) {
      return null;
    }
    return update(
      validate: validate,
      inspect: inspect,
      requestHeaders: requestHeaders,
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

  Future<File> get file async {
    return _getFile();
  }

  Future<Profile> update({
    required ValidateConfig validate,
    required InspectConfig inspect,
    Map<String, String>? requestHeaders,
  }) async {
    final target = normalizeSubscriptionUrl(url);
    final record = await preferences.getSubscriptionHostRecord();
    var lastError = 'subscription fetch failed';
    // A payload that parses but carries no dialable node is a panel stub; the
    // first parsed one is still better than nothing when probing runs dry.
    (Profile, Map<String, List<String>>)? stubFallback;
    for (final host in subscriptionUrlCandidates(target, record.hostsFor(id))) {
      for (final candidate in probeOrder(
        clientEmulation,
        lastWorking: lastWorkingClient,
      )) {
        final headers = buildSubscriptionHeaders(
          candidate,
          deviceDetails: await deviceIdentity.info,
          defaultUa: requestHeaders?['User-Agent'],
          identityUserAgent: requestHeaders?['User-Agent'],
          customUserAgent: customUserAgent,
          sendDeviceHeaders: requestHeaders != null,
        );
        final Response<Uint8List> response;
        try {
          response = await request.getFileResponseForUrl(
            host,
            headers: headers,
          );
        } catch (error) {
          if (!shouldTryFallbackHost(error)) {
            rethrow;
          }
          lastError = compactError(error);
          break;
        }
        final data = response.data;
        if (data == null) {
          lastError = 'empty response body';
          continue;
        }
        try {
          final updated = await _updateFromResponse(
            response,
            data,
            primaryUrl: target,
            validate: validate,
            workingClient: candidate,
          );
          if (await _isDialable(inspect)) {
            await _rememberSpareHosts(
              record: record,
              headers: response.headers.map,
              primaryUrl: target,
              updatedUrl: updated.url,
            );
            return updated.copyWith(undialableNodes: false);
          }
          stubFallback ??= (updated, response.headers.map);
          lastError = 'subscription returned no dialable nodes';
        } on MessageException catch (e) {
          lastError = e.message;
        }
      }
    }
    final stub = stubFallback?.$1;
    if (stub != null) {
      await _rememberSpareHosts(
        record: record,
        headers: stubFallback!.$2,
        primaryUrl: target,
        updatedUrl: stub.url,
      );
      return stub.copyWith(undialableNodes: true);
    }
    throw MessageException(lastError);
  }

  Future<bool> _isDialable(InspectConfig inspect) async {
    final file = await _getFile(false);
    final inspection = await inspect(file.path);
    return inspection == null || hasDialableNode(inspection);
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

  Future<Profile> _updateFromResponse(
    Response<Uint8List> response,
    Uint8List data, {
    required String primaryUrl,
    required ValidateConfig validate,
    required SubscriptionClient workingClient,
  }) async {
    final disposition = response.headers.value('content-disposition');
    final userinfo = response.headers.value('subscription-userinfo');
    final panelMeta = PanelMeta.fromHeaders(response.headers.map);
    final updateInterval = panelMeta.updateIntervalMinutes;
    var updatedUrl = primaryUrl;
    final newDomain = panelMeta.newDomain;
    if (newDomain != null && newDomain.isNotEmpty) {
      final currentUri = Uri.tryParse(primaryUrl);
      if (currentUri != null && currentUri.host != newDomain) {
        updatedUrl = currentUri.replace(host: newDomain).toString();
      }
    }
    final naming = ProfileNaming.fromResponse(
      headers: response.headers.map,
      host: Uri.tryParse(primaryUrl)?.host,
      profileTitle: panelMeta.profileTitle,
      dispositionFilename: getFileNameForDisposition(disposition),
    );
    final enrichedMeta = panelMeta.hasContent || naming.username != null
        ? panelMeta.copyWith(accountUsername: naming.username)
        : null;
    // A hand-set name wins forever; only panel-derived labels track the wire.
    final resolvedLabel = userLabel
        ? null
        : naming.label.takeFirstValid([
            getFileNameForDisposition(disposition),
            Uri.tryParse(primaryUrl)?.host,
          ]);
    return copyWith(
      url: updatedUrl,
      label: resolvedLabel ?? label,
      subscriptionInfo: SubscriptionInfo.formHString(userinfo),
      panelMeta: enrichedMeta,
      autoUpdateDuration: updateInterval != null
          ? Duration(minutes: updateInterval)
          : autoUpdateDuration,
      lastWorkingClient: clientEmulation == SubscriptionClient.auto
          ? workingClient
          : clientEmulation,
    ).saveFile(data, validate: validate);
  }

  Future<Profile> saveFile(
    Uint8List bytes, {
    required ValidateConfig validate,
  }) async {
    final (content, skipped) = await _validatedConfig(
      utf8.decode(bytes, allowMalformed: true),
      validate: validate,
    );
    final path = await appPath.tempFilePath;
    final tempFile = File(path);
    await tempFile.safeWriteAsString(content);
    final message = await validate(path);
    if (message.isNotEmpty) {
      throw MessageException(message);
    }
    final mFile = await file;
    await tempFile.copy(mFile.path);
    await tempFile.safeDelete();
    return copyWith(lastUpdateDate: DateTime.now(), skippedNodes: skipped);
  }

  Future<Profile> saveFileWithString(
    String value, {
    required ValidateConfig validate,
  }) async {
    final (content, skipped) = await _validatedConfig(
      value,
      validate: validate,
    );
    final path = await appPath.tempFilePath;
    final tempFile = File(path);
    await tempFile.safeWriteAsString(content);
    final message = await validate(path);
    if (message.isNotEmpty) {
      throw MessageException(message);
    }
    final mFile = await file;
    await tempFile.copy(mFile.path);
    await tempFile.safeDelete();
    return copyWith(lastUpdateDate: DateTime.now(), skippedNodes: skipped);
  }

  Future<(String, List<SkippedNode>)> _validatedConfig(
    String content, {
    required ValidateConfig validate,
  }) async {
    final message = await validateData(content, validate);
    if (message.isEmpty) return (content, const <SkippedNode>[]);

    final converters = <ConvertedSubscription? Function()>[
      () => tryConvertShareLinks(content),
      () => tryConvertXrayConfig(content),
      () => tryConvertSingboxConfig(content),
    ];
    for (final convert in converters) {
      final converted = convert();
      if (converted == null) continue;
      final convertedMessage = await validateData(converted.config, validate);
      if (convertedMessage.isEmpty) {
        return (converted.config, converted.skipped);
      }
    }
    throw MessageException(message.isEmpty ? 'invalid config' : message);
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
