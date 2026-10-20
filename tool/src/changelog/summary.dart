import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' show join;
import 'package:reclash/common/update_summary.dart';

import 'git.dart';

const releaseSummariesDirectory = 'release_summaries';
const _sourceLimit = 131072;

ReleaseSummary? readReleaseSummary(String root, String tag) {
  final parsedTag = VersionTag.tryParse(tag);
  if (parsedTag == null || parsedTag.name != tag) {
    throw FormatException('Invalid release summary tag', tag);
  }
  final directory = Directory('$root/$releaseSummariesDirectory');
  final file = File('${directory.path}/$tag.json');
  final type = FileSystemEntity.typeSync(file.path, followLinks: false);
  if (type == FileSystemEntityType.notFound) return null;
  if (type != FileSystemEntityType.file) {
    throw const FormatException('Release summaries must be regular files');
  }
  if (file.resolveSymbolicLinksSync() !=
      join(directory.resolveSymbolicLinksSync(), '$tag.json')) {
    throw const FormatException('Release summaries must be regular files');
  }
  if (file.lengthSync() > _sourceLimit) {
    throw const FormatException('Release summary source is too large');
  }
  final summary = ReleaseSummary.fromJson(jsonDecode(file.readAsStringSync()));
  if (summary.tag != tag) {
    throw FormatException(
      'Release summary tag does not match its filename',
      tag,
    );
  }
  final rendered = renderReleaseSummary(summary);
  if (parseReleaseSummary(rendered, tag: tag) == null) {
    throw const FormatException('Release summary cannot be read by the app');
  }
  return summary;
}

List<String> verifyReleaseSummaries(String root) {
  final directory = Directory('$root/$releaseSummariesDirectory');
  if (!directory.existsSync()) return const [];
  final problems = <String>[];
  final files =
      directory
          .listSync(followLinks: false)
          .where((entry) => entry.path.endsWith('.json'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));
  for (final entry in files) {
    final fileName = entry.uri.pathSegments.lastWhere(
      (segment) => segment.isNotEmpty,
    );
    final tag = fileName.substring(0, fileName.length - '.json'.length);
    try {
      if (entry is! File) {
        throw const FormatException('Release summaries must be regular files');
      }
      readReleaseSummary(root, tag);
    } on Object catch (error) {
      problems.add('$releaseSummariesDirectory/$fileName: $error');
    }
  }
  return problems;
}
