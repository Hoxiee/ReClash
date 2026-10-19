import 'dart:async';

import 'package:flutter/services.dart';
import 'package:reclash/common/path.dart';

import 'core_manifest.dart';
import 'launcher.dart';
import 'model.dart';

enum MacOSHelperStatus { enabled, notRegistered, notFound, requiresApproval }

final class MacOSHelperReadiness {
  final MacOSHelperStatus status;
  final String? code;
  final String? detail;

  const MacOSHelperReadiness({required this.status, this.code, this.detail});

  bool get isReady => status == MacOSHelperStatus.enabled && code == null;
}

final class MacOSHelperStartResult {
  final String sessionId;
  final int pid;

  const MacOSHelperStartResult({required this.sessionId, required this.pid});
}

final class MacOSHelperException implements Exception {
  final String code;
  final String? detail;
  final MacOSHelperStartResult? pendingCore;

  const MacOSHelperException({
    required this.code,
    this.detail,
    this.pendingCore,
  });

  @override
  String toString() => detail == null ? code : '$code: $detail';
}

abstract interface class MacOSHelperPort {
  Future<MacOSHelperReadiness> readiness();
  Future<MacOSHelperReadiness> register();
  Future<MacOSHelperReadiness> unregister();
  Future<MacOSHelperStartResult> start({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  });
  Future<CoreProcessStopResult> stop({
    required String sessionId,
    required Duration timeout,
  });
}

final class NativeMacOSHelperPort implements MacOSHelperPort {
  final MethodChannel channel;

  const NativeMacOSHelperPort({
    this.channel = const MethodChannel('reclash/privileged_helper'),
  });

  Future<Map<Object?, Object?>> _invoke(
    String method, [
    Map<String, Object>? arguments,
  ]) async {
    try {
      final result = await channel.invokeMapMethod<Object?, Object?>(
        method,
        arguments,
      );
      if (result == null) {
        throw const MacOSHelperException(code: 'helperResponseInvalid');
      }
      return result;
    } on PlatformException catch (error) {
      final details = error.details;
      final session = details is Map ? details['sessionId'] : null;
      final pid = details is Map ? details['pid'] : null;
      throw MacOSHelperException(
        code: error.code,
        detail: error.message,
        pendingCore: session is String && pid is int && pid > 1
            ? MacOSHelperStartResult(sessionId: session, pid: pid)
            : null,
      );
    } on MissingPluginException {
      throw const MacOSHelperException(
        code: 'bundleInvalid',
        detail: 'The macOS privileged Helper bridge is not bundled.',
      );
    }
  }

  Future<MacOSHelperReadiness> _readiness(String method) async {
    final value = await _invoke(method);
    final status = switch (value['status']) {
      'enabled' => MacOSHelperStatus.enabled,
      'notRegistered' => MacOSHelperStatus.notRegistered,
      'notFound' => MacOSHelperStatus.notFound,
      'requiresApproval' => MacOSHelperStatus.requiresApproval,
      _ => throw const MacOSHelperException(code: 'helperResponseInvalid'),
    };
    final code = value['code'];
    final detail = value['detail'];
    if ((code != null && code is! String) ||
        (detail != null && detail is! String)) {
      throw const MacOSHelperException(code: 'helperResponseInvalid');
    }
    return MacOSHelperReadiness(
      status: status,
      code: code as String?,
      detail: detail as String?,
    );
  }

  @override
  Future<MacOSHelperReadiness> readiness() => _readiness('readiness');

  @override
  Future<MacOSHelperReadiness> register() => _readiness('register');

  @override
  Future<MacOSHelperReadiness> unregister() => _readiness('unregister');

  @override
  Future<MacOSHelperStartResult> start({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  }) async {
    final value = await _invoke('start', {
      'sessionId': sessionId,
      'address': address,
      'homeDir': homeDir,
      'coreSha256': coreSha256,
    });
    final returnedSession = value['sessionId'];
    final pid = value['pid'];
    if (returnedSession != sessionId || pid is! int || pid <= 1) {
      throw const MacOSHelperException(code: 'helperResponseInvalid');
    }
    return MacOSHelperStartResult(sessionId: sessionId, pid: pid);
  }

  @override
  Future<CoreProcessStopResult> stop({
    required String sessionId,
    required Duration timeout,
  }) async {
    try {
      final value = await _invoke('stop', {
        'sessionId': sessionId,
        'timeoutMillis': timeout.inMilliseconds.clamp(0, 8000),
      });
      final stopped = value['stopped'];
      final confirmed = value['exitConfirmed'];
      if (stopped is! bool || confirmed is! bool) {
        throw const MacOSHelperException(code: 'helperResponseInvalid');
      }
      return CoreProcessStopResult(stopped: stopped, exitConfirmed: confirmed);
    } on MacOSHelperException catch (error) {
      if (error.code == 'coreStopFailed') {
        return const CoreProcessStopResult(stopped: true, exitConfirmed: false);
      }
      rethrow;
    }
  }
}

final class MacOSHelperLauncher implements CancellableCoreProcessLauncher {
  final MacOSHelperPort port;
  final Future<String?> Function() readCoreSha256;
  final Future<String> Function() homeDirectory;

  MacOSHelperLauncher({
    this.port = const NativeMacOSHelperPort(),
    Future<String?> Function()? readCoreSha256,
    Future<String> Function()? homeDirectory,
  }) : readCoreSha256 = readCoreSha256 ?? CoreManifest.readCoreSha256,
       homeDirectory = homeDirectory ?? (() => appPath.homeDirPath);

  @override
  CoreLaunchAttempt begin({
    required String sessionId,
    required String address,
  }) => _MacOSHelperLaunchAttempt(this, sessionId, address);

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) => begin(sessionId: sessionId, address: address).result;
}

final class _MacOSHelperLaunchAttempt implements CoreLaunchAttempt {
  final MacOSHelperLauncher launcher;
  @override
  final String sessionId;
  final String address;
  final Completer<void> _spawned = Completer<void>();
  final Completer<void> _settled = Completer<void>();
  final Completer<CoreProcessLease> _result = Completer<CoreProcessLease>();
  MacOSHelperLease? _lease;
  bool _cancelled = false;
  bool _sent = false;

  _MacOSHelperLaunchAttempt(this.launcher, this.sessionId, this.address) {
    _result.future.ignore();
    _spawned.future.ignore();
    unawaited(_launch());
  }

  @override
  Future<void> get spawned => _spawned.future;
  @override
  Future<CoreProcessLease> get result => _result.future;
  @override
  Future<void> get settled => _settled.future;
  @override
  bool get isSettled => _settled.isCompleted;
  @override
  CoreProcessLease? get lease => _lease;

  Future<void> _launch() async {
    try {
      final hash = await launcher.readCoreSha256();
      if (_cancelled) return _finishCancelled();
      if (hash == null || !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
        throw const MacOSHelperException(code: 'bundleInvalid');
      }
      final home = await launcher.homeDirectory();
      if (_cancelled) return _finishCancelled();
      _sent = true;
      final MacOSHelperStartResult started;
      try {
        started = await launcher.port.start(
          sessionId: sessionId,
          address: address,
          homeDir: home,
          coreSha256: hash,
        );
      } on MacOSHelperException catch (error) {
        final pending = error.pendingCore;
        if (pending != null && pending.sessionId == sessionId) {
          _lease = MacOSHelperLease(
            sessionId: sessionId,
            pid: pending.pid,
            port: launcher.port,
          );
          _spawned.complete();
          if (_cancelled) {
            await _lease!.stop(const Duration(seconds: 8)).catchError((
              Object _,
            ) {
              return const CoreProcessStopResult(
                stopped: false,
                exitConfirmed: false,
              );
            });
          }
        }
        rethrow;
      }
      if (started.sessionId != sessionId || started.pid <= 1) {
        throw const MacOSHelperException(code: 'helperResponseInvalid');
      }
      _lease = MacOSHelperLease(
        sessionId: started.sessionId,
        pid: started.pid,
        port: launcher.port,
      );
      _spawned.complete();
      if (_cancelled) {
        await _lease!.stop(const Duration(seconds: 8));
        _finishCancelled();
      } else {
        _result.complete(_lease);
      }
    } catch (error, stack) {
      if (!_spawned.isCompleted) _spawned.completeError(error, stack);
      if (!_result.isCompleted) _result.completeError(error, stack);
    } finally {
      if (!_settled.isCompleted) _settled.complete();
    }
  }

  void _finishCancelled() {
    const error = MacOSHelperException(code: 'launchCancelled');
    if (!_spawned.isCompleted) _spawned.completeError(error);
    if (!_result.isCompleted) _result.completeError(error);
  }

  @override
  void cancel() {
    _cancelled = true;
    final owned = _lease;
    if (owned != null) {
      unawaited(
        owned.stop(const Duration(seconds: 8)).catchError((Object _) {
          return const CoreProcessStopResult(
            stopped: false,
            exitConfirmed: false,
          );
        }),
      );
    } else if (!_sent) {
      _finishCancelled();
    }
  }
}

final class MacOSHelperLease implements CoreProcessLease {
  @override
  final String sessionId;
  @override
  final int pid;
  final MacOSHelperPort port;
  Future<CoreProcessStopResult>? _stopOperation;
  bool _exited = false;

  MacOSHelperLease({
    required this.sessionId,
    required this.pid,
    required this.port,
  });

  @override
  CoreProcessOwner get owner => CoreProcessOwner.macosHelper;

  @override
  Future<CoreProcessStopResult> stop(Duration timeout) {
    if (_exited) {
      return Future.value(
        const CoreProcessStopResult(stopped: true, exitConfirmed: true),
      );
    }
    return _stopOperation ??= _stop(timeout).whenComplete(() {
      _stopOperation = null;
    });
  }

  Future<CoreProcessStopResult> _stop(Duration timeout) async {
    final result = await port.stop(sessionId: sessionId, timeout: timeout);
    _exited = result.exitConfirmed;
    return result;
  }
}
