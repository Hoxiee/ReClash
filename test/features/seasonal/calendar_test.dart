import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/seasonal/calendar.dart';

void main() {
  group('built-in calendar', () {
    test('the winter holidays show lights and snow in paint order', () {
      expect(activeSeasonalEffects(DateTime(2026, 12, 25)), const [
        SeasonalEffect(SeasonalEffectKind.lights, SeasonalDensity.medium),
        SeasonalEffect(SeasonalEffectKind.snow, SeasonalDensity.medium),
      ]);
    });

    test('winter shows low snow', () {
      expect(activeSeasonalEffects(DateTime(2026, 2, 10)), const [
        SeasonalEffect(SeasonalEffectKind.snow, SeasonalDensity.low),
      ]);
    });

    test('autumn shows low leaves', () {
      expect(activeSeasonalEffects(DateTime(2026, 10, 15)), const [
        SeasonalEffect(SeasonalEffectKind.leaves, SeasonalDensity.low),
      ]);
    });

    test('spring shows low petals', () {
      expect(activeSeasonalEffects(DateTime(2026, 4, 15)), const [
        SeasonalEffect(SeasonalEffectKind.petals, SeasonalDensity.low),
      ]);
    });

    test('a day outside every season shows nothing', () {
      expect(activeSeasonalEffects(DateTime(2026, 11, 17)), isEmpty);
    });
  });

  group('provider effects', () {
    test('a provider snow effect replaces the built-in snow', () {
      const provider = ProviderSeasonal(
        effects: [
          SeasonalEntry(
            kind: SeasonalEffectKind.snow,
            from: SeasonalDate(12, 1),
            to: SeasonalDate(12, 31),
            density: SeasonalDensity.high,
            colors: [0xFFFF0000],
          ),
        ],
      );
      expect(
        activeSeasonalEffects(DateTime(2026, 12, 25), provider: provider),
        const [
          SeasonalEffect(SeasonalEffectKind.lights, SeasonalDensity.medium),
          SeasonalEffect(SeasonalEffectKind.snow, SeasonalDensity.high, [
            0xFFFF0000,
          ]),
        ],
      );
    });

    test('with the calendar off only the provider effects show', () {
      const provider = ProviderSeasonal(
        calendar: false,
        effects: [
          SeasonalEntry(
            kind: SeasonalEffectKind.hearts,
            from: SeasonalDate(12, 20),
            to: SeasonalDate(12, 31),
          ),
        ],
      );
      expect(
        activeSeasonalEffects(DateTime(2026, 12, 25), provider: provider),
        const [
          SeasonalEffect(SeasonalEffectKind.hearts, SeasonalDensity.medium),
        ],
      );
    });

    test(
      'with the calendar off and nothing covering the day nothing shows',
      () {
        expect(
          activeSeasonalEffects(
            DateTime(2026, 12, 25),
            provider: const ProviderSeasonal(calendar: false),
          ),
          isEmpty,
        );
      },
    );

    test('provider effects fill the layers before the calendar does', () {
      final provider = ProviderSeasonal(
        effects: [
          for (final kind in [
            SeasonalEffectKind.stars,
            SeasonalEffectKind.confetti,
          ])
            SeasonalEntry(
              kind: kind,
              from: const SeasonalDate(12, 1),
              to: const SeasonalDate(12, 31),
            ),
        ],
      );
      final kinds = activeSeasonalEffects(
        DateTime(2026, 12, 25),
        provider: provider,
      ).map((effect) => effect.kind);
      expect(kinds, hasLength(3));
      expect(
        kinds,
        containsAll([SeasonalEffectKind.stars, SeasonalEffectKind.confetti]),
      );
    });

    test(
      'past three layers the first provider effects win, in paint order',
      () {
        final provider = ProviderSeasonal(
          calendar: false,
          effects: [
            for (final kind in [
              SeasonalEffectKind.hearts,
              SeasonalEffectKind.confetti,
              SeasonalEffectKind.stars,
              SeasonalEffectKind.petals,
            ])
              SeasonalEntry(
                kind: kind,
                from: const SeasonalDate(12, 1),
                to: const SeasonalDate(12, 31),
              ),
          ],
        );
        expect(
          activeSeasonalEffects(DateTime(2026, 12, 25), provider: provider),
          const [
            SeasonalEffect(SeasonalEffectKind.stars, SeasonalDensity.medium),
            SeasonalEffect(SeasonalEffectKind.confetti, SeasonalDensity.medium),
            SeasonalEffect(SeasonalEffectKind.hearts, SeasonalDensity.medium),
          ],
        );
      },
    );
  });

  group('SeasonalEffect', () {
    test('equal kind, density and colors make equal effects', () {
      final colors = [0xFFFF0000];
      final effect = SeasonalEffect(
        SeasonalEffectKind.snow,
        SeasonalDensity.low,
        colors,
      );
      final same = SeasonalEffect(
        SeasonalEffectKind.snow,
        SeasonalDensity.low,
        [...colors],
      );
      expect(effect, equals(same));
      expect(effect.hashCode, same.hashCode);
    });

    test('a different kind, density or color is a different effect', () {
      const effect = SeasonalEffect(
        SeasonalEffectKind.snow,
        SeasonalDensity.low,
      );
      expect(
        effect,
        isNot(
          const SeasonalEffect(SeasonalEffectKind.leaves, SeasonalDensity.low),
        ),
      );
      expect(
        effect,
        isNot(
          const SeasonalEffect(SeasonalEffectKind.snow, SeasonalDensity.high),
        ),
      );
      expect(
        effect,
        isNot(
          const SeasonalEffect(SeasonalEffectKind.snow, SeasonalDensity.low, [
            0xFFFF0000,
          ]),
        ),
      );
    });
  });
}
