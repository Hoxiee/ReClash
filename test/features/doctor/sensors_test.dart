import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/sensors/sensors.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

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

  group('use-system-hosts', () {
    ProviderContainer container({bool? applied, bool? override}) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appliedUseSystemHostsProvider.notifier).value = applied;
      if (override != null) {
        const config = PatchClashConfig();
        container.read(patchClashConfigProvider.notifier).value = config
            .copyWith(
              dns: config.dns.copyWith(useSystemHosts: override),
              dnsOverrideKeys: {DnsOverrideKey.useSystemHosts},
            );
      }
      return container;
    }

    bool read(ProviderContainer container) =>
        container.read(effectiveUseSystemHostsProvider);

    test('reads the profile while no override is set', () {
      expect(read(container(applied: false)), isFalse);
      expect(read(container()), isTrue);
    });

    test('an override counts before the config is applied again', () {
      expect(read(container(applied: true, override: false)), isFalse);
      expect(read(container(applied: false, override: true)), isTrue);
    });
  });
}
