import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/sensors/sensors.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/providers/on_demand.dart';

class _BatteryStatus extends BatteryOptimizationIgnored {
  _BatteryStatus(this.updates);

  final Stream<bool?> updates;

  @override
  Stream<bool?> build() => updates;
}

class _Facts implements FactSink {
  final values = <String, Object>{};

  @override
  void put<T extends Object>(FactKey<T> key, T? value, {Duration? ttl}) {
    if (value == null) {
      values.remove(key.id);
    } else {
      values[key.id] = value;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'battery sensor replaces stale restrictions with unknown or exempt',
    () async {
      final changes = StreamController<bool?>();
      final facts = _Facts();
      final sensor = Provider<void>(
        (ref) => batteryOptimizationSensor(ref, facts),
      );
      final container = ProviderContainer(
        overrides: [
          batteryOptimizationIgnoredProvider.overrideWith(
            () => _BatteryStatus(changes.stream),
          ),
        ],
      );
      addTearDown(changes.close);
      addTearDown(container.dispose);
      container.listen(sensor, (_, _) {});

      changes.add(false);
      await pumpEventQueue();
      expect(facts.values[Facts.batteryOptimizationIgnored.id], isFalse);

      changes.add(null);
      await pumpEventQueue();
      expect(
        facts.values.containsKey(Facts.batteryOptimizationIgnored.id),
        isFalse,
      );

      changes.add(true);
      await pumpEventQueue();
      expect(facts.values[Facts.batteryOptimizationIgnored.id], isTrue);
    },
  );
}
