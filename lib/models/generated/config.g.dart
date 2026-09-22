// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationComponent _$NotificationComponentFromJson(
  Map<String, dynamic> json,
) => _NotificationComponent(
  type: $enumDecode(_$NotificationComponentTypeEnumMap, json['type']),
  doctorPriority: $enumDecodeNullable(
    _$DoctorNotificationPriorityEnumMap,
    json['doctorPriority'],
  ),
  hideWhenIdle: json['hideWhenIdle'] as bool?,
  group: json['group'] as String?,
);

Map<String, dynamic> _$NotificationComponentToJson(
  _NotificationComponent instance,
) => <String, dynamic>{
  'type': _$NotificationComponentTypeEnumMap[instance.type]!,
  'doctorPriority':
      _$DoctorNotificationPriorityEnumMap[instance.doctorPriority],
  'hideWhenIdle': instance.hideWhenIdle,
  'group': instance.group,
};

const _$NotificationComponentTypeEnumMap = {
  NotificationComponentType.connectionDoctor: 'connectionDoctor',
  NotificationComponentType.networkState: 'networkState',
  NotificationComponentType.currentServer: 'currentServer',
  NotificationComponentType.smartRouting: 'smartRouting',
  NotificationComponentType.speed: 'speed',
  NotificationComponentType.sessionTraffic: 'sessionTraffic',
};

const _$DoctorNotificationPriorityEnumMap = {
  DoctorNotificationPriority.problems: 'problems',
  DoctorNotificationPriority.always: 'always',
};

_NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _NotificationSettings(
  components: json['components'] == null
      ? defaultNotificationComponents
      : notificationComponentsSafeFromJson(json['components']),
  visibility:
      $enumDecodeNullable(
        _$NotificationVisibilityEnumMap,
        json['visibility'],
      ) ??
      NotificationVisibility.detailed,
  showPauseAction: json['showPauseAction'] as bool? ?? true,
  showStopAction: json['showStopAction'] as bool? ?? true,
  hideSensitiveOnLockScreen: json['hideSensitiveOnLockScreen'] as bool? ?? true,
  subscriptionReminders: json['subscriptionReminders'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'components': instance.components,
  'visibility': _$NotificationVisibilityEnumMap[instance.visibility]!,
  'showPauseAction': instance.showPauseAction,
  'showStopAction': instance.showStopAction,
  'hideSensitiveOnLockScreen': instance.hideSensitiveOnLockScreen,
  'subscriptionReminders': instance.subscriptionReminders,
};

const _$NotificationVisibilityEnumMap = {
  NotificationVisibility.detailed: 'detailed',
  NotificationVisibility.minimal: 'minimal',
};

_AppSettingProps _$AppSettingPropsFromJson(Map<String, dynamic> json) =>
    _AppSettingProps(
      locale: json['locale'] as String?,
      region: $enumDecodeNullable(
        _$AppRegionEnumMap,
        json['region'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      dashboardWidgets: json['dashboardWidgets'] == null
          ? defaultDashboardWidgets
          : dashboardWidgetsSafeFormJson(json['dashboardWidgets'] as List?),
      onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool? ?? false,
      notificationSettings: json['notificationSettings'] == null
          ? defaultNotificationSettings
          : NotificationSettings.fromJson(
              json['notificationSettings'] as Map<String, dynamic>,
            ),
      autoLaunch: json['autoLaunch'] as bool? ?? false,
      silentLaunch: json['silentLaunch'] as bool? ?? false,
      highPriorityAutoLaunch: json['highPriorityAutoLaunch'] as bool? ?? false,
      autoRun: json['autoRun'] as bool? ?? false,
      openLogs: json['openLogs'] as bool? ?? false,
      closeConnections: json['closeConnections'] as bool? ?? true,
      newDashboard: json['newDashboard'] as bool? ?? true,
      testUrl: json['testUrl'] as String? ?? defaultTestUrl,
      isAnimateToPage: json['isAnimateToPage'] as bool? ?? true,
      autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? false,
      showLabel: json['showLabel'] as bool? ?? false,
      disclaimerAccepted: json['disclaimerAccepted'] as bool? ?? false,
      setupCompleted: json['setupCompleted'] as bool? ?? false,
      setupStep: (json['setupStep'] as num?)?.toInt() ?? 0,
      crashlyticsTip: json['crashlyticsTip'] as bool? ?? false,
      crashlytics: json['crashlytics'] as bool? ?? false,
      minimizeOnExit: json['minimizeOnExit'] as bool? ?? true,
      hidden: json['hidden'] as bool? ?? false,
      developerMode: json['developerMode'] as bool? ?? false,
      restoreStrategy:
          $enumDecodeNullable(
            _$RestoreStrategyEnumMap,
            json['restoreStrategy'],
          ) ??
          RestoreStrategy.compatible,
      showTrayTitle: json['showTrayTitle'] as bool? ?? true,
      checkCertificate: json['checkCertificate'] as bool? ?? true,
      customUserAgent: json['customUserAgent'] as String? ?? '',
      sendDeviceIdentity: json['sendDeviceIdentity'] as bool? ?? false,
      iconVariant: json['iconVariant'] as String? ?? 'default',
      reduceMotion: json['reduceMotion'] as bool? ?? false,
    );

Map<String, dynamic> _$AppSettingPropsToJson(_AppSettingProps instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'region': _$AppRegionEnumMap[instance.region],
      'dashboardWidgets': instance.dashboardWidgets
          .map((e) => _$DashboardWidgetEnumMap[e]!)
          .toList(),
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'notificationSettings': instance.notificationSettings,
      'autoLaunch': instance.autoLaunch,
      'silentLaunch': instance.silentLaunch,
      'highPriorityAutoLaunch': instance.highPriorityAutoLaunch,
      'autoRun': instance.autoRun,
      'openLogs': instance.openLogs,
      'closeConnections': instance.closeConnections,
      'newDashboard': instance.newDashboard,
      'testUrl': instance.testUrl,
      'isAnimateToPage': instance.isAnimateToPage,
      'autoCheckUpdate': instance.autoCheckUpdate,
      'showLabel': instance.showLabel,
      'disclaimerAccepted': instance.disclaimerAccepted,
      'setupCompleted': instance.setupCompleted,
      'setupStep': instance.setupStep,
      'crashlyticsTip': instance.crashlyticsTip,
      'crashlytics': instance.crashlytics,
      'minimizeOnExit': instance.minimizeOnExit,
      'hidden': instance.hidden,
      'developerMode': instance.developerMode,
      'restoreStrategy': _$RestoreStrategyEnumMap[instance.restoreStrategy]!,
      'showTrayTitle': instance.showTrayTitle,
      'checkCertificate': instance.checkCertificate,
      'customUserAgent': instance.customUserAgent,
      'sendDeviceIdentity': instance.sendDeviceIdentity,
      'iconVariant': instance.iconVariant,
      'reduceMotion': instance.reduceMotion,
    };

const _$AppRegionEnumMap = {
  AppRegion.russia: 'ru',
  AppRegion.iran: 'ir',
  AppRegion.china: 'cn',
  AppRegion.other: 'other',
};

const _$RestoreStrategyEnumMap = {
  RestoreStrategy.compatible: 'compatible',
  RestoreStrategy.override: 'override',
};

const _$DashboardWidgetEnumMap = {
  DashboardWidget.networkSpeed: 'networkSpeed',
  DashboardWidget.outboundModeV2: 'outboundModeV2',
  DashboardWidget.outboundMode: 'outboundMode',
  DashboardWidget.trafficUsage: 'trafficUsage',
  DashboardWidget.networkDetection: 'networkDetection',
  DashboardWidget.tunButton: 'tunButton',
  DashboardWidget.vpnButton: 'vpnButton',
  DashboardWidget.systemProxyButton: 'systemProxyButton',
  DashboardWidget.intranetIp: 'intranetIp',
  DashboardWidget.memoryInfo: 'memoryInfo',
  DashboardWidget.goroutineInfo: 'goroutineInfo',
  DashboardWidget.metaInfo: 'metaInfo',
  DashboardWidget.announce: 'announce',
  DashboardWidget.serviceInfo: 'serviceInfo',
  DashboardWidget.changeServerButton: 'changeServerButton',
  DashboardWidget.smartRouting: 'smartRouting',
  DashboardWidget.desyncStrategy: 'desyncStrategy',
  DashboardWidget.desyncTest: 'desyncTest',
  DashboardWidget.desyncEngine: 'desyncEngine',
};

_AccessControlProps _$AccessControlPropsFromJson(Map<String, dynamic> json) =>
    _AccessControlProps(
      enable: json['enable'] as bool? ?? false,
      mode:
          $enumDecodeNullable(_$AccessControlModeEnumMap, json['mode']) ??
          AccessControlMode.rejectSelected,
      acceptList:
          (json['acceptList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rejectList:
          (json['rejectList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sort:
          $enumDecodeNullable(_$AccessSortTypeEnumMap, json['sort']) ??
          AccessSortType.none,
      isFilterSystemApp: json['isFilterSystemApp'] as bool? ?? true,
      isFilterNonInternetApp: json['isFilterNonInternetApp'] as bool? ?? true,
    );

Map<String, dynamic> _$AccessControlPropsToJson(_AccessControlProps instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'mode': _$AccessControlModeEnumMap[instance.mode]!,
      'acceptList': instance.acceptList,
      'rejectList': instance.rejectList,
      'sort': _$AccessSortTypeEnumMap[instance.sort]!,
      'isFilterSystemApp': instance.isFilterSystemApp,
      'isFilterNonInternetApp': instance.isFilterNonInternetApp,
    };

const _$AccessControlModeEnumMap = {
  AccessControlMode.acceptSelected: 'acceptSelected',
  AccessControlMode.rejectSelected: 'rejectSelected',
};

const _$AccessSortTypeEnumMap = {
  AccessSortType.none: 'none',
  AccessSortType.name: 'name',
  AccessSortType.time: 'time',
};

_WindowProps _$WindowPropsFromJson(Map<String, dynamic> json) => _WindowProps(
  width: (json['width'] as num?)?.toDouble() ?? 0,
  height: (json['height'] as num?)?.toDouble() ?? 0,
  top: (json['top'] as num?)?.toDouble(),
  left: (json['left'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WindowPropsToJson(_WindowProps instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'top': instance.top,
      'left': instance.left,
    };

_VpnProps _$VpnPropsFromJson(Map<String, dynamic> json) => _VpnProps(
  enable: json['enable'] as bool? ?? true,
  systemProxy: json['systemProxy'] as bool? ?? true,
  ipv6: json['ipv6'] as bool? ?? false,
  allowBypass: json['allowBypass'] as bool? ?? true,
  dnsHijacking: json['dnsHijacking'] as bool? ?? false,
  smartPauseEnabled: json['smartPauseEnabled'] as bool? ?? false,
  smartPauseNetworks:
      (json['smartPauseNetworks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  smartPauseCloseConnections:
      json['smartPauseCloseConnections'] as bool? ?? false,
  accessControlProps: json['accessControlProps'] == null
      ? defaultAccessControlProps
      : AccessControlProps.fromJson(
          json['accessControlProps'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$VpnPropsToJson(_VpnProps instance) => <String, dynamic>{
  'enable': instance.enable,
  'systemProxy': instance.systemProxy,
  'ipv6': instance.ipv6,
  'allowBypass': instance.allowBypass,
  'dnsHijacking': instance.dnsHijacking,
  'smartPauseEnabled': instance.smartPauseEnabled,
  'smartPauseNetworks': instance.smartPauseNetworks,
  'smartPauseCloseConnections': instance.smartPauseCloseConnections,
  'accessControlProps': instance.accessControlProps,
};

_SmartRoutingProps _$SmartRoutingPropsFromJson(
  Map<String, dynamic> json,
) => _SmartRoutingProps(
  enabled: json['enabled'] as bool? ?? false,
  preset:
      $enumDecodeNullable(_$SmartRoutingPresetEnumMap, json['preset']) ??
      SmartRoutingPreset.off,
  strategy:
      $enumDecodeNullable(_$SmartRoutingStrategyEnumMap, json['strategy']) ??
      SmartRoutingStrategy.balanced,
  censorCountries:
      (json['censorCountries'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  canaryForeign:
      (json['canaryForeign'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  canaryDomestic:
      (json['canaryDomestic'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  openMarkers:
      (json['openMarkers'] as List<dynamic>?)
          ?.map((e) => RcxMarker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  domesticMarkers:
      (json['domesticMarkers'] as List<dynamic>?)
          ?.map((e) => RcxMarker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  localMarkers:
      (json['localMarkers'] as List<dynamic>?)
          ?.map((e) => RcxMarker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  nameHints:
      (json['nameHints'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  egressEchoes:
      (json['egressEchoes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  countryEchoes:
      (json['countryEchoes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  breakerPatterns:
      (json['breakerPatterns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  nodeRules:
      (json['nodeRules'] as List<dynamic>?)
          ?.map((e) => RcxNodeRule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  avoidCountries:
      (json['avoidCountries'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  latencyBands:
      (json['latencyBands'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  allowDomesticLastResort: json['allowDomesticLastResort'] as bool? ?? true,
  requireUdp: json['requireUdp'] as bool? ?? false,
  respectPick: json['respectPick'] as bool? ?? true,
  dwellSeconds: (json['dwellSeconds'] as num?)?.toInt() ?? 90,
  waveWidth: (json['waveWidth'] as num?)?.toInt() ?? 12,
);

Map<String, dynamic> _$SmartRoutingPropsToJson(
  _SmartRoutingProps instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'preset': _$SmartRoutingPresetEnumMap[instance.preset]!,
  'strategy': _$SmartRoutingStrategyEnumMap[instance.strategy]!,
  'censorCountries': instance.censorCountries,
  'canaryForeign': instance.canaryForeign,
  'canaryDomestic': instance.canaryDomestic,
  'openMarkers': instance.openMarkers.map((e) => e.toJson()).toList(),
  'domesticMarkers': instance.domesticMarkers.map((e) => e.toJson()).toList(),
  'localMarkers': instance.localMarkers.map((e) => e.toJson()).toList(),
  'nameHints': instance.nameHints,
  'egressEchoes': instance.egressEchoes,
  'countryEchoes': instance.countryEchoes,
  'breakerPatterns': instance.breakerPatterns,
  'nodeRules': instance.nodeRules.map((e) => e.toJson()).toList(),
  'avoidCountries': instance.avoidCountries,
  'latencyBands': instance.latencyBands,
  'allowDomesticLastResort': instance.allowDomesticLastResort,
  'requireUdp': instance.requireUdp,
  'respectPick': instance.respectPick,
  'dwellSeconds': instance.dwellSeconds,
  'waveWidth': instance.waveWidth,
};

const _$SmartRoutingPresetEnumMap = {
  SmartRoutingPreset.off: 'off',
  SmartRoutingPreset.russia: 'ru',
  SmartRoutingPreset.iran: 'ir',
  SmartRoutingPreset.china: 'cn',
};

const _$SmartRoutingStrategyEnumMap = {
  SmartRoutingStrategy.stable: 'stable',
  SmartRoutingStrategy.balanced: 'balanced',
  SmartRoutingStrategy.lowestLatency: 'lowest-latency',
  SmartRoutingStrategy.saver: 'saver',
};

_AuthenticationProps _$AuthenticationPropsFromJson(Map<String, dynamic> json) =>
    _AuthenticationProps(
      enable: json['enable'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );

Map<String, dynamic> _$AuthenticationPropsToJson(
  _AuthenticationProps instance,
) => <String, dynamic>{
  'enable': instance.enable,
  'username': instance.username,
  'password': instance.password,
};

_NetworkProps _$NetworkPropsFromJson(Map<String, dynamic> json) =>
    _NetworkProps(
      systemProxy: json['systemProxy'] as bool? ?? true,
      bypassDomain:
          (json['bypassDomain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          defaultBypassDomain,
      routeMode:
          $enumDecodeNullable(_$RouteModeEnumMap, json['routeMode']) ??
          RouteMode.config,
      autoSetSystemDns: json['autoSetSystemDns'] as bool? ?? true,
      appendSystemDns: json['appendSystemDns'] as bool? ?? false,
      overrideSubscriptionNetwork:
          json['overrideSubscriptionNetwork'] as bool? ?? false,
      authentication: json['authentication'] == null
          ? defaultAuthenticationProps
          : AuthenticationProps.fromJson(
              json['authentication'] as Map<String, dynamic>?,
            ),
    );

Map<String, dynamic> _$NetworkPropsToJson(_NetworkProps instance) =>
    <String, dynamic>{
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'routeMode': _$RouteModeEnumMap[instance.routeMode]!,
      'autoSetSystemDns': instance.autoSetSystemDns,
      'appendSystemDns': instance.appendSystemDns,
      'overrideSubscriptionNetwork': instance.overrideSubscriptionNetwork,
      'authentication': instance.authentication,
    };

const _$RouteModeEnumMap = {
  RouteMode.bypassPrivate: 'bypassPrivate',
  RouteMode.config: 'config',
};

_ProxiesStyleProps _$ProxiesStylePropsFromJson(Map<String, dynamic> json) =>
    _ProxiesStyleProps(
      type:
          $enumDecodeNullable(_$ProxiesTypeEnumMap, json['type']) ??
          ProxiesType.tab,
      sortType:
          $enumDecodeNullable(_$ProxiesSortTypeEnumMap, json['sortType']) ??
          ProxiesSortType.none,
      layout:
          $enumDecodeNullable(_$ProxiesLayoutEnumMap, json['layout']) ??
          ProxiesLayout.standard,
      iconStyle:
          $enumDecodeNullable(_$ProxiesIconStyleEnumMap, json['iconStyle']) ??
          ProxiesIconStyle.standard,
      cardType:
          $enumDecodeNullable(_$ProxyCardTypeEnumMap, json['cardType']) ??
          ProxyCardType.expand,
      followPanel: json['followPanel'] as bool? ?? true,
      userOwned:
          (json['userOwned'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ProxiesStyleFieldEnumMap, e))
              .toSet() ??
          const <ProxiesStyleField>{},
    );

Map<String, dynamic> _$ProxiesStylePropsToJson(_ProxiesStyleProps instance) =>
    <String, dynamic>{
      'type': _$ProxiesTypeEnumMap[instance.type]!,
      'sortType': _$ProxiesSortTypeEnumMap[instance.sortType]!,
      'layout': _$ProxiesLayoutEnumMap[instance.layout]!,
      'iconStyle': _$ProxiesIconStyleEnumMap[instance.iconStyle]!,
      'cardType': _$ProxyCardTypeEnumMap[instance.cardType]!,
      'followPanel': instance.followPanel,
      'userOwned': instance.userOwned
          .map((e) => _$ProxiesStyleFieldEnumMap[e]!)
          .toList(),
    };

const _$ProxiesTypeEnumMap = {ProxiesType.tab: 'tab', ProxiesType.list: 'list'};

const _$ProxiesSortTypeEnumMap = {
  ProxiesSortType.none: 'none',
  ProxiesSortType.delay: 'delay',
  ProxiesSortType.name: 'name',
};

const _$ProxiesLayoutEnumMap = {
  ProxiesLayout.loose: 'loose',
  ProxiesLayout.standard: 'standard',
  ProxiesLayout.tight: 'tight',
};

const _$ProxiesIconStyleEnumMap = {
  ProxiesIconStyle.none: 'none',
  ProxiesIconStyle.standard: 'standard',
  ProxiesIconStyle.icon: 'icon',
};

const _$ProxyCardTypeEnumMap = {
  ProxyCardType.expand: 'expand',
  ProxyCardType.shrink: 'shrink',
  ProxyCardType.min: 'min',
};

const _$ProxiesStyleFieldEnumMap = {
  ProxiesStyleField.type: 'type',
  ProxiesStyleField.sortType: 'sortType',
  ProxiesStyleField.layout: 'layout',
  ProxiesStyleField.iconStyle: 'iconStyle',
  ProxiesStyleField.cardType: 'cardType',
};

_TextScale _$TextScaleFromJson(Map<String, dynamic> json) => _TextScale(
  enable: json['enable'] as bool? ?? false,
  scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$TextScaleToJson(_TextScale instance) =>
    <String, dynamic>{'enable': instance.enable, 'scale': instance.scale};

_ThemeProps _$ThemePropsFromJson(Map<String, dynamic> json) => _ThemeProps(
  primaryColor: (json['primaryColor'] as num?)?.toInt(),
  primaryColors:
      (json['primaryColors'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      defaultPrimaryColors,
  themeMode:
      $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
      ThemeMode.dark,
  scheduledTheme: json['scheduledTheme'] as bool? ?? false,
  darkAt: json['darkAt'] as String?,
  lightAt: json['lightAt'] as String?,
  schemeVariant:
      $enumDecodeNullable(
        _$DynamicSchemeVariantEnumMap,
        json['schemeVariant'],
      ) ??
      DynamicSchemeVariant.content,
  pureBlack: json['pureBlack'] as bool? ?? false,
  contrastLevel: (json['contrastLevel'] as num?)?.toDouble() ?? 0,
  textScale: json['textScale'] == null
      ? const TextScale()
      : TextScale.fromJson(json['textScale'] as Map<String, dynamic>),
  wallpaper: json['wallpaper'] == null
      ? const WallpaperProps()
      : WallpaperProps.safeFromJson(json['wallpaper']),
);

Map<String, dynamic> _$ThemePropsToJson(_ThemeProps instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'primaryColors': instance.primaryColors,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'scheduledTheme': instance.scheduledTheme,
      'darkAt': instance.darkAt,
      'lightAt': instance.lightAt,
      'schemeVariant': _$DynamicSchemeVariantEnumMap[instance.schemeVariant]!,
      'pureBlack': instance.pureBlack,
      'contrastLevel': instance.contrastLevel,
      'textScale': instance.textScale,
      'wallpaper': instance.wallpaper,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$DynamicSchemeVariantEnumMap = {
  DynamicSchemeVariant.tonalSpot: 'tonalSpot',
  DynamicSchemeVariant.fidelity: 'fidelity',
  DynamicSchemeVariant.monochrome: 'monochrome',
  DynamicSchemeVariant.neutral: 'neutral',
  DynamicSchemeVariant.vibrant: 'vibrant',
  DynamicSchemeVariant.expressive: 'expressive',
  DynamicSchemeVariant.content: 'content',
  DynamicSchemeVariant.rainbow: 'rainbow',
  DynamicSchemeVariant.fruitSalad: 'fruitSalad',
};

_MilestoneProps _$MilestonePropsFromJson(Map<String, dynamic> json) =>
    _MilestoneProps(
      unlocked:
          (json['unlocked'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      revealedAt:
          (json['revealedAt'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      revealQueue:
          (json['revealQueue'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      findingsEnabled: json['findingsEnabled'] as bool? ?? true,
      seasonalEnabled: json['seasonalEnabled'] as bool? ?? true,
      providerEffectsEnabled: json['providerEffectsEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$MilestonePropsToJson(_MilestoneProps instance) =>
    <String, dynamic>{
      'unlocked': instance.unlocked.toList(),
      'revealedAt': instance.revealedAt,
      'revealQueue': instance.revealQueue,
      'findingsEnabled': instance.findingsEnabled,
      'seasonalEnabled': instance.seasonalEnabled,
      'providerEffectsEnabled': instance.providerEffectsEnabled,
    };

_Config _$ConfigFromJson(Map<String, dynamic> json) => _Config(
  currentProfileId: (json['currentProfileId'] as num?)?.toInt(),
  overrideDns: json['overrideDns'] as bool? ?? false,
  milestoneProps: json['milestoneProps'] == null
      ? const MilestoneProps()
      : MilestoneProps.safeFromJson(
          json['milestoneProps'] as Map<String, Object?>?,
        ),
  hotKeyActions:
      (json['hotKeyActions'] as List<dynamic>?)
          ?.map((e) => HotKeyAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  appSettingProps: json['appSettingProps'] == null
      ? defaultAppSettingProps
      : AppSettingProps.safeFromJson(
          json['appSettingProps'] as Map<String, Object?>?,
        ),
  davProps: json['davProps'] == null
      ? null
      : DAVProps.fromJson(json['davProps'] as Map<String, dynamic>),
  networkProps: json['networkProps'] == null
      ? defaultNetworkProps
      : NetworkProps.fromJson(json['networkProps'] as Map<String, dynamic>?),
  vpnProps: json['vpnProps'] == null
      ? defaultVpnProps
      : VpnProps.fromJson(json['vpnProps'] as Map<String, dynamic>?),
  smartRoutingProps: json['smartRoutingProps'] == null
      ? defaultSmartRoutingProps
      : SmartRoutingProps.fromJson(
          json['smartRoutingProps'] as Map<String, dynamic>?,
        ),
  desyncProps: json['desyncProps'] == null
      ? defaultDesyncProps
      : DesyncProps.safeFromJson(json['desyncProps'] as Map<String, Object?>?),
  themeProps: ThemeProps.safeFromJson(
    json['themeProps'] as Map<String, Object?>?,
  ),
  proxiesStyleProps: json['proxiesStyleProps'] == null
      ? defaultProxiesStyleProps
      : ProxiesStyleProps.fromJson(
          json['proxiesStyleProps'] as Map<String, dynamic>?,
        ),
  windowProps: json['windowProps'] == null
      ? defaultWindowProps
      : WindowProps.fromJson(json['windowProps'] as Map<String, dynamic>?),
  patchClashConfig: json['patchClashConfig'] == null
      ? defaultClashConfig
      : PatchClashConfig.fromJson(
          json['patchClashConfig'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ConfigToJson(_Config instance) => <String, dynamic>{
  'currentProfileId': instance.currentProfileId,
  'overrideDns': instance.overrideDns,
  'milestoneProps': instance.milestoneProps,
  'hotKeyActions': instance.hotKeyActions,
  'appSettingProps': instance.appSettingProps,
  'davProps': instance.davProps,
  'networkProps': instance.networkProps,
  'vpnProps': instance.vpnProps,
  'smartRoutingProps': instance.smartRoutingProps,
  'desyncProps': instance.desyncProps,
  'themeProps': instance.themeProps,
  'proxiesStyleProps': instance.proxiesStyleProps,
  'windowProps': instance.windowProps,
  'patchClashConfig': instance.patchClashConfig,
};
