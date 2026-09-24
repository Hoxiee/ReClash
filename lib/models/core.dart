import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/core.freezed.dart';
part 'generated/core.g.dart';

@freezed
abstract class SetupParams with _$SetupParams {
  const factory SetupParams({
    @JsonKey(name: 'selected-map') required Map<String, String> selectedMap,
    @JsonKey(name: 'test-url') required String testUrl,
  }) = _SetupParams;

  factory SetupParams.fromJson(Map<String, dynamic> json) =>
      _$SetupParamsFromJson(json);
}

@freezed
abstract class UpdateParams with _$UpdateParams {
  const factory UpdateParams({
    required Tun tun,
    @JsonKey(name: 'mixed-port') required int mixedPort,
    @JsonKey(name: 'allow-lan') required bool allowLan,
    @JsonKey(name: 'find-process-mode')
    required FindProcessMode findProcessMode,
    required Mode mode,
    @JsonKey(name: 'log-level') required LogLevel logLevel,
    required bool ipv6,
    @JsonKey(name: 'tcp-concurrent') required bool tcpConcurrent,
    @JsonKey(name: 'external-controller')
    required ExternalControllerStatus externalController,
    @JsonKey(name: 'unified-delay') required bool unifiedDelay,
    @Default([]) List<String> authentication,
    @Default(false) @JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,
    @Default(24) @JsonKey(name: 'geo-update-interval') int geoUpdateInterval,
  }) = _UpdateParams;

  factory UpdateParams.fromJson(Map<String, dynamic> json) =>
      _$UpdateParamsFromJson(json);
}

@freezed
abstract class VpnOptions with _$VpnOptions {
  const factory VpnOptions({
    required bool enable,
    required int port,
    required bool ipv6,
    required bool dnsHijacking,
    required AccessControlProps accessControlProps,
    required bool allowBypass,
    required bool systemProxy,
    required List<String> bypassDomain,
    required String stack,
    @Default([]) List<String> routeAddress,
    @Default(false) bool smartPauseEnabled,
    @Default([]) List<String> smartPauseNetworks,
    @Default(false) bool smartPauseCloseConnections,
    @Default(false) bool desyncEnabled,
    @Default(false) bool desyncOnly,
    @Default(defaultDesyncPort) int desyncPort,
    @Default([]) List<String> desyncStrategy,
    @Default(defaultDesyncCacheTtl) int desyncCacheTtl,
    @Default(true) bool desyncCacheEnabled,
    @Default(false) bool desyncTesting,
  }) = _VpnOptions;

  factory VpnOptions.fromJson(Map<String, Object?> json) =>
      _$VpnOptionsFromJson(json);
}

@freezed
abstract class InitParams with _$InitParams {
  const factory InitParams({
    @JsonKey(name: 'home-dir') required String homeDir,
    required int version,
  }) = _InitParams;

  factory InitParams.fromJson(Map<String, Object?> json) =>
      _$InitParamsFromJson(json);
}

@freezed
abstract class ChangeProxyParams with _$ChangeProxyParams {
  const factory ChangeProxyParams({
    @JsonKey(name: 'group-name') required String groupName,
    @JsonKey(name: 'proxy-name') required String proxyName,
    @Default(false) bool manual,
  }) = _ChangeProxyParams;

  factory ChangeProxyParams.fromJson(Map<String, Object?> json) =>
      _$ChangeProxyParamsFromJson(json);
}

@freezed
abstract class UpdateGeoDataParams with _$UpdateGeoDataParams {
  const factory UpdateGeoDataParams({
    @JsonKey(name: 'geo-type') required String geoType,
    @JsonKey(name: 'geo-name') required String geoName,
  }) = _UpdateGeoDataParams;

  factory UpdateGeoDataParams.fromJson(Map<String, Object?> json) =>
      _$UpdateGeoDataParamsFromJson(json);
}

@freezed
abstract class CoreEvent with _$CoreEvent {
  const factory CoreEvent({required CoreEventType type, dynamic data}) =
      _CoreEvent;

  factory CoreEvent.fromJson(Map<String, Object?> json) =>
      _$CoreEventFromJson(json);
}

@freezed
abstract class InvokeMessage with _$InvokeMessage {
  const factory InvokeMessage({required InvokeMessageType type, dynamic data}) =
      _InvokeMessage;

  factory InvokeMessage.fromJson(Map<String, Object?> json) =>
      _$InvokeMessageFromJson(json);
}

@freezed
abstract class Delay with _$Delay {
  const factory Delay({required String name, required String url, int? value}) =
      _Delay;

  factory Delay.fromJson(Map<String, Object?> json) => _$DelayFromJson(json);
}

@freezed
abstract class Now with _$Now {
  const factory Now({required String name, required String value}) = _Now;

  factory Now.fromJson(Map<String, Object?> json) => _$NowFromJson(json);
}

@freezed
abstract class ProviderSubscriptionInfo with _$ProviderSubscriptionInfo {
  const factory ProviderSubscriptionInfo({
    @JsonKey(name: 'UPLOAD') @Default(0) int upload,
    @JsonKey(name: 'DOWNLOAD') @Default(0) int download,
    @JsonKey(name: 'TOTAL') @Default(0) int total,
    @JsonKey(name: 'EXPIRE') @Default(0) int expire,
  }) = _ProviderSubscriptionInfo;

  factory ProviderSubscriptionInfo.fromJson(Map<String, Object?> json) =>
      _$ProviderSubscriptionInfoFromJson(json);
}

SubscriptionInfo? subscriptionInfoFormCore(Map<String, Object?>? json) {
  if (json == null) return null;
  return SubscriptionInfo(
    upload: (json['Upload'] as num?)?.toInt() ?? 0,
    download: (json['Download'] as num?)?.toInt() ?? 0,
    total: (json['Total'] as num?)?.toInt() ?? 0,
    expire: (json['Expire'] as num?)?.toInt() ?? 0,
  );
}

@freezed
abstract class ExternalProvider with _$ExternalProvider {
  const factory ExternalProvider({
    required String name,
    required String type,
    String? path,
    required int count,
    @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
    SubscriptionInfo? subscriptionInfo,
    @JsonKey(name: 'vehicle-type') required String vehicleType,
    @JsonKey(name: 'update-at') required DateTime updateAt,
  }) = _ExternalProvider;

  factory ExternalProvider.fromJson(Map<String, Object?> json) =>
      _$ExternalProviderFromJson(json);
}

extension ExternalProviderExt on ExternalProvider {
  String get updatingKey => 'provider_$name';
}

@freezed
abstract class ProxiesData with _$ProxiesData {
  const factory ProxiesData({
    required Map<String, dynamic> proxies,
    required List<String> all,
  }) = _ProxiesData;

  factory ProxiesData.fromJson(Map<String, Object?> json) =>
      _$ProxiesDataFromJson(json);
}

/// A parsed profile as the subscription gate sees it: every proxy server plus
/// whether providers may still inject nodes the list cannot show.
@freezed
abstract class ConfigInspection with _$ConfigInspection {
  const factory ConfigInspection({
    @Default([]) List<String> servers,
    @Default(false) bool providers,
    String? error,
  }) = _ConfigInspection;

  factory ConfigInspection.fromJson(Map<String, Object?> json) =>
      _$ConfigInspectionFromJson(json);
}

@freezed
abstract class RcxMarker with _$RcxMarker {
  const factory RcxMarker({
    @JsonKey(name: 'url') required String url,
    @JsonKey(name: 'statuses') required List<int> statuses,
  }) = _RcxMarker;

  factory RcxMarker.fromJson(Map<String, Object?> json) =>
      _$RcxMarkerFromJson(json);
}

@freezed
abstract class RcxLaneSelector with _$RcxLaneSelector {
  const factory RcxLaneSelector({
    @JsonKey(name: 'p') String? provider,
    @JsonKey(name: 'has') String? nameContains,
    @JsonKey(name: 'grp', includeIfNull: false) String? group,
  }) = _RcxLaneSelector;

  factory RcxLaneSelector.fromJson(Map<String, Object?> json) =>
      _$RcxLaneSelectorFromJson(json);
}

@freezed
abstract class RcxNodeRule with _$RcxNodeRule {
  const factory RcxNodeRule({
    @JsonKey(name: 'a') required String action,
    @JsonKey(name: 'p', includeIfNull: false) String? provider,
    @JsonKey(name: 'n', includeIfNull: false) String? nameContains,
    @JsonKey(name: 'g', includeIfNull: false) String? group,
    @JsonKey(name: 'c', includeIfNull: false) String? country,
  }) = _RcxNodeRule;

  factory RcxNodeRule.fromJson(Map<String, Object?> json) =>
      _$RcxNodeRuleFromJson(json);
}

@freezed
abstract class RcxLaneConfig with _$RcxLaneConfig {
  const factory RcxLaneConfig({
    @JsonKey(name: 'id') required String capabilityId,
    @JsonKey(name: 'g') required String group,
    @JsonKey(name: 'fb') required String fallback,
    @JsonKey(name: 'role', includeIfNull: false) String? role,
    @JsonKey(name: 'st', includeIfNull: false) String? strategy,
    @JsonKey(name: 'sel') @Default([]) List<RcxLaneSelector> selectors,
  }) = _RcxLaneConfig;

  factory RcxLaneConfig.fromJson(Map<String, Object?> json) =>
      _$RcxLaneConfigFromJson(json);
}

@freezed
abstract class RcxConfigParams with _$RcxConfigParams {
  const factory RcxConfigParams({
    @JsonKey(name: 'on') required bool enabled,
    @JsonKey(name: 'preset') required String preset,
    @JsonKey(name: 'st') required String strategy,
    @JsonKey(name: 'dv') required int defaultsVersion,
    @JsonKey(name: 'cc') required List<String> censorCountries,
    @JsonKey(name: 'cf') required List<String> canaryForeign,
    @JsonKey(name: 'cd') required List<String> canaryDomestic,
    @JsonKey(name: 'om') required List<RcxMarker> openMarkers,
    @JsonKey(name: 'dm') required List<RcxMarker> domesticMarkers,
    @JsonKey(name: 'lm') @Default([]) List<RcxMarker> localMarkers,
    @JsonKey(name: 'nh') @Default([]) List<String> nameHints,
    @JsonKey(name: 'ee') @Default([]) List<String> egressEchoes,
    @JsonKey(name: 'ce') @Default([]) List<String> countryEchoes,
    @JsonKey(name: 'bp') required List<String> breakerPatterns,
    @JsonKey(name: 'nr') @Default([]) List<RcxNodeRule> nodeRules,
    @JsonKey(name: 'ac') @Default([]) List<String> avoidCountries,
    @JsonKey(name: 'lb') @Default([]) List<int> latencyBands,
    @JsonKey(name: 'dlr') required bool allowDomesticLastResort,
    @JsonKey(name: 'udp') required bool requireUdp,
    @JsonKey(name: 'rpk') required bool respectPick,
    @JsonKey(name: 'dwl') required int dwellSeconds,
    @JsonKey(name: 'ww') required int waveWidth,
    @JsonKey(name: 'acm') @Default(300) int absCeilingMs,
    @JsonKey(name: 'dgc') @Default(60) int degradeConfirmSeconds,
    @JsonKey(name: 'pttl') @Default(30) int proofTtlMinutes,
    @JsonKey(name: 'ln') @Default([]) List<RcxLaneConfig> lanes,
  }) = _RcxConfigParams;

  factory RcxConfigParams.fromJson(Map<String, Object?> json) =>
      _$RcxConfigParamsFromJson(json);
}

@freezed
abstract class RcxLaneStatus with _$RcxLaneStatus {
  const factory RcxLaneStatus({
    @Default('') String id,
    @Default('') String group,
    @Default('empty') String state,
    @Default('') String node,
    @Default(0) int candidates,
    @Default(0) int eligible,
    @Default(false) bool searching,
    @Default('main') String fallback,
    @Default('') String reason,
    @Default(0) int switchedAt,
  }) = _RcxLaneStatus;

  factory RcxLaneStatus.fromJson(Map<String, Object?> json) =>
      _$RcxLaneStatusFromJson(json);
}

@freezed
abstract class RcxStatus with _$RcxStatus {
  const factory RcxStatus({
    @Default(false) bool enabled,
    @Default('off') String preset,
    @Default('balanced') String strategy,
    @Default('') String mode,
    @Default('unknown') String terrain,
    @Default('') String env,
    @Default('') String node,
    @Default(0) int delay,
    @Default('') String reason,
    @Default(false) bool searching,
    @Default(false) bool deep,
    @Default(false) bool pinned,
    @Default('') String pinNode,
    @Default('') String direct,
    @Default(0) int candidates,
    @Default(0) int eligible,
    @Default(0) int switchedAt,
    @Default([]) List<RcxLaneStatus> lanes,
  }) = _RcxStatus;

  factory RcxStatus.fromJson(Map<String, Object?> json) =>
      _$RcxStatusFromJson(json);
}

/// One row of the overview: why this node sits where it does, in the engine's
/// own vocabulary rather than a score the UI would have to invent.
@freezed
abstract class RcxCandidateReport with _$RcxCandidateReport {
  const factory RcxCandidateReport({
    @Default('') String node,
    @Default('') String country,
    @Default('') String exit,
    @Default('unknown') String origin,
    @Default('reject') String verdict,
    @Default('none') String evidence,
    @Default('') String block,
    @Default(0) int delay,
    @Default(0) int hostDelay,
    @Default(0) int band,
    @Default(0) int latencyMs,
    @Default(false) bool unproven,
    @Default(0) int order,
    @Default(false) bool degraded,
    @Default(0) int homeRisk,
    @Default(0) int recurrence,
    @Default(false) bool confirmed,
    @Default(false) bool breaker,
    @Default(false) bool udp,
    @Default(0) int fails,
    @Default(0) int coolFor,
    @Default(false) bool current,
    @Default('unknown') String trust,
    @Default('none') String confidence,
  }) = _RcxCandidateReport;

  factory RcxCandidateReport.fromJson(Map<String, Object?> json) =>
      _$RcxCandidateReportFromJson(json);
}

@freezed
abstract class RcxSwitchReport with _$RcxSwitchReport {
  const factory RcxSwitchReport({
    @Default('') String from,
    @Default('') String to,
    @Default('') String reason,
    @Default(0) int at,
  }) = _RcxSwitchReport;

  factory RcxSwitchReport.fromJson(Map<String, Object?> json) =>
      _$RcxSwitchReportFromJson(json);
}

@freezed
abstract class RcxCanaryReport with _$RcxCanaryReport {
  const factory RcxCanaryReport({
    @Default('') String addr,
    @Default(false) bool domestic,
    @Default('unknown') String outcome,
    @Default(0) int delay,
  }) = _RcxCanaryReport;

  factory RcxCanaryReport.fromJson(Map<String, Object?> json) =>
      _$RcxCanaryReportFromJson(json);
}

@freezed
abstract class RcxLinkReport with _$RcxLinkReport {
  const factory RcxLinkReport({
    @Default('') String transport,
    @Default(false) bool validated,
    @Default(false) bool portal,
    @Default(false) bool metered,
    @Default('unknown') String foreign,
    @Default('unknown') String domestic,
    @Default(0) int since,
  }) = _RcxLinkReport;

  factory RcxLinkReport.fromJson(Map<String, Object?> json) =>
      _$RcxLinkReportFromJson(json);
}

@freezed
abstract class RcxMetricsReport with _$RcxMetricsReport {
  const factory RcxMetricsReport({
    @Default(0) int enabledMillis,
    @Default(0) int availableMillis,
    @Default(0) int availability,
    @Default(0) int incidents,
    @Default(0) int standbyHits,
    @Default(0) int providerIncidents,
    @Default(0) int markerIncidents,
    @Default(0) int lastFailover,
    @Default(0) int averageFailover,
    @Default(0) int lastOutage,
    @Default(0) int averageOutage,
    @Default([]) List<String> activeCircuits,
    @Default([]) List<String> activeMarkers,
  }) = _RcxMetricsReport;

  factory RcxMetricsReport.fromJson(Map<String, Object?> json) =>
      _$RcxMetricsReportFromJson(json);
}

@freezed
abstract class RcxDiscoveryReport with _$RcxDiscoveryReport {
  const factory RcxDiscoveryReport({
    @Default(0) int covered,
    @Default(0) int pending,
    @Default(0) int attempts,
    @Default(0) int confirmations,
    @Default('') String state,
  }) = _RcxDiscoveryReport;

  factory RcxDiscoveryReport.fromJson(Map<String, Object?> json) =>
      _$RcxDiscoveryReportFromJson(json);
}

@freezed
abstract class CoreMemoryStats with _$CoreMemoryStats {
  const factory CoreMemoryStats({
    @Default(0) int rss,
    @Default(0) int heapInuse,
    @Default(0) int heapIdle,
    @Default(0) int stackInuse,
    @Default(0) int runtimeOther,
  }) = _CoreMemoryStats;

  factory CoreMemoryStats.fromJson(Map<String, Object?> json) =>
      _$CoreMemoryStatsFromJson(json);
}

extension CoreMemoryStatsExt on CoreMemoryStats {
  int get runtimeTotal => heapInuse + heapIdle + stackInuse + runtimeOther;
}

@freezed
abstract class RcxReport with _$RcxReport {
  const factory RcxReport({
    @Default(RcxStatus()) RcxStatus status,
    @Default(RcxLinkReport()) RcxLinkReport link,
    @Default([]) List<RcxCanaryReport> canaries,
    @Default([]) List<RcxCandidateReport> candidates,
    @Default([]) List<RcxSwitchReport> history,
    @Default(RcxMetricsReport()) RcxMetricsReport metrics,
    @Default([]) List<int> bands,
    @Default(0) int probesLeft,
    @Default(0) int probeCap,
    @Default(false) bool manual,
    @Default(RcxDiscoveryReport()) RcxDiscoveryReport discovery,
    @Default(0) int at,
  }) = _RcxReport;

  factory RcxReport.fromJson(Map<String, Object?> json) =>
      _$RcxReportFromJson(json);
}
