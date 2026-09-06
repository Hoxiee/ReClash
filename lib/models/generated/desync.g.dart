// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../desync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DesyncStrategy _$DesyncStrategyFromJson(Map<String, dynamic> json) =>
    _DesyncStrategy(
      name: json['name'] as String,
      args:
          (json['args'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$DesyncStrategyToJson(_DesyncStrategy instance) =>
    <String, dynamic>{'name': instance.name, 'args': instance.args};

_DesyncProps _$DesyncPropsFromJson(Map<String, dynamic> json) => _DesyncProps(
  enabled: json['enabled'] as bool? ?? false,
  onlyDpi: json['onlyDpi'] as bool? ?? false,
  port: (json['port'] as num?)?.toInt() ?? defaultDesyncPort,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DesyncCategoryEnumMap, e))
          .toList() ??
      const [
        DesyncCategory.youtube,
        DesyncCategory.discord,
        DesyncCategory.telegram,
      ],
  forceTcp: json['forceTcp'] as bool? ?? true,
  strategyArgs:
      (json['strategyArgs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      desyncDefaultStrategy,
  cacheEnabled: json['cacheEnabled'] as bool? ?? true,
  cacheTtl: (json['cacheTtl'] as num?)?.toInt() ?? defaultDesyncCacheTtl,
  savedStrategies:
      (json['savedStrategies'] as List<dynamic>?)
          ?.map((e) => DesyncStrategy.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  testSiteLists:
      (json['testSiteLists'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      defaultDesyncTestSiteLists,
  testRunning: json['testRunning'] as bool? ?? false,
  testRestoreArgs:
      (json['testRestoreArgs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      null,
);

Map<String, dynamic> _$DesyncPropsToJson(_DesyncProps instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'onlyDpi': instance.onlyDpi,
      'port': instance.port,
      'categories': instance.categories
          .map((e) => _$DesyncCategoryEnumMap[e]!)
          .toList(),
      'forceTcp': instance.forceTcp,
      'strategyArgs': instance.strategyArgs,
      'cacheEnabled': instance.cacheEnabled,
      'cacheTtl': instance.cacheTtl,
      'savedStrategies': instance.savedStrategies,
      'testSiteLists': instance.testSiteLists,
      'testRunning': instance.testRunning,
      'testRestoreArgs': instance.testRestoreArgs,
    };

const _$DesyncCategoryEnumMap = {
  DesyncCategory.youtube: 'youtube',
  DesyncCategory.discord: 'discord',
  DesyncCategory.telegram: 'telegram',
  DesyncCategory.twitter: 'twitter',
  DesyncCategory.meta: 'meta',
  DesyncCategory.signal: 'signal',
};
