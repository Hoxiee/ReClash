import 'dart:io';

import 'package:reclash/common/config/protocol.dart';
import 'package:reclash/common/subscription/subscription_links.dart';
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

  test('the android manifest declares only exact supported pairs', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    final declared = <(String, String)>{};
    final filters = RegExp(
      r'<intent-filter>(.*?)</intent-filter>',
      dotAll: true,
    ).allMatches(manifest);

    for (final filter in filters) {
      final body = filter.group(1)!;
      final schemes = RegExp(
        r'android:scheme="([^"]+)"',
      ).allMatches(body).map((match) => match.group(1)!).toList();
      if (schemes.isEmpty) continue;
      final hosts = RegExp(
        r'android:host="([^"]+)"',
      ).allMatches(body).map((match) => match.group(1)!).toList();
      expect(schemes, hasLength(1), reason: body);
      expect(hosts, hasLength(1), reason: body);
      declared.add((schemes.single, hosts.single));
    }

    final expected = {
      for (final entry in androidProtocolHosts.entries)
        for (final host in entry.value) (entry.key, host),
    };
    expect(declared, expected);
    expect(
      declared.map((pair) => pair.$1),
      isNot(contains(anyOf(shareProtocolSchemes))),
    );
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
