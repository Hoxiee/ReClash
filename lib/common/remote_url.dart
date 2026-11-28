import 'dart:io';

const _metadataHosts = {
  'metadata',
  'metadata.google.internal',
  'instance-data',
  'instance-data.ec2.internal',
  'metadata.tencentyun.com',
};

const _blockedIpv6 = ['fd00:ec2::254'];

/// Whether a URL taken from subscription content must not be fetched.
///
/// Loopback, link-local, carrier-grade NAT and cloud metadata are refused;
/// RFC 1918 and ULA addresses stay reachable for LAN-hosted subscriptions.
/// Credentials in the URL are refused too: a fetch never needs them, and a
/// redirect should not carry them.
bool isBlockedRemoteUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.userInfo.isNotEmpty) {
    return true;
  }
  return isBlockedProviderUrl(value);
}

/// Whether a provider URL from subscription content must not be handed to the
/// Core to fetch.
///
/// Unlike [isBlockedRemoteUrl] userinfo stays: it is the provider's own
/// credentials, which the Core sends as Basic auth. Loopback, metadata and
/// non-http URLs are refused here for the same reason as above.
bool isBlockedProviderUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      uri.host.isEmpty ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    return true;
  }
  return isBlockedRemoteHost(uri.host);
}

bool isBlockedRemoteHost(String host) {
  var value = host.toLowerCase();
  if (value.startsWith('[') && value.endsWith(']')) {
    value = value.substring(1, value.length - 1);
  }
  if (value.endsWith('.')) {
    value = value.substring(0, value.length - 1);
  }
  if (value.isEmpty ||
      value == 'localhost' ||
      value.endsWith('.localhost') ||
      _metadataHosts.contains(value)) {
    return true;
  }
  final shorthand = _ipv4(value);
  if (shorthand != null) return _blockedV4(shorthand);
  final address = InternetAddress.tryParse(_withoutZone(value));
  return address != null && isBlockedRemoteAddress(address);
}

bool isBlockedRemoteAddress(InternetAddress address) {
  final raw = address.rawAddress;
  if (address.type == InternetAddressType.IPv6) {
    if (raw.length != 16) return true;
    if (_mappedV4(raw)) return _blockedV4(raw.sublist(12));
    if (raw.take(15).every((byte) => byte == 0)) return true;
    if (raw[0] == 0xfe && (raw[1] & 0xc0) == 0x80) return true;
    if (raw[0] == 0xff) return true;
    for (final blocked in _blockedIpv6) {
      final parsed = InternetAddress.tryParse(blocked);
      if (parsed != null && _sameBytes(parsed.rawAddress, raw)) return true;
    }
    return false;
  }
  return _blockedV4(raw);
}

Future<bool> resolvesToBlockedRemoteAddress(
  Uri uri, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  if (isBlockedRemoteUrl(uri.toString())) return true;
  final host = uri.host;
  if (_ipv4(host) != null ||
      InternetAddress.tryParse(_withoutZone(host)) != null) {
    return false;
  }
  try {
    final addresses = await InternetAddress.lookup(host).timeout(timeout);
    return addresses.any(isBlockedRemoteAddress);
  } on Object {
    return false;
  }
}

List<int>? _ipv4(String host) {
  if (host.isEmpty || host.contains(':')) return null;
  final parts = host.split('.');
  if (parts.length > 4) return null;
  final values = <int>[];
  for (final part in parts) {
    if (part.isEmpty) return null;
    var radix = 10;
    var digits = part;
    if (part.startsWith('0x') || part.startsWith('0X')) {
      radix = 16;
      digits = part.substring(2);
    } else if (part.length > 1 && part.startsWith('0')) {
      radix = 8;
      digits = part.substring(1);
      if (!RegExp('^[0-7]+\$').hasMatch(digits)) {
        radix = 10;
        digits = part;
      }
    }
    if (digits.isEmpty) {
      values.add(0);
      continue;
    }
    final value = int.tryParse(digits, radix: radix);
    if (value == null || value < 0) return null;
    values.add(value);
  }
  if (values.length == 1) {
    return values[0] > 0xffffffff ? null : _v4(values[0]);
  }
  if (values.length == 2) {
    if (values[0] > 0xff || values[1] > 0xffffff) return null;
    return _v4(values[0] << 24 | values[1]);
  }
  if (values.length == 3) {
    if (values[0] > 0xff || values[1] > 0xff || values[2] > 0xffff) {
      return null;
    }
    return _v4(values[0] << 24 | values[1] << 16 | values[2]);
  }
  if (values.any((value) => value > 0xff)) return null;
  return _v4(values[0] << 24 | values[1] << 16 | values[2] << 8 | values[3]);
}

List<int> _v4(int value) => [
  (value >> 24) & 0xff,
  (value >> 16) & 0xff,
  (value >> 8) & 0xff,
  value & 0xff,
];

bool _blockedV4(List<int> bytes) {
  final a = bytes[0];
  if (a == 0 || a == 127) return true;
  if (a == 169 && bytes[1] == 254) return true;
  if (a == 100 && bytes[1] >= 64 && bytes[1] <= 127) return true;
  if (a == 168 && bytes[1] == 63 && bytes[2] == 129 && bytes[3] == 16) {
    return true;
  }
  return a >= 224;
}

bool _mappedV4(List<int> raw) {
  for (var i = 0; i < 10; i++) {
    if (raw[i] != 0) return false;
  }
  return raw[10] == 0xff && raw[11] == 0xff;
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _withoutZone(String host) {
  final zone = host.indexOf('%');
  return zone == -1 ? host : host.substring(0, zone);
}
