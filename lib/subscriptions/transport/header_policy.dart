import 'dart:convert';

import '../protocol/registry.dart';

const _controlledHeaders = {
  'host',
  'connection',
  'content-length',
  'transfer-encoding',
  'upgrade',
  'proxy-authorization',
  'proxy-connection',
  'accept-encoding',
  'te',
  'trailer',
  'x-hwid-max-devices-reached',
  'x-hwid-not-supported',
  'subscription-userinfo',
  'content-disposition',
};
const _identityHeaders = {
  'x-hwid',
  'x-device-os',
  'x-ver-os',
  'x-device-model',
  'x-device-locale',
};
const _publicHeaders = {'user-agent', 'accept', 'accept-language'};
final _headerName = RegExp(r"^[!#$%&'*+.^_`|~0-9A-Za-z-]+$");

class SubscriptionHeaderException implements Exception {
  const SubscriptionHeaderException();

  @override
  String toString() => 'Invalid subscription request headers';
}

Map<String, String> validateSubscriptionHeaders(
  Map<String, String> headers, {
  bool allowManaged = false,
}) {
  final result = <String, String>{};
  var size = 0;
  for (final MapEntry(:key, :value) in headers.entries) {
    final name = key.toLowerCase();
    final bytes = utf8.encode(value).length;
    size += key.length + bytes + 4;
    if (!_headerName.hasMatch(key) ||
        result.containsKey(name) ||
        value.runes.any((r) => r < 32 && r != 9 || r >= 127) ||
        bytes > subscriptionHeaderLimit ||
        size > subscriptionHeadersLimit ||
        _controlledHeaders.contains(name) ||
        name.startsWith('reclash-') ||
        !allowManaged && _identityHeaders.contains(name)) {
      throw const SubscriptionHeaderException();
    }
    result[name] = value;
  }
  return Map.unmodifiable(result);
}

Map<String, String> overlaySubscriptionHeaders(
  Map<String, String> base,
  Map<String, String> overlay, {
  bool allowManaged = false,
}) {
  final merged = {
    ...validateSubscriptionHeaders(base, allowManaged: allowManaged),
    ...validateSubscriptionHeaders(overlay, allowManaged: allowManaged),
  };
  return Map.unmodifiable(merged);
}

Map<String, String> validateResourceHeaders(Map<String, String> headers) =>
    validateSubscriptionHeaders(headers);

String subscriptionOrigin(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  if ((scheme != 'https' && scheme != 'http') || uri.host.isEmpty) {
    throw const FormatException('Expected an HTTP(S) origin');
  }
  return Uri(
    scheme: scheme,
    host: uri.host.toLowerCase(),
    port: uri.port == (scheme == 'https' ? 443 : 80) ? null : uri.port,
  ).toString();
}

Map<String, String> redirectSubscriptionHeaders(
  Map<String, String> headers,
  Uri previous,
  Uri next,
) {
  if (subscriptionOrigin(previous) == subscriptionOrigin(next)) {
    return headers;
  }
  return Map.unmodifiable({
    for (final MapEntry(:key, :value) in headers.entries)
      if (_publicHeaders.contains(key.toLowerCase())) key: value,
  });
}

Map<String, String> redactSubscriptionHeaders(Map<String, String> headers) => {
  for (final MapEntry(:key, :value) in headers.entries)
    key: _publicHeaders.contains(key.toLowerCase()) ? value : '[redacted]',
};
