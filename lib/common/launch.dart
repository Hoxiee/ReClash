import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../enum/enum.dart';
import 'constant.dart';
import 'launch_linux.dart';
import 'print.dart';
import 'system.dart';

/// One platform's login-item registration.
abstract class AutoLaunchBackend {
  Future<bool> isEnabled();

  Future<bool> enable();

  Future<bool> disable();

  /// Whether the desktop session's own startup editor turned our entry off.
  /// Backends that cannot tell that apart from a missing entry return false.
  Future<bool> isSessionDisabled() async => false;
}

class _LaunchAtStartupBackend extends AutoLaunchBackend {
  _LaunchAtStartupBackend() {
    AutoLaunch.launcher.setup(
      appName: appName,
      appPath: AutoLaunch.resolveLaunchAppPath(),
      packageName: packageName,
    );
  }

  @override
  Future<bool> isEnabled() => AutoLaunch.launcher.isEnabled();

  @override
  Future<bool> enable() => AutoLaunch.launcher.enable();

  @override
  Future<bool> disable() => AutoLaunch.launcher.disable();
}

class _XdgBackend extends AutoLaunchBackend {
  _XdgBackend(this._xdg);

  final XdgAutostart _xdg;
  bool _reported = false;

  @override
  Future<bool> isEnabled() => _xdg.isEnabled();

  @override
  Future<bool> isSessionDisabled() => _xdg.isSessionDisabled();

  @override
  Future<bool> enable() async {
    final enabled = await _xdg.enable();
    _report(enabled);
    return enabled;
  }

  @override
  Future<bool> disable() async {
    final disabled = await _xdg.disable();
    _report(disabled);
    return disabled;
  }

  void _report(bool succeeded) {
    if (succeeded || _reported) return;
    _reported = true;
    commonPrint.log(
      'autostart is unavailable: '
      '${_xdg.lastError ?? _xdg.unsupportedReason ?? 'unknown reason'}',
      logLevel: LogLevel.warning,
    );
  }
}

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._();

  @visibleForTesting
  static LaunchAtStartup launcher = launchAtStartup;

  /// Replaced in tests so a run never writes the host's real login item.
  @visibleForTesting
  static AutoLaunchBackend backend = _createBackend();

  static AutoLaunchBackend _createBackend() {
    if (Platform.isLinux) {
      return _XdgBackend(
        XdgAutostart(executable: resolveLaunchExecutable(), appName: appName),
      );
    }
    return _LaunchAtStartupBackend();
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._();
    return _instance!;
  }

  @visibleForTesting
  static String resolveLaunchExecutable({
    String? resolvedExecutable,
    Map<String, String>? environment,
    String? platform,
  }) {
    final os = platform ?? Platform.operatingSystem;
    final env = environment ?? Platform.environment;
    final appImage = env['APPIMAGE'];
    if (os == 'linux' && appImage != null && appImage.isNotEmpty) {
      return appImage;
    }
    return resolvedExecutable ?? Platform.resolvedExecutable;
  }

  @visibleForTesting
  static String resolveLaunchAppPath({
    String? resolvedExecutable,
    Map<String, String>? environment,
    String? platform,
  }) {
    final os = platform ?? Platform.operatingSystem;
    final executable = resolveLaunchExecutable(
      resolvedExecutable: resolvedExecutable,
      environment: environment,
      platform: os,
    );
    if (os == 'windows') return '"${executable.replaceAll('"', '')}"';
    if (os == 'linux') return quoteDesktopExec(executable);
    return executable;
  }

  Future<bool> get isEnable async {
    try {
      return await backend.isEnabled();
    } catch (error) {
      _logFailure('check', error);
      return false;
    }
  }

  Future<bool> enable() async {
    try {
      await backend.enable();
    } catch (error) {
      _logFailure('enable', error);
      return false;
    }
    final enabled = await isEnable;
    if (!enabled) {
      _logFailure('enable', 'the login item is still absent or stale');
    }
    return enabled;
  }

  Future<bool> disable() async {
    try {
      await backend.disable();
    } catch (error) {
      _logFailure('disable', error);
      return false;
    }
    final enabled = await isEnable;
    if (enabled) {
      _logFailure('disable', 'the login item is still present');
    }
    return !enabled;
  }

  /// Applies the stored preference, except in a development run, where
  /// registering the running build would leave a login item pointing at it.
  Future<bool> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) return true;
    return apply(isAutoLaunch);
  }

  /// Applies the stored preference at boot, but leaves alone an entry the
  /// desktop session itself turned off, so an external disable stays off.
  Future<bool> reconcile(bool isAutoLaunch) async {
    if (kDebugMode) return true;
    return apply(isAutoLaunch, respectSessionDisable: true);
  }

  @visibleForTesting
  Future<bool> apply(
    bool isAutoLaunch, {
    bool respectSessionDisable = false,
  }) async {
    if (respectSessionDisable && isAutoLaunch) {
      try {
        if (await backend.isSessionDisabled()) return false;
      } catch (error) {
        _logFailure('inspect', error);
      }
    }
    if (await isEnable == isAutoLaunch) return true;
    final applied = isAutoLaunch ? await enable() : await disable();
    if (!applied) {
      _logFailure(
        isAutoLaunch ? 'enable' : 'disable',
        'the system rejected the change',
      );
    }
    return applied;
  }

  void _logFailure(String action, Object error) {
    commonPrint.log(
      'autostart $action failed: '
      '${error is String ? error : compactError(error)}',
      logLevel: LogLevel.warning,
    );
  }
}

final autoLaunch = system.isDesktop && !safeModeBuild ? AutoLaunch() : null;
