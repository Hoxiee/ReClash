import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/launcher.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';

import 'fakes.dart';
import 'windows_fakes.dart';

const _session = '0123456789abcdef0123456789abcdef';
const _address = r'\\.\pipe\ReClashCore_test';

void main() {
  late FakeWindowsCorePort port;
  late WindowsCoreLauncher launcher;

  setUp(() {
    port = FakeWindowsCorePort();
    launcher = windowsLauncher(port);
  });
  tearDown(() => port.events.close());

  CoreLaunchAttempt begin() =>
      launcher.begin(sessionId: _session, address: _address);

  test('ordinary proxy session uses the direct launcher', () async {
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 20);
    final resolver = WindowsLauncherResolver(
      direct: direct,
      elevated: launcher,
    );
    expect(await resolver.resolve(), same(direct));
    expect(port.launches, 0);
  });

  test('an already elevated GUI still uses the managed launcher', () async {
    port.elevated = true;
    final resolver = WindowsLauncherResolver(
      direct: FakeLauncher(owner: CoreProcessOwner.direct, pid: 20),
      elevated: launcher,
    );
    expect(await resolver.resolve(), same(launcher));
  });

  test('TUN requires explicit consent before opening UAC', () async {
    final resolver = WindowsLauncherResolver(
      direct: FakeLauncher(owner: CoreProcessOwner.direct, pid: 20),
      elevated: launcher,
    )..elevationRequired = true;
    await expectLater(
      resolver.resolve(),
      throwsA(
        isA<WindowsLaunchException>().having(
          (error) => error.detail,
          'detail',
          'windows_authorization_required',
        ),
      ),
    );
    expect(port.launches, 0);
  });

  test('consent is consumed once and never reused by recovery', () async {
    final resolver =
        WindowsLauncherResolver(
            direct: FakeLauncher(owner: CoreProcessOwner.direct, pid: 20),
            elevated: launcher,
          )
          ..elevationRequired = true
          ..promptAllowed = true;
    expect(await resolver.resolve(), same(launcher));
    expect(resolver.promptAllowed, isFalse);
    await expectLater(
      resolver.resolve(),
      throwsA(isA<WindowsLaunchException>()),
    );
    resolver.promptAllowed = true;
    expect(await resolver.resolve(), same(launcher));
  });

  test('failed token query consumes consent and cannot fall back', () async {
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 20);
    final resolver = WindowsLauncherResolver(direct: direct, elevated: launcher)
      ..elevationRequired = true
      ..promptAllowed = true;
    port.elevationError = StateError('token query denied');
    await expectLater(
      resolver.resolve(),
      throwsA(
        isA<WindowsLaunchException>().having(
          (error) => error.detail,
          'detail',
          contains('windows_elevation_query_failed'),
        ),
      ),
    );
    expect(resolver.promptAllowed, isFalse);
    port.elevationError = null;
    await expectLater(
      resolver.resolve(),
      throwsA(isA<WindowsLaunchException>()),
    );
    expect(direct.startCount, 0);
    expect(port.launches, 0);
  });

  test('proxy-only startup does not request elevation', () async {
    final direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 20);
    final resolver = WindowsLauncherResolver(direct: direct, elevated: launcher)
      ..promptAllowed = true;
    expect(await resolver.resolve(), same(direct));
    expect(port.launches, 0);
  });

  test('already elevated GUI does not need repeated consent', () async {
    port.elevated = true;
    final resolver = WindowsLauncherResolver(
      direct: FakeLauncher(owner: CoreProcessOwner.direct, pid: 20),
      elevated: launcher,
    )..elevationRequired = true;
    expect(await resolver.resolve(), same(launcher));
    expect(await resolver.resolve(), same(launcher));
  });

  test('missing manifest fails before a native ticket exists', () async {
    launcher = WindowsCoreLauncher(
      port: port,
      readCoreSha256: () async => null,
      homeDirectory: () async => r'C:\home',
    );
    final attempt = begin();
    await expectLater(attempt.result, throwsA(isA<WindowsLaunchException>()));
    await attempt.settled;
    expect(port.calls, isEmpty);
  });

  test('cancellation during manifest loading cannot open UAC', () async {
    final hash = Completer<String?>();
    launcher = WindowsCoreLauncher(
      port: port,
      readCoreSha256: () => hash.future,
      homeDirectory: () async => r'C:\home',
    );
    final attempt = begin();
    attempt.cancel();
    await expectLater(attempt.result, throwsA(isA<WindowsLaunchException>()));
    hash.complete('a' * 64);
    await pumpEventQueue();
    expect(attempt.isSettled, isTrue);
    expect(port.calls, isEmpty);
  });

  test(
    'registers before launch and retains the original user directory',
    () async {
      final attempt = begin();
      await port.launched.future;
      expect(port.calls, ['prepare', 'launch']);
      expect(port.home, r'C:\Users\original\ReClash');
      expect(port.hash, 'a' * 64);
      port.emit('spawned');
      await attempt.spawned;
      expect(attempt.lease?.pid, 42);
      expect(attempt.isSettled, isFalse);
      port.emit('ready');
      final lease = await attempt.result;
      expect(lease.owner, CoreProcessOwner.windowsElevated);
      expect(lease.sessionId, _session);
      expect(attempt.isSettled, isTrue);
      await lease.stop(Duration.zero);
    },
  );

  test('rejects a ready message with another PID', () async {
    final attempt = begin();
    await port.launched.future;
    port.emit('spawned');
    port.emit('ready', '43');
    await expectLater(attempt.result, throwsA(isA<FormatException>()));
    expect(attempt.isSettled, isFalse);
    expect(attempt.lease?.pid, 42);
    port.emit('exited');
    await attempt.settled;
  });

  test(
    'late approval after cancellation never returns a usable lease',
    () async {
      final attempt = begin();
      await port.launched.future;
      attempt.cancel();
      expect(attempt.isSettled, isFalse);
      port.emit('spawned');
      port.emit('ready');
      await pumpEventQueue();
      expect(attempt.isSettled, isFalse);
      expect(attempt.lease, isNotNull);
      port.emit('exited');
      await expectLater(attempt.result, throwsA(isA<WindowsLaunchException>()));
      await attempt.settled;
    },
  );

  test('failed async launch releases its prepared ticket', () async {
    port.launchError = StateError('native launch rejected');
    port.cancelConfirmed = true;
    final attempt = begin();
    await expectLater(attempt.result, throwsStateError);
    await attempt.settled;
    expect(port.active, isFalse);
    expect(port.calls, ['prepare', 'launch', 'cancel']);
  });

  test(
    'stream failure retains ownership until native exit is confirmed',
    () async {
      final attempt = begin();
      await port.launched.future;
      port.events.addError(StateError('stream failed'));
      await expectLater(attempt.result, throwsStateError);
      expect(attempt.isSettled, isFalse);
      port.cancelConfirmed = true;
      attempt.cancel();
      await attempt.settled;
      expect(port.active, isFalse);
    },
  );

  test(
    'malformed events and failed cancellation do not escape callbacks',
    () async {
      final attempt = begin();
      await port.launched.future;
      port.cancelError = StateError('cannot revoke');
      port.events.add(['invalid']);
      await expectLater(attempt.result, throwsA(isA<FormatException>()));
      expect(attempt.isSettled, isFalse);
      port.cancelError = null;
      port.emit('exited');
      await attempt.settled;
    },
  );

  test(
    'lease retries unconfirmed exit and coalesces concurrent stops',
    () async {
      final attempt = begin();
      await port.launched.future;
      port.emit('spawned');
      port.emit('ready');
      final lease = await attempt.result;
      port.stopGate = Completer<bool>();
      final first = lease.stop(Duration.zero);
      final second = lease.stop(Duration.zero);
      expect(identical(first, second), isTrue);
      port.stopGate!.complete(false);
      expect((await first).exitConfirmed, isFalse);
      port.stopGate = null;
      expect((await lease.stop(Duration.zero)).exitConfirmed, isTrue);
      expect(port.stops, 2);
    },
  );
}
