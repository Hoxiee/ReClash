import 'dart:io';

import 'package:test/test.dart';

import '../../setup.dart' as setup;
import '../../tool/linux_package.dart';
import '../../tool/src/release_version.dart';

void main() {
  final version = ReleaseVersion.parse('0.1.0-pre.1+2026091501');

  test('keeps public names separate from native package versions', () {
    expect(version.name, '0.1.0-pre.1');
    expect(version.base, '0.1.0');
    expect(version.buildNumber, '2026091501');
    expect(version.debianVersion, '1:0.1.0~pre.1-2026091501');
    expect(version.linuxVersion, '0.1.0~pre.1');
    expect(version.pacmanVersion, '0.1.0pre1');
    expect(version.pacmanRelease, '2026091501');
    expect(version.macosBuildNumber, '2609.15.1');
    expect(setup.createBuildEnvironment('pre', version: version), {
      'APP_ENV': 'pre',
      'APP_VERSION': '0.1.0-pre.1',
      'APP_BUILD_NUMBER': '2026091501',
    });
  });

  test('passes numeric Apple versions without changing Android versions', () {
    expect(
      setup.createFlutterBuildArgs(
        platform: 'macos',
        verbose: false,
        version: version,
      ),
      [
        'dart-define-from-file=env.json',
        'build-name=0.1.0',
        'build-number=2609.15.1',
      ],
    );
    expect(
      setup.createFlutterBuildArgs(
        platform: 'android',
        verbose: false,
        version: version,
      ),
      ['dart-define-from-file=env.json', 'split-per-abi'],
    );
  });

  test('preserves per-ABI Android upgrade ordering and Play limits', () {
    final previous = ReleaseVersion.parse('0.8.97+2026090701');
    for (final offset in [1000, 2000, 4000]) {
      final code = int.parse(version.buildNumber) + offset;
      expect(code, greaterThan(int.parse(previous.buildNumber) + offset));
      expect(code, lessThanOrEqualTo(2100000000));
    }
  });

  test('rejects malformed versions, dates and overflowing split APK codes', () {
    for (final value in [
      '0.1.0 pre 1+2026091501',
      '0.1.0-pre.0+2026091501',
      '0.1.0-pre.1+1',
      '0.1.0-pre.1+2026023001',
      '0.1.0-pre.1+2026091500',
      '0.1.0-pre.1+2100010101',
    ]) {
      expect(() => ReleaseVersion.parse(value), throwsFormatException);
    }
    expect(
      ReleaseVersion.fromPubspec(
        'name: reclash\nversion: 0.1.0-pre.1+2026091501\n',
      ).name,
      version.name,
    );
  });

  test('CI accepts only the exact public version tag', () async {
    final current = ReleaseVersion.read(Directory.current.path);
    final accepted = await Process.run('dart', [
      'tool/check_release_version.dart',
      'v${current.name}',
    ]);
    expect(accepted.exitCode, 0, reason: '${accepted.stderr}');
    expect((accepted.stdout as String).trim(), current.name);
    final rejected = await Process.run('dart', [
      'tool/check_release_version.dart',
      'v${current.name}-mismatch',
    ]);
    expect(rejected.exitCode, 1);
    expect(rejected.stderr, contains('does not match pubspec version'));
  });

  test('normalizes pinned packager metadata and preserves other fields', () {
    expect(
      normalizePackageMetadata(
        'Package: reclash\nVersion: 0.1.0-pre.1+2026091501\nArchitecture: arm64\n',
        version,
        rpm: false,
      ),
      'Package: reclash\nVersion: 1:0.1.0~pre.1-2026091501\nArchitecture: arm64\n',
    );
    expect(
      normalizePackageMetadata(
        'Name: ReClash\nVersion: 0.1.0-pre.1+2026091501\nRelease: 2026091501%{?dist}\n',
        version,
        rpm: true,
      ),
      'Name: ReClash\nEpoch: 1\nVersion: 0.1.0~pre.1\nRelease: 2026091501%{?dist}\n',
    );
    expect(
      () => normalizePackageMetadata(
        'Package: other\nVersion: 1\n',
        version,
        rpm: false,
      ),
      throwsFormatException,
    );
  });

  test('Debian upgrades across the reset, prereleases and stable', () async {
    if (!Platform.isLinux || !await setup.hasCommand('dpkg-deb')) return;
    final sequence = [
      '0.8.97+2026090701',
      version.debianVersion,
      ReleaseVersion.parse('0.1.0-pre.2+2026091502').debianVersion,
      ReleaseVersion.parse('0.1.0-pre.10+2026091510').debianVersion,
      ReleaseVersion.parse('0.1.0+2026091601').debianVersion,
    ];
    for (var i = 1; i < sequence.length; i++) {
      final result = await Process.run('dpkg', [
        '--compare-versions',
        sequence[i - 1],
        'lt',
        sequence[i],
      ]);
      expect(result.exitCode, 0, reason: '${sequence[i - 1]} < ${sequence[i]}');
    }
  });

  test(
    'the adapter builds a DEB with the expected installable version',
    () async {
      if (!Platform.isLinux || !await setup.hasCommand('dpkg-deb')) return;
      final temp = await Directory.systemTemp.createTemp(
        'reclash-version-deb-',
      );
      addTearDown(() => temp.delete(recursive: true));
      final control = File('${temp.path}/package/DEBIAN/control');
      await control.create(recursive: true);
      await control.writeAsString(
        'Package: reclash\nVersion: 0.1.0-pre.1+2026091501\n'
        'Architecture: all\nMaintainer: Test <test@example.com>\n'
        'Description: Version test\n',
      );
      final which = await Process.run('which', ['dpkg-deb']);
      final result = await Process.run('dart', [
        'run',
        'tool/linux_package.dart',
        (which.stdout as String).trim(),
        '--build',
        '--root-owner-group',
        '${temp.path}/package',
        '${temp.path}/app.deb',
      ]);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      final metadata = await Process.run('dpkg-deb', [
        '--field',
        '${temp.path}/app.deb',
        'Version',
      ]);
      expect(
        (metadata.stdout as String).trim(),
        ReleaseVersion.read(Directory.current.path).debianVersion,
      );
    },
  );

  test(
    'rewrites pacman metadata into a libalpm-parseable, upgradable form',
    () {
      const raw =
          'pkgname=reclash\npkgver=0.1.0-pre.1+2026091501\n'
          'license=(Other)\ngroups=(default)\narch=(x86_64)\n'
          'depends=(gtk3, libsecret)\nsize=6604\n';
      const expected =
          'pkgname = reclash\npkgver = 1:0.1.0pre1-2026091501\n'
          'license = Other\ngroup = default\narch = x86_64\n'
          'depend = gtk3\ndepend = libsecret\nsize = 918273\n';
      expect(
        normalizePacmanPkgInfo(raw, version, installedSize: 918273),
        expected,
      );
      expect(
        normalizePacmanPkgInfo(expected, version, installedSize: 918273),
        expected,
      );
      expect(
        () => normalizePacmanPkgInfo('pkgname=other\npkgver=1\n', version),
        throwsFormatException,
      );
      expect(
        () => normalizePacmanPkgInfo('pkgname=reclash\ngarbage\n', version),
        throwsFormatException,
      );
    },
  );

  test(
    'the adapter builds a pacman package with a valid installable version',
    () async {
      if (!Platform.isLinux || !await setup.hasCommand('bsdtar')) return;
      final temp = await Directory.systemTemp.createTemp(
        'reclash-version-pacman-',
      );
      addTearDown(() => temp.delete(recursive: true));
      final pkg = Directory('${temp.path}/package');
      await Directory('${pkg.path}/opt/reclash').create(recursive: true);
      await File(
        '${pkg.path}/opt/reclash/reclash',
      ).writeAsString('#!/bin/sh\n');
      await File(
        '${pkg.path}/.INSTALL',
      ).writeAsString('post_install() {\n\t:\n}\n');
      await File('${pkg.path}/.PKGINFO').writeAsString(
        'pkgname=reclash\npkgver=0.1.0-pre.1+2026091501\n'
        'pkgdesc=Version test\narch=(x86_64)\ndepends=(gtk3, libsecret)\n',
      );
      final which = await Process.run('which', ['bsdtar']);
      final bsdtar = (which.stdout as String).trim();
      final tool = '${Directory.current.path}/tool/linux_package.dart';
      Future<ProcessResult> run(List<String> arguments) => Process.run(
        'dart',
        ['run', tool, bsdtar, ...arguments],
        workingDirectory: pkg.path,
        environment: {'LANG': 'C'},
      );
      final mtree = await run([
        '-czf',
        '.MTREE',
        '--format=mtree',
        '--options=!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link',
        '.PKGINFO',
        '.INSTALL',
        'opt',
      ]);
      expect(mtree.exitCode, 0, reason: '${mtree.stdout}\n${mtree.stderr}');
      final archive = await run([
        '-cf',
        'temptar',
        '.MTREE',
        '.INSTALL',
        '.PKGINFO',
        'opt',
      ]);
      expect(
        archive.exitCode,
        0,
        reason: '${archive.stdout}\n${archive.stderr}',
      );
      final xz = await Process.run('xz', [
        '-z',
        'temptar',
      ], workingDirectory: pkg.path);
      expect(xz.exitCode, 0);
      final output = '${temp.path}/app.pkg.tar.xz';
      await File('${pkg.path}/temptar.xz').rename(output);
      final current = ReleaseVersion.read(Directory.current.path);
      final expected = '1:${current.pacmanVersion}-${current.pacmanRelease}';

      final pkgInfo = await Process.run('bsdtar', ['-xOf', output, '.PKGINFO']);
      expect(pkgInfo.stdout, contains('size = 10'));
      expect(pkgInfo.stdout, isNot(contains('6604')));

      final listing = await Process.run('bsdtar', ['-tvf', output]);
      expect(listing.exitCode, 0);
      expect(listing.stdout, contains('root'));
      final user = Platform.environment['USER'];
      if (user != null && user.isNotEmpty && user != 'root') {
        expect(listing.stdout, isNot(contains(user)));
      }

      if (await setup.hasCommand('pacman')) {
        final query = await Process.run('pacman', ['-Qp', output]);
        expect(query.exitCode, 0, reason: '${query.stdout}\n${query.stderr}');
        expect((query.stdout as String).trim(), 'reclash $expected');
      } else {
        final info = await Process.run('bsdtar', ['-xOf', output, '.PKGINFO']);
        expect(info.stdout, contains('pkgver = $expected'));
      }
    },
  );
}
