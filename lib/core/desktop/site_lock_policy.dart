import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/site_lock.dart';

enum SiteLockHostStatus { inactive, applied, helperUnavailable, failed }

/// Keeps the privileged host's firewall policy in step with the Core's
/// lock addresses. The Helper persists the policy, so a stopped or crashed
/// Core leaves it in place; only the user disabling every lock lifts it.
final class SiteLockHostPolicy {
  final Future<SiteLockPolicy?> Function(String known) _fetch;
  final Future<void> Function(SiteLockPolicy policy) _put;
  final Future<void> Function() _delete;
  final Future<bool> Function() _helperReady;
  final void Function(SiteLockHostStatus status) _onStatus;
  final Duration _interval;

  bool _locksEnabled = false;
  bool _connected = false;
  bool _disposed = false;
  bool _running = false;
  bool _dirty = false;
  bool _lifted = false;
  String? _appliedRevision;
  Timer? _timer;

  SiteLockHostPolicy({
    required Future<SiteLockPolicy?> Function(String known) fetch,
    required Future<void> Function(SiteLockPolicy policy) put,
    required Future<void> Function() delete,
    required Future<bool> Function() helperReady,
    required void Function(SiteLockHostStatus status) onStatus,
    Duration interval = const Duration(seconds: 15),
  }) : _fetch = fetch,
       _put = put,
       _delete = delete,
       _helperReady = helperReady,
       _onStatus = onStatus,
       _interval = interval;

  void update({required bool locksEnabled, required bool coreConnected}) {
    if (_disposed) return;
    _locksEnabled = locksEnabled;
    _connected = coreConnected;
    _timer?.cancel();
    _timer = null;
    if (locksEnabled) {
      _lifted = false;
      if (coreConnected) {
        _timer = Timer.periodic(_interval, (_) => _kick());
      }
    }
    _kick();
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
        if (!_locksEnabled) {
          await _lift();
        } else if (_connected) {
          await _sync();
        }
      } while (_dirty && !_disposed);
    } finally {
      _running = false;
    }
  }

  Future<void> _sync() async {
    try {
      if (!await _helperReady() && !_disposed) {
        _appliedRevision = null;
        _emit(SiteLockHostStatus.helperUnavailable);
        return;
      }
      final wanted = await _fetch(_appliedRevision ?? '');
      if (wanted == null || wanted.unchanged || _disposed) return;
      await _put(wanted);
      _appliedRevision = wanted.revision;
      _emit(SiteLockHostStatus.applied);
    } catch (error) {
      _fail('apply', error);
    }
  }

  Future<void> _lift() async {
    if (_lifted) return;
    try {
      if (!await _helperReady() || _disposed) return;
      await _delete();
      _lifted = true;
      _appliedRevision = null;
      _emit(SiteLockHostStatus.inactive);
    } catch (error) {
      _fail('lift', error);
    }
  }

  void _fail(String action, Object error) {
    if (_disposed) return;
    commonPrint.log(
      'Site lock host policy $action failed: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
    _emit(SiteLockHostStatus.failed);
  }

  void _emit(SiteLockHostStatus status) {
    if (!_disposed) _onStatus(status);
  }
}
