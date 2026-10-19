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
      expect(config['app_id'], '728B3532-C74B-4870-9068-BE70FE12A3E6');
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
      expect(installer, contains('Close ReClash in this installation'));
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
