import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:reclash/common/file.dart';
import 'package:reclash/common/path.dart';
import 'package:riverpod/riverpod.dart';

import 'sources.dart';

const reportRetention = Duration(days: 30);

/// Report ids in a small JSON file under the diagnostics directory, pruned of
/// expired records whenever one is added.
final class FileReportRegistry implements ReportRegistry {
  FileReportRegistry({
    required Future<Directory> Function() directory,
    DateTime Function() now = DateTime.now,
  }) : _directory = directory,
       _now = now;

  final Future<Directory> Function() _directory;
  final DateTime Function() _now;
  Future<void> _writes = Future.value();

  Future<File> _file() async =>
      File(p.join((await _directory()).path, 'diagnostics', 'reports.json'));

  Future<List<ReportRecord>> _read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final json = jsonDecode(await file.readAsString()) as List<Object?>;
      return [
        for (final item in json.whereType<Map<String, Object?>>())
          ?_decode(item),
      ];
    } on Object {
      return [];
    }
  }

  ReportRecord? _decode(Map<String, Object?> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (json['id'] case final String id when createdAt != null) {
      return ReportRecord(
        id: id,
        profileId: json['profileId'] as int?,
        createdAt: createdAt,
        redaction: json['redaction'] as String? ?? '',
      );
    }
    return null;
  }

  List<ReportRecord> _live(List<ReportRecord> records) {
    final cutoff = _now().subtract(reportRetention);
    return records.where((r) => r.createdAt.isAfter(cutoff)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> record(ReportRecord record) {
    final write = _writes.then((_) async {
      final records = _live([
        record,
        ...(await _read()).where((r) => r.id != record.id),
      ]);
      await (await _file()).writeAsStringAtomically(
        jsonEncode([
          for (final r in records)
            {
              'id': r.id,
              'profileId': r.profileId,
              'createdAt': r.createdAt.toUtc().toIso8601String(),
              'redaction': r.redaction,
            },
        ]),
      );
    });
    _writes = write.catchError((Object _) {});
    return write;
  }

  @override
  Future<ReportRecord?> find(String id) async {
    await _writes;
    return _live(await _read()).where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<List<ReportRecord>> list() async {
    await _writes;
    return _live(await _read());
  }
}

final fileReportRegistryProvider = Provider<FileReportRegistry>(
  (ref) => FileReportRegistry(
    directory: () async => Directory(await appPath.homeDirPath),
  ),
);

final reportRegistryProvider = Provider<ReportRegistry>(
  (ref) => ref.watch(fileReportRegistryProvider),
);
