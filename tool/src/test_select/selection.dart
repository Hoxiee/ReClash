import 'dart:collection';

import 'dart_source.dart';
import 'graph.dart';

/// Generated localizations, imported nearly everywhere, follow the ARB rule.
const graphExcluded = ['lib/l10n/'];

class Reason {
  const Reason(this.root, {this.via = const [], this.note});

  final String root;
  final List<String> via;
  final String? note;

  String describe(int others) {
    final more = others > 0 ? ' (+$others more)' : '';
    if (note == 'changed') return '<- changed$more';
    final through = via.isEmpty ? '' : ' via ${via.join(' > ')}';
    final why = note == null ? '' : ' ($note)';
    return '<- $root$through$why$more';
  }
}

class Selection {
  final tests = SplayTreeMap<String, Reason>();
  final _roots = <String, Set<String>>{};
  final unmapped = <String>[];
  String? fullSuite;

  int others(String test) => _roots[test]!.length - 1;

  void add(String test, Reason reason) {
    (_roots[test] ??= {}).add(reason.root);
    final current = tests[test];
    if (current == null ||
        (current.note != 'changed' && reason.via.length < current.via.length)) {
      tests[test] = reason;
    }
  }
}

typedef _Dependent = ({
  String path,
  List<String> via,
  List<ExportDirective> filters,
});

/// Selects the tests under `test/` that [changed] can break. Through a
/// barrel, a library counts only when it names a declaration reached so far;
/// a changed file's committed text from [previousSource] adds its old names.
Selection selectTests(
  SourceGraph graph,
  Iterable<String> changed, {
  String? Function(String path)? previousSource,
}) {
  final selection = Selection();
  final tests = graph.tests.toList()..sort();
  final dependents = <String, List<_Dependent>>{};

  bool addAll(String path, bool Function(String test) where, String note) {
    final matched = tests.where(where).toList();
    for (final test in matched) {
      selection.add(test, Reason(path, note: note));
    }
    return matched.isNotEmpty;
  }

  for (final path in changed) {
    final name = path.split('/').last;
    if (name.startsWith('pubspec.') &&
        (!path.contains('/') || RegExp(r'^plugins/[^/]+/').hasMatch(path))) {
      selection.fullSuite ??= path;
      addAll(path, (_) => true, 'full suite');
      continue;
    }
    var mapped = false;
    if (path.startsWith('lib/')) {
      mapped = true;
      addAll(path, (test) => test.startsWith('test/lint/'), 'scans lib/');
    }
    if (path.startsWith('arb/') || path.startsWith('lib/l10n/')) {
      mapped = true;
      addAll(
        path,
        (test) =>
            test.startsWith('test/l10n/') ||
            test == 'test/tool/l10n_assembler_test.dart' ||
            test == 'test/lint/dynamic_message_key_test.dart',
        'l10n',
      );
    }
    final tool = _toolTarget(path);
    if (tool != null) {
      mapped |= addAll(
        path,
        (test) => test.startsWith('test/tool/$tool'),
        'tool',
      );
    }
    if (graph.covers(path)) {
      mapped = true;
      final root = graph.libraryOf(path);
      if (graph.isTest(root)) {
        selection.add(root, Reason(root, note: 'changed'));
      }
      final names = path == root
          ? {...?graph.libraries[root]?.declared}
          : {
              for (final declaration
                  in graph.declarationsByFile[path] ?? const <Declaration>[])
                ...declaration.names,
            };
      final previous = previousSource?.call(path);
      if (previous != null) {
        final source = DartSource.parse(previous);
        names.addAll(
          path == root
              ? source.declared
              : source.declarations.expand((declaration) => declaration.names),
        );
      }
      if (path != root) {
        final library = graph.libraries[root];
        if (library != null) names.addAll(_affectedNames(library, names));
        names.removeWhere((name) => name.startsWith('_'));
      }
      _propagate(graph, root, names, dependents, selection);
    }
    if (!mapped) selection.unmapped.add(path);
  }
  return selection;
}

String? _toolTarget(String path) {
  if (path.startsWith('.fork/') ||
      path == 'tool/fork.dart' ||
      path.startsWith('tool/src/fork/')) {
    return 'fork';
  }
  final match = RegExp(
    r'^tool/(?:src/)?([^/]+?)(?:\.dart$|/)',
  ).firstMatch(path);
  return match?.group(1);
}

void _propagate(
  SourceGraph graph,
  String root,
  Set<String> rootNames,
  Map<String, List<_Dependent>> cache,
  Selection selection,
) {
  final routes = <String, List<String>>{root: const []};
  final affected = <String, Set<String>>{root: rootNames};
  final queue = Queue.of([root]);
  final queued = {root};
  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    queued.remove(current);
    final names = affected[current]!;
    final chain = current == root
        ? const <String>[]
        : [...routes[current]!, current];
    for (final (:path, :via, :filters) in cache[current] ??= _dependents(
      graph,
      current,
    )) {
      final library = graph.libraries[path]!;
      final visible = filters.fold(names, (names, f) => f.filter(names));
      if (via.isNotEmpty && !visible.any(library.used.contains)) continue;
      if (!routes.containsKey(path)) {
        routes[path] = [...chain, ...via];
        if (graph.isTest(path)) {
          selection.add(path, Reason(root, via: routes[path]!));
        }
      }
      final reached = _affectedNames(library, visible);
      final known = affected[path] ??= {};
      if (known.containsAll(reached)) continue;
      known.addAll(reached);
      if (queued.add(path)) queue.add(path);
    }
  }
}

/// The public names of [library] whose declarations use [incoming], directly
/// or through one another.
Set<String> _affectedNames(Library library, Set<String> incoming) {
  final users = library.users;
  final pending = [
    for (final name in incoming)
      if (users.containsKey(name)) name,
  ];
  final affected = <String>{};
  final done = Set<Declaration>.identity();
  while (pending.isNotEmpty) {
    for (final declaration in users[pending.removeLast()]!) {
      if (!done.add(declaration)) continue;
      if (declaration.names.isEmpty) return library.declared;
      for (final name in declaration.names) {
        if (affected.add(name) && users.containsKey(name)) pending.add(name);
      }
    }
  }
  return {
    for (final name in affected)
      if (!name.startsWith('_')) name,
  };
}

/// The libraries importing [library], and those importing a barrel that
/// exports it, with the barrels in between and their combinators.
List<_Dependent> _dependents(SourceGraph graph, String library) {
  final result = <_Dependent>[
    for (final importer in graph.importers[library] ?? const <String>[])
      (path: importer, via: const <String>[], filters: const []),
  ];
  final seen = <String>{};
  final pending = Queue.of([
    (path: library, via: const <String>[], filters: const <ExportDirective>[]),
  ]);
  while (pending.isNotEmpty) {
    final conduit = pending.removeFirst();
    for (final (barrel, directive)
        in graph.exporters[conduit.path] ??
            const <(String, ExportDirective)>[]) {
      final filters = [
        ...conduit.filters,
        if (directive.show != null || directive.hide.isNotEmpty) directive,
      ];
      if (!seen.add('$barrel ${filters.map(identityHashCode).toSet()}')) {
        continue;
      }
      final via = [...conduit.via, barrel];
      pending.add((path: barrel, via: via, filters: filters));
      for (final importer in graph.importers[barrel] ?? const <String>[]) {
        if (importer != library) {
          result.add((path: importer, via: via, filters: filters));
        }
      }
    }
  }
  return result;
}
