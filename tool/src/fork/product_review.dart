import 'git.dart';
import 'model.dart';
import 'normalize.dart';
import 'registry.dart';

class ProductReview {
  ProductReview(this.registry);

  final Registry registry;
  ForkGit get git => registry.git;
  bool get enabled => registry.files.contains('.fork/product.yaml');

  Map<String, dynamic> policy() {
    if (!enabled) return {};
    final data = yamlObject(registry.read('.fork/product.yaml'), 'product');
    keys(data, 'v identity surfaces', 'product');
    if (data['v'] != 1) reject('Unsupported product review policy');
    for (final entry in object(data['identity'], 'identity').entries) {
      identifier(entry.key);
      final anchor = object(entry.value, entry.key);
      keys(anchor, 'preserve why watch', entry.key);
      text(anchor['preserve'], '${entry.key}.preserve');
      text(anchor['why'], '${entry.key}.why');
      patterns(anchor['watch'], '${entry.key}.watch');
    }
    for (final entry in object(data['surfaces'], 'surfaces').entries) {
      identifier(entry.key);
      patterns(entry.value, entry.key);
    }
    return data;
  }

  void patterns(Object? value, String where) {
    final paths = strings(value, where);
    if (paths.isEmpty) reject('$where needs watch patterns');
    for (final path in paths) {
      safePath(path, glob: true);
    }
  }

  Map<String, dynamic> draft({
    required Map<String, dynamic> inputs,
    required NormalizedTree incoming,
    required String baseline,
    required String downstream,
    required List<String> rawPaths,
    required Map<String, dynamic> pathMappings,
    List<String> predecessorPaths = const [],
    String? candidate,
    Map<String, dynamic>? previous,
  }) {
    final profile = policy();
    final before = {for (final e in git.entries(baseline)) e.path: e};
    final own = {for (final e in git.entries(downstream)) e.path: e};
    final next = {for (final e in incoming.entries) e.path: e};
    final result = {
      if (candidate != null)
        for (final e in git.entries(candidate)) e.path: e,
    };
    final sources = <String, List<String>>{};
    for (final raw in rawPaths) {
      var path = raw;
      for (final entry in pathMappings.entries) {
        if (raw == entry.key || raw.startsWith('${entry.key}/')) {
          path = '${entry.value}${raw.substring(entry.key.length)}';
          break;
        }
      }
      sources.putIfAbsent(path, () => []).add(raw);
    }
    final upstreamPaths = incoming.residual(baseline).toSet();
    final resultPaths = candidate == null
        ? <String>{}
        : git.changed(inputs['dev'] as String, candidate).toSet();
    final paths = {
      ...upstreamPaths,
      ...sources.keys,
      ...predecessorPaths,
      ...resultPaths,
    }.toList()..sort();
    final identity = object(profile['identity'] ?? {}, 'identity');
    final surfaces = object(profile['surfaces'] ?? {}, 'surfaces');
    final inventory = [
      for (final path in paths)
        {
          'path': path,
          'before': before[path]?.toJson(),
          'downstream': own[path]?.toJson(),
          'upstream': next[path]?.toJson(),
          if (candidate != null) 'candidate': result[path]?.toJson(),
          'rawPaths': sources[path] ?? <String>[],
          'upstreamChanged': upstreamPaths.contains(path),
          'predecessorChanged': predecessorPaths.contains(path),
          'resultChanged': resultPaths.contains(path),
          'identity': [
            for (final entry in identity.entries)
              if (strings(
                object(entry.value, entry.key)['watch'],
                'watch',
              ).any((pattern) => matches(pattern, path)))
                entry.key,
          ],
          'surfaces': [
            for (final entry in surfaces.entries)
              if (strings(
                entry.value,
                'surfaces',
              ).any((pattern) => matches(pattern, path)))
                entry.key,
          ],
        },
    ];
    final previousCards = previous == null
        ? <Map<String, dynamic>>[]
        : cards(previous);
    final covered = {
      for (final card in previousCards) ...strings(card['paths'], 'card paths'),
    };
    return {
      'v': 1,
      'inputs': {
        ...inputs,
        'baseline': baseline,
        'downstream': downstream,
        'normalized': productReviewDigest({
          for (final entry in incoming.entries) entry.path: entry.toJson(),
        }),
      },
      'candidate': candidate,
      'identity': identity,
      'inventory': inventory,
      'cards': <Map<String, dynamic>>[
        for (final card in previousCards)
          {
            ...card,
            'visual': {'status': 'not-checked', 'reason': '', 'approval': ''},
            'outcome': pendingOutcome(),
          },
        for (final row in inventory)
          if (!covered.contains(row['path']))
            {
              'id': 'change-${digest(row['path']!).substring(0, 12)}',
              'paths': [row['path']],
              'impact': visualSurface(row) ? 'product' : 'unassessed',
              'current': '',
              'incoming': '',
              'expected': '',
              'recommendation': '',
              'checklist': <String>[],
              'alternatives': <String>[],
              'decision': 'pending',
              'reason': '',
              'approval': '',
              'evidence': <Map<String, String>>[],
              'visual': {'status': 'not-checked', 'reason': '', 'approval': ''},
              'outcome': pendingOutcome(),
            },
      ],
    };
  }

  Map<String, dynamic> pendingOutcome() => {
    'status': 'pending',
    'evidence': <Map<String, String>>[],
  };

  bool visualSurface(Map<String, dynamic> row) =>
      strings(row['identity'], 'identity').isNotEmpty ||
      strings(row['surfaces'], 'surfaces').isNotEmpty;

  List<Map<String, dynamic>> cards(Map<String, dynamic> document) {
    final values = document['cards'];
    if (values is! List) reject('Product review cards must be a list');
    return values.map((value) => object(value, 'product review card')).toList();
  }

  List<Map<String, dynamic>> evidence(Object? value, String where) {
    if (value is! List) reject('$where must be a list');
    return [
      for (final item in value)
        (() {
          final entry = object(item, where);
          keys(entry, 'kind reference', where);
          if (!['code', 'visual', 'test'].contains(entry['kind'])) {
            reject('$where: invalid evidence kind');
          }
          text(entry['reference'], '$where.reference');
          return entry;
        })(),
    ];
  }

  Map<String, dynamic> assess(
    Map<String, dynamic>? document,
    Map<String, dynamic> expected, {
    required bool result,
  }) {
    if (document == null) {
      return {
        'status': 'missing',
        'blockers': ['Product ${result ? 'result ' : ''}review is missing'],
        'cards': <Map<String, dynamic>>[],
      };
    }
    keys(
      document,
      'v inputs candidate identity inventory cards',
      'product review',
    );
    final blockers = <String>[];
    if (document['v'] != 1) reject('Unsupported product review document');
    for (final key in ['inputs', 'identity', 'inventory', 'candidate']) {
      if (productReviewDigest(document[key]) !=
          productReviewDigest(expected[key])) {
        blockers.add('Product review $key is stale; regenerate the review');
      }
    }
    final inventory = {
      for (final value in expected['inventory'] as List)
        (value as Map)['path'] as String: object(value, 'inventory'),
    };
    final seen = <String>{};
    final ids = <String>{};
    final rows = <Map<String, dynamic>>[];
    for (final card in cards(document)) {
      keys(
        card,
        'id paths impact current incoming expected recommendation checklist alternatives decision reason approval evidence visual outcome',
        'product review card',
      );
      final id = text(card['id'], 'card id');
      identifier(id);
      if (!ids.add(id)) reject('Duplicate product review card: $id');
      final paths = strings(card['paths'], '$id.paths');
      if (paths.isEmpty) reject('$id has no paths');
      for (final path in paths) {
        safePath(path);
        if (!inventory.containsKey(path)) {
          blockers.add('$id: path outside the review inventory: $path');
        }
        if (!seen.add(path)) blockers.add('Path reviewed twice: $path');
      }
      final impact = card['impact'];
      if (!['unassessed', 'routine', 'product', 'uncertain'].contains(impact)) {
        reject('$id: invalid product impact');
      }
      final decision = card['decision'];
      if (![
        'pending',
        'keep',
        'adapt',
        'adopt',
        'reduce',
        'retire',
        'defer',
      ].contains(decision)) {
        reject('$id: invalid product decision');
      }
      if (impact == 'unassessed') {
        blockers.add('$id: product impact unassessed');
      }
      if (decision == 'pending' || (result && decision == 'defer')) {
        blockers.add('$id: product decision unresolved');
      }
      if (result && impact == 'uncertain') {
        blockers.add('$id: product impact remains uncertain');
      }
      for (final key in [
        'current',
        'incoming',
        'expected',
        'recommendation',
        'reason',
        'approval',
      ]) {
        if (card[key] is! String) reject('$id.$key must be a string');
        if (key != 'approval' && (card[key] as String).trim().isEmpty) {
          blockers.add('$id: $key is missing');
        }
      }
      final approvalRequired =
          impact != 'routine' ||
          ['reduce', 'retire', 'defer'].contains(decision);
      if (approvalRequired && (card['approval'] as String).trim().isEmpty) {
        blockers.add('$id: maintainer decision reference is missing');
      }
      final checklist = strings(card['checklist'], '$id.checklist');
      if (checklist.isEmpty) {
        blockers.add('$id: comparison checklist is missing');
      }
      if (strings(card['alternatives'], '$id.alternatives').length > 2) {
        reject('$id: present at most two alternatives');
      }
      final proof = evidence(card['evidence'], '$id.evidence');
      if (proof.isEmpty) blockers.add('$id: comparison evidence is missing');
      final visual = object(card['visual'], '$id.visual');
      keys(visual, 'status reason approval', '$id.visual');
      if (![
        'not-checked',
        'checked',
        'not-applicable',
        'waived',
      ].contains(visual['status'])) {
        reject('$id: invalid visual review status');
      }
      for (final key in ['reason', 'approval']) {
        if (visual[key] is! String) reject('$id.visual.$key must be a string');
      }
      if (visual['status'] == 'checked' &&
          (visual['approval'] as String).trim().isEmpty) {
        blockers.add('$id: maintainer visual verdict is missing');
      }
      if (!result &&
          visual['status'] == 'checked' &&
          !proof.any((entry) => entry['kind'] == 'visual')) {
        blockers.add('$id: pre-replay visual evidence is missing');
      }
      if (!result &&
          visual['status'] == 'waived' &&
          ((visual['reason'] as String).trim().isEmpty ||
              (visual['approval'] as String).trim().isEmpty)) {
        blockers.add('$id: visual waiver needs rationale and authority');
      }
      final outcome = object(card['outcome'], '$id.outcome');
      keys(outcome, 'status evidence', '$id.outcome');
      if (!['pending', 'confirmed', 'blocked'].contains(outcome['status'])) {
        reject('$id: invalid outcome status');
      }
      final outcomeProof = evidence(
        outcome['evidence'],
        '$id.outcome.evidence',
      );
      if (result) {
        if (outcome['status'] != 'confirmed' || outcomeProof.isEmpty) {
          blockers.add('$id: candidate outcome is not confirmed with evidence');
        }
        if (visual['status'] != 'not-checked' ||
            impact != 'routine' ||
            paths.any(
              (path) =>
                  inventory.containsKey(path) &&
                  visualSurface(inventory[path]!),
            )) {
          switch (visual['status']) {
            case 'checked':
              if (!outcomeProof.any((entry) => entry['kind'] == 'visual')) {
                blockers.add('$id: candidate visual evidence is missing');
              }
            case 'not-applicable':
            case 'waived':
              if ((visual['reason'] as String).trim().isEmpty ||
                  ((impact != 'routine' || visual['status'] == 'waived') &&
                      (visual['approval'] as String).trim().isEmpty)) {
                blockers.add(
                  '$id: visual exclusion needs rationale and authority',
                );
              }
            default:
              blockers.add('$id: candidate visual comparison is not checked');
          }
        }
      }
      rows.add({
        'id': id,
        'paths': paths,
        'impact': impact,
        'expected': card['expected'],
        'checklist': checklist,
        'recommendation': card['recommendation'],
        'decision': decision,
        'approval': card['approval'],
        'visual': visual,
        'outcome': outcome['status'],
      });
    }
    for (final path in inventory.keys.where((path) => !seen.contains(path))) {
      blockers.add('Product review does not cover $path');
    }
    return {
      'status': blockers.isNotEmpty
          ? 'incomplete'
          : rows.any((row) => (row['visual'] as Map)['status'] == 'waived')
          ? 'recorded-with-waivers'
          : 'recorded',
      'candidate': document['candidate'],
      'coveredPaths': seen.intersection(inventory.keys.toSet()).length,
      'totalPaths': inventory.length,
      'cards': rows,
      'blockers': blockers,
      'authority':
          'Recorded decisions and evidence are not acceptance authority.',
    };
  }

  void requireDecisionContinuity(
    Map<String, dynamic> before,
    Map<String, dynamic> after,
  ) {
    final original = {
      for (final card in cards(before))
        for (final path in strings(card['paths'], 'paths')) path: card,
    };
    for (final card in cards(after)) {
      for (final path in strings(card['paths'], 'paths')) {
        final old = original[path];
        if (old == null) continue;
        final changed = [
          'decision',
          'impact',
          'reason',
          'expected',
        ].any((key) => old[key] != card[key]);
        if (changed &&
            ((card['approval'] as String).trim().isEmpty ||
                card['approval'] == old['approval'])) {
          reject(
            'Changed product decision for $path needs a new maintainer reference',
          );
        }
      }
    }
  }

  void requireComplete(
    Map<String, dynamic>? document,
    Map<String, dynamic> expected, {
    required bool result,
  }) {
    final report = assess(document, expected, result: result);
    final blockers = strings(report['blockers'], 'product review blockers');
    if (blockers.isNotEmpty) reject(blockers.join('\n'));
  }
}

String productReviewDigest(Object? value) {
  Object? canonical(Object? value) => switch (value) {
    Map() => {
      for (final key in value.keys.cast<String>().toList()..sort())
        key: canonical(value[key]),
    },
    List() => value.map(canonical).toList(),
    _ => value,
  };
  return digest({'value': canonical(value)});
}
