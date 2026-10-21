import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/l10n/cli.dart';
import '../../tool/src/l10n/placeholders.dart';

void main() {
  late Directory root;
  late StringBuffer out;
  late StringBuffer err;
  late int generated;

  void writeFile(String path, String source) {
    File('${root.path}/$path')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(source);
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('l10n-tool-');
    out = StringBuffer();
    err = StringBuffer();
    generated = 0;
    writeFile('arb_upstream/intl_en.arb', '{"hello":"Hello"}');
    writeFile('arb_upstream/intl_ru.arb', '{"hello":"Привет"}');
    writeFile('arb/locales/intl_kk.arb', '{"hello":"Сәлем"}');
    writeFile(
      'arb/fragments/feature.a/intl_en.arb',
      '{"one":"One","old":"Old"}',
    );
    writeFile(
      'arb/fragments/feature.a/intl_ru.arb',
      '{"one":"Один","old":"Старый"}',
    );
    writeFile(
      'arb/fragments/feature.a/intl_kk.arb',
      '{"one":"Бір","old":"Ескі"}',
    );
    writeFile('arb/fragments/feature.b/intl_en.arb', '{"two":"Two"}');
    writeFile('arb/fragments/feature.b/intl_ru.arb', '{"two":"Два"}');
    writeFile('arb/fragments/feature.b/intl_kk.arb', '{"two":"Екі"}');
  });

  tearDown(() => root.deleteSync(recursive: true));

  Map<String, Object?> readArb(String path) =>
      jsonDecode(File('${root.path}/$path').readAsStringSync())
          as Map<String, Object?>;

  Future<int> run(List<String> args) => L10nCli(
    root: root,
    out: out,
    err: err,
    generate: (_) async {
      generated++;
      return null;
    },
  ).run(args);

  Future<int> apply(
    Map<String, Object?> spec, [
    List<String> flags = const [],
  ]) {
    writeFile('spec.json', jsonEncode(spec));
    return run(['apply', '${root.path}/spec.json', ...flags]);
  }

  String snapshot() => [
    for (final entity in Directory(
      '${root.path}/arb',
    ).listSync(recursive: true))
      if (entity is File) '${entity.path}=${entity.readAsStringSync()}',
  ].join('\n');

  test('apply updates in place, appends new keys and assembles', () async {
    final status = await apply({
      'fragment': 'feature.a',
      'set': {
        'one': {'en': 'One!', 'ru': 'Один!', 'kk': 'Бір!'},
        'count': {
          'en': '{n, plural, one{1 item} other{{n} items}}',
          'ru': '{n} шт.',
          'kk': '{n} дана',
          '@': {
            'placeholders': {
              'n': {'type': 'int'},
            },
          },
        },
      },
      'remove': ['old'],
    });

    expect(status, 0, reason: '$err');
    expect(
      out.toString(),
      'feature.a: set 2, removed 1; assembled; generated\n',
    );
    expect(generated, 1);
    expect(readArb('arb/fragments/feature.a/intl_en.arb').keys, [
      'one',
      'count',
      '@count',
    ]);
    expect(readArb('arb/fragments/feature.a/intl_ru.arb'), {
      'one': 'Один!',
      'count': '{n} шт.',
    });
    expect(readArb('arb/intl_kk.arb'), {
      'hello': 'Сәлем',
      'one': 'Бір!',
      'count': '{n} дана',
      'two': 'Екі',
    });
  });

  test('apply creates every locale file for a new fragment', () async {
    final status = await apply(
      {
        'fragment': 'feature.c',
        'set': {
          'three': {'en': 'Three', 'ru': 'Три', 'kk': 'Үш'},
        },
      },
      ['--no-generate'],
    );

    expect(status, 0, reason: '$err');
    expect(generated, 0);
    for (final locale in ['en', 'ru', 'kk']) {
      expect(
        File(
          '${root.path}/arb/fragments/feature.c/intl_$locale.arb',
        ).existsSync(),
        isTrue,
      );
    }
    expect(readArb('arb/intl_ru.arb')['three'], 'Три');
  });

  test('apply rejects invalid specs without writing anything', () async {
    final before = snapshot();

    expect(
      await apply({
        'fragment': 'feature.a',
        'set': {
          'four': {'en': 'Four {n}', 'ru': 'Четыре {m}'},
          'two': {'en': 'Two', 'ru': 'Два', 'kk': 'Екі'},
        },
        'remove': ['hello'],
      }),
      1,
    );

    expect(
      err.toString().split('\n'),
      containsAll([
        'four: missing locales kk',
        'four: en {n} not declared in @.placeholders',
        'four: ru has {m}, en has {n}',
        'two: owned by feature.b',
        'hello: not in feature.a',
      ]),
    );
    expect(snapshot(), before);
    expect(generated, 0);
  });

  test('dry run reports changes and writes nothing', () async {
    final before = snapshot();

    final status = await apply(
      {
        'fragment': 'feature.a',
        'set': {
          'hello': {'en': 'Hi', 'ru': 'Привет', 'kk': 'Сәлем'},
        },
      },
      ['--dry-run'],
    );

    expect(status, 0, reason: '$err');
    expect(out.toString(), '+ hello\nfeature.a: set 1; dry run, 3 files\n');
    expect(snapshot(), before);
  });

  test('audit reports a fragment key missing from a locale file', () async {
    writeFile('arb/fragments/feature.b/intl_kk.arb', '{}');
    writeFile('arb/locales/intl_kk.arb', '{"hello":"Сәлем","two":"Екі"}');

    expect(await run(['audit']), 1);
    expect(out.toString(), contains('missing-locale feature.b/two: kk\n'));
  });

  test(
    'audit warns about undeclared en placeholders without failing',
    () async {
      writeFile('arb/fragments/feature.b/intl_en.arb', '{"two":"Two {n}"}');
      writeFile('arb/fragments/feature.b/intl_ru.arb', '{"two":"Два {n}"}');
      writeFile('arb/fragments/feature.b/intl_kk.arb', '{"two":"Екі {n}"}');

      expect(await run(['audit']), 0);
      expect(
        out.toString(),
        contains('undeclared two: en {n} not declared in @.placeholders\n'),
      );
    },
  );

  test('message arguments follow plural, select and escaped braces', () {
    expect(
      messageArguments(
        "{count, plural, one{{name} '{'x'}'} other{{count} {kind, select, a{A} other{{extra}}}}}",
      ),
      {'count', 'name', 'kind', 'extra'},
    );
  });
}
