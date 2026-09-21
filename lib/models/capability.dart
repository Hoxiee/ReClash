import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/capability.freezed.dart';
part 'generated/capability.g.dart';

const capabilityRoleAny = '';
const capabilityRoleForeign = 'foreign';
const capabilityRoleDomestic = 'domestic';
const capabilityRoles = {
  capabilityRoleAny,
  capabilityRoleForeign,
  capabilityRoleDomestic,
};

// Shipped classes, off until a policy enables them; a manifest may reference an
// id to add membership or override the rules.
class RoutingClassTemplate {
  const RoutingClassTemplate({
    required this.rules,
    this.role = capabilityRoleAny,
    this.strategy = '',
    this.defaultFallback = ServiceRouteFallback.main,
  });

  final List<String> rules;
  final String role;
  final String strategy;
  final ServiceRouteFallback defaultFallback;
}

const routingClassTemplates = <String, RoutingClassTemplate>{
  'youtube-adfree': RoutingClassTemplate(
    rules: ['GEOSITE,youtube'],
    role: capabilityRoleForeign,
  ),
  'gemini-access': RoutingClassTemplate(
    rules: [
      'DOMAIN-SUFFIX,gemini.google.com',
      'DOMAIN,aistudio.google.com',
      'DOMAIN-SUFFIX,ai.google.dev',
      'DOMAIN,generativelanguage.googleapis.com',
      'DOMAIN,bard.google.com',
    ],
    role: capabilityRoleForeign,
    defaultFallback: ServiceRouteFallback.reject,
  ),
};

// Excludes fetch (RULE-SET), exec (SCRIPT) and regex verbs: new attack surface, not trust.
const _allowedRuleVerbs = <String>{
  'DOMAIN',
  'DOMAIN-SUFFIX',
  'DOMAIN-KEYWORD',
  'GEOSITE',
  'GEOIP',
  'IP-CIDR',
  'IP-CIDR6',
  'DST-PORT',
  'SRC-PORT',
  'PROCESS-NAME',
  'PROCESS-PATH',
};
const _allowedRuleFlags = <String>{'no-resolve', 'src'};
const capabilityMaxRulesPerClaim = 32;

// All-or-nothing: one malformed rule drops the set so a half-applied class
// cannot leak. The skeleton appends the target; an author never supplies one.
List<String>? sanitizeCapabilityRules(List<String> rules) {
  if (rules.length > capabilityMaxRulesPerClaim) return null;
  final sanitized = <String>[];
  final seen = <String>{};
  for (final raw in rules) {
    final rule = raw.trim();
    final parts = rule.split(',').map((part) => part.trim()).toList();
    if (parts.length < 2 || parts.length > 3) return null;
    if (!_allowedRuleVerbs.contains(parts[0].toUpperCase())) return null;
    if (parts[1].isEmpty) return null;
    if (parts.length == 3 &&
        !_allowedRuleFlags.contains(parts[2].toLowerCase())) {
      return null;
    }
    final normalized =
        '${parts[0].toUpperCase()},${parts.sublist(1).join(',')}';
    if (seen.add(normalized)) sanitized.add(normalized);
  }
  return sanitized;
}

Set<String> effectiveCapabilityIds(ProviderCapabilityManifest? manifest) {
  final ids = {...routingClassTemplates.keys};
  if (manifest != null && !manifest.stale) {
    for (final claim in manifest.claims) {
      ids.add(claim.capabilityId);
    }
  }
  return ids;
}

Iterable<CapabilityClaim> _liveClaims(
  ProviderCapabilityManifest? manifest,
  String capabilityId,
) {
  if (manifest == null || manifest.stale) return const [];
  return manifest.claims.where((claim) => claim.capabilityId == capabilityId);
}

// A live claim overrides the shipped template; the template is only the floor.
List<String> resolvedClassRules(
  ProviderCapabilityManifest? manifest,
  String capabilityId,
) {
  for (final claim in _liveClaims(manifest, capabilityId)) {
    if (claim.rules.isNotEmpty) return claim.rules;
  }
  return routingClassTemplates[capabilityId]?.rules ?? const [];
}

String resolvedClassRole(
  ProviderCapabilityManifest? manifest,
  String capabilityId,
) {
  for (final claim in _liveClaims(manifest, capabilityId)) {
    if (claim.role != capabilityRoleAny) return claim.role;
  }
  return routingClassTemplates[capabilityId]?.role ?? capabilityRoleAny;
}

String resolvedClassStrategy(
  ProviderCapabilityManifest? manifest,
  String capabilityId,
) {
  for (final claim in _liveClaims(manifest, capabilityId)) {
    if (claim.strategy.isNotEmpty) return claim.strategy;
  }
  return routingClassTemplates[capabilityId]?.strategy ?? '';
}

ServiceRouteFallback defaultFallbackFor(String capabilityId) =>
    routingClassTemplates[capabilityId]?.defaultFallback ??
    ServiceRouteFallback.main;

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
    String? group,
  }) = _CapabilitySelector;

  factory CapabilitySelector.fromJson(Map<String, Object?> json) =>
      _$CapabilitySelectorFromJson(json);
}

@freezed
abstract class CapabilityClaim with _$CapabilityClaim {
  const factory CapabilityClaim({
    @JsonKey(name: 'cap') required String capabilityId,
    required List<CapabilitySelector> selectors,
    @Default([]) List<String> rules,
    @Default(capabilityRoleAny) String role,
    @Default('') String strategy,
    String? title,
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
