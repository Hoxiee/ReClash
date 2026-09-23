import 'dart:async';

import 'package:reclash/common/util/constant.dart';
import 'package:reclash/common/desktop/system.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/core.dart';
import 'package:flutter/foundation.dart';

import 'desktop/helper_client.dart';
import 'desktop/launcher.dart';
import 'desktop/lifecycle.dart';
import 'desktop/model.dart';
import 'desktop/rpc_client.dart';
import 'desktop/transport.dart';
import 'event.dart';
import 'interface.dart';
import 'method.dart';

class CoreService extends CoreHandlerInterface {
  static CoreService? _instance;

  final DesktopCoreLifecycleController _lifecycle;
  final CoreRpcChannel _rpcClient;
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

    final lifecycle = DesktopCoreLifecycle(
      transportFactory: () => IPCCoreTransport(address: address),
      launcherResolver: HelperLauncherResolver(
        hasHelper: system.hasHelperService,
        directLauncher: directLauncher,
        helperLauncher: HelperLauncher(helperClient),
        helperReady: () => helperClient.readiness(),
      ),
      verifyPeerPid: system.isWindows || system.isLinux,
    );
    return CoreService._(
      lifecycle: lifecycle,
      rpcClient: CoreRpcClient(lifecycle.transport),
    );
  }

  @visibleForTesting
  CoreService.forTesting({
    required DesktopCoreLifecycleController lifecycle,
    required CoreRpcChannel rpcClient,
  }) : this._(lifecycle: lifecycle, rpcClient: rpcClient);

  CoreService._({
    required DesktopCoreLifecycleController lifecycle,
    required CoreRpcChannel rpcClient,
  }) : _lifecycle = lifecycle,
       _rpcClient = rpcClient {
    _lifecycle.setRecoveryHandler(_recover);
    _crashSubscription = _lifecycle.crashEvents.listen((failure) {
      coreEventManager.sendEvent(
        CoreEvent(
          type: CoreEventType.crash,
          data: failure.cause?.toString() ?? 'core done',
        ),
      );
    });
  }

  Future<void> _recover(bool Function() isCurrent) async {
    final handler = _recoveryHandler;
    if (handler == null) {
      throw StateError('Desktop Core recovery handler is not configured');
    }
    await handler(isCurrent);
  }

  Future<void> Function(bool Function() isCurrent)? _recoveryHandler;

  @override
  void setRecoveryHandler(
    Future<void> Function(bool Function() isCurrent)? handler,
  ) {
    _recoveryHandler = handler;
  }

  @override
  CoreProcessOwner? get processOwner => switch (_lifecycle.state) {
    DesktopCoreRunning(:final session) => session.owner,
    _ => null,
  };

  @override
  Future<CoreLifecycleResult> start() => _lifecycle.start();

  @override
  Future<CoreLifecycleResult> restart() => _lifecycle.restart();

  @override
  Future<CoreLifecycleResult> stop() => _lifecycle.stop();

  @override
  Future<CoreLifecycleResult> close() {
    return _closeOperation ??= _close();
  }

  Future<CoreLifecycleResult> _close() async {
    try {
      return await _lifecycle.close();
    } finally {
      _lifecycle.setRecoveryHandler(null);
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
    return _rpcClient.invoke<T>(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
  }
}

final coreService = system.isDesktop ? CoreService() : null;
