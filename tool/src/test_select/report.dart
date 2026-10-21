import 'dart:convert';

import 'package:path/path.dart' as p;

/// One test of a `flutter test` JSON report.
class TestResult {
  TestResult(this.id, this.suite, this.name, this.url, this.line);

  final int id;
  final String suite;
  final String name;
  final String? url;
  final int? line;
  String? result;
  bool hidden = false;
  bool skipped = false;
  final errors = <({String message, String stackTrace})>[];
  final prints = <String>[];

  bool get failed =>
      errors.isNotEmpty || (result != null && result != 'success');

  bool get passed => result == 'success' && !failed && !skipped && !hidden;
}

/// The tests of a JSON report, in the order they started.
List<TestResult> readReport(Iterable<String> lines) {
  final suites = <int, String>{};
  final tests = <int, TestResult>{};
  for (final line in lines) {
    if (!line.startsWith('{')) continue;
    final event = jsonDecode(line) as Map<String, dynamic>;
    final test = tests[event['testID']];
    switch (event['type']) {
      case 'suite':
        final suite = event['suite'] as Map<String, dynamic>;
        suites[suite['id'] as int] = suite['path'] as String;
      case 'testStart':
        final data = event['test'] as Map<String, dynamic>;
        final id = data['id'] as int;
        final (url, at) = _location(data);
        tests[id] = TestResult(
          id,
          suites[data['suiteID']] ?? '',
          data['name'] as String,
          url,
          at,
        );
      case 'error' when test != null:
        test.errors.add((
          message: event['error'] as String,
          stackTrace: event['stackTrace'] as String? ?? '',
        ));
      case 'print' when test != null:
        test.prints.add(event['message'] as String);
      case 'testDone' when test != null:
        test
          ..result = event['result'] as String
          ..hidden = event['hidden'] == true
          ..skipped = event['skipped'] == true;
    }
  }
  return tests.values.toList();
}

final _bundled = RegExp(r'^(\S+_test\.dart) ');

/// Where the test is declared: `url` names the first frame outside the test
/// runner, which for `testWidgets` is flutter_test, and `root_url` the suite,
/// which for a bundled file is its generated entrypoint.
(String?, int?) _location(Map<String, dynamic> test) {
  for (final (url, line) in [
    (test['url'], test['line']),
    (test['root_url'], test['root_line']),
  ]) {
    if (url is String &&
        url.startsWith('file:') &&
        !url.contains('/.dart_tool/')) {
      return (url, line as int?);
    }
  }
  return (null, null);
}

final _frameworkFrame = RegExp(
  r'(?:^|\()\s*(?:package:(?:flutter|flutter_test|flutter_tools|test_api|'
  r'test_core|matcher|stack_trace|fake_async)(?:[/\s)]|$)|dart:)',
);
final _noise = RegExp(
  r'^(?:══|<asynchronous suspension>|\(elided |When the exception was thrown|'
  r'This was caught by the test expectation|The following \S+ was thrown)',
);

/// `N passed, M failed, K skipped`, then each failed test as `file:line  name`
/// over the first [lines] lines of its error that are not framework frames.
String summarize(
  List<TestResult> results, {
  required String root,
  int lines = 6,
}) {
  final failed = results.where((test) => test.failed).toList();
  final passed = results.where((test) => test.passed).length;
  final skipped = results.where((test) => test.skipped && !test.failed).length;
  final buffer = StringBuffer(
    '$passed passed, ${failed.length} failed, $skipped skipped',
  );
  for (final test in failed) {
    final url = test.url;
    final file = url != null
        ? _relative(Uri.parse(url).toFilePath(), root)
        : _bundled.firstMatch(test.name)?.group(1) ??
              _relative(test.suite, root);
    final location = test.line == null ? file : '$file:${test.line}';
    final name = test.name.startsWith('$file ')
        ? test.name.substring(file.length + 1)
        : test.name.replaceAll('$root${p.separator}', '');
    buffer.write('\n\n$location  $name');
    for (final line in _errorLines(test, root).take(lines)) {
      buffer.write('\n    $line');
    }
  }
  return buffer.toString();
}

Iterable<String> _errorLines(TestResult test, String root) sync* {
  final prefix = Uri.directory(root).toString();
  for (final error in test.errors) {
    final logged = error.message.startsWith('Test failed. See exception logs')
        ? test.prints.where((print) => print.contains('EXCEPTION CAUGHT'))
        : const <String>[];
    final text = logged.isEmpty
        ? '${error.message}\n${error.stackTrace}'
        : logged.join('\n');
    var description = false;
    for (final raw in const LineSplitter().convert(text)) {
      final line = raw
          .replaceAll(prefix, '')
          .replaceAll('$root${p.separator}', '')
          .trimRight();
      if (description) {
        description = false;
        continue;
      }
      if (line.startsWith('The test description was:')) {
        description = line.trim() == 'The test description was:';
        continue;
      }
      if (line.trim().isEmpty ||
          _noise.hasMatch(line.trimLeft()) ||
          _frameworkFrame.hasMatch(line.trimLeft())) {
        continue;
      }
      yield line;
    }
  }
}

String _relative(String path, String root) => p.posix.joinAll(
  p.split(p.isAbsolute(path) ? p.relative(path, from: root) : path),
);
