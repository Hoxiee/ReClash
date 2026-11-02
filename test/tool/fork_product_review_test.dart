import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/fork/model.dart';
import '../../tool/src/fork/product_review.dart';
import '../../tool/src/fork/report.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  late String source;

  setUp(() {
    f = ForkFixture();
    f.write(
      '.fork/product.yaml',
      jsonEncode({
        'v': 1,
        'identity': {
          'empty-states': {
            'preserve': 'Retain the selected empty-state presentation.',
            'why': 'Fixture product preference, not real approval.',
            'watch': ['lib/code.dart'],
          },
        },
        'surfaces': {
          'presentation': ['lib/**'],
        },
      }),
    );
    f.commit('test: declare product review policy');
    f.bootstrap();
    source = f.rewritten(
      code: "import 'package:fl_clash/a.dart';\nconst upstream = 2;\n",
    );
  });
  tearDown(() => f.dispose());

  Map<String, dynamic> draft() => f.service.reviewSource(source);

  List<Map<String, dynamic>> cards(Map<String, dynamic> review) =>
      (review['cards'] as List).cast<Map<String, dynamic>>();

  void decide(
    Map<String, dynamic> review, {
    String impact = 'product',
    String decision = 'keep',
    String approval = 'fixture maintainer decision 1',
  }) {
    for (final card in cards(review)) {
      card.addAll({
        'impact': impact,
        'current': 'The current fixture keeps its selected presentation.',
        'incoming': 'The incoming fixture changes the implementation.',
        'expected': 'The candidate retains the selected presentation.',
        'checklist': [
          'Compare the empty state and its replay on the captured versions.',
        ],
        'recommendation':
            'Keep the chosen behavior and assess fixes separately.',
        'decision': decision,
        'reason': 'Preserve the fixture product preference.',
        'approval': approval,
        'evidence': [
          {'kind': 'code', 'reference': 'fixture three-way code comparison'},
        ],
      });
    }
  }

  void confirm(Map<String, dynamic> review, {bool visual = true}) {
    for (final card in cards(review)) {
      if (card['decision'] == 'pending') {
        decide({
          'cards': [card],
        });
      }
      card['visual'] = {
        'status': visual ? 'checked' : 'not-checked',
        'reason': '',
        'approval': visual ? 'fixture maintainer candidate visual verdict' : '',
      };
      card['outcome'] = {
        'status': 'confirmed',
        'evidence': [
          {'kind': 'code', 'reference': 'fixture candidate code comparison'},
          if (visual)
            {
              'kind': 'visual',
              'reference':
                  'fixture maintainer manual comparison of the candidate',
            },
        ],
      };
    }
  }

  String saveReview(Map<String, dynamic> review, [String name = 'review']) {
    final file = File(p.join(f.git.common, '$name.json'));
    file.writeAsStringSync(jsonEncode(review));
    return file.path;
  }

  void prepare([String id = 'product', Map<String, dynamic>? review]) {
    final plan = review ?? draft();
    if (review == null) decide(plan);
    f.service.prepare(id, productReview: saveReview(plan));
    f.finish(id);
  }

  Map<String, dynamic> result([String id = 'product']) {
    final review = f.service.reviewCandidate(id);
    confirm(review);
    return review;
  }

  Map<String, dynamic> verify(
    Map<String, dynamic> review, [
    String id = 'product',
  ]) => f.service.verify(
    id,
    reviews: ['unclassified'],
    productReview: saveReview(review, 'result'),
  );

  Matcher failsWith(String message) => throwsA(
    isA<ForkException>().having((e) => e.message, 'message', contains(message)),
  );

  List<String> blockers(
    Map<String, dynamic> review,
    Map<String, dynamic> expected, {
    bool result = false,
  }) =>
      (f.service.productReviews.assess(
                review,
                expected,
                result: result,
              )['blockers']
              as List)
          .cast<String>();

  test(
    'review is read-only and compares committed downstream, not caller WIP',
    () {
      f.write('lib/code.dart', 'uncommitted caller work\n');
      final refs = f.git.run(['show-ref']);
      final objects = f.git.run(['count-objects', '-v']);
      final dirty = f.git.dirty;
      final receipt = f.service.receiptFile('initial').readAsBytesSync();
      final review = draft();
      final row = (review['inventory'] as List).single as Map;
      expect(row['before'], isNot(row['downstream']));
      expect(row['upstream'], isNot(row['before']));
      expect(row['rawPaths'], ['lib/code.dart']);
      expect(row['identity'], ['empty-states']);
      expect(
        (row['downstream'] as Map)['oid'],
        f.git.entries('dev').singleWhere((e) => e.path == 'lib/code.dart').oid,
      );
      expect(f.git.run(['show-ref']), refs);
      expect(f.git.run(['count-objects', '-v']), objects);
      expect(f.git.dirty, dirty);
      expect(f.service.receiptFile('initial').readAsBytesSync(), receipt);
    },
  );

  test('inherited behavior is reviewed without a downstream patch', () {
    f.write('lib/code.dart', f.git.read('vendor/flclash', 'lib/code.dart'));
    f.commit('test: retain inherited behavior unchanged');
    final row = (draft()['inventory'] as List).single as Map;
    expect(row['before'], row['downstream']);
    expect(row['upstreamChanged'], isTrue);
    expect((draft()['cards'] as List).single['impact'], 'product');
  });

  test('new unclassified paths are included outside all known watches', () {
    source = f.rewritten(files: {'unknown/presentation.txt': 'new surface\n'});
    final review = draft();
    expect(
      (review['inventory'] as List).single['path'],
      'unknown/presentation.txt',
    );
    expect(cards(review).single['impact'], 'unassessed');
    expect(blockers(review, draft()), contains(contains('unassessed')));
  });

  test('missing or untouched reviews cannot create release candidates', () {
    final refs = f.git.run(['show-ref']);
    expect(
      () => f.service.prepare('missing', source: source),
      failsWith('review is missing'),
    );
    expect(
      () => f.service.prepare(
        'blank',
        source: source,
        productReview: saveReview(draft()),
      ),
      failsWith('unresolved'),
    );
    expect(f.git.run(['show-ref']), refs);
    expect(f.service.receiptFile('missing').parent.existsSync(), isFalse);
    expect(f.service.receiptFile('blank').parent.existsSync(), isFalse);
  });

  test('configured preparation does not fetch before a source is reviewed', () {
    expect(() => f.service.prepare('no-fetch'), failsWith('review --source'));
    expect(f.git.exists('refs/reclash/upstream/no-fetch'), isFalse);
  });

  test(
    'planning requires comparison, recommendation and real decision reference',
    () {
      final review = draft();
      decide(review, approval: '');
      cards(review).single['evidence'] = <Object>[];
      final gaps = blockers(review, draft());
      expect(gaps, contains(contains('maintainer decision reference')));
      expect(gaps, contains(contains('comparison evidence')));
      cards(review).single['recommendation'] = '';
      cards(review).single['expected'] = '';
      cards(review).single['checklist'] = <String>[];
      final incomplete = blockers(review, draft());
      expect(incomplete, contains(contains('recommendation is missing')));
      expect(incomplete, contains(contains('expected is missing')));
      expect(incomplete, contains(contains('checklist is missing')));
    },
  );

  test('coverage rejects omissions, duplicates and out-of-inventory paths', () {
    final expected = draft();
    final review = draft();
    decide(review);
    review['cards'] = <Object>[];
    expect(blockers(review, expected), contains(contains('does not cover')));
    final complete = draft();
    decide(complete);
    (cards(complete).single['paths'] as List).add('lib/code.dart');
    expect(blockers(complete, expected), contains(contains('reviewed twice')));
    (cards(complete).single['paths'] as List).add('unrelated.txt');
    expect(
      blockers(complete, expected),
      contains(contains('outside the review inventory')),
    );
  });

  test('source, development and policy changes stale a planning document', () {
    final review = draft();
    decide(review);
    final file = saveReview(review);
    final different = f.rewritten(files: {'lib/new.dart': 'new source\n'});
    expect(
      () => f.service.prepare(
        'source-moved',
        source: different,
        productReview: file,
      ),
      failsWith('stale'),
    );
    f.write('downstream.txt', 'later development\n');
    f.commit('test: advance development');
    expect(
      () => f.service.prepare('dev-moved', source: source, productReview: file),
      failsWith('stale'),
    );
    final fresh = draft();
    decide(fresh);
    final policy = File(p.join(f.directory.path, '.fork/product.yaml'));
    policy.writeAsStringSync('${policy.readAsStringSync()}\n');
    expect(
      () => f.service.prepare(
        'policy-moved',
        source: source,
        productReview: saveReview(fresh),
      ),
      failsWith('stale'),
    );
  });

  test('JSON object key order does not stale a review', () {
    final review = draft();
    decide(review);
    final inputs = review['inputs'] as Map<String, dynamic>;
    review['inputs'] = {
      for (final key in inputs.keys.toList().reversed) key: inputs[key],
    };
    expect(blockers(review, draft()), isEmpty);
  });

  test(
    'preparation uses the exact locally reviewed source and archives choices',
    () {
      final review = draft();
      decide(review);
      final expected = jsonDecode(jsonEncode(review));
      prepare('captured', review);
      final receipt = f.service.receipt('captured');
      expect(receipt['source'], source);
      expect(receipt['productReview'], expected);
      expect(receipt['productReviewDigest'], productReviewDigest(expected));
      expect(f.git.oid('refs/reclash/upstream/captured'), source);
    },
  );

  test('status exposes missing outcome review without writing receipts', () {
    prepare();
    final bytes = f.service.receiptFile('product').readAsBytesSync();
    final refs = f.git.run(['show-ref']);
    final status = MaintenanceReport(f.registry).status('product');
    expect(status['ready'], isFalse);
    expect((status['productReview'] as Map)['status'], 'missing');
    final pending = ((status['productReview'] as Map)['cards'] as List).single;
    expect(
      pending['expected'],
      'The candidate retains the selected presentation.',
    );
    expect(pending['checklist'], isNotEmpty);
    expect(pending['outcome'], 'pending');
    expect(status['blockers'], contains('Product result review is missing'));
    expect(f.service.receiptFile('product').readAsBytesSync(), bytes);
    expect(f.git.run(['show-ref']), refs);
    expect(
      () => f.service.verify('product', reviews: ['unclassified']),
      failsWith('result review is missing'),
    );
    expect(f.service.receipt('product'), isNot(contains('verified')));
  });

  test('a saved decision is not evidence that the candidate retained it', () {
    final plan = draft();
    decide(plan);
    (cards(plan).single['visual'] as Map)['status'] = 'checked';
    (cards(plan).single['visual'] as Map)['approval'] =
        'fixture maintainer upstream visual verdict';
    (cards(plan).single['evidence'] as List).add({
      'kind': 'visual',
      'reference': 'fixture upstream comparison before replay',
    });
    prepare('product', plan);
    final review = f.service.reviewCandidate('product');
    expect(cards(review).single['decision'], 'keep');
    expect((cards(review).single['visual'] as Map)['status'], 'not-checked');
    expect((cards(review).single['outcome'] as Map)['status'], 'pending');
    expect(() => verify(review), failsWith('outcome is not confirmed'));
  });

  test('visual evidence cannot replace the maintainer manual verdict', () {
    final plan = draft();
    decide(plan);
    (cards(plan).single['visual'] as Map)['status'] = 'checked';
    (cards(plan).single['evidence'] as List).add({
      'kind': 'visual',
      'reference': 'fixture preview without a maintainer verdict',
    });
    expect(
      () => prepare('manual', plan),
      failsWith('maintainer visual verdict'),
    );
    (cards(plan).single['visual'] as Map)['approval'] =
        'fixture maintainer upstream verdict';
    prepare('manual', plan);
    final review = result('manual');
    (cards(review).single['visual'] as Map)['approval'] = '';
    expect(
      () => verify(review, 'manual'),
      failsWith('maintainer visual verdict'),
    );
    (cards(review).single['visual'] as Map)['approval'] =
        'fixture manual verdict for ${review['candidate']}';
    verify(review, 'manual');
  });

  test('code evidence alone cannot claim that a visual comparison passed', () {
    prepare();
    final review = f.service.reviewCandidate('product');
    confirm(review, visual: false);
    expect(() => verify(review), failsWith('visual comparison is not checked'));
    (cards(review).single['visual'] as Map)['status'] = 'checked';
    expect(() => verify(review), failsWith('visual evidence is missing'));
  });

  test(
    'a visual waiver requires rationale and authority and stays a waiver',
    () {
      prepare();
      final review = f.service.reviewCandidate('product');
      confirm(review, visual: false);
      cards(review).single['visual'] = {
        'status': 'waived',
        'reason': '',
        'approval': '',
      };
      expect(() => verify(review), failsWith('visual exclusion'));
      cards(review).single['visual'] = {
        'status': 'waived',
        'reason': 'Fixture host unavailable.',
        'approval': 'fixture explicit visual waiver',
      };
      expect(verify(review)['status'], 'verified-with-waivers');
      final status = MaintenanceReport(f.registry).status('product');
      expect(
        (status['productReview'] as Map)['status'],
        'recorded-with-waivers',
      );
      expect(status['ready'], isTrue);
    },
  );

  test(
    'routine nonvisual work needs a documented exclusion, not forced screenshots',
    () {
      final review = draft();
      decide(review, impact: 'routine', approval: '');
      prepare('routine', review);
      final finalReview = f.service.reviewCandidate('routine');
      confirm(finalReview, visual: false);
      cards(finalReview).single['visual'] = {
        'status': 'not-applicable',
        'reason': 'Fixture comparison proves a nonvisual mechanical change.',
        'approval': '',
      };
      verify(finalReview, 'routine');
      expect(MaintenanceReport(f.registry).status('routine')['ready'], isTrue);
    },
  );

  test(
    'unwatched routine paths cannot claim unsupported visual evidence or waivers',
    () {
      source = f.rewritten(files: {'tooling.txt': 'nonvisual change\n'});
      final plan = draft();
      decide(plan, impact: 'routine', decision: 'adopt', approval: '');
      prepare('routine-proof', plan);
      final review = f.service.reviewCandidate('routine-proof');
      confirm(review, visual: false);
      (cards(review).single['visual'] as Map)['status'] = 'checked';
      expect(
        () => verify(review, 'routine-proof'),
        failsWith('visual evidence is missing'),
      );
      cards(review).single['visual'] = {
        'status': 'waived',
        'reason':
            'A claimed waiver outside presentation watches still needs authority.',
        'approval': '',
      };
      expect(
        () => verify(review, 'routine-proof'),
        failsWith('visual exclusion'),
      );
      cards(review).single['visual'] = {
        'status': 'not-applicable',
        'reason': 'The fixture comparison has no visual effect.',
        'approval': '',
      };
      verify(review, 'routine-proof');
    },
  );

  test('deferred investigation can prepare but cannot verify or accept', () {
    final review = draft();
    decide(review, impact: 'uncertain', decision: 'defer');
    prepare('investigate', review);
    final finalReview = result('investigate');
    expect(() => verify(finalReview, 'investigate'), failsWith('unresolved'));
    expect(
      () => f.service.accept('investigate'),
      throwsA(isA<ForkException>()),
    );
    decide(finalReview, approval: 'fixture follow-up decision 2');
    verify(finalReview, 'investigate');
  });

  test('candidate adaptation introduces additional review coverage', () {
    prepare();
    final oldReview = result();
    final target = f.candidate('product');
    File(
      p.join(target.root, 'lib/surprise.dart'),
    ).writeAsStringSync('new interaction\n');
    f.finish('product');
    final fresh = f.service.reviewCandidate('product');
    expect(
      (fresh['inventory'] as List).map((row) => row['path']),
      contains('lib/surprise.dart'),
    );
    expect(
      cards(fresh).singleWhere(
        (card) => (card['paths'] as List).contains('lib/surprise.dart'),
      )['decision'],
      'pending',
    );
    expect(() => verify(oldReview), failsWith('stale'));
    confirm(fresh);
    verify(fresh);
  });

  test(
    'changed choices require a new reference even after regrouping cards',
    () {
      prepare();
      final review = result();
      cards(review).single['decision'] = 'adapt';
      cards(review).single['id'] = 'regrouped';
      expect(() => verify(review), failsWith('new maintainer reference'));
      cards(review).single['approval'] =
          'fixture revised maintainer decision 2';
      verify(review);
      cards(review).single['expected'] = 'A newly selected product outcome.';
      expect(() => verify(review), failsWith('new maintainer reference'));
      cards(review).single['approval'] =
          'fixture revised maintainer decision 3';
      verify(review);
    },
  );

  test(
    'verified product evidence is bound to acceptance and visible in status',
    () {
      prepare();
      final review = result();
      verify(review);
      final report = MaintenanceReport(f.registry).status('product');
      expect(report['ready'], isTrue);
      expect((report['productReview'] as Map)['status'], 'recorded');
      final r = f.service.receipt('product');
      expect(
        (r['verified'] as Map)['productReview'],
        productReviewDigest(review),
      );
      final recorded = r['productReviewResult'] as Map<String, dynamic>;
      cards(recorded).single['recommendation'] = 'changed after verification';
      f.service.save('product', r);
      expect(
        MaintenanceReport(f.registry).status('product')['verification'],
        'missing-or-stale',
      );
      expect(
        () => f.service.accept('product'),
        failsWith('product review changed'),
      );
    },
  );

  test('modified or removed planning decisions cannot reuse verification', () {
    prepare();
    verify(result());
    final r = f.service.receipt('product');
    r.remove('productReview');
    f.service.save('product', r);
    final status = MaintenanceReport(f.registry).status('product');
    expect(status['ready'], isFalse);
    expect(status['blockers'], contains(contains('Pre-replay product review')));
    expect(
      () => f.service.accept('product'),
      failsWith('Pre-replay product review'),
    );
  });

  test(
    'complete reviews allow local acceptance without changing release policy',
    () {
      prepare();
      verify(result());
      final before = f.git.oid('dev');
      expect(f.service.accept('product')['status'], 'accepted');
      expect(f.git.oid('archive/dev-before-product'), before);
      expect(f.service.receipt('product'), contains('productReviewResult'));
      expect(
        f.git.firstParentAncestor(
          f.git.oid(f.service.productBaseRef),
          f.git.oid('dev'),
        ),
        isTrue,
      );
    },
  );

  test('history-only observations require no new product decision', () {
    expect(
      f.service.prepare('history', source: f.raw)['status'],
      'history-only',
    );
    expect(f.service.receiptFile('history').existsSync(), isFalse);
  });

  test('chained reviews bind predecessor identity and include its paths', () {
    final rules = f.branding['rules'] as List;
    (rules.single['replace'] as Map)['const upstream'] = 'const origin';
    f.metadata();
    f.commit('test: approve fixture recipe change');
    expect(() => draft(), failsWith('recipe migration first'));
    f.service.prepare(
      'recipe',
      source: f.raw,
      recipeMigration: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    f.finish('recipe');
    source = f.rewritten(files: {'lib/new.dart': 'new release\n'});
    final review = f.service.reviewSource(source, after: 'recipe');
    final inputs = review['inputs'] as Map;
    expect((inputs['after'] as Map)['id'], 'recipe');
    expect(inputs['downstream'], f.candidate('recipe').oid('HEAD'));
    final row = (review['inventory'] as List).singleWhere(
      (row) => row['path'] == 'lib/code.dart',
    );
    expect(row['predecessorChanged'], isTrue);
    decide(review);
    f.service.prepare(
      'chain-product',
      source: source,
      after: 'recipe',
      productReview: saveReview(review),
    );
    f.finish('chain-product');
    final finalReview = result('chain-product');
    f.service.verify(
      'chain-product',
      reviews: ['unclassified', 'normalization-policy'],
      productReview: saveReview(finalReview, 'chain-result'),
    );
    expect(
      MaintenanceReport(f.registry).status('chain-product')['ready'],
      isTrue,
    );
  });

  test('policy validation rejects unsafe paths and unknown profile keys', () {
    f.write(
      '.fork/product.yaml',
      '{"v":1,"identity":{},"surfaces":{"ui":["../outside"]}}',
    );
    expect(
      () => MaintenanceReport(f.registry).policy(),
      throwsA(isA<ForkException>()),
    );
    f.write(
      '.fork/product.yaml',
      '{"v":1,"identity":{},"surfaces":{},"approved":true}',
    );
    expect(
      () => MaintenanceReport(f.registry).policy(),
      failsWith('unknown keys'),
    );
  });

  test(
    'review CLI produces an editable draft without creating an observation',
    () {
      final refs = f.git.run(['show-ref']);
      final command = Process.runSync('dart', [
        'run',
        'tool/fork.dart',
        '--root',
        f.directory.path,
        '--json',
        'review',
        '--source',
        source,
      ], workingDirectory: Directory.current.path);
      expect(
        command.exitCode,
        0,
        reason: '${command.stdout}\n${command.stderr}',
      );
      final output = object(jsonDecode(command.stdout as String), 'CLI output');
      expect(output, contains('inventory'));
      expect((output['cards'] as List).single['decision'], 'pending');
      expect(f.git.run(['show-ref']), refs);
    },
  );
}
