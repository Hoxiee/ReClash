import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/provider_settings.dart';

import 'calendar.dart';

final seasonalClockProvider = Provider<DateTime Function()>(
  (_) => DateTime.now,
);

/// The local date; [SeasonalBackdrop] moves it on at midnight and on resume.
class SeasonalToday extends Notifier<DateTime> {
  @override
  DateTime build() => _today();

  DateTime _today() {
    final now = ref.read(seasonalClockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  void refresh() {
    final today = _today();
    if (today != state) state = today;
  }
}

final seasonalTodayProvider = NotifierProvider<SeasonalToday, DateTime>(
  SeasonalToday.new,
);

final seasonalEffectsProvider = Provider<List<SeasonalEffect>>((ref) {
  final enabled = ref.watch(
    themeSettingProvider.select((theme) => theme.seasonalEffects),
  );
  if (!enabled) return const [];
  final provider = ref.watch(
    providerHintsProvider.select((hints) => hints?.seasonal),
  );
  return activeSeasonalEffects(
    ref.watch(seasonalTodayProvider),
    provider: provider,
  );
});
