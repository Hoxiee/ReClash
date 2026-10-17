import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../tool/src/fork/git.dart';
import '../../tool/src/fork/model.dart';
import '../../tool/src/fork/registry.dart';
import '../../tool/src/fork/sync.dart';

class ForkFixture {
  ForkFixture() {
    directory = Directory.systemTemp.createTempSync('reclash-vendor-test-');
    git = ForkGit(directory.path);
    git.run(['init', '-q', '--initial-branch=dev']);
    git.run(['config', 'user.name', 'Vendor test']);
    git.run(['config', 'user.email', 'vendor-test@example.com']);
    git.run(['config', 'commit.gpgSign', 'false']);
    git.run(['remote', 'add', 'flclash', directory.path]);
    write('.gitignore', '.claude/worktrees/\n');
    write(
      'lib/code.dart',
      "import 'package:fl_clash/a.dart';\nconst upstream = 1;\n",
    );
    write('pubspec.yaml', 'name: fl_clash\nversion: 1.0.0\ndependencies: {}\n');
    write('CHANGELOG.md', '# Upstream\n');
    write('changelog.json', '{}\n');
    raw = commit('chore: initial source');
    config = {
      'v': 1,
      'source': {
        'remote': 'flclash',
        'url': directory.path,
        'ref': 'refs/heads/dev',
      },
      'development': 'dev',
      'vendor': 'vendor/flclash',
      'budget': 6144,
      'owned': ['CHANGELOG.md', 'changelog.json'],
      'checks': {
        'fixture': {
          'argv': ['git', 'status', '--short'],
        },
      },
      'full': ['fixture'],
      'platforms': <String, dynamic>{},
      'sentinels': <String, dynamic>{},
    };
    branding = {
      'v': 1,
      'preserve': ['https://github.com/chen08209/FlClash'],
      'paths': <String, dynamic>{},
      'rules': [
        {
          'paths': ['**/*.dart', 'pubspec.yaml'],
          'replace': {
            'package:fl_clash/': 'package:reclash/',
            'name: fl_clash': 'name: reclash',
          },
        },
      ],
    };
    feature = {
      'v': 1,
      'kind': 'feature',
      'state': 'active',
      'risk': 'routine',
      'must': {'behavior': 'Keep the downstream behavior.'},
      'watch': ['lib/**'],
      'checks': {
        'fixture': ['behavior'],
      },
    };
    metadata();
    write(
      'lib/code.dart',
      "import 'package:reclash/a.dart';\nconst upstream = 1;\nconst downstream = true;\n",
    );
    write('pubspec.yaml', 'name: reclash\nversion: 2.0.0\ndependencies: {}\n');
    write('CHANGELOG.md', '# ReClash\n');
    commit('feat: downstream behavior');
  }
  late final Directory directory;
  late final ForkGit git;
  late final String raw;
  late final Map<String, dynamic> config;
  late final Map<String, dynamic> branding;
  late final Map<String, dynamic> feature;
  Registry get registry => Registry(git);
  VendorSync get service => VendorSync(registry);
  void write(String path, String content) {
    final file = File(p.join(directory.path, path));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  void metadata() {
    write('.fork/config.yaml', jsonEncode(config));
    write('.fork/branding.yaml', jsonEncode(branding));
    write('.fork/features/feature.demo.yaml', jsonEncode(feature));
  }

  String commit(String message) {
    git.run(['add', '--all']);
    git.run(['commit', '-q', '-m', message]);
    return git.oid('HEAD');
  }

  String bootstrap([String id = 'initial']) {
    final audit = digest(service.inspect(raw));
    service.prepare(id, source: raw, bootstrap: true, audit: audit);
    finish(id);
    service.verify(id, reviews: ['bootstrap-audit', 'unclassified']);
    service.accept(id);
    return git.oid('vendor/flclash');
  }

  String rewritten({
    String? code,
    String? manifest,
    String? changelog,
    Map<String, String> files = const {},
  }) {
    final temp = Directory.systemTemp.createTempSync('reclash-upstream-test-');
    try {
      final index = {'GIT_INDEX_FILE': p.join(temp.path, 'index')};
      git.run(['read-tree', raw], environment: index);
      for (final e in <String, String>{
        'lib/code.dart': ?code,
        'pubspec.yaml': ?manifest,
        'CHANGELOG.md': ?changelog,
        ...files,
      }.entries) {
        final file = File(p.join(temp.path, 'payload'))
          ..writeAsStringSync(e.value);
        final blob = git.run([
          'hash-object',
          '-w',
          '--no-filters',
          file.path,
        ]).trim();
        git.run([
          'update-index',
          '--add',
          '--cacheinfo',
          '100644,$blob,${e.key}',
        ], environment: index);
      }
      final tree = git.run(['write-tree'], environment: index).trim();
      return git.commitTree(tree, [], 'chore: rewritten source');
    } finally {
      temp.deleteSync(recursive: true);
    }
  }

  ForkGit candidate(String id) =>
      ForkGit(service.receipt(id)['worktree'] as String);
  void finish(String id) {
    final target = candidate(id);
    if (target.rebaseInProgress) {
      final conflicts = ForkGit.split(
        target.run(['diff', '--name-only', '--diff-filter=U', '-z']),
      );
      for (final path in conflicts) {
        final file = File(p.join(target.root, path));
        if (file.existsSync() &&
            file.readAsStringSync().contains(
              RegExp(r'^(<<<<<<< |=======|>>>>>>> )', multiLine: true),
            )) {
          target.run(['checkout', '--theirs', '--', path]);
        }
      }
      target.run(['add', '--all']);
      target.run(
        ['rebase', '--continue'],
        environment: const {'GIT_EDITOR': 'true'},
      );
    } else if (target.dirty.isNotEmpty) {
      target.run(['add', '--all']);
      target.run([
        '-c',
        'user.name=Vendor test',
        '-c',
        'user.email=vendor-test@example.com',
        'commit',
        '-q',
        '-m',
        'chore(sync): resolve replay\n\nChangelog: skip',
      ]);
    }
  }

  void dispose() {
    // All worktrees, refs and objects belong to this disposable fixture.
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }
}
