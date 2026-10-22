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
  localNetworkTip: json['localNetworkTip'] as String,
  currentProfileName: json['currentProfileName'] as String,
  stopText: json['stopText'] as String,
  onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool,
  showStopAction: json['showStopAction'] as bool? ?? true,
  notificationSettings: json['notificationSettings'] == null
      ? const NotificationSettings()
      : NotificationSettings.fromJson(
          json['notificationSettings'] as Map<String, dynamic>,
        ),
  notificationActiveText: json['notificationActiveText'] as String? ?? '',
  notificationServerText: json['notificationServerText'] as String? ?? '',
  notificationTrafficText: json['notificationTrafficText'] as String? ?? '',
  notificationServerGroup: json['notificationServerGroup'] as String?,
);

Map<String, dynamic> _$SharedStateToJson(_SharedState instance) =>
    <String, dynamic>{
      'setupParams': instance.setupParams,
      'vpnOptions': instance.vpnOptions,
      'stopTip': instance.stopTip,
      'startTip': instance.startTip,
      'localNetworkTip': instance.localNetworkTip,
      'currentProfileName': instance.currentProfileName,
      'stopText': instance.stopText,
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'showStopAction': instance.showStopAction,
      'notificationSettings': instance.notificationSettings,
      'notificationActiveText': instance.notificationActiveText,
      'notificationServerText': instance.notificationServerText,
      'notificationTrafficText': instance.notificationTrafficText,
      'notificationServerGroup': instance.notificationServerGroup,
    };
