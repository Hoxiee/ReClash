import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/launcher.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async =>
      Directory.systemTemp.createTempSync('launcher_test').path;

  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.createTempSync('launcher_test').path;

  @override
  Future<String?> getApplicationCachePath() async =>
      Directory.systemTemp.createTempSync('launcher_test').path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    PathProviderPlatform.instance = _FakePathProvider();
  });

  test('createCoreSessionId returns lowercase 128-bit hex', () {
    expect(createCoreSessionId(), matches(RegExp(r'^[0-9a-f]{32}$')));
  });

  test(
    'awaits core-path resolution before spawning the bundled core',
    () async {
      final process = _FakeProcess(pid: 42, exitCode: Future.value(0));
      String? executable;
      final launcher = DirectCoreLauncher(
        startProcess: (value, _) async {
          executable = value;
          return process;
        },
      );

      final startFuture = launcher.start(
        sessionId: '0123456789abcdef0123456789abcdef',
        address: 'test-address',
      );
      if (Platform.isLinux) {
        // The gate is pending until ensureWritableCore resolves it.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(executable, isNull);
        await appPath.ensureWritableCore();
      }
      final lease = await startFuture;

      expect(executable, appPath.corePath);
      expect(lease.pid, 42);
    },
  );

  test('direct lease kills and confirms the owned process exit', () async {
    final process = _FakeProcess(pid: 42, exitCode: Future.value(0));
    String? executable;
    List<String>? arguments;
    final launcher = DirectCoreLauncher(
      startProcess: (value, valueArguments) async {
        executable = value;
        arguments = valueArguments;
        return process;
      },
      corePath: 'ReClashCore',
    );

    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );
    final result = await lease.stop(const Duration(seconds: 1));

    expect(lease.owner, CoreProcessOwner.direct);
    expect(lease.pid, 42);
    expect(executable, 'ReClashCore');
    expect(arguments, ['test-address']);
    expect(process.killed, isTrue);
    expect(
      result,
      const CoreProcessStopResult(stopped: true, exitConfirmed: true),
    );
  });

  test('direct lease confirms an exit after escalating to SIGKILL', () async {
    final exitCode = Completer<int>();
    late _FakeProcess process;
    process = _FakeProcess(
      pid: 42,
      exitCode: exitCode.future,
      onKill: (signal) {
        if (signal == ProcessSignal.sigkill) exitCode.complete(137);
      },
    );
    final launcher = DirectCoreLauncher(
      startProcess: (_, _) async => process,
      corePath: 'ReClashCore',
    );
    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );

    final result = await lease.stop(const Duration(milliseconds: 10));

    expect(result.stopped, isTrue);
    expect(result.exitConfirmed, isTrue);
  });

  test('direct lease reports an unconfirmed exit after timeout', () async {
    final process = _FakeProcess(pid: 42, exitCode: Completer<int>().future);
    final launcher = DirectCoreLauncher(
      startProcess: (_, _) async => process,
      corePath: 'ReClashCore',
    );
    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );

    final result = await lease.stop(Duration.zero);

    expect(result.stopped, isTrue);
    expect(result.exitConfirmed, isFalse);
  });

  test('direct lease rechecks exit after an unconfirmed timeout', () async {
    final exitCode = Completer<int>();
    final process = _FakeProcess(pid: 42, exitCode: exitCode.future);
    final launcher = DirectCoreLauncher(
      startProcess: (_, _) async => process,
      corePath: 'ReClashCore',
    );
    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );

    final firstResult = await lease.stop(Duration.zero);
    exitCode.complete(0);
    final secondResult = await lease.stop(const Duration(seconds: 1));

    expect(firstResult.exitConfirmed, isFalse);
    expect(secondResult.exitConfirmed, isTrue);
  });
}

class _FakeProcess implements Process {
  @override
  final int pid;

  @override
  final Future<int> exitCode;

  @override
  final Stream<List<int>> stdout = const Stream.empty();

  @override
  final Stream<List<int>> stderr = const Stream.empty();

  bool killed = false;
  final void Function(ProcessSignal signal)? onKill;

  _FakeProcess({required this.pid, required this.exitCode, this.onKill});

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    onKill?.call(signal);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
