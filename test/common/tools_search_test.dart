import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/tools_search.dart';

void main() {
  const documents = [
    ToolSearchDocument(
      id: 'settings',
      title: 'Настройки подключения',
      keywords: ['settings', 'network'],
    ),
    ToolSearchDocument(
      id: 'proxy',
      title: 'Прокси сервер',
      keywords: ['proxy', 'network'],
    ),
    ToolSearchDocument(
      id: 'theme',
      title: 'Тема оформления',
      keywords: ['appearance'],
    ),
    ToolSearchDocument(
      id: 'logs',
      title: 'Журнал подключений',
      keywords: ['logs'],
    ),
  ];

  ToolsSearch makeSearch() => ToolsSearch(documents);

  test('exact title outranks prefix, aliases, and fuzzy matches', () {
    final search = ToolsSearch(const [
      ToolSearchDocument(id: 'exact', title: 'Proxy'),
      ToolSearchDocument(id: 'prefix', title: 'Proxy settings'),
      ToolSearchDocument(
        id: 'alias',
        title: 'Прокси сервер',
        keywords: ['proxy'],
      ),
      ToolSearchDocument(id: 'fuzzy', title: 'Proxxy'),
    ]);

    expect(search.search('proxy').map((match) => match.document.id), [
      'exact',
      'prefix',
      'alias',
      'fuzzy',
    ]);
  });

  test('requires every query term to match', () {
    final results = makeSearch().search('настройки сеть');
    expect(results.map((match) => match.document.id), ['settings']);
  });

  test('normalizes ё and whitespace', () {
    expect(
      makeSearch().search('  Тема\nОФОРМЛЕНИЯ ').first.document.id,
      'theme',
    );
    expect(
      ToolsSearch(const [
        ToolSearchDocument(id: 'ё', title: 'Ёмкость'),
      ]).search('емкость'),
      isNotEmpty,
    );
  });

  test('remaps a query typed with the wrong keyboard layout', () {
    expect(makeSearch().search('ghjr').map((match) => match.document.id), [
      'proxy',
    ]);
  });

  test('expands curated Russian and English synonyms', () {
    expect(makeSearch().search('appearance').first.document.id, 'theme');
    expect(makeSearch().search('прокси').first.document.id, 'proxy');
  });

  test('matches a one-edit typo for words of at least four characters', () {
    expect(makeSearch().search('настройкм').first.document.id, 'settings');
    expect(
      ToolsSearch(const [
        ToolSearchDocument(id: 'setting', title: 'Setting'),
      ]).search('seting'),
      isNotEmpty,
    );
  });

  test('does not fuzzy-match short tokens', () {
    expect(
      ToolsSearch(const [
        ToolSearchDocument(id: 'cat', title: 'Cat'),
      ]).search('bat'),
      isEmpty,
    );
  });

  test('bounds query terms, characters, and results', () {
    final docs = List.generate(
      80,
      (index) => ToolSearchDocument(
        id: '$index',
        title: 'Settings item $index',
        keywords: ['common'],
      ),
    );
    final search = ToolsSearch(docs);
    expect(search.search('common', limit: 100).length, 60);
    expect(search.search('common', limit: 3).length, 3);
    expect(search.search('common', limit: -1), isEmpty);
    expect(search.search('${'common ' * 12}missing'), isEmpty);
    expect(search.search('x' * 300), isEmpty);
  });

  test('empty query has deterministic empty results', () {
    expect(makeSearch().search('  \n '), isEmpty);
    expect(makeSearch().search(''), isEmpty);
  });

  test('ties sort by id and then preserve input order', () {
    final search = ToolsSearch(const [
      ToolSearchDocument(id: 'b', title: 'Shared name'),
      ToolSearchDocument(id: 'a', title: 'Shared name'),
      ToolSearchDocument(id: 'a', title: 'Shared name'),
    ]);
    expect(search.search('shared name').map((match) => match.document.id), [
      'a',
      'a',
      'b',
    ]);
  });
}
