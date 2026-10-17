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

    test('refuses to package while a native build hook is skipped', () {
      const pubspec = '''
hooks:
  user_defines:
    setup:
      build_assets: false
    rust_api:
      build_assets: true
''';

      expect(setup.packagesNotBuildingAssets(pubspec), ['setup']);
      expect(setup.packagesNotBuildingAssets('name: x\n'), isEmpty);
    });

    test('packages every Linux format on every architecture', () {
      expect(
        setup.createPackageTargets('linux', null),
        'deb,appimage,rpm,pacman',
      );
      expect(setup.createPackageTargets('linux', 'deb'), 'deb');
      expect(setup.createPackageTargets('macos', null), 'dmg');
    });

    test('pulls only the selected Linux format tools', () {
      final deb = setup.linuxDependencyPackageGroups('deb').expand((e) => e);
      final rpm = setup.linuxDependencyPackageGroups('rpm').expand((e) => e);
      final appimage = setup
          .linuxDependencyPackageGroups('appimage')
          .expand((e) => e);
      final pacman = setup
          .linuxDependencyPackageGroups('pacman')
          .expand((e) => e);
      final pacmanArch = setup
          .linuxDependencyPackageGroups('pacman', family: 'arch')
          .expand((e) => e);

      expect(deb, isNot(contains('rpm')));
      expect(deb, isNot(contains('libfuse2')));
      expect(deb, isNot(contains('libarchive-tools')));
      expect(rpm, containsAll(['rpm', 'patchelf']));
      expect(appimage, contains('libfuse2'));
      expect(pacman, containsAll(['libarchive-tools', 'xz-utils']));
      expect(pacmanArch, containsAll(['libarchive', 'xz', 'gtk3']));
      expect(pacmanArch, isNot(contains('libarchive-tools')));
    });

    test('downloads the appimagetool build matching the host', () {
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
    });

    test('packager resolves wrappers before the parent PATH', () {
      final env = setup.createPackageProcessEnvironment(
        rootDir: '/repo',
        platform: 'linux',
      );

      expect(
        env['PATH']!.split(':').first,
        endsWith('.dart_tool/release_tools/bin'),
      );
      expect(env['PATH'], contains('pub-cache'));
    });
  });
}
