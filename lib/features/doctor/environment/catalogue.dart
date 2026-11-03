import 'package:flutter/foundation.dart';

import 'facts.dart';

enum ConflictKind { vpnClient, dpiBypass, proxy, tlsScanner }

/// Software known to take the same traffic as ReClash. Detection is by effect;
/// an entry only names what was already found. Every name is lowercase, and
/// none is ours: our Core runs as `ReClashCore`.
@immutable
final class ConflictEntry {
  const ConflictEntry({
    required this.id,
    required this.name,
    required this.kind,
    this.services = const [],
    this.drivers = const [],
    this.processes = const [],
    this.adapterPatterns = const [],
    this.hostsMarkers = const [],
  });

  final String id;
  final String name;
  final ConflictKind kind;
  final List<String> services;
  final List<String> drivers;
  final List<String> processes;

  /// Substrings of an adapter's name or description that only this app uses.
  final List<String> adapterPatterns;

  /// Substrings of the comments it signs its `hosts` blocks with.
  final List<String> hostsMarkers;
}

const conflictCatalogue = <ConflictEntry>[
  ConflictEntry(
    id: 'goodbyedpi',
    name: 'GoodbyeDPI',
    kind: ConflictKind.dpiBypass,
    services: ['goodbyedpi'],
    drivers: ['windivert', 'windivert14'],
    processes: ['goodbyedpi.exe'],
    hostsMarkers: ['goodbyedpi'],
  ),
  ConflictEntry(
    id: 'zapret',
    name: 'zapret',
    kind: ConflictKind.dpiBypass,
    services: ['zapret', 'winws1', 'winws2'],
    drivers: ['windivert', 'windivert14'],
    processes: ['winws.exe', 'nfqws', 'tpws'],
    hostsMarkers: ['zapret'],
  ),
  ConflictEntry(
    id: 'happ',
    name: 'Happ',
    kind: ConflictKind.vpnClient,
    processes: ['happ.exe', 'happ'],
    adapterPatterns: ['happ'],
  ),
  ConflictEntry(
    id: 'hiddify',
    name: 'Hiddify',
    kind: ConflictKind.vpnClient,
    services: ['hiddifytunnelservice'],
    processes: ['hiddify.exe', 'hiddifycli.exe', 'hiddify'],
    adapterPatterns: ['hiddify'],
  ),
  ConflictEntry(
    id: 'v2rayn',
    name: 'v2rayN',
    kind: ConflictKind.vpnClient,
    processes: ['v2rayn.exe', 'v2rayn'],
  ),
  ConflictEntry(
    id: 'nekoray',
    name: 'NekoRay / Throne',
    kind: ConflictKind.vpnClient,
    processes: [
      'nekoray.exe',
      'nekobox.exe',
      'throne.exe',
      'nekoray',
      'throne',
    ],
    adapterPatterns: ['nekoray', 'throne'],
  ),
  ConflictEntry(
    id: 'clashVerge',
    name: 'Clash Verge',
    kind: ConflictKind.vpnClient,
    services: ['clash_verge_service'],
    processes: ['clash-verge.exe', 'clash-verge', 'verge-mihomo.exe'],
  ),
  ConflictEntry(
    id: 'flclash',
    name: 'FlClash',
    kind: ConflictKind.vpnClient,
    services: ['flclashhelperservice'],
    processes: ['flclash.exe', 'flclashcore.exe', 'flclash', 'flclashcore'],
    adapterPatterns: ['flclash'],
  ),
  ConflictEntry(
    id: 'mihomoParty',
    name: 'Mihomo Party',
    kind: ConflictKind.vpnClient,
    services: ['mihomo-party-service'],
    processes: ['mihomo party.exe', 'mihomo-party', 'mihomo.exe'],
    adapterPatterns: ['mihomo'],
  ),
  ConflictEntry(
    id: 'singBox',
    name: 'sing-box',
    kind: ConflictKind.proxy,
    processes: ['sing-box.exe', 'sing-box'],
    adapterPatterns: ['sing-box'],
  ),
  ConflictEntry(
    id: 'xray',
    name: 'Xray',
    kind: ConflictKind.proxy,
    processes: ['xray.exe', 'xray', 'v2ray.exe', 'v2ray'],
  ),
  ConflictEntry(
    id: 'amnezia',
    name: 'AmneziaVPN',
    kind: ConflictKind.vpnClient,
    services: ['amneziavpn-service', 'amneziawgtunnel'],
    processes: ['amneziavpn.exe', 'amneziavpn-service.exe', 'amneziavpn'],
    adapterPatterns: ['amnezia'],
  ),
  ConflictEntry(
    id: 'wireguard',
    name: 'WireGuard',
    kind: ConflictKind.vpnClient,
    services: ['wireguardmanager'],
    processes: ['wireguard.exe'],
    adapterPatterns: ['wireguard tunnel'],
  ),
  ConflictEntry(
    id: 'openvpn',
    name: 'OpenVPN',
    kind: ConflictKind.vpnClient,
    services: ['openvpnservice', 'ovpnconnectservice'],
    processes: [
      'openvpn.exe',
      'openvpn-gui.exe',
      'openvpnconnect.exe',
      'openvpn',
    ],
    adapterPatterns: ['tap-windows', 'openvpn'],
  ),
];

/// Every name the catalogue asks a scanner about, so it reads no more.
final catalogueServices = {for (final e in conflictCatalogue) ...e.services};
final catalogueDrivers = {for (final e in conflictCatalogue) ...e.drivers};
final catalogueProcesses = {for (final e in conflictCatalogue) ...e.processes};

/// Entries whose service, driver or process is running. A shared driver
/// such as WinDivert alone names nothing: both its users stay unnamed.
List<ConflictEntry> matchSoftware(SoftwareFact software) {
  final services = {for (final s in software.services) s.toLowerCase()};
  final processes = {for (final p in software.processes) p.toLowerCase()};
  return [
    for (final entry in conflictCatalogue)
      if (entry.services.any(services.contains) ||
          entry.processes.any(processes.contains))
        entry,
  ];
}

/// Whether a driver that only interceptors load is running, named or not.
bool interceptorDriverLoaded(SoftwareFact software) => software.drivers.any(
  (d) => conflictCatalogue.any(
    (e) =>
        e.kind == ConflictKind.dpiBypass && e.drivers.contains(d.toLowerCase()),
  ),
);

ConflictEntry? matchAdapter(TunnelAdapter adapter) {
  final text = '${adapter.name} ${adapter.description}'.toLowerCase();
  for (final entry in conflictCatalogue) {
    if (entry.adapterPatterns.any(text.contains)) return entry;
  }
  return null;
}

ConflictEntry? matchHostsMarkers(List<String> markers) {
  for (final marker in markers) {
    final text = marker.toLowerCase();
    for (final entry in conflictCatalogue) {
      if (entry.hostsMarkers.any(text.contains)) return entry;
    }
  }
  return null;
}
