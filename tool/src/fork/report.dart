import 'dart:io';

import 'package:path/path.dart' as p;

import 'git.dart';
import 'model.dart';
import 'registry.dart';
import 'sync.dart';

class MaintenanceReport {
  MaintenanceReport(this.registry) : sync = VendorSync(registry);

  final Registry registry;
  final VendorSync sync;
  ForkGit get git => registry.git;

  Map<String, dynamic> policy() {
    final file = File(p.join(git.root, '.fork/maintenance.yaml'));
    if (!file.existsSync()) return {};
    final data = yamlObject(
      registry.read('.fork/maintenance.yaml'),
      'maintenance',
    );
    keys(data, 'v features migrations release paths', 'maintenance');
    if (data['v'] != 1) reject('Unsupported maintenance schema');
    for (final entry in object(data['features'] ?? {}, 'features').entries) {
      final feature = registry.features[entry.key];
      if (feature == null) reject('Unknown maintenance feature: ${entry.key}');
      final metadata = object(entry.value, entry.key);
      keys(metadata, 'owners evidence review', entry.key);
      final owners = object(metadata['owners'] ?? {}, 'owners');
      keys(owners, 'upstream downstream shared', 'owners');
      for (final paths in owners.values) {
        for (final path in strings(paths, 'owner paths')) {
          safePath(path, glob: true);
        }
      }
      for (final evidence in object(
        metadata['evidence'] ?? {},
        'evidence',
      ).entries) {
        if (!feature.invariants.containsKey(evidence.key)) {
          reject('${entry.key}: unknown invariant ${evidence.key}');
        }
        final kinds = strings(evidence.value, 'evidence types');
        if (kinds.isEmpty ||
            kinds.any(
              (kind) => ![
                'structural',
                'behavioral',
                'migration',
                'integration',
                'platform',
                'security',
              ].contains(kind),
            )) {
          reject('Invalid evidence types: ${evidence.key}');
        }
      }
      if (metadata['review'] != null) text(metadata['review'], 'review');
    }
    if (data['migrations'] != null && data['migrations'] is! List) {
      reject('Migrations must be a list');
    }
    final migrationIds = <String>{};
    for (final value in (data['migrations'] ?? []) as List) {
      final migration = object(value, 'migration');
      keys(
        migration,
        'id target sources fixtures checks downgrade',
        'migration',
      );
      final id = text(migration['id'], 'migration id');
      identifier(id);
      if (!migrationIds.add(id)) reject('Duplicate migration: $id');
      if (migration['target'] is! int || migration['target'] < 1) {
        reject('Migration target must be a positive schema version');
      }
      if (migration['sources'] is! List ||
          (migration['sources'] as List).isEmpty) {
        reject('Migration needs source shapes');
      }
      for (final source in migration['sources'] as List) {
        final shape = object(source, 'source shape');
        keys(shape, 'product release schema shape', 'source shape');
        text(shape['product'], 'product');
        text(shape['release'], 'release');
        text(shape['shape'], 'shape');
        if (shape['schema'] is! int || shape['schema'] < 1) {
          reject('Source schema must be a positive integer');
        }
      }
      if (!['reject', 'unsupported'].contains(migration['downgrade'])) {
        reject('Migration downgrade must explicitly reject or be unsupported');
      }
      if (strings(migration['fixtures'], 'fixtures').isEmpty ||
          strings(migration['checks'], 'migration checks').isEmpty) {
        reject('Migration needs fixtures and checks');
      }
      for (final fixture in strings(migration['fixtures'], 'fixtures')) {
        safePath(fixture);
        if (!File(p.join(git.root, fixture)).existsSync()) {
          reject('Missing migration fixture: $fixture');
        }
      }
      for (final check in strings(migration['checks'], 'migration checks')) {
        registry.requireCheck(check);
      }
    }
    for (final entry in object(data['release'] ?? {}, 'release').entries) {
      final rule = object(entry.value, 'release rule');
      keys(rule, 'path pattern', 'release rule');
      safePath(text(rule['path'], 'release path'));
      if (rule['pattern'] != null) {
        RegExp(text(rule['pattern'], 'release pattern'), multiLine: true);
      }
    }
    for (final entry in object(data['paths'] ?? {}, 'paths').entries) {
      safePath(entry.key, glob: true);
      final rule = object(entry.value, 'path rule');
      keys(rule, 'kind checks reason', 'path rule');
      if (![
        'documentation',
        'generated',
        'platform',
        'engine',
      ].contains(rule['kind'])) {
        reject('Invalid path kind');
      }
      text(rule['reason'], 'path reason');
      for (final check in strings(rule['checks'], 'path checks')) {
        registry.requireCheck(check);
      }
    }
    return data;
  }

  Map<String, dynamic> paths(
    List<String> paths, {
    String? from,
    String? to,
    String? downstreamFrom,
    String? downstreamTo,
  }) {
    final metadata = policy();
    final impact = registry.impact(paths);
    final features = object(metadata['features'] ?? {}, 'features');
    final downstream = downstreamFrom == null || downstreamTo == null
        ? <String>{}
        : git.changed(downstreamFrom, downstreamTo).toSet();
    return {
      ...impact,
      'readiness': 'impact-only-not-verified',
      if (downstreamFrom != null && downstreamTo != null)
        'overlap': {
          'upstreamRange': [from, to],
          'downstreamRange': [downstreamFrom, downstreamTo],
          'paths': paths.where(downstream.contains).toList()..sort(),
          'meaning':
              'Path overlap is a review priority, not proof of a semantic conflict.',
        },
      'paths': [
        for (final path in paths..sort())
          {
            'path': path,
            'contracts': registry.affected([path]).keys.toList()..sort(),
            'ownership': [
              for (final entry in features.entries)
                for (final owner in object(
                  object(entry.value, entry.key)['owners'] ?? {},
                  'owners',
                ).entries)
                  if (strings(
                    owner.value,
                    'paths',
                  ).any((pattern) => matches(pattern, path)))
                    {'feature': entry.key, 'owner': owner.key},
            ],
            'classification': classification(path, metadata),
            if (downstreamFrom != null && downstreamTo != null)
              'downstreamTouched': downstream.contains(path),
            if (from != null && to != null)
              'commits': git.run([
                'rev-list',
                '--count',
                '$from..$to',
                '--',
                path,
              ]).trim(),
          },
      ],
      'contracts': {
        for (final id in object(impact['features'], 'features').keys)
          id: {
            'must': registry.features[id]!.invariants,
            'dependencies': registry.features[id]!.deps,
            'checks': registry.features[id]!.checks,
            'metadata': features[id] ?? {},
          },
      },
      'checksDetail': checkPlan(strings(impact['checks'], 'checks'), {}),
      'migrations': metadata['migrations'] ?? [],
      'next':
          'Run focused checks; status --id reports observation readiness. No review is granted by this report.',
    };
  }

  Map<String, dynamic> classification(
    String path,
    Map<String, dynamic> metadata,
  ) {
    final rules = object(metadata['paths'] ?? {}, 'paths');
    for (final entry in rules.entries) {
      if (matches(entry.key, path)) {
        return object(entry.value, 'classification');
      }
    }
    final mapped = (registry.impact([path])['unclassified'] as List).isEmpty;
    return {
      'kind': mapped ? 'contract' : 'unclassified',
      'checks': <String>[],
      'reason': mapped
          ? 'Covered by feature contracts; not proof of a test pass.'
          : 'Requires explicit classification and review.',
    };
  }

  List<Map<String, dynamic>> checkPlan(
    List<String> names,
    Map<String, dynamic> results,
  ) => [
    for (final name in names)
      {
        'name': name,
        ...object(registry.checks[name], name),
        'status': results[name] == null
            ? 'not-run'
            : object(results[name], name)['status'] == 'waived'
            ? 'waived'
            : object(results[name], name)['exit'] == 0
            ? 'passed'
            : 'failed',
        'hostAvailable':
            object(registry.checks[name], name)['host'] == null ||
            object(registry.checks[name], name)['host'] ==
                Platform.operatingSystem,
      },
  ];

  Map<String, dynamic> lineage(String id) {
    final visited = <String>{};
    final observations = <Map<String, dynamic>>[];
    String? next = id;
    while (next != null) {
      if (!visited.add(next)) reject('Receipt lineage cycle: $next');
      final r = sync.receipt(next);
      observations.add({
        'id': next,
        'source': r['source'],
        'candidate': r['verified'] == null
            ? null
            : object(r['verified'], 'verified')['commit'],
        'prepared': r['prepared'],
        'productBase': r['preparedBase'],
        'recipeMigration': r['recipeMigration'],
        'accepted': r['accepted'],
        'after': r['after'],
        'receiptDigest': digest(r),
      });
      final after = r['after'];
      next = after is Map
          ? text(after['id'], 'predecessor id')
          : after is String
          ? after
          : null;
    }
    return {
      'id': id,
      'observations': observations,
      'authority': 'read-only-not-acceptance',
    };
  }

  Map<String, dynamic> status(String id) {
    if (!sync.receiptFile(id).existsSync() &&
        git.exists('refs/reclash/prepared/$id') &&
        git.exists('refs/reclash/upstream/$id')) {
      return {
        'id': id,
        'status': 'history-only',
        'source': git.oid('refs/reclash/upstream/$id'),
        'prepared': git.oid('refs/reclash/prepared/$id'),
        'ready': false,
        'blockers': ['History-only observation has no candidate to accept'],
      };
    }
    final r = sync.receipt(id);
    final blockers = <String>[];
    try {
      sync.assertInputs(r);
    } on ForkException catch (error) {
      blockers.add(error.message);
    }
    final targetPath = text(r['worktree'], 'worktree');
    if (!Directory(targetPath).existsSync()) {
      return {
        'id': id,
        'ready': false,
        'blockers': [...blockers, 'Candidate worktree missing'],
        'worktree': targetPath,
      };
    }
    final target = ForkGit(targetPath);
    final head = target.oid('HEAD');
    final dirty = target.dirty;
    if (dirty.isNotEmpty) blockers.add('Candidate has uncommitted changes');
    if (target.rebaseInProgress) blockers.add('Candidate rebase in progress');
    if (target.common != git.common ||
        target.run(['symbolic-ref', '-q', 'HEAD']).trim() !=
            'refs/heads/sync/$id') {
      blockers.add('Candidate repository or branch changed');
    }
    if (r['accepted'] != null) blockers.add('Observation already accepted');
    final verified = r['verified'] == null
        ? <String, dynamic>{}
        : object(r['verified'], 'verified');
    final current = Registry(target);
    final currentVerification =
        blockers.isEmpty &&
        current.fingerprint == registry.fingerprint &&
        VendorSync(current).normalizer.fingerprint ==
            sync.normalizer.fingerprint &&
        digest({'after': verified['predecessor']}) ==
            digest({'after': r['after']}) &&
        verified['productBase'] == r['preparedBase'] &&
        verified['commit'] == head &&
        verified['tree'] == target.tree(head) &&
        verified['registry'] == registry.fingerprint &&
        verified['normalizer'] == sync.normalizer.fingerprint &&
        dirty.isEmpty;
    if (!currentVerification) blockers.add('Verification missing or stale');
    final changed = target.changed(r['preparedBase'] as String, head);
    final paths = {
      ...strings(r['paths'], 'paths'),
      ...changed,
      if (r['after'] != null)
        ...strings(
          sync.receipt(object(r['after'], 'after')['id'] as String)['paths'],
          'predecessor paths',
        ),
      ...target.changedPaths,
    }.toList();
    final impact = registry.impact(paths);
    if (object(impact['features'], 'features').keys.any(
      (id) =>
          registry.features[id]!.critical &&
          registry.features[id]!.uncovered.isNotEmpty,
    )) {
      blockers.add('Critical invariants lack check coverage');
    }
    final reviews = <String>{
      ...strings(impact['critical'], 'critical'),
      if ((impact['unclassified'] as List).isNotEmpty) 'unclassified',
      if (r['coreReview'] == true ||
          (r['after'] != null &&
              sync.receipt(
                    object(r['after'], 'after')['id'] as String,
                  )['coreReview'] ==
                  true) ||
          paths.any(
            (path) => path == '.gitmodules' || path.startsWith('core/'),
          ))
        'core-source',
      if (r['bootstrap'] == true) 'bootstrap-audit',
      if (r['recipeMigration'] == true || r['after'] != null)
        'normalization-policy',
    };
    final results = currentVerification
        ? object(verified['checks'], 'checks')
        : <String, dynamic>{};
    final checks = checkPlan(strings(impact['checks'], 'checks'), results);
    if (checks.any(
      (check) => !['passed', 'waived'].contains(check['status']),
    )) {
      blockers.add('Required checks are missing or failed');
    }
    if (reviews.any(
      (review) =>
          !currentVerification ||
          !strings(verified['reviews'], 'reviews').contains(review),
    )) {
      blockers.add('Required review labels are missing');
    }
    final metadata = policy();
    final release = releaseReport(target, r['dev'] as String, metadata);
    if (release.any((row) => row['matches'] != true)) {
      blockers.add('Release identity differs from captured development state');
    }
    return {
      'id': id,
      'source': r['source'],
      'worktree': targetPath,
      'candidate': head,
      'accepted': r['accepted'],
      'productBase': r['preparedBase'],
      'replayCount': target.run([
        'rev-list',
        '--count',
        '${r['preparedBase']}..$head',
      ]).trim(),
      'dirtyEntries': dirty,
      'schema': 'valid',
      'coverageGaps': {
        for (final id in object(impact['features'], 'features').keys)
          if (registry.features[id]!.uncovered.isNotEmpty)
            id: registry.features[id]!.uncovered,
      },
      'verification': currentVerification ? 'current' : 'missing-or-stale',
      'reviews': [
        for (final review in reviews)
          {
            'label': review,
            'status':
                currentVerification &&
                    strings(verified['reviews'], 'reviews').contains(review)
                ? 'recorded'
                : 'required',
            'reason':
                registry.features[review]?.data['why'] ??
                'Explicit maintainer authority and evidence required',
            'paths': registry.affected(paths)[review]?.toList() ?? paths,
          },
      ],
      'checks': checks,
      'platforms': checks.where((check) => check['host'] != null).toList(),
      'releaseIdentity': release,
      'migrations': metadata['migrations'] ?? [],
      'lineage': r['after'] ?? r['lineage'],
      'ready': blockers.isEmpty,
      'blockers': blockers,
      'next': blockers.isEmpty
          ? 'Acceptance still requires explicit user authority.'
          : 'Resolve blockers; status never runs checks, writes receipts, or grants reviews.',
    };
  }

  List<Map<String, dynamic>> releaseReport(
    ForkGit target,
    String original,
    Map<String, dynamic> metadata,
  ) {
    return [
      for (final entry in object(metadata['release'] ?? {}, 'release').entries)
        (() {
          final rule = object(entry.value, entry.key);
          final path = rule['path'] as String;
          String? value(ForkGit repo, bool working) {
            final file = File(p.join(repo.root, path));
            if (working && !file.existsSync()) return null;
            if (!working && !repo.files(original).contains(path)) return null;
            final content = working
                ? file.readAsStringSync()
                : repo.read(original, path);
            return rule['pattern'] == null
                ? digest(content)
                : RegExp(
                    rule['pattern'] as String,
                    multiLine: true,
                  ).firstMatch(content)?.group(0);
          }

          final before = value(git, false);
          final after = value(target, true);
          return {
            'id': entry.key,
            'path': path,
            'matches': before == after && before != null,
            'expected': before,
            'actual': after,
          };
        })(),
    ];
  }
}

String renderMaintenanceMarkdown(Map<String, dynamic> report) {
  String cell(Object? value) =>
      '$value'.replaceAll('|', r'\|').replaceAll('\n', ' ');
  final out = StringBuffer('# Fork maintenance report\n\n');
  out.writeln(
    'Read-only report; no acceptance or review authority is granted.\n',
  );
  if (report['id'] != null) {
    out.writeln('Observation: `${cell(report['id'])}`\n');
  }
  if (report['ready'] != null) out.writeln('Ready: **${report['ready']}**\n');
  if (report['blockers'] is List) {
    for (final blocker in report['blockers'] as List) {
      out.writeln('- ${cell(blocker)}');
    }
    out.writeln();
  }
  if (report['paths'] is List) {
    out.writeln('| Path | Contracts | Ownership | Classification |');
    out.writeln('| --- | --- | --- | --- |');
    for (final row in report['paths'] as List) {
      out.writeln(
        '| `${cell(row['path'])}` | ${cell(row['contracts'])} | ${cell(row['ownership'])} | ${cell(row['classification']['kind'])} |',
      );
    }
  }
  final checks = report['checksDetail'] ?? report['checks'];
  if (checks is List) {
    out.writeln('\n## Checks\n');
    out.writeln('| Check | Status | Host | Command |');
    out.writeln('| --- | --- | --- | --- |');
    for (final check in checks) {
      out.writeln(
        '| ${cell(check['name'])} | ${cell(check['status'])} | ${cell(check['host'] ?? 'portable')} | `${cell((check['argv'] as List).join(' '))}` |',
      );
    }
  }
  for (final name in [
    'reviews',
    'releaseIdentity',
    'migrations',
    'observations',
  ]) {
    if (report[name] is List && (report[name] as List).isNotEmpty) {
      out.writeln('\n## $name\n');
      for (final value in report[name] as List) {
        out.writeln('- ${cell(value)}');
      }
    }
  }
  if (report['overlap'] != null) {
    out.writeln('\n## Path overlap\n\n${cell(report['overlap'])}');
  }
  if (report['next'] != null) out.writeln('\n${report['next']}');
  return out.toString();
}
