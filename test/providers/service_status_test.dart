import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/route_state.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/providers/service_status.dart';

class _MockCoreHandler extends Mock implements CoreHandlerInterface {}

class _SeededRouteTracker extends RouteTracker {
  _SeededRouteTracker(this.initial);

  final RouteState initial;

  @override
  RouteState build() => initial;

  void setRoute(RouteState value) => state = value;
}

void main() {
  const route = RouteState(
    coreEpoch: 3,
    picksVersion: 7,
    hostEpoch: 2,
    picks: {'Proxy': 'node-a'},
    synced: true,
    live: true,
  );

  late _MockCoreHandler core;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const ServiceCheckParams(timeout: 10000));
  });

  setUp(() {
    core = _MockCoreHandler();
  });

  void buildContainer({RouteState initial = route}) {
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        routeTrackerProvider.overrideWith(() => _SeededRouteTracker(initial)),
      ],
    );
    addTearDown(container.dispose);
  }

  for (final proxied in [false, true]) {
    test('batches requested services with proxied=$proxied', () async {
      when(() => core.serviceCheck(any())).thenAnswer(
        (_) async => const [
          ServiceCheckItem(
            name: 'google',
            status: 'available',
            delay: 42,
            region: 'US',
            chains: ['node-a', 'Proxy'],
            coreEpoch: 3,
            picksVersion: 7,
          ),
          ServiceCheckItem(
            name: 'youtube',
            status: 'restricted',
            coreEpoch: 3,
            picksVersion: 7,
          ),
        ],
      );
      buildContainer(initial: route.copyWith(proxied: proxied));

      container.read(serviceStatusProvider.notifier).refresh([
        ServiceTarget.google,
        ServiceTarget.youtube,
      ]);
      await pumpEventQueue();

      final params =
          verify(() => core.serviceCheck(captureAny())).captured.single
              as ServiceCheckParams;
      expect(params.names, ['google', 'youtube']);
      expect(params.proxyName, proxied ? routedOutbound : directOutbound);
      expect(params.timeout, serviceProbeTimeout.inMilliseconds);
      final state = container.read(serviceStatusProvider);
      final google = state.entryOf(ServiceTarget.google);
      expect(google.phase, ProbePhase.fresh);
      expect(google.value?.status, ServiceProbeStatus.available);
      expect(google.value?.delay, 42);
      expect(google.value?.region, 'US');
      expect(
        google.stamp,
        RouteStamp(
          coreEpoch: 3,
          picksVersion: 7,
          hostEpoch: 2,
          proxied: proxied,
          chains: const ['node-a', 'Proxy'],
        ),
      );
      expect(state.entryOf(ServiceTarget.youtube).phase, ProbePhase.fresh);
      expect(
        state.valueOf(ServiceTarget.youtube)?.status,
        ServiceProbeStatus.restricted,
      );
      expect(state.entries.length, 2);
    });
  }

  for (final status in ServiceProbeStatus.values) {
    test('classifies ${status.id} and stamps legacy replies', () async {
      when(() => core.serviceCheck(any())).thenAnswer(
        (_) async => [ServiceCheckItem(name: 'google', status: status.id)],
      );
      buildContainer();

      container.read(serviceStatusProvider.notifier).refresh([
        ServiceTarget.google,
      ]);
      await pumpEventQueue();

      final entry = container
          .read(serviceStatusProvider)
          .entryOf(ServiceTarget.google);
      final failed =
          status == ServiceProbeStatus.timeout ||
          status == ServiceProbeStatus.failed;
      expect(entry.phase, failed ? ProbePhase.failed : ProbePhase.fresh);
      expect(entry.value?.status, status);
      expect(
        entry.stamp,
        const RouteStamp(
          coreEpoch: 3,
          picksVersion: 7,
          hostEpoch: 2,
          proxied: false,
        ),
      );
    });
  }

  test(
    'refresh keeps the previous result and coalesces duplicate requests',
    () async {
      when(() => core.serviceCheck(any())).thenAnswer(
        (_) async => const [
          ServiceCheckItem(name: 'google', status: 'available', delay: 42),
        ],
      );
      buildContainer();
      final notifier = container.read(serviceStatusProvider.notifier);
      notifier.refresh([ServiceTarget.google]);
      await pumpEventQueue();
      final previous = container
          .read(serviceStatusProvider)
          .valueOf(ServiceTarget.google);

      final pending = Completer<List<ServiceCheckItem>>();
      when(() => core.serviceCheck(any())).thenAnswer((_) => pending.future);
      notifier.refresh([ServiceTarget.google]);
      await pumpEventQueue();
      final refreshing = container.read(serviceStatusProvider);
      expect(refreshing.isLoading(ServiceTarget.google), isTrue);
      expect(refreshing.valueOf(ServiceTarget.google), same(previous));
      notifier.refresh([ServiceTarget.google]);
      await pumpEventQueue();
      verify(() => core.serviceCheck(any())).called(2);

      pending.complete(const [
        ServiceCheckItem(name: 'google', status: 'blocked', delay: 64),
      ]);
      await pumpEventQueue();
      final refreshed = container.read(serviceStatusProvider);
      expect(refreshed.isLoading(ServiceTarget.google), isFalse);
      expect(
        refreshed.valueOf(ServiceTarget.google)?.status,
        ServiceProbeStatus.blocked,
      );
      expect(refreshed.valueOf(ServiceTarget.google)?.delay, 64);
      verifyNever(() => core.serviceCheck(any()));
    },
  );

  test(
    'a route change discards cached checks without starting unwatched probes',
    () async {
      when(() => core.serviceCheck(any())).thenAnswer(
        (_) async => const [
          ServiceCheckItem(name: 'google', status: 'available'),
        ],
      );
      buildContainer();
      container.read(serviceStatusProvider.notifier).refresh([
        ServiceTarget.google,
      ]);
      await pumpEventQueue();
      expect(container.read(serviceStatusProvider).entries, isNotEmpty);

      final tracker =
          container.read(routeTrackerProvider.notifier) as _SeededRouteTracker;
      tracker.setRoute(route.copyWith(hostEpoch: 3));
      await pumpEventQueue();

      expect(container.read(serviceStatusProvider).entries, isEmpty);
      verify(() => core.serviceCheck(any())).called(1);
    },
  );
}
