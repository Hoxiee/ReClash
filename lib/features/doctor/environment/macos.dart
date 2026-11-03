import 'dart:io';

import 'catalogue.dart';
import 'facts.dart';
import 'reader.dart';
import 'tunnels.dart';

/// `netstat -rn -f inet`. Destinations may be abbreviated (`128.0/1`,
/// `192.168.1`), and a bare count of octets implies a classful prefix.
List<RouteEntry> parseNetstatInet(String text) {
  final routes = <RouteEntry>[];
  for (final line in text.split('\n')) {
    final f = line.trim().split(RegExp(r'\s+'));
    if (f.length < 4) continue;
    final destination = f[0];
    String address;
    int prefix;
    if (destination == 'default') {
      address = '0.0.0.0';
      prefix = 0;
    } else {
      final slash = destination.indexOf('/');
      final octets = (slash < 0 ? destination : destination.substring(0, slash))
          .split('.');
      if (octets.length > 4 || octets.any((o) => int.tryParse(o) == null)) {
        continue;
      }
      prefix = slash < 0
          ? octets.length * 8
          : int.tryParse(destination.substring(slash + 1)) ?? -1;
      if (prefix < 0 || prefix > 32) continue;
      address = [...octets, ...List.filled(4 - octets.length, '0')].join('.');
    }
    final adapter = f[3];
    if (!RegExp(r'^[a-z]+\d+$').hasMatch(adapter)) continue;
    routes.add(
      RouteEntry(
        adapter: adapter,
        destination: InternetAddress(address),
        prefix: prefix,
      ),
    );
  }
  return routes;
}

/// `scutil --dns`, up to the scoped section.
List<String> parseScutilDns(String text) {
  final servers = <String>[];
  for (final line in text.split('\n')) {
    if (line.contains('for scoped queries')) break;
    final m = RegExp(r'nameserver\[\d+\]\s*:\s*(\S+)').firstMatch(line);
    if (m != null && !servers.contains(m.group(1))) servers.add(m.group(1)!);
  }
  return servers;
}

/// `scutil --proxy`.
SystemProxyFact? parseScutilProxy(String text) {
  final values = <String, String>{};
  for (final line in text.split('\n')) {
    final m = RegExp(r'^\s*(\w+)\s*:\s*(.*?)\s*$').firstMatch(line);
    if (m != null) values[m.group(1)!] = m.group(2)!;
  }
  if (values.isEmpty) return null;
  String host = '';
  int? port;
  for (final scheme in const ['HTTP', 'HTTPS', 'SOCKS']) {
    if (values['${scheme}Enable'] == '1') {
      host = values['${scheme}Proxy'] ?? '';
      port = int.tryParse(values['${scheme}Port'] ?? '');
      break;
    }
  }
  final pac = values['ProxyAutoConfigEnable'] == '1'
      ? values['ProxyAutoConfigURLString'] ?? ''
      : '';
  return SystemProxyFact(
    enabled: host.isNotEmpty,
    host: host,
    port: port,
    pac: pac,
  );
}

/// `lsof -F pc` output: `p<pid>` then `c<command>` per process.
PortOwner? parseLsofOwner(String text) {
  int? pid;
  var name = '';
  for (final line in text.split('\n')) {
    if (line.startsWith('p')) pid ??= int.tryParse(line.substring(1));
    if (line.startsWith('c') && name.isEmpty) name = line.substring(1);
  }
  return pid == null ? null : PortOwner(pid: pid, name: name);
}

Future<String?> _run(String exe, List<String> args) async {
  try {
    final result = await Process.run(exe, args);
    return result.exitCode == 0 ? result.stdout as String : null;
  } on Object {
    return null;
  }
}

final class MacosReader extends EnvironmentReader {
  @override
  String get hostsPath => '/etc/hosts';

  @override
  Future<SoftwareFact?> software({required bool deep}) async {
    if (!deep) return const SoftwareFact();
    final out = await _run('ps', ['-axco', 'comm']);
    if (out == null) return null;
    final wanted = catalogueProcesses;
    final names = {
      for (final line in out.split('\n'))
        if (wanted.contains(line.trim().toLowerCase()))
          line.trim().toLowerCase(),
    };
    return SoftwareFact(
      processes: names.toList()..sort(),
      processesScanned: true,
    );
  }

  /// mihomo picks the `utunN` itself, so a configured name that is not one
  /// cannot be matched: nothing is claimed then.
  @override
  Future<TunnelsFact?> tunnels({String? ours}) async {
    if (ours != null && !ours.startsWith('utun')) return null;
    final names = await _run('ifconfig', ['-lu']);
    final table = await _run('netstat', ['-rn', '-f', 'inet']);
    if (names == null || table == null) return null;
    return buildTunnels(
      adapters: [
        for (final name in names.trim().split(RegExp(r'\s+')))
          if (name.startsWith('utun')) AdapterInfo(name: name),
      ],
      routes: parseNetstatInet(table),
      ours: ours,
    );
  }

  @override
  Future<SystemProxyFact?> systemProxy() async {
    final out = await _run('scutil', ['--proxy']);
    return out == null ? null : parseScutilProxy(out);
  }

  @override
  Future<Map<int, PortOwner>?> portOwners(Set<int> ports) async {
    final owners = <int, PortOwner>{};
    for (final port in ports) {
      final out = await _run('lsof', [
        '-nP',
        '-iTCP:$port',
        '-sTCP:LISTEN',
        '-Fpc',
      ]);
      final owner = out == null ? null : parseLsofOwner(out);
      if (owner != null) owners[port] = owner;
    }
    return owners;
  }

  @override
  Future<List<String>?> dnsServers() async {
    final out = await _run('scutil', ['--dns']);
    return out == null ? null : parseScutilDns(out);
  }

  @override
  Future<bool> openHosts() async {
    try {
      await Process.start('open', [
        '-t',
        hostsPath,
      ], mode: ProcessStartMode.detached);
      return true;
    } on Object {
      return false;
    }
  }
}
