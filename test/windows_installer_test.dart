import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final installer = File(
    'windows/packaging/exe/inno_setup.iss',
  ).readAsStringSync();

  test(
    'Windows retains installed-product identity and launches an ordinary GUI',
    () {
      final config =
          loadYaml(
                File(
                  'windows/packaging/exe/make_config.yaml',
                ).readAsStringSync(),
              )
              as YamlMap;
      expect(config['app_id'], 'E642C6C1-B712-41C2-969E-3C2049CA883F');
      expect(config['publisher_name'], 'Hoxiee');
      expect(config.containsKey('publisher'), isFalse);
      expect(config['create_desktop_icon'], isTrue);
      expect(config['executable_name'], 'ReClash.exe');
      expect(
        installer.split('[Run]').last,
        contains('runasoriginaluser nowait postinstall skipifsilent'),
      );
      expect(installer, isNot(contains('runascurrentuser')));
      final manifest = File(
        'windows/runner/runner.exe.manifest',
      ).readAsStringSync();
      expect(manifest, contains('level="asInvoker"'));
      expect(manifest, isNot(contains('requireAdministrator')));
    },
  );

  test(
    'installer offers every product language and supported architecture',
    () {
      final config =
          loadYaml(
                File(
                  'windows/packaging/exe/make_config.yaml',
                ).readAsStringSync(),
              )
              as YamlMap;
      final locales = (config['locales'] as YamlList).cast<YamlMap>();
      expect(locales.map((locale) => locale['lang']), ['en', 'ru', 'zh', 'ko']);
      for (final locale in locales) {
        final customFile = locale['file'] as String?;
        if (customFile != null) {
          expect(
            File(
              'windows/packaging/exe/${customFile.split('\\').last}',
            ).existsSync(),
            isTrue,
          );
        }
      }
      expect(installer, contains('Name: "russian"'));
      expect(installer, contains('Name: "korean"'));
      final customMessages = installer
          .split('[CustomMessages]')
          .last
          .split('[Tasks]')
          .first;
      final messages = <String, Map<String, String>>{};
      for (final match in RegExp(
        r'^(\w+)\.(\w+)=(.+)$',
        multiLine: true,
      ).allMatches(customMessages)) {
        (messages[match[1]!] ??= {})[match[2]!] = match[3]!;
      }
      expect(
        messages.keys,
        unorderedEquals(['english', 'russian', 'chineseSimplified', 'korean']),
      );
      for (final entries in messages.values) {
        expect(
          entries.keys,
          unorderedEquals([
            'RemoveUserData',
            'CloseInstalledApp',
            'LegacyServiceRemovalFailed',
          ]),
        );
        for (final entry in entries.entries) {
          if (entry.key != 'RemoveUserData') {
            expect(entry.value, contains('%1'));
          }
        }
      }
      for (final language in messages.keys.where((key) => key != 'english')) {
        for (final key in messages['english']!.keys) {
          expect(messages[language]![key], isNot(messages['english']![key]));
        }
      }
      expect(installer, contains('MinVersion=10.0'));
      expect(
        installer,
        contains("{% if ARCH == 'arm64' %}arm64{% else %}x64compatible"),
      );
      expect(installer, contains('SetupMutex=ReClashSetupMutex'));
      expect(
        installer,
        contains('UninstallDisplayIcon={app}\\{{EXECUTABLE_NAME}}'),
      );
      expect(
        installer,
        contains('VersionInfoVersion={#GetVersionNumbersString'),
      );
      expect(installer, isNot(contains('FlClash')));
    },
  );

  test(
    'release gates inspect installed packages and require native bootstrap on both architectures',
    () {
      final workflow =
          loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
              as YamlMap;
      final jobs = workflow['jobs'] as YamlMap;
      final native = jobs['windows-helper-test'] as YamlMap;
      final packages = jobs['validate-windows-packages'] as YamlMap;
      for (final job in [native, packages]) {
        final targets = job['strategy']['matrix']['include'] as YamlList;
        expect(
          targets.map((dynamic target) => target['arch']),
          unorderedEquals(['amd64', 'arm64']),
        );
      }
      final bootstrap = (native['steps'] as YamlList)
          .cast<YamlMap>()
          .singleWhere(
            (step) => step['name'] == 'Validate Windows Core bootstrap',
          );
      expect(bootstrap['env']['RECLASH_REQUIRE_WINDOWS_BOOTSTRAP'], '1');
      expect(bootstrap['run'], contains('-count=1 -timeout=5m ./cmd/core'));
      expect(jobs['upload']['needs'], contains('validate-windows-packages'));
      final smoke = File('tool/check_windows_package.ps1').readAsStringSync();
      expect(smoke, contains('upgrade.log'));
      expect(smoke, contains('Confirm-OwnedExit'));
      expect(smoke, contains('Get-AuthenticodeSignature'));
      expect(smoke, isNot(contains('Stop-Process -Name')));
      expect(smoke, isNot(contains('installed/config')));
    },
  );

  test(
    'installer asks only the exact installed app to perform owned shutdown',
    () {
      expect(installer, isNot(contains('taskkill')));
      expect(installer, isNot(contains('KillProcesses')));
      expect(installer, contains('QueryFullProcessImageName'));
      expect(installer, contains('CompareText(Path, ExpandConstant'));
      expect(installer, contains('ReClash.InstalledProductMaintenance'));
      expect(
        installer,
        contains('WaitForSingleObject(ShutdownHandles[i], 20000)'),
      );
      final runner = File(
        'windows/runner/flutter_window.cpp',
      ).readAsStringSync();
      expect(runner, contains('ReClash.InstalledProductMaintenance'));
      expect(runner, contains('"should-terminate"'));
      expect(runner, isNot(contains('TerminateProcess')));
      expect(installer, contains("CustomMessage('CloseInstalledApp')"));
      expect(
        installer,
        contains("CustomMessage('LegacyServiceRemovalFailed')"),
      );
      expect(installer, isNot(contains("Result := 'Close ReClash")));
      final uninstall = installer
          .split('function InitializeUninstall(): Boolean;')
          .last
          .split('procedure CurUninstallStepChanged')
          .first;
      expect(uninstall, contains('PrepareInstalledProduct()'));
      expect(uninstall, contains('Log(ErrorMessage)'));
      expect(
        uninstall,
        contains('SuppressibleMsgBox(ErrorMessage, mbError, MB_OK, IDOK)'),
      );
    },
  );

  test(
    'legacy service removal validates fixed product image before stopping it',
    () {
      expect(installer, contains('Services\\ReClashHelperService'));
      expect(installer, contains("'ImagePath', Value"));
      expect(installer, contains('CompareText(Value, Expected) <> 0'));
      expect(installer, contains("ExpandConstant('{sys}\\sc.exe')"));
      expect(installer, contains('ServiceMissing = 1060'));
      expect(installer, contains('ServiceNotActive = 1062'));
      expect(installer, contains('ServiceMarkedForDelete = 1072'));
      expect(installer, isNot(contains("Exec(HelperPath, 'uninstall'")));
      expect(installer, isNot(contains('FlClash')));
    },
  );

  test(
    'Windows bundle stages no SCM helper and requires app-local runtime',
    () {
      final cmake = File('windows/CMakeLists.txt').readAsStringSync();
      expect(cmake, isNot(contains('ReClashHelperService.exe')));
      expect(cmake, isNot(contains('Stop-Process')));
      expect(cmake, contains('ReClashCore.exe'));
      expect(cmake, contains('manifest.json'));
      expect(cmake, contains('if(NOT CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS)'));
      expect(cmake, contains('message(FATAL_ERROR "MSVC runtime'));
    },
  );
}
