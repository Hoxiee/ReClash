import 'package:flutter_test/flutter_test.dart';
import 'package:proxy/proxy.dart';
import 'package:reclash/common/proxy.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/remedies/environment.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/models/models.dart' hide Proxy;

final _now = DateTime(2026, 11, 3, 12);

class _Patch {
  PatchClashConfig value = defaultClashConfig;

  PatchConfigAccess get access => PatchConfigAccess(
    read: () => value,
    write: (change) => value = change(value),
  );
}

RemedyRequest _request([Map<FactKey<Object>, Object> facts = const {}]) {
  var snapshot = DiagnosticSnapshot(takenAt: _now);
  for (final MapEntry(:key, :value) in facts.entries) {
    snapshot = switch (value) {
      final TunnelsFact tunnels => snapshot.withFact(
        Facts.tunnels,
        Fact(tunnels, at: _now),
      ),
      final SystemProxyFact proxy => snapshot.withFact(
        Facts.systemProxy,
        Fact(proxy, at: _now),
      ),
      final int port => snapshot.withFact(
        Facts.ownProxyPort,
        Fact(port, at: _now),
      ),
      _ => throw ArgumentError('unsupported fact $key'),
    };
  }
  return RemedyRequest(snapshot: snapshot);
}

class _FakeProxy implements Proxy {
  final calls = <String>[];

  @override
  Future<bool> startProxy(
    int port, [
    List<String> bypassDomain = const [],
  ]) async {
    calls.add('start $port');
    return true;
  }

  @override
  Future<bool> stopProxy() async {
    calls.add('stop');
    return true;
  }
}

class _MemoryRecord implements OwnProxyRecord {
  int? port;

  @override
  Future<int?> read() async => port;

  @override
  Future<void> write(int? value) async => port = value;
}

void main() {
  group('reach and kind', () {
    final patch = _Patch();
    final remedies = <Remedy, (RemedyReach, FixKind, bool)>{
      IgnoreSystemHostsRemedy(patch.access): (
        RemedyReach.app,
        FixKind.auto,
        true,
      ),
      OpenHostsRemedy(() async => true): (
        RemedyReach.app,
        FixKind.system,
        false,
      ),
      ClearOwnProxyRemedy((_) async => true): (
        RemedyReach.own,
        FixKind.auto,
        false,
      ),
      ClearProxyRemedy(() async => true): (
        RemedyReach.foreign,
        FixKind.auto,
        false,
      ),
      ReapplyProxyRemedy(() async => true): (
        RemedyReach.foreign,
        FixKind.auto,
        false,
      ),
      FreePortRemedy(patch.access): (RemedyReach.app, FixKind.auto, true),
      FreeTunDeviceRemedy(patch.access): (RemedyReach.app, FixKind.auto, true),
      RestartTunnelRemedy(() async => true): (
        RemedyReach.app,
        FixKind.auto,
        false,
      ),
    };

    test('match the safety model', () {
      expect(remedies.keys.map((r) => r.id), [
        'dns.ignoreSystemHosts',
        'system.openHosts',
        'proxy.clearOwn',
        'proxy.clear',
        'proxy.reapply',
        'config.freePort',
        'tunnel.freeDeviceName',
        'tunnel.restart',
      ]);
      for (final MapEntry(key: remedy, value: (reach, kind, undoable))
          in remedies.entries) {
        expect(remedy.reach, reach, reason: remedy.id);
        expect(remedy.kind, kind, reason: remedy.id);
        expect(remedy.undoable, undoable, reason: remedy.id);
      }
    });
  });

  group('config remedies', () {
    test('ignoring system hosts picks the override and turns it off', () async {
      final patch = _Patch();

      await IgnoreSystemHostsRemedy(patch.access).apply(_request());

      expect(patch.value.dns.useSystemHosts, isFalse);
      expect(
        patch.value.dnsOverrideKeys,
        contains(DnsOverrideKey.useSystemHosts),
      );
    });

    test('a free port skips every port already configured', () async {
      final patch = _Patch()
        ..value = defaultClashConfig.copyWith(mixedPort: 7890, socksPort: 7891);
      Set<int>? avoided;

      await FreePortRemedy(
        patch.access,
        find: (avoid) async {
          avoided = avoid;
          return 7892;
        },
      ).apply(_request());

      expect(patch.value.mixedPort, 7892);
      expect(avoided, containsAll([7890, 7891]));
    });

    test('findFreePort returns a bindable port', () async {
      expect(await findFreePort(avoid: {7890}), isNot(7890));
    });

    test('the device name takes the next suffix nobody uses', () async {
      final patch = _Patch()
        ..value = defaultClashConfig.copyWith.tun(device: 'ReClash');
      const tunnels = TunnelsFact(
        foreign: [
          TunnelAdapter(name: 'ReClash', kind: TunnelKind.wintun),
          TunnelAdapter(name: 'reclash-2', kind: TunnelKind.wintun),
        ],
      );

      await FreeTunDeviceRemedy(
        patch.access,
      ).apply(_request({Facts.tunnels: tunnels}));

      expect(patch.value.tun.device, 'ReClash-3');
    });
  });

  group('system proxy remedies', () {
    const proxy = SystemProxyFact(
      enabled: true,
      host: '127.0.0.1',
      port: 7890,
      reachable: false,
    );

    test('clearing our own proxy needs a matching record', () async {
      var cleared = 0;
      final remedy = ClearOwnProxyRemedy((port) async {
        cleared++;
        return true;
      });

      await expectLater(
        remedy.apply(_request({Facts.systemProxy: proxy})),
        throwsStateError,
      );
      await expectLater(
        remedy.apply(
          _request({Facts.systemProxy: proxy, Facts.ownProxyPort: 7891}),
        ),
        throwsStateError,
      );
      expect(cleared, 0);

      await remedy.apply(
        _request({Facts.systemProxy: proxy, Facts.ownProxyPort: 7890}),
      );
      expect(cleared, 1);
    });

    test('the queue records what it applies and clears it on stop', () async {
      final fake = _FakeProxy();
      final record = _MemoryRecord();
      final queue = SystemProxyQueue(fake, record: record);
      final ports = <int?>[];
      queue.ownPorts.listen(ports.add);

      await queue.apply(
        const ProxyState(
          isStart: true,
          systemProxy: true,
          bassDomain: [],
          port: 7890,
        ),
      );
      expect(record.port, 7890);

      expect(await queue.clear(ownPort: 7891), isFalse);
      expect(fake.calls, ['start 7890']);

      expect(await queue.clear(ownPort: 7890), isTrue);
      expect(fake.calls, ['start 7890', 'stop']);
      expect(record.port, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(ports, [7890, null]);
    });

    test('a recorded proxy from a crashed run can be cleared', () async {
      final fake = _FakeProxy();
      final record = _MemoryRecord()..port = 7890;
      final queue = SystemProxyQueue(fake, record: record);

      expect(await queue.ownPort(), 7890);
      expect(await queue.clear(ownPort: 7890), isTrue);
      expect(record.port, isNull);
    });
  });

  test('the kernel refuses a foreign remedy until it is confirmed', () async {
    var cleared = 0;
    final kernel = DoctorKernel(
      engine: const RuleEngine(defaultRules),
      scheduler: ProbeScheduler(clock: () => _now),
      journal: DiagnosticJournal(MemoryIncidentStore()),
      config: _NoConfig(),
      remedies: [
        ClearProxyRemedy(() async {
          cleared++;
          return true;
        }),
      ],
      clock: () => _now,
    );
    addTearDown(kernel.dispose);

    final refused = await kernel.apply('proxy.clear');
    expect(refused.status, RemedyStatus.needsConfirmation);
    expect(cleared, 0);

    final confirmed = await kernel.apply('proxy.clear', confirmed: true);
    expect(confirmed.status, RemedyStatus.applied);
    expect(cleared, 1);
  });

  test('the cause map offers app and own remedies only', () {
    final kernel = DoctorKernel(
      engine: const RuleEngine(defaultRules),
      scheduler: ProbeScheduler(clock: () => _now),
      journal: DiagnosticJournal(MemoryIncidentStore()),
      config: _NoConfig(),
      clock: () => _now,
    );
    addTearDown(kernel.dispose);

    const foreign = {'proxy.clear', 'proxy.reapply'};
    for (final cause in FailureCause.values) {
      expect(
        kernel.explain(cause).remedyIds.toSet().intersection(foreign),
        isEmpty,
        reason: cause.id,
      );
    }
  });
}

class _NoConfig implements ConfigAccess {
  @override
  Config read() => const Config(
    themeProps: defaultThemeProps,
    patchClashConfig: defaultClashConfig,
  );

  @override
  void write(Config config) {}
}
