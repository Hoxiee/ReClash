import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/macos_helper.dart';
import 'package:reclash/core/desktop/model.dart';

const _session = '0123456789abcdef0123456789abcdef';
const _hash =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('reclash/privileged_helper');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('registration status is not Helper readiness', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          if (call.method == 'register') {
            return {'status': 'requiresApproval'};
          }
          return {
            'status': 'enabled',
            'code': 'helperUnavailable',
            'detail': 'The registered Helper is not responding.',
          };
        });
    const port = NativeMacOSHelperPort();
    final registered = await port.register();
    final readiness = await port.readiness();
    expect(registered.status, MacOSHelperStatus.requiresApproval);
    expect(registered.isReady, isFalse);
    expect(readiness.status, MacOSHelperStatus.enabled);
    expect(readiness.isReady, isFalse);
    expect(readiness.code, 'helperUnavailable');
    expect(calls, ['register', 'readiness']);
  });

  test('native start carries only the scoped launch fields', () async {
    MethodCall? request;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          request = call;
          return {'sessionId': _session, 'pid': 42};
        });
    const port = NativeMacOSHelperPort();
    final started = await port.start(
      sessionId: _session,
      address: '/tmp/ReClashSocket_42.sock',
      homeDir: '/Users/test/Library/Application Support/com.reclash',
      coreSha256: _hash,
    );
    expect(started.pid, 42);
    expect(request!.method, 'start');
    expect(request!.arguments, {
      'sessionId': _session,
      'address': '/tmp/ReClashSocket_42.sock',
      'homeDir': '/Users/test/Library/Application Support/com.reclash',
      'coreSha256': _hash,
    });
  });

  test(
    'unconfirmed native stop is retained rather than treated as success',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async {
            throw PlatformException(code: 'coreStopFailed');
          });
      final result = await const NativeMacOSHelperPort().stop(
        sessionId: _session,
        timeout: const Duration(seconds: 10),
      );
      expect(result.exitConfirmed, isFalse);
    },
  );

  test(
    'unsigned bundle readiness remains actionable and fail closed',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async {
            return {
              'status': 'notFound',
              'code': 'bundleInvalid',
              'detail': 'Certificate signing is required.',
            };
          });
      final result = await const NativeMacOSHelperPort().readiness();
      expect(result.isReady, isFalse);
      expect(result.code, 'bundleInvalid');
    },
  );

  test('late cancellation stops the returned lease before settling', () async {
    final port = _FakePort();
    final launcher = _launcher(port);
    final attempt = launcher.begin(
      sessionId: _session,
      address: 'test-address',
    );
    await port.startEntered.future;
    attempt.cancel();
    expect(attempt.isSettled, isFalse);
    port.started.complete(
      const MacOSHelperStartResult(sessionId: _session, pid: 42),
    );
    await expectLater(attempt.result, throwsA(isA<MacOSHelperException>()));
    await attempt.settled;
    expect(port.stopCalls, 1);
    expect(attempt.lease!.owner, CoreProcessOwner.macosHelper);
    expect(attempt.lease!.pid, 42);
    expect(attempt.isSettled, isTrue);
  });

  test('unconfirmed late cancellation keeps the lease for a retry', () async {
    final port = _FakePort()..exitConfirmed = false;
    final attempt = _launcher(
      port,
    ).begin(sessionId: _session, address: 'test-address');
    await port.startEntered.future;
    attempt.cancel();
    port.started.complete(
      const MacOSHelperStartResult(sessionId: _session, pid: 42),
    );
    await expectLater(attempt.result, throwsA(isA<MacOSHelperException>()));
    await attempt.settled;
    expect(attempt.lease, isNotNull);
    port.exitConfirmed = true;
    final stopped = await attempt.lease!.stop(const Duration(seconds: 1));
    expect(stopped.exitConfirmed, isTrue);
    expect(port.stopCalls, 2);
  });

  test('cancelled pending native start stops its owned lease', () async {
    final port = _FakePort();
    final attempt = _launcher(
      port,
    ).begin(sessionId: _session, address: 'test-address');
    await port.startEntered.future;
    attempt.cancel();
    port.started.completeError(
      const MacOSHelperException(
        code: 'coreStopFailed',
        pendingCore: MacOSHelperStartResult(sessionId: _session, pid: 42),
      ),
    );
    await expectLater(attempt.result, throwsA(isA<MacOSHelperException>()));
    await attempt.settled;
    expect(port.stopCalls, 1);
    expect(attempt.lease!.pid, 42);
  });

  test('cancel before resolving home does not send a native start', () async {
    final port = _FakePort();
    final home = Completer<String>();
    final launcher = MacOSHelperLauncher(
      port: port,
      readCoreSha256: () async => _hash,
      homeDirectory: () => home.future,
    );
    final attempt = launcher.begin(
      sessionId: _session,
      address: 'test-address',
    );
    attempt.cancel();
    home.complete('/test');
    await expectLater(attempt.result, throwsA(isA<MacOSHelperException>()));
    await attempt.settled;
    expect(port.startCalls, 0);
  });

  test('lease serializes stop and retries an unconfirmed exit', () async {
    final port = _FakePort()..exitConfirmed = false;
    final lease = MacOSHelperLease(sessionId: _session, pid: 42, port: port);
    final first = lease.stop(const Duration(seconds: 1));
    final concurrent = lease.stop(const Duration(seconds: 1));
    expect(identical(first, concurrent), isTrue);
    expect((await first).exitConfirmed, isFalse);
    port.exitConfirmed = true;
    expect(
      (await lease.stop(const Duration(seconds: 1))).exitConfirmed,
      isTrue,
    );
    expect(
      (await lease.stop(const Duration(seconds: 1))).exitConfirmed,
      isTrue,
    );
    expect(port.stopCalls, 2);
  });

  test('native unconfirmed bootstrap child becomes an owned lease', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'start') {
            throw PlatformException(
              code: 'coreStopFailed',
              details: {'sessionId': _session, 'pid': 42},
            );
          }
          return {'stopped': true, 'exitConfirmed': false};
        });
    final launcher = MacOSHelperLauncher(
      readCoreSha256: () async => _hash,
      homeDirectory: () async => '/test',
    );
    final attempt = launcher.begin(
      sessionId: _session,
      address: 'test-address',
    );
    await expectLater(attempt.result, throwsA(isA<MacOSHelperException>()));
    await attempt.settled;
    expect(attempt.lease!.pid, 42);
    expect(attempt.lease!.owner, CoreProcessOwner.macosHelper);
  });
}

MacOSHelperLauncher _launcher(_FakePort port) => MacOSHelperLauncher(
  port: port,
  readCoreSha256: () async => _hash,
  homeDirectory: () async => '/test',
);

final class _FakePort implements MacOSHelperPort {
  final started = Completer<MacOSHelperStartResult>();
  final startEntered = Completer<void>();
  int startCalls = 0;
  int stopCalls = 0;
  bool exitConfirmed = true;

  @override
  Future<MacOSHelperStartResult> start({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  }) {
    startCalls++;
    startEntered.complete();
    return started.future;
  }

  @override
  Future<CoreProcessStopResult> stop({
    required String sessionId,
    required Duration timeout,
  }) async {
    stopCalls++;
    return CoreProcessStopResult(stopped: true, exitConfirmed: exitConfirmed);
  }

  @override
  Future<MacOSHelperReadiness> readiness() async =>
      const MacOSHelperReadiness(status: MacOSHelperStatus.enabled);

  @override
  Future<MacOSHelperReadiness> register() => readiness();

  @override
  Future<MacOSHelperReadiness> unregister() async =>
      const MacOSHelperReadiness(status: MacOSHelperStatus.notRegistered);
}
