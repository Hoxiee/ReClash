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
);

Map<String, dynamic> _$PanelMetaToJson(_PanelMeta instance) =>
    <String, dynamic>{
      'hwidMaxDevicesReached': instance.hwidMaxDevicesReached,
      'hwidNotSupported': instance.hwidNotSupported,
      'announce': instance.announce,
      'supportUrl': instance.supportUrl,
      'updateIntervalMinutes': instance.updateIntervalMinutes,
    };
