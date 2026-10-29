import 'package:riverpod/riverpod.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

import '../kernel.dart';
import '../snapshot.dart';

/// A passive source: it subscribes to state that already emits and turns it
/// into facts. A sensor never polls.
typedef Sensor = void Function(Ref ref, FactSink sink);

const List<Sensor> defaultSensors = [
  coreStatusSensor,
  modeSensor,
  batteryOptimizationSensor,
  subscriptionSensor,
];

void coreStatusSensor(Ref ref, FactSink sink) {
  ref.listen(
    coreStatusProvider,
    (_, status) => sink.put(Facts.coreStatus, status),
    fireImmediately: true,
  );
}

void modeSensor(Ref ref, FactSink sink) {
  ref.listen(
    effectiveModeProvider,
    (_, mode) => sink.put(Facts.mode, mode),
    fireImmediately: true,
  );
}

/// Off Android the provider answers true, which raises nothing.
void batteryOptimizationSensor(Ref ref, FactSink sink) {
  ref.listen(batteryOptimizationIgnoredProvider, (_, ignored) {
    if (ignored.hasValue) {
      sink.put(Facts.batteryOptimizationIgnored, ignored.value);
    }
  }, fireImmediately: true);
}

void subscriptionSensor(Ref ref, FactSink sink) {
  ref.listen(
    currentProfileProvider.select((profile) {
      final info = profile?.subscriptionInfo;
      if (profile == null || info == null) return null;
      return SubscriptionFact(
        profileId: profile.id,
        expiresAt: info.expireDate,
        used: info.upload + info.download,
        total: info.total,
      );
    }),
    (_, subscription) => sink.put(Facts.subscription, subscription),
    fireImmediately: true,
  );
}
