import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/probes/clock.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/models/models.dart';

final _start = DateTime(2026, 10, 29, 12);

const _ttl = Duration(minutes: 1);

ProbeRequest<int> _request(
  String key,
  Future<int> Function(ProbeToken token) run, {
  Object? intent,
  CheckCost cost = CheckCost.local,
}) => ProbeRequest<int>(
  key: key,
  cost: cost,
  ttl: _ttl,
  intent: intent,
  run: run,
);

ProbeRequest<int> _counted(List<Object?> calls, {Object? intent}) =>
    _request('k', (_) async {
      calls.add(intent);
      return calls.length;
    }, intent: intent);

void main() {
  group('ProbeScheduler sharing and caching', () {
    test(
      'shares one execution between callers with the same key and intent',
      () async {
        final gate = Completer<int>();
        var runs = 0;
        final scheduler = ProbeScheduler(clock: () => _start);
        final request = _request('k', (_) {
          runs++;
          return gate.future;
        }, intent: 'route');

        final first = scheduler.run(request);
        final second = scheduler.run(request);
        gate.complete(7);

        expect(await first, 7);
        expect(await second, 7);
        expect(runs, 1);
      },
    );

    test(
      'returns a cached result within its ttl without running again',
      () async {
        final calls = <Object?>[];
        final scheduler = ProbeScheduler(clock: () => _start);

        expect(await scheduler.run(_counted(calls)), 1);
        expect(await scheduler.run(_counted(calls)), 1);
        expect(calls, hasLength(1));
      },
    );

    test('runs again once the ttl has passed', () async {
      final calls = <Object?>[];
      var now = _start;
      final scheduler = ProbeScheduler(clock: () => now);

      await scheduler.run(_counted(calls));
      now = now.add(const Duration(minutes: 2));

      expect(await scheduler.run(_counted(calls)), 2);
    });

    test('forced() bypasses the cache', () async {
      final calls = <Object?>[];
      final scheduler = ProbeScheduler(clock: () => _start);

      await scheduler.run(_counted(calls));
      final forced = _counted(calls).forced();

      expect(await scheduler.run(forced), 2);
    });

    test('a different intent bypasses the cache', () async {
      final calls = <Object?>[];
      final scheduler = ProbeScheduler(clock: () => _start);

      await scheduler.run(_counted(calls, intent: 'a'));

      expect(await scheduler.run(_counted(calls, intent: 'b')), 2);
    });
  });

  group('ProbeScheduler latest intent', () {
    test(
      'a newer intent cancels the run in flight and answers its callers',
      () async {
        final stale = Completer<int>();
        var started = false;
        final scheduler = ProbeScheduler(clock: () => _start);

        final first = scheduler.run(
          ProbeRequest<int>(
            key: 'k',
            cost: CheckCost.local,
            ttl: _ttl,
            intent: 1,
            run: (_) {
              started = true;
              return stale.future;
            },
          ),
        );
        final second = scheduler.run(_request('k', (_) async => 20, intent: 2));

        expect(await first, 20);
        expect(started, isFalse);
        expect(await second, 20);

        stale.complete(10);
        await pumpEventQueue();

        expect(
          await scheduler.run(_request('k', (_) async => 99, intent: 2)),
          20,
        );
      },
    );
  });

  group('ProbeScheduler failures and cancellation', () {
    test('rethrows a failed run and does not cache it', () async {
      var calls = 0;
      final scheduler = ProbeScheduler(clock: () => _start);
      final request = _request('k', (_) async {
        calls++;
        if (calls == 1) throw StateError('boom');
        return 5;
      });

      await expectLater(scheduler.run(request), throwsStateError);
      expect(await scheduler.run(request), 5);
      expect(calls, 2);
    });

    test(
      'cancelAll fails pending callers, cancels their tokens and clears the cache',
      () async {
        final calls = <Object?>[];
        final gate = Completer<int>();
        final started = Completer<ProbeToken>();
        final scheduler = ProbeScheduler(clock: () => _start);
        expect(await scheduler.run(_counted(calls)), 1);

        final pending = scheduler.run(
          ProbeRequest<int>(
            key: 'slow',
            cost: CheckCost.local,
            ttl: _ttl,
            run: (token) {
              started.complete(token);
              return gate.future;
            },
          ),
        );
        final token = await started.future;

        scheduler.cancelAll();

        await expectLater(pending, throwsA(isA<ProbeCancelled>()));
        expect(token.isCancelled, isTrue);
        expect(await scheduler.run(_counted(calls)), 2);
      },
    );
  });

  group('ProbeScheduler cost limits', () {
    test(
      'a heavy limit of one holds the second heavy probe until the first completes',
      () async {
        final scheduler = ProbeScheduler(
          clock: () => _start,
          limits: const {CheckCost.heavy: 1},
        );
        final firstGate = Completer<int>();
        final firstStarted = Completer<void>();
        var secondStarted = false;

        final first = scheduler.run(
          _request('a', (_) {
            firstStarted.complete();
            return firstGate.future;
          }, cost: CheckCost.heavy),
        );
        await firstStarted.future;
        final second = scheduler.run(
          _request('b', (_) async {
            secondStarted = true;
            return 2;
          }, cost: CheckCost.heavy),
        );
        await pumpEventQueue();
        expect(secondStarted, isFalse);

        firstGate.complete(1);

        expect(await first, 1);
        expect(await second, 2);
        expect(secondStarted, isTrue);
      },
    );

    test('cancelAll fails a queued caller without starting its run', () async {
      final scheduler = ProbeScheduler(
        clock: () => _start,
        limits: const {CheckCost.heavy: 1},
      );
      final firstStarted = Completer<void>();
      final first = scheduler.run(
        _request('a', (_) {
          firstStarted.complete();
          return Completer<int>().future;
        }, cost: CheckCost.heavy),
      );
      await firstStarted.future;
      var queuedStarted = false;
      final queued = scheduler.run(
        _request('b', (_) async {
          queuedStarted = true;
          return 2;
        }, cost: CheckCost.heavy),
      );
      await pumpEventQueue();

      scheduler.cancelAll();

      await expectLater(first, throwsA(isA<ProbeCancelled>()));
      await expectLater(queued, throwsA(isA<ProbeCancelled>()));
      await pumpEventQueue();
      expect(queuedStarted, isFalse);
    });

    test('a cost without a limit starts all its probes together', () async {
      final scheduler = ProbeScheduler(
        clock: () => _start,
        limits: const {CheckCost.heavy: 1},
      );
      final release = Completer<void>();
      final bothStarted = Completer<void>();
      var started = 0;

      Future<int> probe(ProbeToken token) async {
        started++;
        if (started == 2) bothStarted.complete();
        await release.future;
        return started;
      }

      final first = scheduler.run(_request('a', probe));
      final second = scheduler.run(_request('b', probe));
      await bothStarted.future;
      release.complete();

      expect(await first, 2);
      expect(await second, 2);
    });
  });

  group('clockSkewProbe', () {
    test(
      'reports the skew as a duration and sends the url and timeout',
      () async {
        final scheduler = ProbeScheduler(clock: () => _start);
        ClockSkewParams? sent;
        final request = clockSkewProbe((params) async {
          sent = params;
          return const ClockSkewResult(skewMs: 1500);
        }, url: 'https://example.com/generate_204');

        expect(
          await scheduler.run(request),
          const Duration(milliseconds: 1500),
        );
        expect(sent?.url, 'https://example.com/generate_204');
        expect(sent?.timeout, 5000);
      },
    );

    test('throws the cause the core reports', () async {
      final scheduler = ProbeScheduler(clock: () => _start);
      final request = clockSkewProbe(
        (_) async =>
            const ClockSkewResult(cause: 'authRejected', message: '401'),
        url: 'https://example.com',
      );

      await expectLater(
        scheduler.run(request),
        throwsA(
          isA<ProbeFailure>().having(
            (failure) => failure.cause,
            'cause',
            FailureCause.authRejected,
          ),
        ),
      );
    });

    test('treats a missing answer as an unknown failure', () async {
      final scheduler = ProbeScheduler(clock: () => _start);
      final request = clockSkewProbe(
        (_) async => null,
        url: 'https://example.com',
      );

      await expectLater(
        scheduler.run(request),
        throwsA(
          isA<ProbeFailure>().having(
            (failure) => failure.cause,
            'cause',
            FailureCause.unknown,
          ),
        ),
      );
    });
  });
}
