import 'dart:convert';

import 'package:test/test.dart';

import '../../tool/src/fork/registry.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  setUp(() => f = ForkFixture());
  tearDown(() => f.dispose());

  test('gives only relevant contracts and marks unknown paths', () {
    expect(f.registry.context(['lib/code.dart']), contains('must behavior:'));
    expect(f.registry.context(['unknown.dart']), contains('unclassified=1'));
    expect(
      f.registry.context(['lib/code.dart']),
      f.registry.context(['lib/code.dart']),
    );
  });
  test('includes sentinels, dependencies and dependents', () {
    f.write(
      '.fork/features/feature.other.yaml',
      jsonEncode({
        ...f.feature,
        'deps': ['feature.demo'],
        'watch': ['other/**'],
      }),
    );
    f.config['sentinels'] = {
      'pubspec.yaml': ['feature.demo'],
    };
    f.metadata();
    expect(
      f.registry.affected(['pubspec.yaml']).keys,
      containsAll(['feature.demo', 'feature.other']),
    );
  });
  test('large impact is explicit and context remains bounded', () {
    for (var i = 0; i < 120; i++) {
      f.write(
        '.fork/features/feature.x$i.yaml',
        jsonEncode({
          ...f.feature,
          'must': {
            'behavior':
                'A sufficiently long behavior contract for the output budget.',
          },
        }),
      );
    }
    final registry = f.registry;
    final packet = registry.context(['lib/code.dart']);
    expect(packet, contains('partial'));
    expect(utf8.encode(packet).length, lessThanOrEqualTo(6144));
    expect((registry.impact(['lib/code.dart'])['features'] as Map).length, 121);
  });
  test('partial staging reads contracts from the index', () {
    f.feature['must'] = {'behavior': 'Staged behavior.'};
    f.metadata();
    f.git.run(['add', '.fork']);
    f.feature['must'] = {'behavior': 'Unstaged behavior.'};
    f.metadata();
    expect(
      Registry(f.git, staged: true).context(['lib/code.dart']),
      contains('Staged behavior.'),
    );
    expect(
      f.registry.context(['lib/code.dart']),
      contains('Unstaged behavior.'),
    );
  });
}
