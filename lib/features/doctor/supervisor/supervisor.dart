import 'dart:async';

import 'package:flutter/foundation.dart';

import '../cause.dart';
import '../finding.dart';
import '../journal.dart';
import '../kernel.dart';
import '../path.dart';
import '../remedies/connection.dart';
import '../remedies/remedy.dart';
import 'health.dart';

enum VerifyVerdict { pass, fail, unknown }

@immutable
final class Verification {
  const Verification(this.verdict, {this.cause});

  static const unknown = Verification(VerifyVerdict.unknown);

  /// Pass only when the internet step passed: a check whose steps could not
  /// tell proves nothing either way.
  factory Verification.of(PathResult? path) {
    if (path == null || !path.complete || path.cancelled) return unknown;
    final failed = path.failed;
    if (failed != null) {
      return failed.cause == null
          ? unknown
          : Verification(VerifyVerdict.fail, cause: failed.cause);
    }
    return path.stepOf(PathStep.internet)?.status == PathStepStatus.pass
        ? const Verification(VerifyVerdict.pass)
        : unknown;
  }

  final VerifyVerdict verdict;
  final FailureCause? cause;
}

const _ladder = {
  HealStep.bestNode: ConnectionRemedy.bestNode,
  HealStep.updateProfile: 'profile.update',
  HealStep.resetConnections: ConnectionRemedy.resetConnections,
  HealStep.restartCore: ConnectionRemedy.restartCore,
  HealStep.restartTunnel: ConnectionRemedy.reconnect,
};

const _autoSteps = [
  HealStep.bestNode,
  HealStep.updateProfile,
  HealStep.resetConnections,
];

/// Owns [ConnectionHealth] for the running tunnel: verifies on the triggers
/// it is told about, never on a timer of its own, and climbs the healing
/// ladder through remedies. Whether the tunnel runs stays with its lifecycle
/// owners; a restart rung only asks them.
class ConnectionSupervisor {
  ConnectionSupervisor({
    required DiagnosticKernel kernel,
    required bool Function() autoHeal,
    String? Function()? selectedNode,
    DateTime Function()? clock,
    this.connectBudget = const Duration(seconds: 15),
    this.networkSettle = const Duration(seconds: 5),
    this.confirmGap = const Duration(seconds: 3),
    this.resumeTtl = const Duration(minutes: 2),
    this.graceInterval = const Duration(minutes: 5),
    this.recoveringDelay = const Duration(milliseconds: 800),
  }) : _kernel = kernel,
       _autoHeal = autoHeal,
       _selectedNode = selectedNode,
       _clock = clock ?? DateTime.now;

  final Duration connectBudget;
  final Duration networkSettle;

  /// Two failed checks at least this far apart make the connection broken.
  final Duration confirmGap;

  /// On resume, a check older than this is repeated.
  final Duration resumeTtl;

  /// How often an expired plan that still works is checked while visible.
  final Duration graceInterval;
  final Duration recoveringDelay;

  final DiagnosticKernel _kernel;
  final bool Function() _autoHeal;
  final String? Function()? _selectedNode;
  final DateTime Function() _clock;

  final _updates = StreamController<ConnectionHealth>.broadcast(sync: true);
  final _verifications = StreamController<Verification>.broadcast(sync: true);
  final _subscriptions = <StreamSubscription<Object?>>[];

  ConnectionHealth _health = ConnectionHealth.idle;
  bool _running = false;
  bool _pendingRunning = false;
  bool _restarting = false;
  bool _visible = true;
  bool? _online;
  bool _grace = false;

  int _epoch = 0;
  bool _connecting = false;
  bool _connectStarted = false;
  bool _deferred = false;
  DateTime? _lastCheckAt;
  DateTime? _firstFailureAt;
  DateTime? _networkChangedAt;
  FailureCause? _cause;

  int _plan = 0;
  Future<bool>? _climb;
  HealStep? _step;
  String? _stepDetail;
  bool _recoveringShown = false;
  Future<void>? _inFlight;

  Timer? _connectTimer;
  Timer? _settleTimer;
  Timer? _confirmTimer;
  Timer? _graceTimer;
  Timer? _recoveringTimer;
  bool _disposed = false;

  ConnectionHealth get health => _health;

  Stream<ConnectionHealth> get updates => _updates.stream;

  /// Every finished check, for the account guard's evidence.
  Stream<Verification> get verifications => _verifications.stream;

  void start() {
    _subscriptions
      ..add(_kernel.findingUpdates.listen(_onFindings))
      ..add(_kernel.events.listen(_onEvent));
    _onFindings(_kernel.findings);
  }

  void setRunning(bool running) {
    _pendingRunning = running;
    if (!_restarting) _applyRunning(running);
  }

  void setVisible(bool visible) {
    if (visible == _visible) return;
    _visible = visible;
    if (!visible) {
      _graceTimer?.cancel();
      return;
    }
    if (!_running) return;
    final last = _lastCheckAt;
    if (_deferred ||
        _connecting && !_connectStarted ||
        last == null ||
        _clock().difference(last) >= resumeTtl) {
      _trigger();
    } else {
      _scheduleGrace();
    }
  }

  /// [changed] when the device moved to another network.
  void setNetwork({required bool? online, bool changed = true}) {
    final wasOffline = _online == false;
    _online = online;
    if (changed) _networkChangedAt = _clock();
    if (!_running) return;
    if (online == false) {
      _settleTimer?.cancel();
      _confirmTimer?.cancel();
      _firstFailureAt = null;
      _emit(const ConnectionHealth(phase: ConnectionPhase.waitingNetwork));
      return;
    }
    if (!changed && !wasOffline) return;
    if (_connecting && _connectStarted && !wasOffline) return;
    _settleTimer?.cancel();
    _settleTimer = Timer(networkSettle, _trigger);
  }

  /// Verifies once now, whatever the last check said.
  Future<void> recheck() async {
    if (!_running || _restarting || _climb != null) return;
    if (_connecting) {
      if (!_connectStarted) _startConnect();
      return;
    }
    await _check();
  }

  /// The user moved the main group to another node: what was verified for the
  /// old one says nothing about it, so it is verified again as a fresh connect.
  void selectionChanged() {
    if (!_running || _restarting || _connecting || _climb != null) return;
    _epoch++;
    _plan++;
    _cancelTimers();
    _firstFailureAt = null;
    _cause = null;
    _connecting = true;
    _connectStarted = false;
    _emit(const ConnectionHealth(phase: ConnectionPhase.connecting));
    _trigger();
  }

  /// The full ladder from the face; true when a check passed after a step.
  Future<bool> repair() async {
    if (!_running) return false;
    final plan = ++_plan;
    await _climb;
    if (plan != _plan || !_running) return false;
    _connecting = false;
    _connectTimer?.cancel();
    return _runLadder(HealStep.values, plan: plan, manual: true);
  }

  void _onFindings(List<Finding> findings) {
    final grace = findings.any(
      (finding) => finding.id == 'profile.subscription',
    );
    if (grace == _grace) return;
    _grace = grace;
    _scheduleGrace();
  }

  /// A repair from elsewhere, such as the environment healer, deserves a
  /// fresh look; the ladder's own steps verify themselves.
  void _onEvent(DiagnosticEvent event) {
    if (event.kind != DiagnosticEventKind.remedyApplied ||
        _climb != null ||
        _connecting ||
        _ladder.containsValue(event.subject)) {
      return;
    }
    _trigger();
  }

  void _applyRunning(bool running) {
    if (running == _running) return;
    _running = running;
    _epoch++;
    _plan++;
    _cancelTimers();
    _connecting = false;
    _connectStarted = false;
    _deferred = false;
    _firstFailureAt = null;
    _cause = null;
    _step = null;
    _stepDetail = null;
    if (!running) {
      _emit(ConnectionHealth.idle);
      return;
    }
    _connecting = true;
    _emit(const ConnectionHealth(phase: ConnectionPhase.connecting));
    _trigger();
  }

  bool get _canCheck => _running && !_restarting && _visible;

  void _trigger() {
    if (!_running || _restarting || _disposed) return;
    if (!_visible) {
      _deferred = true;
      return;
    }
    if (_online == false) {
      _emit(const ConnectionHealth(phase: ConnectionPhase.waitingNetwork));
      return;
    }
    _deferred = false;
    if (_connecting) {
      if (!_connectStarted) _startConnect();
      return;
    }
    if (_climb != null) return;
    unawaited(_check());
  }

  void _startConnect() {
    _connectStarted = true;
    final epoch = _epoch;
    _connectTimer?.cancel();
    _connectTimer = Timer(connectBudget, () {
      if (epoch != _epoch || !_connecting) return;
      _connecting = false;
      _broken(_cause ?? FailureCause.timeout);
    });
    unawaited(_connect(epoch));
  }

  Future<void> _connect(int epoch) async {
    final first = await _verify();
    if (epoch != _epoch) return;
    if (first.verdict == VerifyVerdict.pass) return _pass();
    if (!_connecting) return;
    if (first.verdict == VerifyVerdict.unknown) {
      _endConnect();
      _emit(_checked(ConnectionPhase.unknown));
      _scheduleGrace();
      return;
    }
    _cause = first.cause;
    _step = HealStep.bestNode;
    _stepDetail = null;
    final plan = ++_plan;
    _emit(_checked(ConnectionPhase.connecting, searching: true));
    final healed = await _runStep(HealStep.bestNode, plan, searching: true);
    if (epoch != _epoch || plan != _plan) return;
    if (healed) return _pass();
    final wasConnecting = _connecting;
    _endConnect();
    if (wasConnecting) _broken(_cause, from: 1);
  }

  void _endConnect() {
    _connecting = false;
    _connectTimer?.cancel();
  }

  Future<void> _check() =>
      _inFlight ??= _runCheck(_epoch).whenComplete(() => _inFlight = null);

  Future<void> _runCheck(int epoch) async {
    if (!_canCheck) {
      _deferred = true;
      return;
    }
    final result = await _verify();
    if (epoch != _epoch || _climb != null || _connecting) return;
    switch (result.verdict) {
      case VerifyVerdict.pass:
        _pass();
      case VerifyVerdict.unknown:
        if (_health.phase != ConnectionPhase.broken) {
          _emit(_checked(ConnectionPhase.unknown));
        }
        _scheduleGrace();
      case VerifyVerdict.fail:
        _failed(result.cause, epoch);
    }
  }

  void _failed(FailureCause? cause, int epoch) {
    final now = _clock();
    final changedAt = _networkChangedAt;
    if (changedAt != null && now.difference(changedAt) < networkSettle) return;
    _cause = cause;
    if (_health.phase == ConnectionPhase.broken) {
      _emit(_checked(ConnectionPhase.broken));
      return;
    }
    final first = _firstFailureAt;
    if (first != null && now.difference(first) >= confirmGap) {
      _broken(cause);
      return;
    }
    _firstFailureAt ??= now;
    _confirmTimer?.cancel();
    _confirmTimer = Timer(confirmGap - now.difference(_firstFailureAt!), () {
      if (epoch == _epoch) _trigger();
    });
  }

  Future<Verification> _verify() async {
    final Verification result;
    try {
      result = Verification.of(
        await _kernel.runPath(scope: PathScope.verify, force: true),
      );
    } on Object {
      return Verification.unknown;
    }
    _lastCheckAt = _clock();
    if (!_disposed) _verifications.add(result);
    return result;
  }

  void _pass() {
    _endConnect();
    _confirmTimer?.cancel();
    _firstFailureAt = null;
    _cause = null;
    _step = null;
    _stepDetail = null;
    _emit(_checked(ConnectionPhase.verified));
    _scheduleGrace();
  }

  /// [from] skips the rungs the connect phase already tried.
  void _broken(FailureCause? cause, {int from = 0}) {
    _confirmTimer?.cancel();
    _firstFailureAt = null;
    _cause = cause;
    _emit(_checked(ConnectionPhase.broken));
    if (_visible) unawaited(_kernel.runPath().then((_) {}, onError: (_) {}));
    if (!_autoHeal() || _climb != null) return;
    final plan = ++_plan;
    unawaited(_runLadder(_autoSteps.sublist(from), plan: plan, manual: false));
  }

  Future<bool> _runLadder(
    List<HealStep> steps, {
    required int plan,
    required bool manual,
  }) {
    final climb = _ladderOf(steps, plan, manual);
    _climb = climb;
    return climb.whenComplete(() {
      if (identical(_climb, climb)) _climb = null;
    });
  }

  Future<bool> _ladderOf(List<HealStep> steps, int plan, bool manual) async {
    final epoch = _epoch;
    _recoveringShown = false;
    _recoveringTimer?.cancel();
    _recoveringTimer = Timer(recoveringDelay, () {
      if (plan != _plan || epoch != _epoch) return;
      _recoveringShown = true;
      _emitRecovering();
    });
    try {
      for (final step in steps) {
        final healed = await _runStep(step, plan);
        if (plan != _plan || epoch != _epoch) return false;
        if (healed) {
          _pass();
          return true;
        }
      }
      if (plan == _plan && epoch == _epoch) {
        _step = null;
        _stepDetail = null;
        _emit(_checked(ConnectionPhase.broken, repairFailed: manual));
      }
      return false;
    } finally {
      if (plan == _plan) {
        _recoveringTimer?.cancel();
        _recoveringShown = false;
      }
    }
  }

  /// Applies one rung and verifies; true when the check passed.
  Future<bool> _runStep(
    HealStep step,
    int plan, {
    bool searching = false,
  }) async {
    _step = step;
    _stepDetail = null;
    if (_recoveringShown) _emitRecovering();
    final restarts =
        step == HealStep.restartCore || step == HealStep.restartTunnel;
    if (restarts) _restarting = true;
    try {
      final outcome = await _kernel.apply(_ladder[step]!);
      if (plan != _plan) return false;
      if (step == HealStep.bestNode && outcome.status != RemedyStatus.failed) {
        _stepDetail = _selectedNode?.call();
        if (searching) {
          _emit(_checked(ConnectionPhase.connecting, searching: true));
        } else if (_recoveringShown) {
          _emitRecovering();
        }
      }
    } finally {
      if (restarts) {
        _restarting = false;
        if (_pendingRunning != _running) _applyRunning(_pendingRunning);
      }
    }
    if (plan != _plan || !_running) return false;
    final result = await _verify();
    if (plan != _plan) return false;
    if (result.verdict == VerifyVerdict.fail) _cause = result.cause;
    return result.verdict == VerifyVerdict.pass;
  }

  void _emitRecovering() => _emit(
    ConnectionHealth(
      phase: ConnectionPhase.recovering,
      cause: _cause,
      step: _step,
      stepDetail: _stepDetail,
      checkedAt: _lastCheckAt,
    ),
  );

  ConnectionHealth _checked(
    ConnectionPhase phase, {
    bool searching = false,
    bool repairFailed = false,
  }) => ConnectionHealth(
    phase: phase,
    cause:
        phase == ConnectionPhase.broken ||
            phase == ConnectionPhase.connecting && searching
        ? _cause
        : null,
    step: searching ? _step : null,
    stepDetail: searching ? _stepDetail : null,
    searching: searching,
    repairFailed: repairFailed,
    checkedAt: _lastCheckAt,
  );

  void _scheduleGrace() {
    _graceTimer?.cancel();
    if (!_grace || !_visible || !_running || _connecting) return;
    _graceTimer = Timer(graceInterval, _trigger);
  }

  void _emit(ConnectionHealth health) {
    if (_disposed || health == _health) return;
    _health = health;
    _updates.add(health);
  }

  void _cancelTimers() {
    for (final timer in [
      _connectTimer,
      _settleTimer,
      _confirmTimer,
      _graceTimer,
      _recoveringTimer,
    ]) {
      timer?.cancel();
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _plan++;
    _epoch++;
    _cancelTimers();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _updates.close();
    await _verifications.close();
  }
}
