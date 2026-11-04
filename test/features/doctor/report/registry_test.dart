import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/report/registry.dart';
import 'package:reclash/features/doctor/report/sources.dart';

ReportRecord _record(String id, DateTime at, {int? profile = 3}) =>
    ReportRecord(
      id: id,
      profileId: profile,
      createdAt: at,
      redaction: 'public',
    );

void main() {
  late Directory dir;
  late DateTime now;
  late FileReportRegistry registry;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('report_registry');
    now = DateTime.utc(2026, 11, 3, 12);
    registry = FileReportRegistry(directory: () async => dir, now: () => now);
  });

  tearDown(() => dir.delete(recursive: true));

  test('find returns a recorded report and list is newest first', () async {
    await registry.record(
      _record('RC-AAAA-0001', now.subtract(const Duration(days: 2))),
    );
    await registry.record(_record('RC-AAAA-0002', now, profile: null));

    final found = await registry.find('RC-AAAA-0001');
    expect(found?.profileId, 3);
    expect(found?.redaction, 'public');
    expect(await registry.find('RC-ZZZZ-9999'), isNull);
    expect(
      [for (final r in await registry.list()) r.id],
      ['RC-AAAA-0002', 'RC-AAAA-0001'],
    );

    final reopened = FileReportRegistry(
      directory: () async => dir,
      now: () => now,
    );
    expect((await reopened.find('RC-AAAA-0002'))?.profileId, isNull);
  });

  test('a report older than 30 days is gone and pruned on write', () async {
    await registry.record(_record('RC-OLD0-0001', now));
    now = now.add(reportRetention + const Duration(minutes: 1));

    expect(await registry.find('RC-OLD0-0001'), isNull);
    expect(await registry.list(), isEmpty);

    await registry.record(_record('RC-NEW0-0001', now));
    final file = File('${dir.path}/diagnostics/reports.json');
    expect(file.readAsStringSync(), isNot(contains('RC-OLD0-0001')));
  });

  test('recording an id twice keeps one entry', () async {
    await registry.record(_record('RC-AAAA-0001', now));
    await registry.record(_record('RC-AAAA-0001', now, profile: 5));
    final records = await registry.list();
    expect(records, hasLength(1));
    expect(records.single.profileId, 5);
  });

  test('a corrupt file reads as empty and is replaced', () async {
    File('${dir.path}/diagnostics/reports.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('{not json');
    expect(await registry.list(), isEmpty);
    await registry.record(_record('RC-AAAA-0001', now));
    expect((await registry.find('RC-AAAA-0001'))?.id, 'RC-AAAA-0001');
  });
}
