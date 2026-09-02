import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'clash_config.dart';
import 'panel_meta.dart';

part 'generated/profile.freezed.dart';
part 'generated/profile.g.dart';

typedef ValidateConfig = Future<String> Function(String path);

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
    @Default([])
    @SkippedNodesConverter()
    List<SkippedNode> skippedNodes,
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
    Map<String, String>? requestHeaders,
  }) async {
    final mFile = await _getFile(false);
    final isExists = await mFile.exists();
    if (isExists || url.isEmpty) {
      return null;
    }
    return update(validate: validate, requestHeaders: requestHeaders);
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
    Map<String, String>? requestHeaders,
  }) async {
    var lastError = 'subscription fetch failed';
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
      final response = await request.getFileResponseForUrl(
        url,
        headers: headers,
      );
      final data = response.data;
      if (data == null) {
        lastError = 'empty response body';
        continue;
      }
      try {
        return await _updateFromResponse(
          response,
          data,
          validate: validate,
          workingClient: candidate,
        );
      } on MessageException catch (e) {
        lastError = e.message;
      }
    }
    throw MessageException(lastError);
  }

  Future<Profile> _updateFromResponse(
    Response<Uint8List> response,
    Uint8List data, {
    required ValidateConfig validate,
    required SubscriptionClient workingClient,
  }) async {
    final disposition = response.headers.value('content-disposition');
    final userinfo = response.headers.value('subscription-userinfo');
    final panelMeta = PanelMeta.fromHeaders(response.headers.map);
    final updateInterval = panelMeta.updateIntervalMinutes;
    var updatedUrl = url;
    final newDomain = panelMeta.newDomain;
    if (newDomain != null && newDomain.isNotEmpty) {
      final currentUri = Uri.tryParse(url);
      if (currentUri != null && currentUri.host != newDomain) {
        updatedUrl = currentUri.replace(host: newDomain).toString();
      }
    }
    return copyWith(
      url: updatedUrl,
      label: label.takeFirstValid([
        getFileNameForDisposition(disposition),
        panelMeta.profileTitle,
        id.toString(),
      ]),
      subscriptionInfo: SubscriptionInfo.formHString(userinfo),
      panelMeta: panelMeta.hasContent ? panelMeta : null,
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
      final convertedMessage = await validateData(
        converted.config,
        validate,
      );
      if (convertedMessage.isEmpty) return (converted.config, converted.skipped);
    }
    throw MessageException(
      message.isEmpty ? 'invalid config' : message,
    );
  }

  Future<String> validateData(
    String data,
    ValidateConfig validate,
  ) async {
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
