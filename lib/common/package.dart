import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/enum/enum.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
    '$appName/v$version',
    'clash-verge',
    'Platform/${Platform.operatingSystem}',
  ].join(' ');
}

class AppVersion implements Comparable<AppVersion> {
  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    required this.prerelease,
    required this.build,
  });

  final BigInt major;
  final BigInt minor;
  final BigInt patch;
  final List<String> prerelease;
  final String? build;

  bool get isPreRelease => prerelease.isNotEmpty;

  @override
  int compareTo(AppVersion other) {
    for (final (left, right) in [
      (major, other.major),
      (minor, other.minor),
      (patch, other.patch),
    ]) {
      final comparison = left.compareTo(right);
      if (comparison != 0) return comparison;
    }
    if (prerelease.isEmpty || other.prerelease.isEmpty) {
      if (prerelease.isEmpty && other.prerelease.isEmpty) return 0;
      return prerelease.isEmpty ? 1 : -1;
    }
    for (var index = 0; index < prerelease.length; index++) {
      if (index >= other.prerelease.length) return 1;
      final left = prerelease[index];
      final right = other.prerelease[index];
      final leftNumber = BigInt.tryParse(left);
      final rightNumber = BigInt.tryParse(right);
      if (leftNumber != null && rightNumber != null) {
        final comparison = leftNumber.compareTo(rightNumber);
        if (comparison != 0) return comparison;
      } else if (leftNumber != null) {
        return -1;
      } else if (rightNumber != null) {
        return 1;
      } else {
        final comparison = left.compareTo(right);
        if (comparison != 0) return comparison;
      }
    }
    return prerelease.length.compareTo(other.prerelease.length);
  }
}

AppVersion parseAppVersion(String value) {
  final normalized = value.replaceFirst(RegExp(r'^v'), '');
  final match = RegExp(
    r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$',
  ).firstMatch(normalized);
  if (match == null) throw FormatException('Invalid app version: $value');
  for (final core in [match[1]!, match[2], match[3]].whereType<String>()) {
    if (core.length > 1 && core.startsWith('0')) {
      throw FormatException('Invalid numeric version identifier: $value');
    }
  }
  final prerelease = match[4]?.split('.') ?? const <String>[];
  if (prerelease.any(
    (item) =>
        item.length > 1 &&
        item.startsWith('0') &&
        BigInt.tryParse(item) != null,
  )) {
    throw FormatException('Invalid numeric prerelease identifier: $value');
  }
  return AppVersion(
    major: BigInt.parse(match[1]!),
    minor: BigInt.parse(match[2] ?? '0'),
    patch: BigInt.parse(match[3] ?? '0'),
    prerelease: prerelease,
    build: match[5],
  );
}

AppVersion? tryParseAppVersion(String value) {
  try {
    return parseAppVersion(value);
  } on FormatException {
    return null;
  }
}

int compareVersions(String version1, String version2) {
  final left = parseAppVersion(version1);
  final right = parseAppVersion(version2);
  final precedence = left.compareTo(right);
  if (precedence != 0) return precedence;
  final leftBuild = BigInt.tryParse(left.build ?? '');
  final rightBuild = BigInt.tryParse(right.build ?? '');
  if (leftBuild != null && rightBuild != null) {
    return leftBuild.compareTo(rightBuild);
  }
  return (left.build ?? '').compareTo(right.build ?? '');
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
