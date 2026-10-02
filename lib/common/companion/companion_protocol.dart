import 'dart:convert';

import 'package:reclash/models/companion.dart';

const _maxQrBytes = 2048;
const _requiredParams = {'v', 'd', 'h', 'p', 'k', 's'};

// Pure, dependency-free so Kotlin can mirror it against the same JSON fixtures. Every reject is a
// typed reason before any network reaches the wire (S01): a companion QR that fails here is never
// retried as a subscription URL, and a subscription URL never parses as a pairing payload (S02).
CompanionQrResult parseCompanionPairingQr(String raw) {
  if (utf8.encode(raw).length > _maxQrBytes) {
    return const CompanionQrRejected(CompanionQrRejection.tooLarge);
  }
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'reclash') {
    return const CompanionQrRejected(CompanionQrRejection.wrongScheme);
  }
  if (uri.userInfo.isNotEmpty) {
    return const CompanionQrRejected(CompanionQrRejection.hasUserInfo);
  }
  if (uri.hasFragment) {
    return const CompanionQrRejected(CompanionQrRejection.hasFragment);
  }
  if (uri.host != 'companion' || uri.path != '/pair') {
    return const CompanionQrRejected(CompanionQrRejection.wrongPath);
  }

  final params = <String, String>{};
  for (final entry in uri.queryParametersAll.entries) {
    if (entry.value.length != 1) {
      return const CompanionQrRejected(CompanionQrRejection.duplicateParam);
    }
    params[entry.key] = entry.value.single;
  }
  for (final key in _requiredParams) {
    if (!params.containsKey(key)) {
      return const CompanionQrRejected(CompanionQrRejection.missingParam);
    }
  }

  if (params['v'] != '1') {
    return const CompanionQrRejected(CompanionQrRejection.unsupportedVersion);
  }
  if (_decodeFixed(params['d']!, 16) == null) {
    return const CompanionQrRejected(CompanionQrRejection.invalidDeviceId);
  }
  final host = params['h']!;
  if (!_isPrivateIpv4(host)) {
    return const CompanionQrRejected(CompanionQrRejection.invalidHost);
  }
  final port = int.tryParse(params['p']!);
  if (port == null || port < 1 || port > 65535 || '$port' != params['p']) {
    return const CompanionQrRejected(CompanionQrRejection.invalidPort);
  }
  if (_decodeFixed(params['k']!, 32) == null) {
    return const CompanionQrRejected(CompanionQrRejection.invalidPin);
  }
  if (_decodeFixed(params['s']!, 32) == null) {
    return const CompanionQrRejected(CompanionQrRejection.invalidSecret);
  }

  return CompanionQrPaired(
    CompanionPairingPayload(
      deviceId: params['d']!,
      host: host,
      port: port,
      spkiPin: params['k']!,
      pairingSecret: params['s']!,
    ),
  );
}

bool isCompanionPairingLink(String raw) =>
    parseCompanionPairingQr(raw) is CompanionQrPaired;

List<int>? _decodeFixed(String value, int expectedLength) {
  final normalized = value.replaceAll('-', '+').replaceAll('_', '/');
  final padded = normalized.padRight((normalized.length + 3) & ~3, '=');
  try {
    final bytes = base64.decode(padded);
    if (bytes.length != expectedLength) return null;
    if (base64Url.encode(bytes).replaceAll('=', '') != value) return null;
    return bytes;
  } catch (_) {
    return null;
  }
}

bool _isPrivateIpv4(String host) {
  final parts = host.split('.');
  if (parts.length != 4) return false;
  final octets = <int>[];
  for (final part in parts) {
    if (part.isEmpty || part.length > 3) return false;
    if (part.length > 1 && part[0] == '0') return false;
    final octet = int.tryParse(part);
    if (octet == null || octet < 0 || octet > 255) return false;
    octets.add(octet);
  }
  final a = octets[0];
  final b = octets[1];
  final isPrivate =
      a == 10 ||
      (a == 172 && b >= 16 && b <= 31) ||
      (a == 192 && b == 168) ||
      (a == 169 && b == 254);
  return isPrivate;
}
