import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/http.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/features/speed_test/backend.dart';
import 'package:reclash/features/speed_test/cloudflare.dart';
import 'package:reclash/features/speed_test/engine.dart';
import 'package:reclash/features/speed_test/librespeed.dart';
import 'package:reclash/features/speed_test/types.dart';
import 'package:reclash/models/speed_test.dart';

import 'app.dart';
import 'config.dart';
import 'route_state.dart';
import 'routing.dart';
import 'state.dart';

export 'package:reclash/features/speed_test/types.dart';

final speedTestBackendsProvider = Provider<List<SpeedTestBackend>>(
  (ref) => [CloudflareSpeedTestBackend(), LibreSpeedBackend()],
);

final speedTestNetworkProvider = Provider<NetworkCostMonitor>(
  (ref) => createNetworkCostMonitor(),
);

final speedTestPlanProvider = Provider<SpeedTestPlan>(
  (ref) => const SpeedTestPlan(),
);

final _selectedBackendProvider = Provider<SpeedTestBackend?>((ref) {
  final id = ref.watch(
    appSettingProvider.select((value) => value.speedTest.backendId),
  );
  return ref
      .watch(speedTestBackendsProvider)
      .where((value) => value.id == id)
      .firstOrNull;
});

final _speedTestRouteProvider = Provider((ref) {
  final backend = ref.watch(_selectedBackendProvider);
  return (
    proxy: backend == null
        ? 'DIRECT'
        : ReClashHttpOverrides.findProxyForReader(
            ref.watch,
            backend.measurementUri,
          ),
    profile: ref.watch(currentProfileIdProvider),
    patch: ref.watch(patchClashConfigProvider),
    selected: ref.watch(selectedMapProvider),
    mode: ref.watch(effectiveModeProvider),
  );
});

final speedTestViaVpnProvider = Provider<bool>(
  (ref) => ref.watch(_speedTestRouteProvider).proxy != 'DIRECT',
);

class SpeedTest extends Notifier<SpeedTestState> {
  SpeedTestEngine? _engine;
  StreamSubscription<NetworkCostSnapshot>? _networkSubscription;
  int _run = 0;
  bool _disposed = false;

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
      _disposed = true;
      _run++;
      _engine?.cancel();
      unawaited(_networkSubscription?.cancel());
    });
    return const SpeedTestState();
  }

  Future<void> start({
    SpeedTestSettings settings = const SpeedTestSettings(),
    NetworkCostSnapshot? expectedNetwork,
  }) async {
    if (state.running) return;
    if (expectedNetwork == null) {
      state = const SpeedTestState(
        phase: SpeedTestPhase.failed,
        failure: 'confirmationRequired',
      );
      return;
    }
    final backend = ref
        .read(speedTestBackendsProvider)
        .where((value) => value.id == settings.backendId)
        .firstOrNull;
    if (backend == null) {
      state = SpeedTestState(
        phase: SpeedTestPhase.failed,
        backendId: settings.backendId,
        failure: 'backendUnavailable',
      );
      return;
    }
    final run = ++_run;
    final route = _speedTestRouteProvider;
    final before = ref.read(route);
    final proxy = ReClashHttpOverrides.findProxyForReader(
      ref.read,
      backend.measurementUri,
    );
    final network = ref.read(speedTestNetworkProvider);
    final tracker = ref.read(routeTrackerProvider.notifier);
    var attached = false;
    state = SpeedTestState(
      phase: SpeedTestPhase.running,
      byteLimit: settings.mode == SpeedTestMode.complete
          ? settings.byteLimit
          : 0,
      viaVpn: proxy != 'DIRECT',
      backendId: backend.id,
    );
    try {
      final current = await network.read();
      if (_disposed || run != _run) return;
      if (current != expectedNetwork ||
          current.cost == NetworkCost.offline ||
          ref.read(route) != before) {
        cancel(failure: 'routeChanged');
        return;
      }
      _networkSubscription = network.changes.listen((next) {
        if (run == _run && next != expectedNetwork) {
          cancel(failure: 'routeChanged');
        }
      }, onError: (Object _) => cancel(failure: 'routeChanged'));
      tracker.attach();
      attached = true;
      final session = backend.open(
        () => HttpClient()
          ..connectionTimeout = const Duration(seconds: 5)
          ..findProxy = (_) => proxy,
      );
      final engine = SpeedTestEngine(
        session: session,
        settings: settings,
        viaVpn: proxy != 'DIRECT',
        plan: ref.read(speedTestPlanProvider),
        streams: backend.streams,
        onUpdate: (next) {
          if (!_disposed && run == _run) state = next;
        },
      );
      _engine = engine;
      await engine.run();
    } on Object {
      if (!_disposed && run == _run) {
        state = SpeedTestState(
          phase: SpeedTestPhase.failed,
          backendId: settings.backendId,
          failure: 'unavailable',
        );
      }
    } finally {
      if (attached) tracker.detach();
      if (run == _run) {
        _engine = null;
        final subscription = _networkSubscription;
        _networkSubscription = null;
        await subscription?.cancel();
      }
    }
  }

  void cancel({String? failure}) {
    if (_disposed || !state.running) return;
    final engine = _engine;
    if (engine != null) {
      engine.cancel(failure: failure);
    } else {
      _run++;
      state = SpeedTestState(
        phase: failure == null
            ? SpeedTestPhase.cancelled
            : SpeedTestPhase.failed,
        failure: failure,
      );
    }
    unawaited(_networkSubscription?.cancel());
    _networkSubscription = null;
  }
}

final speedTestProvider = NotifierProvider<SpeedTest, SpeedTestState>(
  SpeedTest.new,
);
