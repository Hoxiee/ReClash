// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharedState _$SharedStateFromJson(Map<String, dynamic> json) => _SharedState(
  setupParams: json['setupParams'] == null
      ? null
      : SetupParams.fromJson(json['setupParams'] as Map<String, dynamic>),
  vpnOptions: json['vpnOptions'] == null
      ? null
      : VpnOptions.fromJson(json['vpnOptions'] as Map<String, dynamic>),
  stopTip: json['stopTip'] as String,
  startTip: json['startTip'] as String,
  pauseTip: json['pauseTip'] as String,
  currentProfileName: json['currentProfileName'] as String,
  stopText: json['stopText'] as String,
  pauseText: json['pauseText'] as String,
  resumeText: json['resumeText'] as String,
  pausedText: json['pausedText'] as String,
  smartRoutingText: json['smartRoutingText'] as String? ?? 'Smart Routing',
  smartRoutingSearchingText:
      json['smartRoutingSearchingText'] as String? ?? 'Searching',
  connectionDoctorText:
      json['connectionDoctorText'] as String? ?? 'Connection Doctor',
  doctorExaminingText:
      json['doctorExaminingText'] as String? ?? 'Checking connection',
  doctorHealthyText:
      json['doctorHealthyText'] as String? ?? 'Connection healthy',
  doctorDegradedText:
      json['doctorDegradedText'] as String? ?? 'Connection degraded',
  doctorBrokenText: json['doctorBrokenText'] as String? ?? 'Problem found',
  doctorObservingText:
      json['doctorObservingText'] as String? ?? 'Observing traffic',
  sessionTrafficText:
      json['sessionTrafficText'] as String? ?? 'Session traffic',
  networkStateText: json['networkStateText'] as String? ?? 'Network',
  currentServerText: json['currentServerText'] as String? ?? 'Current server',
  networkNormalText: json['networkNormalText'] as String? ?? 'Normal',
  networkWhitelistText: json['networkWhitelistText'] as String? ?? 'Whitelist',
  networkPortalText: json['networkPortalText'] as String? ?? 'Captive portal',
  networkOfflineText: json['networkOfflineText'] as String? ?? 'Offline',
  networkUnknownText: json['networkUnknownText'] as String? ?? 'Unknown',
  activeText: json['activeText'] as String? ?? 'Protection active',
  activeServerGroup: json['activeServerGroup'] as String?,
  onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool,
  notificationSettings: json['notificationSettings'] == null
      ? defaultNotificationSettings
      : NotificationSettings.fromJson(
          json['notificationSettings'] as Map<String, dynamic>,
        ),
  crashlytics: json['crashlytics'] as bool,
  pureBlackTheme: json['pureBlackTheme'] as bool? ?? false,
  autoRun: json['autoRun'] as bool? ?? false,
);

Map<String, dynamic> _$SharedStateToJson(_SharedState instance) =>
    <String, dynamic>{
      'setupParams': instance.setupParams,
      'vpnOptions': instance.vpnOptions,
      'stopTip': instance.stopTip,
      'startTip': instance.startTip,
      'pauseTip': instance.pauseTip,
      'currentProfileName': instance.currentProfileName,
      'stopText': instance.stopText,
      'pauseText': instance.pauseText,
      'resumeText': instance.resumeText,
      'pausedText': instance.pausedText,
      'smartRoutingText': instance.smartRoutingText,
      'smartRoutingSearchingText': instance.smartRoutingSearchingText,
      'connectionDoctorText': instance.connectionDoctorText,
      'doctorExaminingText': instance.doctorExaminingText,
      'doctorHealthyText': instance.doctorHealthyText,
      'doctorDegradedText': instance.doctorDegradedText,
      'doctorBrokenText': instance.doctorBrokenText,
      'doctorObservingText': instance.doctorObservingText,
      'sessionTrafficText': instance.sessionTrafficText,
      'networkStateText': instance.networkStateText,
      'currentServerText': instance.currentServerText,
      'networkNormalText': instance.networkNormalText,
      'networkWhitelistText': instance.networkWhitelistText,
      'networkPortalText': instance.networkPortalText,
      'networkOfflineText': instance.networkOfflineText,
      'networkUnknownText': instance.networkUnknownText,
      'activeText': instance.activeText,
      'activeServerGroup': instance.activeServerGroup,
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'notificationSettings': instance.notificationSettings,
      'crashlytics': instance.crashlytics,
      'pureBlackTheme': instance.pureBlackTheme,
      'autoRun': instance.autoRun,
    };
