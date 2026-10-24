import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/launcher.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';

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

  test('reports the GUI token elevation', () async {
    final elevation = WindowsGuiElevation(launcher);
    expect(await elevation.isElevated(), isFalse);
    port.elevated = true;
    expect(await elevation.isElevated(), isTrue);
    expect(port.launches, 0);
  });

  test('a failed token query is typed and opens nothing', () async {
    port.elevationError = StateError('token query denied');
    await expectLater(
      WindowsGuiElevation(launcher).isElevated(),
      throwsA(
        isA<WindowsLaunchException>().having(
          (error) => error.detail,
          'detail',
          contains('windows_elevation_query_failed'),
        ),
      ),
    );
    expect(port.launches, 0);
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
