import 'dart:io';

import 'package:build_tool/src/build_cache.dart';
import 'package:build_tool/src/error.dart';
import 'package:build_tool/src/go_builder.dart';
import 'package:build_tool/src/options.dart';
import 'package:build_tool/src/target.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

bool _hasGo() {
  try {
    return Process.runSync('go', ['version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

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

  test('adds a UTC build timestamp without changing the version flags', () {
    const flags = '-w -s ${versionFlag}1.19.31-2-gf77b7475';
    expect(
      GoBuilder.timestampedLdflags(
        flags,
        DateTime.parse('2026-10-02T11:05:06.123+03:00'),
      ),
      '$flags -X github.com/metacubex/mihomo/constant.BuildTime='
      '2026-10-02T08:05:06.123Z',
    );
  });

  test('stamps the repository describe into the engine build id', () {
    final repo = Directory.systemTemp.createTempSync('rcx-repo-');
    addTearDown(() => repo.deleteSync(recursive: true));
    git(['init'], path: repo.path);
    File(p.join(repo.path, 'readme')).writeAsStringSync('rcx');
    git(['add', '.'], path: repo.path);
    git(['commit', '-m', 'initial'], path: repo.path);
    git(['tag', 'v0.1.0-pre.1'], path: repo.path);

    expect(
      GoBuilder.committedLdflags('-s', repo.path),
      '-s -X main.CoreCommit=v0.1.0-pre.1',
    );
  });

  test('falls back to dev when the repository has no Git metadata', () {
    final plain = Directory.systemTemp.createTempSync('rcx-plain-');
    addTearDown(() => plain.deleteSync(recursive: true));

    expect(
      GoBuilder.committedLdflags('-s', plain.path),
      '-s -X main.CoreCommit=dev',
    );
  });

  test(
    'embeds build metadata and retains its timestamp on a cache hit',
    () async {
      File(p.join(corePath, 'go.mod')).writeAsStringSync('''
module core-fixture

go 1.20

require github.com/metacubex/mihomo v0.0.0
replace github.com/metacubex/mihomo => ./mihomo
''');
      File(p.join(mihomoPath, 'go.mod')).writeAsStringSync('''
module github.com/metacubex/mihomo

go 1.20
''');
      Directory(p.join(mihomoPath, 'constant')).createSync();
      File(p.join(mihomoPath, 'constant', 'version.go')).writeAsStringSync('''
package constant

var Version = "unknown"
var BuildTime = "unknown time"
''');
      File(p.join(corePath, 'main.go')).writeAsStringSync('''
package main

import (
    "fmt"
    "github.com/metacubex/mihomo/constant"
)

func main() {
    fmt.Println(constant.Version)
    fmt.Println(constant.BuildTime)
}
''');
      git(['add', '.']);
      git(['commit', '-m', 'build metadata fixture']);
      git(['tag', 'v1.19.31']);
      final host = Process.runSync('go', [
        'env',
        'GOHOSTOS',
        'GOHOSTARCH',
      ], workingDirectory: corePath);
      expect(host.exitCode, 0, reason: '${host.stderr}');
      final hostParts = (host.stdout as String).trim().split(RegExp(r'\s+'));
      final target = Target(goos: hostParts[0], goarch: hostParts[1]);
      final builder = GoBuilder(
        rootDir: directory.path,
        config: BuildConfig.load(rootDir: directory.path),
        cache: BuildCache(rootDir: directory.path),
        notice: BuildNotice(),
      );
      List<String> metadata(String executable) {
        final result = Process.runSync(executable, []);
        expect(result.exitCode, 0, reason: '${result.stderr}');
        return (result.stdout as String).trim().split(RegExp(r'\s+'));
      }

      final before = DateTime.now().toUtc();
      final first = await builder.build(target);
      final embedded = metadata(first.primaryOutput);
      final stamp = DateTime.parse(embedded.last);
      expect(first.rebuilt, isTrue);
      expect(embedded.first, '1.19.31');
      expect(stamp.isUtc, isTrue);
      expect(stamp.isBefore(before), isFalse);
      expect(stamp.isAfter(DateTime.now().toUtc()), isFalse);
      final firstBytes = File(first.primaryOutput).readAsBytesSync();

      final cached = await builder.build(target);
      expect(cached.rebuilt, isFalse);
      expect(metadata(cached.primaryOutput), embedded);
      expect(File(cached.primaryOutput).readAsBytesSync(), firstBytes);

      final rebuilt = await builder.build(target, force: true);
      expect(rebuilt.rebuilt, isTrue);
      expect(metadata(rebuilt.primaryOutput).last, isNot(embedded.last));
    },
    skip: _hasGo() ? false : 'Go SDK is required for the build smoke test',
    timeout: const Timeout(Duration(minutes: 2)),
  );

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
