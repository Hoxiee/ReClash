import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/environment/healer.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/models/models.dart';

final _now = DateTime(2026, 11, 3, 12);

class _Config implements ConfigAccess {
  Config config = const Config(
    themeProps: defaultThemeProps,
    patchClashConfig: defaultClashConfig,
  );

  @override
  Config read() => config;

  @override
  void write(Config next) => config = next;
}

class _Fake implements Remedy {
  _Fake(
    this.id,
    this.reach, {
    this.kind = FixKind.auto,
    this.undoable = false,
    required this.onApply,
  });

  @override
  final String id;

  @override
  final RemedyReach reach;

  @override
  final FixKind kind;

  @override
  final bool undoable;

  final void Function() onApply;
  int applied = 0;

  @override
  Duration get settle => Duration.zero;

  @override
  Future<void> apply(RemedyRequest request) async {
    applied++;
    onApply();
  }
}

const _taken = [
  PortFact(port: 7890, role: PortRole.mixed, listening: true, owner: 'nginx'),
];

class _LateSink implements FactSink {
  const _LateSink(this._sink);

  final FactSink Function() _sink;

  @override
  void put<T extends Object>(FactKey<T> key, T? value, {Duration? ttl}) =>
      _sink().put(key, value, ttl: ttl);
}

class _Rig {
  _Rig(
    List<Remedy> Function(FactSink) remedies, {
    this.autoHeal = true,
    int maxHeals = 3,
    _Config? config,
  }) : config = config ?? _Config() {
    final built = remedies(_LateSink(() => kernel));
    kernel = DoctorKernel(
      engine: const RuleEngine(defaultRules),
      scheduler: ProbeScheduler(clock: () => _now),
      journal: DiagnosticJournal(MemoryIncidentStore()),
      config: this.config,
      remedies: built,
      clock: () => _now,
    );
    healer = EnvironmentHealer(
      kernel: kernel,
      remedies: built,
      enabled: () => autoHeal,
      settleDelay: const Duration(milliseconds: 5),
      maxHeals: maxHeals,
      clock: () => _now,
    )..start();
    notices = [];
    subscription = healer.notices.listen(notices.add);
  }

  final _Config config;
  late final DoctorKernel kernel;
  late final EnvironmentHealer healer;
  late final List<HealNotice> notices;
  late final StreamSubscription<HealNotice> subscription;
  bool autoHeal;

  Future<void> pump() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await kernel.settle();
  }

  Future<void> dispose() async {
    await subscription.cancel();
    await healer.dispose();
    await kernel.dispose();
  }

  void blockPort() => kernel.put(Facts.ports, _taken);

  void freePort() => kernel.put(Facts.ports, const <PortFact>[]);
}

_Rig _rig(
  List<Remedy> Function(FactSink) remedies, {
  bool autoHeal = true,
  int maxHeals = 3,
  _Config? config,
}) {
  final rig = _Rig(
    remedies,
    autoHeal: autoHeal,
    maxHeals: maxHeals,
    config: config,
  );
  addTearDown(rig.dispose);
  return rig;
}

_Fake _portFix(FactSink kernel, {bool clears = true}) => _Fake(
  'config.freePort',
  RemedyReach.app,
  undoable: true,
  onApply: () {
    if (clears) kernel.put(Facts.ports, const <PortFact>[]);
  },
);

void main() {
  test('applies an app remedy once when the finding is raised', () async {
    late _Fake fix;
    final rig = _rig((k) => [fix = _portFix(k)]);

    rig.blockPort();
    await rig.pump();

    expect(fix.applied, 1);
    expect(rig.kernel.findings, isEmpty);
    expect(rig.notices, hasLength(1));
    expect(rig.notices.single.findingId, 'env.portTaken');
    expect(rig.notices.single.remedyId, 'config.freePort');
    expect(rig.notices.single.titleKey, 'doctorPortTakenTitle');
    expect(rig.notices.single.args, {'port': 7890, 'owner': 'nginx'});
  });

  test('does not repeat a remedy that did not clear the finding', () async {
    late _Fake fix;
    final rig = _rig((k) => [fix = _portFix(k, clears: false)]);

    rig.blockPort();
    await rig.pump();
    rig.kernel.put(Facts.mixedPort, 7891);
    await rig.pump();
    await rig.pump();

    expect(fix.applied, 1);
  });

  test('acts again when the finding is raised anew after clearing', () async {
    late _Fake fix;
    final rig = _rig((k) => [fix = _portFix(k)]);

    rig.blockPort();
    await rig.pump();
    rig.blockPort();
    await rig.pump();

    expect(fix.applied, 2);
  });

  test('applies an own remedy', () async {
    final own = _Fake('proxy.clearOwn', RemedyReach.own, onApply: () {});
    final rig = _rig((_) => [own]);
    rig.kernel
      ..put(
        Facts.systemProxy,
        const SystemProxyFact(
          enabled: true,
          host: '127.0.0.1',
          port: 7890,
          reachable: false,
        ),
      )
      ..put(Facts.coreStatus, CoreStatus.disconnected)
      ..put(Facts.ownProxyPort, 7890);
    await rig.pump();

    expect(own.applied, 1);
  });

  test('never runs a foreign remedy', () async {
    final foreign = _Fake('proxy.clear', RemedyReach.foreign, onApply: () {});
    final rig = _rig((_) => [foreign]);
    rig.kernel
      ..put(
        Facts.systemProxy,
        const SystemProxyFact(
          enabled: true,
          host: '127.0.0.1',
          port: 7890,
          reachable: false,
        ),
      )
      ..put(Facts.coreStatus, CoreStatus.disconnected);
    await rig.pump();

    expect(rig.kernel.findings.single.remedyIds, ['proxy.clear']);
    expect(foreign.applied, 0);
    expect(rig.notices, isEmpty);
  });

  test('skips a remedy that is not automatic', () async {
    final manual = _Fake(
      'config.freePort',
      RemedyReach.app,
      kind: FixKind.system,
      onApply: () {},
    );
    final rig = _rig((_) => [manual]);

    rig.blockPort();
    await rig.pump();

    expect(manual.applied, 0);
  });

  test('does nothing while auto-heal is off', () async {
    late _Fake fix;
    final rig = _rig((k) => [fix = _portFix(k)], autoHeal: false);

    rig.blockPort();
    await rig.pump();

    expect(fix.applied, 0);
    expect(rig.kernel.findings, hasLength(1));
  });

  test('ignores a transient finding that clears within the delay', () async {
    late _Fake fix;
    final rig = _rig((k) => [fix = _portFix(k)]);

    rig.blockPort();
    rig.freePort();
    await rig.pump();

    expect(fix.applied, 0);
  });

  test('caps automatic repairs within the window', () async {
    late _Fake fix;
    final rig = _rig((k) => [fix = _portFix(k)], maxHeals: 3);

    for (var i = 0; i < 5; i++) {
      rig.blockPort();
      await rig.pump();
    }

    expect(fix.applied, 3);
  });

  test('undo goes through the kernel and restores the config', () async {
    final config = _Config();
    final before = config.config;
    final rig = _rig(
      (k) => [
        _Fake(
          'config.freePort',
          RemedyReach.app,
          undoable: true,
          onApply: () {
            config.config = before.copyWith(
              patchClashConfig: before.patchClashConfig.copyWith(
                mixedPort: 7999,
              ),
            );
            k.put(Facts.ports, const <PortFact>[]);
          },
        ),
      ],
      config: config,
    );

    rig.blockPort();
    await rig.pump();

    expect(config.config.patchClashConfig.mixedPort, 7999);
    expect(rig.notices.single.undoable, isTrue);

    final outcome = await rig.healer.undo(rig.notices.single);

    expect(outcome.status, RemedyStatus.undone);
    expect(config.config, before);
  });

  test('takes back a change that did not clear its finding', () async {
    final config = _Config();
    final before = config.config;
    final rig = _rig(
      (k) => [
        _Fake(
          'config.freePort',
          RemedyReach.app,
          undoable: true,
          onApply: () => config.config = before.copyWith(
            patchClashConfig: before.patchClashConfig.copyWith(mixedPort: 7999),
          ),
        ),
      ],
      config: config,
    );

    rig.blockPort();
    await rig.pump();

    expect(rig.notices, isEmpty);
    expect(config.config, before);
  });
}
