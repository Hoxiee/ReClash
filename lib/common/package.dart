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

int compareVersions(String version1, String version2) {
  Version parse(String value) {
    final match = RegExp(r'^\d+(?:\.\d+){0,2}').firstMatch(value)!;
    final base = match.group(0)!;
    final padding = List.filled(3 - base.split('.').length, '.0').join();
    return Version.parse('$base$padding${value.substring(base.length)}');
  }

  return parse(version1).compareTo(parse(version2));
}

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
