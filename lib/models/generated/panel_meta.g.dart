// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../panel_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PanelMeta _$PanelMetaFromJson(Map<String, dynamic> json) => _PanelMeta(
  hwidMaxDevicesReached: json['hwidMaxDevicesReached'] as bool? ?? false,
  hwidNotSupported: json['hwidNotSupported'] as bool? ?? false,
  announce: json['announce'] as String?,
  supportUrl: json['supportUrl'] as String?,
  updateIntervalMinutes: (json['updateIntervalMinutes'] as num?)?.toInt(),
  serviceName: json['serviceName'] as String?,
  serviceLogo: json['serviceLogo'] as String?,
  serverInfoGroup: json['serverInfoGroup'] as String?,
  buyPlanUrl: json['buyPlanUrl'] as String?,
  buyTrafficUrl: json['buyTrafficUrl'] as String?,
  widgets: (json['widgets'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  widgetsApplyMode:
      $enumDecodeNullable(
        _$PanelWidgetsApplyModeEnumMap,
        json['widgetsApplyMode'],
      ) ??
      PanelWidgetsApplyMode.add,
  settings: (json['settings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  newDomain: json['newDomain'] as String?,
  profileTitle: json['profileTitle'] as String?,
);

Map<String, dynamic> _$PanelMetaToJson(_PanelMeta instance) =>
    <String, dynamic>{
      'hwidMaxDevicesReached': instance.hwidMaxDevicesReached,
      'hwidNotSupported': instance.hwidNotSupported,
      'announce': instance.announce,
      'supportUrl': instance.supportUrl,
      'updateIntervalMinutes': instance.updateIntervalMinutes,
      'serviceName': instance.serviceName,
      'serviceLogo': instance.serviceLogo,
      'serverInfoGroup': instance.serverInfoGroup,
      'buyPlanUrl': instance.buyPlanUrl,
      'buyTrafficUrl': instance.buyTrafficUrl,
      'widgets': instance.widgets,
      'widgetsApplyMode':
          _$PanelWidgetsApplyModeEnumMap[instance.widgetsApplyMode]!,
      'settings': instance.settings,
      'newDomain': instance.newDomain,
      'profileTitle': instance.profileTitle,
    };

const _$PanelWidgetsApplyModeEnumMap = {
  PanelWidgetsApplyMode.add: 'add',
  PanelWidgetsApplyMode.update: 'update',
};
