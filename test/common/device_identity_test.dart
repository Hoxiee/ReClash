import 'dart:io';

import 'package:reclash/common/device_identity.dart';
import 'package:reclash/common/path.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceIdentity.hwidFromSource', () {
    test('is stable for the same source', () {
      expect(
        DeviceIdentity.hwidFromSource('device-1'),
        DeviceIdentity.hwidFromSource('device-1'),
      );
    });

    test('separates devices by source', () {
      expect(
        DeviceIdentity.hwidFromSource('device-1'),
        isNot(DeviceIdentity.hwidFromSource('device-2')),
      );
    });

    test('is domain separated from a bare hash of the source', () {
      final bare = DeviceIdentity.hwidFromSource('device-1');
      final salted = DeviceIdentity.hwidFromSource('reclash-device:device-1');
      expect(bare, isNot(salted));
    });
  });

  group('subscriptionHeaders', () {
    late Directory home;
    late ProviderContainer container;

    setUpAll(() {
      globalState.packageInfo = PackageInfo(
        appName: 'ReClash',
        packageName: 'reclash',
        version: '1.2.3',
        buildNumber: '1',
      );
      home = Directory.systemTemp.createTempSync('reclash-device-identity-');
      AppPath.supportDirectory = () async => home;
      AppPath.temporaryDirectory = () async => home;
      AppPath.cacheDirectory = () async => home;
      AppPath.downloadDirectory = () async => home;
    });

    tearDownAll(() {
      if (home.existsSync()) home.deleteSync(recursive: true);
    });

    setUp(() {
      container = ProviderContainer();
      globalState.container = container;
    });

    tearDown(() {
      container.dispose();
    });

    test('sends the preset user agent and device identity', () async {
      final headers = await deviceIdentity.subscriptionHeaders(
        includeDeviceIdentity: true,
      );

      expect(headers['User-Agent'], flClashXCompatUa);
      expect(headers['x-hwid'], isNotEmpty);
      expect(headers['x-device-os'], isNotEmpty);
    });

    test('falls back to the app UA when default is chosen', () async {
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(globalUa: null));

      final headers = await deviceIdentity.subscriptionHeaders(
        includeDeviceIdentity: false,
      );

      expect(headers['User-Agent'], contains('ReClash/v1.2.3'));
      expect(headers.containsKey('x-hwid'), isFalse);
    });

    test('prefers the configured user agent', () async {
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(globalUa: 'custom-agent/2.0'));

      final headers = await deviceIdentity.subscriptionHeaders(
        includeDeviceIdentity: false,
      );

      expect(headers['User-Agent'], 'custom-agent/2.0');
      expect(headers.containsKey('x-hwid'), isFalse);
    });
  });
}
