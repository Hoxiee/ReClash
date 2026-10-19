import 'dart:io';

import 'package:reclash/core/desktop/core_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('reclash_manifest_test_');
  });

  tearDown(() {
    directory.deleteSync(recursive: true);
  });

  test('reads the Core SHA256 from the runtime manifest', () async {
    const hash =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    final file = File('${directory.path}/manifest.json')
      ..writeAsStringSync('{"coreSha256":"$hash"}');

    expect(await CoreManifest.readCoreSha256(path: file.path), hash);
  });

  test('reads final Helper integrity independently of the Core hash', () async {
    final core = '0' * 64;
    final helper = '1' * 64;
    final file = File('${directory.path}/manifest.json')
      ..writeAsStringSync(
        '{'
        '"coreSha256":"$core",'
        '"helperSha256":"$helper"'
        '}',
      );
    expect(await CoreManifest.readCoreSha256(path: file.path), core);
    expect(await CoreManifest.readHelperSha256(path: file.path), helper);
    file.writeAsStringSync(
      '{'
      '"coreSha256":"$core",'
      '"helperSha256":"INVALID"'
      '}',
    );
    expect(await CoreManifest.readHelperSha256(path: file.path), isNull);
    expect(await CoreManifest.readCoreSha256(path: file.path), core);
  });

  test('rejects malformed or non-SHA256 manifest values', () async {
    final file = File('${directory.path}/manifest.json')
      ..writeAsStringSync('{"coreSha256":"not-a-sha256"}');

    expect(await CoreManifest.readCoreSha256(path: file.path), isNull);
  });

  test('returns null when the manifest is missing', () async {
    expect(
      await CoreManifest.readCoreSha256(
        path: '${directory.path}/missing-manifest.json',
      ),
      isNull,
    );
  });
}
