import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../tool/fork.dart' show clusters;
import '../../../tool/src/fork/git.dart';
import '../../../tool/src/fork/model.dart';
import '../../../tool/src/fork/registry.dart';
import '../../../tool/src/fork/sync.dart';

const atlasPreviewLimit = 128 * 1024;
const atlasLogLimit = 256 * 1024;

class AtlasRepository {
  AtlasRepository(String root) : git = ForkGit(root);

  final ForkGit git;

  Map<String, dynamic> dispatch(String route, Map<String, String> query) =>
      switch (route) {
        '/api/snapshot' => snapshot(),
        '/api/stamp' => stamp(staged: query['mode'] == 'staged'),
        '/api/impact' => impact(query),
        '/api/file' => file(query),
        '/api/syncs' => observations(),
        '/api/sync' => observation(_required(query, 'id')),
        '/api/log' => log(_required(query, 'id'), _required(query, 'check')),
        _ => throw const ForkException('Unknown API endpoint', code: 404),
      };

  Map<String, dynamic> stamp({bool staged = false}) {
    final registry = Registry(git, staged: staged);
    final status = _status();
    final files = <String, Object?>{};
    for (final item in status) {
      final path = item['path'] as String;
      final stat = FileStat.statSync(p.join(git.root, path));
      files[path] = [
        stat.type.toString(),
        stat.size,
        stat.modified.microsecondsSinceEpoch,
      ];
    }
    final identity = {
      'head': _oid('HEAD'),
      'development': _oid(registry.config['development'] as String),
      'vendor': _oid(registry.config['vendor'] as String),
      'productBase': _oid('refs/reclash/product-base/current'),
      'registry': registry.fingerprint,
      'normalizer': VendorSync(registry).normalizer.fingerprint,
      'indexChanges': git.run([
        'diff',
        '--cached',
        '--raw',
        '--no-renames',
        '--no-ext-diff',
        '-z',
        'HEAD',
      ]),
      'observationRefs': git.run([
        'for-each-ref',
        '--format=%(refname) %(objectname)',
        'refs/reclash',
        'refs/heads/sync',
      ]),
      'status': status,
      'files': files,
    };
    return {
      'fingerprint': digest(identity),
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'head': identity['head'],
      'registry': identity['registry'],
    };
  }

  Map<String, dynamic> snapshot() {
    final registry = Registry(git);
    final service = VendorSync(registry);
    final vendor = _oid(service.vendorRef);
    final development = _oid(service.devRef);
    final base = _oid(service.productBaseRef);
    final status = _status();
    final inventory = ForkGit.split(
      git.run(['ls-files', '--cached', '--others', '--exclude-standard', '-z']),
    ).toSet().toList()..sort();
    final notices = <Map<String, dynamic>>[];
    Map<String, String>? provenance;
    if (vendor != null) {
      try {
        provenance = service.provenance(vendor);
      } on ForkException catch (error) {
        notices.add(
          _notice(
            'provenance',
            'blocker',
            'Vendor provenance is invalid',
            error.message,
          ),
        );
      }
    } else {
      notices.add(
        _notice(
          'vendor',
          'review',
          'No accepted vendor snapshot',
          'The repository has not established a normalized vendor baseline.',
        ),
      );
    }
    if (base == null) {
      notices.add(
        _notice(
          'base',
          'review',
          'No accepted product base',
          'A normal sync needs a separate accepted product-base ref.',
        ),
      );
    } else if (vendor != null) {
      try {
        service.assertProductBase(base, vendor);
      } on ForkException catch (error) {
        notices.add(
          _notice(
            'base',
            'blocker',
            'Product base does not match vendor',
            error.message,
          ),
        );
      }
      if (development != null && !git.firstParentAncestor(base, development)) {
        notices.add(
          _notice(
            'ancestry',
            'blocker',
            'Product base is outside the development stack',
            'The accepted base must be on the development first-parent history.',
          ),
        );
      } else if (development != null &&
          git
              .run(['rev-list', '--merges', '$base..$development'])
              .trim()
              .isNotEmpty) {
        notices.add(
          _notice(
            'linearity',
            'blocker',
            'The downstream stack contains merges',
            'Sync expects a linear downstream replay above the accepted product base.',
          ),
        );
      }
    }
    final fingerprint = service.normalizer.fingerprint;
    if (provenance != null && provenance['Normalizer'] != fingerprint) {
      notices.add(
        _notice(
          'normalizer',
          'blocker',
          'Normalizer fingerprint changed',
          'Normal preparation is blocked. A separately reviewed recipe migration must use the exact accepted raw source.',
        ),
      );
    }
    try {
      service.sourceIdentity();
    } on ForkException catch (error) {
      notices.add(
        _notice(
          'source',
          'blocker',
          'Configured source identity does not match',
          error.message,
        ),
      );
    }
    for (final feature in registry.features.values) {
      if (feature.state != 'retired' && feature.uncovered.isNotEmpty) {
        notices.add({
          ..._notice(
            'coverage:${feature.id}',
            feature.critical ? 'review' : 'info',
            'Unmapped invariants in ${feature.id}',
            'Check mappings are missing; critical gaps block verification when affected.',
          ),
          'features': [feature.id],
          'invariants': feature.uncovered,
        });
      }
    }
    final downstreamPaths = vendor != null && development != null
        ? git.changed(vendor, development)
        : <String>[];
    final vendorFiles = git.files(vendor ?? 'HEAD').toSet();
    final downstream = registry.impact(downstreamPaths);
    final unknown = strings(downstream['unclassified'], 'unclassified');
    if (unknown.isNotEmpty) {
      notices.add({
        ..._notice(
          'unclassified',
          'review',
          '${unknown.length} unclassified downstream paths',
          'These paths have no active watch or sentinel. Classification or an explicit unclassified review is required.',
        ),
        'paths': unknown,
      });
    }
    final refs = git
        .run([
          'for-each-ref',
          '--format=%(refname)',
          'refs/heads',
          'refs/reclash',
        ])
        .trim()
        .split('\n')
        .where((ref) => ref.isNotEmpty)
        .toList();
    final branch = git.result(['symbolic-ref', '--short', '-q', 'HEAD']);
    return {
      'schemaVersion': 1,
      ...stamp(),
      'repository': {
        'name': p.basename(git.root),
        'branch': branch.exitCode == 0
            ? (branch.stdout as String).trim()
            : 'detached HEAD',
        'host': Platform.operatingSystem,
        'head': _oid('HEAD'),
        'development': development,
        'developmentRef': registry.config['development'],
        'vendor': vendor,
        'vendorRef': registry.config['vendor'],
        'productBase': base,
        'source': registry.config['source'],
        'provenance': provenance,
        'dirty': status,
        'refs': refs,
      },
      'features': [
        for (final feature in registry.features.values)
          {
            'id': feature.id,
            ...feature.data,
            'uncovered': feature.uncovered,
            'yaml': registry.read('.fork/features/${feature.id}.yaml'),
            'files': inventory
                .where(
                  (path) =>
                      feature.watch.any((pattern) => matches(pattern, path)),
                )
                .toList(),
          },
      ],
      'relations': [
        for (final feature in registry.features.values)
          for (final dependency in feature.deps)
            {'from': feature.id, 'to': dependency, 'kind': 'dependency'},
      ],
      'checks': {
        for (final check in registry.checks.entries)
          check.key: {
            ...object(check.value, check.key),
            'baseline': strings(
              registry.config['full'],
              'full',
            ).contains(check.key),
            'availableHost':
                (check.value as Map)['host'] == null ||
                (check.value as Map)['host'] == Platform.operatingSystem,
            'covers': [
              for (final feature in registry.features.values)
                if (feature.checks.containsKey(check.key))
                  {
                    'feature': feature.id,
                    'invariants': feature.checks[check.key],
                  },
            ],
          },
      },
      'sentinels': registry.sentinels,
      'platforms': registry.config['platforms'],
      'normalization': {
        'fingerprint': fingerprint,
        'acceptedFingerprint': provenance?['Normalizer'],
        'recipe': service.normalizer.recipe,
      },
      'downstream': {
        ...downstream,
        'paths': downstreamPaths,
        'vendorFiles': downstreamPaths.where(vendorFiles.contains).length,
        'downstreamOnly': downstreamPaths
            .where((path) => !vendorFiles.contains(path))
            .length,
      },
      'notices': notices,
      'histories': {
        'vendor': vendor == null ? <Object>[] : _history(vendor, limit: 20),
        'product': development == null
            ? <Object>[]
            : _history(development, base: base, limit: 100),
        'productBase': base == null ? null : _commit(base),
      },
    };
  }

  Map<String, dynamic> impact(Map<String, String> query) {
    final selection = _selection(query);
    final registry = Registry(git, staged: selection.mode == 'staged');
    final changes = _changes(selection);
    final paths = changes.map((change) => change['path'] as String).toList();
    return {
      'schemaVersion': 1,
      ...stamp(staged: selection.mode == 'staged'),
      'selection': selection.toJson(),
      'impact': registry.impact(paths),
      'clusters': clusters(registry, paths),
      'changes': [
        for (final change in changes)
          {...change, 'direct': _direct(registry, change['path'] as String)},
      ],
      'features': [
        for (final feature in registry.features.values)
          {'id': feature.id, ...feature.data, 'uncovered': feature.uncovered},
      ],
    };
  }

  Map<String, dynamic> file(Map<String, String> query) {
    final path = safePath(_required(query, 'path'));
    final selection = _selection(query);
    final before = _blobAt(selection.from ?? 'HEAD', path);
    final after = switch (selection.mode) {
      'working' || 'paths' => _workingFile(path),
      'staged' => _indexFile(path),
      _ => _blobAt(selection.to!, path),
    };
    final args = [
      '--literal-pathspecs',
      'diff',
      '--no-ext-diff',
      '--no-textconv',
      '--no-renames',
      '--no-color',
      '--unified=3',
      if (selection.mode == 'staged') '--cached',
      if (selection.to != null) ...[selection.from!, selection.to!] else 'HEAD',
      '--',
      path,
    ];
    String patch;
    if ((after['size'] as int? ?? 0) > atlasPreviewLimit ||
        (before['size'] as int? ?? 0) > atlasPreviewLimit) {
      patch = 'Diff preview omitted: this file exceeds the preview limit.';
    } else {
      patch = git.run(args);
      if (utf8.encode(patch).length > atlasPreviewLimit) {
        patch = utf8.decode(
          utf8.encode(patch).take(atlasPreviewLimit).toList(),
          allowMalformed: true,
        );
        patch += '\n… diff preview truncated …';
      }
      if (patch.isEmpty &&
          before['kind'] == 'missing' &&
          after['kind'] == 'text') {
        patch =
            '--- /dev/null\n+++ $path\n${(after['content'] as String).split('\n').map((line) => '+$line').join('\n')}';
      }
    }
    final registry = Registry(git, staged: selection.mode == 'staged');
    return {
      'path': path,
      'selection': selection.toJson(),
      'before': before,
      'after': after,
      'patch': patch,
      'direct': _direct(registry, path),
      'impact': registry.impact([path]),
    };
  }

  Map<String, dynamic> observations() {
    final root = Directory(git.stateRoot);
    rejectSymlinks(root.path);
    final runs = <Map<String, dynamic>>[];
    if (root.existsSync()) {
      final directories =
          root.listSync(followLinks: false).whereType<Directory>().toList()
            ..sort((a, b) => b.path.compareTo(a.path));
      for (final directory in directories) {
        final id = p.basename(directory.path);
        try {
          identifier(id);
          if (!File(p.join(directory.path, 'receipt.json')).existsSync()) {
            runs.add({
              'id': id,
              'status': 'missing-receipt',
              'note':
                  'This directory has no receipt; its state cannot be established.',
            });
          } else {
            runs.add(_observationSummary(id));
          }
        } on ForkException catch (error) {
          runs.add({'id': id, 'status': 'unavailable', 'note': error.message});
        } on FormatException {
          runs.add({
            'id': id,
            'status': 'unavailable',
            'note': 'The archived receipt is not valid JSON.',
          });
        }
      }
    }
    return {
      'runs': runs,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> observation(String id) {
    final receipt = _receipt(id);
    final summary = _observationSummary(id, receipt: receipt);
    final source = _receiptOid(receipt, 'source');
    final vendor = _receiptOid(receipt, 'vendor');
    final prepared = _receiptOid(receipt, 'prepared');
    final preparedBase = _receiptOid(receipt, 'preparedBase');
    final candidate = summary['candidate'] as String?;
    String? previousSource;
    if (vendor != null) {
      try {
        previousSource = VendorSync(
          Registry(git),
        ).provenance(vendor)['Upstream-Commit'];
      } on ForkException {
        previousSource = null;
      }
    }
    return {
      ...summary,
      'receipt': receipt,
      'comparisons': [
        if (previousSource != null && source != null)
          {
            'lens': 'raw',
            'label': 'Upstream',
            'from': previousSource,
            'to': source,
          },
        if (vendor != null && prepared != null)
          {
            'lens': 'normalized',
            'label': 'Normalized',
            'from': vendor,
            'to': prepared,
          },
        if (candidate != null && (preparedBase ?? prepared) != null)
          {
            'lens': 'product',
            'label': 'Product',
            'from': preparedBase ?? prepared,
            'to': candidate,
          },
      ],
      'replaySource': _receiptCommits(receipt['replaySource']),
      'replayed': _receiptCommits(receipt['replayed']),
      'productBaseCommit': preparedBase == null ? null : _commit(preparedBase),
      'vendorCommit': prepared == null ? null : _commit(prepared),
      'candidateCommit': candidate == null ? null : _commit(candidate),
      'legacy': preparedBase == null,
    };
  }

  Map<String, dynamic> log(String id, String check) {
    identifier(check);
    final receipt = _receipt(id);
    final results = object(
      receipt['verified'] is Map
          ? (receipt['verified'] as Map)['checks'] ?? {}
          : receipt['checks'] ?? {},
      'checks',
    );
    if (!results.containsKey(check)) {
      throw const ForkException('No recorded result for this check', code: 404);
    }
    final file = File(p.join(git.stateRoot, id, '$check.log'));
    rejectSymlinks(file.path);
    if (!file.existsSync()) {
      throw const ForkException(
        'No log was archived for this check',
        code: 404,
      );
    }
    return {
      'id': id,
      'check': check,
      ..._previewFile(file, limit: atlasLogLimit),
    };
  }

  _Selection _selection(Map<String, String> query) {
    final mode = query['mode'] ?? 'working';
    switch (mode) {
      case 'working':
      case 'staged':
      case 'paths':
        return _Selection(
          mode,
          paths: mode == 'paths' ? [safePath(_required(query, 'path'))] : null,
        );
      case 'refs':
        return _Selection(
          mode,
          from: _revision(_required(query, 'from')),
          to: _revision(_required(query, 'to')),
        );
      case 'downstream':
        final registry = Registry(git);
        return _Selection(
          mode,
          from: _revision(registry.config['vendor'] as String),
          to: _revision(registry.config['development'] as String),
        );
      case 'sync':
        final id = _required(query, 'id');
        final detail = observation(id);
        final lens = query['lens'] ?? 'normalized';
        final comparison = (detail['comparisons'] as List)
            .cast<Map>()
            .where((item) => item['lens'] == lens)
            .firstOrNull;
        if (comparison == null) {
          reject('This observation has no $lens comparison');
        }
        return _Selection(
          mode,
          from: _revision(comparison['from'] as String),
          to: _revision(comparison['to'] as String),
          id: id,
          lens: lens,
        );
      default:
        reject('Unknown comparison mode');
    }
  }

  List<Map<String, dynamic>> _changes(_Selection selection) {
    if (selection.to != null) {
      final before = {
        for (final entry in git.entries(selection.from!)) entry.path: entry,
      };
      final after = {
        for (final entry in git.entries(selection.to!)) entry.path: entry,
      };
      final binary = <String>{};
      for (final item in ForkGit.split(
        git.run([
          'diff',
          '--numstat',
          '--no-ext-diff',
          '--no-textconv',
          '--no-renames',
          '-z',
          selection.from!,
          selection.to!,
        ]),
      )) {
        if (item.startsWith('-\t-\t')) binary.add(item.substring(4));
      }
      return [
        for (final path in git.changed(selection.from!, selection.to!))
          {
            'path': path,
            'status': selection.mode == 'paths'
                ? 'inspect'
                : before[path] == null
                ? 'add'
                : after[path] == null
                ? 'delete'
                : 'modify',
            'kind':
                [
                  before[path],
                  after[path],
                ].any((entry) => entry?.mode == '160000')
                ? 'gitlink'
                : [
                    before[path],
                    after[path],
                  ].any((entry) => entry?.mode == '120000')
                ? 'symlink'
                : binary.contains(path)
                ? 'binary'
                : 'text',
            'modeChanged':
                before[path] != null &&
                after[path] != null &&
                before[path]!.mode != after[path]!.mode,
          },
      ];
    }
    final paths =
        selection.paths ??
        (selection.mode == 'staged' ? git.stagedPaths : git.changedPaths);
    final before = {for (final entry in git.entries('HEAD')) entry.path: entry};
    final status = {for (final item in _status()) item['path']: item};
    return paths.map((path) {
      final preview = selection.mode == 'staged'
          ? _indexFile(path)
          : _workingFile(path);
      return {
        'path': path,
        'status': selection.mode == 'paths'
            ? 'inspect'
            : before[path] == null
            ? 'add'
            : preview['kind'] == 'missing'
            ? 'delete'
            : 'modify',
        'kind': preview['kind'],
        'index': status[path]?['index'],
        'worktree': status[path]?['worktree'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _direct(Registry registry, String path) => [
    for (final feature in registry.features.values.where(
      (feature) => feature.state != 'retired',
    ))
      for (final pattern in feature.watch)
        if (matches(pattern, path))
          {'feature': feature.id, 'via': 'watch', 'pattern': pattern},
    for (final sentinel in registry.sentinels.entries)
      if (matches(sentinel.key, path))
        for (final id in strings(sentinel.value, 'sentinel'))
          {'feature': id, 'via': 'sentinel', 'pattern': sentinel.key},
  ];

  List<Map<String, dynamic>> _status() => [
    for (final entry in ForkGit.split(
      git.run([
        'status',
        '--porcelain=v1',
        '--no-renames',
        '-z',
        '--untracked-files=all',
      ]),
    ))
      {'path': entry.substring(3), 'index': entry[0], 'worktree': entry[1]},
  ];

  Map<String, dynamic> _workingFile(String path) {
    final full = p.join(git.root, safePath(path));
    rejectSymlinks(p.dirname(full));
    final type = FileSystemEntity.typeSync(full, followLinks: false);
    if (type == FileSystemEntityType.link) {
      return {'kind': 'symlink', 'content': Link(full).targetSync(), 'size': 0};
    }
    if (type == FileSystemEntityType.notFound) {
      return {'kind': 'missing', 'content': '', 'size': 0};
    }
    if (type == FileSystemEntityType.directory) {
      return {
        'kind': 'gitlink',
        'content': 'Directory or submodule; no file preview.',
        'size': 0,
      };
    }
    rejectSymlinks(full);
    return _previewFile(File(full));
  }

  Map<String, dynamic> _indexFile(String path) {
    final entries = ForkGit.split(
      git.run([
        '--literal-pathspecs',
        'ls-files',
        '--stage',
        '-z',
        '--',
        safePath(path),
      ]),
    );
    if (entries.isEmpty) return {'kind': 'missing', 'content': '', 'size': 0};
    final fields = entries.first.split('\t').first.split(' ');
    if (fields[2] != '0') {
      return {
        'kind': 'conflict',
        'content': 'The index has unresolved stages for this path.',
        'size': 0,
      };
    }
    return _entryPreview(TreeEntry(fields[0], fields[1], path));
  }

  Map<String, dynamic> _blobAt(String revision, String path) {
    final entries = ForkGit.split(
      git.run([
        '--literal-pathspecs',
        'ls-tree',
        '-z',
        revision,
        '--',
        safePath(path),
      ]),
    );
    if (entries.isEmpty) return {'kind': 'missing', 'content': '', 'size': 0};
    final fields = entries.first.split('\t').first.split(' ');
    return _entryPreview(TreeEntry(fields[0], fields[2], path));
  }

  Map<String, dynamic> _entryPreview(TreeEntry entry) {
    if (entry.mode == '160000' || entry.mode == '040000') {
      return {'kind': 'gitlink', 'content': entry.oid, 'size': 0};
    }
    final size = int.parse(git.run(['cat-file', '-s', entry.oid]).trim());
    if (size > atlasPreviewLimit) {
      return {
        'kind': entry.mode == '120000' ? 'symlink' : 'large',
        'content':
            'File exceeds the ${atlasPreviewLimit ~/ 1024} KiB preview limit.',
        'size': size,
        'truncated': true,
      };
    }
    final preview = _preview(git.blob(entry.oid), size);
    return {
      ...preview,
      if (entry.mode == '120000') 'kind': 'symlink',
      'oid': entry.oid,
    };
  }

  Map<String, dynamic> _previewFile(
    File file, {
    int limit = atlasPreviewLimit,
  }) {
    final size = file.lengthSync();
    final stream = file.openSync();
    try {
      return _preview(stream.readSync(limit), size);
    } finally {
      stream.closeSync();
    }
  }

  Map<String, dynamic> _preview(List<int> bytes, int size) {
    if (bytes.contains(0)) {
      return {
        'kind': 'binary',
        'content': 'Binary file; text preview is unavailable.',
        'size': size,
      };
    }
    try {
      return {
        'kind': 'text',
        'content': utf8.decode(bytes),
        'size': size,
        'truncated': bytes.length < size,
      };
    } on FormatException {
      if (bytes.length < size) {
        for (var trim = 1; trim <= 3 && trim < bytes.length; trim++) {
          try {
            final content = utf8.decode(bytes.sublist(0, bytes.length - trim));
            return {
              'kind': 'text',
              'content': content,
              'size': size,
              'truncated': true,
            };
          } on FormatException {
            continue;
          }
        }
      }
      return {
        'kind': 'binary',
        'content': 'Non-UTF-8 file; text preview is unavailable.',
        'size': size,
      };
    }
  }

  Map<String, dynamic> _receipt(String id) {
    identifier(id);
    final file = File(p.join(git.stateRoot, id, 'receipt.json'));
    rejectSymlinks(file.path);
    if (!file.existsSync()) {
      throw const ForkException('Observation receipt not found', code: 404);
    }
    if (file.lengthSync() > 8 * 1024 * 1024) {
      reject('Observation receipt exceeds the read limit');
    }
    final result = object(jsonDecode(file.readAsStringSync()), 'receipt');
    if (result['id'] != id) reject('Receipt ID does not match its directory');
    final capturedRoot = result['root'];
    if (capturedRoot is! String ||
        p.normalize(capturedRoot) != p.normalize(git.root)) {
      reject('Receipt belongs to a different checkout');
    }
    return result;
  }

  Map<String, dynamic> _observationSummary(
    String id, {
    Map<String, dynamic>? receipt,
  }) {
    final r = receipt ?? _receipt(id);
    final verified = r['verified'] is Map
        ? object(r['verified'], 'verified')
        : <String, dynamic>{};
    final accepted = _receiptOid(r, 'accepted');
    final candidate =
        accepted ??
        _oid('refs/heads/sync/$id') ??
        _receiptOid(verified, 'commit');
    final registry = Registry(git);
    final service = VendorSync(registry);
    final staleReasons = <String>[];
    if (accepted == null) {
      if (verified.isNotEmpty &&
          (candidate == null || candidate != verified['commit'])) {
        staleReasons.add('Candidate commit changed or is no longer available.');
      }
      if (_oid('refs/heads/${registry.config['development']}') != r['dev']) {
        staleReasons.add('Development moved after preparation.');
      }
      if (registry.fingerprint != (verified['registry'] ?? r['registry'])) {
        staleReasons.add('Contract or check policy changed.');
      }
      if (service.normalizer.fingerprint !=
          (verified['normalizer'] ?? r['normalizer'])) {
        staleReasons.add('Normalizer changed.');
      }
    }
    if (accepted == null && verified.isNotEmpty) {
      if (candidate != null && git.tree(candidate) != verified['tree']) {
        staleReasons.add('Verified candidate tree no longer matches.');
      }
      if (verified['productBase'] != r['preparedBase']) {
        staleReasons.add('Prepared product base changed.');
      }
      final checkout = git.worktrees()['refs/heads/sync/$id'];
      if (checkout == null || !Directory(checkout).existsSync()) {
        staleReasons.add(
          'Candidate checkout is unavailable; only archival evidence remains.',
        );
      } else {
        rejectSymlinks(checkout);
        final target = ForkGit(checkout);
        if (target.rebaseInProgress || target.dirty.isNotEmpty) {
          staleReasons.add('Candidate checkout has unfinished work.');
        }
        if (target.oid('HEAD') != verified['commit']) {
          staleReasons.add('Candidate checkout moved after verification.');
        }
      }
    }
    final results = object(verified['checks'] ?? r['checks'] ?? {}, 'checks');
    return {
      'id': id,
      'status': accepted != null
          ? 'accepted'
          : staleReasons.isNotEmpty
          ? 'stale'
          : verified.isNotEmpty
          ? 'verified'
          : candidate != null
          ? 'candidate'
          : 'unverified',
      'candidate': candidate,
      'accepted': accepted,
      'source': _receiptOid(r, 'source'),
      'prepared': _receiptOid(r, 'prepared'),
      'preparedBase': _receiptOid(r, 'preparedBase'),
      'reviews': verified['reviews'] ?? [],
      'waivers': verified['waivers'] ?? [],
      'staleReasons': staleReasons,
      'historical': accepted != null,
      'checks': {
        for (final result in results.entries)
          result.key: {
            ...object(result.value, result.key),
            'status': (result.value as Map)['status'] == 'waived'
                ? 'waived'
                : (result.value as Map)['exit'] == 0
                ? 'passed'
                : (result.value as Map)['exit'] is int
                ? 'failed'
                : 'not-run',
          },
      },
    };
  }

  List<Map<String, dynamic>> _receiptCommits(Object? value) {
    if (value == null) return [];
    return strings(value, 'commits')
        .take(150)
        .where(
          (oid) =>
              RegExp(r'^[a-f0-9]{40,64}$').hasMatch(oid) && git.exists(oid),
        )
        .map(_commit)
        .toList();
  }

  List<Map<String, dynamic>> _history(
    String revision, {
    String? base,
    int limit = 100,
  }) {
    final range = base != null && git.ancestor(base, revision)
        ? '$base..$revision'
        : revision;
    return git
        .run(['rev-list', '--first-parent', '--max-count=$limit', range])
        .trim()
        .split('\n')
        .where((oid) => oid.isNotEmpty)
        .map(_commit)
        .toList();
  }

  Map<String, dynamic> _commit(String oid) {
    final fields = git
        .run(['show', '-s', '--format=%H%x00%P%x00%T%x00%s%x00%cI', oid])
        .trim()
        .split('\u0000');
    return {
      'oid': fields[0],
      'parents': fields[1]
          .split(' ')
          .where((parent) => parent.isNotEmpty)
          .toList(),
      'tree': fields[2],
      'subject': fields[3],
      'date': fields[4],
    };
  }

  String? _receiptOid(Map<String, dynamic> receipt, String key) {
    final value = receipt[key];
    if (value == null) return null;
    if (value is! String ||
        !RegExp(r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$').hasMatch(value)) {
      reject('Invalid archived object ID: $key');
    }
    return git.exists(value) ? git.oid(value) : null;
  }

  String _revision(String value) {
    if (value.length > 200 ||
        !RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9/._@~^{}-]*$').hasMatch(value)) {
      reject('Invalid Git revision');
    }
    return git.oid(value);
  }

  String? _oid(String ref) => git.exists(ref) ? git.oid(ref) : null;

  String _required(Map<String, String> query, String key) =>
      text(query[key], key);

  Map<String, dynamic> _notice(
    String id,
    String level,
    String title,
    String detail,
  ) => {'id': id, 'level': level, 'title': title, 'detail': detail};
}

class _Selection {
  const _Selection(
    this.mode, {
    this.from,
    this.to,
    this.id,
    this.lens,
    this.paths,
  });
  final String mode;
  final String? from;
  final String? to;
  final String? id;
  final String? lens;
  final List<String>? paths;

  Map<String, dynamic> toJson() => {
    'mode': mode,
    if (from != null) 'from': from,
    if (to != null) 'to': to,
    if (id != null) 'id': id,
    if (lens != null) 'lens': lens,
  };
}
