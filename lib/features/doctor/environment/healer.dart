import 'dart:async';

import 'package:flutter/foundation.dart';

import '../finding.dart';
import '../kernel.dart';
import '../remedies/remedy.dart';

/// One automatic repair, for the UI to announce and offer to take back.
@immutable
final class HealNotice {
  const HealNotice({
    required this.findingId,
    required this.titleKey,
    required this.remedyId,
    this.args = const {},
    this.undoable = false,
  });

  final String findingId;
  final String titleKey;
  final Map<String, Object> args;
  final String remedyId;
  final bool undoable;
}

/// Repairs the environment findings a remedy of ours can fix, when the user
/// allows it. It never runs a foreign remedy and acts once per raise, so a fix
/// that does not hold cannot loop.
class EnvironmentHealer {
  EnvironmentHealer({
    required DiagnosticKernel kernel,
    required Iterable<Remedy> remedies,
    required bool Function() enabled,
    this.settleDelay = const Duration(milliseconds: 1500),
    this.maxHeals = 3,
    this.window = const Duration(minutes: 10),
    DateTime Function()? clock,
  }) : _kernel = kernel,
       _remedies = {for (final remedy in remedies) remedy.id: remedy},
       _enabled = enabled,
       _clock = clock ?? DateTime.now;

  static const findingPrefix = 'env.';

  /// A transient state must outlast this before it triggers a repair.
  final Duration settleDelay;
  final int maxHeals;
  final Duration window;

  final DiagnosticKernel _kernel;
  final Map<String, Remedy> _remedies;
  final bool Function() _enabled;
  final DateTime Function() _clock;

  final _notices = StreamController<HealNotice>.broadcast();
  final _present = <String>{};
  final _handled = <String>{};
  final _timers = <String, Timer>{};
  final _running = <String>{};
  final _healedAt = <DateTime>[];
  final _inFlight = <Future<void>>{};
  StreamSubscription<List<Finding>>? _subscription;
  bool _disposed = false;

  Stream<HealNotice> get notices => _notices.stream;

  void start() {
    if (_subscription != null || _disposed) return;
    _subscription = _kernel.findingUpdates.listen(_onFindings);
    _onFindings(_kernel.findings);
  }

  Future<RemedyOutcome> undo(HealNotice notice) =>
      _kernel.undo(notice.remedyId);

  void _onFindings(List<Finding> findings) {
    final ids = {
      for (final finding in findings)
        if (finding.id.startsWith(findingPrefix)) finding.id,
    };
    for (final gone in _present.difference(ids)) {
      _timers.remove(gone)?.cancel();
      _handled.remove(gone);
    }
    for (final raised in ids.difference(_present)) {
      _timers[raised] = Timer(settleDelay, () => _settled(raised));
    }
    _present
      ..clear()
      ..addAll(ids);
  }

  void _settled(String id) {
    _timers.remove(id);
    if (_disposed || !_handled.add(id) || !_enabled()) return;
    final finding = _kernel.findings.where((f) => f.id == id).firstOrNull;
    if (finding == null) return;
    final remedy = [
      for (final remedyId in finding.remedyIds) ?_remedies[remedyId],
    ].where((r) => r.reach != RemedyReach.foreign && r.kind == FixKind.auto);
    final chosen = remedy.firstOrNull;
    if (chosen == null || _running.contains(chosen.id)) return;
    final now = _clock();
    _healedAt.removeWhere((at) => now.difference(at) >= window);
    if (_healedAt.length >= maxHeals) return;
    _healedAt.add(now);
    late final Future<void> run;
    run = _heal(finding, chosen).whenComplete(() => _inFlight.remove(run));
    _inFlight.add(run);
  }

  Future<void> _heal(Finding finding, Remedy remedy) async {
    _running.add(remedy.id);
    try {
      final outcome = await _kernel.apply(remedy.id);
      if (outcome.status == RemedyStatus.notFixed) {
        // A change that did not help must not stay behind unannounced.
        if (outcome.canUndo && !_disposed) await _kernel.undo(remedy.id);
        return;
      }
      final changed =
          outcome.status == RemedyStatus.fixed ||
          outcome.status == RemedyStatus.applied;
      if (changed && !_disposed) {
        _notices.add(
          HealNotice(
            findingId: finding.id,
            titleKey: finding.titleKey,
            args: finding.args,
            remedyId: remedy.id,
            undoable: outcome.canUndo,
          ),
        );
      }
    } on Object {
      // The kernel went away mid-repair; there is nobody left to tell.
    } finally {
      _running.remove(remedy.id);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    await _subscription?.cancel();
    await Future.wait(_inFlight.toList());
    await _notices.close();
  }
}
