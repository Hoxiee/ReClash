import 'dart:async';

import 'package:reclash/common/future.dart';
import 'package:flutter_test/flutter_test.dart';

int _identity(int value) => value;

int _failOnNegative(int value) {
  if (value < 0) {
    throw ArgumentError.value(value, 'value', 'must not be negative');
  }
  return value;
}

void main() {
  group('FutureExt.withTimeout', () {
    test('returns the value when it completes before the timeout', () async {
      final result = await Future<int>.value(
        7,
      ).withTimeout(timeout: const Duration(seconds: 1));

      expect(result, 7);
    });

    test('throws TimeoutException tagged with the supplied tag', () async {
      final pending = Completer<int>();
      addTearDown(() => pending.complete(0));

      await expectLater(
        pending.future.withTimeout(
          timeout: const Duration(milliseconds: 10),
          tag: 'fetchProfile',
        ),
        throwsA(
          isA<TimeoutException>().having(
            (error) => error.message,
            'message',
            'fetchProfile timeout',
          ),
        ),
      );
    });

    test('prefers onTimeout over throwing', () async {
      final pending = Completer<int>();
      addTearDown(() => pending.complete(0));

      final result = await pending.future.withTimeout(
        timeout: const Duration(milliseconds: 10),
        onTimeout: () => -1,
      );

      expect(result, -1);
    });

    test('cancels the onLast timer when the value arrives in time', () async {
      var lastCalls = 0;

      await Future<int>.value(1).withTimeout(
        timeout: const Duration(milliseconds: 50),
        onLast: () => lastCalls++,
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));

      expect(lastCalls, 0);
    });

    test(
      'runs onLast after the timeout when the future never settles',
      () async {
        var lastCalls = 0;
        final pending = Completer<int>();
        addTearDown(() => pending.complete(0));

        await pending.future.withTimeout(
          timeout: const Duration(milliseconds: 50),
          onLast: () => lastCalls++,
          onTimeout: () => 0,
        );

        expect(lastCalls, 0);
        await Future<void>.delayed(const Duration(milliseconds: 400));
        expect(lastCalls, 1);
      },
    );

    test('cancels the onLast timer when the future fails', () async {
      var lastCalls = 0;

      await expectLater(
        Future<int>.error(StateError('boom')).withTimeout(
          timeout: const Duration(milliseconds: 50),
          onLast: () => lastCalls++,
        ),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));

      expect(lastCalls, 0);
    });
  });

  group('LatestCompute', () {
    test('coalesces queued runs and reports only the latest input', () async {
      final results = <int>[];
      final reported = Completer<void>();
      final queue = LatestCompute<int, int>(_identity, (result) {
        results.add(result);
        if (result == 3) {
          reported.complete();
        }
      });

      queue.run(1);
      queue.run(2);
      queue.run(3);

      await reported.future.timeout(const Duration(seconds: 10));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(results, [3]);
    });

    test('drops the result of a run cancelled while in flight', () async {
      final results = <int>[];
      final queue = LatestCompute<int, int>(_identity, results.add);

      queue.run(1);
      queue.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(results, isEmpty);
    });

    test('reports every result when runs do not overlap', () async {
      final results = <int>[];
      final first = Completer<void>();
      final second = Completer<void>();
      final queue = LatestCompute<int, int>(_identity, (result) {
        results.add(result);
        if (result == 1) {
          first.complete();
        } else if (result == 2) {
          second.complete();
        }
      });

      queue.run(1);
      await first.future.timeout(const Duration(seconds: 10));
      queue.run(2);
      await second.future.timeout(const Duration(seconds: 10));

      expect(results, [1, 2]);
    });

    test('keeps draining after a task throws', () async {
      final results = <int>[];
      final reported = Completer<void>();
      final queue = LatestCompute<int, int>(_failOnNegative, (result) {
        results.add(result);
        reported.complete();
      });

      queue.run(-1);
      queue.run(2);

      await reported.future.timeout(const Duration(seconds: 10));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(results, [2]);
    });
  });

  group('CompleterExt.safeCompleter', () {
    test('completes a pending completer', () async {
      final completer = Completer<String>();

      completer.safeCompleter('value');

      expect(await completer.future, 'value');
    });

    test('ignores a second completion instead of throwing', () async {
      final completer = Completer<String>()..complete('first');

      expect(() => completer.safeCompleter('second'), returnsNormally);
      expect(await completer.future, 'first');
    });
  });
}
