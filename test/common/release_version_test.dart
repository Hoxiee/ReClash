import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/common/package.dart';
import 'package:test/test.dart';

void main() {
  test('compares prereleases numerically before the final release', () {
    expect(compareVersions('0.1.0-pre.2', '0.1.0-pre.1'), greaterThan(0));
    expect(compareVersions('0.1.0-pre.10', '0.1.0-pre.2'), greaterThan(0));
    expect(compareVersions('0.1.0', '0.1.0-pre.10'), greaterThan(0));
    expect(compareVersions('0.1.0-pre.1', '0.1.0'), lessThan(0));
  });

  test('restores public metadata after Apple native normalization', () {
    final native = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '0.1.0',
      buildNumber: '2609.15.1',
      buildSignature: 'signature',
    );
    final release = releasePackageInfo(
      native,
      version: '0.1.0-pre.1',
      buildNumber: '2026091501',
    );
    expect(release.version, '0.1.0-pre.1');
    expect(release.buildNumber, '2026091501');
    expect(release.packageName, native.packageName);
    expect(release.buildSignature, native.buildSignature);
    expect(releasePackageInfo(native).version, native.version);
  });

  test('never offers legacy 0.8 releases after the version reset', () {
    expect(
      isNewerAppRelease(
        remoteVersion: 'v0.8.97',
        installedVersion: '0.1.0-pre.1',
        body: 'Legacy release',
      ),
      isFalse,
    );
    expect(
      isNewerAppRelease(
        remoteVersion: 'v0.1.0',
        installedVersion: '0.1.0-pre.1',
        body: releaseEpochMarker,
      ),
      isTrue,
    );
    expect(
      isNewerAppRelease(
        remoteVersion: 'v0.1.0',
        installedVersion: '0.1.0',
        body: releaseEpochMarker,
      ),
      isFalse,
    );
    expect(
      File('.github/release_template.md').readAsStringSync(),
      contains(releaseEpochMarker),
    );
  });
}
