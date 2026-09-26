final _termSeparator = RegExp(r'\s+');

/// A whitespace-tolerant, case-insensitive query: every term must be found, so
/// pasting a label and its subtitle still matches the item they came from.
class SearchQuery {
  final List<String> terms;

  SearchQuery(String text)
    : terms = text
          .toLowerCase()
          .split(_termSeparator)
          .where((term) => term.isNotEmpty)
          .toList(growable: false);

  bool get isEmpty => terms.isEmpty;

  bool get isNotEmpty => terms.isNotEmpty;

  // Terms hold no whitespace, so the newline keeps one from spanning fields.
  static String textOf(Iterable<String?> fields) {
    return fields.nonNulls.join('\n').toLowerCase();
  }

  bool matches(Iterable<String?> fields) {
    if (terms.isEmpty) {
      return true;
    }
    return terms.every(textOf(fields).contains);
  }
}

extension SearchIterableExt<T> on Iterable<T> {
  Iterable<T> whereMatches(
    SearchQuery query,
    Iterable<String?> Function(T item) fieldsOf,
  ) {
    if (query.isEmpty) {
      return this;
    }
    return where((item) => query.matches(fieldsOf(item)));
  }
}
