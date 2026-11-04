import '../finding.dart';
import '../journal.dart';
import '../path.dart';
import 'report.dart';
import 'sections.dart';
import 'sources.dart';

const reportHistoryWindow = Duration(days: 7);

/// [secrets] are the subscription URL and its token parts, read before
/// redaction.
typedef ReportProfile = ({
  int id,
  String label,
  Map<String, Object?> json,
  List<String> secrets,
});

/// What a report reads. A source that throws leaves its section out instead
/// of failing the report.
abstract interface class ReportSources {
  /// Manifest fields: `app` {name, version, build, flavor}, `safeMode`,
  /// `platform`, `os`, `device`, `abi`, `locale`, `region`, `uptimeMs`.
  Future<Map<String, Object?>> device();

  Future<Map<String, Object?>> environment();

  List<Finding> findings();

  Future<List<DiagnosticEvent>> incidents();

  bool get connected;

  PathResult? get lastPath;

  Future<PathResult> runPath();

  NodeSweeper get sweeper;

  Future<Map<String, Object?>> services();

  ReportProfile? profile();

  Future<String?> config();

  PassiveRecorder get recorder;
}

/// Lets the UI stop the sweep and keep its finished rows, or abandon the
/// whole report.
final class ReportControl {
  bool _sweepStopped = false;
  bool _cancelled = false;

  bool get cancelled => _cancelled;

  bool get sweepStopped => _sweepStopped || _cancelled;

  void stopSweep() => _sweepStopped = true;

  void cancel() => _cancelled = true;
}

final class CollectedReport {
  const CollectedReport({
    required this.data,
    required this.secrets,
    this.profileId,
  });

  final ReportData data;
  final List<String> secrets;
  final int? profileId;
}

Future<T?> _quiet<T>(Future<T?> Function() read) async {
  try {
    return await read();
  } on Object {
    return null;
  }
}

final _appLine = RegExp(r'^\S+ \S+ \[APP\] ');

final class ReportCollector {
  const ReportCollector(this.sources);

  final ReportSources sources;

  Future<CollectedReport> collect({
    required String id,
    required DateTime createdAt,
    required ReportOptions options,
    ReportProgressCallback? onProgress,
    ReportControl? control,
  }) async {
    final ctl = control ?? ReportControl();
    void phase(ReportPhase phase) {
      if (ctl.cancelled) throw const ReportCancelled();
      onProgress?.call(ReportProgress(phase));
    }

    T? wanted<T>(ReportSection section, T? value) =>
        options.includes(section) ? value : null;

    phase(ReportPhase.snapshot);
    final device = await _quiet(sources.device) ?? const {};
    final environment = options.includes(ReportSection.environment)
        ? await _quiet(sources.environment)
        : null;
    final profile = await _quiet(() async => sources.profile());
    final config = options.includes(ReportSection.config)
        ? await _quiet(sources.config)
        : null;

    phase(ReportPhase.path);
    final connected = sources.connected;
    final freshPath = connected ? await _quiet(sources.runPath) : null;
    final path = freshPath ?? sources.lastPath;

    phase(ReportPhase.sweep);
    List<SweepRow>? rows;
    if (options.includes(ReportSection.servers) && connected) {
      rows = await _quiet(
        () => sources.sweeper.sweep(
          onProgress: (done, total) => onProgress?.call(
            ReportProgress(ReportPhase.sweep, done: done, total: total),
          ),
          cancelled: () => ctl.sweepStopped,
        ),
      );
    }

    phase(ReportPhase.services);
    final services = options.includes(ReportSection.services) && connected
        ? await _quiet(sources.services)
        : null;
    if (ctl.cancelled) throw const ReportCancelled();

    final since = createdAt.subtract(reportHistoryWindow);
    final findings = sources.findings();
    final incidents = [
      for (final event
          in await _quiet(sources.incidents) ?? <DiagnosticEvent>[])
        if (!event.at.isBefore(since)) event,
    ];
    final events =
        await _quiet(() => sources.recorder.events(since: since)) ??
        const <PassiveEvent>[];
    final logs = options.includes(ReportSection.logs)
        ? await _logs(options.captureLines)
        : null;

    final manifest = <String, Object?>{
      'id': id,
      'createdAt': createdAt.toUtc().toIso8601String(),
      ...device,
      'redaction': options.redaction.name,
    };
    final data = ReportData(
      manifest: manifest,
      summary: _summary(
        device: device,
        path: path,
        findings: findings,
        incidents: incidents,
        rows: rows,
        note: options.note,
        profile: profile?.label,
      ),
      findings: wanted(
        ReportSection.findings,
        findingsJson(findings, incidents),
      ),
      path: wanted(
        ReportSection.path,
        path == null ? null : pathJson(path, fresh: freshPath != null),
      ),
      servers: rows == null
          ? null
          : [for (final row in rows) sweepRowJson(row)],
      services: services,
      environment: environment,
      profile: wanted(
        ReportSection.profile,
        profile == null ? null : _profileJson(profile, events),
      ),
      history: wanted(
        ReportSection.history,
        historyJson(since: since, incidents: incidents, events: events),
      ),
      config: config,
      logs: logs,
    );
    return CollectedReport(
      data: data,
      secrets: profile?.secrets ?? const [],
      profileId: profile?.id,
    );
  }

  Future<Map<String, List<String>>> _logs(List<String>? capture) async {
    final recorder = sources.recorder;
    await _quiet(recorder.flush);
    final lines = await _quiet(recorder.logLines) ?? const <String>[];
    final core = <String>[];
    final app = <String>[];
    for (final line in lines) {
      (_appLine.hasMatch(line) ? app : core).add(line);
    }
    return {
      if (core.isNotEmpty) ReportLogs.core: core,
      if (app.isNotEmpty) ReportLogs.app: app,
      if (capture != null && capture.isNotEmpty) ReportLogs.capture: capture,
    };
  }

  Map<String, Object?> _profileJson(
    ReportProfile profile,
    List<PassiveEvent> events,
  ) {
    final updates = [
      for (final event in events)
        if (event.kind == 'profileUpdate' &&
            event.data['profile'] == profile.id)
          {
            'at': event.time.toUtc().toIso8601String(),
            'ok': event.data['ok'],
            'error': ?event.data['error'],
          },
    ];
    return {
      ...profile.json,
      'updates': updates.length > 10
          ? updates.sublist(updates.length - 10)
          : updates,
    };
  }
}

Map<String, Object?> _summary({
  required Map<String, Object?> device,
  required PathResult? path,
  required List<Finding> findings,
  required List<DiagnosticEvent> incidents,
  required List<SweepRow>? rows,
  required String? note,
  required String? profile,
}) {
  final failed = path?.failed;
  final verdict = pathVerdict(path);
  final critical = findings.any((f) => f.severity == CheckSeverity.critical);
  final healed = [
    for (final event in incidents)
      if (event.kind == DiagnosticEventKind.remedyApplied)
        {
          'remedy': event.subject,
          'outcome': event.outcome,
          'at': event.at.toUtc().toIso8601String(),
        },
  ];
  final app = device['app'] as Map<String, Object?>? ?? const {};
  final trimmedNote = note?.trim();
  return {
    'verdict': verdict != 'fail' && critical ? 'fail' : verdict,
    if (failed != null) ...{
      'failedStep': failed.step.name,
      'cause': ?failed.cause?.id,
      'detail': ?failed.detail,
    },
    'findings': {
      for (final severity in CheckSeverity.values)
        severity.name: [
          for (final finding in [...findings]..sort(compareFindings))
            if (finding.severity == severity) finding.id,
        ],
    },
    'healed': healed.length > 5 ? healed.sublist(healed.length - 5) : healed,
    if (rows != null)
      'servers': {
        'total': rows.length,
        for (final status in SweepStatus.values)
          if (rows.where((r) => r.status == status).length case final n
              when n > 0)
            status.name: n,
      },
    if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
    'app':
        '${app['name'] ?? 'ReClash'} ${app['version'] ?? '?'} '
        '(${app['build'] ?? '?'}, ${app['flavor'] ?? '?'})',
    'os': device['os'] ?? device['platform'] ?? '?',
    'device': device['device'] ?? '?',
    'profile': ?profile,
  };
}
