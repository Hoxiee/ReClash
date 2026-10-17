import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/changelog/git.dart';
import '../../tool/src/changelog/parser.dart';
import '../../tool/src/fork/git.dart';
import '../../tool/src/fork/model.dart';
import '../../tool/src/fork/registry.dart';
import '../../tool/src/fork/sync.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  setUp(() => f = ForkFixture());
  tearDown(() => f.dispose());

  test(
    'verification includes critical paths introduced during candidate resolution',
    () {
      f.write(
        '.fork/features/feature.identity.yaml',
        '{"v":1,"kind":"identity","state":"active","risk":"critical","must":{"identity":"Preserve the product ID."},"watch":["identity.txt"],"checks":{"fixture":["identity"]}}',
      );
      f.commit('test: declare critical identity seam');
      f.service.prepare(
        'expanded',
        source: f.raw,
        bootstrap: true,
        audit: digest(f.service.inspect(f.raw)),
      );
      File(
        p.join(f.candidate('expanded').root, 'identity.txt'),
      ).writeAsStringSync('changed during resolution');
      f.finish('expanded');
      expect(
        () => f.service.verify(
          'expanded',
          reviews: ['bootstrap-audit', 'unclassified'],
        ),
        throwsA(isA<ForkException>()),
      );
      f.service.verify(
        'expanded',
        reviews: ['bootstrap-audit', 'unclassified', 'feature.identity'],
      );
      expect(
        (f.service.receipt('expanded')['impact'] as Map)['critical'],
        contains('feature.identity'),
      );
    },
  );
  test(
    'candidate normalization implementation drift invalidates verification',
    () {
      f.service.prepare(
        'implementation',
        source: f.raw,
        bootstrap: true,
        audit: digest(f.service.inspect(f.raw)),
      );
      final target = f.candidate('implementation');
      final file = File(p.join(target.root, 'tool/src/fork/normalize.dart'));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('changed normalization implementation');
      f.finish('implementation');
      expect(
        () => f.service.verify(
          'implementation',
          reviews: ['bootstrap-audit', 'unclassified'],
        ),
        throwsA(isA<ForkException>()),
      );
      expect(f.service.receipt('implementation'), isNot(contains('verified')));
    },
  );
  test(
    'fetch captures unrelated force-pushed source trees under unique refs',
    () {
      f.config['source'] = {
        'remote': 'flclash',
        'url': f.directory.path,
        'ref': 'refs/heads/source-observed',
      };
      f.metadata();
      f.commit('chore: configure source branch');
      f.bootstrap();
      final first = f.rewritten();
      f.git.run(['update-ref', 'refs/heads/source-observed', first]);
      expect(f.service.prepare('fetch-same')['status'], 'history-only');
      final next = f.rewritten(
        code: "import 'package:fl_clash/a.dart';\nconst upstream = 7;\n",
      );
      f.git.run(['update-ref', 'refs/heads/source-observed', next, first]);
      expect(f.git.ancestor(first, next), isFalse);
      f.service.prepare('fetch-next');
      expect(f.git.oid('refs/reclash/upstream/fetch-next'), next);
      expect(f.git.oid('refs/reclash/upstream/fetch-same'), first);
    },
  );

  test('policy drift invalidates an earlier successful verification', () {
    f.service.prepare(
      'policy',
      source: f.raw,
      bootstrap: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    f.finish('policy');
    f.service.verify('policy', reviews: ['bootstrap-audit', 'unclassified']);
    (f.feature['must'] as Map)['behavior'] =
        'A changed policy cannot reuse an old receipt.';
    f.metadata();
    expect(
      () => f.service.verify(
        'policy',
        reviews: ['bootstrap-audit', 'unclassified'],
      ),
      throwsA(isA<ForkException>()),
    );
    expect(f.service.receipt('policy'), isNot(contains('verified')));
  });

  test('committed conflict markers cannot produce a verification receipt', () {
    f.write(
      'lib/unresolved.dart',
      '<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> source\n',
    );
    f.commit('test: unresolved baseline');
    f.service.prepare(
      'markers',
      source: f.raw,
      bootstrap: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    f.finish('markers');
    expect(
      () => f.service.verify(
        'markers',
        reviews: ['bootstrap-audit', 'unclassified'],
      ),
      throwsA(isA<ForkException>()),
    );
    expect(f.service.receipt('markers'), isNot(contains('verified')));
  });

  test(
    'recipe migrations require the same raw source, audit and policy review',
    () {
      f.bootstrap();
      f.branding['preserve'] = [
        'https://github.com/chen08209/FlClash',
        'retained-attribution',
      ];
      f.metadata();
      f.commit('chore: approve normalization recipe');
      expect(
        () =>
            f.service.prepare('mixed', source: f.rewritten(code: 'changed\n')),
        throwsA(isA<ForkException>()),
      );
      final audit = digest(f.service.inspect(f.raw));
      f.service.prepare(
        'recipe',
        source: f.raw,
        recipeMigration: true,
        audit: audit,
      );
      f.finish('recipe');
      expect(() => f.service.verify('recipe'), throwsA(isA<ForkException>()));
      f.service.verify(
        'recipe',
        reviews: ['normalization-policy', 'unclassified'],
      );
      f.service.accept('recipe');
      expect(
        f.service.provenance(f.git.oid('vendor/flclash'))['Upstream-Commit'],
        f.raw,
      );
    },
  );

  test(
    'a missing platform host blocks readiness and an explicit waiver is not a pass',
    () {
      f.config['checks'] = {
        'fixture': {
          'argv': ['git', 'status', '--short'],
          'host': Platform.isWindows ? 'macos' : 'windows',
        },
      };
      f.metadata();
      f.commit('chore: require another platform');
      f.service.prepare(
        'platform',
        source: f.raw,
        bootstrap: true,
        audit: digest(f.service.inspect(f.raw)),
      );
      f.finish('platform');
      expect(
        () => f.service.verify(
          'platform',
          reviews: ['bootstrap-audit', 'unclassified'],
        ),
        throwsA(isA<ForkException>()),
      );
      expect(f.service.receipt('platform'), isNot(contains('verified')));
      final result = f.service.verify(
        'platform',
        reviews: ['bootstrap-audit', 'unclassified'],
        waivers: ['fixture'],
      );
      expect(result['status'], 'verified-with-waivers');
      expect(
        ((f.service.receipt('platform')['verified'] as Map)['checks']
            as Map)['fixture']['status'],
        'waived',
      );
    },
  );

  test(
    'clean Core source changes require review and vendor does not absorb our pin',
    () {
      final original = f.git.oid('HEAD');
      final indexDir = Directory.systemTemp.createTempSync('reclash-gitlink-');
      addTearDown(() => indexDir.deleteSync(recursive: true));
      final environment = {'GIT_INDEX_FILE': p.join(indexDir.path, 'index')};
      String snapshot(String base, String pin, String modules) {
        f.git.run(['read-tree', base], environment: environment);
        final payload = File(p.join(indexDir.path, 'modules'))
          ..writeAsStringSync(modules);
        final blob = f.git.run(['hash-object', '-w', payload.path]).trim();
        f.git.run([
          'update-index',
          '--add',
          '--cacheinfo',
          '100644,$blob,.gitmodules',
        ], environment: environment);
        f.git.run([
          'update-index',
          '--add',
          '--cacheinfo',
          '160000,$pin,core/mihomo',
        ], environment: environment);
        return f.git.commitTree(
          f.git.run(['write-tree'], environment: environment).trim(),
          [base],
          'chore: engine snapshot',
        );
      }

      const modules =
          '[submodule "core/mihomo"]\npath = core/mihomo\nurl = https://example.com/upstream.git\n';
      final source = snapshot(original, f.raw, modules);
      final downstream = snapshot(source, original, modules);
      f.git.run(['merge', '--ff-only', downstream]);
      f.service.prepare(
        'engine-base',
        source: source,
        bootstrap: true,
        audit: digest(f.service.inspect(source)),
      );
      f.finish('engine-base');
      f.service.verify(
        'engine-base',
        reviews: ['bootstrap-audit', 'unclassified', 'core-source'],
      );
      f.service.accept('engine-base');
      final next = snapshot(
        source,
        f.raw,
        '$modules# upstream source observation\n',
      );
      f.service.prepare('engine', source: next);
      final receipt = f.service.receipt('engine');
      expect(receipt['coreReview'], isTrue);
      expect(
        f.git
            .entries(receipt['prepared'] as String)
            .singleWhere((e) => e.path == 'core/mihomo')
            .oid,
        f.raw,
      );
      expect(
        f.candidate('engine').run(['ls-files', '--stage', 'core/mihomo']),
        contains(original),
      );
      f.finish('engine');
      expect(
        () => f.service.verify('engine', reviews: ['unclassified']),
        throwsA(isA<ForkException>()),
      );
      f.service.verify('engine', reviews: ['unclassified', 'core-source']);
    },
  );

  test(
    'bootstrap replays downstream commits onto an independent product base',
    () {
      final old = f.git.oid('HEAD');
      final audit = digest(f.service.inspect(f.raw));
      f.service.prepare('start', source: f.raw, bootstrap: true, audit: audit);
      final target = f.candidate('start');
      if (target.rebaseInProgress) {
        target.run([
          'restore',
          '--source=$old',
          '--staged',
          '--worktree',
          '--',
          '.',
        ]);
        target.run(
          ['rebase', '--continue'],
          environment: const {'GIT_EDITOR': 'true'},
        );
      }
      final r = f.service.receipt('start');
      final candidate = target.oid('HEAD');
      final prepared = r['prepared'] as String;
      final productBase = r['preparedBase'] as String;
      expect(f.git.oid('dev'), old);
      expect(f.git.tree(candidate), f.git.tree(old));
      expect(
        f.git.run(['show', '-s', '--format=%P', candidate]).trim(),
        productBase,
      );
      expect(
        f.git.run(['show', '-s', '--format=%P', productBase]).trim(),
        isEmpty,
      );
      expect(f.git.tree(productBase), f.git.tree(prepared));
      expect(target.firstParentAncestor(productBase, candidate), isTrue);
      expect(target.ancestor(prepared, candidate), isFalse);
      expect(f.git.run(['rev-list', '--merges', candidate]).trim(), isEmpty);
    },
  );
  test(
    'bootstrap rejects merge-shaped downstream history before writing refs',
    () {
      final dev = f.git.oid('dev');
      final side = f.git.commitTree(f.git.tree(dev), [
        dev,
      ], 'fix: side history');
      f.git.run(['update-ref', 'refs/heads/side', side]);
      f.git.run(['merge', '--no-ff', '--no-edit', 'side']);
      final audit = digest(f.service.inspect(f.raw));
      expect(
        () => f.service.prepare(
          'nonlinear-bootstrap',
          source: f.raw,
          bootstrap: true,
          audit: audit,
        ),
        throwsA(isA<ForkException>()),
      );
      expect(
        f.git.exists('refs/reclash/prepared/nonlinear-bootstrap'),
        isFalse,
      );
    },
  );
  test('bootstrap audit cannot silently use different inputs', () {
    expect(
      () => f.service.prepare(
        'bad',
        source: f.raw,
        bootstrap: true,
        audit: 'not-reviewed',
      ),
      throwsA(isA<ForkException>()),
    );
    expect(f.git.exists('refs/reclash/prepared/bad'), isFalse);
  });
  test('preparation and verification never modify dirty caller work', () {
    f.write('lib/code.dart', 'uncommitted user change');
    f.git.run(['add', 'lib/code.dart']);
    f.write('untracked.txt', 'keep me');
    final status = f.git.run(['status', '--porcelain=v1']);
    final index = f.git.run(['write-tree']);
    final audit = digest(f.service.inspect(f.raw));
    f.service.prepare('dirty', source: f.raw, bootstrap: true, audit: audit);
    f.finish('dirty');
    f.service.verify('dirty', reviews: ['bootstrap-audit', 'unclassified']);
    expect(f.git.run(['write-tree']), index);
    expect(f.git.run(['status', '--porcelain=v1']), status);
    expect(() => f.service.accept('dirty'), throwsA(isA<ForkException>()));
  });
  test(
    'unrelated rewritten source rebases cleanly and vendor history stays append-only',
    () {
      final v0 = f.bootstrap();
      final raw = f.rewritten(
        code: "import 'package:fl_clash/a.dart';\nconst upstream = 2;\n",
      );
      expect(f.git.ancestor(f.raw, raw), isFalse);
      f.service.prepare('next', source: raw);
      final target = f.candidate('next');
      expect(target.rebaseInProgress, isTrue);
      expect(
        () => f.service.verify('next', reviews: ['unclassified']),
        throwsA(isA<ForkException>()),
      );
      if (target.run(['ls-files', '-u']).isNotEmpty) {
        File(p.join(target.root, 'lib/code.dart')).writeAsStringSync(
          "import 'package:reclash/a.dart';\nconst upstream = 2;\nconst downstream = true;\n",
        );
      }
      f.finish('next');
      final candidate = target.oid('HEAD');
      final receipt = f.service.receipt('next');
      final prepared = receipt['prepared'] as String;
      final productBase = receipt['preparedBase'] as String;
      expect(target.firstParentAncestor(productBase, candidate), isTrue);
      expect(
        target.run(['rev-list', '--merges', '$productBase..$candidate']).trim(),
        isEmpty,
      );
      f.service.verify('next', reviews: ['unclassified']);
      expect(f.service.receipt('next')['replayed'], isNotEmpty);
      expect(f.git.run(['show', '-s', '--format=%P', prepared]).trim(), v0);
      expect(f.git.ancestor(raw, prepared), isFalse);
      expect(target.ancestor(prepared, candidate), isFalse);
      expect(
        target.read('HEAD', 'lib/code.dart'),
        contains('const downstream = true;'),
      );
      f.service.accept('next');
      expect(f.git.oid('vendor/flclash'), prepared);
      expect(f.git.oid(f.service.productBaseRef), productBase);
      expect(f.git.ancestor(v0, 'dev'), isFalse);
    },
  );
  test('an upstream-absorbed patch is omitted from the replayed stack', () {
    final vendor = f.bootstrap();
    f.write('lib/already_upstream.dart', 'const absorbed = true;\n');
    final absorbedCommit = f.commit('fix: add behavior absorbed upstream');
    final source = f.rewritten(
      files: {'lib/already_upstream.dart': 'const absorbed = true;\n'},
    );
    f.service.prepare('absorbed', source: source);
    f.finish('absorbed');
    final target = f.candidate('absorbed');
    f.service.verify('absorbed', reviews: ['unclassified']);
    final receipt = f.service.receipt('absorbed');
    expect(receipt['vendor'], vendor);
    expect(receipt['replaySource'], contains(absorbedCommit));
    expect(receipt['replayed'], isNot(contains(absorbedCommit)));
    expect(receipt['rebaseLog'], contains('patch contents already upstream'));
    expect(
      target.read('HEAD', 'lib/already_upstream.dart'),
      contains('absorbed'),
    );
  });
  test('normal sync rejects a merge-shaped downstream stack', () {
    f.bootstrap();
    final dev = f.git.oid('dev');
    final side = f.git.commitTree(f.git.tree(dev), [dev], 'fix: side history');
    f.git.run(['update-ref', 'refs/heads/side', side]);
    f.git.run(['merge', '--no-ff', '--no-edit', 'side']);
    expect(
      () => f.service.prepare('nonlinear', source: f.rewritten(code: 'new\n')),
      throwsA(isA<ForkException>()),
    );
    expect(f.git.exists('refs/reclash/prepared/nonlinear'), isFalse);
  });
  test('normal sync requires an explicit accepted product base', () {
    f.bootstrap();
    f.git.run(['update-ref', '-d', f.service.productBaseRef]);
    expect(
      () => f.service.prepare('missing-product-base', source: f.rewritten()),
      throwsA(isA<ForkException>()),
    );
    expect(f.git.exists('refs/reclash/prepared/missing-product-base'), isFalse);
  });
  test('history-only rewrite requires no rebase candidate', () {
    final vendor = f.bootstrap();
    final productBase = f.git.oid(f.service.productBaseRef);
    final dev = f.git.oid('dev');
    final raw = f.rewritten();
    final result = f.service.prepare('history', source: raw);
    expect(result['status'], 'history-only');
    expect(f.git.oid('dev'), dev);
    expect(f.git.oid('vendor/flclash'), vendor);
    expect(f.git.oid(f.service.productBaseRef), productBase);
  });
  test(
    'upstream release files and version cannot overwrite downstream values',
    () {
      f.bootstrap();
      final raw = f.rewritten(
        manifest:
            'name: fl_clash\nversion: 99.0.0\ndependencies: {new_package: any}\n',
        changelog: '# New upstream release\n',
      );
      f.service.prepare('release', source: raw);
      final target = f.candidate('release');
      final file = File(p.join(target.root, 'pubspec.yaml'));
      if (target.run(['ls-files', '-u']).isNotEmpty) {
        file.writeAsStringSync(
          'name: reclash\nversion: 2.0.0\ndependencies: {new_package: any}\n',
        );
      }
      f.finish('release');
      f.service.verify('release', reviews: ['unclassified']);
      expect(target.read('HEAD', 'CHANGELOG.md'), '# ReClash\n');
      expect(target.read('HEAD', 'pubspec.yaml'), contains('version: 2.0.0'));
      expect(target.read('HEAD', 'pubspec.yaml'), contains('new_package'));
    },
  );
  test('candidate edits after verification invalidate acceptance', () {
    final audit = digest(f.service.inspect(f.raw));
    f.service.prepare('stale', source: f.raw, bootstrap: true, audit: audit);
    f.finish('stale');
    f.service.verify('stale', reviews: ['bootstrap-audit', 'unclassified']);
    File(
      p.join(f.candidate('stale').root, 'lib/code.dart'),
    ).writeAsStringSync('edited');
    expect(() => f.service.accept('stale'), throwsA(isA<ForkException>()));
  });
  test('concurrent development commit blocks acceptance', () {
    final audit = digest(f.service.inspect(f.raw));
    f.service.prepare('moving', source: f.raw, bootstrap: true, audit: audit);
    f.finish('moving');
    f.service.verify('moving', reviews: ['bootstrap-audit', 'unclassified']);
    f.git.run(['commit', '--allow-empty', '-q', '-m', 'fix: concurrent work']);
    expect(() => f.service.accept('moving'), throwsA(isA<ForkException>()));
  });
  test('concurrent product-base ref movement blocks acceptance', () {
    final vendor = f.bootstrap();
    final oldDev = f.git.oid('dev');
    final oldProductBase = f.git.oid(f.service.productBaseRef);
    f.service.prepare(
      'base-moving',
      source: f.rewritten(
        files: {'lib/upstream_new.dart': 'const source = 2;'},
      ),
    );
    f.finish('base-moving');
    f.service.verify('base-moving', reviews: ['unclassified']);
    f.git.run(['update-ref', f.service.productBaseRef, oldDev, oldProductBase]);
    expect(
      () => f.service.accept('base-moving'),
      throwsA(isA<ForkException>()),
    );
    expect(f.git.oid('dev'), oldDev);
    expect(f.git.oid('vendor/flclash'), vendor);
  });
  test('an interrupted acceptance can finish base and vendor advancement', () {
    final audit = digest(f.service.inspect(f.raw));
    f.service.prepare('recover', source: f.raw, bootstrap: true, audit: audit);
    f.finish('recover');
    f.service.verify('recover', reviews: ['bootstrap-audit', 'unclassified']);
    final receipt = f.service.receipt('recover');
    final candidate = f.candidate('recover').oid('HEAD');
    final old = f.git.oid('dev');
    f.git.run(['update-ref', 'refs/heads/dev', candidate, old]);
    f.git.run([
      'update-ref',
      f.service.productBaseRef,
      receipt['preparedBase'] as String,
      '',
    ]);
    expect(f.git.exists('vendor/flclash'), isFalse);
    expect(f.service.accept('recover')['status'], 'accepted');
    expect(f.git.oid(f.service.productBaseRef), receipt['preparedBase']);
    expect(f.git.oid('vendor/flclash'), receipt['prepared']);
    expect(f.git.tree('dev'), f.git.tree(candidate));
    expect(ForkGit(f.directory.path).dirty, isEmpty);
  });
  test('receipt cannot bypass missing critical coverage', () {
    f.feature['risk'] = 'critical';
    (f.feature['must'] as Map)['uncovered'] = 'This has no regression test.';
    f.metadata();
    f.commit('test: uncovered contract');
    final audit = digest(f.service.inspect(f.raw));
    f.service.prepare('gap', source: f.raw, bootstrap: true, audit: audit);
    f.finish('gap');
    expect(
      () =>
          f.service.verify('gap', reviews: ['bootstrap-audit', 'unclassified']),
      throwsA(isA<ForkException>()),
    );
  });
  test('failed check does not produce a verified receipt', () {
    (f.config['checks'] as Map)['fixture'] = {
      'argv': ['git', 'nonexistent-command'],
    };
    f.metadata();
    f.commit('test: failing check');
    final audit = digest(f.service.inspect(f.raw));
    f.service.prepare('failure', source: f.raw, bootstrap: true, audit: audit);
    f.finish('failure');
    expect(
      () => f.service.verify(
        'failure',
        reviews: ['bootstrap-audit', 'unclassified'],
      ),
      throwsA(isA<ForkException>()),
    );
    expect(f.service.receipt('failure').containsKey('verified'), isFalse);
  });
  test('duplicate observation IDs and changed source identity fail closed', () {
    f.bootstrap();
    expect(
      () => f.service.prepare('initial', source: f.raw),
      throwsA(isA<ForkException>()),
    );
    f.git.run([
      'remote',
      'set-url',
      'flclash',
      'https://example.com/other.git',
    ]);
    expect(
      () => f.service.prepare('wrong-source', source: f.raw),
      throwsA(isA<ForkException>()),
    );
  });
  test('bundle restores declared objects into an empty repository', () {
    f.bootstrap();
    final restored = Directory.systemTemp.createTempSync(
      'reclash-bundle-test-',
    );
    try {
      final other = ForkGit(restored.path);
      other.run(['init', '--bare', '-q']);
      final archive = p.join(
        f.service.receiptFile('initial').parent.path,
        'snapshot.bundle',
      );
      other.run(['fetch', archive, 'refs/*:refs/*']);
      expect(other.oid('refs/reclash/upstream/initial'), f.raw);
      expect(
        other.tree('refs/reclash/prepared/initial'),
        f.git.tree('vendor/flclash'),
      );
      expect(
        other.tree('refs/reclash/product-base/prepared/initial'),
        f.git.tree('vendor/flclash'),
      );
    } finally {
      restored.deleteSync(recursive: true);
    }
  });
  test(
    'source objects survive GC and vendor commits never enter release notes',
    () {
      f.bootstrap();
      f.git.run(['gc', '--prune=now']);
      expect(f.git.oid('refs/reclash/upstream/initial'), f.raw);
      final parser = ChangelogParser();
      final git = Git(workingDirectory: f.directory.path);
      expect(
        parser.parseAll(git.commits(from: f.raw, to: 'vendor/flclash')),
        isEmpty,
      );
      f.git.run([
        'commit',
        '--allow-empty',
        '-q',
        '-m',
        'fix: preserve our behavior\n\nChangelog: Our fix',
      ]);
      expect(
        parser
            .parseAll(git.commits(from: 'vendor/flclash', to: 'dev'))
            .map((item) => item.entry.text),
        contains('Our fix'),
      );
    },
  );
  test('linked worktree resolves the common archive directory', () {
    f.bootstrap();
    final candidate = f.candidate('initial');
    expect(candidate.common, f.git.common);
    expect(candidate.stateRoot, f.git.stateRoot);
    expect(Registry(candidate).features.keys, contains('feature.demo'));
    expect(
      VendorSync(Registry(candidate)).normalizer.fingerprint,
      f.service.normalizer.fingerprint,
    );
  });
}
