import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'prepare.dart';
import 'src/test_select/graph.dart';
import 'src/fork/git.dart';
import 'src/fork/registry.dart';
import 'src/fork/report.dart';
import 'src/test_select/report.dart';
import 'src/test_select/selection.dart';

const _usage =
    '''
Runs the root package tests from a few generated entrypoints.

usage: dart run tool/test.dart [path ...] [-- flutter test arguments]
       dart run tool/test.dart --changed [--list] [--summary-only] [-- ...]
       dart run tool/test.dart --affected <path>... [--list] [--summary-only]

  --changed           Run the tests the working tree can break: files changed
                      against HEAD, staged or not, and untracked files under
                      lib/ and test/.
  --affected path...  Run the tests the given changed paths can break.
  --list              Print the selected test files, each with the change
                      that selects it, and run nothing.
  --summary-only      Print no reporter output: only the counts and the
                      failed tests.

Every *_test.dart under the given paths (default: test) is imported into one of
$_bundleCount entrypoints under $_bundleDir, so `flutter test` compiles and
starts $_bundleCount programs rather than one per file. A file carrying a
library-level annotation such as @TestOn runs on its own.

Files in one entrypoint share an isolate. A file that fails there is run again
on its own, and that run decides the result; the files that pass alone are
listed, since they depend on or are broken by state another file left. A
failure in a file that already ran on its own, or one the report ties to no
file, fails the run whatever the rerun finds. A failing run ends with each
failed test of that final outcome: its file:line, name, and first error lines.

A changed Dart file selects the tests that import it, directly or through
the libraries it reaches. Through a barrel's export, a file counts only when it
names a declaration the change reaches. ARB and l10n changes select the l10n
tests, any lib/ change test/lint/, a tool/<name> change test/tool/<name>*, and
a pubspec change the whole suite. Other paths list external maintenance checks
when classified in .fork/maintenance.yaml; unknown paths require explicit review.
External checks are not executed by this selector.''';

// Fixed, so a commit groups its files the same way on every machine.
const _bundleCount = 32;
const _bundleDir = '.dart_tool/test_bundles';
const _reportPath = '$_bundleDir/report.json';
const _rerunReportPath = '$_bundleDir/rerun.json';

final _annotation = RegExp(r'^@(TestOn|Tags|Timeout|Skip|OnPlatform)\b');

// Options of `flutter test` the rerun drops: it only decides pass or fail, and
// would otherwise overwrite the coverage of the whole run.
// Sharding its few files anew would skip the test that failed.
const _rerunDropsWithValue = {
  '--coverage-path',
  '--coverage-package',
  '--file-reporter',
  '--total-shards',
  '--shard-index',
};
const _rerunDropsFlag = {'--coverage', '--merge-coverage', '--branch-coverage'};

class _Bundle {
  final files = <String>[];
  var size = 0;
}

class _Options {
  final paths = <String>[];
  final affected = <String>[];
  var changed = false;
  var affects = false;
  var list = false;
  var summaryOnly = false;
  var help = false;

  bool get selects => changed || affects;

  factory _Options.parse(List<String> arguments) {
    final options = _Options._();
    for (final argument in arguments) {
      switch (argument) {
        case '-h' || '--help':
          options.help = true;
        case '--changed':
          options.changed = true;
        case '--affected':
          options.affects = true;
        case '--list':
          options.list = true;
        case '--summary-only':
          options.summaryOnly = true;
        case _ when argument.startsWith('-'):
          _usageError('Unknown option: $argument');
        case _:
          (options.affects ? options.affected : options.paths).add(argument);
      }
    }
    if (options.affects && options.affected.isEmpty) {
      _usageError('--affected needs at least one path');
    }
    if (options.selects && options.paths.isNotEmpty) {
      _usageError('Test paths cannot be combined with --changed or --affected');
    }
    return options;
  }

  _Options._();
}

Never _usageError(String message) {
  stderr.writeln('$message\n\n$_usage');
  exit(64);
}

Future<void> main(List<String> arguments) async {
  final split = arguments.indexOf('--');
  final options = _Options.parse(
    split < 0 ? arguments : arguments.sublist(0, split),
  );
  final flutterArguments = split < 0
      ? const <String>[]
      : arguments.sublist(split + 1);
  if (options.help) {
    stdout.writeln(_usage);
    return;
  }

  if (!options.list) {
    final prepared = await prepareProject(
      Directory.current.path,
      pubGet: false,
      quiet: options.summaryOnly,
    );
    if (prepared != 0) exit(prepared);
  }

  final files = options.selects
      ? await _select(options)
      : _collect(options.paths.isEmpty ? const ['test'] : options.paths);
  if (options.list) {
    if (!options.selects) stdout.writeln(files.join('\n'));
    return;
  }
  if (files.isEmpty) {
    stdout.writeln('No test is affected.');
    return;
  }
  final standalone = files.where(_hasAnnotation).toList();
  final bundles = _writeBundles(
    files.where((file) => !standalone.contains(file)).toList(),
  );
  final setsConcurrency = flutterArguments.any(
    (argument) =>
        argument.startsWith('-j') || argument.startsWith('--concurrency'),
  );
  final reports = !flutterArguments.any(
    (argument) => argument.startsWith('--file-reporter'),
  );
  final silent = options.summaryOnly
      ? const ['-r', 'silent']
      : const <String>[];

  final code = await _flutterTest(quiet: options.summaryOnly, [
    if (!setsConcurrency)
      '--concurrency=${min(_bundleCount, Platform.numberOfProcessors)}',
    if (reports) '--file-reporter=json:$_reportPath',
    ...flutterArguments,
    ...silent,
    for (final bundle in bundles) bundle.path,
    ...standalone,
  ]);
  if (!reports) exit(code);
  final results = _readReport(_reportPath);
  Never finish(List<TestResult> results, int code) {
    if (options.summaryOnly || results.any((test) => test.failed)) {
      stdout.writeln('\n${summarize(results, root: Directory.current.path)}');
    }
    exit(code);
  }

  if (code == 0) finish(results, code);
  final byPath = {
    for (final bundle in bundles) p.canonicalize(bundle.path): bundle.files,
  };
  final failures = _failures(results, byPath);
  final failed = failures.files;
  if (failed.isEmpty) finish(results, code);
  stdout.writeln(
    '\n${failed.length} file(s) failed in a shared isolate; '
    'running them on their own:\n${failed.map((f) => '  $f').join('\n')}\n',
  );
  final rerunCode = await _flutterTest(quiet: options.summaryOnly, [
    ..._rerunArguments(flutterArguments),
    '--file-reporter=json:$_rerunReportPath',
    ...silent,
    ...failed,
  ]);
  final rerun = File(_rerunReportPath).existsSync()
      ? _readReport(_rerunReportPath)
      : null;
  final outcome = rerun == null
      ? results
      : [
          for (final test in results)
            if (!_rerunOwns(_owners(test, byPath), failed)) test,
          ...rerun,
        ];
  if (rerunCode == 0) {
    stdout.writeln(
      '\nEvery file above passes on its own: each depends on, or is broken by, '
      'state another file in its entrypoint left behind.',
    );
  }
  if (failures.failsOutsideBundles) {
    stdout.writeln(
      '\nThe run still fails: other failures came from files that ran on '
      'their own, or from no file the report names.',
    );
    finish(outcome, code);
  }
  finish(outcome, rerunCode);
}

bool _rerunOwns(List<String> owners, List<String> rerun) =>
    owners.isNotEmpty && owners.every(rerun.contains);

Future<List<String>> _select(_Options options) async {
  final watch = Stopwatch()..start();
  final root = Directory.current.path;
  final graph = SourceGraph.build(root, excluded: graphExcluded);
  final built = watch.elapsedMilliseconds;
  final changed = {
    if (options.changed) ..._changedPaths(),
    for (final path in options.affected) ..._expand(path, root),
  }.toList()..sort();
  final previous = await _committedSources(changed.where(graph.covers));
  final selection = selectTests(
    graph,
    changed,
    previousSource: (path) => previous[path],
  );
  if (selection.unmapped.isNotEmpty) {
    final metadata = File('$root/.fork/maintenance.yaml');
    final report = metadata.existsSync()
        ? MaintenanceReport(Registry(ForkGit(root)))
        : null;
    final policy = report?.policy();
    for (final path in selection.unmapped) {
      final classification = report?.classification(path, policy!);
      if (classification == null ||
          classification['kind'] == 'unclassified' ||
          classification['kind'] == 'contract') {
        stdout.writeln(
          'unmapped: $path (no Dart test selection; explicit review required)',
        );
      } else {
        stdout.writeln(
          'external: $path [${classification['kind']}] '
          'checks=${(classification['checks'] as List).join(',')} '
          '(not run by this test selector)',
        );
      }
    }
  }
  if (selection.fullSuite case final path?) {
    stdout.writeln('full suite recommended: $path changed');
  }
  final tests = selection.tests;
  if (options.list) {
    final width = tests.keys.fold(0, (width, test) => max(width, test.length));
    for (final MapEntry(key: test, value: reason) in tests.entries) {
      stdout.writeln(
        '${test.padRight(width)}  ${reason.describe(selection.others(test))}',
      );
    }
    stdout.writeln(
      '${tests.length} test file(s) for ${changed.length} changed path(s); '
      '${graph.libraries.length} libraries read in $built ms, '
      'selected in ${watch.elapsedMilliseconds - built} ms',
    );
  } else if (tests.isNotEmpty) {
    stdout.writeln(
      'Running ${tests.length} test file(s) affected by '
      '${changed.length} changed path(s).',
    );
  }
  return tests.keys.toList();
}

List<String> _changedPaths() {
  List<String> git(List<String> arguments) {
    final result = Process.runSync('git', [
      '-c',
      'core.quotePath=false',
      ...arguments,
    ]);
    if (result.exitCode != 0) {
      stderr.writeln('git ${arguments.join(' ')} failed:\n${result.stderr}');
      exit(70);
    }
    return const LineSplitter()
        .convert(result.stdout as String)
        .where((line) => line.isNotEmpty)
        .toList();
  }

  return [
    ...git(['diff', '--name-only', 'HEAD']),
    ...git(['diff', '--name-only', '--cached']),
    ...git(['ls-files', '--others', '--exclude-standard', '--', 'lib', 'test']),
  ];
}

Iterable<String> _expand(String path, String root) {
  final relative = _posix(p.normalize(p.relative(path, from: root)));
  final directory = Directory(relative);
  if (!directory.existsSync()) return [relative];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => _posix(p.normalize(file.path)));
}

/// The committed text of [paths] that exist in HEAD, read by one
/// `git cat-file --batch`.
Future<Map<String, String>> _committedSources(Iterable<String> paths) async {
  final requested = paths.toList();
  if (requested.isEmpty) return const {};
  final process = await Process.start('git', ['cat-file', '--batch']);
  process.stdin.write(requested.map((path) => 'HEAD:$path\n').join());
  unawaited(process.stdin.close());
  unawaited(process.stderr.drain<void>());
  final bytes = await process.stdout.fold(
    BytesBuilder(copy: false),
    (builder, chunk) => builder..add(chunk),
  );
  await process.exitCode;
  final data = bytes.takeBytes();
  final sources = <String, String>{};
  var offset = 0;
  for (final path in requested) {
    final newline = data.indexOf(0x0A, offset);
    if (newline < 0) break;
    final header = ascii.decode(data.sublist(offset, newline)).split(' ');
    offset = newline + 1;
    if (header.length != 3 || header[1] != 'blob') continue;
    final size = int.parse(header[2]);
    sources[path] = utf8.decode(
      data.sublist(offset, offset + size),
      allowMalformed: true,
    );
    offset += size + 1;
  }
  return sources;
}

List<TestResult> _readReport(String path) {
  final file = File(path);
  return file.existsSync() ? readReport(file.readAsLinesSync()) : const [];
}

Future<int> _flutterTest(List<String> arguments, {bool quiet = false}) async {
  final process = await Process.start(
    'flutter',
    ['test', ...arguments],
    mode: quiet ? ProcessStartMode.normal : ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  if (quiet) {
    // The silent reporter still lets flutter_tester's own `Shell:` log through,
    // such as a Fontconfig warning per engine; the JSON report keeps failures.
    Future<void> forward(Stream<List<int>> from, IOSink to) => from
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => !line.startsWith('Shell: '))
        .forEach(to.writeln);
    await Future.wait([
      forward(process.stdout, stdout),
      forward(process.stderr, stderr),
    ]);
  }
  return process.exitCode;
}

List<String> _rerunArguments(List<String> arguments) {
  final kept = <String>[];
  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    final name = argument.split('=').first;
    if (_rerunDropsFlag.contains(name)) continue;
    if (_rerunDropsWithValue.contains(name)) {
      if (!argument.contains('=')) i++;
      continue;
    }
    kept.add(argument);
  }
  return kept;
}

List<String> _collect(List<String> paths) {
  final files = <String>{};
  for (final path in paths) {
    switch (FileSystemEntity.typeSync(path)) {
      case FileSystemEntityType.directory:
        files.addAll(
          Directory(path)
              .listSync(recursive: true)
              .whereType<File>()
              .map((file) => p.normalize(file.path))
              .where((file) => file.endsWith('_test.dart')),
        );
      case FileSystemEntityType.file:
        files.add(p.normalize(path));
      default:
        stderr.writeln('No such test path: $path');
        exit(64);
    }
  }
  if (files.isEmpty) {
    stderr.writeln('No *_test.dart files under ${paths.join(' ')}');
    exit(64);
  }
  return files.toList()..sort();
}

bool _hasAnnotation(String file) {
  for (final line in File(file).readAsLinesSync()) {
    if (_annotation.hasMatch(line)) return true;
    if (line.startsWith('import ') || line.startsWith('void main')) break;
  }
  return false;
}

/// Hands each file, largest first, to the bundle with the least code so far;
/// size stands in for run time.
List<({String path, List<String> files})> _writeBundles(List<String> files) {
  final directory = Directory(_bundleDir);
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  directory.createSync(recursive: true);

  final sizes = {for (final file in files) file: File(file).lengthSync()};
  final bundles = List.generate(
    min(_bundleCount, files.length),
    (_) => _Bundle(),
  );
  final bySize = [...files]
    ..sort((a, b) {
      final order = sizes[b]!.compareTo(sizes[a]!);
      return order != 0 ? order : a.compareTo(b);
    });
  for (final file in bySize) {
    final bundle = bundles.reduce((a, b) => b.size < a.size ? b : a);
    bundle.files.add(file);
    bundle.size += sizes[file]!;
  }

  return [
    for (final (index, bundle) in bundles.indexed)
      (
        path: _writeBundle(directory, index, bundle.files..sort()),
        files: bundle.files,
      ),
  ];
}

String _writeBundle(Directory directory, int index, List<String> files) {
  final buffer = StringBuffer()
    ..writeln('// Generated by tool/test.dart.')
    ..writeln("import 'package:flutter_test/flutter_test.dart';");
  for (final (i, file) in files.indexed) {
    buffer.writeln(
      "import '${_posix(p.relative(file, from: directory.path))}' as t$i;",
    );
  }
  buffer
    ..writeln()
    ..writeln('void main() {');
  for (final (i, file) in files.indexed) {
    buffer.writeln("  group('${_posix(file)}', t$i.main);");
  }
  buffer.writeln('}');

  final name = 'bundle_${index.toString().padLeft(2, '0')}_test.dart';
  final path = p.join(directory.path, name);
  File(path).writeAsStringSync(buffer.toString());
  return path;
}

String _posix(String path) => p.posix.joinAll(p.split(path));

/// The files behind every failed test in the JSON report; a bundle that failed
/// to load stands for all of its files.
({List<String> files, bool failsOutsideBundles}) _failures(
  List<TestResult> results,
  Map<String, List<String>> byPath,
) {
  final failed = <String>{};
  var failsOutsideBundles = false;
  for (final test in results.where((test) => test.failed)) {
    final owners = _owners(test, byPath);
    if (owners.isEmpty) failsOutsideBundles = true;
    failed.addAll(owners);
  }
  return (
    files: failed.toList()..sort(),
    failsOutsideBundles: failsOutsideBundles,
  );
}

List<String> _owners(TestResult test, Map<String, List<String>> byPath) {
  final files = byPath[p.canonicalize(test.suite)];
  if (files == null) return const [];
  if (test.name.startsWith('loading ')) return files;
  return [
    for (final file in files)
      if (test.name.startsWith('${_posix(file)} ')) file,
  ];
}
