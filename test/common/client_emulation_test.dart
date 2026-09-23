import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/config/client_emulation.dart';
import 'package:reclash/common/app/device_identity.dart';
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

    test('auto probes every compatible client format', () {
      expect(probeOrder(SubscriptionClient.auto), [
        SubscriptionClient.clashMeta,
        SubscriptionClient.clash,
        SubscriptionClient.happ,
        SubscriptionClient.incy,
        SubscriptionClient.singbox,
        SubscriptionClient.v2rayng,
      ]);
    });

    test('the remembered working preset comes first without duplicating', () {
      expect(
        probeOrder(
          SubscriptionClient.auto,
          lastWorking: SubscriptionClient.incy,
        ),
        [
          SubscriptionClient.incy,
          SubscriptionClient.clashMeta,
          SubscriptionClient.clash,
          SubscriptionClient.happ,
          SubscriptionClient.singbox,
          SubscriptionClient.v2rayng,
        ],
      );
      expect(
        probeOrder(
          SubscriptionClient.auto,
          lastWorking: SubscriptionClient.clash,
        ),
        [
          SubscriptionClient.clash,
          SubscriptionClient.clashMeta,
          SubscriptionClient.happ,
          SubscriptionClient.incy,
          SubscriptionClient.singbox,
          SubscriptionClient.v2rayng,
        ],
      );
    });
  });

  group('isNativeSubscriptionClient', () {
    test('the clash family needs no conversion', () {
      for (final client in [
        SubscriptionClient.auto,
        SubscriptionClient.clashMeta,
        SubscriptionClient.clash,
      ]) {
        expect(isNativeSubscriptionClient(client), isTrue, reason: client.name);
      }
    });

    test('every emulated preset is flagged, custom included', () {
      for (final client in [
        SubscriptionClient.happ,
        SubscriptionClient.incy,
        SubscriptionClient.singbox,
        SubscriptionClient.v2rayng,
        SubscriptionClient.custom,
      ]) {
        expect(
          isNativeSubscriptionClient(client),
          isFalse,
          reason: client.name,
        );
      }
    });
  });

  group('buildSubscriptionHeaders', () {
    test('clash meta preset sends a mihomo-era UA', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.clashMeta,
        deviceDetails: details(),
        defaultUa: 'ReClash/v1.0.0 core/v1.19.13 Platform/android',
      );
      expect(headers['User-Agent'], metaClashUserAgent);
      expect(headers['User-Agent'], isNot(legacyClashUserAgent));
    });

    test('clash preset sends a legacy Clash UA', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.clash,
        deviceDetails: details(),
        defaultUa: 'ReClash/v1.0.0 core/v1.19.13 Platform/android',
        identityUserAgent: 'MyCustom/UA',
      );
      expect(headers['User-Agent'], legacyClashUserAgent);
    });

    test('auto preset falls back to the default UA', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.auto,
        deviceDetails: details(),
        defaultUa: 'ReClash/v1.0.0 core/v1.19.13 Platform/android',
      );
      expect(
        headers['User-Agent'],
        'ReClash/v1.0.0 core/v1.19.13 Platform/android',
      );
    });

    test(
      'a preset UA beats the identity override — it is the whole point of the preset',
      () {
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
          expect(
            headers['User-Agent'],
            isNot(anyOf('MyCustom/UA', 'ReClash/v1.0.0')),
            reason: client.name,
          );
        }
      },
    );

    test('happ preset omits device headers by default', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.happ,
        deviceDetails: details(),
      );
      expect(headers['User-Agent'], 'Happ/3.26.1');
      expect(headers, isNot(contains('x-hwid')));
      expect(headers, isNot(contains('x-device-os')));
      expect(headers, isNot(contains('x-ver-os')));
      expect(headers, isNot(contains('x-device-model')));
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

    test(
      'custom preset uses the profile text, empty falls back to the default',
      () {
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
      },
    );

    test('sendDeviceHeaders=true adds the whole device-header family', () {
      final headers = buildSubscriptionHeaders(
        SubscriptionClient.happ,
        deviceDetails: details(),
        sendDeviceHeaders: true,
      );
      expect(headers['User-Agent'], 'Happ/3.26.1');
      expect(headers['x-hwid'], 'HWID1234');
      expect(headers['x-device-os'], 'Android');
      expect(headers['x-ver-os'], '16');
      expect(headers['x-device-model'], 'Pixel 9');
    });

    test('device headers can be added to an already built request', () {
      final headers = withDeviceIdentityHeaders(
        buildSubscriptionHeaders(
          SubscriptionClient.clashMeta,
          deviceDetails: details(),
        ),
        details(),
      );
      expect(headers['User-Agent'], metaClashUserAgent);
      expect(headers['x-hwid'], 'HWID1234');
      expect(headers['x-device-model'], 'Pixel 9');
    });

    test('a User-Agent alone does not imply device-header consent', () {
      expect(hasDeviceIdentityHeaders({'User-Agent': 'ReClash/1.0'}), isFalse);
      expect(
        hasDeviceIdentityHeaders({'User-Agent': 'ReClash/1.0', 'x-hwid': 'a'}),
        isTrue,
      );
    });
  });
}
