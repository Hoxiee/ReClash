import 'dart:io';
import 'dart:typed_data';

import 'facts.dart';

/// The owner of a listening socket; [pid] is null when the OS hid it.
final class PortOwner {
  const PortOwner({this.pid, this.name = ''});

  final int? pid;
  final String name;
}

/// A cached read of the `hosts` file, valid while [stamp] holds.
final class HostsSource {
  const HostsSource(this.bytes, this.stamp);

  final Uint8List bytes;
  final String stamp;
}

/// The part of the environment scan that differs per OS. Every method is
/// read-only and answers null when the OS gave nothing usable.
abstract class EnvironmentReader {
  String get hostsPath;

  /// Null when the file is missing; [previous] is returned as is while the
  /// file is unchanged.
  Future<HostsSource?> readHosts(HostsSource? previous) async {
    final file = File(hostsPath);
    final stat = await file.stat();
    if (stat.type == FileSystemEntityType.notFound) return null;
    final stamp = '${stat.modified.microsecondsSinceEpoch}:${stat.size}';
    if (previous != null && previous.stamp == stamp) return previous;
    return HostsSource(await file.readAsBytes(), stamp);
  }

  Future<SoftwareFact?> software({required bool deep});

  /// [ours] is the device name of our TUN, null while it is off.
  Future<TunnelsFact?> tunnels({String? ours});

  /// The system proxy without [SystemProxyFact.reachable].
  Future<SystemProxyFact?> systemProxy();

  /// The listening sockets among [ports].
  Future<Map<int, PortOwner>?> portOwners(Set<int> ports);

  /// Ports nobody can bind although nothing listens.
  Future<Set<int>> reservedPorts(Set<int> ports) async => const {};

  Future<List<String>?> dnsServers();

  Future<bool> openHosts();
}

/// Parses `host:port` or `scheme=host:port;...` as Windows stores
/// `ProxyServer`, preferring the HTTP entry.
({String host, int? port}) parseProxyServer(String value) {
  final parts = value.split(';').map((part) => part.trim()).toList();
  String pick() {
    for (final scheme in const ['http=', 'https=']) {
      for (final part in parts) {
        if (part.startsWith(scheme)) return part.substring(scheme.length);
      }
    }
    return parts.firstWhere((part) => part.isNotEmpty, orElse: () => '');
  }

  var target = pick();
  final eq = target.indexOf('=');
  if (eq >= 0) target = target.substring(eq + 1);
  target = target.replaceFirst(RegExp(r'^[a-z]+://'), '');
  final colon = target.lastIndexOf(':');
  if (colon < 0) return (host: target, port: null);
  return (
    host: target.substring(0, colon).replaceAll(RegExp(r'^\[|\]$'), ''),
    port: int.tryParse(target.substring(colon + 1)),
  );
}

bool isLoopbackHost(String host) {
  final name = host.toLowerCase().replaceAll(RegExp(r'^\[|\]$'), '');
  return name == 'localhost' ||
      InternetAddress.tryParse(name)?.isLoopback == true;
}
