import 'dart:io';

import 'package:flutter/foundation.dart';

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

/// SSID rules match exactly; subnet rules accept bare IPv4s as /32.
bool smartPauseMatches(
  List<String> networks, {
  String? ssid,
  List<String> ipv4s = const [],
}) {
  final trustedSsid = ssid?.trim().toLowerCase();
  if (trustedSsid != null && trustedSsid.isNotEmpty) {
    for (final network in networks) {
      if (network.trim().toLowerCase() == trustedSsid) {
        return true;
      }
    }
  }
  return ipv4s.any((ipv4) => _inTrustedSubnets(ipv4, networks));
}

/// A rule that parses as an IPv4 subnet needs no location permission to match.
bool isSubnetRule(String network) => _parseCidr(network) != null;

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
    final cidr = _parseCidr(network);
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
    if (part.isEmpty || part.length > 3 || (part.length > 1 && part[0] == '0')) {
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

(int, int)? _parseCidr(String text) {
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
