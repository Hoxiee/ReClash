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

CapabilityClaim? _parseClaim(Object? value) {
  if (value is! Map<String, Object?> ||
      value.keys.any((key) => key != 'cap' && key != 'selectors')) {
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
  return CapabilityClaim(capabilityId: capabilityId, selectors: selectors);
}

CapabilitySelector? _parseSelector(Object? value) {
  if (value is! Map<String, Object?> ||
      value.isEmpty ||
      value.keys.any((key) => key != 'provider' && key != 'name_contains')) {
    return null;
  }
  if (!value.containsKey('provider') && !value.containsKey('name_contains')) {
    return null;
  }
  final provider = value['provider'];
  final nameContains = value['name_contains'];
  if ((value.containsKey('provider') && provider is! String) ||
      (value.containsKey('name_contains') && nameContains is! String)) {
    return null;
  }
  final normalizedProvider = (provider as String?)?.trim();
  final normalizedName = (nameContains as String?)?.trim();
  if ((provider != null && normalizedProvider!.isEmpty) ||
      (nameContains != null && normalizedName!.isEmpty) ||
      (normalizedProvider != null &&
          utf8.encode(normalizedProvider).length >
              capabilitySelectorMaxTokenBytes) ||
      (normalizedName != null &&
          utf8.encode(normalizedName).length >
              capabilitySelectorMaxTokenBytes)) {
    return null;
  }
  return CapabilitySelector(
    provider: normalizedProvider,
    nameContains: normalizedName,
  );
}
