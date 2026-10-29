import 'package:flutter/foundation.dart';

import '../finding.dart';
import '../path.dart';
import '../snapshot.dart';

/// The button verb: Fix, Open, How?, or nothing to press.
enum FixKind { auto, system, guided, none }

enum RemedyStatus {
  /// Applied, and the rules no longer raise what it addressed.
  fixed,

  notFixed,

  /// Applied with nothing raised for it to clear, so nothing was verified.
  applied,
  failed,

  unavailable,

  undone,

  /// The config changed after the remedy, so undo would overwrite a newer
  /// choice.
  stale,
}

@immutable
final class RemedyRequest {
  const RemedyRequest({required this.snapshot, this.finding});

  final DiagnosticSnapshot snapshot;

  final Finding? finding;
}

/// The only code in the kernel that changes anything. A remedy that restarts
/// something requests it through `ServiceState` or the desktop lifecycle
/// controller, never by owning process state.
abstract interface class Remedy {
  String get id;

  FixKind get kind;

  /// The kernel snapshots `Config` before an undoable remedy and restores it
  /// on undo.
  bool get undoable;

  /// How long verification waits for the fix to reach the snapshot, for
  /// remedies whose answer arrives asynchronously, like a system dialog.
  Duration get settle;

  Future<void> apply(RemedyRequest request);
}

@immutable
final class RemedyOutcome {
  const RemedyOutcome({
    required this.remedyId,
    required this.status,
    this.remaining = const [],
    this.canUndo = false,
    this.error,
  });

  final String remedyId;
  final RemedyStatus status;

  final List<String> remaining;
  final bool canUndo;
  final Object? error;

  @override
  String toString() => 'RemedyOutcome($remedyId, ${status.name})';
}

/// An ordered ladder of remedies with verification between the steps; it
/// stops at the first step after which none of [findingIds] remain.
@immutable
final class HealPlan {
  const HealPlan({
    required this.id,
    required this.remedyIds,
    required this.findingIds,
    this.verify,
  });

  final String id;
  final List<String> remedyIds;
  final List<String> findingIds;

  /// A path that must also pass before the plan counts as healed.
  final PathScope? verify;
}

@immutable
final class PlanOutcome {
  const PlanOutcome({
    required this.planId,
    required this.healed,
    required this.steps,
    this.path,
  });

  final String planId;
  final bool healed;
  final List<RemedyOutcome> steps;

  /// The last verification run, when the plan asked for one.
  final PathResult? path;
}
