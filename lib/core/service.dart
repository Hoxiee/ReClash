import 'dart:async';

import 'package:reclash/common/constant.dart';
import 'package:reclash/common/path.dart';
import 'package:reclash/common/system.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/core.dart';
import 'package:flutter/foundation.dart';

import 'desktop/helper_client.dart';
import 'desktop/launcher.dart';
import 'desktop/lifecycle.dart';
import 'desktop/model.dart';
import 'desktop/privilege.dart';
import 'desktop/linux_helper.dart';
import 'desktop/macos_helper.dart';
import 'desktop/windows_launcher.dart';
import 'desktop/windows_service.dart';
import 'desktop/rpc_client.dart';
import 'desktop/transport.dart';
import 'event.dart';
import 'interface.dart';
import 'method.dart';

class CoreService extends CoreHandlerInterface {
  static CoreService? _instance;

  final DesktopCoreLifecycleController _lifecycle;
  final CoreRpcChannel _rpcClient;
  final DesktopPrivilegeCoordinator? _privileges;
  late final StreamSubscription<DesktopCoreFailure> _crashSubscription;
  Future<CoreLifecycleResult>? _closeOperation;

  factory CoreService() {
    return _instance ??= CoreService._create();
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory CoreService._create() {
    final address = system.isWindows ? windowsPipeName : unixSocketPath;
    final directLauncher = DirectCoreLauncher();

    late final DesktopCoreLifecycle lifecycle;
    Future<HelperReadiness> serviceReady() =>
        helperClient.readiness(logFailure: false);
    final privileges = DesktopPrivilegeCoordinator(
      direct: directLauncher,
      linux: HelperLauncher(helperClient),
      windows: WindowsGuiElevation(WindowsCoreLauncher()),
      windowsService: HelperLauncher(
        helperClient,
        homeDirectory: () => appPath.homeDirPath,
      ),
      windowsServiceReady: serviceReady,
      windowsInstaller: system.isWindows
          ? WindowsServiceInstaller(readiness: serviceReady)
          : null,
      macos: MacOSHelperLauncher(),
      linuxInstaller: LinuxHelperInstaller(),
      linuxReady: serviceReady,
      readinessFailure: () => helperClient.readinessFailure,
      currentOwner: () => switch (lifecycle.state) {
        DesktopCoreRunning(:final session) => session.owner,
        _ => null,
      },
    );
    lifecycle = DesktopCoreLifecycle(
      transportFactory: () => IpcCoreTransport(address: address),
      launcherResolver: privileges,
      verifyPeerPid: true,
    );
    return CoreService._(
      lifecycle: lifecycle,
      rpcClient: CoreRpcClient(lifecycle.transport),
      privileges: privileges,
    );
  }

  @visibleForTesting
  CoreService.forTesting({
    required DesktopCoreLifecycleController lifecycle,
    required CoreRpcChannel rpcClient,
    DesktopPrivilegeCoordinator? privileges,
  }) : this._(
         lifecycle: lifecycle,
         rpcClient: rpcClient,
         privileges: privileges,
       );

  CoreService._({
    required DesktopCoreLifecycleController lifecycle,
    required CoreRpcChannel rpcClient,
    DesktopPrivilegeCoordinator? privileges,
  }) : _privileges = privileges,
       _lifecycle = lifecycle,
       _rpcClient = rpcClient {
    _crashSubscription = _lifecycle.crashEvents.listen((failure) {
      coreEventManager.sendEvent(
        CoreEvent(
          type: CoreEventType.crash,
          data: failure.cause?.toString() ?? 'core done',
        ),
      );
    });
  }

  @override
  CoreProcessOwner? get processOwner => switch (_lifecycle.state) {
    DesktopCoreRunning(:final session) => session.owner,
    DesktopCoreStopping(:final session) => session.owner,
    _ => null,
  };

  @override
  void configurePrivilege({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) {
    _privileges?.configure(tunEnabled: tunEnabled, allowPrompt: allowPrompt);
  }

  @override
  void revokePrivilegePrompt() => _privileges?.revokePrompt();

  @override
  void allowPrivilegeInstall() => _privileges?.allowInstall();

  @override
  void suspendPrivilege() => _privileges?.suspend();

  @override
  Future<DesktopPrivilegeSetup> inspectPrivilege({
    required bool tunEnabled,
  }) async =>
      await _privileges?.inspect(tunEnabled: tunEnabled) ??
      DesktopPrivilegeSetup.notRequired;

  @override
  Future<DesktopPrivilegeDecision> preparePrivilege({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) async =>
      await _privileges?.prepare(
        tunEnabled: tunEnabled,
        allowPrompt: allowPrompt,
      ) ??
      DesktopPrivilegeDecision.notRequired;

  @override
  Future<CoreLifecycleResult> start() => _lifecycle.start();

  @override
  Future<CoreLifecycleResult> restart() => _lifecycle.restart();

  @override
  Future<CoreLifecycleResult> stop() => _lifecycle.stop();

  @override
  Future<CoreLifecycleResult> close() {
    revokePrivilegePrompt();
    return _closeOperation ??= _close();
  }

  Future<CoreLifecycleResult> _close() async {
    try {
      return await _lifecycle.close();
    } finally {
      await _rpcClient.close();
      await _crashSubscription.cancel();
    }
  }

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) {
    // No Core will connect until a new start, so a call would only sit out
    // its connect window and answer null anyway.
    if (_lifecycle.state case DesktopCoreFailed() || DesktopCoreClosed()) {
      return Future.value();
    }
    return _rpcClient.invoke<T>(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
  }
}

final coreService = system.isDesktop ? CoreService() : null;
