import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/client_emulation.dart';
import 'package:reclash/common/device_identity.dart';
import 'package:reclash/enum/enum.dart';

DeviceIdentityInfo details() => const DeviceIdentityInfo(
      hwid: 'HWID1234',
      os: 'Android',
      osVersion: '16',
      model: 'Pixel 9',
    );

void main() {
  group('probeOrder', () {
    test('a pinned preset is tried alone', () {
      for (final client in SubscriptionClient.values) {
        if (client == SubscriptionClient.auto) continue;
        expect(probeOrder(client), [client], reason: client.name);
      }
    });

    test('auto probes clash, happ, incy, singbox', () {
      expect(probeOrder(SubscriptionClient.auto), [
        SubscriptionClient.clash,
        SubscriptionClient.happ,
        SubscriptionClient.incy,
        SubscriptionClient.singbox,
      ]);
    });

    test('the remembered working preset comes first without duplicating', () {
      expect(
        probeOrder(SubscriptionClient.auto, lastWorking: SubscriptionClient.incy),
        [
          SubscriptionClient.incy,
          SubscriptionClient.clash,
          SubscriptionClient.happ,
          SubscriptionClient.singbox,
        ],
      );
      expect(probeOrder(SubscriptionClient.auto, lastWorking: SubscriptionClient.clash), [
        SubscriptionClient.clash,
        SubscriptionClient.happ,
        SubscriptionClient.incy,
        SubscriptionClient.singbox,
      ]);
    });
  });

  group('buildSubscriptionHeaders', () {
    test('clash preset sends the identity UA over the app default', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.clash,
        deviceDetails: details(),
        defaultUa: 'ReClash/v1.0.0 core/v1.19.13 Platform/android',
        identityUserAgent: 'MyCustom/UA',
      );
      expect(headers['User-Agent'], 'MyCustom/UA');
    });

    test('auto preset falls back to the default UA', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.auto,
        deviceDetails: details(),
        defaultUa: 'ReClash/v1.0.0 core/v1.19.13 Platform/android',
      );
      expect(headers['User-Agent'], 'ReClash/v1.0.0 core/v1.19.13 Platform/android');
    });

    test('a preset UA beats the identity override — it is the whole point of the preset', () {
      for (final client in [
        SubscriptionClient.happ,
        SubscriptionClient.incy,
        SubscriptionClient.v2rayng,
      ]) {
        final headers = buildSubscriptionHeaders(
          client,
          deviceDetails: details(),
          defaultUa: 'ReClash/v1.0.0',
          identityUserAgent: 'MyCustom/UA',
          customUserAgent: 'CustomPreset/UA',
        );
        expect(headers['User-Agent'], isNot(anyOf('MyCustom/UA', 'ReClash/v1.0.0')),
            reason: client.name);
      }
    });

    test('happ preset: UA only, device headers flow as today', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.happ,
        deviceDetails: details(),
      );
      expect(headers['User-Agent'], 'Happ/3.26.1');
      expect(headers['x-hwid'], 'HWID1234');
      expect(headers['x-device-os'], 'Android');
      expect(headers['x-ver-os'], '16');
      expect(headers['x-device-model'], 'Pixel 9');
    });

    test('incy preset: UA, client identity headers and locale', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.incy,
        deviceDetails: details(),
        locale: 'ru-RU',
      );
      expect(headers['User-Agent'], 'INCY/3.3.1/Android');
      expect(headers['x-client'], 'INCY');
      expect(headers['x-app-version'], '3.3.1');
      expect(headers['x-device-locale'], 'ru-RU');
      expect(headers['Accept-Language'], 'ru-RU');
    });

    test('v2rayng preset: UA only', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.v2rayng,
        deviceDetails: details(),
      );
      expect(headers['User-Agent'], 'v2rayNG/1.9.24');
      expect(headers, isNot(contains('x-client')));
    });

    test('singbox preset: Karing UA only', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.singbox,
        deviceDetails: details(),
      );
      expect(headers['User-Agent'], 'Karing/1.0.0');
      expect(headers, isNot(contains('x-client')));
    });

    test('custom preset uses the profile text, empty falls back to the default', () {
      expect(
        buildSubscriptionHeaders(
          SubscriptionClient.custom,
          deviceDetails: details(),
          customUserAgent: 'Whatever/1.2',
        )['User-Agent'],
        'Whatever/1.2',
      );
      expect(
        buildSubscriptionHeaders(
          SubscriptionClient.custom,
          deviceDetails: details(),
          customUserAgent: '',
          defaultUa: 'ReClash/v1.0.0',
        )['User-Agent'],
        'ReClash/v1.0.0',
      );
    });

    test('sendDeviceHeaders=false drops the whole device-header family', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.happ,
        deviceDetails: details(),
        sendDeviceHeaders: false,
      );
      expect(headers['User-Agent'], 'Happ/3.26.1');
      for (final name in ['x-hwid', 'x-device-os', 'x-ver-os', 'x-device-model']) {
        expect(headers, isNot(contains(name)), reason: name);
      }
    });
  });
}
