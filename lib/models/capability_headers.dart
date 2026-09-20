import 'dart:convert';

import 'capability.dart';

const capabilityManifestHeader = 'x-reclash-capabilities';
const capabilityManifestMaxHeaderBytes = 8 * 1024;
const capabilityManifestMaxClaims = 32;
const capabilityManifestMaxSelectors = 64;
const capabilitySelectorMaxTokenBytes = 64;

final _capabilityIdPattern = RegExp(r'^[a-z0-9][a-z0-9.-]{0,63}$');
final _base64UrlPayloadPattern = RegExp(r'^[A-Za-z0-9_-]+$');

sealed class CapabilityManifestHeaderResult {
  const CapabilityManifestHeaderResult();
}

class CapabilityManifestHeaderAbsent extends CapabilityManifestHeaderResult {
  const CapabilityManifestHeaderAbsent();
}

class CapabilityManifestHeaderInvalid extends CapabilityManifestHeaderResult {
  const CapabilityManifestHeaderInvalid();
}

class CapabilityManifestHeaderValid extends CapabilityManifestHeaderResult {
  const CapabilityManifestHeaderValid(this.claims);

  final List<CapabilityClaim> claims;
}

CapabilityManifestHeaderResult parseCapabilityManifestHeader(
  Map<String, List<String>> headers,
) {
  final values = [
    for (final entry in headers.entries)
      if (entry.key.toLowerCase() == capabilityManifestHeader) ...entry.value,
  ];
  if (values.isEmpty) return const CapabilityManifestHeaderAbsent();
  if (values.length != 1) return const CapabilityManifestHeaderInvalid();
  final value = values.single.trim();
  final payload = value.startsWith('v1.') ? value.substring(3) : '';
  if (utf8.encode(value).length > capabilityManifestMaxHeaderBytes ||
      payload.isEmpty ||
      !_base64UrlPayloadPattern.hasMatch(payload)) {
    return const CapabilityManifestHeaderInvalid();
  }
  try {
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    final json = jsonDecode(decoded);
    final claims = _parseManifest(json);
    return claims == null
        ? const CapabilityManifestHeaderInvalid()
        : CapabilityManifestHeaderValid(claims);
  } catch (_) {
    return const CapabilityManifestHeaderInvalid();
  }
}

List<CapabilityClaim>? _parseManifest(Object? value) {
  if (value is! Map<String, Object?> ||
      value.length != 2 ||
      value['v'] != 1 ||
      value['claims'] is! List) {
    return null;
  }
  final rawClaims = value['claims']! as List;
  if (rawClaims.length > capabilityManifestMaxClaims) return null;
  var selectorCount = 0;
  final claims = <CapabilityClaim>[];
  for (final rawClaim in rawClaims) {
    if (rawClaim is Map<String, Object?> && rawClaim['selectors'] is List) {
      selectorCount += (rawClaim['selectors']! as List).length;
      if (selectorCount > capabilityManifestMaxSelectors) return null;
    }
    final claim = _parseClaim(rawClaim);
    if (claim == null) continue;
    if (claim.selectors.isNotEmpty) claims.add(claim);
  }
  return List.unmodifiable(claims);
}

const _claimKeys = {'cap', 'selectors', 'rules', 'role', 'strategy', 'title'};
final _capabilityTitlePattern = RegExp(r'^.{1,48}$');

CapabilityClaim? _parseClaim(Object? value) {
  if (value is! Map<String, Object?> ||
      value.keys.any((key) => !_claimKeys.contains(key))) {
    return null;
  }
  final capabilityId = value['cap'];
  final rawSelectors = value['selectors'];
  if (capabilityId is! String ||
      !_capabilityIdPattern.hasMatch(capabilityId) ||
      rawSelectors is! List) {
    return null;
  }
  final selectors = <CapabilitySelector>[];
  for (final rawSelector in rawSelectors) {
    final selector = _parseSelector(rawSelector);
    if (selector != null) selectors.add(selector);
  }
  final rules = _parseRules(value['rules']);
  if (rules == null) return null;
  final role = value['role'];
  if (role != null && (role is! String || !capabilityRoles.contains(role))) {
    return null;
  }
  final strategy = value['strategy'];
  if (strategy != null &&
      (strategy is! String || !_allowedStrategies.contains(strategy))) {
    return null;
  }
  final title = value['title'];
  if (title != null &&
      (title is! String || !_capabilityTitlePattern.hasMatch(title.trim()))) {
    return null;
  }
  return CapabilityClaim(
    capabilityId: capabilityId,
    selectors: selectors,
    rules: rules,
    role: role as String? ?? capabilityRoleAny,
    strategy: strategy as String? ?? '',
    title: (title as String?)?.trim(),
  );
}

const _allowedStrategies = {'stable', 'balanced', 'lowest-latency', 'saver'};

List<String>? _parseRules(Object? value) {
  if (value == null) return const [];
  if (value is! List) return null;
  final raw = <String>[];
  for (final item in value) {
    if (item is! String) return null;
    raw.add(item);
  }
  return sanitizeCapabilityRules(raw);
}

const _selectorKeys = {'provider', 'name_contains', 'group'};

CapabilitySelector? _parseSelector(Object? value) {
  if (value is! Map<String, Object?> ||
      value.isEmpty ||
      value.keys.any((key) => !_selectorKeys.contains(key))) {
    return null;
  }
  final provider = value['provider'];
  final nameContains = value['name_contains'];
  final group = value['group'];
  if ((value.containsKey('provider') && provider is! String) ||
      (value.containsKey('name_contains') && nameContains is! String) ||
      (value.containsKey('group') && group is! String)) {
    return null;
  }
  final normalizedProvider = (provider as String?)?.trim();
  final normalizedName = (nameContains as String?)?.trim();
  final normalizedGroup = (group as String?)?.trim();
  if (normalizedProvider == null &&
      normalizedName == null &&
      normalizedGroup == null) {
    return null;
  }
  bool tooLong(String? token) =>
      token != null &&
      utf8.encode(token).length > capabilitySelectorMaxTokenBytes;
  if ((provider != null && normalizedProvider!.isEmpty) ||
      (nameContains != null && normalizedName!.isEmpty) ||
      (group != null && normalizedGroup!.isEmpty) ||
      tooLong(normalizedProvider) ||
      tooLong(normalizedName) ||
      tooLong(normalizedGroup)) {
    return null;
  }
  return CapabilitySelector(
    provider: normalizedProvider,
    nameContains: normalizedName,
    group: normalizedGroup,
  );
}
