import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/features/speed_test/client.dart';
import 'package:reclash/features/speed_test/history.dart';
import 'package:reclash/features/speed_test/types.dart';
import 'package:reclash/models/speed_test.dart';

import 'app.dart';
import 'config.dart';
import 'core.dart';
import 'route_state.dart';
import 'routing.dart';
import 'state.dart';

export 'package:reclash/features/speed_test/types.dart';

final speedTestClientProvider = Provider<SpeedTestClient>(
  (ref) => CoreSpeedTestClient(ref.watch(coreHandlerProvider)),
);

final speedTestNetworkProvider = Provider<NetworkCostMonitor>(
  (ref) => createNetworkCostMonitor(),
);

class SpeedTestProxy extends Notifier<String> {
  @override
  String build() => '';

  void select(String name) => state = name;
}

final speedTestProxyProvider = NotifierProvider<SpeedTestProxy, String>(
  SpeedTestProxy.new,
);

final _speedTestRouteProvider = Provider(
  (ref) => (
    active: ref.watch(isStartProvider) && !ref.watch(suspendProvider),
    proxy: ref.watch(speedTestProxyProvider),
    profile: ref.watch(currentProfileIdProvider),
    patch: ref.watch(patchClashConfigProvider),
    selected: ref.watch(selectedMapProvider),
    mode: ref.watch(effectiveModeProvider),
  ),
);

final speedTestViaVpnProvider = Provider<bool>((ref) {
  final route = ref.watch(_speedTestRouteProvider);
  return route.active && route.proxy != 'DIRECT';
});

class _SpeedTestRun {
  _SpeedTestRun(this.id, this.client);

  final String id;
  final SpeedTestClient client;
  final stopped = Completer<void>();
  Timer? _pause;

  Future<T?> wait<T>(Future<T> work) =>
      Future.any<T?>([work, stopped.future.then((_) => null)]);

  Future<void> pause() async {
    final ready = Completer<void>();
    _pause = Timer(const Duration(milliseconds: 200), ready.complete);
    await wait(ready.future);
    _pause = null;
  }

  void stop() {
    if (stopped.isCompleted) return;
    _pause?.cancel();
    stopped.complete();
    unawaited(client.cancel(id).catchError((Object _) {}));
  }
}

class SpeedTest extends Notifier<SpeedTestState> {
  _SpeedTestRun? _active;
  int _serial = 0;

  @override
  SpeedTestState build() {
    ref.listen(
      _speedTestRouteProvider,
      (_, _) => cancel(failure: 'routeChanged'),
    );
    ref.listen(appVisibleProvider, (_, visible) {
      if (!visible) cancel();
    });
    ref.listen(routeTrackerProvider, (previous, next) {
      if (previous?.synced == true &&
          (previous!.coreEpoch != next.coreEpoch ||
              previous.routeVersion != next.routeVersion ||
              previous.hostEpoch != next.hostEpoch)) {
        cancel(failure: 'routeChanged');
      }
    });
    ref.onDispose(() {
      _active?.stop();
      _active = null;
    });
    return const SpeedTestState();
  }

  Future<void> start({SpeedTestSettings? settings}) async {
    if (_active != null) return;
    final selected = settings ?? ref.read(appSettingProvider).speedTest;
    final route = ref.read(_speedTestRouteProvider);
    final direct = !route.active || route.proxy == 'DIRECT';
    if (direct && route.proxy.isNotEmpty && route.proxy != 'DIRECT') {
      state = const SpeedTestState(
        phase: SpeedTestPhase.failed,
        failure: 'proxyUnavailable',
      );
      return;
    }
    if (!SpeedTestSettings.platforms.containsKey(selected.backendId)) {
      state = SpeedTestState(
        phase: SpeedTestPhase.failed,
        backendId: selected.backendId,
        failure: 'backendUnavailable',
      );
      return;
    }
    final run = _SpeedTestRun(
      'speed-${DateTime.now().microsecondsSinceEpoch}-${++_serial}',
      ref.read(speedTestClientProvider),
    );
    _active = run;
    state = SpeedTestState(
      requestId: run.id,
      phase: SpeedTestPhase.running,
      backendId: selected.backendId,
      byteLimit: selected.mode == SpeedTestMode.complete
          ? selected.byteLimit
          : 0,
      viaVpn: !direct,
      proxyName: route.proxy,
      protocol: selected.protocol.value,
    );
    final network = ref.read(speedTestNetworkProvider);
    final tracker = ref.read(routeTrackerProvider.notifier);
    StreamSubscription<NetworkCostSnapshot>? subscription;
    var attached = false;
    final deadline = Timer(const Duration(seconds: 155), () {
      if (identical(_active, run)) cancel(failure: 'timeout');
    });
    try {
      final before = await run.wait(network.read());
      if (!_owns(run) || before == null) return;
      if (before.cost == NetworkCost.offline) {
        cancel(failure: 'offline');
        return;
      }
      subscription = network.changes.listen(
        (next) {
          if (_owns(run) && next != before) cancel(failure: 'routeChanged');
        },
        onError: (Object _) {
          if (_owns(run)) cancel(failure: 'routeChanged');
        },
      );
      tracker.attach();
      attached = true;
      final current = await run.wait(network.read());
      if (!_owns(run)) return;
      if (current != before || ref.read(_speedTestRouteProvider) != route) {
        cancel(failure: 'routeChanged');
        return;
      }
      final accepted = await run.wait(
        run.client.start(
          selected,
          requestId: run.id,
          proxyName: route.proxy,
          direct: direct,
        ),
      );
      if (!_owns(run)) return;
      if (accepted != true) {
        cancel(failure: 'coreUnavailable');
        return;
      }
      while (_owns(run)) {
        final next = await run.wait(run.client.snapshot(run.id));
        if (!_owns(run)) return;
        if (next == null ||
            next.requestId != run.id ||
            next.phase == SpeedTestPhase.idle) {
          cancel(failure: 'coreUnavailable');
          return;
        }
        final tracked = ref.read(routeTrackerProvider);
        if (tracked.synced &&
            next.coreEpoch != 0 &&
            (tracked.coreEpoch != next.coreEpoch ||
                tracked.routeVersion != next.routeVersion)) {
          cancel(failure: 'routeChanged');
          return;
        }
        state = next.copyWith(checkedAt: next.running ? null : DateTime.now());
        if (!next.running) {
          final result = state;
          _active = null;
          try {
            await ref.read(speedTestHistoryProvider.notifier).add(result);
          } on Object {
            if (ref.mounted && state.requestId == run.id) {
              state = state.copyWith(historySaveFailed: true);
            }
          }
          return;
        }
        await run.pause();
      }
    } on Object {
      if (_owns(run)) cancel(failure: 'unavailable');
    } finally {
      deadline.cancel();
      await subscription?.cancel();
      if (attached) tracker.detach();
      if (identical(_active, run)) _active = null;
      run.stop();
    }
  }

  bool _owns(_SpeedTestRun run) => ref.mounted && identical(_active, run);

  void cancel({String? failure}) {
    final run = _active;
    if (run == null) return;
    _active = null;
    run.stop();
    state = state.copyWith(
      phase: failure == null ? SpeedTestPhase.cancelled : SpeedTestPhase.failed,
      failure: failure,
      liveMbps: null,
      checkedAt: DateTime.now(),
    );
  }
}

class SpeedTestServers extends Notifier<AsyncValue<List<SpeedTestServer>>?> {
  _SpeedTestRun? _query;

  @override
  AsyncValue<List<SpeedTestServer>>? build() {
    ref.listen(_speedTestRouteProvider, (_, _) => cancel());
    ref.listen(appVisibleProvider, (_, visible) {
      if (!visible) cancel();
    });
    ref.listen(routeTrackerProvider, (previous, next) {
      if (previous?.synced == true &&
          (previous!.coreEpoch != next.coreEpoch ||
              previous.routeVersion != next.routeVersion ||
              previous.hostEpoch != next.hostEpoch)) {
        cancel();
      }
    });
    ref.onDispose(() => _query?.stop());
    return null;
  }

  void cancel() {
    _query?.stop();
    _query = null;
    if (ref.mounted) state = null;
  }

  Future<void> search(String search) async {
    cancel();
    final route = ref.read(_speedTestRouteProvider);
    final direct = !route.active || route.proxy == 'DIRECT';
    if (direct && route.proxy.isNotEmpty && route.proxy != 'DIRECT') {
      state = AsyncError(
        StateError('Proxy is unavailable'),
        StackTrace.current,
      );
      return;
    }
    final run = _SpeedTestRun(
      'speed-servers-${DateTime.now().microsecondsSinceEpoch}',
      ref.read(speedTestClientProvider),
    );
    _query = run;
    state = const AsyncLoading();
    final network = ref.read(speedTestNetworkProvider);
    StreamSubscription<NetworkCostSnapshot>? subscription;
    try {
      final before = await run.wait(network.read());
      if (!ref.mounted || !identical(_query, run)) return;
      if (before == null || before.cost == NetworkCost.offline) {
        throw StateError('No network connection');
      }
      subscription = network.changes.listen(
        (next) {
          if (identical(_query, run) && next != before) cancel();
        },
        onError: (Object _) {
          if (identical(_query, run)) cancel();
        },
      );
      final result = await run.wait(
        run.client
            .servers(
              requestId: run.id,
              proxyName: route.proxy,
              direct: direct,
              useSystemDns:
                  direct && ref.read(appSettingProvider).speedTest.useSystemDns,
              search: search.trim(),
            )
            .timeout(const Duration(seconds: 20)),
      );
      if (ref.mounted && identical(_query, run)) {
        state = AsyncData(result ?? const []);
      }
    } on Object catch (error, stack) {
      if (ref.mounted && identical(_query, run)) {
        state = AsyncError(error, stack);
      }
    } finally {
      await subscription?.cancel();
      run.stop();
      if (identical(_query, run)) _query = null;
    }
  }
}

final speedTestServersProvider =
    NotifierProvider<SpeedTestServers, AsyncValue<List<SpeedTestServer>>?>(
      SpeedTestServers.new,
    );

final speedTestProvider = NotifierProvider<SpeedTest, SpeedTestState>(
  SpeedTest.new,
);
