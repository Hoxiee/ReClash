import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main() {
  final iss = File(
    p.join('windows', 'packaging', 'exe', 'inno_setup.iss'),
  ).readAsStringSync();
  final makeConfig = File(
    p.join('windows', 'packaging', 'exe', 'make_config.yaml'),
  ).readAsStringSync();

  test('installer clears the ReClash helper service through system sc.exe', () {
    expect(iss, contains("ExpandConstant('{sys}\\sc.exe')"));
    expect(iss, contains("RemoveHelperService('ReClashHelperService')"));
    expect(iss, contains('ServiceMissing = 1060'));
    expect(iss, contains('ServiceNotActive = 1062'));
    expect(iss, contains('ServiceMarkedForDelete = 1072'));
    expect(iss, contains('Name: "{app}\\ReClashHelperService.exe"'));
  });

  test('installer carries no FlClash identity', () {
    expect(iss, isNot(contains('FlClash')));
    expect(makeConfig, isNot(contains('FlClash')));
    // FlClash's inherited Inno AppId made setup reuse FlClash's install dir;
    // a re-sync from upstream must never drag that GUID back in.
    expect(makeConfig, isNot(contains('728B3532-C74B-4870-9068-BE70FE12A3E6')));
  });

  test('installer ships the four requested setup languages', () {
    for (final lang in ['en', 'ru', 'zh', 'ko']) {
      expect(makeConfig, contains('lang: $lang'));
    }
    expect(iss, contains('Name: "russian"'));
    expect(iss, contains('Name: "korean"'));
  });

  test(
    'postinstall launch uses the original user and skips silent installs',
    () {
      final launch = iss.split('[Run]').last;
      expect(
        launch,
        contains('runasoriginaluser nowait postinstall skipifsilent'),
      );
      expect(launch, isNot(contains('runascurrentuser')));
    },
  );

  test('installer declares supported Windows and native architectures', () {
    expect(iss, contains('MinVersion=10.0'));
    expect(
      iss,
      contains("{% if ARCH == 'arm64' %}arm64{% else %}x64compatible"),
    );
  });

  test(
    'installer uses the packager publisher field and keeps its identity',
    () {
      expect(makeConfig, contains('publisher_name: Hoxiee'));
      expect(makeConfig, isNot(contains('\npublisher:')));
      expect(makeConfig, contains('E642C6C1-B712-41C2-969E-3C2049CA883F'));
      expect(makeConfig, contains('create_desktop_icon: true'));
    },
  );

  test(
    'release gates require native bootstrap and installed package checks',
    () {
      final workflow =
          loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
              as YamlMap;
      final jobs = workflow['jobs'] as YamlMap;
      final native = jobs['windows-native'] as YamlMap;
      final packages = jobs['validate-windows-packages'] as YamlMap;
      for (final job in [native, packages]) {
        final targets = job['strategy']['matrix']['include'] as YamlList;
        expect(
          targets.map((dynamic target) => target['arch']),
          unorderedEquals(['amd64', 'arm64']),
        );
      }
      final steps = (native['steps'] as YamlList).cast<YamlMap>();
      final bootstrap = steps.singleWhere(
        (step) => step['name'] == 'Test Windows Core bootstrap',
      );
      expect(bootstrap['env']['RECLASH_REQUIRE_WINDOWS_BOOTSTRAP'], '1');
      expect(bootstrap['run'], contains('go test -v -count=1 -timeout=5m .'));
      expect(jobs['build']['needs'], contains('windows-native'));
      expect(jobs['upload']['needs'], contains('validate-windows-packages'));
      expect(jobs['upload']['environment'], 'release');
      final uploads = (jobs['build']['steps'] as YamlList).cast<YamlMap>();
      final artifacts = uploads.singleWhere(
        (step) => step['uses'] == 'actions/upload-artifact@v4',
      );
      expect(artifacts['with']['retention-days'], 1);
    },
  );

  test('missing app-local runtime fails the CMake build', () {
    final cmake = File('windows/CMakeLists.txt').readAsStringSync();
    expect(cmake, contains('include(InstallRequiredSystemLibraries)'));
    expect(cmake, contains('if(NOT CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS)'));
    expect(cmake, contains('message(FATAL_ERROR "MSVC runtime'));
  });
}
