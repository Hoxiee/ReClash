import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

Map<String, Object?> asset(
  String name, {
  int? size,
  String? digest,
  String url = 'https://example.invalid/apk',
}) {
  return {
    'name': name,
    'browser_download_url': url,
    if (size != null) 'size': size,
    if (digest != null) 'digest': digest,
  };
}

void main() {
  group('matchesAndroidTarget', () {
    test('matches the versioned release naming', () {
      expect(
        matchesAndroidTarget(
          'ReClash-0.8.96-android-arm64-v8a.apk',
          'arm64-v8a',
        ),
        isTrue,
      );
    });

    test('is case insensitive', () {
      expect(
        matchesAndroidTarget(
          'ReClash-1.0.0-Android-ARM64-V8A.APK',
          'arm64-v8a',
        ),
        isTrue,
      );
    });

    test('rejects a different abi', () {
      expect(
        matchesAndroidTarget('ReClash-0.8.96-android-x86_64.apk', 'arm64-v8a'),
        isFalse,
      );
    });

    test('rejects an abi that is only a suffix of the asset abi', () {
      expect(
        matchesAndroidTarget('ReClash-0.8.96-android-arm64-v8a.apk', 'v8a'),
        isFalse,
      );
    });
  });

  group('selectAndroidUpdateAsset', () {
    test('prefers the first supported abi', () {
      final selected = selectAndroidUpdateAsset(
        [
          asset('ReClash-1.0.0-android-armeabi-v7a.apk'),
          asset('ReClash-1.0.0-android-arm64-v8a.apk'),
        ],
        supportedAbis: const ['arm64-v8a', 'armeabi-v7a'],
      );

      expect(selected?.name, 'ReClash-1.0.0-android-arm64-v8a.apk');
    });

    test('follows the device abi order rather than the asset order', () {
      final selected = selectAndroidUpdateAsset(
        [
          asset('ReClash-1.0.0-android-arm64-v8a.apk'),
          asset('ReClash-1.0.0-android-armeabi-v7a.apk'),
        ],
        supportedAbis: const ['armeabi-v7a'],
      );

      expect(selected?.name, 'ReClash-1.0.0-android-armeabi-v7a.apk');
    });

    test('falls back to the universal apk', () {
      final selected = selectAndroidUpdateAsset(
        [
          asset('ReClash-1.0.0-android-x86_64.apk'),
          asset('ReClash-1.0.0-android-universal.apk'),
        ],
        supportedAbis: const ['arm64-v8a'],
      );

      expect(selected?.name, 'ReClash-1.0.0-android-universal.apk');
    });

    test('falls back to a lone apk with no abi token', () {
      final selected = selectAndroidUpdateAsset(
        [asset('ReClash.apk'), asset('ReClash-linux-amd64.AppImage')],
        supportedAbis: const ['arm64-v8a'],
      );

      expect(selected?.name, 'ReClash.apk');
    });

    test('returns null when several apks are all unmatched', () {
      final selected = selectAndroidUpdateAsset(
        [
          asset('ReClash-1.0.0-android-x86.apk'),
          asset('ReClash-1.0.0-android-x86_64.apk'),
        ],
        supportedAbis: const ['arm64-v8a'],
      );

      expect(selected, isNull);
    });

    test('carries size and digest through', () {
      final selected = selectAndroidUpdateAsset(
        [
          asset(
            'ReClash-1.0.0-android-arm64-v8a.apk',
            size: 4096,
            digest: 'sha256:${'a' * 64}',
          ),
        ],
        supportedAbis: const ['arm64-v8a'],
      );

      expect(selected?.size, 4096);
      expect(selected?.sha256, 'a' * 64);
    });

    test('skips malformed entries', () {
      final selected = selectAndroidUpdateAsset(
        [
          'not a map',
          {'name': 'ReClash-1.0.0-android-arm64-v8a.apk'},
          {'browser_download_url': 'https://example.invalid/apk'},
          asset('ReClash-1.0.0-android-arm64-v8a.apk'),
        ],
        supportedAbis: const ['arm64-v8a'],
      );

      expect(selected?.url, 'https://example.invalid/apk');
    });

    test('returns null when assets is not a list', () {
      expect(
        selectAndroidUpdateAsset({}, supportedAbis: const ['arm64-v8a']),
        isNull,
      );
    });
  });

  group('parseAssetSha256', () {
    test('accepts a lowercase sha256 digest', () {
      expect(parseAssetSha256('sha256:${'f' * 64}'), 'f' * 64);
    });

    test('normalizes case', () {
      expect(parseAssetSha256('sha256:${'A' * 64}'), 'a' * 64);
    });

    test('rejects another algorithm', () {
      expect(parseAssetSha256('sha512:${'a' * 128}'), isNull);
    });

    test('rejects a truncated digest', () {
      expect(parseAssetSha256('sha256:${'a' * 63}'), isNull);
    });

    test('rejects a non string', () {
      expect(parseAssetSha256(42), isNull);
    });
  });

  group('updateApkFileName', () {
    test('keeps a plain tag', () {
      expect(updateApkFileName('v1.2.3'), 'update-v1.2.3.apk');
    });

    test('replaces path separators and other unsafe characters', () {
      expect(updateApkFileName('../v1 (beta)'), 'update-.._v1__beta_.apk');
    });

    test('falls back when the tag is missing', () {
      expect(updateApkFileName(''), 'update-latest.apk');
    });
  });

  group('isStaleUpdateApk', () {
    test('keeps the current download', () {
      expect(
        isStaleUpdateApk('update-v1.apk', keepFileName: 'update-v1.apk'),
        isFalse,
      );
    });

    test('drops an older download and its partial file', () {
      expect(
        isStaleUpdateApk('update-v0.apk', keepFileName: 'update-v1.apk'),
        isTrue,
      );
      expect(
        isStaleUpdateApk('update-v0.apk.tmp', keepFileName: 'update-v1.apk'),
        isTrue,
      );
    });

    test('leaves unrelated files alone', () {
      expect(
        isStaleUpdateApk('database.sqlite', keepFileName: 'update-v1.apk'),
        isFalse,
      );
      expect(
        isStaleUpdateApk('update-notes.txt', keepFileName: 'update-v1.apk'),
        isFalse,
      );
    });
  });

  group('matchesUpdateAsset', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('app_update_test');
    });

    tearDown(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    File write(String name, String content) {
      final file = File(join(root.path, name));
      file.writeAsStringSync(content);
      return file;
    }

    test('accepts a matching digest', () async {
      final file = write('update-v1.apk', 'payload');
      final digest = await fileSha256(file);

      expect(
        await matchesUpdateAsset(
          file,
          AndroidUpdateAsset(name: 'a.apk', url: 'u', size: 1, sha256: digest),
        ),
        isTrue,
      );
    });

    test('rejects a mismatching digest even when the size matches', () async {
      final file = write('update-v1.apk', 'payload');

      expect(
        await matchesUpdateAsset(
          file,
          AndroidUpdateAsset(
            name: 'a.apk',
            url: 'u',
            size: file.lengthSync(),
            sha256: 'b' * 64,
          ),
        ),
        isFalse,
      );
    });

    test('falls back to the size when no digest is published', () async {
      final file = write('update-v1.apk', 'payload');

      expect(
        await matchesUpdateAsset(
          file,
          AndroidUpdateAsset(name: 'a.apk', url: 'u', size: file.lengthSync()),
        ),
        isTrue,
      );
      expect(
        await matchesUpdateAsset(
          file,
          const AndroidUpdateAsset(name: 'a.apk', url: 'u', size: 1),
        ),
        isFalse,
      );
    });

    test('rejects when neither digest nor size is published', () async {
      final file = write('update-v1.apk', 'payload');

      expect(
        await matchesUpdateAsset(
          file,
          const AndroidUpdateAsset(name: 'a.apk', url: 'u'),
        ),
        isFalse,
      );
    });

    test('rejects a missing file', () async {
      expect(
        await matchesUpdateAsset(
          File(join(root.path, 'absent.apk')),
          const AndroidUpdateAsset(name: 'a.apk', url: 'u', size: 0),
        ),
        isFalse,
      );
    });
  });

  group('removeStaleUpdateApks', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('app_update_clean');
    });

    tearDown(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    test('removes only stale update artifacts', () async {
      final keep = join(root.path, 'update-v1.apk');
      for (final name in const [
        'update-v1.apk',
        'update-v0.apk',
        'update-v0.apk.tmp',
        'database.sqlite',
      ]) {
        File(join(root.path, name)).writeAsStringSync('x');
      }
      Directory(join(root.path, 'update-dir.apk')).createSync();

      await removeStaleUpdateApks(keep);

      expect(File(keep).existsSync(), isTrue);
      expect(File(join(root.path, 'update-v0.apk')).existsSync(), isFalse);
      expect(File(join(root.path, 'update-v0.apk.tmp')).existsSync(), isFalse);
      expect(File(join(root.path, 'database.sqlite')).existsSync(), isTrue);
      expect(Directory(join(root.path, 'update-dir.apk')).existsSync(), isTrue);
    });

    test('tolerates a missing directory', () async {
      await removeStaleUpdateApks(join(root.path, 'absent', 'update-v1.apk'));
    });
  });
}
