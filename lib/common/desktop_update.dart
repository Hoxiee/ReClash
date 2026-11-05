import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/common/app_update.dart';
import 'package:win32/win32.dart' as win32;

typedef ProcessStarter =
    Future<void> Function(String executable, List<String> arguments);

abstract interface class DesktopUpdater {
  /// Suffix of the downloaded file, e.g. '-setup.exe'.
  String get fileSuffix;

  UpdateAsset? selectAsset(Object? assets, String tag);

  /// Starts the detached replacement. The caller exits the app right after, so
  /// this must not depend on the process surviving.
  /// [relaunch]: start the new version once it is in place.
  Future<void> launch(String path, {required bool relaunch, String? logPath});

  /// Time since the last user input, or null when the platform cannot tell.
  Duration? systemIdle();
}

DesktopUpdater? detectDesktopUpdater({
  String? operatingSystem,
  String? executable,
  Map<String, String>? environment,
  Abi? abi,
  bool Function(String path)? fileExists,
  bool Function(String directory)? writable,
  ProcessStarter? start,
}) {
  final os = operatingSystem ?? Platform.operatingSystem;
  final exe = executable ?? Platform.resolvedExecutable;
  final env = environment ?? Platform.environment;
  final currentAbi = abi ?? Abi.current();
  final exists = fileExists ?? (String path) => File(path).existsSync();
  final canWrite = writable ?? _isWritableDirectory;
  final starter = start ?? _startDetached;
  switch (os) {
    case 'windows':
      final arch = switch (currentAbi) {
        Abi.windowsX64 => 'amd64',
        Abi.windowsArm64 => 'arm64',
        _ => null,
      };
      if (arch == null) return null;
      final directory = p.windows.dirname(exe);
      if (!exists(p.windows.join(directory, 'unins000.exe'))) return null;
      if (!canWrite(directory)) return null;
      return _WindowsUpdater(arch, starter);
    case 'linux':
      if (currentAbi != Abi.linuxX64) return null;
      final image = env['APPIMAGE'];
      if (image == null || !p.posix.isAbsolute(image) || !exists(image)) {
        return null;
      }
      if (!canWrite(p.posix.dirname(image))) return null;
      return _LinuxUpdater(image, starter);
    case 'macos':
      final arch = switch (currentAbi) {
        Abi.macosArm64 => 'arm64',
        Abi.macosX64 => 'amd64',
        _ => null,
      };
      if (arch == null) return null;
      final match = RegExp(r'^(.+\.app)/Contents/MacOS/[^/]+$').firstMatch(exe);
      if (match == null) return null;
      final bundle = match.group(1)!;
      if (!canWrite(p.posix.dirname(bundle)) || !canWrite(bundle)) return null;
      return _MacUpdater(bundle, arch, starter);
  }
  return null;
}

bool _isWritableDirectory(String directory) {
  try {
    Directory(directory).createTempSync('.reclash-write-').deleteSync();
    return true;
  } on FileSystemException {
    return false;
  }
}

Future<void> _startDetached(String executable, List<String> arguments) async {
  await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.detached,
    runInShell: false,
  );
}

UpdateAsset? _selectNamedAsset(Object? assets, String expected) {
  if (assets is! List) return null;
  final wanted = expected.toLowerCase();
  for (final raw in assets) {
    if (raw is! Map) continue;
    final name = raw['name'];
    final url = raw['browser_download_url'];
    if (name is! String || url is! String) continue;
    if (name.toLowerCase() != wanted) continue;
    final sha256 = parseAssetSha256(raw['digest']);
    if (sha256 == null) return null;
    final size = raw['size'];
    return UpdateAsset(
      name: name,
      url: url,
      size: size is int ? size : null,
      sha256: sha256,
    );
  }
  return null;
}

String _versionOf(String tag) =>
    tag.startsWith('v') || tag.startsWith('V') ? tag.substring(1) : tag;

class _WindowsUpdater implements DesktopUpdater {
  _WindowsUpdater(this._arch, this._start);

  final String _arch;
  final ProcessStarter _start;

  @override
  String get fileSuffix => '-setup.exe';

  @override
  UpdateAsset? selectAsset(Object? assets, String tag) => _selectNamedAsset(
    assets,
    'ReClash-${_versionOf(tag)}-windows-$_arch$fileSuffix',
  );

  @override
  Future<void> launch(String path, {required bool relaunch, String? logPath}) =>
      _start(path, [
        '/VERYSILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
        '/SP-',
        '/WAITPID=$pid',
        if (relaunch) '/RELAUNCH',
        if (logPath != null) '/LOG=$logPath',
      ]);

  @override
  Duration? systemIdle() {
    try {
      return using((arena) {
        final info = arena<win32.LASTINPUTINFO>();
        info.ref.cbSize = sizeOf<win32.LASTINPUTINFO>();
        if (!win32.GetLastInputInfo(info)) return null;
        final elapsed = (win32.GetTickCount() - info.ref.dwTime) & 0xFFFFFFFF;
        return Duration(milliseconds: elapsed);
      });
    } catch (_) {
      return null;
    }
  }
}

class _LinuxUpdater implements DesktopUpdater {
  _LinuxUpdater(this._target, this._start);

  final String _target;
  final ProcessStarter _start;

  @override
  String get fileSuffix => '.AppImage';

  @override
  UpdateAsset? selectAsset(Object? assets, String tag) => _selectNamedAsset(
    assets,
    'ReClash-${_versionOf(tag)}-linux-amd64$fileSuffix',
  );

  @override
  Future<void> launch(String path, {required bool relaunch, String? logPath}) =>
      _start('/bin/sh', [
        '-c',
        linuxUpdateScript,
        'reclash-update',
        '$pid',
        path,
        _target,
        relaunch ? '1' : '0',
        logPath ?? '',
      ]);

  @override
  Duration? systemIdle() => null;
}

class _MacUpdater implements DesktopUpdater {
  _MacUpdater(this._bundle, this._arch, this._start);

  final String _bundle;
  final String _arch;
  final ProcessStarter _start;

  @override
  String get fileSuffix => '.dmg';

  @override
  UpdateAsset? selectAsset(Object? assets, String tag) => _selectNamedAsset(
    assets,
    'ReClash-${_versionOf(tag)}-macos-$_arch$fileSuffix',
  );

  @override
  Future<void> launch(String path, {required bool relaunch, String? logPath}) =>
      _start('/bin/sh', [
        '-c',
        macosUpdateScript,
        'reclash-update',
        '$pid',
        path,
        _bundle,
        relaunch ? '1' : '0',
        logPath ?? '',
      ]);

  @override
  Duration? systemIdle() {
    try {
      final lookup =
          DynamicLibrary.open(
            '/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics',
          ).lookupFunction<
            Double Function(Int32, Uint32),
            double Function(int, int)
          >('CGEventSourceSecondsSinceLastEventType');
      // kCGEventSourceStateCombinedSessionState, kCGAnyInputEventType.
      final seconds = lookup(0, 0xFFFFFFFF);
      if (seconds.isNaN || seconds < 0) return null;
      return Duration(microseconds: (seconds * 1e6).round());
    } catch (_) {
      return null;
    }
  }
}

/// Arguments: pid, new AppImage, target AppImage, relaunch (0|1), log path.
@visibleForTesting
const String linuxUpdateScript = r'''
set -u
pid=$1; new=$2; target=$3; relaunch=$4; log=${5:-}
[ -n "$log" ] || log=/dev/null
exec >>"$log" 2>&1
tries=0
while kill -0 "$pid" 2>/dev/null; do
  tries=$((tries + 1))
  [ "$tries" -gt 300 ] && exit 0
  sleep 0.2
done
if cp "$new" "$target.update" && chmod 755 "$target.update" \
    && mv -f "$target.update" "$target"; then
  rm -f "$new"
else
  rm -f "$target.update"
fi
if [ "$relaunch" = 1 ]; then
  nohup "$target" >/dev/null 2>&1 &
fi
''';

/// Arguments: pid, downloaded dmg, app bundle, relaunch (0|1), log path.
@visibleForTesting
const String macosUpdateScript = r'''
set -u
pid=$1; dmg=$2; bundle=$3; relaunch=$4; log=${5:-}
[ -n "$log" ] || log=/dev/null
exec >>"$log" 2>&1
mnt=
cleanup() {
  if [ -n "$mnt" ]; then
    hdiutil detach "$mnt" -force >/dev/null 2>&1
    rmdir "$mnt" 2>/dev/null
    mnt=
  fi
  rm -rf "$bundle.update"
}
trap cleanup EXIT
tries=0
while kill -0 "$pid" 2>/dev/null; do
  tries=$((tries + 1))
  [ "$tries" -gt 300 ] && exit 0
  sleep 0.2
done
replace() {
  mnt=$(mktemp -d "${TMPDIR:-/tmp}/reclash-update.XXXXXX") || { mnt=; return 1; }
  hdiutil attach -nobrowse -readonly -noverify -mountpoint "$mnt" "$dmg" \
    >/dev/null || return 1
  app=; count=0
  for candidate in "$mnt"/*.app; do
    [ -d "$candidate" ] || continue
    app=$candidate
    count=$((count + 1))
  done
  [ "$count" -eq 1 ] || return 1
  rm -rf "$bundle.update"
  ditto "$app" "$bundle.update" || return 1
  codesign --verify --deep --strict "$bundle.update" || return 1
  rm -rf "$bundle.old"
  mv "$bundle" "$bundle.old" || return 1
  if ! mv "$bundle.update" "$bundle"; then
    mv "$bundle.old" "$bundle"
    return 1
  fi
  rm -rf "$bundle.old"
}
if replace; then
  rm -f "$dmg"
fi
cleanup
if [ "$relaunch" = 1 ]; then
  open "$bundle"
fi
''';
