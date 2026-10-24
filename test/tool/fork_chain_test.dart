import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/fork/git.dart';
import '../../tool/src/fork/model.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  setUp(() => f = ForkFixture());
  tearDown(() => f.dispose());

  void migration() {
    f.bootstrap();
    f.branding['preserve'] = [
      'https://github.com/chen08209/FlClash',
      'retained-attribution',
    ];
    f.metadata();
    f.commit('chore: approve normalization recipe');
    f.service.prepare(
      'recipe',
      source: f.raw,
      recipeMigration: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    f.finish('recipe');
  }

  Map<String, String> acceptedRefs() => {
    for (final ref in [
      'refs/heads/dev',
      'refs/heads/vendor/flclash',
      'refs/reclash/product-base/current',
    ])
      ref: f.git.oid(ref),
  };

  String nextSource() =>
      f.rewritten(files: {'lib/next.dart': 'const next = 2;\n'});

  test('continues an unaccepted migration without advancing accepted refs', () {
    migration();
    final refs = acceptedRefs();
    final predecessor = f.service.receipt('recipe');
    final head = f.candidate('recipe').oid('HEAD');
    final before = f.service.receiptFile('recipe').readAsStringSync();
    f.write('caller-wip.txt', 'leave untouched');
    final result = f.service.prepare(
      'next',
      source: nextSource(),
      after: 'recipe',
    );
    f.finish('next');
    final receipt = f.service.receipt('next');
    expect(result['status'], 'chained-candidate-preparation-only');
    expect(acceptedRefs(), refs);
    expect(f.service.receiptFile('recipe').readAsStringSync(), before);
    expect(
      File(p.join(f.directory.path, 'caller-wip.txt')).readAsStringSync(),
      'leave untouched',
    );
    expect(receipt['dev'], refs['refs/heads/dev']);
    expect(receipt['vendor'], refs['refs/heads/vendor/flclash']);
    expect(receipt['productBase'], refs['refs/reclash/product-base/current']);
    expect(receipt['base'], predecessor['preparedBase']);
    expect((receipt['lineage'] as Map)['candidate'], head);
    expect((receipt['lineage'] as Map)['receipt'], predecessor);
    expect(
      f.git.run([
        'show',
        '-s',
        '--format=%P',
        receipt['prepared'] as String,
      ]).trim(),
      predecessor['prepared'],
    );
    f.service.assertProductBase(
      receipt['preparedBase'] as String,
      receipt['prepared'] as String,
    );
    expect(
      f.candidate('next').read('HEAD', 'lib/next.dart'),
      'const next = 2;\n',
    );
    expect(
      f.candidate('next').read('HEAD', 'lib/code.dart'),
      contains('const downstream = true;'),
    );
    expect(
      () => f.service.verify(
        'next',
        reviews: ['normalization-policy', 'unclassified'],
      ),
      throwsA(isA<ForkException>()),
    );
    expect(f.service.receipt('next'), isNot(contains('verified')));
    final forged = f.service.receipt('next')
      ..['verified'] = <String, dynamic>{};
    f.service.save('next', forged);
    expect(() => f.service.accept('next'), throwsA(isA<ForkException>()));
    expect(acceptedRefs(), refs);

    final recovery = Directory.systemTemp.createTempSync(
      'reclash-chain-recovery-',
    );
    try {
      final git = ForkGit(recovery.path)..run(['init', '--bare', '-q']);
      git.run([
        'fetch',
        p.join(f.service.receiptFile('next').parent.path, 'snapshot.bundle'),
        'refs/*:refs/*',
      ]);
      for (final oid in [
        head,
        ...refs.values,
        predecessor['prepared'],
        predecessor['preparedBase'],
        predecessor['source'],
        receipt['prepared'],
        receipt['preparedBase'],
      ]) {
        expect(git.exists(oid as String), isTrue);
      }
      expect(git.oid('refs/reclash/lineage/next/candidate'), head);
    } finally {
      recovery.deleteSync(recursive: true);
    }
  });

  test(
    'rejects dirty and in-progress predecessors before creating next refs',
    () {
      migration();
      final target = f.candidate('recipe');
      final dirty = File(p.join(target.root, 'untracked.txt'))
        ..writeAsStringSync('dirty');
      expect(
        () => f.service.prepare('dirty', source: nextSource(), after: 'recipe'),
        throwsA(isA<ForkException>()),
      );
      dirty.deleteSync();
      for (final name in ['rebase-merge', 'sequencer']) {
        final path = target.run([
          'rev-parse',
          '--path-format=absolute',
          '--git-path',
          name,
        ]).trim();
        final state = Directory(path)..createSync();
        expect(
          () => f.service.prepare(
            'operation',
            source: nextSource(),
            after: 'recipe',
          ),
          throwsA(isA<ForkException>()),
        );
        state.deleteSync();
      }
      expect(f.git.exists('refs/reclash/prepared/dirty'), isFalse);
      expect(f.git.exists('refs/reclash/prepared/operation'), isFalse);
    },
  );

  test(
    'rejects replaced predecessor observation refs and candidate branch',
    () {
      migration();
      final r = f.service.receipt('recipe');
      f.git.run(['update-ref', 'refs/reclash/prepared/recipe', f.raw]);
      expect(
        () =>
            f.service.prepare('changed', source: nextSource(), after: 'recipe'),
        throwsA(isA<ForkException>()),
      );
      f.git.run([
        'update-ref',
        'refs/reclash/prepared/recipe',
        r['prepared'] as String,
      ]);
      f.candidate('recipe').run(['checkout', '--detach']);
      expect(
        () => f.service.prepare(
          'detached',
          source: nextSource(),
          after: 'recipe',
        ),
        throwsA(isA<ForkException>()),
      );
    },
  );

  test('rejects moved accepted refs and candidate policy drift', () {
    migration();
    final dev = f.git.oid('dev');
    f.write('advance.txt', 'advance');
    f.commit('chore: advance development');
    expect(
      () => f.service.prepare('moved', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
    f.git.run(['update-ref', 'refs/heads/dev', dev]);
    final target = f.candidate('recipe');
    File(p.join(target.root, '.fork/branding.yaml')).writeAsStringSync('{}');
    target.run(['add', '--all']);
    target.run(['commit', '-qm', 'chore: change candidate policy']);
    expect(
      () => f.service.prepare('policy', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
  });

  test(
    'rejects forged migration provenance despite matching protected refs',
    () {
      migration();
      final receipt = f.service.receipt('recipe');
      final oldVendor = receipt['vendor'] as String;
      final forged = f.git.commitTree(
        f.git.tree(receipt['prepared'] as String),
        [oldVendor],
        f.git.run(['show', '-s', '--format=%B', oldVendor]),
      );
      final base = f.service.productBaseCommit('forged', forged);
      f.git.run(['update-ref', 'refs/reclash/prepared/recipe', forged]);
      f.git.run([
        'update-ref',
        'refs/reclash/product-base/prepared/recipe',
        base,
      ]);
      receipt['prepared'] = forged;
      receipt['preparedBase'] = base;
      f.service.save('recipe', receipt);
      final target = f.candidate('recipe');
      target.run(['rebase', '--onto', base, receipt['base'] as String]);
      expect(
        () =>
            f.service.prepare('forged', source: nextSource(), after: 'recipe'),
        throwsA(isA<ForkException>()),
      );
    },
  );

  test('rejects accepted, ordinary, nested and history-only predecessors', () {
    migration();
    expect(
      () =>
          f.service.prepare('ordinary', source: nextSource(), after: 'initial'),
      throwsA(isA<ForkException>()),
    );
    expect(
      () => f.service.prepare('same', source: f.raw, after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
    expect(
      () => f.service.prepare(
        'mixed',
        source: nextSource(),
        after: 'recipe',
        recipeMigration: true,
      ),
      throwsA(isA<ForkException>()),
    );
    f.service.prepare('next', source: nextSource(), after: 'recipe');
    f.finish('next');
    expect(
      () => f.service.prepare('nested', source: nextSource(), after: 'next'),
      throwsA(isA<ForkException>()),
    );
    f.service.verify(
      'recipe',
      reviews: ['normalization-policy', 'unclassified'],
    );
    f.service.accept('recipe');
    expect(
      () =>
          f.service.prepare('accepted', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
  });
}
