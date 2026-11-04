import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/report/archive.dart';
import 'package:reclash/features/doctor/report/report.dart';

Map<String, Object?> _fixture() =>
    jsonDecode(
          File(
            'test/features/doctor/report/fixtures/report_data.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

ReportData _data() => ReportData.fromJson(_fixture());

const _fullTree = [
  'README.md',
  'report.html',
  '01-summary.md',
  '02-findings.json',
  '03-path.json',
  '04-servers.csv',
  '05-services.json',
  '06-environment.json',
  '07-profile.json',
  '08-history.json',
  '09-config.yaml',
  'logs/core.log',
  'logs/app.log',
  'report.json',
];

Future<Archive> _pack(
  Map<String, Object?> data, {
  ReportRedaction redaction = ReportRedaction.provider,
}) async {
  final dir = await Directory.systemTemp.createTemp('report_archive');
  addTearDown(() => dir.delete(recursive: true));
  final path = '${dir.path}/r.zip';
  packReportSync(
    (data: data, secrets: const [], redaction: redaction, path: path),
    salt: const [7],
  );
  return ZipDecoder().decodeBytes(File(path).readAsBytesSync());
}

String _text(ArchiveFile file) => utf8.decode(file.content as List<int>);

void main() {
  test('report id is RC-XXXX-XXXX in Crockford base32', () {
    final random = Random(1);
    for (var i = 0; i < 200; i++) {
      expect(newReportId(random), matches(reportIdPattern));
    }
    expect(reportIdPattern.hasMatch('RC-ILOU-0000'), isFalse);
  });

  test('archive name carries local time and id', () {
    final created = DateTime(2026, 11, 3, 8, 5);
    expect(
      reportArchiveName(created, 'RC-7Q2M-K4XD'),
      'reclash-report-2026-11-03-0805-RC-7Q2M-K4XD.zip',
    );
  });

  test(
    'the fixture packs into the full tree, each JSON with a schema',
    () async {
      final archive = await _pack(_fixture());
      expect([for (final f in archive.files) f.name], _fullTree);

      final schemas = {
        for (final file in archive.files)
          if (file.name.endsWith('.json'))
            file.name: (jsonDecode(_text(file)) as Map)['schema'],
      };
      expect(schemas, {
        '02-findings.json': ReportSchema.findings,
        '03-path.json': ReportSchema.path,
        '05-services.json': ReportSchema.services,
        '06-environment.json': ReportSchema.environment,
        '07-profile.json': ReportSchema.profile,
        '08-history.json': ReportSchema.history,
        'report.json': ReportSchema.manifest,
      });

      final manifest =
          jsonDecode(_text(archive.findFile('report.json')!)) as Map;
      expect(manifest['files'], _fullTree);
      expect(manifest['id'], 'RC-7Q2M-K4XD');

      final csv = _text(archive.findFile('04-servers.csv')!).trim().split('\n');
      expect(csv.first, serverColumns.join(','));
      expect(csv, hasLength(13));

      final summary = _text(archive.findFile('01-summary.md')!);
      expect(summary.trim().split('\n').length, lessThanOrEqualTo(15));
      expect(summary, contains('fail at server (timeout)'));

      final readme = _text(archive.findFile('README.md')!);
      expect(readme.trim().split('\n').length, lessThanOrEqualTo(25));
      expect(readme, contains('reclash://fix'));
      expect(readme, contains('reclash-support-key'));
      expect(readme, contains('RC-7Q2M-K4XD'));
    },
  );

  test('a section left out leaves no file behind', () async {
    final data = _fixture()
      ..remove('servers')
      ..remove('config')
      ..remove('environment');
    final logs = {...data['logs']! as Map}..remove('app');
    data['logs'] = logs;
    final archive = await _pack(data);
    final names = [for (final f in archive.files) f.name];
    expect(names, isNot(contains('04-servers.csv')));
    expect(names, isNot(contains('09-config.yaml')));
    expect(names, isNot(contains('06-environment.json')));
    expect(names, isNot(contains('logs/app.log')));
    expect(names, contains('logs/core.log'));
    final readme = _text(archive.findFile('README.md')!);
    expect(readme, isNot(contains('04-servers.csv')));
  });

  test('servers CSV defuses formula cells', () {
    final csv = serversCsv([
      {'node': '=HYPERLINK("x")', 'group': 'a,b', 'port': 443},
    ]);
    expect(csv.split('\n')[1], startsWith('"\'=HYPERLINK(""x"")","a,b"'));
  });

  group('size cap', () {
    test('drops the oldest log lines first', () {
      final core = [for (var i = 0; i < 1000; i++) 'line $i ${'x' * 90}'];
      final data = _data().copyWith(
        logs: {
          'core': core,
          'app': ['app 0'],
        },
      );
      final cap = utf8Length(reportEntries(data).values.join()) - 20000;

      final capped = capReport(data, cap: cap);
      final entries = reportEntries(capped);
      expect(utf8Length(entries.values.join()), lessThanOrEqualTo(cap));
      final kept = capped.logs!['core']!;
      expect(kept.last, core.last);
      expect(kept.first, isNot(core.first));
      expect(core.sublist(core.length - kept.length), kept);
      expect(capped.logs!['app'], ['app 0']);
    });

    test('the default cap is 10 MB of uncompressed text', () async {
      final data = _fixture();
      data['logs'] = {
        'core': [for (var i = 0; i < 120000; i++) 'core $i ${'y' * 80}'],
      };
      final dir = await Directory.systemTemp.createTemp('report_cap');
      addTearDown(() => dir.delete(recursive: true));
      final packed = packReportSync((
        data: data,
        secrets: const [],
        redaction: ReportRedaction.provider,
        path: '${dir.path}/r.zip',
      ));
      final total = packed.sizes.values.fold(0, (a, b) => a + b);
      expect(total, lessThanOrEqualTo(reportSizeCap));
      expect(total, greaterThan(reportSizeCap * 0.8));
      expect(packed.sizes['logs/core.log'], greaterThan(0));
    });
  });

  test('public redaction hashes hosts across the archive', () async {
    final archive = await _pack(_fixture(), redaction: ReportRedaction.public);
    for (final file in archive.files) {
      expect(
        _text(file),
        isNot(contains('nl1.edge.example.net')),
        reason: file.name,
      );
    }
  });
}
