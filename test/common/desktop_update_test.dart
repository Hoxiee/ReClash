import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/desktop_update.dart';

const String _digest =
    'sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

Map<String, Object?> _asset(String name, {Object? digest = _digest}) => {
  'name': name,
  'browser_download_url': 'https://example.com/$name',
  'size': 42,
  'digest': ?digest,
};

Future<bool> _eventually(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  return condition();
}

void main() {
  group('detectDesktopUpdater', () {
    const winExe = r'C:\Users\a\AppData\Local\Programs\ReClash\ReClash.exe';
    bool winFiles(String path) => path.endsWith('unins000.exe');

    test('windows installer install is updatable', () {
      final updater = detectDesktopUpdater(
        operatingSystem: 'windows',
        executable: winExe,
        abi: Abi.windowsArm64,
        fileExists: winFiles,
        writable: (_) => true,
      );
      expect(updater, isNotNull);
      expect(updater!.fileSuffix, '-setup.exe');
      final asset = updater.selectAsset([
        _asset('ReClash-1.2.3-windows-amd64-setup.exe'),
        _asset('ReClash-1.2.3-windows-arm64-setup.exe'),
      ], 'v1.2.3');
      expect(asset?.name, 'ReClash-1.2.3-windows-arm64-setup.exe');
    });

    test('windows portable, unwritable and wrong abi give null', () {
      DesktopUpdater? detect({
        bool Function(String)? exists,
        bool writable = true,
        Abi abi = Abi.windowsX64,
      }) => detectDesktopUpdater(
        operatingSystem: 'windows',
        executable: winExe,
        abi: abi,
        fileExists: exists ?? winFiles,
        writable: (_) => writable,
      );
      expect(detect(exists: (_) => false), isNull);
      expect(detect(writable: false), isNull);
      expect(detect(abi: Abi.linuxX64), isNull);
    });

    test('linux needs a writable AppImage on x64', () {
      DesktopUpdater? detect({
        Map<String, String> env = const {'APPIMAGE': '/opt/R.AppImage'},
        bool exists = true,
        bool writable = true,
        Abi abi = Abi.linuxX64,
      }) => detectDesktopUpdater(
        operatingSystem: 'linux',
        executable: '/tmp/.mount_x/usr/bin/reclash',
        environment: env,
        abi: abi,
        fileExists: (_) => exists,
        writable: (_) => writable,
      );
      final updater = detect();
      expect(updater, isNotNull);
      expect(updater!.fileSuffix, '.AppImage');
      expect(updater.systemIdle(), isNull);
      expect(detect(env: const {}), isNull);
      expect(detect(env: const {'APPIMAGE': 'relative.AppImage'}), isNull);
      expect(detect(exists: false), isNull);
      expect(detect(writable: false), isNull);
      expect(detect(abi: Abi.linuxArm64), isNull);
    });

    test('macos needs a writable bundle path', () {
      DesktopUpdater? detect({
        String exe = '/Applications/ReClash.app/Contents/MacOS/ReClash',
        Abi abi = Abi.macosArm64,
        bool Function(String)? writable,
      }) => detectDesktopUpdater(
        operatingSystem: 'macos',
        executable: exe,
        abi: abi,
        writable: writable ?? (_) => true,
      );
      final updater = detect();
      expect(
        updater!.selectAsset([
          _asset('ReClash-1.0.0-macos-arm64.dmg'),
        ], '1.0.0')?.name,
        'ReClash-1.0.0-macos-arm64.dmg',
      );
      expect(
        detect(
          abi: Abi.macosX64,
        )!.selectAsset([_asset('ReClash-1.0.0-macos-amd64.dmg')], 'v1.0.0'),
        isNotNull,
      );
      expect(detect(exe: '/usr/local/bin/reclash'), isNull);
      expect(detect(writable: (path) => path != '/Applications'), isNull);
      expect(detect(writable: (path) => path == '/Applications'), isNull);
      expect(detect(abi: Abi.linuxX64), isNull);
    });

    test('other platforms give null', () {
      expect(detectDesktopUpdater(operatingSystem: 'fuchsia'), isNull);
    });
  });

  group('selectAsset', () {
    final updater = detectDesktopUpdater(
      operatingSystem: 'windows',
      executable: r'C:\R\ReClash.exe',
      abi: Abi.windowsX64,
      fileExists: (_) => true,
      writable: (_) => true,
    )!;

    test('derives the version from the tag and ignores case', () {
      final asset = updater.selectAsset([
        _asset('reclash-0.1.0-pre.5-WINDOWS-amd64-setup.exe'),
      ], 'v0.1.0-pre.5');
      expect(asset, isNotNull);
      expect(asset!.size, 42);
      expect(asset.sha256, _digest.substring(7));
      expect(
        updater.selectAsset([
          _asset('ReClash-0.1.0-pre.5-windows-amd64-setup.exe'),
        ], '0.1.0-pre.5'),
        isNotNull,
      );
    });

    test('rejects missing digest, wrong arch, wrong version, bad input', () {
      expect(
        updater.selectAsset([
          _asset('ReClash-1.0.0-windows-amd64-setup.exe', digest: null),
        ], 'v1.0.0'),
        isNull,
      );
      expect(
        updater.selectAsset([
          _asset('ReClash-1.0.0-windows-amd64-setup.exe', digest: 'sha256:zz'),
        ], 'v1.0.0'),
        isNull,
      );
      expect(
        updater.selectAsset([
          _asset('ReClash-1.0.0-windows-arm64-setup.exe'),
        ], 'v1.0.0'),
        isNull,
      );
      expect(
        updater.selectAsset([
          _asset('ReClash-1.0.0-windows-amd64-setup.exe'),
        ], 'v1.0.1'),
        isNull,
      );
      expect(updater.selectAsset('nope', 'v1.0.0'), isNull);
      expect(updater.selectAsset(['x', 3], 'v1.0.0'), isNull);
    });
  });

  group('windows launch', () {
    Future<List<String>> run({required bool relaunch, String? logPath}) async {
      late String exe;
      late List<String> args;
      final updater = detectDesktopUpdater(
        operatingSystem: 'windows',
        executable: r'C:\R\ReClash.exe',
        abi: Abi.windowsX64,
        fileExists: (_) => true,
        writable: (_) => true,
        start: (executable, arguments) async {
          exe = executable;
          args = arguments;
        },
      )!;
      await updater.launch(
        r'C:\t\setup.exe',
        relaunch: relaunch,
        logPath: logPath,
      );
      expect(exe, r'C:\t\setup.exe');
      return args;
    }

    final base = [
      '/VERYSILENT',
      '/SUPPRESSMSGBOXES',
      '/NORESTART',
      '/SP-',
      '/WAITPID=$pid',
    ];

    test('without relaunch', () async {
      expect(await run(relaunch: false), base);
    });

    test('with relaunch and log', () async {
      expect(await run(relaunch: true, logPath: r'C:\l.log'), [
        ...base,
        '/RELAUNCH',
        r'/LOG=C:\l.log',
      ]);
    });
  });

  group('scripts', () {
    test('macos script is valid shell', () async {
      final result = await Process.run('/bin/sh', [
        '-n',
        '-c',
        macosUpdateScript,
      ]);
      expect(result.exitCode, 0, reason: '${result.stderr}');
    });
  });

  group('linux AppImage script', () {
    late Directory dir;
    late String target;
    late String marker;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('reclash-update-test');
      target = '${dir.path}/ReClash.AppImage';
      marker = '${dir.path}/marker';
      File(target).writeAsStringSync('#!/bin/sh\necho old > "$marker"\n');
      Process.runSync('chmod', ['755', target]);
    });

    tearDown(() => dir.deleteSync(recursive: true));

    Future<Process> run(Process pidHolder, String newPath, String relaunch) =>
        Process.start('/bin/sh', [
          '-c',
          linuxUpdateScript,
          'reclash-update',
          '${pidHolder.pid}',
          newPath,
          target,
          relaunch,
          '${dir.path}/update.log',
        ]);

    String newImage() {
      final path = '${dir.path}/new.AppImage';
      File(path).writeAsStringSync('#!/bin/sh\necho new > "$marker"\n');
      return path;
    }

    String markerText() =>
        File(marker).existsSync() ? File(marker).readAsStringSync().trim() : '';

    test(
      'replaces only after the pid exits and relaunches the new one',
      () async {
        final holder = await Process.start('sleep', ['1.5']);
        final newPath = newImage();
        final script = await run(holder, newPath, '1');
        await Future<void>.delayed(const Duration(milliseconds: 600));
        expect(File(target).readAsStringSync(), contains('echo old'));
        expect(File(newPath).existsSync(), isTrue);
        expect(await _eventually(() => markerText() == 'new'), isTrue);
        expect(File(target).readAsStringSync(), contains('echo new'));
        expect(File(newPath).existsSync(), isFalse);
        await script.exitCode;
      },
    );

    test('relaunch 0 replaces without starting', () async {
      final holder = await Process.start('sleep', ['0.3']);
      final script = await run(holder, newImage(), '0');
      await script.exitCode;
      expect(File(target).readAsStringSync(), contains('echo new'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(File(marker).existsSync(), isFalse);
    });

    test('failed copy keeps the old version and starts it', () async {
      final holder = await Process.start('sleep', ['0.3']);
      final script = await run(holder, '${dir.path}/missing', '1');
      expect(await _eventually(() => markerText() == 'old'), isTrue);
      await script.exitCode;
      expect(File('$target.update').existsSync(), isFalse);
      expect(File(target).readAsStringSync(), contains('echo old'));
    });
  }, skip: !Platform.isLinux);
}
