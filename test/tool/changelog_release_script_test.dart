@TestOn('!windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
    File('${root.path}/CHANGELOG.md').writeAsStringSync('# Changelog\n');
    git(['init', '--quiet', '--initial-branch=main']);
    git(['config', 'user.name', 'Release test']);
    git(['config', 'user.email', 'release-test@example.com']);
    git(['config', 'commit.gpgsign', 'false']);
    git(['config', 'core.hooksPath', '${root.path}/no-hooks']);
    git(['add', '.']);
    git(['commit', '--quiet', '-m', 'chore: initial fixture']);
    git(['tag', 'v0.1.0-pre.1']);
  });

  tearDown(() => root.deleteSync(recursive: true));

  ProcessResult release(List<String> arguments) => Process.runSync(
    'bash',
    ['tool/release.sh', ...arguments],
    workingDirectory: root.path,
    environment: environment,
  );

  String pubspec() => File('${root.path}/pubspec.yaml').readAsStringSync();

  String head() => git(['rev-parse', 'HEAD']).stdout as String;

  List<String> tags() => (git(['tag']).stdout as String).trim().split('\n');

  File notesFile(String tag) => File('${root.path}/release_notes/$tag.md');

  File summaryFile(String tag) =>
      File('${root.path}/release_summaries/$tag.json');

  String today() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
  }

  void stage(String tag, {bool notes = true, bool summary = true}) {
    File('${root.path}/pubspec.yaml').writeAsStringSync(
      'name: release_fixture\nversion: ${tag.substring(1)}+2026102301\n',
    );
    if (notes) {
      notesFile(tag)
        ..createSync(recursive: true)
        ..writeAsStringSync('### New\n\n- Something.\n');
    }
    if (summary) {
      summaryFile(tag)
        ..createSync(recursive: true)
        ..writeAsStringSync('{}\n');
    }
    git(['add', '.']);
    git(['commit', '--quiet', '-m', 'chore(release): prepare $tag']);
  }

  void expectOk(ProcessResult result) =>
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

  group('prepare', () {
    test('pre bumps the pubspec and creates skeletons without committing', () {
      final before = head();

      final result = release(['prepare', 'pre']);

      expectOk(result);
      expect(pubspec(), contains('version: 0.1.0-pre.2+${today()}01\n'));
      expect(notesFile('v0.1.0-pre.2').readAsStringSync(), contains('### New'));
      expect(
        summaryFile('v0.1.0-pre.2').readAsStringSync(),
        contains('"tag": "v0.1.0-pre.2"'),
      );
      expect(head(), before);
      expect(tags(), ['v0.1.0-pre.1']);
    });

    test('pre keeps notes and summary that are already authored', () {
      notesFile('v0.1.0-pre.2')
        ..createSync(recursive: true)
        ..writeAsStringSync('### Fixed\n\n- Authored.\n');
      summaryFile('v0.1.0-pre.2')
        ..createSync(recursive: true)
        ..writeAsStringSync('{"authored": true}\n');
      git(['add', '.']);
      git(['commit', '--quiet', '-m', 'docs: author notes']);

      expectOk(release(['prepare', 'pre']));

      expect(
        notesFile('v0.1.0-pre.2').readAsStringSync(),
        '### Fixed\n\n- Authored.\n',
      );
      expect(
        summaryFile('v0.1.0-pre.2').readAsStringSync(),
        '{"authored": true}\n',
      );
    });

    test('stable drops the prerelease suffix', () {
      expectOk(release(['prepare', 'stable']));

      expect(pubspec(), contains('version: 0.1.0+'));
      expect(notesFile('v0.1.0').existsSync(), isTrue);
      expect(summaryFile('v0.1.0').existsSync(), isTrue);
    });

    test('stable targets the next patch once the version is tagged', () {
      git(['tag', 'v0.1.0']);

      expectOk(release(['prepare', 'stable']));

      expect(pubspec(), contains('version: 0.1.1+'));
      expect(notesFile('v0.1.1').existsSync(), isTrue);
    });

    test('an explicit version overrides the pubspec', () {
      expectOk(release(['prepare', 'stable', '--version', '0.2.0']));

      expect(pubspec(), contains('version: 0.2.0+'));
      expect(notesFile('v0.2.0').existsSync(), isTrue);
    });

    test('refuses a dirty working tree', () {
      File('${root.path}/CHANGELOG.md').writeAsStringSync('# Edited\n');

      final result = release(['prepare', 'pre']);

      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('uncommitted changes'));
      expect(pubspec(), contains('0.1.0-pre.1+2026102301'));
    });

    test('refuses a version that is already tagged', () {
      git(['tag', 'v0.2.0']);

      final result = release(['prepare', 'pre', '--version', '0.2.0']);

      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('v0.2.0 is already tagged'));
      expect(pubspec(), contains('0.1.0-pre.1+2026102301'));
    });

    test('missing version argument reports a usage error', () {
      final result = release(['prepare', 'pre', '--version']);

      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('--version needs a value'));
      expect(git(['status', '--porcelain']).stdout, isEmpty);
    });
  });

  group('tag', () {
    test('refuses when the notes are not committed', () {
      stage('v0.1.0-pre.2', notes: false);

      final result = release(['tag', '--yes']);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        contains('release_notes/v0.1.0-pre.2.md is not committed'),
      );
      expect(tags(), ['v0.1.0-pre.1']);
    });

    test('refuses when the summary is not committed', () {
      stage('v0.1.0-pre.2', summary: false);

      final result = release(['tag', '--yes']);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr,
        contains('release_summaries/v0.1.0-pre.2.json is not committed'),
      );
      expect(tags(), ['v0.1.0-pre.1']);
    });

    test('refuses when the pubspec version is already tagged', () {
      final result = release(['tag', '--yes']);

      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('v0.1.0-pre.1 is already tagged'));
    });

    test('dry run changes nothing', () {
      stage('v0.1.0-pre.2');
      final before = head();

      final result = release(['tag', '--dry-run']);

      expectOk(result);
      expect(result.stdout, contains('dry run'));
      expect(head(), before);
      expect(tags(), ['v0.1.0-pre.1']);
      expect(git(['status', '--porcelain']).stdout, isEmpty);
    });

    test('--yes creates a lightweight tag at HEAD and pushes nothing', () {
      stage('v0.1.0-pre.2');

      final result = release(['tag', '--yes']);

      expectOk(result);
      expect(result.stdout, contains('Nothing was pushed'));
      expect(git(['tag', '--points-at', 'HEAD']).stdout, 'v0.1.0-pre.2\n');
      expect(git(['cat-file', '-t', 'v0.1.0-pre.2']).stdout, 'commit\n');
    });
  });

  test('bump_version accepts a prerelease source version', () {
    final result = Process.runSync('bash', [
      'tool/bump_version.sh',
      'major',
    ], workingDirectory: root.path);

    expectOk(result);
    expect(pubspec(), contains('version: 0.1.1+2026102301\n'));
  });

  test('no arguments prints usage and exits 64', () {
    final result = release([]);

    expect(result.exitCode, 64);
    expect(result.stderr, contains('Usage:'));
  });
}
