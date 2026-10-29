import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reclash/common/network_error.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

import 'cause.dart';
import 'finding.dart';
import 'journal.dart';
import 'path.dart';
import 'probes/scheduler.dart';
import 'remedies/remedy.dart';
import 'rules/engine.dart';
import 'snapshot.dart';

@immutable
final class FailureExplanation {
  const FailureExplanation({
    required this.cause,
    required this.titleKey,
    this.remedyIds = const [],
  });

  final FailureCause cause;
  final String titleKey;
  final List<String> remedyIds;
}

/// The diagnostic kernel every consumer reads. The report joins this API in
/// its own phase.
abstract interface class DiagnosticKernel {
  DiagnosticSnapshot get snapshot;

  Stream<DiagnosticSnapshot> get snapshots;

  /// Sorted by severity, snoozes applied.
  List<Finding> get findings;

  Stream<List<Finding>> get findingUpdates;

  Stream<DiagnosticEvent> get events;

  Future<List<DiagnosticEvent>> history();

  /// Deduplicated, cached by TTL; a result with a fact key lands in the
  /// snapshot.
  Future<T> probe<T extends Object>(ProbeRequest<T> request);

  Future<RemedyOutcome> apply(String remedyId);

  Future<RemedyOutcome> undo(String remedyId);

  Future<PlanOutcome> heal(HealPlan plan);

  /// The latest path of any scope, running or finished.
  PathResult? get path;

  Stream<PathResult> get pathUpdates;

  /// The connection path every consumer shares: callers of one scope share a
  /// run, a newer route intent supersedes it, and steps keep their results
  /// for their TTL unless [force]d. When the Core leaves, the run ends as
  /// cancelled instead of throwing.
  Future<PathResult> runPath({PathScope scope = PathScope.full, bool force});

  /// Hides a warning or tip until [until], or for good when it is null;
  /// critical findings cannot be snoozed.
  bool snooze(String findingId, {DateTime? until});

  FailureExplanation explain(Object error);
}

abstract interface class FactSink {
  /// A null [value] removes the fact.
  void put<T extends Object>(FactKey<T> key, T? value, {Duration? ttl});
}

abstract interface class ConfigAccess {
  Config read();

  void write(Config config);
}

const _causeRemedies = <FailureCause, List<String>>{
  FailureCause.subscriptionExpired: ['profile.update'],
  FailureCause.trafficExhausted: ['profile.update'],
};

FailureCause failureCauseOf(Object error) => switch (error) {
  ProbeFailure(:final cause) => cause,
  FailureCause() => error,
  _ => networkFailureCause(error) ?? FailureCause.unknown,
};

class _Undo {
  const _Undo(this.before, this.after);

  final Config before;
  final Config after;
}

class DoctorKernel implements DiagnosticKernel, FactSink {
  DoctorKernel({
    required RuleEngine engine,
    required ProbeScheduler scheduler,
    required DiagnosticJournal journal,
    required ConfigAccess config,
    Iterable<Remedy> remedies = const [],
    PathChecks? pathChecks,
    Object? Function()? pathIntent,
    DateTime Function()? clock,
  }) : _engine = engine,
       _pathChecks = pathChecks,
       _pathIntent = pathIntent,
       _scheduler = scheduler,
       _journal = journal,
       _config = config,
       _remedies = {for (final remedy in remedies) remedy.id: remedy},
       _clock = clock ?? DateTime.now {
    _snapshot = DiagnosticSnapshot(takenAt: _clock());
  }

  final RuleEngine _engine;
  final ProbeScheduler _scheduler;
  final DiagnosticJournal _journal;
  final ConfigAccess _config;
  final Map<String, Remedy> _remedies;
  final DateTime Function() _clock;
  final PathChecks? _pathChecks;
  final Object? Function()? _pathIntent;

  final _snapshots = StreamController<DiagnosticSnapshot>.broadcast(sync: true);
  final _findingUpdates = StreamController<List<Finding>>.broadcast(sync: true);
  final _snoozes = <String, DateTime?>{};
  final _undo = <String, _Undo>{};
  final _pathUpdates = StreamController<PathResult>.broadcast(sync: true);
  final _paths = <PathScope, PathResult>{};

  late DiagnosticSnapshot _snapshot;
  List<Finding> _raw = const [];
  int _generation = 0;
  Future<void>? _evaluation;
  bool _disposed = false;
  PathResult? _path;
  String? _pathFailure;

  @override
  DiagnosticSnapshot get snapshot => _snapshot;

  @override
  Stream<DiagnosticSnapshot> get snapshots => _snapshots.stream;

  @override
  List<Finding> get findings {
    final now = _clock();
    return [
      for (final finding in _raw)
        if (!_isSnoozed(finding, now)) finding,
    ];
  }

  @override
  Stream<List<Finding>> get findingUpdates => _findingUpdates.stream;

  @override
  Stream<DiagnosticEvent> get events => _journal.events;

  @override
  Future<List<DiagnosticEvent>> history() => _journal.history();

  bool _isSnoozed(Finding finding, DateTime now) {
    if (!_snoozes.containsKey(finding.id)) return false;
    final until = _snoozes[finding.id];
    return until == null || now.isBefore(until);
  }

  @override
  void put<T extends Object>(FactKey<T> key, T? value, {Duration? ttl}) {
    if (_disposed) return;
    final previous = _snapshot.fact(key);
    if (value == null && previous == null) return;
    final now = _clock();
    if (value != null &&
        previous != null &&
        previous.value == value &&
        ttl == null &&
        previous.ttl == null) {
      return;
    }
    if (key == Facts.coreStatus) {
      _onCoreStatus(previous?.value as CoreStatus?, value as CoreStatus?, now);
    }
    _snapshot = _snapshot.withFact(
      key,
      value == null ? null : Fact(value, at: now, ttl: ttl),
      at: now,
    );
    _snapshots.add(_snapshot);
    _scheduleEvaluation();
  }

  /// Every result measured through the route that is gone is stale.
  void _onCoreStatus(CoreStatus? previous, CoreStatus? next, DateTime now) {
    if (previous != CoreStatus.connected || next == CoreStatus.connected) {
      return;
    }
    _scheduler.cancelAll();
    for (final path in _paths.values.toList()) {
      if (!path.complete) _publishPath(path.finish(now, cancelled: true));
    }
    unawaited(
      _journal.record(
        DiagnosticEvent(
          kind: DiagnosticEventKind.disconnected,
          at: now,
          subject: next?.name ?? 'unknown',
        ),
      ),
    );
  }

  void _scheduleEvaluation() {
    final generation = ++_generation;
    _evaluation = Future.microtask(() async {
      if (generation != _generation || _disposed) return;
      final snapshot = _snapshot.at(_clock());
      final next = await _engine.evaluate(snapshot);
      if (generation != _generation || _disposed) return;
      _publish(next, snapshot.takenAt);
    });
  }

  /// Completes once the findings reflect every fact put so far.
  Future<void> settle() async {
    while (true) {
      final generation = _generation;
      await _evaluation;
      if (generation == _generation) return;
    }
  }

  /// Re-evaluates without a new fact, for TTL expiry and verification.
  Future<void> refresh() {
    _scheduleEvaluation();
    return settle();
  }

  void _publish(List<Finding> next, DateTime now) {
    final before = {for (final finding in _raw) finding.id: finding};
    final after = {for (final finding in next) finding.id: finding};
    _raw = next;
    for (final finding in next) {
      final previous = before[finding.id];
      if (previous == null || previous.severity != finding.severity) {
        _record(DiagnosticEventKind.findingRaised, finding, now);
      }
    }
    for (final finding in before.values) {
      if (!after.containsKey(finding.id)) {
        _record(DiagnosticEventKind.findingCleared, finding, now);
      }
    }
    _findingUpdates.add(findings);
  }

  void _record(DiagnosticEventKind kind, Finding finding, DateTime now) {
    unawaited(
      _journal.record(
        DiagnosticEvent(
          kind: kind,
          at: now,
          subject: finding.id,
          severity: finding.severity,
          cause: finding.cause,
        ),
      ),
    );
  }

  @override
  Future<T> probe<T extends Object>(ProbeRequest<T> request) async {
    try {
      final value = await _scheduler.run(request);
      if (request.fact case final fact?) put(fact, value, ttl: request.ttl);
      return value;
    } on ProbeCancelled {
      rethrow;
    } catch (error) {
      final cause = failureCauseOf(error);
      unawaited(
        _journal.record(
          DiagnosticEvent(
            kind: DiagnosticEventKind.probeFailed,
            at: _clock(),
            subject: request.key,
            cause: cause,
            detail: error is ProbeFailure ? error.message : '$error',
          ),
        ),
      );
      rethrow;
    }
  }

  @override
  Future<RemedyOutcome> apply(String remedyId) async {
    final remedy = _remedies[remedyId];
    if (remedy == null) {
      return RemedyOutcome(
        remedyId: remedyId,
        status: RemedyStatus.unavailable,
      );
    }
    await settle();
    final targets = [
      for (final finding in _raw)
        if (finding.remedyIds.contains(remedyId)) finding.id,
    ];
    final before = remedy.undoable ? _config.read() : null;
    try {
      await remedy.apply(
        RemedyRequest(
          snapshot: _snapshot,
          finding: _raw
              .where((finding) => finding.id == targets.firstOrNull)
              .firstOrNull,
        ),
      );
    } catch (error) {
      return _recordOutcome(
        RemedyOutcome(
          remedyId: remedyId,
          status: RemedyStatus.failed,
          remaining: targets,
          error: error,
        ),
        DiagnosticEventKind.remedyApplied,
      );
    }
    final remaining = await _verify(targets, remedy.settle);
    if (before != null) {
      _undo[remedyId] = _Undo(before, _config.read());
    }
    return _recordOutcome(
      RemedyOutcome(
        remedyId: remedyId,
        status: switch (remaining) {
          _ when targets.isEmpty => RemedyStatus.applied,
          [] => RemedyStatus.fixed,
          _ => RemedyStatus.notFixed,
        },
        remaining: remaining,
        canUndo: before != null,
      ),
      DiagnosticEventKind.remedyApplied,
    );
  }

  /// The ids in [targets] still raised once the rules have seen the change,
  /// waiting up to [settle] for facts that arrive later.
  Future<List<String>> _verify(List<String> targets, Duration settle) async {
    List<String> remaining() => [
      for (final finding in _raw)
        if (targets.contains(finding.id)) finding.id,
    ];
    await refresh();
    if (remaining().isEmpty || settle == Duration.zero) return remaining();
    final cleared = Completer<void>();
    final subscription = _findingUpdates.stream.listen((_) {
      if (remaining().isEmpty && !cleared.isCompleted) cleared.complete();
    });
    try {
      await cleared.future.timeout(settle, onTimeout: () {});
    } finally {
      await subscription.cancel();
    }
    return remaining();
  }

  @override
  Future<RemedyOutcome> undo(String remedyId) async {
    final entry = _undo.remove(remedyId);
    if (entry == null) {
      return RemedyOutcome(
        remedyId: remedyId,
        status: RemedyStatus.unavailable,
      );
    }
    if (_config.read() != entry.after) {
      return _recordOutcome(
        RemedyOutcome(remedyId: remedyId, status: RemedyStatus.stale),
        DiagnosticEventKind.remedyUndone,
      );
    }
    _config.write(entry.before);
    await refresh();
    return _recordOutcome(
      RemedyOutcome(remedyId: remedyId, status: RemedyStatus.undone),
      DiagnosticEventKind.remedyUndone,
    );
  }

  RemedyOutcome _recordOutcome(
    RemedyOutcome outcome,
    DiagnosticEventKind kind,
  ) {
    unawaited(
      _journal.record(
        DiagnosticEvent(
          kind: kind,
          at: _clock(),
          subject: outcome.remedyId,
          outcome: outcome.status.name,
          detail: outcome.error?.toString(),
        ),
      ),
    );
    return outcome;
  }

  @override
  Future<PlanOutcome> heal(HealPlan plan) async {
    final steps = <RemedyOutcome>[];
    PathResult? path;
    for (final remedyId in plan.remedyIds) {
      steps.add(await apply(remedyId));
      await refresh();
      if (_raw.any((finding) => plan.findingIds.contains(finding.id))) {
        continue;
      }
      if (plan.verify case final scope?) {
        path = await runPath(scope: scope, force: true);
        if (!path.passed) continue;
      }
      return PlanOutcome(
        planId: plan.id,
        healed: true,
        steps: steps,
        path: path,
      );
    }
    return PlanOutcome(
      planId: plan.id,
      healed: false,
      steps: steps,
      path: path,
    );
  }

  @override
  PathResult? get path => _path;

  @override
  Stream<PathResult> get pathUpdates => _pathUpdates.stream;

  @override
  Future<PathResult> runPath({
    PathScope scope = PathScope.full,
    bool force = false,
  }) async {
    final request = ProbeRequest<PathResult>(
      key: 'path:${scope.name}',
      cost: CheckCost.local,
      ttl: Duration.zero,
      intent: _pathIntent?.call(),
      force: force,
      run: (token) => _walk(scope, token, force: force),
    );
    try {
      return await _scheduler.run(request);
    } on ProbeCancelled {
      return _paths[scope] ??
          PathResult.start(scope, _clock()).finish(_clock(), cancelled: true);
    }
  }

  Future<PathResult> _walk(
    PathScope scope,
    ProbeToken token, {
    required bool force,
  }) async {
    var result = PathResult.start(scope, _clock());
    void publish(PathResult next) {
      if (token.isCancelled || _disposed) throw ProbeCancelled('path:$scope');
      result = next;
      _publishPath(next);
    }

    publish(result);
    for (final step in scope.steps) {
      final check = _pathChecks?.call(step);
      if (check == null) {
        publish(
          result.withStep(PathStepResult(step, status: PathStepStatus.skipped)),
        );
        continue;
      }
      publish(
        result.withStep(PathStepResult(step, status: PathStepStatus.running)),
      );
      final request = check.request(step, force: force);
      StepCheck outcome;
      try {
        outcome = await _scheduler.run(request);
      } on ProbeCancelled {
        rethrow;
      } catch (error) {
        outcome = StepCheck.fail(failureCauseOf(error), detail: '$error');
      }
      if (outcome.status != PathStepStatus.pass) {
        _scheduler.invalidate(request.key);
      }
      publish(
        result.withStep(
          PathStepResult(
            step,
            status: outcome.status,
            duration: outcome.elapsed,
            detail: outcome.detail,
            cause: outcome.cause,
          ),
        ),
      );
      if (outcome.status == PathStepStatus.fail) break;
    }
    publish(result.finish(_clock()));
    _journalPath(result);
    return result;
  }

  void _publishPath(PathResult path) {
    _paths[path.scope] = path;
    _path = path;
    _pathUpdates.add(path);
  }

  /// Journals a new failure once and the recovery after it; a tunnel the user
  /// has not started is not a failure.
  void _journalPath(PathResult path) {
    final failed = path.failed;
    if (failed != null && failed.cause == null) return;
    final key = failed == null ? null : '${failed.step.name}/${failed.cause}';
    if (key == _pathFailure) return;
    final previous = _pathFailure;
    _pathFailure = key;
    if (failed == null && previous == null) return;
    unawaited(
      _journal.record(
        DiagnosticEvent(
          kind: failed == null
              ? DiagnosticEventKind.pathRecovered
              : DiagnosticEventKind.pathFailed,
          at: _clock(),
          subject: failed?.step.name ?? previous!.split('/').first,
          cause: failed?.cause,
          detail: failed?.detail,
        ),
      ),
    );
  }

  @override
  bool snooze(String findingId, {DateTime? until}) {
    final finding = _raw.where((f) => f.id == findingId).firstOrNull;
    if (finding == null || finding.severity == CheckSeverity.critical) {
      return false;
    }
    _snoozes[findingId] = until;
    _findingUpdates.add(findings);
    return true;
  }

  @override
  FailureExplanation explain(Object error) {
    final cause = failureCauseOf(error);
    return FailureExplanation(
      cause: cause,
      titleKey: 'doctorCause_${cause.id}',
      remedyIds: _causeRemedies[cause] ?? const [],
    );
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _scheduler.cancelAll();
    await _snapshots.close();
    await _findingUpdates.close();
    await _pathUpdates.close();
    await _journal.close();
  }
}
