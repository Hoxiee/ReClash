import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'prepare.dart';
import 'preview/preview_cli.dart';

Future<void> main(List<String> args) async {
  final parser = PreviewOptions.parser();
  final PreviewOptions options;
  try {
    final results = parser.parse(args);
    if (results.flag('help')) {
      stdout
        ..write(previewUsage)
        ..writeln()
        ..writeln(parser.usage);
      return;
    }
    options = PreviewOptions.parse(results);
  } on FormatException catch (error) {
    _fail('${error.message}\n\n$previewUsage\n${parser.usage}');
  }

  final root = p.dirname(p.dirname(p.fromUri(Platform.script)));
  final scenario = File(p.absolute(options.scenario));
  if (!scenario.existsSync()) _fail('No scenario at ${scenario.path}.');
  final ScenarioHooks hooks;
  try {
    hooks = scenarioHooks(scenario.readAsStringSync());
  } on FormatException catch (error) {
    _fail(error.message);
  }

  final prepared = await prepareProject(root, pubGet: false, quiet: true);
  if (prepared != 0) exit(prepared);

  final work = Directory(p.join(root, '.dart_tool', 'preview'));
  final outDir = Directory(
    p.absolute(options.outDir ?? p.join(work.path, 'out')),
  )..createSync(recursive: true);
  final name = p.basenameWithoutExtension(scenario.path);
  final cells = options.cells(name);
  final cjk = _cjkFonts(
    work,
    cells.map((cell) => CjkVariant.of(cell.locale)).toSet(),
  );
  final outputs = [
    for (final cell in cells) p.join(outDir.path, cell.fileName),
  ];
  for (final path in outputs) {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }

  final configPath = p.join(work.path, '${name}_preview.json');
  File(configPath).writeAsStringSync(
    jsonEncode({
      'pixelRatio': options.pixelRatio,
      'textScale': options.textScale,
      'fonts': {
        'Roboto': _robotoFonts(root),
        for (final MapEntry(key: variant, value: path) in cjk.entries)
          variant.previewFamily: [path],
      },
      'cells': [
        for (final (index, cell) in cells.indexed)
          {
            'width': cell.size.width,
            'height': cell.size.height,
            'theme': cell.theme,
            'locale': cell.locale,
            'fallback': [
              'Twemoji',
              if (cjk.containsKey(CjkVariant.of(cell.locale)))
                CjkVariant.of(cell.locale).previewFamily,
            ],
            'path': outputs[index],
          },
      ],
    }),
  );
  final harness = File(p.join(work.path, '${name}_preview_test.dart'))
    ..writeAsStringSync(
      harnessSource(
        harnessLibrary: p.toUri(
          p.join(root, 'tool', 'preview', 'harness.dart'),
        ),
        scenario: scenario.uri,
        configPath: configPath,
        hooks: hooks,
      ),
    );

  final result = await Process.run(
    'flutter',
    ['test', '-r', 'failures-only', '--no-pub', harness.path],
    workingDirectory: root,
    runInShell: Platform.isWindows,
  );
  final written = outputs.where((path) => File(path).existsSync()).toList();
  written.forEach(stdout.writeln);
  if (result.exitCode != 0 || written.length != outputs.length) {
    stderr.writeln(
      compactFailure('${result.stdout}\n${result.stderr}').join('\n'),
    );
    exitCode = 1;
  }
}

List<String> _robotoFonts(String root) {
  final fonts = Directory(
    p.join(_flutterRoot(root), 'bin', 'cache', 'artifacts', 'material_fonts'),
  );
  if (!fonts.existsSync()) {
    stderr.writeln('No Roboto in ${fonts.path}; text falls back to boxes.');
    return const [];
  }
  return [
    for (final file in fonts.listSync().whereType<File>())
      if (RegExp(r'^Roboto-\w+\.ttf$').hasMatch(p.basename(file.path)))
        file.path,
  ]..sort();
}

String _flutterRoot(String root) {
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && env.isNotEmpty) return env;
  final config = File(p.join(root, '.dart_tool', 'package_config.json'));
  final packages =
      (jsonDecode(config.readAsStringSync()) as Map)['packages'] as List;
  final flutter = packages.cast<Map>().firstWhere(
    (package) => package['name'] == 'flutter',
  );
  final uri = Uri.parse(flutter['rootUri'] as String);
  final path = uri.isAbsolute
      ? p.fromUri(uri)
      : p.normalize(p.join(root, '.dart_tool', p.fromUri(uri)));
  return p.dirname(p.dirname(path));
}

/// System CJK faces as standalone font files, keyed by Han variant.
Map<CjkVariant, String> _cjkFonts(Directory work, Set<CjkVariant> variants) {
  final fonts = <CjkVariant, String>{};
  for (final variant in variants) {
    final match = _fcMatch(variant.families);
    if (match == null) continue;
    final (path, index) = match;
    final out = File(
      p.join(
        work.path,
        'fonts',
        '${p.basenameWithoutExtension(path)}_$index.otf',
      ),
    );
    final source = File(path);
    if (!out.existsSync() ||
        out.lastModifiedSync().isBefore(source.lastModifiedSync())) {
      out
        ..createSync(recursive: true)
        ..writeAsBytesSync(
          extractCollectionFace(source.readAsBytesSync(), index),
        );
    }
    fonts[variant] = out.path;
  }
  return fonts;
}

(String, int)? _fcMatch(List<String> families) {
  for (final family in families) {
    final ProcessResult result;
    try {
      result = Process.runSync('fc-match', [
        '-f',
        '%{file}\t%{index}\t%{family}',
        family,
      ]);
    } on ProcessException {
      return null;
    }
    final fields = '${result.stdout}'.split('\t');
    if (result.exitCode == 0 &&
        fields.length == 3 &&
        fields[2].split(',').contains(family)) {
      return (fields[0], int.parse(fields[1]));
    }
  }
  return null;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
