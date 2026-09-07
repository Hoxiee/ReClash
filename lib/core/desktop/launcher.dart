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

abstract interface class DesktopCoreLauncherResolver {
  Future<CoreProcessLauncher> resolve();
}

final class DirectCoreLauncher implements CoreProcessLauncher {
  final CoreProcessStarter _startProcess;
  final String? _corePath;

  DirectCoreLauncher({CoreProcessStarter? startProcess, String? corePath})
    : _startProcess = startProcess ?? Process.start,
      _corePath = corePath;

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) async {
    final corePath = await _resolveCorePath();
    final process = await _startProcess(corePath, [address]);
    process.stdout.listen((_) {});
    process.stderr.listen((data) {
      final error = utf8.decode(data);
      if (error.isNotEmpty) {
        commonPrint.log(error, logLevel: LogLevel.warning);
      }
    });
    return DirectCoreLease(sessionId: sessionId, process: process);
  }

  // The read-only bundle binary (nosuid mount) can never create TUN.
  Future<String> _resolveCorePath() async {
    final injected = _corePath;
    if (injected != null) {
      return injected;
    }
    try {
      await appPath.corePathReady.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          commonPrint.log(
            'core path resolution timed out, spawning anyway',
            logLevel: LogLevel.warning,
          );
        },
      );
    } catch (error) {
      commonPrint.log('core path resolution failed: $error');
    }
    return appPath.corePath;
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
      // SIGTERM did not finish in time — the core may hang with its TUN
      // routes still installed. Escalate to SIGKILL, mirroring the Helper's
      // terminate ladder, before reporting an unconfirmed exit.
      _process.kill(ProcessSignal.sigkill);
      // Best effort: report the unconfirmed exit either way.
      await _process.exitCode.timeout(timeout).catchError((_) => 0);
      return CoreProcessStopResult(stopped: stopped, exitConfirmed: false);
    }
  }
}
