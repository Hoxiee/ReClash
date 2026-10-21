final _argumentStart = RegExp(
  r'\{\s*([A-Za-z][A-Za-z0-9_]*)\s*(\}|,\s*(?:plural|select)\s*,)',
);
final _clauseStart = RegExp(r'\s*([^\s{}]+)\s*\{');
final _argumentEnd = RegExp(r'\s*\}');
final _quotedCurly = RegExp(r"'[{}]'");

/// Argument names at any depth, as intl_utils parses ICU: its only escapes are
/// `'{'`, `'}'` and `''`, so `'{name}'` is still an argument.
Set<String> messageArguments(String message) {
  final names = <String>{};
  _scan(message, 0, names, nested: false);
  return names;
}

Set<String> declaredPlaceholders(Object? metadata) {
  if (metadata is! Map) return {};
  final placeholders = metadata['placeholders'];
  if (placeholders is! Map) return {};
  return placeholders.keys.cast<String>().toSet();
}

String formatArguments(Set<String> names) {
  if (names.isEmpty) return 'none';
  return (names.toList()..sort()).map((name) => '{$name}').join(' ');
}

int _scan(
  String message,
  int start,
  Set<String> names, {
  required bool nested,
}) {
  var index = start;
  while (index < message.length) {
    final char = message[index];
    if (_quotedCurly.matchAsPrefix(message, index) != null) {
      index += 3;
    } else if (char == '{') {
      index = _argument(message, index, names);
    } else if (char == '}' && nested) {
      return index;
    } else {
      index++;
    }
  }
  return index;
}

int _argument(String message, int start, Set<String> names) {
  final match = _argumentStart.matchAsPrefix(message, start);
  if (match == null) return start + 1;
  names.add(match[1]!);
  if (match[2] == '}') return match.end;
  var index = match.end;
  while (true) {
    final clause = _clauseStart.matchAsPrefix(message, index);
    if (clause == null) break;
    index = _scan(message, clause.end, names, nested: true);
    if (index >= message.length) return index;
    index++;
  }
  return _argumentEnd.matchAsPrefix(message, index)?.end ?? index;
}
