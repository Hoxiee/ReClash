import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Linux CMake installs Core, Helper and manifest together', () async {
    final temporaryDirectory = Directory.systemTemp.createTempSync(
      'setup_linux_bundle_test_',
    );
    addTearDown(() => temporaryDirectory.deleteSync(recursive: true));
    final plugin = Directory('../../linux').absolute.path;
    final source = Directory('${temporaryDirectory.path}/linux')..createSync();
    final build = '${temporaryDirectory.path}/build';
    File('${source.path}/CMakeLists.txt').writeAsStringSync('''
cmake_minimum_required(VERSION 3.10)
project(bundle_fixture LANGUAGES CXX)
set(BINARY_NAME fixture)
add_custom_target(fixture)
add_subdirectory("$plugin" setup)
''');
    final outputs = Directory('${temporaryDirectory.path}/libclash/linux')
      ..createSync(recursive: true);
    const names = ['ReClashCore', 'ReClashHelperService', 'manifest.json'];
    for (final name in names) {
      File('${outputs.path}/$name').writeAsStringSync(name);
    }
    for (final arguments in [
      ['-S', source.path, '-B', build],
      ['--install', build, '--component', 'Runtime'],
    ]) {
      final result = await Process.run('cmake', arguments);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    }
    for (final name in names) {
      final file = File('$build/bundle/$name');
      expect(file.readAsStringSync(), name);
      if (name != 'manifest.json') {
        expect(file.statSync().mode & 0x49, 0x49);
      }
    }
  }, skip: !Platform.isLinux);
}
