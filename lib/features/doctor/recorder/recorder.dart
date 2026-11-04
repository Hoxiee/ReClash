import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/report/sources.dart';
import 'package:reclash/models/models.dart';

const _segmentBytes = 1024 * 1024;
const _flushInterval = Duration(seconds: 30);
const _urgentDelay = Duration(seconds: 1);
const _eventRetention = Duration(days: 7);
const _pruneInterval = Duration(hours: 1);
const _maxEvents = 2000;
const _maxBufferedLines = 5000;

/// Keeps logs and events across restarts and the in-memory log reset, in
/// batches. Without a usable directory it degrades to a bounded memory store.
final class FilePassiveRecorder implements PassiveRecorder {
  FilePassiveRecorder({
    required Future<Directory> Function() directory,
    DateTime Function() now = DateTime.now,
  }) : _directory = directory,
       _now = now;

  final Future<Directory> Function() _directory;
  final DateTime Function() _now;

  final List<String> _lines = [];
  final List<PassiveEvent> _pendingEvents = [];
  List<PassiveEvent>? _events;
  Directory? _root;
  bool _failed = false;
  bool _active = false;
  bool _disposed = false;
  bool _urgent = false;
  Timer? _timer;
  int? _currentSize;
  DateTime? _lastPrune;
  Future<void> _queue = Future.value();

  /// Timers only run once started, so nothing wakes the app before the
  /// recorder is wired in.
  void start() {
    if (_active || _disposed) return;
    _active = true;
    if (_lines.isNotEmpty || _pendingEvents.isNotEmpty) _schedule();
    unawaited(
      _serialized(() async {
        await _loadEvents();
        await _pruneEvents(force: true);
      }),
    );
  }

  void addLog(Log log) {
    if (_disposed) return;
    final payload = log.payload.replaceAll('\r', '').replaceAll('\n', r'\n');
    final level = log.logLevel.name.toUpperCase();
    _lines.add('${_now().toUtc().toIso8601String()} $level $payload');
    if (_failed && _lines.length > _maxBufferedLines) {
      _lines.removeRange(0, _lines.length - _maxBufferedLines);
    }
    _schedule(urgent: log.logLevel == LogLevel.error);
  }

  void addEvent(String kind, [Map<String, Object?> data = const {}]) {
    if (_disposed) return;
    final event = PassiveEvent(time: _now(), kind: kind, data: data);
    _events?.add(event);
    _pendingEvents.add(event);
    _schedule();
  }

  void _schedule({bool urgent = false}) {
    if (!_active || _failed || _disposed) return;
    if (urgent && !_urgent) {
      _urgent = true;
      _timer?.cancel();
      _timer = Timer(_urgentDelay, _onTimer);
    } else {
      _timer ??= Timer(_flushInterval, _onTimer);
    }
  }

  void _onTimer() {
    _timer = null;
    _urgent = false;
    unawaited(flush());
  }

  @visibleForTesting
  int writes = 0;

  @override
  Future<void> flush() {
    if (_lines.isNotEmpty || _pendingEvents.isNotEmpty) writes++;
    _timer?.cancel();
    _timer = null;
    _urgent = false;
    return _serialized(_write);
  }

  Future<void> _serialized(Future<void> Function() action) {
    final next = _queue.then((_) async {
      try {
        await action();
      } on Object {
        _failed = true;
      }
    });
    _queue = next;
    return next;
  }

  Future<Directory?> _logsDir() async {
    if (_failed) return null;
    if (_root != null) return _root;
    try {
      final base = await _directory();
      final dir = Directory(p.join(base.path, 'diagnostics', 'logs'));
      await dir.create(recursive: true);
      return _root = dir;
    } on Object {
      _failed = true;
      return null;
    }
  }

  File _segment(Directory dir, String name) => File(p.join(dir.path, name));

  File _eventsFile(Directory dir) =>
      File(p.join(dir.parent.path, 'events.jsonl'));

  Future<void> _write() async {
    final dir = await _logsDir();
    if (dir == null) return;
    await _loadEvents();
    final lines = List<String>.of(_lines);
    final events = List<PassiveEvent>.of(_pendingEvents);
    _lines.clear();
    _pendingEvents.clear();
    try {
      if (lines.isNotEmpty) await _appendLines(dir, lines);
      if (events.isNotEmpty) {
        if (!await _pruneEvents()) {
          await _eventsFile(dir).writeAsString(
            events.map((e) => '${jsonEncode(e.toJson())}\n').join(),
            mode: FileMode.append,
          );
        }
      }
    } on Object {
      _failed = true;
      _lines.insertAll(0, lines);
      rethrow;
    }
  }

  /// Rotates before a segment would pass the limit, so two segments stay
  /// within twice [_segmentBytes] however large one batch is.
  Future<void> _appendLines(Directory dir, List<String> lines) async {
    final current = _segment(dir, 'current.log');
    var size =
        _currentSize ?? (await current.exists() ? await current.length() : 0);
    final chunk = StringBuffer();
    var chunkBytes = 0;

    Future<void> drain() async {
      if (chunkBytes == 0) return;
      await current.writeAsString(
        chunk.toString(),
        mode: FileMode.append,
        flush: true,
      );
      size += chunkBytes;
      chunk.clear();
      chunkBytes = 0;
    }

    for (final line in lines) {
      final bytes = utf8.encode(line).length + 1;
      if (size + chunkBytes + bytes > _segmentBytes && size + chunkBytes > 0) {
        await drain();
        await current.rename(_segment(dir, 'previous.log').path);
        size = 0;
      }
      chunk.writeln(line);
      chunkBytes += bytes;
    }
    await drain();
    _currentSize = size;
  }

  Future<List<PassiveEvent>> _loadEvents() async {
    if (_events case final loaded?) return loaded;
    final dir = await _logsDir();
    final loaded = <PassiveEvent>[];
    if (dir != null) {
      final file = _eventsFile(dir);
      if (await file.exists()) {
        for (final line in const LineSplitter().convert(
          await file.readAsString(),
        )) {
          if (_parseEvent(line) case final event?) loaded.add(event);
        }
      }
    }
    loaded.addAll(_pendingEvents);
    return _events = loaded;
  }

  PassiveEvent? _parseEvent(String line) {
    try {
      final json = jsonDecode(line) as Map<String, Object?>;
      return PassiveEvent(
        time: DateTime.parse(json['time']! as String),
        kind: json['kind']! as String,
        data: (json['data'] as Map?)?.cast<String, Object?>() ?? const {},
      );
    } on Object {
      return null;
    }
  }

  List<PassiveEvent> _retained(List<PassiveEvent> events) {
    final cutoff = _now().subtract(_eventRetention);
    final kept = events.where((e) => !e.time.isBefore(cutoff)).toList();
    return kept.length > _maxEvents
        ? kept.sublist(kept.length - _maxEvents)
        : kept;
  }

  /// Rewrites the events file without the expired and surplus entries, at most
  /// once per [_pruneInterval]. True when it wrote the whole file.
  Future<bool> _pruneEvents({bool force = false}) async {
    final last = _lastPrune;
    if (!force && last != null && _now().difference(last) < _pruneInterval) {
      return false;
    }
    final loaded = await _loadEvents();
    final kept = _retained(loaded);
    loaded
      ..clear()
      ..addAll(kept);
    _lastPrune = _now();
    _pendingEvents.clear();
    final dir = await _logsDir();
    if (dir == null) return false;
    final file = _eventsFile(dir);
    if (kept.isEmpty && !await file.exists()) return false;
    await file.writeAsString(
      kept.map((e) => '${jsonEncode(e.toJson())}\n').join(),
    );
    return true;
  }

  @override
  Future<List<String>> logLines() async {
    await _serialized(() async {});
    final result = <String>[];
    final dir = await _logsDir();
    if (dir != null) {
      for (final name in const ['previous.log', 'current.log']) {
        final file = _segment(dir, name);
        try {
          if (await file.exists()) {
            result.addAll(
              const LineSplitter().convert(await file.readAsString()),
            );
          }
        } on Object {
          continue;
        }
      }
    }
    return [...result, ..._lines];
  }

  @override
  Future<List<PassiveEvent>> events({required DateTime since}) async {
    await _serialized(_loadEvents);
    final loaded = _events ?? [..._pendingEvents];
    return _retained(loaded).where((e) => !e.time.isBefore(since)).toList();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
