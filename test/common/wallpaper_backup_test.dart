import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:reclash/common/backup.dart';
import 'package:reclash/common/wallpaper_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  late Directory root;
  late Directory home;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('reclash-wallpaper-backup-');
    home = Directory(join(root.path, 'home'))..createSync();
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('backs up only named files from the wallpaper library', () async {
    const name = '0123456789abcdef0123456789abcdef.png';
    final wallpapers = Directory(join(home.path, 'wallpapers'))..createSync();
    File(join(wallpapers.path, name)).writeAsBytesSync(_png);
    File(join(wallpapers.path, 'unlisted.png')).writeAsBytesSync(_png);
    final database = File(join(root.path, 'database.sqlite'))
      ..writeAsBytesSync([1]);
    final archive = join(root.path, 'backup.zip');
    await writeBackupArchive(
      archivePath: archive,
      configMap: const {},
      databaseSnapshotPath: database.path,
      homeDirPath: home.path,
      entries: [BackupEntries.wallpaper(name)],
    );
    final decoded = ZipDecoder().decodeBytes(File(archive).readAsBytesSync());
    expect(
      decoded.files.map((file) => file.name),
      contains('wallpapers/$name'),
    );
    expect(
      decoded.files.map((file) => file.name),
      isNot(contains('wallpapers/unlisted.png')),
    );
  });

  test('резервная копия сохраняет и восстанавливает исходный SVG', () async {
    const name = '0123456789abcdef0123456789abcdef.svg';
    final svg = utf8.encode(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080 1920">'
      '<rect width="1080" height="1920" fill="#ff6b1a"/>'
      '</svg>',
    );
    final wallpapers = Directory(join(home.path, 'wallpapers'))..createSync();
    File(join(wallpapers.path, name)).writeAsBytesSync(svg);
    final database = File(join(root.path, 'database.sqlite'))
      ..writeAsBytesSync([1]);
    final archive = join(root.path, 'backup.zip');
    await writeBackupArchive(
      archivePath: archive,
      configMap: const {},
      databaseSnapshotPath: database.path,
      homeDirPath: home.path,
      entries: [BackupEntries.wallpaper(name)],
    );
    final staging = join(root.path, 'stage');
    await readBackupArchive(archivePath: archive, stagingDirPath: staging);
    final restored = File(join(staging, 'wallpapers', name));
    expect(await WallpaperStore.readStoredImage(restored), svg);
    expect(restored.readAsBytesSync(), svg);
  });

  for (final declaredSize in [1, 2048]) {
    test('rejects a false wallpaper ZIP size of $declaredSize', () async {
      const name = '0123456789abcdef0123456789abcdef.png';
      final payload = Uint8List(1024);
      final archive = Archive()
        ..addFile(ArchiveFile.bytes('wallpapers/$name', payload))
        ..addFile(ArchiveFile.string('config.json', '{"version":1}'));
      final bytes = ZipEncoder().encodeBytes(archive);
      final directory = ZipDirectory()..read(InputMemoryStream(bytes));
      final header = directory.fileHeaders.first;
      final data = ByteData.sublistView(bytes);
      data.setUint32(
        directory.centralDirectoryOffset + 24,
        declaredSize,
        Endian.little,
      );
      data.setUint32(
        header.localHeaderOffset + 22,
        declaredSize,
        Endian.little,
      );
      final archivePath = join(root.path, 'invalid-size.zip');
      File(archivePath).writeAsBytesSync(bytes);
      final staging = join(root.path, 'stage');

      await expectLater(
        readBackupArchive(archivePath: archivePath, stagingDirPath: staging),
        throwsA(
          isA<BackupException>().having(
            (error) => error.failure,
            'failure',
            BackupFailure.invalid,
          ),
        ),
      );

      final output = File(join(staging, 'wallpapers', name));
      if (output.existsSync()) {
        expect(output.lengthSync(), lessThanOrEqualTo(declaredSize));
      }
    });
  }

  test(
    'skips unsafe and unsupported wallpaper entries during restore staging',
    () async {
      const name = '0123456789abcdef0123456789abcdef.png';
      final archive = Archive()
        ..addFile(ArchiveFile.string('config.json', jsonEncode({'version': 1})))
        ..addFile(ArchiveFile('wallpapers/$name', _png.length, _png))
        ..addFile(ArchiveFile('wallpapers/../escape.png', _png.length, _png))
        ..addFile(
          ArchiveFile('wallpapers/not-a-wallpaper.png', _png.length, _png),
        );
      final archivePath = join(root.path, 'input.zip');
      final encoded = ZipEncoder().encode(archive);
      File(archivePath).writeAsBytesSync(encoded);
      final staging = join(root.path, 'stage');
      await readBackupArchive(
        archivePath: archivePath,
        stagingDirPath: staging,
      );
      expect(File(join(staging, 'wallpapers', name)).readAsBytesSync(), _png);
      expect(File(join(root.path, 'escape.png')).existsSync(), isFalse);
      expect(
        File(join(staging, 'wallpapers', 'not-a-wallpaper.png')).existsSync(),
        isFalse,
      );
    },
  );
}
