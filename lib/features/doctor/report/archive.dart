import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'html.dart';
import 'redact.dart';
import 'report.dart';
import 'summary.dart';

const reportSizeCap = 10 * 1024 * 1024;

abstract final class ReportFiles {
  static const readme = 'README.md';
  static const html = 'report.html';
  static const summary = '01-summary.md';
  static const findings = '02-findings.json';
  static const path = '03-path.json';
  static const servers = '04-servers.csv';
  static const services = '05-services.json';
  static const environment = '06-environment.json';
  static const profile = '07-profile.json';
  static const history = '08-history.json';
  static const config = '09-config.yaml';
  static const manifest = 'report.json';

  static const logs = {
    ReportLogs.core: 'logs/core.log',
    ReportLogs.app: 'logs/app.log',
    ReportLogs.logcat: 'logs/logcat.txt',
    ReportLogs.capture: 'logs/capture.log',
  };
}

const serverColumns = [
  'node',
  'group',
  'type',
  'server',
  'port',
  'status',
  'resolveMs',
  'tcpMs',
  'delayMs',
  'lastDelayMs',
];

/// `reclash-report-<yyyy-mm-dd-hhmm>-<id>.zip`, in the device's local time.
String reportArchiveName(DateTime createdAt, String id) {
  final t = createdAt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'reclash-report-${t.year}-${two(t.month)}-${two(t.day)}-'
      '${two(t.hour)}${two(t.minute)}-$id.zip';
}

List<String> reportFileNames(ReportData data) => [
  ReportFiles.readme,
  ReportFiles.html,
  ReportFiles.summary,
  if (data.findings != null) ReportFiles.findings,
  if (data.path != null) ReportFiles.path,
  if (data.servers != null) ReportFiles.servers,
  if (data.services != null) ReportFiles.services,
  if (data.environment != null) ReportFiles.environment,
  if (data.profile != null) ReportFiles.profile,
  if (data.history != null) ReportFiles.history,
  if (data.config != null) ReportFiles.config,
  for (final MapEntry(:key, :value) in ReportFiles.logs.entries)
    if (data.logs?[key] != null) value,
  ReportFiles.manifest,
];

const _json = JsonEncoder.withIndent('  ');

String _csvCell(Object? value) {
  var text = value?.toString() ?? '';
  if (text.startsWith(RegExp('[=+@]'))) text = "'$text";
  return text.contains(RegExp('[",\n\r]'))
      ? '"${text.replaceAll('"', '""')}"'
      : text;
}

String serversCsv(List<Map<String, Object?>> rows) {
  final out = StringBuffer()..writeln(serverColumns.join(','));
  for (final row in rows) {
    out.writeln(serverColumns.map((column) => _csvCell(row[column])).join(','));
  }
  return out.toString();
}

/// Archive entry name to its text, in archive order.
Map<String, String> reportEntries(ReportData data) {
  final files = reportFileNames(data);
  final full = data.copyWith(manifest: {...data.manifest, 'files': files});
  String json(String schema, Map<String, Object?> body) =>
      '${_json.convert({'schema': schema, ...body})}\n';
  return {
    ReportFiles.readme: reportReadme(full, files),
    ReportFiles.html: renderReportHtml(full),
    ReportFiles.summary: reportSummaryText(full),
    if (full.findings case final findings?)
      ReportFiles.findings: json(ReportSchema.findings, {'findings': findings}),
    if (full.path case final path?)
      ReportFiles.path: json(ReportSchema.path, path),
    if (full.servers case final servers?)
      ReportFiles.servers: serversCsv(servers),
    if (full.services case final services?)
      ReportFiles.services: json(ReportSchema.services, services),
    if (full.environment case final environment?)
      ReportFiles.environment: json(ReportSchema.environment, environment),
    if (full.profile case final profile?)
      ReportFiles.profile: json(ReportSchema.profile, profile),
    if (full.history case final history?)
      ReportFiles.history: json(ReportSchema.history, history),
    ReportFiles.config: ?full.config,
    for (final MapEntry(:key, :value) in ReportFiles.logs.entries)
      if (full.logs?[key] case final lines?)
        value: lines.isEmpty ? '' : '${lines.join('\n')}\n',
    ReportFiles.manifest: json(ReportSchema.manifest, full.manifest),
  };
}

int utf8Length(String text) {
  var bytes = 0;
  for (var i = 0; i < text.length; i++) {
    final unit = text.codeUnitAt(i);
    bytes += unit < 0x80
        ? 1
        : unit < 0x800
        ? 2
        : unit >= 0xD800 && unit < 0xE000
        ? 2
        : 3;
  }
  return bytes;
}

int _entriesSize(Map<String, String> entries) =>
    entries.values.fold(0, (total, text) => total + utf8Length(text));

/// Drops at least [bytes] from the front of the logs, the largest log first.
Map<String, List<String>> dropOldestLines(
  Map<String, List<String>> logs,
  int bytes,
) {
  final sizes = {
    for (final MapEntry(:key, :value) in logs.entries)
      key: value.fold(0, (total, line) => total + utf8Length(line) + 1),
  };
  final starts = {for (final key in logs.keys) key: 0};
  var removed = 0;
  while (removed < bytes) {
    String? largest;
    for (final key in logs.keys) {
      if (starts[key]! < logs[key]!.length &&
          (largest == null || sizes[key]! > sizes[largest]!)) {
        largest = key;
      }
    }
    if (largest == null) break;
    final line = logs[largest]![starts[largest]!];
    starts[largest] = starts[largest]! + 1;
    final size = utf8Length(line) + 1;
    sizes[largest] = sizes[largest]! - size;
    removed += size;
  }
  return {
    for (final MapEntry(:key, :value) in logs.entries)
      key: value.sublist(starts[key]!),
  };
}

const _truncatedConfig = '\n# truncated to fit the report size cap\n';

int _logsSize(Map<String, List<String>> logs) => logs.values.fold(
  0,
  (total, lines) =>
      lines.fold(total, (sum, line) => sum + utf8Length(line) + 1),
);

/// Measures uncompressed text, so the zip stays under [cap] however well it
/// compresses. Log lines also ride in `report.html`, so each dropped log
/// byte frees more than one archive byte; the ratio is measured, not assumed.
ReportData capReport(ReportData data, {int cap = reportSizeCap}) {
  var current = data;
  for (var round = 0; round < 16; round++) {
    final size = _entriesSize(reportEntries(current));
    final excess = size - cap;
    if (excess <= 0) return current;
    final logs = current.logs;
    final logBytes = logs == null ? 0 : _logsSize(logs);
    if (logs != null && logBytes > 0) {
      final bare = current.copyWith(
        logs: {for (final key in logs.keys) key: const []},
      );
      final ratio = (size - _entriesSize(reportEntries(bare))) / logBytes;
      final target = (excess / (ratio < 1 ? 1 : ratio)).ceil();
      current = current.copyWith(logs: dropOldestLines(logs, target));
    } else if (current.config case final config?
        when config.length > _truncatedConfig.length) {
      final keep = config.length - excess - _truncatedConfig.length;
      current = current.copyWith(
        config: '${config.substring(0, keep < 0 ? 0 : keep)}$_truncatedConfig',
      );
    } else {
      return current;
    }
  }
  return current;
}

Uint8List encodeReportArchive(Map<String, String> entries) {
  final archive = Archive();
  for (final MapEntry(:key, :value) in entries.entries) {
    archive.addFile(ArchiveFile.string(key, value));
  }
  return ZipEncoder().encodeBytes(archive);
}

typedef ReportPackRequest = ({
  Map<String, Object?> data,
  List<String> secrets,
  ReportRedaction redaction,
  String path,
});

typedef ReportPacked = ({Map<String, int> sizes, String summary});

/// Redacts, checks for leaks, caps and writes the archive off the UI isolate.
Future<ReportPacked> packReport(ReportPackRequest request) =>
    Isolate.run(() => packReportSync(request));

ReportPacked packReportSync(ReportPackRequest request, {List<int>? salt}) {
  final raw = ReportData.fromJson(request.data);
  final redactor = Redactor(
    level: request.redaction,
    secrets: {...request.secrets, ...fieldSecrets(raw.config ?? '')},
    salt: salt,
  );
  final redacted = redactReport(raw, redactor);
  if (findLeak(redacted, redactor.matcher) case final section?) {
    throw ReportLeak(section);
  }
  final entries = reportEntries(capReport(redacted));
  File(request.path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(encodeReportArchive(entries), flush: true);
  return (
    sizes: {
      for (final MapEntry(:key, :value) in entries.entries)
        key: utf8Length(value),
    },
    summary: entries[ReportFiles.summary]!,
  );
}
