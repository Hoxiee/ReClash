import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/enum/enum.dart';

typedef KillSwitchConfig = ({KillSwitchMode mode, String tun, bool allowLan});

typedef KillSwitchHostSnapshot = ({
  HelperReadiness readiness,
  HelperKillSwitch? info,
});

/// Keeps the Helper's kill switch configuration in step with the setting.
/// A standard block is armed here when the TUN comes up during a run; the
/// Helper's Core start does not arm it. Each tick re-reads the Helper, so one reinstalled or restarted
/// without its state is configured again.
final class KillSwitchHostPolicy {
  final Future<HelperReadiness> Function() _readiness;
  final Future<HelperKillSwitch> Function() _read;
  final Future<void> Function(KillSwitchConfig config) _put;
  final Future<void> Function() _delete;
  final Future<void> Function() _arm;
  final void Function(KillSwitchHostSnapshot snapshot) _onSnapshot;
  final Duration _interval;

  KillSwitchConfig? _wanted;
  bool _started = false;
  bool _lifted = false;
  bool _disposed = false;
  bool _running = false;
  bool _dirty = false;
  bool _tunUp = false;
  bool _armPending = false;
  Timer? _timer;

  KillSwitchHostPolicy({
    required Future<HelperReadiness> Function() readiness,
    required Future<HelperKillSwitch> Function() read,
    required Future<void> Function(KillSwitchConfig config) put,
    required Future<void> Function() delete,
    required Future<void> Function() arm,
    required void Function(KillSwitchHostSnapshot snapshot) onSnapshot,
    Duration interval = const Duration(seconds: 15),
  }) : _readiness = readiness,
       _read = read,
       _put = put,
       _delete = delete,
       _arm = arm,
       _onSnapshot = onSnapshot,
       _interval = interval;

  void update(KillSwitchConfig? wanted) {
    if (_disposed || (_started && wanted == _wanted)) return;
    _started = true;
    _wanted = wanted;
    _lifted = false;
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _kick());
    _kick();
  }

  /// Reads the Helper again now, as after a Core start or stop that may have
  /// armed or lifted the block.
  void refresh() {
    if (_started) _kick();
  }

  /// Arms standard mode on the rising edge only, so a deliberate stop that
  /// disarms while the TUN is still reported up is not undone.
  void observeTun({required bool up}) {
    if (up && !_tunUp) _armPending = true;
    _tunUp = up;
    refresh();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }

  void _kick() {
    if (_disposed) return;
    if (_running) {
      _dirty = true;
      return;
    }
    unawaited(_run());
  }

  Future<void> _run() async {
    _running = true;
    try {
      do {
        _dirty = false;
        await _sync();
      } while (_dirty && !_disposed);
    } finally {
      _running = false;
    }
  }

  Future<void> _sync() async {
    if (_lifted) return;
    final wanted = _wanted;
    try {
      final readiness = await _readiness();
      if (_disposed) return;
      if (readiness != HelperReadiness.ready) {
        _emit((readiness: readiness, info: null));
        if (wanted == null && readiness == HelperReadiness.manifestMissing) {
          _stopLifting();
        }
        return;
      }
      var info = await _read();
      if (_disposed || wanted != _wanted) return;
      if (wanted == null) {
        if (info.configured) {
          await _delete();
          info = await _read();
        }
        _stopLifting();
      } else {
        if (!_matches(info, wanted)) {
          await _put(wanted);
          info = await _read();
        }
        final arm = _armPending && _tunUp;
        _armPending = false;
        if (arm && wanted.mode == KillSwitchMode.standard && !info.armed) {
          await _arm();
          info = await _read();
        }
      }
      _emit((readiness: readiness, info: info));
    } catch (error) {
      if (_disposed) return;
      commonPrint.log(
        'Kill switch host policy failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }

  static bool _matches(HelperKillSwitch info, KillSwitchConfig wanted) =>
      info.configured &&
      info.mode == wanted.mode &&
      info.tun == wanted.tun &&
      info.allowLan == wanted.allowLan;

  void _stopLifting() {
    _lifted = true;
    _timer?.cancel();
    _timer = null;
  }

  void _emit(KillSwitchHostSnapshot snapshot) {
    if (!_disposed) _onSnapshot(snapshot);
  }
}
