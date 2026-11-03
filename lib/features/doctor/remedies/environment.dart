import 'dart:io';

import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

import '../environment/reader.dart';
import '../snapshot.dart';
import 'remedy.dart';

/// Reads and rewrites the app's Clash patch config, which the kernel snapshots
/// around an undoable remedy.
class PatchConfigAccess {
  const PatchConfigAccess({required this.read, required this.write});

  final PatchClashConfig Function() read;
  final void Function(PatchClashConfig Function(PatchClashConfig)) write;
}

const _freePortRange = (min: 7890, max: 7999);

Future<bool> _bindable(int port) async {
  try {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    await socket.close();
    return true;
  } on SocketException {
    return false;
  }
}

/// A port nothing holds: the 7890..7999 range first, an ephemeral one after.
Future<int> findFreePort({Set<int> avoid = const {}}) async {
  for (var port = _freePortRange.min; port <= _freePortRange.max; port++) {
    if (!avoid.contains(port) && await _bindable(port)) return port;
  }
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

class IgnoreSystemHostsRemedy implements Remedy {
  const IgnoreSystemHostsRemedy(this._config);

  final PatchConfigAccess _config;

  @override
  String get id => 'dns.ignoreSystemHosts';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.app;

  @override
  bool get undoable => true;

  @override
  Duration get settle => Duration.zero;

  @override
  Future<void> apply(RemedyRequest request) async {
    _config.write(
      (config) => config.copyWith(
        dns: config.dns.copyWith(useSystemHosts: false),
        dnsOverrideKeys: {
          ...config.dnsOverrideKeys,
          DnsOverrideKey.useSystemHosts,
        },
      ),
    );
  }
}

class OpenHostsRemedy implements Remedy {
  const OpenHostsRemedy(this._open);

  /// False when no editor could be opened.
  final Future<bool> Function() _open;

  @override
  String get id => 'system.openHosts';

  @override
  FixKind get kind => FixKind.system;

  @override
  RemedyReach get reach => RemedyReach.app;

  @override
  bool get undoable => false;

  @override
  Duration get settle => Duration.zero;

  @override
  Future<void> apply(RemedyRequest request) async {
    if (!await _open()) throw StateError('$id: no editor to open');
  }
}

class ClearOwnProxyRemedy implements Remedy {
  const ClearOwnProxyRemedy(this._clear);

  /// Clears only while the record still holds the port; false when it did not.
  final Future<bool> Function(int port) _clear;

  @override
  String get id => 'proxy.clearOwn';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.own;

  @override
  bool get undoable => false;

  @override
  Duration get settle => const Duration(seconds: 2);

  @override
  Future<void> apply(RemedyRequest request) async {
    final proxy = request.snapshot.valueOf(Facts.systemProxy);
    final own = request.snapshot.valueOf(Facts.ownProxyPort);
    if (proxy == null ||
        own == null ||
        !proxy.enabled ||
        !isLoopbackHost(proxy.host) ||
        proxy.port != own) {
      throw StateError('the system proxy is not one ReClash set');
    }
    if (!await _clear(own)) throw StateError('$id: the proxy was not cleared');
  }
}

class ClearProxyRemedy implements Remedy {
  const ClearProxyRemedy(this._clear);

  final Future<bool> Function() _clear;

  @override
  String get id => 'proxy.clear';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.foreign;

  @override
  bool get undoable => false;

  @override
  Duration get settle => const Duration(seconds: 2);

  @override
  Future<void> apply(RemedyRequest request) async {
    if (!await _clear()) throw StateError('$id: the proxy was not cleared');
  }
}

class ReapplyProxyRemedy implements Remedy {
  const ReapplyProxyRemedy(this._apply);

  final Future<void> Function() _apply;

  @override
  String get id => 'proxy.reapply';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.foreign;

  @override
  bool get undoable => false;

  @override
  Duration get settle => const Duration(seconds: 2);

  @override
  Future<void> apply(RemedyRequest request) => _apply();
}

class FreePortRemedy implements Remedy {
  const FreePortRemedy(this._config, {Future<int> Function(Set<int>)? find})
    : _find = find ?? _defaultFind;

  final PatchConfigAccess _config;
  final Future<int> Function(Set<int> avoid) _find;

  static Future<int> _defaultFind(Set<int> avoid) => findFreePort(avoid: avoid);

  @override
  String get id => 'config.freePort';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.app;

  @override
  bool get undoable => true;

  @override
  Duration get settle => const Duration(seconds: 3);

  @override
  Future<void> apply(RemedyRequest request) async {
    final current = _config.read();
    final port = await _find({
      current.mixedPort,
      current.socksPort,
      current.port,
      current.redirPort,
      current.tproxyPort,
    });
    _config.write((config) => config.copyWith(mixedPort: port));
  }
}

class FreeTunDeviceRemedy implements Remedy {
  const FreeTunDeviceRemedy(this._config);

  final PatchConfigAccess _config;

  @override
  String get id => 'tunnel.freeDeviceName';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.app;

  @override
  bool get undoable => true;

  @override
  Duration get settle => const Duration(seconds: 3);

  @override
  Future<void> apply(RemedyRequest request) async {
    final tunnels = request.snapshot.valueOf(Facts.tunnels);
    final taken = {
      for (final adapter in [?tunnels?.ours, ...?tunnels?.foreign])
        adapter.name.toLowerCase(),
    };
    final base = _config.read().tun.device.replaceFirst(RegExp(r'-\d+$'), '');
    var suffix = 2;
    while (taken.contains('$base-$suffix'.toLowerCase())) {
      suffix++;
    }
    _config.write((config) => config.copyWith.tun(device: '$base-$suffix'));
  }
}

class RestartTunnelRemedy implements Remedy {
  const RestartTunnelRemedy(this._restart);

  /// False when the restart did not complete.
  final Future<bool> Function() _restart;

  @override
  String get id => 'tunnel.restart';

  @override
  FixKind get kind => FixKind.auto;

  @override
  RemedyReach get reach => RemedyReach.app;

  @override
  bool get undoable => false;

  @override
  Duration get settle => const Duration(seconds: 5);

  @override
  Future<void> apply(RemedyRequest request) async {
    if (!await _restart()) throw StateError('$id: the Core did not restart');
  }
}
