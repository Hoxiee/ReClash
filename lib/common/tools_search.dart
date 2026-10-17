/// A searchable item in the tools catalogue.
class ToolSearchDocument {
  const ToolSearchDocument({
    required this.id,
    required this.title,
    this.keywords = const [],
    this.path = '',
  });

  final String id;
  final String title;
  final List<String> keywords;
  final String path;
}

/// A catalogue item and its relevance score.
class ToolSearchMatch {
  const ToolSearchMatch({required this.document, required this.score});

  final ToolSearchDocument document;
  final int score;
}

/// Searches a small, static tools catalogue without external dependencies.
class ToolsSearch {
  ToolsSearch(Iterable<ToolSearchDocument> docs)
    : _documents = docs
          .map(
            (document) => _IndexedDocument(
              document,
              _normalize(document.title),
              document.keywords
                  .map(_normalize)
                  .where((value) => value.isNotEmpty)
                  .toList(growable: false),
              _normalize(document.path),
            ),
          )
          .toList(growable: false);

  static const _maxQueryLength = 256;
  static const _maxTerms = 12;
  static const _maxResults = 60;

  final List<_IndexedDocument> _documents;

  List<ToolSearchMatch> search(String query, {int limit = 60}) {
    if (limit <= 0 || query.length > _maxQueryLength) return const [];
    final normalized = _normalize(query);
    final terms = _terms(normalized);
    if (terms.isEmpty || terms.length > _maxTerms) return const [];

    final alternatives = {for (final term in terms) term: _alternates(term)};
    final matches = <_RankedMatch>[];
    for (var index = 0; index < _documents.length; index++) {
      final indexed = _documents[index];
      var score = 0;
      var matched = true;
      for (final term in terms) {
        final termScore = _scoreTerm(term, alternatives[term]!, indexed);
        if (termScore == 0) {
          matched = false;
          break;
        }
        score += termScore;
      }
      if (matched) {
        matches.add(
          _RankedMatch(
            indexed.document,
            score + (indexed.title == normalized ? 10000 : 0),
            index,
          ),
        );
      }
    }

    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byId = a.document.id.compareTo(b.document.id);
      return byId != 0 ? byId : a.inputIndex.compareTo(b.inputIndex);
    });
    return matches
        .take(limit < _maxResults ? limit : _maxResults)
        .map(
          (match) =>
              ToolSearchMatch(document: match.document, score: match.score),
        )
        .toList(growable: false);
  }
}

class _IndexedDocument {
  _IndexedDocument(this.document, this.title, this.keywords, this.path)
    : titleWords = _words(title),
      keywordWords = keywords.expand(_words).toList(growable: false),
      pathWords = _words(path);

  final ToolSearchDocument document;
  final String title;
  final List<String> keywords;
  final String path;
  final List<String> titleWords;
  final List<String> keywordWords;
  final List<String> pathWords;
}

class _RankedMatch {
  const _RankedMatch(this.document, this.score, this.inputIndex);

  final ToolSearchDocument document;
  final int score;
  final int inputIndex;
}

const Map<String, List<String>> _synonyms = {
  'настройки': ['settings', 'параметры'],
  'сеть': ['network', 'connection'],
  'network': ['сеть', 'подключение'],
  'автозапуск': ['auto launch', 'startup'],
  'autostart': ['auto launch', 'startup'],
  'резервная': ['backup'],
  'backup': ['резервная', 'копирование'],
  'журнал': ['logs', 'log'],
  'logs': ['журнал', 'логи'],
  'settings': ['настройки', 'preferences'],
  'прокси': ['proxy', 'сервер'],
  'proxy': ['прокси', 'сервер'],
  'подключение': ['connection', 'сеть'],
  'connection': ['подключение', 'сеть'],
  'профиль': ['profile', 'конфигурация'],
  'profile': ['профиль', 'configuration'],
  'обновление': ['update', 'версия'],
  'update': ['обновление', 'версия'],
  'тема': ['theme', 'оформление'],
  'theme': ['тема', 'appearance'],
};

const String _russianKeys =
    '` й ц у к е н г ш щ з х ъ ф ы в а п р о л д ж э я ч с м и т ь б ю .';
const String _englishKeys =
    '` q w e r t y u i o p [ ] a s d f g h j k l ; \' z x c v b n m , .';

int _scoreTerm(
  String term,
  Set<String> alternatives,
  _IndexedDocument document,
) {
  final titleWords = document.titleWords;
  if (document.title == term) return 1000;
  if (titleWords.contains(term)) return 800;
  if (titleWords.any((word) => word.startsWith(term))) return 600;

  if (document.keywords.any(
    (keyword) => keyword == term || _words(keyword).contains(term),
  )) {
    return 400;
  }
  if (document.pathWords.contains(term)) return 350;

  for (final alternative in alternatives) {
    if (alternative == term) continue;
    if (document.title == alternative ||
        titleWords.contains(alternative) ||
        titleWords.any((word) => word.startsWith(alternative))) {
      return 250;
    }
    if (document.keywords.any(
      (keyword) =>
          keyword == alternative || _words(keyword).contains(alternative),
    )) {
      return 200;
    }
    if (document.pathWords.contains(alternative)) return 175;
  }

  if (term.length < 4) return 0;
  for (final word in <String>[
    ...titleWords,
    ...document.keywordWords,
    ...document.pathWords,
  ]) {
    if (_editDistanceOne(term, word)) return 100;
  }
  return 0;
}

Set<String> _alternates(String term) {
  final alternatives = <String>{...?_synonyms[term]};
  alternatives.add(_normalize(_remap(term, _russianKeys, _englishKeys)));
  alternatives.add(_normalize(_remap(term, _englishKeys, _russianKeys)));
  return alternatives;
}

String _normalize(String value) => value
    .replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    )
    .toLowerCase()
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

List<String> _terms(String value) =>
    value.isEmpty ? const [] : value.split(' ').toList(growable: false);

List<String> _words(String value) =>
    value.isEmpty ? const [] : value.split(' ');

String _remap(String value, String from, String to) {
  final source = from.split(' ');
  final target = to.split(' ');
  final result = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final position = source.indexOf(char);
    result.write(position < 0 ? char : target[position]);
  }
  return result.toString();
}

bool _editDistanceOne(String first, String second) {
  if ((first.length - second.length).abs() > 1 || first == second) return false;
  var firstIndex = 0;
  var secondIndex = 0;
  var edits = 0;
  while (firstIndex < first.length && secondIndex < second.length) {
    if (first[firstIndex] == second[secondIndex]) {
      firstIndex++;
      secondIndex++;
      continue;
    }
    if (++edits > 1) return false;
    if (first.length > second.length) {
      firstIndex++;
    } else if (second.length > first.length) {
      secondIndex++;
    } else {
      firstIndex++;
      secondIndex++;
    }
  }
  if (firstIndex < first.length || secondIndex < second.length) edits++;
  return edits == 1;
}
