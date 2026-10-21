import 'dart:io';

import 'package:path/path.dart' as p;

import 'dart_source.dart';

/// A library with its `part` files folded in.
class Library {
  Library(this.path);

  final String path;
  final declarations = <Declaration>[];
  final used = <String>{};
  final imports = <String>{};
  final exports = <(String, ExportDirective)>[];

  late final Set<String> declared = publicNames(declarations);

  /// The declarations using each name.
  late final Map<String, List<Declaration>> users = () {
    final users = <String, List<Declaration>>{};
    for (final declaration in declarations) {
      for (final name in declaration.used) {
        (users[name] ??= []).add(declaration);
      }
    }
    return users;
  }();
}

/// The import and export graph of the Dart files under [root], keyed by
/// POSIX paths relative to it.
class SourceGraph {
  SourceGraph._(this.root, this.excluded);

  final String root;
  final List<String> excluded;
  final libraries = <String, Library>{};
  final declarationsByFile = <String, List<Declaration>>{};
  final libraryOfPart = <String, String>{};
  final importers = <String, List<String>>{};
  final exporters = <String, List<(String, ExportDirective)>>{};
  final _packages = <String, String>{};

  static const rootPackage = 'reclash';

  /// Reads `lib`, `test`, `tool`, `plugins/*/lib` and the top-level Dart
  /// files, leaving out any path under one of [excluded].
  factory SourceGraph.build(String root, {List<String> excluded = const []}) {
    final graph = SourceGraph._(root, excluded);
    graph._packages[rootPackage] = 'lib';
    final plugins = Directory(p.join(root, 'plugins'));
    if (plugins.existsSync()) {
      for (final plugin in plugins.listSync().whereType<Directory>()) {
        final pubspec = File(p.join(plugin.path, 'pubspec.yaml'));
        if (!pubspec.existsSync()) continue;
        final name = RegExp(
          r'^name:\s*(\S+)',
          multiLine: true,
        ).firstMatch(pubspec.readAsStringSync())?.group(1);
        if (name != null) {
          graph._packages[name] = 'plugins/${p.basename(plugin.path)}/lib';
        }
      }
    }

    final sources = <String, DartSource>{};
    void read(String relative) {
      if (!graph.covers(relative)) return;
      final source = DartSource.parse(
        File(p.join(root, relative)).readAsStringSync(),
      );
      sources[relative] = source;
      graph.declarationsByFile[relative] = source.declarations;
    }

    for (final directory in {'lib', 'test', 'tool', ..._pluginLibs(graph)}) {
      final dir = Directory(p.join(root, directory));
      if (!dir.existsSync()) continue;
      for (final file in dir.listSync(recursive: true).whereType<File>()) {
        if (file.path.endsWith('.dart')) read(graph._relative(file.path));
      }
    }
    for (final file in Directory(root).listSync().whereType<File>()) {
      if (file.path.endsWith('.dart')) read(graph._relative(file.path));
    }

    for (final MapEntry(key: path, value: source) in sources.entries) {
      for (final part in source.parts) {
        final resolved = graph.resolve(path, part);
        if (resolved != null) graph.libraryOfPart[resolved] = path;
      }
    }
    for (final MapEntry(key: path, value: source) in sources.entries) {
      final owner = graph.libraryOfPart[path] ?? path;
      final library = graph.libraries.putIfAbsent(owner, () => Library(owner));
      library.declarations.addAll(source.declarations);
      library.used.addAll(source.used);
      for (final uri in source.imports) {
        final target = graph.resolve(path, uri);
        if (target != null) library.imports.add(graph.libraryOf(target));
      }
      for (final directive in source.exports) {
        final target = graph.resolve(path, directive.uri);
        if (target != null) {
          library.exports.add((graph.libraryOf(target), directive));
        }
      }
    }
    for (final library in graph.libraries.values) {
      for (final target in library.imports) {
        (graph.importers[target] ??= []).add(library.path);
      }
      for (final (target, directive) in library.exports) {
        (graph.exporters[target] ??= []).add((library.path, directive));
      }
    }
    return graph;
  }

  static Iterable<String> _pluginLibs(SourceGraph graph) =>
      graph._packages.values.where((dir) => dir.startsWith('plugins/'));

  /// Whether [path] is a Dart file this graph reads, present or not.
  bool covers(String path) {
    if (!path.endsWith('.dart') || excluded.any(path.startsWith)) return false;
    if (!path.contains('/')) return true;
    return path.startsWith('lib/') ||
        path.startsWith('test/') ||
        path.startsWith('tool/') ||
        _pluginLibs(this).any((dir) => path.startsWith('$dir/'));
  }

  String libraryOf(String path) => libraryOfPart[path] ?? path;

  bool isTest(String path) =>
      path.startsWith('test/') && path.endsWith('_test.dart');

  Iterable<String> get tests => libraries.keys.where(isTest);

  String? resolve(String from, String uri) {
    if (uri.startsWith('package:')) {
      final rest = uri.substring('package:'.length);
      final slash = rest.indexOf('/');
      if (slash < 0) return null;
      final directory = _packages[rest.substring(0, slash)];
      return directory == null
          ? null
          : p.posix.join(directory, rest.substring(slash + 1));
    }
    if (uri.contains(':')) return null;
    return p.posix.normalize(p.posix.join(p.posix.dirname(from), uri));
  }

  String _relative(String path) =>
      p.posix.joinAll(p.split(p.relative(path, from: root)));
}
