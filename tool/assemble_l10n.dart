import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class LocalizationAssembler {
  LocalizationAssembler(this.root);

  final Directory root;

  Directory get arbDirectory => Directory(p.join(root.path, 'arb'));
  Directory get upstreamDirectory =>
      Directory(p.join(root.path, 'arb_upstream'));
  Directory get localeBasesDirectory =>
      Directory(p.join(arbDirectory.path, 'locales'));
  Directory get fragmentsDirectory =>
      Directory(p.join(arbDirectory.path, 'fragments'));

  Map<String, String> assemble() {
    final upstream = _arbFiles(upstreamDirectory, recursive: false);
    final localeBases = _arbFiles(localeBasesDirectory, recursive: false);
    final fragments = _arbFiles(fragmentsDirectory, recursive: true);
    final bases = <String, File>{};
    for (final file in [...upstream, ...localeBases]) {
      final locale = _locale(file);
      if (bases.containsKey(locale)) {
        throw FormatException('Duplicate base ARB for $locale');
      }
      bases[locale] = file;
    }
    final localeFiles = <String>{
      ...bases.keys,
      ...fragments.map((file) => _locale(file)),
    }.toList()..sort();
    if (!localeFiles.contains('en')) {
      throw const FormatException('English ARB source is missing');
    }

    final assembled = <String, Map<String, Object?>>{};
    for (final locale in localeFiles) {
      final source = bases[locale];
      final messages = source == null ? <String, Object?>{} : _read(source);
      final owners = <String, String>{};
      final removals = <String, String>{};
      final metadata = <String, String>{};
      final fragmentsForLocale =
          fragments.where((file) => _locale(file) == locale).toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in fragmentsForLocale) {
        final feature = _feature(file);
        final fragment = _read(file);
        final localMetadata = <String, Object?>{};
        for (final entry in fragment.entries) {
          if (entry.key.startsWith('@@')) {
            if (entry.key != '@@locale') {
              throw FormatException(
                '${file.path} uses unsupported global ARB metadata ${entry.key}',
              );
            }
            if (entry.value != locale) {
              throw FormatException(
                '${file.path} declares @@locale ${entry.value}, expected $locale',
              );
            }
          } else if (entry.key.startsWith('@')) {
            localMetadata[entry.key] = entry.value;
          } else if (entry.value == null) {
            final previous = removals[entry.key];
            if (previous != null) {
              throw FormatException(
                'Duplicate removal of ${entry.key} in $previous and $feature',
              );
            }
            removals[entry.key] = feature;
          } else {
            if (entry.value is! String) {
              throw FormatException(
                '${file.path} message ${entry.key} must be a string or null removal marker',
              );
            }
            final previous = owners[entry.key];
            if (previous != null) {
              throw FormatException(
                'Duplicate fragment key ${entry.key} in $previous and $feature',
              );
            }
            owners[entry.key] = feature;
            messages[entry.key] = entry.value;
          }
        }
        for (final field in localMetadata.keys) {
          final key = field.substring(1);
          if (!fragment.containsKey(key) || fragment[key] == null) {
            throw FormatException(
              '${file.path} has orphan ARB metadata $field',
            );
          }
          final previous = metadata[field];
          if (previous != null) {
            throw FormatException(
              'Duplicate metadata $field in $previous and $feature',
            );
          }
          metadata[field] = feature;
          if (localMetadata[field] == null ||
              localMetadata[field] is! Map<String, Object?>) {
            throw FormatException(
              '${file.path} metadata $field must be an object',
            );
          }
          if (owners[key] != null && owners[key] != feature) {
            throw FormatException(
              '$feature cannot change metadata for $key owned by ${owners[key]}',
            );
          }
          messages[field] = localMetadata[field];
        }
      }

      for (final entry in removals.entries) {
        if (!messages.containsKey(entry.key)) {
          throw FormatException(
            '${entry.value} removes unknown key ${entry.key} for $locale',
          );
        }
        messages.remove(entry.key);
        messages.remove('@${entry.key}');
      }
      assembled[locale] = messages;
    }

    final englishKeys = _messageKeys(assembled['en']!);
    for (final entry in assembled.entries) {
      final localeKeys = _messageKeys(entry.value);
      if (!_setEquals(englishKeys, localeKeys)) {
        final missing = englishKeys.difference(localeKeys).toList()..sort();
        final extra = localeKeys.difference(englishKeys).toList()..sort();
        throw FormatException(
          '${entry.key} key mismatch; missing=${missing.join(',')} extra=${extra.join(',')}',
        );
      }
    }

    return {
      for (final locale in localeFiles)
        'intl_$locale.arb':
            '${const JsonEncoder.withIndent('  ').convert(assembled[locale])}\n',
    };
  }

  void write() {
    final output = assemble();
    arbDirectory.createSync(recursive: true);
    for (final file in _flatArbFiles()) {
      if (!output.containsKey(p.basename(file.path))) file.deleteSync();
    }
    for (final entry in output.entries) {
      File(p.join(arbDirectory.path, entry.key)).writeAsStringSync(entry.value);
    }
  }

  void check() {
    final output = assemble();
    final existing = {
      for (final file in _flatArbFiles()) p.basename(file.path),
    };
    final stale = existing.difference(output.keys.toSet());
    if (stale.isNotEmpty) {
      throw FormatException('Stale assembled ARBs: ${stale.join(', ')}');
    }
    for (final entry in output.entries) {
      final file = File(p.join(arbDirectory.path, entry.key));
      if (!file.existsSync() || file.readAsStringSync() != entry.value) {
        throw FormatException(
          '${entry.key} is stale; run dart run tool/assemble_l10n.dart',
        );
      }
    }
  }

  List<File> _arbFiles(Directory directory, {required bool recursive}) {
    if (!directory.existsSync()) return [];
    return directory
        .listSync(recursive: recursive, followLinks: false)
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList();
  }

  List<File> _flatArbFiles() => _arbFiles(
    arbDirectory,
    recursive: false,
  ).where((file) => p.basename(file.path).startsWith('intl_')).toList();

  String _feature(File file) {
    final relative = p.relative(file.path, from: fragmentsDirectory.path);
    final parts = p.split(relative);
    if (parts.length != 2) {
      throw FormatException(
        'ARB fragments must be arb/fragments/<feature>/intl_<locale>.arb: ${file.path}',
      );
    }
    final feature = parts.first;
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]*$').hasMatch(feature)) {
      throw FormatException('Invalid feature fragment directory: $feature');
    }
    return feature;
  }

  String _locale(File file) {
    final name = p.basenameWithoutExtension(file.path);
    if (!name.startsWith('intl_')) {
      throw FormatException(
        'ARB file must use intl_<locale>.arb: ${file.path}',
      );
    }
    final locale = name.substring('intl_'.length);
    if (!RegExp(r'^[a-z]{2,3}(?:_[A-Za-z0-9]{2,8})*$').hasMatch(locale)) {
      throw FormatException('Invalid locale in ${file.path}');
    }
    return locale;
  }

  Map<String, Object?> _read(File file) {
    final value = loadYaml(file.readAsStringSync(), sourceUrl: file.uri);
    if (value is! YamlMap) {
      throw FormatException('${file.path} must contain an ARB object');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException('${file.path} contains a non-string ARB key');
      }
      result[key] = _plain(entry.value);
    }
    return result;
  }

  Object? _plain(Object? value) {
    if (value is YamlMap) {
      final result = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String) {
          throw const FormatException('ARB metadata keys must be strings');
        }
        result[key] = _plain(entry.value);
      }
      return result;
    }
    if (value is YamlList) return value.map(_plain).toList();
    return value;
  }

  Set<String> _messageKeys(Map<String, Object?> values) => {
    for (final entry in values.entries)
      if (!entry.key.startsWith('@')) entry.key,
  };

  bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

void main(List<String> args) {
  try {
    final assembler = LocalizationAssembler(Directory.current);
    if (args.isEmpty || (args.length == 1 && args.single == '--write')) {
      assembler.write();
      stdout.writeln(
        'Assembled localization ARBs from upstream sources and feature fragments.',
      );
      return;
    }
    if (args.length == 1 && args.single == '--check') {
      assembler.check();
      stdout.writeln('Assembled localization ARBs are current.');
      return;
    }
    stderr.writeln('Usage: dart run tool/assemble_l10n.dart [--write|--check]');
    exitCode = 64;
  } on Object catch (error) {
    stderr.writeln('Localization assembly failed: $error');
    exitCode = 1;
  }
}
