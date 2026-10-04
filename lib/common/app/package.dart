import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua =>
      ['$appName/v$version', 'Platform/${Platform.operatingSystem}'].join(' ');
}

PackageInfo releasePackageInfo(
  PackageInfo native, {
  String version = const String.fromEnvironment('APP_VERSION'),
  String buildNumber = const String.fromEnvironment('APP_BUILD_NUMBER'),
}) => PackageInfo(
  appName: native.appName,
  packageName: native.packageName,
  version: version.isEmpty ? native.version : version,
  buildNumber: buildNumber.isEmpty ? native.buildNumber : buildNumber,
  buildSignature: native.buildSignature,
  installerStore: native.installerStore,
  installTime: native.installTime,
  updateTime: native.updateTime,
);

/// Parses an app version such as `0.1.0-pre.2` or a short `1.2` into a semver
/// [Version], zero-padding a missing patch/minor so comparisons stay total.
Version parseAppVersion(String value) {
  final match = RegExp(r'^\d+(?:\.\d+){0,2}').firstMatch(value);
  if (match == null) {
    throw FormatException('No semantic version in "$value"');
  }
  final base = match.group(0)!;
  final padding = List.filled(3 - base.split('.').length, '.0').join();
  return Version.parse('$base$padding${value.substring(base.length)}');
}

Version? tryParseAppVersion(String value) {
  try {
    return parseAppVersion(value);
  } on FormatException {
    return null;
  }
}

int compareVersions(String version1, String version2) =>
    parseAppVersion(version1).compareTo(parseAppVersion(version2));

const releaseEpochMarker = '<!-- reclash:release-epoch:1 -->';

bool isNewerAppRelease({
  required String remoteVersion,
  required String installedVersion,
  required String? body,
}) =>
    (body?.contains(releaseEpochMarker) ?? false) &&
    compareVersions(
          remoteVersion.replaceFirst(RegExp(r'^v'), ''),
          installedVersion,
        ) >
        0;

/// A release is a prerelease when its tag carries a semver prerelease segment
/// (`-pre.2`) or GitHub's own `prerelease` flag is set, so a stable tag a
/// maintainer still marked as a beta is treated as one.
bool isPrereleaseRelease({
  required String tag,
  required bool flaggedPrerelease,
}) {
  if (flaggedPrerelease) return true;
  final version = tryParseAppVersion(tag.replaceFirst(RegExp(r'^v'), ''));
  return version?.isPreRelease ?? false;
}

/// Picks the best upgrade from a GitHub releases payload for a build on
/// [installedVersion]. Every candidate must clear [isNewerAppRelease] (epoch
/// marker plus a higher version) and not be a draft. Stable releases are always
/// eligible, so a prerelease build can always step onto the finished release.
/// Prereleases are offered to a build already on a prerelease, or to a stable
/// build only when [acceptPrereleases] opts in. Among the survivors the highest
/// version wins, so a late hotfix to an old line never shadows the real newest.
Map<String, dynamic>? selectUpdateRelease(
  List<Map<String, dynamic>> releases, {
  required String installedVersion,
  required bool acceptPrereleases,
}) {
  final installed = tryParseAppVersion(installedVersion);
  if (installed == null) return null;
  final allowPrereleases = acceptPrereleases || installed.isPreRelease;
  Map<String, dynamic>? best;
  Version? bestVersion;
  for (final release in releases) {
    if (release['draft'] == true) continue;
    final tag = release['tag_name'];
    if (tag is! String) continue;
    final candidate = tryParseAppVersion(tag.replaceFirst(RegExp(r'^v'), ''));
    if (candidate == null) continue;
    final prerelease = isPrereleaseRelease(
      tag: tag,
      flaggedPrerelease: release['prerelease'] == true,
    );
    if (prerelease && !allowPrereleases) continue;
    if (!isNewerAppRelease(
      remoteVersion: tag,
      installedVersion: installedVersion,
      body: release['body'] as String?,
    )) {
      continue;
    }
    if (bestVersion == null || candidate.compareTo(bestVersion) > 0) {
      best = release;
      bestVersion = candidate;
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
