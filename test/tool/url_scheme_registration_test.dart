import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/protocol.dart';
import 'package:reclash/common/url_scheme.dart';
import 'package:yaml/yaml.dart';

Set<String> _androidValues(String filter, String name) => {
  for (final match in RegExp('android:$name="([^"]+)"').allMatches(filter))
    match.group(1)!,
};

void main() {
  test('Android advertises supported schemes with command-specific hosts', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final filters = RegExp(r'<intent-filter>[\s\S]*?</intent-filter>')
        .allMatches(manifest)
        .map((match) => match.group(0)!)
        .where((filter) => filter.contains('android.intent.action.VIEW'))
        .toList();
    final advertised = <String>{};
    for (final filter in filters) {
      expect(filter, contains('android.intent.category.DEFAULT'));
      expect(filter, contains('android.intent.category.BROWSABLE'));
      final schemes = _androidValues(filter, 'scheme');
      final hosts = _androidValues(filter, 'host');
      advertised.addAll(schemes);
      for (final scheme in schemes) {
        final expected = switch (scheme) {
          'reclash' => {
            for (final command in ReClashCommand.values) command.host,
          },
          'clash' || 'clashmeta' => {'install-config'},
          'incy' => {'crypt1', 'add', 'import'},
          'happ' => {'add'},
          _ => <String>{},
        };
        expect(hosts, unorderedEquals(expected), reason: scheme);
      }
    }
    expect(advertised, unorderedEquals(protocolSchemes));
    expect(
      RegExp(
        r'android:name="flutter_deeplinking_enabled"\s+android:value="false"',
      ).hasMatch(manifest),
      isTrue,
    );
    expect(manifest, contains('android:launchMode="singleTop"'));
  });

  test('macOS URL handlers match the shared scheme table', () {
    final plist = File('macos/Runner/Info.plist').readAsStringSync();
    final array = RegExp(
      r'<key>CFBundleURLSchemes</key>\s*<array>([\s\S]*?)</array>',
    ).firstMatch(plist)!.group(1)!;
    final schemes = RegExp(
      r'<string>([^<]+)</string>',
    ).allMatches(array).map((match) => match.group(1)!);
    expect(schemes, unorderedEquals(protocolSchemes));
  });

  for (final format in ['appimage', 'deb', 'rpm', 'pacman']) {
    test('$format MIME handlers match every supported scheme', () {
      final config =
          loadYaml(
                File(
                  'linux/packaging/$format/make_config.yaml',
                ).readAsStringSync(),
              )
              as Map;
      expect(
        config['supported_mime_type'],
        unorderedEquals([
          for (final scheme in protocolSchemes) 'x-scheme-handler/$scheme',
        ]),
      );
    });
  }

  test(
    'Windows uninstall lists all handlers and checks executable ownership',
    () {
      final installer = File(
        'windows/packaging/exe/inno_setup.iss',
      ).readAsStringSync();
      final entries = RegExp(
        r'Schemes := \[([^\]]+)\]',
      ).firstMatch(installer)!.group(1)!;
      final schemes = RegExp(
        "'([^']+)'",
      ).allMatches(entries).map((match) => match.group(1)!);
      expect(schemes, unorderedEquals(protocolSchemes));
      final cleanup = RegExp(
        r'procedure RemoveUserRegistrations;([\s\S]*?)function PrepareToInstall',
      ).firstMatch(installer)!.group(1)!;
      expect(cleanup, contains('and PointsIntoApp(Value) then'));
      expect(cleanup, contains(r'Software\Classes\ReClash.Url.'));
      expect(cleanup, contains(r'\OpenWithProgids'));
      expect(cleanup, contains(r'Software\ReClash\UrlHandler\URLAssociations'));
      expect(cleanup, isNot(contains(r'\UserChoice')));
    },
  );

  test(
    'runtime offers third-party handlers without claiming their defaults',
    () {
      for (final scheme in [
        ...deepLinkProtocolSchemes,
        ...shareProtocolSchemes,
      ]) {
        final plan = ProtocolRegistrationPlan(
          scheme: scheme,
          executable: 'ReClash.exe',
        );
        expect(plan.claimsDefault, isFalse, reason: scheme);
        expect(plan.progId, 'ReClash.Url.$scheme');
      }
      const linux = LinuxProtocolRegistrationPlan(
        schemes: protocolSchemes,
        executable: '/opt/ReClash',
        applicationsDir: '/tmp/applications',
      );
      expect(linux.mimeTypes, hasLength(protocolSchemes.length));
      expect(
        linux.xdgMimeArguments.skip(2),
        unorderedEquals([
          for (final scheme in configProtocolSchemes)
            'x-scheme-handler/$scheme',
        ]),
      );
    },
  );

  test('safe mode gates both desktop handler registration paths', () {
    final window = File('lib/common/window.dart').readAsStringSync();
    expect(
      RegExp(
        r'if \(!safeModeBuild\) \{\s*if \(system\.isWindows\) \{'
        r'[\s\S]*?protocol\.register\(scheme\);[\s\S]*?'
        r'if \(system\.isLinux\) \{\s*'
        r'unawaited\(protocol\.registerLinux\(protocolSchemes\)\);',
      ).hasMatch(window),
      isTrue,
    );
  });
}
