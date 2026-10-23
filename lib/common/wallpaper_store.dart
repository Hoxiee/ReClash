import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:reclash/models/wallpaper.dart';

const maxWallpaperBytes = 20 * 1024 * 1024;
const maxStoredWallpaperBytes = 32 * 1024 * 1024;
const maxWallpaperDimension = 2560;
const _maxWallpaperPixels = 50000000;

enum WallpaperImportFailure { invalidImage, tooLarge }

class WallpaperImportException implements Exception {
  const WallpaperImportException(this.failure);

  final WallpaperImportFailure failure;
}

class WallpaperStore {
  const WallpaperStore({required this.directory});

  final Future<Directory> Function() directory;

  Future<String> importImage(PlatformFile source) async {
    if (await source.length() > maxWallpaperBytes) {
      throw const WallpaperImportException(WallpaperImportFailure.tooLarge);
    }
    final bytes = await _readLimited(
      source.readAsByteStream(),
      maxWallpaperBytes,
    );
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return _store(bytes, '$id.png');
  }

  /// Stores [bytes] under [fileName], which must pass [isWallpaperFileName].
  Future<String> importBytes(Uint8List bytes, String fileName) {
    if (bytes.length > maxWallpaperBytes) {
      throw const WallpaperImportException(WallpaperImportFailure.tooLarge);
    }
    return _store(bytes, fileName);
  }

  Future<bool> hasImage(String fileName) async =>
      isWallpaperFileName(fileName) &&
      await FileSystemEntity.type(
            join((await directory()).path, fileName),
            followLinks: false,
          ) ==
          FileSystemEntityType.file;

  Future<String> _store(Uint8List bytes, String fileName) async {
    final image = await _decode(bytes);
    final Uint8List normalized;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const WallpaperImportException(
          WallpaperImportFailure.invalidImage,
        );
      }
      normalized = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      if (normalized.length > maxStoredWallpaperBytes) {
        throw const WallpaperImportException(WallpaperImportFailure.tooLarge);
      }
    } finally {
      image.dispose();
    }
    final root = await directory();
    await root.create(recursive: true);
    final file = File(join(root.path, fileName));
    final staged = File(join(root.path, '.$fileName.tmp'));
    try {
      await staged.writeAsBytes(normalized, flush: true);
      await staged.rename(file.path);
    } catch (_) {
      if (await staged.exists()) await staged.delete();
      rethrow;
    }
    return fileName;
  }

  Future<Uint8List?> readImage(String? fileName) async {
    if (!isWallpaperFileName(fileName)) return null;
    final file = File(join((await directory()).path, fileName!));
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      return null;
    }
    return readStoredImage(file);
  }

  Future<void> removeImage(String? fileName) async {
    if (!isWallpaperFileName(fileName)) return;
    final file = File(join((await directory()).path, fileName!));
    if (await FileSystemEntity.type(file.path, followLinks: false) ==
        FileSystemEntityType.file) {
      await file.delete();
    }
  }

  static Future<Uint8List> readStoredImage(File file) async {
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const WallpaperImportException(WallpaperImportFailure.invalidImage);
    }
    if (await file.length() > maxStoredWallpaperBytes) {
      throw const WallpaperImportException(WallpaperImportFailure.tooLarge);
    }
    final bytes = await _readLimited(file.openRead(), maxStoredWallpaperBytes);
    final image = await _decode(bytes, stored: true);
    image.dispose();
    return bytes;
  }

  static Future<Uint8List> _readLimited(
    Stream<List<int>> stream,
    int limit,
  ) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      if (builder.length + chunk.length > limit) {
        throw const WallpaperImportException(WallpaperImportFailure.tooLarge);
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  static Future<ui.Image> _decode(
    Uint8List bytes, {
    bool stored = false,
  }) async {
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10;
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    final webp =
        bytes.length >= 12 &&
        bytes[0] == 82 &&
        bytes[1] == 73 &&
        bytes[2] == 70 &&
        bytes[3] == 70 &&
        bytes[8] == 87 &&
        bytes[9] == 69 &&
        bytes[10] == 66 &&
        bytes[11] == 80;
    if (!png && (stored || (!jpeg && !webp))) {
      throw const WallpaperImportException(WallpaperImportFailure.invalidImage);
    }
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final width = descriptor.width;
      final height = descriptor.height;
      if (width <= 0 || height <= 0) {
        throw const WallpaperImportException(
          WallpaperImportFailure.invalidImage,
        );
      }
      if (width * height > _maxWallpaperPixels ||
          (stored && max(width, height) > maxWallpaperDimension)) {
        throw const WallpaperImportException(WallpaperImportFailure.tooLarge);
      }
      final ratio = min(1.0, maxWallpaperDimension / max(width, height));
      codec = await descriptor.instantiateCodec(
        targetWidth: max(1, (width * ratio).round()),
        targetHeight: max(1, (height * ratio).round()),
      );
      return (await codec.getNextFrame()).image;
    } on WallpaperImportException {
      rethrow;
    } catch (_) {
      throw const WallpaperImportException(WallpaperImportFailure.invalidImage);
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}
