import 'dart:async';

import 'package:reclash/common/constant.dart';
import 'package:reclash/common/preferences.dart';
import 'package:reclash/common/print.dart';
import 'package:reclash/common/system.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart' show ProxyState;
import 'package:proxy/proxy.dart';

final proxy = system.isDesktop && !safeModeBuild ? Proxy() : null;

final systemProxyQueue = proxy == null
    ? null
    : SystemProxyQueue(proxy!, record: const PreferencesOwnProxyRecord());

/// The port of the system proxy ReClash applied, kept across restarts so a
/// proxy a crash left behind is still recognised as ours.
abstract interface class OwnProxyRecord {
  Future<int?> read();

  Future<void> write(int? port);
}

class PreferencesOwnProxyRecord implements OwnProxyRecord {
  const PreferencesOwnProxyRecord();

  @override
  Future<int?> read() => preferences.getOwnProxyPort();

  @override
  Future<void> write(int? port) => preferences.saveOwnProxyPort(port);
}

/// Exit's stop goes through the same queue as every other change, so a start
/// still waiting behind a slow call cannot turn the proxy back on after it.
/// A stop also clears settings someone else made, so it only undoes a start
/// of this run.
class SystemProxyQueue {
  final Proxy _proxy;
  Future<void> _tail = Future.value();
  bool _closed = false;
  bool _applied = false;

  final OwnProxyRecord? _record;
  final _ownPorts = StreamController<int?>.broadcast();

  SystemProxyQueue(this._proxy, {OwnProxyRecord? record}) : _record = record;

  /// The recorded port after every change of the record.
  Stream<int?> get ownPorts => _ownPorts.stream;

  Future<int?> ownPort() async => await _record?.read();

  /// Whether the system proxy now matches [state]; false when starting it
  /// failed.
  Future<bool> apply(ProxyState state) async {
    var ok = true;
    await _enqueue(() async {
      if (_closed) {
        return;
      }
      if (state.isStart && state.systemProxy) {
        _applied = true;
        if (await _proxy.startProxy(state.port, state.bassDomain)) {
          await _remember(state.port);
        } else {
          ok = false;
          _logFailure();
        }
      } else {
        await _stop();
      }
    });
    return ok;
  }

  Future<void> close() {
    _closed = true;
    return _enqueue(_stop).whenComplete(() => _ownPorts.close());
  }

  /// Stops the system proxy whoever set it, for a remedy the user chose. With
  /// [ownPort] it acts only while the record still holds that port.
  Future<bool> clear({int? ownPort}) async {
    var cleared = false;
    await _enqueue(() async {
      if (ownPort != null && await _record?.read() != ownPort) {
        return;
      }
      if (!await _proxy.stopProxy()) {
        _logFailure();
        return;
      }
      _applied = false;
      await _remember(null);
      cleared = true;
    });
    return cleared;
  }

  Future<void> _stop() async {
    if (!_applied) {
      return;
    }
    if (!await _proxy.stopProxy()) {
      _logFailure();
      return;
    }
    _applied = false;
    await _remember(null);
  }

  Future<void> _remember(int? port) async {
    await _record?.write(port);
    if (!_ownPorts.isClosed) {
      _ownPorts.add(port);
    }
  }

  void _logFailure() {
    commonPrint.log('update system proxy failed', logLevel: LogLevel.warning);
  }

  Future<void> _enqueue(Future<void> Function() task) {
    return _tail = _tail.then((_) => task()).catchError((Object error) {
      commonPrint.log(
        'update system proxy failed: $error',
        logLevel: LogLevel.warning,
      );
    });
  }
}

String proxyEnvCommand(int port, {required bool isWindows}) {
  final url = 'http://127.0.0.1:$port';
  return isWindows ? 'set \$env:all_proxy=$url' : 'export all_proxy=$url';
}
