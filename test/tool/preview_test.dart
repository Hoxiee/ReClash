import 'dart:typed_data';

import 'package:test/test.dart';

import '../../tool/preview/preview_cli.dart';

PreviewOptions _parse(List<String> args) =>
    PreviewOptions.parse(PreviewOptions.parser().parse(args));

Uint8List _collection(List<List<int>> faceTables) {
  final out = BytesBuilder();
  final header = ByteData(12 + faceTables.length * 4)
    ..setUint32(0, 0x74746366)
    ..setUint32(4, 0x00010000)
    ..setUint32(8, faceTables.length);
  var faceOffset = header.lengthInBytes;
  final faces = <Uint8List>[];
  var dataOffset = faceOffset + faceTables.length * 28;
  final tables = BytesBuilder();
  for (final (index, table) in faceTables.indexed) {
    header.setUint32(12 + index * 4, faceOffset);
    final face = ByteData(12 + 16)
      ..setUint32(0, 0x00010000)
      ..setUint16(4, 1)
      ..setUint32(12, 0x6e616d65)
      ..setUint32(20, dataOffset)
      ..setUint32(24, table.length);
    faces.add(face.buffer.asUint8List());
    faceOffset += face.lengthInBytes;
    final padded = (table.length + 3) & ~3;
    tables.add([...table, ...List.filled(padded - table.length, 0)]);
    dataOffset += padded;
  }
  out.add(header.buffer.asUint8List());
  faces.forEach(out.add);
  out.add(tables.takeBytes());
  return out.takeBytes();
}

void main() {
  group('options', () {
    test('defaults to one small light English phone image', () {
      final options = _parse(['about.dart']);
      expect(options.pixelRatio, 1);
      expect(options.textScale, 1);
      expect(options.outDir, isNull);
      expect(options.cells('about').map((cell) => cell.fileName), [
        'about_412x915_light_en.png',
      ]);
    });

    test('names every matrix cell after size, theme and locale', () {
      final options = _parse([
        'about.dart',
        '--size',
        '412x915,1280x800',
        '--theme',
        'light,dark',
        '--locale',
        'en,zh_CN',
      ]);
      final names = options.cells('about').map((cell) => cell.fileName);
      expect(names, hasLength(8));
      expect(names.first, 'about_412x915_light_en.png');
      expect(names, contains('about_1280x800_dark_zh_CN.png'));
      expect(names.toSet(), hasLength(8));
    });

    test('rejects malformed values', () {
      for (final args in [
        <String>[],
        ['a.dart', 'b.dart'],
        ['a.dart', '--size', '412'],
        ['a.dart', '--theme', 'dim'],
        ['a.dart', '--scale', '0'],
        ['a.dart', '--text-scale', 'big'],
      ]) {
        expect(() => _parse(args), throwsFormatException, reason: '$args');
      }
    });
  });

  test('picks the Han variant a locale reads', () {
    expect(CjkVariant.of('en'), CjkVariant.simplified);
    expect(CjkVariant.of('zh_CN'), CjkVariant.simplified);
    expect(CjkVariant.of('zh_TW'), CjkVariant.traditional);
    expect(CjkVariant.of('zh-Hant'), CjkVariant.traditional);
    expect(CjkVariant.of('ja'), CjkVariant.japanese);
    expect(CjkVariant.of('ko'), CjkVariant.korean);
  });

  group('scenario', () {
    test('wires only the hooks the scenario defines', () {
      final hooks = scenarioHooks('''
Widget preview() => const Placeholder();
Future<void> previewAct(WidgetTester tester) async {}
''');
      expect(hooks, (overrides: false, setUp: false, act: true));
      final source = harnessSource(
        harnessLibrary: Uri.file('/repo/tool/preview/harness.dart'),
        scenario: Uri.file('/tmp/about.dart'),
        configPath: '/repo/.dart_tool/preview/about.json',
        hooks: hooks,
      );
      expect(source, contains("import 'file:///tmp/about.dart' as scenario;"));
      expect(source, contains('act: scenario.previewAct'));
      expect(source, isNot(contains('previewOverrides')));
      expect(source, isNot(contains('previewSetUp')));
    });

    test('requires preview()', () {
      expect(
        () => scenarioHooks('Widget previewAct() => const Placeholder();'),
        throwsFormatException,
      );
    });
  });

  group('compactFailure', () {
    test('keeps the first compile error from the path on', () {
      expect(
        compactFailure(
          '  Compilation failed for testPath=/x_test.dart: /s.dart:3:32: '
          "Error: The argument type 'int' can't be assigned.\n"
          '  Widget preview() => const Text(42);\n'
          '/s.dart:4:1: Error: second\n',
        ),
        [
          "/s.dart:3:32: Error: The argument type 'int' can't be assigned.",
          '  Widget preview() => const Text(42);',
        ],
      );
    });

    test('reduces an exception to its message and first app frame', () {
      expect(
        compactFailure('''
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══
The following StateError was thrown building Builder(dirty):
Bad state: boom

The relevant error-causing widget was:
#0      preview.<anonymous closure> (file:///tmp/broken.dart:3:51)
#1      StatelessElement.build (package:flutter/src/widgets/framework.dart:1:1)
'''),
        [
          'The following StateError was thrown building Builder(dirty):',
          'Bad state: boom',
          'at /tmp/broken.dart:3:51',
        ],
      );
    });
  });

  test('extracts one face of a font collection with its own offsets', () {
    final collection = _collection([
      [1, 2, 3, 4, 5],
      [6, 7, 8],
    ]);
    final face = ByteData.sublistView(extractCollectionFace(collection, 1));
    expect(face.getUint32(0), 0x00010000);
    expect(face.getUint16(4), 1);
    expect(face.getUint32(12), 0x6e616d65);
    final offset = face.getUint32(20);
    expect(offset, 28);
    expect(face.getUint32(24), 3);
    expect(face.buffer.asUint8List(offset, 3), [6, 7, 8]);
    expect(face.lengthInBytes, 32);

    final plain = Uint8List.fromList([0, 1, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9]);
    expect(extractCollectionFace(plain, 0), same(plain));
  });
}
