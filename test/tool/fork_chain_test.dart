import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/fork/model.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  setUp(() {
    f = ForkFixture();
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
  });
  tearDown(() => f.dispose());

  String nextSource() =>
      f.rewritten(files: {'lib/new.dart': 'const next = 2;\n'});

  test(
    'chain replays predecessor, captures inputs and requires policy review',
    () {
      final service = f.service;
      final before = service.receipt('recipe');
      final target = f.candidate('recipe');
      File(
        p.join(target.root, 'lib/resolution.dart'),
      ).writeAsStringSync('resolved\n');
      f.finish('recipe');
      final tip = target.oid('HEAD');
      final dev = f.git.oid(service.devRef);
      final vendor = f.git.oid(service.vendorRef);
      final base = f.git.oid(service.productBaseRef);
      f.write('caller-wip.txt', 'untouched\n');
      final dirty = f.git.dirty;
      service.prepare('chain', source: nextSource(), after: 'recipe');
      final r = service.receipt('chain');
      final after = r['after'] as Map;
      expect(after['receipt'], digest(service.receipt('recipe')));
      expect(after['candidate'], tip);
      expect(r['base'], before['preparedBase']);
      expect(r['dev'], dev);
      expect(r['vendor'], vendor);
      expect(r['productBase'], base);
      expect(
        f.git.run([
          'show',
          '-s',
          '--format=%P',
          r['prepared'] as String,
        ]).trim(),
        before['prepared'],
      );
      expect(
        f.git.run([
          'show',
          '-s',
          '--format=%P',
          r['preparedBase'] as String,
        ]).trim(),
        isEmpty,
      );
      expect(f.git.oid(service.chainObservationRef('chain')), tip);
      expect(
        f.candidate('chain').read('HEAD', 'lib/resolution.dart'),
        'resolved\n',
      );
      expect(target.oid('HEAD'), tip);
      expect(target.dirty, isEmpty);
      expect(f.git.dirty, dirty);
      expect(f.git.oid(service.devRef), dev);
      expect(f.git.oid(service.vendorRef), vendor);
      expect(f.git.oid(service.productBaseRef), base);
      service.assertInputs(r);
      expect(
        () => service.verify(
          'chain',
          reviews: ['unclassified'],
          waivers: ['fixture'],
        ),
        throwsA(isA<ForkException>()),
      );
      f.finish('chain');
      service.verify(
        'chain',
        reviews: ['unclassified', 'normalization-policy'],
        waivers: ['fixture'],
      );
      final verified = service.receipt('chain')['verified'] as Map;
      expect(verified['predecessor'], after);
      expect(f.git.oid(service.devRef), dev);
      final archive = p.join(
        service.receiptFile('chain').parent.path,
        'snapshot.bundle',
      );
      expect(
        f.git.run(['bundle', 'list-heads', archive]),
        contains('$tip ${service.chainObservationRef('chain')}'),
      );
    },
  );

  test('incompatible modes reject before creating observations', () {
    for (final options in [0, 1, 2]) {
      expect(
        () => f.service.prepare(
          'bad$options',
          source: nextSource(),
          after: 'recipe',
          bootstrap: options == 0,
          recipeMigration: options == 1,
          audit: options == 2 ? 'audit' : null,
        ),
        throwsA(isA<ForkException>()),
      );
      expect(f.git.exists('refs/reclash/prepared/bad$options'), isFalse);
    }
  });

  test('dirty predecessor is not changed or captured', () {
    final target = f.candidate('recipe');
    final tip = target.oid('HEAD');
    final file = File(p.join(target.root, 'dirty.txt'))
      ..writeAsStringSync('keep\n');
    expect(
      () => f.service.prepare('dirty', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
    expect(target.oid('HEAD'), tip);
    expect(file.readAsStringSync(), 'keep\n');
    expect(f.git.exists('refs/reclash/prepared/dirty'), isFalse);
  });

  test('clean in-progress predecessor is rejected', () {
    final target = f.candidate('recipe');
    target.run(['update-ref', 'CHERRY_PICK_HEAD', target.oid('HEAD')]);
    expect(
      () => f.service.prepare('busy', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
  });

  test(
    'moved accepted inputs and protected observations reject preparation',
    () {
      f.git.run(['update-ref', 'refs/reclash/prepared/recipe', f.raw]);
      expect(
        () => f.service.prepare('moved', source: nextSource(), after: 'recipe'),
        throwsA(isA<ForkException>()),
      );
    },
  );

  test('corrupt bundle rejects preparation', () {
    final archive = File(
      p.join(f.service.receiptFile('recipe').parent.path, 'snapshot.bundle'),
    );
    archive.writeAsStringSync('not a bundle');
    expect(
      () => f.service.prepare('archive', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
  });

  test('current or candidate policy drift rejects preparation', () {
    final target = f.candidate('recipe');
    final file = File(p.join(target.root, '.fork/branding.yaml'));
    final original = file.readAsStringSync();
    file.writeAsStringSync('$original\n# drift\n');
    f.finish('recipe');
    expect(
      () => f.service.prepare(
        'candidate-policy',
        source: nextSource(),
        after: 'recipe',
      ),
      throwsA(isA<ForkException>()),
    );
    file.writeAsStringSync(original);
    f.finish('recipe');
    f.branding['preserve'] = ['changed-policy'];
    f.metadata();
    expect(
      () => f.service.prepare(
        'current-policy',
        source: nextSource(),
        after: 'recipe',
      ),
      throwsA(isA<ForkException>()),
    );
  });

  test('accepted development movement rejects preparation', () {
    f.git.run([
      'commit',
      '--allow-empty',
      '-m',
      'chore: move accepted development',
    ]);
    expect(
      () =>
          f.service.prepare('dev-moved', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
  });

  test('valid bundle with substituted protected refs rejects preparation', () {
    final service = f.service;
    final r = service.receipt('recipe');
    final archive = p.join(
      service.receiptFile('recipe').parent.path,
      'snapshot.bundle',
    );
    File(archive).deleteSync();
    f.git.run([
      'update-ref',
      'refs/reclash/upstream/recipe',
      r['prepared'] as String,
    ]);
    f.git.run([
      'bundle',
      'create',
      archive,
      'refs/reclash/upstream/recipe',
      'refs/reclash/prepared/recipe',
      service.productBaseObservationRef('recipe'),
      service.productBaseRef,
      'refs/heads/sync/recipe',
    ]);
    f.git.run([
      'update-ref',
      'refs/reclash/upstream/recipe',
      r['source'] as String,
    ]);
    expect(
      () =>
          service.prepare('substituted', source: nextSource(), after: 'recipe'),
      throwsA(isA<ForkException>()),
    );
  });

  test('predecessor candidate and base recover from child bundle', () {
    f.service.prepare('recovery', source: nextSource(), after: 'recipe');
    final r = f.service.receipt('recovery');
    final recovery = Directory.systemTemp.createTempSync(
      'reclash-chain-recovery-',
    );
    try {
      final init = Process.runSync('git', ['init', '--bare', recovery.path]);
      expect(init.exitCode, 0);
      final archive = p.join(
        f.service.receiptFile('recovery').parent.path,
        'snapshot.bundle',
      );
      final fetched = Process.runSync('git', [
        '--git-dir=${recovery.path}',
        'fetch',
        archive,
        'refs/*:refs/*',
      ]);
      expect(fetched.exitCode, 0, reason: fetched.stderr.toString());
      for (final oid in [
        (r['after'] as Map)['candidate'],
        r['preparedBase'],
        (r['after'] as Map)['preparedBase'],
      ]) {
        expect(
          Process.runSync('git', [
            '--git-dir=${recovery.path}',
            'cat-file',
            '-e',
            '$oid^{commit}',
          ]).exitCode,
          0,
        );
      }
    } finally {
      recovery.deleteSync(recursive: true);
    }
  });

  test('receipt or candidate movement invalidates captured chain', () {
    f.service.prepare('chain', source: nextSource(), after: 'recipe');
    final r = f.service.receipt('chain');
    final predecessor = f.service.receipt('recipe');
    predecessor['note'] = 'changed';
    f.service.save('recipe', predecessor);
    expect(() => f.service.assertInputs(r), throwsA(isA<ForkException>()));
    predecessor.remove('note');
    f.service.save('recipe', predecessor);
    final target = f.candidate('recipe');
    target.run(['commit', '--allow-empty', '-m', 'chore: move predecessor']);
    expect(() => f.service.assertInputs(r), throwsA(isA<ForkException>()));
  });

  test('accepted and ordinary predecessors are rejected', () {
    expect(
      () =>
          f.service.prepare('ordinary', source: nextSource(), after: 'initial'),
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
  void verifiedChild() {
    f.service.prepare('child', source: nextSource(), after: 'recipe');
    f.finish('child');
    f.service.verify(
      'child',
      reviews: ['unclassified', 'normalization-policy'],
    );
  }

  test(
    'accept advances the complete chain and archives original development',
    () {
      final old = f.git.oid(f.service.devRef);
      final predecessor = f.service.receipt('recipe');
      verifiedChild();
      final child = f.service.receipt('child');
      final result = f.service.accept('child');
      expect(result['status'], 'accepted');
      expect(f.git.oid(f.service.devRef), f.candidate('child').oid('HEAD'));
      expect(f.git.oid(f.service.vendorRef), child['prepared']);
      expect(f.git.oid(f.service.productBaseRef), child['preparedBase']);
      expect(f.git.oid(f.service.developmentArchiveRef('child')), old);
      expect(f.service.receipt('recipe'), predecessor);
      expect(
        f.git.ancestor(
          predecessor['prepared'] as String,
          child['prepared'] as String,
        ),
        isTrue,
      );
      expect(f.service.accept('child')['status'], 'accepted');
    },
  );

  test(
    'changed predecessor after verification blocks acceptance before refs move',
    () {
      verifiedChild();
      final dev = f.git.oid(f.service.devRef);
      File(
        p.join(f.candidate('recipe').root, 'lib/moved.dart'),
      ).writeAsStringSync('moved');
      f.finish('recipe');
      expect(() => f.service.accept('child'), throwsA(isA<ForkException>()));
      expect(f.git.oid(f.service.devRef), dev);
      expect(f.git.exists(f.service.developmentArchiveRef('child')), isFalse);
    },
  );

  test('interrupted chain acceptance resumes after dev and base advanced', () {
    verifiedChild();
    final r = f.service.receipt('child');
    final tip = f.candidate('child').oid('HEAD');
    f.service.archiveDevelopment('child', r);
    f.git.run(['update-ref', f.service.devRef, tip, r['dev'] as String]);
    f.git.run([
      'update-ref',
      f.service.productBaseRef,
      r['preparedBase'] as String,
      r['productBase'] as String,
    ]);
    f.git.run(['reset', '--hard', tip]);
    expect(f.service.accept('child')['status'], 'accepted');
    expect(f.git.oid(f.service.vendorRef), r['prepared']);
  });

  test('archive collision blocks acceptance without changing development', () {
    verifiedChild();
    final old = f.git.oid(f.service.devRef);
    f.git.run(['update-ref', f.service.developmentArchiveRef('child'), f.raw]);
    expect(() => f.service.accept('child'), throwsA(isA<ForkException>()));
    expect(f.git.oid(f.service.devRef), old);
  });

  test(
    'retention keeps two accepted archives and leaves unrelated archives alone',
    () {
      verifiedChild();
      f.service.accept('child');
      f.git.run(['update-ref', 'refs/heads/archive/manual', f.raw]);
      for (final id in ['next1', 'next2']) {
        final source = f.rewritten(
          files: {'lib/$id.dart': 'const value = 3;\n'},
        );
        f.service.prepare(id, source: source);
        f.finish(id);
        f.service.verify(id, reviews: ['unclassified']);
        f.service.accept(id);
      }
      expect(f.git.exists(f.service.developmentArchiveRef('initial')), isFalse);
      expect(f.git.exists(f.service.developmentArchiveRef('child')), isFalse);
      expect(f.git.exists(f.service.developmentArchiveRef('next1')), isTrue);
      expect(f.git.exists(f.service.developmentArchiveRef('next2')), isTrue);
      expect(f.git.oid('refs/heads/archive/manual'), f.raw);
      expect(
        File(
          p.join(
            f.service.receiptFile('child').parent.path,
            'development-before.bundle',
          ),
        ).existsSync(),
        isTrue,
      );
    },
  );
  test(
    'archive bundle restores previous development into an empty repository',
    () {
      final old = f.git.oid(f.service.devRef);
      verifiedChild();
      f.service.accept('child');
      final archive = p.join(
        f.service.receiptFile('child').parent.path,
        'development-before.bundle',
      );
      final restored = Directory.systemTemp.createTempSync(
        'chain-archive-restore-',
      );
      addTearDown(() => restored.deleteSync(recursive: true));
      f.git.run(['init', '--bare', restored.path]);
      f.git.run([
        '-C',
        restored.path,
        'fetch',
        archive,
        '${f.service.developmentArchiveRef('child')}:refs/heads/restored',
      ]);
      expect(
        f.git.run([
          '-C',
          restored.path,
          'rev-parse',
          'refs/heads/restored',
        ]).trim(),
        old,
      );
    },
  );

  test('modified managed archive blocks pruning before development moves', () {
    verifiedChild();
    f.service.accept('child');
    final source = f.rewritten(files: {'lib/next.dart': 'const value = 4;\n'});
    f.service.prepare('next', source: source);
    f.finish('next');
    f.service.verify('next', reviews: ['unclassified']);
    final old = f.git.oid(f.service.devRef);
    f.git.run([
      'update-ref',
      f.service.developmentArchiveRef('initial'),
      f.raw,
    ]);
    expect(() => f.service.accept('next'), throwsA(isA<ForkException>()));
    expect(f.git.oid(f.service.devRef), old);
    expect(f.git.exists(f.service.developmentArchiveRef('next')), isFalse);
  });

  test('predecessor receipt mutation invalidates verified child', () {
    verifiedChild();
    final old = f.git.oid(f.service.devRef);
    final r = f.service.receipt('recipe');
    r['extra'] = 'modified';
    f.service.save('recipe', r);
    expect(() => f.service.accept('child'), throwsA(isA<ForkException>()));
    expect(f.git.oid(f.service.devRef), old);
  });
  test('predecessor source identity must match its observed vendor', () {
    final r = f.service.receipt('recipe');
    r['source'] = nextSource();
    f.service.save('recipe', r);
    f.git.run([
      'update-ref',
      'refs/reclash/upstream/recipe',
      r['source'] as String,
    ]);
    expect(
      () => f.service.prepare(
        'forged-source',
        source: nextSource(),
        after: 'recipe',
      ),
      throwsA(isA<ForkException>()),
    );
    expect(f.git.exists('refs/reclash/prepared/forged-source'), isFalse);
  });
}
