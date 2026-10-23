import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';

void main() {
  group('SubscriptionClientSettings', () {
    test('defaults migrated profiles to the original ReClash request', () {
      expect(
        const SubscriptionClientSettings().preset,
        SubscriptionClientPreset.reclash,
      );
      expect(
        const SubscriptionClientSettings.forNewProfile().preset,
        SubscriptionClientPreset.auto,
      );
    });

    test('round-trips the selected preset and custom user-agent', () {
      const settings = SubscriptionClientSettings(
        preset: SubscriptionClientPreset.custom,
        customUserAgent: 'ExampleClient/2.4',
      );
      expect(
        SubscriptionClientSettings.safeFromJson(settings.toJson()).toJson(),
        settings.toJson(),
      );
    });

    test('round-trips the FlClashX preset', () {
      const settings = SubscriptionClientSettings(
        preset: SubscriptionClientPreset.flClashX,
      );
      expect(
        SubscriptionClientSettings.safeFromJson(settings.toJson()).preset,
        SubscriptionClientPreset.flClashX,
      );
    });

    test('copyWith changes one client setting at a time', () {
      const settings = SubscriptionClientSettings.forNewProfile();
      final updated = settings.copyWith(customUserAgent: 'ExampleClient/2.4');
      expect(updated.preset, SubscriptionClientPreset.auto);
      expect(updated.customUserAgent, 'ExampleClient/2.4');
    });

    test(
      'salvages unknown or malformed stored values to the native default',
      () {
        for (final value in [
          null,
          'auto',
          {'preset': 'missing'},
          {'preset': 'custom', 'customUserAgent': 12},
          {'preset': 'custom', 'customUserAgent': 'x' * 513},
        ]) {
          expect(
            SubscriptionClientSettings.safeFromJson(value).preset,
            SubscriptionClientPreset.reclash,
          );
        }
      },
    );

    test('keeps control characters in stored settings invalid', () {
      final settings = SubscriptionClientSettings.safeFromJson({
        'preset': 'custom',
        'customUserAgent': 'agent\r\nInjected: yes',
      });
      expect(settings.preset, SubscriptionClientPreset.custom);
      expect(settings.isValid, isFalse);
    });

    test(
      'keeps an incomplete custom choice invalid until the user fixes it',
      () {
        expect(
          const SubscriptionClientSettings(
            preset: SubscriptionClientPreset.custom,
          ).isValid,
          isFalse,
        );
      },
    );
  });
}
