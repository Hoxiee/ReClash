// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../core.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetupParams _$SetupParamsFromJson(Map<String, dynamic> json) => _SetupParams(
  selectedMap: Map<String, String>.from(json['selected-map'] as Map),
  testUrl: json['test-url'] as String,
);

Map<String, dynamic> _$SetupParamsToJson(_SetupParams instance) =>
    <String, dynamic>{
      'selected-map': instance.selectedMap,
      'test-url': instance.testUrl,
    };

_UpdateParams _$UpdateParamsFromJson(Map<String, dynamic> json) =>
    _UpdateParams(
      tun: Tun.fromJson(json['tun'] as Map<String, dynamic>),
      mixedPort: (json['mixed-port'] as num).toInt(),
      allowLan: json['allow-lan'] as bool,
      findProcessMode: $enumDecode(
        _$FindProcessModeEnumMap,
        json['find-process-mode'],
      ),
      mode: $enumDecode(_$ModeEnumMap, json['mode']),
      logLevel: $enumDecode(_$LogLevelEnumMap, json['log-level']),
      ipv6: json['ipv6'] as bool,
      tcpConcurrent: json['tcp-concurrent'] as bool,
      externalController: $enumDecode(
        _$ExternalControllerStatusEnumMap,
        json['external-controller'],
      ),
      unifiedDelay: json['unified-delay'] as bool,
      authentication:
          (json['authentication'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      geoAutoUpdate: json['geo-auto-update'] as bool? ?? false,
      geoUpdateInterval: (json['geo-update-interval'] as num?)?.toInt() ?? 24,
    );

Map<String, dynamic> _$UpdateParamsToJson(_UpdateParams instance) =>
    <String, dynamic>{
      'tun': instance.tun,
      'mixed-port': instance.mixedPort,
      'allow-lan': instance.allowLan,
      'find-process-mode': _$FindProcessModeEnumMap[instance.findProcessMode]!,
      'mode': _$ModeEnumMap[instance.mode]!,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'ipv6': instance.ipv6,
      'tcp-concurrent': instance.tcpConcurrent,
      'external-controller':
          _$ExternalControllerStatusEnumMap[instance.externalController]!,
      'unified-delay': instance.unifiedDelay,
      'authentication': instance.authentication,
      'geo-auto-update': instance.geoAutoUpdate,
      'geo-update-interval': instance.geoUpdateInterval,
    };

const _$FindProcessModeEnumMap = {
  FindProcessMode.always: 'always',
  FindProcessMode.off: 'off',
};

const _$ModeEnumMap = {
  Mode.rule: 'rule',
  Mode.global: 'global',
  Mode.direct: 'direct',
};

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
};

const _$ExternalControllerStatusEnumMap = {
  ExternalControllerStatus.close: '',
  ExternalControllerStatus.open: '127.0.0.1:9090',
};

_VpnOptions _$VpnOptionsFromJson(Map<String, dynamic> json) => _VpnOptions(
  enable: json['enable'] as bool,
  port: (json['port'] as num).toInt(),
  ipv6: json['ipv6'] as bool,
  dnsHijacking: json['dnsHijacking'] as bool,
  accessControlProps: AccessControlProps.fromJson(
    json['accessControlProps'] as Map<String, dynamic>,
  ),
  allowBypass: json['allowBypass'] as bool,
  systemProxy: json['systemProxy'] as bool,
  bypassDomain: (json['bypassDomain'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  stack: json['stack'] as String,
  routeAddress:
      (json['routeAddress'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  smartPauseEnabled: json['smartPauseEnabled'] as bool? ?? false,
  smartPauseNetworks:
      (json['smartPauseNetworks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  smartPauseCloseConnections:
      json['smartPauseCloseConnections'] as bool? ?? false,
  desyncEnabled: json['desyncEnabled'] as bool? ?? false,
  desyncOnly: json['desyncOnly'] as bool? ?? false,
  desyncPort: (json['desyncPort'] as num?)?.toInt() ?? defaultDesyncPort,
  desyncStrategy:
      (json['desyncStrategy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  desyncCacheTtl:
      (json['desyncCacheTtl'] as num?)?.toInt() ?? defaultDesyncCacheTtl,
  desyncCacheEnabled: json['desyncCacheEnabled'] as bool? ?? true,
  desyncTesting: json['desyncTesting'] as bool? ?? false,
);

Map<String, dynamic> _$VpnOptionsToJson(_VpnOptions instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'port': instance.port,
      'ipv6': instance.ipv6,
      'dnsHijacking': instance.dnsHijacking,
      'accessControlProps': instance.accessControlProps,
      'allowBypass': instance.allowBypass,
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'stack': instance.stack,
      'routeAddress': instance.routeAddress,
      'smartPauseEnabled': instance.smartPauseEnabled,
      'smartPauseNetworks': instance.smartPauseNetworks,
      'smartPauseCloseConnections': instance.smartPauseCloseConnections,
      'desyncEnabled': instance.desyncEnabled,
      'desyncOnly': instance.desyncOnly,
      'desyncPort': instance.desyncPort,
      'desyncStrategy': instance.desyncStrategy,
      'desyncCacheTtl': instance.desyncCacheTtl,
      'desyncCacheEnabled': instance.desyncCacheEnabled,
      'desyncTesting': instance.desyncTesting,
    };

_InitParams _$InitParamsFromJson(Map<String, dynamic> json) => _InitParams(
  homeDir: json['home-dir'] as String,
  version: (json['version'] as num).toInt(),
);

Map<String, dynamic> _$InitParamsToJson(_InitParams instance) =>
    <String, dynamic>{
      'home-dir': instance.homeDir,
      'version': instance.version,
    };

_ChangeProxyParams _$ChangeProxyParamsFromJson(Map<String, dynamic> json) =>
    _ChangeProxyParams(
      groupName: json['group-name'] as String,
      proxyName: json['proxy-name'] as String,
      manual: json['manual'] as bool? ?? false,
    );

Map<String, dynamic> _$ChangeProxyParamsToJson(_ChangeProxyParams instance) =>
    <String, dynamic>{
      'group-name': instance.groupName,
      'proxy-name': instance.proxyName,
      'manual': instance.manual,
    };

_UpdateGeoDataParams _$UpdateGeoDataParamsFromJson(Map<String, dynamic> json) =>
    _UpdateGeoDataParams(
      geoType: json['geo-type'] as String,
      geoName: json['geo-name'] as String,
    );

Map<String, dynamic> _$UpdateGeoDataParamsToJson(
  _UpdateGeoDataParams instance,
) => <String, dynamic>{
  'geo-type': instance.geoType,
  'geo-name': instance.geoName,
};

_CoreEvent _$CoreEventFromJson(Map<String, dynamic> json) => _CoreEvent(
  type: $enumDecode(_$CoreEventTypeEnumMap, json['type']),
  data: json['data'],
);

Map<String, dynamic> _$CoreEventToJson(_CoreEvent instance) =>
    <String, dynamic>{
      'type': _$CoreEventTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$CoreEventTypeEnumMap = {
  CoreEventType.log: 'log',
  CoreEventType.delay: 'delay',
  CoreEventType.request: 'request',
  CoreEventType.loaded: 'loaded',
  CoreEventType.crash: 'crash',
  CoreEventType.geoUpdate: 'geoUpdate',
  CoreEventType.rcxStatus: 'rcxStatus',
  CoreEventType.doctorStatus: 'doctorStatus',
};

_InvokeMessage _$InvokeMessageFromJson(Map<String, dynamic> json) =>
    _InvokeMessage(
      type: $enumDecode(_$InvokeMessageTypeEnumMap, json['type']),
      data: json['data'],
    );

Map<String, dynamic> _$InvokeMessageToJson(_InvokeMessage instance) =>
    <String, dynamic>{
      'type': _$InvokeMessageTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$InvokeMessageTypeEnumMap = {
  InvokeMessageType.protect: 'protect',
  InvokeMessageType.process: 'process',
};

_Delay _$DelayFromJson(Map<String, dynamic> json) => _Delay(
  name: json['name'] as String,
  url: json['url'] as String,
  value: (json['value'] as num?)?.toInt(),
);

Map<String, dynamic> _$DelayToJson(_Delay instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'value': instance.value,
};

_Now _$NowFromJson(Map<String, dynamic> json) =>
    _Now(name: json['name'] as String, value: json['value'] as String);

Map<String, dynamic> _$NowToJson(_Now instance) => <String, dynamic>{
  'name': instance.name,
  'value': instance.value,
};

_ProviderSubscriptionInfo _$ProviderSubscriptionInfoFromJson(
  Map<String, dynamic> json,
) => _ProviderSubscriptionInfo(
  upload: (json['UPLOAD'] as num?)?.toInt() ?? 0,
  download: (json['DOWNLOAD'] as num?)?.toInt() ?? 0,
  total: (json['TOTAL'] as num?)?.toInt() ?? 0,
  expire: (json['EXPIRE'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProviderSubscriptionInfoToJson(
  _ProviderSubscriptionInfo instance,
) => <String, dynamic>{
  'UPLOAD': instance.upload,
  'DOWNLOAD': instance.download,
  'TOTAL': instance.total,
  'EXPIRE': instance.expire,
};

_ExternalProvider _$ExternalProviderFromJson(Map<String, dynamic> json) =>
    _ExternalProvider(
      name: json['name'] as String,
      type: json['type'] as String,
      path: json['path'] as String?,
      count: (json['count'] as num).toInt(),
      subscriptionInfo: subscriptionInfoFormCore(
        json['subscription-info'] as Map<String, Object?>?,
      ),
      vehicleType: json['vehicle-type'] as String,
      updateAt: DateTime.parse(json['update-at'] as String),
    );

Map<String, dynamic> _$ExternalProviderToJson(_ExternalProvider instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'path': instance.path,
      'count': instance.count,
      'subscription-info': instance.subscriptionInfo,
      'vehicle-type': instance.vehicleType,
      'update-at': instance.updateAt.toIso8601String(),
    };

_ProxiesData _$ProxiesDataFromJson(Map<String, dynamic> json) => _ProxiesData(
  proxies: json['proxies'] as Map<String, dynamic>,
  all: (json['all'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ProxiesDataToJson(_ProxiesData instance) =>
    <String, dynamic>{'proxies': instance.proxies, 'all': instance.all};

_ConfigInspection _$ConfigInspectionFromJson(Map<String, dynamic> json) =>
    _ConfigInspection(
      servers:
          (json['servers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      providers: json['providers'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ConfigInspectionToJson(_ConfigInspection instance) =>
    <String, dynamic>{
      'servers': instance.servers,
      'providers': instance.providers,
      'error': instance.error,
    };

_RcxMarker _$RcxMarkerFromJson(Map<String, dynamic> json) => _RcxMarker(
  url: json['url'] as String,
  statuses: (json['statuses'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$RcxMarkerToJson(_RcxMarker instance) =>
    <String, dynamic>{'url': instance.url, 'statuses': instance.statuses};

_RcxLaneSelector _$RcxLaneSelectorFromJson(Map<String, dynamic> json) =>
    _RcxLaneSelector(
      provider: json['p'] as String?,
      nameContains: json['has'] as String?,
    );

Map<String, dynamic> _$RcxLaneSelectorToJson(_RcxLaneSelector instance) =>
    <String, dynamic>{'p': instance.provider, 'has': instance.nameContains};

_RcxLaneConfig _$RcxLaneConfigFromJson(Map<String, dynamic> json) =>
    _RcxLaneConfig(
      capabilityId: json['id'] as String,
      group: json['g'] as String,
      fallback: json['fb'] as String,
      selectors:
          (json['sel'] as List<dynamic>?)
              ?.map((e) => RcxLaneSelector.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxLaneConfigToJson(_RcxLaneConfig instance) =>
    <String, dynamic>{
      'id': instance.capabilityId,
      'g': instance.group,
      'fb': instance.fallback,
      'sel': instance.selectors,
    };

_RcxConfigParams _$RcxConfigParamsFromJson(Map<String, dynamic> json) =>
    _RcxConfigParams(
      enabled: json['on'] as bool,
      preset: json['preset'] as String,
      strategy: json['st'] as String,
      defaultsVersion: (json['dv'] as num).toInt(),
      censorCountries: (json['cc'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      canaryForeign: (json['cf'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      canaryDomestic: (json['cd'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      openMarkers: (json['om'] as List<dynamic>)
          .map((e) => RcxMarker.fromJson(e as Map<String, dynamic>))
          .toList(),
      domesticMarkers: (json['dm'] as List<dynamic>)
          .map((e) => RcxMarker.fromJson(e as Map<String, dynamic>))
          .toList(),
      egressEchoes:
          (json['ee'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      breakerPatterns: (json['bp'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allowDomesticLastResort: json['dlr'] as bool,
      requireUdp: json['udp'] as bool,
      respectPick: json['rpk'] as bool,
      dwellSeconds: (json['dwl'] as num).toInt(),
      waveWidth: (json['ww'] as num).toInt(),
      lanes:
          (json['ln'] as List<dynamic>?)
              ?.map((e) => RcxLaneConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxConfigParamsToJson(_RcxConfigParams instance) =>
    <String, dynamic>{
      'on': instance.enabled,
      'preset': instance.preset,
      'st': instance.strategy,
      'dv': instance.defaultsVersion,
      'cc': instance.censorCountries,
      'cf': instance.canaryForeign,
      'cd': instance.canaryDomestic,
      'om': instance.openMarkers,
      'dm': instance.domesticMarkers,
      'ee': instance.egressEchoes,
      'bp': instance.breakerPatterns,
      'dlr': instance.allowDomesticLastResort,
      'udp': instance.requireUdp,
      'rpk': instance.respectPick,
      'dwl': instance.dwellSeconds,
      'ww': instance.waveWidth,
      'ln': instance.lanes,
    };

_RcxLaneStatus _$RcxLaneStatusFromJson(Map<String, dynamic> json) =>
    _RcxLaneStatus(
      id: json['id'] as String? ?? '',
      group: json['group'] as String? ?? '',
      state: json['state'] as String? ?? 'empty',
      node: json['node'] as String? ?? '',
      candidates: (json['candidates'] as num?)?.toInt() ?? 0,
      eligible: (json['eligible'] as num?)?.toInt() ?? 0,
      searching: json['searching'] as bool? ?? false,
      fallback: json['fallback'] as String? ?? 'main',
      reason: json['reason'] as String? ?? '',
      switchedAt: (json['switchedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RcxLaneStatusToJson(_RcxLaneStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group': instance.group,
      'state': instance.state,
      'node': instance.node,
      'candidates': instance.candidates,
      'eligible': instance.eligible,
      'searching': instance.searching,
      'fallback': instance.fallback,
      'reason': instance.reason,
      'switchedAt': instance.switchedAt,
    };

_RcxStatus _$RcxStatusFromJson(Map<String, dynamic> json) => _RcxStatus(
  enabled: json['enabled'] as bool? ?? false,
  preset: json['preset'] as String? ?? 'off',
  strategy: json['strategy'] as String? ?? 'balanced',
  mode: json['mode'] as String? ?? '',
  terrain: json['terrain'] as String? ?? 'unknown',
  env: json['env'] as String? ?? '',
  node: json['node'] as String? ?? '',
  delay: (json['delay'] as num?)?.toInt() ?? 0,
  reason: json['reason'] as String? ?? '',
  searching: json['searching'] as bool? ?? false,
  deep: json['deep'] as bool? ?? false,
  pinned: json['pinned'] as bool? ?? false,
  pinNode: json['pinNode'] as String? ?? '',
  direct: json['direct'] as String? ?? '',
  candidates: (json['candidates'] as num?)?.toInt() ?? 0,
  eligible: (json['eligible'] as num?)?.toInt() ?? 0,
  switchedAt: (json['switchedAt'] as num?)?.toInt() ?? 0,
  lanes:
      (json['lanes'] as List<dynamic>?)
          ?.map((e) => RcxLaneStatus.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RcxStatusToJson(_RcxStatus instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'preset': instance.preset,
      'strategy': instance.strategy,
      'mode': instance.mode,
      'terrain': instance.terrain,
      'env': instance.env,
      'node': instance.node,
      'delay': instance.delay,
      'reason': instance.reason,
      'searching': instance.searching,
      'deep': instance.deep,
      'pinned': instance.pinned,
      'pinNode': instance.pinNode,
      'direct': instance.direct,
      'candidates': instance.candidates,
      'eligible': instance.eligible,
      'switchedAt': instance.switchedAt,
      'lanes': instance.lanes,
    };

_RcxCandidateReport _$RcxCandidateReportFromJson(Map<String, dynamic> json) =>
    _RcxCandidateReport(
      node: json['node'] as String? ?? '',
      country: json['country'] as String? ?? '',
      exit: json['exit'] as String? ?? '',
      origin: json['origin'] as String? ?? 'unknown',
      verdict: json['verdict'] as String? ?? 'reject',
      evidence: json['evidence'] as String? ?? 'none',
      block: json['block'] as String? ?? '',
      delay: (json['delay'] as num?)?.toInt() ?? 0,
      hostDelay: (json['hostDelay'] as num?)?.toInt() ?? 0,
      band: (json['band'] as num?)?.toInt() ?? 0,
      latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
      unproven: json['unproven'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      degraded: json['degraded'] as bool? ?? false,
      recurrence: (json['recurrence'] as num?)?.toInt() ?? 0,
      confirmed: json['confirmed'] as bool? ?? false,
      breaker: json['breaker'] as bool? ?? false,
      udp: json['udp'] as bool? ?? false,
      fails: (json['fails'] as num?)?.toInt() ?? 0,
      coolFor: (json['coolFor'] as num?)?.toInt() ?? 0,
      current: json['current'] as bool? ?? false,
    );

Map<String, dynamic> _$RcxCandidateReportToJson(_RcxCandidateReport instance) =>
    <String, dynamic>{
      'node': instance.node,
      'country': instance.country,
      'exit': instance.exit,
      'origin': instance.origin,
      'verdict': instance.verdict,
      'evidence': instance.evidence,
      'block': instance.block,
      'delay': instance.delay,
      'hostDelay': instance.hostDelay,
      'band': instance.band,
      'latencyMs': instance.latencyMs,
      'unproven': instance.unproven,
      'order': instance.order,
      'degraded': instance.degraded,
      'recurrence': instance.recurrence,
      'confirmed': instance.confirmed,
      'breaker': instance.breaker,
      'udp': instance.udp,
      'fails': instance.fails,
      'coolFor': instance.coolFor,
      'current': instance.current,
    };

_RcxSwitchReport _$RcxSwitchReportFromJson(Map<String, dynamic> json) =>
    _RcxSwitchReport(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      at: (json['at'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RcxSwitchReportToJson(_RcxSwitchReport instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'reason': instance.reason,
      'at': instance.at,
    };

_RcxCanaryReport _$RcxCanaryReportFromJson(Map<String, dynamic> json) =>
    _RcxCanaryReport(
      addr: json['addr'] as String? ?? '',
      domestic: json['domestic'] as bool? ?? false,
      outcome: json['outcome'] as String? ?? 'unknown',
      delay: (json['delay'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RcxCanaryReportToJson(_RcxCanaryReport instance) =>
    <String, dynamic>{
      'addr': instance.addr,
      'domestic': instance.domestic,
      'outcome': instance.outcome,
      'delay': instance.delay,
    };

_RcxLinkReport _$RcxLinkReportFromJson(Map<String, dynamic> json) =>
    _RcxLinkReport(
      transport: json['transport'] as String? ?? '',
      validated: json['validated'] as bool? ?? false,
      portal: json['portal'] as bool? ?? false,
      metered: json['metered'] as bool? ?? false,
      foreign: json['foreign'] as String? ?? 'unknown',
      domestic: json['domestic'] as String? ?? 'unknown',
      since: (json['since'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RcxLinkReportToJson(_RcxLinkReport instance) =>
    <String, dynamic>{
      'transport': instance.transport,
      'validated': instance.validated,
      'portal': instance.portal,
      'metered': instance.metered,
      'foreign': instance.foreign,
      'domestic': instance.domestic,
      'since': instance.since,
    };

_RcxMetricsReport _$RcxMetricsReportFromJson(Map<String, dynamic> json) =>
    _RcxMetricsReport(
      enabledMillis: (json['enabledMillis'] as num?)?.toInt() ?? 0,
      availableMillis: (json['availableMillis'] as num?)?.toInt() ?? 0,
      availability: (json['availability'] as num?)?.toInt() ?? 0,
      incidents: (json['incidents'] as num?)?.toInt() ?? 0,
      standbyHits: (json['standbyHits'] as num?)?.toInt() ?? 0,
      providerIncidents: (json['providerIncidents'] as num?)?.toInt() ?? 0,
      markerIncidents: (json['markerIncidents'] as num?)?.toInt() ?? 0,
      lastFailover: (json['lastFailover'] as num?)?.toInt() ?? 0,
      averageFailover: (json['averageFailover'] as num?)?.toInt() ?? 0,
      lastOutage: (json['lastOutage'] as num?)?.toInt() ?? 0,
      averageOutage: (json['averageOutage'] as num?)?.toInt() ?? 0,
      activeCircuits:
          (json['activeCircuits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      activeMarkers:
          (json['activeMarkers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RcxMetricsReportToJson(_RcxMetricsReport instance) =>
    <String, dynamic>{
      'enabledMillis': instance.enabledMillis,
      'availableMillis': instance.availableMillis,
      'availability': instance.availability,
      'incidents': instance.incidents,
      'standbyHits': instance.standbyHits,
      'providerIncidents': instance.providerIncidents,
      'markerIncidents': instance.markerIncidents,
      'lastFailover': instance.lastFailover,
      'averageFailover': instance.averageFailover,
      'lastOutage': instance.lastOutage,
      'averageOutage': instance.averageOutage,
      'activeCircuits': instance.activeCircuits,
      'activeMarkers': instance.activeMarkers,
    };

_RcxDiscoveryReport _$RcxDiscoveryReportFromJson(Map<String, dynamic> json) =>
    _RcxDiscoveryReport(
      covered: (json['covered'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      state: json['state'] as String? ?? '',
    );

Map<String, dynamic> _$RcxDiscoveryReportToJson(_RcxDiscoveryReport instance) =>
    <String, dynamic>{
      'covered': instance.covered,
      'pending': instance.pending,
      'attempts': instance.attempts,
      'confirmations': instance.confirmations,
      'state': instance.state,
    };

_RcxReport _$RcxReportFromJson(Map<String, dynamic> json) => _RcxReport(
  status: json['status'] == null
      ? const RcxStatus()
      : RcxStatus.fromJson(json['status'] as Map<String, dynamic>),
  link: json['link'] == null
      ? const RcxLinkReport()
      : RcxLinkReport.fromJson(json['link'] as Map<String, dynamic>),
  canaries:
      (json['canaries'] as List<dynamic>?)
          ?.map((e) => RcxCanaryReport.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  candidates:
      (json['candidates'] as List<dynamic>?)
          ?.map((e) => RcxCandidateReport.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => RcxSwitchReport.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  metrics: json['metrics'] == null
      ? const RcxMetricsReport()
      : RcxMetricsReport.fromJson(json['metrics'] as Map<String, dynamic>),
  bands:
      (json['bands'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  probesLeft: (json['probesLeft'] as num?)?.toInt() ?? 0,
  probeCap: (json['probeCap'] as num?)?.toInt() ?? 0,
  manual: json['manual'] as bool? ?? false,
  discovery: json['discovery'] == null
      ? const RcxDiscoveryReport()
      : RcxDiscoveryReport.fromJson(json['discovery'] as Map<String, dynamic>),
  at: (json['at'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RcxReportToJson(_RcxReport instance) =>
    <String, dynamic>{
      'status': instance.status,
      'link': instance.link,
      'canaries': instance.canaries,
      'candidates': instance.candidates,
      'history': instance.history,
      'metrics': instance.metrics,
      'bands': instance.bands,
      'probesLeft': instance.probesLeft,
      'probeCap': instance.probeCap,
      'manual': instance.manual,
      'discovery': instance.discovery,
      'at': instance.at,
    };
