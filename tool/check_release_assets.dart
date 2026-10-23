import 'dart:io';

import 'check_release_version.dart';

List<String> releaseAssetNames(String version) => [
  for (final abi in ['arm64-v8a', 'armeabi-v7a', 'x86_64'])
    'ReClash-$version-android-$abi.apk',
  for (final arch in ['amd64', 'arm64']) ...[
    'ReClash-$version-windows-$arch-setup.exe',
    'ReClash-$version-windows-$arch.zip',
    'ReClash-$version-macos-$arch.dmg',
    for (final format in ['deb', 'rpm', 'pkg.tar.xz'])
      'ReClash-$version-linux-$arch.$format',
  ],
  'ReClash-$version-linux-amd64.AppImage',
]..sort();

void checkReleaseAssets(Directory directory, String version) {
  final expected = releaseAssetNames(version).toSet();
  final files = directory.listSync(followLinks: false);
  final actual = files.map((file) => file.uri.pathSegments.last).toSet();
  final missing = expected.difference(actual).toList()..sort();
  final extra = actual.difference(expected).toList()..sort();
  final invalid = [
    for (final file in files)
      if (file is! File || file.lengthSync() == 0) file.uri.pathSegments.last,
  ]..sort();
  if (missing.isNotEmpty || extra.isNotEmpty || invalid.isNotEmpty) {
    throw FormatException(
      'Release assets mismatch: missing=$missing, extra=$extra, '
      'empty or non-regular=$invalid',
    );
  }
}

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/check_release_assets.dart <tag>');
    exitCode = 64;
    return;
  }
  try {
    final version = validateReleaseVersion(
      File('pubspec.yaml').readAsStringSync(),
      args.single,
    );
    if (args.single.isEmpty) {
      throw const FormatException('Release tag must not be empty');
    }
    checkReleaseAssets(Directory('dist'), version);
    stdout.writeln(
      'All ${releaseAssetNames(version).length} release assets are present and non-empty.',
    );
  } on Object catch (error) {
    stderr.writeln('Release asset validation failed: $error');
    exitCode = 1;
  }
}
