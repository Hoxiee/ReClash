import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/update_summary.dart';
import 'package:test/test.dart';

import '../../tool/src/changelog/summary.dart';

Map<String, Object?> _summaryJson({String tag = 'v0.1.1'}) {
  Map<String, Object?> locale(String headline) => {
    'headline': headline,
    'spotlight': <String, Object?>{
      'title': 'A --> B',
      'description': 'An authored improvement.',
      'kind': 'update',
    },
    'highlights': <Object>[],
    'warnings': <Object>[],
  };
  return {
    'schemaVersion': 1,
    'tag': tag,
    'automaticInstall': false,
    'locales': {
      'en': locale('A release overview'),
      'ru': locale('Обзор релиза'),
    },
  };
}

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('reclash-release-summary-');
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  File writeSummary(Map<String, Object?> value, {String fileTag = 'v0.1.1'}) {
    final file = File('${root.path}/$releaseSummariesDirectory/$fileTag.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(value));
    return file;
  }

  test('an absent author file never creates a synthetic summary', () {
    expect(readReleaseSummary(root.path, 'v0.1.1'), isNull);
    expect(verifyReleaseSummaries(root.path), isEmpty);
  });

  test('reads and validates the exact release tag', () {
    writeSummary(_summaryJson());
    final summary = readReleaseSummary(root.path, 'v0.1.1');
    expect(summary?.tag, 'v0.1.1');
    expect(summary?.locales['ru']?.headline, 'Обзор релиза');
    expect(verifyReleaseSummaries(root.path), isEmpty);
    expect(readReleaseSummary(root.path, 'v0.1.2'), isNull);
  });

  test('prereleases use their own exact author file', () {
    writeSummary(_summaryJson(tag: 'v0.1.1-pre.2'), fileTag: 'v0.1.1-pre.2');
    expect(readReleaseSummary(root.path, 'v0.1.1-pre.2')?.tag, 'v0.1.1-pre.2');
    expect(readReleaseSummary(root.path, 'v0.1.1'), isNull);
    expect(verifyReleaseSummaries(root.path), isEmpty);
  });

  test('HTML comment escaping round-trips authored text', () {
    writeSummary(_summaryJson());
    final summary = readReleaseSummary(root.path, 'v0.1.1')!;
    final rendered = renderReleaseSummary(summary);
    final payload = rendered.substring(
      releaseSummaryMarker.length,
      rendered.lastIndexOf('-->'),
    );
    expect(payload, isNot(contains('-->')));
    expect(payload, contains(String.fromCharCodes([92, 117, 48, 48, 51, 101])));
    expect(
      parseReleaseSummary(
        rendered,
        tag: 'v0.1.1',
      )?.locales['en']?.spotlight.title,
      'A --> B',
    );
  });

  test('rejects a source whose tag differs from its filename', () {
    writeSummary(_summaryJson(tag: 'v0.1.2'));
    expect(
      () => readReleaseSummary(root.path, 'v0.1.1'),
      throwsFormatException,
    );
    expect(
      verifyReleaseSummaries(root.path).single,
      contains('tag does not match'),
    );
  });

  for (final tag in [
    '../../secrets',
    'latest',
    'v0.1.1/file',
    ' v0.1.1',
    'v0.1.1 ',
  ]) {
    test('does not use an invalid tag as a source path: $tag', () {
      expect(() => readReleaseSummary(root.path, tag), throwsFormatException);
    });
  }

  for (final malformed in <String, void Function(Map<String, Object?>)>{
    'unsupported schema': (json) => json['schemaVersion'] = 2,
    'missing English fallback': (json) => (json['locales'] as Map).remove('en'),
    'unknown highlight kind': (json) =>
        (((json['locales'] as Map)['en'] as Map)['spotlight'] as Map)['kind'] =
            'arbitrary',
    'unknown platform': (json) =>
        (((json['locales'] as Map)['en'] as Map)['spotlight']
            as Map)['platforms'] = [
          'unknown',
        ],
    'blank headline': (json) =>
        ((json['locales'] as Map)['en'] as Map)['headline'] = ' ',
    'long title': (json) =>
        (((json['locales'] as Map)['en'] as Map)['spotlight'] as Map)['title'] =
            'x' * 121,
    'too many highlights': (json) =>
        ((json['locales'] as Map)['en'] as Map)['highlights'] = List.filled(5, {
          'title': 'Title',
          'description': 'Description',
        }),
    'too many warnings': (json) =>
        ((json['locales'] as Map)['en'] as Map)['warnings'] = List.filled(13, {
          'title': 'Title',
          'description': 'Description',
        }),
  }.entries) {
    test('reports ${malformed.key} without accepting the source', () {
      final json = _summaryJson();
      malformed.value(json);
      writeSummary(json);
      expect(
        () => readReleaseSummary(root.path, 'v0.1.1'),
        throwsFormatException,
      );
      expect(verifyReleaseSummaries(root.path), hasLength(1));
    });
  }

  test('does not allow a translation to omit an English warning', () {
    final json = _summaryJson();
    ((json['locales'] as Map)['en'] as Map)['warnings'] = [
      {
        'title': 'Read this first',
        'description': 'This update changes storage.',
        'platforms': ['android'],
      },
    ];
    writeSummary(json);
    expect(
      () => readReleaseSummary(root.path, 'v0.1.1'),
      throwsFormatException,
    );
  });

  test(
    'warnings prevent automatic installation even when the source requests it',
    () {
      final json = _summaryJson()..['automaticInstall'] = true;
      for (final locale in (json['locales'] as Map).values) {
        (locale as Map)['warnings'] = [
          {
            'title': 'Read this first',
            'description': 'This update changes storage.',
          },
        ];
      }
      writeSummary(json);
      expect(
        readReleaseSummary(root.path, 'v0.1.1')?.permitsAutomaticInstall,
        isFalse,
      );
    },
  );

  test('rejects a payload over the app parser size limit', () {
    final json = _summaryJson();
    final locale = ((json['locales'] as Map)['en'] as Map)
        .cast<String, Object?>();
    final largerLocale = {
      ...locale,
      'spotlight': {'title': 'x' * 120, 'description': 'x' * 600},
      'highlights': List.filled(4, {
        'title': 'x' * 120,
        'description': 'x' * 600,
      }),
    };
    json['locales'] = {
      'en': largerLocale,
      for (final key in [
        'aa',
        'ab',
        'ac',
        'ad',
        'ae',
        'af',
        'ag',
        'ah',
        'ai',
        'aj',
        'ak',
        'al',
        'am',
        'an',
        'ao',
        'ap',
        'aq',
        'ar',
        'as',
      ])
        key: largerLocale,
    };
    writeSummary(json);
    expect(
      () => readReleaseSummary(root.path, 'v0.1.1'),
      throwsFormatException,
    );
  });

  test('rejects a rendered overview the app cannot read', () {
    final json = _summaryJson();
    (((json['locales'] as Map)['en'] as Map)['spotlight'] as Map)['title'] =
        releaseSummaryMarker;
    writeSummary(json);
    expect(
      () => readReleaseSummary(root.path, 'v0.1.1'),
      throwsFormatException,
    );
    expect(verifyReleaseSummaries(root.path), hasLength(1));
  });

  test('rejects an oversized author file before decoding it', () {
    final file = writeSummary(_summaryJson());
    file.writeAsStringSync('x' * 131073);
    expect(
      () => readReleaseSummary(root.path, 'v0.1.1'),
      throwsFormatException,
    );
    expect(verifyReleaseSummaries(root.path), hasLength(1));
  });

  test('rejects a linked author file rather than following it', () {
    final source = writeSummary(_summaryJson(tag: 'v0.1.2'), fileTag: 'v0.1.2');
    Link(
      '${root.path}/$releaseSummariesDirectory/v0.1.1.json',
    ).createSync(source.path);
    expect(
      () => readReleaseSummary(root.path, 'v0.1.1'),
      throwsFormatException,
    );
    expect(verifyReleaseSummaries(root.path), hasLength(1));
  }, skip: Platform.isWindows);

  test('reports a directory that uses a release summary filename', () {
    Directory(
      '${root.path}/$releaseSummariesDirectory/v0.1.1.json',
    ).createSync(recursive: true);
    expect(
      () => readReleaseSummary(root.path, 'v0.1.1'),
      throwsFormatException,
    );
    expect(
      verifyReleaseSummaries(root.path).single,
      startsWith('$releaseSummariesDirectory/v0.1.1.json:'),
    );
  });

  test('verification reports malformed and invalid-named source files', () {
    writeSummary(_summaryJson(), fileTag: 'latest');
    final invalid = File('${root.path}/$releaseSummariesDirectory/v0.1.2.json');
    invalid.writeAsStringSync('{broken');
    expect(verifyReleaseSummaries(root.path), hasLength(2));
  });
}
