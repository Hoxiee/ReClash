import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:reclash/common/common.dart';

typedef NetworkInterfaceLister =
    Future<List<NetworkInterface>> Function({bool includeLoopback});

@visibleForTesting
NetworkInterfaceLister listNetworkInterfaces =
    ({bool includeLoopback = false}) =>
        NetworkInterface.list(includeLoopback: includeLoopback);

extension NetworkInterfaceExt on NetworkInterface {
  bool get isWifi {
    final nameLowCase = name.toLowerCase();
    if (nameLowCase.contains('wlan') ||
        nameLowCase.contains('wi-fi') ||
        nameLowCase == 'en0' ||
        nameLowCase == 'eth0') {
      return true;
    }

    return false;
  }

  bool get includesIPv4 {
    return addresses.any((addr) => addr.isIPv4);
  }
}

extension InternetAddressExt on InternetAddress {
  bool get isIPv4 {
    return type == InternetAddressType.IPv4;
  }

  bool get isIPv6 {
    return type == InternetAddressType.IPv6;
  }
}

Future<String?> getLocalIpAddress() async {
  final List<NetworkInterface> interfaces =
      await listNetworkInterfaces(includeLoopback: false)
        ..sort((a, b) {
          if (a.isWifi && !b.isWifi) return -1;
          if (!a.isWifi && b.isWifi) return 1;
          if (a.includesIPv4 && !b.includesIPv4) return -1;
          if (!a.includesIPv4 && b.includesIPv4) return 1;
          return 0;
        });
  for (final interface in interfaces) {
    final addresses = interface.addresses;
    if (addresses.isEmpty) {
      continue;
    }
    addresses.sort((a, b) {
      if (a.isIPv4 && !b.isIPv4) return -1;
      if (!a.isIPv4 && b.isIPv4) return 1;
      return 0;
    });
    return addresses.first.address;
  }
  return '';
}

/// Counting the mihomo TUN address would make teardown a network change.
const _tunInterfaceAddress = '198.18.0.1';

Future<List<String>> getLocalIPv4s() async {
  final interfaces = await listNetworkInterfaces(includeLoopback: false);
  return [
    for (final interface in interfaces)
      for (final address in interface.addresses)
        if (address.isIPv4 && address.address != _tunInterfaceAddress)
          address.address,
  ];
}

Future<List<String>> getLocalIPv6s() async {
  final interfaces = await listNetworkInterfaces(includeLoopback: false);
  return [
    for (final interface in interfaces)
      for (final address in interface.addresses)
        if (address.isIPv6) address.address,
  ];
}

/// SSID rules match exactly; subnet rules accept bare IPs as host routes.
/// A strict list pauses only when an SSID rule and a subnet rule both hit.
/// Hand-mirrored by Kotlin's TrustedNetworkMatcher in SmartPause.kt.
bool smartPauseMatches(
  List<String> networks, {
  String? ssid,
  List<String> ipv4s = const [],
  List<String> ipv6s = const [],
  bool strict = false,
}) {
  return smartPauseMatchedRules(
    networks,
    ssid: ssid,
    ipv4s: ipv4s,
    ipv6s: ipv6s,
    strict: strict,
  ).isNotEmpty;
}

List<String> smartPauseMatchedRules(
  List<String> networks, {
  String? ssid,
  List<String> ipv4s = const [],
  List<String> ipv6s = const [],
  bool strict = false,
}) {
  String? ssidHit;
  final trustedSsid = ssid?.trim().toLowerCase();
  if (trustedSsid != null && trustedSsid.isNotEmpty) {
    for (final network in networks) {
      if (network.trim().toLowerCase() == trustedSsid) {
        ssidHit = network;
        break;
      }
    }
  }
  final subnetHits = [
    for (final network in networks)
      if (_parseCidrV4(network) != null
          ? ipv4s.any((ipv4) => _inTrustedSubnets(ipv4, [network]))
          : _parseCidrV6(network) != null &&
                ipv6s.any((ipv6) => _inTrustedSubnetsV6(ipv6, network)))
        network,
  ];
  if (strict &&
      networks.any((network) => !isSubnetRule(network)) &&
      networks.any(isSubnetRule)) {
    return ssidHit != null && subnetHits.isNotEmpty
        ? [ssidHit, ...subnetHits]
        : const [];
  }
  final matched = [...subnetHits];
  if (ssidHit != null) {
    matched.insert(0, ssidHit);
  }
  return matched;
}

/// A rule that parses as an IPv4 or IPv6 subnet needs no location permission.
bool isSubnetRule(String network) =>
    _parseCidrV4(network) != null || _parseCidrV6(network) != null;

/// Home subnets are /24 and site allocations are /48 or longer; anything
/// wider trusts networks the user has never seen.
bool smartPauseIsBroadRule(String network) {
  final v4 = _parseCidrV4(network);
  if (v4 != null) {
    return v4.$2 <= 16;
  }
  final v6 = _parseCidrV6(network);
  if (v6 != null) {
    return v6.prefix < 48;
  }
  return false;
}

/// A /64 is the smallest anchor that survives a SLAAC renewal.
String ipv6ToSubnetCidr(String ipv6) {
  final bytes = _parseIpv6(ipv6);
  if (bytes == null) {
    return ipv6;
  }
  final head = [
    for (var i = 0; i < 4; i++)
      ((bytes[i * 2] << 8) | bytes[i * 2 + 1]).toRadixString(16),
  ].join(':');
  return '$head::/64';
}

Uint8List? _parseIpv6(String text) {
  var host = text.trim();
  if (host.startsWith('[') && host.endsWith(']')) {
    host = host.substring(1, host.length - 1);
  }
  final zone = host.indexOf('%');
  if (zone != -1) {
    host = host.substring(0, zone);
  }
  if (!host.contains(':')) {
    return null;
  }
  final parsed = InternetAddress.tryParse(host);
  if (parsed == null || parsed.type != InternetAddressType.IPv6) {
    return null;
  }
  return parsed.rawAddress;
}

/// A /24 is the smallest anchor that survives a DHCP renewal.
String ipv4ToSubnetCidr(String ipv4) {
  final octets = ipv4.split('.');
  if (octets.length != 4) {
    return ipv4;
  }
  return '${octets.take(3).join('.')}.0/24';
}

bool _inTrustedSubnets(String ipv4, List<String> networks) {
  final address = _parseIpv4(ipv4);
  if (address == null) {
    return false;
  }
  for (final network in networks) {
    final cidr = _parseCidrV4(network);
    if (cidr == null) {
      continue;
    }
    final (networkAddress, prefix) = cidr;
    // A /0 rule would trust every network, so it matches nothing.
    if (prefix <= 0) {
      continue;
    }
    if (address >> (32 - prefix) == networkAddress >> (32 - prefix)) {
      return true;
    }
  }
  return false;
}

int? _parseIpv4(String text) {
  final parts = text.trim().split('.');
  if (parts.length != 4) {
    return null;
  }
  var value = 0;
  for (final part in parts) {
    if (part.isEmpty ||
        part.length > 3 ||
        (part.length > 1 && part[0] == '0')) {
      return null;
    }
    final octet = int.tryParse(part);
    if (octet == null || octet < 0 || octet > 255) {
      return null;
    }
    value = (value << 8) | octet;
  }
  return value;
}

(int, int)? _parseCidrV4(String text) {
  final trimmed = text.trim();
  final slash = trimmed.indexOf('/');
  final addressPart = slash == -1 ? trimmed : trimmed.substring(0, slash);
  final prefixPart = slash == -1 ? '32' : trimmed.substring(slash + 1);
  final prefix = int.tryParse(prefixPart);
  if (prefix == null || prefix < 0 || prefix > 32) {
    return null;
  }
  final address = _parseIpv4(addressPart);
  if (address == null) {
    return null;
  }
  final mask = prefix == 0 ? 0 : -1 << (32 - prefix);
  return (address & mask, prefix);
}

({Uint8List network, int prefix})? _parseCidrV6(String text) {
  final trimmed = text.trim();
  final slash = trimmed.indexOf('/');
  final addressPart = slash == -1 ? trimmed : trimmed.substring(0, slash);
  final prefixPart = slash == -1 ? '128' : trimmed.substring(slash + 1);
  final prefix = int.tryParse(prefixPart);
  if (prefix == null || prefix < 0 || prefix > 128) {
    return null;
  }
  final address = _parseIpv6(addressPart);
  if (address == null) {
    return null;
  }
  final masked = Uint8List.fromList(address);
  for (var i = prefix; i < 128; i++) {
    masked[i ~/ 8] &= ~(1 << (7 - i % 8));
  }
  return (network: masked, prefix: prefix);
}

bool _inTrustedSubnetsV6(String ipv6, String network) {
  final address = _parseIpv6(ipv6);
  final cidr = _parseCidrV6(network);
  if (address == null || cidr == null || cidr.prefix <= 0) {
    return false;
  }
  return _maskedPrefixEqual(address, cidr.network, cidr.prefix);
}

bool _maskedPrefixEqual(Uint8List address, Uint8List network, int prefix) {
  final full = prefix ~/ 8;
  for (var i = 0; i < full; i++) {
    if (address[i] != network[i]) {
      return false;
    }
  }
  final rest = prefix % 8;
  if (rest != 0) {
    final mask = 0xFF << (8 - rest) & 0xFF;
    if ((address[full] & mask) != (network[full] & mask)) {
      return false;
    }
  }
  return true;
}
