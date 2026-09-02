import 'package:reclash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('normalizePanelHeaders', () {
    test('maps wire keys to canonical keys case-insensitively', () {
      final map = normalizePanelHeaders({
        'X-HWID-Max-Devices-Reached': ['true'],
        'Announce': ['panel text'],
        'Support-Url': ['https://support.example.com'],
      });

      expect(map, {
        'hwidMaxDevicesReached': 'true',
        'announce': 'panel text',
        'supportUrl': 'https://support.example.com',
      });
    });

    test('reclash namespace outranks compatibility headers', () {
      final map = normalizePanelHeaders({
        'reclash-autoupdateinterval': ['30'],
        'profile-update-interval': ['5'],
        'reclash-supporturl': ['https://reclash.example.com'],
        'flclashx-supporturl': ['https://flclashx.example.com'],
      });

      expect(map['updateIntervalMinutes'], '30');
      expect(map['supportUrl'], 'https://reclash.example.com');
    });

    test('converts the compatibility interval from hours to minutes', () {
      final map = normalizePanelHeaders({
        'profile-update-interval': ['5'],
      });

      expect(map['updateIntervalMinutes'], '300');
    });

    test('drops unknown and empty headers', () {
      final map = normalizePanelHeaders({
        'x-unknown-panel-header': ['value'],
        'profile-update-interval': ['  '],
        'another': ['', 'ignored'],
      });

      expect(map, isEmpty);
    });

    test('ignores non-positive intervals', () {
      for (final value in ['0', '-3', 'abc']) {
        final map = normalizePanelHeaders({
          'profile-update-interval': [value],
        });
        expect(map, isEmpty, reason: 'interval "$value" must not apply');
      }
    });
  });

  group('PanelMeta.fromHeaders', () {
    test('parses verdicts and interval', () {
      final meta = PanelMeta.fromHeaders({
        'x-hwid-max-devices-reached': ['true'],
        'x-hwid-not-supported': ['True'],
        'announce': ['limit text'],
        'support-url': ['https://support.example.com'],
        'reclash-autoupdateinterval': ['45'],
      });

      expect(meta.hwidMaxDevicesReached, isTrue);
      expect(meta.hwidNotSupported, isTrue);
      expect(meta.announce, 'limit text');
      expect(meta.supportUrl, 'https://support.example.com');
      expect(meta.updateIntervalMinutes, 45);
      expect(meta.hasContent, isTrue);
    });

    test('empty response yields inert meta', () {
      final meta = PanelMeta.fromHeaders({
        'content-type': ['application/yaml'],
        'server': ['nginx'],
      });

      expect(meta, const PanelMeta());
      expect(meta.hasContent, isFalse);
    });
  });
}
