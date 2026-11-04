import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/speed_test/history.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/speed_test.dart';

import '../features/speed_test_fakes.dart';
import '../helpers/preferences.dart';

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
  FakeSpeedClient? client,
  FakeSpeedNetwork? network,
  MemorySpeedHistory? history,
}) {
  final runtime = network ?? FakeSpeedNetwork();
  final container = ProviderContainer(
    overrides: [
      isStartProvider.overrideWithValue(running),
      suspendProvider.overrideWithValue(suspended),
      providerSecureNetworkProvider.overrideWithValue(false),
      selectedMapProvider.overrideWithValue(const {}),
      effectiveModeProvider.overrideWithValue(Mode.rule),
      routeTrackerProvider.overrideWith(_QuietRoutes.new),
      speedTestNetworkProvider.overrideWithValue(runtime),
      speedTestClientProvider.overrideWithValue(client ?? FakeSpeedClient()),
      speedTestHistoryStoreProvider.overrideWithValue(
        history ?? MemorySpeedHistory(),
      ),
    ],
  );
  final hold = container.listen(speedTestProvider, (_, _) {});
  addTearDown(hold.close);
  addTearDown(container.dispose);
  addTearDown(runtime.close);
  return container;
}

void main() {
  setUpAll(mockPreferences);

  test('opening the provider never starts a test or server discovery', () {
    final client = FakeSpeedClient();
    _container(client: client).read(speedTestProvider);
    expect(client.requests, isEmpty);
    expect(client.serverRequests, isEmpty);
  });

  for (final cost in [
    NetworkCost.unmetered,
    NetworkCost.metered,
    NetworkCost.unknown,
  ]) {
    test('starts immediately without confirmation on ${cost.name}', () async {
      final client = FakeSpeedClient();
      final history = MemorySpeedHistory();
      final container = _container(
        client: client,
        history: history,
        network: FakeSpeedNetwork(
          snapshot: NetworkCostSnapshot(cost: cost, identity: 'network'),
        ),
      );
      await container.read(speedTestProvider.notifier).start();
      expect(client.requests, hasLength(1));
      expect(container.read(speedTestProvider).phase, SpeedTestPhase.done);
      expect(container.read(speedTestProvider).downloadMbps, 123.4);
      expect(history.records, hasLength(1));
    });
  }

  test('offline never starts native traffic', () async {
    final client = FakeSpeedClient();
    final container = _container(
      client: client,
      network: FakeSpeedNetwork(
        snapshot: const NetworkCostSnapshot(
          cost: NetworkCost.offline,
          identity: 'offline',
        ),
      ),
    );
    await container.read(speedTestProvider.notifier).start();
    expect(client.requests, isEmpty);
    expect(container.read(speedTestProvider).failure, 'offline');
  });

  test('network read errors leave a retryable failed state', () async {
    final network = FakeSpeedNetwork()..error = StateError('platform failed');
    final client = FakeSpeedClient();
    final container = _container(client: client, network: network);
    final notifier = container.read(speedTestProvider.notifier);
    await notifier.start();
    expect(container.read(speedTestProvider).phase, SpeedTestPhase.failed);
    network.error = null;
    await notifier.start();
    expect(container.read(speedTestProvider).phase, SpeedTestPhase.done);
  });

  test(
    'revalidates the network before dispatching the native request',
    () async {
      final client = FakeSpeedClient();
      final network = FakeSpeedNetwork()
        ..secondRead = const NetworkCostSnapshot(
          cost: NetworkCost.metered,
          identity: 'cellular',
        );
      final container = _container(client: client, network: network);
      await container.read(speedTestProvider.notifier).start();
      expect(client.requests, isEmpty);
      expect(container.read(speedTestProvider).failure, 'routeChanged');
    },
  );

  test('a pinned test route never changes the active selections', () async {
    final client = FakeSpeedClient();
    final container = _container(client: client);
    container.read(speedTestProxyProvider.notifier).select('test-node');
    final before = container.read(selectedMapProvider);
    await container.read(speedTestProvider.notifier).start();
    expect(client.requests.single['proxyName'], 'test-node');
    expect(client.requests.single['direct'], isFalse);
    expect(container.read(selectedMapProvider), same(before));
  });

  test(
    'a stopped Core cannot silently replace a pinned proxy with DIRECT',
    () async {
      final client = FakeSpeedClient();
      final container = _container(client: client, running: false);
      container.read(speedTestProxyProvider.notifier).select('test-node');
      await container.read(speedTestProvider.notifier).start();
      expect(client.requests, isEmpty);
      expect(container.read(speedTestProvider).failure, 'proxyUnavailable');
    },
  );

  test(
    'direct is explicit or follows a stopped Core with no pinned route',
    () async {
      final stopped = FakeSpeedClient();
      final container = _container(client: stopped, running: false);
      await container.read(speedTestProvider.notifier).start();
      expect(stopped.requests.single['direct'], isTrue);
      expect(container.read(speedTestViaVpnProvider), isFalse);
      final direct = FakeSpeedClient();
      final active = _container(client: direct);
      active.read(speedTestProxyProvider.notifier).select('DIRECT');
      await active.read(speedTestProvider.notifier).start();
      expect(direct.requests.single['direct'], isTrue);
    },
  );

  test('unknown platform fails without trying another one', () async {
    final client = FakeSpeedClient();
    final container = _container(client: client);
    await container
        .read(speedTestProvider.notifier)
        .start(settings: const SpeedTestSettings(backendId: 'missing'));
    expect(client.requests, isEmpty);
    expect(container.read(speedTestProvider).failure, 'backendUnavailable');
  });

  test('latency-only requests have no transfer budget', () async {
    final client = FakeSpeedClient();
    final container = _container(client: client);
    await container
        .read(speedTestProvider.notifier)
        .start(
          settings: const SpeedTestSettings(mode: SpeedTestMode.latencyOnly),
        );
    expect(client.requests.single['mode'], 'latencyOnly');
    expect(client.requests.single['byteLimit'], 0);
    expect(container.read(speedTestProvider).latency!.medianMs, 18);
    expect(container.read(speedTestProvider).downloadMbps, isNull);
  });

  test(
    'cancel releases a stalled start and ignores its late completion',
    () async {
      final gate = Completer<bool>();
      final client = FakeSpeedClient()..startGate = gate;
      final container = _container(client: client);
      final notifier = container.read(speedTestProvider.notifier);
      final first = notifier.start();
      await client.started.future;
      final firstId = client.requests.single['requestId'];
      notifier.cancel();
      await first;
      expect(container.read(speedTestProvider).phase, SpeedTestPhase.cancelled);
      client.startGate = null;
      await notifier.start();
      final secondId = container.read(speedTestProvider).requestId;
      gate.complete(true);
      await Future<void>.delayed(Duration.zero);
      expect(client.cancellations, contains(firstId));
      expect(container.read(speedTestProvider).requestId, secondId);
      expect(container.read(speedTestProvider).phase, SpeedTestPhase.done);
    },
  );

  test(
    'a route change cancels a stalled snapshot without waiting for it',
    () async {
      final gate = Completer<SpeedTestState?>();
      final client = FakeSpeedClient()..snapshotGate = gate;
      final container = _container(client: client);
      final running = container.read(speedTestProvider.notifier).start();
      await client.started.future;
      await Future<void>.delayed(Duration.zero);
      container.read(patchClashConfigProvider.notifier).value =
          const PatchClashConfig().copyWith(mixedPort: 9876);
      await container.pump();
      await running;
      expect(container.read(speedTestProvider).failure, 'routeChanged');
      expect(client.cancellations, isNotEmpty);
      gate.complete(null);
    },
  );

  test('a network change stops a running measurement', () async {
    final client = FakeSpeedClient(complete: false);
    final network = FakeSpeedNetwork();
    final container = _container(client: client, network: network);
    final operation = container.read(speedTestProvider.notifier).start();
    await client.started.future;
    network.change(
      const NetworkCostSnapshot(cost: NetworkCost.metered, identity: 'mobile'),
    );
    await operation;
    expect(container.read(speedTestProvider).failure, 'routeChanged');
  });

  test('duplicate taps start only one native job', () async {
    final client = FakeSpeedClient(complete: false);
    final container = _container(client: client);
    final notifier = container.read(speedTestProvider.notifier);
    final operation = notifier.start();
    await notifier.start();
    await client.started.future;
    expect(client.requests, hasLength(1));
    notifier.cancel();
    await operation;
  });

  test('rejected starts and mismatched snapshots fail closed', () async {
    for (final client in [
      FakeSpeedClient()..accepted = false,
      FakeSpeedClient()..wrongId = true,
      FakeSpeedClient()..snapshotError = StateError('IPC failed'),
    ]) {
      final container = _container(client: client);
      await container.read(speedTestProvider.notifier).start();
      expect(container.read(speedTestProvider).phase, SpeedTestPhase.failed);
      expect(client.cancellations, isNotEmpty);
    }
  });

  test(
    'history write failure does not erase successful measurements',
    () async {
      final history = MemorySpeedHistory()..saveError = StateError('disk full');
      final container = _container(history: history);
      await container.read(speedTestProvider.notifier).start();
      final state = container.read(speedTestProvider);
      expect(state.phase, SpeedTestPhase.done);
      expect(state.downloadMbps, 123.4);
      expect(state.historySaveFailed, isTrue);
    },
  );

  test('server discovery is explicit, route-pinned and cancellable', () async {
    final client = FakeSpeedClient()
      ..serversGate = Completer<List<SpeedTestServer>>();
    final network = FakeSpeedNetwork();
    final container = _container(client: client, network: network);
    final finder = container.read(speedTestServersProvider.notifier);
    expect(client.serverRequests, isEmpty);
    container.read(speedTestProxyProvider.notifier).select('node');
    final query = finder.search(' City ');
    await Future<void>.delayed(Duration.zero);
    expect(client.serverRequests.single['proxyName'], 'node');
    expect(client.serverRequests.single['search'], 'City');
    network.change(
      const NetworkCostSnapshot(cost: NetworkCost.offline, identity: 'offline'),
    );
    await query;
    expect(container.read(speedTestServersProvider), isNull);
    expect(
      client.cancellations,
      contains(client.serverRequests.single['requestId']),
    );
    client.serversGate!.complete(const []);
  });

  test('cancel while idle leaves the state untouched', () {
    final container = _container();
    final before = container.read(speedTestProvider);
    container.read(speedTestProvider.notifier).cancel();
    expect(container.read(speedTestProvider), same(before));
  });
}
