import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/enum/enum.dart';

import 'common.dart';

export 'app_version.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
    '$appName/v$version',
    'clash-verge',
    'Platform/${Platform.operatingSystem}',
  ].join(' ');
}

bool isPrereleaseRelease({
  required String tag,
  required bool flaggedPrerelease,
}) {
  if (flaggedPrerelease) return true;
  return tryParseAppVersion(tag)?.isPreRelease ?? false;
}

Map<String, dynamic>? selectUpdateRelease(
  List<Map<String, dynamic>> releases, {
  required String installedVersion,
  required UpdateChannel channel,
}) {
  final installed = tryParseAppVersion(installedVersion);
  if (installed == null) return null;
  Map<String, dynamic>? best;
  for (final release in releases) {
    if (release['draft'] == true) continue;
    final tag = release['tag_name'];
    if (tag is! String) continue;
    final candidate = tryParseAppVersion(tag);
    if (candidate == null ||
        compareVersions(tag, installedVersion) <= 0 ||
        (channel == UpdateChannel.release &&
            isPrereleaseRelease(
              tag: tag,
              flaggedPrerelease: release['prerelease'] == true,
            ))) {
      continue;
    }
    if (best == null || compareVersions(tag, best['tag_name'] as String) > 0) {
      best = release;
    }
  }
  return best;
}

const releaseNotesBeginMarker = '<!-- reclash:changelog:begin -->';
const releaseNotesEndMarker = '<!-- reclash:changelog:end -->';

List<String> parseReleaseBody(String? body) {
  if (body == null) return [];
  final regex = RegExp(r'^[ \t]*-[ \t]+(.*)$', multiLine: true);
  return regex
      .allMatches(scopeReleaseNotes(body))
      .map((match) => match.group(1)?.trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

String scopeReleaseNotes(String body) {
  final begin = body.indexOf(releaseNotesBeginMarker);
  if (begin < 0) return body;
  final start = begin + releaseNotesBeginMarker.length;
  final end = body.indexOf(releaseNotesEndMarker, start);
  return end < 0 ? body.substring(start) : body.substring(start, end);
}
