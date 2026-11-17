import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/metadata/provider_seasonal.dart';

import '../helpers/provider_presentation.dart';

const _lights = "{effect: lights, from: '12-20', to: '01-14'}";
const _hearts = "{effect: hearts, from: '02-10', to: '02-14'}";

ProviderConfigResult _parse(String seasonal) =>
    parseProviderConfig('version: 1\nseasonal: $seasonal', 'en');

SeasonalEntry _entry(String from, String to) => parseProviderSeasonal({
  'effects': [
    {'effect': 'snow', 'from': from, 'to': to},
  ],
}, <String>[])!.effects.single;

String _two(int value) => value.toString().padLeft(2, '0');

String _colors(int count) => List.filled(count, "'#ff0000'").join(', ');

String _snowDays(int count) => [
  for (var day = 1; day <= count; day++)
    "{effect: snow, from: '01-${_two(day)}', to: '12-31'}",
].join(', ');

void main() {
  group('section', () {
    test('parses kind, dates, density and colors of each effect', () {
      final result = parseProviderConfig('''
version: 1
seasonal:
  effects:
    - effect: snow
      from: '12-01'
      to: '02-28'
    - effect: hearts
      from: '02-10'
      to: '02-14'
      density: high
      colors: ['#ff0000', 'ff0000']
''', 'en');
      expect(result.warnings, isEmpty);
      final seasonal = result.config!.seasonal!;
      expect(seasonal.calendar, isTrue);
      expect(seasonal.effects, hasLength(2));

      final snow = seasonal.effects[0];
      expect(snow.kind, SeasonalEffectKind.snow);
      expect(snow.from, const SeasonalDate(12, 1));
      expect(snow.to, const SeasonalDate(2, 28));
      expect(snow.density, SeasonalDensity.medium);
      expect(snow.colors, isEmpty);

      final hearts = seasonal.effects[1];
      expect(hearts.kind, SeasonalEffectKind.hearts);
      expect(hearts.density, SeasonalDensity.high);
      expect(hearts.colors, [0xFFFF0000, 0xFFFF0000]);
    });

    test('eight colors are the most one effect takes', () {
      final effects = _parse(
        "{effects: [{effect: snow, from: '12-01', to: '12-31', colors: [${_colors(8)}]}]}",
      ).config!.seasonal!.effects;
      expect(effects.single.colors, hasLength(8));
    });

    test('sixteen effects apply without a warning', () {
      final result = _parse('{effects: [${_snowDays(16)}]}');
      expect(result.warnings, isEmpty);
      expect(result.config!.seasonal!.effects, hasLength(16));
    });

    test('only the first sixteen effects apply', () {
      final result = _parse('{effects: [${_snowDays(17)}]}');
      final effects = result.config!.seasonal!.effects;
      expect(effects, hasLength(16));
      expect(effects.last.from, const SeasonalDate(1, 16));
      expect(
        result.warnings,
        contains('Only the first 16 seasonal effects apply'),
      );
    });

    test('an unknown key in the section warns and keeps the effects', () {
      final result = _parse('{effects: [$_lights], speed: fast}');
      expect(result.warnings, contains('Unknown key speed in seasonal'));
      expect(result.config!.seasonal!.effects, hasLength(1));
    });

    test('an unknown key in an effect warns and keeps the effect', () {
      final result = _parse(
        "{effects: [{effect: snow, from: '12-01', to: '12-31', glow: 2}]}",
      );
      expect(result.warnings, contains('Unknown key glow in seasonal effect'));
      expect(
        result.config!.seasonal!.effects.single.kind,
        SeasonalEffectKind.snow,
      );
    });
  });

  group('calendar', () {
    test('none turns the built-in calendar off', () {
      final seasonal = _parse('{calendar: none}').config!.seasonal!;
      expect(seasonal.calendar, isFalse);
      expect(seasonal.effects, isEmpty);
    });

    test('an absent or default calendar keeps it on', () {
      for (final body in ['{}', '{effects: []}', '{calendar: default}']) {
        expect(_parse(body).config!.seasonal!.calendar, isTrue, reason: body);
      }
    });

    test('an unknown calendar value rejects the section', () {
      for (final body in ['{calendar: always}', '{calendar: true}']) {
        final result = _parse(body);
        expect(result.config!.seasonal, isNull, reason: body);
        expect(
          result.warnings,
          contains('Invalid seasonal section'),
          reason: body,
        );
      }
    });

    test(
      'a section that is not a map or has no list of effects is rejected',
      () {
        for (final body in ['true', '[]', '{effects: snow}']) {
          final result = _parse(body);
          expect(result.config!.seasonal, isNull, reason: body);
          expect(
            result.warnings,
            contains('Invalid seasonal section'),
            reason: body,
          );
        }
      },
    );
  });

  group('invalid effects', () {
    final invalid = {
      'unknown name': "{effect: fireworks, from: '12-01', to: '12-31'}",
      'impossible day': "{effect: snow, from: '02-30', to: '03-01'}",
      'mixed date forms': "{effect: snow, from: '12-01', to: '2026-01-05'}",
      'dated range ending first':
          "{effect: snow, from: '2026-12-05', to: '2026-12-01'}",
      'unknown density':
          "{effect: snow, from: '12-01', to: '12-31', density: huge}",
      'non-hex color':
          "{effect: snow, from: '12-01', to: '12-31', colors: ['#gg0000']}",
      'empty colors': "{effect: snow, from: '12-01', to: '12-31', colors: []}",
      'nine colors':
          "{effect: snow, from: '12-01', to: '12-31', colors: [${_colors(9)}]}",
    };

    for (final MapEntry(:key, :value) in invalid.entries) {
      test('skips an effect with $key and keeps its siblings', () {
        final result = _parse('{effects: [$_lights, $value, $_hearts]}');
        final effects = result.config!.seasonal!.effects;
        expect(effects.map((effect) => effect.kind), [
          SeasonalEffectKind.lights,
          SeasonalEffectKind.hearts,
        ]);
        expect(result.warnings, contains('Invalid seasonal effect at index 1'));
      });
    }
  });

  group('view flag', () {
    test('app seasonal false reaches the hints', () {
      expect(
        presentedHints({
          'view': {
            'app': {'seasonal': false},
          },
        }).view.seasonal,
        isFalse,
      );
    });

    test('a string value is ignored with a warning', () {
      final result = parseProviderConfig(
        'version: 1\nview: {app: {seasonal: "false"}}',
        'en',
      );
      expect(
        result.warnings,
        contains('Invalid value for app.seasonal in view'),
      );
      expect(
        presentedHints({
          'view': {
            'app': {'seasonal': 'false'},
          },
        }).view.seasonal,
        isNull,
      );
    });
  });

  group('covers', () {
    test('a month-day range over the new year covers both of its ends', () {
      final entry = _entry('12-20', '01-14');
      for (final day in [
        DateTime(2026, 12, 20),
        DateTime(2026, 12, 31),
        DateTime(2027, 1, 1),
        DateTime(2027, 1, 14),
      ]) {
        expect(entry.covers(day), isTrue, reason: '$day');
      }
      for (final day in [DateTime(2026, 12, 19), DateTime(2027, 1, 15)]) {
        expect(entry.covers(day), isFalse, reason: '$day');
      }
    });

    test('a dated range covers its own year only', () {
      final entry = _entry('2026-12-24', '2026-12-26');
      expect(entry.covers(DateTime(2026, 12, 25)), isTrue);
      expect(entry.covers(DateTime(2027, 12, 25)), isFalse);
    });

    test('a range ending on the 29th covers February of a common year', () {
      final entry = _entry('02-01', '02-29');
      expect(entry.covers(DateTime(2027, 2, 28)), isTrue);
      expect(entry.covers(DateTime(2027, 3, 1)), isFalse);
    });
  });
}
