import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';

import 'constant.dart';
import 'system.dart';
import 'windows_task.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    launcher.setup(appName: appName, appPath: Platform.resolvedExecutable);
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

  Future<void> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) {
      return;
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

final autoLaunch = system.isDesktop ? AutoLaunch() : null;
