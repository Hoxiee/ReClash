import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../../test/tool/fork_fixture.dart';
import '../../../tool/src/fork/model.dart';
import '../../../tool/src/fork/registry.dart';
import '../src/http.dart';
import '../src/repository.dart';

void main() {
  late ForkFixture fixture;
  late AtlasRepository repository;

  setUp(() {
    fixture = ForkFixture();
    repository = AtlasRepository(fixture.directory.path);
  });
  tearDown(() => fixture.dispose());

  test(
    'snapshot reads the canonical registry without changing refs or index',
    () {
      final refs = fixture.git.run(['show-ref']);
      final status = fixture.git.dirty;
      final index = File(
        p.join(fixture.directory.path, '.git/index'),
      ).readAsBytesSync();
      final snapshot = repository.snapshot();
      expect((snapshot['features'] as List).first['id'], 'feature.demo');
      expect(snapshot['checks'], contains('fixture'));
      expect(fixture.git.run(['show-ref']), refs);
      expect(fixture.git.dirty, status);
      expect(
        File(p.join(fixture.directory.path, '.git/index')).readAsBytesSync(),
        index,
      );
    },
  );

  test(
    'working impact uses canonical mappings and includes unknown new files',
    () {
      fixture.write('lib/new.dart', 'const added = true;\n');
      fixture.write('unknown.txt', 'unclassified');
      final result = repository.impact({'mode': 'working'});
      expect(
        result['impact'],
        fixture.registry.impact(fixture.git.changedPaths),
      );
      expect(
        (result['changes'] as List).map((item) => item['path']),
        containsAll(['lib/new.dart', 'unknown.txt']),
      );
      expect(
        (result['impact'] as Map)['unclassified'],
        contains('unknown.txt'),
      );
    },
  );

  test('staged impact never substitutes invalid unstaged contracts', () {
    fixture.feature['must'] = {'behavior': 'Staged invariant.'};
    fixture.metadata();
    fixture.git.run(['add', '.fork']);
    fixture.write('.fork/features/feature.demo.yaml', '{broken: true}');
    final result = repository.impact({'mode': 'staged'});
    final staged = Registry(fixture.git, staged: true);
    expect(result['impact'], staged.impact(fixture.git.stagedPaths));
    expect((result['features'] as List).first['must'], {
      'behavior': 'Staged invariant.',
    });
  });

  test('single-path inspection is not reported as a real edit', () {
    final result = repository.impact({
      'mode': 'paths',
      'path': 'lib/code.dart',
    });
    expect((result['changes'] as List).first['status'], 'inspect');
    expect((result['impact'] as Map)['features'], contains('feature.demo'));
  });

  test(
    'file previews preserve literal paths and never follow parent symlinks',
    () {
      fixture.write('lib/[a].dart', 'literal\n');
      fixture.write('lib/a.dart', 'other\n');
      fixture.commit('test: literal file names');
      final result = repository.file({'mode': 'paths', 'path': 'lib/[a].dart'});
      expect((result['before'] as Map)['content'], 'literal\n');
      expect((result['after'] as Map)['content'], 'literal\n');
      expect(result['patch'], isEmpty);
      if (!Platform.isWindows) {
        Link(
          p.join(fixture.directory.path, 'outside'),
        ).createSync(Directory.systemTemp.path);
        expect(
          () => repository.file({'mode': 'paths', 'path': 'outside/anything'}),
          throwsA(isA<ForkException>()),
        );
      }
    },
  );

  test('unsafe paths and revision options are refused before Git reads', () {
    for (final path in ['../secret', '.git/config', '/etc/passwd']) {
      expect(
        () => repository.file({'mode': 'paths', 'path': path}),
        throwsA(isA<ForkException>()),
      );
    }
    expect(
      () => repository.impact({'mode': 'refs', 'from': '--help', 'to': 'HEAD'}),
      throwsA(isA<ForkException>()),
    );
  });

  test('snapshot shows separate parentless product and vendor histories', () {
    fixture.bootstrap();
    final snapshot = repository.snapshot();
    final history = snapshot['histories'] as Map;
    expect((history['productBase'] as Map)['parents'], isEmpty);
    expect(
      (history['productBase'] as Map)['tree'],
      (history['vendor'] as List).first['tree'],
    );
    expect(fixture.git.ancestor('vendor/flclash', 'dev'), isFalse);
  });

  test('normalizer drift is visible without changing accepted refs', () {
    fixture.bootstrap();
    fixture.branding['preserve'] = ['retained'];
    fixture.metadata();
    final vendor = fixture.git.oid('vendor/flclash');
    final snapshot = repository.snapshot();
    expect(
      (snapshot['notices'] as List).any((item) => item['id'] == 'normalizer'),
      isTrue,
    );
    expect(fixture.git.oid('vendor/flclash'), vendor);
  });

  test('receipts and waived results remain historical evidence', () {
    fixture.bootstrap();
    final receipt = fixture.service.receipt('initial');
    (receipt['verified'] as Map)['checks'] = {
      'fixture': {'status': 'waived', 'authority': 'Explicit test waiver'},
    };
    (receipt['verified'] as Map)['waivers'] = ['fixture'];
    fixture.service.save('initial', receipt);
    final detail = repository.observation('initial');
    expect(detail['historical'], isTrue);
    expect((detail['checks'] as Map)['fixture']['status'], 'waived');
    expect(
      (detail['comparisons'] as List).any((item) => item['lens'] == 'product'),
      isTrue,
    );
  });

  test(
    'the freshness stamp detects edits, staged contents and policy changes',
    () {
      final before = repository.stamp()['fingerprint'];
      fixture.write('lib/code.dart', 'new content');
      final working = repository.stamp()['fingerprint'];
      expect(working, isNot(before));
      fixture.git.run(['add', 'lib/code.dart']);
      expect(repository.stamp()['fingerprint'], isNot(working));
      final policy = repository.stamp()['fingerprint'];
      fixture.feature['why'] = 'New rationale.';
      fixture.metadata();
      expect(repository.stamp()['fingerprint'], isNot(policy));
    },
  );

  test('binary, deleted, large and truncated UTF-8 previews stay bounded', () {
    fixture.write('lib/deleted.dart', 'removed\n');
    fixture.commit('test: preview inputs');
    File(p.join(fixture.directory.path, 'lib/deleted.dart')).deleteSync();
    File(
      p.join(fixture.directory.path, 'lib/binary.bin'),
    ).writeAsBytesSync([0, 1, 2]);
    fixture.write(
      'lib/large.txt',
      '${'a' * (atlasPreviewLimit - 1)}ёremaining',
    );
    final binary = repository.file({'mode': 'paths', 'path': 'lib/binary.bin'});
    expect((binary['after'] as Map)['kind'], 'binary');
    final deleted = repository.file({
      'mode': 'working',
      'path': 'lib/deleted.dart',
    });
    expect((deleted['after'] as Map)['kind'], 'missing');
    expect(deleted['patch'], contains('-removed'));
    final large = repository.file({'mode': 'paths', 'path': 'lib/large.txt'});
    expect((large['after'] as Map)['kind'], 'text');
    expect((large['after'] as Map)['truncated'], isTrue);
    expect(
      utf8.encode((large['after'] as Map)['content'] as String).length,
      lessThanOrEqualTo(atlasPreviewLimit),
    );
    expect(large['patch'], contains('exceeds the preview limit'));
  });

  test('leaf symlinks are displayed, not followed', () {
    if (Platform.isWindows) return;
    Link(p.join(fixture.directory.path, 'lib/link')).createSync('/etc/passwd');
    final result = repository.file({'mode': 'paths', 'path': 'lib/link'});
    expect((result['after'] as Map)['kind'], 'symlink');
    expect((result['after'] as Map)['content'], '/etc/passwd');
  });

  test('commit comparisons resolve endpoints and preserve pinned previews', () {
    final from = fixture.git.oid('HEAD');
    fixture.write('lib/code.dart', 'next\n');
    final to = fixture.commit('test: comparison endpoint');
    final result = repository.impact({
      'mode': 'refs',
      'from': from,
      'to': 'HEAD',
    });
    expect(result['selection'], {'mode': 'refs', 'from': from, 'to': to});
    fixture.write('lib/code.dart', 'later\n');
    fixture.commit('test: moved ref');
    final file = repository.file({
      'mode': 'refs',
      'from': from,
      'to': to,
      'path': 'lib/code.dart',
    });
    expect((file['after'] as Map)['content'], 'next\n');
  });

  test(
    'malformed receipts and missing receipts are never treated as verified',
    () {
      final directory = Directory(p.join(fixture.git.stateRoot, 'broken'))
        ..createSync(recursive: true);
      File(
        p.join(directory.path, 'receipt.json'),
      ).writeAsStringSync('{invalid');
      Directory(p.join(fixture.git.stateRoot, 'empty')).createSync();
      final runs = (repository.observations()['runs'] as List).cast<Map>();
      expect(
        runs.singleWhere((run) => run['id'] == 'broken')['status'],
        'unavailable',
      );
      expect(
        runs.singleWhere((run) => run['id'] == 'empty')['status'],
        'missing-receipt',
      );
    },
  );

  test(
    'receipts belonging to other checkouts cannot supply comparison paths',
    () {
      final directory = Directory(p.join(fixture.git.stateRoot, 'foreign'))
        ..createSync(recursive: true);
      File(p.join(directory.path, 'receipt.json')).writeAsStringSync(
        jsonEncode({'id': 'foreign', 'root': Directory.systemTemp.path}),
      );
      expect(
        () => repository.observation('foreign'),
        throwsA(isA<ForkException>()),
      );
    },
  );

  test('dirty verified candidates are stale, never current passes', () {
    final audit = digest(fixture.service.inspect(fixture.raw));
    fixture.service.prepare(
      'next',
      source: fixture.raw,
      bootstrap: true,
      audit: audit,
    );
    fixture.finish('next');
    fixture.service.verify(
      'next',
      reviews: ['bootstrap-audit', 'unclassified'],
    );
    expect(repository.observation('next')['status'], 'verified');
    final target = fixture.candidate('next');
    File(p.join(target.root, 'unfinished.txt')).writeAsStringSync('pending');
    final result = repository.observation('next');
    expect(result['status'], 'stale');
    expect(
      result['staleReasons'],
      contains('Candidate checkout has unfinished work.'),
    );
  });

  test('recorded logs are bounded and absent logs remain absent', () {
    final directory = Directory(p.join(fixture.git.stateRoot, 'logged'))
      ..createSync(recursive: true);
    File(p.join(directory.path, 'receipt.json')).writeAsStringSync(
      jsonEncode({
        'id': 'logged',
        'root': fixture.directory.path,
        'checks': {
          'fixture': {'exit': 0},
        },
      }),
    );
    expect(
      () => repository.log('logged', 'fixture'),
      throwsA(isA<ForkException>()),
    );
    File(
      p.join(directory.path, 'fixture.log'),
    ).writeAsStringSync('x' * (atlasLogLimit + 20));
    final result = repository.log('logged', 'fixture');
    expect(result['truncated'], isTrue);
    expect((result['content'] as String).length, atlasLogLimit);
  });

  group('loopback HTTP boundary', () {
    late AtlasServer server;
    late HttpClient client;
    setUp(() async {
      server = AtlasServer(
        root: fixture.directory.path,
        siteRoot: p.join(Directory.current.path, 'site/fork'),
      );
      await server.start(port: 0);
      client = HttpClient();
    });
    tearDown(() async {
      client.close(force: true);
      await server.close();
    });

    Future<(int, String)> request(
      String path, {
      String method = 'GET',
      bool authenticated = true,
      Map<String, String> headers = const {},
    }) async {
      final request = await client.openUrl(
        method,
        Uri.parse('http://127.0.0.1:${server.port}$path'),
      );
      if (authenticated) request.headers.set('X-Atlas-Token', server.token);
      headers.forEach(request.headers.set);
      final response = await request.close();
      return (
        response.statusCode,
        await response.transform(utf8.decoder).join(),
      );
    }

    test(
      'page receives a session token but repository API does not allow anonymous reads',
      () async {
        final page = await request('/fork/', authenticated: false);
        expect(page.$1, 200);
        expect(page.$2, contains(server.token));
        expect(page.$2, isNot(contains('__ATLAS_TOKEN__')));
        expect((await request('/api/snapshot', authenticated: false)).$1, 403);
        final snapshot = await request('/api/snapshot');
        expect(snapshot.$1, 200);
        expect(jsonDecode(snapshot.$2), contains('features'));
      },
    );

    test(
      'cross-origin, rebound host and all write verbs are refused',
      () async {
        expect(
          (await request(
            '/api/snapshot',
            headers: {'Origin': 'https://elsewhere.invalid'},
          )).$1,
          403,
        );
        expect(
          (await request(
            '/api/snapshot',
            headers: {'Host': 'elsewhere.invalid'},
          )).$1,
          403,
        );
        expect((await request('/api/snapshot', method: 'POST')).$1, 405);
        expect((await request('/api/snapshot', method: 'DELETE')).$1, 405);
      },
    );

    test(
      'only explicit browser assets are served, never source or arbitrary logs',
      () async {
        expect((await request('/fork/src/repository.dart')).$1, 404);
        expect((await request('/fork/test/server_test.dart')).$1, 404);
        expect(
          (await request('/api/log?id=initial&check=../../config')).$1,
          400,
        );
        expect((await request('/fork/assets/model.mjs')).$1, 200);
        expect((await request('/fork/assets/glyph.svg')).$1, 200);
      },
    );
  });
}
