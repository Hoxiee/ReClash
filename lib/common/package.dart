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

/// A pre build tells the user once per installed version that it is for
/// testing, even when first-run setup is still active.
bool shouldShowPreReleaseNotice({
  required String appEnv,
  required String version,
  required String? acknowledgedVersion,
}) {
  if (appEnv != 'pre' || acknowledgedVersion == version) return false;
  return tryParseAppVersion(version)?.isPreRelease ?? false;
}

bool _eligibleUpdate(
  Map<String, dynamic> release, {
  required String installedVersion,
  required UpdateChannel channel,
}) {
  if (release['draft'] == true) return false;
  final tag = release['tag_name'];
  if (tag is! String || tryParseAppVersion(tag) == null) return false;
  if (compareVersions(tag, installedVersion) <= 0) return false;
  return channel != UpdateChannel.release ||
      !isPrereleaseRelease(
        tag: tag,
        flaggedPrerelease: release['prerelease'] == true,
      );
}

Map<String, dynamic>? selectUpdateRelease(
  List<Map<String, dynamic>> releases, {
  required String installedVersion,
  required UpdateChannel channel,
}) {
  if (tryParseAppVersion(installedVersion) == null) return null;
  Map<String, dynamic>? best;
  for (final release in releases) {
    if (!_eligibleUpdate(
      release,
      installedVersion: installedVersion,
      channel: channel,
    )) {
      continue;
    }
    if (best == null ||
        compareVersions(
              release['tag_name'] as String,
              best['tag_name'] as String,
            ) >
            0) {
      best = release;
    }
  }
  return best;
}

/// Releases the update skips over: newer than the installed version, older
/// than [selected], newest first.
List<Map<String, dynamic>> selectIntermediateReleases(
  List<Map<String, dynamic>> releases, {
  required String installedVersion,
  required UpdateChannel channel,
  required String selected,
}) {
  if (tryParseAppVersion(installedVersion) == null) return const [];
  return releases
      .where(
        (release) =>
            _eligibleUpdate(
              release,
              installedVersion: installedVersion,
              channel: channel,
            ) &&
            compareVersions(release['tag_name'] as String, selected) < 0,
      )
      .toList()
    ..sort(
      (a, b) =>
          compareVersions(b['tag_name'] as String, a['tag_name'] as String),
    );
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
