const providerPowerLabelTitleLimit = 64;
const providerPowerLabelHintLimit = 96;
const providerPowerLabelStates = [
  'off',
  'connecting',
  'on',
  'paused',
  'expired',
  'exhausted',
  'ending',
  'grace',
];

class ProviderPowerLabel {
  const ProviderPowerLabel(this.title, [this.hint]);

  final String title;
  final String? hint;

  @override
  bool operator ==(Object other) =>
      other is ProviderPowerLabel && other.title == title && other.hint == hint;

  @override
  int get hashCode => Object.hash(title, hint);
}

/// The values for each state; an array keeps every valid entry for the
/// session pick.
typedef ProviderPowerLabels = Map<String, List<ProviderPowerLabel>>;

/// Entries that are not a string or `{title, hint}` within the limits are
/// dropped, so a state with none left uses the localized text.
ProviderPowerLabels parseProviderPowerLabels(Object? json) {
  if (json is! Map) return const {};
  final labels = <String, List<ProviderPowerLabel>>{};
  for (final state in providerPowerLabelStates) {
    final value = json[state];
    final entries = value is List ? value : [value];
    final parsed = [for (final entry in entries) ?_label(entry)];
    if (parsed.isNotEmpty) labels[state] = List.unmodifiable(parsed);
  }
  return Map.unmodifiable(labels);
}

ProviderPowerLabel? _label(Object? entry) {
  final title = entry is Map ? entry['title'] : entry;
  if (title is! String || !_fits(title, providerPowerLabelTitleLimit)) {
    return null;
  }
  if (entry is! Map || !entry.containsKey('hint')) {
    return ProviderPowerLabel(title);
  }
  final hint = entry['hint'];
  if (hint is! String || !_fits(hint, providerPowerLabelHintLimit)) {
    return null;
  }
  return ProviderPowerLabel(title, hint);
}

bool _fits(String value, int limit) =>
    value.trim().isNotEmpty && value.runes.length <= limit;

final _placeholder = RegExp(r'\{(daysLeft|trafficLeft|server)\}');

/// Null when a placeholder has no value, so the whole label falls back.
String? fillProviderPlaceholders(String text, Map<String, String?> values) {
  var missing = false;
  final filled = text.replaceAllMapped(_placeholder, (match) {
    final value = values[match.group(1)];
    if (value == null) missing = true;
    return value ?? '';
  });
  return missing ? null : filled;
}

/// The label with its placeholders filled, or null to use the localized one.
ProviderPowerLabel? resolveProviderPowerLabel(
  ProviderPowerLabel label,
  Map<String, String?> values,
) {
  final title = fillProviderPlaceholders(label.title, values);
  final hint = label.hint == null
      ? null
      : fillProviderPlaceholders(label.hint!, values);
  if (title == null || (label.hint != null && hint == null)) return null;
  return ProviderPowerLabel(title, hint);
}
