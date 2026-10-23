import 'dart:io';

import 'package:test/test.dart';

import '../../tool/check_release_version.dart' as release;

void main() {
  late Directory root;
  late String script;

  setUp(() {
    root = Directory.systemTemp.createTempSync('reclash-release-version-');
    script = File('tool/check_release_version.dart').absolute.path;
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  Future<ProcessResult> run({
    String? pubspec = 'version: 0.1.0-pre.1+2026102301\n',
    List<String> args = const [],
  }) async {
    if (pubspec != null) {
      File('${root.path}/pubspec.yaml').writeAsStringSync(pubspec);
    }
    return Process.run('dart', [script, ...args], workingDirectory: root.path);
  }

  void expectSuccess(ProcessResult result, String name) {
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(result.stdout, '$name\n');
    expect(result.stderr, isEmpty);
  }

  void expectFailure(ProcessResult result, String message) {
    expect(result.exitCode, isNot(0));
    expect(result.stdout, isEmpty);
    expect(result.stderr, contains(message));
    expect(result.stderr, isNot(contains('Unhandled exception')));
  }

  test('exposes the same validation contract to other release tools', () {
    const pubspec = 'version: 0.1.0+2026102301\n';
    expect(release.validateReleaseVersion(pubspec), '0.1.0');
    expect(release.validateReleaseVersion(pubspec, ''), '0.1.0');
    expect(release.validateReleaseVersion(pubspec, 'v0.1.0'), '0.1.0');
    expect(release.validateReleaseVersion(pubspec, 'v0.1.0-pre.2'), '0.1.0');
    expect(
      () => release.validateReleaseVersion(pubspec, 'v0.2.0'),
      throwsFormatException,
    );
  });

  test('prints only the public version without requiring a tag', () async {
    expectSuccess(await run(), '0.1.0-pre.1');
  });

  test('an explicitly empty tag only validates the pubspec', () async {
    expectSuccess(await run(args: ['']), '0.1.0-pre.1');
  });

  test(
    'matches the entire prerelease name and ignores build metadata',
    () async {
      expectSuccess(await run(args: ['v0.1.0-pre.1']), '0.1.0-pre.1');
    },
  );

  test('accepts stable and prerelease names without build metadata', () async {
    for (final name in ['0.1.0', '0.1.0-pre.1']) {
      expectSuccess(
        await run(pubspec: 'version: $name\n', args: ['v$name']),
        name,
      );
    }
  });

  test('accepts quoted YAML versions and inline comments', () async {
    expectSuccess(
      await run(
        pubspec: 'name: reclash\nversion: "0.1.0+2026102301" # release\n',
        args: ['v0.1.0'],
      ),
      '0.1.0',
    );
  });

  test('supports release.sh prerelease tags over a stable pubspec', () async {
    expectSuccess(
      await run(
        pubspec: 'version: 0.1.0+2026102301\n',
        args: ['v0.1.0-pre.12'],
      ),
      '0.1.0',
    );
  });

  for (final tag in [
    'v0.1.0',
    'v0.1.0-pre.2',
    'v0.2.0-pre.1',
    '0.1.0-pre.1',
    'v0.1.0-pre.1+2026102301',
    ' v0.1.0-pre.1',
    'v0.1.0-pre.1\n',
  ]) {
    test('rejects mismatched prerelease tag ${tag.trim()}', () async {
      expectFailure(await run(args: [tag]), 'does not match pubspec version');
    });
  }

  for (final tag in [
    'v0.2.0-pre.1',
    'v0.1.0-pre.0',
    'v0.1.0-pre.01',
    'v0.1.0-pre.1-suffix',
    'v0.1.0-pre.1\n',
  ]) {
    test(
      'rejects malformed or unrelated release.sh tag ${tag.trim()}',
      () async {
        expectFailure(
          await run(pubspec: 'version: 0.1.0+2026102301\n', args: [tag]),
          'does not match pubspec version',
        );
      },
    );
  }

  for (final version in [
    '0.1',
    '01.1.0',
    '0.01.0',
    '0.1.00',
    '0.1.0-pre.0',
    '0.1.0-pre.01',
    '0.1.0+1',
    '0.1.0+2026023001',
    '0.1.0+2026102300',
    '0.1.0+2100010101',
  ]) {
    test('rejects invalid release version $version', () async {
      expectFailure(
        await run(pubspec: 'version: "$version"\n'),
        'Invalid release',
      );
    });
  }

  for (final pubspec in [
    'name: reclash\n',
    'version:\n',
    'version: 123\n',
    'version: [0, 1, 0]\n',
    '- version: 0.1.0\n',
    'dependencies:\n  version: 0.1.0\n',
  ]) {
    test('rejects missing or non-string top-level version $pubspec', () async {
      expectFailure(await run(pubspec: pubspec), 'pubspec version');
    });
  }

  test('reports malformed YAML without a stack trace', () async {
    expectFailure(await run(pubspec: 'version: [\n'), 'Invalid pubspec.yaml');
  });

  test('rejects duplicate version declarations', () async {
    expectFailure(
      await run(pubspec: 'version: 0.1.0\nversion: 0.2.0\n'),
      'Invalid pubspec.yaml',
    );
  });

  test('reports a missing pubspec without a stack trace', () async {
    expectFailure(await run(pubspec: null), 'Could not read pubspec.yaml');
  });

  test('rejects additional arguments with usage on stderr', () async {
    final result = await run(args: ['v0.1.0-pre.1', 'extra']);
    expect(result.exitCode, 64);
    expectFailure(
      result,
      'Usage: dart run tool/check_release_version.dart [tag]',
    );
  });
}
