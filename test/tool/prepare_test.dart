import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/prepare.dart' as prepare;

void main() {
  final calls = <(String, List<String>, String, bool)>[];
  var failureAt = -1;

  Future<int> record(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
    required bool quiet,
  }) async {
    calls.add((executable, arguments, workingDirectory, quiet));
    return calls.length == failureAt ? 23 : 0;
  }

  setUp(() {
    calls.clear();
    failureAt = -1;
  });

  test('prepares every app source in dependency order', () async {
    expect(await prepare.prepareProject('checkout', run: record), 0);
    expect(calls.map((call) => call.$1), [
      'flutter',
      Platform.resolvedExecutable,
      Platform.resolvedExecutable,
      Platform.resolvedExecutable,
    ]);
    expect(calls.map((call) => call.$2), [
      ['pub', 'get'],
      ['run', 'tool/assemble_l10n.dart'],
      ['run', 'intl_utils:generate'],
      ['run', 'build_runner', 'build'],
    ]);
    expect(calls.every((call) => call.$3 == 'checkout' && !call.$4), true);
  });

  for (var step = 1; step <= 4; step++) {
    test('stops and preserves the exit code when step $step fails', () async {
      failureAt = step;
      expect(await prepare.prepareProject('checkout', run: record), 23);
      expect(calls, hasLength(step));
    });
  }

  test('no-pub still runs all generators and forwards quiet mode', () async {
    expect(
      await prepare.prepareProject(
        'checkout',
        pubGet: false,
        quiet: true,
        run: record,
      ),
      0,
    );
    expect(calls, hasLength(3));
    expect(calls.map((call) => call.$2), [
      ['run', 'tool/assemble_l10n.dart'],
      ['run', 'intl_utils:generate'],
      ['run', 'build_runner', 'build'],
    ]);
    expect(calls.every((call) => call.$3 == 'checkout' && call.$4), true);
  });

  for (final (arguments, code) in [
    (['--help'], 0),
    (['--unknown'], 64),
  ]) {
    test(
      'CLI $arguments needs no resolved package or generated files',
      () async {
        final directory = Directory.systemTemp.createTempSync('prepare-cli-');
        addTearDown(() => directory.deleteSync(recursive: true));
        final script = File('${directory.path}/tool/prepare.dart');
        script.parent.createSync(recursive: true);
        File('tool/prepare.dart').copySync(script.path);
        final result = await Process.run(
          'dart',
          [script.path, ...arguments],
          workingDirectory: directory.path,
          runInShell: Platform.isWindows,
        );
        expect(
          result.exitCode,
          code,
          reason: '${result.stdout}\n${result.stderr}',
        );
        expect('${result.stdout}${result.stderr}', contains('Usage:'));
        expect(Directory('${directory.path}/.dart_tool').existsSync(), false);
      },
    );
  }

  test('only app-owned generated paths are ignored', () async {
    const generated = [
      'arb/intl_en.arb',
      'lib/l10n/l10n.dart',
      'lib/l10n/intl/messages_en.dart',
      'lib/models/generated/config.g.dart',
      'lib/providers/generated/config.g.dart',
      'lib/database/generated/database.g.dart',
      'lib/ui/generated/keyword.freezed.dart',
    ];
    const sources = [
      'arb_upstream/intl_en.arb',
      'arb/locales/intl_ru.arb',
      'arb/fragments/app.setup/intl_en.arb',
      'upstream_l10n/l10n.dart',
      'plugins/rust_api/lib/src/rust/frb_generated.dart',
      'plugins/rust_api/rust/src/frb_generated.rs',
      'lib/models/config.dart',
      'build.yaml',
      'pubspec.lock',
    ];
    final result = await Process.run('git', [
      'check-ignore',
      '--no-index',
      ...generated,
      ...sources,
    ]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect((result.stdout as String).trim().split(RegExp(r'\r?\n')), generated);
  });

  test('generated app sources are not tracked', () async {
    final result = await Process.run('git', [
      'ls-files',
      '--',
      'arb/intl_*.arb',
      'lib/l10n',
      'lib/models/generated',
      'lib/providers/generated',
      'lib/database/generated',
      'lib/ui/generated',
    ]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(result.stdout, isEmpty);
  });
}
