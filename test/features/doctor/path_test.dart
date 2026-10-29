import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/models/models.dart';

final _now = DateTime(2026, 10, 29, 12);

const _healPlan = HealPlan(
  id: 'setup',
  remedyIds: ['config.ruleMode'],
  findingIds: ['config.directMode'],
  verify: PathScope.setup,
);

Config _config() => const Config(
  themeProps: defaultThemeProps,
  patchClashConfig: defaultClashConfig,
);

class _FakeConfig implements ConfigAccess {
  _FakeConfig(this.config);

  Config config;

  @override
  Config read() => config;

  @override
  void write(Config next) => config = next;
}

class _FakeRemedy implements Remedy {
  _FakeRemedy(this.id, this._onApply);

  final Future<void> Function(RemedyRequest request) _onApply;

  @override
  final String id;

  @override
  FixKind get kind => FixKind.auto;

  @override
  bool get undoable => false;

  @override
  Duration get settle => Duration.zero;

  @override
  Future<void> apply(RemedyRequest request) => _onApply(request);
}

typedef _Answer = StepCheck Function(Object? intent);

StepCheck _pass(Object? intent) => const StepCheck.pass();

class _FakeCheck {
  _FakeCheck({this.answer = _pass, this.gate, this.ttl = Duration.zero});

  _Answer answer;
  final Completer<void>? gate;
  final Duration ttl;
  final started = Completer<void>();
  int calls = 0;

  PathCheck build(Object? intent) => PathCheck(
    cost: CheckCost.local,
    ttl: ttl,
    intent: intent,
    run: (_) async {
      calls++;
      if (!started.isCompleted) started.complete();
      await gate?.future;
      return answer(intent);
    },
  );
}

Map<PathStep, _FakeCheck> _passingChecks() => {
  for (final step in PathStep.values)
    step: _FakeCheck(answer: (_) => StepCheck.pass(detail: step.name)),
};

DoctorKernel _kernel(
  Map<PathStep, _FakeCheck> checks, {
  Object? Function()? intent,
  Iterable<Remedy> remedies = const [],
}) {
  final kernel = DoctorKernel(
    engine: const RuleEngine(defaultRules),
    scheduler: ProbeScheduler(clock: () => _now),
    journal: DiagnosticJournal(MemoryIncidentStore()),
    config: _FakeConfig(_config()),
    remedies: remedies,
    pathChecks: (step) => checks[step]?.build(intent?.call()),
    pathIntent: intent,
    clock: () => _now,
  );
  addTearDown(kernel.dispose);
  return kernel;
}

DoctorKernel _modeRemedyKernel(Map<PathStep, _FakeCheck> checks) {
  late final DoctorKernel kernel;
  kernel = _kernel(
    checks,
    remedies: [
      _FakeRemedy(
        'config.ruleMode',
        (_) async => kernel.put(Facts.mode, Mode.rule),
      ),
    ],
  );
  return kernel;
}

List<DiagnosticEvent> _collect(DoctorKernel kernel) {
  final events = <DiagnosticEvent>[];
  final subscription = kernel.events.listen(events.add);
  addTearDown(subscription.cancel);
  return events;
}

List<PathResult> _collectPaths(DoctorKernel kernel) {
  final updates = <PathResult>[];
  final subscription = kernel.pathUpdates.listen(updates.add);
  addTearDown(subscription.cancel);
  return updates;
}

List<PathStep> _startOrder(List<PathResult> updates) => [
  for (final update in updates)
    if (update.running case final running?) running.step,
];

void main() {
  group('DoctorKernel path', () {
    test('runs every full-scope step in order and passes', () async {
      final checks = _passingChecks();
      final kernel = _kernel(checks);
      final updates = _collectPaths(kernel);

      final result = await kernel.runPath();

      expect(result.steps.map((step) => step.step), PathStep.values);
      expect(
        result.steps.map((step) => step.status),
        everyElement(PathStepStatus.pass),
      );
      expect(result.steps.map((step) => step.detail), [
        for (final step in PathStep.values) step.name,
      ]);
      expect(
        result.steps.map((step) => step.duration),
        everyElement(isNotNull),
      );
      expect(result.complete, isTrue);
      expect(result.passed, isTrue);
      expect(_startOrder(updates), PathStep.values);
      expect(checks.values.map((check) => check.calls), everyElement(1));
    });

    test('the setup scope stops before the service checks', () async {
      final checks = _passingChecks();
      final kernel = _kernel(checks);

      final result = await kernel.runPath(scope: PathScope.setup);

      expect(PathScope.setup.steps, isNot(contains(PathStep.services)));
      expect(result.steps.map((step) => step.step), PathScope.setup.steps);
      expect(result.passed, isTrue);
      expect(checks[PathStep.services]!.calls, 0);
    });

    test('stops at the first failed step and never runs the rest', () async {
      final checks = _passingChecks();
      checks[PathStep.server] = _FakeCheck(
        answer: (_) => const StepCheck.fail(FailureCause.refused, detail: 'n'),
      );
      final kernel = _kernel(checks);

      final result = await kernel.runPath();

      expect(result.complete, isTrue);
      expect(result.passed, isFalse);
      expect(result.failed?.step, PathStep.server);
      expect(result.failed?.cause, FailureCause.refused);
      expect(result.failed?.detail, 'n');
      expect(result.stepOf(PathStep.internet)?.status, PathStepStatus.skipped);
      expect(result.stepOf(PathStep.services)?.status, PathStepStatus.skipped);
      expect(checks[PathStep.internet]!.calls, 0);
      expect(checks[PathStep.services]!.calls, 0);
    });

    test('an unknown step does not stop the chain', () async {
      final checks = _passingChecks();
      checks[PathStep.clock] = _FakeCheck(
        answer: (_) => const StepCheck.unknown(),
      );
      final kernel = _kernel(checks);

      final result = await kernel.runPath();

      expect(result.stepOf(PathStep.clock)?.status, PathStepStatus.unknown);
      expect(result.failed, isNull);
      expect(result.stepOf(PathStep.services)?.status, PathStepStatus.pass);
      expect(result.passed, isTrue);
    });

    test('a step without a check is skipped and the chain continues', () async {
      final checks = _passingChecks()..remove(PathStep.dns);
      final kernel = _kernel(checks);

      final result = await kernel.runPath();

      expect(result.stepOf(PathStep.dns)?.status, PathStepStatus.skipped);
      expect(result.stepOf(PathStep.server)?.status, PathStepStatus.pass);
      expect(result.passed, isTrue);
    });

    test(
      'a ProbeFailure becomes a failed step with its cause and message',
      () async {
        final checks = _passingChecks();
        checks[PathStep.tunnel] = _FakeCheck(
          answer: (_) => throw const ProbeFailure(FailureCause.timeout, 'x'),
        );
        final kernel = _kernel(checks);

        final result = await kernel.runPath();

        expect(result.failed?.step, PathStep.tunnel);
        expect(result.failed?.cause, FailureCause.timeout);
        expect(result.failed?.detail, 'x');
      },
    );

    test(
      'an unclassified error becomes a failed step with unknown cause',
      () async {
        final checks = _passingChecks();
        checks[PathStep.dns] = _FakeCheck(
          answer: (_) => throw StateError('boom'),
        );
        final kernel = _kernel(checks);

        final result = await kernel.runPath();

        expect(result.failed?.step, PathStep.dns);
        expect(result.failed?.cause, FailureCause.unknown);
        expect(result.passed, isFalse);
      },
    );

    test('publishes a running step before its settled status', () async {
      final kernel = _kernel(_passingChecks());
      final updates = _collectPaths(kernel);

      final result = await kernel.runPath();

      final clock = [
        for (final update in updates) update.stepOf(PathStep.clock)?.status,
      ];
      expect(
        clock,
        containsAllInOrder([PathStepStatus.running, PathStepStatus.pass]),
      );
      expect(kernel.path?.steps, result.steps);
    });

    test('concurrent callers of one intent share a single walk', () async {
      final checks = _passingChecks();
      final kernel = _kernel(checks);

      final first = kernel.runPath();
      final second = kernel.runPath();
      final results = await Future.wait([first, second]);

      expect(results.last, same(results.first));
      expect(checks.values.map((check) => check.calls), everyElement(1));
    });

    test('a passing step with a TTL is not re-run until forced', () async {
      final checks = _passingChecks();
      checks[PathStep.dns] = _FakeCheck(ttl: const Duration(minutes: 1));
      final kernel = _kernel(checks);

      await kernel.runPath();
      await kernel.runPath();
      expect(checks[PathStep.dns]!.calls, 1);

      await kernel.runPath(force: true);
      expect(checks[PathStep.dns]!.calls, 2);
    });

    test('a failed step is re-run on the next path within its TTL', () async {
      final checks = _passingChecks();
      final dns = _FakeCheck(
        ttl: const Duration(minutes: 1),
        answer: (_) => const StepCheck.fail(FailureCause.dnsFailed),
      );
      checks[PathStep.dns] = dns;
      final kernel = _kernel(checks);

      final failed = await kernel.runPath();
      dns.answer = _pass;
      final recovered = await kernel.runPath();

      expect(failed.failed?.step, PathStep.dns);
      expect(dns.calls, 2);
      expect(recovered.passed, isTrue);
    });

    test('the first caller receives the walk of the newer intent', () async {
      var route = 'A';
      final gate = Completer<void>();
      final checks = _passingChecks();
      checks[PathStep.clock] = _FakeCheck(
        gate: gate,
        answer: (intent) => StepCheck.pass(detail: 'route $intent'),
      );
      final kernel = _kernel(checks, intent: () => route);
      final updates = _collectPaths(kernel);

      final superseded = kernel.runPath();
      await checks[PathStep.clock]!.started.future;
      final seen = updates.length;

      route = 'B';
      final current = kernel.runPath();
      gate.complete();
      final results = await Future.wait([superseded, current]);

      expect(results.first, same(results.last));
      expect(results.first.stepOf(PathStep.clock)?.detail, 'route B');
      expect(
        updates
            .skip(seen)
            .map((update) => update.stepOf(PathStep.clock)?.detail),
        isNot(contains('route A')),
      );
    });

    test(
      'leaving the Core cancels the walk and publishes nothing after',
      () async {
        final gate = Completer<void>();
        final checks = _passingChecks();
        checks[PathStep.clock] = _FakeCheck(gate: gate);
        final kernel = _kernel(checks);
        kernel.put(Facts.coreStatus, CoreStatus.connected);
        final updates = _collectPaths(kernel);

        final walk = kernel.runPath();
        await checks[PathStep.clock]!.started.future;
        kernel.put(Facts.coreStatus, CoreStatus.disconnected);
        final result = await walk;

        expect(result.cancelled, isTrue);
        expect(result.complete, isTrue);
        expect(result.passed, isFalse);
        expect(result.stepOf(PathStep.network)?.status, PathStepStatus.pass);
        expect(result.stepOf(PathStep.clock)?.status, PathStepStatus.skipped);
        expect(
          result.steps.skip(2).map((step) => step.status),
          everyElement(PathStepStatus.skipped),
        );

        final seen = updates.length;
        gate.complete();
        await pumpEventQueue();

        expect(updates, hasLength(seen));
        expect(kernel.path?.cancelled, isTrue);
      },
    );

    test('journals a path failure once and its recovery', () async {
      final checks = _passingChecks();
      checks[PathStep.server] = _FakeCheck(
        answer: (_) => const StepCheck.fail(FailureCause.timeout, detail: 'n'),
      );
      final kernel = _kernel(checks);
      final events = _collect(kernel);

      await kernel.runPath();
      await kernel.runPath();

      expect(events, [
        DiagnosticEvent(
          kind: DiagnosticEventKind.pathFailed,
          at: _now,
          subject: 'server',
          cause: FailureCause.timeout,
          detail: 'n',
        ),
      ]);

      checks[PathStep.server] = _FakeCheck();
      await kernel.runPath();

      expect(events, hasLength(2));
      expect(events.last.kind, DiagnosticEventKind.pathRecovered);
      expect(events.last.subject, 'server');
    });

    test('does not journal a step that is not up', () async {
      final checks = _passingChecks();
      checks[PathStep.tunnel] = _FakeCheck(
        answer: (_) => const StepCheck.fail(null),
      );
      final kernel = _kernel(checks);
      final events = _collect(kernel);

      final result = await kernel.runPath();

      expect(result.failed?.step, PathStep.tunnel);
      expect(events, isEmpty);
    });

    test('heal counts the plan healed once the setup path passes', () async {
      final kernel = _modeRemedyKernel(_passingChecks());
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      final outcome = await kernel.heal(_healPlan);

      expect(outcome.healed, isTrue);
      expect(outcome.path?.passed, isTrue);
    });

    test('heal reports a failed verification path as not healed', () async {
      final checks = _passingChecks();
      checks[PathStep.server] = _FakeCheck(
        answer: (_) => const StepCheck.fail(FailureCause.refused),
      );
      final kernel = _modeRemedyKernel(checks);
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      final outcome = await kernel.heal(_healPlan);

      expect(outcome.healed, isFalse);
      expect(outcome.path?.failed?.step, PathStep.server);
    });
  });

  group('PathCheck', () {
    test(
      'keys the request by step and reports how long the run took',
      () async {
        final check = PathCheck(
          cost: CheckCost.local,
          run: (_) async => const StepCheck.pass(detail: 'node'),
        );

        final request = check.request(PathStep.dns);
        final value = await request.run(ProbeToken());

        expect(pathStepKey(PathStep.dns), 'path.dns');
        expect(request.key, pathStepKey(PathStep.dns));
        expect(value.status, PathStepStatus.pass);
        expect(value.detail, 'node');
        expect(value.elapsed, isNotNull);
      },
    );

    test('turns a ProbeFailure into a failed step', () async {
      final check = PathCheck(
        cost: CheckCost.network,
        run: (_) async =>
            throw const ProbeFailure(FailureCause.timeout, 'slow'),
      );

      final value = await check.request(PathStep.internet).run(ProbeToken());

      expect(value.status, PathStepStatus.fail);
      expect(value.cause, FailureCause.timeout);
      expect(value.detail, 'slow');
      expect(value.elapsed, isNotNull);
    });

    test('rethrows a cancelled run', () async {
      final check = PathCheck(
        cost: CheckCost.local,
        run: (_) async => throw const ProbeCancelled('path.dns'),
      );

      await expectLater(
        check.request(PathStep.dns).run(ProbeToken()),
        throwsA(isA<ProbeCancelled>()),
      );
    });
  });

  group('PathResult', () {
    final start = PathResult.start(PathScope.setup, _now);

    test('finish settles the steps that never ran as skipped', () {
      final partial = start
          .withStep(
            const PathStepResult(PathStep.network, status: PathStepStatus.pass),
          )
          .withStep(
            const PathStepResult(
              PathStep.clock,
              status: PathStepStatus.running,
            ),
          );

      final finished = partial.finish(_now);

      expect(finished.complete, isTrue);
      expect(finished.stepOf(PathStep.network)?.status, PathStepStatus.pass);
      expect(
        finished.steps.skip(1).map((step) => step.status),
        everyElement(PathStepStatus.skipped),
      );
    });

    test('duration sums the steps that were measured', () {
      final measured = start
          .withStep(
            const PathStepResult(
              PathStep.network,
              status: PathStepStatus.pass,
              duration: Duration(milliseconds: 40),
            ),
          )
          .withStep(
            const PathStepResult(
              PathStep.clock,
              status: PathStepStatus.pass,
              duration: Duration(milliseconds: 60),
            ),
          );

      expect(measured.duration, const Duration(milliseconds: 100));
    });

    test('withStep replaces only the named step', () {
      final result = start.withStep(
        const PathStepResult(
          PathStep.clock,
          status: PathStepStatus.fail,
          cause: FailureCause.clockSkew,
        ),
      );

      expect(result.steps.map((step) => step.step), PathScope.setup.steps);
      expect(result.stepOf(PathStep.clock)?.cause, FailureCause.clockSkew);
      expect(
        result.steps
            .where((step) => step.step != PathStep.clock)
            .map((step) => step.status),
        everyElement(PathStepStatus.waiting),
      );
    });
  });
}
