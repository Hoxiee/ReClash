import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';

void main() {
  group('subscriptionClientRequestHeaders', () {
    test('uses the configured default identity for ReClash', () {
      expect(
        subscriptionClientRequestHeaders(
          SubscriptionClientPreset.reclash,
          defaultUserAgent: 'ReClash/test',
        ),
        {'User-Agent': 'ReClash/test'},
      );
    });

    test('names the FlClash X release, its core and the platform', () {
      expect(
        subscriptionClientRequestHeaders(
          SubscriptionClientPreset.flClashX,
          defaultUserAgent: 'ReClash/test',
          operatingSystem: 'windows',
        ),
        {'User-Agent': 'FlClash X/v0.4.2 core/v1.19.28 Platform/windows'},
      );
    });

    test(
      'builds the Happ user-agent per platform with the locale language',
      () {
        const expected = {
          'android': 'Android',
          'ios': 'iOS',
          'windows': 'Windows',
          'macos': 'macOS',
          'linux': 'Linux',
        };
        for (final MapEntry(key: os, value: name) in expected.entries) {
          expect(
            subscriptionClientRequestHeaders(
              SubscriptionClientPreset.happ,
              defaultUserAgent: 'ReClash/test',
              locale: 'ru_RU',
              operatingSystem: os,
            ),
            {
              'User-Agent': 'Happ/4.7.1/$name/17912103176801703650',
              'x-device-locale': 'ru',
            },
          );
        }
      },
    );

    test('sends no Happ locale header without a usable locale', () {
      for (final locale in [null, '', '_US']) {
        expect(
          subscriptionClientRequestHeaders(
            SubscriptionClientPreset.happ,
            defaultUserAgent: 'ReClash/test',
            locale: locale,
            operatingSystem: 'android',
          ).keys,
          ['User-Agent'],
        );
      }
    });

    test('pins the released versions of the other client presets', () {
      String agent(SubscriptionClientPreset preset) =>
          subscriptionClientRequestHeaders(
            preset,
            defaultUserAgent: 'ReClash/test',
            operatingSystem: 'android',
          )['User-Agent']!;
      expect(
        agent(SubscriptionClientPreset.clashMeta),
        'ClashMetaForAndroid/2.11.36.Meta',
      );
      expect(agent(SubscriptionClientPreset.v2rayng), 'v2rayNG/2.3.11');
      expect(agent(SubscriptionClientPreset.singbox), 'Karing/1.2.25.2802');
    });

    test('keeps INCY client headers separate from device identity', () {
      expect(
        subscriptionClientRequestHeaders(
          SubscriptionClientPreset.incy,
          defaultUserAgent: 'ReClash/test',
          locale: 'en-US',
        ),
        {
          'User-Agent': 'INCY/3.3.1',
          'x-client': 'INCY',
          'x-app-version': '3.3.1',
          'x-device-locale': 'en-US',
          'Accept-Language': 'en-US',
        },
      );
    });

    test('trims and uses custom user-agent text', () {
      expect(
        subscriptionClientRequestHeaders(
          SubscriptionClientPreset.custom,
          defaultUserAgent: 'ReClash/test',
          customUserAgent: '  panel-client/1  ',
        ),
        {'User-Agent': 'panel-client/1'},
      );
    });

    test('refuses an invalid custom value before sending a request', () {
      expect(
        () => subscriptionClientRequestHeaders(
          SubscriptionClientPreset.custom,
          defaultUserAgent: 'ReClash/test',
        ),
        throwsFormatException,
      );
    });

    test('validates custom user-agent input before requesting', () {
      expect(validateCustomSubscriptionUserAgent('  '), 'empty');
      expect(
        validateCustomSubscriptionUserAgent('agent\r\nInjected: yes'),
        'controlCharacter',
      );
      expect(validateCustomSubscriptionUserAgent('a' * 513), 'tooLong');
      expect(validateCustomSubscriptionUserAgent('custom/1'), isNull);
    });

    test('returns immutable request headers', () {
      final headers = subscriptionClientRequestHeaders(
        SubscriptionClientPreset.clashMeta,
        defaultUserAgent: 'ReClash/test',
      );
      expect(() => headers['User-Agent'] = 'mutated', throwsUnsupportedError);
    });
  });
}
