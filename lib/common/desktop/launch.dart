import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';

import '../util/constant.dart';
import 'system.dart';
import 'windows_task.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    launcher.setup(appName: appName, appPath: resolveLaunchAppPath());
  }

  @visibleForTesting
  static String resolveLaunchAppPath({
    String? resolvedExecutable,
    Map<String, String>? environment,
  }) {
    // Under AppImage the resolved executable lives in the ephemeral FUSE
    // mount; $APPIMAGE is the stable path on disk.
    final env = environment ?? Platform.environment;
    final appImage = (env['APPIMAGE'] ?? '').trim();
    if (appImage.isNotEmpty) {
      return appImage;
    }
    return resolvedExecutable ?? Platform.resolvedExecutable;
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  @visibleForTesting
  static LaunchAtStartup launcher = launchAtStartup;

  @visibleForTesting
  static WindowsTaskScheduler taskScheduler = WindowsTaskScheduler();

  @visibleForTesting
  static WindowsRunKey windowsRunKey = WindowsRunKey();

  @visibleForTesting
  static bool Function() readHighPriority = _readHighPriorityFromState;

  static bool _readHighPriorityFromState() {
    try {
      return globalState.container
          .read(appSettingProvider)
          .highPriorityAutoLaunch;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isEnable async {
    return launcher.isEnabled();
  }

  Future<bool> get isHighPriorityEnable async {
    if (!system.isWindows) return false;
    return taskScheduler.isRegistered(appName);
  }

  Future<bool> enable() async {
    return launcher.enable();
  }

  Future<bool> disable() async {
    return launcher.disable();
  }

  Future<bool> enableHighPriority() async {
    if (!system.isWindows) return false;
    return taskScheduler.register(appName, Platform.resolvedExecutable);
  }

  Future<bool> disableHighPriority() async {
    if (!system.isWindows) return true;
    return taskScheduler.unregister(appName);
  }

  Future<void> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) {
      return;
    }
    final target = resolveLaunchMechanism(
      isWindows: system.isWindows,
      autoLaunch: isAutoLaunch,
      highPriority: readHighPriority(),
    );
    final wantsRunKey = target == AutoLaunchMechanism.runKey;
    // Windows owns both autostart mechanisms: the scheduled task and a quoted
    // Run-key entry, which the upstream package leaves unquoted.
    if (system.isWindows) {
      final wantsTask = target == AutoLaunchMechanism.scheduledTask;
      if (await isHighPriorityEnable != wantsTask) {
        await (wantsTask ? enableHighPriority() : disableHighPriority());
      }
      final path = resolveLaunchAppPath();
      if (windowsRunKey.isEnabled(appName, path) != wantsRunKey) {
        if (wantsRunKey) {
          windowsRunKey.enable(appName, path);
        } else {
          windowsRunKey.disable(appName);
        }
      }
      return;
    }
    // Linux owns its XDG autostart entry so the Exec is quoted and the path
    // tracks $APPIMAGE on every launch; the upstream package only handles
    // macOS.
    if (system.isLinux) {
      if (wantsRunKey) {
        writeLinuxAutostartEntry(
          appPath: resolveLaunchAppPath(),
          environment: Platform.environment,
        );
      } else {
        removeLinuxAutostartEntry(Platform.environment);
      }
      return;
    }
    if (await isEnable != wantsRunKey) {
      if (wantsRunKey) {
        unawaited(enable());
      } else {
        unawaited(disable());
      }
    }
  }
}

final autoLaunch = system.isDesktop && !safeModeBuild ? AutoLaunch() : null;

@visibleForTesting
String linuxAutostartDesktopPath(Map<String, String> environment) {
  final base = linuxAutostartConfigBase(environment);
  if (base.isEmpty) {
    return '';
  }
  return '$base/autostart/$appName.desktop';
}

/// `$XDG_CONFIG_HOME`, falling back to `$HOME/.config` per the XDG base-dir
/// spec; empty when neither is set so callers can skip the write.
@visibleForTesting
String linuxAutostartConfigBase(Map<String, String> environment) {
  final configHome = environment['XDG_CONFIG_HOME']?.trim() ?? '';
  if (configHome.isNotEmpty) {
    return configHome;
  }
  final home = environment['HOME']?.trim() ?? '';
  return home.isEmpty ? '' : '$home/.config';
}

@visibleForTesting
String buildLinuxAutostartEntry({required String appPath}) {
  return [
    '[Desktop Entry]',
    'Type=Application',
    'Version=1.0',
    'Name=$appName',
    'Comment=$appName autostart',
    'Exec="${quoteLinuxExecArgument(appPath)}"',
    'Terminal=false',
    'StartupNotify=false',
    // GNOME treats a missing key as enabled; set it so re-enabling from the
    // app overrides a prior opt-out in gnome-session.
    'X-GNOME-Autostart-enabled=true',
    '',
  ].join('\n');
}

/// Escapes the reserved characters a double-quoted Exec value may carry, the
/// same way the url-handler entry does, so paths with spaces survive.
@visibleForTesting
String quoteLinuxExecArgument(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll(r'$', r'\$')
      .replaceAll('`', r'\`')
      .replaceAll('%', '%%');
}

@visibleForTesting
bool linuxAutostartEnabled(Map<String, String> environment) {
  final path = linuxAutostartDesktopPath(environment);
  return path.isNotEmpty && File(path).existsSync();
}

/// Writes the canonical entry, skipping the write when the file already matches
/// so a stale mount path or an older format is repaired without churn.
@visibleForTesting
bool writeLinuxAutostartEntry({
  required String appPath,
  required Map<String, String> environment,
}) {
  final path = linuxAutostartDesktopPath(environment);
  if (path.isEmpty) {
    return false;
  }
  final file = File(path);
  final desired = buildLinuxAutostartEntry(appPath: appPath);
  try {
    if (file.existsSync() && file.readAsStringSync() == desired) {
      return true;
    }
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    file.writeAsStringSync(desired);
    return true;
  } catch (_) {
    return false;
  }
}

@visibleForTesting
bool removeLinuxAutostartEntry(Map<String, String> environment) {
  final path = linuxAutostartDesktopPath(environment);
  if (path.isEmpty) {
    return true;
  }
  final file = File(path);
  try {
    if (file.existsSync()) {
      file.deleteSync();
    }
    return true;
  } catch (_) {
    return false;
  }
}
