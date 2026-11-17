import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/update_manifest.dart';

final _seed = List<int>.generate(32, (index) => index + 1);
final _otherSeed = List<int>.generate(32, (index) => 100 + index);
final _hash = 'ab' * 32;
final _otherHash = 'cd' * 32;

Future<Map<String, Object?>> _entry({
  String tag = 'v0.2.0',
  bool prerelease = false,
  String notes = 'Release notes',
  int size = 1234,
  String? sha256,
  String url = 'https://mirror.example/dl/app.apk',
  List<int>? seed,
}) async => {
  'tag': tag,
  'prerelease': prerelease,
  'notes': notes,
  'assets': [
    {'name': 'app.apk', 'size': size, 'sha256': sha256 ?? _hash, 'url': url},
  ],
  'signature': await signUpdateManifestMessage(
    updateManifestMessage(
      tag: tag,
      prerelease: prerelease,
      notes: notes,
      assets: [(name: 'app.apk', size: 1234, sha256: _hash)],
    ),
    seed ?? _seed,
  ),
};

List<int> _manifest(List<Object?> releases) =>
    utf8.encode(jsonEncode({'releases': releases}));

void main() {
  late String key;

  setUp(() async {
    key = await updateManifestPublicKey(_seed);
  });

  Future<List<Map<String, dynamic>>> parse(
    List<int> bytes, [
    List<String>? keys,
  ]) => parseUpdateManifest(bytes, keys: keys ?? [key]);

  test('valid stable and pre entries become GitHub-shaped releases', () async {
    final releases = await parse(
      _manifest([
        await _entry(),
        await _entry(tag: 'v0.3.0-pre.1', prerelease: true, notes: 'Pre'),
      ]),
    );
    expect(releases, hasLength(2));
    expect(releases.first, {
      'tag_name': 'v0.2.0',
      'prerelease': false,
      'body': 'Release notes',
      'assets': [
        {
          'name': 'app.apk',
          'size': 1234,
          'digest': 'sha256:$_hash',
          'browser_download_url': 'https://mirror.example/dl/app.apk',
        },
      ],
    });
    expect(releases.last['tag_name'], 'v0.3.0-pre.1');
    expect(releases.last['prerelease'], isTrue);
    expect(releases.last['body'], 'Pre');
  });

  group('an entry differing from what was signed is dropped', () {
    final cases = <String, Future<Map<String, Object?>> Function()>{
      'notes': () async => (await _entry())..['notes'] = 'Altered notes',
      'tag': () async => (await _entry())..['tag'] = 'v0.9.0',
      'prerelease flag': () async => (await _entry())..['prerelease'] = true,
      'asset size': () => _entry(size: 4321),
      'asset sha256': () => _entry(sha256: _otherHash),
      'http url': () => _entry(url: 'http://mirror.example/dl/app.apk'),
      'url userinfo': () => _entry(url: 'https://user:pw@mirror.example/a.apk'),
    };
    for (final MapEntry(:key, value: build) in cases.entries) {
      test(key, () async {
        final releases = await parse(
          _manifest([
            await build(),
            await _entry(tag: 'v0.4.0', notes: 'Sibling'),
          ]),
          [await updateManifestPublicKey(_seed)],
        );
        expect(releases.map((release) => release['tag_name']), ['v0.4.0']);
      });
    }
  });

  test('a manifest whose every entry fails is refused', () async {
    await expectLater(
      parse(
        _manifest([
          await _entry(notes: 'x')
            ..['notes'] = 'y',
        ]),
      ),
      throwsA(isA<UpdateManifestException>()),
    );
  });

  test('an empty release list is accepted', () async {
    expect(await parse(utf8.encode('{"releases": []}')), isEmpty);
  });

  test('malformed documents and an empty key list are refused', () async {
    for (final bytes in [
      utf8.encode('not json'),
      utf8.encode('{"other": []}'),
    ]) {
      await expectLater(parse(bytes), throwsA(isA<UpdateManifestException>()));
    }
    await expectLater(
      parse(_manifest([await _entry()]), const []),
      throwsA(isA<UpdateManifestException>()),
    );
  });

  test('a signature from another key is rejected', () async {
    await expectLater(
      parse(_manifest([await _entry(seed: _otherSeed)])),
      throwsA(isA<UpdateManifestException>()),
    );
  });

  test('any listed key may verify, so keys can rotate', () async {
    final rotated = await updateManifestPublicKey(_otherSeed);
    final releases = await parse(_manifest([await _entry(seed: _otherSeed)]), [
      key,
      rotated,
    ]);
    expect(releases, hasLength(1));
  });
}
