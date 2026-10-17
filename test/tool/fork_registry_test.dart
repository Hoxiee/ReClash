import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:test/test.dart' hide matches;

import '../../tool/src/fork/model.dart';
import '../../tool/src/fork/registry.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  setUp(() => f = ForkFixture());
  tearDown(() => f.dispose());

  test('metadata directory symlinks are not read as trusted policy', () {
    if (Platform.isWindows) return;
    final metadata = Directory(p.join(f.directory.path, '.fork'));
    final other = Directory(p.join(f.directory.path, 'other-policy'));
    metadata.renameSync(other.path);
    Link(metadata.path).createSync(other.path);
    expect(() => f.registry, throwsA(isA<ForkException>()));
  });
  test('Claude maintenance skill resolves to its canonical source', () {
    if (Platform.isWindows) return;
    final link = Link('.claude/skills/fork-maintenance');
    expect(link.targetSync(), '../../.agents/skills/fork-maintenance');
    expect(Directory(link.path).existsSync(), isTrue);
  });
  test('loads contracts and reports actual uncovered invariants', () {
    expect(f.registry.features['feature.demo']!.uncovered, isEmpty);
    (f.feature['must'] as Map)['unproven'] = 'No assertion yet.';
    f.metadata();
    expect(f.registry.features['feature.demo']!.uncovered, ['unproven']);
  });
  test('rejects unknown keys, invalid types and unknown invariant checks', () {
    f.feature['typo'] = true;
    f.metadata();
    expect(() => f.registry, throwsA(isA<ForkException>()));
    f.feature.remove('typo');
    f.feature['checks'] = {
      'fixture': ['absent'],
    };
    f.metadata();
    expect(() => f.registry, throwsA(isA<ForkException>()));
  });
  test('rejects cycles and unknown check groups', () {
    f.feature['deps'] = ['feature.demo'];
    f.metadata();
    expect(() => f.registry, throwsA(isA<ForkException>()));
    f.feature.remove('deps');
    f.feature['checks'] = {
      'unknown': ['behavior'],
    };
    f.metadata();
    expect(() => f.registry, throwsA(isA<ForkException>()));
  });
  test('rejects aliases, duplicate keys and unsafe paths', () {
    expect(
      () => yamlObject('v: 1\nv: 2', 'test'),
      throwsA(isA<ForkException>()),
    );
    expect(
      () => yamlObject('a: &anchor [x]\nb: *anchor', 'test'),
      throwsA(isA<ForkException>()),
    );
    expect(() => safePath('../elsewhere'), throwsA(isA<ForkException>()));
    expect(() => safePath('.git/config'), throwsA(isA<ForkException>()));
    expect(yamlObject('watch: ["**/*.dart"]', 'test')['watch'], ['**/*.dart']);
  });
  test('staged validation never substitutes unstaged metadata', () {
    f.git.run(['add', '.fork']);
    f.write('.fork/features/feature.demo.yaml', jsonEncode({'broken': true}));
    expect(() => f.registry, throwsA(isA<ForkException>()));
    expect(Registry(f.git, staged: true).features, contains('feature.demo'));
  });
  test('literal paths and recursive globs are bounded', () {
    expect(matches('lib/**/*.dart', 'lib/a.dart'), isTrue);
    expect(matches('lib/*.dart', 'lib/nested/a.dart'), isFalse);
    expect(matches('lib/**/*.dart', 'other/lib/a.dart'), isFalse);
  });
}
