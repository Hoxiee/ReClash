import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/plugins/service.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'desktop/model.dart';
import 'interface.dart';
import 'method.dart';
import 'spill.dart';

class CoreLib extends CoreHandlerInterface {
  static CoreLib? _instance;

  final Service? _service;
  final _lifecycleScheduler = SerialTaskScheduler();

  Completer<bool> _connectedCompleter = Completer<bool>();
  Future<CoreLifecycleResult>? _closeOperation;
  int _lifecycleRevision = 0;
  int _connectionGeneration = 0;
  int _methodCallId = 0;
  bool _initialized = false;
  bool _closed = false;

  CoreLib._internal() : _service = service;

  @visibleForTesting
  CoreLib.scoped(Service this._service);

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory CoreLib() {
    _instance ??= CoreLib._internal();
    return _instance!;
  }

  @override
  Future<CoreLifecycleResult> start() async {
    if (_closed) {
      throw StateError('Core lifecycle is closed');
    }
    final revision = ++_lifecycleRevision;
    final generation = _connectionGeneration;
    return _lifecycleScheduler.run(() => _start(revision, generation));
  }

  bool _isCurrent(int generation) =>
      !_closed && generation == _connectionGeneration;

  CoreLifecycleResult _superseded(int revision) => CoreLifecycleResult(
    revision: revision,
    outcome: CoreLifecycleOutcome.superseded,
  );

  Future<CoreLifecycleResult> _start(int revision, int generation) async {
    if (!_isCurrent(generation)) return _superseded(revision);
    if (_connectedCompleter.isCompleted) {
      return CoreLifecycleResult(
        revision: revision,
        outcome: CoreLifecycleOutcome.coalesced,
      );
    }
    await _shutdown();
    if (!_isCurrent(generation)) return _superseded(revision);
    final initializationError = await _service?.init() ?? '';
    if (initializationError.isNotEmpty) {
      if (_isCurrent(generation)) _resetConnection();
      throw StateError(initializationError);
    }
    _initialized = true;
    try {
      if (!_isCurrent(generation)) return _superseded(revision);
      await globalState.container.read(vpnOptionsProvider.future);
      if (!_isCurrent(generation)) return _superseded(revision);
      final syncError =
          await _service?.syncState(
            globalState.container.read(sharedStateProvider),
          ) ??
          '';
      if (syncError.isNotEmpty) throw StateError(syncError);
      if (!_isCurrent(generation)) return _superseded(revision);
      _connectedCompleter.complete(true);
      return CoreLifecycleResult(
        revision: revision,
        outcome: CoreLifecycleOutcome.applied,
      );
    } catch (_) {
      if (_isCurrent(generation)) _resetConnection();
      await _shutdown();
      rethrow;
    }
  }

  @override
  Future<CoreLifecycleResult> restart() async {
    if (_closed) throw StateError('Core lifecycle is closed');
    final revision = ++_lifecycleRevision;
    final generation = ++_connectionGeneration;
    _resetConnection();
    return _lifecycleScheduler.run(() => _start(revision, generation));
  }

  @override
  Future<CoreLifecycleResult> stop() => _stop();

  Future<CoreLifecycleResult> _stop({bool allowClosed = false}) async {
    if (_closed && !allowClosed) {
      throw StateError('Core lifecycle is closed');
    }
    final revision = ++_lifecycleRevision;
    _connectionGeneration++;
    _resetConnection();
    return _lifecycleScheduler.run(() async {
      final initialized = _initialized;
      await _shutdown();
      return CoreLifecycleResult(
        revision: revision,
        outcome: revision != _lifecycleRevision
            ? CoreLifecycleOutcome.superseded
            : initialized
            ? CoreLifecycleOutcome.applied
            : CoreLifecycleOutcome.coalesced,
      );
    });
  }

  void _resetConnection() {
    if (!_connectedCompleter.isCompleted) _connectedCompleter.complete(false);
    _connectedCompleter = Completer<bool>();
  }

  Future<void> _shutdown() async {
    if (!_initialized) return;
    final stopped = await _service?.shutdown() ?? true;
    if (!stopped) {
      throw StateError('Android Core service shutdown failed');
    }
    _initialized = false;
  }

  @override
  Future<CoreLifecycleResult> close() {
    return _closeOperation ??= _close();
  }

  Future<CoreLifecycleResult> _close() async {
    _closed = true;
    return _stop(allowClosed: true);
  }

  // Native service transitions own the Core listeners. Separate RPCs here
  // could arrive after a newer service command and reverse its intent.
  @override
  Future<bool> startListener() async {
    if (_closed) return false;
    return await _service?.start() ?? false;
  }

  @override
  Future<bool> stopListener() async {
    if (_closed) return false;
    return await _service?.stop() ?? false;
  }

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) {
    final call = _invokeMethod<T>(method: method, arguments: arguments);
    return call.withTimeout(
      timeout: timeout,
      onTimeout: () {
        unawaited(call.then(discardSpilledFile, onError: (_) {}));
        return null;
      },
    );
  }

  Future<T?> _invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
  }) async {
    if (_closed) return null;
    final connection = _connectedCompleter;
    try {
      final connected = await connection.future.timeout(
        coreConnectionWaitDuration,
      );
      if (!connected ||
          _closed ||
          !identical(connection, _connectedCompleter)) {
        return null;
      }
    } catch (error) {
      commonPrint.log(
        'Invoke method ${method.name} before connection timed out: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
    final id = '${++_methodCallId}';
    final response = await _service?.invokeMethod(
      CoreMethodCall(id: id, method: method, arguments: arguments),
    );
    if (response == null) {
      return null;
    }
    return response.unwrap<T>();
  }
}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
