/// The particle layers the app background can show.
enum SeasonalEffectKind {
  stars,
  lights,
  leaves,
  petals,
  confetti,
  hearts,
  snow,
}

enum SeasonalDensity { low, medium, high }

/// A day of the year, or of one particular year when [year] is set.
class SeasonalDate implements Comparable<SeasonalDate> {
  const SeasonalDate(this.month, this.day, [this.year]);

  final int month;
  final int day;
  final int? year;

  static final _pattern = RegExp(r'^(?:(\d{4})-)?(\d{2})-(\d{2})$');

  static SeasonalDate? tryParse(Object? value) {
    if (value is! String) return null;
    final match = _pattern.firstMatch(value.trim());
    if (match == null) return null;
    final year = match[1] == null ? null : int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    if (month < 1 || month > 12 || day < 1) return null;
    final last = DateTime.utc(year ?? 2000, month + 1, 0).day;
    return day > last ? null : SeasonalDate(month, day, year);
  }

  int get _key => ((year ?? 0) * 100 + month) * 100 + day;

  @override
  int compareTo(SeasonalDate other) => _key.compareTo(other._key);

  @override
  bool operator ==(Object other) => other is SeasonalDate && other._key == _key;

  @override
  int get hashCode => _key;
}

/// One effect shown from [from] to [to], both inclusive. Days of the year
/// may wrap past the new year; dated ranges may not.
class SeasonalEntry {
  const SeasonalEntry({
    required this.kind,
    required this.from,
    required this.to,
    this.density = SeasonalDensity.medium,
    this.colors = const [],
  });

  final SeasonalEffectKind kind;
  final SeasonalDate from;
  final SeasonalDate to;
  final SeasonalDensity density;

  /// Opaque ARGB values replacing the effect's own palette.
  final List<int> colors;

  bool covers(DateTime local) {
    if (from.year != null) {
      final today = SeasonalDate(local.month, local.day, local.year);
      return from.compareTo(today) <= 0 && today.compareTo(to) <= 0;
    }
    final today = SeasonalDate(local.month, local.day);
    return from.compareTo(to) <= 0
        ? from.compareTo(today) <= 0 && today.compareTo(to) <= 0
        : from.compareTo(today) <= 0 || today.compareTo(to) <= 0;
  }
}

/// What the manifest's `seasonal` section asks for.
class ProviderSeasonal {
  const ProviderSeasonal({this.calendar = true, this.effects = const []});

  /// Whether the app's own calendar still runs beside [effects].
  final bool calendar;
  final List<SeasonalEntry> effects;
}

const seasonalEffectsLimit = 16;
const seasonalColorsLimit = 8;

const _sectionKeys = {'calendar', 'effects'};
const _entryKeys = {'effect', 'from', 'to', 'density', 'colors'};
final _hexColor = RegExp(r'^#?([0-9a-fA-F]{6})$');

/// Null for a section whose shape is wrong; an invalid effect is skipped
/// with a warning and the rest are kept.
ProviderSeasonal? parseProviderSeasonal(Object? value, List<String> warnings) {
  if (value is! Map<String, Object?>) return null;
  for (final key in value.keys) {
    if (!_sectionKeys.contains(key)) {
      warnings.add('Unknown key $key in seasonal');
    }
  }
  final calendar = switch (value['calendar']) {
    null || 'default' => true,
    'none' => false,
    _ => null,
  };
  if (calendar == null) return null;
  final raw = value['effects'] ?? const <Object?>[];
  if (raw is! List) return null;
  if (raw.length > seasonalEffectsLimit) {
    warnings.add('Only the first $seasonalEffectsLimit seasonal effects apply');
  }
  final effects = <SeasonalEntry>[];
  for (final (index, item) in raw.take(seasonalEffectsLimit).indexed) {
    final entry = item is Map<String, Object?> ? _entry(item, warnings) : null;
    if (entry == null) {
      warnings.add('Invalid seasonal effect at index $index');
    } else {
      effects.add(entry);
    }
  }
  return ProviderSeasonal(
    calendar: calendar,
    effects: List.unmodifiable(effects),
  );
}

SeasonalEntry? _entry(Map<String, Object?> entry, List<String> warnings) {
  for (final key in entry.keys) {
    if (!_entryKeys.contains(key)) {
      warnings.add('Unknown key $key in seasonal effect');
    }
  }
  final name = entry['effect'];
  final kind = SeasonalEffectKind.values
      .where((kind) => name is String && kind.name == name.trim().toLowerCase())
      .firstOrNull;
  final from = SeasonalDate.tryParse(entry['from']);
  final to = SeasonalDate.tryParse(entry['to']);
  if (kind == null || from == null || to == null) return null;
  if ((from.year == null) != (to.year == null)) return null;
  if (from.year != null && from.compareTo(to) > 0) return null;
  final density = switch (entry['density']) {
    null => SeasonalDensity.medium,
    final String name =>
      SeasonalDensity.values
          .where((density) => density.name == name.trim().toLowerCase())
          .firstOrNull,
    _ => null,
  };
  if (density == null) return null;
  final colors = _colors(entry['colors']);
  if (colors == null) return null;
  return SeasonalEntry(
    kind: kind,
    from: from,
    to: to,
    density: density,
    colors: colors,
  );
}

List<int>? _colors(Object? value) {
  if (value == null) return const [];
  if (value is! List ||
      value.isEmpty ||
      value.length > seasonalColorsLimit ||
      value.any((color) => color is! String || !_hexColor.hasMatch(color))) {
    return null;
  }
  return List.unmodifiable([
    for (final color in value.cast<String>())
      0xFF000000 | int.parse(_hexColor.firstMatch(color)![1]!, radix: 16),
  ]);
}
