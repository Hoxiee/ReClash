import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../assemble_l10n.dart';

typedef ArbMap = Map<String, Object?>;

class L10nException implements Exception {
  L10nException(this.messages);

  final List<String> messages;

  @override
  String toString() => messages.join('\n');
}

final featurePattern = RegExp(r'^[a-z0-9][a-z0-9._-]*$');

String encodeArb(ArbMap values) =>
    '${const JsonEncoder.withIndent('  ').convert(values)}\n';

bool isMessageKey(String key) => !key.startsWith('@');

String oneLine(Object? value) => value is String
    ? value.replaceAll('\n', r'\n').replaceAll('\t', r'\t')
    : jsonEncode(value);

class L10nWorkspace {
  L10nWorkspace._(
    this.root,
    this.bases,
    this.baseSources,
    this.fragments,
    this.locales,
  );

  factory L10nWorkspace.load(Directory root) {
    final assembler = LocalizationAssembler(root);
    final bases = <String, ArbMap>{};
    final baseSources = <String, String>{};
    for (final (directory, label) in [
      (assembler.upstreamDirectory, 'arb_upstream'),
      (assembler.localeBasesDirectory, 'arb/locales'),
    ]) {
      for (final MapEntry(key: locale, value: file) in _localeFiles(
        directory,
      ).entries) {
        bases[locale] = _read(file);
        baseSources[locale] = label;
      }
    }
    final fragments = <String, Map<String, ArbMap>>{};
    final fragmentsDirectory = assembler.fragmentsDirectory;
    if (fragmentsDirectory.existsSync()) {
      final directories =
          fragmentsDirectory.listSync().whereType<Directory>().toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      for (final directory in directories) {
        fragments[p.basename(directory.path)] = {
          for (final MapEntry(key: locale, value: file) in _localeFiles(
            directory,
          ).entries)
            locale: _read(file),
        };
      }
    }
    final locales = <String>{
      ...bases.keys,
      for (final files in fragments.values) ...files.keys,
    }.toList()..sort();
    return L10nWorkspace._(root, bases, baseSources, fragments, locales);
  }

  final Directory root;
  final Map<String, ArbMap> bases;
  final Map<String, String> baseSources;
  final Map<String, Map<String, ArbMap>> fragments;
  final List<String> locales;

  Set<String> fragmentKeys(String feature) => {
    for (final values in (fragments[feature] ?? const {}).values)
      ...values.keys.where(isMessageKey),
  };

  String? claimingFragment(String key, {required String except}) {
    for (final MapEntry(key: feature, value: files) in fragments.entries) {
      if (feature == except) continue;
      if (files.values.any((values) => values.containsKey(key))) {
        return feature;
      }
    }
    return null;
  }

  String ownerOf(String key, String locale) {
    for (final MapEntry(key: feature, value: files) in fragments.entries) {
      if (files[locale]?[key] != null) return feature;
    }
    return baseSources[locale] ?? 'unknown';
  }

  Map<String, ArbMap> assembled() => {
    for (final MapEntry(key: name, value: source) in LocalizationAssembler(
      root,
    ).assemble().entries)
      p.basenameWithoutExtension(name).substring('intl_'.length):
          jsonDecode(source) as ArbMap,
  };

  static Map<String, File> _localeFiles(Directory directory) {
    if (!directory.existsSync()) return {};
    return {
      for (final file in directory.listSync().whereType<File>())
        if (p.basename(file.path) case final name
            when name.startsWith('intl_') && name.endsWith('.arb'))
          p.basenameWithoutExtension(name).substring('intl_'.length): file,
    };
  }

  static ArbMap _read(File file) {
    final value = jsonDecode(file.readAsStringSync());
    if (value is! Map<String, Object?>) {
      throw FormatException('${file.path} must contain an ARB object');
    }
    return value;
  }
}
