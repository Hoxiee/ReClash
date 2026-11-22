import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';

void main() {
  group('shouldShowPreReleaseNotice', () {
    test('shows once on an unacknowledged pre build', () {
      expect(
        shouldShowPreReleaseNotice(
          appEnv: 'pre',
          version: '0.1.0-pre.13',
          acknowledgedVersion: null,
        ),
        isTrue,
      );
      expect(
        shouldShowPreReleaseNotice(
          appEnv: 'pre',
          version: '0.1.0-pre.13',
          acknowledgedVersion: '0.1.0-pre.12',
        ),
        isTrue,
      );
    });

    test('hides after the same version was acknowledged', () {
      expect(
        shouldShowPreReleaseNotice(
          appEnv: 'pre',
          version: '0.1.0-pre.13',
          acknowledgedVersion: '0.1.0-pre.13',
        ),
        isFalse,
      );
    });

    test('ignores stable and dev environments', () {
      for (final env in ['stable', 'dev', '']) {
        expect(
          shouldShowPreReleaseNotice(
            appEnv: env,
            version: '0.1.0-pre.13',
            acknowledgedVersion: null,
          ),
          isFalse,
          reason: env,
        );
      }
    });

    test('ignores stable and malformed versions on the pre environment', () {
      for (final version in ['0.1.0', '0.1.0+build', 'nightly']) {
        expect(
          shouldShowPreReleaseNotice(
            appEnv: 'pre',
            version: version,
            acknowledgedVersion: null,
          ),
          isFalse,
          reason: version,
        );
      }
    });

    test('shows again when another pre version is installed', () {
      expect(
        shouldShowPreReleaseNotice(
          appEnv: 'pre',
          version: '0.1.0-pre.14',
          acknowledgedVersion: '0.1.0-pre.13',
        ),
        isTrue,
      );
    });
  });
}
