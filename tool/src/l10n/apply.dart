import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../assemble_l10n.dart';
import 'placeholders.dart';
import 'workspace.dart';

final _keyPattern = RegExp(r'^[A-Za-z][A-Za-z0-9_]*$');
const _specFields = {'fragment', 'set', 'remove', 'remove_upstream'};

class SpecMessage {
  SpecMessage(this.values, this.metadata);

  final Map<String, String> values;
  final ArbMap? metadata;
}

class L10nSpec {
  L10nSpec({
    required this.fragment,
    required this.set,
    required this.remove,
    required this.removeUpstream,
  });

  factory L10nSpec.parse(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (error) {
      throw L10nException(['spec: invalid JSON: ${error.message}']);
    }
    if (json is! Map<String, Object?>) {
      throw L10nException(['spec: must be a JSON object']);
    }
    final errors = [
      for (final field in json.keys)
        if (!_specFields.contains(field)) 'spec: unknown field $field',
    ];
    final fragment = json['fragment'];
    if (fragment is! String || !featurePattern.hasMatch(fragment)) {
      errors.add('spec: fragment must match ${featurePattern.pattern}');
    }
    final set = <String, SpecMessage>{};
    final rawSet = json['set'] ?? const <String, Object?>{};
    if (rawSet is! Map<String, Object?>) {
      errors.add('spec: set must be an object');
    } else {
      for (final MapEntry(:key, :value) in rawSet.entries) {
        final message = _parseMessage(key, value, errors);
        if (message != null) set[key] = message;
      }
    }
    final remove = _keyList(json, 'remove', errors);
    final removeUpstream = _keyList(json, 'remove_upstream', errors);
    for (final key in {...remove, ...removeUpstream}) {
      if (set.containsKey(key)) errors.add('$key: both set and removed');
    }
    for (final key in remove.toSet().intersection(removeUpstream.toSet())) {
      errors.add('$key: both remove and remove_upstream');
    }
    if (errors.isNotEmpty) throw L10nException(errors);
    return L10nSpec(
      fragment: fragment as String,
      set: set,
      remove: remove,
      removeUpstream: removeUpstream,
    );
  }

  final String fragment;
  final Map<String, SpecMessage> set;
  final List<String> remove;
  final List<String> removeUpstream;

  static SpecMessage? _parseMessage(
    String key,
    Object? value,
    List<String> errors,
  ) {
    if (!_keyPattern.hasMatch(key)) {
      errors.add('$key: invalid message key');
      return null;
    }
    if (value is! Map<String, Object?>) {
      errors.add('$key: must map locales to strings');
      return null;
    }
    final values = <String, String>{};
    ArbMap? metadata;
    for (final MapEntry(key: locale, value: text) in value.entries) {
      if (locale == '@') {
        if (text is! Map<String, Object?>) {
          errors.add('$key: @ must be an object');
        } else if (text['placeholders'] case final placeholders?
            when placeholders is! Map ||
                placeholders.values.any((entry) => entry is! Map)) {
          errors.add('$key: @.placeholders must map names to objects');
        } else {
          metadata = text;
        }
      } else if (text is! String) {
        errors.add('$key: $locale value must be a string');
      } else if (text.trim().isEmpty) {
        errors.add('$key: $locale value is empty');
      } else {
        values[locale] = text;
      }
    }
    return SpecMessage(values, metadata);
  }

  static List<String> _keyList(
    Map<String, Object?> json,
    String field,
    List<String> errors,
  ) {
    final value = json[field] ?? const <Object?>[];
    if (value is! List || value.any((key) => key is! String)) {
      errors.add('spec: $field must be a list of keys');
      return const [];
    }
    return value.cast<String>().toSet().toList();
  }
}

class ApplyPlan {
  ApplyPlan(this.spec, this.texts, this.lines);

  final L10nSpec spec;

  /// New text per locale, only for fragment files whose content changes.
  final Map<String, String> texts;
  final List<String> lines;

  bool get isEmpty => texts.isEmpty;

  String get summary {
    final parts = [
      'set ${spec.set.length}',
      if (spec.remove.isNotEmpty) 'removed ${spec.remove.length}',
      if (spec.removeUpstream.isNotEmpty)
        'removed upstream ${spec.removeUpstream.length}',
    ];
    return '${spec.fragment}: ${parts.join(', ')}';
  }
}

ApplyPlan planApply(L10nWorkspace workspace, L10nSpec spec) {
  final errors = <String>[];
  final feature = spec.fragment;
  final current = workspace.fragments[feature] ?? const <String, ArbMap>{};
  final english = current['en'] ?? const <String, Object?>{};
  final englishMetadata = <String, ArbMap?>{};

  for (final MapEntry(:key, value: message) in spec.set.entries) {
    final missing = workspace.locales
        .where((locale) => !message.values.containsKey(locale))
        .toList();
    if (missing.isNotEmpty) {
      errors.add('$key: missing locales ${missing.join(', ')}');
    }
    final unknown = message.values.keys
        .where((locale) => !workspace.locales.contains(locale))
        .toList();
    if (unknown.isNotEmpty) {
      errors.add('$key: unknown locales ${unknown.join(', ')}');
    }
    _checkOwner(workspace, feature, key, errors);
    final metadata = message.metadata ?? english['@$key'] as ArbMap?;
    englishMetadata[key] = metadata;
    final englishText = message.values['en'];
    if (englishText == null) continue;
    final arguments = messageArguments(englishText);
    final declared = declaredPlaceholders(metadata);
    final undeclared = arguments.difference(declared);
    if (undeclared.isNotEmpty) {
      errors.add(
        '$key: en ${formatArguments(undeclared)} not declared in @.placeholders',
      );
    }
    final unused = declared.difference(arguments);
    if (unused.isNotEmpty) {
      errors.add(
        '$key: @.placeholders declares unused ${formatArguments(unused)}',
      );
    }
    for (final MapEntry(key: locale, value: text) in message.values.entries) {
      final localeArguments = messageArguments(text);
      if (locale != 'en' && !_sameSet(localeArguments, arguments)) {
        errors.add(
          '$key: $locale has ${formatArguments(localeArguments)}, en has ${formatArguments(arguments)}',
        );
      }
    }
  }

  final owned = workspace.fragmentKeys(feature);
  for (final key in spec.remove) {
    if (!owned.contains(key)) errors.add('$key: not in $feature');
  }
  for (final key in spec.removeUpstream) {
    if (workspace.bases['en']?.containsKey(key) != true) {
      errors.add('$key: not in the en base');
    }
    _checkOwner(workspace, feature, key, errors);
  }
  if (errors.isNotEmpty) throw L10nException(errors);

  final texts = <String, String>{};
  final changedLocales = <String, List<String>>{};
  for (final locale in workspace.locales) {
    final before = current[locale];
    final after = _rewrite(
      before ?? const <String, Object?>{},
      locale,
      spec,
      englishMetadata,
    );
    if (before != null && jsonEncode(before) == jsonEncode(after)) continue;
    texts[locale] = encodeArb(after);
    for (final key in [...spec.set.keys, ...spec.removeUpstream]) {
      if (jsonEncode([before?[key], before?['@$key']]) !=
          jsonEncode([after[key], after['@$key']])) {
        changedLocales.putIfAbsent(key, () => []).add(locale);
      }
    }
  }

  final lines = [
    for (final key in spec.set.keys)
      if (!english.containsKey(key))
        '+ $key'
      else if (changedLocales[key] case final locales?)
        '~ $key: ${locales.join(', ')}'
      else
        '= $key',
    for (final key in spec.removeUpstream)
      changedLocales.containsKey(key) ? '- $key (upstream)' : '= $key',
    for (final key in spec.remove) '- $key',
  ];
  return ApplyPlan(spec, texts, lines);
}

/// Validates [plan] by assembling a scratch copy of the ARB sources with the
/// planned fragment files in place, so a failing plan never touches [root].
void checkAssembly(Directory root, ApplyPlan plan) {
  final scratch = Directory.systemTemp.createTempSync('l10n-tool-');
  try {
    for (final directory in ['arb_upstream', p.join('arb', 'locales')]) {
      _copyArbs(Directory(p.join(root.path, directory)), scratch, root);
    }
    final fragments = Directory(p.join(root.path, 'arb', 'fragments'));
    if (fragments.existsSync()) {
      for (final directory in fragments.listSync().whereType<Directory>()) {
        _copyArbs(directory, scratch, root);
      }
    }
    _writeTexts(scratch, plan);
    LocalizationAssembler(scratch).assemble();
  } on FormatException catch (error) {
    throw L10nException([
      'assembly: ${error.message.replaceAll('${scratch.path}/', '')}',
    ]);
  } finally {
    scratch.deleteSync(recursive: true);
  }
}

void writePlan(Directory root, ApplyPlan plan) {
  _writeTexts(root, plan);
  LocalizationAssembler(root).write();
}

void _writeTexts(Directory root, ApplyPlan plan) {
  for (final MapEntry(key: locale, value: text) in plan.texts.entries) {
    File(
        p.join(
          root.path,
          'arb',
          'fragments',
          plan.spec.fragment,
          'intl_$locale.arb',
        ),
      )
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(text);
  }
}

void _copyArbs(Directory source, Directory target, Directory root) {
  if (!source.existsSync()) return;
  for (final file in source.listSync().whereType<File>()) {
    if (!file.path.endsWith('.arb')) continue;
    final copy = File(
      p.join(target.path, p.relative(file.path, from: root.path)),
    );
    copy.parent.createSync(recursive: true);
    file.copySync(copy.path);
  }
}

void _checkOwner(
  L10nWorkspace workspace,
  String feature,
  String key,
  List<String> errors,
) {
  final owner = workspace.claimingFragment(key, except: feature);
  if (owner != null) errors.add('$key: owned by $owner');
}

ArbMap _rewrite(
  ArbMap before,
  String locale,
  L10nSpec spec,
  Map<String, ArbMap?> englishMetadata,
) {
  final values = <String, Object?>{
    for (final MapEntry(:key, value: message) in spec.set.entries)
      key: message.values[locale],
    for (final key in spec.removeUpstream) key: null,
  };
  final removed = spec.remove.toSet();
  ArbMap? metadataFor(String key) {
    final metadata = englishMetadata[key];
    if (locale == 'en') return metadata;
    // Older fragments mirror en metadata into every locale; intl_utils reads
    // only the en copy, so a mirror is kept identical rather than dropped.
    return before.containsKey('@$key') ? metadata : null;
  }

  final after = <String, Object?>{};
  void put(String key, Object? value) {
    after[key] = value;
    if (metadataFor(key) case final metadata?) after['@$key'] = metadata;
  }

  for (final MapEntry(:key, :value) in before.entries) {
    if (key.startsWith('@') && !key.startsWith('@@')) {
      final message = key.substring(1);
      if (removed.contains(message) || values.containsKey(message)) continue;
      after[key] = value;
    } else if (removed.contains(key)) {
      continue;
    } else if (values.containsKey(key)) {
      put(key, values[key]);
    } else {
      after[key] = value;
    }
  }
  for (final MapEntry(:key, :value) in values.entries) {
    if (!before.containsKey(key)) put(key, value);
  }
  return after;
}

bool _sameSet(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);
