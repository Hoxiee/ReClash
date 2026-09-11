import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/connection_doctor.freezed.dart';
part 'generated/connection_doctor.g.dart';

enum DoctorExamState {
  observing,
  examining,
  complete,
  inconclusive,
  superseded,
  cancelled,
  unknown,
}

enum DoctorExamMode { standard, deep, unknown }

enum DoctorHealth { unknown, healthy, degraded, broken }

enum DoctorConfidence { confirmed, probable, insufficient, unknown }

enum DoctorSeverity { info, warning, critical, unknown }

enum DoctorScope { unknown, app, inbound }

enum DoctorPathKind { unknown, vpn, tun, localProxy, direct, byeDpi }

enum DoctorCaptureState { unknown, inactive, active, notApplicable }

enum DoctorStageState {
  passed,
  failed,
  checking,
  unknown,
  notApplicable,
  consequence,
}

enum DoctorLayer {
  capture,
  ingress,
  dns,
  route,
  dial,
  transport,
  marker,
  unknown,
}

enum DoctorEvidenceKind {
  ingress,
  preHandle,
  route,
  outerDial,
  trackerOpen,
  firstProgress,
  marker,
  probe,
  evidenceOverflow,
  unknown,
}

enum DoctorEvidenceOutcome {
  seen,
  succeeded,
  failed,
  dropped,
  notApplicable,
  unknown,
}

@freezed
abstract class DoctorCapabilities with _$DoctorCapabilities {
  const factory DoctorCapabilities({
    @Default(false) bool passiveWitness,
    @Default(false) bool explicitExam,
    @Default(false) bool cancel,
    @Default(false) bool dnsFlush,
    @Default(false) bool androidAppIngressProbe,
    @Default(false) bool tunIngressProof,
    @Default(false) bool byedpiStatus,
    @Default(false) bool redactedExport,
  }) = _DoctorCapabilities;

  factory DoctorCapabilities.fromJson(Map<String, Object?> json) =>
      _$DoctorCapabilitiesFromJson(json);
}

@freezed
abstract class DoctorGenerations with _$DoctorGenerations {
  const factory DoctorGenerations({
    @Default(0) int environment,
    @Default(0) int config,
    @Default(0) int routing,
    @Default(0) int tun,
  }) = _DoctorGenerations;

  factory DoctorGenerations.fromJson(Map<String, Object?> json) =>
      _$DoctorGenerationsFromJson(json);
}

@freezed
abstract class DoctorEvidence with _$DoctorEvidence {
  const factory DoctorEvidence({
    @JsonKey(unknownEnumValue: DoctorEvidenceKind.unknown)
    @Default(DoctorEvidenceKind.unknown)
    DoctorEvidenceKind kind,
    @JsonKey(unknownEnumValue: DoctorLayer.unknown)
    @Default(DoctorLayer.unknown)
    DoctorLayer layer,
    @JsonKey(unknownEnumValue: DoctorEvidenceOutcome.unknown)
    @Default(DoctorEvidenceOutcome.unknown)
    DoctorEvidenceOutcome outcome,
    @JsonKey(unknownEnumValue: DoctorConfidence.unknown)
    @Default(DoctorConfidence.unknown)
    DoctorConfidence confidence,
    @Default('') String code,
    @Default('') String network,
    @Default('') String inbound,
    @Default(0) int offsetMillis,
    @Default(0) int durationBucketMs,
    @Default(false) bool consequence,
  }) = _DoctorEvidence;

  factory DoctorEvidence.fromJson(Map<String, Object?> json) =>
      _$DoctorEvidenceFromJson(json);
}

@freezed
abstract class DoctorStage with _$DoctorStage {
  const factory DoctorStage({
    @Default('') String id,
    @JsonKey(unknownEnumValue: DoctorStageState.unknown)
    @Default(DoctorStageState.unknown)
    DoctorStageState state,
    @JsonKey(unknownEnumValue: DoctorLayer.unknown)
    @Default(DoctorLayer.unknown)
    DoctorLayer layer,
    @Default('') String code,
  }) = _DoctorStage;

  factory DoctorStage.fromJson(Map<String, Object?> json) =>
      _$DoctorStageFromJson(json);
}

@freezed
abstract class DoctorAction with _$DoctorAction {
  const factory DoctorAction({
    required String id,
    @Default(false) bool eligible,
    @Default('') String eligibilityReasonCode,
  }) = _DoctorAction;

  factory DoctorAction.fromJson(Map<String, Object?> json) =>
      _$DoctorActionFromJson(json);
}

@freezed
abstract class DoctorHealAudit with _$DoctorHealAudit {
  const factory DoctorHealAudit({
    required String actionId,
    @Default(0) int at,
    @Default('') String outcome,
    @Default(0) int beforeRevision,
    @Default('') String reexamId,
  }) = _DoctorHealAudit;

  factory DoctorHealAudit.fromJson(Map<String, Object?> json) =>
      _$DoctorHealAuditFromJson(json);
}

@freezed
abstract class DoctorIncident with _$DoctorIncident {
  const factory DoctorIncident({
    @Default('') String examId,
    @JsonKey(unknownEnumValue: DoctorExamMode.unknown)
    @Default(DoctorExamMode.unknown)
    DoctorExamMode mode,
    @JsonKey(unknownEnumValue: DoctorExamState.unknown)
    @Default(DoctorExamState.unknown)
    DoctorExamState state,
    @JsonKey(unknownEnumValue: DoctorHealth.unknown)
    @Default(DoctorHealth.unknown)
    DoctorHealth health,
    @JsonKey(unknownEnumValue: DoctorConfidence.unknown)
    @Default(DoctorConfidence.unknown)
    DoctorConfidence confidence,
    @Default('') String causeCode,
    @JsonKey(unknownEnumValue: DoctorLayer.unknown)
    @Default(DoctorLayer.unknown)
    DoctorLayer layer,
    @Default(0) int startedAt,
    @Default(0) int finishedAt,
  }) = _DoctorIncident;

  factory DoctorIncident.fromJson(Map<String, Object?> json) =>
      _$DoctorIncidentFromJson(json);
}

@freezed
abstract class DoctorProgress with _$DoctorProgress {
  const factory DoctorProgress({
    @Default('') String phase,
    @Default(0) int completed,
    @Default(0) int total,
  }) = _DoctorProgress;

  factory DoctorProgress.fromJson(Map<String, Object?> json) =>
      _$DoctorProgressFromJson(json);
}

@freezed
abstract class DoctorSnapshot with _$DoctorSnapshot {
  const factory DoctorSnapshot({
    @Default(1) int schemaVersion,
    @Default(0) int revision,
    @Default(false) bool supported,
    @Default(DoctorCapabilities()) DoctorCapabilities capabilities,
    @JsonKey(unknownEnumValue: DoctorExamState.unknown)
    @Default(DoctorExamState.unknown)
    DoctorExamState state,
    @JsonKey(unknownEnumValue: DoctorHealth.unknown)
    @Default(DoctorHealth.unknown)
    DoctorHealth health,
    @JsonKey(unknownEnumValue: DoctorConfidence.unknown)
    @Default(DoctorConfidence.unknown)
    DoctorConfidence confidence,
    @JsonKey(unknownEnumValue: DoctorSeverity.unknown)
    @Default(DoctorSeverity.unknown)
    DoctorSeverity severity,
    @JsonKey(unknownEnumValue: DoctorScope.unknown)
    @Default(DoctorScope.unknown)
    DoctorScope scope,
    @JsonKey(unknownEnumValue: DoctorPathKind.unknown)
    @Default(DoctorPathKind.unknown)
    DoctorPathKind pathKind,
    @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)
    @Default(DoctorCaptureState.unknown)
    DoctorCaptureState captureState,
    @Default([]) List<DoctorStage> stages,
    @Default('') String examId,
    @JsonKey(unknownEnumValue: DoctorExamMode.unknown)
    @Default(DoctorExamMode.unknown)
    DoctorExamMode mode,
    @Default('') String causeCode,
    @JsonKey(unknownEnumValue: DoctorLayer.unknown)
    @Default(DoctorLayer.unknown)
    DoctorLayer layer,
    @Default(DoctorProgress()) DoctorProgress progress,
    @Default(DoctorGenerations()) DoctorGenerations generations,
    @Default(DoctorGenerations()) DoctorGenerations startGenerations,
    @Default(0) int startedAt,
    @Default(0) int updatedAt,
    @Default(0) int freshUntil,
    @Default(0) int evidenceDropped,
    @Default([]) List<DoctorEvidence> evidence,
    @Default([]) List<DoctorAction> actions,
    @Default([]) List<DoctorHealAudit> healAudit,
    @Default([]) List<DoctorIncident> incidents,
  }) = _DoctorSnapshot;

  const DoctorSnapshot._();

  factory DoctorSnapshot.fromJson(Map<String, Object?> json) =>
      _$DoctorSnapshotFromJson(json);

  bool get isFresh =>
      freshUntil == 0 || DateTime.now().millisecondsSinceEpoch <= freshUntil;

  DoctorAction? action(String id) {
    for (final action in actions) {
      if (action.id == id) return action;
    }
    return null;
  }
}

@freezed
abstract class DoctorStatus with _$DoctorStatus {
  const factory DoctorStatus({
    @Default(0) int revision,
    @JsonKey(unknownEnumValue: DoctorExamState.unknown)
    @Default(DoctorExamState.unknown)
    DoctorExamState state,
    @JsonKey(unknownEnumValue: DoctorHealth.unknown)
    @Default(DoctorHealth.unknown)
    DoctorHealth health,
    @JsonKey(unknownEnumValue: DoctorConfidence.unknown)
    @Default(DoctorConfidence.unknown)
    DoctorConfidence confidence,
    @Default('') String causeCode,
  }) = _DoctorStatus;

  factory DoctorStatus.fromJson(Map<String, Object?> json) =>
      _$DoctorStatusFromJson(json);
}

@freezed
abstract class DoctorStartParams with _$DoctorStartParams {
  const factory DoctorStartParams({required DoctorExamMode mode}) =
      _DoctorStartParams;

  factory DoctorStartParams.fromJson(Map<String, Object?> json) =>
      _$DoctorStartParamsFromJson(json);
}

@freezed
abstract class DoctorCancelParams with _$DoctorCancelParams {
  const factory DoctorCancelParams({required String examId}) =
      _DoctorCancelParams;

  factory DoctorCancelParams.fromJson(Map<String, Object?> json) =>
      _$DoctorCancelParamsFromJson(json);
}

@freezed
abstract class DoctorReport with _$DoctorReport {
  const factory DoctorReport({
    @Default(1) int schemaVersion,
    @Default('') String coreVersion,
    @Default('') String platform,
    @Default('') String architecture,
    @Default(0) int generatedAt,
    @JsonKey(unknownEnumValue: DoctorExamState.unknown)
    @Default(DoctorExamState.unknown)
    DoctorExamState state,
    @JsonKey(unknownEnumValue: DoctorHealth.unknown)
    @Default(DoctorHealth.unknown)
    DoctorHealth health,
    @JsonKey(unknownEnumValue: DoctorConfidence.unknown)
    @Default(DoctorConfidence.unknown)
    DoctorConfidence confidence,
    @JsonKey(unknownEnumValue: DoctorScope.unknown)
    @Default(DoctorScope.unknown)
    DoctorScope scope,
    @JsonKey(unknownEnumValue: DoctorPathKind.unknown)
    @Default(DoctorPathKind.unknown)
    DoctorPathKind pathKind,
    @JsonKey(unknownEnumValue: DoctorCaptureState.unknown)
    @Default(DoctorCaptureState.unknown)
    DoctorCaptureState captureState,
    @Default([]) List<DoctorStage> stages,
    @JsonKey(unknownEnumValue: DoctorExamMode.unknown)
    @Default(DoctorExamMode.unknown)
    DoctorExamMode mode,
    @Default('') String causeCode,
    @JsonKey(unknownEnumValue: DoctorLayer.unknown)
    @Default(DoctorLayer.unknown)
    DoctorLayer layer,
    @Default(DoctorGenerations()) DoctorGenerations generations,
    @Default([]) List<DoctorEvidence> evidence,
    @Default([]) List<DoctorHealAudit> healAudit,
    @Default([]) List<DoctorIncident> incidents,
  }) = _DoctorReport;

  factory DoctorReport.fromJson(Map<String, Object?> json) =>
      _$DoctorReportFromJson(json);
}

@freezed
abstract class DoctorHealParams with _$DoctorHealParams {
  const factory DoctorHealParams({
    required String examId,
    required int revision,
    @Default('flushDns') String actionId,
  }) = _DoctorHealParams;

  factory DoctorHealParams.fromJson(Map<String, Object?> json) =>
      _$DoctorHealParamsFromJson(json);
}
