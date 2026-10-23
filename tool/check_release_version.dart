import 'dart:io';

import 'package:yaml/yaml.dart';

import 'src/release_version.dart';

void main(List<String> args) {
  if (args.length > 1) {
    stderr.writeln('Usage: dart run tool/check_release_version.dart [tag]');
    exitCode = 64;
    return;
  }

  try {
    stdout.writeln(
      validateReleaseVersion(
        File('pubspec.yaml').readAsStringSync(),
        args.isEmpty ? null : args.single,
      ),
    );
  } on YamlException catch (error) {
    stderr.writeln('Invalid pubspec.yaml: $error');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Could not read pubspec.yaml: $error');
    exitCode = 1;
  }
}

String validateReleaseVersion(String pubspecSource, [String? tag]) {
  final pubspec = loadYaml(pubspecSource);
  if (pubspec is! YamlMap || pubspec['version'] is! String) {
    throw const FormatException('Missing or invalid pubspec version');
  }
  final version = ReleaseVersion.parse(pubspec['version'] as String);
  if (version.base
      .split('.')
      .any((part) => part.length > 1 && part.startsWith('0'))) {
    throw FormatException('Invalid release version: ${pubspec['version']}');
  }

  final matchesLegacyPrerelease =
      version.name == version.base &&
      RegExp(
        '^v${RegExp.escape(version.base)}-pre\\.[1-9][0-9]*\$',
      ).hasMatch(tag ?? '');
  if (tag != null &&
      tag.isNotEmpty &&
      tag != 'v${version.name}' &&
      !matchesLegacyPrerelease) {
    throw FormatException(
      'Tag $tag does not match pubspec version ${version.name}',
    );
  }
  return version.name;
}
