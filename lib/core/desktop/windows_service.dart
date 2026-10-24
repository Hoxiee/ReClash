import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:reclash/common/path.dart';
import 'package:reclash/common/print.dart';
import 'package:reclash/enum/enum.dart';
import 'package:win32/win32.dart' as win32;

import 'helper_client.dart';

enum WindowsServiceInstallResult {
  ready,
  installed,
  cancelled,
  bundleInvalid,
  serviceFailed,
  ownerInvalid,
  installBusy,
  notReady,
  failed,
}

/// Runs [executable] elevated and waits for it: the exit code, or null when
/// the user declined the UAC prompt.
typedef WindowsElevatedRunner =
    Future<int?> Function(String executable, String arguments);

final class WindowsServiceInstaller {
  final HelperReadinessProbe _readiness;
  final WindowsElevatedRunner _runElevated;
  final String Function() _servicePath;
  final int Function() _ownerPid;
  final Duration readyTimeout;
  Future<WindowsServiceInstallResult>? _operation;
  String? _lastDiagnostic;

  String? get lastDiagnostic => _lastDiagnostic;

  WindowsServiceInstaller({
    required HelperReadinessProbe readiness,
    WindowsElevatedRunner? runElevated,
    String Function()? servicePath,
    int Function()? ownerPid,
    this.readyTimeout = const Duration(seconds: 15),
  }) : _readiness = readiness,
       _runElevated = runElevated ?? runWindowsElevated,
       _servicePath = servicePath ?? (() => appPath.helperPath),
       _ownerPid = ownerPid ?? (() => pid);

  Future<WindowsServiceInstallResult> install() {
    final current = _operation;
    if (current != null) return current;
    final operation = _install();
    _operation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_operation, operation)) _operation = null;
      }),
    );
    return operation;
  }

  Future<WindowsServiceInstallResult> _install() async {
    _lastDiagnostic = null;
    if (await _readiness() == HelperReadiness.ready) {
      return WindowsServiceInstallResult.ready;
    }
    final int? exitCode;
    try {
      exitCode = await _runElevated(
        _servicePath(),
        'install --owner-pid ${_ownerPid()}',
      );
    } on Object catch (error) {
      _record('Elevated service installation could not start: $error');
      return WindowsServiceInstallResult.failed;
    }
    if (exitCode == null) return WindowsServiceInstallResult.cancelled;
    if (exitCode != 0) {
      _record('Service installation exited with $exitCode');
      return switch (exitCode) {
        2 => WindowsServiceInstallResult.bundleInvalid,
        3 => WindowsServiceInstallResult.serviceFailed,
        4 => WindowsServiceInstallResult.ownerInvalid,
        5 => WindowsServiceInstallResult.installBusy,
        _ => WindowsServiceInstallResult.failed,
      };
    }
    final deadline = DateTime.now().add(readyTimeout);
    do {
      if (await _readiness() == HelperReadiness.ready) {
        return WindowsServiceInstallResult.installed;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    } while (DateTime.now().isBefore(deadline));
    _record('The service did not answer after installation');
    return WindowsServiceInstallResult.notReady;
  }

  void _record(String message) {
    _lastDiagnostic = message;
    commonPrint.log('Windows service: $message', logLevel: LogLevel.error);
  }
}

/// The wait lasts as long as the UAC prompt stays open, so it runs off the UI
/// isolate.
Future<int?> runWindowsElevated(String executable, String arguments) =>
    Isolate.run(() => _runElevated(executable, arguments));

const _seeMaskNoCloseProcess = 0x00000040;
const _seeMaskNoAsync = 0x00000100;

int? _runElevated(String executable, String arguments) {
  final initialized = win32.CoInitializeEx(
    win32.COINIT_APARTMENTTHREADED | win32.COINIT_DISABLE_OLE1DDE,
  );
  final arena = Arena();
  try {
    final info = arena<win32.SHELLEXECUTEINFO>();
    info.ref
      ..cbSize = sizeOf<win32.SHELLEXECUTEINFO>()
      ..fMask = _seeMaskNoCloseProcess | _seeMaskNoAsync
      ..lpVerb = win32.PWSTR('runas'.toNativeUtf16(allocator: arena))
      ..lpFile = win32.PWSTR(executable.toNativeUtf16(allocator: arena))
      ..lpParameters = win32.PWSTR(arguments.toNativeUtf16(allocator: arena))
      ..nShow = win32.SW_HIDE;
    final launched = win32.ShellExecuteEx(info);
    if (!launched.value) {
      if (launched.error == win32.ERROR_CANCELLED) return null;
      throw OSError('ShellExecuteEx failed', launched.error);
    }
    final process = info.ref.hProcess;
    try {
      win32.WaitForSingleObject(process, win32.INFINITE);
      final code = arena<Uint32>();
      final read = win32.GetExitCodeProcess(process, code);
      if (!read.value) {
        throw OSError('GetExitCodeProcess failed', read.error);
      }
      return code.value;
    } finally {
      win32.CloseHandle(process);
    }
  } finally {
    arena.releaseAll();
    if (win32.SUCCEEDED(initialized)) win32.CoUninitialize();
  }
}
