import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/environment/domains.dart';
import 'package:reclash/features/doctor/environment/reader.dart';
import 'package:reclash/features/doctor/environment/scanner.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/snapshot.dart';

class _Sink implements FactSink {
  final values = <String, Object?>{};
  int puts = 0;

  @override
  void put<T extends Object>(FactKey<T> key, T? value, {Duration? ttl}) {
    puts++;
    values[key.id] = value;
  }
}

class _Reader extends EnvironmentReader {
  final scans = <bool>[];
  int hostsReads = 0;
  Completer<void>? gate;
  List<String>? dns = ['127.0.0.1'];
  Map<int, PortOwner>? owners = {};
  bool failTunnels = false;
  String hostsText = '0.0.0.0 youtube.com\n';

  @override
  String get hostsPath => '/etc/hosts';

  @override
  Future<HostsSource?> readHosts(HostsSource? previous) async {
    hostsReads++;
    return HostsSource(Uint8List.fromList(hostsText.codeUnits), 'x');
  }

  @override
  Future<SoftwareFact?> software({required bool deep}) async {
    scans.add(deep);
    await gate?.future;
    return SoftwareFact(processesScanned: deep);
  }

  @override
  Future<TunnelsFact?> tunnels({String? ours}) async {
    if (failTunnels) throw StateError('boom');
    return const TunnelsFact();
  }

  @override
  Future<SystemProxyFact?> systemProxy() async =>
      const SystemProxyFact(enabled: true, host: '127.0.0.1', port: 7890);

  @override
  Future<Map<int, PortOwner>?> portOwners(Set<int> ports) async => owners;

  @override
  Future<List<String>?> dnsServers() async => dns;

  @override
  Future<bool> openHosts() async => true;
}

DesktopEnvironmentScanner _scanner(
  _Reader reader,
  _Sink sink, {
  ScanInputs inputs = const ScanInputs(mixedPort: 7890, coreConnected: true),
  RelevantDomains domains = const RelevantDomains(),
}) => DesktopEnvironmentScanner(
  reader: reader,
  sink: sink,
  inputs: () => inputs,
  domains: () => domains,
  tcp: (_, _) async => true,
  dns: (_, _) async => false,
);

void main() {
  test('debounces bursts into one scan and deep wins', () {
    fakeAsync((async) {
      final reader = _Reader();
      final scanner = _scanner(reader, _Sink());
      scanner.rescan();
      async.elapse(const Duration(milliseconds: 300));
      scanner.rescan(deep: true);
      scanner.rescan();
      async.elapse(const Duration(milliseconds: 499));
      expect(reader.scans, isEmpty);
      async.elapse(const Duration(milliseconds: 2));
      async.flushMicrotasks();
      expect(reader.scans, [true]);
      scanner.dispose();
    });
  });

  test('never overlaps scans and coalesces into one trailing scan', () {
    fakeAsync((async) {
      final reader = _Reader()..gate = Completer<void>();
      final scanner = _scanner(reader, _Sink());
      scanner.rescan();
      async.elapse(const Duration(milliseconds: 600));
      expect(reader.scans, [false]);
      scanner.rescan();
      scanner.rescan(deep: true);
      async.elapse(const Duration(seconds: 2));
      expect(reader.scans, [false]);
      final gate = reader.gate!;
      reader.gate = null;
      gate.complete();
      async.flushMicrotasks();
      expect(reader.scans, [false, true]);
      scanner.dispose();
    });
  });

  test('puts every fact; one failing reader omits only its fact', () {
    fakeAsync((async) {
      final reader = _Reader()
        ..failTunnels = true
        ..owners = {7890: const PortOwner(pid: 4, name: 'other.exe')};
      final sink = _Sink();
      final scanner = _scanner(reader, sink, domains: const RelevantDomains());
      scanner.rescan();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(sink.values['network.tunnels'], isNull);
      expect(sink.values['system.software'], const SoftwareFact());
      expect(sink.values['system.hosts'], isA<HostsFact>());
      expect(
        sink.values['network.systemProxy'],
        const SystemProxyFact(
          enabled: true,
          host: '127.0.0.1',
          port: 7890,
          reachable: true,
        ),
      );
      expect(sink.values['network.ports'], [
        const PortFact(
          port: 7890,
          role: PortRole.mixed,
          listening: true,
          owner: 'other.exe',
        ),
      ]);
      expect(
        sink.values['network.systemDns'],
        const SystemDnsFact(servers: ['127.0.0.1'], deadLoopback: true),
      );
      scanner.dispose();
    });
  });

  test('a loopback resolver that misses the short window gets a retry', () {
    fakeAsync((async) {
      final sink = _Sink();
      final timeouts = <Duration>[];
      final scanner = DesktopEnvironmentScanner(
        reader: _Reader(),
        sink: sink,
        inputs: () => const ScanInputs(),
        domains: () => const RelevantDomains(),
        tcp: (_, _) async => true,
        dns: (_, timeout) async {
          timeouts.add(timeout);
          return timeout > const Duration(seconds: 1);
        },
      );
      scanner.rescan();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(timeouts, hasLength(2));
      expect(
        sink.values['network.systemDns'],
        const SystemDnsFact(servers: ['127.0.0.1'], deadLoopback: false),
      );
      scanner.dispose();
    });
  });

  test('a hidden owner is ours only while the Core is connected', () {
    fakeAsync((async) {
      final reader = _Reader()..owners = {7890: const PortOwner()};
      final sink = _Sink();
      var connected = true;
      final scanner = DesktopEnvironmentScanner(
        reader: reader,
        sink: sink,
        inputs: () => ScanInputs(mixedPort: 7890, coreConnected: connected),
        domains: () => const RelevantDomains(),
        tcp: (_, _) async => true,
        dns: (_, _) async => true,
      );
      scanner.rescan();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(
        (sink.values['network.ports'] as List<PortFact>).single.ours,
        isTrue,
      );
      connected = false;
      scanner.rescan();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(
        (sink.values['network.ports'] as List<PortFact>).single.ours,
        isFalse,
      );
      scanner.dispose();
    });
  });

  group('owner by Core pid', () {
    bool? oursFor(PortOwner owner, ScanInputs inputs) {
      late bool? result;
      fakeAsync((async) {
        final reader = _Reader()..owners = {7890: owner};
        final sink = _Sink();
        final scanner = _scanner(reader, sink, inputs: inputs)..rescan();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        result = (sink.values['network.ports'] as List<PortFact>).single.ours;
        scanner.dispose();
      });
      return result;
    }

    test('a matching pid is ours whatever the name', () {
      expect(
        oursFor(
          const PortOwner(pid: 42, name: 'renamed'),
          const ScanInputs(mixedPort: 7890, corePid: 42),
        ),
        isTrue,
      );
    });

    test('a different pid is foreign even when named ReClashCore', () {
      expect(
        oursFor(
          const PortOwner(pid: 43, name: 'ReClashCore'),
          const ScanInputs(mixedPort: 7890, corePid: 42),
        ),
        isFalse,
      );
    });

    test('without a Core pid the name decides', () {
      const inputs = ScanInputs(mixedPort: 7890);
      expect(
        oursFor(const PortOwner(pid: 43, name: 'ReClashCore'), inputs),
        isTrue,
      );
      expect(oursFor(const PortOwner(pid: 43, name: 'nginx'), inputs), isFalse);
    });
  });

  test('new relevant domains re-filter without reading the file again', () {
    fakeAsync((async) {
      final reader = _Reader();
      final sink = _Sink();
      var domains = const RelevantDomains();
      final scanner = DesktopEnvironmentScanner(
        reader: reader,
        sink: sink,
        inputs: () => const ScanInputs(),
        domains: () => domains,
        tcp: (_, _) async => true,
        dns: (_, _) async => true,
      );
      scanner.rescan();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect((sink.values['system.hosts'] as HostsFact).entries, hasLength(1));
      domains = const RelevantDomains(services: {});
      scanner.refilterHosts();
      async.flushMicrotasks();
      expect((sink.values['system.hosts'] as HostsFact).entries, isEmpty);
      expect(reader.hostsReads, 1);
      scanner.dispose();
    });
  });
}
