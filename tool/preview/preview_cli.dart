import 'dart:convert';
import 'dart:typed_data';

import 'package:args/args.dart';

const previewUsage = '''
Renders a widget scenario to PNG files inside flutter_test, without launching
the app. Prints the written PNG paths, one per line.

Usage: dart run tool/preview.dart <scenario.dart> [options]

A scenario is a Dart file defining top-level functions:
  Widget preview()                                  required, the widget to show
  List<Override> previewOverrides()                 optional Riverpod overrides
  Future<void> previewSetUp()                       optional, runs before each image
  Future<void> previewAct(WidgetTester tester)      optional taps and scrolls

It imports package:reclash/..., package:flutter_test/flutter_test.dart,
package:flutter_riverpod/misc.dart for Override and, by relative path or file
URI, helpers under test/helpers/. Each image gets a fresh ProviderContainer as
globalState.container with viewSizeProvider, theme mode and locale set, and
mounts the widget in TestApp with the app theme (watchAppTheme), Roboto,
MaterialIcons, pubspec fonts and a system CJK fallback, over mocked preferences
and a temporary appPath. Example: tool/preview/examples/about_preview.dart.
''';

class PreviewOptions {
  const PreviewOptions({
    required this.scenario,
    required this.outDir,
    required this.sizes,
    required this.themes,
    required this.locales,
    required this.pixelRatio,
    required this.textScale,
  });

  final String scenario;
  final String? outDir;
  final List<PreviewSize> sizes;
  final List<String> themes;
  final List<String> locales;
  final double pixelRatio;
  final double textScale;

  static ArgParser parser() => ArgParser()
    ..addOption('out', help: 'Output directory [.dart_tool/preview/out].')
    ..addOption(
      'size',
      defaultsTo: '412x915',
      help: 'Comma-separated logical sizes in dp.',
    )
    ..addOption(
      'theme',
      defaultsTo: 'light',
      help: 'Comma-separated: light,dark.',
    )
    ..addOption(
      'locale',
      defaultsTo: 'en',
      help: 'Comma-separated locales, e.g. en,ru,zh_CN.',
    )
    ..addOption(
      'scale',
      defaultsTo: '1.0',
      help: 'Device pixel ratio of the images.',
    )
    ..addOption('text-scale', defaultsTo: '1.0', help: 'System text scale.')
    ..addFlag('help', abbr: 'h', negatable: false);

  /// Throws [FormatException] on a malformed argument.
  static PreviewOptions parse(ArgResults results) {
    if (results.rest.length != 1) {
      throw const FormatException('Expected exactly one scenario file.');
    }
    final themes = _list(results.option('theme')!);
    for (final theme in themes) {
      if (theme != 'light' && theme != 'dark') {
        throw FormatException('Unknown theme "$theme".');
      }
    }
    return PreviewOptions(
      scenario: results.rest.single,
      outDir: results.option('out'),
      sizes: _list(results.option('size')!).map(PreviewSize.parse).toList(),
      themes: themes,
      locales: _list(results.option('locale')!),
      pixelRatio: _positive(results.option('scale')!, 'scale'),
      textScale: _positive(results.option('text-scale')!, 'text-scale'),
    );
  }

  List<PreviewCell> cells(String name) => [
    for (final size in sizes)
      for (final theme in themes)
        for (final locale in locales)
          PreviewCell(name: name, size: size, theme: theme, locale: locale),
  ];

  static List<String> _list(String value) => [
    for (final item in value.split(','))
      if (item.trim().isNotEmpty) item.trim(),
  ];

  static double _positive(String value, String name) {
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      throw FormatException('--$name must be a positive number.');
    }
    return parsed;
  }
}

class PreviewSize {
  const PreviewSize(this.width, this.height);

  factory PreviewSize.parse(String value) {
    final match = RegExp(r'^(\d+)x(\d+)$').firstMatch(value);
    if (match == null) {
      throw FormatException('Size "$value" is not WIDTHxHEIGHT.');
    }
    return PreviewSize(int.parse(match[1]!), int.parse(match[2]!));
  }

  final int width;
  final int height;

  @override
  String toString() => '${width}x$height';
}

class PreviewCell {
  const PreviewCell({
    required this.name,
    required this.size,
    required this.theme,
    required this.locale,
  });

  final String name;
  final PreviewSize size;
  final String theme;
  final String locale;

  String get fileName => '${name}_${size}_${theme}_$locale.png';
}

enum CjkVariant {
  simplified([
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'Source Han Sans SC',
    'WenQuanYi Micro Hei',
  ]),
  traditional(['Noto Sans CJK TC', 'Noto Sans TC', 'Source Han Sans TC']),
  japanese(['Noto Sans CJK JP', 'Noto Sans JP', 'Source Han Sans']),
  korean(['Noto Sans CJK KR', 'Noto Sans KR', 'Source Han Sans K']);

  const CjkVariant(this.families);

  final List<String> families;

  String get previewFamily => 'PreviewCJK_$name';

  static CjkVariant of(String locale) {
    final parts = locale.split(RegExp('[-_]'));
    return switch (parts.first) {
      'ja' => japanese,
      'ko' => korean,
      'zh' when parts.skip(1).any(const {'TW', 'HK', 'MO', 'Hant'}.contains) =>
        traditional,
      _ => simplified,
    };
  }
}

typedef ScenarioHooks = ({bool overrides, bool setUp, bool act});

/// Throws [FormatException] when [source] defines no `preview()`.
ScenarioHooks scenarioHooks(String source) {
  bool defines(String name) => RegExp(
    '^[A-Za-z_][\\w<>?, ]*\\s+$name\\s*\\(',
    multiLine: true,
  ).hasMatch(source);
  if (!defines('preview')) {
    throw const FormatException('The scenario must define Widget preview().');
  }
  return (
    overrides: defines('previewOverrides'),
    setUp: defines('previewSetUp'),
    act: defines('previewAct'),
  );
}

String harnessSource({
  required Uri harnessLibrary,
  required Uri scenario,
  required String configPath,
  required ScenarioHooks hooks,
}) {
  final buffer = StringBuffer()
    ..writeln('// Generated by tool/preview.dart; rewritten on every run.')
    ..writeln("import '$harnessLibrary';")
    ..writeln("import '$scenario' as scenario;")
    ..writeln()
    ..writeln('void main() => runPreviews(')
    ..writeln('  ${jsonEncode(configPath)},')
    ..writeln('  preview: scenario.preview,');
  if (hooks.overrides) {
    buffer.writeln('  overrides: scenario.previewOverrides,');
  }
  if (hooks.setUp) buffer.writeln('  prepare: scenario.previewSetUp,');
  if (hooks.act) buffer.writeln('  act: scenario.previewAct,');
  buffer.writeln(');');
  return buffer.toString();
}

/// The few lines of a `flutter test` log that say why it failed.
List<String> compactFailure(String log) {
  final lines = const LineSplitter().convert(log);
  final compile = RegExp(r'\S+\.dart:\d+:\d+: Error: ');
  for (var i = 0; i < lines.length; i++) {
    final match = compile.firstMatch(lines[i]);
    if (match != null) {
      return [
        lines[i].substring(match.start),
        if (i + 1 < lines.length && !compile.hasMatch(lines[i + 1]))
          lines[i + 1],
      ];
    }
  }
  final thrown = lines.indexWhere(
    (line) => line.startsWith('The following ') && line.contains(' was thrown'),
  );
  if (thrown >= 0) {
    final frame = RegExp(r'\(((?:file://|package:reclash/)[^)]+:\d+:\d+)\)');
    final message = lines
        .skip(thrown + 1)
        .takeWhile((line) => line.trim().isNotEmpty && !line.startsWith('#'))
        .take(3);
    final location = lines
        .skip(thrown)
        .map(frame.firstMatch)
        .whereType<RegExpMatch>()
        .firstOrNull;
    return [
      lines[thrown],
      ...message,
      if (location != null) 'at ${location[1]!.replaceFirst('file://', '')}',
    ];
  }
  final tail = lines.where((line) => line.trim().isNotEmpty).toList();
  return tail.sublist(tail.length > 12 ? tail.length - 12 : 0);
}

/// Copies face [index] of a TrueType/OpenType collection into a standalone
/// font, because the engine only loads the first face of a collection.
Uint8List extractCollectionFace(Uint8List collection, int index) {
  final data = ByteData.sublistView(collection);
  if (data.getUint32(0) != 0x74746366) return collection;
  final faces = data.getUint32(8);
  if (index >= faces) {
    throw RangeError.index(index, faces, 'index', 'Collection face');
  }
  final face = data.getUint32(12 + index * 4);
  final tableCount = data.getUint16(face + 4);
  final headerLength = 12 + tableCount * 16;
  var length = headerLength;
  for (var i = 0; i < tableCount; i++) {
    length += _padded(data.getUint32(face + 12 + i * 16 + 12));
  }
  final out = Uint8List(length);
  final view = ByteData.sublistView(out);
  out.setRange(0, 12, collection, face);
  var cursor = headerLength;
  for (var i = 0; i < tableCount; i++) {
    final record = face + 12 + i * 16;
    final offset = data.getUint32(record + 8);
    final tableLength = data.getUint32(record + 12);
    out.setRange(12 + i * 16, 12 + i * 16 + 8, collection, record);
    view
      ..setUint32(12 + i * 16 + 8, cursor)
      ..setUint32(12 + i * 16 + 12, tableLength);
    out.setRange(cursor, cursor + tableLength, collection, offset);
    cursor += _padded(tableLength);
  }
  return out;
}

int _padded(int length) => (length + 3) & ~3;
