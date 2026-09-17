import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../setup.dart' as setup;

void main() {
  group('setup.dart', () {
    test('parses -v as verbose mode', () {
      final results = setup.createSetupArgParser().parse(['android', '-v']);

      expect(results['verbose'], isTrue);
      expect(results.rest, ['android']);
    });

    test('accepts dev application environment', () {
      final results = setup.createSetupArgParser().parse([
        'android',
        '--env',
        'dev',
      ]);

      expect(results['env'], 'dev');
    });

    test('Flutter build environment does not depend on Core SHA256', () {
      expect(setup.createBuildEnvironment('dev'), {'APP_ENV': 'dev'});
    });

    test('omits verbose from flutter build args by default', () {
      final args = setup.createFlutterBuildArgs(
        platform: 'android',
        verbose: false,
      );

      expect(args, ['dart-define-from-file=env.json', 'split-per-abi']);
    });

    test('adds verbose to flutter build args with -v', () {
      final args = setup.createFlutterBuildArgs(
        platform: 'android',
        verbose: true,
      );

      expect(args, [
        'verbose',
        'dart-define-from-file=env.json',
        'split-per-abi',
      ]);
    });

    test('resolves outputs relative to setup.dart, not the caller', () {
      expect(setup.setupRootDirectory(), Directory.current.path);
    });

    test('prepends the writable release tools directory on Linux', () {
      final environment = setup.createPackageProcessEnvironment(
        rootDir: '/project',
        platform: 'linux',
      );

      expect(
        environment['PATH'],
        startsWith(p.join('/project', '.dart_tool', 'release_tools', 'bin')),
      );
    });

    test('skips AppImage on ARM64 until its packager supports the host', () {
      expect(
        setup.createPackageTargets('linux', null, arch: 'amd64'),
        'deb,appimage,rpm',
      );
      expect(
        setup.createPackageTargets('linux', null, arch: 'arm64'),
        'deb,rpm',
      );
      expect(setup.createPackageTargets('linux', 'deb', arch: 'arm64'), 'deb');
      expect(
        () => setup.createPackageTargets('linux', 'appimage', arch: 'arm64'),
        throwsUnsupportedError,
      );
      expect(setup.createPackageTargets('macos', null, arch: 'arm64'), 'dmg');
    });

    test('installs packaging dependencies only for selected targets', () {
      final deb = setup.linuxDependencyPackageGroups('deb').expand((e) => e);
      final rpm = setup
          .linuxDependencyPackageGroups('deb,rpm')
          .expand((e) => e);
      final appimage = setup
          .linuxDependencyPackageGroups('appimage')
          .expand((e) => e);

      expect(deb, isNot(contains('rpm')));
      expect(deb, isNot(contains('libfuse2')));
      expect(rpm, containsAll(['rpm', 'patchelf']));
      expect(appimage, contains('libfuse2'));
    });

    test('downloads a pinned verified appimagetool for the host', () async {
      expect(setup.appImageToolArch('arm64'), 'aarch64');
      expect(setup.appImageToolArch('amd64'), 'x86_64');
      expect(
        setup.appImageToolUrl('amd64'),
        'https://github.com/AppImage/AppImageKit/releases/download/'
        '12/appimagetool-x86_64.AppImage',
      );
      expect(
        setup.appImageToolSha256('arm64'),
        'c9d058310a4e04b9fbbd81340fff2b5fb44943a630b31881e321719f271bd41a',
      );

      final directory = await Directory.systemTemp.createTemp(
        'setup_hash_test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(p.join(directory.path, 'appimagetool'));
      await file.writeAsString('corrupted');

      expect(
        await setup.fileSha256(file),
        isNot(setup.appImageToolSha256('amd64')),
      );
    });

    test(
      'probes POSIX commands without invoking a shell builtin directly',
      () async {
        if (Platform.isWindows) return;

        expect(await setup.hasCommand('sh'), isTrue);
        expect(
          await setup.hasCommand('reclash-command-that-does-not-exist'),
          isFalse,
        );
        expect(await setup.hasCommand(r'$(touch /tmp/reclash-probe)'), isFalse);
      },
    );

    test(
      'CMake reevaluates build_tool without bundling the Windows Helper',
      () {
        final buildkitSource = File(
          p.join(
            Directory.current.path,
            'plugins',
            'setup',
            'buildkit',
            'cmake',
            'buildkit.cmake',
          ),
        ).readAsStringSync();

        final windowsPluginSource = File(
          p.join(
            Directory.current.path,
            'plugins',
            'setup',
            'windows',
            'CMakeLists.txt',
          ),
        ).readAsStringSync();

        expect(buildkitSource, contains('ReClashHelperService.exe'));
        expect(
          buildkitSource,
          contains(
            'add_custom_target(setup_buildkit_build ALL DEPENDS "\${_phony}")',
          ),
        );
        expect(
          windowsPluginSource,
          isNot(contains('ReClashHelperService.exe')),
        );
      },
    );
  });
}
