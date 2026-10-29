/// The closed failure taxonomy every diagnostic layer and consumer speaks.
///
/// The Go side (`core/doctor.go`) classifies mihomo errors into the same set
/// and sends [id] on the wire.
enum FailureCause {
  noNetwork('noNetwork'),
  captivePortal('captivePortal'),
  clockSkew('clockSkew'),
  coreDown('coreDown'),
  profileInvalid('profileInvalid'),
  subscriptionExpired('subscriptionExpired'),
  trafficExhausted('trafficExhausted'),
  tunnelDenied('tunnelDenied'),
  tunnelTaken('tunnelTaken'),
  dnsFailed('dnsFailed'),
  serverDns('serverDns'),
  refused('refused'),
  timeout('timeout'),
  reset('reset'),
  tlsHandshake('tlsHandshake'),
  authRejected('authRejected'),
  udpBlocked('udpBlocked'),
  noUpstream('noUpstream'),
  serviceBlocked('serviceBlocked'),
  unknown('unknown');

  const FailureCause(this.id);

  final String id;

  static final _byId = {for (final cause in values) cause.id: cause};

  /// An empty or missing id means the operation did not fail; an id this
  /// build does not know is still a failure.
  static FailureCause? fromWire(String? id) {
    if (id == null || id.isEmpty) return null;
    return _byId[id] ?? FailureCause.unknown;
  }
}
