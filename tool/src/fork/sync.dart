import 'dart:io';

import 'package:path/path.dart' as p;

import 'git.dart';
import 'model.dart';
import 'normalize.dart';
import 'registry.dart';

class VendorSync {
  VendorSync(this.registry)
    : git = registry.git,
      normalizer = Normalizer(
        registry.git,
        registry.read('.fork/branding.yaml'),
      );
  final Registry registry;
  final ForkGit git;
  final Normalizer normalizer;
  String get devRef => 'refs/heads/${registry.config['development']}';
  String get vendorRef => 'refs/heads/${registry.config['vendor']}';
  String get productBaseRef => 'refs/reclash/product-base/current';
  String productBaseObservationRef(String id) =>
      'refs/reclash/product-base/prepared/$id';

  File receiptFile(String id) {
    identifier(id);
    final file = File(p.join(git.stateRoot, id, 'receipt.json'));
    rejectSymlinks(file.path);
    return file;
  }

  Map<String, dynamic> receipt(String id) {
    final r = readJson(receiptFile(id));
    if (r['root'] != git.root || r['id'] != id) {
      reject('Receipt belongs to another repository/run');
    }
    return r;
  }

  void save(String id, Map<String, dynamic> r) =>
      atomicJson(receiptFile(id), r);

  void sourceIdentity() {
    final source = object(registry.config['source'], 'source');
    final url = git.run([
      'remote',
      'get-url',
      text(source['remote'], 'remote'),
    ]).trim();
    if (url != source['url']) {
      reject('Source URL mismatch: expected ${source['url']}, found $url');
    }
  }

  Map<String, dynamic> inspect(String source) {
    sourceIdentity();
    final raw = git.oid(source);
    final dev = git.oid(devRef);
    final normalized = normalizer.apply(raw);
    final residual = normalized.residual(dev);
    return {
      'source': raw,
      'sourceTree': git.tree(raw),
      'dev': dev,
      'devTree': git.tree(dev),
      'vendor': git.exists(vendorRef) ? git.oid(vendorRef) : null,
      'productBase': git.exists(productBaseRef)
          ? git.oid(productBaseRef)
          : null,
      'normalizer': normalizer.fingerprint,
      'registry': registry.fingerprint,
      'normalizedPaths': normalized.changed,
      'residual': residual,
      'impact': registry.impact(residual),
      'dirtyEntries': git.dirty.length,
      'blockers': markers(git, dev),
      'audit':
          'Review every residual against intended downstream behavior; path matches alone are not proof.',
    };
  }

  Map<String, dynamic> prepare(
    String id, {
    String? source,
    bool bootstrap = false,
    String? audit,
    bool recipeMigration = false,
    String? after,
  }) {
    identifier(id);
    if (after != null && (bootstrap || recipeMigration || audit != null)) {
      reject(
        '--after cannot be combined with bootstrap, recipe migration or audit',
      );
    }
    final predecessor = after == null ? null : chainPredecessor(after);
    sourceIdentity();
    if (receiptFile(id).parent.existsSync() ||
        git.exists('refs/heads/sync/$id') ||
        git.exists('refs/reclash/prepared/$id') ||
        git.exists(productBaseObservationRef(id)) ||
        git.exists(chainObservationRef(id)) ||
        git.exists('refs/reclash/upstream/$id')) {
      reject('Observation ID exists; inspect it or choose another ID');
    }
    final dev = git.oid(devRef);
    final oldVendor = git.exists(vendorRef) ? git.oid(vendorRef) : null;
    final oldProductBase = git.exists(productBaseRef)
        ? git.oid(productBaseRef)
        : null;
    if (bootstrap && oldVendor != null) reject('Vendor is already initialized');
    if (bootstrap && oldProductBase != null) {
      reject('Product base is already initialized');
    }
    if (!bootstrap && oldVendor == null) {
      reject('Audit and bootstrap the vendor first');
    }
    if (!bootstrap && oldProductBase == null) {
      reject('Product base is not initialized; migrate product history first');
    }
    if (!bootstrap && !git.firstParentAncestor(oldProductBase!, dev)) {
      reject(
        'Accepted product base is not on the development first-parent history',
      );
    }
    if (!bootstrap &&
        git
            .run(['rev-list', '--merges', '$oldProductBase..$dev'])
            .trim()
            .isNotEmpty) {
      reject(
        'Development history after product base must be linear before sync',
      );
    }
    if (!bootstrap) assertProductBase(oldProductBase!, oldVendor!);
    if (bootstrap && (audit == null || audit.trim().isEmpty)) {
      reject('Bootstrap requires --audit with the reviewed inspection digest');
    }
    assertSafeCheckout();
    String raw;
    if (source != null) {
      raw = git.oid(source);
    } else {
      if (bootstrap) reject('Bootstrap requires an explicit local source OID');
      final configured = object(registry.config['source'], 'source');
      final ref = 'refs/reclash/upstream/$id';
      git.run([
        'fetch',
        '--no-tags',
        '--no-recurse-submodules',
        configured['remote'] as String,
        '${configured['ref']}:$ref',
      ]);
      raw = git.oid(ref);
    }
    final inspection = bootstrap ? inspect(raw) : null;
    if (bootstrap && digest(inspection!) != audit) {
      reject('Bootstrap audit digest differs; inspect current inputs again');
    }
    if (recipeMigration && (bootstrap || oldVendor == null)) {
      reject('Recipe migration requires an accepted vendor');
    }
    final replayTip = predecessor?['candidate'] as String? ?? dev;
    final observedVendor = predecessor?['prepared'] as String? ?? oldVendor;
    final base =
        predecessor?['preparedBase'] as String? ??
        (bootstrap ? raw : oldProductBase!);
    if (!git.firstParentAncestor(base, replayTip)) {
      reject('Replay base must be on the development first-parent history');
    }
    if (git
        .run(['rev-list', '--merges', '$base..$replayTip'])
        .trim()
        .isNotEmpty) {
      reject('Development history after replay base must be linear');
    }
    final rawRef = 'refs/reclash/upstream/$id';
    if (observedVendor != null) {
      final old = provenance(observedVendor);
      final changedRecipe = old['Normalizer'] != normalizer.fingerprint;
      if (recipeMigration) {
        if (!changedRecipe ||
            raw != old['Upstream-Commit'] ||
            audit != digest(inspect(raw))) {
          reject(
            'Recipe migration requires a changed recipe, the exact accepted raw source and its reviewed inspection digest',
          );
        }
      } else if (changedRecipe) {
        reject(
          'Normalizer changed; inspect the accepted raw source and prepare --recipe-migration with --audit separately',
        );
      }
      if (after == null &&
          !recipeMigration &&
          git.tree(old['Upstream-Commit']!) == git.tree(raw)) {
        if (!git.exists(rawRef)) git.createRef(rawRef, raw);
        git.createRef('refs/reclash/prepared/$id', oldVendor!);
        final dir = receiptFile(id).parent..createSync(recursive: true);
        final archive = p.join(dir.path, 'snapshot.bundle');
        git.run([
          'bundle',
          'create',
          archive,
          rawRef,
          'refs/reclash/prepared/$id',
          if (git.exists(productBaseRef)) productBaseRef,
          devRef,
        ]);
        git.run(['bundle', 'verify', archive]);
        return {
          'id': id,
          'status': 'history-only',
          'source': raw,
          'vendor': oldVendor,
          'archive': archive,
        };
      }
    }
    if (!git.exists(rawRef)) git.createRef(rawRef, raw);
    final normalized = normalizer.apply(raw);
    final tree = normalized.write();
    final vendor = git.commitTree(
      tree,
      [?observedVendor],
      'chore(sync): observe upstream snapshot $id\n\nChangelog: skip\nUpstream-Commit: $raw\nUpstream-Tree: ${git.tree(raw)}\nNormalizer: ${normalizer.fingerprint}\nNormalized-Tree: $tree',
    );
    git.createRef('refs/reclash/prepared/$id', vendor);
    final preparedBase = productBaseCommit(id, vendor);
    git.createRef(productBaseObservationRef(id), preparedBase);
    final checkout = p.join(git.root, '.claude', 'worktrees', 'fork-$id');
    if (FileSystemEntity.typeSync(checkout) != FileSystemEntityType.notFound) {
      reject('Candidate path already exists');
    }
    final paths = bootstrap
        ? normalized.residual(dev)
        : git.changed(observedVendor!, vendor);
    final rawPaths = bootstrap
        ? <String>[]
        : git.changed(provenance(observedVendor!)['Upstream-Commit']!, raw);
    final gitlinkPaths = {
      for (final e in [
        ...git.entries(raw),
        if (observedVendor != null)
          ...git.entries(provenance(observedVendor)['Upstream-Commit']!),
      ])
        if (e.mode == '160000') e.path,
    };
    final r = <String, dynamic>{
      'v': 1,
      'id': id,
      'root': git.root,
      'dev': dev,
      'vendor': oldVendor,
      'productBase': oldProductBase,
      'source': raw,
      'prepared': vendor,
      'preparedBase': preparedBase,
      'worktree': checkout,
      'base': base,
      'after': ?predecessor,
      'replaySource': git
          .run(['rev-list', '--reverse', '--first-parent', '$base..$replayTip'])
          .trim()
          .split('\n')
          .where((commit) => commit.isNotEmpty)
          .toList(),
      'bootstrap': bootstrap,
      'recipeMigration': recipeMigration,
      'registry': registry.fingerprint,
      'normalizer': normalizer.fingerprint,
      'paths': paths,
      'impact': registry.impact(paths),
      'rawPaths': rawPaths,
      'coreReview': rawPaths.any(
        (path) =>
            path == '.gitmodules' ||
            gitlinkPaths.contains(path) ||
            path.startsWith('core/'),
      ),
    };
    if (predecessor != null) {
      assertPredecessor(predecessor);
      git.createRef(chainObservationRef(id), replayTip);
    }
    save(id, r);
    git.run(['worktree', 'add', '-b', 'sync/$id', '--', checkout, replayTip]);
    git.run([
      'worktree',
      'lock',
      '--reason',
      'ReClash vendor candidate $id',
      checkout,
    ]);
    final target = ForkGit(checkout);
    final rebased = target.result(['rebase', '--onto', preparedBase, base]);
    r['rebaseExit'] = rebased.exitCode;
    r['rebaseLog'] = '${rebased.stdout}\n${rebased.stderr}';
    save(id, r);
    if (rebased.exitCode != 0 && target.run(['ls-files', '-u']).isEmpty) {
      reject(
        'Rebase failed without index conflicts; inspect candidate: $checkout',
      );
    }
    if (rebased.exitCode == 0) {
      if (bootstrap && target.tree('HEAD') != git.tree(dev)) {
        reject('Bootstrap replay changed the downstream tree');
      }
      preserveOwned(target, replayTip);
    }
    bundle(id, r);
    return {
      'id': id,
      'status': bootstrap ? 'bootstrap-candidate' : 'rebase-candidate',
      'worktree': checkout,
      'productBase': preparedBase,
      'impact': r['impact'],
      'coreReview': r['coreReview'],
    };
  }

  String chainObservationRef(String id) => 'refs/reclash/predecessor/$id';

  void assertPredecessor(
    Map<String, dynamic> captured, {
    bool recovering = false,
  }) {
    final current = chainPredecessor(
      text(captured['id'], 'predecessor id'),
      validateAccepted: !recovering,
    );
    if (digest(current) != digest(captured)) {
      reject('Predecessor inputs moved after preparation');
    }
  }

  Map<String, dynamic> chainPredecessor(
    String id, {
    bool validateAccepted = true,
  }) {
    final r = receipt(id);
    if (r['recipeMigration'] != true ||
        r['bootstrap'] != false ||
        r['after'] != null ||
        r.containsKey('accepted')) {
      reject('Predecessor must be a standalone unaccepted recipe migration');
    }
    assertInputs(r, validateAccepted: validateAccepted);
    final target = ForkGit(text(r['worktree'], 'predecessor worktree'));
    target.assertClean();
    final operation =
        target.rebaseInProgress ||
        ['MERGE_HEAD', 'CHERRY_PICK_HEAD', 'REVERT_HEAD'].any(target.exists) ||
        ['sequencer', 'BISECT_START'].any((name) {
          final path = target.run(['rev-parse', '--git-path', name]).trim();
          return FileSystemEntity.typeSync(
                p.isAbsolute(path) ? path : p.join(target.root, path),
              ) !=
              FileSystemEntityType.notFound;
        });
    if (operation) reject('Predecessor has an operation in progress');
    final candidate = target.oid('HEAD');
    if (target.common != git.common ||
        target.run(['symbolic-ref', '-q', 'HEAD']).trim() !=
            'refs/heads/sync/$id' ||
        git.oid('refs/heads/sync/$id') != candidate ||
        !target.firstParentAncestor(r['preparedBase'] as String, candidate) ||
        target
            .run(['rev-list', '--merges', '${r['preparedBase']}..$candidate'])
            .trim()
            .isNotEmpty) {
      reject('Predecessor must be a linear candidate on its prepared base');
    }
    final policy = Registry(target);
    if (policy.fingerprint != registry.fingerprint ||
        VendorSync(policy).normalizer.fingerprint != normalizer.fingerprint) {
      reject('Predecessor contracts/config differ from current policy');
    }
    preservePolicyCheck(target, r['dev'] as String);
    if (markers(target, candidate).isNotEmpty) {
      reject('Conflict markers in predecessor');
    }
    final archive = p.join(receiptFile(id).parent.path, 'snapshot.bundle');
    rejectSymlinks(archive);
    git.run(['bundle', 'verify', archive]);
    final heads = <String, String>{
      for (final line
          in git.run(['bundle', 'list-heads', archive]).trim().split('\n'))
        if (line.contains(' '))
          line.substring(line.indexOf(' ') + 1): line.split(' ').first,
    };
    if (heads['refs/reclash/upstream/$id'] != r['source'] ||
        heads['refs/reclash/prepared/$id'] != r['prepared'] ||
        heads[productBaseObservationRef(id)] != r['preparedBase'] ||
        !heads.containsKey('refs/heads/sync/$id') ||
        (heads['refs/heads/sync/$id'] != r['dev'] &&
            !git.firstParentAncestor(
              heads['refs/heads/sync/$id']!,
              candidate,
            )) ||
        heads[productBaseRef] != r['productBase']) {
      reject('Predecessor bundle does not match protected observations');
    }
    return {
      'id': id,
      'receipt': digest(r),
      'candidate': candidate,
      'prepared': r['prepared'],
      'preparedBase': r['preparedBase'],
      'registry': registry.fingerprint,
      'normalizer': normalizer.fingerprint,
    };
  }

  void assertSafeCheckout() {
    for (final name in ['merge', 'filter']) {
      final configured = git.result([
        'config',
        '--get-regexp',
        '^$name\\..*\\.(driver|clean|smudge|process)\$',
      ]);
      final drivers = configured.stdout
          .toString()
          .trim()
          .split('\n')
          .where((line) => line.isNotEmpty);
      final standardLfs = RegExp(
        r'^filter\.lfs\.(clean|smudge|process) git-lfs (clean -- %f|smudge -- %f|filter-process)$',
      );
      if (configured.exitCode == 0 &&
          drivers.any((line) => !standardLfs.hasMatch(line))) {
        reject('Review configured $name drivers before source checkout');
      }
    }
  }

  void preserveOwned(ForkGit target, String original) {
    for (final path in strings(registry.config['owned'], 'owned')) {
      if (git.entries(original).any((e) => e.path == path)) {
        target.run([
          'restore',
          '--source=$original',
          '--staged',
          '--worktree',
          '--',
          path,
        ]);
      } else if (target.result([
            'ls-files',
            '--error-unmatch',
            '--',
            path,
          ]).exitCode ==
          0) {
        target.run(['rm', '-f', '--', path]);
      }
    }
    if (!git.entries(original).any((e) => e.path == 'pubspec.yaml')) return;
    final file = File(p.join(target.root, 'pubspec.yaml'));
    if (!file.existsSync()) reject('Product manifest was deleted');
    final version = RegExp(
      r'^version:.*$',
      multiLine: true,
    ).firstMatch(git.read(original, 'pubspec.yaml'))?.group(0);
    final current = file.readAsStringSync();
    if (version != null &&
        !current.contains(
          RegExp(r'^(<<<<<<<|=======|>>>>>>>)', multiLine: true),
        )) {
      file.writeAsStringSync(
        current.replaceAll(RegExp(r'^version:.*$', multiLine: true), version),
      );
      target.run(['add', '--', 'pubspec.yaml']);
    }
  }

  void bundle(String id, Map<String, dynamic> r) {
    final dir = receiptFile(id).parent;
    final refs = [
      'refs/reclash/upstream/$id',
      'refs/reclash/prepared/$id',
      productBaseObservationRef(id),
      if (r['after'] != null) chainObservationRef(id),
      if (git.exists(productBaseRef)) productBaseRef,
      'refs/heads/sync/$id',
    ];
    final temp = p.join(dir.path, 'snapshot.bundle.tmp');
    git.run(['bundle', 'create', temp, ...refs]);
    git.run(['bundle', 'verify', temp]);
    File(temp).renameSync(p.join(dir.path, 'snapshot.bundle'));
    r['archive'] = {
      'refs': refs,
      'submodules':
          'External objects are not included; archive pinned Core separately for offline recovery.',
    };
    save(id, r);
  }

  Map<String, String> provenance(String vendor) {
    final body = git.run(['show', '-s', '--format=%B', vendor]);
    final found = <String, String>{};
    for (final line in body.split('\n')) {
      final i = line.indexOf(': ');
      if (i > 0) found[line.substring(0, i)] = line.substring(i + 2);
    }
    for (final key in [
      'Upstream-Commit',
      'Upstream-Tree',
      'Normalizer',
      'Normalized-Tree',
    ]) {
      if (!found.containsKey(key)) reject('Missing vendor provenance: $key');
    }
    if (git.tree(vendor) != found['Normalized-Tree'] ||
        git.tree(found['Upstream-Commit']!) != found['Upstream-Tree']) {
      reject('Vendor provenance does not match objects');
    }
    return found;
  }

  String productBaseCommit(String id, String vendor) {
    final source = provenance(vendor);
    return git.commitTree(
      git.tree(vendor),
      const [],
      'chore(sync): establish product base $id\n\nChangelog: skip\nVendor-Snapshot: $vendor\nUpstream-Commit: ${source['Upstream-Commit']}\nUpstream-Tree: ${source['Upstream-Tree']}\nNormalizer: ${source['Normalizer']}\nNormalized-Tree: ${source['Normalized-Tree']}',
    );
  }

  void assertProductBase(String base, String vendor) {
    final baseMessage = git.run(['show', '-s', '--format=%B', base]);
    final baseParents = git.run(['show', '-s', '--format=%P', base]).trim();
    final baseSource = provenance(base);
    final vendorSource = provenance(vendor);
    if (baseParents.isNotEmpty ||
        git.tree(base) != git.tree(vendor) ||
        !baseMessage.split('\n').contains('Vendor-Snapshot: $vendor') ||
        baseSource['Upstream-Commit'] != vendorSource['Upstream-Commit'] ||
        baseSource['Upstream-Tree'] != vendorSource['Upstream-Tree'] ||
        baseSource['Normalizer'] != vendorSource['Normalizer'] ||
        baseSource['Normalized-Tree'] != vendorSource['Normalized-Tree']) {
      reject('Product base does not match its normalized vendor snapshot');
    }
  }

  Map<String, dynamic> verify(
    String id, {
    List<String> reviews = const [],
    List<String> waivers = const [],
  }) {
    final r = receipt(id);
    r.remove('verified');
    save(id, r);
    assertInputs(r);
    final target = ForkGit(r['worktree'] as String);
    if (target.rebaseInProgress) {
      reject('Finish the candidate rebase before verification');
    }
    target.assertClean();
    final candidate = target.oid('HEAD');
    r['replayed'] = target
        .run([
          'rev-list',
          '--reverse',
          '--first-parent',
          '${r['preparedBase']}..$candidate',
        ])
        .trim()
        .split('\n')
        .where((commit) => commit.isNotEmpty)
        .toList();
    if (target.run(['symbolic-ref', '-q', 'HEAD']).trim() !=
        'refs/heads/sync/$id') {
      reject('Candidate worktree changed branch');
    }
    if (!target.firstParentAncestor(r['preparedBase'] as String, candidate) ||
        target
            .run(['rev-list', '--merges', '${r['preparedBase']}..$candidate'])
            .trim()
            .isNotEmpty) {
      reject('Candidate must be a linear replay on the prepared product base');
    }
    final current = Registry(target);
    if (current.fingerprint != registry.fingerprint ||
        VendorSync(current).normalizer.fingerprint != normalizer.fingerprint) {
      reject(
        'Candidate contracts/config differ; review policy changes explicitly and prepare again',
      );
    }
    preservePolicyCheck(target, r['dev'] as String);
    final blockers = markers(target, candidate);
    if (blockers.isNotEmpty) {
      reject('Conflict markers in candidate: ${blockers.join(', ')}');
    }
    final candidatePaths = target.changed(
      r['preparedBase'] as String,
      candidate,
    );
    final impact = registry.impact(
      {
        ...strings(r['paths'], 'paths'),
        ...candidatePaths,
        if (r['after'] != null)
          ...strings(
            receipt(object(r['after'], 'after')['id'] as String)['paths'],
            'predecessor paths',
          ),
      }.toList(),
    );
    r['impact'] = impact;
    final affected = object(impact['features'], 'features');
    final gaps = affected.keys
        .where(
          (key) =>
              registry.features[key]!.critical &&
              registry.features[key]!.uncovered.isNotEmpty,
        )
        .toList();
    if (gaps.isNotEmpty) {
      reject('Uncovered critical invariants: ${gaps.join(', ')}');
    }
    final unknown = strings(impact['unclassified'], 'unclassified');
    final requiredReviews = <String>{
      ...strings(impact['critical'], 'critical'),
      if (unknown.isNotEmpty) 'unclassified',
      if (r['coreReview'] == true ||
          (r['after'] != null &&
              receipt(
                    object(r['after'], 'after')['id'] as String,
                  )['coreReview'] ==
                  true) ||
          candidatePaths.any(
            (path) => path == '.gitmodules' || path.startsWith('core/'),
          ))
        'core-source',
      if (r['bootstrap'] == true) 'bootstrap-audit',
      if (r['recipeMigration'] == true || r['after'] != null)
        'normalization-policy',
    };
    if (!reviews.toSet().containsAll(requiredReviews)) {
      reject(
        'Explicit authorized review required: ${requiredReviews.join(', ')}',
      );
    }
    final selectedChecks = strings(impact['checks'], 'checks');
    if (waivers.any((name) => !selectedChecks.contains(name))) {
      reject('Unknown check waiver');
    }
    final results = <String, dynamic>{};
    final versions = <String, String>{};
    for (final name in strings(impact['checks'], 'checks')) {
      final check = object(registry.checks[name], name);
      final argv = strings(check['argv'], name);
      if (waivers.contains(name)) {
        results[name] = {
          'status': 'waived',
          'authority': 'Explicit maintainer waiver required; not a test pass.',
        };
        continue;
      }
      if (check['host'] != null && check['host'] != Platform.operatingSystem) {
        reject(
          'Check $name requires ${check['host']}; obtain host evidence or an explicitly authorized --waive-check $name',
        );
      }
      final cwd = check['cwd'] == null
          ? target.root
          : p.join(target.root, check['cwd'] as String);
      final log = File(p.join(receiptFile(id).parent.path, '$name.log'));
      ProcessResult result;
      try {
        versions.putIfAbsent(argv.first, () {
          final version = Process.runSync(argv.first, [
            argv.first == 'go' ? 'version' : '--version',
          ], workingDirectory: cwd);
          final value = '${version.stdout}\n${version.stderr}'.trim();
          return value.length > 4096 ? value.substring(0, 4096) : value;
        });
        result = Process.runSync(
          argv.first,
          argv.skip(1).toList(),
          workingDirectory: cwd,
        );
      } on ProcessException catch (e) {
        throw ForkException(
          'Missing check tool: ${argv.first}: ${e.message}',
          code: 3,
        );
      }
      log.writeAsStringSync('${result.stdout}\n${result.stderr}');
      results[name] = {
        'argv': argv,
        'cwd': check['cwd'],
        'exit': result.exitCode,
      };
      if (result.exitCode != 0) {
        r.remove('verified');
        r['checks'] = results;
        save(id, r);
        reject('Check $name failed (${result.exitCode}); see ${log.path}');
      }
    }
    target.assertClean();
    if (target.oid('HEAD') != candidate ||
        Registry(target).fingerprint != registry.fingerprint ||
        VendorSync(Registry(target)).normalizer.fingerprint !=
            normalizer.fingerprint) {
      reject('Checks changed the candidate');
    }
    assertInputs(r);
    r['verified'] = {
      'predecessor': r['after'],
      'commit': candidate,
      'tree': target.tree(candidate),
      'productBase': r['preparedBase'],
      'registry': registry.fingerprint,
      'normalizer': normalizer.fingerprint,
      'reviews': reviews,
      'waivers': waivers,
      'toolVersions': versions,
      'checks': results,
    };
    save(id, r);
    bundle(id, r);
    return {
      'id': id,
      'status': waivers.isEmpty ? 'verified' : 'verified-with-waivers',
      'candidate': candidate,
      'productBase': r['preparedBase'],
      'checks': results.keys.toList(),
    };
  }

  void preservePolicyCheck(ForkGit target, String original) {
    for (final path in strings(registry.config['owned'], 'owned')) {
      final before = git
          .entries(original)
          .where((e) => e.path == path)
          .map((e) => e.oid)
          .firstOrNull;
      final after = target
          .entries('HEAD')
          .where((e) => e.path == path)
          .map((e) => e.oid)
          .firstOrNull;
      if (before != after) reject('Downstream-owned file changed: $path');
    }
    if (git.files(original).contains('pubspec.yaml')) {
      final pattern = RegExp(r'^version:.*$', multiLine: true);
      if (pattern.firstMatch(git.read(original, 'pubspec.yaml'))?.group(0) !=
          pattern.firstMatch(target.read('HEAD', 'pubspec.yaml'))?.group(0)) {
        reject('Product version changed during sync');
      }
    }
  }

  void assertInputs(
    Map<String, dynamic> r, {
    bool recovering = false,
    bool validateAccepted = true,
  }) {
    if (r['registry'] != registry.fingerprint ||
        r['normalizer'] != normalizer.fingerprint) {
      reject('Policy/normalizer changed after preparation');
    }
    if (validateAccepted && !recovering && git.oid(devRef) != r['dev']) {
      reject('Development branch moved; reconcile a new candidate');
    }
    final vendor = git.exists(vendorRef) ? git.oid(vendorRef) : null;
    final oldVendor = r['vendor'] as String?;
    final prepared = r['prepared'] as String;
    if (validateAccepted && recovering) {
      if (vendor != oldVendor && vendor != prepared) {
        reject('Vendor ref changed during interrupted acceptance');
      }
    } else if (validateAccepted && vendor != oldVendor) {
      reject('Vendor branch moved; reconcile a new candidate');
    }
    final productBase = git.exists(productBaseRef)
        ? git.oid(productBaseRef)
        : null;
    final oldProductBase = r['productBase'] as String?;
    final preparedBase = r['preparedBase'] as String;
    if (oldProductBase != null && oldVendor != null) {
      assertProductBase(oldProductBase, oldVendor);
    }
    if (validateAccepted && recovering) {
      if (productBase != oldProductBase && productBase != preparedBase) {
        reject('Product-base ref changed during interrupted acceptance');
      }
    } else if (validateAccepted && productBase != oldProductBase) {
      reject('Product base moved; reconcile a new candidate');
    }
    if (git.oid('refs/reclash/prepared/${r['id']}') != prepared ||
        git.oid(productBaseObservationRef(r['id'] as String)) != preparedBase ||
        git.oid('refs/reclash/upstream/${r['id']}') != r['source']) {
      reject('Protected observation refs changed');
    }
    provenance(prepared);
    assertProductBase(preparedBase, prepared);
    final after = r['after'] == null ? null : object(r['after'], 'after');
    if (after != null) {
      assertPredecessor(after, recovering: recovering);
      if (git.oid(chainObservationRef(r['id'] as String)) !=
          after['candidate']) {
        reject('Protected predecessor observation changed');
      }
    }
    final parents = git.run(['show', '-s', '--format=%P', prepared]).trim();
    if (parents != (after?['prepared'] ?? oldVendor ?? '')) {
      reject('Vendor snapshot parent chain changed');
    }
  }

  Map<String, dynamic> accept(String id) {
    final r = receipt(id);
    final verified = object(r['verified'], 'verified receipt required');
    final target = ForkGit(r['worktree'] as String);
    target.assertClean();
    final candidate = target.oid('HEAD');
    if (digest({'after': verified['predecessor']}) !=
            digest({'after': r['after']}) ||
        candidate != verified['commit'] ||
        target.tree(candidate) != verified['tree'] ||
        verified['productBase'] != r['preparedBase'] ||
        verified['registry'] != registry.fingerprint ||
        verified['normalizer'] != normalizer.fingerprint) {
      reject('Verification receipt is stale');
    }
    final recovering = git.oid(devRef) == candidate;
    assertInputs(r, recovering: recovering);
    final current = Registry(target);
    if (current.fingerprint != registry.fingerprint ||
        VendorSync(current).normalizer.fingerprint != normalizer.fingerprint ||
        target.common != git.common ||
        target.run(['symbolic-ref', '-q', 'HEAD']).trim() !=
            'refs/heads/sync/$id') {
      reject('Candidate policy, repository or branch changed');
    }
    final worktrees = git.worktrees();
    if (worktrees.containsKey(vendorRef)) {
      reject('Vendor branch is checked out; detach it explicitly');
    }
    final devWorktree = worktrees[devRef];
    final checkout = devWorktree == null ? null : ForkGit(devWorktree);
    if (checkout != null && !recovering) checkout.assertClean();
    for (final archive in developmentArchives().skip(
      r['accepted'] == null ? 1 : 2,
    )) {
      final ref = text(archive['ref'], 'archive ref');
      if (git.exists(ref) &&
          (worktrees.containsKey(ref) || git.oid(ref) != archive['commit'])) {
        reject('Retained archive changed or is checked out: $ref');
      }
    }
    archiveDevelopment(id, r);
    if (!recovering) {
      git.run(['update-ref', devRef, candidate, r['dev'] as String]);
    }
    if (checkout != null) {
      final atCandidate =
          checkout.run(['write-tree']).trim() == git.tree(candidate) &&
          checkout.result(['diff', '--quiet', candidate, '--']).exitCode == 0 &&
          checkout
              .run(['ls-files', '--others', '--exclude-standard'])
              .trim()
              .isEmpty;
      if (!atCandidate) {
        if (checkout.run(['write-tree']).trim() !=
                git.tree(r['dev'] as String) ||
            checkout.result([
                  'diff',
                  '--quiet',
                  r['dev'] as String,
                  '--',
                ]).exitCode !=
                0 ||
            checkout
                .run(['ls-files', '--others', '--exclude-standard'])
                .trim()
                .isNotEmpty) {
          reject('Development checkout changed during interrupted acceptance');
        }
        checkout.run(['reset', '--hard', candidate]);
      }
      checkout.assertClean();
    }
    advanceRef(
      productBaseRef,
      r['productBase'] as String?,
      r['preparedBase'] as String,
    );
    advanceRef(vendorRef, r['vendor'] as String?, r['prepared'] as String);
    if (git.oid(productBaseRef) != r['preparedBase'] ||
        git.oid(vendorRef) != r['prepared'] ||
        !git.firstParentAncestor(
          r['preparedBase'] as String,
          git.oid(devRef),
        )) {
      reject('Accepted refs do not match the prepared product candidate');
    }
    r['accepted'] = candidate;
    save(id, r);
    pruneArchives();
    return {
      'id': id,
      'archive': r['developmentArchive'],
      'status': 'accepted',
      'dev': candidate,
      'vendor': r['prepared'],
      'productBase': r['preparedBase'],
    };
  }

  String developmentArchiveRef(String id) =>
      'refs/heads/archive/dev-before-$id';

  List<Map<String, dynamic>> developmentArchives() {
    final root = Directory(git.stateRoot);
    if (!root.existsSync()) return [];
    final archives = <Map<String, dynamic>>[];
    for (final directory
        in root.listSync(followLinks: false).whereType<Directory>()) {
      final file = File(p.join(directory.path, 'receipt.json'));
      if (!file.existsSync()) continue;
      rejectSymlinks(file.path);
      final r = readJson(file);
      if (r['root'] == git.root &&
          r['accepted'] != null &&
          r['developmentArchive'] != null) {
        final archive = object(r['developmentArchive'], 'development archive');
        final id = text(r['id'], 'archive observation id');
        identifier(id);
        if (archive['ref'] != developmentArchiveRef(id) ||
            archive['commit'] != r['dev'] ||
            archive['order'] is! int ||
            (archive['order'] as int) < 1) {
          reject('Invalid development archive receipt: $id');
        }
        archives.add(archive);
      }
    }
    archives.sort((a, b) => (b['order'] as int).compareTo(a['order'] as int));
    return archives;
  }

  void archiveDevelopment(String id, Map<String, dynamic> r) {
    final ref = developmentArchiveRef(id);
    final old = r['dev'] as String;
    final archive = r['developmentArchive'];
    if (archive == null) {
      if (git.exists(ref)) reject('Archive name already exists: $ref');
      final existing = developmentArchives();
      r['developmentArchive'] = {
        'ref': ref,
        'commit': old,
        'order': existing.isEmpty ? 1 : (existing.first['order'] as int) + 1,
      };
      save(id, r);
    } else {
      final captured = object(archive, 'development archive');
      if (captured['ref'] != ref || captured['commit'] != old) {
        reject('Archive receipt changed');
      }
    }
    if (git.exists(ref)) {
      if (git.oid(ref) != old) reject('Archive ref moved: $ref');
    } else {
      git.run(['update-ref', ref, old, '']);
    }
    final bundlePath = p.join(
      receiptFile(id).parent.path,
      'development-before.bundle',
    );
    rejectSymlinks(bundlePath);
    if (!File(bundlePath).existsSync()) {
      git.run(['bundle', 'create', bundlePath, ref]);
    }
    git.run(['bundle', 'verify', bundlePath]);
    if (!git
        .run(['bundle', 'list-heads', bundlePath])
        .split('\n')
        .contains('$old $ref')) {
      reject('Development archive bundle mismatch');
    }
  }

  void pruneArchives() {
    final worktrees = git.worktrees();
    for (final archive in developmentArchives().skip(2)) {
      final ref = text(archive['ref'], 'archive ref');
      if (!ref.startsWith('refs/heads/archive/dev-before-')) {
        reject('Invalid archive namespace');
      }
      if (!git.exists(ref)) continue;
      if (worktrees.containsKey(ref)) {
        reject('Archive is checked out; detach before pruning: $ref');
      }
      git.run([
        'update-ref',
        '-d',
        ref,
        text(archive['commit'], 'archive commit'),
      ]);
    }
  }

  void advanceRef(String ref, String? old, String next) {
    final current = git.exists(ref) ? git.oid(ref) : null;
    if (current == next) return;
    if (current != old) reject('$ref moved during interrupted acceptance');
    git.run(['update-ref', ref, next, old ?? '']);
  }

  static List<String> markers(ForkGit git, String rev) {
    final r = git.result([
      'grep',
      '-l',
      '-I',
      '-E',
      r'^(<<<<<<< |>>>>>>> |=======$)',
      rev,
      '--',
      ':!test/tool/fork*',
    ]);
    if (r.exitCode != 0 && r.exitCode != 1) {
      reject('Could not scan conflict markers');
    }
    return r.stdout
        .toString()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList();
  }
}
