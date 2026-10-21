import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/test_select/dart_source.dart';
import '../../tool/src/test_select/graph.dart';
import '../../tool/src/test_select/report.dart';
import '../../tool/src/test_select/selection.dart';

const _fixture = {
  'lib/common/leaf.dart': "String leafHelper() => 'leaf';",
  'lib/common/other.dart': 'const otherValue = 1;',
  'lib/common/common.dart': "export 'leaf.dart';\nexport 'other.dart';",
  'lib/models/model.dart': '''
import 'package:reclash/common/common.dart';

part 'generated/model.g.dart';

class Model {
  String get label => leafHelper() + _partLabel;
}

extension ModelLabel on Model {
  String get shout => label.toUpperCase();
}

const unrelated = 2;
''',
  'lib/models/generated/model.g.dart': '''
part of '../model.dart';

const _partLabel = 'generated';
final modelProvider = Model();
''',
  'lib/models/models.dart': "export 'model.dart';",
  'test/helpers/app.dart': '''
import 'package:reclash/common/common.dart';

final appValue = otherValue;
''',
  'test/leaf_test.dart': '''
import 'package:reclash/common/common.dart';

void main() => leafHelper();
''',
  'test/other_test.dart': '''
import 'package:reclash/common/common.dart';

void main() => otherValue;
''',
  'test/model_test.dart': '''
import 'package:reclash/models/model.dart';

void main() => unrelated;
''',
  'test/provider_test.dart': '''
import 'package:reclash/models/models.dart';

void main() => modelProvider;
''',
  'test/shout_test.dart': '''
import 'package:reclash/models/models.dart';

void main() => '\${value.shout}';
''',
  'test/unrelated_test.dart': '''
import 'package:reclash/models/models.dart';

// modelProvider is only named in this comment.
void main() => unrelated;
''',
  'test/helper_user_test.dart': '''
import 'helpers/app.dart';

void main() => appValue;
''',
  'test/lint/scan_test.dart': 'void main() {}',
  'test/l10n/keys_test.dart': 'void main() {}',
  'test/tool/build_site_test.dart': 'void main() {}',
  'tool/build_site.dart': 'void main() {}',
};

void main() {
  late Directory root;
  late SourceGraph graph;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('test_select_');
    for (final MapEntry(key: path, value: source) in _fixture.entries) {
      File(p.join(root.path, path))
        ..createSync(recursive: true)
        ..writeAsStringSync(source);
    }
    graph = SourceGraph.build(root.path, excluded: graphExcluded);
  });
  tearDownAll(() => root.deleteSync(recursive: true));

  Map<String, String> select(
    List<String> changed, {
    String? Function(String path)? previousSource,
  }) {
    final selection = selectTests(
      graph,
      changed,
      previousSource: previousSource,
    );
    return {
      for (final MapEntry(key: test, value: reason) in selection.tests.entries)
        test: reason.describe(selection.others(test)),
    };
  }

  test('a barrel passes a change only to files naming what changed', () {
    expect(select(['lib/common/leaf.dart']), {
      'test/leaf_test.dart':
          '<- lib/common/leaf.dart via lib/common/common.dart',
      'test/model_test.dart':
          '<- lib/common/leaf.dart via lib/common/common.dart > '
          'lib/models/model.dart',
      'test/provider_test.dart':
          '<- lib/common/leaf.dart via lib/common/common.dart > '
          'lib/models/model.dart > lib/models/models.dart',
      'test/shout_test.dart':
          '<- lib/common/leaf.dart via lib/common/common.dart > '
          'lib/models/model.dart > lib/models/models.dart',
      'test/lint/scan_test.dart': '<- lib/common/leaf.dart (scans lib/)',
    });
  });

  test('a test helper propagates like a library', () {
    expect(select(['lib/common/other.dart']).keys, [
      'test/helper_user_test.dart',
      'test/lint/scan_test.dart',
      'test/other_test.dart',
    ]);
  });

  test('a generated part counts as its library', () {
    expect(
      select(['lib/models/generated/model.g.dart']).keys,
      containsAll([
        'test/model_test.dart',
        'test/provider_test.dart',
        'test/shout_test.dart',
      ]),
    );
    expect(
      select(['lib/models/generated/model.g.dart']).keys,
      isNot(contains('test/unrelated_test.dart')),
    );
  });

  test('a name the committed version declared still selects', () {
    const before = "String leafHelper() => 'leaf';\nconst otherValue = 0;";
    expect(
      select(['lib/common/leaf.dart'], previousSource: (path) => before),
      containsPair('test/other_test.dart', startsWith('<- lib/common/leaf')),
    );
  });

  test('non-Dart paths follow the path rules', () {
    final selection = selectTests(graph, [
      'test/other_test.dart',
      'arb/intl_en.arb',
      'tool/build_site.dart',
      'README.md',
    ]);
    expect(selection.tests.keys, [
      'test/l10n/keys_test.dart',
      'test/other_test.dart',
      'test/tool/build_site_test.dart',
    ]);
    expect(selection.tests['test/other_test.dart']!.describe(0), '<- changed');
    expect(selection.unmapped, ['README.md']);
    expect(selection.fullSuite, isNull);

    final full = selectTests(graph, ['pubspec.yaml']);
    expect(full.fullSuite, 'pubspec.yaml');
    expect(full.tests, hasLength(graph.tests.length));
  });

  test('declarations ignore strings, comments and nested bodies', () {
    final source = DartSource.parse(r'''
import 'a.dart' if (dart.library.io) 'b.dart';
export 'c.dart' show Shown;

/// class Commented {}
@Riverpod(keepAlive: true)
String greeting(Ref ref) => 'class Quoted { ${ref.name} }';

final table = {'{': 1}.map((key, value) => MapEntry(key, value));
final kind = switch (table) { _ => 'x' };
(int, int) pair() => (1, 2);
typedef Callback = void Function({int value});

extension on String {
  int get size => length;
}
''');
    expect(source.imports, ['a.dart', 'b.dart']);
    expect(source.exports.single.filter({'Shown', 'Hidden'}), {'Shown'});
    expect(source.declared, {
      'greeting',
      'table',
      'kind',
      'pair',
      'Callback',
      'size',
    });
    expect(source.used, containsAll(['name', 'MapEntry']));
    expect(source.used, isNot(contains('Quoted')));
  });

  test('the summary lists failed tests without framework frames', () {
    final results = readReport([
      for (final event in _report) jsonEncode(event),
    ]);
    expect(summarize(results, root: '/repo'), '''
1 passed, 2 failed, 1 skipped

test/a_test.dart:5  plain expect
    Expected: <3>
      Actual: <2>
    test/a_test.dart 6:5                                main.<fn>

test/a_test.dart:10  widget finder
    Expected: exactly one matching candidate
      Actual: _TextWidgetFinder:<Found 0 widgets>
    #4      main.<anonymous closure> (test/a_test.dart:12:5)''');
  });
}

const _url = 'file:///repo/test/a_test.dart';
const _report = [
  {
    'type': 'suite',
    'suite': {'id': 0, 'path': '/repo/test/a_test.dart'},
  },
  {
    'type': 'testStart',
    'test': {'id': 1, 'name': 'loading /repo/test/a_test.dart', 'suiteID': 0},
  },
  {'type': 'testDone', 'testID': 1, 'result': 'success', 'hidden': true},
  {
    'type': 'testStart',
    'test': {
      'id': 2,
      'name': 'plain expect',
      'suiteID': 0,
      'line': 5,
      'url': _url,
    },
  },
  {
    'type': 'error',
    'testID': 2,
    'error': 'Expected: <3>\n  Actual: <2>\n',
    'stackTrace':
        'package:matcher                                     expect\n'
        'package:flutter_test/src/widget_tester.dart 473:18  expect\n'
        'test/a_test.dart 6:5                                main.<fn>\n',
  },
  {'type': 'testDone', 'testID': 2, 'result': 'failure'},
  {
    'type': 'testStart',
    'test': {'id': 3, 'name': 'passes', 'suiteID': 0, 'line': 8, 'url': _url},
  },
  {'type': 'testDone', 'testID': 3, 'result': 'success'},
  {
    'type': 'testStart',
    'test': {'id': 4, 'name': 'skipped', 'suiteID': 0, 'line': 9, 'url': _url},
  },
  {'type': 'testDone', 'testID': 4, 'result': 'success', 'skipped': true},
  {
    'type': 'testStart',
    'test': {
      'id': 5,
      'name': 'widget finder',
      'suiteID': 0,
      'line': 10,
      'url': _url,
    },
  },
  {
    'type': 'print',
    'testID': 5,
    'message':
        '══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════\n'
        'The following TestFailure was thrown running a test:\n'
        'Expected: exactly one matching candidate\n'
        '  Actual: _TextWidgetFinder:<Found 0 widgets>\n'
        '\n'
        'When the exception was thrown, this was the stack:\n'
        '#4      main.<anonymous closure> ($_url:12:5)\n'
        '<asynchronous suspension>\n'
        '#5      testWidgets.<anonymous closure> '
        '(package:flutter_test/src/widget_tester.dart:192:15)\n'
        'The test description was:\n'
        '  widget finder\n'
        '════',
  },
  {
    'type': 'error',
    'testID': 5,
    'error':
        'Test failed. See exception logs above.\n'
        'The test description was: widget finder',
    'stackTrace': '',
  },
  {'type': 'testDone', 'testID': 5, 'result': 'error'},
];
