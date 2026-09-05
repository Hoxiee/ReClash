import 'dart:io';

import 'package:reclash/common/protocol.dart';
import 'package:reclash/common/subscription_links.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

const _packagingConfigs = [
  'linux/packaging/appimage/make_config.yaml',
  'linux/packaging/deb/make_config.yaml',
  'linux/packaging/rpm/make_config.yaml',
];

String _read(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    fail('$path no longer exists; update this test.');
  }
  return file.readAsStringSync();
}

void main() {
  test('every claimed share scheme is one the importer can read', () {
    expect(shareLinkSchemes, containsAll(shareProtocolSchemes));
  });

  test('transport-generic and foreign-client schemes stay unclaimed', () {
    final unclaimed = shareLinkSchemes
        .where((scheme) => !shareProtocolSchemes.contains(scheme))
        .toList();

    expect(unclaimed, [
      'socks',
      'socks5',
      'wireguard',
      'wg',
      'amneziawg',
      'awg',
      'vpn',
    ]);
  });

  test('no scheme is claimed twice', () {
    expect(allProtocolSchemes.toSet(), hasLength(allProtocolSchemes.length));
  });

  test('the android manifest declares every claimed scheme', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    final declared = RegExp(
      r'android:scheme="([^"]+)"',
    ).allMatches(manifest).map((match) => match.group(1)).toSet();

    expect(declared, containsAll(allProtocolSchemes));
  });

  test('no scheme filter pins a host', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    final filters = RegExp(
      r'<intent-filter>(.*?)</intent-filter>',
      dotAll: true,
    ).allMatches(manifest);

    for (final filter in filters) {
      final body = filter.group(1)!;
      if (!body.contains('android:scheme')) continue;
      expect(
        body,
        isNot(contains('android:host')),
        reason: 'a pinned host drops every deep link addressed to another one',
      );
    }
  });

  test('the macos bundle declares every claimed scheme', () {
    final plist = _read('macos/Runner/Info.plist');
    final missing = allProtocolSchemes
        .where((scheme) => !plist.contains('<string>$scheme</string>'))
        .toList();

    expect(missing, isEmpty);
  });

  test('the linux packages hand every claimed scheme to xdg', () {
    final expected = allProtocolSchemes
        .map((scheme) => 'x-scheme-handler/$scheme')
        .toSet();

    for (final path in _packagingConfigs) {
      final config = loadYaml(_read(path)) as Map;
      final declared = (config['supported_mime_type'] as List?)?.cast<String>();

      expect(declared?.toSet(), expected, reason: path);
    }
  });
}
