import 'dart:convert';
import 'dart:typed_data';

final class PeImport {
  final String library;
  final String? name;
  final int? ordinal;

  const PeImport(this.library, {this.name, this.ordinal});

  String get symbol => name ?? '#$ordinal';
}

final class PeExport {
  final int ordinal;
  final String? forwarder;

  const PeExport(this.ordinal, this.forwarder);
}

final class PeImage {
  final Uint8List bytes;
  late final ByteData _data = ByteData.sublistView(bytes);
  late final int machine;
  late final bool _is64;
  late final int _optional;
  late final int _directories;
  late final int _directoryCount;
  late final int _headersSize;
  late final int _imageBase;
  final List<({int rva, int offset, int size})> _sections = [];
  final Map<int, PeExport> _ordinals = {};
  final Map<String, PeExport> _names = {};

  PeImage(this.bytes) {
    if (_u16(0) != 0x5a4d) _invalid('missing MZ header');
    final pe = _u32(0x3c);
    if (_u32(pe) != 0x4550) _invalid('missing PE header');
    machine = _u16(pe + 4);
    final sections = _u16(pe + 6);
    final optionalSize = _u16(pe + 20);
    _optional = pe + 24;
    _check(_optional, optionalSize);
    final magic = _u16(_optional);
    if (magic != 0x10b && magic != 0x20b) _invalid('unsupported PE format');
    _is64 = magic == 0x20b;
    final directoryOffset = _is64 ? 112 : 96;
    if (optionalSize < directoryOffset) _invalid('short optional header');
    _directories = _optional + directoryOffset;
    _directoryCount = _u32(_directories - 4);
    if (_directoryCount > (optionalSize - directoryOffset) ~/ 8) {
      _invalid('invalid data directory count');
    }
    _headersSize = _u32(_optional + 60);
    _imageBase = _is64 ? _u64(_optional + 24) : _u32(_optional + 28);
    final table = _optional + optionalSize;
    _check(table, sections * 40);
    for (var i = 0; i < sections; i++) {
      final section = table + i * 40;
      final size = _u32(section + 16);
      final offset = _u32(section + 20);
      _check(offset, size);
      _sections.add((rva: _u32(section + 12), offset: offset, size: size));
    }
    _readExports();
  }

  Never _invalid(String reason) => throw FormatException('Invalid PE: $reason');

  void _check(int offset, int length) {
    if (offset < 0 || length < 0 || offset > bytes.length - length) {
      _invalid('data outside the file');
    }
  }

  int _u16(int offset) {
    _check(offset, 2);
    return _data.getUint16(offset, Endian.little);
  }

  int _u32(int offset) {
    _check(offset, 4);
    return _data.getUint32(offset, Endian.little);
  }

  int _u64(int offset) {
    _check(offset, 8);
    return _data.getUint64(offset, Endian.little);
  }

  ({int rva, int size}) _directory(int index) {
    if (index >= _directoryCount) return (rva: 0, size: 0);
    return (
      rva: _u32(_directories + index * 8),
      size: _u32(_directories + index * 8 + 4),
    );
  }

  int _offset(int rva, [int size = 1]) {
    if (rva < 0 || size < 0) _invalid('negative RVA');
    if (rva < _headersSize && size <= _headersSize - rva) {
      _check(rva, size);
      return rva;
    }
    for (final section in _sections) {
      final relative = rva - section.rva;
      if (relative >= 0 && relative <= section.size - size) {
        final offset = section.offset + relative;
        _check(offset, size);
        return offset;
      }
    }
    _invalid('unmapped RVA 0x${rva.toRadixString(16)}');
  }

  String _string(int rva) {
    final start = _offset(rva);
    var end = start;
    while (end < bytes.length && end - start < 4096) {
      if (bytes[end] == 0) return utf8.decode(bytes.sublist(start, end));
      end++;
    }
    _invalid('unterminated string');
  }

  bool get hasCertificate {
    final certificate = _directory(4);
    if (certificate.rva == 0 || certificate.size == 0) return false;
    _check(certificate.rva, certificate.size);
    return certificate.size >= 8;
  }

  Iterable<PeImport> get imports sync* {
    for (final delay in [false, true]) {
      final directory = _directory(delay ? 13 : 1);
      if (directory.rva == 0 && directory.size == 0) continue;
      if (directory.rva == 0) _invalid('missing import directory RVA');
      final stride = delay ? 32 : 20;
      var terminated = false;
      for (
        var relative = 0;
        relative + stride <= directory.size;
        relative += stride
      ) {
        final at = _offset(directory.rva + relative, stride);
        final fields = List.generate(stride ~/ 4, (i) => _u32(at + i * 4));
        if (fields.every((field) => field == 0)) {
          terminated = true;
          break;
        }
        final usesVa = delay && fields[0] & 1 == 0;
        int rva(int value) => usesVa ? value - _imageBase : value;
        final nameRva = rva(fields[delay ? 1 : 3]);
        final thunkRva = rva(
          delay ? fields[4] : (fields[0] == 0 ? fields[4] : fields[0]),
        );
        final library = _string(nameRva).toLowerCase();
        if (!RegExp(r'^[a-z0-9_.-]+\.(dll|drv)$').hasMatch(library)) {
          _invalid('invalid import library $library');
        }
        final width = _is64 ? 8 : 4;
        final ordinalFlag = _is64 ? 0x8000000000000000 : 0x80000000;
        var thunkTerminated = false;
        for (var i = 0; i < bytes.length ~/ width; i++) {
          final offset = _offset(thunkRva + i * width, width);
          final value = _is64 ? _u64(offset) : _u32(offset);
          if (value == 0) {
            thunkTerminated = true;
            break;
          }
          if (value & ordinalFlag != 0) {
            yield PeImport(library, ordinal: value & 0xffff);
          } else {
            yield PeImport(library, name: _string(rva(value) + 2));
          }
        }
        if (!thunkTerminated) _invalid('unterminated import thunk table');
      }
      if (!terminated) _invalid('unterminated import descriptors');
    }
  }

  void _readExports() {
    final directory = _directory(0);
    if (directory.rva == 0 && directory.size == 0) return;
    if (directory.rva == 0 || directory.size < 40) {
      _invalid('invalid export directory');
    }
    final at = _offset(directory.rva, 40);
    final base = _u32(at + 16);
    final count = _u32(at + 20);
    final namesCount = _u32(at + 24);
    final functions = _offset(_u32(at + 28), count * 4);
    for (var i = 0; i < count; i++) {
      final address = _u32(functions + i * 4);
      if (address == 0) continue;
      final forwarded =
          address >= directory.rva && address < directory.rva + directory.size;
      _ordinals[base + i] = PeExport(
        base + i,
        forwarded ? _string(address) : null,
      );
    }
    if (namesCount == 0) return;
    final names = _offset(_u32(at + 32), namesCount * 4);
    final ordinals = _offset(_u32(at + 36), namesCount * 2);
    for (var i = 0; i < namesCount; i++) {
      final ordinalIndex = _u16(ordinals + i * 2);
      final exported = _ordinals[base + ordinalIndex];
      if (ordinalIndex >= count || exported == null) {
        _invalid('invalid export ordinal');
      }
      final name = _string(_u32(names + i * 4));
      if (_names.containsKey(name)) _invalid('duplicate export name');
      _names[name] = exported;
    }
  }

  PeExport? resolve(PeImport symbol) =>
      symbol.name == null ? _ordinals[symbol.ordinal] : _names[symbol.name];
}
