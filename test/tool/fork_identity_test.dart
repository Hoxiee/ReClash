import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test(
    'Android namespace and application ID retain installed product identity',
    () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(gradle, contains('namespace = "com.reclash"'));
      expect(gradle, contains('applicationId = "com.reclash"'));
    },
  );
  test('Windows installer retains its established AppId and executable', () {
    final installer =
        loadYaml(
              File('windows/packaging/exe/make_config.yaml').readAsStringSync(),
            )
            as Map;
    expect(installer['app_id'], '728B3532-C74B-4870-9068-BE70FE12A3E6');
    expect(installer['executable_name'], 'ReClash.exe');
  });
  test(
    'public issue and release destinations retain the ReClash repository',
    () {
      expect(
        File('lib/common/constant.dart').readAsStringSync(),
        contains("const repository = 'Hoxiee/ReClash'"),
      );
      for (final path in [
        '.github/ISSUE_TEMPLATE/bug_report.yml',
        '.github/ISSUE_TEMPLATE/feature_request.yml',
      ]) {
        expect(
          File(path).readAsStringSync(),
          contains('github.com/Hoxiee/ReClash/issues'),
          reason: path,
        );
      }
      final workflow =
          loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
              as Map;
      final release = (workflow['jobs'] as Map)['build'] as Map;
      expect(release['if'], contains("github.repository == 'Hoxiee/ReClash'"));
      expect(
        release['needs'],
        containsAll([
          'dart',
          'plugins',
          'go',
          'android',
          'rust',
          'windows-helper-test',
        ]),
      );
    },
  );
  test('upstream attribution and bundled license texts remain available', () {
    final about = File('lib/views/about.dart').readAsStringSync();
    expect(about, contains('https://github.com/chen08209/FlClash'));
    for (final name in [
      'ReClash-GPL3.txt',
      'mihomo-GPL3.txt',
      'JetBrainsMono-OFL.txt',
      'Twemoji.Mozilla-LICENSE.txt',
    ]) {
      expect(File('assets/data/licenses/$name').lengthSync(), greaterThan(100));
    }
  });
  test('application branding uses the established icon paths', () {
    for (final path in ['lib/views/about.dart', 'lib/views/setup.dart']) {
      expect(
        File(path).readAsStringSync(),
        contains('assets/images/icon.png'),
        reason: path,
      );
    }
    expect(
      File('linux/runner/my_application.cc').readAsStringSync(),
      contains('"icon.png"'),
    );
    for (final format in ['deb', 'rpm', 'appimage', 'pacman']) {
      final config =
          loadYaml(
                File(
                  'linux/packaging/$format/make_config.yaml',
                ).readAsStringSync(),
              )
              as Map;
      expect(config['icon'], './assets/images/icon.png', reason: format);
    }
    expect(
      File('assets/images/icon.ico').readAsBytesSync(),
      File('windows/runner/resources/app_icon.ico').readAsBytesSync(),
    );
    final generator = File(
      'tool/generate_status_icons.dart',
    ).readAsStringSync();
    expect(generator, contains(r'$sourceDir/glyph.svg'));
    expect(generator, contains(r'$sourceDir/macos.png'));
  });

  test('Android and tray sources retain the shared three-bar mark', () {
    final mark = File('assets_source/images/icon/glyph.svg').readAsStringSync();
    final paths = RegExp(
      r'<path\b[^>]*\bd="([^"]+)"',
    ).allMatches(mark).map((match) => match[1]!).toList();
    expect(paths, hasLength(3));
    for (final path in [
      'android/app/src/main/res/drawable/ic_launcher_foreground.xml',
      'android/app/src/main/res/drawable/ic_launcher_foreground_tv.xml',
      'android/app/src/main/res/drawable/ic_launcher_monochrome.xml',
      'android/service/src/main/res/drawable/ic.xml',
      'android/service/src/main/res/drawable/ic_service.xml',
      for (final status in [1, 2, 3])
        'assets_source/images/icon/status_$status.svg',
    ]) {
      final source = File(path).readAsStringSync();
      for (final data in paths) {
        expect(source, contains('"$data"'), reason: path);
      }
    }
    for (final path in [
      'android/app/src/main/res/drawable/ic_launcher_monochrome.xml',
      'android/service/src/main/res/drawable/ic.xml',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains('android:fillColor="#FFFFFF"'), reason: path);
      expect(source, isNot(contains('<gradient')), reason: path);
    }
    for (final path in [
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
      'android/app/src/main/res/mipmap-television-anydpi-v26/ic_launcher.xml',
    ]) {
      expect(
        File(path).readAsStringSync(),
        contains('@drawable/ic_launcher_monochrome'),
        reason: path,
      );
    }
    expect(
      File(
        'android/service/src/main/java/com/reclash/service/modules/'
        'NotificationModule.kt',
      ).readAsStringSync(),
      contains('setSmallIcon(R.drawable.ic)'),
    );
  });

  test('website branding uses the same current glyph and icon', () {
    final site = File('tool/build_site.sh').readAsStringSync();
    expect(site, contains('assets/images/icon.png'));
    expect(site, contains('assets_source/images/icon/glyph.svg'));
    final glyph = File(
      'assets_source/images/icon/glyph.svg',
    ).readAsStringSync();
    final paths = RegExp(
      r'<path\b[^>]*\bd="([^"]+)"',
    ).allMatches(glyph).map((match) => match[1]!);
    final html = File('site/index.html').readAsStringSync();
    for (final path in paths) {
      expect('d="$path"'.allMatches(html), hasLength(2));
    }
    final generator = File(
      'tool/generate_status_icons.dart',
    ).readAsStringSync();
    expect(generator, contains('assets/images/icon.png'));
    expect(generator, contains(r'$sourceDir/glyph.svg'));
  });
  test(
    'TV banner is self-contained vector artwork with an outlined wordmark',
    () {
      final banner = File(
        'assets_source/images/icon/tv_banner.svg',
      ).readAsStringSync();
      expect(banner, contains('width="320" height="180"'));
      expect(banner, contains('<title>ReClash TV Banner</title>'));
      expect(
        RegExp(r'<path\b[^>]*\bid="wordmark"[^>]*\bd="[^"]+"').hasMatch(banner),
        isTrue,
      );
      expect(banner, isNot(contains('<text')));
      expect(banner, isNot(contains('<image')));
      expect(banner, isNot(contains('href=')));
    },
  );
}
