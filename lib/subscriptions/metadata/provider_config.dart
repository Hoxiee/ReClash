import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../protocol/registry.dart';
import 'metadata.dart';
import 'provider_cards.dart';
import 'provider_power_labels.dart';

const providerConfigSizeLimit = 512 * 1024;
const providerConfigDepthLimit = 32;
const providerConfigVersion = 1;

const _localizedKeys = {'title', 'text', 'label', 'hint'};

class ProviderConfig {
  const ProviderConfig({
    required this.cards,
    required this.powerLabels,
    this.view = const {},
    this.powerButton = const {},
    this.wallpaper,
    this.widgets,
    this.fields = const {},
    this.routing,
  });

  final List<ProviderCard> cards;
  final ProviderPowerLabels powerLabels;

  /// Flat `group.key` pairs of the valid `view` entries, lowercased.
  final Map<String, String> view;

  /// The valid `shape` and `type` entries of `power-button`, lowercased.
  final Map<String, String> powerButton;
  final ({String url, int opacity})? wallpaper;

  /// Lowercased widget names in display order, null without a valid section.
  final List<String>? widgets;

  /// The valid manifest sections as snapshot metadata fields, keyed by
  /// registry path; text is resolved for the locale given to the parser.
  final Map<String, Object?> fields;

  /// The `routing` section when its shape is valid. The Core reads it from
  /// the stored source, so only its presence matters here.
  final Map<String, Object?>? routing;
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
    var view = const <String, String>{};
    var powerButton = const <String, String>{};
    ({String url, int opacity})? wallpaper;
    List<String>? widgets;
    var cards = const <ProviderCard>[];
    var labels = const <String, List<ProviderPowerLabel>>{};
    final fields = <String, Object?>{};
    Map<String, Object?>? routing;
    for (final MapEntry(:key, :value) in plain.entries) {
      switch (key) {
        case 'version':
          break;
        case 'view':
          if (value is Map<String, Object?>) {
            view = _view(value, warnings);
          } else {
            warnings.add('Invalid view section');
          }
        case 'power-button':
          if (value is Map<String, Object?>) {
            powerButton = _powerButton(value, warnings);
          } else {
            warnings.add('Invalid power-button section');
          }
        case 'wallpaper':
          wallpaper = value is Map<String, Object?>
              ? _wallpaper(value, warnings)
              : null;
          if (wallpaper == null) warnings.add('Invalid wallpaper section');
        case 'widgets':
          if (value is List && value.every((name) => name is String)) {
            widgets = [
              for (final name in value) (name! as String).trim().toLowerCase(),
            ];
          } else {
            warnings.add('Invalid widgets section');
          }
        case 'cards':
          final parsed = parseProviderCards(_localizedTexts(value, tags));
          cards = parsed.cards;
          warnings.addAll(parsed.warnings);
        case 'power-labels':
          labels = parseProviderPowerLabels(
            _labelStates(value, tags, warnings),
          );
        case 'routing':
          routing = _routing(value);
          if (routing == null) warnings.add('Invalid routing section');
        case _ when _fieldSections.contains(key):
          fields.addAll(_section(key, value, tags, warnings));
        default:
          warnings.add('Unknown key $key');
      }
    }
    return (
      config: ProviderConfig(
        cards: cards,
        powerLabels: labels,
        view: Map.unmodifiable(view),
        powerButton: Map.unmodifiable(powerButton),
        wallpaper: wallpaper,
        widgets: widgets == null ? null : List.unmodifiable(widgets),
        fields: Map.unmodifiable(fields),
        routing: routing,
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

({String url, int opacity})? _wallpaper(
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
  return (url: url, opacity: valid ? opacity : _wallpaperDefaultOpacity);
}

const _fieldSections = {
  'provider',
  'reminders',
  'settings',
  'policy',
  'apps',
  'transport',
  'support',
};

/// Manifest key to [ProviderSettingFlag] name.
const providerSettingKeys = {
  'minimize-on-exit': 'minimize',
  'launch-at-login': 'autorun',
  'start-hidden': 'shadowstart',
  'connect-on-launch': 'autostart',
  'check-app-updates': 'autoupdate',
  'capture-logs': 'openlogs',
  'close-connections': 'closeconnections',
};

/// Each policy key's values, mapped to the restriction the value turns on;
/// null is the unrestricted default.
const providerPolicyValues = <String, Map<String, String?>>{
  'global': {'any': null, 'listed': 'lockglobal', 'off': 'noglobal'},
  'apps': {'recommended': null, 'required': 'lockapps'},
  'local-ports': {'open': null, 'closed': 'androidsecure'},
  'dashboard': {'editable': null, 'locked': 'denywidgets'},
};

/// A section with any invalid value is ignored whole, so its fields are
/// withdrawn rather than half applied.
Map<String, Object?> _section(
  String name,
  Object? value,
  List<String> tags,
  List<String> warnings,
) {
  final fields = <String, Object?>{};
  final known = <String>{};
  void invalid(String detail) => warnings.add('Invalid $name section: $detail');

  if (value is! Map<String, Object?>) {
    invalid('expected a map');
    return const {};
  }
  if (name == 'policy') {
    final tokens = <String>[];
    for (final MapEntry(:key, :value) in value.entries) {
      final values = providerPolicyValues[key];
      if (values == null) {
        warnings.add('Unknown key $key in policy');
      } else if (!values.containsKey(value)) {
        invalid('$key has no value $value');
        return const {};
      } else if (values[value] case final token?) {
        tokens.add(token);
      }
    }
    return _checked(name, 'settings.restrictions', tokens, warnings);
  }
  if (name == 'settings') {
    final flags = <String, bool>{};
    for (final MapEntry(:key, :value) in value.entries) {
      final flag = providerSettingKeys[key];
      if (flag == null) {
        warnings.add('Unknown key $key in settings');
      } else if (value is bool) {
        flags[flag] = value;
      } else {
        invalid('$key must be a boolean');
        return const {};
      }
    }
    return flags.isEmpty
        ? const {}
        : _checked(name, 'settings.flags', flags, warnings);
  }
  for (final field in subscriptionFields) {
    final manifest = field.manifest;
    if (manifest == null || manifest.split('.').first != name) continue;
    final rest = manifest.split('.').skip(1).toList();
    known.add(rest.join('.'));
    final raw = _lookup(value, rest);
    if (raw != null) {
      final converted = _convert(field, raw, tags);
      if (converted == null || !validSubscriptionField(field, converted)) {
        invalid(manifest);
        return const {};
      }
      fields[field.path] = converted;
    }
    if (field.suffix case final suffix?) {
      final count = _lookup(value, suffix.manifest.split('.').skip(1).toList());
      known.add(suffix.manifest.split('.').skip(1).join('.'));
      if (count != null) {
        if (count is! int || count < suffix.minimum || count > suffix.maximum) {
          invalid(suffix.manifest);
          return const {};
        }
        fields[suffix.path] = count;
      }
    }
  }
  _unknownKeys(value, '', known, name, warnings);
  return fields;
}

Map<String, Object?> _checked(
  String section,
  String path,
  Object value,
  List<String> warnings,
) {
  final field = subscriptionFields.firstWhere((f) => f.path == path);
  if (value is Iterable && value.isEmpty) return const {};
  if (!validSubscriptionField(field, value)) {
    warnings.add('Invalid $section section');
    return const {};
  }
  return {path: value};
}

Object? _lookup(Map<String, Object?> map, List<String> path) {
  Object? current = map;
  for (final key in path) {
    if (current is! Map<String, Object?>) return null;
    current = current[key];
  }
  return current;
}

void _unknownKeys(
  Map<String, Object?> map,
  String prefix,
  Set<String> known,
  String section,
  List<String> warnings,
) {
  for (final MapEntry(:key, :value) in map.entries) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    final isPrefix = known.any((k) => k.startsWith('$path.'));
    if (known.contains(path)) continue;
    if (isPrefix && value is Map<String, Object?>) {
      _unknownKeys(value, path, known, section, warnings);
    } else {
      warnings.add('Unknown key $path in $section');
    }
  }
}

Object? _convert(SubscriptionField field, Object raw, List<String> tags) {
  switch (field.type) {
    case SubscriptionFieldType.text:
      final text = switch (raw) {
        final String text => text,
        final Map<String, Object?> map => _localized(map, tags),
        _ => null,
      };
      return text == null || text.trim().isEmpty ? null : text.trim();
    case SubscriptionFieldType.tokens:
    case SubscriptionFieldType.hosts:
      final list = field.limit == 1 ? (raw is String ? [raw] : null) : raw;
      if (list is! List || list.any((item) => item is! String)) return null;
      final items = [
        for (final item in list.cast<String>())
          if (field.type == SubscriptionFieldType.hosts)
            subscriptionAuthority(item.trim()) ?? item
          else
            item.trim().toLowerCase(),
      ];
      return items.toSet().toList();
    case SubscriptionFieldType.numbers:
      return raw is List && raw.every((n) => n is int)
          ? (raw.cast<int>().toSet().toList()..sort())
          : null;
    case SubscriptionFieldType.packages:
    case SubscriptionFieldType.keys:
      return raw is List && raw.every((item) => item is String)
          ? raw.cast<String>().toSet().toList()
          : null;
    default:
      return raw;
  }
}

const _routingKeys = {'profiles', 'scenarios', 'scenario', 'bindings'};

Map<String, Object?>? _routing(Object? value) {
  if (value is! Map<String, Object?> ||
      value.keys.any((key) => !_routingKeys.contains(key))) {
    return null;
  }
  for (final key in ['profiles', 'scenarios', 'bindings']) {
    if (value.containsKey(key) && value[key] is! Map<String, Object?>) {
      return null;
    }
  }
  if (value.containsKey('scenario') && value['scenario'] is! String) {
    return null;
  }
  return value;
}
