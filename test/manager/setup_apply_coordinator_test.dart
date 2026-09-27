import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/manager/setup_apply_coordinator.dart';

void main() {
  test('applies without a frame, purely on the event loop', () async {
    var applied = 0;
    final coordinator = SetupApplyCoordinator(() async {
      applied++;
      return true;
    });

    final result = await coordinator.request();

    expect(result, isTrue);
    expect(applied, 1);
  });

  test('coalesces a synchronous burst into one trailing run', () async {
    var applied = 0;
    final coordinator = SetupApplyCoordinator(() async {
      applied++;
      return true;
    });

    unawaited(coordinator.request());
    unawaited(coordinator.request());
    await coordinator.request();

    expect(applied, 1);
  });

  test('a request arriving during a run triggers exactly one rerun', () async {
    var applied = 0;
    final gates = <Completer<bool>>[Completer(), Completer()];
    late SetupApplyCoordinator coordinator;
    coordinator = SetupApplyCoordinator(() {
      final gate = gates[applied];
      applied++;
      return gate.future;
    });

    final first = coordinator.request();
    await Future<void>.delayed(Duration.zero);
    unawaited(coordinator.request());
    gates[0].complete(true);
    await first;
    gates[1].complete(true);
    await Future<void>.delayed(Duration.zero);

    expect(applied, 2);
  });

  test('surfaces apply failures to the caller', () async {
    final coordinator = SetupApplyCoordinator(() async {
      throw StateError('apply failed');
    });

    await expectLater(coordinator.request(), throwsStateError);
  });
}
