import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const _relativeSource = 'lib/common/config/client_compatibility.dart';

/// A subscription-client User-Agent whose version drifts from an upstream we
/// can poll. `Manual` clients have no reliable release feed, so the tool only
/// lists them for a human to refresh by hand.
sealed class UaSource {
  const UaSource();
}

class GithubLatest extends UaSource {
  const GithubLatest(this.repo, this.render);
  final String repo;
  final String Function(String tag) render;
}

class Manual extends UaSource {
  const Manual(this.note);
  final String note;
}

class UaEntry {
  const UaEntry({
    required this.key,
    required this.constName,
    required this.source,
  });
  final String key;
  final String constName;
  final UaSource source;
}

String stripLeadingV(String tag) =>
    tag.startsWith('v') ? tag.substring(1) : tag;

final entries = <UaEntry>[
  UaEntry(
    key: 'clashMeta',
    constName: 'metaClashUserAgent',
    source: GithubLatest(
      'MetaCubeX/ClashMetaForAndroid',
      (tag) => 'ClashMetaForAndroid/${stripLeadingV(tag)}.Meta',
    ),
  ),
  UaEntry(
    key: 'v2rayng',
    constName: '_v2rayngUa',
    source: GithubLatest(
      '2dust/v2rayNG',
      (tag) => 'v2rayNG/${stripLeadingV(tag)}',
    ),
  ),
  // Panels key on the `Karing` name, not the build tail, so the raw tag is fine.
  UaEntry(
    key: 'singbox',
    constName: '_singboxUa',
    source: GithubLatest(
      'KaringX/karing',
      (tag) => 'Karing/${stripLeadingV(tag)}',
    ),
  ),
  const UaEntry(
    key: 'clash',
    constName: 'legacyClashUserAgent',
    source: Manual('ClashForAndroid is archived; 2.5.12 is its last release'),
  ),
  const UaEntry(
    key: 'happ',
    constName: '_happUa',
    source: Manual('Happ ships no public release feed; check happ.su'),
  ),
  const UaEntry(
    key: 'incy',
    constName: '_incyVersion',
    source: Manual('INCY has no public release feed; this const is version-only'),
  ),
];

final _constPattern = <String, RegExp>{};

RegExp _patternFor(String constName) => _constPattern.putIfAbsent(
  constName,
  () => RegExp("(const\\s+$constName\\s*=\\s*')([^']*)(';)"),
);

String? readConstValue(String source, String constName) =>
    _patternFor(constName).firstMatch(source)?.group(2);

String replaceConstValue(String source, String constName, String value) =>
    source.replaceFirstMapped(
      _patternFor(constName),
      (match) => '${match.group(1)}$value${match.group(3)}',
    );

Future<String?> _fetchLatestTag(String repo) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final request = await client.getUrl(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
    );
    request.headers
      ..set(HttpHeaders.userAgentHeader, 'ReClash-ua-bump')
      ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    final token = Platform.environment['GITHUB_TOKEN'];
    if (token != null && token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    final response = await request.close();
    if (response.statusCode != 200) {
      stderr.writeln('  $repo: HTTP ${response.statusCode}');
      return null;
    }
    final body = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(body);
    return decoded is Map && decoded['tag_name'] is String
        ? decoded['tag_name'] as String
        : null;
  } catch (error) {
    stderr.writeln('  $repo: $error');
    return null;
  } finally {
    client.close(force: true);
  }
}

enum _Status { ok, stale, manual, unknown }

class _Row {
  _Row(this.entry, this.current, this.latest, this.status);
  final UaEntry entry;
  final String current;
  final String? latest;
  final _Status status;
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'write',
      negatable: false,
      help: 'Rewrite stale User-Agent constants in place.',
    )
    ..addOption('root', help: 'Repository root, defaults to the cwd.')
    ..addFlag('help', abbr: 'h', negatable: false);
  final args = parser.parse(arguments);
  if (args.flag('help')) {
    stdout.writeln('Usage: dart run tool/update_client_uas.dart [--write]\n');
    stdout.writeln(parser.usage);
    return;
  }

  final root = args.option('root') ?? Directory.current.path;
  final file = File('$root/$_relativeSource');
  if (!file.existsSync()) {
    stderr.writeln('Source not found: ${file.path}');
    exitCode = 1;
    return;
  }
  var source = file.readAsStringSync();

  final rows = <_Row>[];
  for (final entry in entries) {
    final current = readConstValue(source, entry.constName);
    if (current == null) {
      stderr.writeln('Constant ${entry.constName} not found in source');
      exitCode = 1;
      return;
    }
    switch (entry.source) {
      case Manual():
        rows.add(_Row(entry, current, null, _Status.manual));
      case GithubLatest(:final repo, :final render):
        final tag = await _fetchLatestTag(repo);
        if (tag == null) {
          rows.add(_Row(entry, current, null, _Status.unknown));
          continue;
        }
        final latest = render(tag);
        rows.add(
          _Row(
            entry,
            current,
            latest,
            latest == current ? _Status.ok : _Status.stale,
          ),
        );
    }
  }

  _printTable(rows);

  final stale = rows.where((row) => row.status == _Status.stale).toList();
  if (args.flag('write')) {
    if (stale.isEmpty) {
      stdout.writeln('\nNothing to write; GitHub-backed clients are current.');
    } else {
      for (final row in stale) {
        source = replaceConstValue(source, row.entry.constName, row.latest!);
      }
      file.writeAsStringSync(source);
      stdout.writeln('\nUpdated ${stale.length} constant(s). Review git diff.');
    }
    _printManualReminder(rows);
    return;
  }

  _printManualReminder(rows);
  if (stale.isNotEmpty) {
    stdout.writeln('\n${stale.length} client(s) stale. Run with --write.');
    exitCode = 1;
  }
}

void _printTable(List<_Row> rows) {
  final keyWidth = rows.map((r) => r.entry.key.length).reduce(_max);
  final curWidth = rows.map((r) => r.current.length).reduce(_max);
  for (final row in rows) {
    final latest = switch (row.status) {
      _Status.manual => '(manual)',
      _Status.unknown => '(unreachable)',
      _ => row.latest ?? '',
    };
    stdout.writeln(
      '${row.entry.key.padRight(keyWidth)}  '
      '${row.current.padRight(curWidth)}  '
      '${latest.padRight(curWidth)}  '
      '${row.status.name.toUpperCase()}',
    );
  }
}

void _printManualReminder(List<_Row> rows) {
  final manual = rows
      .where((row) => row.status == _Status.manual)
      .toList();
  if (manual.isEmpty) return;
  stdout.writeln('\nCheck these by hand (no release feed):');
  for (final row in manual) {
    stdout.writeln('  ${row.entry.key}: ${(row.entry.source as Manual).note}');
  }
}

int _max(int a, int b) => a > b ? a : b;
