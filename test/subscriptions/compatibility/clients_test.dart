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

    test('uses the FlClashX 0.4.2 user-agent', () {
      expect(
        subscriptionClientRequestHeaders(
          SubscriptionClientPreset.flClashX,
          defaultUserAgent: 'ReClash/test',
        ),
        {'User-Agent': 'FlClashX/0.4.2'},
      );
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
