import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cause.dart';
import 'finding.dart';

enum DiagnosticEventKind {
  findingRaised,
  findingCleared,
  probeFailed,
  remedyApplied,
  remedyUndone,
  disconnected,
  pathFailed,
  pathRecovered,
}

/// One thing the kernel saw or did. Every event is also an incident, so the
/// persisted history and the live stream never disagree.
@immutable
final class DiagnosticEvent {
  const DiagnosticEvent({
    required this.kind,
    required this.at,
    required this.subject,
    this.severity,
    this.cause,
    this.outcome,
    this.detail,
  });

  factory DiagnosticEvent.fromJson(Map<String, Object?> json) {
    return DiagnosticEvent(
      kind: DiagnosticEventKind.values.byName(json['kind']! as String),
      at: DateTime.fromMillisecondsSinceEpoch(json['at']! as int),
      subject: json['subject']! as String,
      severity: switch (json['severity']) {
        final String name => CheckSeverity.values.byName(name),
        _ => null,
      },
      cause: FailureCause.fromWire(json['cause'] as String?),
      outcome: json['outcome'] as String?,
      detail: json['detail'] as String?,
    );
  }

  final DiagnosticEventKind kind;
  final DateTime at;

  /// The finding, probe or remedy id; for a disconnect, the status reached;
  /// for the path, the step.
  final String subject;
  final CheckSeverity? severity;
  final FailureCause? cause;
  final String? outcome;
  final String? detail;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'at': at.millisecondsSinceEpoch,
    'subject': subject,
    if (severity != null) 'severity': severity!.name,
    if (cause != null) 'cause': cause!.id,
    if (outcome != null) 'outcome': outcome,
    if (detail != null) 'detail': detail,
  };

  @override
  bool operator ==(Object other) =>
      other is DiagnosticEvent &&
      other.kind == kind &&
      other.at == at &&
      other.subject == subject &&
      other.severity == severity &&
      other.cause == cause &&
      other.outcome == outcome &&
      other.detail == detail;

  @override
  int get hashCode =>
      Object.hash(kind, at, subject, severity, cause, outcome, detail);

  @override
  String toString() => 'DiagnosticEvent(${kind.name}, $subject, $outcome)';
}

abstract interface class IncidentStore {
  Future<List<String>> load();

  Future<void> save(List<String> incidents);
}

class MemoryIncidentStore implements IncidentStore {
  MemoryIncidentStore([List<String> incidents = const []])
    : incidents = List.of(incidents);

  List<String> incidents;

  @override
  Future<List<String>> load() async => List.of(incidents);

  @override
  Future<void> save(List<String> incidents) async {
    this.incidents = List.of(incidents);
  }
}

class DiagnosticJournal {
  DiagnosticJournal(this._store, {this.capacity = 100});

  final IncidentStore _store;
  final int capacity;
  final _events = StreamController<DiagnosticEvent>.broadcast(sync: true);
  final _history = <DiagnosticEvent>[];
  Future<void>? _loaded;
  Future<void> _writes = Future.value();
  bool _closed = false;

  Stream<DiagnosticEvent> get events => _events.stream;

  /// Oldest first, at most [capacity].
  Future<List<DiagnosticEvent>> history() async {
    await _load();
    return List.unmodifiable(_history);
  }

  Future<void> _load() => _loaded ??= _readStored();

  Future<void> _readStored() async {
    final stored = <DiagnosticEvent>[];
    for (final line in await _store.load()) {
      try {
        stored.add(
          DiagnosticEvent.fromJson(jsonDecode(line) as Map<String, Object?>),
        );
      } on Object {
        continue;
      }
    }
    _history.insertAll(0, stored);
    _trim();
  }

  /// Publishes [event] at once and persists it after the stored history has
  /// been read, so an event recorded during start-up is not overwritten.
  Future<void> record(DiagnosticEvent event) {
    if (_closed) return Future.value();
    _events.add(event);
    final write = _writes.then((_) async {
      await _load();
      _history.add(event);
      _trim();
      await _store.save([for (final e in _history) jsonEncode(e.toJson())]);
    });
    _writes = write.catchError((Object _) {});
    return write;
  }

  void _trim() {
    final excess = _history.length - capacity;
    if (excess > 0) _history.removeRange(0, excess);
  }

  Future<void> close() async {
    _closed = true;
    await _writes;
    await _events.close();
  }
}
