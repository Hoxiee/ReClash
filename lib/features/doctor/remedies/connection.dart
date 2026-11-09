import 'remedy.dart';

/// A rung of the connection ladder or an account transition: our own state,
/// changed through the owner that already serializes it.
class ConnectionRemedy implements Remedy {
  const ConnectionRemedy(this.id, this._run, {this.settle = Duration.zero});

  /// Re-tests the main group and selects its best live node.
  static const bestNode = 'group.bestNode';

  /// Closes connections and flushes the DNS cache.
  static const resetConnections = 'connections.reset';

  static const restartCore = 'core.restart';

  /// Stops and starts the tunnel through its lifecycle owner.
  static const reconnect = 'tunnel.reconnect';

  static const stopForAccount = 'tunnel.stopForAccount';
  static const resumeAfterRenewal = 'tunnel.resumeAfterRenewal';

  @override
  final String id;

  /// Throws when the step could not be carried out.
  final Future<void> Function() _run;

  @override
  final Duration settle;

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.app;

  @override
  bool get undoable => false;

  @override
  Future<void> apply(RemedyRequest request) => _run();
}
