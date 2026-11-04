/// One node of the active profile as the sweep saw it.
class SweepRow {
  const SweepRow({
    required this.node,
    required this.group,
    required this.type,
    required this.server,
    required this.port,
    required this.status,
    this.resolveMs,
    this.tcpMs,
    this.delayMs,
    this.lastDelayMs,
  });

  final String node;
  final String group;
  final String type;
  final String server;
  final int port;
  final SweepStatus status;
  final int? resolveMs;
  final int? tcpMs;
  final int? delayMs;
  final int? lastDelayMs;
}

enum SweepStatus { ok, dns, refused, timeout, tls, auth, skipped, unknown }

abstract interface class NodeSweeper {
  /// Rows finished before [cancelled] turned true are kept.
  Future<List<SweepRow>> sweep({
    required void Function(int done, int total) onProgress,
    required bool Function() cancelled,
  });
}

class PassiveEvent {
  const PassiveEvent({
    required this.time,
    required this.kind,
    this.data = const {},
  });

  final DateTime time;
  final String kind;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
    'time': time.toUtc().toIso8601String(),
    'kind': kind,
    if (data.isNotEmpty) 'data': data,
  };
}

/// What the app recorded while nobody was looking.
abstract interface class PassiveRecorder {
  /// Persisted log lines, oldest first, already formatted.
  Future<List<String>> logLines();

  /// Recorded events from [since], oldest first.
  Future<List<PassiveEvent>> events({required DateTime since});

  /// Writes what is still buffered, so a report sees the latest lines.
  Future<void> flush();
}

/// A report this device made, kept for 30 days so a fix link can name it.
class ReportRecord {
  const ReportRecord({
    required this.id,
    required this.profileId,
    required this.createdAt,
    required this.redaction,
  });

  final String id;

  /// The profile that was current when the report was made; null without one.
  final int? profileId;
  final DateTime createdAt;

  /// `ReportRedaction.name`.
  final String redaction;
}

abstract interface class ReportRegistry {
  /// The record of [id] if it is younger than 30 days.
  Future<ReportRecord?> find(String id);

  /// Records younger than 30 days, newest first.
  Future<List<ReportRecord>> list();
}
