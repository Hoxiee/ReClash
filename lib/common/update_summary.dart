import 'dart:convert';

const releaseSummaryMarker = '<!-- reclash:update:json';
const _summaryLimit = 65536;
const _platforms = {'android', 'windows', 'macos', 'linux'};
const _kinds = {'wallpaper', 'link', 'dashboard', 'shield', 'speed', 'update'};

class ReleaseHighlight {
  const ReleaseHighlight({
    required this.title,
    required this.description,
    this.kind = 'update',
    this.platforms = const {},
  });

  final String title;
  final String description;
  final String kind;
  final Set<String> platforms;

  bool appliesTo(String platform) =>
      platforms.isEmpty || platforms.contains(platform);

  Map<String, Object> toJson() => {
    'title': title,
    'description': description,
    'kind': kind,
    if (platforms.isNotEmpty) 'platforms': platforms.toList(),
  };

  factory ReleaseHighlight.fromJson(Object? value) {
    final json = _object(value);
    final kind = json['kind'] ?? 'update';
    if (kind is! String || !_kinds.contains(kind)) {
      throw const FormatException('Unknown release highlight kind');
    }
    final rawPlatforms = json['platforms'] ?? const [];
    if (rawPlatforms is! List ||
        rawPlatforms.any((item) => !_platforms.contains(item))) {
      throw const FormatException('Unknown release platform');
    }
    return ReleaseHighlight(
      title: _text(json['title'], 120),
      description: _text(json['description'], 600),
      kind: kind,
      platforms: Set.unmodifiable(rawPlatforms.cast<String>()),
    );
  }
}

class ReleaseSummaryLocale {
  const ReleaseSummaryLocale({
    required this.headline,
    required this.spotlight,
    this.highlights = const [],
    this.warnings = const [],
  });

  final String headline;
  final ReleaseHighlight spotlight;
  final List<ReleaseHighlight> highlights;
  final List<ReleaseHighlight> warnings;

  ReleaseSummaryLocale forPlatform(String platform) => ReleaseSummaryLocale(
    headline: headline,
    spotlight: spotlight,
    highlights: highlights.where((item) => item.appliesTo(platform)).toList(),
    warnings: warnings.where((item) => item.appliesTo(platform)).toList(),
  );

  Map<String, Object> toJson() => {
    'headline': headline,
    'spotlight': spotlight.toJson(),
    'highlights': highlights.map((item) => item.toJson()).toList(),
    'warnings': warnings.map((item) => item.toJson()).toList(),
  };

  factory ReleaseSummaryLocale.fromJson(Object? value) {
    final json = _object(value);
    return ReleaseSummaryLocale(
      headline: _text(json['headline'], 120),
      spotlight: ReleaseHighlight.fromJson(json['spotlight']),
      highlights: _items(json['highlights'], 10),
      warnings: _items(json['warnings'], 12),
    );
  }
}

class ReleaseSummary {
  const ReleaseSummary({
    required this.tag,
    required this.locales,
    this.automaticInstall = false,
  });

  final String tag;
  final bool automaticInstall;
  final Map<String, ReleaseSummaryLocale> locales;

  ReleaseSummaryLocale? localized(String locale, {required String platform}) {
    final normalized = locale.replaceAll('-', '_').toLowerCase();
    final language = normalized.split('_').first;
    final content = locales[normalized] ?? locales[language] ?? locales['en']!;
    final fallback = locales['en']!;
    final selected = content.spotlight.appliesTo(platform) ? content : fallback;
    if (selected.spotlight.appliesTo(platform)) {
      return selected.forPlatform(platform);
    }
    final applicable = selected.highlights
        .where((item) => item.appliesTo(platform))
        .toList();
    if (applicable.isEmpty) return null;
    return ReleaseSummaryLocale(
      headline: selected.headline,
      spotlight: applicable.first,
      highlights: applicable.skip(1).toList(),
      warnings: selected.warnings
          .where((item) => item.appliesTo(platform))
          .toList(),
    );
  }

  bool get permitsAutomaticInstall =>
      automaticInstall &&
      locales.values.every((locale) => locale.warnings.isEmpty);

  Map<String, Object> toJson() => {
    'schemaVersion': 1,
    'tag': tag,
    'automaticInstall': automaticInstall,
    'locales': locales.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory ReleaseSummary.fromJson(Object? value) {
    final json = _object(value);
    if (json['schemaVersion'] != 1 || json['automaticInstall'] is! bool) {
      throw const FormatException('Unsupported release summary schema');
    }
    final tag = _text(json['tag'], 100);
    final rawLocales = _object(json['locales']);
    if (!rawLocales.containsKey('en') || rawLocales.length > 32) {
      throw const FormatException('Release summary needs an English fallback');
    }
    final locales = <String, ReleaseSummaryLocale>{};
    for (final entry in rawLocales.entries) {
      if (!RegExp(r'^[a-z]{2,3}(?:_[a-z0-9]{2,8})?$').hasMatch(entry.key)) {
        throw const FormatException('Invalid release summary locale');
      }
      locales[entry.key] = ReleaseSummaryLocale.fromJson(entry.value);
    }
    final baselineWarnings = locales['en']!.warnings;
    for (final locale in locales.values) {
      if (locale.warnings.length != baselineWarnings.length) {
        throw const FormatException(
          'A translation must preserve release warnings',
        );
      }
      for (var index = 0; index < baselineWarnings.length; index++) {
        final expected = baselineWarnings[index].platforms;
        final actual = locale.warnings[index].platforms;
        if (expected.length != actual.length || !actual.containsAll(expected)) {
          throw const FormatException(
            'A translation must preserve warning platforms',
          );
        }
      }
    }
    return ReleaseSummary(
      tag: tag,
      automaticInstall: json['automaticInstall'] as bool,
      locales: Map.unmodifiable(locales),
    );
  }
}

ReleaseSummary? parseReleaseSummary(String? body, {required String tag}) {
  if (body == null) return null;
  final begin = body.indexOf(releaseSummaryMarker);
  if (begin < 0 || body.indexOf(releaseSummaryMarker, begin + 1) >= 0) {
    return null;
  }
  final start = begin + releaseSummaryMarker.length;
  final end = body.indexOf('-->', start);
  if (end < 0 || end - start > _summaryLimit) return null;
  try {
    final summary = ReleaseSummary.fromJson(
      jsonDecode(body.substring(start, end)),
    );
    return summary.tag == tag ? summary : null;
  } on Object {
    return null;
  }
}

String renderReleaseSummary(ReleaseSummary summary) {
  final payload = jsonEncode(
    summary.toJson(),
  ).replaceAll('>', String.fromCharCodes([92, 117, 48, 48, 51, 101]));
  if (payload.length > _summaryLimit) {
    throw const FormatException('Release summary is too large');
  }
  return '$releaseSummaryMarker\n$payload\n-->\n';
}

Map<String, dynamic> _object(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected a release summary object');
  }
  return value;
}

String _text(Object? value, int limit) {
  if (value is! String || value.trim().isEmpty || value.length > limit) {
    throw const FormatException('Invalid release summary text');
  }
  return value.trim();
}

List<ReleaseHighlight> _items(Object? value, int limit) {
  if (value is! List || value.length > limit) {
    throw const FormatException('Invalid release summary items');
  }
  return List.unmodifiable(value.map(ReleaseHighlight.fromJson));
}
