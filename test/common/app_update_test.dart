import 'dart:io';

import 'package:path/path.dart';
import 'package:reclash/common/common.dart';
import 'package:test/test.dart';

Map<String, Object?> asset(String name, {String? digest, int? size}) => {
  'name': name,
  'browser_download_url': 'https://updates.example/$name',
  'digest': ?digest,
  'size': ?size,
};

void main() {
  group('selectAndroidUpdateAsset', () {
    test('prefers the first supported ABI', () {
      final selected = selectAndroidUpdateAsset(
        [
          asset('ReClash-1.0-android-armeabi-v7a.apk'),
          asset('ReClash-1.0-android-arm64-v8a.apk'),
        ],
        supportedAbis: const ['arm64-v8a', 'armeabi-v7a'],
      );
      expect(selected?.name, 'ReClash-1.0-android-arm64-v8a.apk');
    });

    test('uses universal or a single unambiguous APK as fallback', () {
      expect(
        selectAndroidUpdateAsset(
          [asset('ReClash-android-universal.apk')],
          supportedAbis: const ['x86_64'],
        )?.name,
        'ReClash-android-universal.apk',
      );
      expect(
        selectAndroidUpdateAsset(
          [asset('ReClash.apk')],
          supportedAbis: const ['arm64-v8a'],
        )?.name,
        'ReClash.apk',
      );
    });

    test('rejects ambiguous assets for unsupported ABIs', () {
      expect(
        selectAndroidUpdateAsset(
          [
            asset('ReClash-android-x86.apk'),
            asset('ReClash-android-x86_64.apk'),
          ],
          supportedAbis: const ['arm64-v8a'],
        ),
        isNull,
      );
    });
  });

  group('APK SHA-256 validation', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('reclash-update-');
    });

    tearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    test('parses only valid SHA-256 digests', () {
      expect(parseAssetSha256('sha256:${'a' * 64}'), 'a' * 64);
      expect(parseAssetSha256('sha512:${'a' * 128}'), isNull);
      expect(parseAssetSha256('sha256:${'a' * 63}'), isNull);
      expect(parseAssetSha256(null), isNull);
    });

    test('accepts only a byte-for-byte matching file and digest', () async {
      final file = File(join(directory.path, 'update-v1.apk'));
      await file.writeAsString('apk bytes');
      final digest = await fileSha256(file);
      expect(
        await matchesUpdateAsset(
          file,
          AndroidUpdateAsset(name: 'v1.apk', url: '', sha256: digest),
        ),
        isTrue,
      );
      expect(
        await matchesUpdateAsset(
          file,
          AndroidUpdateAsset(name: 'v1.apk', url: '', sha256: '0' * 64),
        ),
        isFalse,
      );
      expect(
        await matchesUpdateAsset(
          file,
          const AndroidUpdateAsset(name: 'v1.apk', url: ''),
        ),
        isFalse,
      );
      expect(
        await matchesUpdateAsset(
          file,
          AndroidUpdateAsset(name: 'v1.apk', url: '', size: 1, sha256: digest),
        ),
        isFalse,
      );
    });
  });

  test(
    'GC retains one cache entry and removes temporary and stale files',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'reclash-update-gc-',
      );
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      for (final name in [
        'update-v1.apk',
        'update-v2.apk',
        'update-v2.apk.tmp',
        'pending-install.json',
        'database.sqlite',
      ]) {
        await File(join(directory.path, name)).writeAsString('data');
      }

      await removeStaleUpdateApks(directory, keep: {'update-v1.apk'});

      expect(
        await File(join(directory.path, 'update-v1.apk')).exists(),
        isTrue,
      );
      expect(
        await File(join(directory.path, 'update-v2.apk')).exists(),
        isFalse,
      );
      expect(
        await File(join(directory.path, 'update-v2.apk.tmp')).exists(),
        isFalse,
      );
      expect(
        await File(join(directory.path, 'pending-install.json')).exists(),
        isTrue,
      );
      expect(
        await File(join(directory.path, 'database.sqlite')).exists(),
        isTrue,
      );
    },
  );

  test(
    'GC keeps the most recently modified APK when no install is pending',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'reclash-update-latest-',
      );
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final older = File(join(directory.path, 'update-v1.apk'));
      final latest = File(join(directory.path, 'update-v2.apk'));
      await older.writeAsString('old');
      await latest.writeAsString('new');
      final now = DateTime.now();
      await older.setLastModified(now.subtract(const Duration(days: 1)));
      await latest.setLastModified(now);

      await removeStaleUpdateApks(directory);

      expect(await older.exists(), isFalse);
      expect(await latest.exists(), isTrue);
    },
  );

  test(
    'GC preserves only the explicitly retained partial and metadata',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'reclash-update-partial-',
      );
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      for (final name in [
        'update-pending.apk',
        'update-next.apk.tmp',
        'update-next.apk.tmp.json',
        'update-stale.apk.tmp',
        'update-stale.apk.tmp.json',
        'update-stale.apk.tmp.json.123.tmp',
        'pending-install.json',
        'database.sqlite',
      ]) {
        await File(join(directory.path, name)).writeAsString('data');
      }
      await removeStaleUpdateApks(
        directory,
        keep: {'update-pending.apk'},
        keepPartial: {'update-next.apk'},
      );
      for (final name in [
        'update-pending.apk',
        'update-next.apk.tmp',
        'update-next.apk.tmp.json',
        'pending-install.json',
        'database.sqlite',
      ]) {
        expect(
          await File(join(directory.path, name)).exists(),
          isTrue,
          reason: name,
        );
      }
      for (final name in [
        'update-stale.apk.tmp',
        'update-stale.apk.tmp.json',
        'update-stale.apk.tmp.json.123.tmp',
      ]) {
        expect(
          await File(join(directory.path, name)).exists(),
          isFalse,
          reason: name,
        );
      }
    },
  );

  test('sanitizes release tags for update cache filenames', () {
    expect(updateApkFileName('v1.2.3'), 'update-v1.2.3.apk');
    expect(updateApkFileName('../v1 beta'), 'update-.._v1_beta.apk');
  });
}
