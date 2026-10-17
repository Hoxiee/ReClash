import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

class ForkException implements Exception {
  const ForkException(this.message, {this.code = 2});
  final String message;
  final int code;
  @override
  String toString() => message;
}

Never reject(String message) => throw ForkException(message);
String digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();

Map<String, dynamic> object(Object? value, String where) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    reject('$where must be a string-keyed map');
  }
  return Map<String, dynamic>.from(value);
}

Map<String, dynamic> yamlObject(String source, String where) {
  final plain = source.replaceAll(
    RegExp(r'''"(?:\\.|[^"\\])*"|'(?:''|[^'])*' '''.trim()),
    '""',
  );
  if (RegExp(r'(^|[\s:\[,{])[&*!][^\s]', multiLine: true).hasMatch(plain)) {
    reject(
      '$where: quote literal globs; YAML anchors, aliases and tags are forbidden',
    );
  }
  try {
    return object(loadYaml(source), where);
  } on YamlException catch (error) {
    reject('$where: ${error.message}');
  }
}

void keys(Map<String, dynamic> data, String allowed, String where) {
  final unknown = data.keys.toSet().difference(allowed.split(' ').toSet());
  if (unknown.isNotEmpty) reject('$where: unknown keys ${unknown.join(', ')}');
}

String text(Object? value, String where) {
  if (value is! String ||
      value.trim().isEmpty ||
      value.contains(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]'))) {
    reject('$where must be a nonempty string');
  }
  return value;
}

List<String> strings(Object? value, String where, {bool optional = false}) {
  if (optional && value == null) return [];
  if (value is! List) reject('$where must be a list');
  return value.map((entry) => text(entry, where)).toList();
}

void identifier(String value) {
  if (!RegExp(r'^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$').hasMatch(value)) {
    reject('Invalid ID: $value');
  }
}

String safePath(String value, {bool glob = false}) {
  if (value.startsWith('/') ||
      value.contains('\\') ||
      value.contains(':') ||
      value
          .split('/')
          .any(
            (part) =>
                part.isEmpty ||
                part == '.' ||
                part == '..' ||
                part.toLowerCase() == '.git',
          ) ||
      value.contains(RegExp(r'[\x00-\x1f]')) ||
      (!glob && value.contains('*')) ||
      (glob && value.contains(RegExp(r'[\[\]{}?!]')))) {
    reject('Unsafe repository path: $value');
  }
  return value;
}

bool matches(String pattern, String path) {
  final out = StringBuffer('^');
  for (var i = 0; i < pattern.length; i++) {
    if (pattern[i] != '*') {
      out.write(RegExp.escape(pattern[i]));
    } else if (i + 1 < pattern.length && pattern[i + 1] == '*') {
      i++;
      if (i + 1 < pattern.length && pattern[i + 1] == '/') {
        i++;
        out.write('(?:.*/)?');
      } else {
        out.write('.*');
      }
    } else {
      out.write('[^/]*');
    }
  }
  return RegExp('$out\$').hasMatch(path);
}

class Feature {
  Feature(this.id, this.data) {
    identifier(id);
    keys(
      data,
      'v kind state risk why must watch checks deps drop evidence',
      id,
    );
    if (data['v'] != 1) reject('$id: unsupported schema');
    for (final entry in <String, List<String>>{
      'kind': ['identity', 'feature', 'fix', 'removal', 'integration', 'meta'],
      'state': ['active', 'upstream', 'retired'],
      'risk': ['routine', 'critical'],
    }.entries) {
      if (!entry.value.contains(data[entry.key])) {
        reject('$id: invalid ${entry.key}');
      }
    }
    if (invariants.isEmpty || watch.isEmpty) {
      reject('$id: empty contract/watch');
    }
    for (final entry in invariants.entries) {
      identifier(entry.key);
      text(entry.value, '$id.must');
    }
    for (final path in watch) {
      safePath(path, glob: true);
    }
    for (final dep in deps) {
      identifier(dep);
    }
    for (final entry in checks.entries) {
      identifier(entry.key);
      final covered = strings(entry.value, '$id.checks.${entry.key}');
      if (covered.isEmpty ||
          covered.any((key) => !invariants.containsKey(key))) {
        reject('$id: unknown/empty invariant mapping');
      }
    }
    for (final key in ['why', 'drop', 'evidence']) {
      if (data[key] != null) text(data[key], '$id.$key');
    }
    if (state == 'upstream' && data['evidence'] == null) {
      reject('$id: adopted behavior needs evidence');
    }
  }
  final String id;
  final Map<String, dynamic> data;
  String get state => data['state'] as String;
  bool get critical => data['risk'] == 'critical';
  List<String> get watch => strings(data['watch'], '$id.watch');
  Map<String, dynamic> get checks => object(data['checks'], '$id.checks');
  List<String> get deps => strings(data['deps'], '$id.deps', optional: true);
  Map<String, dynamic> get invariants => object(data['must'], '$id.must');
  List<String> get uncovered =>
      invariants.keys
          .toSet()
          .difference(
            checks.values.expand((value) => strings(value, id)).toSet(),
          )
          .toList()
        ..sort();
}
