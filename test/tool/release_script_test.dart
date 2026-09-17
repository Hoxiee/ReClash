import 'dart:io';

import 'package:test/test.dart';

void main() {
  if (Platform.isWindows) return;
  late Directory repo;
  late File pubspec;
  late Map<String, String> environment;
  final root = Directory.current.path;

  ProcessResult run(String command, List<String> args) => Process.runSync(
    command,
    args,
    workingDirectory: repo.path,
    environment: environment,
  );

  void git(List<String> args) {
    final result = run('git', args);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  }

  setUp(() {
    repo = Directory.systemTemp.createTempSync('reclash-release-script-');
    Directory('${repo.path}/tool').createSync();
    Directory('${repo.path}/bin').createSync();
    for (final name in ['release.sh', 'bump_version.sh']) {
      File('$root/tool/$name').copySync('${repo.path}/tool/$name');
      Process.runSync('chmod', ['+x', '${repo.path}/tool/$name']);
    }
    File('${repo.path}/bin/dart').writeAsStringSync('#!/bin/sh\nexit 0\n');
    Process.runSync('chmod', ['+x', '${repo.path}/bin/dart']);
    environment = {'PATH': '${repo.path}/bin:${Platform.environment['PATH']}'};
    pubspec = File('${repo.path}/pubspec.yaml')
      ..writeAsStringSync('name: reclash\nversion: 0.1.0-pre.1+2026090701\n');
    File('${repo.path}/changelog.json').writeAsStringSync('{}\n');
    File('${repo.path}/CHANGELOG.md').writeAsStringSync('# Changelog\n');
    git(['init', '--quiet', '--initial-branch=main']);
    git(['config', 'user.email', 'release-test@example.com']);
    git(['config', 'user.name', 'Release test']);
    git(['add', '.']);
    git(['commit', '--quiet', '-m', 'chore: initialize release fixture']);
  });

  tearDown(() => repo.deleteSync(recursive: true));

  test('a dry run neither writes nor stages release files', () {
    final before = pubspec.statSync();
    final result = run('bash', ['tool/release.sh', 'pre', '--dry-run']);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(result.stdout, contains('v0.1.0-pre.1'));
    expect(pubspec.statSync().modified, before.modified);
    expect(run('git', ['status', '--porcelain']).stdout, isEmpty);
  });

  test('prerelease tags and pubspec advance together', () {
    git(['tag', 'v0.1.0-pre.1']);
    final result = run('bash', ['tool/release.sh', 'pre', '--yes']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(pubspec.readAsStringSync(), contains('version: 0.1.0-pre.2+'));
    expect(
      run('git', ['tag', '--points-at', 'HEAD']).stdout,
      contains('v0.1.0-pre.2'),
    );
    expect(run('git', ['status', '--porcelain']).stdout, isEmpty);
  });

  test('stable releases remove the prerelease suffix', () {
    final result = run('bash', ['tool/release.sh', 'stable', '--yes']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(pubspec.readAsStringSync(), contains('version: 0.1.0+'));
    expect(
      run('git', ['tag', '--points-at', 'HEAD']).stdout,
      contains('v0.1.0'),
    );
  });

  test('build bumps preserve prereleases and reject a backwards clock', () {
    final result = run('bash', ['tool/bump_version.sh', 'minor']);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(pubspec.readAsStringSync(), contains('version: 0.1.0-pre.1+'));
    final future = DateTime.now().year + 1;
    final source = 'version: 0.1.0-pre.1+${future}123101\n';
    pubspec.writeAsStringSync(source);
    final rejected = run('bash', ['tool/bump_version.sh', 'minor']);
    expect(rejected.exitCode, isNot(0));
    expect(pubspec.readAsStringSync(), source);
  });
}
