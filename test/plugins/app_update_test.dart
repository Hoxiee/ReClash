import 'package:reclash/common/constant.dart';
import 'package:reclash/plugins/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('$packageName/app');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('verification carries expected APK identity and SHA-256', () async {
    MethodCall? received;
    messenger.setMockMethodCallHandler(channel, (call) async {
      received = call;
      return null;
    });

    await App().verifyUpdateApk(
      '/updates/update-v1.apk',
      expectedVersion: 'v1.0.1',
      expectedSha256: 'a' * 64,
    );

    expect(received?.method, 'verifyUpdateApk');
    expect(received?.arguments, {
      'path': '/updates/update-v1.apk',
      'version': 'v1.0.1',
      'sha256': 'a' * 64,
    });
  });

  test('manual installation never requests no-confirmation policy', () async {
    MethodCall? received;
    messenger.setMockMethodCallHandler(channel, (call) async {
      received = call;
      return 'started';
    });

    final result = await App().installApk(
      '/updates/update-v1.apk',
      expectedVersion: 'v1.0.1',
      expectedSha256: 'b' * 64,
    );

    expect(result, ApkInstallResult.started);
    expect(received?.arguments, {
      'path': '/updates/update-v1.apk',
      'version': 'v1.0.1',
      'sha256': 'b' * 64,
      'automatic': false,
    });
  });

  test(
    'automatic consent is forwarded without claiming installation success',
    () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return 'started';
      });

      expect(
        await App().installApk(
          '/updates/update-v1.apk',
          expectedVersion: 'v1.0.1',
          expectedSha256: 'b' * 64,
          automatic: true,
        ),
        ApkInstallResult.started,
      );
      expect(received?.arguments['automatic'], true);
    },
  );

  test('permission and VPN blocks remain distinct results', () async {
    for (final result in {
      'permissionRequired': ApkInstallResult.permissionRequired,
      'vpnActive': ApkInstallResult.vpnActive,
    }.entries) {
      messenger.setMockMethodCallHandler(channel, (_) async => result.key);
      expect(
        await App().installApk(
          '/updates/update-v1.apk',
          expectedVersion: 'v1.0.1',
          expectedSha256: 'b' * 64,
        ),
        result.value,
      );
    }
  });

  test('invalid native install result is not treated as success', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => 'installed');
    await expectLater(
      App().installApk(
        '/updates/update-v1.apk',
        expectedVersion: 'v1.0.1',
        expectedSha256: 'b' * 64,
      ),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'INVALID_INSTALL_RESULT',
        ),
      ),
    );
  });

  test('native verification failure propagates to updater owner', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'APK_INVALID');
    });
    await expectLater(
      App().verifyUpdateApk(
        '/updates/update-v1.apk',
        expectedVersion: 'v1.0.1',
        expectedSha256: 'b' * 64,
      ),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'APK_INVALID',
        ),
      ),
    );
  });

  test('missing permission and service answers fail closed', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect(await App().canRequestPackageInstalls(), false);
    expect(await App().updateInstallBlockedByVpn(), true);
    expect(await App().openUpdateInstallPermission(), false);
    expect(await App().continueUpdateInstall(), false);
  });

  test(
    'permission settings and system confirmation open only by dedicated calls',
    () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return true;
      });
      expect(await App().openUpdateInstallPermission(), true);
      expect(await App().continueUpdateInstall(), true);
      expect(calls, ['openUpdateInstallPermission', 'continueUpdateInstall']);
    },
  );

  test(
    'installed version is read freshly from Android, not PackageInfo cache',
    () async {
      var version = '1.0.0';
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'updateInstalledVersion');
        return version;
      });
      expect(await App().updateInstalledVersion(), '1.0.0');
      version = '1.0.1';
      expect(await App().updateInstalledVersion(), '1.0.1');
      messenger.setMockMethodCallHandler(channel, (_) async => null);
      await expectLater(
        App().updateInstalledVersion(),
        throwsA(isA<PlatformException>()),
      );
    },
  );

  test('every persisted native installer status is preserved', () async {
    for (final status in ApkInstallStatus.values) {
      messenger.setMockMethodCallHandler(channel, (_) async => status.name);
      expect(await App().updateInstallStatus(), status);
    }
  });

  test(
    'invalid native installer status fails instead of inventing completion',
    () async {
      messenger.setMockMethodCallHandler(channel, (_) async => 'unknown');
      await expectLater(
        App().updateInstallStatus(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'INVALID_INSTALL_STATUS',
          ),
        ),
      );
    },
  );

  test(
    'private native callback reaches only subscribed update listeners',
    () async {
      final app = App();
      final statuses = <ApkInstallStatus>[];
      final subscription = app.updateInstallChanges.listen(statuses.add);
      addTearDown(subscription.cancel);

      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('updateInstallChanged', 'awaitingConfirmation'),
        ),
        (_) {},
      );
      await pumpEventQueue();
      expect(statuses, [ApkInstallStatus.awaitingConfirmation]);

      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('updateInstallChanged', 'success'),
        ),
        (_) {},
      );
      await pumpEventQueue();
      expect(statuses, [
        ApkInstallStatus.awaitingConfirmation,
        ApkInstallStatus.success,
      ]);
    },
  );
}
