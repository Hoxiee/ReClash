import 'dart:async';

// Schedules fullSetup on the event loop (a retained engine with no Activity may never draw a frame).
class SetupApplyCoordinator {
  SetupApplyCoordinator(this._apply, {void Function(void Function())? schedule})
    : _schedule = schedule ?? scheduleMicrotask;

  final Future<bool> Function() _apply;
  final void Function(void Function()) _schedule;

  bool _draining = false;
  Completer<bool>? _next;

  Future<bool> request() {
    final next = _next ??= Completer<bool>();
    if (!_draining) {
      _draining = true;
      _schedule(_drain);
    }
    return next.future;
  }

  Future<void> _drain() async {
    while (_next != null) {
      final current = _next!;
      _next = null;
      try {
        current.complete(await _apply());
      } catch (error, stackTrace) {
        current.completeError(error, stackTrace);
      }
    }
    _draining = false;
  }
}
