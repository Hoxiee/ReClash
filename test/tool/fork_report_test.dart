import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/fork/model.dart';
import '../../tool/src/fork/report.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  setUp(() => f = ForkFixture());
  tearDown(() => f.dispose());

  test(
    'impact contains actionable contracts without claiming verification',
    () {
      final report = MaintenanceReport(
        f.registry,
      ).paths(['lib/code.dart', 'unknown.txt']);
      expect(report['readiness'], 'impact-only-not-verified');
      expect(report['unclassified'], contains('unknown.txt'));
      expect((report['contracts'] as Map)['feature.demo'], contains('must'));
      expect((report['checksDetail'] as List).single['status'], 'not-run');
    },
  );

  test('metadata rejects unknown contracts, evidence and checks', () {
    f.write('.fork/maintenance.yaml', '{"v":1,"features":{"missing":{}}}');
    expect(
      () => MaintenanceReport(f.registry).policy(),
      throwsA(isA<ForkException>()),
    );
    f.write(
      '.fork/maintenance.yaml',
      '{"v":1,"features":{"feature.demo":{"evidence":{"missing":["behavioral"]}}}}',
    );
    expect(
      () => MaintenanceReport(f.registry).policy(),
      throwsA(isA<ForkException>()),
    );
    f.write(
      '.fork/maintenance.yaml',
      '{"v":1,"paths":{"lib/**":{"kind":"generated","checks":["missing"],"reason":"fixture"}}}',
    );
    expect(
      () => MaintenanceReport(f.registry).policy(),
      throwsA(isA<ForkException>()),
    );
  });

  test('status reports dirty candidate and preserves receipts and refs', () {
    f.service.prepare(
      'status',
      source: f.raw,
      bootstrap: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    f.finish('status');
    final receipt = f.service.receiptFile('status').readAsBytesSync();
    final refs = f.git.run(['show-ref']);
    File(
      p.join(f.candidate('status').root, 'lib/code.dart'),
    ).writeAsStringSync('dirty');
    final report = MaintenanceReport(f.registry).status('status');
    expect(report['ready'], isFalse);
    expect(report['blockers'], contains('Candidate has uncommitted changes'));
    expect(report['verification'], 'missing-or-stale');
    expect(f.service.receiptFile('status').readAsBytesSync(), receipt);
    expect(f.git.run(['show-ref']), refs);
  });

  test(
    'current verification is reported separately from acceptance authority',
    () {
      f.service.prepare(
        'verified',
        source: f.raw,
        bootstrap: true,
        audit: digest(f.service.inspect(f.raw)),
      );
      f.finish('verified');
      f.service.verify(
        'verified',
        reviews: ['bootstrap-audit', 'unclassified'],
      );
      final report = MaintenanceReport(f.registry).status('verified');
      expect(report['verification'], 'current');
      expect(report['ready'], isTrue);
      expect(report['next'], contains('explicit user authority'));
      final target = f.candidate('verified');
      File(p.join(target.root, 'lib/code.dart')).writeAsStringSync('later');
      expect(
        MaintenanceReport(f.registry).status('verified')['ready'],
        isFalse,
      );
    },
  );

  test('platform plan exposes unavailable hosts without pretending a pass', () {
    f.config['checks'] = Map<String, dynamic>.from(f.config['checks'] as Map);
    f.config['checks']['other-host'] = {
      'argv': ['git', 'status'],
      'host': Platform.isWindows ? 'linux' : 'windows',
    };
    (f.config['full'] as List).add('other-host');
    f.metadata();
    final checks =
        MaintenanceReport(f.registry).paths(['lib/code.dart'])['checksDetail']
            as List;
    final check = checks.singleWhere((entry) => entry['name'] == 'other-host');
    expect(check['hostAvailable'], isFalse);
    expect(check['status'], 'not-run');
  });

  test(
    'release comparison detects working-copy changes without updating refs',
    () {
      f.write(
        '.fork/maintenance.yaml',
        r'{"v":1,"release":{"version":{"path":"pubspec.yaml","pattern":"^version:.*$"}}}',
      );
      f.commit('chore: declare release identity');
      f.service.prepare(
        'release',
        source: f.raw,
        bootstrap: true,
        audit: digest(f.service.inspect(f.raw)),
      );
      f.finish('release');
      final report = MaintenanceReport(f.registry);
      expect(
        (report.status('release')['releaseIdentity'] as List).single['matches'],
        isTrue,
      );
      File(
        p.join(f.candidate('release').root, 'pubspec.yaml'),
      ).writeAsStringSync('version: 99.0.0\n');
      expect(
        (report.status('release')['releaseIdentity'] as List).single['matches'],
        isFalse,
      );
    },
  );
  test('overlap compares explicit upstream and downstream ranges', () {
    final base = f.git.oid('HEAD');
    f.write('lib/code.dart', 'changed\n');
    final tip = f.commit('feat: fixture change');
    final report = MaintenanceReport(f.registry).paths(
      ['lib/code.dart', 'unknown.txt'],
      from: base,
      to: tip,
      downstreamFrom: base,
      downstreamTo: tip,
    );
    expect((report['overlap'] as Map)['paths'], ['lib/code.dart']);
    expect((report['paths'] as List).first['downstreamTouched'], isTrue);
    expect(renderMaintenanceMarkdown(report), contains('Path overlap'));
  });

  test('missing candidate is reported without mutating the observation', () {
    f.service.prepare(
      'missing',
      source: f.raw,
      bootstrap: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    final receipt = f.service.receipt('missing');
    receipt['worktree'] = p.join(f.directory.path, 'absent');
    f.service.save('missing', receipt);
    final report = MaintenanceReport(f.registry).status('missing');
    expect(report['ready'], isFalse);
    expect(report['blockers'], contains('Candidate worktree missing'));
  });

  test('verification bound to a different product base is stale', () {
    f.service.prepare(
      'stale',
      source: f.raw,
      bootstrap: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    f.finish('stale');
    f.service.verify('stale', reviews: ['bootstrap-audit', 'unclassified']);
    final receipt = f.service.receipt('stale');
    (receipt['verified'] as Map)['productBase'] = f.raw;
    f.service.save('stale', receipt);
    expect(
      MaintenanceReport(f.registry).status('stale')['verification'],
      'missing-or-stale',
    );
  });

  test('lineage rejects cycles instead of looping', () {
    f.service.prepare(
      'cycle',
      source: f.raw,
      bootstrap: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    final receipt = f.service.receipt('cycle');
    receipt['after'] = {'id': 'cycle'};
    f.service.save('cycle', receipt);
    expect(
      () => MaintenanceReport(f.registry).lineage('cycle'),
      throwsA(isA<ForkException>()),
    );
  });
  test('history-only observation has no acceptable candidate', () {
    f.bootstrap();
    final result = f.service.prepare('history', source: f.raw);
    expect(result['status'], 'history-only');
    final report = MaintenanceReport(f.registry).status('history');
    expect(report['status'], 'history-only');
    expect(report['ready'], isFalse);
    expect(f.service.receiptFile('history').existsSync(), isFalse);
  });

  test('chained preparation reports lineage and requires policy review', () {
    f.bootstrap();
    f.branding['preserve'] = [
      'https://github.com/chen08209/FlClash',
      'attribution',
    ];
    f.metadata();
    f.commit('chore: approve fixture recipe');
    f.service.prepare(
      'recipe',
      source: f.raw,
      recipeMigration: true,
      audit: digest(f.service.inspect(f.raw)),
    );
    f.finish('recipe');
    final source = f.rewritten(files: {'lib/new.dart': 'const next = 2;\n'});
    f.service.prepare('child', source: source, after: 'recipe');
    final report = MaintenanceReport(f.registry);
    expect(
      report.status('child')['blockers'],
      contains('Verification missing or stale'),
    );
    expect(
      (report.lineage('child')['observations'] as List).map((r) => r['id']),
      ['child', 'recipe'],
    );
  });
}
