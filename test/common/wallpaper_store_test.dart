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
