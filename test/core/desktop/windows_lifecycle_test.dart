import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/lifecycle.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/transport.dart';

import 'fakes.dart';
import 'windows_fakes.dart';

const _session = '0123456789abcdef0123456789abcdef';

void main() {
  late FakeWindowsCorePort port;
  late FakeDesktopCoreTransport transport;
  late DesktopCoreLifecycle lifecycle;
  late MutableLauncherResolver resolver;

  void create({Duration authorization = const Duration(seconds: 5)}) {
    port = FakeWindowsCorePort();
    transport = FakeDesktopCoreTransport(state: DesktopTransportState.ready);
    resolver = MutableLauncherResolver(windowsLauncher(port));
    lifecycle = DesktopCoreLifecycle(
      transportFactory: () => transport,
      launcherResolver: resolver,
      sessionIdFactory: () => _session,
      verifyPeerPid: true,
      maxRecoveryAttempts: 0,
      timeouts: DesktopCoreTimeouts(
        authorization: authorization,
        connection: const Duration(milliseconds: 100),
      ),
    );
    addTearDown(() async {
      port.cancelConfirmed = true;
      port.stopConfirmed = true;
      port.emit('exited');
      await lifecycle.close();
      await port.events.close();
    });
  }

  test('UAC wait does not consume the post-spawn connection budget', () async {
    create();
    final start = lifecycle.start();
    await port.launched.future;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(lifecycle.state, isA<DesktopCoreStarting>());
    port.emit('spawned');
    transport.connect(pid: 42);
    port.emit('ready');
    expect((await start).session?.pid, 42);
  });

  test('connection arriving before ready is retained', () async {
    create();
    final start = lifecycle.start();
    await port.launched.future;
    port.emit('spawned');
    transport.connect(pid: 42);
    await pumpEventQueue();
    expect(lifecycle.state, isA<DesktopCoreStarting>());
    port.emit('ready');
    await start;
    expect(lifecycle.state, isA<DesktopCoreRunning>());
  });

  for (final close in [false, true]) {
    test(
      '${close ? 'close' : 'stop'} revokes pending UAC without awaiting approval',
      () async {
        create();
        final start = lifecycle.start();
        await port.launched.future;
        await (close ? lifecycle.close() : lifecycle.stop()).timeout(
          const Duration(seconds: 1),
        );
        expect((await start).outcome, CoreLifecycleOutcome.superseded);
        expect(port.calls, contains('cancel'));
        port.emit('spawned');
        port.emit('ready');
        await pumpEventQueue();
        expect(lifecycle.state, isNot(isA<DesktopCoreRunning>()));
      },
    );
  }

  test(
    'an unresolved UAC attempt also blocks a direct Core replacement',
    () async {
      create();
      final start = lifecycle.start();
      await port.launched.future;
      await lifecycle.stop();
      await start;
      final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 84);
      resolver.launcher = direct;
      await expectLater(
        lifecycle.start(),
        throwsA(
          isA<DesktopCoreFailure>().having(
            (e) => e.code,
            'code',
            'launch_pending',
          ),
        ),
      );
      expect(direct.startCount, 0);
    },
  );

  test('a post-spawn unconfirmed exit prevents replacement', () async {
    create();
    port.stopConfirmed = false;
    final start = expectLater(
      lifecycle.start(),
      throwsA(isA<DesktopCoreFailure>()),
    );
    await port.launched.future;
    port.emit('spawned');
    await pumpEventQueue();
    await expectLater(lifecycle.stop(), throwsA(isA<DesktopCoreFailure>()));
    await start;
    await expectLater(lifecycle.start(), throwsA(isA<DesktopCoreFailure>()));
    expect(port.launches, 1);
  });

  test('authorization timeout retains the late native attempt', () async {
    create(authorization: const Duration(milliseconds: 30));
    await expectLater(lifecycle.start(), throwsA(isA<DesktopCoreFailure>()));
    expect(port.calls, contains('cancel'));
    await expectLater(lifecycle.start(), throwsA(isA<DesktopCoreFailure>()));
    expect(port.launches, 1);
  });

  test('bootstrap deadline applies when RPC connects before ready', () async {
    create();
    final start = expectLater(
      lifecycle.start(),
      throwsA(isA<DesktopCoreFailure>()),
    );
    await port.launched.future;
    port.emit('spawned');
    transport.connect(pid: 42);
    await start;
    expect(port.stops, 1);
  });

  test('mismatched IPC PID cannot publish running', () async {
    create();
    final start = expectLater(
      lifecycle.start(),
      throwsA(
        isA<DesktopCoreFailure>().having(
          (e) => e.code,
          'code',
          'peer_pid_mismatch',
        ),
      ),
    );
    await port.launched.future;
    port.emit('spawned');
    port.emit('ready');
    transport.connect(pid: 43);
    await start;
    expect(port.stops, 1);
  });

  test('failed cancellation cannot lose a pending native owner', () async {
    create();
    final start = lifecycle.start();
    start.ignore();
    await port.launched.future;
    port.cancelError = StateError('native cancellation failed');
    await expectLater(lifecycle.stop(), throwsA(isA<DesktopCoreFailure>()));
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 84);
    resolver.launcher = direct;
    await expectLater(lifecycle.start(), throwsA(isA<DesktopCoreFailure>()));
    expect(direct.startCount, 0);
    port.cancelError = null;
  });
}
