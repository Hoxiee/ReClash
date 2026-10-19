import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/pe_image.dart';
import '../../tool/src/windows_bundle.dart';

Uint8List _pe({
  int machine = windowsMachineAmd64,
  List<PeImport> imports = const [],
  List<PeImport> delayImports = const [],
  Map<String, String?> exports = const {},
}) {
  final bytes = Uint8List(0x4000);
  final data = ByteData.sublistView(bytes);
  void u16(int at, int value) => data.setUint16(at, value, Endian.little);
  void u32(int at, int value) => data.setUint32(at, value, Endian.little);
  void u64(int at, int value) => data.setUint64(at, value, Endian.little);
  var cursor = 0x200;
  int allocate(int size) {
    final result = cursor;
    cursor += size;
    return result;
  }

  int rva(int at) => at - 0x200 + 0x1000;
  int string(String value, {int hint = 0}) {
    final encoded = utf8.encode(value);
    final at = allocate(hint + encoded.length + 1);
    bytes.setRange(at + hint, at + hint + encoded.length, encoded);
    return rva(at);
  }

  void directory(int index, int at, int size) {
    u32(0x108 + index * 8, rva(at));
    u32(0x10c + index * 8, size);
  }

  u16(0, 0x5a4d);
  u32(0x3c, 0x80);
  u32(0x80, 0x4550);
  u16(0x84, machine);
  u16(0x86, 1);
  u16(0x94, 0xf0);
  u16(0x98, 0x20b);
  u64(0x98 + 24, 0x140000000);
  u32(0x98 + 60, 0x200);
  u32(0x104, 16);
  u32(0x188 + 8, 0x3e00);
  u32(0x188 + 12, 0x1000);
  u32(0x188 + 16, 0x3e00);
  u32(0x188 + 20, 0x200);

  void addImports(List<PeImport> symbols, bool delay) {
    if (symbols.isEmpty) return;
    final stride = delay ? 32 : 20;
    final table = allocate((symbols.length + 1) * stride);
    directory(delay ? 13 : 1, table, (symbols.length + 1) * stride);
    for (var i = 0; i < symbols.length; i++) {
      final symbol = symbols[i];
      final at = table + i * stride;
      final library = string(symbol.library);
      final thunk = allocate(16);
      u64(
        thunk,
        symbol.ordinal == null
            ? string(symbol.name!, hint: 2)
            : 0x8000000000000000 | symbol.ordinal!,
      );
      if (delay) {
        u32(at, 1);
        u32(at + 4, library);
        u32(at + 16, rva(thunk));
      } else {
        u32(at, rva(thunk));
        u32(at + 12, library);
        u32(at + 16, rva(thunk));
      }
    }
  }

  addImports(imports, false);
  addImports(delayImports, true);
  if (exports.isNotEmpty) {
    final table = allocate(40);
    final functions = allocate(exports.length * 4);
    final names = allocate(exports.length * 4);
    final ordinals = allocate(exports.length * 2);
    u32(table + 16, 1);
    u32(table + 20, exports.length);
    u32(table + 24, exports.length);
    u32(table + 28, rva(functions));
    u32(table + 32, rva(names));
    u32(table + 36, rva(ordinals));
    var i = 0;
    for (final entry in exports.entries) {
      u32(
        functions + i * 4,
        entry.value == null ? 0x4000 : string(entry.value!),
      );
      u32(names + i * 4, string(entry.key));
      u16(ordinals + i * 2, i);
      i++;
    }
    directory(0, table, cursor - table);
  }
  return bytes;
}

Map<String, Uint8List> _bundle({bool delay = false}) {
  final core = _pe();
  final imports = [const PeImport('MSVCP140.dll', name: 'run')];
  return {
    'ReClash.exe': _pe(
      imports: delay ? [] : imports,
      delayImports: delay ? imports : [],
    ),
    'ReClashCore.exe': core,
    'rust_api.dll': _pe(),
    'sqlite3.dll': _pe(),
    'flutter_windows.dll': _pe(),
    'msvcp140.dll': _pe(exports: {'run': null}),
    'data/icudtl.dat': Uint8List.fromList([1]),
    'data/app.so': Uint8List.fromList([1]),
    'data/flutter_assets/AssetManifest.bin': Uint8List.fromList([1]),
    'manifest.json': Uint8List.fromList(
      utf8.encode(jsonEncode({'coreSha256': sha256.convert(core).toString()})),
    ),
  };
}

void main() {
  void validate(Map<String, Uint8List> files, {bool signed = false}) {
    WindowsBundle(
      files,
    ).validate(machine: windowsMachineAmd64, requireSigned: signed);
  }

  test('reads named, ordinal and delay imports and exported forwarders', () {
    final image = PeImage(
      _pe(
        imports: [const PeImport('msvcp140.dll', ordinal: 7)],
        delayImports: [const PeImport('vcruntime140.dll', name: 'delayed')],
        exports: {'first': null, 'second': 'other.target'},
      ),
    );
    expect(image.machine, windowsMachineAmd64);
    expect(image.imports.map((symbol) => symbol.symbol), ['#7', 'delayed']);
    expect(
      image.resolve(const PeImport('self.dll', ordinal: 1))?.forwarder,
      isNull,
    );
    expect(
      image.resolve(const PeImport('self.dll', name: 'second'))?.forwarder,
      'other.target',
    );
  });

  test('validates bundled runtime without consulting installed DLLs', () {
    final report = WindowsBundle(
      _bundle(),
    ).validate(machine: windowsMachineAmd64);
    expect(report.nativeFiles, 6);
    expect(report.unsigned, contains('reclash.exe'));
  });

  test(
    'missing runtime, wrong architecture and missing export fail closed',
    () {
      for (final replacement in [
        null,
        _pe(machine: windowsMachineArm64, exports: {'run': null}),
        _pe(exports: {'other': null}),
      ]) {
        final files = _bundle();
        files.remove('msvcp140.dll');
        if (replacement != null) files['msvcp140.dll'] = replacement;
        expect(() => validate(files), throwsFormatException);
      }
    },
  );

  test('delay-loaded runtime is mandatory too', () {
    final files = _bundle(delay: true);
    validate(files);
    files.remove('msvcp140.dll');
    expect(() => validate(files), throwsFormatException);
  });

  test('follows forwarded exports and rejects cycles or missing targets', () {
    final files = _bundle();
    files['msvcp140.dll'] = _pe(exports: {'run': 'other.#1'});
    files['other.dll'] = _pe(exports: {'target': null});
    validate(files);
    files['other.dll'] = _pe(exports: {'target': 'msvcp140.run'});
    expect(() => validate(files), throwsFormatException);
    files.remove('other.dll');
    expect(() => validate(files), throwsFormatException);
  });

  test('requires correct Core manifest and assets', () {
    final files = _bundle();
    files['ReClashCore.exe'] = _pe(machine: windowsMachineArm64);
    expect(() => validate(files), throwsFormatException);
    final missing = _bundle()..remove('data/app.so');
    expect(() => validate(missing), throwsFormatException);
  });

  test(
    'does not confuse unused or standalone auxiliary architectures with imports',
    () {
      final files = _bundle();
      files['EnableLoopback.exe'] = _pe(machine: 0x14c);
      files['unused.dll'] = _pe(machine: windowsMachineArm64);
      validate(files);
    },
  );

  test('rejects helper in any subdirectory and unsigned required payload', () {
    final files = _bundle();
    expect(() => validate(files, signed: true), throwsFormatException);
    files['nested/ReClashHelperService.exe'] = _pe();
    expect(() => validate(files), throwsFormatException);
  });

  test('rejects malformed PE and truncated import tables', () {
    expect(() => PeImage(Uint8List(4)), throwsFormatException);
    final bytes = _pe(imports: [const PeImport('msvcp140.dll', name: 'run')]);
    ByteData.sublistView(bytes).setUint32(0x10c + 8, 1, Endian.little);
    expect(() => PeImage(bytes).imports.toList(), throwsFormatException);
  });

  test('rejects unsafe Windows paths, aliases and case collisions', () {
    for (final path in [
      '../evil.dll',
      '/evil.dll',
      'C:\\evil.dll',
      'dir/../evil.dll',
      'file:stream',
      'NUL.dll',
      'file.',
    ]) {
      expect(() => windowsBundlePath(path), throwsFormatException);
    }
    expect(
      () => WindowsBundle({'a.dll': _pe(), 'A.DLL': _pe()}),
      throwsFormatException,
    );
  });

  test('validates final ZIP bytes and rejects traversal before extraction', () {
    final dir = Directory.systemTemp.createTempSync('windows-bundle-test-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final archive = Archive();
    for (final entry in _bundle().entries) {
      archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
    }
    final zip = File('${dir.path}/bundle.zip')
      ..writeAsBytesSync(ZipEncoder().encode(archive));
    WindowsBundle.zip(zip).validate(machine: windowsMachineAmd64);
    archive.addFile(ArchiveFile('../outside', 1, [1]));
    zip.writeAsBytesSync(ZipEncoder().encode(archive));
    expect(() => WindowsBundle.zip(zip), throwsFormatException);
  });
}
