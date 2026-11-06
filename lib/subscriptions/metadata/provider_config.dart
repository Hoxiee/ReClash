import 'dart:convert';

import 'package:yaml/yaml.dart';

import 'metadata.dart';
import 'provider_cards.dart';
import 'provider_power_labels.dart';

const providerConfigSizeLimit = 256 * 1024;
const providerConfigDepthLimit = 32;
const providerConfigVersion = 1;

const _localizedKeys = {'title', 'text', 'label', 'hint'};

class ProviderConfig {
  const ProviderConfig({
    required this.cards,
    required this.powerLabels,
    this.overrides = const {},
  });

  final List<ProviderCard> cards;
  final ProviderPowerLabels powerLabels;

  /// Valid presentation sections as the header fields they replace.
  final Map<String, Object?> overrides;
}

typedef ProviderConfigResult = ({
  ProviderConfig? config,
  List<String> warnings,
});

class _Rejected implements Exception {
  const _Rejected(this.reason);

  final String reason;
}

/// Never throws: a rejected document has a null config and the reason in
/// the warnings. [locale] is a language tag such as `ru` or `pt-BR`.
ProviderConfigResult parseProviderConfig(String source, String locale) {
  final warnings = <String>[];
  try {
    if (utf8.encode(source).length > providerConfigSizeLimit) {
      throw const _Rejected('Config is over $providerConfigSizeLimit bytes');
    }
    final Object? plain;
    try {
      plain = _plain(loadYamlNode(source), 0, Set<Object>.identity());
    } on _Rejected {
      rethrow;
    } catch (_) {
      throw const _Rejected('Config is not valid YAML');
    }
    if (plain is! Map<String, Object?>) {
      throw const _Rejected('Config must be a map');
    }
    final version = plain['version'];
    if (version is! int || version != providerConfigVersion) {
      throw const _Rejected('Unsupported config version');
    }
    final tags = _tags(locale);
    final overrides = <String, Object?>{};
    var cards = const <ProviderCard>[];
    var labels = const <String, List<ProviderPowerLabel>>{};
    for (final MapEntry(:key, :value) in plain.entries) {
      switch (key) {
        case 'version':
          break;
        case 'view' || 'power-button' || 'wallpaper' || 'widgets':
          overrides.addAll(_section(key, value, warnings));
        case 'cards':
          final parsed = parseProviderCards(_localizedTexts(value, tags));
          cards = parsed.cards;
          warnings.addAll(parsed.warnings);
        case 'power-labels':
          labels = parseProviderPowerLabels(
            _labelStates(value, tags, warnings),
          );
        default:
          warnings.add('Unknown key $key');
      }
    }
    return (
      config: ProviderConfig(
        cards: cards,
        powerLabels: labels,
        overrides: Map.unmodifiable(overrides),
      ),
      warnings: List.unmodifiable(warnings),
    );
  } on _Rejected catch (e) {
    return (config: null, warnings: List.unmodifiable([...warnings, e.reason]));
  } catch (_) {
    return (
      config: null,
      warnings: List.unmodifiable([...warnings, 'Config could not be read']),
    );
  }
}

/// package:yaml resolves an alias to the node instance of its anchor, so a
/// repeated instance is an alias; that also bounds an expansion bomb.
Object? _plain(YamlNode node, int depth, Set<Object> seen) {
  if (depth > providerConfigDepthLimit) {
    throw const _Rejected('Config is nested too deeply');
  }
  if (!seen.add(node)) {
    throw const _Rejected('Anchors and aliases are not allowed');
  }
  switch (node) {
    case YamlScalar():
      return node.value;
    case YamlList():
      return [for (final item in node.nodes) _plain(item, depth + 1, seen)];
    case YamlMap():
      final map = <String, Object?>{};
      for (final entry in node.nodes.entries) {
        final key = entry.key;
        if (key is! YamlScalar || key.value is! String) {
          throw const _Rejected('Keys must be strings');
        }
        if (!seen.add(key)) {
          throw const _Rejected('Anchors and aliases are not allowed');
        }
        if (map.containsKey(key.value)) {
          throw const _Rejected('Duplicate key');
        }
        map[key.value as String] = _plain(entry.value, depth + 1, seen);
      }
      return map;
    default:
      throw const _Rejected('Unsupported YAML node');
  }
}

List<String> _tags(String locale) {
  final tag = locale.trim().toLowerCase().replaceAll('_', '-');
  final language = tag.split('-').first;
  return [
    if (tag.isNotEmpty) tag,
    if (language.isNotEmpty && language != tag) language,
    'en',
  ];
}

/// A text key may hold a locale map; everything else passes through.
Object? _localizedTexts(Object? value, List<String> tags) => switch (value) {
  final List<Object?> list => [
    for (final item in list) _localizedTexts(item, tags),
  ],
  final Map<String, Object?> map => {
    for (final MapEntry(:key, :value) in map.entries)
      key: _localizedKeys.contains(key) && value is Map<String, Object?>
          ? _localized(value, tags)
          : _localizedTexts(value, tags),
  },
  _ => value,
};

/// A state holds an entry or a list of them; an entry is a string, a locale
/// map, or `{title, hint}` where each part may itself be a locale map.
Object? _labelStates(Object? value, List<String> tags, List<String> warnings) {
  if (value is! Map<String, Object?>) return value;
  Object? entry(Object? e) {
    if (e is! Map<String, Object?>) return e;
    if (!e.containsKey('title')) return _localized(e, tags);
    final out = <String, Object?>{};
    for (final part in e.entries) {
      if (part.key != 'title' && part.key != 'hint') {
        warnings.add('Unknown key ${part.key} in power-labels');
        continue;
      }
      final v = part.value;
      out[part.key] = v is Map<String, Object?> ? _localized(v, tags) : v;
    }
    return out;
  }

  final out = <String, Object?>{};
  for (final state in value.entries) {
    if (!providerPowerLabelStates.contains(state.key)) {
      warnings.add('Unknown key ${state.key} in power-labels');
      continue;
    }
    final v = state.value;
    out[state.key] = v is List ? [for (final e in v) entry(e)] : entry(v);
  }
  return out;
}

String _localized(Map<String, Object?> map, List<String> tags) {
  for (final entry in map.entries) {
    final v = entry.value;
    if (v is! String || v.trim().isEmpty) return '';
  }
  if (map.isEmpty) return '';
  final lower = {for (final e in map.entries) e.key.toLowerCase(): e.value};
  for (final tag in tags) {
    if (lower[tag] case final String text) return text;
  }
  return map.values.first! as String;
}

const _viewKeys = {
  'proxies': {'type', 'sort', 'layout', 'icon', 'card'},
  'app': {'navbar', 'tabs', 'glass', 'color', 'color-dark', 'style', 'black'},
};
const _wallpaperDefaultOpacity = 8;

/// A valid section as the header fields it replaces; an invalid one warns
/// and yields nothing, so the header stays in effect.
Map<String, Object?> _section(
  String key,
  Object? value,
  List<String> warnings,
) {
  switch (key) {
    case 'view':
      if (value is Map<String, Object?>) {
        return {'presentation.view': _view(value, warnings)};
      }
    case 'power-button':
      if (value is Map<String, Object?>) {
        return {'presentation.powerButton': _powerButton(value, warnings)};
      }
    case 'wallpaper':
      if (value is Map<String, Object?>) {
        final fields = _wallpaper(value, warnings);
        if (fields != null) return fields;
      }
    case 'widgets':
      if (value is List && value.every((name) => name is String)) {
        return {
          'presentation.widgets': [
            for (final name in value) (name! as String).trim().toLowerCase(),
          ],
        };
      }
  }
  warnings.add('Invalid $key section');
  return const {};
}

Map<String, String> _view(Map<String, Object?> view, List<String> warnings) {
  final pairs = <String, String>{};
  for (final group in view.entries) {
    final name = group.key.toLowerCase();
    final known = _viewKeys[name];
    final values = group.value;
    if (known == null || values is! Map<String, Object?>) {
      warnings.add('Unknown or invalid key ${group.key} in view');
      continue;
    }
    for (final item in values.entries) {
      final key = item.key.toLowerCase();
      final value = item.value;
      if (!known.contains(key)) {
        warnings.add('Unknown key ${item.key} in view.${group.key}');
      } else if (name == 'app' && key == 'black' && value is bool) {
        pairs['app.black'] = '$value';
      } else if (key != 'black' && value is String) {
        pairs['$name.${key.replaceAll('-', '')}'] = value.trim().toLowerCase();
      } else {
        warnings.add('Invalid value for ${group.key}.${item.key} in view');
      }
    }
  }
  return pairs;
}

Map<String, String> _powerButton(
  Map<String, Object?> button,
  List<String> warnings,
) {
  final pairs = <String, String>{};
  for (final item in button.entries) {
    final key = item.key.toLowerCase();
    final value = item.value;
    if (key == 'shape' &&
        (value is String ||
            (value is List && value.every((name) => name is String)))) {
      final names = value is String ? [value] : value as List;
      pairs[key] = names
          .map((n) => (n as String).trim().toLowerCase())
          .join(',');
    } else if (key == 'type' && value is String) {
      pairs[key] = value.trim().toLowerCase();
    } else {
      warnings.add(
        key == 'shape' || key == 'type'
            ? 'Invalid value for ${item.key} in power-button'
            : 'Unknown key ${item.key} in power-button',
      );
    }
  }
  return pairs;
}

Map<String, Object?>? _wallpaper(
  Map<String, Object?> wallpaper,
  List<String> warnings,
) {
  for (final key in wallpaper.keys) {
    if (key != 'url' && key != 'opacity') {
      warnings.add('Unknown key $key in wallpaper');
    }
  }
  final url = wallpaper['url'];
  if (url is! String || safeSubscriptionLink(url, httpsOnly: true) == null) {
    return null;
  }
  final opacity = wallpaper['opacity'];
  final valid = opacity is int && opacity >= 1 && opacity <= 100;
  if (wallpaper.containsKey('opacity') && !valid) {
    warnings.add('Invalid opacity in wallpaper');
  }
  return {
    'presentation.background': url,
    'presentation.backgroundOpacity': valid
        ? opacity
        : _wallpaperDefaultOpacity,
  };
}
