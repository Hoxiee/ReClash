import 'package:reclash/subscriptions/metadata/provider_seasonal.dart';

export 'package:reclash/subscriptions/metadata/provider_seasonal.dart';

/// The app's own calendar, read against the device's local date. Later
/// entries override earlier ones of the same kind.
const builtinSeasonalCalendar = [
  SeasonalEntry(
    kind: SeasonalEffectKind.leaves,
    from: SeasonalDate(10, 1),
    to: SeasonalDate(11, 10),
    density: SeasonalDensity.low,
  ),
  SeasonalEntry(
    kind: SeasonalEffectKind.snow,
    from: SeasonalDate(12, 1),
    to: SeasonalDate(2, 29),
    density: SeasonalDensity.low,
  ),
  SeasonalEntry(
    kind: SeasonalEffectKind.snow,
    from: SeasonalDate(12, 20),
    to: SeasonalDate(1, 14),
  ),
  SeasonalEntry(
    kind: SeasonalEffectKind.lights,
    from: SeasonalDate(12, 20),
    to: SeasonalDate(1, 14),
  ),
  SeasonalEntry(
    kind: SeasonalEffectKind.petals,
    from: SeasonalDate(4, 1),
    to: SeasonalDate(5, 10),
    density: SeasonalDensity.low,
  ),
];

/// More layers at once stop reading as a background.
const maxSeasonalLayers = 3;

class SeasonalEffect {
  const SeasonalEffect(this.kind, this.density, [this.colors = const []]);

  final SeasonalEffectKind kind;
  final SeasonalDensity density;
  final List<int> colors;

  @override
  bool operator ==(Object other) =>
      other is SeasonalEffect &&
      other.kind == kind &&
      other.density == density &&
      _sameColors(other.colors, colors);

  @override
  int get hashCode => Object.hash(kind, density, Object.hashAll(colors));
}

bool _sameColors(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The effects for [local], in paint order. A provider's effect replaces the
/// calendar's of the same kind; past [maxSeasonalLayers] the provider's
/// effects are kept first.
List<SeasonalEffect> activeSeasonalEffects(
  DateTime local, {
  ProviderSeasonal? provider,
}) {
  final calendar = {
    if (provider?.calendar ?? true)
      for (final entry in builtinSeasonalCalendar)
        if (entry.covers(local)) entry.kind: entry,
  };
  final provided = {
    for (final entry in provider?.effects ?? const <SeasonalEntry>[])
      if (entry.covers(local)) entry.kind: entry,
  };
  final chosen = {
    ...provided,
    for (final MapEntry(:key, :value) in calendar.entries)
      if (!provided.containsKey(key)) key: value,
  };
  final kinds = chosen.keys.take(maxSeasonalLayers).toSet();
  return [
    for (final kind in SeasonalEffectKind.values)
      if (kinds.contains(kind))
        SeasonalEffect(kind, chosen[kind]!.density, chosen[kind]!.colors),
  ];
}
