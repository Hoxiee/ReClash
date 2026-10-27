import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/speed_test/engine.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/speed_test.dart';

import '../features/speed_test_fakes.dart';

class _QuietRoutes extends RouteTracker {
  @override
  RouteState build() => const RouteState();
  @override
  void attach() {}
  @override
  void detach() {}
}

ProviderContainer _container({
  bool running = true,
  bool suspended = false,
  bool secureNetwork = false,
  int mixedPort = 7890,
  FakeSpeedBackend? backend,
  FakeSpeedNetwork? network,
}) {
  final runtime = network ?? FakeSpeedNetwork();
  final container = ProviderContainer(
    overrides: [
      isStartProvider.overrideWithValue(running),
      suspendProvider.overrideWithValue(suspended),
      providerSecureNetworkProvider.overrideWithValue(secureNetwork),
      selectedMapProvider.overrideWithValue(const {}),
      effectiveModeProvider.overrideWithValue(Mode.rule),
      routeTrackerProvider.overrideWith(_QuietRoutes.new),
      speedTestNetworkProvider.overrideWithValue(runtime),
      speedTestBackendsProvider.overrideWithValue([
        backend ?? FakeSpeedBackend(),
      ]),
      speedTestPlanProvider.overrideWithValue(
        const SpeedTestPlan(
          latencyCount: 3,
          probeInterval: Duration(milliseconds: 1),
          directionDuration: Duration(milliseconds: 100),
          runTimeout: Duration(seconds: 3),
        ),
      ),
    ],
  );
  container.read(patchClashConfigProvider.notifier).value =
      const PatchClashConfig().copyWith(mixedPort: mixedPort);
  final hold = container.listen(speedTestProvider, (_, _) {});
  addTearDown(hold.close);
  addTearDown(container.dispose);
  addTearDown(runtime.close);
  return container;
}

void main() {
  group('speedTestViaVpnProvider', () {
    test('uses the mixed port only when available', () {
      expect(_container().read(speedTestViaVpnProvider), isTrue);
      expect(_container(running: false).read(speedTestViaVpnProvider), isFalse);
      expect(
        _container(suspended: true).read(speedTestViaVpnProvider),
        isFalse,
      );
      expect(_container(mixedPort: 0).read(speedTestViaVpnProvider), isFalse);
      expect(
        _container(secureNetwork: true).read(speedTestViaVpnProvider),
        isFalse,
      );
    });
  });

  group('SpeedTest', () {
    test('building the provider does not open a backend', () {
      final backend = FakeSpeedBackend();
      _container(backend: backend).read(speedTestProvider);
      expect(backend.opens, 0);
    });

    test('requires a network snapshot approved by the caller', () async {
      final backend = FakeSpeedBackend();
      final container = _container(backend: backend);
      await container.read(speedTestProvider.notifier).start();
      expect(backend.opens, 0);
      expect(container.read(speedTestProvider).failure, 'confirmationRequired');
    });

    test(
      'a confirmed run preserves its route and completes all metrics',
      () async {
        final network = FakeSpeedNetwork();
        final container = _container(running: false, network: network);
        await container
            .read(speedTestProvider.notifier)
            .start(
              settings: const SpeedTestSettings(budgetMiB: 25),
              expectedNetwork: network.snapshot,
            );
        final state = container.read(speedTestProvider);
        expect(state.phase, SpeedTestPhase.done);
        expect(state.downloadMbps, isNotNull);
        expect(state.uploadMbps, isNotNull);
        expect(state.viaVpn, isFalse);
      },
    );

    test(
      'does not fall back to another service for an unknown platform',
      () async {
        final backend = FakeSpeedBackend();
        final network = FakeSpeedNetwork();
        final container = _container(backend: backend, network: network);
        await container
            .read(speedTestProvider.notifier)
            .start(
              settings: const SpeedTestSettings(backendId: 'missing'),
              expectedNetwork: network.snapshot,
            );
        expect(backend.opens, 0);
        expect(container.read(speedTestProvider).failure, 'backendUnavailable');
      },
    );

    test(
      'a network change after confirmation prevents any test request',
      () async {
        final backend = FakeSpeedBackend();
        final network = FakeSpeedNetwork();
        final before = network.snapshot;
        network.snapshot = const NetworkCostSnapshot(
          cost: NetworkCost.metered,
          identity: 'cellular',
        );
        final container = _container(backend: backend, network: network);
        await container
            .read(speedTestProvider.notifier)
            .start(expectedNetwork: before);
        expect(backend.opens, 0);
        expect(container.read(speedTestProvider).failure, 'routeChanged');
      },
    );

    test('a running test stops when a network becomes metered', () async {
      final session = FakeSpeedSession(holdDownload: true);
      final network = FakeSpeedNetwork();
      final container = _container(
        backend: FakeSpeedBackend(session: session),
        network: network,
      );
      final operation = container
          .read(speedTestProvider.notifier)
          .start(expectedNetwork: network.snapshot);
      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(container.read(speedTestProvider).running, isTrue);
      network.change(
        const NetworkCostSnapshot(
          cost: NetworkCost.metered,
          identity: 'cellular',
        ),
      );
      await operation;
      expect(session.closed, isTrue);
      expect(container.read(speedTestProvider).failure, 'routeChanged');
      session.held.complete();
    });

    test(
      'changing mixed ports cancels even when both routes are proxied',
      () async {
        final session = FakeSpeedSession(holdDownload: true);
        final network = FakeSpeedNetwork();
        final container = _container(
          backend: FakeSpeedBackend(session: session),
          network: network,
        );
        final operation = container
            .read(speedTestProvider.notifier)
            .start(expectedNetwork: network.snapshot);
        await Future<void>.delayed(const Duration(milliseconds: 15));
        container.read(patchClashConfigProvider.notifier).value =
            const PatchClashConfig().copyWith(mixedPort: 7891);
        await container.pump();
        await operation;
        expect(session.closed, isTrue);
        expect(container.read(speedTestProvider).failure, 'routeChanged');
        session.held.complete();
      },
    );

    test('cancel while idle leaves state untouched', () {
      final container = _container();
      final before = container.read(speedTestProvider);
      container.read(speedTestProvider.notifier).cancel();
      expect(container.read(speedTestProvider), same(before));
    });
  });
}
