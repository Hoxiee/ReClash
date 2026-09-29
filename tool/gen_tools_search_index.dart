import 'dart:io';

import 'package:args/args.dart';

import 'tools_search_index.dart';

const _generatedPath = 'lib/views/tools/tools_search_index.g.dart';

/// Reads each owner's source, keeps the title hits whose widget type is a known
/// searchable row, drops duplicates within an owner, and returns them in source
/// order paired with their owner.
List<(OwnerSpec, SettingTitle)> collectSettings(String root) {
  final collected = <(OwnerSpec, SettingTitle)>[];
  for (final owner in ownerSpecs) {
    final seen = <SettingTitle>{};
    for (final relative in owner.files) {
      final file = File('$root/$relative');
      if (!file.existsSync()) {
        stderr.writeln('Missing owner source: $relative');
        exitCode = 1;
        continue;
      }
      for (final hit in extractTitleHits(file.readAsStringSync())) {
        if (!rowTypes.contains(hit.enclosingType)) {
          continue;
        }
        if (seen.add(hit.title)) {
          collected.add((owner, hit.title));
        }
      }
    }
  }
  return collected;
}

/// Prints every `title:` the parser sees with its widget type, so the row-type
/// allowlist can be checked against reality.
void dumpAll(String root) {
  for (final owner in ownerSpecs) {
    for (final relative in owner.files) {
      final file = File('$root/$relative');
      if (!file.existsSync()) {
        continue;
      }
      for (final hit in extractTitleHits(file.readAsStringSync())) {
        final label = hit.title.getter ?? "'${hit.title.literal}'";
        final gate = rowTypes.contains(hit.enclosingType) ? '  ' : ' x';
        stdout.writeln(
          '$gate ${owner.paneId.padRight(13)} '
          '${hit.enclosingType.padRight(26)} $label',
        );
      }
    }
  }
}

String render(List<(OwnerSpec, SettingTitle)> settings) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Regenerate with: dart run tool/gen_tools_search_index.dart')
    ..writeln('//')
    ..writeln(
      '// Source of truth is the settings screens themselves; this file',
    )
    ..writeln('// mirrors every static row title so search can never silently')
    ..writeln(
      '// miss one. See tool/tools_search_index.dart for the extractor.',
    )
    ..writeln()
    ..writeln("import 'package:reclash/l10n/l10n.dart';")
    ..writeln()
    ..writeln(
      '/// One searchable setting harvested from a tool screen: the row',
    )
    ..writeln(
      '/// title, the pane it lives in, its category, and whether it is',
    )
    ..writeln('/// gated behind developer mode.')
    ..writeln('class DeepSettingSpec {')
    ..writeln('  const DeepSettingSpec({')
    ..writeln('    required this.title,')
    ..writeln('    required this.paneId,')
    ..writeln('    required this.category,')
    ..writeln('    required this.developerOnly,')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final String title;')
    ..writeln('  final String paneId;')
    ..writeln('  final String category;')
    ..writeln('  final bool developerOnly;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Every static setting row across the tool screens, resolved')
    ..writeln('/// against the active locale, in source order per owner.')
    ..writeln('List<DeepSettingSpec> deepSettingSpecs(AppLocalizations l) {')
    ..writeln('  return [');
  for (final (owner, title) in settings) {
    final developer = developerOwners.contains(owner.paneId);
    final prefix = title.isGetter ? '' : 'const ';
    buffer
      ..writeln('    ${prefix}DeepSettingSpec(')
      ..writeln('      title: ${title.expression},')
      ..writeln("      paneId: '${owner.paneId}',")
      ..writeln("      category: '${owner.category}',")
      ..writeln('      developerOnly: $developer,')
      ..writeln('    ),');
  }
  buffer
    ..writeln('  ];')
    ..writeln('}');
  return buffer.toString();
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('write', negatable: false, help: 'Rewrite the generated index.')
    ..addFlag('check', negatable: false, help: 'Fail if the index is stale.')
    ..addFlag('dump', negatable: false, help: 'Print every title hit seen.')
    ..addOption('root', help: 'Repository root, defaults to the cwd.')
    ..addFlag('help', abbr: 'h', negatable: false);
  final args = parser.parse(arguments);
  if (args.flag('help')) {
    stdout.writeln(
      'Usage: dart run tool/gen_tools_search_index.dart [--write]',
    );
    stdout.writeln(parser.usage);
    return;
  }

  final root = args.option('root') ?? Directory.current.path;
  if (args.flag('dump')) {
    dumpAll(root);
    return;
  }

  final rendered = render(collectSettings(root));
  final file = File('$root/$_generatedPath');

  if (args.flag('check')) {
    final current = file.existsSync() ? file.readAsStringSync() : '';
    if (current != rendered) {
      stderr.writeln(
        '$_generatedPath is stale; run the generator with --write.',
      );
      exitCode = 1;
    }
    return;
  }

  file.writeAsStringSync(rendered);
  stdout.writeln('Wrote $_generatedPath.');
}
