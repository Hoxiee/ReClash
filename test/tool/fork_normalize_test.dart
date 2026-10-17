import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../tool/src/fork/model.dart';
import '../../tool/src/fork/normalize.dart';
import 'fork_fixture.dart';

void main() {
  late ForkFixture f;
  setUp(() => f = ForkFixture());
  tearDown(() => f.dispose());

  test(
    'repository recipe is idempotent and retains attribution and source URLs',
    () {
      final recipe = File('.fork/branding.yaml').readAsStringSync();
      const license = 'Copyright (c) 2025 FlClash\n';
      const readme =
          'Derived from FlClash; https://github.com/chen08209/FlClash\n';
      f.write('plugins/window/LICENSE', license);
      f.write('plugins/window/README.md', readme);
      f.write(
        'plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/Plugin.kt',
        'package com.follow.clash\n',
      );
      f.write('site/index.html', 'https://chen08209.github.io/FlClash\n');
      const upstreamArb = '{"example":"FlClash source text"}\n';
      const upstreamGenerated = 'class AppLocalizations {}\n';
      f.write('arb/intl_en.arb', upstreamArb);
      f.write('lib/l10n/l10n.dart', upstreamGenerated);
      f.write('lib/l10n/intl/messages_en.dart', upstreamGenerated);
      f.commit('test: actual branding boundary');
      final n = Normalizer(f.git, recipe);
      final tree = n.apply('HEAD').write();
      expect(n.apply(tree).write(), tree);
      expect(f.git.read(tree, 'plugins/window/LICENSE'), license);
      expect(f.git.read(tree, 'plugins/window/README.md'), readme);
      expect(
        f.git.read(tree, 'site/index.html'),
        'https://chen08209.github.io/FlClash\n',
      );
      expect(f.git.read(tree, 'arb_upstream/intl_en.arb'), upstreamArb);
      expect(f.git.read(tree, 'upstream_l10n/l10n.dart'), upstreamGenerated);
      expect(
        f.git.read(tree, 'upstream_l10n/intl/messages_en.dart'),
        upstreamGenerated,
      );
      expect(
        f.git.entries(tree).any((entry) => entry.path == 'arb/intl_en.arb'),
        isFalse,
      );
      expect(
        f.git.entries(tree).any((entry) => entry.path == 'lib/l10n/l10n.dart'),
        isFalse,
      );
      expect(
        f.git.read(
          tree,
          'plugins/wifi_ssid/android/src/main/kotlin/com/reclash/Plugin.kt',
        ),
        'package com.reclash\n',
      );
    },
  );
  test('chained recipes are rejected before they can break idempotence', () {
    f.branding['paths'] = {'lib': 'middle', 'middle': 'final'};
    expect(
      () => Normalizer(f.git, jsonEncode(f.branding)),
      throwsA(isA<ForkException>()),
    );
    f.branding['paths'] = <String, String>{};
    f.branding['rules'] = [
      {
        'paths': ['**/*.dart'],
        'replace': {'middle': 'final', 'initial': 'middle'},
      },
    ];
    expect(
      () => Normalizer(f.git, jsonEncode(f.branding)),
      throwsA(isA<ForkException>()),
    );
  });

  test(
    'endpoint reports retain deletion, addition, executable and binary changes',
    () {
      final old = f.git.oid('HEAD');
      File(p.join(f.directory.path, 'lib/code.dart')).deleteSync();
      File(p.join(f.directory.path, 'lib/new.dart')).writeAsBytesSync([0, 255]);
      f.write('tool.sh', 'echo local\n');
      f.git.run(['add', '--all']);
      f.git.run(['update-index', '--chmod=+x', 'tool.sh']);
      f.git.run(['commit', '-q', '-m', 'test: endpoint modes']);
      final changes = {
        for (final e in f.git.changes(old, 'HEAD')) e['path']: e,
      };
      expect(changes['lib/code.dart']!['status'], 'delete');
      expect(changes['lib/new.dart']!['kind'], 'binary');
      expect((changes['tool.sh']!['new'] as Map)['mode'], '100755');
      final tree = Normalizer(
        f.git,
        jsonEncode(f.branding),
      ).apply('HEAD').write();
      expect(
        f.git.entries(tree).singleWhere((e) => e.path == 'tool.sh').mode,
        '100755',
      );
    },
  );

  test(
    'normalization is deterministic, idempotent and leaves caller untouched',
    () {
      final n = Normalizer(f.git, jsonEncode(f.branding));
      final head = f.git.oid('HEAD');
      final status = f.git.dirty;
      final a = n.apply(f.raw).write();
      expect(n.apply(f.raw).write(), a);
      expect(n.apply(a).write(), a);
      expect(f.git.oid('HEAD'), head);
      expect(f.git.dirty, status);
      expect(f.git.read(a, 'lib/code.dart'), contains('package:reclash/'));
    },
  );
  test(
    'read-only preview writes no refs and computes residual downstream delta',
    () {
      final before = f.git.run(['show-ref']);
      final preview = Normalizer(f.git, jsonEncode(f.branding)).apply(f.raw);
      expect(preview.residual('HEAD'), contains('lib/code.dart'));
      expect(f.git.run(['show-ref']), before);
      expect(preview.changed, contains('pubspec.yaml'));
    },
  );
  test('path normalization retains upstream gitlink SHA and source URL', () {
    f.write(
      '.gitmodules',
      '[submodule "core/Clash.Meta"]\n path = core/Clash.Meta\n url = https://example.com/upstream.git\n',
    );
    f.git.run(['add', '.gitmodules']);
    f.git.run([
      'update-index',
      '--add',
      '--cacheinfo',
      '160000,${f.raw},core/Clash.Meta',
    ]);
    f.git.run(['commit', '-q', '-m', 'chore: source gitlink']);
    f.branding['paths'] = {'core/Clash.Meta': 'core/mihomo'};
    final tree = Normalizer(
      f.git,
      jsonEncode(f.branding),
    ).apply('HEAD').write();
    final link = f.git
        .entries(tree)
        .singleWhere((e) => e.path == 'core/mihomo');
    expect(link.oid, f.raw);
    expect(
      f.git.read(tree, '.gitmodules'),
      contains('https://example.com/upstream.git'),
    );
  });
  test('symlinks are not followed and binary blobs remain exact', () {
    if (Platform.isWindows) return;
    Link(p.join(f.directory.path, 'lib/link.dart')).createSync('../outside');
    final file = File(p.join(f.directory.path, 'lib/binary.dart'))
      ..writeAsBytesSync([0, 255, 1]);
    f.commit('chore: special blobs');
    final before = {for (final e in f.git.entries('HEAD')) e.path: e.oid};
    final normalized = Normalizer(f.git, jsonEncode(f.branding)).apply('HEAD');
    expect(
      normalized.entries.singleWhere((e) => e.path == 'lib/link.dart').oid,
      before['lib/link.dart'],
    );
    expect(
      normalized.entries.singleWhere((e) => e.path == 'lib/binary.dart').oid,
      before['lib/binary.dart'],
    );
    expect(file.readAsBytesSync(), [0, 255, 1]);
  });
  test(
    'file and directory target collisions fail during read-only preview',
    () {
      f.write('folder/nested.dart', 'nested');
      f.write('folder-adjacent.dart', 'adjacent');
      f.commit('test: directory collision');
      f.branding['paths'] = {'lib/code.dart': 'folder'};
      expect(
        () => Normalizer(f.git, jsonEncode(f.branding)).apply('HEAD'),
        throwsA(isA<ForkException>()),
      );
    },
  );
  test('target collisions fail rather than dropping a file', () {
    f.write('lib/other.dart', 'other');
    f.commit('chore: collision');
    f.branding['paths'] = {'lib/code.dart': 'lib/other.dart'};
    expect(
      () => Normalizer(f.git, jsonEncode(f.branding)).apply('HEAD'),
      throwsA(isA<ForkException>()),
    );
  });
}
