import 'dart:io';

import 'package:reclash/common/launch.dart';
import 'package:reclash/common/launch_linux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBackend extends AutoLaunchBackend {
  bool enabled = false;
  bool failEnable = false;
  bool failDisable = false;
  bool sessionDisabled = false;
  final calls = <String>[];

  @override
  Future<bool> isEnabled() async {
    calls.add('isEnabled');
    return enabled;
  }

  @override
  Future<bool> isSessionDisabled() async {
    calls.add('isSessionDisabled');
    return sessionDisabled;
  }

  @override
  Future<bool> enable() async {
    calls.add('enable');
    if (failEnable) return false;
    enabled = true;
    return true;
  }

  @override
  Future<bool> disable() async {
    calls.add('disable');
    if (failDisable) return false;
    enabled = false;
    return true;
  }
}

class _XdgFixture {
  _XdgFixture({
    Map<String, String>? environment,
    String executable = '/opt/ReClash/ReClash',
  }) : root = Directory.systemTemp.createTempSync('reclash-autostart-') {
    addTearDown(() {
      if (root.existsSync()) root.deleteSync(recursive: true);
    });
    final env = environment ?? {'HOME': root.path};
    autostart = XdgAutostart(
      executable: executable,
      appName: 'ReClash',
      environment: env,
    );
  }

  final Directory root;
  late final XdgAutostart autostart;

  File entry(Map<String, String> environment) {
    final configHome = XdgAutostart.xdgConfigHome(environment)!;
    return File('$configHome/autostart/ReClash.desktop');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeBackend backend;
  late AutoLaunch autoLaunch;
  late AutoLaunchBackend originalBackend;

  setUpAll(() {
    originalBackend = AutoLaunch.backend;
  });

  setUp(() {
    backend = _FakeBackend();
    AutoLaunch.backend = backend;
    autoLaunch = AutoLaunch();
    backend.calls.clear();
  });

  tearDown(() {
    AutoLaunch.backend = originalBackend;
  });

  test('autostart quotes the stable AppImage rather than its mount', () {
    expect(
      AutoLaunch.resolveLaunchExecutable(
        platform: 'linux',
        environment: {'APPIMAGE': '/home/a b/ReClash.AppImage'},
        resolvedExecutable: '/tmp/.mount/random/ReClash',
      ),
      '/home/a b/ReClash.AppImage',
    );
    expect(
      AutoLaunch.resolveLaunchAppPath(
        platform: 'linux',
        environment: {'APPIMAGE': '/home/a b/ReClash.AppImage'},
        resolvedExecutable: '/tmp/.mount/random/ReClash',
      ),
      '"/home/a b/ReClash.AppImage"',
    );
    expect(
      AutoLaunch.resolveLaunchAppPath(
        platform: 'windows',
        environment: {},
        resolvedExecutable: r'C:\Program Files\ReClash\ReClash.exe',
      ),
      r'"C:\Program Files\ReClash\ReClash.exe"',
    );
  });

  test('desktop Exec escapes field codes and metacharacters', () {
    expect(
      AutoLaunch.resolveLaunchAppPath(
        platform: 'linux',
        environment: {},
        resolvedExecutable: r'/home/a/%$b/ReClash',
      ),
      r'"/home/a/%%\$b/ReClash"',
    );
    expect(
      quoteDesktopExec(r'/home/a/"b`c\d/ReClash'),
      r'"/home/a/\"b\`c\\d/ReClash"',
    );
  });

  test('AutoLaunch is a singleton', () {
    expect(AutoLaunch(), same(autoLaunch));
  });

  test('each call verifies the backend result', () async {
    backend.enabled = true;
    expect(await autoLaunch.isEnable, isTrue);

    expect(await autoLaunch.disable(), isTrue);
    expect(backend.enabled, isFalse);

    expect(await autoLaunch.enable(), isTrue);
    expect(backend.enabled, isTrue);

    expect(backend.calls, [
      'isEnabled',
      'disable',
      'isEnabled',
      'enable',
      'isEnabled',
    ]);
  });

  test('a debug build never registers autostart', () async {
    expect(
      kDebugMode,
      isTrue,
      reason: 'flutter test runs in debug; the guard below assumes it.',
    );

    expect(await autoLaunch.updateStatus(true), isTrue);
    expect(await autoLaunch.updateStatus(false), isTrue);

    expect(
      backend.calls,
      isEmpty,
      reason:
          'updateStatus must return before reading or writing the autostart '
          'entry, or every debug run would register the running binary.',
    );
  });

  test('apply enables, checks and reports a refused change', () async {
    expect(await autoLaunch.apply(true), isTrue);
    expect(backend.enabled, isTrue);
    expect(backend.calls, ['isEnabled', 'enable', 'isEnabled']);

    backend.calls.clear();
    backend.failEnable = true;
    backend.enabled = false;
    expect(await autoLaunch.apply(true), isFalse);
    expect(backend.enabled, isFalse);
  });

  test('apply disables and reports a login item that survived', () async {
    backend.enabled = true;
    expect(await autoLaunch.apply(false), isTrue);
    expect(backend.enabled, isFalse);

    backend.calls.clear();
    backend.enabled = true;
    backend.failDisable = true;
    expect(await autoLaunch.apply(false), isFalse);
    expect(backend.enabled, isTrue);
  });

  test('apply keeps an already matching login item untouched', () async {
    backend.enabled = true;
    expect(await autoLaunch.apply(true), isTrue);
    expect(backend.calls, ['isEnabled']);

    backend.enabled = false;
    backend.calls.clear();
    expect(await autoLaunch.apply(false), isTrue);
    expect(backend.calls, ['isEnabled']);
  });

  test('boot reconcile respects a session-disabled entry', () async {
    backend.sessionDisabled = true;
    expect(await autoLaunch.apply(true, respectSessionDisable: true), isFalse);
    expect(backend.calls, ['isSessionDisabled']);
    expect(backend.enabled, isFalse);

    backend.sessionDisabled = false;
    backend.calls.clear();
    expect(await autoLaunch.apply(true, respectSessionDisable: true), isTrue);
    expect(backend.calls, [
      'isSessionDisabled',
      'isEnabled',
      'enable',
      'isEnabled',
    ]);
  });

  group('XDG autostart', () {
    test('writes, reports and removes the entry', () async {
      final fixture = _XdgFixture();
      final entry = fixture.entry({'HOME': fixture.root.path});
      expect(await fixture.autostart.isEnabled(), isFalse);

      expect(await fixture.autostart.enable(), isTrue);
      expect(await entry.exists(), isTrue);
      expect(await fixture.autostart.isEnabled(), isTrue);

      final contents = await entry.readAsString();
      expect(contents, contains('Type=Application'));
      expect(contents, contains('Exec="/opt/ReClash/ReClash"'));
      expect(contents, contains('TryExec=/opt/ReClash/ReClash'));
      expect(contents, contains('X-GNOME-Autostart-enabled=true'));

      expect(await fixture.autostart.disable(), isTrue);
      expect(await entry.exists(), isFalse);
      expect(await fixture.autostart.isEnabled(), isFalse);
    });

    test('honors XDG_CONFIG_HOME and ignores a relative value', () async {
      final home = fixtureRoot();
      final xdg = Directory('$home/xdg')..createSync();
      final fixture = _XdgFixture(
        environment: {'HOME': home, 'XDG_CONFIG_HOME': xdg.path},
      );
      expect(
        fixture.entry({'HOME': home, 'XDG_CONFIG_HOME': xdg.path}).path,
        '${xdg.path}/autostart/ReClash.desktop',
      );
      expect(await fixture.autostart.enable(), isTrue);
      expect(
        File('${xdg.path}/autostart/ReClash.desktop').existsSync(),
        isTrue,
      );

      expect(
        XdgAutostart.xdgConfigHome({
          'HOME': '/home/user',
          'XDG_CONFIG_HOME': 'relative/path',
        }),
        '/home/user/.config',
      );
    });

    test('moves a legacy HOME entry into XDG_CONFIG_HOME', () async {
      final home = fixtureRoot();
      final xdg = Directory('$home/xdg')..createSync();
      final legacy = File('$home/.config/autostart/ReClash.desktop')
        ..createSync(recursive: true);
      legacy.writeAsStringSync('[Desktop Entry]\nType=Application\n');
      final fixture = _XdgFixture(
        environment: {'HOME': home, 'XDG_CONFIG_HOME': xdg.path},
      );

      expect(await fixture.autostart.enable(), isTrue);
      expect(legacy.existsSync(), isFalse);
      expect(
        File('${xdg.path}/autostart/ReClash.desktop').existsSync(),
        isTrue,
      );
    });

    test('a stale executable is reported disabled and repaired', () async {
      final fixture = _XdgFixture();
      final entry = fixture.entry({'HOME': fixture.root.path});
      expect(await fixture.autostart.enable(), isTrue);
      expect(await entry.exists(), isTrue);

      final moved = XdgAutostart(
        executable: '/opt/ReClash/ReClash-new',
        appName: 'ReClash',
        environment: {'HOME': fixture.root.path},
      );
      expect(await moved.isEnabled(), isFalse);
      expect(await moved.enable(), isTrue);
      expect(
        await entry.readAsString(),
        contains('Exec="/opt/ReClash/ReClash-new"'),
      );
    });

    test('a session-disabled entry counts as off and re-enables', () async {
      final fixture = _XdgFixture();
      final entry = fixture.entry({'HOME': fixture.root.path});
      await fixture.autostart.enable();

      await entry.writeAsString(
        '[Desktop Entry]\n'
        'Type=Application\n'
        'Exec="/opt/ReClash/ReClash"\n'
        'Hidden=true\n',
      );
      expect(await fixture.autostart.isEnabled(), isFalse);
      expect(await fixture.autostart.isSessionDisabled(), isTrue);

      await entry.writeAsString(
        '[Desktop Entry]\n'
        'Type=Application\n'
        'Exec="/opt/ReClash/ReClash"\n'
        'X-GNOME-Autostart-enabled=false\n',
      );
      expect(await fixture.autostart.isEnabled(), isFalse);
      expect(await fixture.autostart.isSessionDisabled(), isTrue);
      expect(await fixture.autostart.enable(), isTrue);
      expect(await fixture.autostart.isEnabled(), isTrue);
      expect(await fixture.autostart.isSessionDisabled(), isFalse);
    });

    test('reads an entry written with CRLF line endings', () async {
      final fixture = _XdgFixture();
      final entry = fixture.entry({'HOME': fixture.root.path});
      await entry.parent.create(recursive: true);
      await entry.writeAsString(
        '[Desktop Entry]\r\n'
        'Type=Application\r\n'
        'Exec="/opt/ReClash/ReClash"\r\n',
      );
      expect(await fixture.autostart.isEnabled(), isTrue);
    });

    test('repairs a malformed entry', () async {
      final fixture = _XdgFixture();
      final entry = fixture.entry({'HOME': fixture.root.path});
      await entry.parent.create(recursive: true);
      await entry.writeAsString('not a desktop entry');
      expect(await fixture.autostart.isEnabled(), isFalse);

      expect(await fixture.autostart.enable(), isTrue);
      expect(await fixture.autostart.isEnabled(), isTrue);
    });

    test('rewrites a symlinked entry without replacing the link', () async {
      final fixture = _XdgFixture();
      final entry = fixture.entry({'HOME': fixture.root.path});
      await entry.parent.create(recursive: true);
      final managed = File('${fixture.root.path}/managed.desktop')
        ..writeAsStringSync('[Desktop Entry]\n');
      Link(entry.path).createSync(managed.path);

      expect(await fixture.autostart.enable(), isTrue);
      expect(await FileSystemEntity.isLink(entry.path), isTrue);
      expect(
        managed.readAsStringSync(),
        contains('Exec="/opt/ReClash/ReClash"'),
      );
    });

    test('refuses a sandboxed session and a path it cannot encode', () async {
      final fixture = _XdgFixture(
        environment: {'HOME': fixtureRoot(), 'FLATPAK_ID': 'com.reclash'},
      );
      expect(fixture.autostart.isSupported, isFalse);
      expect(await fixture.autostart.enable(), isFalse);

      final snap = _XdgFixture(
        environment: {'HOME': fixtureRoot(), 'SNAP': '/snap/reclash/1'},
      );
      expect(snap.autostart.isSupported, isFalse);

      final broken = _XdgFixture(executable: '/opt/ReClash\nReClash');
      expect(broken.autostart.isSupported, isFalse);

      final noHome = _XdgFixture(environment: {});
      expect(noHome.autostart.isSupported, isFalse);
    });

    test('reports a write failure instead of claiming success', () async {
      final fixture = _XdgFixture();
      final configHome = XdgAutostart.xdgConfigHome({
        'HOME': fixture.root.path,
      })!;
      File('$configHome/autostart').createSync(recursive: true);

      expect(await fixture.autostart.enable(), isFalse);
      expect(await fixture.autostart.isEnabled(), isFalse);
      expect(fixture.autostart.lastError, isNotNull);
    });
  });
}

String fixtureRoot() {
  final directory = Directory.systemTemp.createTempSync(
    'reclash-autostart-root-',
  );
  addTearDown(() => directory.deleteSync(recursive: true));
  return directory.path;
}
