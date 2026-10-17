import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'git.dart';
import 'model.dart';

class NormalizedTree {
  NormalizedTree(this.git, this.entries, this.blobs, this.changed);
  final ForkGit git;
  final List<TreeEntry> entries;
  final Map<String, List<int>> blobs;
  final List<String> changed;

  List<String> residual(String downstream) {
    final own = {for (final e in git.entries(downstream)) e.path: e};
    final base = {for (final e in entries) e.path: e};
    return {...own.keys, ...base.keys}
        .where(
          (path) =>
              own[path]?.mode != base[path]?.mode ||
              own[path]?.oid != base[path]?.oid,
        )
        .toList()
      ..sort();
  }

  String write() {
    final temp = Directory.systemTemp.createTempSync('reclash-normalize-');
    try {
      final env = {'GIT_INDEX_FILE': p.join(temp.path, 'index')};
      git.run(['read-tree', '--empty'], environment: env);
      final payload = File(p.join(temp.path, 'blob'));
      for (final e in entries) {
        final bytes = blobs[e.oid];
        if (bytes != null) {
          payload.writeAsBytesSync(bytes);
          final actual = git.run([
            'hash-object',
            '-w',
            '--no-filters',
            payload.path,
          ]).trim();
          if (actual != e.oid) reject('Blob identity mismatch');
        }
        git.run([
          'update-index',
          '--add',
          '--cacheinfo',
          '${e.mode},${e.oid},${e.path}',
        ], environment: env);
      }
      return git.run(['write-tree'], environment: env).trim();
    } finally {
      temp.deleteSync(recursive: true);
    }
  }
}

class Normalizer {
  Normalizer(this.git, String source)
    : recipe = yamlObject(source, 'branding') {
    keys(recipe, 'v preserve paths rules', 'branding');
    if (recipe['v'] != 1) reject('Unsupported normalization version');
    strings(recipe['preserve'], 'preserve');
    for (final entry in object(recipe['paths'], 'paths').entries) {
      safePath(entry.key);
      safePath(text(entry.value, 'paths'));
    }
    if (recipe['rules'] is! List) reject('rules must be a list');
    for (final value in recipe['rules'] as List) {
      final rule = object(value, 'rule');
      keys(rule, 'paths replace', 'rule');
      final paths = strings(rule['paths'], 'rule.paths');
      if (paths.isEmpty) reject('Empty rule paths');
      for (final path in paths) {
        safePath(path, glob: true);
      }
      final replacements = object(rule['replace'], 'replace');
      for (final entry in replacements.entries) {
        text(entry.key, 'replacement source');
        text(entry.value, 'replacement target');
        if ((entry.value as String).contains(entry.key)) {
          reject('Non-idempotent replacement: ${entry.key}');
        }
      }
    }
    final mappings = object(recipe['paths'], 'paths');
    for (final target in mappings.values.cast<String>()) {
      if (mappings.keys.any(
        (source) => target == source || target.startsWith('$source/'),
      )) {
        reject('Chained normalization path mapping: $target');
      }
    }
    final replacements = <MapEntry<String, String>>[];
    for (final value in recipe['rules'] as List) {
      final rule = object(value, 'rule');
      for (final entry in object(rule['replace'], 'replace').entries) {
        replacements.add(MapEntry(entry.key, entry.value as String));
      }
    }
    for (final target in replacements.map((entry) => entry.value)) {
      if (replacements.any((entry) => target.contains(entry.key))) {
        reject('Chained normalization replacement: $target');
      }
    }
  }
  final ForkGit git;
  final Map<String, dynamic> recipe;
  String get fingerprint {
    final implementation = <String, String>{};
    final dir = Directory(p.join(git.root, 'tool', 'src', 'fork'));
    if (dir.existsSync()) {
      for (final file
          in dir
              .listSync()
              .whereType<File>()
              .where(
                (f) => [
                  'normalize.dart',
                  'model.dart',
                  'git.dart',
                ].contains(p.basename(f.path)),
              )
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path))) {
        implementation[p.basename(file.path)] = file.readAsStringSync();
      }
    }
    return digest({'recipe': recipe, 'implementation': implementation});
  }

  NormalizedTree apply(String source) {
    final entries = <TreeEntry>[];
    final blobs = <String, List<int>>{};
    final changed = <String>[];
    final targets = <String>{};
    final paths = object(recipe['paths'], 'paths');
    final preserved = strings(recipe['preserve'], 'preserve');
    for (final entry in git.entries(source)) {
      var path = entry.path;
      for (final mapping in paths.entries) {
        if (path == mapping.key || path.startsWith('${mapping.key}/')) {
          path = '${mapping.value}${path.substring(mapping.key.length)}';
          break;
        }
      }
      safePath(path);
      if (!targets.add(path)) reject('Normalization path collision: $path');
      var oid = entry.oid;
      final rules = (recipe['rules'] as List)
          .map((value) => object(value, 'rule'))
          .where(
            (rule) => strings(rule['paths'], 'paths').any(
              (pattern) =>
                  matches(pattern, entry.path) || matches(pattern, path),
            ),
          )
          .toList();
      if (entry.blob && rules.isNotEmpty) {
        final bytes = git.blob(oid);
        String? content;
        if (!bytes.contains(0)) {
          try {
            content = utf8.decode(bytes);
          } on FormatException {
            content = null;
          }
        }
        if (content != null) {
          final original = content;
          for (var i = 0; i < preserved.length; i++) {
            if (content!.contains('\u0001FORK$i\u0001')) {
              reject('Reserved normalization token');
            }
            content = content.replaceAll(preserved[i], '\u0001FORK$i\u0001');
          }
          for (final rule in rules) {
            for (final e in object(rule['replace'], 'replace').entries) {
              content = content!.replaceAll(e.key, e.value as String);
            }
          }
          for (var i = 0; i < preserved.length; i++) {
            content = content!.replaceAll('\u0001FORK$i\u0001', preserved[i]);
          }
          if (content != original) {
            final encoded = utf8.encode(content!);
            oid = git.blobId(encoded);
            blobs[oid] = encoded;
          }
        }
      }
      entries.add(TreeEntry(entry.mode, oid, path));
      if (path != entry.path || oid != entry.oid) changed.add(entry.path);
    }
    entries.sort((a, b) => a.path.compareTo(b.path));
    for (final entry in entries) {
      var parent = p.posix.dirname(entry.path);
      while (parent != '.') {
        if (targets.contains(parent)) {
          reject('Normalization file/directory collision: $parent');
        }
        parent = p.posix.dirname(parent);
      }
    }
    return NormalizedTree(git, entries, blobs, changed..sort());
  }
}
