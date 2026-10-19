import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'constant.dart';
import 'system.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    launcher.setup(appName: appName, appPath: resolveLaunchAppPath());
  }

  @visibleForTesting
  static String resolveLaunchAppPath({
    String? resolvedExecutable,
    Map<String, String>? environment,
    String? platform,
  }) {
    final os = platform ?? Platform.operatingSystem;
    final env = environment ?? Platform.environment;
    final executable = os == 'linux' && (env['APPIMAGE'] ?? '').isNotEmpty
        ? env['APPIMAGE']!
        : resolvedExecutable ?? Platform.resolvedExecutable;
    if (os == 'windows') return '"${executable.replaceAll('"', '')}"';
    if (os == 'linux') {
      final escaped = executable
          .replaceAll(r'\', r'\\')
          .replaceAll('"', r'\"')
          .replaceAll(r'$', r'\$')
          .replaceAll('`', r'\`')
          .replaceAll('%', '%%');
      return '"$escaped"';
    }
    return executable;
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  @visibleForTesting
  static LaunchAtStartup launcher = launchAtStartup;

  Future<bool> get isEnable async {
    return launcher.isEnabled();
  }

  Future<bool> enable() async {
    return launcher.enable();
  }

  Future<bool> disable() async {
    return launcher.disable();
  }

  Future<void> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) {
      return;
    }
    if (await isEnable == isAutoLaunch) return;
    if (isAutoLaunch == true) {
      unawaited(enable());
    } else {
      unawaited(disable());
    }
  }
}

final autoLaunch = system.isDesktop && !safeModeBuild ? AutoLaunch() : null;
