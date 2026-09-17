import 'dart:io';

import 'package:build_tool/src/error.dart';
import 'package:build_tool/src/go_builder.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late String corePath;
  late String mihomoPath;
  const versionFlag = '-X github.com/metacubex/mihomo/constant.Version=';

  String git(List<String> arguments, {String? path}) {
    final result = Process.runSync('git', [
      '-c',
      'user.name=Build Test',
      '-c',
      'user.email=build@example.invalid',
      '-c',
      'commit.gpgsign=false',
      ...arguments,
    ], workingDirectory: path ?? mihomoPath);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    return (result.stdout as String).trim();
  }

  setUp(() {
    directory = Directory.systemTemp.createTempSync('mihomo-version-test-');
    corePath = p.join(directory.path, 'core');
    mihomoPath = p.join(corePath, 'mihomo');
    Directory(mihomoPath).createSync(recursive: true);
    git(['init']);
    File(
      p.join(mihomoPath, 'source.go'),
    ).writeAsStringSync('package constant\n');
    git(['add', '.']);
    git(['commit', '-m', 'initial']);
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('injects the release tag and preserves configured linker flags', () {
    git(['tag', 'v1.19.30']);

    expect(
      GoBuilder.coreLdflags(corePath, '-w -s'),
      '-w -s ${versionFlag}1.19.30',
    );
  });

  test('identifies fork commits beyond the release tag', () {
    git(['tag', 'v1.19.30']);
    git(['commit', '--allow-empty', '-m', 'fork changes']);
    final revision = git(['rev-parse', '--short=8', 'HEAD']);

    expect(
      GoBuilder.coreLdflags(corePath, '-s'),
      '-s ${versionFlag}1.19.30-1-g$revision',
    );
  });

  test('marks tracked local modifications as dirty', () {
    git(['tag', 'v1.19.30']);
    File(
      p.join(mihomoPath, 'source.go'),
    ).writeAsStringSync('package changed\n');

    expect(
      GoBuilder.coreLdflags(corePath, '-s'),
      '-s ${versionFlag}1.19.30-dirty',
    );
  });

  test('uses the revision when a shallow checkout has no release tags', () {
    final revision = git(['rev-parse', '--short=8', 'HEAD']);

    expect(GoBuilder.coreLdflags(corePath, '-s'), '-s $versionFlag$revision');
  });

  test('ignores tags that are not mihomo releases', () {
    git(['tag', 'v1.19.30']);
    git(['commit', '--allow-empty', '-m', 'fork changes']);
    git(['tag', 'reclash-build']);
    final revision = git(['rev-parse', '--short=8', 'HEAD']);

    expect(
      GoBuilder.coreLdflags(corePath, '-s'),
      '-s ${versionFlag}1.19.30-1-g$revision',
    );
  });

  test('accepts a submodule-style Git metadata file', () {
    final metadata = p.join(directory.path, 'metadata');
    Directory(p.join(mihomoPath, '.git')).renameSync(metadata);
    File(p.join(mihomoPath, '.git')).writeAsStringSync('gitdir: $metadata\n');
    git(['tag', 'v1.19.30']);

    expect(GoBuilder.coreLdflags(corePath, '-s'), '-s ${versionFlag}1.19.30');
  });

  test('refuses to use the app repository version for an exported core', () {
    git(['init'], path: directory.path);
    git(['commit', '--allow-empty', '-m', 'app'], path: directory.path);
    git(['tag', 'v9.0.0'], path: directory.path);
    Directory(p.join(mihomoPath, '.git')).deleteSync(recursive: true);

    expect(
      () => GoBuilder.coreLdflags(corePath, '-s'),
      throwsA(isA<BuildException>()),
    );
  });
}
