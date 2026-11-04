import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:reclash/common/path.dart';
import 'package:riverpod/riverpod.dart';

import 'archive.dart';
import 'collector.dart';
import 'live.dart';
import 'registry.dart';
import 'report.dart';
import 'sources.dart';

const _staleArchive = Duration(days: 1);

final class ReportBuilder {
  ReportBuilder({
    required this.collector,
    required this.registry,
    required this.directory,
    DateTime Function() now = DateTime.now,
    Random? random,
    Future<ReportPacked> Function(ReportPackRequest request) pack = packReport,
  }) : _now = now,
       _random = random,
       _pack = pack;

  final ReportCollector collector;
  final FileReportRegistry registry;

  /// Where archives are written; older ones there are removed after a day.
  final Future<Directory> Function() directory;
  final DateTime Function() _now;
  final Random? _random;
  final Future<ReportPacked> Function(ReportPackRequest request) _pack;

  /// Throws [ReportCancelled] when [control] cancels, and `ReportLeak` when
  /// a secret survived redaction; neither leaves an archive behind.
  Future<ReportResult> build(
    ReportOptions options, {
    ReportProgressCallback? onProgress,
    ReportControl? control,
  }) async {
    final id = newReportId(_random);
    final createdAt = _now();
    final collected = await collector.collect(
      id: id,
      createdAt: createdAt,
      options: options,
      onProgress: onProgress,
      control: control,
    );
    if (control?.cancelled ?? false) throw const ReportCancelled();
    onProgress?.call(const ReportProgress(ReportPhase.packing));
    final dir = await directory();
    await _removeStale(dir);
    final file = File(p.join(dir.path, reportArchiveName(createdAt, id)));
    final packed = await _pack((
      data: collected.data.toJson(),
      secrets: collected.secrets,
      redaction: options.redaction,
      path: file.path,
    ));
    if (control?.cancelled ?? false) {
      await file.delete().then((_) {}, onError: (_) {});
      throw const ReportCancelled();
    }
    await registry.record(
      ReportRecord(
        id: id,
        profileId: collected.profileId,
        createdAt: createdAt,
        redaction: options.redaction.name,
      ),
    );
    return ReportResult(
      id: id,
      path: file.path,
      summary: packed.summary,
      sizes: packed.sizes,
      createdAt: createdAt,
      redaction: options.redaction,
    );
  }

  Future<void> _removeStale(Directory dir) async {
    try {
      if (!await dir.exists()) return;
      final cutoff = _now().subtract(_staleArchive);
      await for (final entity in dir.list()) {
        if (entity is File &&
            p.basename(entity.path).startsWith('reclash-report-') &&
            (await entity.lastModified()).isBefore(cutoff)) {
          await entity.delete();
        }
      }
    } on Object {
      return;
    }
  }
}

final reportBuilderProvider = Provider<ReportBuilder>(
  (ref) => ReportBuilder(
    collector: ReportCollector(RefReportSources(ref)),
    registry: ref.read(fileReportRegistryProvider),
    directory: () async =>
        Directory(p.join(await appPath.tempPath, 'reclash-reports')),
  ),
);
