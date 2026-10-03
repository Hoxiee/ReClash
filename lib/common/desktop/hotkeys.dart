import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:reclash/enum/enum.dart';

import 'hotkey_export.dart';

class HotkeyPlatformState {
  const HotkeyPlatformState({
    this.systemSupported = true,
    this.applicationId,
    this.exportDirectory,
    this.exports = const {},
  });

  final bool systemSupported;
  final String? applicationId;
  final String? exportDirectory;
  final Map<HotkeyExportFormat, HotkeyExport> exports;
}

class LinuxHotkeys {
  LinuxHotkeys({
    required this.onAction,
    MethodChannel channel = const MethodChannel('com.reclash/hotkeys'),
  }) : _channel = channel;

  final void Function(HotAction) onAction;
  final MethodChannel _channel;
  final Set<void Function()> _pending = {};
  bool _disposed = false;
  bool _initialized = false;
  Future<void>? _disposing;

  Future<T> _wait<T>(Future<T> response) {
    final result = Completer<T>();
    late Timer timer;
    late void Function() cancel;
    void cleanup() {
      timer.cancel();
      _pending.remove(cancel);
    }

    void fail(Object error, StackTrace stack) {
      if (result.isCompleted) return;
      cleanup();
      result.completeError(error, stack);
    }

    cancel = () => fail(StateError('Hotkey bridge closed'), StackTrace.current);
    timer = Timer(const Duration(seconds: 2), () {
      fail(
        TimeoutException('Desktop hotkey response timed out'),
        StackTrace.current,
      );
    });
    _pending.add(cancel);
    response.then((value) {
      if (result.isCompleted) return;
      cleanup();
      result.complete(value);
    }, onError: fail);
    if (_disposed) cancel();
    return result.future;
  }

  Future<HotkeyPlatformState> initialize() async {
    _channel.setMethodCallHandler((call) async {
      if (_disposed || call.method != 'invoke') return;
      for (final action in HotAction.values) {
        if (action.desktopAction == call.arguments) {
          onAction(action);
          break;
        }
      }
    });
    final result = await _wait(
      _channel.invokeMapMethod<String, Object?>('initialize', [
        for (final action in HotAction.values) action.desktopAction,
      ]),
    );
    _initialized = true;
    final id = result?['applicationId'];
    if (id is! String || !RegExp(r'^[A-Za-z_][A-Za-z0-9_.-]*$').hasMatch(id)) {
      throw const FormatException('Invalid desktop application ID');
    }
    return HotkeyPlatformState(
      systemSupported: result?['systemSupported'] == true,
      applicationId: id,
    );
  }

  Future<List<String?>> keyNames(List<int> keyCodes) async {
    final names = await _wait(
      _channel.invokeListMethod<String?>('keyNames', keyCodes),
    );
    if (names == null || names.length != keyCodes.length) {
      throw const FormatException('Invalid desktop key names');
    }
    return names;
  }

  Future<void> setEnabled(bool enabled) {
    return _wait(_channel.invokeMethod<void>('setEnabled', enabled));
  }

  void stopListening() {
    if (_disposed) return;
    _disposed = true;
    _channel.setMethodCallHandler(null);
    for (final cancel in _pending.toList()) {
      cancel();
    }
  }

  Future<void> dispose() => _disposing ??= _dispose();

  Future<void> _dispose() async {
    stopListening();
    final response = _channel.invokeMethod<void>('dispose');
    if (!_initialized) {
      response.ignore();
      return;
    }
    try {
      await response.timeout(const Duration(seconds: 2));
    } on MissingPluginException {
      return;
    }
  }
}

Future<void> writeHotkeyExports(
  Directory directory,
  Map<HotkeyExportFormat, HotkeyExport> exports,
) async {
  await directory.create(recursive: true);
  for (final entry in exports.entries) {
    final file = File('${directory.path}/${entry.key.fileName}');
    final text = entry.value.text;
    if (await file.exists() && await file.readAsString() == text) continue;
    final staged = File('${file.path}.tmp');
    await staged.writeAsString(text, flush: true);
    await staged.rename(file.path);
  }
}
