import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:reclash/common/wallpaper_store.dart';
import 'package:flutter_test/flutter_test.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

final _svg = utf8.encode(
  '<?xml version="1.0" encoding="UTF-8"?>\n'
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080 1920">'
  '<rect width="1080" height="1920" fill="#ff6b1a"/>'
  '</svg>',
);

final class _PickedFile extends PlatformFile {
  _PickedFile(this.file, this.name);

  final File file;
  @override
  final String name;
  @override
  Uri get uri => file.uri;
  @override
  XFile get xFile => XFile(file.path, name: name);
  @override
  int lengthSync() => file.lengthSync();
  @override
  Future<int> length() => file.length();
  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();
  @override
  Stream<Uint8List> readAsByteStream() async* {
    await for (final chunk in file.openRead()) {
      yield Uint8List.fromList(chunk);
    }
  }
}

void main() {
  late Directory root;
  late WallpaperStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('reclash-wallpaper-');
    store = WallpaperStore(directory: () async => root);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('normalizes a supported image into an app-owned PNG', () async {
    final source = File('${root.path}/source.png')..writeAsBytesSync(_png);
    final fileName = await store.importImage(_PickedFile(source, 'source.png'));
    expect(fileName, matches(RegExp(r'^[a-f0-9]{32}\.png$')));
    expect(await store.readImage(fileName), isNotEmpty);
    expect(await root.list().length, 2);
  });

  test('сохраняет фон подписки как исходный SVG без конвертации', () async {
    final fileName = await store.importBytes(
      _svg,
      '0123456789abcdef0123456789abcdef.png',
    );
    expect(fileName, '0123456789abcdef0123456789abcdef.svg');
    expect(await store.hasImage(fileName), isTrue);
    expect(await store.readImage(fileName), _svg);
    expect(File('${root.path}/$fileName').readAsBytesSync(), _svg);
    expect(await root.list().length, 1);
  });

  test('импортирует выбранный SVG без изменения байтов', () async {
    final source = File('${root.path}/source.svg')..writeAsBytesSync(_svg);
    final fileName = await store.importImage(_PickedFile(source, 'source.svg'));
    expect(fileName, matches(RegExp(r'^[a-f0-9]{32}\.svg$')));
    expect(await store.readImage(fileName), _svg);
    await store.removeImage(fileName);
    expect(await store.hasImage(fileName), isFalse);
    expect(await root.list().length, 1);
  });

  for (final source in [
    '<svg xmlns="http://www.w3.org/2000/svg"><path',
    '<html><body>Not an image</body></html>',
    '<svg xmlns="http://www.w3.org/2000/svg" width="0" height="0"/>',
  ]) {
    test('отклоняет недопустимый SVG: $source', () async {
      await expectLater(
        store.importBytes(
          utf8.encode(source),
          '0123456789abcdef0123456789abcdef.svg',
        ),
        throwsA(isA<WallpaperImportException>()),
      );
      expect(await root.list().length, 0);
    });
  }

  test('соблюдает лимит размера и безопасные имена для SVG', () async {
    await expectLater(
      () => store.importBytes(
        Uint8List(maxWallpaperBytes + 1),
        '0123456789abcdef0123456789abcdef.svg',
      ),
      throwsA(
        isA<WallpaperImportException>().having(
          (error) => error.failure,
          'failure',
          WallpaperImportFailure.tooLarge,
        ),
      ),
    );
    await expectLater(
      store.importBytes(_svg, '../escape.svg'),
      throwsA(isA<WallpaperImportException>()),
    );
    expect(await root.list().length, 0);
  });

  test(
    'проверяет соответствие содержимого расширению сохранённого фона',
    () async {
      const pngName = '0123456789abcdef0123456789abcdef.png';
      const svgName = '0123456789abcdef0123456789abcdef.svg';
      File('${root.path}/$pngName').writeAsBytesSync(_svg);
      File('${root.path}/$svgName').writeAsBytesSync(_png);
      for (final name in [pngName, svgName]) {
        await expectLater(
          store.readImage(name),
          throwsA(isA<WallpaperImportException>()),
        );
      }
    },
  );

  test('rejects invalid image contents without leaving a temp file', () async {
    final source = File('${root.path}/source.png')..writeAsBytesSync([1, 2, 3]);
    await expectLater(
      store.importImage(_PickedFile(source, 'source.png')),
      throwsA(isA<WallpaperImportException>()),
    );
    expect(await root.list().length, 1);
  });

  test('refuses unsafe names and symlinked files', () async {
    expect(await store.readImage('../outside.png'), isNull);
    final outside = File('${root.parent.path}/outside.png')
      ..writeAsBytesSync(_png);
    final link = Link('${root.path}/0123456789abcdef0123456789abcdef.png')
      ..createSync(outside.path);
    expect(
      await store.readImage('0123456789abcdef0123456789abcdef.png'),
      isNull,
    );
    expect(await link.exists(), isTrue);
  });
}
