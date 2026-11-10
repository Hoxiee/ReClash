import 'package:flutter/foundation.dart';

import '../cause.dart';

/// What the supervisor knows about the running connection. The power face
/// reads it and decides nothing from it alone.
enum ConnectionPhase {
  /// Not running, or nothing checked yet.
  idle,

  /// From the tunnel coming up until the first passed check, within the
  /// connect budget.
  connecting,

  verified,

  /// The last check could not tell, such as with the app in the background.
  unknown,

  /// A heal plan has run longer than the recovering delay.
  recovering,

  /// Failed past the hysteresis.
  broken,

  waitingNetwork,
}

/// The healing steps. [bestNode] runs only on the user's tap; the rest climb
/// in this order, the first two automatically.
enum HealStep {
  bestNode,
  updateProfile,
  resetConnections,
  restartCore,
  restartTunnel,
}

@immutable
final class ConnectionHealth {
  const ConnectionHealth({
    this.phase = ConnectionPhase.idle,
    this.cause,
    this.step,
    this.stepDetail,
    this.repairFailed = false,
    this.checkedAt,
  });

  static const idle = ConnectionHealth();

  final ConnectionPhase phase;

  /// Why the latest check failed; kept while [phase] is broken or recovering.
  final FailureCause? cause;

  final HealStep? step;

  /// Data for the step's line, such as the node switched to.
  final String? stepDetail;

  /// The full ladder from the face ended without a passing check.
  final bool repairFailed;

  final DateTime? checkedAt;

  @override
  bool operator ==(Object other) =>
      other is ConnectionHealth &&
      other.phase == phase &&
      other.cause == cause &&
      other.step == step &&
      other.stepDetail == stepDetail &&
      other.repairFailed == repairFailed &&
      other.checkedAt == checkedAt;

  @override
  int get hashCode =>
      Object.hash(phase, cause, step, stepDetail, repairFailed, checkedAt);

  @override
  String toString() => 'ConnectionHealth(${phase.name}, ${cause?.id})';
}
