import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../cause.dart';
import '../snapshot.dart';

/// local: milliseconds, no I/O. network: needs a probe through the network.
/// heavy: sweeps, only in a report or on an explicit tap.
enum CheckCost { local, network, heavy }

class ProbeCancelled implements Exception {
  const ProbeCancelled(this.key);

  final String key;

  @override
  String toString() => 'ProbeCancelled($key)';
}

/// A probe that ran and failed, with the classified cause.
class ProbeFailure implements Exception {
  const ProbeFailure(this.cause, [this.message]);

  final FailureCause cause;
  final String? message;

  @override
  String toString() => 'ProbeFailure(${cause.id}, $message)';
}

class ProbeToken {
  final _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;

  Future<void> get whenCancelled => _cancelled.future;

  void _cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}

@immutable
final class ProbeRequest<T extends Object> {
  const ProbeRequest({
    required this.key,
    required this.cost,
    required this.ttl,
    required this.run,
    this.intent,
    this.fact,
    this.force = false,
  });

  /// Requests with the same key share a run and its cached result.
  final String key;
  final CheckCost cost;
  final Duration ttl;

  /// What the result is valid for, such as the route it went through. A
  /// request with a different intent supersedes the run in flight, and every
  /// caller of that run receives the newer result.
  final Object? intent;

  /// Where the kernel stores a successful result in the snapshot.
  final FactKey<T>? fact;

  /// Skips the cache; a run in flight for the same intent is still shared.
  final bool force;

  final Future<T> Function(ProbeToken token) run;

  ProbeRequest<T> forced() => ProbeRequest(
    key: key,
    cost: cost,
    ttl: ttl,
    run: run,
    intent: intent,
    fact: fact,
    force: true,
  );
}

class _Run {
  _Run(this.key, this.intent);

  final String key;
  final Object? intent;
  final token = ProbeToken();
  final result = Completer<Object>();
}

class _Cached {
  const _Cached(this.value, this.intent, this.expiresAt);

  final Object value;
  final Object? intent;
  final DateTime expiresAt;
}

class ProbeScheduler {
  ProbeScheduler({
    DateTime Function()? clock,
    this.limits = const {CheckCost.network: 4, CheckCost.heavy: 1},
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// Runs of a cost class allowed at once; a missing class is unbounded.
  final Map<CheckCost, int> limits;

  final _runs = <String, _Run>{};
  final _cache = <String, _Cached>{};
  final _active = <CheckCost, int>{};
  final _queues = <CheckCost, Queue<Completer<void>>>{};

  Future<T> run<T extends Object>(ProbeRequest<T> request) {
    final key = request.key;
    final cached = _cache[key];
    if (!request.force &&
        cached != null &&
        cached.intent == request.intent &&
        _clock().isBefore(cached.expiresAt)) {
      return Future.value(cached.value as T);
    }
    final current = _runs[key];
    if (current != null && current.intent == request.intent) {
      return current.result.future.then((value) => value as T);
    }
    final run = _Run(key, request.intent);
    _runs[key] = run;
    if (current != null) {
      current.token._cancel();
      current.result.complete(run.result.future);
    }
    unawaited(_execute(request, run));
    return run.result.future.then((value) => value as T);
  }

  Future<void> _execute<T extends Object>(
    ProbeRequest<T> request,
    _Run run,
  ) async {
    var acquired = false;
    try {
      acquired = await _acquire(request.cost, run.token);
      if (!acquired || run.token.isCancelled) return;
      final value = await request.run(run.token);
      if (!identical(_runs[request.key], run)) return;
      _cache[request.key] = _Cached(
        value,
        request.intent,
        _clock().add(request.ttl),
      );
      run.result.complete(value);
    } catch (error, stackTrace) {
      if (identical(_runs[request.key], run) && !run.result.isCompleted) {
        run.result.completeError(
          run.token.isCancelled ? ProbeCancelled(request.key) : error,
          stackTrace,
        );
      }
    } finally {
      if (acquired) _release(request.cost);
      if (identical(_runs[request.key], run)) {
        _runs.remove(request.key);
        if (!run.result.isCompleted) {
          run.result.completeError(ProbeCancelled(request.key));
        }
      }
    }
  }

  Future<bool> _acquire(CheckCost cost, ProbeToken token) async {
    final limit = limits[cost];
    if (limit != null && (_active[cost] ?? 0) >= limit) {
      final slot = Completer<void>();
      _queues.putIfAbsent(cost, Queue.new).add(slot);
      await Future.any([slot.future, token.whenCancelled]);
      if (!slot.isCompleted) {
        _queues[cost]?.remove(slot);
        return false;
      }
      if (token.isCancelled) {
        _release(cost);
        return false;
      }
      return true;
    }
    if (token.isCancelled) return false;
    _active[cost] = (_active[cost] ?? 0) + 1;
    return true;
  }

  /// A queued waiter inherits the slot, so the active count stays put.
  void _release(CheckCost cost) {
    final queue = _queues[cost];
    if (queue != null && queue.isNotEmpty) {
      queue.removeFirst().complete();
      return;
    }
    _active[cost] = (_active[cost] ?? 1) - 1;
  }

  /// Fails every caller in flight with [ProbeCancelled] and forgets the cache,
  /// for when what the results described is gone, such as the Core stopping.
  void cancelAll() {
    _cache.clear();
    final runs = _runs.values.toList();
    _runs.clear();
    for (final run in runs) {
      run.token._cancel();
      if (!run.result.isCompleted) {
        run.result.completeError(ProbeCancelled(run.key));
      }
    }
  }

  void invalidate(String key) => _cache.remove(key);
}
