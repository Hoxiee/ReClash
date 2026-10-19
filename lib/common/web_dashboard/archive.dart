import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/enum/enum.dart';

import 'dashboard.dart';

typedef WebDashboardExtraction = ({
  String archivePath,
  String stagingPath,
  String cancelPath,
});

String _entryName(String name) {
  final slash = name.replaceAll('\\', '/');
  final parts = p.posix.split(slash);
  if (slash.isEmpty ||
      slash.length > 1024 ||
      p.posix.isAbsolute(slash) ||
      parts.contains('..') ||
      parts.length > 16 ||
      RegExp(r'[\x00-\x1f\x7f<>:"|?*]').hasMatch(slash) ||
      parts.any(
        (part) =>
            part != '.' &&
            (part.endsWith('.') ||
                part.endsWith(' ') ||
                RegExp(
                  r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)',
                  caseSensitive: false,
                ).hasMatch(part)),
      )) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  }
  return p.posix.normalize(slash);
}

String? webDashboardArchiveRoot(Iterable<String> names) {
  final entries = names
      .map(_entryName)
      .where((name) => p.posix.basename(name) == webDashboardEntryName)
      .toList();
  if (entries.isEmpty) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  }
  entries.sort(
    (a, b) => p.posix.split(a).length.compareTo(p.posix.split(b).length),
  );
  final first = entries.first;
  if (entries
      .skip(1)
      .any(
        (entry) => p.posix.split(entry).length == p.posix.split(first).length,
      )) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  }
  final root = p.posix.dirname(first);
  return root == '.' ? null : root;
}

String? webDashboardEntryPath(String target, String name, String? root) {
  final normalized = _entryName(name);
  if (root != null && !p.posix.isWithin(root, normalized)) {
    return null;
  }
  final relative = root == null
      ? normalized
      : p.posix.relative(normalized, from: root);
  if (relative == '.') {
    return null;
  }
  final destination = p.joinAll([target, ...p.posix.split(relative)]);
  if (!p.isWithin(target, destination)) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  }
  return destination;
}

void _checkCancelled(String path) {
  if (File(path).existsSync()) {
    throw const WebDashboardException(WebDashboardFailure.cancelled);
  }
}

class _LimitedOutput extends OutputFileStream {
  _LimitedOutput(
    String path,
    this.limit,
    this.cancelPath, {
    this.checksum = false,
  }) : super.withFileHandle(FileHandle(path, mode: FileAccess.write));

  final int limit;
  final String cancelPath;
  final bool checksum;
  int _nextCancelCheck = 0;
  int crc = 0;

  void _check(int count) {
    if (length + count > limit) {
      throw const WebDashboardException(WebDashboardFailure.tooLarge);
    }
    if (length + count >= _nextCancelCheck) {
      _checkCancelled(cancelPath);
      _nextCancelCheck = length + count + 64 * 1024;
    }
  }

  @override
  void writeByte(int value) {
    _check(1);
    if (checksum) {
      crc = getCrc32Byte(crc ^ 0xffffffff, value) ^ 0xffffffff;
    }
    super.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final count = length ?? bytes.length;
    _check(count);
    if (checksum) {
      crc = getCrc32(
        count == bytes.length ? bytes : bytes.sublist(0, count),
        crc,
      );
    }
    super.writeBytes(bytes, length: count);
  }
}

Archive _decodeZip(InputFileStream input) {
  final tailLength = input.length < 65557 ? input.length : 65557;
  final tail = input.subset(position: input.length - tailLength).toUint8List();
  var count = -1;
  for (var offset = tail.length - 22; offset >= 0; offset--) {
    final data = ByteData.sublistView(tail, offset);
    if (data.getUint32(0, Endian.little) != ZipDirectory.eocdSignature ||
        offset + 22 + data.getUint16(20, Endian.little) != tail.length) {
      continue;
    }
    count = data.getUint16(10, Endian.little);
    if (data.getUint16(4, Endian.little) != 0 ||
        data.getUint16(6, Endian.little) != 0 ||
        data.getUint16(8, Endian.little) != count) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
    break;
  }
  if (count < 0) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  }
  if (count > webDashboardMaxFiles) {
    throw const WebDashboardException(WebDashboardFailure.tooLarge);
  }
  input.reset();
  final directory = ZipDirectory()..read(input);
  if (directory.fileHeaders.length != count) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  }
  final archive = Archive();
  final names = <String>{};
  var size = 0;
  for (final header in directory.fileHeaders) {
    final file = header.file;
    final type = (header.externalFileAttributes >> 16) & 0xf000;
    final name = _entryName(header.filename);
    if (file == null ||
        file.filename != header.filename ||
        ![0, 0x8000, 0x4000].contains(type) ||
        !names.add(name.toLowerCase())) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
    if (file.uncompressedSize < 0 ||
        file.uncompressedSize > webDashboardMaxFileBytes) {
      throw const WebDashboardException(WebDashboardFailure.tooLarge);
    }
    size += file.uncompressedSize;
    if (size > webDashboardMaxExtractedBytes) {
      throw const WebDashboardException(WebDashboardFailure.tooLarge);
    }
    final isDirectory = type == 0x4000 || header.filename.endsWith('/');
    archive.add(
      isDirectory
          ? ArchiveFile.directory(header.filename)
          : (ArchiveFile.file(header.filename, file.uncompressedSize, file)
              ..crc32 = header.crc32),
    );
  }
  return archive;
}

String _tarString(List<int> bytes) {
  final end = bytes.indexOf(0);
  if (end >= 0 && bytes.skip(end).any((byte) => byte != 0)) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  }
  return utf8.decode(end < 0 ? bytes : bytes.sublist(0, end));
}

void _validateTar(InputFileStream input, String cancelPath) {
  var count = 0;
  while (!input.isEOS) {
    _checkCancelled(cancelPath);
    final header = input.peekBytes(512).toUint8List();
    if (header.length != 512) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
    if (header.every((byte) => byte == 0)) break;
    if (++count > webDashboardMaxFiles * 2) {
      throw const WebDashboardException(WebDashboardFailure.tooLarge);
    }
    final name = _tarString(header.sublist(0, 100));
    _entryName(name);
    if (_tarString(header.sublist(257, 263)) == 'ustar') {
      final prefix = _tarString(header.sublist(345, 500));
      if (prefix.isNotEmpty) _entryName('$prefix/$name');
    }
    final type = header[156];
    if (![0, 0x30, 0x35, 0x4c].contains(type)) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
    final position = input.position;
    final file = TarFile.read(input, storeData: false);
    if (input.position > input.fileLength || file.fileSize < 0) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
    if (type == 0x4c) {
      if (file.fileSize > 1025) {
        throw const WebDashboardException(WebDashboardFailure.archive);
      }
      _entryName(_tarString(file.rawContent!.toUint8List()));
    } else if (file.fileSize > webDashboardMaxFileBytes) {
      throw const WebDashboardException(WebDashboardFailure.tooLarge);
    } else if (type == 0x35 && file.fileSize != 0) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
    if (input.position <= position) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
  }
  input.reset();
}

void extractWebDashboard(WebDashboardExtraction args) {
  _checkCancelled(args.cancelPath);
  final staging = Directory(args.stagingPath);
  if (FileSystemEntity.typeSync(staging.path, followLinks: false) !=
          FileSystemEntityType.directory ||
      staging.listSync().isNotEmpty) {
    throw const WebDashboardException(WebDashboardFailure.storage);
  }
  final input = InputFileStream(args.archivePath);
  InputFileStream? tarInput;
  Archive? archive;
  try {
    final magic = input.peekBytes(2).toUint8List();
    final isGzip = magic.length == 2 && magic[0] == 0x1f && magic[1] == 0x8b;
    if (isGzip) {
      final tarPath = p.join(p.dirname(args.archivePath), 'contents.tar');
      final output = _LimitedOutput(
        tarPath,
        webDashboardMaxExtractedBytes + webDashboardMaxFiles * 1024,
        args.cancelPath,
      );
      try {
        if (!const GZipDecoder().decodeStream(input, output, verify: true)) {
          throw const WebDashboardException(WebDashboardFailure.archive);
        }
      } finally {
        output.closeSync();
      }
      tarInput = InputFileStream(tarPath);
      _validateTar(tarInput, args.cancelPath);
      final decoder = TarDecoder();
      final names = <String>{};
      var size = 0;
      var count = 0;
      archive = decoder.decodeStream(
        tarInput,
        verify: true,
        callback: (file) {
          _checkCancelled(args.cancelPath);
          final type = decoder.files.last.typeFlag;
          if (!['', TarFile.normalFile, TarFile.directory].contains(type) ||
              file.isSymbolicLink ||
              !names.add(_entryName(file.name).toLowerCase())) {
            throw const WebDashboardException(WebDashboardFailure.archive);
          }
          size += file.size;
          if (++count > webDashboardMaxFiles ||
              file.size < 0 ||
              file.size > webDashboardMaxFileBytes ||
              size > webDashboardMaxExtractedBytes) {
            throw const WebDashboardException(WebDashboardFailure.tooLarge);
          }
        },
      );
    } else {
      archive = _decodeZip(input);
    }
    final files = archive.files.where((file) => file.isFile).toList();
    final root = webDashboardArchiveRoot(files.map((file) => file.name));
    for (final file in files) {
      _checkCancelled(args.cancelPath);
      final destination = webDashboardEntryPath(
        args.stagingPath,
        file.name,
        root,
      );
      if (destination == null) {
        continue;
      }
      Directory(p.dirname(destination)).createSync(recursive: true);
      final output = _LimitedOutput(
        destination,
        file.size,
        args.cancelPath,
        checksum: !isGzip,
      );
      try {
        file.writeContent(output);
        if (output.length != file.size ||
            (!isGzip && output.crc != file.crc32)) {
          throw const WebDashboardException(WebDashboardFailure.archive);
        }
      } finally {
        output.closeSync();
      }
    }
    final entry = File(p.join(args.stagingPath, webDashboardEntryName));
    if (!entry.existsSync() || entry.lengthSync() == 0) {
      throw const WebDashboardException(WebDashboardFailure.archive);
    }
  } on WebDashboardException {
    rethrow;
  } catch (_) {
    throw const WebDashboardException(WebDashboardFailure.archive);
  } finally {
    archive?.clearSync();
    tarInput?.closeSync();
    input.closeSync();
  }
}
