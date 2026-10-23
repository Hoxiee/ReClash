@TestOn('!windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_release_version.dart';

void main() {
  late Directory root;
  late Map<String, String> environment;

  ProcessResult git(List<String> arguments) {
    final result = Process.runSync(
      'git',
      arguments,
      workingDirectory: root.path,
    );
    expect(result.exitCode, 0, reason: '${result.stderr}');
    return result;
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('reclash-release-script-');
    Directory('${root.path}/tool').createSync();
    for (final name in ['release.sh', 'bump_version.sh']) {
      File('tool/$name').copySync('${root.path}/tool/$name');
    }
    final bin = Directory('${root.path}/bin')..createSync();
    File('${bin.path}/dart').writeAsStringSync('#!/bin/sh\nexit 0\n');
    final chmod = Process.runSync('chmod', [
      '+x',
      '${bin.path}/dart',
      '${root.path}/tool/bump_version.sh',
    ]);
    expect(chmod.exitCode, 0);
    environment = {'PATH': '${bin.path}:${Platform.environment['PATH']}'};
    File('${root.path}/pubspec.yaml').writeAsStringSync(
      'name: release_fixture\nversion: 0.1.0-pre.1+2026102301\n',
    );
    File('${root.path}/changelog.json').writeAsStringSync('{}\n');
    File('${root.path}/CHANGELOG.md').writeAsStringSync('# Changelog\n');
    git(['init', '--quiet', '--initial-branch=main']);
    git(['config', 'user.name', 'Release test']);
    git(['config', 'user.email', 'release-test@example.com']);
    git(['config', 'commit.gpgsign', 'false']);
    git(['config', 'core.hooksPath', '${root.path}/no-hooks']);
    git(['add', '.']);
    git(['commit', '--quiet', '-m', 'chore: initial fixture']);
  });

  tearDown(() => root.deleteSync(recursive: true));

  ProcessResult release(List<String> arguments) => Process.runSync(
    'bash',
    ['tool/release.sh', ...arguments],
    workingDirectory: root.path,
    environment: environment,
  );

  String pubspec() => File('${root.path}/pubspec.yaml').readAsStringSync();

  test('successive prereleases keep package names aligned with tags', () {
    for (final number in [1, 2]) {
      final result = release(['pre', '--yes']);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      final tag = 'v0.1.0-pre.$number';
      expect(validateReleaseVersion(pubspec(), tag), '0.1.0-pre.$number');
      expect(git(['tag', '--points-at', 'HEAD']).stdout, contains(tag));
      expect(git(['status', '--porcelain']).stdout, isEmpty);
    }
  });

  test('stable removes the prerelease suffix before tagging', () {
    final result = release(['stable', '--yes']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(validateReleaseVersion(pubspec(), 'v0.1.0'), '0.1.0');
    expect(git(['tag', '--points-at', 'HEAD']).stdout, contains('v0.1.0\n'));
  });

  test('explicit target replaces the full prerelease version', () {
    final result = release(['pre', '--version', '0.2.0', '--yes']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(validateReleaseVersion(pubspec(), 'v0.2.0-pre.1'), '0.2.0-pre.1');
  });

  test('dry run preserves tracked contents, HEAD and tags', () {
    final before = pubspec();
    final head = git(['rev-parse', 'HEAD']).stdout;
    final result = release(['pre', '--dry-run']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(pubspec(), before);
    expect(git(['rev-parse', 'HEAD']).stdout, head);
    expect(git(['tag']).stdout, isEmpty);
    expect(git(['status', '--porcelain']).stdout, isEmpty);
  });

  test('missing version argument reports a usage error', () {
    final result = release(['pre', '--version']);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('--version needs a value'));
    expect(git(['status', '--porcelain']).stdout, isEmpty);
  });

  test('patch bump accepts a prerelease source version', () {
    final result = Process.runSync('bash', [
      'tool/bump_version.sh',
      'major',
    ], workingDirectory: root.path);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(pubspec(), contains('version: 0.1.1+2026102301\n'));
  });
}
