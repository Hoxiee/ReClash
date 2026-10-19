import 'dart:async';

import 'package:reclash/common/path.dart';
import 'package:rust_api/rust_api.dart' as native;

import 'core_manifest.dart';
import 'launcher.dart';
import 'model.dart';

abstract interface class WindowsCorePort {
  Future<bool> isElevated();
  void prepare(String sessionId);
  Stream<List<String>> launch({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  });
  bool cancel(String sessionId);
  Future<bool> stop(String sessionId, Duration timeout);
}

final class NativeWindowsCorePort implements WindowsCorePort {
  const NativeWindowsCorePort();

  @override
  Future<bool> isElevated() => native.windowsIsElevated();

  @override
  void prepare(String sessionId) {
    try {
      native.prepareWindowsCoreLaunch(sessionId: sessionId);
    } catch (error) {
      throw WindowsLaunchException(error.toString());
    }
  }

  @override
  Stream<List<String>> launch({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  }) => native
      .launchWindowsCore(
        sessionId: sessionId,
        address: address,
        homeDir: homeDir,
        expectedSha256: coreSha256,
      )
      .handleError((Object error) {
        throw WindowsLaunchException(error.toString());
      });

  @override
  bool cancel(String sessionId) =>
      native.cancelWindowsCoreLaunch(sessionId: sessionId);

  @override
  Future<bool> stop(String sessionId, Duration timeout) =>
      native.stopWindowsCore(
        sessionId: sessionId,
        timeoutMillis: timeout.inMilliseconds.clamp(0, 0xfffffffe),
      );
}

final class WindowsLauncherResolver implements DesktopCoreLauncherResolver {
  final CoreProcessLauncher direct;
  final WindowsCoreLauncher elevated;
  bool elevationRequired = false;
  bool promptAllowed = false;

  WindowsLauncherResolver({required this.direct, required this.elevated});

  @override
  Future<CoreProcessLauncher> resolve() async {
    final allowPrompt = promptAllowed;
    promptAllowed = false;
    final bool guiElevated;
    try {
      guiElevated = await elevated.port.isElevated();
    } catch (error) {
      throw WindowsLaunchException('windows_elevation_query_failed: $error');
    }
    if (!elevationRequired && !guiElevated) return direct;
    if (!guiElevated && !allowPrompt) {
      throw const WindowsLaunchException('windows_authorization_required');
    }
    return elevated;
  }
}

final class WindowsCoreLauncher implements CancellableCoreProcessLauncher {
  final WindowsCorePort port;
  final Future<String?> Function() readCoreSha256;
  final Future<String> Function() homeDirectory;

  WindowsCoreLauncher({
    this.port = const NativeWindowsCorePort(),
    Future<String?> Function()? readCoreSha256,
    Future<String> Function()? homeDirectory,
  }) : readCoreSha256 = readCoreSha256 ?? CoreManifest.readCoreSha256,
       homeDirectory = homeDirectory ?? (() => appPath.homeDirPath);

  @override
  CoreLaunchAttempt begin({
    required String sessionId,
    required String address,
  }) => _WindowsLaunchAttempt(this, sessionId, address);

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) => begin(sessionId: sessionId, address: address).result;
}

final class WindowsLaunchException implements Exception {
  final String detail;

  const WindowsLaunchException(this.detail);

  bool get cancelled => detail.contains('windows_launch_cancelled');
  bool get pending => detail.contains('windows_launch_pending');

  @override
  String toString() => detail;
}

final class _WindowsLaunchAttempt implements CoreLaunchAttempt {
  final WindowsCoreLauncher launcher;
  @override
  final String sessionId;
  final String address;
  final Completer<void> _spawned = Completer<void>();
  final Completer<void> _settled = Completer<void>();
  final Completer<CoreProcessLease> _result = Completer<CoreProcessLease>();
  StreamSubscription<List<String>>? _subscription;
  WindowsCoreLease? _lease;
  bool _cancelled = false;
  bool _prepared = false;
  bool _finished = false;
  bool _ready = false;

  _WindowsLaunchAttempt(this.launcher, this.sessionId, this.address) {
    _result.future.ignore();
    _spawned.future.ignore();
    unawaited(_launch());
  }

  @override
  CoreProcessLease? get lease => _lease;
  @override
  Future<void> get spawned => _spawned.future;
  @override
  Future<void> get settled => _settled.future;
  @override
  bool get isSettled => _settled.isCompleted;
  @override
  Future<CoreProcessLease> get result => _result.future;

  Future<void> _launch() async {
    try {
      final hash = await launcher.readCoreSha256();
      if (_cancelled) return _finish();
      if (hash == null || !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
        throw const WindowsLaunchException('windows_core_manifest_missing');
      }
      final home = await launcher.homeDirectory();
      if (_cancelled) return _finish();
      launcher.port.prepare(sessionId);
      _prepared = true;
      _subscription = launcher.port
          .launch(
            sessionId: sessionId,
            address: address,
            homeDir: home,
            coreSha256: hash,
          )
          .listen(
            _event,
            onError: (Object error, StackTrace stack) => _abort(error, stack),
            onDone: () {
              if (!_finished) {
                _abort(
                  const WindowsLaunchException('windows_launch_stream_closed'),
                );
              }
            },
          );
      if (_finished) _cancelSubscription();
    } catch (error, stack) {
      _abort(error, stack);
    }
  }

  void _event(List<String> event) {
    if (_finished) return;
    try {
      if (event.length != 2) {
        throw const FormatException('Invalid Windows launch event');
      }
      switch (event[0]) {
        case 'spawned':
          final pid = int.parse(event[1]);
          if (pid <= 0 || pid > 0xffffffff || _lease != null) {
            throw const FormatException('Invalid Windows Core PID');
          }
          _lease = WindowsCoreLease(
            sessionId: sessionId,
            pid: pid,
            port: launcher.port,
            onExited: _finish,
          );
          if (!_spawned.isCompleted) _spawned.complete();
          if (_cancelled) cancel();
        case 'ready':
          final lease = _lease;
          if (_ready || lease == null || lease.pid.toString() != event[1]) {
            throw const FormatException('Windows Core ready PID mismatch');
          }
          _ready = true;
          if (_cancelled) {
            cancel();
          } else {
            if (!_result.isCompleted) _result.complete(lease);
            if (!_settled.isCompleted) _settled.complete();
          }
        case 'error':
          _abort(WindowsLaunchException(event[1]));
        case 'exited':
          _lease?.exited = true;
          _finish();
        default:
          throw const FormatException('Unknown Windows launch event');
      }
    } catch (error, stack) {
      _abort(error, stack);
    }
  }

  void _abort(Object error, [StackTrace? stack]) {
    _fail(error, stack);
    try {
      cancel();
    } catch (_) {
      // Native ownership remains until a later cancellation or stop confirms exit.
    }
  }

  void _fail(Object error, [StackTrace? stack]) {
    if (!_result.isCompleted) _result.completeError(error, stack);
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    final error = WindowsLaunchException(
      _cancelled
          ? 'windows_launch_cancelled'
          : 'windows_core_exited_before_ready',
    );
    if (!_result.isCompleted) _fail(error);
    if (!_spawned.isCompleted) _spawned.completeError(error);
    if (!_settled.isCompleted) _settled.complete();
    _cancelSubscription();
  }

  void _cancelSubscription() {
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel().catchError((Object _) {}));
    }
  }

  @override
  void cancel() {
    if (_finished) return;
    _cancelled = true;
    if (!_prepared || launcher.port.cancel(sessionId)) {
      _lease?.exited = true;
      _finish();
    }
  }
}

final class WindowsCoreLease implements CoreProcessLease {
  @override
  final String sessionId;
  @override
  final int pid;
  final WindowsCorePort port;
  final void Function() onExited;
  bool exited = false;
  Future<CoreProcessStopResult>? _stopOperation;

  WindowsCoreLease({
    required this.sessionId,
    required this.pid,
    required this.port,
    required this.onExited,
  });

  @override
  CoreProcessOwner get owner => CoreProcessOwner.windowsElevated;

  @override
  Future<CoreProcessStopResult> stop(Duration timeout) => _stopOperation ??=
      _stop(timeout).whenComplete(() => _stopOperation = null);

  Future<CoreProcessStopResult> _stop(Duration timeout) async {
    if (!exited) {
      try {
        exited = port.cancel(sessionId);
      } catch (_) {
        exited = false;
      }
      if (!exited) exited = await port.stop(sessionId, timeout);
    }
    if (exited) onExited();
    return CoreProcessStopResult(stopped: true, exitConfirmed: exited);
  }
}
