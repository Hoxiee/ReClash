import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

/// Best-effort OS icon of the process that owns a connection, for the desktop
/// connections list. Resolution can fail (unknown path, sandboxed app, SVG-only
/// theme); the caller falls back to a generic avatar, so this only ever adds an
/// icon, never removes one. Keyed by exe path / binary name so the poll re-render
/// reuses a decoded icon instead of re-extracting.
Future<ImageProvider?>? processIcon(String processPath, String process) {
  if (Platform.isWindows) {
    if (processPath.isEmpty) {
      return null;
    }
    return _winIconCache.putIfAbsent(
      processPath,
      () => _loadWindowsIcon(processPath),
    );
  }
  if (Platform.isLinux) {
    final base = processPath.isNotEmpty ? p.basename(processPath) : process;
    if (base.isEmpty) {
      return null;
    }
    return _linuxIconCache.putIfAbsent(
      base,
      () => _resolveLinuxIcon(base, process),
    );
  }
  return null;
}

final Map<String, Future<ImageProvider?>> _winIconCache = {};
final Map<String, Future<ImageProvider?>?> _linuxIconCache = {};
Future<Map<String, String>>? _desktopIndex;

Future<ImageProvider?> _resolveLinuxIcon(String binary, String process) async {
  final index = await (_desktopIndex ??= _buildDesktopIndex());
  final iconName = index[binary] ?? index[process.toLowerCase()] ?? binary;
  if (iconName.isEmpty) {
    return null;
  }
  if (iconName.startsWith('/')) {
    final file = File(iconName);
    return await file.exists() ? FileImage(file) : null;
  }
  final file = await _findIconFile(iconName);
  return file == null ? null : FileImage(file);
}

Future<Map<String, String>> _buildDesktopIndex() async {
  final index = <String, String>{};
  final home = Platform.environment['HOME'] ?? '';
  final dirs = <String>[
    if (home.isNotEmpty) '$home/.local/share/applications',
    if (home.isNotEmpty)
      '$home/.local/share/flatpak/exports/share/applications',
    '/usr/local/share/applications',
    '/usr/share/applications',
    '/var/lib/flatpak/exports/share/applications',
  ];
  for (final path in dirs) {
    final dir = Directory(path);
    if (!await dir.exists()) {
      continue;
    }
    try {
      await for (final entry in dir.list()) {
        if (entry is! File || !entry.path.endsWith('.desktop')) {
          continue;
        }
        try {
          String? exec, icon, wmClass;
          for (final line in await entry.readAsLines()) {
            if (icon == null && line.startsWith('Icon=')) {
              icon = line.substring(5).trim();
            } else if (exec == null && line.startsWith('Exec=')) {
              exec = line.substring(5).trim();
            } else if (wmClass == null && line.startsWith('StartupWMClass=')) {
              wmClass = line.substring(15).trim();
            }
          }
          if (icon == null || icon.isEmpty) {
            continue;
          }
          final bin = exec == null ? '' : _execBinary(exec);
          if (bin.isNotEmpty) {
            index.putIfAbsent(bin, () => icon!);
          }
          if (wmClass != null && wmClass.isNotEmpty) {
            index.putIfAbsent(wmClass.toLowerCase(), () => icon!);
          }
        } catch (_) {}
      }
    } catch (_) {}
  }
  return index;
}

String _execBinary(String exec) {
  for (final token in exec.split(RegExp(r'\s+'))) {
    final trimmed = token.replaceAll('"', '');
    if (trimmed.isEmpty || trimmed.startsWith('%') || trimmed.contains('=')) {
      continue;
    }
    return p.basename(trimmed);
  }
  return '';
}

Future<File?> _findIconFile(String name) async {
  final home = Platform.environment['HOME'] ?? '';
  final roots = <String>[
    if (home.isNotEmpty) '$home/.local/share/icons',
    '/usr/local/share/icons',
    '/usr/share/icons',
  ];
  const themes = ['hicolor', 'Adwaita', 'breeze', 'gnome'];
  const sizes = ['512x512', '256x256', '128x128', '96x96', '64x64', '48x48'];
  for (final root in roots) {
    for (final theme in themes) {
      for (final size in sizes) {
        final file = File('$root/$theme/$size/apps/$name.png');
        if (await file.exists()) {
          return file;
        }
      }
    }
  }
  for (final dir in ['/usr/share/pixmaps', '/usr/local/share/pixmaps']) {
    final file = File('$dir/$name.png');
    if (await file.exists()) {
      return file;
    }
  }
  return null;
}

// Win32 extraction touches the UI thread; serialize it so one list build can't
// fire a dozen extractions in a single frame, each yielding a frame after.
Future<void> _extractQueue = Future.value();

Future<ImageProvider?> _loadWindowsIcon(String exePath) {
  final completer = Completer<ImageProvider?>();
  _extractQueue = _extractQueue.then((_) async {
    try {
      final bytes = await _extractIconBytes(exePath);
      completer.complete(bytes == null ? null : MemoryImage(bytes));
    } catch (_) {
      completer.complete(null);
    }
    await Future<void>.delayed(Duration.zero);
  });
  return completer.future;
}

Future<Uint8List?> _extractIconBytes(String exePath) async {
  final pathPtr = exePath.toNativeUtf16();
  final shfi = calloc<SHFILEINFO>();
  HICON? hIcon;
  try {
    final res = SHGetFileInfo(
      PCWSTR(pathPtr),
      const FILE_FLAGS_AND_ATTRIBUTES(0),
      shfi,
      sizeOf<SHFILEINFO>(),
      SHGFI_ICON | SHGFI_LARGEICON,
    );
    if (res == 0) {
      return null;
    }
    final icon = shfi.ref.hIcon;
    if (icon == nullptr) {
      return null;
    }
    hIcon = icon;
    return await _hIconToPng(icon);
  } finally {
    if (hIcon != null && hIcon != nullptr) {
      DestroyIcon(hIcon);
    }
    free(pathPtr);
    free(shfi);
  }
}

Future<Uint8List?> _hIconToPng(HICON hIcon) async {
  final iconInfo = calloc<ICONINFO>();
  final bmp = calloc<BITMAP>();
  final bi = calloc<BITMAPINFO>();
  HBITMAP? hbmColor;
  HBITMAP? hbmMask;
  HDC? hdc;
  Pointer<Uint8>? buffer;
  try {
    if (!GetIconInfo(hIcon, iconInfo).value) {
      return null;
    }
    hbmColor = iconInfo.ref.hbmColor;
    hbmMask = iconInfo.ref.hbmMask;
    if (hbmColor == nullptr) {
      return null;
    }
    if (GetObject(HGDIOBJ(hbmColor), sizeOf<BITMAP>(), bmp.cast()) == 0) {
      return null;
    }

    final w = bmp.ref.bmWidth;
    final h = bmp.ref.bmHeight;
    if (w <= 0 || h <= 0) {
      return null;
    }

    bi.ref.bmiHeader.biSize = sizeOf<BITMAPINFOHEADER>();
    bi.ref.bmiHeader.biWidth = w;
    bi.ref.bmiHeader.biHeight = -h;
    bi.ref.bmiHeader.biPlanes = 1;
    bi.ref.bmiHeader.biBitCount = 32;
    bi.ref.bmiHeader.biCompression = BI_RGB;

    final count = w * h;
    buffer = calloc<Uint8>(count * 4);
    hdc = GetDC(null);
    final got = GetDIBits(
      hdc,
      hbmColor,
      0,
      h,
      buffer.cast(),
      bi,
      DIB_RGB_COLORS,
    );
    if (got == 0) {
      return null;
    }

    final bgra = Uint8List.fromList(buffer.asTypedList(count * 4));
    // BI_RGB leaves alpha undefined; an all-zero alpha channel would render the
    // icon fully transparent, so force it opaque in that case.
    var hasAlpha = false;
    for (var i = 3; i < bgra.length; i += 4) {
      if (bgra[i] != 0) {
        hasAlpha = true;
        break;
      }
    }
    if (!hasAlpha) {
      for (var i = 3; i < bgra.length; i += 4) {
        bgra[i] = 0xFF;
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bgra,
      w,
      h,
      ui.PixelFormat.bgra8888,
      completer.complete,
    );
    final image = await completer.future;
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return png?.buffer.asUint8List();
  } finally {
    if (hdc != null && hdc != nullptr) {
      ReleaseDC(null, hdc);
    }
    if (hbmColor != null && hbmColor != nullptr) {
      DeleteObject(HGDIOBJ(hbmColor));
    }
    if (hbmMask != null && hbmMask != nullptr) {
      DeleteObject(HGDIOBJ(hbmMask));
    }
    if (buffer != null) {
      free(buffer);
    }
    free(iconInfo);
    free(bmp);
    free(bi);
  }
}
