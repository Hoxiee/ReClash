// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../connection_doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoctorCapabilities _$DoctorCapabilitiesFromJson(Map<String, dynamic> json) =>
    _DoctorCapabilities(
      passiveWitness: json['passiveWitness'] as bool? ?? false,
      explicitExam: json['explicitExam'] as bool? ?? false,
      cancel: json['cancel'] as bool? ?? false,
      dnsFlush: json['dnsFlush'] as bool? ?? false,
      androidAppIngressProbe: json['androidAppIngressProbe'] as bool? ?? false,
      tunIngressProof: json['tunIngressProof'] as bool? ?? false,
      byedpiStatus: json['byedpiStatus'] as bool? ?? false,
      redactedExport: json['redactedExport'] as bool? ?? false,
    );

Map<String, dynamic> _$DoctorCapabilitiesToJson(_DoctorCapabilities instance) =>
    <String, dynamic>{
      'passiveWitness': instance.passiveWitness,
      'explicitExam': instance.explicitExam,
      'cancel': instance.cancel,
      'dnsFlush': instance.dnsFlush,
      'androidAppIngressProbe': instance.androidAppIngressProbe,
      'tunIngressProof': instance.tunIngressProof,
      'byedpiStatus': instance.byedpiStatus,
      'redactedExport': instance.redactedExport,
    };

_DoctorGenerations _$DoctorGenerationsFromJson(Map<String, dynamic> json) =>
    _DoctorGenerations(
      environment: (json['environment'] as num?)?.toInt() ?? 0,
      config: (json['config'] as num?)?.toInt() ?? 0,
      routing: (json['routing'] as num?)?.toInt() ?? 0,
      tun: (json['tun'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DoctorGenerationsToJson(_DoctorGenerations instance) =>
    <String, dynamic>{
      'environment': instance.environment,
      'config': instance.config,
      'routing': instance.routing,
      'tun': instance.tun,
    };

_DoctorEvidence _$DoctorEvidenceFromJson(Map<String, dynamic> json) =>
    _DoctorEvidence(
      kind:
          $enumDecodeNullable(
            _$DoctorEvidenceKindEnumMap,
            json['kind'],
            unknownValue: DoctorEvidenceKind.unknown,
          ) ??
          DoctorEvidenceKind.unknown,
      layer:
          $enumDecodeNullable(
            _$DoctorLayerEnumMap,
            json['layer'],
            unknownValue: DoctorLayer.unknown,
          ) ??
          DoctorLayer.unknown,
      outcome:
          $enumDecodeNullable(
            _$DoctorEvidenceOutcomeEnumMap,
            json['outcome'],
            unknownValue: DoctorEvidenceOutcome.unknown,
          ) ??
          DoctorEvidenceOutcome.unknown,
      confidence:
          $enumDecodeNullable(
            _$DoctorConfidenceEnumMap,
            json['confidence'],
            unknownValue: DoctorConfidence.unknown,
          ) ??
          DoctorConfidence.unknown,
      code: json['code'] as String? ?? '',
      network: json['network'] as String? ?? '',
      inbound: json['inbound'] as String? ?? '',
      offsetMillis: (json['offsetMillis'] as num?)?.toInt() ?? 0,
      durationBucketMs: (json['durationBucketMs'] as num?)?.toInt() ?? 0,
      consequence: json['consequence'] as bool? ?? false,
    );

Map<String, dynamic> _$DoctorEvidenceToJson(_DoctorEvidence instance) =>
    <String, dynamic>{
      'kind': _$DoctorEvidenceKindEnumMap[instance.kind]!,
      'layer': _$DoctorLayerEnumMap[instance.layer]!,
      'outcome': _$DoctorEvidenceOutcomeEnumMap[instance.outcome]!,
      'confidence': _$DoctorConfidenceEnumMap[instance.confidence]!,
      'code': instance.code,
      'network': instance.network,
      'inbound': instance.inbound,
      'offsetMillis': instance.offsetMillis,
      'durationBucketMs': instance.durationBucketMs,
      'consequence': instance.consequence,
    };

const _$DoctorEvidenceKindEnumMap = {
  DoctorEvidenceKind.ingress: 'ingress',
  DoctorEvidenceKind.preHandle: 'preHandle',
  DoctorEvidenceKind.route: 'route',
  DoctorEvidenceKind.outerDial: 'outerDial',
  DoctorEvidenceKind.trackerOpen: 'trackerOpen',
  DoctorEvidenceKind.firstProgress: 'firstProgress',
  DoctorEvidenceKind.marker: 'marker',
  DoctorEvidenceKind.probe: 'probe',
  DoctorEvidenceKind.evidenceOverflow: 'evidenceOverflow',
  DoctorEvidenceKind.unknown: 'unknown',
};

const _$DoctorLayerEnumMap = {
  DoctorLayer.capture: 'capture',
  DoctorLayer.ingress: 'ingress',
  DoctorLayer.dns: 'dns',
  DoctorLayer.route: 'route',
  DoctorLayer.dial: 'dial',
  DoctorLayer.transport: 'transport',
  DoctorLayer.marker: 'marker',
  DoctorLayer.unknown: 'unknown',
};

const _$DoctorEvidenceOutcomeEnumMap = {
  DoctorEvidenceOutcome.seen: 'seen',
  DoctorEvidenceOutcome.succeeded: 'succeeded',
  DoctorEvidenceOutcome.failed: 'failed',
  DoctorEvidenceOutcome.dropped: 'dropped',
  DoctorEvidenceOutcome.notApplicable: 'notApplicable',
  DoctorEvidenceOutcome.unknown: 'unknown',
};

const _$DoctorConfidenceEnumMap = {
  DoctorConfidence.confirmed: 'confirmed',
  DoctorConfidence.probable: 'probable',
  DoctorConfidence.insufficient: 'insufficient',
  DoctorConfidence.unknown: 'unknown',
};

_DoctorStage _$DoctorStageFromJson(Map<String, dynamic> json) => _DoctorStage(
  id: json['id'] as String? ?? '',
  state:
      $enumDecodeNullable(
        _$DoctorStageStateEnumMap,
        json['state'],
        unknownValue: DoctorStageState.unknown,
      ) ??
      DoctorStageState.unknown,
  layer:
      $enumDecodeNullable(
        _$DoctorLayerEnumMap,
        json['layer'],
        unknownValue: DoctorLayer.unknown,
      ) ??
      DoctorLayer.unknown,
  code: json['code'] as String? ?? '',
);

Map<String, dynamic> _$DoctorStageToJson(_DoctorStage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'state': _$DoctorStageStateEnumMap[instance.state]!,
      'layer': _$DoctorLayerEnumMap[instance.layer]!,
      'code': instance.code,
    };

const _$DoctorStageStateEnumMap = {
  DoctorStageState.passed: 'passed',
  DoctorStageState.failed: 'failed',
  DoctorStageState.checking: 'checking',
  DoctorStageState.unknown: 'unknown',
  DoctorStageState.notApplicable: 'notApplicable',
  DoctorStageState.consequence: 'consequence',
};

_DoctorAction _$DoctorActionFromJson(Map<String, dynamic> json) =>
    _DoctorAction(
      id: json['id'] as String,
      eligible: json['eligible'] as bool? ?? false,
      eligibilityReasonCode: json['eligibilityReasonCode'] as String? ?? '',
    );

Map<String, dynamic> _$DoctorActionToJson(_DoctorAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eligible': instance.eligible,
      'eligibilityReasonCode': instance.eligibilityReasonCode,
    };

_DoctorHealAudit _$DoctorHealAuditFromJson(Map<String, dynamic> json) =>
    _DoctorHealAudit(
      actionId: json['actionId'] as String,
      at: (json['at'] as num?)?.toInt() ?? 0,
      outcome: json['outcome'] as String? ?? '',
      beforeRevision: (json['beforeRevision'] as num?)?.toInt() ?? 0,
      reexamId: json['reexamId'] as String? ?? '',
    );

Map<String, dynamic> _$DoctorHealAuditToJson(_DoctorHealAudit instance) =>
    <String, dynamic>{
      'actionId': instance.actionId,
      'at': instance.at,
      'outcome': instance.outcome,
      'beforeRevision': instance.beforeRevision,
      'reexamId': instance.reexamId,
    };

_DoctorIncident _$DoctorIncidentFromJson(Map<String, dynamic> json) =>
    _DoctorIncident(
      examId: json['examId'] as String? ?? '',
      mode:
          $enumDecodeNullable(
            _$DoctorExamModeEnumMap,
            json['mode'],
            unknownValue: DoctorExamMode.unknown,
          ) ??
          DoctorExamMode.unknown,
      state:
          $enumDecodeNullable(
            _$DoctorExamStateEnumMap,
            json['state'],
            unknownValue: DoctorExamState.unknown,
          ) ??
          DoctorExamState.unknown,
      health:
          $enumDecodeNullable(
            _$DoctorHealthEnumMap,
            json['health'],
            unknownValue: DoctorHealth.unknown,
          ) ??
          DoctorHealth.unknown,
      confidence:
          $enumDecodeNullable(
            _$DoctorConfidenceEnumMap,
            json['confidence'],
            unknownValue: DoctorConfidence.unknown,
          ) ??
          DoctorConfidence.unknown,
      causeCode: json['causeCode'] as String? ?? '',
      layer:
          $enumDecodeNullable(
            _$DoctorLayerEnumMap,
            json['layer'],
            unknownValue: DoctorLayer.unknown,
          ) ??
          DoctorLayer.unknown,
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      finishedAt: (json['finishedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DoctorIncidentToJson(_DoctorIncident instance) =>
    <String, dynamic>{
      'examId': instance.examId,
      'mode': _$DoctorExamModeEnumMap[instance.mode]!,
      'state': _$DoctorExamStateEnumMap[instance.state]!,
      'health': _$DoctorHealthEnumMap[instance.health]!,
      'confidence': _$DoctorConfidenceEnumMap[instance.confidence]!,
      'causeCode': instance.causeCode,
      'layer': _$DoctorLayerEnumMap[instance.layer]!,
      'startedAt': instance.startedAt,
      'finishedAt': instance.finishedAt,
    };

const _$DoctorExamModeEnumMap = {
  DoctorExamMode.standard: 'standard',
  DoctorExamMode.deep: 'deep',
  DoctorExamMode.unknown: 'unknown',
};

const _$DoctorExamStateEnumMap = {
  DoctorExamState.observing: 'observing',
  DoctorExamState.examining: 'examining',
  DoctorExamState.complete: 'complete',
  DoctorExamState.inconclusive: 'inconclusive',
  DoctorExamState.superseded: 'superseded',
  DoctorExamState.cancelled: 'cancelled',
  DoctorExamState.unknown: 'unknown',
};

const _$DoctorHealthEnumMap = {
  DoctorHealth.unknown: 'unknown',
  DoctorHealth.healthy: 'healthy',
  DoctorHealth.degraded: 'degraded',
  DoctorHealth.broken: 'broken',
};

_DoctorProgress _$DoctorProgressFromJson(Map<String, dynamic> json) =>
    _DoctorProgress(
      phase: json['phase'] as String? ?? '',
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DoctorProgressToJson(_DoctorProgress instance) =>
    <String, dynamic>{
      'phase': instance.phase,
      'completed': instance.completed,
      'total': instance.total,
    };

_DoctorSnapshot _$DoctorSnapshotFromJson(Map<String, dynamic> json) =>
    _DoctorSnapshot(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      supported: json['supported'] as bool? ?? false,
      capabilities: json['capabilities'] == null
          ? const DoctorCapabilities()
          : DoctorCapabilities.fromJson(
              json['capabilities'] as Map<String, dynamic>,
            ),
      state:
          $enumDecodeNullable(
            _$DoctorExamStateEnumMap,
            json['state'],
            unknownValue: DoctorExamState.unknown,
          ) ??
          DoctorExamState.unknown,
      health:
          $enumDecodeNullable(
            _$DoctorHealthEnumMap,
            json['health'],
            unknownValue: DoctorHealth.unknown,
          ) ??
          DoctorHealth.unknown,
      confidence:
          $enumDecodeNullable(
            _$DoctorConfidenceEnumMap,
            json['confidence'],
            unknownValue: DoctorConfidence.unknown,
          ) ??
          DoctorConfidence.unknown,
      severity:
          $enumDecodeNullable(
            _$DoctorSeverityEnumMap,
            json['severity'],
            unknownValue: DoctorSeverity.unknown,
          ) ??
          DoctorSeverity.unknown,
      scope:
          $enumDecodeNullable(
            _$DoctorScopeEnumMap,
            json['scope'],
            unknownValue: DoctorScope.unknown,
          ) ??
          DoctorScope.unknown,
      pathKind:
          $enumDecodeNullable(
            _$DoctorPathKindEnumMap,
            json['pathKind'],
            unknownValue: DoctorPathKind.unknown,
          ) ??
          DoctorPathKind.unknown,
      captureState:
          $enumDecodeNullable(
            _$DoctorCaptureStateEnumMap,
            json['captureState'],
            unknownValue: DoctorCaptureState.unknown,
          ) ??
          DoctorCaptureState.unknown,
      stages:
          (json['stages'] as List<dynamic>?)
              ?.map((e) => DoctorStage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      examId: json['examId'] as String? ?? '',
      mode:
          $enumDecodeNullable(
            _$DoctorExamModeEnumMap,
            json['mode'],
            unknownValue: DoctorExamMode.unknown,
          ) ??
          DoctorExamMode.unknown,
      causeCode: json['causeCode'] as String? ?? '',
      layer:
          $enumDecodeNullable(
            _$DoctorLayerEnumMap,
            json['layer'],
            unknownValue: DoctorLayer.unknown,
          ) ??
          DoctorLayer.unknown,
      progress: json['progress'] == null
          ? const DoctorProgress()
          : DoctorProgress.fromJson(json['progress'] as Map<String, dynamic>),
      generations: json['generations'] == null
          ? const DoctorGenerations()
          : DoctorGenerations.fromJson(
              json['generations'] as Map<String, dynamic>,
            ),
      startGenerations: json['startGenerations'] == null
          ? const DoctorGenerations()
          : DoctorGenerations.fromJson(
              json['startGenerations'] as Map<String, dynamic>,
            ),
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
      freshUntil: (json['freshUntil'] as num?)?.toInt() ?? 0,
      evidenceDropped: (json['evidenceDropped'] as num?)?.toInt() ?? 0,
      evidence:
          (json['evidence'] as List<dynamic>?)
              ?.map((e) => DoctorEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => DoctorAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      healAudit:
          (json['healAudit'] as List<dynamic>?)
              ?.map((e) => DoctorHealAudit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      incidents:
          (json['incidents'] as List<dynamic>?)
              ?.map((e) => DoctorIncident.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DoctorSnapshotToJson(_DoctorSnapshot instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'revision': instance.revision,
      'supported': instance.supported,
      'capabilities': instance.capabilities,
      'state': _$DoctorExamStateEnumMap[instance.state]!,
      'health': _$DoctorHealthEnumMap[instance.health]!,
      'confidence': _$DoctorConfidenceEnumMap[instance.confidence]!,
      'severity': _$DoctorSeverityEnumMap[instance.severity]!,
      'scope': _$DoctorScopeEnumMap[instance.scope]!,
      'pathKind': _$DoctorPathKindEnumMap[instance.pathKind]!,
      'captureState': _$DoctorCaptureStateEnumMap[instance.captureState]!,
      'stages': instance.stages,
      'examId': instance.examId,
      'mode': _$DoctorExamModeEnumMap[instance.mode]!,
      'causeCode': instance.causeCode,
      'layer': _$DoctorLayerEnumMap[instance.layer]!,
      'progress': instance.progress,
      'generations': instance.generations,
      'startGenerations': instance.startGenerations,
      'startedAt': instance.startedAt,
      'updatedAt': instance.updatedAt,
      'freshUntil': instance.freshUntil,
      'evidenceDropped': instance.evidenceDropped,
      'evidence': instance.evidence,
      'actions': instance.actions,
      'healAudit': instance.healAudit,
      'incidents': instance.incidents,
    };

const _$DoctorSeverityEnumMap = {
  DoctorSeverity.info: 'info',
  DoctorSeverity.warning: 'warning',
  DoctorSeverity.critical: 'critical',
  DoctorSeverity.unknown: 'unknown',
};

const _$DoctorScopeEnumMap = {
  DoctorScope.unknown: 'unknown',
  DoctorScope.app: 'app',
  DoctorScope.inbound: 'inbound',
};

const _$DoctorPathKindEnumMap = {
  DoctorPathKind.unknown: 'unknown',
  DoctorPathKind.vpn: 'vpn',
  DoctorPathKind.tun: 'tun',
  DoctorPathKind.localProxy: 'localProxy',
  DoctorPathKind.direct: 'direct',
  DoctorPathKind.byeDpi: 'byeDpi',
};

const _$DoctorCaptureStateEnumMap = {
  DoctorCaptureState.unknown: 'unknown',
  DoctorCaptureState.inactive: 'inactive',
  DoctorCaptureState.active: 'active',
  DoctorCaptureState.notApplicable: 'notApplicable',
};

_DoctorStatus _$DoctorStatusFromJson(Map<String, dynamic> json) =>
    _DoctorStatus(
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      state:
          $enumDecodeNullable(
            _$DoctorExamStateEnumMap,
            json['state'],
            unknownValue: DoctorExamState.unknown,
          ) ??
          DoctorExamState.unknown,
      health:
          $enumDecodeNullable(
            _$DoctorHealthEnumMap,
            json['health'],
            unknownValue: DoctorHealth.unknown,
          ) ??
          DoctorHealth.unknown,
      confidence:
          $enumDecodeNullable(
            _$DoctorConfidenceEnumMap,
            json['confidence'],
            unknownValue: DoctorConfidence.unknown,
          ) ??
          DoctorConfidence.unknown,
      causeCode: json['causeCode'] as String? ?? '',
    );

Map<String, dynamic> _$DoctorStatusToJson(_DoctorStatus instance) =>
    <String, dynamic>{
      'revision': instance.revision,
      'state': _$DoctorExamStateEnumMap[instance.state]!,
      'health': _$DoctorHealthEnumMap[instance.health]!,
      'confidence': _$DoctorConfidenceEnumMap[instance.confidence]!,
      'causeCode': instance.causeCode,
    };

_DoctorStartParams _$DoctorStartParamsFromJson(Map<String, dynamic> json) =>
    _DoctorStartParams(
      mode: $enumDecode(_$DoctorExamModeEnumMap, json['mode']),
    );

Map<String, dynamic> _$DoctorStartParamsToJson(_DoctorStartParams instance) =>
    <String, dynamic>{'mode': _$DoctorExamModeEnumMap[instance.mode]!};

_DoctorCancelParams _$DoctorCancelParamsFromJson(Map<String, dynamic> json) =>
    _DoctorCancelParams(examId: json['examId'] as String);

Map<String, dynamic> _$DoctorCancelParamsToJson(_DoctorCancelParams instance) =>
    <String, dynamic>{'examId': instance.examId};

_DoctorReport _$DoctorReportFromJson(Map<String, dynamic> json) =>
    _DoctorReport(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      coreVersion: json['coreVersion'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      architecture: json['architecture'] as String? ?? '',
      generatedAt: (json['generatedAt'] as num?)?.toInt() ?? 0,
      state:
          $enumDecodeNullable(
            _$DoctorExamStateEnumMap,
            json['state'],
            unknownValue: DoctorExamState.unknown,
          ) ??
          DoctorExamState.unknown,
      health:
          $enumDecodeNullable(
            _$DoctorHealthEnumMap,
            json['health'],
            unknownValue: DoctorHealth.unknown,
          ) ??
          DoctorHealth.unknown,
      confidence:
          $enumDecodeNullable(
            _$DoctorConfidenceEnumMap,
            json['confidence'],
            unknownValue: DoctorConfidence.unknown,
          ) ??
          DoctorConfidence.unknown,
      scope:
          $enumDecodeNullable(
            _$DoctorScopeEnumMap,
            json['scope'],
            unknownValue: DoctorScope.unknown,
          ) ??
          DoctorScope.unknown,
      pathKind:
          $enumDecodeNullable(
            _$DoctorPathKindEnumMap,
            json['pathKind'],
            unknownValue: DoctorPathKind.unknown,
          ) ??
          DoctorPathKind.unknown,
      captureState:
          $enumDecodeNullable(
            _$DoctorCaptureStateEnumMap,
            json['captureState'],
            unknownValue: DoctorCaptureState.unknown,
          ) ??
          DoctorCaptureState.unknown,
      stages:
          (json['stages'] as List<dynamic>?)
              ?.map((e) => DoctorStage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mode:
          $enumDecodeNullable(
            _$DoctorExamModeEnumMap,
            json['mode'],
            unknownValue: DoctorExamMode.unknown,
          ) ??
          DoctorExamMode.unknown,
      causeCode: json['causeCode'] as String? ?? '',
      layer:
          $enumDecodeNullable(
            _$DoctorLayerEnumMap,
            json['layer'],
            unknownValue: DoctorLayer.unknown,
          ) ??
          DoctorLayer.unknown,
      generations: json['generations'] == null
          ? const DoctorGenerations()
          : DoctorGenerations.fromJson(
              json['generations'] as Map<String, dynamic>,
            ),
      evidence:
          (json['evidence'] as List<dynamic>?)
              ?.map((e) => DoctorEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      healAudit:
          (json['healAudit'] as List<dynamic>?)
              ?.map((e) => DoctorHealAudit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      incidents:
          (json['incidents'] as List<dynamic>?)
              ?.map((e) => DoctorIncident.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DoctorReportToJson(_DoctorReport instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'coreVersion': instance.coreVersion,
      'platform': instance.platform,
      'architecture': instance.architecture,
      'generatedAt': instance.generatedAt,
      'state': _$DoctorExamStateEnumMap[instance.state]!,
      'health': _$DoctorHealthEnumMap[instance.health]!,
      'confidence': _$DoctorConfidenceEnumMap[instance.confidence]!,
      'scope': _$DoctorScopeEnumMap[instance.scope]!,
      'pathKind': _$DoctorPathKindEnumMap[instance.pathKind]!,
      'captureState': _$DoctorCaptureStateEnumMap[instance.captureState]!,
      'stages': instance.stages,
      'mode': _$DoctorExamModeEnumMap[instance.mode]!,
      'causeCode': instance.causeCode,
      'layer': _$DoctorLayerEnumMap[instance.layer]!,
      'generations': instance.generations,
      'evidence': instance.evidence,
      'healAudit': instance.healAudit,
      'incidents': instance.incidents,
    };

_DoctorHealParams _$DoctorHealParamsFromJson(Map<String, dynamic> json) =>
    _DoctorHealParams(
      examId: json['examId'] as String,
      revision: (json['revision'] as num).toInt(),
      actionId: json['actionId'] as String? ?? 'flushDns',
    );

Map<String, dynamic> _$DoctorHealParamsToJson(_DoctorHealParams instance) =>
    <String, dynamic>{
      'examId': instance.examId,
      'revision': instance.revision,
      'actionId': instance.actionId,
    };
