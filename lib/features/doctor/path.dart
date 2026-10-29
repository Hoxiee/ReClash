import 'package:flutter/foundation.dart';

import 'cause.dart';
import 'probes/scheduler.dart';

/// The connection path in order; the first failure stops the chain.
enum PathStep {
  network,
  clock,
  core,
  profile,
  tunnel,
  dns,
  server,
  internet,
  services,
}

enum PathScope {
  full(PathStep.values),

  /// The setup wizard: everything but the optional service checks.
  setup([
    PathStep.network,
    PathStep.clock,
    PathStep.core,
    PathStep.profile,
    PathStep.tunnel,
    PathStep.dns,
    PathStep.server,
    PathStep.internet,
  ]);

  const PathScope(this.steps);

  final List<PathStep> steps;
}

/// unknown: could not tell, never shown as a problem and never stops the chain.
enum PathStepStatus { waiting, running, pass, fail, skipped, unknown }

/// What one step measured. [detail] is data for display, such as a node name,
/// an address or a skew, never a sentence.
@immutable
final class StepCheck {
  const StepCheck.pass({this.detail, this.elapsed})
    : status = PathStepStatus.pass,
      cause = null;

  /// A null [cause] is a step that is not up rather than broken, such as a
  /// tunnel the user has not started.
  const StepCheck.fail(this.cause, {this.detail, this.elapsed})
    : status = PathStepStatus.fail;

  const StepCheck.unknown({this.detail, this.elapsed})
    : status = PathStepStatus.unknown,
      cause = null;

  final PathStepStatus status;
  final FailureCause? cause;
  final String? detail;

  /// How long the measurement took when it ran, kept with a cached result.
  final Duration? elapsed;

  StepCheck _timed(Duration elapsed) => switch (status) {
    PathStepStatus.fail => StepCheck.fail(
      cause,
      detail: detail,
      elapsed: elapsed,
    ),
    PathStepStatus.unknown => StepCheck.unknown(
      detail: detail,
      elapsed: elapsed,
    ),
    _ => StepCheck.pass(detail: detail, elapsed: elapsed),
  };
}

/// How a step is measured right now. [intent] is what its result is valid
/// for, such as the route counters and the selected node; a different one
/// supersedes a run in flight.
@immutable
final class PathCheck {
  const PathCheck({
    required this.cost,
    required this.run,
    this.ttl = Duration.zero,
    this.intent,
  });

  final CheckCost cost;
  final Duration ttl;
  final Object? intent;
  final Future<StepCheck> Function(ProbeToken token) run;

  ProbeRequest<StepCheck> request(PathStep step, {bool force = false}) {
    final key = pathStepKey(step);
    return ProbeRequest(
      key: key,
      cost: cost,
      ttl: ttl,
      intent: intent,
      force: force,
      run: (token) async {
        final watch = Stopwatch()..start();
        try {
          return (await run(token))._timed(watch.elapsed);
        } on ProbeCancelled {
          rethrow;
        } on ProbeFailure catch (failure) {
          return StepCheck.fail(
            failure.cause,
            detail: failure.message,
            elapsed: watch.elapsed,
          );
        }
      },
    );
  }
}

/// Null when the step does not apply here, which shows it as skipped.
typedef PathChecks = PathCheck? Function(PathStep step);

String pathStepKey(PathStep step) => 'path.${step.name}';

@immutable
final class PathStepResult {
  const PathStepResult(
    this.step, {
    this.status = PathStepStatus.waiting,
    this.duration,
    this.detail,
    this.cause,
  });

  final PathStep step;
  final PathStepStatus status;
  final Duration? duration;
  final String? detail;
  final FailureCause? cause;

  bool get settled =>
      status != PathStepStatus.waiting && status != PathStepStatus.running;

  @override
  bool operator ==(Object other) =>
      other is PathStepResult &&
      other.step == step &&
      other.status == status &&
      other.duration == duration &&
      other.detail == detail &&
      other.cause == cause;

  @override
  int get hashCode => Object.hash(step, status, duration, detail, cause);
}

@immutable
final class PathResult {
  const PathResult({
    required this.scope,
    required this.steps,
    required this.startedAt,
    this.finishedAt,
    this.cancelled = false,
  });

  factory PathResult.start(PathScope scope, DateTime at) => PathResult(
    scope: scope,
    steps: [for (final step in scope.steps) PathStepResult(step)],
    startedAt: at,
  );

  final PathScope scope;
  final List<PathStepResult> steps;
  final DateTime startedAt;

  /// Null while the path runs.
  final DateTime? finishedAt;

  /// The Core left or a newer run took over before the end.
  final bool cancelled;

  bool get complete => finishedAt != null;

  PathStepResult? get failed =>
      steps.where((step) => step.status == PathStepStatus.fail).firstOrNull;

  PathStepResult? get running =>
      steps.where((step) => step.status == PathStepStatus.running).firstOrNull;

  bool get passed => complete && !cancelled && failed == null;

  /// The sum of the measured steps, the figure the collapsed card shows.
  Duration get duration => steps.fold(
    Duration.zero,
    (total, step) => total + (step.duration ?? Duration.zero),
  );

  PathStepResult? stepOf(PathStep step) =>
      steps.where((result) => result.step == step).firstOrNull;

  PathResult withStep(PathStepResult result) => PathResult(
    scope: scope,
    steps: [for (final step in steps) step.step == result.step ? result : step],
    startedAt: startedAt,
    finishedAt: finishedAt,
    cancelled: cancelled,
  );

  /// Settles what never ran as skipped.
  PathResult finish(DateTime at, {bool cancelled = false}) => PathResult(
    scope: scope,
    steps: [
      for (final step in steps)
        step.settled
            ? step
            : PathStepResult(step.step, status: PathStepStatus.skipped),
    ],
    startedAt: startedAt,
    finishedAt: at,
    cancelled: cancelled,
  );
}
