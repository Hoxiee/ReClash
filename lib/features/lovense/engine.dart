import 'dart:async';

import 'package:flutter/foundation.dart';

import 'controller.dart';
import 'models.dart';
import 'reactions.dart';

abstract interface class LovenseReactionSource {
  LovenseLink get link;
  bool get visible;
  VoidCallback listenLink(ValueChanged<LovenseLink> listener);
  VoidCallback listenSpeed(ValueChanged<num> listener);
  VoidCallback listenVisible(ValueChanged<bool> listener);
}

/// Session-only reactions that outlive the Lovense page. Nothing is listened
/// to or sent while both switches are off, and both turn off once the
/// controller loses its connection.
class LovenseReactions extends ChangeNotifier {
  LovenseReactions(this._controller, this._source, {Duration Function()? now})
    : _now = now ?? _elapsed(Stopwatch()..start());

  final LovenseController _controller;
  final LovenseReactionSource _source;
  final Duration Function() _now;
  final _governor = LovenseTrafficGovernor();
  final _subscriptions = <VoidCallback>[];
  final _trafficSubscriptions = <VoidCallback>[];
  Future<void> _tail = Future.value();
  LovenseLinkTracker? _tracker;
  Timer? _confirm;
  Timer? _ticker;
  num _speed = 0;
  Duration? _speedAt;
  int _burst = 0;
  bool _bursting = false;
  bool _disposed = false;
  bool _listeningController = false;

  bool connection = false;
  bool traffic = false;

  bool get active => connection || traffic;

  void setConnection(bool value) {
    if (_disposed || value == connection || (value && !_controller.connected)) {
      return;
    }
    connection = value;
    if (value) {
      _tracker = LovenseLinkTracker(_source.link);
      _subscriptions.add(_source.listenLink(_onLink));
    } else {
      _cancelBurst();
      _tracker = null;
      _closeAll(_subscriptions);
      _quiet();
    }
    _syncController();
    notifyListeners();
  }

  void setTraffic(bool value) {
    if (_disposed || value == traffic || (value && !_controller.connected)) {
      return;
    }
    traffic = value;
    if (value) {
      _speedAt = null;
      _trafficSubscriptions
        ..add(_source.listenSpeed(_onSpeed))
        ..add(_source.listenVisible(_onVisible));
      _onVisible(_source.visible);
    } else {
      _ticker?.cancel();
      _ticker = null;
      _closeAll(_trafficSubscriptions);
      _quiet();
    }
    _syncController();
    notifyListeners();
  }

  void disableAll() {
    setConnection(false);
    setTraffic(false);
  }

  void _onControllerChanged() {
    if (!_controller.connected && !_controller.busy) disableAll();
  }

  void _syncController() {
    if (active == _listeningController) return;
    _listeningController = active;
    if (active) {
      _controller.addListener(_onControllerChanged);
    } else {
      _controller.removeListener(_onControllerChanged);
    }
  }

  void _onLink(LovenseLink link) {
    final tracker = _tracker;
    if (tracker == null) return;
    final reaction = tracker.update(link);
    _confirm?.cancel();
    _confirm = null;
    if (reaction != null) unawaited(_play(reaction));
    if (tracker.pendingStart) {
      _confirm = Timer(lovenseStartSettle, () {
        final started = _tracker?.confirm();
        if (started != null) unawaited(_play(started));
      });
    }
  }

  void _onSpeed(num speed) {
    _speed = speed;
    _speedAt = _now();
  }

  void _onVisible(bool visible) {
    if (!traffic) return;
    if (!visible) {
      _ticker?.cancel();
      _ticker = null;
      if (!_bursting) _quiet();
      return;
    }
    _governor.reset();
    _ticker ??= Timer.periodic(lovenseTrafficInterval, (_) => _tick());
  }

  void _tick() {
    if (_bursting || !traffic) return;
    final now = _now();
    final sampleAt = _speedAt;
    final fresh = sampleAt != null && now - sampleAt < lovenseTrafficStale;
    final level = _governor.next(fresh ? lovenseTrafficLevel(_speed) : 0, now);
    if (level != null) _enqueue(() => _send(level, lovenseTrafficDuration));
  }

  Future<void> _play(LovenseReaction reaction) async {
    final burst = ++_burst;
    _bursting = true;
    for (final pulse in lovenseReactionPattern(reaction)) {
      if (burst != _burst) return;
      await _enqueue(() => _send(pulse.level, lovenseMinDuration));
      await Future<void>.delayed(pulse.on);
      if (burst != _burst) return;
      await _enqueue(() => _send(0, 0));
      await Future<void>.delayed(pulse.off);
    }
    if (burst != _burst) return;
    _bursting = false;
    _governor.reset();
  }

  void _cancelBurst() {
    _burst++;
    _bursting = false;
    _confirm?.cancel();
    _confirm = null;
  }

  void _quiet() {
    _governor.reset();
    if (!_bursting) _enqueue(() => _send(0, 0));
  }

  Future<void> _send(int level, int duration) async {
    for (final toy in _controller.toys) {
      final function = lovenseReactionFunction(toy);
      if (!toy.connected || function == null) continue;
      final strength = lovenseScaledStrength(level, function);
      if (strength == 0) {
        await _controller.stopReaction(toy.id);
      } else {
        await _controller.sendReaction(
          toyId: toy.id,
          function: function,
          strength: strength,
          duration: duration,
        );
      }
    }
  }

  Future<void> _enqueue(Future<void> Function() task) {
    if (_disposed) return Future.value();
    return _tail = _tail.then((_) => _disposed ? null : task());
  }

  static Duration Function() _elapsed(Stopwatch watch) =>
      () => watch.elapsed;

  static void _closeAll(List<VoidCallback> subscriptions) {
    for (final close in subscriptions) {
      close();
    }
    subscriptions.clear();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _cancelBurst();
    _ticker?.cancel();
    _closeAll(_subscriptions);
    _closeAll(_trafficSubscriptions);
    if (_listeningController) _controller.removeListener(_onControllerChanged);
    _disposed = true;
    super.dispose();
  }
}
