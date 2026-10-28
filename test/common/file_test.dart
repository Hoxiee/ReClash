import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';

class _MockFile extends Mock implements File {}

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('file_test');
  });

  tearDown(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  group('safeDelete', () {
    test('tolerates a file removed after the existence check', () async {
      final original = File(join(root.path, 'cache'))
        ..writeAsStringSync('data');
      final file = _MockFile();
      when(file.exists).thenAnswer((_) async {
        await original.delete();
        return true;
      });
      when(
        () => file.delete(recursive: false),
      ).thenAnswer((_) => original.delete());

      await expectLater(file.safeDelete(), completes);

      expect(original.existsSync(), isFalse);
    });

    test('preserves errors other than a missing file', () async {
      final failure = FileSystemException('Permission denied', root.path);
      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(() => file.delete(recursive: false)).thenThrow(failure);

      await expectLater(file.safeDelete(), throwsA(same(failure)));
    });
  });

  group('safeDeletePath', () {
    test('removes a file', () async {
      final path = join(root.path, 'config.yaml');
      File(path).writeAsStringSync('mixed-port: 7890');

      await safeDeletePath(path);

      expect(File(path).existsSync(), isFalse);
    });

    test('removes a directory along with everything under it', () async {
      final path = join(root.path, '42');
      File(join(path, 'proxies', 'abc'))
        ..createSync(recursive: true)
        ..writeAsStringSync('proxies: []');

      await safeDeletePath(path);

      expect(Directory(path).existsSync(), isFalse);
    });

    test('accepts a path that is already gone', () async {
      await expectLater(safeDeletePath(join(root.path, 'missing')), completes);
    });
  });

  group('writeAsStringAtomically', () {
    test('replaces the file and leaves nothing beside it', () async {
      final file = File(join(root.path, 'config.yaml'))
        ..writeAsStringSync('mixed-port: 7890');

      await file.writeAsStringAtomically('mixed-port: 7891');

      expect(file.readAsStringSync(), 'mixed-port: 7891');
      expect(root.listSync().map((entry) => basename(entry.path)), [
        'config.yaml',
      ]);
    });

    test('creates the directory a first write needs', () async {
      final file = File(join(root.path, 'home', 'config.yaml'));

      await file.writeAsStringAtomically('mode: rule');

      expect(file.readAsStringSync(), 'mode: rule');
    });

    test('keeps the old file when the new one cannot be written', () async {
      final file = File(join(root.path, 'config.yaml'))
        ..writeAsStringSync('mode: rule');
      Directory('${file.path}.$pid.tmp').createSync();

      await expectLater(
        file.writeAsStringAtomically('mode: global'),
        throwsA(isA<FileSystemException>()),
      );
      expect(file.readAsStringSync(), 'mode: rule');
    });
  });
}
