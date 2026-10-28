import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

import 'model.dart';

typedef CoreProcessStarter =
    Future<Process> Function(String executable, List<String> arguments);

abstract interface class CoreProcessLauncher {
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  });
}

final class CoreLaunchCleanupFailure implements Exception {
  final String sessionId;
  final Object cause;
  final Future<void> Function() retryCleanup;

  const CoreLaunchCleanupFailure({
    required this.sessionId,
    required this.cause,
    required this.retryCleanup,
  });

  @override
  String toString() =>
      'Core launch cleanup for $sessionId is unconfirmed: $cause';
}

abstract interface class CoreLaunchAttempt {
  String get sessionId;
  Future<void> get spawned;
  Future<CoreProcessLease> get result;
  Future<void> get settled;
  bool get isSettled;
  CoreProcessLease? get lease;
  void cancel();
}

abstract interface class CancellableCoreProcessLauncher
    implements CoreProcessLauncher {
  CoreLaunchAttempt begin({required String sessionId, required String address});
}

abstract interface class DesktopCoreLauncherResolver {
  Future<CoreProcessLauncher> resolve();
}

final class DirectCoreLauncher implements CoreProcessLauncher {
  final CoreProcessStarter _startProcess;
  final String corePath;

  DirectCoreLauncher({CoreProcessStarter? startProcess, String? corePath})
    : _startProcess = startProcess ?? Process.start,
      corePath = corePath ?? appPath.corePath;

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) async {
    final process = await _startProcess(corePath, [address]);
    process.stdout.listen((_) {});
    process.stderr.listen((data) {
      final error = utf8.decode(data, allowMalformed: true);
      if (error.isNotEmpty) {
        commonPrint.log(error, logLevel: LogLevel.warning);
      }
    });
    return DirectCoreLease(sessionId: sessionId, process: process);
  }
}

final class DirectCoreLease implements CoreProcessLease {
  @override
  final String sessionId;

  final Process _process;
  Future<CoreProcessStopResult>? _stopOperation;

  DirectCoreLease({required this.sessionId, required Process process})
    : _process = process;

  @override
  CoreProcessOwner get owner => CoreProcessOwner.direct;

  @override
  int get pid => _process.pid;

  @override
  Future<CoreProcessStopResult> stop(Duration timeout) {
    final stopOperation = _stopOperation;
    if (stopOperation != null) {
      return stopOperation;
    }
    final nextOperation = _stop(timeout).then((result) {
      if (!result.exitConfirmed) {
        _stopOperation = null;
      }
      return result;
    });
    _stopOperation = nextOperation;
    return nextOperation;
  }

  Future<CoreProcessStopResult> _stop(Duration timeout) async {
    final stopped = _process.kill();
    try {
      await _process.exitCode.timeout(timeout);
      return CoreProcessStopResult(stopped: stopped, exitConfirmed: true);
    } on TimeoutException {
      return CoreProcessStopResult(stopped: stopped, exitConfirmed: false);
    }
  }
}
