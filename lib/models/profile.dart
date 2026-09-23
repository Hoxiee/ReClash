import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'capability.dart';
import 'clash_config.dart';
import 'core.dart';
import 'panel_meta.dart';

export 'profile_import.dart';

part 'generated/profile.freezed.dart';
part 'generated/profile.g.dart';

typedef ValidateConfig = Future<String> Function(String path);

typedef InspectConfig = Future<ConfigInspection?> Function(String path);

typedef FetchProfileResponse =
    Future<Response<Uint8List>> Function(
      String url, {
      Map<String, String>? headers,
    });

enum ProfileImportFormat { clash, shareLinks, xray, singbox, wireguard }

class ProfileImportSummary {
  const ProfileImportSummary({
    required this.format,
    required this.nodeCount,
    required this.groupCount,
    required this.hasProviders,
  });

  final ProfileImportFormat format;
  final int nodeCount;
  final int groupCount;
  final bool hasProviders;
}

class ProfilePanelException implements Exception {
  const ProfilePanelException(this.meta);

  final PanelMeta meta;

  @override
  String toString() =>
      'The panel returned an unusable subscription with a device restriction';
}

class PreparedProfileImport {
  const PreparedProfileImport({
    required this.profile,
    required this.content,
    required this.skippedNodes,
    required this.summary,
    this.responseHeaders = const {},
    this.undialableNodes = false,
  });

  final Profile profile;
  final String content;
  final List<SkippedNode> skippedNodes;
  final ProfileImportSummary summary;
  final Map<String, List<String>> responseHeaders;
  final bool undialableNodes;

  PreparedProfileImport withUndialableNodes() => PreparedProfileImport(
    profile: profile,
    content: content,
    skippedNodes: skippedNodes,
    summary: summary,
    responseHeaders: responseHeaders,
    undialableNodes: true,
  );
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
    final Map<String, int?> map = {};
    for (final segment in info.split(';')) {
      final separator = segment.indexOf('=');
      if (separator <= 0) continue;
      final key = segment.substring(0, separator).trim();
      final value = segment.substring(separator + 1).trim();
      if (key.isEmpty || value.isEmpty) continue;
      map[key] = int.tryParse(value);
    }
    return SubscriptionInfo(
      upload: map['upload'] ?? 0,
      download: map['download'] ?? 0,
      total: map['total'] ?? 0,
      expire: map['expire'] ?? 0,
    );
  }
}

/// A panel that sells an unlimited plan reports `total=0`, which is not the
/// same as a panel that reports nothing at all.
extension SubscriptionInfoExt on SubscriptionInfo {
  int get used => upload + download;

  bool get unlimited => total <= 0;

  bool get hasFacts =>
      upload != 0 || download != 0 || total != 0 || expire != 0;
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required int id,
    @Default('') String label,
    String? currentGroupName,
    @Default('') String url,
    DateTime? lastUpdateDate,
    DateTime? lastUsedAt,
    required Duration autoUpdateDuration,
    SubscriptionInfo? subscriptionInfo,
    PanelMeta? panelMeta,
    ProviderCapabilityManifest? capabilityManifest,
    @Default([]) List<ServiceRoutePolicy> serviceRoutePolicies,
    @Default([]) List<ManualCapabilitySelector> manualCapabilitySelectors,
    CapabilityManifestIssue? capabilityManifestIssue,
    @Default(true) bool autoUpdate,
    @Default({}) Map<String, String> selectedMap,
    @Default({}) Set<String> unfoldSet,
    @Default(OverwriteType.standard) OverwriteType overwriteType,
    int? scriptId,
    String? matchTarget,
    int? order,
    @JsonKey(name: 'clientEmulation')
    @Default(SubscriptionClient.auto) SubscriptionClient clientCompatibility,
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
    SubscriptionClient clientCompatibility = SubscriptionClient.auto,
    String customUserAgent = '',
  }) {
    final id = snowflake.id;
    return Profile(
      label: label ?? '',
      url: url,
      id: id,
      clientCompatibility: clientCompatibility,
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

// Continuous dust curve shared by the model and the developer preview: amount N
// lands on the discrete level-N step, then creeps to 3.0 near a year of neglect.
double patinaAmountForDays(double days) {
  if (days <= 14) return 0;
  if (days <= 45) return (days - 14) / 31;
  if (days <= 120) return 1 + (days - 45) / 75;
  if (days <= 300) return 2 + (days - 120) / 180;
  return 3;
}

extension ProfilePatinaExt on Profile {
  int patinaLevelAt(DateTime now) {
    final usedAt = lastUsedAt ?? lastUpdateDate;
    if (usedAt == null || usedAt.isAfter(now)) return 0;
    final days = now.difference(usedAt).inDays;
    if (days < 14) return 0;
    if (days < 45) return 1;
    if (days < 120) return 2;
    return 3;
  }

  int get patinaLevel => patinaLevelAt(DateTime.now());

  double patinaAmountAt(DateTime now) {
    final usedAt = lastUsedAt ?? lastUpdateDate;
    if (usedAt == null || usedAt.isAfter(now)) return 0;
    return patinaAmountForDays(now.difference(usedAt).inHours / 24);
  }

  double get patinaAmount => patinaAmountAt(DateTime.now());
}
