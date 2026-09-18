import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/subscription_report.freezed.dart';
part 'generated/subscription_report.g.dart';

/// Who the evidence points at. Errs toward [inconclusive], never toward a false
/// [server] — that hands the provider a lie and turns them against the client.
enum SubscriptionFault {
  yourNetwork,
  client,
  subscription,
  server,
  inconclusive,
  unknown,
}

@freezed
abstract class SubscriptionVerdict with _$SubscriptionVerdict {
  const factory SubscriptionVerdict({
    @Default('') String headline,
    @JsonKey(unknownEnumValue: SubscriptionFault.unknown)
    @Default(SubscriptionFault.unknown)
    SubscriptionFault fault,
    @Default('') String health,
    @Default('') String causeCode,
    @Default('') String layer,
    @Default('') String terrain,
    @Default('') String env,
  }) = _SubscriptionVerdict;

  factory SubscriptionVerdict.fromJson(Map<String, Object?> json) =>
      _$SubscriptionVerdictFromJson(json);
}

@freezed
abstract class SubscriptionUpdateStage with _$SubscriptionUpdateStage {
  const factory SubscriptionUpdateStage({
    @Default('') String stage,
    @Default(0) int attempts,
    @Default(0) int failures,
    @Default('') String dominantError,
  }) = _SubscriptionUpdateStage;

  factory SubscriptionUpdateStage.fromJson(Map<String, Object?> json) =>
      _$SubscriptionUpdateStageFromJson(json);
}

@freezed
abstract class SubscriptionUpdateHost with _$SubscriptionUpdateHost {
  const factory SubscriptionUpdateHost({
    @Default('') String host,
    @Default(0) int attempts,
    @Default(0) int failures,
    @Default(false) bool succeeded,
    @Default('') String lastError,
  }) = _SubscriptionUpdateHost;

  factory SubscriptionUpdateHost.fromJson(Map<String, Object?> json) =>
      _$SubscriptionUpdateHostFromJson(json);
}

/// Dart-side aggregate of the last update attempt, built in the live isolate a
/// UI-triggered update runs in. The real URL, query and device headers never
/// enter it — hosts appear only as `host-NN`.
@freezed
abstract class SubscriptionUpdateReport with _$SubscriptionUpdateReport {
  const factory SubscriptionUpdateReport({
    @Default(false) bool attempted,
    @Default(false) bool succeeded,
    @Default(0) int generatedAt,
    @Default(0) int hostCount,
    @Default(0) int attempts,
    @Default(0) int failures,
    @Default(false) bool hwidRejected,
    @Default(false) bool emptyResponse,
    @Default(false) bool undialable,
    @Default('') String dominantError,
    @Default([]) List<SubscriptionUpdateStage> byStage,
    @Default([]) List<SubscriptionUpdateHost> hosts,
  }) = _SubscriptionUpdateReport;

  factory SubscriptionUpdateReport.fromJson(Map<String, Object?> json) =>
      _$SubscriptionUpdateReportFromJson(json);
}

@freezed
abstract class SubscriptionOutcome with _$SubscriptionOutcome {
  const factory SubscriptionOutcome({
    @Default('') String key,
    @Default(0) int attempts,
    @Default(0) int failure,
  }) = _SubscriptionOutcome;

  factory SubscriptionOutcome.fromJson(Map<String, Object?> json) =>
      _$SubscriptionOutcomeFromJson(json);
}

@freezed
abstract class SubscriptionGroupOutcome with _$SubscriptionGroupOutcome {
  const factory SubscriptionGroupOutcome({
    @Default('') String group,
    @Default(0) int attempts,
    @Default(0) int failure,
  }) = _SubscriptionGroupOutcome;

  factory SubscriptionGroupOutcome.fromJson(Map<String, Object?> json) =>
      _$SubscriptionGroupOutcomeFromJson(json);
}

@freezed
abstract class SubscriptionClassCount with _$SubscriptionClassCount {
  const factory SubscriptionClassCount({
    @JsonKey(name: 'class') @Default('') String errorClass,
    @Default(0) int count,
  }) = _SubscriptionClassCount;

  factory SubscriptionClassCount.fromJson(Map<String, Object?> json) =>
      _$SubscriptionClassCountFromJson(json);
}

@freezed
abstract class SubscriptionDialReport with _$SubscriptionDialReport {
  const factory SubscriptionDialReport({
    @Default(0) int attempts,
    @Default(0) int success,
    @Default(0) int failure,
    @Default([]) List<SubscriptionOutcome> byTransport,
    @Default([]) List<SubscriptionOutcome> byStage,
    @Default([]) List<SubscriptionClassCount> byErrorClass,
    @Default([]) List<SubscriptionOutcome> byProtocol,
    @Default([]) List<SubscriptionGroupOutcome> byGroup,
    @Default([]) List<SubscriptionOutcome> byEgress,
  }) = _SubscriptionDialReport;

  factory SubscriptionDialReport.fromJson(Map<String, Object?> json) =>
      _$SubscriptionDialReportFromJson(json);
}

@freezed
abstract class SubscriptionNodeReport with _$SubscriptionNodeReport {
  const factory SubscriptionNodeReport({
    @Default('') String alias,
    @Default('') String protocol,
    @Default('') String transport,
    @Default('') String egressCountry,
    @Default([]) List<String> groups,
    @Default(0) int positionHint,
    @Default(0) int attempts,
    @Default(0) int failures,
    @Default(0) int successes,
    @Default(0) int failStreak,
    @Default('') String dominantClass,
    @Default(0) int delayBucketMs,
  }) = _SubscriptionNodeReport;

  factory SubscriptionNodeReport.fromJson(Map<String, Object?> json) =>
      _$SubscriptionNodeReportFromJson(json);
}

/// [verdict] and [subscriptionUpdate] are layered in on the Dart side; the rest
/// arrives from the core's always-on `subscriptionReport`.
@freezed
abstract class SubscriptionReport with _$SubscriptionReport {
  const factory SubscriptionReport({
    SubscriptionVerdict? verdict,
    @Default(1) int schemaVersion,
    @Default(0) int generatedAt,
    @Default('') String coreVersion,
    @Default('') String appVersion,
    @Default('') String platform,
    @Default('') String architecture,
    @Default(0) int windowStart,
    @Default(0) int windowEnd,
    @Default('') String terrain,
    @Default('') String env,
    @Default([]) List<String> presets,
    @Default(0) int droppedEvents,
    @Default(0) int configNodeCount,
    @Default(0) int observedNodeCount,
    SubscriptionUpdateReport? subscriptionUpdate,
    @Default(SubscriptionDialReport()) SubscriptionDialReport runtimeDial,
    @Default([]) List<SubscriptionNodeReport> nodes,
  }) = _SubscriptionReport;

  factory SubscriptionReport.fromJson(Map<String, Object?> json) =>
      _$SubscriptionReportFromJson(json);
}

@freezed
abstract class SubscriptionNodeLabel with _$SubscriptionNodeLabel {
  const factory SubscriptionNodeLabel({
    @Default('') String protocol,
    @Default('') String transport,
    @Default([]) List<String> groups,
    @Default(0) int positionHint,
  }) = _SubscriptionNodeLabel;

  factory SubscriptionNodeLabel.fromJson(Map<String, Object?> json) =>
      _$SubscriptionNodeLabelFromJson(json);
}

@freezed
abstract class SubscriptionMetadata with _$SubscriptionMetadata {
  const factory SubscriptionMetadata({
    @Default({}) Map<String, SubscriptionNodeLabel> nodes,
    @Default([]) List<String> presets,
  }) = _SubscriptionMetadata;

  factory SubscriptionMetadata.fromJson(Map<String, Object?> json) =>
      _$SubscriptionMetadataFromJson(json);
}
