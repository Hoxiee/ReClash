import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reclash/common/preferences.dart';

import 'client.dart';
import 'models.dart';

abstract interface class LovenseEndpointStore {
  Future<String?> load();
  Future<bool> save(String address);
}

class LovensePreferences implements LovenseEndpointStore {
  @override
  Future<String?> load() => preferences.getLovenseEndpoint();

  @override
  Future<bool> save(String address) => preferences.saveLovenseEndpoint(address);
}

enum LovenseNotice { commandSent, stopSent }

typedef LovenseClientFactory = LovenseApi Function(LovenseEndpoint endpoint);

class LovenseController extends ChangeNotifier {
  LovenseController({
    LovenseClientFactory? clientFactory,
    LovenseEndpointStore? store,
    Future<bool> Function()? requestPermission,
    DateTime Function()? now,
  }) : _clientFactory = clientFactory ?? LovenseClient.new,
       _store = store ?? LovensePreferences(),
       _requestPermission = requestPermission,
       _now = now ?? DateTime.now;

  final LovenseClientFactory _clientFactory;
  final LovenseEndpointStore _store;
  final Future<bool> Function()? _requestPermission;
  final DateTime Function() _now;
  final Set<String> _startedIds = {};
  final Set<String> _reactionIds = {};
  final Map<String, DateTime> _manualUntil = {};
  LovenseApi? _client;
  int _connectionGeneration = 0;
  int _controlGeneration = 0;
  bool _disposed = false;
  bool _closing = false;
  Future<void>? _stopInProgress;
  Future<void> _shutdown = Future.value();

  LovenseEndpoint? endpoint;
  List<LovenseToy> toys = const [];
  LovenseError? error;
  LovenseNotice? notice;
  int lastDuration = 10;
  bool busy = false;
  bool stopping = false;
  bool paused = false;
  bool saveFailed = false;
  bool stopFailed = false;

  bool get connected => _client != null;
  bool get canStart =>
      connected && !busy && !stopping && !paused && !_closing && !_disposed;
  Future<void> get shutdown => _shutdown;

  /// A manual command owns its toy until it ends or is stopped; reactions
  /// skip the toy meanwhile.
  bool manualActive(String toyId) {
    final until = _manualUntil[toyId];
    return until != null && _now().isBefore(until);
  }

  Future<String> restoreAddress() async {
    try {
      final saved = await _store.load();
      if (saved != null) return LovenseEndpoint.parse(saved).displayAddress;
    } catch (_) {
      // A corrupt saved address falls back to the default without a request.
    }
    return lovenseDefaultAddress;
  }

  Future<void> connect(String address) async {
    if (_disposed || _closing || busy || connected) return;
    final generation = ++_connectionGeneration;
    busy = true;
    error = null;
    notice = null;
    saveFailed = false;
    stopFailed = false;
    _notify();
    LovenseApi? client;
    try {
      final target = LovenseEndpoint.parse(address);
      if (!(await _requestPermission?.call() ?? true)) {
        throw LovenseError(LovenseErrorKind.unavailable);
      }
      if (_disposed || generation != _connectionGeneration) return;
      client = _clientFactory(target);
      final result = await client.getToys();
      if (_disposed || generation != _connectionGeneration) {
        client.close();
        return;
      }
      _client = client;
      endpoint = target;
      toys = List.unmodifiable(result);
      try {
        saveFailed = !await _store.save(target.displayAddress);
      } catch (_) {
        saveFailed = true;
      }
    } catch (failure) {
      client?.close();
      if (!_disposed && generation == _connectionGeneration) {
        error = _error(failure);
      }
    } finally {
      if (!_disposed && generation == _connectionGeneration) {
        busy = false;
        _notify();
      }
    }
  }

  Future<void> refresh() async {
    final client = _client;
    if (client == null || busy || stopping || _closing || _disposed) return;
    busy = true;
    error = null;
    _notify();
    try {
      final result = await client.getToys();
      if (_isCurrent(client)) toys = List.unmodifiable(result);
    } catch (failure) {
      if (_isCurrent(client)) error = _error(failure);
    } finally {
      if (_isCurrent(client)) {
        busy = false;
        _notify();
      }
    }
  }

  Future<void> run({
    required String toyId,
    required LovenseFunction function,
    required int strength,
    required int duration,
    LovenseStroke? stroke,
  }) async {
    if (!canStart) return;
    final matches = toys.where((toy) => toy.id == toyId);
    if (matches.isEmpty ||
        !matches.first.connected ||
        !matches.first.functions.contains(function) ||
        (stroke != null && !matches.first.supportsStroke) ||
        strength < 0 ||
        strength > function.maxStrength ||
        duration < lovenseMinDuration ||
        duration > lovenseMaxDuration ||
        (stroke != null &&
            (function != LovenseFunction.thrusting || !stroke.isValid))) {
      error = LovenseError(LovenseErrorKind.invalidCommand);
      _notify();
      return;
    }
    final client = _client!;
    final generation = _controlGeneration;
    _startedIds.add(toyId);
    _reactionIds.remove(toyId);
    _manualUntil[toyId] = _now().add(Duration(seconds: duration));
    busy = true;
    error = null;
    notice = null;
    stopFailed = false;
    _notify();
    try {
      await client.function(
        toyId: toyId,
        function: function,
        strength: strength,
        duration: duration,
        stroke: stroke,
      );
      if (_isCurrent(client) && generation == _controlGeneration) {
        notice = LovenseNotice.commandSent;
        lastDuration = duration;
      }
    } catch (failure) {
      if (_isCurrent(client) && generation == _controlGeneration) {
        _manualUntil.remove(toyId);
        error = _error(failure);
      }
    } finally {
      if (_isCurrent(client)) {
        busy = false;
        _notify();
      }
    }
  }

  Future<void> stopAll() => _stop();
  Future<void> stopToy(String toyId) => _stop(toyId: toyId);

  Future<void> _stop({String? toyId}) async {
    final client = _client;
    if (client == null || stopping || _disposed || _closing) return;
    _controlGeneration++;
    if (toyId == null) {
      _manualUntil.clear();
    } else {
      _manualUntil.remove(toyId);
    }
    stopping = true;
    error = null;
    notice = null;
    stopFailed = false;
    _notify();
    final pending = () async {
      try {
        await client.stop(toyId: toyId);
        if (_isCurrent(client)) {
          if (toyId == null) {
            _startedIds.clear();
            _reactionIds.clear();
          } else {
            _startedIds.remove(toyId);
            _reactionIds.remove(toyId);
          }
          notice = LovenseNotice.stopSent;
        }
      } catch (failure) {
        if (_isCurrent(client)) {
          error = _error(failure);
          stopFailed = true;
        }
      } finally {
        if (_isCurrent(client)) {
          stopping = false;
          _notify();
        }
      }
    }();
    _stopInProgress = pending;
    await pending;
    if (identical(_stopInProgress, pending)) _stopInProgress = null;
  }

  Future<LovenseError?> _stopStarted(
    LovenseApi client, {
    bool reactions = false,
  }) async {
    LovenseError? failure;
    for (final id in {..._startedIds, if (reactions) ..._reactionIds}) {
      try {
        await client.stop(toyId: id);
        _startedIds.remove(id);
        _reactionIds.remove(id);
      } catch (error) {
        failure ??= _error(error);
      }
    }
    return failure;
  }

  Future<void> sendReaction({
    required String toyId,
    required LovenseFunction function,
    required int strength,
    required int duration,
  }) async {
    final client = _client;
    if (client == null || _closing || _disposed || manualActive(toyId)) return;
    _reactionIds.add(toyId);
    try {
      await client.function(
        toyId: toyId,
        function: function,
        strength: strength,
        duration: duration,
      );
    } catch (_) {
      // A missed reaction is not worth an error; the next one retries.
    }
  }

  Future<void> stopReaction(String toyId) async {
    final client = _client;
    if (client == null ||
        _closing ||
        _disposed ||
        manualActive(toyId) ||
        !_reactionIds.remove(toyId)) {
      return;
    }
    try {
      await client.stop(toyId: toyId);
    } catch (_) {
      // The reaction command still ends after its own short duration.
    }
  }

  Future<void> pause() async {
    if (_disposed || _closing || paused) return;
    paused = true;
    await stopManual();
  }

  Future<void> stopManual() async {
    if (_disposed || _closing) return;
    _controlGeneration++;
    _manualUntil.clear();
    _notify();
    final pending = _stopInProgress;
    if (pending != null) await pending;
    final client = _client;
    if (client == null || _startedIds.isEmpty || _disposed || _closing) return;
    stopping = true;
    _notify();
    final failure = await _stopStarted(client);
    if (_isCurrent(client)) {
      stopping = false;
      notice = null;
      if (failure != null) {
        error = failure;
        stopFailed = true;
      }
      _notify();
    }
  }

  void resume() {
    if (_disposed || _closing) return;
    paused = false;
    _notify();
  }

  Future<void> disconnect() async {
    if (_disposed || _closing) return;
    _closing = true;
    _connectionGeneration++;
    _controlGeneration++;
    stopping = true;
    _notify();
    final client = _client;
    final failure = client == null
        ? null
        : await _stopStarted(client, reactions: true);
    client?.close();
    if (_disposed) return;
    _client = null;
    endpoint = null;
    toys = const [];
    _startedIds.clear();
    _reactionIds.clear();
    _manualUntil.clear();
    busy = false;
    stopping = false;
    _closing = false;
    notice = null;
    error = failure;
    stopFailed = failure != null;
    _notify();
  }

  bool _isCurrent(LovenseApi client) =>
      !_disposed && identical(_client, client);

  static LovenseError _error(Object failure) => failure is LovenseError
      ? failure
      : LovenseError(LovenseErrorKind.unavailable);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _closing = true;
    _connectionGeneration++;
    _controlGeneration++;
    final client = _client;
    _client = null;
    _shutdown = () async {
      if (client == null) return;
      try {
        await _stopStarted(client, reactions: true);
      } finally {
        client.close();
      }
    }();
    unawaited(_shutdown);
    super.dispose();
  }
}
