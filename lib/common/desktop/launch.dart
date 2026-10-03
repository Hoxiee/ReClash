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

  Future<void> _repairLinuxAutostartIfStale() async {
    if (isLinuxAutostartExecStale(
      expectedAppPath: resolveLaunchAppPath(),
      environment: Platform.environment,
    )) {
      await enable();
    }
  }

  Future<void> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) {
      return;
    }
    if (system.isLinux && isAutoLaunch) {
      await _repairLinuxAutostartIfStale();
    }
    final target = resolveLaunchMechanism(
      isWindows: system.isWindows,
      autoLaunch: isAutoLaunch,
      highPriority: readHighPriority(),
    );
    if (system.isWindows) {
      final wantsTask = target == AutoLaunchMechanism.scheduledTask;
      if (await isHighPriorityEnable != wantsTask) {
        await (wantsTask ? enableHighPriority() : disableHighPriority());
      }
    }
    final wantsRunKey = target == AutoLaunchMechanism.runKey;
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
  return '${environment['HOME'] ?? ''}/.config/autostart/$appName.desktop';
}

@visibleForTesting
bool isLinuxAutostartExecCurrent({
  required String fileContents,
  required String expectedAppPath,
}) {
  final execLines = fileContents
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.startsWith('Exec='));
  if (execLines.isEmpty) {
    return false;
  }
  final value = execLines.first.substring('Exec='.length).trim();
  if (value == expectedAppPath) {
    return true;
  }
  if (value.startsWith('"')) {
    final end = value.indexOf('"', 1);
    return end != -1 && value.substring(1, end) == expectedAppPath;
  }
  return value.split(RegExp(r'\s+')).first == expectedAppPath;
}

@visibleForTesting
bool isLinuxAutostartExecStale({
  required String expectedAppPath,
  required Map<String, String> environment,
}) {
  final file = File(linuxAutostartDesktopPath(environment));
  if (!file.existsSync()) {
    return false;
  }
  String contents;
  try {
    contents = file.readAsStringSync();
  } catch (_) {
    return false;
  }
  return !isLinuxAutostartExecCurrent(
    fileContents: contents,
    expectedAppPath: expectedAppPath,
  );
}
