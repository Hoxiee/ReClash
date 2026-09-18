// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../subscription_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionVerdict _$SubscriptionVerdictFromJson(Map<String, dynamic> json) =>
    _SubscriptionVerdict(
      headline: json['headline'] as String? ?? '',
      fault:
          $enumDecodeNullable(
            _$SubscriptionFaultEnumMap,
            json['fault'],
            unknownValue: SubscriptionFault.unknown,
          ) ??
          SubscriptionFault.unknown,
      health: json['health'] as String? ?? '',
      causeCode: json['causeCode'] as String? ?? '',
      layer: json['layer'] as String? ?? '',
      terrain: json['terrain'] as String? ?? '',
      env: json['env'] as String? ?? '',
    );

Map<String, dynamic> _$SubscriptionVerdictToJson(
  _SubscriptionVerdict instance,
) => <String, dynamic>{
  'headline': instance.headline,
  'fault': _$SubscriptionFaultEnumMap[instance.fault]!,
  'health': instance.health,
  'causeCode': instance.causeCode,
  'layer': instance.layer,
  'terrain': instance.terrain,
  'env': instance.env,
};

const _$SubscriptionFaultEnumMap = {
  SubscriptionFault.yourNetwork: 'yourNetwork',
  SubscriptionFault.client: 'client',
  SubscriptionFault.subscription: 'subscription',
  SubscriptionFault.server: 'server',
  SubscriptionFault.inconclusive: 'inconclusive',
  SubscriptionFault.unknown: 'unknown',
};

_SubscriptionUpdateStage _$SubscriptionUpdateStageFromJson(
  Map<String, dynamic> json,
) => _SubscriptionUpdateStage(
  stage: json['stage'] as String? ?? '',
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  failures: (json['failures'] as num?)?.toInt() ?? 0,
  dominantError: json['dominantError'] as String? ?? '',
);

Map<String, dynamic> _$SubscriptionUpdateStageToJson(
  _SubscriptionUpdateStage instance,
) => <String, dynamic>{
  'stage': instance.stage,
  'attempts': instance.attempts,
  'failures': instance.failures,
  'dominantError': instance.dominantError,
};

_SubscriptionUpdateHost _$SubscriptionUpdateHostFromJson(
  Map<String, dynamic> json,
) => _SubscriptionUpdateHost(
  host: json['host'] as String? ?? '',
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  failures: (json['failures'] as num?)?.toInt() ?? 0,
  succeeded: json['succeeded'] as bool? ?? false,
  lastError: json['lastError'] as String? ?? '',
);

Map<String, dynamic> _$SubscriptionUpdateHostToJson(
  _SubscriptionUpdateHost instance,
) => <String, dynamic>{
  'host': instance.host,
  'attempts': instance.attempts,
  'failures': instance.failures,
  'succeeded': instance.succeeded,
  'lastError': instance.lastError,
};

_SubscriptionUpdateReport _$SubscriptionUpdateReportFromJson(
  Map<String, dynamic> json,
) => _SubscriptionUpdateReport(
  attempted: json['attempted'] as bool? ?? false,
  succeeded: json['succeeded'] as bool? ?? false,
  generatedAt: (json['generatedAt'] as num?)?.toInt() ?? 0,
  hostCount: (json['hostCount'] as num?)?.toInt() ?? 0,
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  failures: (json['failures'] as num?)?.toInt() ?? 0,
  hwidRejected: json['hwidRejected'] as bool? ?? false,
  emptyResponse: json['emptyResponse'] as bool? ?? false,
  undialable: json['undialable'] as bool? ?? false,
  dominantError: json['dominantError'] as String? ?? '',
  byStage:
      (json['byStage'] as List<dynamic>?)
          ?.map(
            (e) => SubscriptionUpdateStage.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  hosts:
      (json['hosts'] as List<dynamic>?)
          ?.map(
            (e) => SubscriptionUpdateHost.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$SubscriptionUpdateReportToJson(
  _SubscriptionUpdateReport instance,
) => <String, dynamic>{
  'attempted': instance.attempted,
  'succeeded': instance.succeeded,
  'generatedAt': instance.generatedAt,
  'hostCount': instance.hostCount,
  'attempts': instance.attempts,
  'failures': instance.failures,
  'hwidRejected': instance.hwidRejected,
  'emptyResponse': instance.emptyResponse,
  'undialable': instance.undialable,
  'dominantError': instance.dominantError,
  'byStage': instance.byStage,
  'hosts': instance.hosts,
};

_SubscriptionOutcome _$SubscriptionOutcomeFromJson(Map<String, dynamic> json) =>
    _SubscriptionOutcome(
      key: json['key'] as String? ?? '',
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      failure: (json['failure'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SubscriptionOutcomeToJson(
  _SubscriptionOutcome instance,
) => <String, dynamic>{
  'key': instance.key,
  'attempts': instance.attempts,
  'failure': instance.failure,
};

_SubscriptionGroupOutcome _$SubscriptionGroupOutcomeFromJson(
  Map<String, dynamic> json,
) => _SubscriptionGroupOutcome(
  group: json['group'] as String? ?? '',
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  failure: (json['failure'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SubscriptionGroupOutcomeToJson(
  _SubscriptionGroupOutcome instance,
) => <String, dynamic>{
  'group': instance.group,
  'attempts': instance.attempts,
  'failure': instance.failure,
};

_SubscriptionClassCount _$SubscriptionClassCountFromJson(
  Map<String, dynamic> json,
) => _SubscriptionClassCount(
  errorClass: json['class'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SubscriptionClassCountToJson(
  _SubscriptionClassCount instance,
) => <String, dynamic>{'class': instance.errorClass, 'count': instance.count};

_SubscriptionDialReport _$SubscriptionDialReportFromJson(
  Map<String, dynamic> json,
) => _SubscriptionDialReport(
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  success: (json['success'] as num?)?.toInt() ?? 0,
  failure: (json['failure'] as num?)?.toInt() ?? 0,
  byTransport:
      (json['byTransport'] as List<dynamic>?)
          ?.map((e) => SubscriptionOutcome.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  byStage:
      (json['byStage'] as List<dynamic>?)
          ?.map((e) => SubscriptionOutcome.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  byErrorClass:
      (json['byErrorClass'] as List<dynamic>?)
          ?.map(
            (e) => SubscriptionClassCount.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  byProtocol:
      (json['byProtocol'] as List<dynamic>?)
          ?.map((e) => SubscriptionOutcome.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  byGroup:
      (json['byGroup'] as List<dynamic>?)
          ?.map(
            (e) => SubscriptionGroupOutcome.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  byEgress:
      (json['byEgress'] as List<dynamic>?)
          ?.map((e) => SubscriptionOutcome.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SubscriptionDialReportToJson(
  _SubscriptionDialReport instance,
) => <String, dynamic>{
  'attempts': instance.attempts,
  'success': instance.success,
  'failure': instance.failure,
  'byTransport': instance.byTransport,
  'byStage': instance.byStage,
  'byErrorClass': instance.byErrorClass,
  'byProtocol': instance.byProtocol,
  'byGroup': instance.byGroup,
  'byEgress': instance.byEgress,
};

_SubscriptionNodeReport _$SubscriptionNodeReportFromJson(
  Map<String, dynamic> json,
) => _SubscriptionNodeReport(
  alias: json['alias'] as String? ?? '',
  protocol: json['protocol'] as String? ?? '',
  transport: json['transport'] as String? ?? '',
  egressCountry: json['egressCountry'] as String? ?? '',
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  positionHint: (json['positionHint'] as num?)?.toInt() ?? 0,
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  failures: (json['failures'] as num?)?.toInt() ?? 0,
  successes: (json['successes'] as num?)?.toInt() ?? 0,
  failStreak: (json['failStreak'] as num?)?.toInt() ?? 0,
  dominantClass: json['dominantClass'] as String? ?? '',
  delayBucketMs: (json['delayBucketMs'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SubscriptionNodeReportToJson(
  _SubscriptionNodeReport instance,
) => <String, dynamic>{
  'alias': instance.alias,
  'protocol': instance.protocol,
  'transport': instance.transport,
  'egressCountry': instance.egressCountry,
  'groups': instance.groups,
  'positionHint': instance.positionHint,
  'attempts': instance.attempts,
  'failures': instance.failures,
  'successes': instance.successes,
  'failStreak': instance.failStreak,
  'dominantClass': instance.dominantClass,
  'delayBucketMs': instance.delayBucketMs,
};

_SubscriptionReport _$SubscriptionReportFromJson(
  Map<String, dynamic> json,
) => _SubscriptionReport(
  verdict: json['verdict'] == null
      ? null
      : SubscriptionVerdict.fromJson(json['verdict'] as Map<String, dynamic>),
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
  generatedAt: (json['generatedAt'] as num?)?.toInt() ?? 0,
  coreVersion: json['coreVersion'] as String? ?? '',
  appVersion: json['appVersion'] as String? ?? '',
  platform: json['platform'] as String? ?? '',
  architecture: json['architecture'] as String? ?? '',
  windowStart: (json['windowStart'] as num?)?.toInt() ?? 0,
  windowEnd: (json['windowEnd'] as num?)?.toInt() ?? 0,
  terrain: json['terrain'] as String? ?? '',
  env: json['env'] as String? ?? '',
  presets:
      (json['presets'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  droppedEvents: (json['droppedEvents'] as num?)?.toInt() ?? 0,
  configNodeCount: (json['configNodeCount'] as num?)?.toInt() ?? 0,
  observedNodeCount: (json['observedNodeCount'] as num?)?.toInt() ?? 0,
  subscriptionUpdate: json['subscriptionUpdate'] == null
      ? null
      : SubscriptionUpdateReport.fromJson(
          json['subscriptionUpdate'] as Map<String, dynamic>,
        ),
  runtimeDial: json['runtimeDial'] == null
      ? const SubscriptionDialReport()
      : SubscriptionDialReport.fromJson(
          json['runtimeDial'] as Map<String, dynamic>,
        ),
  nodes:
      (json['nodes'] as List<dynamic>?)
          ?.map(
            (e) => SubscriptionNodeReport.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$SubscriptionReportToJson(_SubscriptionReport instance) =>
    <String, dynamic>{
      'verdict': instance.verdict,
      'schemaVersion': instance.schemaVersion,
      'generatedAt': instance.generatedAt,
      'coreVersion': instance.coreVersion,
      'appVersion': instance.appVersion,
      'platform': instance.platform,
      'architecture': instance.architecture,
      'windowStart': instance.windowStart,
      'windowEnd': instance.windowEnd,
      'terrain': instance.terrain,
      'env': instance.env,
      'presets': instance.presets,
      'droppedEvents': instance.droppedEvents,
      'configNodeCount': instance.configNodeCount,
      'observedNodeCount': instance.observedNodeCount,
      'subscriptionUpdate': instance.subscriptionUpdate,
      'runtimeDial': instance.runtimeDial,
      'nodes': instance.nodes,
    };

_SubscriptionNodeLabel _$SubscriptionNodeLabelFromJson(
  Map<String, dynamic> json,
) => _SubscriptionNodeLabel(
  protocol: json['protocol'] as String? ?? '',
  transport: json['transport'] as String? ?? '',
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  positionHint: (json['positionHint'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SubscriptionNodeLabelToJson(
  _SubscriptionNodeLabel instance,
) => <String, dynamic>{
  'protocol': instance.protocol,
  'transport': instance.transport,
  'groups': instance.groups,
  'positionHint': instance.positionHint,
};

_SubscriptionMetadata _$SubscriptionMetadataFromJson(
  Map<String, dynamic> json,
) => _SubscriptionMetadata(
  nodes:
      (json['nodes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          SubscriptionNodeLabel.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  presets:
      (json['presets'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$SubscriptionMetadataToJson(
  _SubscriptionMetadata instance,
) => <String, dynamic>{'nodes': instance.nodes, 'presets': instance.presets};
