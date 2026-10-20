import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/linux_package.dart';

void main() {
  group('Linux packaging teardown', () {
    for (final format in ['deb', 'rpm']) {
      test(
        '$format removes only package-owned Helpers before files disappear',
        () async {
          final config =
              loadYaml(
                    File(
                      'linux/packaging/$format/make_config.yaml',
                    ).readAsStringSync(),
                  )
                  as YamlMap;
          expect(config['postuninstall_scripts'], isNull);
          final script = linuxHelperPackageRemovalScript(rpm: format == 'rpm');
          expect(
            script,
            contains(
              'ReClashHelperService package-uninstall --package $format',
            ),
          );
          expect(script, isNot(contains('rm -')));
          expect(script, isNot(contains('reclash-helper.service')));
          expect(script, isNot(contains('*.service')));
          for (final argument
              in format == 'deb'
                  ? ['upgrade', 'purge', 'failed-upgrade']
                  : ['1', '2']) {
            final result = await Process.run('/bin/sh', [
              '-c',
              script,
              'uninstall',
              argument,
            ]);
            expect(result.exitCode, 0, reason: argument);
            expect(result.stderr, isEmpty);
          }
        },
      );
    }

    test(
      'RPM pre-removal hook precedes post-removal and keeps upgrade guard',
      () {
        const spec =
            'Name: ReClash\n%install\ncp app %{buildroot}/usr/share/ReClash\n%post\nupdate-mime-database\n%postun\nupdate-mime-database\n%files\n/bin/ReClash\n';
        final source = withRpmHelperPackageHooks(spec);
        expect(
          source.indexOf('%preun\n'),
          lessThan(source.indexOf('%postun\n')),
        );
        expect(source, contains('[ "\$1" = 0 ] || exit 0'));
        expect(
          source,
          contains(
            "printf 'rpm\\n' > %{buildroot}%{_datadir}/%{name}/reclash-package",
          ),
        );
        expect(() => withRpmHelperPackageHooks(source), throwsFormatException);
        expect(
          () => withRpmHelperPackageHooks('Name: ReClash\n'),
          throwsFormatException,
        );
      },
    );
  });

  test('every Linux package names the GTK application id as its window '
      'class', () {
    final applicationId = RegExp(
      r'set\(APPLICATION_ID "([^"]+)"\)',
    ).firstMatch(File('linux/CMakeLists.txt').readAsStringSync())!.group(1);

    for (final format in ['deb', 'rpm', 'appimage', 'pacman']) {
      final config =
          loadYaml(
                File(
                  'linux/packaging/$format/make_config.yaml',
                ).readAsStringSync(),
              )
              as YamlMap;
      expect(config['startup_wm_class'], applicationId, reason: format);
    }
  });

  test('rpm keeps the Core bytes the Helper was built against', () {
    final config =
        loadYaml(
              File('linux/packaging/rpm/make_config.yaml').readAsStringSync(),
            )
            as YamlMap;
    final macros = (config['spec_macros'] as YamlList).cast<String>();

    expect(macros, contains('%global debug_package %{nil}'));
    expect(macros, contains('%global __os_install_post %{nil}'));
  });
}
