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
    test('desktop path honors XDG_CONFIG_HOME', () {
      expect(
        linuxAutostartDesktopPath(const {
          'HOME': '/home/test',
          'XDG_CONFIG_HOME': '/home/test/.myconfig',
        }),
        '/home/test/.myconfig/autostart/ReClash.desktop',
      );
    });

    test('desktop path falls back to HOME/.config', () {
      expect(
        linuxAutostartDesktopPath(const {'HOME': '/home/test'}),
        '/home/test/.config/autostart/ReClash.desktop',
      );
    });

    test('desktop path is empty without a base dir', () {
      expect(linuxAutostartDesktopPath(const {}), isEmpty);
    });

    test('entry quotes the Exec path', () {
      final entry = buildLinuxAutostartEntry(
        appPath: '/home/My Apps/ReClash.AppImage',
      );
      expect(entry, contains('Exec="/home/My Apps/ReClash.AppImage"'));
      expect(entry, contains('X-GNOME-Autostart-enabled=true'));
    });

    test('Exec escaping mirrors the url-handler rules', () {
      expect(
        quoteLinuxExecArgument(r'/a b/$x`y"z\w%v'),
        r'/a b/\$x\`y\"z\\w%%v',
      );
    });
  });

  group('linux autostart filesystem', () {
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

    test('enabled reflects the file presence', () {
      expect(linuxAutostartEnabled(env()), isFalse);
      expect(
        writeLinuxAutostartEntry(appPath: '/opt/reclash', environment: env()),
        isTrue,
      );
      expect(linuxAutostartEnabled(env()), isTrue);
    });

    test('write produces the canonical entry', () {
      writeLinuxAutostartEntry(appPath: '/opt/reclash', environment: env());
      final contents = File(
        linuxAutostartDesktopPath(env()),
      ).readAsStringSync();
      expect(contents, buildLinuxAutostartEntry(appPath: '/opt/reclash'));
    });

    test('write rewrites a stale mount path', () {
      final file = File(linuxAutostartDesktopPath(env()));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        buildLinuxAutostartEntry(appPath: '/tmp/.mount_OLD/usr/bin/ReClash'),
      );
      writeLinuxAutostartEntry(
        appPath: '/home/test/Applications/ReClash.AppImage',
        environment: env(),
      );
      expect(
        file.readAsStringSync(),
        contains('Exec="/home/test/Applications/ReClash.AppImage"'),
      );
    });

    test('remove deletes the entry', () {
      writeLinuxAutostartEntry(appPath: '/opt/reclash', environment: env());
      expect(removeLinuxAutostartEntry(env()), isTrue);
      expect(linuxAutostartEnabled(env()), isFalse);
    });

    test('remove on a missing entry still succeeds', () {
      expect(removeLinuxAutostartEntry(env()), isTrue);
    });
  });
}
