import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/capability.freezed.dart';
part 'generated/capability.g.dart';

const supportedCapabilityIds = <String>{'youtube-adfree', 'gemini-access'};

const capabilityServiceRules = <String, List<String>>{
  'youtube-adfree': ['GEOSITE,youtube'],
  'gemini-access': [
    'DOMAIN-SUFFIX,gemini.google.com',
    'DOMAIN,aistudio.google.com',
    'DOMAIN-SUFFIX,ai.google.dev',
    'DOMAIN,generativelanguage.googleapis.com',
    'DOMAIN,bard.google.com',
  ],
};

const rcxCapabilityGroupPrefix = 'RCX-CAP-';

String capabilityGroupName(String capabilityId) =>
    '$rcxCapabilityGroupPrefix${capabilityId.toUpperCase().replaceAll(RegExp('[^A-Z0-9]+'), '_')}';

enum ServiceRouteFallback { main, reject }

enum CapabilityManifestIssue { invalidHeader }

@freezed
abstract class CapabilitySelector with _$CapabilitySelector {
  const factory CapabilitySelector({
    String? provider,
    @JsonKey(name: 'name_contains') String? nameContains,
  }) = _CapabilitySelector;

  factory CapabilitySelector.fromJson(Map<String, Object?> json) =>
      _$CapabilitySelectorFromJson(json);
}

@freezed
abstract class CapabilityClaim with _$CapabilityClaim {
  const factory CapabilityClaim({
    @JsonKey(name: 'cap') required String capabilityId,
    required List<CapabilitySelector> selectors,
  }) = _CapabilityClaim;

  factory CapabilityClaim.fromJson(Map<String, Object?> json) =>
      _$CapabilityClaimFromJson(json);
}

@freezed
abstract class ProviderCapabilityManifest with _$ProviderCapabilityManifest {
  const factory ProviderCapabilityManifest({
    required int version,
    @Default([]) List<CapabilityClaim> claims,
    required DateTime receivedAt,
    required String sourceHost,
    @Default(false) bool stale,
  }) = _ProviderCapabilityManifest;

  factory ProviderCapabilityManifest.fromJson(Map<String, Object?> json) =>
      _$ProviderCapabilityManifestFromJson(json);
}

@freezed
abstract class ServiceRoutePolicy with _$ServiceRoutePolicy {
  const factory ServiceRoutePolicy({
    required String capabilityId,
    @Default(false) bool enabled,
    @Default(ServiceRouteFallback.main) ServiceRouteFallback fallback,
  }) = _ServiceRoutePolicy;

  factory ServiceRoutePolicy.fromJson(Map<String, Object?> json) =>
      _$ServiceRoutePolicyFromJson(json);
}

@freezed
abstract class ManualCapabilitySelector with _$ManualCapabilitySelector {
  const factory ManualCapabilitySelector({
    required String capabilityId,
    String? provider,
    required String nameContains,
  }) = _ManualCapabilitySelector;

  factory ManualCapabilitySelector.fromJson(Map<String, Object?> json) =>
      _$ManualCapabilitySelectorFromJson(json);
}
