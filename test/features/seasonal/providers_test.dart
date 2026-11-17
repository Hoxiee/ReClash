import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/seasonal/calendar.dart';
import 'package:reclash/features/seasonal/providers.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';

import '../../helpers/provider_presentation.dart';

void main() {
  late DateTime now;
  late ProviderContainer container;

  setUp(() {
    now = DateTime(2026, 12, 25, 10);
    container = ProviderContainer(
      overrides: [
        seasonalClockProvider.overrideWithValue(() => now),
        providerHintsProvider.overrideWithValue(ProviderHints.empty),
      ],
    );
    addTearDown(container.dispose);
    container.listen(themeSettingProvider, (_, _) {});
  });

  group('seasonalEffectsProvider', () {
    test('shows the built-in effects for the clock date by default', () {
      final effects = container.read(seasonalEffectsProvider);
      expect(effects, isNotEmpty);
      expect(effects, activeSeasonalEffects(DateTime(2026, 12, 25)));
    });

    test('the theme setting turns the effects off and back on', () {
      final notifier = container.read(themeSettingProvider.notifier);
      notifier.update((theme) => theme.copyWith(seasonalEffects: false));
      expect(container.read(seasonalEffectsProvider), isEmpty);

      notifier.update((theme) => theme.copyWith(seasonalEffects: true));
      expect(container.read(seasonalEffectsProvider), isNotEmpty);
    });
  });

  test('a provider seasonal section replaces the built-in effects', () {
    final provider = ProviderContainer(
      overrides: [
        seasonalClockProvider.overrideWithValue(() => now),
        providerHintsProvider.overrideWithValue(
          presentedHints({
            'seasonal': {
              'calendar': 'none',
              'effects': [
                {'effect': 'hearts', 'from': '12-20', 'to': '12-31'},
              ],
            },
          }),
        ),
      ],
    );
    addTearDown(provider.dispose);

    expect(provider.read(seasonalEffectsProvider), const [
      SeasonalEffect(SeasonalEffectKind.hearts, SeasonalDensity.medium),
    ]);
  });

  test('refresh moves the date to the clock and the effects with it', () {
    expect(container.read(seasonalTodayProvider), DateTime(2026, 12, 25));

    now = DateTime(2026, 11, 17, 9);
    container.read(seasonalTodayProvider.notifier).refresh();

    expect(container.read(seasonalTodayProvider), DateTime(2026, 11, 17));
    expect(container.read(seasonalEffectsProvider), isEmpty);
  });
}
