import 'package:reclash/models/models.dart';

const double _serverFailureThreshold = 0.5;
const int _minBucketAttempts = 4;
const double _healthyBucketRatio = 0.2;

const _clientCauses = {'vpnNotActive', 'tunNotActive'};
const _networkCauses = {
  'captivePortal',
  'noPhysicalNetwork',
  'networkUnvalidated',
};

/// Errs toward inconclusive: a false server blame hands the provider a lie.
SubscriptionFault subscriptionFaultOf({
  required String terrain,
  required String doctorCauseCode,
  required DoctorLayer doctorLayer,
  required SubscriptionUpdateReport? update,
  required SubscriptionDialReport dial,
}) {
  if (terrain == 'portal' ||
      terrain == 'offline' ||
      _networkCauses.contains(doctorCauseCode)) {
    return SubscriptionFault.yourNetwork;
  }
  if (_clientCauses.contains(doctorCauseCode) ||
      doctorLayer == DoctorLayer.capture) {
    return SubscriptionFault.client;
  }
  if (update != null && update.attempted && !update.succeeded) {
    return SubscriptionFault.subscription;
  }
  if (_pointsAtServer(terrain: terrain, update: update, dial: dial)) {
    return SubscriptionFault.server;
  }
  return SubscriptionFault.inconclusive;
}

bool _pointsAtServer({
  required String terrain,
  required SubscriptionUpdateReport? update,
  required SubscriptionDialReport dial,
}) {
  final networkAlive =
      terrain == 'normal' || terrain == 'whitelist' || terrain.isEmpty;
  if (!networkAlive) return false;
  if (update != null && update.attempted && !update.succeeded) return false;
  if (dial.attempts < _minBucketAttempts) return false;
  if (dial.failure / dial.attempts < _serverFailureThreshold) return false;
  return _hasContrastingEgress(dial.byEgress);
}

/// One egress failing while another works points at the node; uniform failure
/// reads as local interference, so it stays inconclusive.
bool _hasContrastingEgress(List<SubscriptionOutcome> byEgress) {
  var failing = false;
  var working = false;
  for (final egress in byEgress) {
    if (egress.key.isEmpty || egress.attempts < _minBucketAttempts) continue;
    final ratio = egress.failure / egress.attempts;
    if (ratio >= _serverFailureThreshold) failing = true;
    if (ratio <= _healthyBucketRatio) working = true;
  }
  return failing && working;
}
