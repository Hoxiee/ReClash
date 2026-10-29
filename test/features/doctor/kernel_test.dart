import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/models/models.dart';

final _now = DateTime(2026, 10, 29, 12);

Config _config({Mode mode = Mode.rule}) => Config(
  themeProps: defaultThemeProps,
  patchClashConfig: defaultClashConfig.copyWith(mode: mode),
);

class _FakeConfig implements ConfigAccess {
  _FakeConfig(this.config);

  Config config;
  int writes = 0;

  @override
  Config read() => config;

  @override
  void write(Config next) {
    writes++;
    config = next;
  }
}

class _FakeRemedy implements Remedy {
  _FakeRemedy(
    this.id,
    this._onApply, {
    this.undoable = false,
    this.settle = Duration.zero,
  });

  final Future<void> Function(RemedyRequest request) _onApply;

  @override
  final String id;

  @override
  final bool undoable;

  @override
  final Duration settle;

  @override
  FixKind get kind => FixKind.auto;

  @override
  Future<void> apply(RemedyRequest request) => _onApply(request);
}

DoctorKernel _kernel(
  ConfigAccess config, {
  Iterable<Remedy> remedies = const [],
}) {
  final kernel = DoctorKernel(
    engine: const RuleEngine(defaultRules),
    scheduler: ProbeScheduler(clock: () => _now),
    journal: DiagnosticJournal(MemoryIncidentStore()),
    config: config,
    remedies: remedies,
    clock: () => _now,
  );
  addTearDown(kernel.dispose);
  return kernel;
}

List<DiagnosticEvent> _collect(DoctorKernel kernel) {
  final events = <DiagnosticEvent>[];
  final subscription = kernel.events.listen(events.add);
  addTearDown(subscription.cancel);
  return events;
}

List<String> _ids(DoctorKernel kernel) => [
  for (final finding in kernel.findings) finding.id,
];

void main() {
  group('DoctorKernel findings', () {
    test(
      'raises and clears the direct-mode finding as the mode changes',
      () async {
        final kernel = _kernel(_FakeConfig(_config()));
        final events = _collect(kernel);

        kernel.put(Facts.mode, Mode.direct);
        await kernel.settle();

        expect(_ids(kernel), contains('config.directMode'));
        expect(events, [
          DiagnosticEvent(
            kind: DiagnosticEventKind.findingRaised,
            at: _now,
            subject: 'config.directMode',
            severity: CheckSeverity.warning,
          ),
        ]);

        kernel.put(Facts.mode, Mode.rule);
        await kernel.settle();

        expect(kernel.findings, isEmpty);
        expect(
          events.last,
          DiagnosticEvent(
            kind: DiagnosticEventKind.findingCleared,
            at: _now,
            subject: 'config.directMode',
            severity: CheckSeverity.warning,
          ),
        );
      },
    );

    test('publishes one snapshot for a repeated value', () async {
      final kernel = _kernel(_FakeConfig(_config()));
      final snapshots = <DiagnosticSnapshot>[];
      final subscription = kernel.snapshots.listen(snapshots.add);

      kernel.put(Facts.mode, Mode.direct);
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      expect(snapshots, hasLength(1));
      expect(snapshots.single.valueOf(Facts.mode), Mode.direct);

      await subscription.cancel();
    });

    test('hides a snoozed warning from the findings', () async {
      final kernel = _kernel(_FakeConfig(_config()));
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      expect(kernel.snooze('config.directMode'), isTrue);
      expect(kernel.findings, isEmpty);
    });

    test('keeps a warning whose snooze ended in the past', () async {
      final kernel = _kernel(_FakeConfig(_config()));
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      final snoozed = kernel.snooze(
        'config.directMode',
        until: _now.subtract(const Duration(minutes: 1)),
      );

      expect(snoozed, isTrue);
      expect(_ids(kernel), ['config.directMode']);
    });

    test('refuses to snooze a critical finding', () async {
      final kernel = _kernel(_FakeConfig(_config()));
      kernel.put(
        Facts.subscription,
        SubscriptionFact(
          profileId: 3,
          expiresAt: _now.subtract(const Duration(days: 1)),
        ),
      );
      await kernel.settle();

      expect(kernel.snooze('profile.subscription'), isFalse);
      expect(_ids(kernel), contains('profile.subscription'));
    });
  });

  group('DoctorKernel remedies', () {
    test('reports an unknown remedy as unavailable', () async {
      final kernel = _kernel(_FakeConfig(_config()));

      final outcome = await kernel.apply('config.missing');

      expect(outcome.status, RemedyStatus.unavailable);
    });

    test(
      'applies an undoable remedy and restores the config on undo',
      () async {
        final original = _config(mode: Mode.direct);
        final config = _FakeConfig(original);
        late final DoctorKernel kernel;
        kernel = _kernel(
          config,
          remedies: [
            _FakeRemedy('config.ruleMode', (_) async {
              kernel.put(Facts.mode, Mode.rule);
              config.write(
                config.read().copyWith.patchClashConfig(mode: Mode.rule),
              );
            }, undoable: true),
          ],
        );
        kernel.put(Facts.mode, Mode.direct);
        await kernel.settle();

        final applied = await kernel.apply('config.ruleMode');

        expect(applied.status, RemedyStatus.fixed);
        expect(applied.canUndo, isTrue);
        expect(applied.remaining, isEmpty);
        expect(config.read().patchClashConfig.mode, Mode.rule);
        await pumpEventQueue();
        expect(
          await kernel.history(),
          contains(
            DiagnosticEvent(
              kind: DiagnosticEventKind.remedyApplied,
              at: _now,
              subject: 'config.ruleMode',
              outcome: 'fixed',
            ),
          ),
        );

        final undone = await kernel.undo('config.ruleMode');

        expect(undone.status, RemedyStatus.undone);
        expect(config.read(), original);
      },
    );

    test('refuses to undo once the config changed after the remedy', () async {
      final config = _FakeConfig(_config(mode: Mode.direct));
      late final DoctorKernel kernel;
      kernel = _kernel(
        config,
        remedies: [
          _FakeRemedy('config.ruleMode', (_) async {
            kernel.put(Facts.mode, Mode.rule);
            config.write(
              config.read().copyWith.patchClashConfig(mode: Mode.rule),
            );
          }, undoable: true),
        ],
      );
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();
      await kernel.apply('config.ruleMode');

      config.config = config.read().copyWith.patchClashConfig(
        mode: Mode.global,
      );
      final writes = config.writes;

      final undone = await kernel.undo('config.ruleMode');

      expect(undone.status, RemedyStatus.stale);
      expect(config.writes, writes);
      expect(config.read().patchClashConfig.mode, Mode.global);
    });

    test('reports a remedy that throws as failed with its error', () async {
      final kernel = _kernel(
        _FakeConfig(_config(mode: Mode.direct)),
        remedies: [
          _FakeRemedy(
            'config.ruleMode',
            (_) async => throw StateError('denied'),
          ),
        ],
      );
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      final outcome = await kernel.apply('config.ruleMode');

      expect(outcome.status, RemedyStatus.failed);
      expect(outcome.error, isA<StateError>());
      expect(outcome.remaining, ['config.directMode']);
    });

    test(
      'reports a fix that never reaches the snapshot as not fixed',
      () async {
        final kernel = _kernel(
          _FakeConfig(_config(mode: Mode.direct)),
          remedies: [
            _FakeRemedy(
              'config.ruleMode',
              (_) async {},
              settle: const Duration(milliseconds: 50),
            ),
          ],
        );
        kernel.put(Facts.mode, Mode.direct);
        await kernel.settle();

        final outcome = await kernel.apply('config.ruleMode');

        expect(outcome.status, RemedyStatus.notFixed);
        expect(outcome.remaining, ['config.directMode']);
      },
    );

    test('waits within the settle window for a fix that lands late', () async {
      late final DoctorKernel kernel;
      kernel = _kernel(
        _FakeConfig(_config(mode: Mode.direct)),
        remedies: [
          _FakeRemedy('config.ruleMode', (_) async {
            unawaited(
              Future<void>.delayed(
                const Duration(milliseconds: 10),
                () => kernel.put(Facts.mode, Mode.rule),
              ),
            );
          }, settle: const Duration(seconds: 1)),
        ],
      );
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      final outcome = await kernel.apply('config.ruleMode');

      expect(outcome.status, RemedyStatus.fixed);
      expect(outcome.remaining, isEmpty);
    });

    test('heals through the first step that clears the findings', () async {
      var ranLast = false;
      late final DoctorKernel kernel;
      kernel = _kernel(
        _FakeConfig(_config(mode: Mode.direct)),
        remedies: [
          _FakeRemedy('a', (_) async {}),
          _FakeRemedy('b', (_) async => kernel.put(Facts.mode, Mode.rule)),
          _FakeRemedy('c', (_) async {
            ranLast = true;
          }),
        ],
      );
      kernel.put(Facts.mode, Mode.direct);
      await kernel.settle();

      final plan = await kernel.heal(
        const HealPlan(
          id: 'p',
          remedyIds: ['a', 'b', 'c'],
          findingIds: ['config.directMode'],
        ),
      );

      expect(plan.healed, isTrue);
      expect(plan.steps.map((step) => step.remedyId), ['a', 'b']);
      expect(ranLast, isFalse);
    });
  });

  group('DoctorKernel core and probes', () {
    test(
      'cancels in-flight probes and journals the drop when the core disconnects',
      () async {
        final kernel = _kernel(_FakeConfig(_config()));
        final events = _collect(kernel);
        final started = Completer<void>();
        final probe = kernel.probe(
          ProbeRequest<int>(
            key: 'pending',
            cost: CheckCost.local,
            ttl: const Duration(minutes: 1),
            run: (_) {
              started.complete();
              return Completer<int>().future;
            },
          ),
        );
        await started.future;

        kernel.put(Facts.coreStatus, CoreStatus.connected);
        kernel.put(Facts.coreStatus, CoreStatus.disconnected);

        await expectLater(probe, throwsA(isA<ProbeCancelled>()));
        expect(
          events,
          contains(
            DiagnosticEvent(
              kind: DiagnosticEventKind.disconnected,
              at: _now,
              subject: 'disconnected',
            ),
          ),
        );
      },
    );

    test(
      'stores a probed fact in the snapshot and raises the finding it implies',
      () async {
        final kernel = _kernel(_FakeConfig(_config()));

        final skew = await kernel.probe(
          ProbeRequest<Duration>(
            key: Facts.clockSkew.id,
            fact: Facts.clockSkew,
            cost: CheckCost.network,
            ttl: const Duration(minutes: 10),
            run: (_) async => const Duration(seconds: 120),
          ),
        );
        await kernel.settle();

        expect(skew, const Duration(seconds: 120));
        expect(
          kernel.snapshot.valueOf(Facts.clockSkew),
          const Duration(seconds: 120),
        );
        final finding = kernel.findings.single;
        expect(finding.id, 'device.clockSkew');
        expect(finding.severity, CheckSeverity.critical);
      },
    );

    test(
      'journals a failed probe with its cause and rethrows the error',
      () async {
        final kernel = _kernel(_FakeConfig(_config()));
        final events = _collect(kernel);
        final failing = ProbeRequest<Duration>(
          key: 'skew',
          cost: CheckCost.network,
          ttl: const Duration(minutes: 1),
          run: (_) async =>
              throw const ProbeFailure(FailureCause.timeout, 'slow'),
        );

        await expectLater(
          kernel.probe(failing),
          throwsA(
            isA<ProbeFailure>().having(
              (failure) => failure.cause,
              'cause',
              FailureCause.timeout,
            ),
          ),
        );
        expect(
          events,
          contains(
            DiagnosticEvent(
              kind: DiagnosticEventKind.probeFailed,
              at: _now,
              subject: 'skew',
              cause: FailureCause.timeout,
              detail: 'slow',
            ),
          ),
        );
      },
    );

    test('explains a probe failure with its title and remedies', () {
      final kernel = _kernel(_FakeConfig(_config()));

      final explanation = kernel.explain(
        const ProbeFailure(FailureCause.subscriptionExpired),
      );

      expect(explanation.cause, FailureCause.subscriptionExpired);
      expect(explanation.remedyIds, ['profile.update']);
      expect(explanation.titleKey, 'doctorCause_subscriptionExpired');
    });

    test('explains an unrecognised error as unknown', () {
      final kernel = _kernel(_FakeConfig(_config()));

      final explanation = kernel.explain(StateError('x'));

      expect(explanation.cause, FailureCause.unknown);
      expect(explanation.remedyIds, isEmpty);
    });
  });
}
