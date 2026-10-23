import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_release_assets.dart';

void main() {
  late Directory dist;
  const version = '0.1.0-pre.1';

  setUp(() {
    dist = Directory.systemTemp.createTempSync('reclash-assets-');
    for (final name in releaseAssetNames(version)) {
      File('${dist.path}/$name').writeAsStringSync('package');
    }
  });
  tearDown(() => dist.deleteSync(recursive: true));

  test('manifest covers all sixteen platform packages', () {
    final names = releaseAssetNames(version);
    expect(names, hasLength(16));
    expect(names.toSet(), hasLength(16));
    expect(names, contains('ReClash-$version-linux-arm64.pkg.tar.xz'));
    expect(names, contains('ReClash-$version-windows-arm64-setup.exe'));
    expect(() => checkReleaseAssets(dist, version), returnsNormally);
  });

  test('missing package fails', () {
    File('${dist.path}/${releaseAssetNames(version).first}').deleteSync();
    expect(() => checkReleaseAssets(dist, version), throwsFormatException);
  });

  test('unexpected package fails', () {
    File('${dist.path}/stale.zip').writeAsStringSync('stale');
    expect(() => checkReleaseAssets(dist, version), throwsFormatException);
  });

  test('empty package fails', () {
    File(
      '${dist.path}/${releaseAssetNames(version).first}',
    ).writeAsStringSync('');
    expect(() => checkReleaseAssets(dist, version), throwsFormatException);
  });

  test('directory cannot stand in for a package', () {
    final path = '${dist.path}/${releaseAssetNames(version).first}';
    File(path).deleteSync();
    Directory(path).createSync();
    expect(() => checkReleaseAssets(dist, version), throwsFormatException);
  });

  test('symlink cannot stand in for a package', () {
    final path = '${dist.path}/${releaseAssetNames(version).first}';
    File(path).deleteSync();
    Link(path).createSync(releaseAssetNames(version).last);
    expect(() => checkReleaseAssets(dist, version), throwsFormatException);
  }, skip: Platform.isWindows ? 'Symlink creation requires privileges' : false);
}
