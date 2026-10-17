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
}
