import 'dart:async';
import 'dart:io';

import 'package:reclash/common/constant.dart';

import 'helper_client.dart';
import 'launcher.dart';
import 'linux_helper.dart';
import 'macos_helper.dart';
import 'model.dart';
import 'windows_launcher.dart';
import 'windows_service.dart';

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

/// What TUN still needs before a privileged Core can run, as the setup prompt
/// presents it.
enum DesktopPrivilegeSetup {
  notRequired,
  active,
  ready,
  install,
  update,
  approval,
  unavailable,
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

/// A start that failed on the privileged path, after which an unprivileged
/// Core is still worth starting; a cancelled start is the user's stop.
bool isPrivilegedLaunchFailure(Object error) {
  if (error is! DesktopCoreFailure ||
      error.phase != DesktopCorePhase.starting) {
    return false;
  }
  return switch (error.cause) {
    DesktopPrivilegeException(code: 'launch_cancelled') => false,
    WindowsLaunchException(:final cancelled) => !cancelled,
    DesktopPrivilegeException() ||
    HelperException() ||
    MacOSHelperException() => true,
    _ =>
      error.code == 'authorization_timeout' ||
          isPrivilegedCoreOwner(error.owner),
  };
}

/// Without a usable grant the Core runs unprivileged and TUN stays off:
/// bootstrap, recovery and background re-applies never prompt and never leave
/// the app without a Core. Installing or updating the Linux Helper or the
/// Windows service needs its own one-shot grant, which only the setup prompt
/// gives.
final class DesktopPrivilegeCoordinator implements DesktopCoreLauncherResolver {
  final CoreProcessLauncher direct;
  final CoreProcessLauncher linux;
  final WindowsGuiElevation windows;
  final CoreProcessLauncher windowsService;
  final HelperReadinessProbe windowsServiceReady;
  final WindowsServiceInstaller? windowsInstaller;
  final MacOSHelperLauncher macos;
  final LinuxHelperInstaller linuxInstaller;
  final HelperReadinessProbe linuxReady;
  final HelperException? Function() readinessFailure;
  final String platform;
  final bool safeMode;
  final CoreProcessOwner? Function() currentOwner;
  bool _tunEnabled = false;
  bool _promptAllowed = false;
  bool _installAllowed = false;
  bool _suspended = false;
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
    required this.windowsService,
    required this.windowsServiceReady,
    this.windowsInstaller,
    HelperException? Function()? readinessFailure,
    String? platform,
    this.safeMode = safeModeBuild,
  }) : readinessFailure = readinessFailure ?? _noFailure,
       platform = platform ?? Platform.operatingSystem;

  static HelperException? _noFailure() => null;

  bool get _installs => platform == 'linux' || platform == 'windows';

  void configure({required bool tunEnabled, bool allowPrompt = false}) {
    _tunEnabled = tunEnabled && !safeMode;
    _promptAllowed = _tunEnabled && (_promptAllowed || allowPrompt);
    if (allowPrompt) _suspended = false;
    if (!_tunEnabled) {
      _promptAllowed = false;
      _installAllowed = false;
    }
  }

  /// The user confirmed installing or updating the Helper or service.
  void allowInstall() {
    if (safeMode) return;
    _installAllowed = true;
    _promptAllowed = true;
    _suspended = false;
  }

  void revokePrompt() {
    _promptAllowed = false;
    _installAllowed = false;
  }

  /// After a privileged launch failed, later starts stay unprivileged until an
  /// explicit grant, so a broken Helper cannot loop restart after restart.
  void suspend() {
    _suspended = true;
    _promptAllowed = false;
    _installAllowed = false;
  }

  Future<DesktopPrivilegeSetup> inspect({required bool tunEnabled}) async {
    if (safeMode || !tunEnabled) return DesktopPrivilegeSetup.notRequired;
    if (isPrivilegedCoreOwner(currentOwner())) {
      return DesktopPrivilegeSetup.active;
    }
    switch (platform) {
      case 'linux':
        if (!linuxInstaller.systemdAvailable) {
          return DesktopPrivilegeSetup.unavailable;
        }
        return _helperSetup(await linuxReady());
      case 'windows':
        try {
          if (await windows.isElevated()) return DesktopPrivilegeSetup.ready;
        } on WindowsLaunchException {
          return DesktopPrivilegeSetup.unavailable;
        }
        return _helperSetup(await windowsServiceReady());
      case 'macos':
        final readiness = await macos.port.readiness();
        _setMacOSReadiness(readiness);
        if (readiness.isReady) return DesktopPrivilegeSetup.ready;
        return switch (readiness.status) {
          MacOSHelperStatus.requiresApproval => DesktopPrivilegeSetup.approval,
          MacOSHelperStatus.notRegistered => DesktopPrivilegeSetup.install,
          _ => DesktopPrivilegeSetup.unavailable,
        };
      default:
        return DesktopPrivilegeSetup.unavailable;
    }
  }

  DesktopPrivilegeSetup _helperSetup(HelperReadiness readiness) =>
      switch (readiness) {
        HelperReadiness.ready => DesktopPrivilegeSetup.ready,
        HelperReadiness.manifestMissing => DesktopPrivilegeSetup.unavailable,
        HelperReadiness.notReady => switch (readinessFailure()?.code) {
          null || 'unreachable' => DesktopPrivilegeSetup.install,
          _ => DesktopPrivilegeSetup.update,
        },
      };

  Future<DesktopPrivilegeDecision> prepare({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) async {
    configure(tunEnabled: tunEnabled, allowPrompt: allowPrompt);
    if (!_tunEnabled) return DesktopPrivilegeDecision.notRequired;
    if (isPrivilegedCoreOwner(currentOwner())) {
      _promptAllowed = false;
      _installAllowed = false;
      status = DesktopPrivilegeStatus.active;
      code = null;
      return DesktopPrivilegeDecision.active;
    }
    if (_suspended) return DesktopPrivilegeDecision.authorizationRequired;
    if (await _readyWithoutPrompt() ||
        (_installs ? _installAllowed : _promptAllowed)) {
      return DesktopPrivilegeDecision.restartRequired;
    }
    return DesktopPrivilegeDecision.authorizationRequired;
  }

  Future<bool> _readyWithoutPrompt() async {
    switch (platform) {
      case 'linux':
        return _setHelperReadiness(await linuxReady());
      case 'macos':
        final readiness = await macos.port.readiness();
        _setMacOSReadiness(readiness);
        return readiness.isReady;
      case 'windows':
        try {
          if (await windows.isElevated()) return true;
        } on WindowsLaunchException {
          status = DesktopPrivilegeStatus.failed;
          code = 'windows_elevation_query_failed';
          return false;
        }
        return _setHelperReadiness(await windowsServiceReady());
      default:
        status = DesktopPrivilegeStatus.unsupported;
        code = 'privilege_unsupported';
        return false;
    }
  }

  bool _setHelperReadiness(HelperReadiness readiness) {
    status = readiness == HelperReadiness.ready
        ? DesktopPrivilegeStatus.ready
        : DesktopPrivilegeStatus.notRegistered;
    code = switch (readiness) {
      HelperReadiness.ready => null,
      HelperReadiness.manifestMissing => 'bundle_invalid',
      HelperReadiness.notReady => 'authorization_required',
    };
    return readiness == HelperReadiness.ready;
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
    final tunEnabled = _tunEnabled && !_suspended;
    final allowPrompt = _promptAllowed;
    final allowInstall = _installAllowed;
    _promptAllowed = false;
    _installAllowed = false;
    if (safeMode) return direct;
    if (platform == 'windows') {
      // An elevated GUI cannot start an unelevated Core, and the Core refuses
      // an elevated plain launch, so it always takes the managed launch.
      if (await windows.isElevated()) return windows.launcher;
      if (!tunEnabled) return direct;
      return _PreparedCoreLauncher((isCancelled) async {
        if (_setHelperReadiness(await windowsServiceReady())) {
          return windowsService;
        }
        final installer = windowsInstaller;
        if (!allowInstall || installer == null) return direct;
        if (isCancelled()) {
          throw const DesktopPrivilegeException('launch_cancelled');
        }
        final result = await installer.install();
        if (result != WindowsServiceInstallResult.ready &&
            result != WindowsServiceInstallResult.installed) {
          status = DesktopPrivilegeStatus.failed;
          code = 'windows_${result.name}';
          throw DesktopPrivilegeException(
            code!,
            detail: installer.lastDiagnostic,
          );
        }
        status = DesktopPrivilegeStatus.ready;
        code = null;
        return windowsService;
      });
    }
    if (!tunEnabled) return direct;
    return _PreparedCoreLauncher((isCancelled) async {
      switch (platform) {
        case 'linux':
          if (_setHelperReadiness(await linuxReady())) return linux;
          if (!allowInstall) return direct;
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
            _setMacOSReadiness(readiness);
            if (!readiness.isReady) {
              throw DesktopPrivilegeException(
                code ?? 'macos_authorization_required',
                detail: readiness.detail,
              );
            }
          }
          _setMacOSReadiness(readiness);
          return readiness.isReady ? macos : direct;
        default:
          return direct;
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
