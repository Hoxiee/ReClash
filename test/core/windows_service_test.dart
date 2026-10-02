import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/core/desktop/lifecycle.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/rpc_client.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';
import 'package:reclash/core/service.dart';

import 'desktop/fakes.dart';
import 'desktop/windows_fakes.dart';

final class _Lifecycle extends Mock implements DesktopCoreLifecycleController {}

final class _Rpc extends Mock implements CoreRpcChannel {}

void main() {
  late _Lifecycle lifecycle;
  late _Rpc rpc;
  late FakeWindowsCorePort port;
  late WindowsLauncherResolver resolver;
  late StreamController<DesktopCoreFailure> crashes;
  late CoreService service;
  late DesktopCoreState state;

  const result = CoreLifecycleResult(
    revision: 1,
    outcome: CoreLifecycleOutcome.applied,
  );
  const starting = DesktopCoreStarting(revision: 1, sessionId: 'test');
  const failed = DesktopCoreFailed(
    DesktopCoreFailure(
      code: 'start_failed',
      phase: DesktopCorePhase.starting,
      revision: 1,
    ),
  );

  setUp(() {
    lifecycle = _Lifecycle();
    rpc = _Rpc();
    port = FakeWindowsCorePort();
    resolver = WindowsLauncherResolver(
      direct: FakeLauncher(owner: CoreProcessOwner.direct, pid: 20),
      elevated: windowsLauncher(port),
    );
    crashes = StreamController<DesktopCoreFailure>.broadcast();
    state = const DesktopCoreIdle();
    when(() => lifecycle.state).thenAnswer((_) => state);
    when(() => lifecycle.crashEvents).thenAnswer((_) => crashes.stream);
    when(() => lifecycle.stop()).thenAnswer((_) async {
      state = const DesktopCoreIdle();
      return result;
    });
    when(() => lifecycle.close()).thenAnswer((_) async => result);
    when(() => rpc.close()).thenAnswer((_) async {});
    service = CoreService.forTesting(
      lifecycle: lifecycle,
      rpcClient: rpc,
      windowsLauncher: resolver,
    );
  });

  tearDown(() async {
    await service.close();
    await crashes.close();
    await port.events.close();
  });

  test('a requirement alone never grants another UAC prompt', () async {
    expect(await service.requireTunElevation(true), isFalse);
    expect(resolver.elevationRequired, isTrue);
    expect(resolver.promptAllowed, isFalse);
    await service.requireTunElevation(true, allowPrompt: true);
    expect(resolver.promptAllowed, isTrue);
    await resolver.resolve();
    await service.requireTunElevation(true);
    expect(resolver.promptAllowed, isFalse);
  });

  test(
    'stop during elevation cancels the lifecycle and skips listener RPC',
    () async {
      await service.requireTunElevation(true, allowPrompt: true);
      state = starting;
      expect(await service.requireTunElevation(false), isTrue);
      verify(() => lifecycle.stop()).called(1);
      expect(resolver.elevationRequired, isFalse);
      expect(resolver.promptAllowed, isFalse);
      verifyZeroInteractions(rpc);
    },
  );

  test(
    'a failed launch is stopped before reporting the listener absent',
    () async {
      state = failed;
      expect(await service.requireTunElevation(false), isTrue);
      verify(() => lifecycle.stop()).called(1);
    },
  );

  test('idle and closed states never need listener RPC', () async {
    expect(await service.requireTunElevation(false), isTrue);
    state = const DesktopCoreClosed(2);
    expect(await service.requireTunElevation(false), isTrue);
    verifyNever(() => lifecycle.stop());
  });

  test(
    'a superseded stop cannot report the replacement listener absent',
    () async {
      state = starting;
      await service.requireTunElevation(true);
      when(() => lifecycle.stop()).thenAnswer((_) async {
        state = DesktopCoreRunning(
          DesktopCoreSession(
            sessionId: 'replacement',
            connectionGeneration: 2,
            lease: FakeProcessLease(
              owner: CoreProcessOwner.windowsElevated,
              pid: 43,
            ),
          ),
        );
        return const CoreLifecycleResult(
          revision: 1,
          outcome: CoreLifecycleOutcome.superseded,
        );
      });
      expect(await service.requireTunElevation(false), isFalse);
      expect(service.processOwner, CoreProcessOwner.windowsElevated);
    },
  );

  test('active elevated Core remains owned until lifecycle restart', () async {
    state = DesktopCoreRunning(
      DesktopCoreSession(
        sessionId: 'test',
        connectionGeneration: 1,
        lease: FakeProcessLease(
          owner: CoreProcessOwner.windowsElevated,
          pid: 42,
        ),
      ),
    );
    await service.requireTunElevation(true);
    expect(await service.requireTunElevation(false), isFalse);
    expect(service.processOwner, CoreProcessOwner.windowsElevated);
    verifyNever(() => lifecycle.stop());
  });

  test(
    'failed cancellation cannot falsely report a missing listener',
    () async {
      state = starting;
      await service.requireTunElevation(true);
      when(() => lifecycle.stop()).thenThrow(StateError('stop failed'));
      await expectLater(service.requireTunElevation(false), throwsStateError);
      expect(state, same(starting));
    },
  );

  test('non-Windows service leaves its lifecycle unchanged', () async {
    final other = CoreService.forTesting(lifecycle: lifecycle, rpcClient: rpc);
    expect(await other.requireTunElevation(true, allowPrompt: true), isFalse);
    expect(await other.requireTunElevation(false), isFalse);
    verifyNever(() => lifecycle.stop());
    await other.close();
  });
}
