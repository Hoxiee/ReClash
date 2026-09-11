// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../capability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CapabilitySelector _$CapabilitySelectorFromJson(Map<String, dynamic> json) =>
    _CapabilitySelector(
      provider: json['provider'] as String?,
      nameContains: json['name_contains'] as String?,
    );

Map<String, dynamic> _$CapabilitySelectorToJson(_CapabilitySelector instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'name_contains': instance.nameContains,
    };

_CapabilityClaim _$CapabilityClaimFromJson(Map<String, dynamic> json) =>
    _CapabilityClaim(
      capabilityId: json['cap'] as String,
      selectors: (json['selectors'] as List<dynamic>)
          .map((e) => CapabilitySelector.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CapabilityClaimToJson(_CapabilityClaim instance) =>
    <String, dynamic>{
      'cap': instance.capabilityId,
      'selectors': instance.selectors,
    };

_ProviderCapabilityManifest _$ProviderCapabilityManifestFromJson(
  Map<String, dynamic> json,
) => _ProviderCapabilityManifest(
  version: (json['version'] as num).toInt(),
  claims:
      (json['claims'] as List<dynamic>?)
          ?.map((e) => CapabilityClaim.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  receivedAt: DateTime.parse(json['receivedAt'] as String),
  sourceHost: json['sourceHost'] as String,
  stale: json['stale'] as bool? ?? false,
);

Map<String, dynamic> _$ProviderCapabilityManifestToJson(
  _ProviderCapabilityManifest instance,
) => <String, dynamic>{
  'version': instance.version,
  'claims': instance.claims,
  'receivedAt': instance.receivedAt.toIso8601String(),
  'sourceHost': instance.sourceHost,
  'stale': instance.stale,
};

_ServiceRoutePolicy _$ServiceRoutePolicyFromJson(Map<String, dynamic> json) =>
    _ServiceRoutePolicy(
      capabilityId: json['capabilityId'] as String,
      enabled: json['enabled'] as bool? ?? false,
      fallback:
          $enumDecodeNullable(
            _$ServiceRouteFallbackEnumMap,
            json['fallback'],
          ) ??
          ServiceRouteFallback.main,
    );

Map<String, dynamic> _$ServiceRoutePolicyToJson(_ServiceRoutePolicy instance) =>
    <String, dynamic>{
      'capabilityId': instance.capabilityId,
      'enabled': instance.enabled,
      'fallback': _$ServiceRouteFallbackEnumMap[instance.fallback]!,
    };

const _$ServiceRouteFallbackEnumMap = {
  ServiceRouteFallback.main: 'main',
  ServiceRouteFallback.reject: 'reject',
};

_ManualCapabilitySelector _$ManualCapabilitySelectorFromJson(
  Map<String, dynamic> json,
) => _ManualCapabilitySelector(
  capabilityId: json['capabilityId'] as String,
  provider: json['provider'] as String?,
  nameContains: json['nameContains'] as String,
);

Map<String, dynamic> _$ManualCapabilitySelectorToJson(
  _ManualCapabilitySelector instance,
) => <String, dynamic>{
  'capabilityId': instance.capabilityId,
  'provider': instance.provider,
  'nameContains': instance.nameContains,
};
