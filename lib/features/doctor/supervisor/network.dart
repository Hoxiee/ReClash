import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

/// Reads the network when the platform says it changed; the cost monitor's
/// own change stream polls, which the supervisor must not.
abstract interface class NetworkWatch {
  Future<NetworkCostSnapshot> read();

  Stream<Object?> get events;
}

class _ConnectivityWatch implements NetworkWatch {
  final _monitor = createNetworkCostMonitor();

  @override
  Future<NetworkCostSnapshot> read() => _monitor.read();

  @override
  Stream<Object?> get events => Connectivity().onConnectivityChanged;
}

final networkWatchProvider = Provider<NetworkWatch>(
  (ref) => _ConnectivityWatch(),
);

/// The current network, read on platform events and when the app comes back;
/// null until the first read lands.
final networkSnapshotProvider =
    NotifierProvider<NetworkSnapshot, NetworkCostSnapshot?>(
      NetworkSnapshot.new,
    );

class NetworkSnapshot extends Notifier<NetworkCostSnapshot?> {
  int _reads = 0;

  @override
  NetworkCostSnapshot? build() {
    final watch = ref.watch(networkWatchProvider);
    final subscription = watch.events.listen(
      (_) => unawaited(_read(watch)),
      onError: (Object _) {},
    );
    ref
      ..onDispose(subscription.cancel)
      ..listen(appVisibleProvider, (_, visible) {
        if (visible) unawaited(_read(watch));
      });
    unawaited(_read(watch));
    return null;
  }

  Future<void> _read(NetworkWatch watch) async {
    final read = ++_reads;
    try {
      final snapshot = await watch.read();
      if (ref.mounted && read == _reads) state = snapshot;
    } on Object {
      return;
    }
  }
}

final networkOnlineProvider = Provider<bool?>(
  (ref) => switch (ref.watch(networkSnapshotProvider)?.cost) {
    null => null,
    NetworkCost.offline => false,
    _ => true,
  },
);
