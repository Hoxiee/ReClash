import 'dart:async';
import 'dart:io';

import 'package:reclash/common/proxy.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import '../kernel.dart';
import '../snapshot.dart';
import 'domains.dart';
import 'hosts.dart';
import 'linux.dart';
import 'macos.dart';
import 'probes.dart';
import 'reader.dart';
import 'windows.dart';

abstract interface class EnvironmentScanner {
  /// [deep] also reads process names, which only a failure or a doctor
  /// refresh asks for.
  Future<void> rescan({bool deep = false});

  /// Elevated where the OS needs it; false when no editor could be opened.
  Future<bool> openHosts();
}

/// What the scan needs to know about the app's own routing, read afresh on
/// every scan.
final class ScanInputs {
  const ScanInputs({
    this.tunDevice,
    this.mixedPort,
    this.controllerPort,
    this.coreConnected = false,
    this.corePid,
  });

  /// Null while TUN is off.
  final String? tunDevice;
  final int? mixedPort;
  final int? controllerPort;
  final bool coreConnected;
  final int? corePid;
}

typedef TcpProbe = Future<bool> Function(String host, int port);
typedef DnsProbe = Future<bool> Function(String server, Duration timeout);

const scanDebounce = Duration(milliseconds: 500);
const _dnsRetryTimeout = Duration(seconds: 2);

/// Exact by Core pid when both pids are known; otherwise our Core runs as
/// `ReClashCore`, and a hidden name counts as ours only while connected.
bool _isOurs(PortOwner owner, ScanInputs inputs) {
  if (owner.pid != null && inputs.corePid != null) {
    return owner.pid == inputs.corePid;
  }
  final name = owner.name.toLowerCase();
  if (name.isNotEmpty) return name.startsWith('reclashcore');
  return inputs.coreConnected;
}

final class DesktopEnvironmentScanner implements EnvironmentScanner {
  DesktopEnvironmentScanner({
    required this.reader,
    required this.sink,
    required this.inputs,
    required this.domains,
    this.debounce = scanDebounce,
    this.tcp = tcpReachable,
    this.dns = dnsAnswers,
  });

  final EnvironmentReader reader;
  final FactSink sink;
  final ScanInputs Function() inputs;
  final RelevantDomains Function() domains;
  final Duration debounce;
  final TcpProbe tcp;
  final DnsProbe dns;

  Timer? _timer;
  bool _wanted = false;
  bool _wantedDeep = false;
  bool _running = false;
  bool _disposed = false;
  final _waiters = <Completer<void>>[];
  HostsSource? _hostsSource;
  int _refilter = 0;

  @override
  Future<void> rescan({bool deep = false}) {
    if (_disposed) return Future.value();
    _wanted = true;
    _wantedDeep |= deep;
    final done = Completer<void>();
    _waiters.add(done);
    _timer?.cancel();
    _timer = Timer(debounce, _drain);
    return done.future;
  }

  @override
  Future<bool> openHosts() => reader.openHosts();

  /// Re-filters the cached `hosts` text for new relevant domains.
  Future<void> refilterHosts() async {
    final source = _hostsSource;
    if (_disposed || source == null) return;
    final token = ++_refilter;
    final fact = await _guard(
      () => parseHostsOffIsolate(reader.hostsPath, source.bytes, domains()),
    );
    if (!_disposed && token == _refilter && fact != null) {
      sink.put(Facts.hosts, fact);
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _waiters.clear();
  }

  Future<void> _drain() async {
    if (_running || _disposed) return;
    _running = true;
    try {
      while (_wanted && !_disposed) {
        final deep = _wantedDeep;
        final waiting = List.of(_waiters);
        _wanted = false;
        _wantedDeep = false;
        _waiters.clear();
        await _scan(deep);
        for (final waiter in waiting) {
          if (!waiter.isCompleted) waiter.complete();
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<T?> _guard<T extends Object>(Future<T?> Function() read) async {
    try {
      return await read();
    } on Object {
      return null;
    }
  }

  Future<void> _scan(bool deep) async {
    final input = inputs();
    await Future.wait([
      _scanHosts(),
      _scanSoftware(deep),
      _scanTunnels(input),
      _scanProxy(),
      _scanPorts(input),
      _scanDns(),
    ]);
  }

  Future<void> _scanHosts() async {
    final token = ++_refilter;
    final fact = await _guard(() async {
      final source = await reader.readHosts(_hostsSource);
      _hostsSource = source;
      if (source == null) return null;
      return parseHostsOffIsolate(reader.hostsPath, source.bytes, domains());
    });
    if (!_disposed && token == _refilter) sink.put(Facts.hosts, fact);
  }

  Future<void> _scanSoftware(bool deep) async {
    final fact = await _guard(() => reader.software(deep: deep));
    if (!_disposed) sink.put(Facts.software, fact);
  }

  Future<void> _scanTunnels(ScanInputs input) async {
    final fact = await _guard(() => reader.tunnels(ours: input.tunDevice));
    if (!_disposed) sink.put(Facts.tunnels, fact);
  }

  Future<void> _scanProxy() async {
    final fact = await _guard(() async {
      final read = await reader.systemProxy();
      if (read == null) return null;
      final port = read.port;
      if (!read.enabled || port == null || !isLoopbackHost(read.host)) {
        return read;
      }
      return SystemProxyFact(
        enabled: read.enabled,
        host: read.host,
        port: port,
        pac: read.pac,
        reachable: await tcp(read.host, port),
      );
    });
    if (!_disposed) sink.put(Facts.systemProxy, fact);
  }

  Future<void> _scanPorts(ScanInputs input) async {
    final wanted = {
      if (input.mixedPort case final port? when port > 0) port: PortRole.mixed,
      if (input.controllerPort case final port? when port > 0)
        port: PortRole.controller,
    };
    final fact = await _guard<List<PortFact>>(() async {
      if (wanted.isEmpty) return const [];
      final owners = await reader.portOwners(wanted.keys.toSet());
      if (owners == null) return null;
      final reserved = await reader.reservedPorts({
        for (final port in wanted.keys)
          if (!owners.containsKey(port)) port,
      });
      return [
        for (final entry in wanted.entries)
          _portFact(
            entry.key,
            entry.value,
            owners[entry.key],
            reserved.contains(entry.key),
            input,
          ),
      ];
    });
    if (!_disposed) sink.put(Facts.ports, fact);
  }

  PortFact _portFact(
    int port,
    PortRole role,
    PortOwner? owner,
    bool reserved,
    ScanInputs input,
  ) {
    if (owner == null) {
      return PortFact(port: port, role: role, reserved: reserved);
    }
    final ours = _isOurs(owner, input);
    return PortFact(
      port: port,
      role: role,
      listening: true,
      ours: ours,
      owner: ours ? '' : owner.name,
    );
  }

  /// A cold local resolver can miss the first short window.
  Future<bool> _answers(String server) async =>
      await dns(server, probeTimeout) || await dns(server, _dnsRetryTimeout);

  Future<void> _scanDns() async {
    final fact = await _guard(() async {
      final servers = await reader.dnsServers();
      if (servers == null) return null;
      var dead = servers.isNotEmpty && servers.every(isLoopbackHost);
      if (dead) {
        final answers = await Future.wait(servers.map(_answers));
        dead = !answers.contains(true);
      }
      return SystemDnsFact(servers: servers, deadLoopback: dead);
    });
    if (!_disposed) sink.put(Facts.systemDns, fact);
  }
}

/// Lets a provider hand out the scanner before the sensor, which owns the
/// sink, has built it.
final class _ScannerLink implements EnvironmentScanner {
  EnvironmentScanner? target;

  @override
  Future<void> rescan({bool deep = false}) =>
      target?.rescan(deep: deep) ?? Future.value();

  @override
  Future<bool> openHosts() async => await target?.openHosts() ?? false;
}

final environmentScannerProvider = Provider<EnvironmentScanner>(
  (ref) => _ScannerLink(),
);

/// Null off the desktop, where the sensor does nothing.
final environmentReaderProvider = Provider<EnvironmentReader?>((ref) {
  if (Platform.isWindows) return WindowsReader();
  if (Platform.isLinux) return LinuxReader();
  if (Platform.isMacOS) return MacosReader();
  return null;
});

int? _controllerPort(ExternalControllerStatus status) {
  final value = status.value;
  return value.isEmpty ? null : int.tryParse(value.split(':').last);
}

void environmentSensor(Ref ref, FactSink sink) {
  final reader = ref.read(environmentReaderProvider);
  if (reader == null) return;
  final scanner = DesktopEnvironmentScanner(
    reader: reader,
    sink: sink,
    inputs: () {
      final config = ref.read(patchClashConfigProvider);
      return ScanInputs(
        tunDevice: config.tun.enable ? config.tun.device : null,
        mixedPort: config.mixedPort,
        controllerPort: _controllerPort(config.externalController),
        coreConnected: ref.read(coreStatusProvider) == CoreStatus.connected,
        corePid: ref.read(coreHandlerProvider).processId,
      );
    },
    domains: () => ref.read(relevantDomainsProvider),
  );
  final link = ref.read(environmentScannerProvider);
  if (link is _ScannerLink) link.target = scanner;
  ref.onDispose(() {
    if (link is _ScannerLink) link.target = null;
    scanner.dispose();
  });

  ref.listen(coreStatusProvider, (previous, next) {
    final failed =
        previous == CoreStatus.connecting && next == CoreStatus.disconnected;
    unawaited(scanner.rescan(deep: failed));
  });
  ref.listen(appVisibleProvider, (previous, next) {
    if (next && previous == false) unawaited(scanner.rescan());
  });
  ref.listen(localIpProvider, (_, _) => unawaited(scanner.rescan()));
  ref.listen(
    patchClashConfigProvider.select(
      (config) => (
        config.tun.enable,
        config.tun.device,
        config.mixedPort,
        config.externalController,
      ),
    ),
    (_, _) => unawaited(scanner.rescan()),
  );
  ref.listen(
    proxyStateProvider.select((state) => (state.isStart, state.systemProxy)),
    (_, _) => unawaited(scanner.rescan()),
  );
  ref.listen(
    relevantDomainsProvider,
    (_, _) => unawaited(scanner.refilterHosts()),
  );
  final queue = systemProxyQueue;
  if (queue != null) {
    final subscription = queue.ownPorts.listen(
      (_) => unawaited(scanner.rescan()),
    );
    ref.onDispose(subscription.cancel);
  }
  _watchHosts(ref, reader.hostsPath, scanner);
  unawaited(scanner.rescan());
}

/// Editors replace the file atomically, so the directory is watched.
void _watchHosts(Ref ref, String hostsPath, EnvironmentScanner scanner) {
  try {
    final name = File(hostsPath).uri.pathSegments.last;
    final subscription = Directory(File(hostsPath).parent.path).watch().listen((
      event,
    ) {
      if (event.path.split(Platform.pathSeparator).last == name) {
        unawaited(scanner.rescan());
      }
    }, onError: (_) {});
    ref.onDispose(subscription.cancel);
  } on Object {
    return;
  }
}
