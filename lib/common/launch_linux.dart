import 'dart:convert';
import 'dart:io';

/// Quotes an executable path for a desktop entry `Exec` value.
String quoteDesktopExec(String executable) {
  final escaped = executable
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll(r'$', r'\$')
      .replaceAll('`', r'\`')
      .replaceAll('%', '%%');
  return '"$escaped"';
}

/// Manages the XDG autostart entry Linux sessions read at login.
///
/// Sessions that do not run an XDG autostart server still reach the entry:
/// systemd's user generator turns it into an `app-*@autostart.service`.
class XdgAutostart {
  XdgAutostart({
    required String executable,
    required this.appName,
    Map<String, String>? environment,
  }) : environment = Map.unmodifiable(environment ?? Platform.environment),
       executable = _absolutePath(executable) {
    _resolveEntry();
  }

  final String appName;
  final String executable;
  final Map<String, String> environment;

  File? _entry;
  File? _legacyEntry;
  String? _unsupportedReason;
  String? _lastError;

  bool get isSupported => _entry != null;

  String? get unsupportedReason => _unsupportedReason;

  String? get lastError => _lastError;

  String get _entryFileName => '$appName.desktop';

  String get _execValue => quoteDesktopExec(executable);

  String get _contents {
    return '''
[Desktop Entry]
Type=Application
Name=$appName
Comment=$appName startup entry
Exec=$_execValue
TryExec=$executable
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
''';
  }

  static String _absolutePath(String path) {
    if (path.startsWith('/')) return path;
    return File(path).absolute.path;
  }

  void _resolveEntry() {
    final sandbox = _sandboxReason();
    if (sandbox != null) {
      _unsupportedReason = sandbox;
      return;
    }
    if (executable.contains('\n') || executable.contains('\r')) {
      _unsupportedReason =
          'the executable path contains a line break, which an autostart '
          'entry cannot represent';
      return;
    }
    final configHome = xdgConfigHome(environment);
    if (configHome == null) {
      _unsupportedReason =
          'neither XDG_CONFIG_HOME nor HOME is an absolute path';
      return;
    }
    _entry = File('$configHome/autostart/$_entryFileName');
    final home = environment['HOME'];
    if (home != null && home.startsWith('/') && home.length > 1) {
      final legacy = File('$home/.config/autostart/$_entryFileName');
      if (legacy.path != _entry!.path) {
        _legacyEntry = legacy;
      }
    }
  }

  String? _sandboxReason() {
    final flatpak = environment['FLATPAK_ID'];
    if (flatpak != null && flatpak.isNotEmpty) {
      return 'Flatpak isolates XDG_CONFIG_HOME from the host session';
    }
    final snap = environment['SNAP_NAME'] ?? environment['SNAP'];
    if (snap != null && snap.isNotEmpty) {
      return 'Snap isolates XDG_CONFIG_HOME from the host session';
    }
    return null;
  }

  /// The autostart directory the XDG base directory spec resolves to.
  static String? xdgConfigHome(Map<String, String> environment) {
    final xdg = environment['XDG_CONFIG_HOME'];
    if (xdg != null && xdg.length > 1 && xdg.startsWith('/')) {
      return xdg;
    }
    final home = environment['HOME'];
    if (home != null && home.length > 1 && home.startsWith('/')) {
      return '$home/.config';
    }
    return null;
  }

  Future<bool> isEnabled() async {
    final entry = _entry;
    if (entry == null) return false;
    try {
      if (!await entry.exists()) return false;
      return _matches(await entry.readAsString());
    } catch (error) {
      _lastError = 'reading ${entry.path} failed: $error';
      return false;
    }
  }

  /// Whether a desktop session's startup editor disabled the entry itself,
  /// rather than the entry being missing or stale.
  Future<bool> isSessionDisabled() async {
    final entry = _entry;
    if (entry == null) return false;
    try {
      if (!await entry.exists()) return false;
      return _sessionDisabled(_parse(await entry.readAsString()));
    } catch (error) {
      _lastError = 'reading ${entry.path} failed: $error';
      return false;
    }
  }

  Future<bool> enable() async {
    final entry = _entry;
    if (entry == null) {
      _lastError = _unsupportedReason ?? 'autostart is unavailable';
      return false;
    }
    try {
      await entry.parent.create(recursive: true);
      await _write(entry);
      await _removeLegacy();
    } catch (error) {
      _lastError = 'writing ${entry.path} failed: $error';
      return false;
    }
    _lastError = null;
    return isEnabled();
  }

  Future<void> _write(File entry) async {
    final contents = _contents;
    if (await FileSystemEntity.isLink(entry.path)) {
      // Keep a home-manager or dotfile link in place; a rename would replace
      // the link with a regular file and silently detach the managed config.
      await entry.writeAsString(contents, flush: true);
      return;
    }
    final temporary = File('${entry.path}.$pid.tmp');
    try {
      await temporary.writeAsString(contents, flush: true);
      await temporary.rename(entry.path);
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }
  }

  Future<bool> disable() async {
    final entry = _entry;
    if (entry == null) return true;
    var removed = true;
    for (final file in [entry, ?_legacyEntry]) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (error) {
        removed = false;
        _lastError = 'removing ${file.path} failed: $error';
      }
    }
    if (removed) _lastError = null;
    return removed && !await isEnabled();
  }

  Future<void> _removeLegacy() async {
    final legacy = _legacyEntry;
    if (legacy == null) return;
    try {
      if (await legacy.exists()) {
        await legacy.delete();
      }
    } catch (error) {
      // A stale duplicate cannot launch anything the XDG entry already does,
      // and failing the main entry for it would leave autostart off.
      _lastError = 'removing ${legacy.path} failed: $error';
    }
  }

  bool _matches(String contents) {
    final values = _parse(contents);
    if (values['Type'] != 'Application') return false;
    if (_sessionDisabled(values)) return false;
    return values['Exec'] == _execValue;
  }

  static bool _sessionDisabled(Map<String, String> values) {
    final hidden = values['Hidden'];
    if (hidden != null && hidden.toLowerCase() == 'true') return true;
    final enabled = values['X-GNOME-Autostart-enabled'];
    return enabled != null && enabled.toLowerCase() == 'false';
  }

  static Map<String, String> _parse(String contents) {
    final values = <String, String>{};
    var inEntry = false;
    for (final rawLine in const LineSplitter().convert(contents)) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      if (line.startsWith('[') && line.endsWith(']')) {
        inEntry = line == '[Desktop Entry]';
        continue;
      }
      if (!inEntry) continue;
      final separator = line.indexOf('=');
      if (separator <= 0) continue;
      values[line.substring(0, separator).trim()] = line
          .substring(separator + 1)
          .trim();
    }
    return values;
  }
}
