import 'report.dart';

const _fileNotes = {
  'report.html': 'everything below on one page, offline',
  '01-summary.md': 'verdict, failed step, findings, the user\'s note',
  '02-findings.json': 'findings, evidence, what auto-heal tried',
  '03-path.json': 'connection path, step by step, with timings',
  '04-servers.csv': 'every node: DNS, TCP, delay, error',
  '05-services.json': 'services through the tunnel and direct',
  '06-environment.json': 'hosts, other VPNs and proxies, DNS, ports',
  '07-profile.json': 'subscription headers, updates, groups, selections',
  '08-history.json': 'last 7 days: incidents, repairs, crashes',
  '09-config.yaml': 'the effective runtime config',
  'logs/': 'core.log, app.log, logcat.txt, capture.log',
  'report.json': 'manifest: app, OS, device, file list',
};

String _utc(String? iso) {
  final time = DateTime.tryParse(iso ?? '')?.toUtc();
  if (time == null) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)} '
      '${two(time.hour)}:${two(time.minute)} UTC';
}

String _verdict(Map<String, Object?> summary) {
  final verdict = summary['verdict'] as String? ?? 'unknown';
  final step = summary['failedStep'] as String?;
  if (step == null) return verdict;
  final cause = summary['cause'] as String?;
  final detail = summary['detail'] as String?;
  return [
    '$verdict at $step',
    if (cause != null) '($cause)',
    if (detail != null && detail.isNotEmpty) '— $detail',
  ].join(' ');
}

String _findings(Map<String, Object?> summary) {
  final bySeverity = (summary['findings'] as Map?) ?? const {};
  final parts = [
    for (final MapEntry(:key, :value) in bySeverity.entries)
      if (value is List && value.isNotEmpty) '$key ${value.join(', ')}',
  ];
  return parts.isEmpty ? 'none' : parts.join('; ');
}

String? _healed(Map<String, Object?> summary) {
  final healed = (summary['healed'] as List?) ?? const [];
  if (healed.isEmpty) return null;
  return [
    for (final entry in healed.cast<Map<Object?, Object?>>())
      '${entry['remedy']} ${entry['outcome']}',
  ].join(', ');
}

String? _servers(Map<String, Object?> summary) {
  final servers = summary['servers'] as Map?;
  if (servers == null) return null;
  final total = servers['total'];
  final counts = [
    for (final MapEntry(:key, :value) in servers.entries)
      if (key != 'total') '$value $key',
  ];
  return ['$total tested', ...counts].join(', ');
}

/// `01-summary.md`, also the "Copy summary" text: short enough to paste into
/// a support chat as it is.
String reportSummaryText(ReportData data) {
  final summary = data.summary;
  final manifest = data.manifest;
  final note = summary['note'] as String?;
  final abi = manifest['abi'] as String?;
  final healed = _healed(summary);
  final servers = _servers(summary);
  final profile = summary['profile'] as String?;
  final created = _utc(manifest['createdAt'] as String?);
  final lines = [
    '# ReClash report ${data.id}',
    '',
    '- Verdict: ${_verdict(summary)}',
    '- Findings: ${_findings(summary)}',
    if (healed != null) '- Auto-heal: $healed',
    if (servers != null) '- Servers: $servers',
    if (note != null && note.isNotEmpty)
      '- Note: ${note.replaceAll('\n', ' ')}',
    '- App: ${summary['app']}${manifest['safeMode'] == true ? ', safe mode' : ''}',
    '- OS: ${summary['os']}${abi == null ? '' : ', $abi'}',
    '- Device: ${summary['device']}',
    if (profile != null) '- Profile: $profile',
    '- Created: $created, redaction: ${manifest['redaction']}',
  ];
  return '${lines.join('\n')}\n';
}

String reportReadme(ReportData data, List<String> files) {
  final id = data.id;
  final present = {
    for (final file in files) file.startsWith('logs/') ? 'logs/' : file,
  };
  final made = _utc(data.manifest['createdAt'] as String?);
  final redaction = data.manifest['redaction'];
  final lines = [
    '# ReClash support report $id',
    '',
    'Diagnostics from one device, made $made. Redaction: $redaction.',
    'Open report.html in a browser, or start with 01-summary.md.',
    '',
    '## Files',
    for (final MapEntry(key: file, value: note) in _fileNotes.entries)
      if (present.contains(file)) '- `$file` $note',
    '',
    '## Answer with a fix',
    'Reply with a signed link `reclash://fix?p=…&s=…` whose `rid` is $id.',
    'Sign it with the key your manifest lists in `support.keys`:',
    '`reclash-fix sign -key key.txt -report $id <actions>`.',
    'It works once, on this device, within 30 days.',
  ];
  return '${lines.join('\n')}\n';
}
