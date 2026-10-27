import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:reclash/plugins/app.dart';

enum NetworkCost { unmetered, metered, unknown, offline }

@immutable
class NetworkCostSnapshot {
  const NetworkCostSnapshot({required this.cost, required this.identity});

  final NetworkCost cost;
  final String identity;

  @override
  bool operator ==(Object other) =>
      other is NetworkCostSnapshot &&
      cost == other.cost &&
      identity == other.identity;

  @override
  int get hashCode => Object.hash(cost, identity);
}

abstract interface class NetworkCostMonitor {
  Future<NetworkCostSnapshot> read();
  Stream<NetworkCostSnapshot> get changes;
}

NetworkCostMonitor createNetworkCostMonitor() => _PlatformNetworkCostMonitor();

class _PlatformNetworkCostMonitor implements NetworkCostMonitor {
  final _connectivity = Connectivity();

  @override
  Future<NetworkCostSnapshot> read() async {
    Map<String, dynamic>? native;
    var transports = <ConnectivityResult>[];
    var addresses = <String>[];
    try {
      transports = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 2),
      );
    } on Object {
      transports = [];
    }
    if (Platform.isAndroid) {
      try {
        native = await app?.getNetworkCost();
      } on Object {
        native = null;
      }
    }
    if (native?['connected'] == false ||
        transports.length == 1 &&
            transports.single == ConnectivityResult.none) {
      return const NetworkCostSnapshot(
        cost: NetworkCost.offline,
        identity: 'offline',
      );
    }
    if (native == null) {
      try {
        final interfaces = await NetworkInterface.list().timeout(
          const Duration(seconds: 1),
        );
        addresses = [
          for (final interface in interfaces)
            for (final address in interface.addresses)
              '${interface.name}:${address.address}',
        ]..sort();
      } on Object {
        addresses = [];
      }
    }
    final names = transports.map((value) => value.name).toList()..sort();
    final cost = switch (native?['metered']) {
      true => NetworkCost.metered,
      false => NetworkCost.unmetered,
      _ when transports.contains(ConnectivityResult.mobile) =>
        NetworkCost.metered,
      _ => NetworkCost.unknown,
    };
    return NetworkCostSnapshot(
      cost: cost,
      identity:
          '${native?['identity'] ?? addresses.join(',')}|${names.join(',')}',
    );
  }

  @override
  Stream<NetworkCostSnapshot> get changes {
    late StreamController<NetworkCostSnapshot> controller;
    StreamSubscription<List<ConnectivityResult>>? subscription;
    Timer? timer;
    var active = true;
    var reading = false;
    NetworkCostSnapshot? previous;
    Future<void> check() async {
      if (reading || !active) return;
      reading = true;
      try {
        final snapshot = await read();
        if (active && snapshot != previous) {
          previous = snapshot;
          controller.add(snapshot);
        }
      } finally {
        reading = false;
      }
    }

    controller = StreamController<NetworkCostSnapshot>(
      onListen: () {
        unawaited(check());
        subscription = _connectivity.onConnectivityChanged.listen(
          (_) => unawaited(check()),
          onError: (Object _) => unawaited(check()),
        );
        timer = Timer.periodic(
          const Duration(seconds: 2),
          (_) => unawaited(check()),
        );
      },
      onCancel: () async {
        active = false;
        timer?.cancel();
        await subscription?.cancel();
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }
}
