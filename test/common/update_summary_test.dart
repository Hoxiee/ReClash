import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/update_summary.dart';

Map<String, dynamic> summaryJson({bool automatic = true}) => {
  'schemaVersion': 1,
  'tag': 'v1.2.3',
  'automaticInstall': automatic,
  'locales': {
    'en': {
      'headline': 'A quieter update',
      'spotlight': <String, dynamic>{
        'title': 'Your background',
        'description': 'Choose a wallpaper.',
        'kind': 'wallpaper',
      },
      'highlights': [
        <String, dynamic>{
          'title': 'Confirmed links',
          'description': 'Review before opening.',
          'kind': 'link',
        },
      ],
      'warnings': [],
    },
    'ru': {
      'headline': 'Обновления без суеты',
      'spotlight': <String, dynamic>{
        'title': 'Ваш фон',
        'description': 'Выберите обои.',
        'kind': 'wallpaper',
      },
      'highlights': [],
      'warnings': [],
    },
  },
};

String body(Map<String, dynamic> json) =>
    '$releaseSummaryMarker\n${jsonEncode(json)}\n-->\n';

void main() {
  test('authored summary round-trips without closing its HTML comment', () {
    final json = summaryJson();
    json['locales']['en']['spotlight']['title'] = 'A --> B';
    final encoded = renderReleaseSummary(ReleaseSummary.fromJson(json));
    expect('-->'.allMatches(encoded), hasLength(1));
    final summary = parseReleaseSummary(encoded, tag: 'v1.2.3')!;
    expect(summary.locales['en']!.spotlight.title, 'A --> B');
    expect(summary.permitsAutomaticInstall, isTrue);
  });

  test(
    'resolves language and English fallback without inventing translations',
    () {
      final summary = ReleaseSummary.fromJson(summaryJson());
      expect(
        summary.localized('ru-RU', platform: 'android')!.headline,
        'Обновления без суеты',
      );
      expect(
        summary.localized('ja', platform: 'android')!.headline,
        'A quieter update',
      );
    },
  );

  test('filters platforms and promotes an applicable highlight', () {
    final json = summaryJson();
    json['locales']['en']['spotlight']['platforms'] = ['android'];
    json['locales']['ru']['spotlight']['platforms'] = ['android'];
    final summary = ReleaseSummary.fromJson(json);
    final desktop = summary.localized('ru', platform: 'linux')!;
    expect(desktop.spotlight.title, 'Confirmed links');
    expect(desktop.highlights, isEmpty);
    json['locales']['en']['highlights'][0]['platforms'] = ['android'];
    expect(
      ReleaseSummary.fromJson(json).localized('ru', platform: 'linux'),
      isNull,
    );
  });

  test(
    'warnings remain visible and make automatic installation ineligible',
    () {
      final json = summaryJson();
      for (final locale in json['locales'].values) {
        locale['warnings'] = [
          {
            'title': 'Read first',
            'description': 'An explicit choice is required.',
            'platforms': ['android'],
          },
        ];
      }
      final summary = ReleaseSummary.fromJson(json);
      expect(summary.permitsAutomaticInstall, isFalse);
      expect(
        summary.localized('ru', platform: 'android')!.warnings,
        hasLength(1),
      );
      expect(summary.localized('ru', platform: 'linux')!.warnings, isEmpty);
    },
  );

  test('translations cannot silently omit or re-scope a warning', () {
    final json = summaryJson();
    json['locales']['en']['warnings'] = [
      {
        'title': 'Read first',
        'description': 'Keep this warning.',
        'platforms': ['android'],
      },
    ];
    expect(parseReleaseSummary(body(json), tag: 'v1.2.3'), isNull);
    json['locales']['ru']['warnings'] = [
      {
        'title': 'Read first',
        'description': 'Keep this warning.',
        'platforms': ['linux'],
      },
    ];
    expect(parseReleaseSummary(body(json), tag: 'v1.2.3'), isNull);
  });

  test('missing, mismatched, duplicate and oversized metadata fail closed', () {
    expect(parseReleaseSummary(null, tag: 'v1.2.3'), isNull);
    expect(parseReleaseSummary('## Changes', tag: 'v1.2.3'), isNull);
    final encoded = body(summaryJson());
    expect(parseReleaseSummary(encoded, tag: 'v1.2.4'), isNull);
    expect(parseReleaseSummary('$encoded$encoded', tag: 'v1.2.3'), isNull);
    expect(
      parseReleaseSummary(
        '$releaseSummaryMarker${' ' * 65537}-->',
        tag: 'v1.2.3',
      ),
      isNull,
    );
    expect(
      parseReleaseSummary('$releaseSummaryMarker{', tag: 'v1.2.3'),
      isNull,
    );
  });

  final invalidCases = [
    (Map<String, dynamic> json) => json['schemaVersion'] = 9,
    (Map<String, dynamic> json) => json.remove('automaticInstall'),
    (Map<String, dynamic> json) => json['automaticInstall'] = 'true',
    (Map<String, dynamic> json) => json['locales'].remove('en'),
    (Map<String, dynamic> json) =>
        json['locales']['en']['spotlight']['kind'] = 'unknown',
    (Map<String, dynamic> json) =>
        json['locales']['en']['spotlight']['platforms'] = ['ios'],
    (Map<String, dynamic> json) => json['locales']['en']['headline'] = '',
    (Map<String, dynamic> json) => json['locales']['en']['highlights'] =
        List.filled(5, json['locales']['en']['spotlight']),
  ];
  for (var index = 0; index < invalidCases.length; index++) {
    test('rejects invalid authored summary case $index', () {
      final json = summaryJson();
      invalidCases[index](json);
      expect(parseReleaseSummary(body(json), tag: 'v1.2.3'), isNull);
    });
  }
}
