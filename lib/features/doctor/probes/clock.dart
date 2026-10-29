import 'package:reclash/models/models.dart';

import '../cause.dart';
import '../snapshot.dart';
import 'scheduler.dart';

typedef ClockSkewCall =
    Future<ClockSkewResult?> Function(ClockSkewParams params);

const clockSkewTtl = Duration(minutes: 10);

/// Measured against the HTTP `Date` of [url], reached the way the tunnel
/// routes it; the header's one-second resolution is far below the thresholds.
ProbeRequest<Duration> clockSkewProbe(
  ClockSkewCall call, {
  required String url,
  Duration timeout = const Duration(seconds: 5),
}) {
  return ProbeRequest(
    key: Facts.clockSkew.id,
    cost: CheckCost.network,
    ttl: clockSkewTtl,
    intent: url,
    fact: Facts.clockSkew,
    run: (_) async {
      final result = await call(
        ClockSkewParams(url: url, timeout: timeout.inMilliseconds),
      );
      if (result == null) {
        throw const ProbeFailure(FailureCause.unknown, 'no answer');
      }
      if (FailureCause.fromWire(result.cause) case final cause?) {
        throw ProbeFailure(cause, result.message);
      }
      return Duration(milliseconds: result.skewMs);
    },
  );
}
