// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../desync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DesyncProps _$DesyncPropsFromJson(Map<String, dynamic> json) => _DesyncProps(
  enabled: json['enabled'] as bool? ?? false,
  port: (json['port'] as num?)?.toInt() ?? defaultDesyncPort,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DesyncCategoryEnumMap, e))
          .toList() ??
      const [DesyncCategory.youtube, DesyncCategory.discord],
  forceTcp: json['forceTcp'] as bool? ?? true,
);

Map<String, dynamic> _$DesyncPropsToJson(_DesyncProps instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'port': instance.port,
      'categories': instance.categories
          .map((e) => _$DesyncCategoryEnumMap[e]!)
          .toList(),
      'forceTcp': instance.forceTcp,
    };

const _$DesyncCategoryEnumMap = {
  DesyncCategory.youtube: 'youtube',
  DesyncCategory.discord: 'discord',
  DesyncCategory.twitter: 'twitter',
  DesyncCategory.meta: 'meta',
  DesyncCategory.signal: 'signal',
};
