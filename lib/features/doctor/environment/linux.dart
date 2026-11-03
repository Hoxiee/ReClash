import 'dart:io';
import 'dart:typed_data';

import 'catalogue.dart';
import 'facts.dart';
import 'reader.dart';
import 'tunnels.dart';

/// `/proc/net/route`: little-endian hex addresses.
List<RouteEntry> parseProcNetRoute(String text) {
  final routes = <RouteEntry>[];
  for (final line in text.split('\n').skip(1)) {
    final f = line.trim().split(RegExp(r'\s+'));
    if (f.length < 8) continue;
    final destination = int.tryParse(f[1], radix: 16);
    final mask = int.tryParse(f[7], radix: 16);
    if (destination == null || mask == null) continue;
    routes.add(
      RouteEntry(
        adapter: f[0],
        destination: InternetAddress.fromRawAddress(
          Uint8List.fromList([
            for (var i = 0; i < 4; i++) (destination >> (8 * i)) & 0xFF,
          ]),
        ),
        prefix: _bitCount(mask),
        metric: int.tryParse(f[6]),
      ),
    );
  }
  return routes;
}

/// `/proc/net/ipv6_route`: destination, prefix length, ..., metric, ..., name.
List<RouteEntry> parseProcNetIpv6Route(String text) {
  final routes = <RouteEntry>[];
  for (final line in text.split('\n')) {
    final f = line.trim().split(RegExp(r'\s+'));
    if (f.length < 10 || f[0].length != 32) continue;
    final prefix = int.tryParse(f[1], radix: 16);
    final metric = int.tryParse(f[5], radix: 16);
    if (prefix == null) continue;
    routes.add(
      RouteEntry(
        adapter: f[9],
        destination: InternetAddress.fromRawAddress(
          Uint8List.fromList([
            for (var i = 0; i < 16; i++)
              int.parse(f[0].substring(i * 2, i * 2 + 2), radix: 16),
          ]),
        ),
        prefix: prefix,
        metric: metric,
      ),
    );
  }
  return routes;
}

int _bitCount(int value) {
  var count = 0;
  for (var v = value; v != 0; v >>= 1) {
    count += v & 1;
  }
  return count;
}

/// Reads `nameserver` lines of `resolv.conf`.
List<String> parseResolvConf(String text) => [
  for (final line in text.split('\n'))
    if (RegExp(r'^\s*nameserver\s+(\S+)').firstMatch(line) case final m?)
      m.group(1)!.split('%').first,
];

/// Local ports of listening sockets mapped to inodes, from `/proc/net/tcp*`.
Map<int, String> parseProcNetTcp(String text, Set<int> ports) {
  final found = <int, String>{};
  for (final line in text.split('\n').skip(1)) {
    final f = line.trim().split(RegExp(r'\s+'));
    if (f.length < 10 || f[3] != '0A') continue;
    final colon = f[1].lastIndexOf(':');
    final port = colon < 0
        ? null
        : int.tryParse(f[1].substring(colon + 1), radix: 16);
    if (port != null && ports.contains(port)) found[port] = f[9];
  }
  return found;
}

/// `gsettings list-recursively org.gnome.system.proxy`.
SystemProxyFact? parseGsettingsProxy(String text) {
  final values = <String, String>{};
  for (final line in text.split('\n')) {
    final m = RegExp(r'^(\S+)\s+(\S+)\s+(.*)$').firstMatch(line.trim());
    if (m == null) continue;
    values['${m.group(1)}/${m.group(2)}'] = m.group(3)!.replaceAll("'", '');
  }
  const base = 'org.gnome.system.proxy';
  final mode = values['$base/mode'];
  if (mode == null) return null;
  var host = '';
  int? port;
  for (final scheme in const ['http', 'https', 'socks']) {
    final h = values['$base.$scheme/host'] ?? '';
    if (h.isNotEmpty) {
      host = h;
      port = int.tryParse(values['$base.$scheme/port'] ?? '');
      break;
    }
  }
  return SystemProxyFact(
    enabled: mode == 'manual' && host.isNotEmpty,
    host: mode == 'manual' ? host : '',
    port: mode == 'manual' ? port : null,
    pac: mode == 'auto' ? values['$base/autoconfig-url'] ?? '' : '',
  );
}

/// One `/sys/class/net/<name>` entry; null when it is not a tunnel that is
/// up. A kernel tunnel has ARPHRD_NONE (65534) as its type.
AdapterInfo? parseSysNetAdapter({
  required String name,
  required String type,
  required String flags,
  required bool hasTunFlags,
  String uevent = '',
}) {
  final up =
      ((int.tryParse(flags.trim().replaceFirst('0x', ''), radix: 16) ?? 0) &
          1) !=
      0;
  if (!up) return null;
  if (type.trim() != '65534' && !hasTunFlags) return null;
  final wireguard = uevent.contains('DEVTYPE=wireguard');
  return AdapterInfo(name: name, description: wireguard ? 'wireguard' : '');
}

final class LinuxReader extends EnvironmentReader {
  @override
  String get hostsPath => '/etc/hosts';

  @override
  Future<SoftwareFact?> software({required bool deep}) async {
    if (!deep) return const SoftwareFact();
    final wanted = catalogueProcesses;
    final names = <String>{};
    try {
      await for (final entry in Directory('/proc').list(followLinks: false)) {
        if (int.tryParse(
              entry.uri.pathSegments.where((s) => s.isNotEmpty).last,
            ) ==
            null) {
          continue;
        }
        try {
          final comm = (await File(
            '${entry.path}/comm',
          ).readAsString()).trim().toLowerCase();
          if (wanted.contains(comm)) names.add(comm);
        } on Object {
          continue;
        }
      }
    } on Object {
      return null;
    }
    return SoftwareFact(
      processes: names.toList()..sort(),
      processesScanned: true,
    );
  }

  @override
  Future<TunnelsFact?> tunnels({String? ours}) async {
    final adapters = <AdapterInfo>[];
    try {
      await for (final entry in Directory('/sys/class/net').list()) {
        final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
        try {
          final info = parseSysNetAdapter(
            name: name,
            type: await File('${entry.path}/type').readAsString(),
            flags: await File('${entry.path}/flags').readAsString(),
            hasTunFlags: await File('${entry.path}/tun_flags').exists(),
            uevent: await _readOr('${entry.path}/uevent'),
          );
          if (info != null) adapters.add(info);
        } on Object {
          continue;
        }
      }
      final routes = [
        ...parseProcNetRoute(await _readOr('/proc/net/route')),
        ...parseProcNetIpv6Route(await _readOr('/proc/net/ipv6_route')),
      ];
      return buildTunnels(
        adapters: adapters,
        routes: routes,
        ours: ours,
        checkRouting: false,
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<SystemProxyFact?> systemProxy() async {
    try {
      final result = await Process.run('gsettings', [
        'list-recursively',
        'org.gnome.system.proxy',
      ]);
      if (result.exitCode != 0) return null;
      return parseGsettingsProxy(result.stdout as String);
    } on Object {
      return null;
    }
  }

  @override
  Future<Map<int, PortOwner>?> portOwners(Set<int> ports) async {
    try {
      final inodes = <int, String>{
        ...parseProcNetTcp(await _readOr('/proc/net/tcp'), ports),
        ...parseProcNetTcp(await _readOr('/proc/net/tcp6'), ports),
      };
      if (inodes.isEmpty) return const {};
      final owners = {for (final port in inodes.keys) port: const PortOwner()};
      final byInode = {
        for (final e in inodes.entries) 'socket:[${e.value}]': e.key,
      };
      await for (final entry in Directory('/proc').list(followLinks: false)) {
        final pid = int.tryParse(
          entry.uri.pathSegments.where((s) => s.isNotEmpty).last,
        );
        if (pid == null) continue;
        try {
          await for (final fd in Directory(
            '${entry.path}/fd',
          ).list(followLinks: false)) {
            final target = await Link(fd.path).target();
            final port = byInode[target];
            if (port == null) continue;
            owners[port] = PortOwner(
              pid: pid,
              name: (await _readOr('${entry.path}/comm')).trim(),
            );
          }
        } on Object {
          continue;
        }
      }
      return owners;
    } on Object {
      return null;
    }
  }

  @override
  Future<List<String>?> dnsServers() async {
    final text = await _readOr('/etc/resolv.conf');
    return text.isEmpty ? null : parseResolvConf(text);
  }

  @override
  Future<bool> openHosts() async {
    try {
      await Process.start('xdg-open', [
        hostsPath,
      ], mode: ProcessStartMode.detached);
      return true;
    } on Object {
      return false;
    }
  }
}

Future<String> _readOr(String path) async {
  try {
    return await File(path).readAsString();
  } on Object {
    return '';
  }
}
