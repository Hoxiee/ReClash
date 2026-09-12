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

    test('downloads the appimagetool build matching the host', () {
      expect(setup.appImageToolArch('arm64'), 'aarch64');
      expect(setup.appImageToolArch('amd64'), 'x86_64');
    });

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
