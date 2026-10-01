import 'dart:io';

import 'package:args/args.dart';

import 'tools_search_index.dart';

const _generatedPath = 'lib/views/tools/tools_search_index.g.dart';

/// Reads each owner's source, keeps the rows the author marked with `search:`
/// (plus the DNS/NTP enum-label maps), drops duplicate titles within an owner,
/// and returns them in source order paired with their owner. Any author mistake
/// a scan reports (a bad gate token, a titleless searchable row) is fatal.
List<(OwnerSpec, SettingHit)> collectSettings(String root) {
  final collected = <(OwnerSpec, SettingHit)>[];
  for (final owner in ownerSpecs) {
    final seen = <SettingTitle>{};
    for (final relative in owner.files) {
      final file = File('$root/$relative');
      if (!file.existsSync()) {
        stderr.writeln('Missing owner source: $relative');
        exitCode = 1;
        continue;
      }
      final extraction = extractSettingHits(file.readAsStringSync());
      for (final error in extraction.errors) {
        stderr.writeln('$relative: $error');
        exitCode = 1;
      }
      for (final hit in extraction.hits) {
        if (seen.add(hit.title)) {
          collected.add((owner, hit));
        }
      }
    }
  }
  return collected;
}

/// Prints every searchable row the parser sees with its owner and gate, so the
/// baked index can be checked against reality.
void dumpAll(String root) {
  for (final owner in ownerSpecs) {
    for (final relative in owner.files) {
      final file = File('$root/$relative');
      if (!file.existsSync()) {
        continue;
      }
      for (final hit in extractSettingHits(file.readAsStringSync()).hits) {
        final label = hit.title.getter ?? "'${hit.title.literal}'";
        stdout.writeln(
          '${owner.paneId.padRight(13)} ${hit.gate.padRight(14)} $label',
        );
      }
    }
  }
}

String render(List<(OwnerSpec, SettingHit)> settings) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Regenerate with: dart run tool/gen_tools_search_index.dart')
    ..writeln('//')
    ..writeln(
      '// Source of truth is the settings screens themselves; this file',
    )
    ..writeln('// mirrors every row an author marked searchable so search can')
    ..writeln('// never silently miss one. See tool/tools_search_index.dart.')
    ..writeln()
    ..writeln("import 'package:reclash/l10n/l10n.dart';")
    ..writeln()
    ..writeln(
      '/// One searchable setting harvested from a tool screen: the row',
    )
    ..writeln(
      '/// title, the pane it lives in, its category, the availability gate',
    )
    ..writeln('/// token, and any extra search keywords.')
    ..writeln('class DeepSettingSpec {')
    ..writeln('  const DeepSettingSpec({')
    ..writeln('    required this.title,')
    ..writeln('    required this.paneId,')
    ..writeln('    required this.category,')
    ..writeln('    required this.gate,')
    ..writeln('    this.keywords = const [],')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final String title;')
    ..writeln('  final String paneId;')
    ..writeln('  final String category;')
    ..writeln('  final String gate;')
    ..writeln('  final List<String> keywords;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Every searchable setting row across the tool screens,')
    ..writeln('/// resolved against the active locale, in source order per')
    ..writeln('/// owner.')
    ..writeln('List<DeepSettingSpec> deepSettingSpecs(AppLocalizations l) {')
    ..writeln('  return [');
  for (final (owner, hit) in settings) {
    final gate = developerOwners.contains(owner.paneId) && hit.gate == 'always'
        ? 'developerMode'
        : hit.gate;
    final prefix = hit.title.isGetter ? '' : 'const ';
    buffer
      ..writeln('    ${prefix}DeepSettingSpec(')
      ..writeln('      title: ${hit.title.expression},')
      ..writeln("      paneId: '${owner.paneId}',")
      ..writeln("      category: '${owner.category}',")
      ..writeln("      gate: '$gate',");
    if (hit.keywords.isNotEmpty) {
      final literals = hit.keywords.map((k) => "'$k'").join(', ');
      buffer.writeln('      keywords: const [$literals],');
    }
    buffer.writeln('    ),');
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
    ..addFlag('dump', negatable: false, help: 'Print every searchable row.')
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
