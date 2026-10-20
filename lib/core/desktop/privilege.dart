import 'dart:async';
import 'dart:io';

import 'package:reclash/common/constant.dart';

import 'helper_client.dart';
import 'launcher.dart';
import 'linux_helper.dart';
import 'macos_helper.dart';
import 'model.dart';
import 'windows_launcher.dart';

enum DesktopPrivilegeDecision {
  notRequired,
  active,
  restartRequired,
  authorizationRequired,
}

enum DesktopPrivilegeStatus {
  unsupported,
  notRegistered,
  requiresApproval,
  ready,
  active,
  failed,
}

final class DesktopPrivilegeException implements Exception {
  final String code;
  final String? detail;

  const DesktopPrivilegeException(this.code, {this.detail});

  @override
  String toString() => 'DesktopPrivilegeException($code, $detail)';
}

bool isPrivilegedCoreOwner(CoreProcessOwner? owner) => switch (owner) {
  CoreProcessOwner.helper ||
  CoreProcessOwner.windowsElevated ||
  CoreProcessOwner.macosHelper => true,
  _ => false,
};

final class DesktopPrivilegeCoordinator implements DesktopCoreLauncherResolver {
  final CoreProcessLauncher direct;
  final CoreProcessLauncher linux;
  final WindowsLauncherResolver windows;
  final MacOSHelperLauncher macos;
  final LinuxHelperInstaller linuxInstaller;
  final HelperReadinessProbe linuxReady;
  final String platform;
  final bool safeMode;
  final CoreProcessOwner? Function() currentOwner;
  bool _tunEnabled = false;
  bool _promptAllowed = false;
  DesktopPrivilegeStatus status = DesktopPrivilegeStatus.notRegistered;
  String? code;

  DesktopPrivilegeCoordinator({
    required this.direct,
    required this.linux,
    required this.windows,
    required this.macos,
    required this.linuxInstaller,
    required this.linuxReady,
    required this.currentOwner,
    String? platform,
    this.safeMode = safeModeBuild,
  }) : platform = platform ?? Platform.operatingSystem;

  void configure({required bool tunEnabled, bool allowPrompt = false}) {
    _tunEnabled = tunEnabled && !safeMode;
    _promptAllowed = _tunEnabled && (_promptAllowed || allowPrompt);
    if (!_tunEnabled) _promptAllowed = false;
  }

  void revokePrompt() {
    _promptAllowed = false;
  }

  Future<DesktopPrivilegeDecision> prepare({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) async {
    configure(tunEnabled: tunEnabled, allowPrompt: allowPrompt);
    if (!_tunEnabled) return DesktopPrivilegeDecision.notRequired;
    if (isPrivilegedCoreOwner(currentOwner())) {
      _promptAllowed = false;
      status = DesktopPrivilegeStatus.active;
      code = null;
      return DesktopPrivilegeDecision.active;
    }
    if (_promptAllowed || await _readyWithoutPrompt()) {
      return DesktopPrivilegeDecision.restartRequired;
    }
    return DesktopPrivilegeDecision.authorizationRequired;
  }

  Future<bool> _readyWithoutPrompt() async {
    switch (platform) {
      case 'linux':
        final readiness = await linuxReady();
        status = readiness == HelperReadiness.ready
            ? DesktopPrivilegeStatus.ready
            : DesktopPrivilegeStatus.notRegistered;
        code = readiness == HelperReadiness.manifestMissing
            ? 'bundle_invalid'
            : 'authorization_required';
        return readiness == HelperReadiness.ready;
      case 'macos':
        final readiness = await macos.port.readiness();
        _setMacOSReadiness(readiness);
        return readiness.isReady;
      case 'windows':
        status = DesktopPrivilegeStatus.notRegistered;
        code = 'windows_authorization_required';
        return false;
      default:
        status = DesktopPrivilegeStatus.unsupported;
        code = 'privilege_unsupported';
        return false;
    }
  }

  void _setMacOSReadiness(MacOSHelperReadiness readiness) {
    status = switch (readiness.status) {
      MacOSHelperStatus.enabled when readiness.isReady =>
        DesktopPrivilegeStatus.ready,
      MacOSHelperStatus.requiresApproval =>
        DesktopPrivilegeStatus.requiresApproval,
      MacOSHelperStatus.notRegistered => DesktopPrivilegeStatus.notRegistered,
      _ => DesktopPrivilegeStatus.failed,
    };
    code =
        readiness.code ??
        (readiness.isReady ? null : 'macos_authorization_required');
  }

  @override
  Future<CoreProcessLauncher> resolve() async {
    final tunEnabled = _tunEnabled;
    final allowPrompt = _promptAllowed;
    _promptAllowed = false;
    if (safeMode) return direct;
    if (platform == 'windows') {
      windows.elevationRequired = tunEnabled;
      windows.promptAllowed = allowPrompt;
      return windows.resolve();
    }
    if (!tunEnabled) return direct;
    return _PreparedCoreLauncher((isCancelled) async {
      switch (platform) {
        case 'linux':
          if (await linuxReady() != HelperReadiness.ready) {
            if (!allowPrompt) {
              throw const DesktopPrivilegeException('authorization_required');
            }
            if (isCancelled()) {
              throw const DesktopPrivilegeException('launch_cancelled');
            }
            final result = await linuxInstaller.install();
            if (result != LinuxHelperInstallResult.ready &&
                result != LinuxHelperInstallResult.installed) {
              status = DesktopPrivilegeStatus.failed;
              code = 'linux_${result.name}';
              throw DesktopPrivilegeException(
                code!,
                detail: linuxInstaller.lastDiagnostic,
              );
            }
          }
          status = DesktopPrivilegeStatus.ready;
          code = null;
          return linux;
        case 'macos':
          var readiness = await macos.port.readiness();
          if (!readiness.isReady && allowPrompt) {
            if (isCancelled()) {
              throw const DesktopPrivilegeException('launch_cancelled');
            }
            readiness = await macos.port.register();
          }
          _setMacOSReadiness(readiness);
          if (!readiness.isReady) {
            throw DesktopPrivilegeException(
              code ?? 'macos_authorization_required',
              detail: readiness.detail,
            );
          }
          return macos;
        default:
          throw const DesktopPrivilegeException('privilege_unsupported');
      }
    });
  }
}

final class _PreparedCoreLauncher implements CancellableCoreProcessLauncher {
  final Future<CoreProcessLauncher> Function(bool Function() isCancelled)
  prepare;

  const _PreparedCoreLauncher(this.prepare);

  @override
  CoreLaunchAttempt begin({
    required String sessionId,
    required String address,
  }) => _PreparedCoreAttempt(
    sessionId: sessionId,
    address: address,
    prepare: prepare,
  );

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) => begin(sessionId: sessionId, address: address).result;
}

final class _PreparedCoreAttempt implements CoreLaunchAttempt {
  @override
  final String sessionId;
  final String address;
  final Future<CoreProcessLauncher> Function(bool Function() isCancelled)
  prepare;
  final _spawned = Completer<void>();
  final _result = Completer<CoreProcessLease>();
  final _settled = Completer<void>();
  CoreLaunchAttempt? _delegate;
  CoreProcessLease? _lease;
  bool _cancelled = false;
  bool _released = false;

  _PreparedCoreAttempt({
    required this.sessionId,
    required this.address,
    required this.prepare,
  }) {
    _spawned.future.ignore();
    _result.future.ignore();
    unawaited(_run());
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
  CoreProcessLease? get lease => _released ? null : _lease ?? _delegate?.lease;

  @override
  void cancel() {
    _cancelled = true;
    _delegate?.cancel();
    _fail(
      const DesktopPrivilegeException('launch_cancelled'),
      StackTrace.current,
    );
  }

  void _fail(Object error, StackTrace stack) {
    if (!_spawned.isCompleted) _spawned.completeError(error, stack);
    if (!_result.isCompleted) _result.completeError(error, stack);
  }

  Future<void> _run() async {
    try {
      final launcher = await prepare(() => _cancelled);
      if (_cancelled) return;
      if (launcher is CancellableCoreProcessLauncher) {
        final attempt = launcher.begin(sessionId: sessionId, address: address);
        _delegate = attempt;
        unawaited(
          attempt.spawned.then((_) {
            if (!_spawned.isCompleted) _spawned.complete();
          }, onError: (Object error, StackTrace stack) => _fail(error, stack)),
        );
        _lease = await attempt.result;
      } else {
        _lease = await launcher.start(sessionId: sessionId, address: address);
        if (!_spawned.isCompleted) _spawned.complete();
      }
      if (_cancelled) {
        _delegate?.cancel();
        final result = await _lease!.stop(const Duration(seconds: 10));
        _released = result.exitConfirmed;
      } else if (!_result.isCompleted) {
        _result.complete(_lease);
      }
    } catch (error, stack) {
      _fail(error, stack);
    } finally {
      try {
        await _delegate?.settled;
      } finally {
        _settled.complete();
      }
    }
  }
}
