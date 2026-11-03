import 'package:flutter/foundation.dart';

/// Why a `hosts` entry matters: it names a domain ReClash itself depends on,
/// or a service users commonly reach through it.
enum DomainRole { subscription, test, service }

@immutable
final class HostsEntry {
  const HostsEntry({
    required this.line,
    required this.text,
    required this.domain,
    required this.address,
    required this.role,
  });

  /// 1-based, as an editor shows it.
  final int line;

  /// The raw line, which a Helper edit must still find unchanged.
  final String text;
  final String domain;
  final String address;
  final DomainRole role;

  /// Points the domain nowhere instead of somewhere else.
  bool get blackhole =>
      address == '0.0.0.0' ||
      address == '::' ||
      address == '::1' ||
      address.startsWith('127.');

  @override
  bool operator ==(Object other) =>
      other is HostsEntry &&
      other.line == line &&
      other.text == text &&
      other.domain == domain &&
      other.address == address &&
      other.role == role;

  @override
  int get hashCode => Object.hash(line, text, domain, address, role);
}

/// The system `hosts` file, kept to the entries for relevant domains so a
/// blocklist of a hundred thousand lines does not ride in the snapshot.
@immutable
final class HostsFact {
  const HostsFact({
    required this.path,
    required this.lineCount,
    this.entries = const [],
    this.markers = const [],
  });

  final String path;
  final int lineCount;
  final List<HostsEntry> entries;

  /// Comment lines, trimmed and capped, which tools that write `hosts` sign
  /// their blocks with.
  final List<String> markers;

  @override
  bool operator ==(Object other) =>
      other is HostsFact &&
      other.path == path &&
      other.lineCount == lineCount &&
      listEquals(other.entries, entries) &&
      listEquals(other.markers, markers);

  @override
  int get hashCode => Object.hash(
    path,
    lineCount,
    Object.hashAll(entries),
    Object.hashAll(markers),
  );
}

/// What runs on the machine, by name only, lowercased. Read with query
/// rights alone: nothing here was opened in a way that could change it.
@immutable
final class SoftwareFact {
  const SoftwareFact({
    this.services = const [],
    this.drivers = const [],
    this.processes = const [],
    this.processesScanned = false,
  });

  /// Running services among the names the catalogue asks about.
  final List<String> services;

  /// Loaded kernel drivers among the names the catalogue asks about.
  final List<String> drivers;

  /// Running image names (Windows `goodbyedpi.exe`, Unix `nfqws`).
  final List<String> processes;

  /// Process names are read only after a failure or on a doctor refresh; an
  /// empty list then means nothing, not "none running".
  final bool processesScanned;

  @override
  bool operator ==(Object other) =>
      other is SoftwareFact &&
      listEquals(other.services, services) &&
      listEquals(other.drivers, drivers) &&
      listEquals(other.processes, processes) &&
      other.processesScanned == processesScanned;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(services),
    Object.hashAll(drivers),
    Object.hashAll(processes),
    processesScanned,
  );
}

enum TunnelKind { wintun, tap, wireguard, utun, tun, other }

@immutable
final class TunnelAdapter {
  const TunnelAdapter({
    required this.name,
    required this.kind,
    this.description = '',
    this.defaultRoute = false,
    this.metric,
  });

  final String name;
  final TunnelKind kind;

  /// The driver's description on Windows, which names the app that made it.
  final String description;

  /// Holds a default or split-default (`0/1`, `128/1`) route.
  final bool defaultRoute;
  final int? metric;

  @override
  bool operator ==(Object other) =>
      other is TunnelAdapter &&
      other.name == name &&
      other.kind == kind &&
      other.description == description &&
      other.defaultRoute == defaultRoute &&
      other.metric == metric;

  @override
  int get hashCode =>
      Object.hash(name, kind, description, defaultRoute, metric);
}

/// Tunnel adapters that are up, ours apart from the others.
@immutable
final class TunnelsFact {
  const TunnelsFact({
    this.ours,
    this.foreign = const [],
    this.routedThroughOurs,
  });

  /// The adapter named as our TUN device; null when none is up.
  final TunnelAdapter? ours;
  final List<TunnelAdapter> foreign;

  /// Whether the best route to a public address leaves through [ours]; null
  /// when our tunnel is not up or the route could not be read.
  final bool? routedThroughOurs;

  @override
  bool operator ==(Object other) =>
      other is TunnelsFact &&
      other.ours == ours &&
      listEquals(other.foreign, foreign) &&
      other.routedThroughOurs == routedThroughOurs;

  @override
  int get hashCode =>
      Object.hash(ours, Object.hashAll(foreign), routedThroughOurs);
}

/// The system proxy as the OS has it now, whoever set it.
@immutable
final class SystemProxyFact {
  const SystemProxyFact({
    required this.enabled,
    this.host = '',
    this.port,
    this.pac = '',
    this.reachable,
  });

  final bool enabled;
  final String host;
  final int? port;

  /// An automatic configuration URL, empty when none is set.
  final String pac;

  /// Whether something accepts connections on a loopback [host]:[port]; null
  /// for a remote proxy or when nothing is set.
  final bool? reachable;

  @override
  bool operator ==(Object other) =>
      other is SystemProxyFact &&
      other.enabled == enabled &&
      other.host == host &&
      other.port == port &&
      other.pac == pac &&
      other.reachable == reachable;

  @override
  int get hashCode => Object.hash(enabled, host, port, pac, reachable);
}

enum PortRole { mixed, controller }

@immutable
final class PortFact {
  const PortFact({
    required this.port,
    required this.role,
    this.listening = false,
    this.ours = false,
    this.reserved = false,
    this.owner = '',
  });

  final int port;
  final PortRole role;

  /// Someone accepts connections on it.
  final bool listening;

  /// The listener is our Core.
  final bool ours;

  /// Inside a Windows excluded port range, so nobody can bind it.
  final bool reserved;

  /// The listener's image name when it is not ours and could be read.
  final String owner;

  @override
  bool operator ==(Object other) =>
      other is PortFact &&
      other.port == port &&
      other.role == role &&
      other.listening == listening &&
      other.ours == ours &&
      other.reserved == reserved &&
      other.owner == owner;

  @override
  int get hashCode => Object.hash(port, role, listening, ours, reserved, owner);
}

@immutable
final class SystemDnsFact {
  const SystemDnsFact({this.servers = const [], this.deadLoopback = false});

  final List<String> servers;

  /// Every resolver is a loopback address with nothing listening on port 53,
  /// as a DNS proxy that stopped leaves it.
  final bool deadLoopback;

  @override
  bool operator ==(Object other) =>
      other is SystemDnsFact &&
      listEquals(other.servers, servers) &&
      other.deadLoopback == deadLoopback;

  @override
  int get hashCode => Object.hash(Object.hashAll(servers), deadLoopback);
}
