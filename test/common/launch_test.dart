import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:reclash/common/desktop/launch.dart';

class _FakeLauncher implements LaunchAtStartup {
  bool enabled = false;
  final calls = <String>[];

  @override
  void setup({
    required String appName,
    required String appPath,
    String? packageName,
    List<String> args = const [],
  }) {
    calls.add('setup');
  }

  @override
  Future<bool> isEnabled() async {
    calls.add('isEnabled');
    return enabled;
  }

  @override
  Future<bool> enable() async {
    calls.add('enable');
    enabled = true;
    return true;
  }

  @override
  Future<bool> disable() async {
    calls.add('disable');
    enabled = false;
    return true;
  }
}

void main() {
  late _FakeLauncher launcher;
  late AutoLaunch autoLaunch;

  setUp(() {
    launcher = _FakeLauncher();
    AutoLaunch.launcher = launcher;
    autoLaunch = AutoLaunch();
    launcher.calls.clear();
  });

  tearDownAll(() {
    AutoLaunch.launcher = launchAtStartup;
  });

  test('AutoLaunch is a singleton', () {
    expect(AutoLaunch(), same(autoLaunch));
  });

  test('each call delegates straight to the launcher', () async {
    launcher.enabled = true;
    expect(await autoLaunch.isEnable, isTrue);

    expect(await autoLaunch.disable(), isTrue);
    expect(launcher.enabled, isFalse);

    expect(await autoLaunch.enable(), isTrue);
    expect(launcher.enabled, isTrue);

    expect(launcher.calls, ['isEnabled', 'disable', 'enable']);
  });

  test('a debug build never registers autostart', () async {
    expect(
      kDebugMode,
      isTrue,
      reason: 'flutter test runs in debug; the guard below assumes it.',
    );

    await autoLaunch.updateStatus(true);
    await autoLaunch.updateStatus(false);

    expect(
      launcher.calls,
      isEmpty,
      reason:
          'updateStatus must return before reading or writing the autostart '
          'entry, or every debug run would register the running binary.',
    );
  });

  group('resolveLaunchAppPath', () {
    test('prefers APPIMAGE over the resolved executable', () {
      expect(
        AutoLaunch.resolveLaunchAppPath(
          resolvedExecutable: '/tmp/.mount_ABC123/usr/bin/ReClash',
          environment: const {
            'APPIMAGE': '/home/test/Applications/ReClash.AppImage',
          },
        ),
        '/home/test/Applications/ReClash.AppImage',
      );
    });

    test('falls back to the resolved executable without APPIMAGE', () {
      expect(
        AutoLaunch.resolveLaunchAppPath(
          resolvedExecutable: '/opt/reclash/reclash',
          environment: const {},
        ),
        '/opt/reclash/reclash',
      );
    });

    test('ignores blank APPIMAGE', () {
      expect(
        AutoLaunch.resolveLaunchAppPath(
          resolvedExecutable: '/opt/reclash/reclash',
          environment: const {'APPIMAGE': '   '},
        ),
        '/opt/reclash/reclash',
      );
    });
  });

  group('linux autostart entry', () {
    test('desktop path mirrors the upstream package location', () {
      expect(
        linuxAutostartDesktopPath(const {'HOME': '/home/test'}),
        '/home/test/.config/autostart/ReClash.desktop',
      );
    });

    test('plain Exec counts as current', () {
      expect(
        isLinuxAutostartExecCurrent(
          fileContents: '[Desktop Entry]\nExec=/opt/reclash/reclash\n',
          expectedAppPath: '/opt/reclash/reclash',
        ),
        isTrue,
      );
    });

    test('quoted Exec with arguments counts as current', () {
      expect(
        isLinuxAutostartExecCurrent(
          fileContents:
              '[Desktop Entry]\nExec="/opt/my apps/reclash" --hidden\n',
          expectedAppPath: '/opt/my apps/reclash',
        ),
        isTrue,
      );
    });

    test('stale mount Exec counts as outdated', () {
      expect(
        isLinuxAutostartExecCurrent(
          fileContents:
              '[Desktop Entry]\nExec=/tmp/.mount_ABC123/usr/bin/ReClash\n',
          expectedAppPath: '/home/test/Applications/ReClash.AppImage',
        ),
        isFalse,
      );
    });

    test('missing Exec counts as outdated', () {
      expect(
        isLinuxAutostartExecCurrent(
          fileContents: '[Desktop Entry]\nName=ReClash\n',
          expectedAppPath: '/opt/reclash/reclash',
        ),
        isFalse,
      );
    });
  });

  group('isLinuxAutostartExecStale', () {
    late Directory home;

    setUp(() {
      home = Directory.systemTemp.createTempSync('reclash_autostart_test');
    });

    tearDown(() {
      if (home.existsSync()) {
        home.deleteSync(recursive: true);
      }
    });

    Map<String, String> env() => {'HOME': home.path};

    void writeDesktop(String contents) {
      final file = File(linuxAutostartDesktopPath(env()));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(contents);
    }

    test('missing entry is not stale', () {
      expect(
        isLinuxAutostartExecStale(
          expectedAppPath: '/opt/reclash/reclash',
          environment: env(),
        ),
        isFalse,
      );
    });

    test('matching entry is not stale', () {
      writeDesktop('[Desktop Entry]\nExec=/opt/reclash/reclash\n');
      expect(
        isLinuxAutostartExecStale(
          expectedAppPath: '/opt/reclash/reclash',
          environment: env(),
        ),
        isFalse,
      );
    });

    test('entry from an old mount is stale', () {
      writeDesktop('[Desktop Entry]\nExec=/tmp/.mount_OLD/usr/bin/ReClash\n');
      expect(
        isLinuxAutostartExecStale(
          expectedAppPath: '/home/test/Applications/ReClash.AppImage',
          environment: env(),
        ),
        isTrue,
      );
    });
  });
}
