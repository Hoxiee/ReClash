// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../rcx.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RcxPool _$RcxPoolFromJson(Map<String, dynamic> json) => _RcxPool(
  include: json['include'] as String?,
  exclude: json['exclude'] as String?,
);

Map<String, dynamic> _$RcxPoolToJson(_RcxPool instance) => <String, dynamic>{
  'include': ?instance.include,
  'exclude': ?instance.exclude,
};

_RcxTier _$RcxTierFromJson(Map<String, dynamic> json) => _RcxTier(
  label: json['label'] as String? ?? '',
  when: json['when'] as String? ?? '',
  lastResort: json['last-resort'] as bool? ?? false,
);

Map<String, dynamic> _$RcxTierToJson(_RcxTier instance) => <String, dynamic>{
  'label': instance.label,
  'when': instance.when,
  'last-resort': instance.lastResort,
};

_RcxChip _$RcxChipFromJson(Map<String, dynamic> json) => _RcxChip(
  label: json['label'] as String,
  include: json['include'] as String,
);

Map<String, dynamic> _$RcxChipToJson(_RcxChip instance) => <String, dynamic>{
  'label': instance.label,
  'include': instance.include,
};

_RcxBinding _$RcxBindingFromJson(Map<String, dynamic> json) => _RcxBinding(
  profiles:
      (json['profiles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  defaultProfile: json['default'] as String?,
  profile: json['profile'] as String?,
  pool: json['pool'] == null
      ? const RcxPool()
      : RcxPool.fromJson(json['pool'] as Map<String, dynamic>),
  feel: json['feel'] as String?,
  energy: json['energy'] as String?,
  chips:
      (json['chips'] as List<dynamic>?)
          ?.map((e) => RcxChip.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  prefer:
      (json['prefer'] as List<dynamic>?)
          ?.map((e) => RcxTier.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  directSplit: json['directSplit'] as bool? ?? false,
);

Map<String, dynamic> _$RcxBindingToJson(_RcxBinding instance) =>
    <String, dynamic>{
      'profiles': instance.profiles,
      'default': ?instance.defaultProfile,
      'profile': ?instance.profile,
      'pool': instance.pool,
      'feel': ?instance.feel,
      'energy': ?instance.energy,
      'chips': instance.chips,
      'prefer': instance.prefer,
      'directSplit': instance.directSplit,
    };

_RcxUserLayer _$RcxUserLayerFromJson(Map<String, dynamic> json) =>
    _RcxUserLayer(
      groups:
          (json['groups'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, RcxBinding.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      profiles:
          (json['profiles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      scenarios:
          (json['scenarios'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      scenario: json['scenario'] as String?,
      scenarioOff: json['scenarioOff'] as bool? ?? false,
      manualMode: json['manualMode'] as bool? ?? false,
      providerHosts:
          (json['providerHosts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      trusted:
          (json['trusted'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxUserLayerToJson(_RcxUserLayer instance) =>
    <String, dynamic>{
      'groups': instance.groups,
      'profiles': instance.profiles,
      'scenarios': instance.scenarios,
      'scenario': ?instance.scenario,
      'scenarioOff': instance.scenarioOff,
      'manualMode': instance.manualMode,
      'providerHosts': instance.providerHosts,
      'trusted': instance.trusted,
    };

_RcxReason _$RcxReasonFromJson(Map<String, dynamic> json) => _RcxReason(
  code: json['code'] as String,
  args: json['args'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$RcxReasonToJson(_RcxReason instance) =>
    <String, dynamic>{'code': instance.code, 'args': instance.args};

_RcxRanked _$RcxRankedFromJson(Map<String, dynamic> json) => _RcxRanked(
  name: json['name'] as String,
  tier: (json['tier'] as num?)?.toInt() ?? 0,
  tierLabel: json['tierLabel'] as String? ?? '',
  health: json['health'] as String? ?? 'unknown',
  latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
  spreadMs: (json['spreadMs'] as num?)?.toInt() ?? 0,
  episodes: (json['episodes'] as num?)?.toInt() ?? 0,
  checkedAt: json['checkedAt'] == null
      ? null
      : DateTime.parse(json['checkedAt'] as String),
  current: json['current'] as bool? ?? false,
  excluded: json['excluded'] == null
      ? null
      : RcxReason.fromJson(json['excluded'] as Map<String, dynamic>),
  exit: json['exit'] as String? ?? '',
  checks:
      (json['checks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  pending: json['pending'] as String? ?? '',
);

Map<String, dynamic> _$RcxRankedToJson(_RcxRanked instance) =>
    <String, dynamic>{
      'name': instance.name,
      'tier': instance.tier,
      'tierLabel': instance.tierLabel,
      'health': instance.health,
      'latencyMs': instance.latencyMs,
      'spreadMs': instance.spreadMs,
      'episodes': instance.episodes,
      'checkedAt': instance.checkedAt?.toIso8601String(),
      'current': instance.current,
      'excluded': instance.excluded,
      'exit': instance.exit,
      'checks': instance.checks,
      'pending': instance.pending,
    };

_RcxDecision _$RcxDecisionFromJson(Map<String, dynamic> json) => _RcxDecision(
  action: json['action'] as String? ?? 'hold',
  target: json['target'] as String? ?? '',
  reason: json['reason'] == null
      ? const RcxReason(code: '')
      : RcxReason.fromJson(json['reason'] as Map<String, dynamic>),
  tier: json['tier'] as String? ?? '',
  until: json['until'] == null
      ? null
      : RcxReason.fromJson(json['until'] as Map<String, dynamic>),
  ranking:
      (json['ranking'] as List<dynamic>?)
          ?.map((e) => RcxRanked.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RcxDecisionToJson(_RcxDecision instance) =>
    <String, dynamic>{
      'action': instance.action,
      'target': instance.target,
      'reason': instance.reason,
      'tier': instance.tier,
      'until': instance.until,
      'ranking': instance.ranking,
    };

_RcxControl _$RcxControlFromJson(Map<String, dynamic> json) => _RcxControl(
  mode: json['mode'] as String? ?? 'auto',
  pinName: json['pinName'] as String? ?? '',
  pinEnv: json['pinEnv'] as String? ?? '',
);

Map<String, dynamic> _$RcxControlToJson(_RcxControl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'pinName': instance.pinName,
      'pinEnv': instance.pinEnv,
    };

_RcxCurrentNode _$RcxCurrentNodeFromJson(Map<String, dynamic> json) =>
    _RcxCurrentNode(
      name: json['name'] as String,
      latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
      health: json['health'] as String? ?? 'unknown',
      since: json['since'] == null
          ? null
          : DateTime.parse(json['since'] as String),
      exit: json['exit'] as String? ?? '',
    );

Map<String, dynamic> _$RcxCurrentNodeToJson(_RcxCurrentNode instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latencyMs': instance.latencyMs,
      'health': instance.health,
      'since': instance.since?.toIso8601String(),
      'exit': instance.exit,
    };

_RcxExcludedNode _$RcxExcludedNodeFromJson(Map<String, dynamic> json) =>
    _RcxExcludedNode(
      name: json['name'] as String,
      until: DateTime.parse(json['until'] as String),
    );

Map<String, dynamic> _$RcxExcludedNodeToJson(_RcxExcludedNode instance) =>
    <String, dynamic>{
      'name': instance.name,
      'until': instance.until.toIso8601String(),
    };

_RcxGroupNetwork _$RcxGroupNetworkFromJson(Map<String, dynamic> json) =>
    _RcxGroupNetwork(
      kind: json['kind'] as String? ?? '',
      next: json['next'] as String? ?? '',
      paused: json['paused'] as bool? ?? false,
      kinds:
          (json['kinds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$RcxGroupNetworkToJson(_RcxGroupNetwork instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'next': instance.next,
      'paused': instance.paused,
      'kinds': instance.kinds,
    };

_RcxGroupStatus _$RcxGroupStatusFromJson(Map<String, dynamic> json) =>
    _RcxGroupStatus(
      name: json['name'] as String,
      source: json['source'] as String? ?? '',
      profile: json['profile'] as String? ?? '',
      profileTitle: json['profileTitle'] as String? ?? '',
      level: json['level'] as String? ?? 'simple',
      offered:
          (json['offered'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      binding: json['binding'] == null
          ? const RcxBinding()
          : RcxBinding.fromJson(json['binding'] as Map<String, dynamic>),
      program: json['program'] as String? ?? '',
      fixed: json['fixed'] as String? ?? '',
      idle: json['idle'] as bool? ?? false,
      route: json['route'] as bool? ?? false,
      control: json['control'] == null
          ? const RcxControl()
          : RcxControl.fromJson(json['control'] as Map<String, dynamic>),
      now: json['now'] as String? ?? '',
      via:
          (json['via'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      decision: json['decision'] == null
          ? const RcxDecision()
          : RcxDecision.fromJson(json['decision'] as Map<String, dynamic>),
      problem: json['problem'] == null
          ? null
          : RcxReason.fromJson(json['problem'] as Map<String, dynamic>),
      members: (json['members'] as num?)?.toInt() ?? 0,
      candidates: (json['candidates'] as num?)?.toInt() ?? 0,
      excluded:
          (json['excluded'] as List<dynamic>?)
              ?.map((e) => RcxExcludedNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      switchesHour: (json['switchesHour'] as num?)?.toInt() ?? 0,
      maxPerHour: (json['maxPerHour'] as num?)?.toInt() ?? 0,
      improve: json['improve'] as bool? ?? false,
      current: json['current'] == null
          ? null
          : RcxCurrentNode.fromJson(json['current'] as Map<String, dynamic>),
      network: json['network'] == null
          ? null
          : RcxGroupNetwork.fromJson(json['network'] as Map<String, dynamic>),
      directSplit: json['directSplit'] as String? ?? '',
    );

Map<String, dynamic> _$RcxGroupStatusToJson(_RcxGroupStatus instance) =>
    <String, dynamic>{
      'name': instance.name,
      'source': instance.source,
      'profile': instance.profile,
      'profileTitle': instance.profileTitle,
      'level': instance.level,
      'offered': instance.offered,
      'binding': instance.binding,
      'program': instance.program,
      'fixed': instance.fixed,
      'idle': instance.idle,
      'route': instance.route,
      'control': instance.control,
      'now': instance.now,
      'via': instance.via,
      'decision': instance.decision,
      'problem': instance.problem,
      'members': instance.members,
      'candidates': instance.candidates,
      'excluded': instance.excluded,
      'switchesHour': instance.switchesHour,
      'maxPerHour': instance.maxPerHour,
      'improve': instance.improve,
      'current': instance.current,
      'network': instance.network,
      'directSplit': instance.directSplit,
    };

_RcxEnergy _$RcxEnergyFromJson(Map<String, dynamic> json) => _RcxEnergy(
  level: json['level'] as String? ?? 'balanced',
  day: json['day'] as String? ?? '',
  requests: (json['requests'] as num?)?.toInt() ?? 0,
  bytes: (json['bytes'] as num?)?.toInt() ?? 0,
  capBytes: (json['capBytes'] as num?)?.toInt() ?? 0,
  hourlyLimits:
      (json['hourlyLimits'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$RcxEnergyToJson(_RcxEnergy instance) =>
    <String, dynamic>{
      'level': instance.level,
      'day': instance.day,
      'requests': instance.requests,
      'bytes': instance.bytes,
      'capBytes': instance.capBytes,
      'hourlyLimits': instance.hourlyLimits,
    };

_RcxStatus _$RcxStatusFromJson(Map<String, dynamic> json) => _RcxStatus(
  running: json['running'] as bool? ?? false,
  mode: json['mode'] as String? ?? 'stopped',
  network: json['network'] as String? ?? '',
  groups:
      (json['groups'] as List<dynamic>?)
          ?.map((e) => RcxGroupStatus.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  energy: json['energy'] == null
      ? const RcxEnergy()
      : RcxEnergy.fromJson(json['energy'] as Map<String, dynamic>),
  problems:
      (json['problems'] as List<dynamic>?)
          ?.map((e) => RcxReason.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  split: json['split'] as String? ?? '',
  library: (json['library'] as num?)?.toInt() ?? 0,
  scenario: json['scenario'] == null
      ? null
      : RcxScenarioStatus.fromJson(json['scenario'] as Map<String, dynamic>),
  tunnelMode: json['tunnelMode'] as String? ?? '',
  reload: json['reload'] as bool? ?? false,
);

Map<String, dynamic> _$RcxStatusToJson(_RcxStatus instance) =>
    <String, dynamic>{
      'running': instance.running,
      'mode': instance.mode,
      'network': instance.network,
      'groups': instance.groups,
      'energy': instance.energy,
      'problems': instance.problems,
      'split': instance.split,
      'library': instance.library,
      'scenario': instance.scenario,
      'tunnelMode': instance.tunnelMode,
      'reload': instance.reload,
    };

_RcxScenarioStatus _$RcxScenarioStatusFromJson(Map<String, dynamic> json) =>
    _RcxScenarioStatus(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? '',
      problem: json['problem'] == null
          ? null
          : RcxReason.fromJson(json['problem'] as Map<String, dynamic>),
      network: json['network'] == null
          ? null
          : RcxGroupNetwork.fromJson(json['network'] as Map<String, dynamic>),
      mode: json['mode'] as String? ?? '',
      manual: json['manual'] as bool? ?? false,
      holdsMode: json['holdsMode'] as bool? ?? false,
      groups:
          (json['groups'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      routes:
          (json['routes'] as List<dynamic>?)
              ?.map((e) => RcxRouteStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxScenarioStatusToJson(_RcxScenarioStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'source': instance.source,
      'problem': instance.problem,
      'network': instance.network,
      'mode': instance.mode,
      'manual': instance.manual,
      'holdsMode': instance.holdsMode,
      'groups': instance.groups,
      'routes': instance.routes,
    };

_RcxRouteStatus _$RcxRouteStatusFromJson(Map<String, dynamic> json) =>
    _RcxRouteStatus(
      name: json['name'] as String,
      to: json['to'] as String? ?? '',
      problem: json['problem'] == null
          ? null
          : RcxReason.fromJson(json['problem'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RcxRouteStatusToJson(_RcxRouteStatus instance) =>
    <String, dynamic>{
      'name': instance.name,
      'to': instance.to,
      'problem': instance.problem,
    };

_RcxExplanation _$RcxExplanationFromJson(Map<String, dynamic> json) =>
    _RcxExplanation(
      group: json['group'] as String,
      profile: json['profile'] as String? ?? '',
      decision: json['decision'] == null
          ? const RcxDecision()
          : RcxDecision.fromJson(json['decision'] as Map<String, dynamic>),
      freshnessSeconds: (json['freshnessSeconds'] as num?)?.toInt() ?? 0,
      at: json['at'] == null ? null : DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$RcxExplanationToJson(_RcxExplanation instance) =>
    <String, dynamic>{
      'group': instance.group,
      'profile': instance.profile,
      'decision': instance.decision,
      'freshnessSeconds': instance.freshnessSeconds,
      'at': instance.at?.toIso8601String(),
    };

_RcxJournalEntry _$RcxJournalEntryFromJson(Map<String, dynamic> json) =>
    _RcxJournalEntry(
      seq: (json['seq'] as num).toInt(),
      at: DateTime.parse(json['at'] as String),
      group: json['group'] as String? ?? '',
      kind: json['kind'] as String,
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      reason: json['reason'] == null
          ? const RcxReason(code: '')
          : RcxReason.fromJson(json['reason'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RcxJournalEntryToJson(_RcxJournalEntry instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'at': instance.at.toIso8601String(),
      'group': instance.group,
      'kind': instance.kind,
      'from': instance.from,
      'to': instance.to,
      'reason': instance.reason,
    };

_RcxProfileInfo _$RcxProfileInfoFromJson(Map<String, dynamic> json) =>
    _RcxProfileInfo(
      id: json['id'] as String,
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as String? ?? '',
      source: json['source'] as String? ?? '',
      extendsId: json['extends'] as String? ?? '',
      error: json['error'] as String? ?? '',
      l10n:
          (json['l10n'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
          ) ??
          const {},
      consent:
          (json['consent'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxProfileInfoToJson(_RcxProfileInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'title': instance.title,
      'description': instance.description,
      'level': instance.level,
      'source': instance.source,
      'extends': instance.extendsId,
      'error': instance.error,
      'l10n': instance.l10n,
      'consent': instance.consent,
    };

_RcxUserProfile _$RcxUserProfileFromJson(Map<String, dynamic> json) =>
    _RcxUserProfile(
      text: json['text'] as String,
      kind: json['kind'] as String? ?? '',
      from: json['from'] as String? ?? '',
      base: json['base'] as String? ?? '',
      history:
          (json['history'] as List<dynamic>?)
              ?.map(
                (e) => RcxProfileVersion.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxUserProfileToJson(_RcxUserProfile instance) =>
    <String, dynamic>{
      'text': instance.text,
      'kind': instance.kind,
      'from': instance.from,
      'base': instance.base,
      'history': instance.history,
    };

_RcxProfileVersion _$RcxProfileVersionFromJson(Map<String, dynamic> json) =>
    _RcxProfileVersion(
      at: DateTime.parse(json['at'] as String),
      text: json['text'] as String,
    );

Map<String, dynamic> _$RcxProfileVersionToJson(_RcxProfileVersion instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'text': instance.text,
    };

_RcxIssue _$RcxIssueFromJson(Map<String, dynamic> json) => _RcxIssue(
  line: (json['line'] as num?)?.toInt() ?? 0,
  path: json['path'] as String? ?? '',
  code: json['code'] as String? ?? '',
  args: json['args'] as Map<String, dynamic>? ?? const {},
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$RcxIssueToJson(_RcxIssue instance) => <String, dynamic>{
  'line': instance.line,
  'path': instance.path,
  'code': instance.code,
  'args': instance.args,
  'message': instance.message,
};

_RcxEndpoint _$RcxEndpointFromJson(Map<String, dynamic> json) => _RcxEndpoint(
  host: json['host'] as String,
  use: json['use'] as String? ?? '',
  target: json['target'] as String? ?? '',
  thirdParty: json['thirdParty'] as bool? ?? false,
);

Map<String, dynamic> _$RcxEndpointToJson(_RcxEndpoint instance) =>
    <String, dynamic>{
      'host': instance.host,
      'use': instance.use,
      'target': instance.target,
      'thirdParty': instance.thirdParty,
    };

_RcxClause _$RcxClauseFromJson(Map<String, dynamic> json) => _RcxClause(
  negated: json['not'] as bool? ?? false,
  field: json['field'] as String,
  op: json['op'] as String? ?? '',
  values:
      (json['values'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  ignoreCase: json['ignoreCase'] as bool? ?? false,
);

Map<String, dynamic> _$RcxClauseToJson(_RcxClause instance) =>
    <String, dynamic>{
      'not': instance.negated,
      'field': instance.field,
      'op': instance.op,
      'values': instance.values,
      'ignoreCase': instance.ignoreCase,
    };

_RcxCondForm _$RcxCondFormFromJson(Map<String, dynamic> json) => _RcxCondForm(
  join: json['join'] as String? ?? 'and',
  clauses:
      (json['clauses'] as List<dynamic>?)
          ?.map((e) => RcxClause.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  flat: json['flat'] as bool? ?? false,
  error: json['error'] as String? ?? '',
);

Map<String, dynamic> _$RcxCondFormToJson(_RcxCondForm instance) =>
    <String, dynamic>{
      'join': instance.join,
      'clauses': instance.clauses,
      'flat': instance.flat,
      'error': instance.error,
    };

_RcxField _$RcxFieldFromJson(Map<String, dynamic> json) => _RcxField(
  name: json['name'] as String,
  kind: json['kind'] as String,
  network: json['network'] as bool? ?? false,
  ops:
      (json['ops'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  values:
      (json['values'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$RcxFieldToJson(_RcxField instance) => <String, dynamic>{
  'name': instance.name,
  'kind': instance.kind,
  'network': instance.network,
  'ops': instance.ops,
  'values': instance.values,
};

_RcxStudioResult _$RcxStudioResultFromJson(Map<String, dynamic> json) =>
    _RcxStudioResult(
      text: json['text'] as String? ?? '',
      profile: json['profile'] as Map<String, dynamic>?,
      scenario: json['scenario'] as Map<String, dynamic>?,
      info: json['info'] == null
          ? null
          : RcxProfileInfo.fromJson(json['info'] as Map<String, dynamic>),
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => RcxIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => RcxIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      endpoints:
          (json['endpoints'] as List<dynamic>?)
              ?.map((e) => RcxEndpoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      form: json['form'] == null
          ? null
          : RcxCondForm.fromJson(json['form'] as Map<String, dynamic>),
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => RcxField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conflicts:
          (json['conflicts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      current: json['current'] == null
          ? null
          : RcxDecision.fromJson(json['current'] as Map<String, dynamic>),
      candidate: json['candidate'] == null
          ? null
          : RcxDecision.fromJson(json['candidate'] as Map<String, dynamic>),
      countries:
          (json['countries'] as List<dynamic>?)
              ?.map((e) => RcxCountry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => RcxBundleItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxStudioResultToJson(_RcxStudioResult instance) =>
    <String, dynamic>{
      'text': instance.text,
      'profile': instance.profile,
      'scenario': instance.scenario,
      'info': instance.info,
      'errors': instance.errors,
      'warnings': instance.warnings,
      'endpoints': instance.endpoints,
      'form': instance.form,
      'fields': instance.fields,
      'conflicts': instance.conflicts,
      'current': instance.current,
      'candidate': instance.candidate,
      'countries': instance.countries,
      'items': instance.items,
    };

_RcxCountry _$RcxCountryFromJson(Map<String, dynamic> json) => _RcxCountry(
  code: json['code'] as String,
  count: (json['count'] as num?)?.toInt() ?? 0,
  verified: json['verified'] as bool? ?? false,
);

Map<String, dynamic> _$RcxCountryToJson(_RcxCountry instance) =>
    <String, dynamic>{
      'code': instance.code,
      'count': instance.count,
      'verified': instance.verified,
    };

_RcxBundleItem _$RcxBundleItemFromJson(Map<String, dynamic> json) =>
    _RcxBundleItem(
      kind: json['kind'] as String? ?? '',
      name: json['name'] as String,
      title: json['title'] as String? ?? '',
      text: json['text'] as String,
    );

Map<String, dynamic> _$RcxBundleItemToJson(_RcxBundleItem instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'name': instance.name,
      'title': instance.title,
      'text': instance.text,
    };
