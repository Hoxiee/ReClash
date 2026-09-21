import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/common/datetime.dart';
import 'package:reclash/common/path.dart';
import 'package:path/path.dart';

/// Persistent on-disk log sink under `<home>/logs`, so the log stream survives
/// a crash/ANR/restart that wipes the in-memory `logsProvider`. Writes drain
/// through a queue and flush per batch, so a hard kill loses at most one batch.
class FileLogger {
  factory FileLogger() {
    _instance ??= FileLogger._internal();
    return _instance!;
  }

  FileLogger._internal();

  static FileLogger? _instance;

  static final bool _isFlutterTest = Platform.environment.containsKey(
    'FLUTTER_TEST',
  );

  // Under `flutter test` the disk path relies on a mocked path_provider that
  // only the logger's own suite installs; elsewhere its fire-and-forget I/O
  // would fault after the unrelated test that logged has already completed.
  // That suite flips this on to exercise the real sink.
  @visibleForTesting
  static bool enabledInTests = false;

  static const int _maxFileSizeBytes = 10 * 1024 * 1024;
  static const int _maxLogFiles = 7;

  final List<String> _queue = <String>[];
  // Long-lived sink closed in _closeSink/dispose, not where close_sinks looks.
  // ignore: close_sinks
  IOSink? _sink;
  String? _sinkPath;
  String? _sinkDate;
  bool _draining = false;
  Future<void> _running = Future<void>.value();

  void log(String message) {
    if (_isFlutterTest && !enabledInTests) {
      return;
    }
    _queue.add('[${DateTime.now().showLog}] $message');
    if (!_draining) {
      _draining = true;
      _running = _drain();
    }
  }

  Future<void> _drain() async {
    try {
      while (_queue.isNotEmpty) {
        // ignore: close_sinks
        final sink = await _ensureSink();
        while (_queue.isNotEmpty) {
          sink.writeln(_queue.removeAt(0));
        }
        await sink.flush();
      }
    } catch (_) {
      // Keep queued lines for the next call rather than dropping them.
    } finally {
      _draining = false;
    }
  }

  Future<IOSink> _ensureSink() async {
    final today = DateTime.now().show;
    if (_sink != null && _sinkDate == today && !await _sinkFull()) {
      return _sink!;
    }
    await _closeSink();
    if (_sinkDate != today) {
      _sinkDate = today;
      await _rotate();
    }
    final file = await _openTarget(today);
    _sinkPath = file.path;
    return _sink = file.openWrite(mode: FileMode.append);
  }

  Future<bool> _sinkFull() async {
    final path = _sinkPath;
    if (path == null) {
      return true;
    }
    final file = File(path);
    return await file.exists() && await file.length() >= _maxFileSizeBytes;
  }

  Future<File> _openTarget(String date) async {
    final dir = await _logsDir();
    for (var index = 0; ; index++) {
      final name = index == 0
          ? '${appName}_$date.log'
          : '${appName}_${date}_$index.log';
      final file = File(join(dir, name));
      if (!await file.exists() || await file.length() < _maxFileSizeBytes) {
        return file;
      }
    }
  }

  Future<void> _rotate() async {
    try {
      final dir = Directory(await _logsDir());
      final files = await dir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .cast<File>()
          .toList();
      files.sort(
        (a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()),
      );
      while (files.length > _maxLogFiles) {
        try {
          await files.removeAt(0).delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<String> _logsDir() async {
    final dir = Directory(join(await appPath.homeDirPath, 'logs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<void> _closeSink() async {
    final sink = _sink;
    _sink = null;
    _sinkPath = null;
    if (sink == null) {
      return;
    }
    try {
      await sink.flush();
      await sink.close();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _running;
    if (_queue.isNotEmpty) {
      await _drain();
    }
    await _closeSink();
  }
}

final fileLogger = FileLogger();
