import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/common/app/package.dart';
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

  group('selectUpdateRelease', () {
    Map<String, dynamic> release(
      String tag, {
      bool prerelease = false,
      bool draft = false,
      String? body = releaseEpochMarker,
    }) => {
      'tag_name': tag,
      'prerelease': prerelease,
      'draft': draft,
      'body': body,
    };

    String? pick(
      List<Map<String, dynamic>> releases, {
      required String installed,
      bool acceptPrereleases = false,
    }) =>
        selectUpdateRelease(
              releases,
              installedVersion: installed,
              acceptPrereleases: acceptPrereleases,
            )?['tag_name']
            as String?;

    test('picks the highest eligible version regardless of list order', () {
      final result = pick([
        release('v0.1.1'),
        release('v0.3.0'),
        release('v0.2.0'),
      ], installed: '0.1.0');
      expect(result, 'v0.3.0');
    });

    test('a prerelease build steps onto the finished stable release', () {
      final result = pick([
        release('v0.1.0-pre.3', prerelease: true),
        release('v0.1.0'),
      ], installed: '0.1.0-pre.2');
      expect(result, 'v0.1.0');
    });

    test(
      'a prerelease build takes a newer prerelease when it is the newest',
      () {
        final result = pick([
          release('v0.1.0-pre.3', prerelease: true),
        ], installed: '0.1.0-pre.2');
        expect(result, 'v0.1.0-pre.3');
      },
    );

    test('a stable build ignores prereleases by default', () {
      final result = pick([
        release('v0.2.0-pre.1', prerelease: true),
      ], installed: '0.1.0');
      expect(result, isNull);
    });

    test('a stable build takes a prerelease once the user opts in', () {
      final result = pick(
        [release('v0.2.0-pre.1', prerelease: true)],
        installed: '0.1.0',
        acceptPrereleases: true,
      );
      expect(result, 'v0.2.0-pre.1');
    });

    test('a stable build always takes a newer stable release', () {
      final result = pick([release('v0.2.0')], installed: '0.1.0');
      expect(result, 'v0.2.0');
    });

    test('honors GitHub prerelease flag on a stable-looking tag', () {
      expect(
        pick([release('v0.2.0', prerelease: true)], installed: '0.1.0'),
        isNull,
      );
      expect(
        pick(
          [release('v0.2.0', prerelease: true)],
          installed: '0.1.0',
          acceptPrereleases: true,
        ),
        'v0.2.0',
      );
    });

    test('skips drafts, missing epoch markers, and non-newer versions', () {
      expect(
        pick([release('v0.2.0', draft: true)], installed: '0.1.0'),
        isNull,
      );
      expect(
        pick([release('v0.2.0', body: 'no marker')], installed: '0.1.0'),
        isNull,
      );
      expect(pick([release('v0.1.0')], installed: '0.1.0'), isNull);
    });
  });
}
