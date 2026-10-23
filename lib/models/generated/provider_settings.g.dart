// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../provider_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderSettingsState _$ProviderSettingsStateFromJson(
  Map<String, dynamic> json,
) => _ProviderSettingsState(
  applied: json['applied'] as Map<String, dynamic>? ?? const {},
  userBaseline: json['userBaseline'] as Map<String, dynamic>? ?? const {},
  userOwned:
      (json['userOwned'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const {},
);

Map<String, dynamic> _$ProviderSettingsStateToJson(
  _ProviderSettingsState instance,
) => <String, dynamic>{
  'applied': instance.applied,
  'userBaseline': instance.userBaseline,
  'userOwned': instance.userOwned.toList(),
};
