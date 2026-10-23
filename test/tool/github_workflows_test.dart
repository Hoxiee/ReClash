import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/check_release_assets.dart';

void main() {
  final workflow =
      loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
          as YamlMap;
  final jobs = workflow['jobs'] as YamlMap;

  String steps(String job) => (jobs[job]['steps'] as YamlList)
      .map((step) => step['run'] ?? '')
      .join('\n');

  test('checks run for pull requests and manual packaging is opt-in', () {
    final events = workflow['on'] as YamlMap;
    expect(events['pull_request']['branches'], containsAll(['main', 'dev']));
    expect(
      events['workflow_dispatch']['inputs']['build_packages']['default'],
      false,
    );
    expect(workflow['permissions']['contents'], 'read');
    final build = jobs['build'] as YamlMap;
    expect(build['if'], contains('inputs.build_packages'));
    expect(
      build['needs'],
      containsAll(['dart', 'rust', 'windows-helper-test']),
    );
    final publish = jobs['upload'] as YamlMap;
    expect(publish['if'], contains("github.event_name == 'push'"));
    expect(publish['if'], contains("startsWith(github.ref, 'refs/tags/v')"));
    expect(
      publish['needs'],
      containsAll(['validate-linux-packages', 'validate-windows-packages']),
    );
  });

  test('Telegram download buttons follow published prerelease assets', () {
    final uploadSteps = jobs['upload']['steps'] as YamlList;
    final release = uploadSteps.firstWhere((step) => step['name'] == 'Release');
    expect(release['if'], isNull);
    expect(release['with']['prerelease'], contains("IS_STABLE != 'true'"));
    expect(release['with']['make_latest'], contains("'false'"));
    expect(release['with']['fail_on_unmatched_files'], true);
    expect(
      uploadSteps.indexOf(release),
      lessThan(
        uploadSteps.indexWhere((step) => step['name'] == 'Push to telegram'),
      ),
    );
    final commands = steps('upload');
    expect(commands, contains('python3 -I release_telegram.py'));
    expect(commands, isNot(contains('telegram-bot-api')));
    expect(commands, isNot(contains('pip install requests')));
    expect(steps('dart'), contains('changelog_telegram_test.py'));
  });

  test('localization is assembled before generation and before tests', () {
    final commands = steps('dart');
    expect(
      commands.indexOf('tool/assemble_l10n.dart'),
      lessThan(commands.indexOf('intl_utils:generate')),
    );
    expect(
      commands.indexOf('intl_utils:generate'),
      lessThan(commands.indexOf('tool/test.dart')),
    );
    expect(commands, isNot(contains('assemble_l10n.dart --check')));
    expect(steps('build'), contains('tool/assemble_l10n.dart'));
  });

  test('manifest and package validation gate publishing', () {
    final validation = steps('validate-linux-packages');
    expect(validation, contains('tool/check_release_assets.dart'));
    expect(validation, contains('pacman -Qp'));
    expect(validation, contains('pacman -U'));
    expect(validation, contains('SHA256SUMS'));
    expect(
      steps('rust'),
      contains(
        'cargo test --locked --manifest-path services/helper/Cargo.toml',
      ),
    );
    expect(steps('rust'), isNot(contains('--features linux-service')));
  });

  test('release download table covers every package in the manifest', () {
    final template = File('.github/release_template.md').readAsStringSync();
    for (final name in releaseAssetNames('VERSION')) {
      expect(template, contains('/download/vVERSION/$name'), reason: name);
    }
    expect(template, isNot(contains('reclash:release-epoch')));
    expect(template, contains('SHA256SUMS'));
  });

  test('issue forms retain every supported locale and privacy guidance', () {
    for (final file in Directory('.github/ISSUE_TEMPLATE').listSync()) {
      if (file is! File) continue;
      expect(
        RegExp(
          r'[\u3400-\u4DBF\u4E00-\u9FFF]',
        ).hasMatch(file.readAsStringSync()),
        false,
        reason: file.path,
      );
    }
    final translations =
        loadYaml(
              File('.github/ISSUE_TEMPLATE/translation.yml').readAsStringSync(),
            )
            as YamlMap;
    final language = (translations['body'] as YamlList).firstWhere(
      (field) => field['id'] == 'language',
    );
    expect(language['attributes']['options'], hasLength(10));
    expect(
      language['attributes']['options'],
      containsAll(['Spanish', 'French']),
    );
    final bug = File(
      '.github/ISSUE_TEMPLATE/bug_report.yml',
    ).readAsStringSync();
    expect(bug, contains('subscription URLs, tokens'));
    expect(bug, contains('id: regression'));
    for (final name in ['bug_report', 'feature_request', 'translation']) {
      final form =
          loadYaml(File('.github/ISSUE_TEMPLATE/$name.yml').readAsStringSync())
              as YamlMap;
      final fields = (form['body'] as YamlList)
          .where((field) => field['type'] != 'markdown')
          .toList();
      final ids = fields.map((field) => field['id']).toSet();
      expect(ids, isNot(contains(null)), reason: name);
      expect(ids, hasLength(fields.length), reason: name);
    }
  });
}
