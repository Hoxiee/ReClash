import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

const reportCaptureLength = Duration(seconds: 30);
const _maxCaptureLines = 20000;

abstract interface class LogCaptureSession {
  List<String> stop();
}

typedef LogCaptureStart = LogCaptureSession Function(ProviderContainer);

final logCaptureProvider = Provider<LogCaptureStart>((_) => CoreLogCapture.new);

/// Without the logs page enabled the Core sends no log stream, so the
/// capture opens one until [stop].
final class CoreLogCapture implements LogCaptureSession {
  CoreLogCapture(this._container)
    : _previous = _container.read(patchClashConfigProvider).logLevel {
    if (_previous != LogLevel.debug) {
      unawaited(preferences.saveReportCaptureRestoreLevel(_previous));
      _setLevel(LogLevel.debug);
    }
    if (!_container.read(appSettingProvider).openLogs && _connected) {
      _container.read(coreHandlerProvider).startLog();
      _openedStream = true;
    }
    _subscription = _container.listen(logsProvider, _onLogs);
  }

  final ProviderContainer _container;
  final LogLevel _previous;
  final _lines = <String>[];
  late final ProviderSubscription<FixedList<Log>> _subscription;
  bool _openedStream = false;
  bool _stopped = false;

  bool get _connected =>
      _container.read(coreStatusProvider) == CoreStatus.connected;

  void _setLevel(LogLevel level) => _container
      .read(patchClashConfigProvider.notifier)
      .update((state) => state.copyWith(logLevel: level));

  void _onLogs(FixedList<Log>? previous, FixedList<Log> next) {
    final added = min(
      next.revision - (previous?.revision ?? next.revision),
      next.length,
    );
    if (added <= 0) return;
    final list = next.list;
    final time = DateTime.now().toUtc().toIso8601String();
    for (final log in list.skip(list.length - added)) {
      final payload = log.payload.replaceAll('\r', '').replaceAll('\n', r'\n');
      _lines.add('$time ${log.logLevel.name.toUpperCase()} $payload');
    }
    if (_lines.length > _maxCaptureLines) {
      _lines.removeRange(0, _lines.length - _maxCaptureLines);
    }
  }

  @override
  List<String> stop() {
    if (_stopped) return List.of(_lines);
    _stopped = true;
    _subscription.close();
    final current = _container.read(patchClashConfigProvider).logLevel;
    if (_previous != LogLevel.debug) {
      if (current == LogLevel.debug) _setLevel(_previous);
      unawaited(preferences.saveReportCaptureRestoreLevel(null));
    }
    if (_openedStream &&
        !_container.read(appSettingProvider).openLogs &&
        _connected) {
      _container.read(coreHandlerProvider).stopLog();
    }
    return List.of(_lines);
  }
}
