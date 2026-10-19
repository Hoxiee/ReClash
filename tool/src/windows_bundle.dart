import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'pe_image.dart';

const windowsMachineAmd64 = 0x8664;
const windowsMachineArm64 = 0xaa64;
const _nativeRoots = [
  'reclash.exe',
  'reclashcore.exe',
  'flutter_windows.dll',
  'rust_api.dll',
  'sqlite3.dll',
];
const _systemLibraries = {
  'advapi32.dll',
  'avrt.dll',
  'bcrypt.dll',
  'bcryptprimitives.dll',
  'cfgmgr32.dll',
  'combase.dll',
  'comctl32.dll',
  'comdlg32.dll',
  'credui.dll',
  'crypt32.dll',
  'd2d1.dll',
  'd3d9.dll',
  'd3d11.dll',
  'd3d12.dll',
  'd3dcompiler_47.dll',
  'dbghelp.dll',
  'dcomp.dll',
  'dnsapi.dll',
  'dwmapi.dll',
  'dwrite.dll',
  'dxgi.dll',
  'gdi32.dll',
  'hid.dll',
  'imm32.dll',
  'iphlpapi.dll',
  'kernel32.dll',
  'ksuser.dll',
  'mf.dll',
  'mfplat.dll',
  'mfreadwrite.dll',
  'mfuuid.dll',
  'msacm32.dll',
  'msimg32.dll',
  'msvcrt.dll',
  'ncrypt.dll',
  'netapi32.dll',
  'normaliz.dll',
  'ntdll.dll',
  'ole32.dll',
  'oleacc.dll',
  'oleaut32.dll',
  'opengl32.dll',
  'powrprof.dll',
  'propsys.dll',
  'psapi.dll',
  'rasapi32.dll',
  'rpcrt4.dll',
  'secur32.dll',
  'setupapi.dll',
  'shell32.dll',
  'shcore.dll',
  'shlwapi.dll',
  'synchronization.dll',
  'ucrtbase.dll',
  'urlmon.dll',
  'uiautomationcore.dll',
  'user32.dll',
  'userenv.dll',
  'usp10.dll',
  'uxtheme.dll',
  'version.dll',
  'wevtapi.dll',
  'windowsapp.dll',
  'windowscodecs.dll',
  'winhttp.dll',
  'wininet.dll',
  'winmm.dll',
  'winspool.drv',
  'wintrust.dll',
  'wlanapi.dll',
  'wldap32.dll',
  'ws2_32.dll',
  'wtsapi32.dll',
};

bool _isSystemLibrary(String name) =>
    _systemLibraries.contains(name) ||
    name.startsWith('api-ms-win-') && name.endsWith('.dll') ||
    name.startsWith('ext-ms-win-') && name.endsWith('.dll');

String windowsBundlePath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final parts = normalized.split('/');
  if (parts.isEmpty ||
      parts.any(
        (part) =>
            part.isEmpty ||
            part == '.' ||
            part == '..' ||
            part.endsWith('.') ||
            part.endsWith(' ') ||
            RegExp(r'[<>:"|?*\x00-\x1f]').hasMatch(part) ||
            RegExp(
              r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)',
              caseSensitive: false,
            ).hasMatch(part),
      )) {
    throw FormatException('Unsafe Windows bundle path: $path');
  }
  return normalized.toLowerCase();
}

final class WindowsBundle {
  final Map<String, Uint8List> files;

  WindowsBundle(Map<String, Uint8List> input) : files = {} {
    for (final entry in input.entries) {
      final key = windowsBundlePath(entry.key);
      if (files.containsKey(key)) {
        throw FormatException('Duplicate Windows path: $key');
      }
      files[key] = entry.value;
    }
  }

  factory WindowsBundle.directory(Directory directory) {
    final files = <String, Uint8List>{};
    for (final entity in directory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is Link) {
        throw FormatException('Bundle contains a link: ${entity.path}');
      }
      if (entity is File) {
        files[p.relative(entity.path, from: directory.path)] = entity
            .readAsBytesSync();
      }
    }
    return WindowsBundle(files);
  }

  factory WindowsBundle.zip(File file) {
    final archive = ZipDecoder().decodeBytes(
      file.readAsBytesSync(),
      verify: true,
    );
    final files = <String, Uint8List>{};
    var total = 0;
    for (final entry in archive) {
      if (entry.isSymbolicLink) {
        throw FormatException('ZIP contains a link: ${entry.name}');
      }
      final name = entry.isFile
          ? entry.name
          : entry.name.replaceFirst(RegExp(r'[/\\]+$'), '');
      final key = windowsBundlePath(name);
      if (!entry.isFile) continue;
      total += entry.size;
      if (total > 1024 * 1024 * 1024) {
        throw const FormatException('Windows bundle exceeds 1 GiB');
      }
      if (files.containsKey(key)) {
        throw FormatException('Duplicate ZIP path: ${entry.name}');
      }
      final bytes = entry.readBytes();
      if (bytes == null || bytes.length != entry.size) {
        throw FormatException('Unreadable ZIP entry: ${entry.name}');
      }
      files[key] = bytes;
    }
    return WindowsBundle(files);
  }

  Uint8List require(String path) {
    final bytes = files[path.toLowerCase()];
    if (bytes == null || bytes.isEmpty) {
      throw FormatException('Missing or empty Windows file: $path');
    }
    return bytes;
  }

  Map<String, String> get hashes => {
    for (final entry in files.entries)
      entry.key: sha256.convert(entry.value).toString(),
  };

  WindowsBundleReport validate({
    required int machine,
    bool requireSigned = false,
  }) {
    for (final path in files.keys) {
      final name = path.split('/').last;
      if (name == 'reclashhelperservice.exe' ||
          name == 'flclashhelperservice.exe') {
        throw FormatException(
          'Unauthenticated Windows Helper must not be shipped: $path',
        );
      }
    }
    require('flutter_windows.dll');
    require('data/icudtl.dat');
    require('data/app.so');
    require('data/flutter_assets/AssetManifest.bin');
    final manifest = jsonDecode(utf8.decode(require('manifest.json')));
    final actualHash = sha256.convert(require('reclashcore.exe')).toString();
    if (manifest is! Map || manifest['coreSha256'] != actualHash) {
      throw const FormatException(
        'Core manifest SHA256 does not match the packaged Core',
      );
    }
    final images = <String, PeImage>{};
    final pending = [..._nativeRoots];
    final checked = <String>{};
    var imports = 0;

    PeImage image(String name) {
      final pe = images.putIfAbsent(name, () => PeImage(require(name)));
      if (pe.machine != machine) {
        throw FormatException('Wrong PE architecture: $name');
      }
      return pe;
    }

    void resolve(PeImport symbol, Set<String> chain) {
      if (_isSystemLibrary(symbol.library) &&
          !files.containsKey(symbol.library)) {
        return;
      }
      final id = '${symbol.library}!${symbol.symbol}';
      if (!chain.add(id)) throw FormatException('Cyclic PE forwarder: $id');
      final dependency = image(symbol.library);
      final exported = dependency.resolve(symbol);
      if (exported == null) throw FormatException('Missing PE export: $id');
      pending.add(symbol.library);
      final forwarder = exported.forwarder;
      if (forwarder == null) return;
      final dot = forwarder.lastIndexOf('.');
      if (dot <= 0 || dot == forwarder.length - 1) {
        throw FormatException('Invalid PE forwarder: $id');
      }
      var library = forwarder.substring(0, dot).toLowerCase();
      if (!library.endsWith('.dll')) library = '$library.dll';
      final target = forwarder.substring(dot + 1);
      final ordinal = target.startsWith('#')
          ? int.tryParse(target.substring(1))
          : null;
      if (target.startsWith('#') && ordinal == null) {
        throw FormatException('Invalid forwarded ordinal: $id');
      }
      resolve(
        PeImport(
          library,
          name: ordinal == null ? target : null,
          ordinal: ordinal,
        ),
        chain,
      );
    }

    while (pending.isNotEmpty) {
      final name = pending.removeLast();
      if (!checked.add(name)) continue;
      final pe = image(name);
      for (final symbol in pe.imports) {
        imports++;
        resolve(symbol, {});
      }
    }
    final unsigned = [
      for (final name in ['reclash.exe', 'reclashcore.exe', 'rust_api.dll'])
        if (!image(name).hasCertificate) name,
    ];
    if (requireSigned && unsigned.isNotEmpty) {
      throw FormatException(
        'Missing Authenticode certificate: ${unsigned.join(', ')}',
      );
    }
    return WindowsBundleReport(checked.length, imports, unsigned);
  }
}

final class WindowsBundleReport {
  final int nativeFiles;
  final int imports;
  final List<String> unsigned;

  const WindowsBundleReport(this.nativeFiles, this.imports, this.unsigned);

  @override
  String toString() =>
      '$nativeFiles reachable native files, $imports imports; '
      '${unsigned.isEmpty ? 'embedded certificates present (trust requires Windows verification)' : 'unsigned: ${unsigned.join(', ')}'}';
}

int windowsMachine(String arch) => switch (arch) {
  'amd64' || 'x64' => windowsMachineAmd64,
  'arm64' => windowsMachineArm64,
  _ => throw ArgumentError.value(arch, 'arch', 'Expected amd64 or arm64'),
};
