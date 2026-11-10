import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/remedies/connection.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/supervisor/health.dart';
import 'package:reclash/features/doctor/supervisor/supervisor.dart';
import 'package:reclash/models/models.dart';

final _start = DateTime(2026, 11, 9, 12);

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

const _ladderIds = [
  ConnectionRemedy.bestNode,
  'profile.update',
  ConnectionRemedy.resetConnections,
  ConnectionRemedy.restartCore,
  ConnectionRemedy.reconnect,
];

class _Rig {
  _Rig(this.async, {this.autoHeal = true}) {
    DateTime clock() => _start.add(async.elapsed);
    kernel = DoctorKernel(
      engine: const RuleEngine(defaultRules),
      scheduler: ProbeScheduler(clock: clock),
      journal: DiagnosticJournal(MemoryIncidentStore()),
      config: _Config(),
      remedies: [
        for (final id in _ladderIds)
          ConnectionRemedy(id, () async {
            applied.add(id);
            if (remedyTime > Duration.zero) {
              await Future<void>.delayed(remedyTime);
            }
            onRemedy[id]?.call();
          }),
      ],
      verifyChecks: (step) => PathCheck(
        cost: CheckCost.local,
        run: (_) async {
          if (step != PathStep.internet) return const StepCheck.pass();
          checks++;
          final gate = this.gate;
          if (gate != null) await gate.future;
          return answer;
        },
      ),
      clock: clock,
    );
    supervisor = ConnectionSupervisor(
      kernel: kernel,
      autoHeal: () => autoHeal,
      selectedNode: () => 'Tokyo 2',
      clock: clock,
    )..start();
    supervisor.updates.listen(phases.add);
  }

  final FakeAsync async;
  late final DoctorKernel kernel;
  late final ConnectionSupervisor supervisor;
  bool autoHeal;
  StepCheck answer = const StepCheck.pass();
  Completer<void>? gate;
  Duration remedyTime = Duration.zero;
  int checks = 0;
  final applied = <String>[];
  final onRemedy = <String, void Function()>{};
  final phases = <ConnectionHealth>[];

  ConnectionHealth get health => supervisor.health;

  void fail([FailureCause cause = FailureCause.timeout]) =>
      answer = StepCheck.fail(cause);

  void pass() => answer = const StepCheck.pass();

  void run(Duration duration) {
    async.elapse(duration);
    async.flushMicrotasks();
  }

  void settle() => run(const Duration(milliseconds: 50));

  void connect() {
    supervisor.setRunning(true);
    settle();
  }

  void dispose() {
    unawaited(supervisor.dispose());
    unawaited(kernel.dispose());
    async.flushMicrotasks();
  }
}

void _test(String name, void Function(_Rig rig) body, {bool autoHeal = true}) {
  test(name, () {
    fakeAsync((async) {
      final rig = _Rig(async, autoHeal: autoHeal);
      body(rig);
      rig.dispose();
    });
  });
}

void main() {
  group('connect phase', () {
    _test('connecting is set synchronously and a pass verifies', (rig) {
      rig.supervisor.setRunning(true);
      expect(rig.health.phase, ConnectionPhase.connecting);
      rig.settle();
      expect(rig.health.phase, ConnectionPhase.verified);
      expect(rig.applied, isEmpty);
    });

    _test('a failed connect is confirmed and never moves the node', (rig) {
      rig
        ..fail(FailureCause.authRejected)
        ..connect();
      expect(rig.health.phase, ConnectionPhase.connecting);
      rig.run(const Duration(seconds: 3));
      expect(rig.checks, greaterThanOrEqualTo(2));
      expect(rig.applied, [
        'profile.update',
        ConnectionRemedy.resetConnections,
      ]);
      expect(rig.health.phase, ConnectionPhase.broken);
      expect(rig.health.cause, FailureCause.authRejected);
      expect(rig.health.repairFailed, isFalse);
    });

    _test('without auto-heal a failed connect only offers repair', (rig) {
      rig
        ..fail(FailureCause.authRejected)
        ..connect()
        ..run(const Duration(seconds: 3));
      expect(rig.checks, 2);
      expect(rig.applied, isEmpty);
      expect(rig.health.phase, ConnectionPhase.broken);
      expect(rig.health.cause, FailureCause.authRejected);
    }, autoHeal: false);

    _test('a connect that recovers on its own verifies', (rig) {
      rig
        ..fail()
        ..connect();
      rig
        ..pass()
        ..run(const Duration(seconds: 3));
      expect(rig.applied, isEmpty);
      expect(rig.health.phase, ConnectionPhase.verified);
    });

    _test('the budget ends a check that never answers', (rig) {
      rig
        ..gate = Completer<void>()
        ..connect()
        ..run(const Duration(seconds: 14));
      expect(rig.health.phase, ConnectionPhase.connecting);
      rig.run(const Duration(seconds: 1));
      expect(rig.health.phase, ConnectionPhase.broken);
      expect(rig.health.cause, FailureCause.timeout);
      rig.gate!.complete();
    }, autoHeal: false);

    _test('nothing is verified while the app is hidden', (rig) {
      rig.supervisor.setVisible(false);
      rig.connect();
      expect(rig.checks, 0);
      expect(rig.health.phase, ConnectionPhase.connecting);
      rig.supervisor.setVisible(true);
      rig.settle();
      expect(rig.checks, 1);
      expect(rig.health.phase, ConnectionPhase.verified);
    });

    _test('a dead node picked while verified is not protected', (rig) {
      rig.connect();
      expect(rig.health.phase, ConnectionPhase.verified);
      rig
        ..fail()
        ..supervisor.selectionChanged();
      expect(rig.health.phase, ConnectionPhase.connecting);
      rig.run(const Duration(seconds: 3));
      expect(rig.applied, [
        'profile.update',
        ConnectionRemedy.resetConnections,
      ]);
      expect(rig.health.phase, ConnectionPhase.broken);
    });

    _test('a live node picked while verified stays verified', (rig) {
      rig
        ..connect()
        ..supervisor.selectionChanged();
      rig.settle();
      expect(rig.health.phase, ConnectionPhase.verified);
      expect(rig.applied, isEmpty);
    });

    _test('stopping returns to idle', (rig) {
      rig
        ..connect()
        ..supervisor.setRunning(false);
      expect(rig.health, ConnectionHealth.idle);
    });
  });

  group('hysteresis', () {
    _test('one failed check is not broken yet', (rig) {
      rig
        ..connect()
        ..fail();
      unawaited(rig.supervisor.recheck());
      rig.settle();
      expect(rig.health.phase, ConnectionPhase.verified);
      rig
        ..pass()
        ..run(const Duration(seconds: 3));
      expect(rig.health.phase, ConnectionPhase.verified);
      expect(rig.checks, 3);
    });

    _test('two failed checks three seconds apart are broken', (rig) {
      rig
        ..connect()
        ..fail(FailureCause.reset);
      unawaited(rig.supervisor.recheck());
      rig.run(const Duration(seconds: 3));
      expect(rig.health.phase, ConnectionPhase.broken);
      expect(rig.health.cause, FailureCause.reset);
      expect(rig.applied, isEmpty);
    }, autoHeal: false);

    _test('a broken connection takes one pass to be verified', (rig) {
      rig
        ..connect()
        ..fail();
      unawaited(rig.supervisor.recheck());
      rig
        ..run(const Duration(seconds: 3))
        ..pass();
      unawaited(rig.supervisor.recheck());
      rig.settle();
      expect(rig.health.phase, ConnectionPhase.verified);
    }, autoHeal: false);

    _test('a check that cannot tell is never a problem', (rig) {
      rig
        ..connect()
        ..answer = const StepCheck.unknown();
      unawaited(rig.supervisor.recheck());
      rig.run(const Duration(seconds: 5));
      expect(rig.health.phase, ConnectionPhase.unknown);
    });
  });

  group('triggers', () {
    _test('a network change verifies after the settle', (rig) {
      rig
        ..connect()
        ..supervisor.setNetwork(online: true)
        ..run(const Duration(seconds: 4));
      expect(rig.checks, 1);
      rig.run(const Duration(seconds: 1));
      expect(rig.checks, 2);
    });

    _test('a failure within the settle of a network change is ignored', (rig) {
      rig
        ..connect()
        ..supervisor.setNetwork(online: true)
        ..fail();
      unawaited(rig.supervisor.recheck());
      rig.run(const Duration(seconds: 1));
      expect(rig.health.phase, ConnectionPhase.verified);
      rig
        ..pass()
        ..run(const Duration(seconds: 10));
      expect(rig.health.phase, ConnectionPhase.verified);
    });

    _test('offline waits for the network and verifies when it returns', (rig) {
      rig
        ..connect()
        ..supervisor.setNetwork(online: false);
      expect(rig.health.phase, ConnectionPhase.waitingNetwork);
      rig.supervisor.setNetwork(online: true);
      rig.run(const Duration(seconds: 5));
      expect(rig.health.phase, ConnectionPhase.verified);
      expect(rig.checks, 2);
    });

    _test('resume repeats only a check older than two minutes', (rig) {
      rig
        ..connect()
        ..supervisor.setVisible(false)
        ..run(const Duration(minutes: 1))
        ..supervisor.setVisible(true)
        ..settle();
      expect(rig.checks, 1);
      rig
        ..supervisor.setVisible(false)
        ..run(const Duration(minutes: 2))
        ..supervisor.setVisible(true)
        ..settle();
      expect(rig.checks, 2);
    });
  });

  group('healing', () {
    _test('recovering shows only once a plan runs past 800 ms', (rig) {
      rig
        ..remedyTime = const Duration(seconds: 1)
        ..fail()
        ..connect()
        ..run(const Duration(seconds: 3));
      expect(rig.health.phase, ConnectionPhase.broken);
      rig.run(const Duration(milliseconds: 900));
      expect(rig.health.phase, ConnectionPhase.recovering);
      expect(rig.health.step, HealStep.updateProfile);
      rig.onRemedy[ConnectionRemedy.resetConnections] = rig.pass;
      rig.run(const Duration(seconds: 3));
      expect(rig.health.phase, ConnectionPhase.verified);
    });

    _test('a quick step never shows recovering', (rig) {
      rig
        ..fail()
        ..onRemedy['profile.update'] = rig.pass
        ..connect()
        ..run(const Duration(seconds: 4));
      expect(rig.health.phase, ConnectionPhase.verified);
      expect(
        rig.phases.any((health) => health.phase == ConnectionPhase.recovering),
        isFalse,
      );
    });

    _test('repair climbs the whole ladder and reports its failure', (rig) {
      rig
        ..fail()
        ..connect()
        ..run(const Duration(seconds: 3));
      expect(rig.health.phase, ConnectionPhase.broken);
      rig.applied.clear();
      bool? healed;
      unawaited(rig.supervisor.repair().then((value) => healed = value));
      rig.run(const Duration(seconds: 1));
      expect(healed, isFalse);
      expect(rig.applied, _ladderIds.skip(1));
      expect(rig.health.phase, ConnectionPhase.broken);
      expect(rig.health.repairFailed, isTrue);
      rig.pass();
      unawaited(rig.supervisor.recheck());
      rig.settle();
      expect(rig.health.phase, ConnectionPhase.verified);
      expect(rig.health.repairFailed, isFalse);
    }, autoHeal: false);

    _test('only a tap switches the server', (rig) {
      rig
        ..fail()
        ..connect()
        ..run(const Duration(seconds: 3));
      expect(rig.applied, isEmpty);
      rig.onRemedy[ConnectionRemedy.bestNode] = rig.pass;
      bool? healed;
      unawaited(rig.supervisor.switchServer().then((value) => healed = value));
      rig.settle();
      expect(healed, isTrue);
      expect(rig.applied, [ConnectionRemedy.bestNode]);
      expect(rig.health.phase, ConnectionPhase.verified);
    }, autoHeal: false);

    _test('a failed server switch keeps repair on offer', (rig) {
      rig
        ..fail()
        ..connect()
        ..run(const Duration(seconds: 3));
      unawaited(rig.supervisor.switchServer());
      rig.settle();
      expect(rig.applied, [ConnectionRemedy.bestNode]);
      expect(rig.health.phase, ConnectionPhase.broken);
      expect(rig.health.repairFailed, isFalse);
    }, autoHeal: false);

    _test('a restart rung keeps the plan through its own reconnect', (rig) {
      rig
        ..fail()
        ..connect()
        ..onRemedy[ConnectionRemedy.restartCore] = () {
          rig.supervisor
            ..setRunning(false)
            ..setRunning(true);
          rig.pass();
        };
      bool? healed;
      unawaited(rig.supervisor.repair().then((value) => healed = value));
      rig.run(const Duration(seconds: 1));
      expect(healed, isTrue);
      expect(rig.applied.last, ConnectionRemedy.restartCore);
      expect(rig.health.phase, ConnectionPhase.verified);
    }, autoHeal: false);
  });

  test('a verify run leaves the full path in place for the path card', () {
    fakeAsync((async) {
      final rig = _Rig(async);
      unawaited(rig.kernel.runPath(scope: PathScope.verify));
      async.flushMicrotasks();
      expect(rig.kernel.path, isNull);
      rig.dispose();
    });
  });
}
