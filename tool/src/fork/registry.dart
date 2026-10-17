import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'git.dart';
import 'model.dart';

class Registry {
  Registry(this.git, {this.staged = false, this.revision}) {
    config = yamlObject(read('.fork/config.yaml'), 'config');
    keys(
      config,
      'v source development vendor budget checks sentinels full platforms owned',
      'config',
    );
    if (config['v'] != 1) reject('Unsupported config schema');
    final source = object(config['source'], 'source');
    keys(source, 'remote url ref', 'source');
    for (final key in ['remote', 'url', 'ref']) {
      text(source[key], 'source.$key');
    }
    if (!(source['ref'] as String).startsWith('refs/heads/')) {
      reject('Source must name a branch ref');
    }
    for (final name in ['development', 'vendor']) {
      final value = text(config[name], name);
      if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9/_-]*$').hasMatch(value)) {
        reject('Invalid branch: $value');
      }
    }
    if (config['budget'] is! int || (config['budget'] as int) < 512) {
      reject('Invalid budget');
    }
    for (final entry in checks.entries) {
      identifier(entry.key);
      final check = object(entry.value, entry.key);
      keys(check, 'argv cwd host', entry.key);
      if (check['host'] != null &&
          !['linux', 'windows', 'macos'].contains(check['host'])) {
        reject('Invalid check host: ${entry.key}');
      }
      final argv = strings(check['argv'], entry.key);
      if (argv.isEmpty ||
          ![
            'flutter',
            'dart',
            'git',
            'go',
            'cargo',
            'bash',
          ].contains(argv.first)) {
        reject('Unapproved executable: ${entry.key}');
      }
      if (check['cwd'] != null) safePath(text(check['cwd'], entry.key));
    }
    for (final entry in object(config['platforms'], 'platforms').entries) {
      safePath(entry.key, glob: true);
      for (final check in strings(entry.value, 'platforms')) {
        requireCheck(check);
      }
    }
    for (final check in strings(config['full'], 'full')) {
      requireCheck(check);
    }
    for (final path in strings(config['owned'], 'owned')) {
      safePath(path);
    }
    final paths =
        files
            .where(
              (file) =>
                  file.startsWith('.fork/features/') && file.endsWith('.yaml'),
            )
            .toList()
          ..sort();
    for (final path in paths) {
      final id = p.basenameWithoutExtension(path);
      if (p.dirname(path) != '.fork/features' || features.containsKey(id)) {
        reject('Nested/duplicate feature ID: $path');
      }
      features[id] = Feature(id, yamlObject(read(path), path));
    }
    if (features.isEmpty) reject('No feature contracts');
    for (final f in features.values) {
      for (final check in f.checks.keys) {
        requireCheck(check);
      }
      for (final dep in f.deps) {
        if (!features.containsKey(dep) || features[dep]!.state == 'retired') {
          reject('${f.id}: unavailable dependency $dep');
        }
      }
    }
    final visited = <String>{};
    final visiting = <String>{};
    void visit(String id) {
      if (visiting.contains(id)) reject('Dependency cycle at $id');
      if (!visited.add(id)) return;
      visiting.add(id);
      for (final dep in features[id]!.deps) {
        visit(dep);
      }
      visiting.remove(id);
    }

    for (final id in features.keys) {
      visit(id);
    }
    for (final entry in sentinels.entries) {
      safePath(entry.key, glob: true);
      for (final id in strings(entry.value, 'sentinel')) {
        if (!features.containsKey(id)) reject('Unknown sentinel: $id');
      }
    }
  }

  final ForkGit git;
  final bool staged;
  final String? revision;
  late final Map<String, dynamic> config;
  final Map<String, Feature> features = {};
  Map<String, dynamic> get checks => object(config['checks'], 'checks');
  Map<String, dynamic> get sentinels =>
      object(config['sentinels'], 'sentinels');
  String get fingerprint => digest({
    for (final file in files.where((f) => f.endsWith('.yaml')).toList()..sort())
      file: read(file),
  });
  void requireCheck(String id) {
    if (!checks.containsKey(id)) reject('Unknown check: $id');
  }

  List<String> get files {
    if (revision != null) return git.files(revision!, '.fork');
    if (staged) {
      return ForkGit.split(git.run(['ls-files', '-z', '--', '.fork']));
    }
    final dir = Directory(p.join(git.root, '.fork'));
    rejectSymlinks(dir.path);
    if (!dir.existsSync()) reject('Missing .fork metadata');
    return dir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .map((f) => p.relative(f.path, from: git.root))
        .toList();
  }

  String read(String path) {
    safePath(path);
    if (revision != null) return git.read(revision!, path);
    if (staged) return git.run(['show', ':$path']);
    final file = File(p.join(git.root, path));
    rejectSymlinks(file.path);
    return file.readAsStringSync();
  }

  Map<String, Set<String>> affected(Iterable<String> paths) {
    final selected = <String, Set<String>>{};
    for (final path in paths) {
      for (final f in features.values.where((f) => f.state != 'retired')) {
        if (f.watch.any((pattern) => matches(pattern, path))) {
          selected.putIfAbsent(f.id, () => {}).add(path);
        }
      }
      for (final sentinel in sentinels.entries) {
        if (matches(sentinel.key, path)) {
          for (final id in strings(sentinel.value, 'sentinel')) {
            selected.putIfAbsent(id, () => {}).add('sentinel:$path');
          }
        }
      }
    }
    var size = -1;
    while (size != selected.length) {
      size = selected.length;
      for (final id in selected.keys.toList()) {
        for (final dep in features[id]!.deps) {
          selected.putIfAbsent(dep, () => {'dependency:$id'});
        }
      }
      for (final f in features.values.where((f) => f.state != 'retired')) {
        if (f.deps.any(selected.containsKey)) {
          selected.putIfAbsent(f.id, () => {'dependent'});
        }
      }
    }
    return selected;
  }

  Map<String, dynamic> impact(List<String> paths) {
    final selected = affected(paths);
    final unknown =
        paths
            .where(
              (path) =>
                  !features.values.any(
                    (f) =>
                        f.state != 'retired' &&
                        f.watch.any((pattern) => matches(pattern, path)),
                  ) &&
                  !sentinels.keys.any((pattern) => matches(pattern, path)),
            )
            .toList()
          ..sort();
    final checksToRun = <String>{...strings(config['full'], 'full')};
    for (final id in selected.keys) {
      checksToRun.addAll(features[id]!.checks.keys);
    }
    for (final entry in object(config['platforms'], 'platforms').entries) {
      if (paths.any((path) => matches(entry.key, path))) {
        checksToRun.addAll(strings(entry.value, 'platforms'));
      }
    }
    final ids = selected.keys.toList()..sort();
    return {
      'features': {
        for (final id in ids)
          id: {
            'reasons': selected[id]!.toList()..sort(),
            'risk': features[id]!.data['risk'],
            'state': features[id]!.state,
            'uncovered': features[id]!.uncovered,
          },
      },
      'unclassified': unknown,
      'checks': checksToRun.toList(),
      'critical': ids.where((id) => features[id]!.critical).toList(),
    };
  }

  String context(List<String> paths, {String? id}) {
    if (id != null && !features.containsKey(id)) reject('Unknown feature: $id');
    final selected = id == null ? affected(paths).keys.toList() : [id];
    selected.sort();
    final unknown = impact(paths)['unclassified'] as List<String>;
    final budget = config['budget'] as int;
    final packets = selected.map((id) {
      final f = features[id]!;
      return '$id ${f.data['risk']} ${f.state}\nread .fork/features/$id.yaml\nwatch ${f.watch.join(',')}\ndeps ${f.deps.join(',')}\n${f.invariants.entries.map((e) => 'must ${e.key}: ${e.value}').join('\n')}\nchecks ${f.checks.keys.join(',')}\nuncovered ${f.uncovered.join(',')}\n';
    }).toList();
    final header =
        'FORK/1 scope=${digest(paths)} features=${selected.length} unclassified=${unknown.length}\n';
    final full =
        '$header${packets.join()}${unknown.isEmpty ? '' : 'unclassified ${unknown.join(',')}\n'}';
    if (utf8.encode(full).length <= budget) return full;
    final output = StringBuffer(
      '${header}partial: request each feature separately\n',
    );
    for (final feature in selected) {
      final line = 'next: context --id $feature\n';
      if (utf8.encode('$output$line').length > budget - 100) break;
      output.write(line);
    }
    output.writeln(
      'total=${selected.length}; use --json for the complete impact list',
    );
    if (id != null) {
      reject('Contract $id exceeds context budget; read its YAML directly');
    }
    return output.toString();
  }
}
